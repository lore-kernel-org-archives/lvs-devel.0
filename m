From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v2 07/18] ipvs: Pull out update_pmtu code
Date: Thu, 14 Aug 2014 20:23:30 -0700
Message-ID: <1408073021-24007-8-git-send-email-agartrell@fb.com>
References: <1408073021-24007-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=mp/p5p1TbFDWo4xXgqlIJikW9MA4oRUrVDGQpWjR+20=;
 b=WXd+zTgGU+vW3iASEWv+D3vjK0R7oUeA+pMWbKVVKMXByWNC8N2XJnawrOTXeKoHrB86
 4SSkc9wXruwCzd3TNhVsfsEiktF1FuWnAK15+cfFZBgK3qaXRgV10vrSkh4Xj6cW5Bp6
 XQzZu7qPPCkhUaZaWS0MiSSCUrfG7ax88vg= 
In-Reply-To: <1408073021-24007-1-git-send-email-agartrell@fb.com>
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
 net/netfilter/ipvs/ip_vs_xmit.c | 33 +++++++++++++++++++++------------
 1 file changed, 21 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index b348347..193ad01 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -200,6 +200,25 @@ static inline bool crosses_local_route_boundary(int skb_af, struct sk_buff *skb,
 	return false;
 }
 
+static inline void maybe_update_pmtu(int skb_af, struct sk_buff *skb, int mtu)
+{
+	struct sock *sk = skb->sk;
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (skb_af == AF_INET6) {
+		struct rt6_info *ort = (struct rt6_info *) skb_dst(skb);
+		if (!skb->dev && sk && sk->sk_state != TCP_TIME_WAIT)
+			ort->dst.ops->update_pmtu(&ort->dst, sk, NULL, mtu);
+
+	} else
+#endif
+	{
+		struct rtable *ort = skb_rtable(skb);
+		if (!skb->dev && sk && sk->sk_state != TCP_TIME_WAIT)
+			ort->dst.ops->update_pmtu(&ort->dst, sk, NULL, mtu);
+	}
+}
+
 /* Get route to destination or remote server */
 static int
 __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
@@ -209,7 +228,6 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_dest_dst *dest_dst;
 	struct rtable *rt;			/* Route to the other host */
-	struct rtable *ort;			/* Original route */
 	struct iphdr *iph;
 	__be16 df;
 	int mtu;
@@ -279,16 +297,12 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
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
@@ -367,7 +381,6 @@ __ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	struct ip_vs_dest_dst *dest_dst;
 	struct rt6_info *rt;			/* Route to the other host */
-	struct rt6_info *ort;			/* Original route */
 	struct dst_entry *dst;
 	int mtu;
 	int local, noref = 1;
@@ -432,17 +445,13 @@ __ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 	if (likely(!(rt_mode & IP_VS_RT_MODE_TUNNEL)))
 		mtu = dst_mtu(&rt->dst);
 	else {
-		struct sock *sk = skb->sk;
