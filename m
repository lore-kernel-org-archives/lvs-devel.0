From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 13/22] IPVS: netns awareness to ip_vs_est
Date: Thu, 13 Jan 2011 10:52:59 +0900
Message-ID: <1294883588-5683-14-git-send-email-horms@verge.net.au>
References: <1294883588-5683-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1294883588-5683-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

All variables moved to struct ipvs,
most external changes fixed (i.e. init_net removed)

*v3
 timer per ns instead of a common timer in estimator.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h            |    4 +-
 include/net/netns/ip_vs.h      |    4 ++
 net/netfilter/ipvs/ip_vs_ctl.c |   20 +++++-----
 net/netfilter/ipvs/ip_vs_est.c |   86 ++++++++++++++++++++++-----------------
 4 files changed, 64 insertions(+), 50 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 0cdd8ce..c08927b 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1004,8 +1004,8 @@ extern void ip_vs_sync_cleanup(void);
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
index 03f7fe1..db02401 100644
--- a/include/net/netns/ip_vs.h
+++ b/include/net/netns/ip_vs.h
@@ -70,6 +70,10 @@ struct netns_ipvs {
 	int			sysctl_lblcr_expiration;
 	struct ctl_table_header	*lblcr_ctl_header;
 	struct ctl_table	*lblcr_ctl_table;
+	/* ip_vs_est */
+	struct list_head	est_list;	/* estimator list */
+	spinlock_t		est_lock;
+	struct timer_list	est_timer;	/* Estimation timer */
 };
 
 #endif /* IP_VS_H_ */
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 88474f1..c89beb8 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -816,7 +816,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	spin_unlock(&dest->dst_lock);
 
 	if (add)
-		ip_vs_new_estimator(&dest->stats);
+		ip_vs_new_estimator(svc->net, &dest->stats);
 
 	write_lock_bh(&__ip_vs_svc_lock);
 
@@ -1009,9 +1009,9 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
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
@@ -1080,6 +1080,7 @@ static int
 ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 {
 	struct ip_vs_dest *dest;
+	struct net *net = svc->net;
 	__be16 dport = udest->port;
 
 	EnterFunction(2);
@@ -1108,7 +1109,7 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	/*
 	 *	Delete the destination
 	 */
-	__ip_vs_del_dest(dest);
+	__ip_vs_del_dest(net, dest);
 
 	LeaveFunction(2);
 
@@ -1197,7 +1198,7 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 	else if (svc->port == 0)
 		atomic_inc(&ip_vs_nullsvc_counter);
 
-	ip_vs_new_estimator(&svc->stats);
+	ip_vs_new_estimator(net, &svc->stats);
 
 	/* Count only IPv4 services for old get/setsockopt interface */
 	if (svc->af == AF_INET)
@@ -1345,7 +1346,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc)
 	if (svc->af == AF_INET)
 		ip_vs_num_services--;
 
-	ip_vs_kill_estimator(&svc->stats);
+	ip_vs_kill_estimator(svc->net, &svc->stats);
 
 	/* Unbind scheduler */
 	old_sched = svc->scheduler;
@@ -1368,7 +1369,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc)
 	 */
 	list_for_each_entry_safe(dest, nxt, &svc->destinations, n_list) {
 		__ip_vs_unlink_dest(svc, dest, 0);
-		__ip_vs_del_dest(dest);
+		__ip_vs_del_dest(svc->net, dest);
 	}
 
 	/*
@@ -3460,7 +3461,7 @@ int __net_init __ip_vs_control_init(struct net *net)
 						  vs_vars);
 	if (sysctl_header == NULL)
 		goto err_reg;
-	ip_vs_new_estimator(&ip_vs_stats);
+	ip_vs_new_estimator(net, &ip_vs_stats);
 	return 0;
 
 err_reg:
@@ -3472,7 +3473,7 @@ static void __net_exit __ip_vs_control_cleanup(struct net *net)
 	if (!net_eq(net, &init_net))	/* netns not enabled yet */
 		return;
 
-	ip_vs_kill_estimator(&ip_vs_stats);
+	ip_vs_kill_estimator(net, &ip_vs_stats);
 	unregister_net_sysctl_table(sysctl_header);
 	proc_net_remove(net, "ip_vs_stats");
 	proc_net_remove(net, "ip_vs");
@@ -3536,7 +3537,6 @@ void ip_vs_control_cleanup(void)
 	ip_vs_trash_cleanup();
 	cancel_delayed_work_sync(&defense_work);
 	cancel_work_sync(&defense_work.work);
-	ip_vs_kill_estimator(&ip_vs_stats);
 	unregister_pernet_subsys(&ipvs_control_ops);
 	ip_vs_genl_unregister();
 	nf_unregister_sockopt(&ip_vs_sockopts);
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 7417a0c..07d839b 100644
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
+ *              estimation_timer() runs with timer per netns.
+ *              get_stats()) do the per cpu summing.
  */
 
 #define KMSG_COMPONENT "IPVS"
@@ -48,12 +52,6 @@
  */
 
 
