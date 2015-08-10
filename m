From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next] ipvs: replace ip_vs_fill_ip4hdr with ip_vs_fill_iph_skb_off
Date: Mon, 10 Aug 2015 13:46:04 -0700
Message-ID: <1439239564-1677815-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : mime-version : content-type; s=facebook;
 bh=yhoaKkP/HfGrE2UnBeeNvPjDd74uYmweMgDMY/hzL38=;
 b=cPnc8KRan2ZNEDp8D2qGgb9s8sqCxPshvI//Jnc8yHCI+uA/roTGN1+ZOtIO+vocrmc5
 Vcz5wemQuusoxJJw8EgIWqZjiRxgYkbQ86auLRWrrA/NDLQsNwraC5isqnFVY+nWAxyB
 gVypCOYOLepYDnoUw2pMmFHRnAQDwRVGRYA= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ja@ssi.bg, horms@verge.net.au
Cc: lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

This removes some duplicated code and makes the ICMPv6 path look more like
the ICMP path.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 include/net/ip_vs.h             | 47 +++++++++++++++++++++++------------------
 net/netfilter/ipvs/ip_vs_core.c | 41 ++++++++++-------------------------
 2 files changed, 38 insertions(+), 50 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 4e3731e..3e09725 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -120,48 +120,55 @@ static inline void *frag_safe_skb_hp(const struct sk_buff *skb, int offset,
 	return skb_header_pointer(skb, offset, len, buffer);
 }
 
-static inline void
-ip_vs_fill_ip4hdr(const void *nh, struct ip_vs_iphdr *iphdr)
-{
-	const struct iphdr *iph = nh;
-
-	iphdr->len	= iph->ihl * 4;
-	iphdr->fragoffs	= 0;
-	iphdr->protocol	= iph->protocol;
-	iphdr->saddr.ip	= iph->saddr;
-	iphdr->daddr.ip	= iph->daddr;
-}
-
 /* This function handles filling *ip_vs_iphdr, both for IPv4 and IPv6.
  * IPv6 requires some extra work, as finding proper header position,
  * depend on the IPv6 extension headers.
  */
-static inline void
-ip_vs_fill_iph_skb(int af, const struct sk_buff *skb, struct ip_vs_iphdr *iphdr)
+static inline int
+ip_vs_fill_iph_skb_off(int af, const struct sk_buff *skb, int offset,
+		       struct ip_vs_iphdr *iphdr)
 {
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
-		const struct ipv6hdr *iph =
-			(struct ipv6hdr *)skb_network_header(skb);
+		struct ipv6hdr _iph;
+		const struct ipv6hdr *iph = skb_header_pointer(
+			skb, offset, sizeof(_iph), &_iph);
+		if (!iph)
+			return 0;
+
 		iphdr->saddr.in6 = iph->saddr;
 		iphdr->daddr.in6 = iph->daddr;
 		/* ipv6_find_hdr() updates len, flags */
-		iphdr->len	 = 0;
+		iphdr->len	 = offset;
 		iphdr->flags	 = 0;
 		iphdr->protocol  = ipv6_find_hdr(skb, &iphdr->len, -1,
 						 &iphdr->fragoffs,
 						 &iphdr->flags);
+		if (iphdr->protocol < 0)
+			return 0;
 	} else
 #endif
 	{
-		const struct iphdr *iph =
-			(struct iphdr *)skb_network_header(skb);
-		iphdr->len	= iph->ihl * 4;
+		struct iphdr _iph;
+		const struct iphdr *iph = skb_header_pointer(
+			skb, offset, sizeof(_iph), &_iph);
+		if (!iph)
+			return 0;
+
+		iphdr->len	= offset + iph->ihl * 4;
 		iphdr->fragoffs	= 0;
 		iphdr->protocol	= iph->protocol;
 		iphdr->saddr.ip	= iph->saddr;
 		iphdr->daddr.ip	= iph->daddr;
 	}
