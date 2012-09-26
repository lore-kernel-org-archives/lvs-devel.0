From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH V4 4/7] ipvs: Fix faulty IPv6 extension header handling in IPVS
Date: Wed, 26 Sep 2012 14:06:41 +0200
Message-ID: <20120926120625.24804.37928.stgit@dragon>
References: <20120926120534.24804.78415.stgit@dragon>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120926120534.24804.78415.stgit@dragon>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Hans Schillstrom <hans@schillstrom.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

IPv6 packets can contain extension headers, thus its wrong to assume
that the transport/upper-layer header, starts right after (struct
ipv6hdr) the IPv6 header.  IPVS uses this false assumption, and will
write SNAT & DNAT modifications at a fixed pos which will corrupt the
message.

To fix this, proper header position must be found before modifying
packets.  Introducing ip_vs_fill_iph_skb(), which uses ipv6_find_hdr()
to skip the exthdrs. It finds (1) the transport header offset, (2) the
protocol, and (3) detects if the packet is a fragment.

Note, that fragments in IPv6 is represented via an exthdr.  Thus, this
is detected while skipping through the exthdrs.

This patch depends on commit 84018f55a:
 "netfilter: ip6_tables: add flags parameter to ipv6_find_hdr()"
This also adds a dependency to ip6_tables.

Originally based on patch from: Hans Schillstrom

kABI notes:
Changing struct ip_vs_iphdr is a potential minor kABI breaker,
because external modules can be compiled with another version of
this struct.  This should not matter, as they would most-likely
be using a compiled-in version of ip_vs_fill_iphdr().  When
recompiled, they will notice ip_vs_fill_iphdr() no longer exists,
and they have to used ip_vs_fill_iph_skb() instead.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
V4:
 - Cleanup ip_vs_out_icmp_v6() e.g. avoid double/reuse of variable ipvsh
 - Remove the skb_make_writable call in ip_vs_nat_icmp_v6()
 - Fix ip_vs_in_icmp_v6() writable offset assignment
 - Safer pkt skip, if ICMPv6 contained IPv6 packet is not parsable

V3:
 - No big API changes (these are postpone to later patch)
 - Make ip_vs_in_icmp_v6() easier to review, avoid spliting related
   changes across patches.
 - Fix port write offset bug in ip_vs_in_icmp_v6()
 - Move ip_vs_pe_sip.c changes to a seperate patch.

V2:
 - Use macro IS_ENABLED(CONFIG_XXX)
 - Re-add NULL pointer check in ip_vs_out_icmp_v6()


 include/net/ip_vs.h                   |   72 ++++++++++-
 net/netfilter/ipvs/Kconfig            |    1 
 net/netfilter/ipvs/ip_vs_core.c       |  211 ++++++++++++++++-----------------
 net/netfilter/ipvs/ip_vs_dh.c         |    2 
 net/netfilter/ipvs/ip_vs_lblc.c       |    2 
 net/netfilter/ipvs/ip_vs_lblcr.c      |    2 
 net/netfilter/ipvs/ip_vs_pe_sip.c     |    2 
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   22 ++-
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |   22 ++-
 net/netfilter/ipvs/ip_vs_proto_udp.c  |   22 ++-
 net/netfilter/ipvs/ip_vs_sh.c         |    2 
 net/netfilter/ipvs/ip_vs_xmit.c       |    5 -
 net/netfilter/xt_ipvs.c               |    2 
 13 files changed, 214 insertions(+), 153 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index c8b2bdb..29265bf 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -22,6 +22,9 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>			/* for struct ipv6hdr */
 #include <net/ipv6.h>
+#if IS_ENABLED(CONFIG_IPV6)
+#include <linux/netfilter_ipv6/ip6_tables.h>
+#endif
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 #include <net/netfilter/nf_conntrack.h>
 #endif
@@ -103,30 +106,79 @@ static inline struct net *seq_file_single_net(struct seq_file *seq)
 /* Connections' size value needed by ip_vs_ctl.c */
 extern int ip_vs_conn_tab_size;
 
