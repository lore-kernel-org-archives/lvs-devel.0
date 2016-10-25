From: Dwip Banerjee <dwip@linux.vnet.ibm.com>
Subject: [PATCH V2] ipvs does not decrement IP ttl
Date: Tue, 25 Oct 2016 16:41:09 -0500
Message-ID: <1477431669-2782-1-git-send-email-dwip@linux.vnet.ibm.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: dwip@linux.vnet.ibm.com

We decrement the IP ttl in all the modes in order to prevent infinite
route loops. The changes were done based on Julian Anastasov's
suggestions in a prior thread.

The ttl based check/discard and the actual decrement are done in
__ip_vs_get_out_rt() and in __ip_vs_get_out_rt_v6(), for the IPv6
case. decrement_ttl() implements the actual functionality for the
two cases.


Signed-off-by: Dwip Banerjee <dwip@linux.vnet.ibm.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c |   53 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 53 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 01d3d89..724fd29 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -254,6 +254,53 @@ static inline bool ensure_mtu_is_adequate(struct netns_ipvs *ipvs, int skb_af,
 	return true;
 }
 
+static inline bool decrement_ttl(struct netns_ipvs *ipvs,
+				 int skb_af,
+				 struct sk_buff *skb)
+{
+	struct net *net = ipvs->net;
+#ifdef CONFIG_IP_VS_IPV6
+	if (skb_af == AF_INET6) {
+		struct dst_entry *dst = skb_dst(skb);
+
+		/* check and decrement ttl */
+		if (ipv6_hdr(skb)->hop_limit <= 1) {
+			/* Force OUTPUT device used as source address */
+			skb->dev = dst->dev;
+			icmpv6_send(skb, ICMPV6_TIME_EXCEED,
+					 ICMPV6_EXC_HOPLIMIT, 0);
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
@@ -326,6 +373,9 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 		return local;
 	}
 
+	if (!decrement_ttl(ipvs, skb_af, skb))
+		goto err_put;
+
 	if (likely(!(rt_mode & IP_VS_RT_MODE_TUNNEL))) {
 		mtu = dst_mtu(&rt->dst);
 	} else {
@@ -473,6 +523,9 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 		return local;
 	}
 
+	if (!decrement_ttl(ipvs, skb_af, skb))
+		goto err_put;
+
 	/* MTU checking */
 	if (likely(!(rt_mode & IP_VS_RT_MODE_TUNNEL)))
 		mtu = dst_mtu(&rt->dst);
-- 
1.7.1

