From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 02/20] ipvs: reorganize tot_stats
Date: Mon, 14 Mar 2011 12:45:28 +0900
Message-ID: <1300074346-13799-3-git-send-email-horms@verge.net.au>
References: <1300074346-13799-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300074346-13799-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

 	The global tot_stats contains cpustats field just like the
stats for dest and svc, so better use it to simplify the usage
in estimation_timer. As tot_stats is registered as estimator
we can remove the special ip_vs_read_cpu_stats call for
tot_stats. Fix ip_vs_read_cpu_stats to be called under
stats lock because it is still used as synchronization between
estimation timer and user context (the stats readers).

 	Also, make sure ip_vs_stats_percpu_show reads properly
the u64 stats from user context.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |    3 +-
 net/netfilter/ipvs/ip_vs_core.c |    6 ++--
 net/netfilter/ipvs/ip_vs_ctl.c  |   45 ++++++++++++++++++++------------------
 net/netfilter/ipvs/ip_vs_est.c  |    3 +-
 4 files changed, 29 insertions(+), 28 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 091ca1f..9db750d 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -851,8 +851,7 @@ struct netns_ipvs {
 	atomic_t		conn_count;      /*  connection counter */
 
 	/* ip_vs_ctl */
-	struct ip_vs_stats		*tot_stats;  /* Statistics & est. */
-	struct ip_vs_cpu_stats __percpu *cpustats;   /* Stats per cpu */
+	struct ip_vs_stats		tot_stats;  /* Statistics & est. */
 	seqcount_t			*ustats_seq; /* u64 read retry */
 
 	int			num_services;    /* no of virtual services */
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 2d1f932..6f4940e 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -132,7 +132,7 @@ ip_vs_in_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 		s->ustats.inbytes += skb->len;
 		u64_stats_update_end(&s->syncp);
 
-		s = this_cpu_ptr(ipvs->cpustats);
+		s = this_cpu_ptr(ipvs->tot_stats.cpustats);
 		s->ustats.inpkts++;
 		u64_stats_update_begin(&s->syncp);
 		s->ustats.inbytes += skb->len;
@@ -162,7 +162,7 @@ ip_vs_out_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 		s->ustats.outbytes += skb->len;
 		u64_stats_update_end(&s->syncp);
 
-		s = this_cpu_ptr(ipvs->cpustats);
+		s = this_cpu_ptr(ipvs->tot_stats.cpustats);
 		s->ustats.outpkts++;
 		u64_stats_update_begin(&s->syncp);
 		s->ustats.outbytes += skb->len;
@@ -183,7 +183,7 @@ ip_vs_conn_stats(struct ip_vs_conn *cp, struct ip_vs_service *svc)
 	s = this_cpu_ptr(svc->stats.cpustats);
 	s->ustats.conns++;
 
-	s = this_cpu_ptr(ipvs->cpustats);
+	s = this_cpu_ptr(ipvs->tot_stats.cpustats);
 	s->ustats.conns++;
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index f0369d6..a2a67ad 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1481,7 +1481,7 @@ static int ip_vs_zero_all(struct net *net)
 		}
 	}
 
-	ip_vs_zero_stats(net_ipvs(net)->tot_stats);
+	ip_vs_zero_stats(&net_ipvs(net)->tot_stats);
 	return 0;
 }
 