-
 struct ip_vs_iphdr {
-	int len;
-	__u8 protocol;
+	__u32 len;	/* IPv4 simply where L4 starts
+			   IPv6 where L4 Transport Header starts */
+	__u16 fragoffs; /* IPv6 fragment offset, 0 if first frag (or not frag)*/
+	__s16 protocol;
+	__s32 flags;
 	union nf_inet_addr saddr;
 	union nf_inet_addr daddr;
 };
 
 static inline void
-ip_vs_fill_iphdr(int af, const void *nh, struct ip_vs_iphdr *iphdr)
+ip_vs_fill_ip4hdr(const void *nh, struct ip_vs_iphdr *iphdr)
+{
+	const struct iphdr *iph = nh;
+
+	iphdr->len	= iph->ihl * 4;
+	iphdr->fragoffs	= 0;
+	iphdr->protocol	= iph->protocol;
+	iphdr->saddr.ip	= iph->saddr;
+	iphdr->daddr.ip	= iph->daddr;
+}
+
+/* This function handles filling *ip_vs_iphdr, both for IPv4 and IPv6.
+ * IPv6 requires some extra work, as finding proper header position,
+ * depend on the IPv6 extension headers.
+ */
+static inline void
+ip_vs_fill_iph_skb(int af, const struct sk_buff *skb, struct ip_vs_iphdr *iphdr)
 {
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
-		const struct ipv6hdr *iph = nh;
-		iphdr->len = sizeof(struct ipv6hdr);
-		iphdr->protocol = iph->nexthdr;
+		const struct ipv6hdr *iph =
+			(struct ipv6hdr *)skb_network_header(skb);
 		iphdr->saddr.in6 = iph->saddr;
 		iphdr->daddr.in6 = iph->daddr;
+		/* ipv6_find_hdr() updates len, flags */
+		iphdr->len	 = 0;
+		iphdr->flags	 = 0;
+		iphdr->protocol  = ipv6_find_hdr(skb, &iphdr->len, -1,
+						 &iphdr->fragoffs,
+						 &iphdr->flags);
 	} else
 #endif
 	{
-		const struct iphdr *iph = nh;
-		iphdr->len = iph->ihl * 4;
-		iphdr->protocol = iph->protocol;
+		const struct iphdr *iph =
+			(struct iphdr *)skb_network_header(skb);
+		iphdr->len	= iph->ihl * 4;
+		iphdr->fragoffs	= 0;
+		iphdr->protocol	= iph->protocol;
+		iphdr->saddr.ip	= iph->saddr;
+		iphdr->daddr.ip	= iph->daddr;
+	}
+}
+
+/* This function is a faster version of ip_vs_fill_iph_skb().
+ * Where we only populate {s,d}addr (and avoid calling ipv6_find_hdr()).
+ * This is used by the some of the ip_vs_*_schedule() functions.
+ * (Mostly done to avoid ABI breakage of external schedulers)
+ */
+static inline void
+ip_vs_fill_iph_addr_only(int af, const struct sk_buff *skb,
+			 struct ip_vs_iphdr *iphdr)
+{
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6) {
+		const struct ipv6hdr *iph =
+			(struct ipv6hdr *)skb_network_header(skb);
+		iphdr->saddr.in6 = iph->saddr;
+		iphdr->daddr.in6 = iph->daddr;
+	} else {
+#endif
+		const struct iphdr *iph =
+			(struct iphdr *)skb_network_header(skb);
 		iphdr->saddr.ip = iph->saddr;
 		iphdr->daddr.ip = iph->daddr;
 	}
diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index 8b2cffd..a97ae53 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -28,6 +28,7 @@ if IP_VS
 config	IP_VS_IPV6
 	bool "IPv6 support for IPVS"
 	depends on IPV6 = y || IP_VS = IPV6
+	select IP6_NF_IPTABLES
 	---help---
 	  Add IPv6 support to IPVS. This is incomplete and might be dangerous.
 
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index ebd105c..19c0842 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -236,7 +236,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	union nf_inet_addr snet;	/* source network of the client,
 					   after masking */
 
-	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_skb(svc->af, skb, &iph);
 
 	/* Mask saddr with the netmask to adjust template granularity */
 #ifdef CONFIG_IP_VS_IPV6
@@ -402,7 +402,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	unsigned int flags;
 
 	*ignored = 1;
-	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_skb(svc->af, skb, &iph);
 	pptr = skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
 	if (pptr == NULL)
 		return NULL;
