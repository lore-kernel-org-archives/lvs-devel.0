From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 20/26] IPVS: Add IPv6 Netfilter hooks and add/modify support functions.
Date: Wed, 11 Jun 2008 19:12:03 +0200
Message-ID: <1213204329-10973-21-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213204339; bh=Lft3BCuaSaEfVO55Ma2JmanGBUw=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=TQELZGSTuOvuQ2DGt24wUEBjj/upkYbJAlrcZhPZ
	xuW2Ea2spI/GrsY0pqSJjsGS8iBP4EOz5Mty3yvzIe+cNg==
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com, "Julius R. Volz" <juliusv@google.com>

Add Netfilter hooks for IPv6 and corresponding functions that handle
incoming / outgoing IPv6 packets. Also adapt/add some helper functions
and macros to work with the v6 versions.

Signed-off-by: Julius R. Volz <juliusv@google.com>

 2 files changed, 607 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 8d28d98..ab59696 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -998,7 +998,10 @@ ip_vs_schedule_v6(struct ip_vs_service *svc, const struct sk_buff *skb);
 
 extern int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 			struct ip_vs_protocol *pp);
-
+#ifdef CONFIG_IP_VS_IPV6
+extern int ip_vs_leave_v6(struct ip_vs_service *svc, struct sk_buff *skb,
+			  struct ip_vs_protocol *pp);
+#endif
 
 /*
  *      IPVS control data and functions (from ip_vs_ctl.c)
@@ -1125,7 +1128,12 @@ static inline char ip_vs_fwd_tag(struct ip_vs_conn *cp)
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
 
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index ccd95ff..ded862b 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -41,6 +41,11 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
 
+#ifdef CONFIG_IP_VS_IPV6
+#include <net/ipv6.h>
+#include <linux/netfilter_ipv6.h>
+#endif
+
 #include <net/ip_vs.h>
 
 
@@ -62,6 +67,7 @@ EXPORT_SYMBOL(ip_vs_get_debug_level);
 
 /* ID used in ICMP lookups */
 #define icmp_id(icmph)          (((icmph)->un).echo.id)
