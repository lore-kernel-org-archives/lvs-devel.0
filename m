From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 01/15] ipvs: replace ip_vs_fill_ip4hdr with ip_vs_fill_iph_skb_off
Date: Thu, 17 Sep 2015 14:40:37 +0900
Message-ID: <1442468451-24012-2-git-send-email-horms@verge.net.au>
References: <1442468451-24012-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1442468451-24012-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Alex Gartrell <agartrell@fb.com>, Simon Horman <horms@verge.net.au>

From: Alex Gartrell <agartrell@fb.com>

This removes some duplicated code and makes the ICMPv6 path look more like
the ICMP path.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             | 49 +++++++++++++++++------------
 net/netfilter/ipvs/ip_vs_core.c | 70 +++++++++++++++--------------------------
 net/netfilter/ipvs/ip_vs_xmit.c | 15 ++++-----
 3 files changed, 63 insertions(+), 71 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 9b9ca87a4210..0c8309f34982 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -104,6 +104,7 @@ static inline struct net *seq_file_single_net(struct seq_file *seq)
 extern int ip_vs_conn_tab_size;
 
 struct ip_vs_iphdr {
+	__u32 off;	/* Where IP or IPv4 header starts */
 	__u32 len;	/* IPv4 simply where L4 starts
 			 * IPv6 where L4 Transport Header starts */
 	__u16 fragoffs; /* IPv6 fragment offset, 0 if first frag (or not frag)*/
@@ -120,48 +121,56 @@ static inline void *frag_safe_skb_hp(const struct sk_buff *skb, int offset,
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
+	iphdr->off = offset;
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
index 38fbc194b9cb..b831fe84bff7 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -436,7 +436,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	 * with persistence the connection is created on SYN+ACK.
 	 */
 	if (pptr[0] == FTPDATA) {
-		IP_VS_DBG_PKT(12, svc->af, pp, skb, 0,
+		IP_VS_DBG_PKT(12, svc->af, pp, skb, iph->off,
 			      "Not scheduling FTPDATA");
 		return NULL;
 	}
@@ -446,7 +446,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	 */
 	if ((!skb->dev || skb->dev->flags & IFF_LOOPBACK) &&
 	    (cp = pp->conn_in_get(svc->af, skb, iph, 1))) {
-		IP_VS_DBG_PKT(12, svc->af, pp, skb, 0,
+		IP_VS_DBG_PKT(12, svc->af, pp, skb, iph->off,
 			      "Not scheduling reply for existing connection");
 		__ip_vs_conn_put(cp);
 		return NULL;
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
@@ -951,12 +951,11 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 			     unsigned int hooknum, struct ip_vs_iphdr *ipvsh)
 {
 	struct icmp6hdr	_icmph, *ic;
-	struct ipv6hdr _ip6h, *ip6h; /* The ip header contained within ICMP */
 	struct ip_vs_iphdr ciph = {.flags = 0, .fragoffs = 0};/*Contained IP */
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
 	union nf_inet_addr snet;
-	unsigned int writable;
+	unsigned int offset;
 
 	*related = 1;
 	ic = frag_safe_skb_hp(skb, ipvsh->len, sizeof(_icmph), &_icmph, ipvsh);
@@ -984,17 +983,9 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
 		  &ipvsh->saddr, &ipvsh->daddr);
 
-	/* Now find the contained IP header */
-	ciph.len = ipvsh->len + sizeof(_icmph);
-	ip6h = skb_header_pointer(skb, ciph.len, sizeof(_ip6h), &_ip6h);
-	if (ip6h == NULL)
+	if (!ip_vs_fill_iph_skb_off(AF_INET6, skb, ipvsh->len + sizeof(_icmph),
+				    &ciph))
 		return NF_ACCEPT; /* The packet looks wrong, ignore */
-	ciph.saddr.in6 = ip6h->saddr; /* conn_out_get() handles reverse order */
-	ciph.daddr.in6 = ip6h->daddr;
-	/* skip possible IPv6 exthdrs of contained IPv6 packet */
-	ciph.protocol = ipv6_find_hdr(skb, &ciph.len, -1, &ciph.fragoffs, NULL);
-	if (ciph.protocol < 0)
-		return NF_ACCEPT; /* Contained IPv6 hdr looks wrong, ignore */
 
 	pp = ip_vs_proto_get(ciph.protocol);
 	if (!pp)
@@ -1006,9 +997,9 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 		return NF_ACCEPT;
 
 	snet.in6 = ciph.saddr.in6;
-	writable = ciph.len;
+	offset = ciph.len;
 	return handle_response_icmp(AF_INET6, skb, &snet, ciph.protocol, cp,
-				    pp, writable, sizeof(struct ipv6hdr),
+				    pp, offset, sizeof(struct ipv6hdr),
 				    hooknum);
 }
 #endif
@@ -1093,7 +1084,7 @@ handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 {
 	struct ip_vs_protocol *pp = pd->pp;
 
-	IP_VS_DBG_PKT(11, af, pp, skb, 0, "Outgoing packet");
+	IP_VS_DBG_PKT(11, af, pp, skb, iph->off, "Outgoing packet");
 
 	if (!skb_make_writable(skb, iph->len))
 		goto drop;
@@ -1130,7 +1121,7 @@ handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	if (ip_vs_route_me_harder(af, skb, hooknum))
 		goto drop;
 
-	IP_VS_DBG_PKT(10, af, pp, skb, 0, "After SNAT");
+	IP_VS_DBG_PKT(10, af, pp, skb, iph->off, "After SNAT");
 
 	ip_vs_out_stats(cp, skb);
 	ip_vs_set_state(cp, IP_VS_DIR_OUTPUT, skb, pd);
@@ -1221,7 +1212,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 					       ip_vs_defrag_user(hooknum)))
 				return NF_STOLEN;
 
-			ip_vs_fill_ip4hdr(skb_network_header(skb), &iph);
+			ip_vs_fill_iph_skb(AF_INET, skb, &iph);
 		}
 
 	/*
@@ -1272,7 +1263,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 			}
 		}
 	}
-	IP_VS_DBG_PKT(12, af, pp, skb, 0,
+	IP_VS_DBG_PKT(12, af, pp, skb, iph.off,
 		      "ip_vs_out: packet continues traversal as normal");
 	return NF_ACCEPT;
 }
@@ -1416,9 +1407,9 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 		      "Checking incoming ICMP for");
 
 	offset2 = offset;
-	ip_vs_fill_ip4hdr(cih, &ciph);
-	ciph.len += offset;
+	ip_vs_fill_iph_skb_off(AF_INET, skb, offset, &ciph);
 	offset = ciph.len;
+
 	/* The embedded headers contain source and dest in reverse order.
 	 * For IPIP this is error for request, not for reply.
 	 */
@@ -1511,13 +1502,12 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 			    unsigned int hooknum, struct ip_vs_iphdr *iph)
 {
 	struct net *net = NULL;
-	struct ipv6hdr _ip6h, *ip6h;
 	struct icmp6hdr	_icmph, *ic;
 	struct ip_vs_iphdr ciph = {.flags = 0, .fragoffs = 0};/*Contained IP */
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
-	unsigned int offs_ciph, writable, verdict;
+	unsigned int offset, verdict;
 
 	*related = 1;
 
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
+	offset = iph->len + sizeof(_icmph);
+	if (!ip_vs_fill_iph_skb_off(AF_INET6, skb, offset, &ciph))
+		return NF_ACCEPT;
 
 	net = skb_net(skb);
 	pd = ip_vs_proto_data_get(net, ciph.protocol);
@@ -1569,7 +1550,7 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 	if (ciph.fragoffs)
 		return NF_ACCEPT;
 
-	IP_VS_DBG_PKT(11, AF_INET6, pp, skb, offs_ciph,
+	IP_VS_DBG_PKT(11, AF_INET6, pp, skb, offset,
 		      "Checking incoming ICMPv6 for");
 
 	/* The embedded headers contain source and dest in reverse order
@@ -1591,12 +1572,12 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 	ip_vs_in_stats(cp, skb);
 
 	/* Need to mangle contained IPv6 header in ICMPv6 packet */
-	writable = ciph.len;
+	offset = ciph.len;
 	if (IPPROTO_TCP == ciph.protocol || IPPROTO_UDP == ciph.protocol ||
 	    IPPROTO_SCTP == ciph.protocol)
-		writable += 2 * sizeof(__u16); /* Also mangle ports */
+		offset += 2 * sizeof(__u16); /* Also mangle ports */
 
-	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, writable, hooknum, &ciph);
+	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, offset, hooknum, &ciph);
 
 	__ip_vs_conn_put(cp);
 
