From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 06/15] ipvs: no need to reroute anymore on DNAT over loopback
Date: Thu, 28 Mar 2013 14:39:35 +0900
Message-ID: <1364449184-26672-7-git-send-email-horms@verge.net.au>
References: <1364449184-26672-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1364449184-26672-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

After commit 70e7341673 (ipv4: Show that ip_send_reply()
is purely unicast routine.) we do not need to reroute DNAT-ed
traffic over loopback because reply uses iph daddr and not
rt_spec_dst.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c |   58 ++-------------------------------------
 1 file changed, 2 insertions(+), 56 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 6448a2e..c942d36 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -207,44 +207,6 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 	return rt;
 }
 
-/* Reroute packet to local IPv4 stack after DNAT */
-static int
-__ip_vs_reroute_locally(struct sk_buff *skb)
-{
-	struct rtable *rt = skb_rtable(skb);
-	struct net_device *dev = rt->dst.dev;
-	struct net *net = dev_net(dev);
-	struct iphdr *iph = ip_hdr(skb);
-
-	if (rt_is_input_route(rt)) {
-		unsigned long orefdst = skb->_skb_refdst;
-
-		if (ip_route_input(skb, iph->daddr, iph->saddr,
-				   iph->tos, skb->dev))
-			return 0;
-		refdst_drop(orefdst);
-	} else {
-		struct flowi4 fl4 = {
-			.daddr = iph->daddr,
-			.saddr = iph->saddr,
-			.flowi4_tos = RT_TOS(iph->tos),
-			.flowi4_mark = skb->mark,
-		};
-
-		rt = ip_route_output_key(net, &fl4);
-		if (IS_ERR(rt))
-			return 0;
-		if (!(rt->rt_flags & RTCF_LOCAL)) {
-			ip_rt_put(rt);
-			return 0;
-		}
-		/* Drop old route. */
-		skb_dst_drop(skb);
-		skb_dst_set(skb, &rt->dst);
-	}
-	return 1;
-}
-
 #ifdef CONFIG_IP_VS_IPV6
 
 static inline int __ip_vs_is_local_route6(struct rt6_info *rt)
@@ -635,16 +597,8 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		/* drop old route */
 		skb_dst_drop(skb);
 		skb_dst_set(skb, &rt->dst);
-	} else {
+	} else
 		ip_rt_put(rt);
-		/*
-		 * Some IPv4 replies get local address from routes,
-		 * not from iph, so while we DNAT after routing
-		 * we need this second input/output route.
-		 */
-		if (!__ip_vs_reroute_locally(skb))
-			goto tx_error;
-	}
 
 	IP_VS_DBG_PKT(10, AF_INET, pp, skb, 0, "After DNAT");
 
@@ -1269,16 +1223,8 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		/* drop the old route when skb is not shared */
 		skb_dst_drop(skb);
 		skb_dst_set(skb, &rt->dst);
-	} else {
+	} else
 		ip_rt_put(rt);
-		/*
-		 * Some IPv4 replies get local address from routes,
-		 * not from iph, so while we DNAT after routing
-		 * we need this second input/output route.
-		 */
-		if (!__ip_vs_reroute_locally(skb))
-			goto tx_error;
-	}
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
-- 
1.7.10.4