+#define icmpv6_id(icmph)        (icmph->icmp6_dataun.u_echo.identifier)
 
 const char *ip_vs_proto_name(unsigned proto)
 {
@@ -76,6 +82,10 @@ const char *ip_vs_proto_name(unsigned proto)
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
@@ -716,6 +726,82 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 }
 
 
+#ifdef CONFIG_IP_VS_IPV6
+int ip_vs_leave_v6(struct ip_vs_service *svc, struct sk_buff *skb,
+		   struct ip_vs_protocol *pp)
+{
+	__be16 _ports[2], *pptr;
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+
+	pptr = skb_header_pointer(skb, sizeof(struct ipv6hdr),
+				  sizeof(_ports), _ports);
+	if (pptr == NULL) {
+		ip_vs_service_put(svc);
+		return NF_DROP;
+	}
+
+	/* if it is fwmark-based service, the cache_bypass sysctl is up
+	   and the destination is IPV6_ADDR_UNICAST (and not local), then create
+	   a cache_bypass connection entry */
+	if (sysctl_ip_vs_cache_bypass && svc->fwmark
+	    && (ipv6_addr_type(&iph->daddr) & IPV6_ADDR_UNICAST)) {
+		int ret, cs;
+		struct ip_vs_conn *cp;
+
+		ip_vs_service_put(svc);
+
+		/* create a new connection entry */
+		IP_VS_DBG(6, "ip_vs_leave: create a cache_bypass entry\n");
+		cp = ip_vs_conn_new_v6(iph->nexthdr,
+				    &iph->saddr, pptr[0],
+				    &iph->daddr, pptr[1],
+				    0, 0,
+				    IP_VS_CONN_F_BYPASS,
+				    NULL);
+		if (cp == NULL)
+			return NF_DROP;
+
+		/* statistics */
+		ip_vs_in_stats(cp, skb);
+
+		/* set state */
+		cs = ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pp);
+
+		/* transmit the first SYN packet */
+		ret = cp->packet_xmit(skb, cp, pp);
+		/* do not touch skb anymore */
+
+		atomic_inc(&cp->in_pkts);
+		ip_vs_conn_put(cp);
+		return ret;
+	}
+
+	/*
+	 * When the virtual ftp service is presented, packets destined
+	 * for other services on the VIP may get here (except services
+	 * listed in the ipvs table), pass the packets, because it is
+	 * not ipvs job to decide to drop the packets.
+	 */
+	if ((svc->port == FTPPORT) && (pptr[1] != FTPPORT)) {
+		ip_vs_service_put(svc);
+		return NF_ACCEPT;
+	}
+
+	ip_vs_service_put(svc);
+
+	/*
+	 * Notify the client that the destination is unreachable, and
+	 * release the socket buffer.
+	 * Since it is in IP layer, the TCP socket is not actually
+	 * created, the TCP RST packet cannot be sent, instead that
+	 * ICMP_PORT_UNREACH is sent here no matter it is TCP/UDP. --WZ
+	 */
+	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0, skb->dev);
+	return NF_DROP;
+}
+#endif
+
+
 /*
  *      It is hooked before NF_IP_PRI_NAT_SRC at the NF_INET_POST_ROUTING
  *      chain, and is used for VS/NAT.
@@ -750,6 +836,14 @@ static inline int ip_vs_gather_frags(struct sk_buff *skb, u_int32_t user)
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
@@ -798,6 +892,49 @@ void ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
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
+		iph->saddr = cp->vaddr.v6;
+		ciph->daddr = cp->vaddr.v6;
+	} else {
+		iph->daddr = cp->daddr.v6;
+		ciph->saddr = cp->daddr.v6;
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
@@ -904,11 +1041,112 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related)
 	return verdict;
 }
 
-static inline int is_tcp_reset(const struct sk_buff *skb)
+#ifdef CONFIG_IP_VS_IPV6
+static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related)
+{
+	struct ipv6hdr *iph;
+	struct icmp6hdr	_icmph, *ic;
+	struct ipv6hdr	_ciph, *cih;	/* The ip header contained within the ICMP */
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
+	/* The embedded headers contain source and dest in reverse order */
+	cp = pp->conn_out_get_v6(skb, pp, iph, offset, 1);
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
@@ -980,7 +1218,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 				 * packet or not TCP packet.
 				 */
 				if (iph->protocol != IPPROTO_TCP
-				    || !is_tcp_reset(skb)) {
+				    || !is_tcp_reset(skb, ip_hdrlen(skb))) {
 					icmp_send(skb,ICMP_DEST_UNREACH,
 						  ICMP_PORT_UNREACH, 0);
 					return NF_DROP;
@@ -1029,6 +1267,114 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 	return NF_STOLEN;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static unsigned int
+ip_vs_out_v6(unsigned int hooknum, struct sk_buff *skb,
+	     const struct net_device *in, const struct net_device *out,
+	     int (*okfn)(struct sk_buff *))
+{
+	struct ipv6hdr *iph;
+	struct ip_vs_protocol *pp;
+	struct ip_vs_conn *cp;
+
+	EnterFunction(11);
+
+	if (skb->ipvs_property)
+		return NF_ACCEPT;
+
+	iph = ipv6_hdr(skb);
+	if (unlikely(iph->nexthdr == IPPROTO_ICMPV6)) {
+		int related, verdict = ip_vs_out_icmp_v6(skb, &related);
+
+		if (related)
+			return verdict;
+		iph = ipv6_hdr(skb);
+	}
+
+	/* TODO IPv6: handle extension headers */
+	pp = ip_vs_proto_get(iph->nexthdr);
+	if (unlikely(!pp))
+		return NF_ACCEPT;
+
+	/* reassemble IP fragments */
+	if (iph->nexthdr == IPPROTO_FRAGMENT) {
+		if (ip_vs_gather_frags_v6(skb, IP_DEFRAG_VS_OUT))
+			return NF_STOLEN;
+		iph = ipv6_hdr(skb);
+	}
+
+	/*
+	 * Check if the packet belongs to an existing entry
+	 */
+	cp = pp->conn_out_get_v6(skb, pp, iph, sizeof(struct ipv6hdr), 0);
+
+	if (unlikely(!cp)) {
+		if (sysctl_ip_vs_nat_icmp_send &&
+		    (pp->protocol == IPPROTO_TCP ||
+		     pp->protocol == IPPROTO_UDP)) {
+			__be16 _ports[2], *pptr;
+
+			pptr = skb_header_pointer(skb, sizeof(struct ipv6hdr),
+						  sizeof(_ports), _ports);
+			if (pptr == NULL)
+				return NF_ACCEPT;	/* Not for me */
+			if (ip_vs_lookup_real_service_v6(iph->nexthdr,
+						         &iph->saddr, pptr[0])) {
+				/*
+				 * Notify the real server: there is no
+				 * existing entry if it is not RST
+				 * packet or not TCP packet.
+				 */
+				if (iph->nexthdr != IPPROTO_TCP
+				    || !is_tcp_reset(skb, sizeof(struct ipv6hdr))) {
+					icmpv6_send(skb, ICMPV6_DEST_UNREACH,
+						  ICMPV6_PORT_UNREACH, 0, skb->dev);
+					return NF_DROP;
+				}
+			}
+		}
+		IP_VS_DBG_PKT(12, pp, skb, 0,
+			      "packet continues traversal as normal");
+		return NF_ACCEPT;
+	}
+
+	IP_VS_DBG_PKT(11, pp, skb, 0, "Outgoing packet");
+
+	if (!skb_make_writable(skb, sizeof(struct ipv6hdr)))
+		goto drop;
+
+	/* mangle the packet */
+	if (pp->snat_handler_v6 && !pp->snat_handler_v6(skb, pp, cp))
+		goto drop;
+	ipv6_hdr(skb)->saddr = cp->vaddr.v6;
+
+	/* For policy routing, packets originating from this
+	 * machine itself may be routed differently to packets
+	 * passing through.  We want this packet to be routed as
+	 * if it came from this machine itself.  So re-compute
+	 * the routing information.
+	 */
+	if (ip6_route_me_harder(skb) != 0)
+		goto drop;
+
+	IP_VS_DBG_PKT(10, pp, skb, 0, "After SNAT");
+
+	ip_vs_out_stats(cp, skb);
+	ip_vs_set_state(cp, IP_VS_DIR_OUTPUT, skb, pp);
+	ip_vs_conn_put(cp);
+
+	skb->ipvs_property = 1;
+
+	LeaveFunction(11);
+	return NF_ACCEPT;
+
+  drop:
+	ip_vs_conn_put(cp);
+	kfree_skb(skb);
+	return NF_STOLEN;
+}
+#endif
+
 
 /*
  *	Handle ICMP messages in the outside-to-inside direction (incoming).
@@ -1126,6 +1472,90 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	return verdict;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static int
+ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
+{
+	struct ipv6hdr *iph;
+	struct icmp6hdr	_icmph, *ic;
+	struct ipv6hdr	_ciph, *cih;	/* The ip header contained within the ICMP */
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
+	/* The embedded headers contain source and dest in reverse order */
+	cp = pp->conn_in_get_v6(skb, pp, cih, offset, 1);
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
@@ -1237,6 +1667,118 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 	return ret;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static unsigned int
+ip_vs_in_v6(unsigned int hooknum, struct sk_buff *skb,
+	 const struct net_device *in, const struct net_device *out,
+	 int (*okfn)(struct sk_buff *))
+{
+	struct ipv6hdr *iph;
+	struct ip_vs_protocol *pp;
+	struct ip_vs_conn *cp;
+	int ret, restart;
+
+	/*
+	 *	Big tappo: only PACKET_HOST (neither loopback nor mcasts)
+	 *	... don't know why 1st test DOES NOT include 2nd (?)
+	 */
+	if (unlikely(skb->pkt_type != PACKET_HOST
+		     || skb->dev->flags & IFF_LOOPBACK || skb->sk)) {
+		IP_VS_DBG(12, "packet type=%d proto=%d daddr=" NIP6_FMT " ignored\n",
+			  skb->pkt_type,
+			  ipv6_hdr(skb)->nexthdr,
+			  NIP6(ipv6_hdr(skb)->daddr));
+		return NF_ACCEPT;
+	}
+
+	iph = ipv6_hdr(skb);
+	if (unlikely(iph->nexthdr == IPPROTO_ICMPV6)) {
+		int related, verdict = ip_vs_in_icmp_v6(skb, &related, hooknum);
+
+		if (related)
+			return verdict;
+		iph = ipv6_hdr(skb);
+	}
+
+	/* Protocol supported? */
+	/* TODO IPv6: handle extension headers */
+	pp = ip_vs_proto_get(iph->nexthdr);
+	if (unlikely(!pp))
+		return NF_ACCEPT;
+
+	/*
+	 * Check if the packet belongs to an existing connection entry
+	 */
+	cp = pp->conn_in_get_v6(skb, pp, iph, sizeof(struct ipv6hdr), 0);
+
+	if (unlikely(!cp)) {
+		int v;
+
+		if (!pp->conn_schedule_v6(skb, pp, &v, &cp))
+			return v;
+	}
+
+	if (unlikely(!cp)) {
+		/* sorry, all this trouble for a no-hit :) */
+		IP_VS_DBG_PKT(12, pp, skb, 0,
+			      "packet continues traversal as normal");
+		return NF_ACCEPT;
+	}
+
+	IP_VS_DBG_PKT(11, pp, skb, 0, "Incoming packet");
+
+	/* Check the server status */
+	if (cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
+		/* the destination server is not available */
+
+		if (sysctl_ip_vs_expire_nodest_conn) {
+			/* try to expire the connection immediately */
+			ip_vs_conn_expire_now(cp);
+		}
+		/* don't restart its timer, and silently
+		   drop the packet. */
+		__ip_vs_conn_put(cp);
+		return NF_DROP;
+	}
+
+	ip_vs_in_stats(cp, skb);
+	restart = ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pp);
+	if (cp->packet_xmit)
+		ret = cp->packet_xmit(skb, cp, pp);
+		/* do not touch skb anymore */
+	else {
+		IP_VS_DBG_RL("warning: packet_xmit is null");
+		ret = NF_ACCEPT;
+	}
+
+	/* Increase its packet counter and check if it is needed
+	 * to be synchronized
+	 *
+	 * Sync connection if it is about to close to
+	 * encorage the standby servers to update the connections timeout
+	 *
+	 * TODO IPv6: make sync daemon work with IPv6, disabled for now
+	 */
+
+	/*
+	atomic_inc(&cp->in_pkts);
+	if ((ip_vs_sync_state & IP_VS_STATE_MASTER) &&
+	    (((cp->protocol != IPPROTO_TCP ||
+	       cp->state == IP_VS_TCP_S_ESTABLISHED) &&
+	      (atomic_read(&cp->in_pkts) % sysctl_ip_vs_sync_threshold[1]
+	       == sysctl_ip_vs_sync_threshold[0])) ||
+	     ((cp->protocol == IPPROTO_TCP) && (cp->old_state != cp->state) &&
+	      ((cp->state == IP_VS_TCP_S_FIN_WAIT) ||
+	       (cp->state == IP_VS_TCP_S_CLOSE)))))
+		ip_vs_sync_conn(cp);
+	*/
+	cp->old_state = cp->state;
+
+	ip_vs_conn_put(cp);
+	return ret;
+}
+#endif
+
 
 /*
  *	It is hooked at the NF_INET_FORWARD chain, in order to catch ICMP
@@ -1260,6 +1802,21 @@ ip_vs_forward_icmp(unsigned int hooknum, struct sk_buff *skb,
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
@@ -1297,6 +1854,43 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 		.hooknum        = NF_INET_POST_ROUTING,
 		.priority       = NF_IP_PRI_NAT_SRC-1,
 	},
+#ifdef CONFIG_IP_VS_IPV6
+	/* After packet filtering, forward packet through VS/DR, VS/TUN,
+	 * or VS/NAT(change destination), so that filtering rules can be
+	 * applied to IPVS. */
+	{
+		.hook		= ip_vs_in_v6,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET6,
+		.hooknum        = NF_INET_LOCAL_IN,
+		.priority       = 100,
+	},
+	/* After packet filtering, change source only for VS/NAT */
+	{
+		.hook		= ip_vs_out_v6,
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
1.5.3.6

