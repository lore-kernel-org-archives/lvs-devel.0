From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v3 08/20] ipvs: Pull out update_pmtu code
Date: Wed, 27 Aug 2014 22:43:42 -0700
Message-ID: <1409204634-1123-9-git-send-email-agartrell@fb.com>
References: <1409204634-1123-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=BF8c4RepMUpGvf98T02VyZMgRKfibmooXE5vttPqvME=;
 b=lrlY4CBQMsbBcr4NTgwUGRSdTU+Ax3ftGofQn44dEIaj7bGlNip/QzPoSw6aXzx4LbS/
 RINOFNGodz9f+Qy6iMrhMqGkrD2qXGcsjpRcGGTCctlTuExOyhy/Z95Me0j1EWTsA5gX
 nZL+v9IyawtsewVgVIFeIRndjRAD2isR7Yg= 
In-Reply-To: <1409204634-1123-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

Another step toward heterogeneous pools, this removes another piece of
functionality currently specific to each address family type.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index decc94c..caab1ad 100644
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
