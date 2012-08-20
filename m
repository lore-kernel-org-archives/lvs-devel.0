From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH 3/3] ipvs: Complete IPv6 fragment handling for IPVS
Date: Mon, 20 Aug 2012 15:08:45 +0200
Message-ID: <20120820130845.1509.80511.stgit@dragon>
References: <20120820130732.1509.13080.stgit@dragon>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120820130732.1509.13080.stgit@dragon>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, Hans Schillstrom <hans@schillstrom.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org

IPVS now supports fragmented packets, with support from nf_conntrack_reasm.c

Based on patch from: Hans Schillstrom.

IPVS do like conntrack i.e. use the skb->nfct_reasm
(i.e. when all fragments is collected, nf_ct_frag6_output()
starts a "re-play" of all fragments into the interrupted
PREROUTING chain at prio -399 (NF_IP6_PRI_CONNTRACK_DEFRAG+1)
with nfct_reasm pointing to the assembled packet.)

Notice, module nf_defrag_ipv6 must be loaded for this to work.

IPVS adds a new hook into prerouting chain at prio
-99 (NF_IP6_PRI_NAT_DST+1) to catch fragments, and copy fw-mark
info from the first packet with an upper layer header.

Also, for IPv6, handle all ICMPv6 NONE Informational Messages (via
ICMPV6_INFOMSG_MASK).  This actually only extend our handling to
type ICMPV6_PARAMPROB (Parameter Problem), and future types.

- Fixed refcnt bug since last.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
---

 include/net/ip_vs.h             |   16 ++++
 net/netfilter/ipvs/Kconfig      |    7 +-
 net/netfilter/ipvs/ip_vs_conn.c |    2 
 net/netfilter/ipvs/ip_vs_core.c |  173 ++++++++++++++++++++++++++++-----------
 net/netfilter/ipvs/ip_vs_xmit.c |   24 ++++-
 5 files changed, 161 insertions(+), 61 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 8d5920f..50f377e 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -123,11 +123,27 @@ static inline struct sk_buff *skb_nfct_reasm(const struct sk_buff *skb)
 {
 	return skb->nfct_reasm;
 }
+static inline void *frag_safe_skb_hp(const struct sk_buff *skb, int offset,
+				      int len, void *buffer,
+				      const struct ip_vs_iphdr *ipvsh)
+{
+	if (unlikely(ipvsh->fragoffs && skb_nfct_reasm(skb)))
+		return skb_header_pointer(skb_nfct_reasm(skb), ipvsh->offs,
+					  len, buffer);
+
+	return skb_header_pointer(skb, offset, len, buffer);
+}
 #else
 static inline struct sk_buff *skb_nfct_reasm(const struct sk_buff *skb)
 {
 	return NULL;
 }
+static inline void *frag_safe_skb_hp(const struct sk_buff *skb, int offset,
+				      int len, void *buffer,
+				      const struct ip_vs_iphdr *ipvsh)
+{
+	return skb_header_pointer(skb, offset, len, buffer);
+}
 #endif
 
 static inline void
diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index 8b2cffd..0c3b167 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -28,12 +28,11 @@ if IP_VS
 config	IP_VS_IPV6
 	bool "IPv6 support for IPVS"
 	depends on IPV6 = y || IP_VS = IPV6
+	select IP6_NF_IPTABLES
 	---help---
-	  Add IPv6 support to IPVS. This is incomplete and might be dangerous.
+	  Add IPv6 support to IPVS.
 
-	  See http://www.mindbasket.com/ipvs for more information.
-
-	  Say N if unsure.
+	  Say Y if unsure.
 
 config	IP_VS_DEBUG
 	bool "IP virtual server debugging"
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index a00db99..30e764a 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -313,7 +313,7 @@ ip_vs_conn_fill_param_proto(int af, const struct sk_buff *skb,
 	__be16 _ports[2], *pptr;
 	struct net *net = skb_net(skb);
 
-	pptr = skb_header_pointer(skb, iph->len, sizeof(_ports), _ports);
+	pptr = frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports, iph);
 	if (pptr == NULL)
 		return 1;
 
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 32c69ed..9f2e167 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -402,7 +402,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	/*
 	 * IPv6 frags, only the first hit here.
 	 */
-	pptr = skb_header_pointer(skb, iph->len, sizeof(_ports), _ports);
+	pptr = frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports, iph);
 	if (pptr == NULL)
 		return NULL;
 
@@ -505,7 +505,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 	int unicast;
 #endif
 
-	pptr = skb_header_pointer(skb, iph->len, sizeof(_ports), _ports);
+	pptr = frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports, iph);
 	if (pptr == NULL) {
 		ip_vs_service_put(svc);
 		return NF_DROP;
@@ -651,14 +651,6 @@ static inline int ip_vs_gather_frags(struct sk_buff *skb, u_int32_t user)
 	return err;
 }
 
