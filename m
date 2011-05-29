From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipvs: restore support for iptables SNAT
Date: Mon, 30 May 2011 01:01:37 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1105300025090.1429@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org


	Fix the IPVS priority in LOCAL_IN hook,
so that SNAT target in POSTROUTING is supported for IPVS
traffic as in 2.6.36 where it worked depending on
module load order.

	Before 2.6.37 we used priority 100 in LOCAL_IN to
process remote requests. We used the same priority as
iptables SNAT and if IPVS handlers are installed before
SNAT handlers we supported SNAT in POSTROUTING for the IPVS
traffic. If SNAT is installed before IPVS, the netfilter
handlers are before IPVS and netfilter checks the NAT
table twice for the IPVS requests: once in LOCAL_IN where
IPS_SRC_NAT_DONE is set and second time in POSTROUTING
where the SNAT rules are ignored because IPS_SRC_NAT_DONE
was already set in LOCAL_IN.

	But in 2.6.37 we changed the IPVS priority for
LOCAL_IN with the goal to be unique (101) forgetting the
fact that for IPVS traffic we should not walk both
LOCAL_IN and POSTROUTING nat tables.

	So, change the priority for processing remote
IPVS requests from 101 to 99, i.e. before NAT_SRC (100)
because we prefer to support SNAT in POSTROUTING
instead of LOCAL_IN. It also moves the priority for
IPVS replies from 99 to 98. Use constants instead of
magic numbers at these places.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

	Patch is against 2.6.39 but it applies also to
ipvs-next-2.6-e3f6a65. It is a regression and the fix
can go to the -rc kernels.

diff -urp v2.6.39/linux/net/netfilter/ipvs/ip_vs_core.c linux/net/netfilter/ipvs/ip_vs_core.c
--- v2.6.39/linux/net/netfilter/ipvs/ip_vs_core.c	2011-05-30 00:04:52.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_core.c	2011-05-30 00:09:02.879248364 +0300
@@ -1792,7 +1792,7 @@ static struct nf_hook_ops ip_vs_ops[] __
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
 		.hooknum	= NF_INET_LOCAL_IN,
-		.priority	= 99,
+		.priority	= NF_IP_PRI_NAT_SRC - 2,
 	},
 	/* After packet filtering, forward packet through VS/DR, VS/TUN,
 	 * or VS/NAT(change destination), so that filtering rules can be
@@ -1802,7 +1802,7 @@ static struct nf_hook_ops ip_vs_ops[] __
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
 		.hooknum	= NF_INET_LOCAL_IN,
-		.priority	= 101,
+		.priority	= NF_IP_PRI_NAT_SRC - 1,
 	},
 	/* Before ip_vs_in, change source only for VS/NAT */
 	{
@@ -1810,7 +1810,7 @@ static struct nf_hook_ops ip_vs_ops[] __
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
 		.hooknum	= NF_INET_LOCAL_OUT,
-		.priority	= -99,
+		.priority	= NF_IP_PRI_NAT_DST + 1,
 	},
 	/* After mangle, schedule and forward local requests */
 	{
@@ -1818,7 +1818,7 @@ static struct nf_hook_ops ip_vs_ops[] __
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
 		.hooknum	= NF_INET_LOCAL_OUT,
-		.priority	= -98,
+		.priority	= NF_IP_PRI_NAT_DST + 2,
 	},
 	/* After packet filtering (but before ip_vs_out_icmp), catch icmp
 	 * destined for 0.0.0.0/0, which is for incoming IPVS connections */
@@ -1844,7 +1844,7 @@ static struct nf_hook_ops ip_vs_ops[] __
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
 		.hooknum	= NF_INET_LOCAL_IN,
-		.priority	= 99,
+		.priority	= NF_IP6_PRI_NAT_SRC - 2,
 	},
 	/* After packet filtering, forward packet through VS/DR, VS/TUN,
 	 * or VS/NAT(change destination), so that filtering rules can be
@@ -1854,7 +1854,7 @@ static struct nf_hook_ops ip_vs_ops[] __
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
 		.hooknum	= NF_INET_LOCAL_IN,
-		.priority	= 101,
+		.priority	= NF_IP6_PRI_NAT_SRC - 1,
 	},
 	/* Before ip_vs_in, change source only for VS/NAT */
 	{
@@ -1862,7 +1862,7 @@ static struct nf_hook_ops ip_vs_ops[] __
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
 		.hooknum	= NF_INET_LOCAL_OUT,
-		.priority	= -99,
+		.priority	= NF_IP6_PRI_NAT_DST + 1,
 	},
 	/* After mangle, schedule and forward local requests */
 	{
@@ -1870,7 +1870,7 @@ static struct nf_hook_ops ip_vs_ops[] __
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
 		.hooknum	= NF_INET_LOCAL_OUT,
-		.priority	= -98,
+		.priority	= NF_IP6_PRI_NAT_DST + 2,
 	},
 	/* After packet filtering (but before ip_vs_out_icmp), catch icmp
 	 * destined for 0.0.0.0/0, which is for incoming IPVS connections */
