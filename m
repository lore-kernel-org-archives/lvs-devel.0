From: Julius Volz <juliusv@google.com>
Subject: [PATCH RFC 09/24] IPVS: Add IPv6 Netfilter hooks and add/modify support functions
Date: Wed, 20 Aug 2008 18:15:16 +0200
Message-ID: <1219248931-15064-10-git-send-email-juliusv@google.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219248944; bh=YrmENfYjG74XJhNHLVQMkqt96zU=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=jOLdUWuJPjcEhC+idiKhQVmfpCbfH/La7g2wdXGy
	WeecBnkN9RSUqGgro+3GFzYJOVyuIeSbBnoT780EfeiR5w==
In-Reply-To: <1219248931-15064-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Add Netfilter hook entries for IPv6 and either extend the existing hook
functions to handle both v4 and v6, or where it seems easier, add new ones
for v6. Also adapt/add some helper functions for v6.

Signed-off-by: Julius Volz <juliusv@google.com>

 2 files changed, 437 insertions(+), 61 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 9ba9ee7..352807b 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -901,7 +901,12 @@ static inline char ip_vs_fwd_tag(struct ip_vs_conn *cp)
 }
 
 extern void ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
-		struct ip_vs_conn *cp, int dir);
+			   struct ip_vs_conn *cp, int dir);
+
+#ifdef CONFIG_IP_VS_IPV6
+extern void ip_vs_nat_icmp_v6(struct sk_buff *skb, struct ip_vs_protocol *pp,
+			      struct ip_vs_conn *cp, int dir);
+#endif
 
 extern __sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset);
 
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 63c08c4..99e8938 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -39,6 +39,11 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
 
+#ifdef CONFIG_IP_VS_IPV6
+#include <net/ipv6.h>
+#include <linux/netfilter_ipv6.h>
+#endif
+
 #include <net/ip_vs.h>
 
 
@@ -60,6 +65,7 @@ EXPORT_SYMBOL(ip_vs_get_debug_level);
 
 /* ID used in ICMP lookups */
 #define icmp_id(icmph)          (((icmph)->un).echo.id)
