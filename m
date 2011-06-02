From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] ipvs: restore support for iptables SNAT
Date: Thu,  2 Jun 2011 09:09:54 +0900
Message-ID: <1306973394-29504-2-git-send-email-horms@verge.net.au>
References: <1306973394-29504-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1306973394-29504-1-git-send-email-horms@verge.net.au>
Sender: netfilter-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

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
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index bfa808f..55af224 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1772,7 +1772,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
 		.hooknum	= NF_INET_LOCAL_IN,
-		.priority	= 99,
+		.priority	= NF_IP_PRI_NAT_SRC - 2,
 	},
 	/* After packet filtering, forward packet through VS/DR, VS/TUN,
 	 * or VS/NAT(change destination), so that filtering rules can be
@@ -1782,7 +1782,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
 		.hooknum	= NF_INET_LOCAL_IN,
-		.priority	= 101,
+		.priority	= NF_IP_PRI_NAT_SRC - 1,
 	},
 	/* Before ip_vs_in, change source only for VS/NAT */
 	{
@@ -1790,7 +1790,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
 		.hooknum	= NF_INET_LOCAL_OUT,
-		.priority	= -99,
+		.priority	= NF_IP_PRI_NAT_DST + 1,
 	},
 	/* After mangle, schedule and forward local requests */
 	{
@@ -1798,7 +1798,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
 		.hooknum	= NF_INET_LOCAL_OUT,
-		.priority	= -98,
+		.priority	= NF_IP_PRI_NAT_DST + 2,
 	},
 	/* After packet filtering (but before ip_vs_out_icmp), catch icmp
 	 * destined for 0.0.0.0/0, which is for incoming IPVS connections */
@@ -1824,7 +1824,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
 		.hooknum	= NF_INET_LOCAL_IN,
-		.priority	= 99,
+		.priority	= NF_IP6_PRI_NAT_SRC - 2,
 	},
 	/* After packet filtering, forward packet through VS/DR, VS/TUN,
 	 * or VS/NAT(change destination), so that filtering rules can be
@@ -1834,7 +1834,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
 		.hooknum	= NF_INET_LOCAL_IN,
-		.priority	= 101,
+		.priority	= NF_IP6_PRI_NAT_SRC - 1,
 	},
 	/* Before ip_vs_in, change source only for VS/NAT */
 	{
@@ -1842,7 +1842,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
 		.hooknum	= NF_INET_LOCAL_OUT,
-		.priority	= -99,
+		.priority	= NF_IP6_PRI_NAT_DST + 1,
 	},
 	/* After mangle, schedule and forward local requests */
 	{
@@ -1850,7 +1850,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
 		.hooknum	= NF_INET_LOCAL_OUT,
-		.priority	= -98,
+		.priority	= NF_IP6_PRI_NAT_DST + 2,
 	},
 	/* After packet filtering (but before ip_vs_out_icmp), catch icmp
 	 * destined for 0.0.0.0/0, which is for incoming IPVS connections */
-- 
1.7.4.4