+
+	return 1;
+}
+
+static inline int
+ip_vs_fill_iph_skb(int af, const struct sk_buff *skb, struct ip_vs_iphdr *iphdr)
+{
+	return ip_vs_fill_iph_skb_off(af, skb, skb_network_offset(skb), iphdr);
 }
 
 static inline void ip_vs_addr_copy(int af, union nf_inet_addr *dst,
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 38fbc19..a5ced3c 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -934,8 +934,8 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
 	IP_VS_DBG_PKT(11, AF_INET, pp, skb, offset,
 		      "Checking outgoing ICMP for");
 
-	ip_vs_fill_ip4hdr(cih, &ciph);
-	ciph.len += offset;
+	ip_vs_fill_iph_skb_off(AF_INET, skb, offset, &ciph);
+
 	/* The embedded headers contain source and dest in reverse order */
 	cp = pp->conn_out_get(AF_INET, skb, &ciph, 1);
 	if (!cp)
@@ -951,7 +951,6 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 			     unsigned int hooknum, struct ip_vs_iphdr *ipvsh)
 {
 	struct icmp6hdr	_icmph, *ic;
-	struct ipv6hdr _ip6h, *ip6h; /* The ip header contained within ICMP */
 	struct ip_vs_iphdr ciph = {.flags = 0, .fragoffs = 0};/*Contained IP */
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
@@ -984,17 +983,9 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
 		  &ipvsh->saddr, &ipvsh->daddr);
 
-	/* Now find the contained IP header */
-	ciph.len = ipvsh->len + sizeof(_icmph);
-	ip6h = skb_header_pointer(skb, ciph.len, sizeof(_ip6h), &_ip6h);
-	if (ip6h == NULL)
+	if (!ip_vs_fill_iph_skb_off(
+		    AF_INET6, skb, ipvsh->len + sizeof(_icmph), &ciph))
 		return NF_ACCEPT; /* The packet looks wrong, ignore */
-	ciph.saddr.in6 = ip6h->saddr; /* conn_out_get() handles reverse order */
-	ciph.daddr.in6 = ip6h->daddr;
-	/* skip possible IPv6 exthdrs of contained IPv6 packet */
-	ciph.protocol = ipv6_find_hdr(skb, &ciph.len, -1, &ciph.fragoffs, NULL);
-	if (ciph.protocol < 0)
-		return NF_ACCEPT; /* Contained IPv6 hdr looks wrong, ignore */
 
 	pp = ip_vs_proto_get(ciph.protocol);
 	if (!pp)
@@ -1221,7 +1212,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 					       ip_vs_defrag_user(hooknum)))
 				return NF_STOLEN;
 
-			ip_vs_fill_ip4hdr(skb_network_header(skb), &iph);
+			ip_vs_fill_iph_skb(AF_INET, skb, &iph);
 		}
 
 	/*
@@ -1407,6 +1398,8 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 		return NF_ACCEPT;
 	pp = pd->pp;
 
+	ip_vs_fill_iph_skb_off(AF_INET, skb, offset, &ciph);
+
 	/* Is the embedded protocol header present? */
 	if (unlikely(cih->frag_off & htons(IP_OFFSET) &&
 		     pp->dont_defrag))
@@ -1416,9 +1409,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 		      "Checking incoming ICMP for");
 
 	offset2 = offset;
-	ip_vs_fill_ip4hdr(cih, &ciph);
-	ciph.len += offset;
-	offset = ciph.len;
+
 	/* The embedded headers contain source and dest in reverse order.
 	 * For IPIP this is error for request, not for reply.
 	 */
@@ -1511,7 +1502,6 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 			    unsigned int hooknum, struct ip_vs_iphdr *iph)
 {
 	struct net *net = NULL;
-	struct ipv6hdr _ip6h, *ip6h;
 	struct icmp6hdr	_icmph, *ic;
 	struct ip_vs_iphdr ciph = {.flags = 0, .fragoffs = 0};/*Contained IP */
 	struct ip_vs_conn *cp;
@@ -1546,18 +1536,9 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
 		  &iph->saddr, &iph->daddr);
 
-	/* Now find the contained IP header */
-	ciph.len = iph->len + sizeof(_icmph);
-	offs_ciph = ciph.len; /* Save ip header offset */
-	ip6h = skb_header_pointer(skb, ciph.len, sizeof(_ip6h), &_ip6h);
-	if (ip6h == NULL)
-		return NF_ACCEPT; /* The packet looks wrong, ignore */
-	ciph.saddr.in6 = ip6h->saddr; /* conn_in_get() handles reverse order */
-	ciph.daddr.in6 = ip6h->daddr;
-	/* skip possible IPv6 exthdrs of contained IPv6 packet */
-	ciph.protocol = ipv6_find_hdr(skb, &ciph.len, -1, &ciph.fragoffs, NULL);
-	if (ciph.protocol < 0)
-		return NF_ACCEPT; /* Contained IPv6 hdr looks wrong, ignore */
+	offs_ciph = iph->len + sizeof(_icmph);
+	if (!ip_vs_fill_iph_skb_off(AF_INET6, skb, offs_ciph, &ciph))
+		return NF_ACCEPT;
 
 	net = skb_net(skb);
 	pd = ip_vs_proto_data_get(net, ciph.protocol);
-- 
Alex Gartrell <agartrell@fb.com>