@@ -506,7 +506,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 	int unicast;
 #endif
 
-	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_skb(svc->af, skb, &iph);
 
 	pptr = skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
 	if (pptr == NULL) {
@@ -732,10 +732,19 @@ void ip_vs_nat_icmp_v6(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		    struct ip_vs_conn *cp, int inout)
 {
 	struct ipv6hdr *iph	 = ipv6_hdr(skb);
-	unsigned int icmp_offset = sizeof(struct ipv6hdr);
-	struct icmp6hdr *icmph	 = (struct icmp6hdr *)(skb_network_header(skb) +
-						      icmp_offset);
-	struct ipv6hdr *ciph	 = (struct ipv6hdr *)(icmph + 1);
+	unsigned int icmp_offset = 0;
+	unsigned int offs	 = 0; /* header offset*/
+	int protocol;
+	struct icmp6hdr *icmph;
+	struct ipv6hdr *ciph;
+	unsigned short fragoffs;
+
+	ipv6_find_hdr(skb, &icmp_offset, IPPROTO_ICMPV6, &fragoffs, NULL);
+	icmph = (struct icmp6hdr *)(skb_network_header(skb) + icmp_offset);
+	offs = icmp_offset + sizeof(struct icmp6hdr);
+	ciph = (struct ipv6hdr *)(skb_network_header(skb) + offs);
+
+	protocol = ipv6_find_hdr(skb, &offs, -1, &fragoffs, NULL);
 
 	if (inout) {
 		iph->saddr = cp->vaddr.in6;
@@ -746,10 +755,13 @@ void ip_vs_nat_icmp_v6(struct sk_buff *skb, struct ip_vs_protocol *pp,
 	}
 
 	/* the TCP/UDP/SCTP port */
-	if (IPPROTO_TCP == ciph->nexthdr || IPPROTO_UDP == ciph->nexthdr ||
-	    IPPROTO_SCTP == ciph->nexthdr) {
-		__be16 *ports = (void *)ciph + sizeof(struct ipv6hdr);
+	if (!fragoffs && (IPPROTO_TCP == protocol || IPPROTO_UDP == protocol ||
+			  IPPROTO_SCTP == protocol)) {
+		__be16 *ports = (void *)(skb_network_header(skb) + offs);
 
+		IP_VS_DBG(11, "%s() changed port %d to %d\n", __func__,
+			      ntohs(inout ? ports[1] : ports[0]),
+			      ntohs(inout ? cp->vport : cp->dport));
 		if (inout)
 			ports[1] = cp->vport;
 		else
@@ -898,9 +910,8 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
 	IP_VS_DBG_PKT(11, AF_INET, pp, skb, offset,
 		      "Checking outgoing ICMP for");
 
-	offset += cih->ihl * 4;
-
-	ip_vs_fill_iphdr(AF_INET, cih, &ciph);
+	ip_vs_fill_ip4hdr(cih, &ciph);
+	ciph.len += offset;
 	/* The embedded headers contain source and dest in reverse order */
 	cp = pp->conn_out_get(AF_INET, skb, &ciph, offset, 1);
 	if (!cp)
@@ -908,41 +919,31 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
 
 	snet.ip = iph->saddr;
 	return handle_response_icmp(AF_INET, skb, &snet, cih->protocol, cp,
-				    pp, offset, ihl);
+				    pp, ciph.len, ihl);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
 static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 			     unsigned int hooknum)
 {
-	struct ipv6hdr *iph;
 	struct icmp6hdr	_icmph, *ic;
-	struct ipv6hdr	_ciph, *cih;	/* The ip header contained
-					   within the ICMP */
-	struct ip_vs_iphdr ciph;
+	struct ipv6hdr _ip6h, *ip6h; /* The ip header contained within ICMP */
+	struct ip_vs_iphdr ciph = {.flags = 0, .fragoffs = 0};/*Contained IP */
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
-	unsigned int offset;
 	union nf_inet_addr snet;
+	unsigned int writable;
 
-	*related = 1;
+	struct ip_vs_iphdr ipvsh_stack;
+	struct ip_vs_iphdr *ipvsh = &ipvsh_stack;
+	ip_vs_fill_iph_skb(AF_INET6, skb, ipvsh);
 
-	/* reassemble IP fragments */
-	if (ipv6_hdr(skb)->nexthdr == IPPROTO_FRAGMENT) {
-		if (ip_vs_gather_frags_v6(skb, ip_vs_defrag_user(hooknum)))
-			return NF_STOLEN;
-	}
+	*related = 1;
 
-	iph = ipv6_hdr(skb);
-	offset = sizeof(struct ipv6hdr);
-	ic = skb_header_pointer(skb, offset, sizeof(_icmph), &_icmph);
+	ic = skb_header_pointer(skb, ipvsh->len, sizeof(_icmph), &_icmph);
 	if (ic == NULL)
 		return NF_DROP;
 
-	IP_VS_DBG(12, "Outgoing ICMPv6 (%d,%d) %pI6->%pI6\n",
-		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
-		  &iph->saddr, &iph->daddr);
-
 	/*
 	 * Work through seeing if this is for us.
 	 * These checks are supposed to be in an order that means easy
@@ -955,35 +956,35 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 		return NF_ACCEPT;
 	}
 
+	IP_VS_DBG(8, "Outgoing ICMPv6 (%d,%d) %pI6c->%pI6c\n",
+		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
+		  &ipvsh->saddr, &ipvsh->daddr);
+
 	/* Now find the contained IP header */
-	offset += sizeof(_icmph);
-	cih = skb_header_pointer(skb, offset, sizeof(_ciph), &_ciph);
-	if (cih == NULL)
+	ciph.len = ipvsh->len + sizeof(_icmph);
+	ip6h = skb_header_pointer(skb, ciph.len, sizeof(_ip6h), &_ip6h);
+	if (ip6h == NULL)
 		return NF_ACCEPT; /* The packet looks wrong, ignore */
-
-	pp = ip_vs_proto_get(cih->nexthdr);
+	ciph.saddr.in6 = ip6h->saddr; /* conn_out_get() handles reverse order */
+	ciph.daddr.in6 = ip6h->daddr;
+	/* skip possible IPv6 exthdrs of contained IPv6 packet */
+	ciph.protocol = ipv6_find_hdr(skb, &ciph.len, -1, &ciph.fragoffs, NULL);
+	if (ciph.protocol < 0)
+		return NF_ACCEPT; /* Contained IPv6 hdr looks wrong, ignore */
+
+	pp = ip_vs_proto_get(ciph.protocol);
 	if (!pp)
 		return NF_ACCEPT;
 
-	/* Is the embedded protocol header present? */
-	/* TODO: we don't support fragmentation at the moment anyways */
-	if (unlikely(cih->nexthdr == IPPROTO_FRAGMENT && pp->dont_defrag))
-		return NF_ACCEPT;
-
-	IP_VS_DBG_PKT(11, AF_INET6, pp, skb, offset,
-		      "Checking outgoing ICMPv6 for");
-
-	offset += sizeof(struct ipv6hdr);
-
-	ip_vs_fill_iphdr(AF_INET6, cih, &ciph);
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_out_get(AF_INET6, skb, &ciph, offset, 1);
+	cp = pp->conn_out_get(AF_INET6, skb, &ciph, ciph.len, 1);
 	if (!cp)
 		return NF_ACCEPT;
 
-	snet.in6 = iph->saddr;
-	return handle_response_icmp(AF_INET6, skb, &snet, cih->nexthdr, cp,
-				    pp, offset, sizeof(struct ipv6hdr));
+	snet.in6 = ciph.saddr.in6;
+	writable = ciph.len;
+	return handle_response_icmp(AF_INET6, skb, &snet, ciph.protocol, cp,
+				    pp, writable, sizeof(struct ipv6hdr));
 }
 #endif
 
@@ -1113,7 +1114,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (!net_ipvs(net)->enable)
 		return NF_ACCEPT;
 
-	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_skb(af, skb, &iph);
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
@@ -1123,7 +1124,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 
 			if (related)
 				return verdict;
-			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+			ip_vs_fill_iph_skb(af, skb, &iph);
 		}
 	} else
 #endif
@@ -1133,7 +1134,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 
 			if (related)
 				return verdict;
-			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+			ip_vs_fill_ip4hdr(skb_network_header(skb), &iph);
 		}
 
 	pd = ip_vs_proto_data_get(net, iph.protocol);
