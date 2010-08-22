From: Simon Horman <horms@verge.net.au>
Subject: [patch v1 06/12] IPVS: ip_vs_{un,}bind_scheduler NULL arguments
Date: Sun, 22 Aug 2010 21:45:03 +0900
Message-ID: <20100822124858.738725404@vergenet.net>
References: <20100822124457.339517323@vergenet.net>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline; filename=ip_vs_bind_scheduler-null.patch
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

Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_ctl.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_ctl.c	2010-07-22 22:04:29.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_ctl.c	2010-07-22 22:07:18.000000000 +0900
@@ -1229,8 +1229,7 @@ ip_vs_add_service(struct ip_vs_service_u
 
  out_err:
 	if (svc != NULL) {
-		if (svc->scheduler)
-			ip_vs_unbind_scheduler(svc);
+		ip_vs_unbind_scheduler(svc);
 		if (svc->inc) {
 			local_bh_disable();
 			ip_vs_app_inc_put(svc->inc);
Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_sched.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_sched.c	2010-07-22 22:04:23.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_sched.c	2010-07-22 22:06:20.000000000 +0900
@@ -46,15 +46,6 @@ int ip_vs_bind_scheduler(struct ip_vs_se
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
@@ -74,18 +65,10 @@ int ip_vs_bind_scheduler(struct ip_vs_se
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

