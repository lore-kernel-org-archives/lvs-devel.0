From: Simon Horman <horms@verge.net.au>
Subject: [patch v2 05/12] [PATCH 05/12] IPVS: Allow null argument to ip_vs_scheduler_put()
Date: Fri, 01 Oct 2010 23:35:22 +0900
Message-ID: <20101001143942.118471818@akiko.akashicho.tokyo.vergenet.net>
References: <20101001143517.645421976@akiko.akashicho.tokyo.vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0005-IPVS-Allow-null-argument-to-ip_vs_scheduler_put.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

This simplifies caller logic sightly.

Signed-off-by: Simon Horman <horms@verge.net.au>
---

v2
* Trivial rediff

Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_ctl.c
===================================================================
--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_ctl.c	2010-10-01 22:25:53.000000000 +0900
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_ctl.c	2010-10-01 22:26:10.000000000 +0900
@@ -1144,7 +1144,7 @@ ip_vs_add_service(struct ip_vs_service_u
 	if (sched == NULL) {
 		pr_info("Scheduler module ip_vs_%s not found\n", u->sched_name);
 		ret = -ENOENT;
-		goto out_mod_dec;
+		goto out_err;
 	}
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1204,7 +1204,7 @@ ip_vs_add_service(struct ip_vs_service_u
 	*svc_p = svc;
 	return 0;
 
-  out_err:
+ out_err:
 	if (svc != NULL) {
 		if (svc->scheduler)
 			ip_vs_unbind_scheduler(svc);
@@ -1217,7 +1217,6 @@ ip_vs_add_service(struct ip_vs_service_u
 	}
 	ip_vs_scheduler_put(sched);
 
-  out_mod_dec:
 	/* decrease the module use count */
 	ip_vs_use_count_dec();
 
@@ -1300,10 +1299,7 @@ ip_vs_edit_service(struct ip_vs_service
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
 
@@ -1327,8 +1323,7 @@ static void __ip_vs_del_service(struct i
 	/* Unbind scheduler */
 	old_sched = svc->scheduler;
 	ip_vs_unbind_scheduler(svc);
-	if (old_sched)
-		ip_vs_scheduler_put(old_sched);
+	ip_vs_scheduler_put(old_sched);
 
 	/* Unbind app inc */
 	if (svc->inc) {
Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_sched.c
===================================================================
--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_sched.c	2010-10-01 22:25:53.000000000 +0900
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_sched.c	2010-10-01 22:26:10.000000000 +0900
@@ -159,7 +159,7 @@ struct ip_vs_scheduler *ip_vs_scheduler_
 
 void ip_vs_scheduler_put(struct ip_vs_scheduler *scheduler)
 {
-	if (scheduler->module)
+	if (scheduler && scheduler->module)
 		module_put(scheduler->module);
 }
 