-#ifdef CONFIG_IP_VS_IPV6
-static inline int ip_vs_gather_frags_v6(struct sk_buff *skb, u_int32_t user)
-{
-	/* TODO IPv6: Find out what to do here for IPv6 */
-	return 0;
-}
-#endif
-
 static int ip_vs_route_me_harder(int af, struct sk_buff *skb)
 {
 #ifdef CONFIG_IP_VS_IPV6
@@ -729,10 +721,22 @@ void ip_vs_nat_icmp_v6(struct sk_buff *skb, struct ip_vs_protocol *pp,
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
+
+	if (!skb_make_writable(skb, offs + sizeof(__u32)))
+		return;
 
 	if (inout) {
 		iph->saddr = cp->vaddr.in6;
@@ -743,10 +747,13 @@ void ip_vs_nat_icmp_v6(struct sk_buff *skb, struct ip_vs_protocol *pp,
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
@@ -919,12 +926,12 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 	union nf_inet_addr snet;
 
 	*related = 1;
-
-	ic = skb_header_pointer(skb, ipvsh->len, sizeof(_icmph), &_icmph);
+	ic = frag_safe_skb_hp(skb, ipvsh->len, sizeof(_icmph), &_icmph, ipvsh);
 	if (ic == NULL)
 		return NF_DROP;
 
-	IP_VS_DBG(12, "Outgoing ICMPv6 (%d,%d) %pI6c->%pI6c\n",
+	IP_VS_DBG(12, "Outgoing ICMPv6 %s(%d,%d) %pI6c->%pI6c\n",
+		  ipvsh->flags & IP6T_FH_F_FRAG ? "Fragment " : "",
 		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
 		  &ipvsh->saddr, &ipvsh->daddr);
 
@@ -935,12 +942,15 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 	 * this means that some packets will manage to get a long way
 	 * down this stack and then be rejected, but that's life.
 	 */
-	if ((ic->icmp6_type != ICMPV6_DEST_UNREACH) &&
-	    (ic->icmp6_type != ICMPV6_PKT_TOOBIG) &&
-	    (ic->icmp6_type != ICMPV6_TIME_EXCEED)) {
+	if (ic->icmp6_type & ICMPV6_INFOMSG_MASK) {
 		*related = 0;
 		return NF_ACCEPT;
 	}
+	/* Fragment header that is before ICMP header tells us that:
+	 * it's not an error message since they can't be fragmented.
+	 */
+	if (ipvsh->flags & IP6T_FH_F_FRAG)
+		return NF_DROP;
 
 	/* Now find the contained IP header */
 	ipvsh->len += sizeof(_icmph);
@@ -1095,6 +1105,12 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	ip_vs_fill_iph_skb(af, skb, &iph);
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
+		if (!iph.fragoffs && skb_nfct_reasm(skb)) {
+			struct sk_buff *reasm = skb_nfct_reasm(skb);
+			/* Save fw mark for coming frags */
+			reasm->ipvs_property = 1;
+			reasm->mark = skb->mark;
+		}
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
 			int related;
 			int verdict = ip_vs_out_icmp_v6(skb, &related,
@@ -1102,7 +1118,6 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 
 			if (related)
 				return verdict;
-			ip_vs_fill_iph_skb(af, skb, &iph);
 		}
 	} else
 #endif
@@ -1112,7 +1127,6 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 
 			if (related)
 				return verdict;
-			ip_vs_fill_ip4hdr(skb_network_header(skb), &iph);
 		}
 
 	pd = ip_vs_proto_data_get(net, iph.protocol);
@@ -1145,8 +1159,8 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	     pp->protocol == IPPROTO_SCTP)) {
 		__be16 _ports[2], *pptr;
 
-		pptr = skb_header_pointer(skb, iph.len,
-					  sizeof(_ports), _ports);
+		pptr = frag_safe_skb_hp(skb, iph.len,
+					 sizeof(_ports), _ports, &iph);
 		if (pptr == NULL)
 			return NF_ACCEPT;	/* Not for me */
 		if (ip_vs_lookup_real_service(net, af, iph.protocol,
@@ -1432,20 +1446,21 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 			    unsigned int hooknum, struct ip_vs_iphdr *iph)
 {
 	struct net *net = NULL;
+	const struct ipv6hdr _ip6h, *ip6h;
 	struct icmp6hdr	_icmph, *ic;
 	struct ip_vs_iphdr ciph;
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
-	unsigned int offset, verdict;
+	unsigned int offs_ciph, verdict;
 
 	*related = 1;
 
-	ic = skb_header_pointer(skb, iph->len, sizeof(_icmph), &_icmph);
+	ic = frag_safe_skb_hp(skb, iph->len, sizeof(_icmph), &_icmph, iph);
 	if (ic == NULL)
 		return NF_DROP;
 
-	IP_VS_DBG(12, "Incoming ICMPv6 (%d,%d) %pI6c->%pI6c\n",
+	IP_VS_DBG(12, "Incoming ICMPv6 %d(%d,%d) %pI6c->%pI6c\n", hooknum,
 		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
 		  &iph->saddr, &iph->daddr);
 
@@ -1456,51 +1471,64 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 	 * this means that some packets will manage to get a long way
 	 * down this stack and then be rejected, but that's life.
 	 */
-	if ((ic->icmp6_type != ICMPV6_DEST_UNREACH) &&
-	    (ic->icmp6_type != ICMPV6_PKT_TOOBIG) &&
-	    (ic->icmp6_type != ICMPV6_TIME_EXCEED)) {
+	if (ic->icmp6_type & ICMPV6_INFOMSG_MASK) {
 		*related = 0;
 		return NF_ACCEPT;
 	}
+	/* Fragment header that is before ICMP header tells us that:
+	 * it's not an error message since they can't be fragmented.
+	 */
+	if (iph->flags & IP6T_FH_F_FRAG)
+		return NF_DROP;
 
 	/* Now find the contained IP header */
 	ciph.len = iph->len + sizeof(_icmph);
 	ciph.flags = 0;
 	ciph.fragoffs = 0;
+	offs_ciph = ciph.len;	/* Save ip header offset */
+	ip6h = skb_header_pointer(skb, ciph.len, sizeof(_ip6h),
+				 (void *)&_ip6h);
 	ciph.protocol = ipv6_find_hdr(skb, &ciph.len, -1, &ciph.fragoffs,
 				      &ciph.flags);
-	ciph.saddr = iph->saddr;	/* con_in_get() handles reverse order */
-	ciph.daddr = iph->daddr;
+	ciph.saddr.in6 = ip6h->saddr;	/* con_in_get() handles reverse order */
+	ciph.daddr.in6 = ip6h->daddr;
 
 	net = skb_net(skb);
 	pd = ip_vs_proto_data_get(net, ciph.protocol);
-	if (!pd)
-		return NF_ACCEPT;
-	pp = pd->pp;
 
-	/* Is the embedded protocol header present?
-	 * If it's the second or later fragment we don't know what it is
+	/* Is not the embedded protocol header present?
+	 * or it's the second or later fragment we don't know what it is
 	 * i.e. just let it through.
 	 */
-	if (ciph.fragoffs)
+	if (!pd || ciph.fragoffs)
 		return NF_ACCEPT;
+	pp = pd->pp;
 
-	offset = ciph.len;
-	IP_VS_DBG_PKT(11, AF_INET6, pp, skb, offset,
+	IP_VS_DBG_PKT(11, AF_INET6, pp, skb, offs_ciph,
 		      "Checking incoming ICMPv6 for");
 
-	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_in_get(AF_INET6, skb, &ciph, 1);
+	/* The embedded headers contain source and dest in reverse order
+	 * if not from localhost
+	 */
+	cp = pp->conn_in_get(AF_INET6, skb, &ciph,
+			     (hooknum == NF_INET_LOCAL_OUT) ? 0 : 1);
+
 	if (!cp)
 		return NF_ACCEPT;
+	/* VS/TUN, VS/DR and LOCALNODE just let it go */
+	if ((hooknum == NF_INET_LOCAL_OUT) &&
+	    (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)) {
+		__ip_vs_conn_put(cp);
+		return NF_ACCEPT;
+	}
 
 	/* do the statistics and put it back */
 	ip_vs_in_stats(cp, skb);
 	if (IPPROTO_TCP == ciph.protocol || IPPROTO_UDP == ciph.protocol ||
 	    IPPROTO_SCTP == ciph.protocol)
-		offset = ciph.len + (2 * sizeof(__u16));
+		offs_ciph = ciph.len;
 
-	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, offset, hooknum, &ciph);
+	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, offs_ciph, hooknum, &ciph);
 
 	__ip_vs_conn_put(cp);
 
@@ -1562,6 +1590,12 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
+		if (!iph.fragoffs && skb_nfct_reasm(skb)) {
+			struct sk_buff *reasm = skb_nfct_reasm(skb);
+			/* Save fw mark for coming frags. */
+			reasm->ipvs_property = 1;
+			reasm->mark = skb->mark;
+		}
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
 			int related;
 			int verdict = ip_vs_in_icmp_v6(skb, &related, hooknum,
@@ -1587,12 +1621,12 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	pp = pd->pp;
 	/*
 	 * Check if the packet belongs to an existing connection entry
-	 * Only sched first IPv6 fragment.
 	 */
 	cp = pp->conn_in_get(af, skb, &iph, 0);
-	if (unlikely(!cp) && !iph.fragoffs) {
+	if (unlikely(!cp)) {
 		int v;
 
+		/* Schedule and create new connection entry into &cp */
 		if (!pp->conn_schedule(af, skb, pd, &v, &cp, &iph))
 			return v;
 	}
@@ -1685,6 +1719,39 @@ ip_vs_local_request4(unsigned int hooknum, struct sk_buff *skb,
 #ifdef CONFIG_IP_VS_IPV6
 
 /*
+ * AF_INET6 fragment handling
+ * Copy info from first fragment, to the rest of them.
+ */
+static unsigned int
+ip_vs_preroute_frag6(unsigned int hooknum, struct sk_buff *skb,
+		     const struct net_device *in,
+		     const struct net_device *out,
+		     int (*okfn)(struct sk_buff *))
+{
+	struct ip_vs_iphdr iphdr  = { .len = 0, .flags = 0, };
+	struct sk_buff *reasm = skb_nfct_reasm(skb);
+	struct net *net;
+
+	/* Skip if not a "replay" from nf_ct_frag6_output or first fragment.
+	 * ipvs_property is set when checking first fragment
+	 * in ip_vs_in() and ip_vs_out().
+	 */
+	if (reasm)
+		IP_VS_DBG(2, "Fragment recv prop:%d\n", reasm->ipvs_property);
+	if (!reasm || !reasm->ipvs_property)
+		return NF_ACCEPT;
+
+	net = skb_net(skb);
+	if (!net_ipvs(net)->enable)
+		return NF_ACCEPT;
+
+	/* Copy stored fw mark, saved in ip_vs_{in,out} */
+	skb->mark = reasm->mark;
+
+	return NF_ACCEPT;
+}
+
+/*
  *	AF_INET6 handler in NF_INET_LOCAL_IN chain
  *	Schedule and forward packets from remote clients
  */
@@ -1823,6 +1890,14 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 		.priority	= 100,
 	},
 #ifdef CONFIG_IP_VS_IPV6
+	/* After mangle & nat fetch 2:nd fragment and following */
+	{
+		.hook		= ip_vs_preroute_frag6,
+		.owner		= THIS_MODULE,
+		.pf		= NFPROTO_IPV6,
+		.hooknum	= NF_INET_PRE_ROUTING,
+		.priority	= NF_IP6_PRI_NAT_DST + 1,
+	},
 	/* After packet filtering, change source only for VS/NAT */
 	{
 		.hook		= ip_vs_reply6,
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 925cca2..422b92f 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -497,7 +497,9 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 			skb->dev = net->loopback_dev;
 		}
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+		/* only send ICMP too big on first fragment */
+		if (!iph->fragoffs)
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		dst_release(&rt->dst);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error;
@@ -667,7 +669,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	/* check if it is a connection of no-client-port */
-	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT)) {
+	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT && !iph->fragoffs)) {
 		__be16 _pt, *p;
 		p = skb_header_pointer(skb, iph->len, sizeof(_pt), &_pt);
 		if (p == NULL)
@@ -693,7 +695,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 		if (ct && !nf_ct_is_untracked(ct)) {
 			IP_VS_DBG_RL_PKT(10, AF_INET6, pp, skb, 0,
-					 "ip_vs_nat_xmit_v6(): "
+					 "ip_vs_nat_xmit_v6(): "\
 					 "stopping DNAT to local address");
 			goto tx_error_put;
 		}
@@ -717,7 +719,9 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 			skb->dev = net->loopback_dev;
 		}
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+		/* only send ICMP too big on first fragment */
+		if (!iph->fragoffs)
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		IP_VS_DBG_RL_PKT(0, AF_INET6, pp, skb, 0,
 				 "ip_vs_nat_xmit_v6(): frag needed for");
 		goto tx_error_put;
@@ -952,7 +956,9 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 			skb->dev = net->loopback_dev;
 		}
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+		/* only send ICMP too big on first fragment */
+		if (!ipvsh->fragoffs)
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error_put;
 	}
@@ -1118,7 +1124,9 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 			skb->dev = net->loopback_dev;
 		}
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+		/* only send ICMP too big on first fragment */
+		if (!iph->fragoffs)
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		dst_release(&rt->dst);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error;
@@ -1356,7 +1364,9 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 			skb->dev = net->loopback_dev;
 		}
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+		/* only send ICMP too big on first fragment */
+		if (!iph->fragoffs)
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error_put;
 	}

