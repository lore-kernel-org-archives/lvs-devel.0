From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 15/19] ipvs: do not expect result from done_service
Date: Fri, 22 Mar 2013 11:46:50 +0200
Message-ID: <1363945614-11752-16-git-send-email-ja@ssi.bg>
References: <1363945614-11752-1-git-send-email-ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1363945614-11752-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

	This method releases the scheduler state,
it can not fail. Such change will help to properly
replace the scheduler in following patch.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h              |    4 ++--
 net/netfilter/ipvs/ip_vs_ctl.c   |    5 +----
 net/netfilter/ipvs/ip_vs_dh.c    |    4 +---
 net/netfilter/ipvs/ip_vs_lblc.c  |    4 +---
 net/netfilter/ipvs/ip_vs_lblcr.c |    4 +---
 net/netfilter/ipvs/ip_vs_sched.c |   13 ++++---------
 net/netfilter/ipvs/ip_vs_sh.c    |    4 +---
 net/netfilter/ipvs/ip_vs_wrr.c   |    4 +---
 8 files changed, 12 insertions(+), 30 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 76747d9..8597a71 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -806,7 +806,7 @@ struct ip_vs_scheduler {
 	/* scheduler initializing service */
 	int (*init_service)(struct ip_vs_service *svc);
 	/* scheduling service finish */
-	int (*done_service)(struct ip_vs_service *svc);
+	void (*done_service)(struct ip_vs_service *svc);
 	/* scheduler updating service */
 	int (*update_service)(struct ip_vs_service *svc);
 	/* dest is linked */
@@ -1392,7 +1392,7 @@ extern int register_ip_vs_scheduler(struct ip_vs_scheduler *scheduler);
 extern int unregister_ip_vs_scheduler(struct ip_vs_scheduler *scheduler);
 extern int ip_vs_bind_scheduler(struct ip_vs_service *svc,
 				struct ip_vs_scheduler *scheduler);
-extern int ip_vs_unbind_scheduler(struct ip_vs_service *svc);
+extern void ip_vs_unbind_scheduler(struct ip_vs_service *svc);
 extern struct ip_vs_scheduler *ip_vs_scheduler_get(const char *sched_name);
 extern void ip_vs_scheduler_put(struct ip_vs_scheduler *scheduler);
 extern struct ip_vs_conn *
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index a6c206f..e010deb 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1332,10 +1332,7 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 		/*
 		 * Unbind the old scheduler
 		 */
-		if ((ret = ip_vs_unbind_scheduler(svc))) {
-			old_sched = sched;
-			goto out_unlock;
-		}
+		ip_vs_unbind_scheduler(svc);
 
 		/*
 		 * Bind the new scheduler
diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index ebe80f4..89c2723 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -174,7 +174,7 @@ static int ip_vs_dh_init_svc(struct ip_vs_service *svc)
 }
 
 
-static int ip_vs_dh_done_svc(struct ip_vs_service *svc)
+static void ip_vs_dh_done_svc(struct ip_vs_service *svc)
 {
 	struct ip_vs_dh_state *s = svc->sched_data;
 
@@ -185,8 +185,6 @@ static int ip_vs_dh_done_svc(struct ip_vs_service *svc)
 	kfree_rcu(s, rcu_head);
 	IP_VS_DBG(6, "DH hash table (memory=%Zdbytes) released\n",
 		  sizeof(struct ip_vs_dh_bucket)*IP_VS_DH_TAB_SIZE);
-
-	return 0;
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index b873e17..c7ff978 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -388,7 +388,7 @@ static int ip_vs_lblc_init_svc(struct ip_vs_service *svc)
 }
 
 
-static int ip_vs_lblc_done_svc(struct ip_vs_service *svc)
+static void ip_vs_lblc_done_svc(struct ip_vs_service *svc)
 {
 	struct ip_vs_lblc_table *tbl = svc->sched_data;
 
@@ -402,8 +402,6 @@ static int ip_vs_lblc_done_svc(struct ip_vs_service *svc)
 	kfree_rcu(tbl, rcu_head);
 	IP_VS_DBG(6, "LBLC hash table (memory=%Zdbytes) released\n",
 		  sizeof(*tbl));
-
-	return 0;
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index c22f173..6049b85 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -555,7 +555,7 @@ static int ip_vs_lblcr_init_svc(struct ip_vs_service *svc)
 }
 
 
-static int ip_vs_lblcr_done_svc(struct ip_vs_service *svc)
+static void ip_vs_lblcr_done_svc(struct ip_vs_service *svc)
 {
 	struct ip_vs_lblcr_table *tbl = svc->sched_data;
 
@@ -569,8 +569,6 @@ static int ip_vs_lblcr_done_svc(struct ip_vs_service *svc)
 	kfree_rcu(tbl, rcu_head);
 	IP_VS_DBG(6, "LBLCR hash table (memory=%Zdbytes) released\n",
 		  sizeof(*tbl));
-
-	return 0;
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_sched.c b/net/netfilter/ipvs/ip_vs_sched.c
index 7f11d3d..1b715d0 100644
--- a/net/netfilter/ipvs/ip_vs_sched.c
+++ b/net/netfilter/ipvs/ip_vs_sched.c
@@ -64,22 +64,17 @@ int ip_vs_bind_scheduler(struct ip_vs_service *svc,
 /*
  *  Unbind a service with its scheduler
  */
-int ip_vs_unbind_scheduler(struct ip_vs_service *svc)
+void ip_vs_unbind_scheduler(struct ip_vs_service *svc)
 {
 	struct ip_vs_scheduler *sched = svc->scheduler;
 
 	if (!sched)
-		return 0;
+		return;
 
-	if (sched->done_service) {
-		if (sched->done_service(svc) != 0) {
-			pr_err("%s(): done error\n", __func__);
-			return -EINVAL;
-		}
-	}
+	if (sched->done_service)
+		sched->done_service(svc);
 
 	svc->scheduler = NULL;
-	return 0;
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 55e76d8..81c1a10 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -187,7 +187,7 @@ static int ip_vs_sh_init_svc(struct ip_vs_service *svc)
 }
 
 
-static int ip_vs_sh_done_svc(struct ip_vs_service *svc)
+static void ip_vs_sh_done_svc(struct ip_vs_service *svc)
 {
 	struct ip_vs_sh_state *s = svc->sched_data;
 
@@ -198,8 +198,6 @@ static int ip_vs_sh_done_svc(struct ip_vs_service *svc)
 	kfree_rcu(s, rcu_head);
 	IP_VS_DBG(6, "SH hash table (memory=%Zdbytes) released\n",
 		  sizeof(struct ip_vs_sh_bucket)*IP_VS_SH_TAB_SIZE);
-
-	return 0;
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index 98cb05e..a74fd9b 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -129,7 +129,7 @@ static int ip_vs_wrr_init_svc(struct ip_vs_service *svc)
 }
 
 
-static int ip_vs_wrr_done_svc(struct ip_vs_service *svc)
+static void ip_vs_wrr_done_svc(struct ip_vs_service *svc)
 {
 	struct ip_vs_wrr_mark *mark = svc->sched_data;
 
@@ -137,8 +137,6 @@ static int ip_vs_wrr_done_svc(struct ip_vs_service *svc)
 	 *    Release the mark variable
 	 */
 	kfree_rcu(mark, rcu_head);
-
-	return 0;
 }
 
 
-- 
1.7.3.4
