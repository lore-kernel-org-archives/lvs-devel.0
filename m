From: Simon Horman <horms@verge.net.au>
Subject: [patch] ipvs: remove EXPERIMENTAL tag
Date: Mon, 26 Jul 2010 16:56:09 +0900
Message-ID: <20100726075609.GA11755@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

IPVS was merged into the kernel quite a long time ago and
has been seeing wide-spread production use for even longer.

It seems appropriate for it to be no longer tagged as EXPERIMENTAL

Signed-off-as: Simon Horman <horms@verge.net.au>

Index: nf-next-2.6/net/netfilter/ipvs/Kconfig
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/Kconfig	2010-07-26 16:44:36.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/Kconfig	2010-07-26 16:45:02.000000000 +0900
@@ -26,7 +26,7 @@ if IP_VS
 
 config	IP_VS_IPV6
 	bool "IPv6 support for IPVS"
-	depends on EXPERIMENTAL && (IPV6 = y || IP_VS = IPV6)
+	depends on IPV6 = y || IP_VS = IPV6
 	---help---
 	  Add IPv6 support to IPVS. This is incomplete and might be dangerous.
 