@@ -1963,7 +1963,7 @@ static const struct file_operations ip_vs_info_fops = {
 static int ip_vs_stats_show(struct seq_file *seq, void *v)
 {
 	struct net *net = seq_file_single_net(seq);
-	struct ip_vs_stats *tot_stats = net_ipvs(net)->tot_stats;
+	struct ip_vs_stats *tot_stats = &net_ipvs(net)->tot_stats;
 
 /*               01234567 01234567 01234567 0123456701234567 0123456701234567 */
 	seq_puts(seq,
@@ -2007,7 +2007,8 @@ static const struct file_operations ip_vs_stats_fops = {
 static int ip_vs_stats_percpu_show(struct seq_file *seq, void *v)
 {
 	struct net *net = seq_file_single_net(seq);
-	struct ip_vs_stats *tot_stats = net_ipvs(net)->tot_stats;
+	struct ip_vs_stats *tot_stats = &net_ipvs(net)->tot_stats;
+	struct ip_vs_cpu_stats *cpustats = tot_stats->cpustats;
 	int i;
 
 /*               01234567 01234567 01234567 0123456701234567 0123456701234567 */
@@ -2017,11 +2018,20 @@ static int ip_vs_stats_percpu_show(struct seq_file *seq, void *v)
 		   "CPU    Conns  Packets  Packets            Bytes            Bytes\n");
 
 	for_each_possible_cpu(i) {
-		struct ip_vs_cpu_stats *u = per_cpu_ptr(net->ipvs->cpustats, i);
+		struct ip_vs_cpu_stats *u = per_cpu_ptr(cpustats, i);
+		unsigned int start;
+		__u64 inbytes, outbytes;
+
+		do {
+			start = u64_stats_fetch_begin_bh(&u->syncp);
+			inbytes = u->ustats.inbytes;
+			outbytes = u->ustats.outbytes;
+		} while (u64_stats_fetch_retry_bh(&u->syncp, start));
+
 		seq_printf(seq, "%3X %8X %8X %8X %16LX %16LX\n",
-			    i, u->ustats.conns, u->ustats.inpkts,
-			    u->ustats.outpkts, (__u64)u->ustats.inbytes,
-			    (__u64)u->ustats.outbytes);
+			   i, u->ustats.conns, u->ustats.inpkts,
+			   u->ustats.outpkts, (__u64)inbytes,
+			   (__u64)outbytes);
 	}
 
 	spin_lock_bh(&tot_stats->lock);
@@ -3505,17 +3515,12 @@ int __net_init __ip_vs_control_init(struct net *net)
 	atomic_set(&ipvs->nullsvc_counter, 0);
 
 	/* procfs stats */
-	ipvs->tot_stats = kzalloc(sizeof(struct ip_vs_stats), GFP_KERNEL);
-	if (ipvs->tot_stats == NULL) {
-		pr_err("%s(): no memory.\n", __func__);
-		return -ENOMEM;
-	}
-	ipvs->cpustats = alloc_percpu(struct ip_vs_cpu_stats);
-	if (!ipvs->cpustats) {
+	ipvs->tot_stats.cpustats = alloc_percpu(struct ip_vs_cpu_stats);
+	if (!ipvs->tot_stats.cpustats) {
 		pr_err("%s() alloc_percpu failed\n", __func__);
 		goto err_alloc;
 	}
-	spin_lock_init(&ipvs->tot_stats->lock);
+	spin_lock_init(&ipvs->tot_stats.lock);
 
 	proc_net_fops_create(net, "ip_vs", 0, &ip_vs_info_fops);
 	proc_net_fops_create(net, "ip_vs_stats", 0, &ip_vs_stats_fops);
@@ -3563,7 +3568,7 @@ int __net_init __ip_vs_control_init(struct net *net)
 		goto err_dup;
 	}
 #endif
-	ip_vs_new_estimator(net, ipvs->tot_stats);
+	ip_vs_new_estimator(net, &ipvs->tot_stats);
 	ipvs->sysctl_tbl = tbl;
 	/* Schedule defense work */
 	INIT_DELAYED_WORK(&ipvs->defense_work, defense_work_handler);
@@ -3571,9 +3576,8 @@ int __net_init __ip_vs_control_init(struct net *net)
 	return 0;
 
 err_dup:
-	free_percpu(ipvs->cpustats);
+	free_percpu(ipvs->tot_stats.cpustats);
 err_alloc:
-	kfree(ipvs->tot_stats);
 	return -ENOMEM;
 }
 
@@ -3582,7 +3586,7 @@ static void __net_exit __ip_vs_control_cleanup(struct net *net)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	ip_vs_trash_cleanup(net);
-	ip_vs_kill_estimator(net, ipvs->tot_stats);
+	ip_vs_kill_estimator(net, &ipvs->tot_stats);
 	cancel_delayed_work_sync(&ipvs->defense_work);
 	cancel_work_sync(&ipvs->defense_work.work);
 #ifdef CONFIG_SYSCTL
@@ -3591,8 +3595,7 @@ static void __net_exit __ip_vs_control_cleanup(struct net *net)
 	proc_net_remove(net, "ip_vs_stats_percpu");
 	proc_net_remove(net, "ip_vs_stats");
 	proc_net_remove(net, "ip_vs");
-	free_percpu(ipvs->cpustats);
-	kfree(ipvs->tot_stats);
+	free_percpu(ipvs->tot_stats.cpustats);
 }
 
 static struct pernet_operations ipvs_control_ops = {
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 88bd716..b3751cf 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -101,13 +101,12 @@ static void estimation_timer(unsigned long arg)
 	struct netns_ipvs *ipvs;
 
 	ipvs = net_ipvs(net);
-	ip_vs_read_cpu_stats(&ipvs->tot_stats->ustats, ipvs->cpustats);
 	spin_lock(&ipvs->est_lock);
 	list_for_each_entry(e, &ipvs->est_list, list) {
 		s = container_of(e, struct ip_vs_stats, est);
 
-		ip_vs_read_cpu_stats(&s->ustats, s->cpustats);
 		spin_lock(&s->lock);
+		ip_vs_read_cpu_stats(&s->ustats, s->cpustats);
 		n_conns = s->ustats.conns;
 		n_inpkts = s->ustats.inpkts;
 		n_outpkts = s->ustats.outpkts;
-- 
1.7.2.3

