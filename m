From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipvs: avoid lookup for fwmark 0
Date: Fri, 4 Mar 2011 12:26:17 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103041224010.1452@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org


 	Restore the previous behaviour to lookup for fwmark
service only when fwmark is non-null. This saves only CPU.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

--- lvs-test-2.6-8a80c79/net/netfilter/ipvs/ip_vs_ctl.c	2011-02-28 19:02:33.000000000 +0200
+++ linux/net/netfilter/ipvs/ip_vs_ctl.c	2011-03-03 19:11:17.300378354 +0200
@@ -411,9 +411,11 @@ ip_vs_service_get(struct net *net, int a
  	/*
  	 *	Check the table hashed by fwmark first
  	 */
-	svc = __ip_vs_svc_fwm_find(net, af, fwmark);
-	if (fwmark && svc)
-		goto out;
+	if (fwmark) {
+		svc = __ip_vs_svc_fwm_find(net, af, fwmark);
+		if (svc)
+			goto out;
+	}

  	/*
  	 *	Check the table hashed by <protocol,addr,port>
