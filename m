From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH] ipvs: Create init functions for estimator code
Date: Thu, 14 Aug 2008 00:47:16 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0808140045230.12259@titan.stealer.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg

Commit 8ab19ea36c5c5340ff598e4d15fc084eb65671dc ("ipvs: Fix possible deadlock
in estimator code") fixed a deadlock condition, but that condition can only
happen during unload of IPVS, because during normal operation there is at least
our global stats structure in the estimator list. The mod_timer() and
del_timer_sync() calls are actually initialization and cleanup code in
disguise. Let's make it explicit and move them to their own init and cleanup
function.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 include/net/ip_vs.h        |    2 ++
 net/ipv4/ipvs/ip_vs_core.c |    8 ++++++--
 net/ipv4/ipvs/ip_vs_est.c  |   18 +++++++++++-------
 3 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 7312c3d..a25ad24 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -683,6 +683,8 @@ extern void ip_vs_sync_conn(struct ip_vs_conn *cp);
 /*
  *      IPVS rate estimator prototypes (from ip_vs_est.c)
  */
+extern int ip_vs_estimator_init(void);
+extern void ip_vs_estimator_cleanup(void);
 extern void ip_vs_new_estimator(struct ip_vs_stats *stats);
 extern void ip_vs_kill_estimator(struct ip_vs_stats *stats);
 extern void ip_vs_zero_estimator(struct ip_vs_stats *stats);
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index a7879ea..9fbf0a6 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -1070,10 +1070,12 @@ static int __init ip_vs_init(void)
 {
 	int ret;
 
+	ip_vs_estimator_init();
+
 	ret = ip_vs_control_init();
 	if (ret < 0) {
 		IP_VS_ERR("can't setup control.\n");
-		goto cleanup_nothing;
+		goto cleanup_estimator;
 	}
 
 	ip_vs_protocol_init();
@@ -1106,7 +1108,8 @@ static int __init ip_vs_init(void)
   cleanup_protocol:
 	ip_vs_protocol_cleanup();
 	ip_vs_control_cleanup();
-  cleanup_nothing:
+  cleanup_estimator:
+	ip_vs_estimator_cleanup();
 	return ret;
 }
 
@@ -1117,6 +1120,7 @@ static void __exit ip_vs_cleanup(void)
 	ip_vs_app_cleanup();
 	ip_vs_protocol_cleanup();
 	ip_vs_control_cleanup();
+	ip_vs_estimator_cleanup();
 	IP_VS_INFO("ipvs unloaded.\n");
 }
 
diff --git a/net/ipv4/ipvs/ip_vs_est.c b/net/ipv4/ipvs/ip_vs_est.c
index 5a20f93..4fb620e 100644
--- a/net/ipv4/ipvs/ip_vs_est.c
+++ b/net/ipv4/ipvs/ip_vs_est.c
@@ -124,8 +124,6 @@ void ip_vs_new_estimator(struct ip_vs_stats *stats)
 	est->outbps = stats->outbps<<5;
 
 	spin_lock_bh(&est_lock);
-	if (list_empty(&est_list))
-		mod_timer(&est_timer, jiffies + 2 * HZ);
 	list_add(&est->list, &est_list);
 	spin_unlock_bh(&est_lock);
 }
@@ -136,11 +134,6 @@ void ip_vs_kill_estimator(struct ip_vs_stats *stats)
 
 	spin_lock_bh(&est_lock);
 	list_del(&est->list);
-	while (list_empty(&est_list) && try_to_del_timer_sync(&est_timer) < 0) {
-		spin_unlock_bh(&est_lock);
-		cpu_relax();
-		spin_lock_bh(&est_lock);
-	}
 	spin_unlock_bh(&est_lock);
 }
 
@@ -160,3 +153,14 @@ void ip_vs_zero_estimator(struct ip_vs_stats *stats)
 	est->inbps = 0;
 	est->outbps = 0;
 }
+
+int __init ip_vs_estimator_init(void)
+{
+	mod_timer(&est_timer, jiffies + 2 * HZ);
+	return 0;
+}
+
+void ip_vs_estimator_cleanup(void)
+{
+	del_timer_sync(&est_timer);
+}
