From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 04/34] ipvs: convert the IP_VS_XMIT macros to functions
Date: Fri, 29 Mar 2013 13:11:21 +0900
Message-ID: <1364530311-11512-5-git-send-email-horms@verge.net.au>
References: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

It was a bad idea to hide return statements in macros.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c |  134 +++++++++++++++++++++------------------
 1 file changed, 72 insertions(+), 62 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 4b0bd15..7cd7c61 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -376,45 +376,59 @@ ip_vs_dst_reset(struct ip_vs_dest *dest)
 	dest->dst_saddr.ip = 0;
 }
 
-#define IP_VS_XMIT_TUNNEL(skb, cp)				\
-({								\
-	int __ret = NF_ACCEPT;					\
-								\
-	(skb)->ipvs_property = 1;				\
-	if (unlikely((cp)->flags & IP_VS_CONN_F_NFCT))		\
-		__ret = ip_vs_confirm_conntrack(skb);		\
-	if (__ret == NF_ACCEPT) {				\
-		nf_reset(skb);					\
-		skb_forward_csum(skb);				\
-	}							\
-	__ret;							\
-})
-
-#define IP_VS_XMIT_NAT(pf, skb, cp, local)		\
-do {							\
-	(skb)->ipvs_property = 1;			\
-	if (likely(!((cp)->flags & IP_VS_CONN_F_NFCT)))	\
-		ip_vs_notrack(skb);			\
-	else						\
-		ip_vs_update_conntrack(skb, cp, 1);	\
-	if (local)					\
-		return NF_ACCEPT;			\
-	skb_forward_csum(skb);				\
-	NF_HOOK(pf, NF_INET_LOCAL_OUT, (skb), NULL,	\
-		skb_dst(skb)->dev, dst_output);		\
-} while (0)
-
-#define IP_VS_XMIT(pf, skb, cp, local)			\
-do {							\
-	(skb)->ipvs_property = 1;			\
-	if (likely(!((cp)->flags & IP_VS_CONN_F_NFCT)))	\
-		ip_vs_notrack(skb);			\
-	if (local)					\
-		return NF_ACCEPT;			\
-	skb_forward_csum(skb);				\
-	NF_HOOK(pf, NF_INET_LOCAL_OUT, (skb), NULL,	\
-		skb_dst(skb)->dev, dst_output);		\
-} while (0)
+/* return NF_ACCEPT to allow forwarding or other NF_xxx on error */
+static inline int ip_vs_tunnel_xmit_prepare(struct sk_buff *skb,
+					    struct ip_vs_conn *cp)
+{
+	int ret = NF_ACCEPT;
+
+	skb->ipvs_property = 1;
+	if (unlikely(cp->flags & IP_VS_CONN_F_NFCT))
+		ret = ip_vs_confirm_conntrack(skb);
+	if (ret == NF_ACCEPT) {
+		nf_reset(skb);
+		skb_forward_csum(skb);
+	}
+	return ret;
+}
+
+/* return NF_STOLEN (sent) or NF_ACCEPT if local=1 (not sent) */
+static inline int ip_vs_nat_send_or_cont(int pf, struct sk_buff *skb,
+					 struct ip_vs_conn *cp, int local)
+{
+	int ret = NF_STOLEN;
+
+	skb->ipvs_property = 1;
+	if (likely(!(cp->flags & IP_VS_CONN_F_NFCT)))
+		ip_vs_notrack(skb);
+	else
+		ip_vs_update_conntrack(skb, cp, 1);
+	if (!local) {
+		skb_forward_csum(skb);
+		NF_HOOK(pf, NF_INET_LOCAL_OUT, skb, NULL, skb_dst(skb)->dev,
+			dst_output);
+	} else
+		ret = NF_ACCEPT;
+	return ret;
+}
+
+/* return NF_STOLEN (sent) or NF_ACCEPT if local=1 (not sent) */
+static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
+				     struct ip_vs_conn *cp, int local)
+{
+	int ret = NF_STOLEN;
+
+	skb->ipvs_property = 1;
+	if (likely(!(cp->flags & IP_VS_CONN_F_NFCT)))
+		ip_vs_notrack(skb);
+	if (!local) {
+		skb_forward_csum(skb);
+		NF_HOOK(pf, NF_INET_LOCAL_OUT, skb, NULL, skb_dst(skb)->dev,
+			dst_output);
+	} else
+		ret = NF_ACCEPT;
+	return ret;
+}
 
 
 /*
@@ -425,7 +439,7 @@ ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	/* we do not touch skb and do not need pskb ptr */
-	IP_VS_XMIT(NFPROTO_IPV4, skb, cp, 1);
+	return ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 1);
 }
 
 
