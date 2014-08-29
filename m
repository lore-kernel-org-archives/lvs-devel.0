From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v4 09/20] ipvs: support ipv4 in ipv6 and ipv6 in ipv4 tunnel forwarding
Date: Fri, 29 Aug 2014 01:38:58 -0700
Message-ID: <1409301549-5284-10-git-send-email-agartrell@fb.com>
References: <1409301549-5284-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=d+Zn2R0hYhz+JQ7G8HMOLbzl2kMo7ZPG+86I4y6tbHs=;
 b=oMtx3lGEnMbCpyJ9FKr19NZntCBtzwRunD7wr04ffjvFtX42HHq4S19aQ9UNR9H3h+Wf
 Jd/OMmpbT0XipEGL3AlFjCzHaDqTJExK3c6si4rOyECOtitptA6U75hyxbKnOunfhBkp
 jjoxRGXe7hd2k3LxciD358xMITxkvKGQC/8= 
In-Reply-To: <1409301549-5284-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

Pull the common logic for preparing an skb to prepend the header into a
single function and then set fields such that they can be used in either
case (generalize tos and tclass to dscp, hop_limit and ttl to ttl, etc)

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_conn.c |  12 +++-
 net/netfilter/ipvs/ip_vs_xmit.c | 148 +++++++++++++++++++++++++++++-----------
 2 files changed, 117 insertions(+), 43 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index fdb4880..13e9cee 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -488,7 +488,12 @@ static inline void ip_vs_bind_xmit(struct ip_vs_conn *cp)
 		break;
 
 	case IP_VS_CONN_F_TUNNEL:
-		cp->packet_xmit = ip_vs_tunnel_xmit;
+#ifdef CONFIG_IP_VS_IPV6
+		if (cp->daf == AF_INET6)
+			cp->packet_xmit = ip_vs_tunnel_xmit_v6;
+		else
+#endif
+			cp->packet_xmit = ip_vs_tunnel_xmit;
 		break;
 
 	case IP_VS_CONN_F_DROUTE:
@@ -514,7 +519,10 @@ static inline void ip_vs_bind_xmit_v6(struct ip_vs_conn *cp)
 		break;
 
 	case IP_VS_CONN_F_TUNNEL:
-		cp->packet_xmit = ip_vs_tunnel_xmit_v6;
+		if (cp->daf == AF_INET6)
+			cp->packet_xmit = ip_vs_tunnel_xmit_v6;
+		else
+			cp->packet_xmit = ip_vs_tunnel_xmit;
 		break;
 
 	case IP_VS_CONN_F_DROUTE:
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index fa2fdd7..91f17c1 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -824,6 +824,81 @@ tx_error:
 }
 #endif
 
+/* When forwarding a packet, we must ensure that we've got enough headroom
+ * for the encapsulation packet in the skb.  This also gives us an
+ * opportunity to figure out what the payload_len, dsfield, ttl, and df
+ * values should be, so that we won't need to look at the old ip header
+ * again
+ */
+static struct sk_buff *
+ip_vs_prepare_tunneled_skb(struct sk_buff *skb, int skb_af,
+			   unsigned int max_headroom, __u8 *next_protocol,
+			   __u32 *payload_len, __u8 *dsfield, __u8 *ttl,
+			   __be16 *df)
+{
+	struct sk_buff *new_skb = NULL;
+	struct iphdr *old_iph = NULL;
+#ifdef CONFIG_IP_VS_IPV6
+	struct ipv6hdr *old_ipv6h = NULL;
+#endif
+
+	if (skb_headroom(skb) < max_headroom || skb_cloned(skb)) {
+		new_skb = skb_realloc_headroom(skb, max_headroom);
+		if (!new_skb)
+			goto error;
+		consume_skb(skb);
+		skb = new_skb;
+	}
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (skb_af == AF_INET6) {
+		old_ipv6h = ipv6_hdr(skb);
+		*next_protocol = IPPROTO_IPV6;
+		if (payload_len)
+			*payload_len =
+				ntohs(old_ipv6h->payload_len) +
+				sizeof(*old_ipv6h);
+		*dsfield = ipv6_get_dsfield(old_ipv6h);
+		*ttl = old_ipv6h->hop_limit;
+		if (df)
+			*df = 0;
+	} else
+#endif
+	{
+		old_iph = ip_hdr(skb);
+		/* Copy DF, reset fragment offset and MF */
+		if (df)
+			*df = (old_iph->frag_off & htons(IP_DF));
+		*next_protocol = IPPROTO_IPIP;
+
+		/* fix old IP header checksum */
+		ip_send_check(old_iph);
+		*dsfield = ipv4_get_dsfield(old_iph);
+		*ttl = old_iph->ttl;
+		if (payload_len)
+			*payload_len = ntohs(old_iph->tot_len);
+	}
+
+	return skb;
+error:
+	kfree_skb(skb);
+	return ERR_PTR(-ENOMEM);
+}
+
+static inline int __tun_gso_type_mask(int encaps_af, int orig_af)
+{
+	if (encaps_af == AF_INET) {
+		if (orig_af == AF_INET)
+			return SKB_GSO_IPIP;
+
+		return SKB_GSO_SIT;
+	}
+
+	/* GSO: we need to provide proper SKB_GSO_ value for IPv6:
+	 * SKB_GSO_SIT/IPV6
+	 */
+	return 0;
+}
 
 /*
  *   IP Tunneling transmitter
@@ -852,9 +927,11 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	struct rtable *rt;			/* Route to the other host */
 	__be32 saddr;				/* Source for tunnel */
 	struct net_device *tdev;		/* Device to other host */
