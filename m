From: Simon Horman <horms@verge.net.au>
Subject: [patch v2 06/12] [PATCH 06/12] IPVS: ip_vs_{un,}bind_scheduler NULL arguments
Date: Fri, 01 Oct 2010 23:35:23 +0900
Message-ID: <20101001143942.210668883@akiko.akashicho.tokyo.vergenet.net>
References: <20101001143517.645421976@akiko.akashicho.tokyo.vergenet.net>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline; filename=0006-IPVS-ip_vs_-un-bind_scheduler-NULL-arguments.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

In general NULL arguments aren't passed by the few callers that exist,
so don't test for them.

The exception is to make passing NULL to ip_vs_unbind_scheduler() a noop.

Signed-off-by: Simon Horman <horms@verge.net.au>

v2
* Trivial rediff

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 84dae47..d57cc4a 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1229,8 +1229,7 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 
  out_err:
 	if (svc != NULL) {
-		if (svc->scheduler)
-			ip_vs_unbind_scheduler(svc);
+		ip_vs_unbind_scheduler(svc);
 		if (svc->inc) {
 			local_bh_disable();
 			ip_vs_app_inc_put(svc->inc);
diff --git a/net/netfilter/ipvs/ip_vs_sched.c b/net/netfilter/ipvs/ip_vs_sched.c
index cd77902..be0780a 100644
--- a/net/netfilter/ipvs/ip_vs_sched.c
+++ b/net/netfilter/ipvs/ip_vs_sched.c
@@ -46,15 +46,6 @@ int ip_vs_bind_scheduler(struct ip_vs_service *svc,
 {
 	int ret;
 
-	if (svc == NULL) {
-		pr_err("%s(): svc arg NULL\n", __func__);
-		return -EINVAL;
-	}
-	if (scheduler == NULL) {
-		pr_err("%s(): scheduler arg NULL\n", __func__);
-		return -EINVAL;
-	}
-
 	svc->scheduler = scheduler;
 
 	if (scheduler->init_service) {
@@ -74,18 +65,10 @@ int ip_vs_bind_scheduler(struct ip_vs_service *svc,
  */
 int ip_vs_unbind_scheduler(struct ip_vs_service *svc)
 {
-	struct ip_vs_scheduler *sched;
+	struct ip_vs_scheduler *sched = svc->scheduler;
 
-	if (svc == NULL) {
-		pr_err("%s(): svc arg NULL\n", __func__);
-		return -EINVAL;
-	}
-
-	sched = svc->scheduler;
-	if (sched == NULL) {
-		pr_err("%s(): svc isn't bound\n", __func__);
-		return -EINVAL;
-	}
+	if (!sched)
+		return 0;
 
 	if (sched->done_service) {
 		if (sched->done_service(svc) != 0) {
-- 
1.7.1


