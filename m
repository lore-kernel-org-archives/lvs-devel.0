From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next 07/20] ipvs: Pull out update_pmtu code
Date: Tue, 9 Sep 2014 16:40:26 -0700
Message-ID: <1410306039-2977-8-git-send-email-agartrell@fb.com>
References: <1410306039-2977-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=ZacdhXMczlzCC2PiC5R0RtREXSVdBhEv0jtrQGB4dzk=;
 b=dnlur0byY2YDOrHNsafv/4r7Q1lTYiKlkZNiYeWETDUoF7txIjzC4o6aSk6AZ3GMvFQE
 XCBU3vbAKzRNUCHGzZ1aTVenHOaHzyL1XS3kZ8VjNHWrLVP6GpjwgJ/G+MF9CdMwEOdT
 uwHZsvK50EuZohckqMGucEZ9GUXkq2NBLnY= 
In-Reply-To: <1410306039-2977-1-git-send-email-agartrell@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Cc: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, ps@fb.com, Alex Gartrell <agartrell@fb.com>

Another step toward heterogeneous pools, this removes another piece of
functionality currently specific to each address family type.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
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
1.8.1
