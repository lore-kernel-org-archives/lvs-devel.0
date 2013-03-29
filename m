From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 07/34] ipvs: do not use skb_share_check
Date: Fri, 29 Mar 2013 13:11:24 +0900
Message-ID: <1364530311-11512-8-git-send-email-horms@verge.net.au>
References: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

We run in contexts like ip_rcv, ipv6_rcv, br_handle_frame,
do not expect shared skbs.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c |   45 ++-------------------------------------
 1 file changed, 2 insertions(+), 43 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index c942d36..e6e2d3f 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -421,14 +421,6 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error;
 	}
 
-	/*
-	 * Call ip_send_check because we are not sure it is called
-	 * after ip_defrag. Is copy-on-write needed?
-	 */
-	if (unlikely((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)) {
-		ip_rt_put(rt);
-		return NF_STOLEN;
-	}
 	ip_send_check(ip_hdr(skb));
 
 	/* drop old route */
@@ -482,16 +474,6 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error;
 	}
 
-	/*
-	 * Call ip_send_check because we are not sure it is called
-	 * after ip_defrag. Is copy-on-write needed?
-	 */
-	skb = skb_share_check(skb, GFP_ATOMIC);
-	if (unlikely(skb == NULL)) {
-		dst_release(&rt->dst);
-		return NF_STOLEN;
-	}
-
 	/* drop old route */
 	skb_dst_drop(skb);
 	skb_dst_set(skb, &rt->dst);
@@ -708,7 +690,6 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	ipv6_hdr(skb)->daddr = cp->daddr.in6;
 
 	if (!local || !skb->dev) {
-		/* drop the old route when skb is not shared */
 		skb_dst_drop(skb);
 		skb_dst_set(skb, &rt->dst);
 	} else {
@@ -814,8 +795,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	 */
 	max_headroom = LL_RESERVED_SPACE(tdev) + sizeof(struct iphdr);
 
-	if (skb_headroom(skb) < max_headroom
-	    || skb_cloned(skb) || skb_shared(skb)) {
+	if (skb_headroom(skb) < max_headroom || skb_cloned(skb)) {
 		struct sk_buff *new_skb =
 			skb_realloc_headroom(skb, max_headroom);
 		if (!new_skb) {
@@ -935,8 +915,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	 */
 	max_headroom = LL_RESERVED_SPACE(tdev) + sizeof(struct ipv6hdr);
 
-	if (skb_headroom(skb) < max_headroom
-	    || skb_cloned(skb) || skb_shared(skb)) {
+	if (skb_headroom(skb) < max_headroom || skb_cloned(skb)) {
 		struct sk_buff *new_skb =
 			skb_realloc_headroom(skb, max_headroom);
 		if (!new_skb) {
@@ -1034,14 +1013,6 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error;
 	}
 
-	/*
-	 * Call ip_send_check because we are not sure it is called
-	 * after ip_defrag. Is copy-on-write needed?
-	 */
-	if (unlikely((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)) {
-		ip_rt_put(rt);
-		return NF_STOLEN;
-	}
 	ip_send_check(ip_hdr(skb));
 
 	/* drop old route */
@@ -1099,16 +1070,6 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error;
 	}
 
-	/*
-	 * Call ip_send_check because we are not sure it is called
-	 * after ip_defrag. Is copy-on-write needed?
-	 */
-	skb = skb_share_check(skb, GFP_ATOMIC);
-	if (unlikely(skb == NULL)) {
-		dst_release(&rt->dst);
-		return NF_STOLEN;
-	}
-
 	/* drop old route */
 	skb_dst_drop(skb);
 	skb_dst_set(skb, &rt->dst);
@@ -1220,7 +1181,6 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	ip_vs_nat_icmp(skb, pp, cp, 0);
 
 	if (!local) {
-		/* drop the old route when skb is not shared */
 		skb_dst_drop(skb);
 		skb_dst_set(skb, &rt->dst);
 	} else
@@ -1337,7 +1297,6 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	ip_vs_nat_icmp_v6(skb, pp, cp, 0);
 
 	if (!local || !skb->dev) {
-		/* drop the old route when skb is not shared */
 		skb_dst_drop(skb);
 		skb_dst_set(skb, &rt->dst);
 	} else {
-- 
1.7.10.4

