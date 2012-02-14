From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [PATCH 2/2] IPVS: IPv6 fragment handling added.
Date: Tue, 14 Feb 2012 13:48:09 +0100
Message-ID: <1329223689-19792-3-git-send-email-hans.schillstrom@ericsson.com>
References: <1329223689-19792-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1329223689-19792-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: kaber@trash.net, pablo@netfilter.org, hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

IPVS now supports fragmented packets, with support from
nf_conntrack_reasm.c

IPVS do like conntrack i.e. use the skb->nfct_reasm;
(i.e. when all fragments is collected, nf_ct_frag6_output() starts a "re-play"
of all fragments into the interrupted PREROUTING chain att prio -399 with nfct_reasm
pointing to the assembled packet.)

IPVS adds a new hook into prerouting chain at prio -100 to catch fragments,
and copy fw-mark and routing info from the first packet with an upper layer header.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/ip_vs.h             |   40 ++++++++++----
 net/netfilter/ipvs/Kconfig      |    7 +--
 net/netfilter/ipvs/ip_vs_conn.c |    2 +-
 net/netfilter/ipvs/ip_vs_core.c |  108 ++++++++++++++++++++++++++++-----------
 net/netfilter/ipvs/ip_vs_xmit.c |    2 +-
 5 files changed, 111 insertions(+), 48 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 4ad1f37a..48a1979 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -106,29 +106,45 @@ static inline struct net *seq_file_single_net(struct seq_file *seq)
 /* Connections' size value needed by ip_vs_ctl.c */
 extern int ip_vs_conn_tab_size;
 
+struct ip_vs_iphdr {
+	__u32 len;	/* IPv4 simply where L4 starts
+			   IPv6 where to find next header */
+	__u32 offs;	/* IPv6 frags: header offset in nfct_reasm skb */
+	__u16 fragoffs;
+	__s16 protocol;
+	__s32 flags;
+	union nf_inet_addr saddr;
+	union nf_inet_addr daddr;
+};
+
 #if defined(CONFIG_NF_DEFRAG_IPV6) || defined(CONFIG_NF_DEFRAG_IPV6_MODULE)
 static inline struct sk_buff *skb_nfct_reasm(const struct sk_buff *skb)
 {
 	return skb->nfct_reasm;
 }