+#define icmpv6_id(icmph)        (icmph->icmp6_dataun.u_echo.identifier)
 
 const char *ip_vs_proto_name(unsigned proto)
 {
@@ -74,6 +80,10 @@ const char *ip_vs_proto_name(unsigned proto)
 		return "TCP";
 	case IPPROTO_ICMP:
 		return "ICMP";
+#ifdef CONFIG_IP_VS_IPV6
+	case IPPROTO_ICMPV6:
+		return "ICMPv6";
+#endif
 	default:
 		sprintf(buf, "IP_%d", proto);
 		return buf;
@@ -408,20 +418,27 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		struct ip_vs_protocol *pp)
 {
 	__be16 _ports[2], *pptr;
-	struct iphdr *iph = ip_hdr(skb);
+	struct ip_vs_iphdr iph;
+	int unicast;
+	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 
-	pptr = skb_header_pointer(skb, iph->ihl*4,
-				  sizeof(_ports), _ports);
+	pptr = skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
 	if (pptr == NULL) {
 		ip_vs_service_put(svc);
 		return NF_DROP;
 	}
 
+#ifdef CONFIG_IP_VS_IPV6
+	if (svc->af == AF_INET6)
+		unicast = ipv6_addr_type(&iph.daddr.in6) & IPV6_ADDR_UNICAST;
+	else
+#endif
+		unicast = (inet_addr_type(&init_net, iph.daddr.ip) == RTN_UNICAST);
+
 	/* if it is fwmark-based service, the cache_bypass sysctl is up
-	   and the destination is RTN_UNICAST (and not local), then create
+	   and the destination is a non-local unicast, then create
 	   a cache_bypass connection entry */
-	if (sysctl_ip_vs_cache_bypass && svc->fwmark
-	    && (inet_addr_type(&init_net, iph->daddr) == RTN_UNICAST)) {
+	if (sysctl_ip_vs_cache_bypass && svc->fwmark && unicast) {
 		int ret, cs;
 		struct ip_vs_conn *cp;
 
@@ -429,9 +446,9 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 
 		/* create a new connection entry */
 		IP_VS_DBG(6, "ip_vs_leave: create a cache_bypass entry\n");
-		cp = ip_vs_conn_new(iph->protocol,
-				    iph->saddr, pptr[0],
-				    iph->daddr, pptr[1],
+		cp = ip_vs_conn_new(svc->af, iph.protocol,
+				    &iph.saddr, pptr[0],
+				    &iph.daddr, pptr[1],
 				    0, 0,
 				    IP_VS_CONN_F_BYPASS,
 				    NULL);
@@ -473,7 +490,14 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 	 * created, the TCP RST packet cannot be sent, instead that
 	 * ICMP_PORT_UNREACH is sent here no matter it is TCP/UDP. --WZ
 	 */
-	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
+#ifdef CONFIG_IP_VS_IPV6
+	if (svc->af == AF_INET6)
+		icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0,
+			    skb->dev);
+	else
+#endif
+		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
+
 	return NF_DROP;
 }
 
@@ -512,6 +536,14 @@ static inline int ip_vs_gather_frags(struct sk_buff *skb, u_int32_t user)
 	return err;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static inline int ip_vs_gather_frags_v6(struct sk_buff *skb, u_int32_t user)
+{
+	/* TODO IPv6: Find out what to do here for IPv6 */
+	return 0;
+}
+#endif
+
 /*
  * Packet has been made sufficiently writable in caller
  * - inout: 1=in->out, 0=out->in
@@ -526,14 +558,14 @@ void ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
 	struct iphdr *ciph	 = (struct iphdr *)(icmph + 1);
 
 	if (inout) {
-		iph->saddr = cp->vaddr;
+		iph->saddr = cp->vaddr.ip;
 		ip_send_check(iph);
-		ciph->daddr = cp->vaddr;
+		ciph->daddr = cp->vaddr.ip;
 		ip_send_check(ciph);
 	} else {
-		iph->daddr = cp->daddr;
+		iph->daddr = cp->daddr.ip;
 		ip_send_check(iph);
-		ciph->saddr = cp->daddr;
+		ciph->saddr = cp->daddr.ip;
 		ip_send_check(ciph);
 	}
 
@@ -560,6 +592,49 @@ void ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
 			"Forwarding altered incoming ICMP");
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+void ip_vs_nat_icmp_v6(struct sk_buff *skb, struct ip_vs_protocol *pp,
+		    struct ip_vs_conn *cp, int inout)
+{
+	struct ipv6hdr *iph	 = ipv6_hdr(skb);
+	unsigned int icmp_offset = sizeof(struct ipv6hdr);
+	struct icmp6hdr *icmph	 = (struct icmp6hdr *)(skb_network_header(skb) +
+						      icmp_offset);
+	struct ipv6hdr *ciph	 = (struct ipv6hdr *)(icmph + 1);
+
+	if (inout) {
+		iph->saddr = cp->vaddr.in6;
+		ciph->daddr = cp->vaddr.in6;
+	} else {
+		iph->daddr = cp->daddr.in6;
+		ciph->saddr = cp->daddr.in6;
+	}
+
+	/* the TCP/UDP port */
+	if (IPPROTO_TCP == ciph->nexthdr || IPPROTO_UDP == ciph->nexthdr) {
+		__be16 *ports = (void *)ciph + sizeof(struct ipv6hdr);
+
+		if (inout)
+			ports[1] = cp->vport;
+		else
+			ports[0] = cp->dport;
+	}
+
+	/* And finally the ICMP checksum */
+	icmph->icmp6_cksum = 0;
+	/* TODO IPv6: is this correct for ICMPv6? */
+	ip_vs_checksum_complete(skb, icmp_offset);
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+	if (inout)
+		IP_VS_DBG_PKT(11, pp, skb, (void *)ciph - (void *)iph,
+			"Forwarding altered outgoing ICMPv6");
+	else
+		IP_VS_DBG_PKT(11, pp, skb, (void *)ciph - (void *)iph,
+			"Forwarding altered incoming ICMPv6");
+}
+#endif
+
 /*
  *	Handle ICMP messages in the inside-to-outside direction (outgoing).
  *	Find any that might be relevant, check against existing connections,
@@ -572,6 +647,7 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related)
 	struct iphdr *iph;
 	struct icmphdr	_icmph, *ic;
 	struct iphdr	_ciph, *cih;	/* The ip header contained within the ICMP */
+	struct ip_vs_iphdr ciph;
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
 	unsigned int offset, ihl, verdict;
@@ -627,8 +703,9 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related)
 
 	offset += cih->ihl * 4;
 
