From: Simon Horman <horms@verge.net.au>
Subject: [rfc 06/13] [RFC 06/13] IPVS: Allow null argument to ip_vs_scheduler_put()
Date: Thu, 05 Aug 2010 20:48:01 +0900
Message-ID: <20100805115240.715511400@vergenet.net>
References: <20100805114755.118303531@vergenet.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0006-IPVS-Allow-null-argument-to-ip_vs_scheduler_put.patch
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

This simplifies caller logic sightly.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c   |   13 ++++---------
 net/netfilter/ipvs/ip_vs_sched.c |    2 +-
 2 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 0f0c079..84dae47 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1167,7 +1167,7 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 	if (sched == NULL) {
 		pr_info("Scheduler module ip_vs_%s not found\n", u->sched_name);
 		ret = -ENOENT;
-		goto out_mod_dec;
+		goto out_err;
 	}
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1227,7 +1227,7 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 	*svc_p = svc;
 	return 0;
 
-  out_err:
+ out_err:
 	if (svc != NULL) {
 		if (svc->scheduler)
 			ip_vs_unbind_scheduler(svc);
@@ -1240,7 +1240,6 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 	}
 	ip_vs_scheduler_put(sched);
 
-  out_mod_dec:
 	/* decrease the module use count */
 	ip_vs_use_count_dec();
 
@@ -1323,10 +1322,7 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 #ifdef CONFIG_IP_VS_IPV6
   out:
 #endif
-
-	if (old_sched)
-		ip_vs_scheduler_put(old_sched);
-
+	ip_vs_scheduler_put(old_sched);
 	return ret;
 }
 
@@ -1350,8 +1346,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc)
 	/* Unbind scheduler */
 	old_sched = svc->scheduler;
 	ip_vs_unbind_scheduler(svc);
-	if (old_sched)
-		ip_vs_scheduler_put(old_sched);
+	ip_vs_scheduler_put(old_sched);
 
 	/* Unbind app inc */
 	if (svc->inc) {
diff --git a/net/netfilter/ipvs/ip_vs_sched.c b/net/netfilter/ipvs/ip_vs_sched.c
index bbc1ac7..cd77902 100644
--- a/net/netfilter/ipvs/ip_vs_sched.c
+++ b/net/netfilter/ipvs/ip_vs_sched.c
@@ -159,7 +159,7 @@ struct ip_vs_scheduler *ip_vs_scheduler_get(const char *sched_name)
 
 void ip_vs_scheduler_put(struct ip_vs_scheduler *scheduler)
 {
-	if (scheduler->module)
+	if (scheduler && scheduler->module)
 		module_put(scheduler->module);
 }
 
-- 
1.7.1


