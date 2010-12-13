From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [*v2 PATCH 13/22] IPVS: netns awareness to ip_vs_est
Date: Mon, 13 Dec 2010 14:38:21 +0100
Message-ID: <1292247510-753-14-git-send-email-hans.schillstrom@ericsson.com>
References: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

All variables moved to struct ipvs,
most external changes fixed (i.e. init_net removed)

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/ip_vs.h            |    4 +-
 include/net/netns/ip_vs.h      |    4 ++
 net/netfilter/ipvs/ip_vs_ctl.c |   20 ++++----
 net/netfilter/ipvs/ip_vs_est.c |  114 ++++++++++++++++++++++------------------
 4 files changed, 79 insertions(+), 63 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 5988c5d..34f8d2f 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1012,8 +1012,8 @@ extern void ip_vs_sync_cleanup(void);
  */
 extern int ip_vs_estimator_init(void);
 extern void ip_vs_estimator_cleanup(void);
-extern void ip_vs_new_estimator(struct ip_vs_stats *stats);
-extern void ip_vs_kill_estimator(struct ip_vs_stats *stats);
+extern void ip_vs_new_estimator(struct net *net, struct ip_vs_stats *stats);
+extern void ip_vs_kill_estimator(struct net *net, struct ip_vs_stats *stats);
 extern void ip_vs_zero_estimator(struct ip_vs_stats *stats);
 
 /*
diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
index f077bd3..6486501 100644
--- a/include/net/netns/ip_vs.h
+++ b/include/net/netns/ip_vs.h
@@ -70,6 +70,10 @@ struct netns_ipvs {
 	int 			sysctl_lblcr_expiration;
 	struct ctl_table_header	*lblcr_ctl_header;
 	struct ctl_table	*lblcr_ctl_table;
+	/* ip_vs_est */
+	struct list_head 	est_list;	/* estimator list */
+	spinlock_t		est_lock;
+
 };
 
 #endif /* IP_VS_H_ */
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 2c9cd5c..36458e8 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -815,7 +815,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	spin_unlock(&dest->dst_lock);
 
 	if (add)
-		ip_vs_new_estimator(&dest->stats);
+		ip_vs_new_estimator(svc->net, &dest->stats);
 
 	write_lock_bh(&__ip_vs_svc_lock);
 
@@ -1008,9 +1008,9 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 /*
  *	Delete a destination (must be already unlinked from the service)
  */
-static void __ip_vs_del_dest(struct ip_vs_dest *dest)
+static void __ip_vs_del_dest(struct net *net, struct ip_vs_dest *dest)
 {
-	ip_vs_kill_estimator(&dest->stats);
+	ip_vs_kill_estimator(net, &dest->stats);
 
 	/*
 	 *  Remove it from the d-linked list with the real services.
@@ -1079,6 +1079,7 @@ static int
 ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 {
 	struct ip_vs_dest *dest;
+	struct net *net = svc->net;
 	__be16 dport = udest->port;
 
 	EnterFunction(2);
@@ -1107,7 +1108,7 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	/*
 	 *	Delete the destination
 	 */
-	__ip_vs_del_dest(dest);
+	__ip_vs_del_dest(net, dest);
 
 	LeaveFunction(2);
 
@@ -1196,7 +1197,7 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 	else if (svc->port == 0)
 		atomic_inc(&ip_vs_nullsvc_counter);
 
-	ip_vs_new_estimator(&svc->stats);
+	ip_vs_new_estimator(net, &svc->stats);
 
 	/* Count only IPv4 services for old get/setsockopt interface */
 	if (svc->af == AF_INET)
@@ -1344,7 +1345,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc)
 	if (svc->af == AF_INET)
 		ip_vs_num_services--;
 
-	ip_vs_kill_estimator(&svc->stats);
+	ip_vs_kill_estimator(svc->net, &svc->stats);
 
 	/* Unbind scheduler */
 	old_sched = svc->scheduler;