@@ -1143,22 +1144,14 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 
 	/* reassemble IP fragments */
 #ifdef CONFIG_IP_VS_IPV6
-	if (af == AF_INET6) {
-		if (ipv6_hdr(skb)->nexthdr == IPPROTO_FRAGMENT) {
-			if (ip_vs_gather_frags_v6(skb,
-						  ip_vs_defrag_user(hooknum)))
-				return NF_STOLEN;
-		}
-
-		ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
-	} else
+	if (af == AF_INET)
 #endif
 		if (unlikely(ip_is_fragment(ip_hdr(skb)) && !pp->dont_defrag)) {
 			if (ip_vs_gather_frags(skb,
 					       ip_vs_defrag_user(hooknum)))
 				return NF_STOLEN;
 
-			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+			ip_vs_fill_ip4hdr(skb_network_header(skb), &iph);
 		}
 
 	/*
@@ -1373,9 +1366,9 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 		      "Checking incoming ICMP for");
 
 	offset2 = offset;
-	offset += cih->ihl * 4;
-
-	ip_vs_fill_iphdr(AF_INET, cih, &ciph);
+	ip_vs_fill_ip4hdr(cih, &ciph);
+	ciph.len += offset;
+	offset = ciph.len;
 	/* The embedded headers contain source and dest in reverse order.
 	 * For IPIP this is error for request, not for reply.
 	 */
