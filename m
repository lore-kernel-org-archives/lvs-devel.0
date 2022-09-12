From: Julian Anastasov <ja@ssi.bg>
Subject: [RFC PATCHv3 2/5] ipvs: use kthreads for stats estimation
Date: Mon, 12 Sep 2022 13:18:35 +0300
Message-ID: <20220912101838.12522-3-ja@ssi.bg>
References: <20220912101838.12522-1-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20220912101838.12522-1-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jiri Wiesner <jwiesner@suse.de>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

Estimating all entries in single list in timer context
causes large latency with multiple rules.

Spread the estimator structures in multiple chains and
use kthread(s) for the estimation. Every chain is
processed under RCU lock. The kthreads are tuned
for maximum number of estimators to process.

We also add delayed work est_reload_work that will
make sure the kthread tasks are properly started/stopped.

ip_vs_start_estimator() is changed to report errors
which allows to safely store the estimators in
allocated structures.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h            |  65 ++++-
 net/netfilter/ipvs/ip_vs_ctl.c | 137 +++++++---
 net/netfilter/ipvs/ip_vs_est.c | 465 ++++++++++++++++++++++++++++-----
 3 files changed, 564 insertions(+), 103 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index bd8ae137e43b..4668acce4bf3 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -365,7 +365,7 @@ struct ip_vs_cpu_stats {
 
 /* IPVS statistics objects */
 struct ip_vs_estimator {
-	struct list_head	list;
+	struct hlist_node	list;
 
 	u64			last_inbytes;
 	u64			last_outbytes;
@@ -378,6 +378,52 @@ struct ip_vs_estimator {
 	u64			outpps;
 	u64			inbps;
 	u64			outbps;
+
+	u32			ktid:16,	/* kthread ID */
+				ktrow:8,	/* row ID for kthread */
+				ktcid:8;	/* chain ID for kthread */
+};
+
+/* Process estimators in multiple timer ticks */
+#define IPVS_EST_NTICKS		50
+/* Estimation uses a 2-second period */
+#define IPVS_EST_TICK		((2 * HZ) / IPVS_EST_NTICKS)
+
+/* Desired number of chains per tick */
+#define IPVS_EST_CHAIN_FACTOR	48
+
+/* Compiled number of chains per tick
+ * The defines should match cond_resched_rcu
+ */
+#if defined(CONFIG_DEBUG_ATOMIC_SLEEP) || !defined(CONFIG_PREEMPT_RCU)
+#define IPVS_EST_TICK_CHAINS	IPVS_EST_CHAIN_FACTOR
+#else
+#define IPVS_EST_TICK_CHAINS	1
+#endif
+
+/* Multiple chains processed in same tick */
+struct ip_vs_est_tick_data {
+	struct hlist_head	chains[IPVS_EST_TICK_CHAINS];
+	DECLARE_BITMAP(present, IPVS_EST_TICK_CHAINS);
+	DECLARE_BITMAP(full, IPVS_EST_TICK_CHAINS);
+	int			chain_len[IPVS_EST_TICK_CHAINS];
+};
+
+/* Context for estimation kthread */
+struct ip_vs_est_kt_data {
+	struct netns_ipvs	*ipvs;
+	struct task_struct	*task;		/* task if running */
+	struct ip_vs_est_tick_data __rcu *ticks[IPVS_EST_NTICKS];
+	DECLARE_BITMAP(avail, IPVS_EST_NTICKS);	/* tick has space for ests */
+	unsigned long		est_timer;	/* estimation timer (jiffies) */
+	int			tick_len[IPVS_EST_NTICKS];	/* est count */
+	int			id;		/* ktid per netns */
+	int			chain_max_len;	/* max ests per tick chain */
+	int			tick_max_len;	/* max ests per tick */
+	int			est_count;	/* attached ests to kthread */
+	int			est_max_count;	/* max ests per kthread */
+	int			add_row;	/* row for new ests */
+	int			est_row;	/* estimated row */
 };
 
 /*
@@ -948,9 +994,14 @@ struct netns_ipvs {
 	struct ctl_table_header	*lblcr_ctl_header;
 	struct ctl_table	*lblcr_ctl_table;
 	/* ip_vs_est */
-	struct list_head	est_list;	/* estimator list */
-	spinlock_t		est_lock;
-	struct timer_list	est_timer;	/* Estimation timer */
+	struct delayed_work	est_reload_work;/* Reload kthread tasks */
+	struct mutex		est_mutex;	/* protect kthread tasks */
+	struct ip_vs_est_kt_data **est_kt_arr;	/* Array of kthread data ptrs */
+	unsigned long		est_max_threads;/* rlimit */
+	int			est_kt_count;	/* Allocated ptrs */
+	int			est_add_ktid;	/* ktid where to add ests */
+	atomic_t		est_genid;	/* kthreads reload genid */
+	atomic_t		est_genid_done;	/* applied genid */
 	/* ip_vs_sync */
 	spinlock_t		sync_lock;
 	struct ipvs_master_sync_state *ms;
@@ -1481,10 +1532,14 @@ int stop_sync_thread(struct netns_ipvs *ipvs, int state);
 void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts);
 
 /* IPVS rate estimator prototypes (from ip_vs_est.c) */
-void ip_vs_start_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats);
+int ip_vs_start_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats);
 void ip_vs_stop_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats);
 void ip_vs_zero_estimator(struct ip_vs_stats *stats);
 void ip_vs_read_estimator(struct ip_vs_kstats *dst, struct ip_vs_stats *stats);