@@ -1367,7 +1368,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc)
 	 */
 	list_for_each_entry_safe(dest, nxt, &svc->destinations, n_list) {
 		__ip_vs_unlink_dest(svc, dest, 0);
-		__ip_vs_del_dest(dest);
+		__ip_vs_del_dest(svc->net, dest);
 	}
 
 	/*
@@ -3457,7 +3458,7 @@ int __net_init __ip_vs_control_init(struct net *net)
 	sysctl_header = register_net_sysctl_table(net, net_vs_ctl_path, vs_vars);
 	if (sysctl_header == NULL)
 		goto err_reg;
-	ip_vs_new_estimator(&ip_vs_stats);
+	ip_vs_new_estimator(net, &ip_vs_stats);
 	return 0;
 
 err_reg:
@@ -3469,7 +3470,7 @@ static void __net_exit __ip_vs_control_cleanup(struct net *net)
 	if (!net_eq(net, &init_net))	/* netns not enabled yet */
 		return;
 
-	ip_vs_kill_estimator(&ip_vs_stats);
+	ip_vs_kill_estimator(net, &ip_vs_stats);
 	unregister_net_sysctl_table(sysctl_header);
 	proc_net_remove(net, "ip_vs_stats");
 	proc_net_remove(net, "ip_vs");
@@ -3533,7 +3534,6 @@ void ip_vs_control_cleanup(void)
 	ip_vs_trash_cleanup();
 	cancel_rearming_delayed_work(&defense_work);
 	cancel_work_sync(&defense_work.work);
-	ip_vs_kill_estimator(&ip_vs_stats);
 	unregister_pernet_subsys(&ipvs_control_ops);
 	ip_vs_genl_unregister();
 	nf_unregister_sockopt(&ip_vs_sockopts);
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 7417a0c..6bcabed 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -8,8 +8,12 @@
  *              as published by the Free Software Foundation; either version
  *              2 of the License, or (at your option) any later version.
  *
- * Changes:
- *
+ * Changes:     Hans Schillstrom <hans.schillstrom@ericsson.com>
+ *              Network name space (netns) aware.
+ *              Global data moved to netns i.e struct netns_ipvs
+ *              Affected data: est_list and est_lock.
+ *              estimation_timer() runs with a common timer, but
+ *              do update every netns on timeout.
  */
 
 #define KMSG_COMPONENT "IPVS"
@@ -49,9 +53,6 @@
 
 
 static void estimation_timer(unsigned long arg);
-
-static LIST_HEAD(est_list);
-static DEFINE_SPINLOCK(est_lock);
 static DEFINE_TIMER(est_timer, estimation_timer, 0, 0);
 
 static void estimation_timer(unsigned long arg)
@@ -62,51 +63,57 @@ static void estimation_timer(unsigned long arg)
 	u32 n_inpkts, n_outpkts;
 	u64 n_inbytes, n_outbytes;
 	u32 rate;