@@ -1461,34 +1454,24 @@ static int
 ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 {
 	struct net *net = NULL;
-	struct ipv6hdr *iph;
+	struct ipv6hdr _ip6h, *ip6h;
 	struct icmp6hdr	_icmph, *ic;
-	struct ipv6hdr	_ciph, *cih;	/* The ip header contained
-					   within the ICMP */
-	struct ip_vs_iphdr ciph;
+	struct ip_vs_iphdr ciph = {.flags = 0, .fragoffs = 0};/*Contained IP */
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
-	unsigned int offset, verdict;
+	unsigned int offs_ciph, writable, verdict;
 
-	*related = 1;
+	struct ip_vs_iphdr iph_stack;
+	struct ip_vs_iphdr *iph = &iph_stack;
+	ip_vs_fill_iph_skb(AF_INET6, skb, iph);
 
-	/* reassemble IP fragments */
-	if (ipv6_hdr(skb)->nexthdr == IPPROTO_FRAGMENT) {
-		if (ip_vs_gather_frags_v6(skb, ip_vs_defrag_user(hooknum)))
-			return NF_STOLEN;
-	}
+	*related = 1;
 
-	iph = ipv6_hdr(skb);
-	offset = sizeof(struct ipv6hdr);
-	ic = skb_header_pointer(skb, offset, sizeof(_icmph), &_icmph);
+	ic = skb_header_pointer(skb, iph->len, sizeof(_icmph), &_icmph);
 	if (ic == NULL)
 		return NF_DROP;
 
-	IP_VS_DBG(12, "Incoming ICMPv6 (%d,%d) %pI6c->%pI6c\n",
-		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
-		  &iph->saddr, &iph->daddr);
-
 	/*
 	 * Work through seeing if this is for us.
 	 * These checks are supposed to be in an order that means easy
@@ -1501,40 +1484,51 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 		return NF_ACCEPT;
 	}
 
+	IP_VS_DBG(8, "Incoming ICMPv6 (%d,%d) %pI6c->%pI6c\n",
+		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
+		  &iph->saddr, &iph->daddr);
+
 	/* Now find the contained IP header */
-	offset += sizeof(_icmph);
-	cih = skb_header_pointer(skb, offset, sizeof(_ciph), &_ciph);
-	if (cih == NULL)
+	ciph.len = iph->len + sizeof(_icmph);
+	offs_ciph = ciph.len; /* Save ip header offset */
+	ip6h = skb_header_pointer(skb, ciph.len, sizeof(_ip6h), &_ip6h);
+	if (ip6h == NULL)
 		return NF_ACCEPT; /* The packet looks wrong, ignore */
+	ciph.saddr.in6 = ip6h->saddr; /* conn_in_get() handles reverse order */
+	ciph.daddr.in6 = ip6h->daddr;
+	/* skip possible IPv6 exthdrs of contained IPv6 packet */
+	ciph.protocol = ipv6_find_hdr(skb, &ciph.len, -1, &ciph.fragoffs, NULL);
+	if (ciph.protocol < 0)
+		return NF_ACCEPT; /* Contained IPv6 hdr looks wrong, ignore */
 
 	net = skb_net(skb);
-	pd = ip_vs_proto_data_get(net, cih->nexthdr);
+	pd = ip_vs_proto_data_get(net, ciph.protocol);
 	if (!pd)
 		return NF_ACCEPT;
 	pp = pd->pp;
 
-	/* Is the embedded protocol header present? */
-	/* TODO: we don't support fragmentation at the moment anyways */
-	if (unlikely(cih->nexthdr == IPPROTO_FRAGMENT && pp->dont_defrag))
+	/* Cannot handle fragmented embedded protocol */
+	if (ciph.fragoffs)
 		return NF_ACCEPT;
 
-	IP_VS_DBG_PKT(11, AF_INET6, pp, skb, offset,
+	IP_VS_DBG_PKT(11, AF_INET6, pp, skb, offs_ciph,
 		      "Checking incoming ICMPv6 for");
 
-	offset += sizeof(struct ipv6hdr);
-
-	ip_vs_fill_iphdr(AF_INET6, cih, &ciph);
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_in_get(AF_INET6, skb, &ciph, offset, 1);
+	cp = pp->conn_in_get(AF_INET6, skb, &ciph, ciph.len, 1);
 	if (!cp)
 		return NF_ACCEPT;
 
 	/* do the statistics and put it back */
 	ip_vs_in_stats(cp, skb);
-	if (IPPROTO_TCP == cih->nexthdr || IPPROTO_UDP == cih->nexthdr ||
-	    IPPROTO_SCTP == cih->nexthdr)
-		offset += 2 * sizeof(__u16);
-	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, offset, hooknum);
+
+	/* Need to mangle contained IPv6 header in ICMPv6 packet */
+	writable = ciph.len;
+	if (IPPROTO_TCP == ciph.protocol || IPPROTO_UDP == ciph.protocol ||
+	    IPPROTO_SCTP == ciph.protocol)
+		writable += 2 * sizeof(__u16); /* Also mangle ports */
+
+	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, writable, hooknum);
 
 	__ip_vs_conn_put(cp);
 