+void ip_vs_est_reload_start(struct netns_ipvs *ipvs);
+int ip_vs_est_kthread_start(struct netns_ipvs *ipvs,
+			    struct ip_vs_est_kt_data *kd);
+void ip_vs_est_kthread_stop(struct ip_vs_est_kt_data *kd);
 
 /* Various IPVS packet transmitters (from ip_vs_xmit.c) */
 int ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 44c79fd1779c..d84052d9d43b 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -241,6 +241,46 @@ static void defense_work_handler(struct work_struct *work)
 }
 #endif
 
+static void est_reload_work_handler(struct work_struct *work)
+{
+	struct netns_ipvs *ipvs =
+		container_of(work, struct netns_ipvs, est_reload_work.work);
+	int genid = atomic_read(&ipvs->est_genid);
+	int genid_done = atomic_read(&ipvs->est_genid_done);
+	unsigned long delay = HZ / 10;	/* repeat startups after failure */
+	bool repeat = false;
+	int id;
+
+	mutex_lock(&ipvs->est_mutex);
+	for (id = 0; id < ipvs->est_kt_count; id++) {
+		struct ip_vs_est_kt_data *kd = ipvs->est_kt_arr[id];
+
+		/* netns clean up started, abort delayed work */
+		if (!ipvs->enable)
+			goto unlock;
+		if (!kd)
+			continue;
+		/* New config ? Stop kthread tasks */
+		if (genid != genid_done)
+			ip_vs_est_kthread_stop(kd);
+		if (!kd->task && ip_vs_est_kthread_start(ipvs, kd) < 0)
+			repeat = true;
+	}
+
+	atomic_set(&ipvs->est_genid_done, genid);
+
+unlock:
+	mutex_unlock(&ipvs->est_mutex);
+
+	if (!ipvs->enable)
+		return;
+	if (genid != atomic_read(&ipvs->est_genid))
+		delay = 1;
+	else if (!repeat)
+		return;
+	queue_delayed_work(system_long_wq, &ipvs->est_reload_work, delay);
+}
+
 int
 ip_vs_use_count_inc(void)
 {
@@ -831,7 +871,7 @@ ip_vs_copy_stats(struct ip_vs_kstats *dst, struct ip_vs_stats *src)
 {
 #define IP_VS_SHOW_STATS_COUNTER(c) dst->c = src->kstats.c - src->kstats0.c
 
-	spin_lock_bh(&src->lock);
+	spin_lock(&src->lock);
 
 	IP_VS_SHOW_STATS_COUNTER(conns);
 	IP_VS_SHOW_STATS_COUNTER(inpkts);
@@ -841,7 +881,7 @@ ip_vs_copy_stats(struct ip_vs_kstats *dst, struct ip_vs_stats *src)
 
 	ip_vs_read_estimator(dst, src);
 
-	spin_unlock_bh(&src->lock);
+	spin_unlock(&src->lock);
 }
 
 static void
@@ -862,7 +902,7 @@ ip_vs_export_stats_user(struct ip_vs_stats_user *dst, struct ip_vs_kstats *src)
 static void
 ip_vs_zero_stats(struct ip_vs_stats *stats)
 {
-	spin_lock_bh(&stats->lock);
+	spin_lock(&stats->lock);
 
 	/* get current counters as zero point, rates are zeroed */
 
@@ -876,7 +916,7 @@ ip_vs_zero_stats(struct ip_vs_stats *stats)
 
 	ip_vs_zero_estimator(stats);
 
-	spin_unlock_bh(&stats->lock);
+	spin_unlock(&stats->lock);
 }
 
 /*
@@ -957,7 +997,6 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	spin_unlock_bh(&dest->dst_lock);
 
 	if (add) {
-		ip_vs_start_estimator(svc->ipvs, &dest->stats);
 		list_add_rcu(&dest->n_list, &svc->destinations);
 		svc->num_dests++;
 		sched = rcu_dereference_protected(svc->scheduler, 1);
@@ -979,6 +1018,7 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 {
 	struct ip_vs_dest *dest;
 	unsigned int atype, i;
+	int ret;
 
 	EnterFunction(2);
 
@@ -1003,9 +1043,10 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 			return -EINVAL;
 	}
 
+	ret = -ENOMEM;
 	dest = kzalloc(sizeof(struct ip_vs_dest), GFP_KERNEL);
 	if (dest == NULL)
-		return -ENOMEM;
+		goto err;
 
 	dest->stats.cpustats = alloc_percpu(struct ip_vs_cpu_stats);
 	if (!dest->stats.cpustats)
@@ -1017,6 +1058,12 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 		u64_stats_init(&ip_vs_dest_stats->syncp);
 	}
 
+	spin_lock_init(&dest->stats.lock);
+
+	ret = ip_vs_start_estimator(svc->ipvs, &dest->stats);
+	if (ret < 0)
+		goto err_cpustats;
+
 	dest->af = udest->af;
 	dest->protocol = svc->protocol;
 	dest->vaddr = svc->addr;
@@ -1032,15 +1079,19 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 
 	INIT_HLIST_NODE(&dest->d_list);
 	spin_lock_init(&dest->dst_lock);
-	spin_lock_init(&dest->stats.lock);
 	__ip_vs_update_dest(svc, dest, udest, 1);
 
 	LeaveFunction(2);
 	return 0;
 
+err_cpustats:
+	free_percpu(dest->stats.cpustats);
+
 err_alloc:
 	kfree(dest);
-	return -ENOMEM;
+
+err:
+	return ret;
 }
 
 
@@ -1102,14 +1153,18 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 			      IP_VS_DBG_ADDR(svc->af, &dest->vaddr),
 			      ntohs(dest->vport));
 
+		ret = ip_vs_start_estimator(svc->ipvs, &dest->stats);
+		if (ret < 0)
+			goto err;
 		__ip_vs_update_dest(svc, dest, udest, 1);
-		ret = 0;
 	} else {
 		/*
 		 * Allocate and initialize the dest structure
 		 */
 		ret = ip_vs_new_dest(svc, udest);
 	}
