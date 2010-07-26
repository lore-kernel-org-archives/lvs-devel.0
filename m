From: Simon Horman <horms@verge.net.au>
Subject: [patch 1/5] ipvsadm: Add --ipv6 to ipvsadm.8
Date: Mon, 26 Jul 2010 17:04:49 +0900
Message-ID: <20100726080645.453757910@vergenet.net>
References: <20100726080448.476781076@vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=ip6-man.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Nick Chalk <nick@loadbalancer.org>

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: trunk/ipvsadm.8
===================================================================
--- trunk.orig/ipvsadm.8	2010-07-25 21:00:51.000000000 +0900
+++ trunk/ipvsadm.8	2010-07-25 21:00:54.000000000 +0900
@@ -412,7 +412,7 @@ counters,  instead  of only the rounded
 1000) M's (multiples of 1000K) or G's (multiples  of 1000M).  This
 option is only relevant for the -L command.
 .TP
-.B -6
+.B -6, --ipv6
 Use with -f to signify fwmark rule uses IPv6 addresses.
 .SH EXAMPLE 1 - Simple Virtual Service
 The following commands configure a Linux Director to distribute

