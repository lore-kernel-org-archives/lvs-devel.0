From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 10/24] ipvs: rename estimator functions
Date: Mon, 14 Mar 2011 18:06:22 +0900
Message-ID: <1300093596-3824-11-git-send-email-horms@verge.net.au>
References: <1300093596-3824-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300093596-3824-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

 	Rename ip_vs_new_estimator to ip_vs_start_estimator
and ip_vs_kill_estimator to ip_vs_stop_estimator to better
match their logic.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h            |    4 ++--
 net/netfilter/ipvs/ip_vs_ctl.c |   12 ++++++------
 net/netfilter/ipvs/ip_vs_est.c |    4 ++--
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index e4a39c4..7ca5be2 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1176,8 +1176,8 @@ extern void ip_vs_sync_cleanup(void);
  */
 extern int ip_vs_estimator_init(void);
 extern void ip_vs_estimator_cleanup(void);
-extern void ip_vs_new_estimator(struct net *net, struct ip_vs_stats *stats);
-extern void ip_vs_kill_estimator(struct net *net, struct ip_vs_stats *stats);
+extern void ip_vs_start_estimator(struct net *net, struct ip_vs_stats *stats);
+extern void ip_vs_stop_estimator(struct net *net, struct ip_vs_stats *stats);
 extern void ip_vs_zero_estimator(struct ip_vs_stats *stats);
 extern void ip_vs_read_estimator(struct ip_vs_stats_user *dst,
 				 struct ip_vs_stats *stats);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c93d806..c5b1234 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -802,7 +802,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	spin_unlock(&dest->dst_lock);
 
 	if (add)
-		ip_vs_new_estimator(svc->net, &dest->stats);
+		ip_vs_start_estimator(svc->net, &dest->stats);
 
 	write_lock_bh(&__ip_vs_svc_lock);
 
@@ -1008,7 +1008,7 @@ static void __ip_vs_del_dest(struct net *net, struct ip_vs_dest *dest)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	ip_vs_kill_estimator(net, &dest->stats);
+	ip_vs_stop_estimator(net, &dest->stats);
 
 	/*
 	 *  Remove it from the d-linked list with the real services.
@@ -1201,7 +1201,7 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 	else if (svc->port == 0)
 		atomic_inc(&ipvs->nullsvc_counter);
 
-	ip_vs_new_estimator(net, &svc->stats);
+	ip_vs_start_estimator(net, &svc->stats);
 
 	/* Count only IPv4 services for old get/setsockopt interface */
 	if (svc->af == AF_INET)
@@ -1353,7 +1353,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc)
 	if (svc->af == AF_INET)
 		ipvs->num_services--;
 
-	ip_vs_kill_estimator(svc->net, &svc->stats);
+	ip_vs_stop_estimator(svc->net, &svc->stats);
 
 	/* Unbind scheduler */
 	old_sched = svc->scheduler;
@@ -3585,7 +3585,7 @@ int __net_init __ip_vs_control_init(struct net *net)
 		goto err_dup;
 	}
 #endif
-	ip_vs_new_estimator(net, &ipvs->tot_stats);
+	ip_vs_start_estimator(net, &ipvs->tot_stats);
 	ipvs->sysctl_tbl = tbl;
 	/* Schedule defense work */
 	INIT_DELAYED_WORK(&ipvs->defense_work, defense_work_handler);
@@ -3603,7 +3603,7 @@ static void __net_exit __ip_vs_control_cleanup(struct net *net)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	ip_vs_trash_cleanup(net);
-	ip_vs_kill_estimator(net, &ipvs->tot_stats);
+	ip_vs_stop_estimator(net, &ipvs->tot_stats);
 	cancel_delayed_work_sync(&ipvs->defense_work);
 	cancel_work_sync(&ipvs->defense_work.work);
 #ifdef CONFIG_SYSCTL
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index fda75be..8c8766c 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -139,7 +139,7 @@ static void estimation_timer(unsigned long arg)
 	mod_timer(&ipvs->est_timer, jiffies + 2*HZ);
 }
 
-void ip_vs_new_estimator(struct net *net, struct ip_vs_stats *stats)
+void ip_vs_start_estimator(struct net *net, struct ip_vs_stats *stats)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_estimator *est = &stats->est;
@@ -151,7 +151,7 @@ void ip_vs_new_estimator(struct net *net, struct ip_vs_stats *stats)
 	spin_unlock_bh(&ipvs->est_lock);
 }
 
-void ip_vs_kill_estimator(struct net *net, struct ip_vs_stats *stats)
+void ip_vs_stop_estimator(struct net *net, struct ip_vs_stats *stats)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_estimator *est = &stats->est;
-- 
1.7.2.3