-	struct iphdr  *old_iph = ip_hdr(skb);
-	u8     tos = old_iph->tos;
-	__be16 df;
+	__u8 next_protocol = 0;
+	__u8 dsfield = 0;
+	__u8 ttl = 0;
+	__be16 df = 0;
+	__be16 *dfp = NULL;
 	struct iphdr  *iph;			/* Our new IP header */
 	unsigned int max_headroom;		/* The extra header space needed */
 	int ret, local;
@@ -877,29 +954,21 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	rt = skb_rtable(skb);
 	tdev = rt->dst.dev;
 
-	/* Copy DF, reset fragment offset and MF */
-	df = sysctl_pmtu_disc(ipvs) ? old_iph->frag_off & htons(IP_DF) : 0;
-
 	/*
 	 * Okay, now see if we can stuff it in the buffer as-is.
 	 */
 	max_headroom = LL_RESERVED_SPACE(tdev) + sizeof(struct iphdr);
 
-	if (skb_headroom(skb) < max_headroom || skb_cloned(skb)) {
-		struct sk_buff *new_skb =
-			skb_realloc_headroom(skb, max_headroom);
-
-		if (!new_skb)
-			goto tx_error;
-		consume_skb(skb);
-		skb = new_skb;
-		old_iph = ip_hdr(skb);
-	}
-
-	/* fix old IP header checksum */
-	ip_send_check(old_iph);
+	/* We only care about the df field if sysctl_pmtu_disc(ipvs) is set */
+	dfp = sysctl_pmtu_disc(ipvs) ? &df : NULL;
+	skb = ip_vs_prepare_tunneled_skb(skb, cp->af, max_headroom,
+					 &next_protocol, NULL, &dsfield,
+					 &ttl, dfp);
+	if (IS_ERR(skb))
+		goto tx_error;
 
-	skb = iptunnel_handle_offloads(skb, false, SKB_GSO_IPIP);
+	skb = iptunnel_handle_offloads(
+		skb, false, __tun_gso_type_mask(AF_INET, cp->af));
 	if (IS_ERR(skb))
 		goto tx_error;
 
@@ -916,11 +985,11 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	iph->version		=	4;
 	iph->ihl		=	sizeof(struct iphdr)>>2;
 	iph->frag_off		=	df;
-	iph->protocol		=	IPPROTO_IPIP;
-	iph->tos		=	tos;
+	iph->protocol		=	next_protocol;
+	iph->tos		=	dsfield;
 	iph->daddr		=	cp->daddr.ip;
 	iph->saddr		=	saddr;
-	iph->ttl		=	old_iph->ttl;
+	iph->ttl		=	ttl;
 	ip_select_ident(skb, NULL);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
@@ -953,7 +1022,10 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	struct rt6_info *rt;		/* Route to the other host */
 	struct in6_addr saddr;		/* Source for tunnel */
 	struct net_device *tdev;	/* Device to other host */
-	struct ipv6hdr  *old_iph = ipv6_hdr(skb);
+	__u8 next_protocol = 0;
+	__u32 payload_len = 0;
+	__u8 dsfield = 0;
+	__u8 ttl = 0;
 	struct ipv6hdr  *iph;		/* Our new IP header */
 	unsigned int max_headroom;	/* The extra header space needed */
 	int ret, local;
@@ -981,19 +1053,14 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	 */
 	max_headroom = LL_RESERVED_SPACE(tdev) + sizeof(struct ipv6hdr);
 
-	if (skb_headroom(skb) < max_headroom || skb_cloned(skb)) {
-		struct sk_buff *new_skb =
-			skb_realloc_headroom(skb, max_headroom);
-
-		if (!new_skb)
-			goto tx_error;
-		consume_skb(skb);
-		skb = new_skb;
-		old_iph = ipv6_hdr(skb);
-	}
+	skb = ip_vs_prepare_tunneled_skb(skb, cp->af, max_headroom,
+					 &next_protocol, &payload_len,
+					 &dsfield, &ttl, NULL);
+	if (IS_ERR(skb))
+		goto tx_error;
 
-	/* GSO: we need to provide proper SKB_GSO_ value for IPv6 */
-	skb = iptunnel_handle_offloads(skb, false, 0); /* SKB_GSO_SIT/IPV6 */
+	skb = iptunnel_handle_offloads(
+		skb, false, __tun_gso_type_mask(AF_INET6, cp->af));
 	if (IS_ERR(skb))
 		goto tx_error;
 
@@ -1008,14 +1075,13 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	 */
 	iph			=	ipv6_hdr(skb);
 	iph->version		=	6;
-	iph->nexthdr		=	IPPROTO_IPV6;
-	iph->payload_len	=	old_iph->payload_len;
-	be16_add_cpu(&iph->payload_len, sizeof(*old_iph));
+	iph->nexthdr		=	next_protocol;
+	iph->payload_len	=	htons(payload_len);
 	memset(&iph->flow_lbl, 0, sizeof(iph->flow_lbl));
-	ipv6_change_dsfield(iph, 0, ipv6_get_dsfield(old_iph));
+	ipv6_change_dsfield(iph, 0, dsfield);
 	iph->daddr = cp->daddr.in6;
 	iph->saddr = saddr;
-	iph->hop_limit		=	old_iph->hop_limit;
+	iph->hop_limit		=	ttl;
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->ignore_df = 1;
-- 
1.8.1

