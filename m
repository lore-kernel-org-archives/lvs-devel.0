From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs 7/7] ipvs: support ipv4 in ipv6 and ipv6 in ipv4 tunnel forwarding
Date: Tue, 29 Jul 2014 21:10:55 -0700
Message-ID: <1406693455-915-8-git-send-email-agartrell@fb.com>
References: <1406693455-915-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=gPunhzAGV9HizxQwcrXIaJalvddZNVd4NDX2MeGJiZc=;
 b=m1AyJzFsYnQSlk1/djOPi/eDVwgB7asDtXoJPZPPUUgOWN6fD48NJWE5pjhLhCAcz5SF
 kTNE7J0kL6y9KnIFFtrXqHLDCQUcVqmJBFAYTXpacUaAxP3DBUfU055CFNIjxsFyWO7k
 n+HMe5NtN/b9ApYk4BM1+M2+/qTwldpUqE4= 
In-Reply-To: <1406693455-915-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, agartrell@fb.com, kernel-team@fb.com

Pull the common logic for preparing an skb to prepend the header into a
single function and then set fields such that they can be used in either
case (generalize tos and tclass to dscp, hop_limit and ttl to ttl, etc)

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_conn.c |  12 +++-
 net/netfilter/ipvs/ip_vs_xmit.c | 135 ++++++++++++++++++++++++++--------------
 2 files changed, 100 insertions(+), 47 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 22c72da..86ecb14 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -488,7 +488,12 @@ static inline void ip_vs_bind_xmit(struct ip_vs_conn *cp)
 		break;
 
 	case IP_VS_CONN_F_TUNNEL:
-		cp->packet_xmit = ip_vs_tunnel_xmit;
+#ifdef CONFIG_IP_VS_IPV6
+		if (cp->dest->af == AF_INET6)
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
+		if (cp->dest->af == AF_INET6)
+			cp->packet_xmit = ip_vs_tunnel_xmit_v6;
+		else
+			cp->packet_xmit = ip_vs_tunnel_xmit;
 		break;
 
 	case IP_VS_CONN_F_DROUTE:
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 9c68089..2c5097f 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -790,6 +790,66 @@ tx_error:
 }
 #endif
 
+/* When forwarding a packet, we must ensure that we've got enough headroom
+ * for the encapsulation packet in the skb.  This also gives us an
+ * opportunity to figure out what the payload_len, dsfield, ttl, and df
+ * values should be, so that we won't need to look at the old ip header
+ * again */
+static struct sk_buff *
+ip_vs_prepare_tunneled_skb(struct sk_buff *skb, unsigned int max_headroom,
+			   __u8 *next_protocol, __u32 *payload_len, __u8 *dsfield,
+			   __u8 *ttl, __be16 *df)
+{
+	struct sk_buff *out_skb = NULL;
+	__u8 version = ip_hdr(skb)->version;
+	struct iphdr *old_iph = NULL;
+#ifdef CONFIG_IP_VS_IPV6
+	struct ipv6hdr *old_ipv6h = NULL;
+#endif
+
+	if (skb_headroom(skb) < max_headroom || skb_cloned(skb)) {
+		out_skb = skb_realloc_headroom(skb, max_headroom);
+		if (!out_skb)
+			return NULL;
+		consume_skb(skb);
+	} else
+		out_skb = skb;
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (version == 6) {
+		old_ipv6h = ipv6_hdr(skb);
+		*next_protocol = IPPROTO_IPV6;
+		if (payload_len)
+			*payload_len =
+				ntohs(old_ipv6h->payload_len) + sizeof(*old_ipv6h);
+		*dsfield = ipv6_get_dsfield(old_ipv6h);
+		*ttl = old_ipv6h->hop_limit;
+		if (df)
+			*df = 0;
+	} else
+#endif
+	{
+		old_iph = ip_hdr(out_skb);
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
+	/* We are about to encapsulate the ip header, which breaks hardware
+	 * checksum offload.  Let's call skb_checksum_help to finish up any
+	 * partial checksums */
+	skb_checksum_help(skb);
+
+	return out_skb;
+}
 
 /*
  *   IP Tunneling transmitter
@@ -818,11 +878,14 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
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
+	struct sk_buff *out_skb = NULL;
 	int ret, local;
 
 	EnterFunction(10);
@@ -843,29 +906,18 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
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
-	/* We are about to encapsulate the ip header, which breaks hardware
-	 * checksum offload.  Let's call skb_checksum_help to finish up any
-	 * partial checksums */
-	skb_checksum_help(skb);
+	/* We only care about the df field is sysctl_pmtu_disc(ipvs) is set */
+	dfp = sysctl_pmtu_disc(ipvs) ? &df : NULL;
+	out_skb = ip_vs_prepare_tunneled_skb(skb, max_headroom, &next_protocol,
+					     NULL, &dsfield, &ttl, dfp);
+	if (!out_skb)
+		goto tx_error;
+	skb = out_skb;
 
 	skb->transport_header = skb->network_header;
 
@@ -880,11 +932,11 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
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
@@ -916,9 +968,13 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
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
+	struct sk_buff *out_skb = NULL;
 	int ret, local;
 
 	EnterFunction(10);
@@ -944,21 +1000,11 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
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
-
-	/* We are about to encapsulate the ip header, which breaks hardware
-	 * checksum offload.  Let's call skb_checksum_help to finish up any
-	 * partial checksums */
-	skb_checksum_help(skb);
+	out_skb = ip_vs_prepare_tunneled_skb(skb, max_headroom, &next_protocol,
+					     &payload_len, &dsfield, &ttl, NULL);
+	if (!out_skb)
+		goto tx_error;
+	skb = out_skb;
 
 	skb->transport_header = skb->network_header;
 
@@ -971,14 +1017,13 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	 */
 	iph			=	ipv6_hdr(skb);
 	iph->version		=	6;
-	iph->nexthdr		=	IPPROTO_IPV6;
-	iph->payload_len	=	old_iph->payload_len;
-	be16_add_cpu(&iph->payload_len, sizeof(*old_iph));
+	iph->nexthdr		=	next_protocol;
+	iph->payload_len	=	ntohs(payload_len);
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