+
+err:
 	LeaveFunction(2);
 
 	return ret;
@@ -1397,6 +1452,10 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 		sched = NULL;
 	}
 
+	ret = ip_vs_start_estimator(ipvs, &svc->stats);
+	if (ret < 0)
+		goto out_err;
+
 	/* Bind the ct retriever */
 	RCU_INIT_POINTER(svc->pe, pe);
 	pe = NULL;
@@ -1409,8 +1468,6 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 	if (svc->pe && svc->pe->conn_out)
 		atomic_inc(&ipvs->conn_out_counter);
 
-	ip_vs_start_estimator(ipvs, &svc->stats);
-
 	/* Count only IPv4 services for old get/setsockopt interface */
 	if (svc->af == AF_INET)
 		ipvs->num_services++;
@@ -1421,8 +1478,15 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 	ip_vs_svc_hash(svc);
 
 	*svc_p = svc;
-	/* Now there is a service - full throttle */
-	ipvs->enable = 1;
+
+	if (!ipvs->enable) {
+		/* Now there is a service - full throttle */
+		ipvs->enable = 1;
+
+		/* Start estimation for first time */
+		ip_vs_est_reload_start(ipvs);
+	}
+
 	return 0;
 
 
@@ -2311,13 +2375,13 @@ static int ip_vs_stats_percpu_show(struct seq_file *seq, void *v)
 		u64 conns, inpkts, outpkts, inbytes, outbytes;
 
 		do {
-			start = u64_stats_fetch_begin_irq(&u->syncp);
+			start = u64_stats_fetch_begin(&u->syncp);
 			conns = u->cnt.conns;
 			inpkts = u->cnt.inpkts;
 			outpkts = u->cnt.outpkts;
 			inbytes = u->cnt.inbytes;
 			outbytes = u->cnt.outbytes;
-		} while (u64_stats_fetch_retry_irq(&u->syncp, start));
+		} while (u64_stats_fetch_retry(&u->syncp, start));
 
 		seq_printf(seq, "%3X %8LX %8LX %8LX %16LX %16LX\n",
 			   i, (u64)conns, (u64)inpkts,
@@ -4041,13 +4105,16 @@ static void ip_vs_genl_unregister(void)
 static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 {
 	struct net *net = ipvs->net;
-	int idx;
 	struct ctl_table *tbl;
+	int idx, ret;
 
 	atomic_set(&ipvs->dropentry, 0);
 	spin_lock_init(&ipvs->dropentry_lock);
 	spin_lock_init(&ipvs->droppacket_lock);
 	spin_lock_init(&ipvs->securetcp_lock);
+	INIT_DELAYED_WORK(&ipvs->defense_work, defense_work_handler);
+	INIT_DELAYED_WORK(&ipvs->expire_nodest_conn_work,
+			  expire_nodest_conn_handler);
 
 	if (!net_eq(net, &init_net)) {
 		tbl = kmemdup(vs_vars, sizeof(vs_vars), GFP_KERNEL);
@@ -4115,24 +4182,27 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 		tbl[idx++].mode = 0444;
 #endif
 
+	ret = -ENOMEM;
 	ipvs->sysctl_hdr = register_net_sysctl(net, "net/ipv4/vs", tbl);
-	if (ipvs->sysctl_hdr == NULL) {
-		if (!net_eq(net, &init_net))
-			kfree(tbl);
-		return -ENOMEM;
-	}
+	if (!ipvs->sysctl_hdr)
+		goto err;
 	ipvs->sysctl_tbl = tbl;
+
+	ret = ip_vs_start_estimator(ipvs, &ipvs->tot_stats->s);
+	if (ret < 0)
+		goto err;
+
 	/* Schedule defense work */
-	INIT_DELAYED_WORK(&ipvs->defense_work, defense_work_handler);
 	queue_delayed_work(system_long_wq, &ipvs->defense_work,
 			   DEFENSE_TIMER_PERIOD);
 
-	/* Init delayed work for expiring no dest conn */
-	INIT_DELAYED_WORK(&ipvs->expire_nodest_conn_work,
-			  expire_nodest_conn_handler);
-
-	ip_vs_start_estimator(ipvs, &ipvs->tot_stats->s);
 	return 0;
+
+err:
+	unregister_net_sysctl_table(ipvs->sysctl_hdr);
+	if (!net_eq(net, &init_net))
+		kfree(tbl);
+	return ret;
 }
 
 static void __net_exit ip_vs_control_net_cleanup_sysctl(struct netns_ipvs *ipvs)
@@ -4165,6 +4235,7 @@ static struct notifier_block ip_vs_dst_notifier = {
 
 int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 {
+	int ret = -ENOMEM;
 	int i, idx;
 
 	/* Initialize rs_table */
@@ -4178,10 +4249,12 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 	atomic_set(&ipvs->nullsvc_counter, 0);
 	atomic_set(&ipvs->conn_out_counter, 0);
 
+	INIT_DELAYED_WORK(&ipvs->est_reload_work, est_reload_work_handler);
+
 	/* procfs stats */
 	ipvs->tot_stats = kzalloc(sizeof(*ipvs->tot_stats), GFP_KERNEL);
 	if (!ipvs->tot_stats)
-		return -ENOMEM;
+		goto out;
 	ipvs->tot_stats->s.cpustats = alloc_percpu(struct ip_vs_cpu_stats);
 	if (!ipvs->tot_stats->s.cpustats)
 		goto err_tot_stats;
@@ -4207,7 +4280,8 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 		goto err_percpu;
 #endif
 
-	if (ip_vs_control_net_init_sysctl(ipvs))
+	ret = ip_vs_control_net_init_sysctl(ipvs);
+	if (ret < 0)
 		goto err;
 
 	return 0;
@@ -4228,13 +4302,16 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 
 err_tot_stats:
 	kfree(ipvs->tot_stats);
-	return -ENOMEM;
+
+out:
+	return ret;
 }
 
 void __net_exit ip_vs_control_net_cleanup(struct netns_ipvs *ipvs)
 {
 	ip_vs_trash_cleanup(ipvs);
 	ip_vs_control_net_cleanup_sysctl(ipvs);
+	cancel_delayed_work_sync(&ipvs->est_reload_work);
 #ifdef CONFIG_PROC_FS
 	remove_proc_entry("ip_vs_stats_percpu", ipvs->net->proc_net);
 	remove_proc_entry("ip_vs_stats", ipvs->net->proc_net);
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 9a1a7af6a186..06da6a4ba357 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -30,9 +30,6 @@
   long interval, it is easy to implement a user level daemon which
   periodically reads those statistical counters and measure rate.
 
-  Currently, the measurement is activated by slow timer handler. Hope
-  this measurement will not introduce too much load.
-
   We measure rate during the last 8 seconds every 2 seconds:
 
     avgrate = avgrate*(1-W) + rate*W
@@ -47,68 +44,70 @@
     to 32-bit values for conns, packets, bps, cps and pps.
 
   * A lot of code is taken from net/core/gen_estimator.c
- */
-
 
-/*
- * Make a summary from each cpu
+  KEY POINTS:
+  - cpustats counters are updated per-cpu in SoftIRQ context with BH disabled
+  - kthreads read the cpustats to update the estimators (svcs, dests, total)
+  - the states of estimators can be read (get stats) or modified (zero stats)
+    from processes
+
+  KTHREADS:
+  - kthread contexts are created and attached to array
+  - the kthread tasks are created when first service is added, before that
+    the total stats are not estimated
+  - the kthread context holds lists with estimators (chains) which are
+    processed every 2 seconds
+  - as estimators can be added dynamically and in bursts, we try to spread
+    them to multiple chains which are estimated at different time
+  - est_add_ktid: ktid where to add new ests, can point to empty slot where
+    we should add kt data
  */
-static void ip_vs_read_cpu_stats(struct ip_vs_kstats *sum,
-				 struct ip_vs_cpu_stats __percpu *stats)
-{
-	int i;
-	bool add = false;
-
-	for_each_possible_cpu(i) {
-		struct ip_vs_cpu_stats *s = per_cpu_ptr(stats, i);
-		unsigned int start;
-		u64 conns, inpkts, outpkts, inbytes, outbytes;
-
-		if (add) {
-			do {
-				start = u64_stats_fetch_begin(&s->syncp);
-				conns = s->cnt.conns;
-				inpkts = s->cnt.inpkts;
-				outpkts = s->cnt.outpkts;
-				inbytes = s->cnt.inbytes;
-				outbytes = s->cnt.outbytes;
-			} while (u64_stats_fetch_retry(&s->syncp, start));
-			sum->conns += conns;
-			sum->inpkts += inpkts;
-			sum->outpkts += outpkts;
-			sum->inbytes += inbytes;
-			sum->outbytes += outbytes;
-		} else {
-			add = true;
-			do {
-				start = u64_stats_fetch_begin(&s->syncp);
-				sum->conns = s->cnt.conns;
-				sum->inpkts = s->cnt.inpkts;
-				sum->outpkts = s->cnt.outpkts;
-				sum->inbytes = s->cnt.inbytes;
-				sum->outbytes = s->cnt.outbytes;
-			} while (u64_stats_fetch_retry(&s->syncp, start));
-		}
-	}
-}
 
+static struct lock_class_key __ipvs_est_key;
 
-static void estimation_timer(struct timer_list *t)
+static void ip_vs_chain_estimation(struct ip_vs_est_tick_data *td, int cid)
 {
+	struct hlist_head *chain = &td->chains[cid];
 	struct ip_vs_estimator *e;
+	struct ip_vs_cpu_stats *c;
 	struct ip_vs_stats *s;
 	u64 rate;
-	struct netns_ipvs *ipvs = from_timer(ipvs, t, est_timer);
 
-	if (!sysctl_run_estimation(ipvs))
-		goto skip;
+	hlist_for_each_entry_rcu(e, chain, list) {
+		u64 conns, inpkts, outpkts, inbytes, outbytes;
+		u64 kconns = 0, kinpkts = 0, koutpkts = 0;
+		u64 kinbytes = 0, koutbytes = 0;
+		unsigned int start;
+		int i;
+
+		if (kthread_should_stop())
+			break;
 
-	spin_lock(&ipvs->est_lock);
-	list_for_each_entry(e, &ipvs->est_list, list) {
 		s = container_of(e, struct ip_vs_stats, est);
+		for_each_possible_cpu(i) {
+			c = per_cpu_ptr(s->cpustats, i);
+			do {
+				start = u64_stats_fetch_begin(&c->syncp);
+				conns = c->cnt.conns;
+				inpkts = c->cnt.inpkts;
+				outpkts = c->cnt.outpkts;
+				inbytes = c->cnt.inbytes;
+				outbytes = c->cnt.outbytes;
+			} while (u64_stats_fetch_retry(&c->syncp, start));
+			kconns += conns;
+			kinpkts += inpkts;
+			koutpkts += outpkts;
+			kinbytes += inbytes;
+			koutbytes += outbytes;
+		}
 
 		spin_lock(&s->lock);
-		ip_vs_read_cpu_stats(&s->kstats, s->cpustats);
+
+		s->kstats.conns = kconns;
+		s->kstats.inpkts = kinpkts;
+		s->kstats.outpkts = koutpkts;
+		s->kstats.inbytes = kinbytes;
+		s->kstats.outbytes = koutbytes;
 
 		/* scaled by 2^10, but divided 2 seconds */
 		rate = (s->kstats.conns - e->last_conns) << 9;
@@ -133,30 +132,353 @@ static void estimation_timer(struct timer_list *t)
 		e->outbps += ((s64)rate - (s64)e->outbps) >> 2;
 		spin_unlock(&s->lock);
 	}
-	spin_unlock(&ipvs->est_lock);
+}
+
+static void ip_vs_tick_estimation(struct ip_vs_est_kt_data *kd, int row)
+{
+	struct ip_vs_est_tick_data *td;
+	int cid;
+
+	rcu_read_lock();
+	td = rcu_dereference(kd->ticks[row]);
+	if (!td)
+		goto out;
+	for_each_set_bit(cid, td->present, IPVS_EST_TICK_CHAINS) {
+		if (kthread_should_stop())
+			break;
+		ip_vs_chain_estimation(td, cid);
+		cond_resched_rcu();
+		td = rcu_dereference(kd->ticks[row]);
+		if (!td)
+			break;
+	}
+
+out:
+	rcu_read_unlock();
+}
+
+static int ip_vs_estimation_kthread(void *data)
+{
+	struct ip_vs_est_kt_data *kd = data;
+	struct netns_ipvs *ipvs = kd->ipvs;
+	int row = kd->est_row;
+	unsigned long now;
+	long gap;
+
+	while (1) {
+		set_current_state(TASK_IDLE);
+		if (kthread_should_stop())
+			break;
+
+		/* before estimation, check if we should sleep */
+		now = READ_ONCE(jiffies);
+		gap = kd->est_timer - now;
+		if (gap > 0) {
+			if (gap > IPVS_EST_TICK) {
+				kd->est_timer = now - IPVS_EST_TICK;
+				gap = IPVS_EST_TICK;
+			}
+			schedule_timeout(gap);
+		} else {
+			__set_current_state(TASK_RUNNING);
+			if (gap < -8 * IPVS_EST_TICK)
+				kd->est_timer = now;
+		}
+
+		if (sysctl_run_estimation(ipvs) && kd->tick_len[row])
+			ip_vs_tick_estimation(kd, row);
+
+		row++;
+		if (row >= IPVS_EST_NTICKS)
+			row = 0;
+		kd->est_row = row;
+		kd->est_timer += IPVS_EST_TICK;
+	}
+	__set_current_state(TASK_RUNNING);
+
+	return 0;
+}
+
+/* Schedule stop/start for kthread tasks */
+void ip_vs_est_reload_start(struct netns_ipvs *ipvs)
+{
+	/* Ignore reloads before first service is added */
+	if (!ipvs->enable)
+		return;
+	/* Bump the kthread configuration genid */
+	atomic_inc(&ipvs->est_genid);
+	queue_delayed_work(system_long_wq, &ipvs->est_reload_work, 0);
+}
+
+/* Start kthread task with current configuration */
+int ip_vs_est_kthread_start(struct netns_ipvs *ipvs,
+			    struct ip_vs_est_kt_data *kd)
+{
+	unsigned long now;
+	int ret = 0;
+	long gap;
+
+	lockdep_assert_held(&ipvs->est_mutex);
+
+	if (kd->task)
+		goto out;
+	now = READ_ONCE(jiffies);
+	gap = kd->est_timer - now;
+	/* Sync est_timer if task is starting later */
+	if (abs(gap) > 4 * IPVS_EST_TICK)
+		kd->est_timer = now;
+	kd->task = kthread_create(ip_vs_estimation_kthread, kd, "ipvs-e:%d:%d",
+				  ipvs->gen, kd->id);
+	if (IS_ERR(kd->task)) {
+		ret = PTR_ERR(kd->task);
+		kd->task = NULL;
+		goto out;
+	}
 
-skip:
-	mod_timer(&ipvs->est_timer, jiffies + 2*HZ);
+	pr_info("starting estimator thread %d...\n", kd->id);
+	wake_up_process(kd->task);
+
+out:
+	return ret;
+}
+
+void ip_vs_est_kthread_stop(struct ip_vs_est_kt_data *kd)
+{
+	if (kd->task) {
+		pr_info("stopping estimator thread %d...\n", kd->id);
+		kthread_stop(kd->task);
+		kd->task = NULL;
+	}
+}
+
+/* Create and start estimation kthread in a free or new array slot */
+static int ip_vs_est_add_kthread(struct netns_ipvs *ipvs)
+{
+	struct ip_vs_est_kt_data *kd = NULL;
+	int id = ipvs->est_kt_count;
+	int ret = -ENOMEM;
+	void *arr = NULL;
+	int i;
+
+	if (!ipvs->est_kt_arr)
+		ipvs->est_max_threads = rlimit(RLIMIT_NPROC);
+	if ((unsigned long)ipvs->est_kt_count >= ipvs->est_max_threads)
+		return -EINVAL;
+
+	mutex_lock(&ipvs->est_mutex);
+
+	for (i = 0; i < id; i++) {
+		if (!ipvs->est_kt_arr[i])
+			break;
+	}
+	if (i >= id) {
+		arr = krealloc_array(ipvs->est_kt_arr, id + 1,
+				     sizeof(struct ip_vs_est_kt_data *),
+				     GFP_KERNEL);
+		if (!arr)
+			goto out;
+		ipvs->est_kt_arr = arr;
+	} else {
+		id = i;
+	}
+	kd = kzalloc(sizeof(*kd), GFP_KERNEL);
+	if (!kd)
+		goto out;
+	kd->ipvs = ipvs;
+	bitmap_fill(kd->avail, IPVS_EST_NTICKS);
+	kd->est_timer = jiffies;
+	kd->id = id;
+	i = num_possible_cpus();
+	/* Attempt sub-100 microsecond cond_resched rate */
+	if (i < 2048)
+		kd->chain_max_len = max(1800 / i, 2);
+	else
+		kd->chain_max_len = 1;
+	/* We are using single chain on RCU preemption */
+	if (IPVS_EST_TICK_CHAINS == 1)
+		kd->chain_max_len *= IPVS_EST_CHAIN_FACTOR;
+	kd->tick_max_len = IPVS_EST_TICK_CHAINS * kd->chain_max_len;
+	kd->est_max_count = IPVS_EST_NTICKS * kd->tick_max_len;
+	/* Start kthread tasks only when services are present */
+	if (ipvs->enable) {
+		ret = ip_vs_est_kthread_start(ipvs, kd);
+		if (ret < 0)
+			goto out;
+	}
+
+	if (arr)
+		ipvs->est_kt_count++;
+	ipvs->est_kt_arr[id] = kd;
+	kd = NULL;
+	/* Use most recent kthread for new ests */
+	ipvs->est_add_ktid = id;
+	ret = 0;
+
+out:
+	mutex_unlock(&ipvs->est_mutex);
+	kfree(kd);
+
+	return ret;
+}
+
+/* Select ktid where to add new ests: available, unused or new slot */
+static void ip_vs_est_update_ktid(struct netns_ipvs *ipvs)
+{
+	int ktid, best = ipvs->est_kt_count;
+	struct ip_vs_est_kt_data *kd;
+
+	for (ktid = 0; ktid < ipvs->est_kt_count; ktid++) {
+		kd = ipvs->est_kt_arr[ktid];
+		if (kd) {
+			if (kd->est_count < kd->est_max_count) {
+				best = ktid;
+				break;
+			}
+		} else if (ktid < best) {
+			best = ktid;
+		}
+	}
+	ipvs->est_add_ktid = best;
 }
 
-void ip_vs_start_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
+/* Add estimator to current kthread (est_add_ktid) */
+int ip_vs_start_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
 {
 	struct ip_vs_estimator *est = &stats->est;
+	struct ip_vs_est_kt_data *kd = NULL;
+	struct ip_vs_est_tick_data *td;
+	int ktid, row, crow, cid, ret;
+
+	INIT_HLIST_NODE(&est->list);
+
+	if (ipvs->est_add_ktid < ipvs->est_kt_count) {
+		kd = ipvs->est_kt_arr[ipvs->est_add_ktid];
+		if (kd)
+			goto add_est;
+	}
+	ret = ip_vs_est_add_kthread(ipvs);
+	if (ret < 0)
+		goto out;
+	kd = ipvs->est_kt_arr[ipvs->est_add_ktid];
+
+add_est:
+	ktid = kd->id;
+	/* For small number of estimators prefer to use few ticks,
+	 * otherwise try to add into the last estimated row.
+	 * est_row and add_row point after the row we should use
+	 */
+	if (kd->est_count >= 2 * kd->tick_max_len)
+		crow = READ_ONCE(kd->est_row);
+	else
+		crow = kd->add_row;
+	crow--;
+	if (crow < 0)
+		crow = IPVS_EST_NTICKS - 1;
+	row = crow;
+	if (crow < IPVS_EST_NTICKS - 1) {
+		crow++;
+		row = find_last_bit(kd->avail, crow);
+	}
+	if (row >= crow)
+		row = find_last_bit(kd->avail, IPVS_EST_NTICKS);
+
+	td = rcu_dereference_protected(kd->ticks[row], 1);
+	if (!td) {
+		td = kzalloc(sizeof(*td), GFP_KERNEL);
+		if (!td) {
+			ret = -ENOMEM;
+			goto out;
+		}
+		rcu_assign_pointer(kd->ticks[row], td);
+	}
+
+	cid = find_first_zero_bit(td->full, IPVS_EST_TICK_CHAINS);
+
+	kd->est_count++;
+	kd->tick_len[row]++;
+	if (!td->chain_len[cid])
+		__set_bit(cid, td->present);
+	td->chain_len[cid]++;
+	est->ktid = ktid;
+	est->ktrow = row;
+	est->ktcid = cid;
+	hlist_add_head_rcu(&est->list, &td->chains[cid]);
+
+	if (td->chain_len[cid] >= kd->chain_max_len) {
+		__set_bit(cid, td->full);
+		if (kd->tick_len[row] >= kd->tick_max_len) {
+			__clear_bit(row, kd->avail);
+			/* Next time search from previous row */
+			kd->add_row = row;
+		}
+	}
+
+	/* Update est_add_ktid to point to first available/empty kt slot */
+	if (kd->est_count == kd->est_max_count)
+		ip_vs_est_update_ktid(ipvs);
 
-	INIT_LIST_HEAD(&est->list);
+out:
+	return ret;
+}
 
-	spin_lock_bh(&ipvs->est_lock);
-	list_add(&est->list, &ipvs->est_list);
-	spin_unlock_bh(&ipvs->est_lock);
+static void ip_vs_est_kthread_destroy(struct ip_vs_est_kt_data *kd)
+{
+	if (kd) {
+		if (kd->task)
+			kthread_stop(kd->task);
+		kfree(kd);
+	}
 }
 
+/* Unlink estimator from list */
 void ip_vs_stop_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
 {
 	struct ip_vs_estimator *est = &stats->est;
+	struct ip_vs_est_tick_data *td;
+	struct ip_vs_est_kt_data *kd;
+	int ktid = est->ktid;
+	int row = est->ktrow;
+	int cid = est->ktcid;
+
+	/* Failed to add to chain ? */
+	if (hlist_unhashed(&est->list))
+		return;
+
+	hlist_del_rcu(&est->list);
+	kd = ipvs->est_kt_arr[ktid];
+	td = rcu_dereference_protected(kd->ticks[row], 1);
+	__clear_bit(cid, td->full);
+	td->chain_len[cid]--;
+	if (!td->chain_len[cid])
+		__clear_bit(cid, td->present);
+	kd->tick_len[row]--;
+	__set_bit(row, kd->avail);
+	if (!kd->tick_len[row]) {
+		RCU_INIT_POINTER(kd->ticks[row], NULL);
+		kfree_rcu(td);
+	}
+	kd->est_count--;
+	if (kd->est_count) {
+		/* This kt slot can become available just now, prefer it */
+		if (ktid < ipvs->est_add_ktid)
+			ipvs->est_add_ktid = ktid;
+		return;
+	}
+
+	pr_info("stop unused estimator thread %d...\n", ktid);
 
-	spin_lock_bh(&ipvs->est_lock);
-	list_del(&est->list);
-	spin_unlock_bh(&ipvs->est_lock);
+	mutex_lock(&ipvs->est_mutex);
+
+	ip_vs_est_kthread_destroy(kd);
+	ipvs->est_kt_arr[ktid] = NULL;
+	if (ktid == ipvs->est_kt_count - 1)
+		ipvs->est_kt_count--;
+
+	mutex_unlock(&ipvs->est_mutex);
+
+	/* This slot is now empty, prefer another available kt slot */
+	if (ktid == ipvs->est_add_ktid)
+		ip_vs_est_update_ktid(ipvs);
 }
 
 void ip_vs_zero_estimator(struct ip_vs_stats *stats)
@@ -191,14 +513,21 @@ void ip_vs_read_estimator(struct ip_vs_kstats *dst, struct ip_vs_stats *stats)
 
 int __net_init ip_vs_estimator_net_init(struct netns_ipvs *ipvs)
 {
-	INIT_LIST_HEAD(&ipvs->est_list);
-	spin_lock_init(&ipvs->est_lock);
-	timer_setup(&ipvs->est_timer, estimation_timer, 0);
-	mod_timer(&ipvs->est_timer, jiffies + 2 * HZ);
+	ipvs->est_kt_arr = NULL;
+	ipvs->est_kt_count = 0;
+	ipvs->est_add_ktid = 0;
+	atomic_set(&ipvs->est_genid, 0);
+	atomic_set(&ipvs->est_genid_done, 0);
+	__mutex_init(&ipvs->est_mutex, "ipvs->est_mutex", &__ipvs_est_key);
 	return 0;
 }
 
 void __net_exit ip_vs_estimator_net_cleanup(struct netns_ipvs *ipvs)
 {
-	del_timer_sync(&ipvs->est_timer);
+	int i;
+
+	for (i = 0; i < ipvs->est_kt_count; i++)
+		ip_vs_est_kthread_destroy(ipvs->est_kt_arr[i]);
+	kfree(ipvs->est_kt_arr);
+	mutex_destroy(&ipvs->est_mutex);
 }
-- 
2.37.3