@@ -1570,7 +1564,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (unlikely((skb->pkt_type != PACKET_HOST &&
 		      hooknum != NF_INET_LOCAL_OUT) ||
 		     !skb_dst(skb))) {
-		ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+		ip_vs_fill_iph_skb(af, skb, &iph);
 		IP_VS_DBG_BUF(12, "packet type=%d proto=%d daddr=%s"
 			      " ignored in hook %u\n",
 			      skb->pkt_type, iph.protocol,
@@ -1582,7 +1576,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (!net_ipvs(net)->enable)
 		return NF_ACCEPT;
 
-	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_skb(af, skb, &iph);
 
 	/* Bad... Do not break raw sockets */
 	if (unlikely(skb->sk != NULL && hooknum == NF_INET_LOCAL_OUT &&
@@ -1602,7 +1596,6 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 
 			if (related)
 				return verdict;
-			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 		}
 	} else
 #endif
@@ -1612,7 +1605,6 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 
 			if (related)
 				return verdict;
-			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 		}
 
 	/* Protocol supported? */
@@ -1622,10 +1614,11 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	pp = pd->pp;
 	/*
 	 * Check if the packet belongs to an existing connection entry
+	 * Only sched first IPv6 fragment.
 	 */
 	cp = pp->conn_in_get(af, skb, &iph, iph.len, 0);
 
-	if (unlikely(!cp)) {
+	if (unlikely(!cp) && !iph.fragoffs) {
 		int v;
 
 		if (!pp->conn_schedule(af, skb, pd, &v, &cp))
@@ -1789,8 +1782,10 @@ ip_vs_forward_icmp_v6(unsigned int hooknum, struct sk_buff *skb,
 {
 	int r;
 	struct net *net;
+	struct ip_vs_iphdr iphdr;
 
-	if (ipv6_hdr(skb)->nexthdr != IPPROTO_ICMPV6)
+	ip_vs_fill_iph_skb(AF_INET6, skb, &iphdr);
+	if (iphdr.protocol != IPPROTO_ICMPV6)
 		return NF_ACCEPT;
 
 	/* ipvs enabled in this netns ? */
diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index 8b7dca9..7f3b0cc 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -215,7 +215,7 @@ ip_vs_dh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	struct ip_vs_dh_bucket *tbl;
 	struct ip_vs_iphdr iph;
 
-	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
 
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index df646cc..cbd3748 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -479,7 +479,7 @@ ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	struct ip_vs_dest *dest = NULL;
 	struct ip_vs_lblc_entry *en;
 
-	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
 
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 570e31e..161b679 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -649,7 +649,7 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	struct ip_vs_dest *dest = NULL;
 	struct ip_vs_lblcr_entry *en;
 
-	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
 
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
index 1aa5cac..ee4e2e3 100644
--- a/net/netfilter/ipvs/ip_vs_pe_sip.c
+++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
@@ -73,7 +73,7 @@ ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
 	const char *dptr;
 	int retc;
 
-	ip_vs_fill_iphdr(p->af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_skb(p->af, skb, &iph);
 
 	/* Only useful with UDP */
 	if (iph.protocol != IPPROTO_UDP)
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 9f3fb75..b903db6 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -18,7 +18,7 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	sctp_sctphdr_t *sh, _sctph;
 	struct ip_vs_iphdr iph;
 
-	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_skb(af, skb, &iph);
 
 	sh = skb_header_pointer(skb, iph.len, sizeof(_sctph), &_sctph);
 	if (sh == NULL)
@@ -72,12 +72,14 @@ sctp_snat_handler(struct sk_buff *skb,
 	struct sk_buff *iter;
 	__be32 crc32;
 
+	struct ip_vs_iphdr iph;
+	ip_vs_fill_iph_skb(cp->af, skb, &iph);
+	sctphoff = iph.len;
+
 #ifdef CONFIG_IP_VS_IPV6
-	if (cp->af == AF_INET6)
-		sctphoff = sizeof(struct ipv6hdr);
-	else
+	if (cp->af == AF_INET6 && iph.fragoffs)
+		return 1;
 #endif
-		sctphoff = ip_hdrlen(skb);
 
 	/* csum_check requires unshared skb */
 	if (!skb_make_writable(skb, sctphoff + sizeof(*sctph)))
@@ -116,12 +118,14 @@ sctp_dnat_handler(struct sk_buff *skb,
 	struct sk_buff *iter;
 	__be32 crc32;
 
+	struct ip_vs_iphdr iph;
+	ip_vs_fill_iph_skb(cp->af, skb, &iph);
+	sctphoff = iph.len;
+
 #ifdef CONFIG_IP_VS_IPV6
-	if (cp->af == AF_INET6)
-		sctphoff = sizeof(struct ipv6hdr);
-	else
+	if (cp->af == AF_INET6 && iph.fragoffs)
+		return 1;
 #endif
-		sctphoff = ip_hdrlen(skb);
 
 	/* csum_check requires unshared skb */
 	if (!skb_make_writable(skb, sctphoff + sizeof(*sctph)))
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index cd609cc..8a96069 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -40,7 +40,7 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	struct tcphdr _tcph, *th;
 	struct ip_vs_iphdr iph;
 
-	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_skb(af, skb, &iph);
 
 	th = skb_header_pointer(skb, iph.len, sizeof(_tcph), &_tcph);
 	if (th == NULL) {
@@ -136,12 +136,14 @@ tcp_snat_handler(struct sk_buff *skb,
 	int oldlen;
 	int payload_csum = 0;
 
+	struct ip_vs_iphdr iph;
+	ip_vs_fill_iph_skb(cp->af, skb, &iph);
+	tcphoff = iph.len;
+
 #ifdef CONFIG_IP_VS_IPV6
-	if (cp->af == AF_INET6)
-		tcphoff = sizeof(struct ipv6hdr);
-	else
+	if (cp->af == AF_INET6 && iph.fragoffs)
+		return 1;
 #endif
-		tcphoff = ip_hdrlen(skb);
 	oldlen = skb->len - tcphoff;
 
 	/* csum_check requires unshared skb */
@@ -216,12 +218,14 @@ tcp_dnat_handler(struct sk_buff *skb,
 	int oldlen;
 	int payload_csum = 0;
 
+	struct ip_vs_iphdr iph;
+	ip_vs_fill_iph_skb(cp->af, skb, &iph);
+	tcphoff = iph.len;
+
 #ifdef CONFIG_IP_VS_IPV6
-	if (cp->af == AF_INET6)
-		tcphoff = sizeof(struct ipv6hdr);
-	else
+	if (cp->af == AF_INET6 && iph.fragoffs)
+		return 1;
 #endif
-		tcphoff = ip_hdrlen(skb);
 	oldlen = skb->len - tcphoff;
 
 	/* csum_check requires unshared skb */
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 2fedb2d..d6f4eee 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -37,7 +37,7 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	struct udphdr _udph, *uh;
 	struct ip_vs_iphdr iph;
 
-	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_skb(af, skb, &iph);
 
 	uh = skb_header_pointer(skb, iph.len, sizeof(_udph), &_udph);
 	if (uh == NULL) {
@@ -133,12 +133,14 @@ udp_snat_handler(struct sk_buff *skb,
 	int oldlen;
 	int payload_csum = 0;
 
+	struct ip_vs_iphdr iph;
+	ip_vs_fill_iph_skb(cp->af, skb, &iph);
+	udphoff = iph.len;
+
 #ifdef CONFIG_IP_VS_IPV6
-	if (cp->af == AF_INET6)
-		udphoff = sizeof(struct ipv6hdr);
-	else
+	if (cp->af == AF_INET6 && iph.fragoffs)
+		return 1;
 #endif
-		udphoff = ip_hdrlen(skb);
 	oldlen = skb->len - udphoff;
 
 	/* csum_check requires unshared skb */
@@ -218,12 +220,14 @@ udp_dnat_handler(struct sk_buff *skb,
 	int oldlen;
 	int payload_csum = 0;
 
+	struct ip_vs_iphdr iph;
+	ip_vs_fill_iph_skb(cp->af, skb, &iph);
+	udphoff = iph.len;
+
 #ifdef CONFIG_IP_VS_IPV6
-	if (cp->af == AF_INET6)
-		udphoff = sizeof(struct ipv6hdr);
-	else
+	if (cp->af == AF_INET6 && iph.fragoffs)
+		return 1;
 #endif
-		udphoff = ip_hdrlen(skb);
 	oldlen = skb->len - udphoff;
 
 	/* csum_check requires unshared skb */
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 0512652..e331269 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -228,7 +228,7 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	struct ip_vs_sh_bucket *tbl;
 	struct ip_vs_iphdr iph;
 
-	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
 
 	IP_VS_DBG(6, "ip_vs_sh_schedule(): Scheduling...\n");
 
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 1060bd5..428de75 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -679,14 +679,15 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	struct rt6_info *rt;		/* Route to the other host */
 	int mtu;
 	int local;
+	struct ip_vs_iphdr iph;
 
 	EnterFunction(10);
+	ip_vs_fill_iph_skb(cp->af, skb, &iph);
 
 	/* check if it is a connection of no-client-port */
 	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT)) {
 		__be16 _pt, *p;
-		p = skb_header_pointer(skb, sizeof(struct ipv6hdr),
-				       sizeof(_pt), &_pt);
+		p = skb_header_pointer(skb, iph.len, sizeof(_pt), &_pt);
 		if (p == NULL)
 			goto tx_error;
 		ip_vs_conn_fill_cport(cp, *p);
diff --git a/net/netfilter/xt_ipvs.c b/net/netfilter/xt_ipvs.c
index bb10b07..3f9b8cd 100644
--- a/net/netfilter/xt_ipvs.c
+++ b/net/netfilter/xt_ipvs.c
@@ -67,7 +67,7 @@ ipvs_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		goto out;
 	}
 
-	ip_vs_fill_iphdr(family, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_skb(family, skb, &iph);
 
 	if (data->bitmask & XT_IPVS_PROTO)
 		if ((iph.protocol == data->l4proto) ^