+static inline void *ip_vs_skb_hdr_ptr(const struct sk_buff *skb, int offset,
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
+static inline void *ip_vs_skb_hdr_ptr(const struct sk_buff *skb, int offset,
+				      int len, void *buffer,
+				      const struct ip_vs_iphdr *ipvsh)
+{
+	return skb_header_pointer(skb, offset, len, buffer);
+}
 #endif
 
-struct ip_vs_iphdr {
-	__u32 len;	/* IPv4 simply where L4 starts
-			   IPv6 where to find next header */
-	__u32 offs;	/* IPv6 frags: header offset in nfct_reasm skb */
-	__u16 fragoffs;
-	__s16 protocol;
-	__s32 flags;
-	union nf_inet_addr saddr;
-	union nf_inet_addr daddr;
-};
-
 static inline void
 ip_vs_fill_ip4hdr(const void *nh, struct ip_vs_iphdr *iphdr)
 {
@@ -210,7 +226,7 @@ static inline const char *ip_vs_dbg_addr(int af, char *buf, size_t buf_len,
 	int len;
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6)
-		len = snprintf(&buf[*idx], buf_len - *idx, "[%pI6]",
+		len = snprintf(&buf[*idx], buf_len - *idx, "[%pI6c]",
 			       &addr->in6) + 1;
 	else
 #endif
diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index af4c0b8..4563b9e 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -28,12 +28,11 @@ if IP_VS
 config	IP_VS_IPV6
 	bool "IPv6 support for IPVS"
 	depends on IPV6 = y || IP_VS = IPV6
+	select IP6_NF_IPTABLES
 	---help---
-	  Add IPv6 support to IPVS. This is incomplete and might be dangerous.
+	  Add IPv6 support to IPVS. .
 
-	  See http://www.mindbasket.com/ipvs for more information.
-
-	  Say N if unsure.
+	  Say Y if unsure.
 
 config	IP_VS_DEBUG
 	bool "IP virtual server debugging"
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 550029d..6a61faa 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -313,7 +313,7 @@ ip_vs_conn_fill_param_proto(int af, const struct sk_buff *skb,
 	__be16 _ports[2], *pptr;
 	struct net *net = skb_net(skb);
 
-	pptr = skb_header_pointer(skb, iph->len, sizeof(_ports), _ports);
+	pptr = ip_vs_skb_hdr_ptr(skb, iph->len, sizeof(_ports), _ports, iph);
 	if (pptr == NULL)
 		return 1;
 
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 43b6eab..d35dc4a 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
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
@@ -919,12 +911,12 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 	union nf_inet_addr snet;
 
 	*related = 1;
-
-	ic = skb_header_pointer(skb, ipvsh->len, sizeof(_icmph), &_icmph);
+	ic = ip_vs_skb_hdr_ptr(skb, ipvsh->len, sizeof(_icmph), &_icmph, ipvsh);
 	if (ic == NULL)
 		return NF_DROP;
 
-	IP_VS_DBG(12, "Outgoing ICMPv6 (%d,%d) %pI6c->%pI6c\n",
+	IP_VS_DBG(12, "Outgoing ICMPv6 %s(%d,%d) %pI6c->%pI6c\n",
+		  ipvsh->flags & IP6T_FH_F_FRAG ? "Fragment " : "",
 		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
 		  &ipvsh->saddr, &ipvsh->daddr);
 
@@ -935,12 +927,16 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
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
+	/*
+	 * Fragment header that is before ICMP header tells us that:
+	 * it's not an error message since they can't be fragmented.
+	 */
+	if (ipvsh->flags & IP6T_FH_F_FRAG)
+		return NF_DROP;
 
 	/* Now find the contained IP header */
 	ipvsh->len += sizeof(_icmph);
@@ -1095,6 +1091,12 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	ip_vs_fill_iph_skb(af, skb, &iph);
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
+		if (!iph.fragoffs && skb_nfct_reasm(skb)) {
+			struct sk_buff *reasm = skb_nfct_reasm(skb);
+			/* Save route & fw mark to comming frags */
+			reasm->mark = skb->mark;
+			skb_dst_copy(reasm, skb);
+		}
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
 			int related;
 			int verdict = ip_vs_out_icmp_v6(skb, &related,
@@ -1102,7 +1104,6 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 
 			if (related)
 				return verdict;
-			ip_vs_fill_iph_skb(af, skb, &iph);
 		}
 	} else
 #endif
@@ -1112,7 +1113,6 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 
 			if (related)
 				return verdict;
-			ip_vs_fill_ip4hdr(skb_network_header(skb), &iph);
 		}
 
 	pd = ip_vs_proto_data_get(net, iph.protocol);
@@ -1145,8 +1145,8 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	     pp->protocol == IPPROTO_SCTP)) {
 		__be16 _ports[2], *pptr;
 
-		pptr = skb_header_pointer(skb, iph.len,
-					  sizeof(_ports), _ports);
+		pptr = ip_vs_skb_hdr_ptr(skb, iph.len,
+					 sizeof(_ports), _ports, &iph);
 		if (pptr == NULL)
 			return NF_ACCEPT;	/* Not for me */
 		if (ip_vs_lookup_real_service(net, af, iph.protocol,
@@ -1370,7 +1370,7 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 
 	*related = 1;
 
-	ic = skb_header_pointer(skb, iph->len, sizeof(_icmph), &_icmph);
+	ic = ip_vs_skb_hdr_ptr(skb, iph->len, sizeof(_icmph), &_icmph, iph);
 	if (ic == NULL)
 		return NF_DROP;
 
@@ -1385,12 +1385,16 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
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
+	/*
+	 * Fragment header that is before ICMP header tells us that:
+	 * it's not an error message since they can't be fragmented.
+	 */
+	if (iph->flags & IP6T_FH_F_FRAG)
+		return NF_DROP;
 
 	/* Now find the contained IP header */
 	ciph.len = iph->len + sizeof(_icmph);
@@ -1402,18 +1406,16 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 	ciph.daddr = iph->daddr;
 
 	net = skb_net(skb);
-	pd = ip_vs_proto_data_get(net, ciph.protocol);
-	if (!pd)
-		return NF_ACCEPT;
-	pp = pd->pp;
 
-	/* Is the embedded protocol header present?
-	 * If it's the second or later fragment we don't know what it is
+	/*
+	 * Is not the embedded protocol header present?
+	 * or it's the second or later fragment we don't know what it is
 	 * i.e. just let it through.
 	 */
-	if (ciph.fragoffs)
+	pd = ip_vs_proto_data_get(net, ciph.protocol);
+	if (!pd || ciph.fragoffs)
 		return NF_ACCEPT;
-
+	pp = pd->pp;
 	offset = ciph.len;
 	IP_VS_DBG_PKT(11, AF_INET6, pp, skb, offset,
 		      "Checking incoming ICMPv6 for");
@@ -1491,6 +1493,12 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
+		if (!iph.fragoffs && skb_nfct_reasm(skb)) {
+			struct sk_buff *reasm = skb_nfct_reasm(skb);
+			/* Save route & fw mark to coming frags. */
+			reasm->mark = skb->mark;
+			skb_dst_copy(reasm, skb);
+		}
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
 			int related;
 			int verdict = ip_vs_in_icmp_v6(skb, &related, hooknum,
@@ -1643,6 +1651,38 @@ ip_vs_local_request4(unsigned int hooknum, struct sk_buff *skb,
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
+	/* This is not a "replay" from nf_ct_frag6_output */
+	if (!reasm)
+		return NF_ACCEPT;
+
+	net = skb_net(skb);
+	if (!net_ipvs(net)->enable)
+		return NF_ACCEPT;
+
+	ipv6_find_hdr(skb, &iphdr.len, -1, &iphdr.fragoffs, NULL);
+	if (!iphdr.fragoffs)
+		return NF_ACCEPT;
+	/* Copy stored mark & dst from ip_vs_in / out */
+	skb->mark = reasm->mark;
+	skb_dst_copy(skb, reasm);
+
+	return NF_ACCEPT;
+}
+
+/*
  *	AF_INET6 handler in NF_INET_LOCAL_IN chain
  *	Schedule and forward packets from remote clients
  */
@@ -1781,6 +1821,14 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 		.priority	= 100,
 	},
 #ifdef CONFIG_IP_VS_IPV6
+	/* After mangle & nat fetch 2:nd fragment and following */
+	{
+		.hook		= ip_vs_preroute_frag6,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET6,
+		.hooknum	= NF_INET_PRE_ROUTING,
+		.priority	= NF_IP6_PRI_NAT_DST + 1,
+	},
 	/* After packet filtering, change source only for VS/NAT */
 	{
 		.hook		= ip_vs_reply6,
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 53155c1..552de49 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -638,7 +638,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	/* check if it is a connection of no-client-port */
-	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT)) {
+	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT && !iph->fragoffs)) {
 		__be16 _pt, *p;
 		p = skb_header_pointer(skb, iph->len, sizeof(_pt), &_pt);
 		if (p == NULL)
-- 
1.7.2.3