-static void estimation_timer(unsigned long arg);
-
-static LIST_HEAD(est_list);
-static DEFINE_SPINLOCK(est_lock);
-static DEFINE_TIMER(est_timer, estimation_timer, 0, 0);
-
 static void estimation_timer(unsigned long arg)
 {
 	struct ip_vs_estimator *e;
@@ -62,9 +60,12 @@ static void estimation_timer(unsigned long arg)
 	u32 n_inpkts, n_outpkts;
 	u64 n_inbytes, n_outbytes;
 	u32 rate;
+	struct net *net = (struct net *)arg;
+	struct netns_ipvs *ipvs;
 
-	spin_lock(&est_lock);
-	list_for_each_entry(e, &est_list, list) {
+	ipvs = net_ipvs(net);
+	spin_lock(&ipvs->est_lock);
+	list_for_each_entry(e, &ipvs->est_list, list) {
 		s = container_of(e, struct ip_vs_stats, est);
 
 		spin_lock(&s->lock);
@@ -75,38 +76,39 @@ static void estimation_timer(unsigned long arg)
 		n_outbytes = s->ustats.outbytes;
 
 		/* scaled by 2^10, but divided 2 seconds */
-		rate = (n_conns - e->last_conns)<<9;
+		rate = (n_conns - e->last_conns) << 9;
 		e->last_conns = n_conns;
-		e->cps += ((long)rate - (long)e->cps)>>2;
-		s->ustats.cps = (e->cps+0x1FF)>>10;
+		e->cps += ((long)rate - (long)e->cps) >> 2;
+		s->ustats.cps = (e->cps + 0x1FF) >> 10;
 
-		rate = (n_inpkts - e->last_inpkts)<<9;
+		rate = (n_inpkts - e->last_inpkts) << 9;
 		e->last_inpkts = n_inpkts;
-		e->inpps += ((long)rate - (long)e->inpps)>>2;
-		s->ustats.inpps = (e->inpps+0x1FF)>>10;
+		e->inpps += ((long)rate - (long)e->inpps) >> 2;
+		s->ustats.inpps = (e->inpps + 0x1FF) >> 10;
 
-		rate = (n_outpkts - e->last_outpkts)<<9;
+		rate = (n_outpkts - e->last_outpkts) << 9;
 		e->last_outpkts = n_outpkts;
-		e->outpps += ((long)rate - (long)e->outpps)>>2;
-		s->ustats.outpps = (e->outpps+0x1FF)>>10;
+		e->outpps += ((long)rate - (long)e->outpps) >> 2;
+		s->ustats.outpps = (e->outpps + 0x1FF) >> 10;
 
-		rate = (n_inbytes - e->last_inbytes)<<4;
+		rate = (n_inbytes - e->last_inbytes) << 4;
 		e->last_inbytes = n_inbytes;
-		e->inbps += ((long)rate - (long)e->inbps)>>2;
-		s->ustats.inbps = (e->inbps+0xF)>>5;
+		e->inbps += ((long)rate - (long)e->inbps) >> 2;
+		s->ustats.inbps = (e->inbps + 0xF) >> 5;
 
-		rate = (n_outbytes - e->last_outbytes)<<4;
+		rate = (n_outbytes - e->last_outbytes) << 4;
 		e->last_outbytes = n_outbytes;
-		e->outbps += ((long)rate - (long)e->outbps)>>2;
-		s->ustats.outbps = (e->outbps+0xF)>>5;
+		e->outbps += ((long)rate - (long)e->outbps) >> 2;
+		s->ustats.outbps = (e->outbps + 0xF) >> 5;
 		spin_unlock(&s->lock);
 	}
-	spin_unlock(&est_lock);
-	mod_timer(&est_timer, jiffies + 2*HZ);
+	spin_unlock(&ipvs->est_lock);
+	mod_timer(&ipvs->est_timer, jiffies + 2*HZ);
 }
 
-void ip_vs_new_estimator(struct ip_vs_stats *stats)
+void ip_vs_new_estimator(struct net *net, struct ip_vs_stats *stats)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_estimator *est = &stats->est;
 
 	INIT_LIST_HEAD(&est->list);
@@ -126,18 +128,19 @@ void ip_vs_new_estimator(struct ip_vs_stats *stats)
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
@@ -159,14 +162,25 @@ void ip_vs_zero_estimator(struct ip_vs_stats *stats)
 
 static int __net_init __ip_vs_estimator_init(struct net *net)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
 	if (!net_eq(net, &init_net))	/* netns not enabled yet */
 		return -EPERM;
 
+	INIT_LIST_HEAD(&ipvs->est_list);
+	spin_lock_init(&ipvs->est_lock);
+	setup_timer(&ipvs->est_timer, estimation_timer, (unsigned long)net);
+	mod_timer(&ipvs->est_timer, jiffies + 2 * HZ);
 	return 0;
 }
 
+static void __net_exit __ip_vs_estimator_exit(struct net *net)
+{
+	del_timer_sync(&net_ipvs(net)->est_timer);
+}
 static struct pernet_operations ip_vs_app_ops = {
 	.init = __ip_vs_estimator_init,
+	.exit = __ip_vs_estimator_exit,
 };
 
 int __init ip_vs_estimator_init(void)
@@ -174,14 +188,10 @@ int __init ip_vs_estimator_init(void)
 	int rv;
 
 	rv = register_pernet_subsys(&ip_vs_app_ops);
-	if (rv < 0)
-		return rv;
-	mod_timer(&est_timer, jiffies + 2 * HZ);
 	return rv;
 }
 
 void ip_vs_estimator_cleanup(void)
 {
-	del_timer_sync(&est_timer);
 	unregister_pernet_subsys(&ip_vs_app_ops);
 }
-- 
1.7.2.3

