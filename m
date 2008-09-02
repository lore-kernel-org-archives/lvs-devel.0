From: Julius Volz <juliusv@google.com>
Subject: [PATCHv3 16/24] IPVS: Add/adjust Netfilter hook functions and helpers for v6
Date: Tue,  2 Sep 2008 15:55:47 +0200
Message-ID: <1220363755-9854-17-git-send-email-juliusv@google.com>
References: <1220363755-9854-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220363768; bh=i2SsEcneFxCc3LzJPgEeW08Fyxc=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=oilvb9H/6A0XRkMZUwBBMRxIpqB5zPzP9arBcHTH
	ObuX9fuFQhch3RiuY2mCJyJViyEOJeBPLDuipn8G2shulQ==
In-Reply-To: <1220363755-9854-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Add Netfilter hook functions or modify existing ones, if possible, to
process IPv6 packets. Some support functions are also added/modified for
this. ip_vs_nat_icmp_v6() was already added in the patch that added the v6
xmit functions, as it is called from one of them.

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 329 insertions(+), 36 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 8bfd7c2..035a511 100644
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
@@ -425,7 +435,8 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 {
 	__be16 _ports[2], *pptr;
 	struct ip_vs_iphdr iph;
-	ip_vs_fill_iphdr(AF_INET, skb_network_header(skb), &iph);
+	int unicast;
+	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 
 	pptr = skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
 	if (pptr == NULL) {
@@ -433,11 +444,17 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
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
-	    && (inet_addr_type(&init_net, iph.daddr.ip) == RTN_UNICAST)) {
+	if (sysctl_ip_vs_cache_bypass && svc->fwmark && unicast) {
 		int ret, cs;
 		struct ip_vs_conn *cp;
 
@@ -445,7 +462,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 
 		/* create a new connection entry */
 		IP_VS_DBG(6, "ip_vs_leave: create a cache_bypass entry\n");
-		cp = ip_vs_conn_new(AF_INET, iph.protocol,
+		cp = ip_vs_conn_new(svc->af, iph.protocol,
 				    &iph.saddr, pptr[0],
 				    &iph.daddr, pptr[1],
 				    0, 0,
@@ -489,7 +506,14 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
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
 
@@ -528,6 +552,14 @@ static inline int ip_vs_gather_frags(struct sk_buff *skb, u_int32_t user)
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
@@ -727,11 +759,117 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related)
 	return verdict;
 }
 
-static inline int is_tcp_reset(const struct sk_buff *skb)
+#ifdef CONFIG_IP_VS_IPV6
+static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related)
+{
+	struct ipv6hdr *iph;
+	struct icmp6hdr	_icmph, *ic;
+	struct ipv6hdr	_ciph, *cih;	/* The ip header contained
+					   within the ICMP */
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
+out:
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
@@ -750,38 +888,64 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_conn *cp;
+	int af;
 
 	EnterFunction(11);
 
+	af = (skb->protocol == __constant_htons(ETH_P_IP)) ? AF_INET : AF_INET6;
+
 	if (skb->ipvs_property)
 		return NF_ACCEPT;
 
-	ip_vs_fill_iphdr(AF_INET, skb_network_header(skb), &iph);
-	if (unlikely(iph.protocol == IPPROTO_ICMP)) {
-		int related, verdict = ip_vs_out_icmp(skb, &related);
+	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6) {
+		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
+			int related, verdict = ip_vs_out_icmp_v6(skb, &related);
 
-		if (related)
-			return verdict;
-		ip_vs_fill_iphdr(AF_INET, skb_network_header(skb), &iph);
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
 
 	pp = ip_vs_proto_get(iph.protocol);
 	if (unlikely(!pp))
 		return NF_ACCEPT;
 
 	/* reassemble IP fragments */
-	if (unlikely(ip_hdr(skb)->frag_off & htons(IP_MF|IP_OFFSET) &&
-		     !pp->dont_defrag)) {
-		if (ip_vs_gather_frags(skb, IP_DEFRAG_VS_OUT))
-			return NF_STOLEN;
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6) {
+		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
+			int related, verdict = ip_vs_out_icmp_v6(skb, &related);
 
-		ip_vs_fill_iphdr(AF_INET, skb_network_header(skb), &iph);
-	}
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
+
+			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+		}
 
 	/*
 	 * Check if the packet belongs to an existing entry
 	 */
-	cp = pp->conn_out_get(AF_INET, skb, pp, &iph, iph.len, 0);
+	cp = pp->conn_out_get(af, skb, pp, &iph, iph.len, 0);
 
 	if (unlikely(!cp)) {
 		if (sysctl_ip_vs_nat_icmp_send &&
@@ -794,16 +958,26 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 			if (pptr == NULL)
 				return NF_ACCEPT;	/* Not for me */
 			if (ip_vs_lookup_real_service(iph.protocol,
-						      iph.saddr.ip, pptr[0])) {
+						      iph.saddr.ip,
+						      pptr[0])) {
 				/*
 				 * Notify the real server: there is no
 				 * existing entry if it is not RST
 				 * packet or not TCP packet.
 				 */
 				if (iph.protocol != IPPROTO_TCP
-				    || !is_tcp_reset(skb)) {
-					icmp_send(skb,ICMP_DEST_UNREACH,
-						  ICMP_PORT_UNREACH, 0);
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
@@ -821,8 +995,16 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 	/* mangle the packet */
 	if (pp->snat_handler && !pp->snat_handler(skb, pp, cp))
 		goto drop;
-	ip_hdr(skb)->saddr = cp->vaddr.ip;
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
@@ -830,8 +1012,14 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
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
 
@@ -949,6 +1137,94 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	return verdict;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static int
+ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
+{
+	struct ipv6hdr *iph;
+	struct icmp6hdr	_icmph, *ic;
+	struct ipv6hdr	_ciph, *cih;	/* The ip header contained
+					   within the ICMP */
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
+					       IP_DEFRAG_VS_IN :
+					       IP_DEFRAG_VS_FWD))
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
@@ -961,9 +1237,11 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_conn *cp;
-	int ret, restart;
+	int ret, restart, af;
+
+	af = (skb->protocol == __constant_htons(ETH_P_IP)) ? AF_INET : AF_INET6;
 
-	ip_vs_fill_iphdr(AF_INET, skb_network_header(skb), &iph);
+	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 
 	/*
 	 *	Big tappo: only PACKET_HOST (neither loopback nor mcasts)
@@ -974,7 +1252,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 		IP_VS_DBG_BUF(12, "packet type=%d proto=%d daddr=%s ignored\n",
 			      skb->pkt_type,
 			      iph.protocol,
-			      IP_VS_DBG_ADDR(AF_INET, &iph.daddr));
+			      IP_VS_DBG_ADDR(af, &iph.daddr));
 		return NF_ACCEPT;
 	}
 
@@ -983,7 +1261,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 
 		if (related)
 			return verdict;
-		ip_vs_fill_iphdr(AF_INET, skb_network_header(skb), &iph);
+		ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 	}
 
 	/* Protocol supported? */
@@ -994,12 +1272,12 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 	/*
 	 * Check if the packet belongs to an existing connection entry
 	 */
-	cp = pp->conn_in_get(AF_INET, skb, pp, &iph, iph.len, 0);
+	cp = pp->conn_in_get(af, skb, pp, &iph, iph.len, 0);
 
 	if (unlikely(!cp)) {
 		int v;
 
-		if (!pp->conn_schedule(AF_INET, skb, pp, &v, &cp))
+		if (!pp->conn_schedule(af, skb, pp, &v, &cp))
 			return v;
 	}
 
@@ -1082,6 +1360,21 @@ ip_vs_forward_icmp(unsigned int hooknum, struct sk_buff *skb,
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
-- 
1.5.4.5

