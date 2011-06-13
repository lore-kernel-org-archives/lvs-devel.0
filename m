From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [PATCH 2/2] IPVS: remove unused init and cleanup functions.
Date: Mon, 13 Jun 2011 12:19:27 +0200
Message-ID: <1307960367-15318-3-git-send-email-hans.schillstrom@ericsson.com>
References: <1307960367-15318-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1307960367-15318-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

After restructuring, there is some unused or empty functions
left to be removed.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/ip_vs.h             |    6 ------
 net/netfilter/ipvs/ip_vs_app.c  |   10 ----------
 net/netfilter/ipvs/ip_vs_core.c |   29 ++++-------------------------
 net/netfilter/ipvs/ip_vs_est.c  |    9 ---------
 net/netfilter/ipvs/ip_vs_sync.c |    9 ---------
 5 files changed, 4 insertions(+), 59 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 1b0985f..b1370c4 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1117,8 +1117,6 @@ extern void ip_vs_app_inc_put(struct ip_vs_app *inc);
 
 extern int ip_vs_app_pkt_out(struct ip_vs_conn *, struct sk_buff *skb);
 extern int ip_vs_app_pkt_in(struct ip_vs_conn *, struct sk_buff *skb);
-extern int ip_vs_app_init(void);
-extern void ip_vs_app_cleanup(void);
 
 void ip_vs_bind_pe(struct ip_vs_service *svc, struct ip_vs_pe *pe);
 void ip_vs_unbind_pe(struct ip_vs_service *svc);
@@ -1221,15 +1219,11 @@ extern int start_sync_thread(struct net *net, int state, char *mcast_ifn,
 			     __u8 syncid);
 extern int stop_sync_thread(struct net *net, int state);
 extern void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp);
-extern int ip_vs_sync_init(void);
-extern void ip_vs_sync_cleanup(void);
 
 
 /*
  *      IPVS rate estimator prototypes (from ip_vs_est.c)
  */
-extern int ip_vs_estimator_init(void);
-extern void ip_vs_estimator_cleanup(void);
 extern void ip_vs_start_estimator(struct net *net, struct ip_vs_stats *stats);
 extern void ip_vs_stop_estimator(struct net *net, struct ip_vs_stats *stats);
 extern void ip_vs_zero_estimator(struct ip_vs_stats *stats);
diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index e223fb7..fe6cb43 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -589,13 +589,3 @@ void __net_exit ip_vs_app_net_cleanup(struct net *net)
 {
 	proc_net_remove(net, "ip_vs_app");
 }
-
-int __init ip_vs_app_init(void)
-{
-	return 0;
-}
-
-
-void ip_vs_app_cleanup(void)
-{
-}
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 673504e..267529b 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1968,36 +1968,23 @@ static int __init ip_vs_init(void)
 {
 	int ret;
 
-	ip_vs_estimator_init();
 	ret = ip_vs_control_init();
 	if (ret < 0) {
 		pr_err("can't setup control.\n");
-		goto cleanup_estimator;
+		goto exit;
 	}
 
 	ip_vs_protocol_init();
 
-	ret = ip_vs_app_init();
-	if (ret < 0) {
-		pr_err("can't setup application helper.\n");
-		goto cleanup_protocol;
-	}
-
 	ret = ip_vs_conn_init();
 	if (ret < 0) {
 		pr_err("can't setup connection table.\n");
-		goto cleanup_app;
-	}
-
-	ret = ip_vs_sync_init();
-	if (ret < 0) {
-		pr_err("can't setup sync data.\n");
-		goto cleanup_conn;
+		goto cleanup_protocol;
 	}
 
 	ret = register_pernet_subsys(&ipvs_core_ops);	/* Alloc ip_vs struct */
 	if (ret < 0)
-		goto cleanup_sync;
+		goto cleanup_conn;
 
 	ret = register_pernet_device(&ipvs_core_dev_ops);
 	if (ret < 0)
@@ -2017,17 +2004,12 @@ cleanup_dev:
 	unregister_pernet_device(&ipvs_core_dev_ops);
 cleanup_sub:
 	unregister_pernet_subsys(&ipvs_core_ops);
-cleanup_sync:
-	ip_vs_sync_cleanup();
 cleanup_conn:
 	ip_vs_conn_cleanup();
-cleanup_app:
-	ip_vs_app_cleanup();
 cleanup_protocol:
 	ip_vs_protocol_cleanup();
 	ip_vs_control_cleanup();
-cleanup_estimator:
-	ip_vs_estimator_cleanup();
+exit:
 	return ret;
 }
 
@@ -2036,12 +2018,9 @@ static void __exit ip_vs_cleanup(void)
 	nf_unregister_hooks(ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
 	unregister_pernet_device(&ipvs_core_dev_ops);
 	unregister_pernet_subsys(&ipvs_core_ops);	/* free ip_vs struct */
-	ip_vs_sync_cleanup();
 	ip_vs_conn_cleanup();
-	ip_vs_app_cleanup();
 	ip_vs_protocol_cleanup();
 	ip_vs_control_cleanup();
-	ip_vs_estimator_cleanup();
 	pr_info("ipvs unloaded.\n");
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index f5d2a01..0fac601 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -207,12 +207,3 @@ void __net_exit ip_vs_estimator_net_cleanup(struct net *net)
 {
 	del_timer_sync(&net_ipvs(net)->est_timer);
 }
-
-int __init ip_vs_estimator_init(void)
-{
-	return 0;
-}
-
-void ip_vs_estimator_cleanup(void)
-{
-}
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 58bfabb..7ee7215 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1689,12 +1689,3 @@ void ip_vs_sync_net_cleanup(struct net *net)
 	if (retc && retc != -ESRCH)
 		pr_err("Failed to stop Backup Daemon\n");
 }
-
-int __init ip_vs_sync_init(void)
-{
-	return 0;
-}
-
-void ip_vs_sync_cleanup(void)
-{
-}
-- 
1.7.2.3