+	ip_vs_fill_iphdr(AF_INET6, cih, &ciph);
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_out_get(skb, pp, cih, offset, 1);
+	cp = pp->conn_out_get(AF_INET, skb, pp, &ciph, offset, 1);
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -666,11 +743,116 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related)
 	return verdict;
 }
 
-static inline int is_tcp_reset(const struct sk_buff *skb)
+#ifdef CONFIG_IP_VS_IPV6
+static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related)
+{
+	struct ipv6hdr *iph;
+	struct icmp6hdr	_icmph, *ic;
+	struct ipv6hdr	_ciph, *cih;	/* The ip header contained within the ICMP */
+	struct ip_vs_iphdr ciph;
+	struct ip_vs_conn *cp;
+	struct ip_vs_protocol *pp;
+	unsigned int offset, verdict;
+
+	*related = 1;
+
+	/* reassemble IP fragments */
+	if (ipv6_hdr(skb)->nexthdr == IPPROTO_FRAGMENT) {
+		if (ip_vs_gather_frags_v6(skb, IP_DEFRAG_VS_OUT))
+			return NF_STOLEN;
+	}
+
+	iph = ipv6_hdr(skb);
+	offset = sizeof(struct ipv6hdr);
+	ic = skb_header_pointer(skb, offset, sizeof(_icmph), &_icmph);
+	if (ic == NULL)
+		return NF_DROP;
+
+	IP_VS_DBG(12, "Outgoing ICMPv6 (%d,%d) " NIP6_FMT "->" NIP6_FMT "\n",
+		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
+		  NIP6(iph->saddr), NIP6(iph->daddr));
+
+	/*
+	 * Work through seeing if this is for us.
+	 * These checks are supposed to be in an order that means easy
+	 * things are checked first to speed up processing.... however
+	 * this means that some packets will manage to get a long way
+	 * down this stack and then be rejected, but that's life.
+	 */
+	if ((ic->icmp6_type != ICMPV6_DEST_UNREACH) &&
+	    (ic->icmp6_type != ICMPV6_PKT_TOOBIG) &&
+	    (ic->icmp6_type != ICMPV6_TIME_EXCEED)) {
+		*related = 0;
+		return NF_ACCEPT;
+	}
+
+	/* Now find the contained IP header */
+	offset += sizeof(_icmph);
+	cih = skb_header_pointer(skb, offset, sizeof(_ciph), &_ciph);
+	if (cih == NULL)
+		return NF_ACCEPT; /* The packet looks wrong, ignore */
+
+	pp = ip_vs_proto_get(cih->nexthdr);
+	if (!pp)
+		return NF_ACCEPT;
+
+	/* Is the embedded protocol header present? */
+	/* TODO: we don't support fragmentation at the moment anyways */
+	if (unlikely(cih->nexthdr == IPPROTO_FRAGMENT && pp->dont_defrag))
+		return NF_ACCEPT;
+
+	IP_VS_DBG_PKT(11, pp, skb, offset, "Checking outgoing ICMPv6 for");
+
+	offset += sizeof(struct ipv6hdr);
+
+	ip_vs_fill_iphdr(AF_INET6, cih, &ciph);
+	/* The embedded headers contain source and dest in reverse order */
+	cp = pp->conn_out_get(AF_INET6, skb, pp, &ciph, offset, 1);
+	if (!cp)
+		return NF_ACCEPT;
+
+	verdict = NF_DROP;
+
+	if (IP_VS_FWD_METHOD(cp) != 0) {
+		IP_VS_ERR("shouldn't reach here, because the box is on the "
+			  "half connection in the tun/dr module.\n");
+	}
+
+	/* Ensure the checksum is correct */
+	if (!skb_csum_unnecessary(skb)
+	    && ip_vs_checksum_complete(skb, sizeof(struct ipv6hdr))) {
+		/* Failed checksum! */
+		IP_VS_DBG(1, "Forward ICMPv6: failed checksum from "
+			  NIP6_FMT "!\n",
+			  NIP6(iph->saddr));
+		goto out;
+	}
+
+	if (IPPROTO_TCP == cih->nexthdr || IPPROTO_UDP == cih->nexthdr)
+		offset += 2 * sizeof(__u16);
+	if (!skb_make_writable(skb, offset))
+		goto out;
+
+	ip_vs_nat_icmp_v6(skb, pp, cp, 1);
+
+	/* do the statistics and put it back */
+	ip_vs_out_stats(cp, skb);
+
+	skb->ipvs_property = 1;
+	verdict = NF_ACCEPT;
+
+  out:
+	__ip_vs_conn_put(cp);
+
+	return verdict;
+}
+#endif
+
+static inline int is_tcp_reset(const struct sk_buff *skb, int nh_len)
 {
 	struct tcphdr _tcph, *th;
 
-	th = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(_tcph), &_tcph);
+	th = skb_header_pointer(skb, nh_len, sizeof(_tcph), &_tcph);
 	if (th == NULL)
 		return 0;
 	return th->rst;
