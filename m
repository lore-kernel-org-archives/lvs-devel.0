From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 2/2] ipvs: Decrement ttl
Date: Tue, 15 Nov 2016 10:01:43 +0100
Message-ID: <1479200503-25842-3-git-send-email-horms@verge.net.au>
References: <1479200503-25842-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1479200513; bh=l2WHo2O3OEcbetU61ys9nVyPTWaHzWH0XINtrcb5HWY=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=kFm3PyRd9lpZkJWooAA5K7MpWYUDs5bvNto3kqpdiWwdpwPWob1CFIbIhnWGlJ3dg
         CvwhXtYgbMilbIhfrtAJMZKKq5Qk7SvpQpOSqigjE807A6vQv6bqeXE9eZTceep86w
         RpHVwtA/YzKUL/C9+67/G3PdQRSMLmqYGp0qJ5TE=
In-Reply-To: <1479200503-25842-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Dwip Banerjee <dwip@linux.vnet.ibm.com>, Simon Horman <horms@verge.net.au>

From: Dwip Banerjee <dwip@linux.vnet.ibm.com>

We decrement the IP ttl in all the modes in order to prevent infinite
route loops. The changes were done based on Julian Anastasov's
suggestions in a prior thread.

The ttl based check/discard and the actual decrement are done in
__ip_vs_get_out_rt() and in __ip_vs_get_out_rt_v6(), for the IPv6
case. decrement_ttl() implements the actual functionality for the
two cases.

Signed-off-by: Dwip Banerjee <dwip@linux.vnet.ibm.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 54 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 54 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 01d3d894de46..4e1a98fcc8c3 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -254,6 +254,54 @@ static inline bool ensure_mtu_is_adequate(struct netns_ipvs *ipvs, int skb_af,
 	return true;
 }
 
+static inline bool decrement_ttl(struct netns_ipvs *ipvs,
+				 int skb_af,
+				 struct sk_buff *skb)
+{
+	struct net *net = ipvs->net;
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (skb_af == AF_INET6) {
+		struct dst_entry *dst = skb_dst(skb);
+
+		/* check and decrement ttl */
+		if (ipv6_hdr(skb)->hop_limit <= 1) {
+			/* Force OUTPUT device used as source address */
+			skb->dev = dst->dev;
+			icmpv6_send(skb, ICMPV6_TIME_EXCEED,
+				    ICMPV6_EXC_HOPLIMIT, 0);
+			__IP6_INC_STATS(net, ip6_dst_idev(dst),
+					IPSTATS_MIB_INHDRERRORS);
+
+			return false;
+		}
+
+		/* don't propagate ttl change to cloned packets */
+		if (!skb_make_writable(skb, sizeof(struct ipv6hdr)))
+			return false;
+
+		ipv6_hdr(skb)->hop_limit--;
+	} else
+#endif
+	{
+		if (ip_hdr(skb)->ttl <= 1) {
+			/* Tell the sender its packet died... */
+			__IP_INC_STATS(net, IPSTATS_MIB_INHDRERRORS);
+			icmp_send(skb, ICMP_TIME_EXCEEDED, ICMP_EXC_TTL, 0);
+			return false;
+		}
+
+		/* don't propagate ttl change to cloned packets */
+		if (!skb_make_writable(skb, sizeof(struct iphdr)))
+			return false;
+
+		/* Decrease ttl */
+		ip_decrease_ttl(ip_hdr(skb));
+	}
+
+	return true;
+}
+
 /* Get route to destination or remote server */
 static int
 __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
@@ -326,6 +374,9 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 		return local;
 	}
 
+	if (!decrement_ttl(ipvs, skb_af, skb))
+		goto err_put;
+
 	if (likely(!(rt_mode & IP_VS_RT_MODE_TUNNEL))) {
 		mtu = dst_mtu(&rt->dst);
 	} else {
@@ -473,6 +524,9 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 		return local;
 	}
 
+	if (!decrement_ttl(ipvs, skb_af, skb))
+		goto err_put;
+
 	/* MTU checking */
 	if (likely(!(rt_mode & IP_VS_RT_MODE_TUNNEL)))
 		mtu = dst_mtu(&rt->dst);
-- 
2.7.0.rc3.207.g0ac5344