@@ -476,7 +490,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(NFPROTO_IPV4, skb, cp, 0);
+	ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 0);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -537,7 +551,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(NFPROTO_IPV6, skb, cp, 0);
+	ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 0);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -562,7 +576,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	struct rtable *rt;		/* Route to the other host */
 	int mtu;
 	struct iphdr *iph = ip_hdr(skb);
-	int local;
+	int local, rc;
 
 	EnterFunction(10);
 
@@ -655,10 +669,10 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT_NAT(NFPROTO_IPV4, skb, cp, local);
+	rc = ip_vs_nat_send_or_cont(NFPROTO_IPV4, skb, cp, local);
 
 	LeaveFunction(10);
-	return NF_STOLEN;
+	return rc;
 
   tx_error_icmp:
 	dst_link_failure(skb);
@@ -678,7 +692,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 {
 	struct rt6_info *rt;		/* Route to the other host */
 	int mtu;
-	int local;
+	int local, rc;
 
 	EnterFunction(10);
 
@@ -771,10 +785,10 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT_NAT(NFPROTO_IPV6, skb, cp, local);
+	rc = ip_vs_nat_send_or_cont(NFPROTO_IPV6, skb, cp, local);
 
 	LeaveFunction(10);
-	return NF_STOLEN;
+	return rc;
 
 tx_error_icmp:
 	dst_link_failure(skb);
@@ -833,7 +847,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error_icmp;
 	if (rt->rt_flags & RTCF_LOCAL) {
 		ip_rt_put(rt);
-		IP_VS_XMIT(NFPROTO_IPV4, skb, cp, 1);
+		return ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 1);
 	}
 
 	tdev = rt->dst.dev;
@@ -905,7 +919,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	ret = IP_VS_XMIT_TUNNEL(skb, cp);
+	ret = ip_vs_tunnel_xmit_prepare(skb, cp);
 	if (ret == NF_ACCEPT)
 		ip_local_out(skb);
 	else if (ret == NF_DROP)
@@ -948,7 +962,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error_icmp;
 	if (__ip_vs_is_local_route6(rt)) {
 		dst_release(&rt->dst);
-		IP_VS_XMIT(NFPROTO_IPV6, skb, cp, 1);
+		return ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 1);
 	}
 
 	tdev = rt->dst.dev;
@@ -1023,7 +1037,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	ret = IP_VS_XMIT_TUNNEL(skb, cp);
+	ret = ip_vs_tunnel_xmit_prepare(skb, cp);
 	if (ret == NF_ACCEPT)
 		ip6_local_out(skb);
 	else if (ret == NF_DROP)
@@ -1067,7 +1081,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error_icmp;
 	if (rt->rt_flags & RTCF_LOCAL) {
 		ip_rt_put(rt);
-		IP_VS_XMIT(NFPROTO_IPV4, skb, cp, 1);
+		return ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 1);
 	}
 
 	/* MTU checking */
@@ -1097,7 +1111,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(NFPROTO_IPV4, skb, cp, 0);
+	ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 0);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -1126,7 +1140,7 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error_icmp;
 	if (__ip_vs_is_local_route6(rt)) {
 		dst_release(&rt->dst);
-		IP_VS_XMIT(NFPROTO_IPV6, skb, cp, 1);
+		return ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 1);
 	}
 
 	/* MTU checking */
@@ -1162,7 +1176,7 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(NFPROTO_IPV6, skb, cp, 0);
+	ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 0);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -1283,9 +1297,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT_NAT(NFPROTO_IPV4, skb, cp, local);
-
-	rc = NF_STOLEN;
+	rc = ip_vs_nat_send_or_cont(NFPROTO_IPV4, skb, cp, local);
 	goto out;
 
   tx_error_icmp:
@@ -1404,9 +1416,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT_NAT(NFPROTO_IPV6, skb, cp, local);
-
-	rc = NF_STOLEN;
+	rc = ip_vs_nat_send_or_cont(NFPROTO_IPV6, skb, cp, local);
 	goto out;
 
 tx_error_icmp:
-- 
1.7.10.4
