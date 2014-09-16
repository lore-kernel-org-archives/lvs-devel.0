From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 08/21] ipvs: Pull out update_pmtu code
Date: Tue, 16 Sep 2014 09:34:22 +0900
Message-ID: <1410827675-3637-9-git-send-email-horms@verge.net.au>
References: <1410827675-3637-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1410827675-3637-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Alex Gartrell <agartrell@fb.com>, Simon Horman <horms@verge.net.au>

From: Alex Gartrell <agartrell@fb.com>

Another step toward heterogeneous pools, this removes another piece of
functionality currently specific to each address family type.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index b3b54d7..034a282 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -204,6 +204,15 @@ static inline bool crosses_local_route_boundary(int skb_af, struct sk_buff *skb,
 	return false;
 }
 
+static inline void maybe_update_pmtu(int skb_af, struct sk_buff *skb, int mtu)
+{
+	struct sock *sk = skb->sk;
+	struct rtable *ort = skb_rtable(skb);
+
+	if (!skb->dev && sk && sk->sk_state != TCP_TIME_WAIT)
+		ort->dst.ops->update_pmtu(&ort->dst, sk, NULL, mtu);
+}
+
 /* Get route to destination or remote server */
 static int
 __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
@@ -213,7 +222,6 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_dest_dst *dest_dst;
 	struct rtable *rt;			/* Route to the other host */
-	struct rtable *ort;			/* Original route */
 	struct iphdr *iph;
 	__be16 df;
 	int mtu;
@@ -284,16 +292,12 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 		mtu = dst_mtu(&rt->dst);
 		df = iph->frag_off & htons(IP_DF);
 	} else {
-		struct sock *sk = skb->sk;
-
 		mtu = dst_mtu(&rt->dst) - sizeof(struct iphdr);
 		if (mtu < 68) {
 			IP_VS_DBG_RL("%s(): mtu less than 68\n", __func__);
 			goto err_put;
 		}
-		ort = skb_rtable(skb);
-		if (!skb->dev && sk && sk->sk_state != TCP_TIME_WAIT)
-			ort->dst.ops->update_pmtu(&ort->dst, sk, NULL, mtu);
+		maybe_update_pmtu(skb_af, skb, mtu);
 		/* MTU check allowed? */
 		df = sysctl_pmtu_disc(ipvs) ? iph->frag_off & htons(IP_DF) : 0;
 	}
@@ -372,7 +376,6 @@ __ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	struct ip_vs_dest_dst *dest_dst;
 	struct rt6_info *rt;			/* Route to the other host */
-	struct rt6_info *ort;			/* Original route */
 	struct dst_entry *dst;
 	int mtu;
 	int local, noref = 1;
@@ -438,17 +441,13 @@ __ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 	if (likely(!(rt_mode & IP_VS_RT_MODE_TUNNEL)))
 		mtu = dst_mtu(&rt->dst);
 	else {
-		struct sock *sk = skb->sk;
-
 		mtu = dst_mtu(&rt->dst) - sizeof(struct ipv6hdr);
 		if (mtu < IPV6_MIN_MTU) {
 			IP_VS_DBG_RL("%s(): mtu less than %d\n", __func__,
 				     IPV6_MIN_MTU);
 			goto err_put;
 		}
-		ort = (struct rt6_info *) skb_dst(skb);
-		if (!skb->dev && sk && sk->sk_state != TCP_TIME_WAIT)
-			ort->dst.ops->update_pmtu(&ort->dst, sk, NULL, mtu);
+		maybe_update_pmtu(skb_af, skb, mtu);
 	}
 
 	if (unlikely(__mtu_check_toobig_v6(skb, mtu))) {
-- 
2.0.1