@@ -686,43 +868,67 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 	  const struct net_device *in, const struct net_device *out,
 	  int (*okfn)(struct sk_buff *))
 {
-	struct iphdr	*iph;
+	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_conn *cp;
-	int ihl;
+	int af;
 
 	EnterFunction(11);
 
+	af = (skb->protocol == __constant_htons(ETH_P_IP)) ? AF_INET : AF_INET6;
+
 	if (skb->ipvs_property)
 		return NF_ACCEPT;
 
-	iph = ip_hdr(skb);
-	if (unlikely(iph->protocol == IPPROTO_ICMP)) {
-		int related, verdict = ip_vs_out_icmp(skb, &related);
+	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6) {
+		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
+			int related, verdict = ip_vs_out_icmp_v6(skb, &related);
 
-		if (related)
-			return verdict;
-		iph = ip_hdr(skb);
-	}
+			if (related)
+				return verdict;
+			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+		}
+	} else
+#endif
+		if (unlikely(iph.protocol == IPPROTO_ICMP)) {
+			int related, verdict = ip_vs_out_icmp(skb, &related);
+
+			if (related)
+				return verdict;
+			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+		}
 
-	pp = ip_vs_proto_get(iph->protocol);
+	pp = ip_vs_proto_get(iph.protocol);
 	if (unlikely(!pp))
 		return NF_ACCEPT;
 
 	/* reassemble IP fragments */
-	if (unlikely(iph->frag_off & htons(IP_MF|IP_OFFSET) &&
-		     !pp->dont_defrag)) {
-		if (ip_vs_gather_frags(skb, IP_DEFRAG_VS_OUT))
-			return NF_STOLEN;
-		iph = ip_hdr(skb);
-	}
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6) {
+		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
+			int related, verdict = ip_vs_out_icmp_v6(skb, &related);
+
+			if (related)
+				return verdict;
+
+			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+		}
+	} else
+#endif
+		if (unlikely(ip_hdr(skb)->frag_off & htons(IP_MF|IP_OFFSET) &&
+			     !pp->dont_defrag)) {
+			if (ip_vs_gather_frags(skb, IP_DEFRAG_VS_OUT))
+				return NF_STOLEN;
 
-	ihl = iph->ihl << 2;
+			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+		}
 
 	/*
 	 * Check if the packet belongs to an existing entry
 	 */
