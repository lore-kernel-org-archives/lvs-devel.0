From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re: [PATCH] ipvs: avoid lookup for fwmark 0
Date: Fri, 4 Mar 2011 11:48:18 +0100 (CET)
Message-ID: <6pi9527.faa88a21c91dd91114c03a4bcb764c6e@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org


>---- Original Message ----
>From: Julian Anastasov <ja@ssi.bg>
>To: "Simon Horman" <horms@verge.net.au>
>Cc: lvs-devel@vger.kernel.org
>Sent: Fri, Mar 4, 2011, 11:22 AM
>Subject: [PATCH] ipvs: avoid lookup for fwmark 0
>
>Restore the previous behaviour to lookup for fwmark
>service only when fwmark is non-null. This saves only CPU.

Good point.
>
>Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>

>---
>
>--- lvs-test-2.6-8a80c79/net/netfilter/ipvs/ip_vs_ctl.c	2011-02-28 19:02:33.000000000 +0200
>+++ linux/net/netfilter/ipvs/ip_vs_ctl.c	2011-03-03 19:11:17.300378354 +0200
>@@ -411,9 +411,11 @@ ip_vs_service_get(struct net *net, int a
>  	/*
>  	 *	Check the table hashed by fwmark first
>  	 */
>-	svc = __ip_vs_svc_fwm_find(net, af, fwmark);
>-	if (fwmark && svc)
>-		goto out;
>+	if (fwmark) {
>+		svc = __ip_vs_svc_fwm_find(net, af, fwmark);
>+		if (svc)
>+			goto out;
>+	}
>
>  	/*
>  	 *	Check the table hashed by <protocol,addr,port>
>--
>To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