@@ -1720,12 +1701,13 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 			 * is missing module nf_defrag_ipv6
 			 */
 			IP_VS_DBG_RL("Unhandled frag, load nf_defrag_ipv6\n");
-			IP_VS_DBG_PKT(7, af, pp, skb, 0, "unhandled fragment");
+			IP_VS_DBG_PKT(7, af, pp, skb, iph.off,
+				      "unhandled fragment");
 		}
 		return NF_ACCEPT;
 	}
 
-	IP_VS_DBG_PKT(11, af, pp, skb, 0, "Incoming packet");
+	IP_VS_DBG_PKT(11, af, pp, skb, iph.off, "Incoming packet");
 	/* Check the server status */
 	if (cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
 		/* the destination server is not available */
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 258a0b0e82a2..9a26f2ea86d9 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -723,7 +723,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
 		if (ct && !nf_ct_is_untracked(ct)) {
-			IP_VS_DBG_RL_PKT(10, AF_INET, pp, skb, 0,
+			IP_VS_DBG_RL_PKT(10, AF_INET, pp, skb, ipvsh->off,
 					 "ip_vs_nat_xmit(): "
 					 "stopping DNAT to local address");
 			goto tx_error;
@@ -733,8 +733,9 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* From world but DNAT to loopback address? */
 	if (local && ipv4_is_loopback(cp->daddr.ip) && was_input) {
-		IP_VS_DBG_RL_PKT(1, AF_INET, pp, skb, 0, "ip_vs_nat_xmit(): "
-				 "stopping DNAT to loopback address");
+		IP_VS_DBG_RL_PKT(1, AF_INET, pp, skb, ipvsh->off,
+				 "ip_vs_nat_xmit(): stopping DNAT to loopback "
+				 "address");
 		goto tx_error;
 	}
 
@@ -751,7 +752,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	ip_hdr(skb)->daddr = cp->daddr.ip;
 	ip_send_check(ip_hdr(skb));
 
-	IP_VS_DBG_PKT(10, AF_INET, pp, skb, 0, "After DNAT");
+	IP_VS_DBG_PKT(10, AF_INET, pp, skb, ipvsh->off, "After DNAT");
 
 	/* FIXME: when application helper enlarges the packet and the length
 	   is larger than the MTU of outgoing device, there will be still
@@ -812,7 +813,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
 		if (ct && !nf_ct_is_untracked(ct)) {
-			IP_VS_DBG_RL_PKT(10, AF_INET6, pp, skb, 0,
+			IP_VS_DBG_RL_PKT(10, AF_INET6, pp, skb, ipvsh->off,
 					 "ip_vs_nat_xmit_v6(): "
 					 "stopping DNAT to local address");
 			goto tx_error;
@@ -823,7 +824,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* From world but DNAT to loopback address? */
 	if (local && skb->dev && !(skb->dev->flags & IFF_LOOPBACK) &&
 	    ipv6_addr_type(&cp->daddr.in6) & IPV6_ADDR_LOOPBACK) {
-		IP_VS_DBG_RL_PKT(1, AF_INET6, pp, skb, 0,
+		IP_VS_DBG_RL_PKT(1, AF_INET6, pp, skb, ipvsh->off,
 				 "ip_vs_nat_xmit_v6(): "
 				 "stopping DNAT to loopback address");
 		goto tx_error;
@@ -841,7 +842,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error;
 	ipv6_hdr(skb)->daddr = cp->daddr.in6;
 
-	IP_VS_DBG_PKT(10, AF_INET6, pp, skb, 0, "After DNAT");
+	IP_VS_DBG_PKT(10, AF_INET6, pp, skb, ipvsh->off, "After DNAT");
 
 	/* FIXME: when application helper enlarges the packet and the length
 	   is larger than the MTU of outgoing device, there will be still
-- 
2.1.4