-	cp = pp->conn_out_get(skb, pp, iph, ihl, 0);
+	cp = pp->conn_out_get(af, skb, pp, &iph, iph.len, 0);
 
 	if (unlikely(!cp)) {
 		if (sysctl_ip_vs_nat_icmp_send &&
@@ -730,21 +936,31 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 		     pp->protocol == IPPROTO_UDP)) {
 			__be16 _ports[2], *pptr;
 
-			pptr = skb_header_pointer(skb, ihl,
+			pptr = skb_header_pointer(skb, iph.len,
 						  sizeof(_ports), _ports);
 			if (pptr == NULL)
 				return NF_ACCEPT;	/* Not for me */
-			if (ip_vs_lookup_real_service(iph->protocol,
-						      iph->saddr, pptr[0])) {
+			if (ip_vs_lookup_real_service(af, iph.protocol,
+						      &iph.saddr,
+						      pptr[0])) {
 				/*
 				 * Notify the real server: there is no
 				 * existing entry if it is not RST
 				 * packet or not TCP packet.
 				 */
-				if (iph->protocol != IPPROTO_TCP
-				    || !is_tcp_reset(skb)) {
-					icmp_send(skb,ICMP_DEST_UNREACH,
-						  ICMP_PORT_UNREACH, 0);
+				if (iph.protocol != IPPROTO_TCP
+				    || !is_tcp_reset(skb, iph.len)) {
+#ifdef CONFIG_IP_VS_IPV6
+					if (af == AF_INET6)
+						icmpv6_send(skb,
+							    ICMPV6_DEST_UNREACH,
+							    ICMPV6_PORT_UNREACH,
+							    0, skb->dev);
+					else
+#endif
+						icmp_send(skb,
+							  ICMP_DEST_UNREACH,
+							  ICMP_PORT_UNREACH, 0);
 					return NF_DROP;
 				}
 			}
@@ -756,14 +972,22 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 
 	IP_VS_DBG_PKT(11, pp, skb, 0, "Outgoing packet");
 
-	if (!skb_make_writable(skb, ihl))
+	if (!skb_make_writable(skb, iph.len))
 		goto drop;
 
 	/* mangle the packet */
 	if (pp->snat_handler && !pp->snat_handler(skb, pp, cp))
 		goto drop;
-	ip_hdr(skb)->saddr = cp->vaddr;
-	ip_send_check(ip_hdr(skb));
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		ipv6_hdr(skb)->saddr = cp->vaddr.in6;
+	else
+#endif
+	{
+		ip_hdr(skb)->saddr = cp->vaddr.ip;
+		ip_send_check(ip_hdr(skb));
+	}
 
 	/* For policy routing, packets originating from this
 	 * machine itself may be routed differently to packets
@@ -771,8 +995,14 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 	 * if it came from this machine itself.  So re-compute
 	 * the routing information.
 	 */
-	if (ip_route_me_harder(skb, RTN_LOCAL) != 0)
-		goto drop;
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6) {
+		if (ip6_route_me_harder(skb) != 0)
+			goto drop;
+	} else
+#endif
+		if (ip_route_me_harder(skb, RTN_LOCAL) != 0)
+			goto drop;
 
 	IP_VS_DBG_PKT(10, pp, skb, 0, "After SNAT");
 
@@ -804,6 +1034,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	struct iphdr *iph;
 	struct icmphdr	_icmph, *ic;
 	struct iphdr	_ciph, *cih;	/* The ip header contained within the ICMP */
+	struct ip_vs_iphdr ciph;
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
 	unsigned int offset, ihl, verdict;
@@ -860,8 +1091,9 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 
 	offset += cih->ihl * 4;
 
+	ip_vs_fill_iphdr(AF_INET6, cih, &ciph);
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_in_get(skb, pp, cih, offset, 1);
+	cp = pp->conn_in_get(AF_INET, skb, pp, &ciph, offset, 1);
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -888,6 +1120,92 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	return verdict;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static int
+ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
+{
+	struct ipv6hdr *iph;
+	struct icmp6hdr	_icmph, *ic;
+	struct ipv6hdr	_ciph, *cih;	/* The ip header contained within the ICMP */
+	struct ip_vs_iphdr ciph;
+	struct ip_vs_conn *cp;
+	struct ip_vs_protocol *pp;
+	unsigned int offset, verdict;
+
+	*related = 1;
+
+	/* reassemble IP fragments */
+	if (ipv6_hdr(skb)->nexthdr == IPPROTO_FRAGMENT) {
+		if (ip_vs_gather_frags_v6(skb, hooknum == NF_INET_LOCAL_IN ?
+					       IP_DEFRAG_VS_IN : IP_DEFRAG_VS_FWD))
+			return NF_STOLEN;
+	}
+
+	iph = ipv6_hdr(skb);
+	offset = sizeof(struct ipv6hdr);
+	ic = skb_header_pointer(skb, offset, sizeof(_icmph), &_icmph);
+	if (ic == NULL)
+		return NF_DROP;
+
+	IP_VS_DBG(12, "Incoming ICMPv6 (%d,%d) " NIP6_FMT "->" NIP6_FMT "\n",
+		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
+		  NIP6(iph->saddr), NIP6(iph->daddr));
+
+	/*
+	 * Work through seeing if this is for us.
+	 * These checks are supposed to be in an order that means easy
+	 * things are checked first to speed up processing.... however
+	 * this means that some packets will manage to get a long way
+	 * down this stack and then be rejected, but that's life.
+	 */
+	if ((ic->icmp6_type != ICMPV6_DEST_UNREACH) &&
+	    (ic->icmp6_type != ICMPV6_PKT_TOOBIG) &&
+	    (ic->icmp6_type != ICMPV6_TIME_EXCEED)) {
+		*related = 0;
+		return NF_ACCEPT;
+	}
+
+	/* Now find the contained IP header */
+	offset += sizeof(_icmph);
+	cih = skb_header_pointer(skb, offset, sizeof(_ciph), &_ciph);
+	if (cih == NULL)
+		return NF_ACCEPT; /* The packet looks wrong, ignore */
+
+	pp = ip_vs_proto_get(cih->nexthdr);
+	if (!pp)
+		return NF_ACCEPT;
+
+	/* Is the embedded protocol header present? */
+	/* TODO: we don't support fragmentation at the moment anyways */
+	if (unlikely(cih->nexthdr == IPPROTO_FRAGMENT && pp->dont_defrag))
+		return NF_ACCEPT;
+
+	IP_VS_DBG_PKT(11, pp, skb, offset, "Checking incoming ICMPv6 for");
+
+	offset += sizeof(struct ipv6hdr);
+
+	ip_vs_fill_iphdr(AF_INET6, cih, &ciph);
+	/* The embedded headers contain source and dest in reverse order */
+	cp = pp->conn_in_get(AF_INET6, skb, pp, &ciph, offset, 1);
+	if (!cp)
+		return NF_ACCEPT;
+
+	verdict = NF_DROP;
+
+	/* do the statistics and put it back */
+	ip_vs_in_stats(cp, skb);
+	if (IPPROTO_TCP == cih->nexthdr || IPPROTO_UDP == cih->nexthdr)
+		offset += 2 * sizeof(__u16);
+	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, offset);
+	/* do not touch skb anymore */
+
+	__ip_vs_conn_put(cp);
+
+	return verdict;
+}
+#endif
+
+
 /*
  *	Check if it's for virtual services, look it up,
  *	and send it on its way...
@@ -897,11 +1215,14 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 	 const struct net_device *in, const struct net_device *out,
 	 int (*okfn)(struct sk_buff *))
 {
-	struct iphdr	*iph;
+	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_conn *cp;
-	int ret, restart;
-	int ihl;
+	int ret, restart, af;
+
+	af = (skb->protocol == __constant_htons(ETH_P_IP)) ? AF_INET : AF_INET6;
+
+	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 
 	/*
 	 *	Big tappo: only PACKET_HOST (neither loopback nor mcasts)
@@ -916,31 +1237,28 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 		return NF_ACCEPT;
 	}
 
-	iph = ip_hdr(skb);
-	if (unlikely(iph->protocol == IPPROTO_ICMP)) {
+	if (unlikely(iph.protocol == IPPROTO_ICMP)) {
 		int related, verdict = ip_vs_in_icmp(skb, &related, hooknum);
 
 		if (related)
 			return verdict;
-		iph = ip_hdr(skb);
+		ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 	}
 
 	/* Protocol supported? */
-	pp = ip_vs_proto_get(iph->protocol);
+	pp = ip_vs_proto_get(iph.protocol);
 	if (unlikely(!pp))
 		return NF_ACCEPT;
 
-	ihl = iph->ihl << 2;
-
 	/*
 	 * Check if the packet belongs to an existing connection entry
 	 */
-	cp = pp->conn_in_get(skb, pp, iph, ihl, 0);
+	cp = pp->conn_in_get(af, skb, pp, &iph, iph.len, 0);
 
 	if (unlikely(!cp)) {
 		int v;
 
-		if (!pp->conn_schedule(skb, pp, &v, &cp))
+		if (!pp->conn_schedule(af, skb, pp, &v, &cp))
 			return v;
 	}
 
@@ -984,7 +1302,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 	 * encorage the standby servers to update the connections timeout
 	 */
 	atomic_inc(&cp->in_pkts);
-	if ((ip_vs_sync_state & IP_VS_STATE_MASTER) &&
+	if (af == AF_INET &&
+	    (ip_vs_sync_state & IP_VS_STATE_MASTER) &&
 	    (((cp->protocol != IPPROTO_TCP ||
 	       cp->state == IP_VS_TCP_S_ESTABLISHED) &&
 	      (atomic_read(&cp->in_pkts) % sysctl_ip_vs_sync_threshold[1]
@@ -1023,6 +1342,21 @@ ip_vs_forward_icmp(unsigned int hooknum, struct sk_buff *skb,
 	return ip_vs_in_icmp(skb, &r, hooknum);
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static unsigned int
+ip_vs_forward_icmp_v6(unsigned int hooknum, struct sk_buff *skb,
+		      const struct net_device *in, const struct net_device *out,
+		      int (*okfn)(struct sk_buff *))
+{
+	int r;
+
+	if (ipv6_hdr(skb)->nexthdr != IPPROTO_ICMPV6)
+		return NF_ACCEPT;
+
+	return ip_vs_in_icmp_v6(skb, &r, hooknum);
+}
+#endif
+
 
 static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	/* After packet filtering, forward packet through VS/DR, VS/TUN,
@@ -1060,6 +1394,43 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 		.hooknum        = NF_INET_POST_ROUTING,
 		.priority       = NF_IP_PRI_NAT_SRC-1,
 	},
+#ifdef CONFIG_IP_VS_IPV6
+	/* After packet filtering, forward packet through VS/DR, VS/TUN,
+	 * or VS/NAT(change destination), so that filtering rules can be
+	 * applied to IPVS. */
+	{
+		.hook		= ip_vs_in,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET6,
+		.hooknum        = NF_INET_LOCAL_IN,
+		.priority       = 100,
+	},
+	/* After packet filtering, change source only for VS/NAT */
+	{
+		.hook		= ip_vs_out,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET6,
+		.hooknum        = NF_INET_FORWARD,
+		.priority       = 100,
+	},
+	/* After packet filtering (but before ip_vs_out_icmp), catch icmp
+	 * destined for 0.0.0.0/0, which is for incoming IPVS connections */
+	{
+		.hook		= ip_vs_forward_icmp_v6,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET6,
+		.hooknum        = NF_INET_FORWARD,
+		.priority       = 99,
+	},
+	/* Before the netfilter connection tracking, exit from POST_ROUTING */
+	{
+		.hook		= ip_vs_post_routing,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET6,
+		.hooknum        = NF_INET_POST_ROUTING,
+		.priority       = NF_IP6_PRI_NAT_SRC-1,
+	},
+#endif
 };
 
 
-- 
1.5.4.5