-
-	spin_lock(&est_lock);
-	list_for_each_entry(e, &est_list, list) {
-		s = container_of(e, struct ip_vs_stats, est);
-
-		spin_lock(&s->lock);
-		n_conns = s->ustats.conns;
-		n_inpkts = s->ustats.inpkts;
-		n_outpkts = s->ustats.outpkts;
-		n_inbytes = s->ustats.inbytes;
-		n_outbytes = s->ustats.outbytes;
-
-		/* scaled by 2^10, but divided 2 seconds */
-		rate = (n_conns - e->last_conns)<<9;
-		e->last_conns = n_conns;
-		e->cps += ((long)rate - (long)e->cps)>>2;
-		s->ustats.cps = (e->cps+0x1FF)>>10;
-
-		rate = (n_inpkts - e->last_inpkts)<<9;
-		e->last_inpkts = n_inpkts;
-		e->inpps += ((long)rate - (long)e->inpps)>>2;
-		s->ustats.inpps = (e->inpps+0x1FF)>>10;
-
-		rate = (n_outpkts - e->last_outpkts)<<9;
-		e->last_outpkts = n_outpkts;
-		e->outpps += ((long)rate - (long)e->outpps)>>2;
-		s->ustats.outpps = (e->outpps+0x1FF)>>10;
-
-		rate = (n_inbytes - e->last_inbytes)<<4;
-		e->last_inbytes = n_inbytes;
-		e->inbps += ((long)rate - (long)e->inbps)>>2;
-		s->ustats.inbps = (e->inbps+0xF)>>5;
-
-		rate = (n_outbytes - e->last_outbytes)<<4;
-		e->last_outbytes = n_outbytes;
-		e->outbps += ((long)rate - (long)e->outbps)>>2;
-		s->ustats.outbps = (e->outbps+0xF)>>5;
-		spin_unlock(&s->lock);
+	struct net *net;
+	struct netns_ipvs *ipvs;
+
+	for_each_net(net) {
+		ipvs = net_ipvs(net);
+		spin_lock(&ipvs->est_lock);
+		list_for_each_entry(e, &ipvs->est_list, list) {
+			s = container_of(e, struct ip_vs_stats, est);
+
+			spin_lock(&s->lock);
+			n_conns = s->ustats.conns;
+			n_inpkts = s->ustats.inpkts;
+			n_outpkts = s->ustats.outpkts;
+			n_inbytes = s->ustats.inbytes;
+			n_outbytes = s->ustats.outbytes;
+
+			/* scaled by 2^10, but divided 2 seconds */
+			rate = (n_conns - e->last_conns) << 9;
+			e->last_conns = n_conns;
+			e->cps += ((long)rate - (long)e->cps) >> 2;
+			s->ustats.cps = (e->cps + 0x1FF) >> 10;
+
+			rate = (n_inpkts - e->last_inpkts) << 9;
+			e->last_inpkts = n_inpkts;
+			e->inpps += ((long)rate - (long)e->inpps) >> 2;
+			s->ustats.inpps = (e->inpps + 0x1FF) >> 10;
+
+			rate = (n_outpkts - e->last_outpkts) << 9;
+			e->last_outpkts = n_outpkts;
+			e->outpps += ((long)rate - (long)e->outpps) >> 2;
+			s->ustats.outpps = (e->outpps + 0x1FF) >> 10;
+
+			rate = (n_inbytes - e->last_inbytes) << 4;
+			e->last_inbytes = n_inbytes;
+			e->inbps += ((long)rate - (long)e->inbps) >> 2;
+			s->ustats.inbps = (e->inbps + 0xF) >> 5;
+
+			rate = (n_outbytes - e->last_outbytes) << 4;
+			e->last_outbytes = n_outbytes;
+			e->outbps += ((long)rate - (long)e->outbps) >> 2;
+			s->ustats.outbps = (e->outbps + 0xF) >> 5;
+			spin_unlock(&s->lock);
+		}
+		spin_unlock(&ipvs->est_lock);
 	}
-	spin_unlock(&est_lock);
 	mod_timer(&est_timer, jiffies + 2*HZ);
 }
 
-void ip_vs_new_estimator(struct ip_vs_stats *stats)
+void ip_vs_new_estimator(struct net *net, struct ip_vs_stats *stats)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_estimator *est = &stats->est;
 
 	INIT_LIST_HEAD(&est->list);
@@ -126,18 +133,19 @@ void ip_vs_new_estimator(struct ip_vs_stats *stats)
 	est->last_outbytes = stats->ustats.outbytes;
 	est->outbps = stats->ustats.outbps<<5;
 
-	spin_lock_bh(&est_lock);
-	list_add(&est->list, &est_list);
-	spin_unlock_bh(&est_lock);
+	spin_lock_bh(&ipvs->est_lock);
+	list_add(&est->list, &ipvs->est_list);
+	spin_unlock_bh(&ipvs->est_lock);
 }
 
-void ip_vs_kill_estimator(struct ip_vs_stats *stats)
+void ip_vs_kill_estimator(struct net *net, struct ip_vs_stats *stats)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_estimator *est = &stats->est;
 
-	spin_lock_bh(&est_lock);
+	spin_lock_bh(&ipvs->est_lock);
 	list_del(&est->list);
-	spin_unlock_bh(&est_lock);
+	spin_unlock_bh(&ipvs->est_lock);
 }
 
 void ip_vs_zero_estimator(struct ip_vs_stats *stats)
@@ -159,9 +167,13 @@ void ip_vs_zero_estimator(struct ip_vs_stats *stats)
 
 static int __net_init __ip_vs_estimator_init(struct net *net)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
 	if (!net_eq(net, &init_net))	/* netns not enabled yet */
 		return -EPERM;
 
+	INIT_LIST_HEAD(&ipvs->est_list);
+	spin_lock_init(&ipvs->est_lock);
 	return 0;
 }
 
-- 
1.7.2.3

