From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH V4 5/7] ipvs: Complete IPv6 fragment handling for IPVS
Date: Wed, 26 Sep 2012 14:06:59 +0200
Message-ID: <20120926120646.24804.42743.stgit@dragon>
References: <20120926120534.24804.78415.stgit@dragon>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20120926120534.24804.78415.stgit@dragon>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Hans Schillstrom <hans@schillstrom.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

IPVS now supports fragmented packets, with support from nf_conntrack_reasm.c

Based on patch from: Hans Schillstrom.

IPVS do like conntrack i.e. use the skb->nfct_reasm
(i.e. when all fragments is collected, nf_ct_frag6_output()
starts a "re-play" of all fragments into the interrupted
PREROUTING chain at prio -399 (NF_IP6_PRI_CONNTRACK_DEFRAG+1)
with nfct_reasm pointing to the assembled packet.)

Notice, module nf_defrag_ipv6 must be loaded for this to work.
Report unhandled fragments, and recommend user to load nf_defrag_ipv6.

To handle fw-mark for fragments.  Add a new IPVS hook into prerouting
chain at prio -99 (NF_IP6_PRI_NAT_DST+1) to catch fragments, and copy
fw-mark info from the first packet with an upper layer header.

IPv6 fragment handling should be the last thing on the IPVS IPv6
missing support list.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>

---
V4:
 - Fix style problem: do not use assignment in if condition

V3:
 - In case of no nf_defrag_ipv6, second fragments could create
   strange conn entries, fix that.
 - Report unhandled fragments, and recommend user to load nf_defrag_ipv6.
 - Move ICMPv6 improvements to seperate patch

V2:
 - In ip_vs_in_icmp_v6() hint that &ciph.len can be updated
 - Add NULL pointer check in ip_vs_in_icmp_v6()

V1:
 - Fixed refcnt bug since last.


 include/net/ip_vs.h             |   39 +++++++++++++
 net/netfilter/ipvs/Kconfig      |    6 +-
 net/netfilter/ipvs/ip_vs_conn.c |    2 -
 net/netfilter/ipvs/ip_vs_core.c |  117 ++++++++++++++++++++++++++++++++-------
 net/netfilter/ipvs/ip_vs_xmit.c |   36 +++++++++---
 5 files changed, 164 insertions(+), 36 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 29265bf..98806b6 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -109,6 +109,7 @@ extern int ip_vs_conn_tab_size;
 struct ip_vs_iphdr {
 	__u32 len;	/* IPv4 simply where L4 starts
 			   IPv6 where L4 Transport Header starts */
+	__u32 thoff_reasm; /* Transport Header Offset in nfct_reasm skb */
 	__u16 fragoffs; /* IPv6 fragment offset, 0 if first frag (or not frag)*/
 	__s16 protocol;
 	__s32 flags;
@@ -116,6 +117,35 @@ struct ip_vs_iphdr {
 	union nf_inet_addr daddr;
 };
 
+/* Dependency to module: nf_defrag_ipv6 */
+#if defined(CONFIG_NF_DEFRAG_IPV6) || defined(CONFIG_NF_DEFRAG_IPV6_MODULE)
+static inline struct sk_buff *skb_nfct_reasm(const struct sk_buff *skb)
+{
+	return skb->nfct_reasm;
+}
+static inline void *frag_safe_skb_hp(const struct sk_buff *skb, int offset,
+				      int len, void *buffer,
+				      const struct ip_vs_iphdr *ipvsh)
+{
+	if (unlikely(ipvsh->fragoffs && skb_nfct_reasm(skb)))
+		return skb_header_pointer(skb_nfct_reasm(skb),
+					  ipvsh->thoff_reasm, len, buffer);
+
+	return skb_header_pointer(skb, offset, len, buffer);
+}
+#else
+static inline struct sk_buff *skb_nfct_reasm(const struct sk_buff *skb)
+{
+	return NULL;
+}
+static inline void *frag_safe_skb_hp(const struct sk_buff *skb, int offset,
+				      int len, void *buffer,
+				      const struct ip_vs_iphdr *ipvsh)
+{
+	return skb_header_pointer(skb, offset, len, buffer);
+}
+#endif
+
 static inline void
 ip_vs_fill_ip4hdr(const void *nh, struct ip_vs_iphdr *iphdr)
 {
@@ -141,12 +171,19 @@ ip_vs_fill_iph_skb(int af, const struct sk_buff *skb, struct ip_vs_iphdr *iphdr)
 			(struct ipv6hdr *)skb_network_header(skb);
 		iphdr->saddr.in6 = iph->saddr;
 		iphdr->daddr.in6 = iph->daddr;
-		/* ipv6_find_hdr() updates len, flags */
+		/* ipv6_find_hdr() updates len, flags, thoff_reasm */
+		iphdr->thoff_reasm = 0;
 		iphdr->len	 = 0;
 		iphdr->flags	 = 0;
 		iphdr->protocol  = ipv6_find_hdr(skb, &iphdr->len, -1,
 						 &iphdr->fragoffs,
 						 &iphdr->flags);
+		/* get proto from re-assembled packet and it's offset */
+		if (skb_nfct_reasm(skb))
+			iphdr->protocol = ipv6_find_hdr(skb_nfct_reasm(skb),
+							&iphdr->thoff_reasm,
+							-1, NULL, NULL);
+
 	} else
 #endif
 	{
diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index a97ae53..0c3b167 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -30,11 +30,9 @@ config	IP_VS_IPV6
 	depends on IPV6 = y || IP_VS = IPV6
 	select IP6_NF_IPTABLES
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
index 1548df9..d6c1c26 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -314,7 +314,7 @@ ip_vs_conn_fill_param_proto(int af, const struct sk_buff *skb,
 	__be16 _ports[2], *pptr;
 	struct net *net = skb_net(skb);
 
-	pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
+	pptr = frag_safe_skb_hp(skb, proto_off, sizeof(_ports), _ports, iph);
 	if (pptr == NULL)
 		return 1;
 
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 19c0842..19b89ff 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -402,8 +402,12 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	unsigned int flags;
 
 	*ignored = 1;
+
+	/*
+	 * IPv6 frags, only the first hit here.
+	 */
 	ip_vs_fill_iph_skb(svc->af, skb, &iph);
-	pptr = skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
+	pptr = frag_safe_skb_hp(skb, iph.len, sizeof(_ports), _ports, &iph);
 	if (pptr == NULL)
 		return NULL;
 
@@ -507,8 +511,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 #endif
 
 	ip_vs_fill_iph_skb(svc->af, skb, &iph);
-
-	pptr = skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
+	pptr = frag_safe_skb_hp(skb, iph.len, sizeof(_ports), _ports, &iph);
 	if (pptr == NULL) {
 		ip_vs_service_put(svc);
 		return NF_DROP;
@@ -654,14 +657,6 @@ static inline int ip_vs_gather_frags(struct sk_buff *skb, u_int32_t user)
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
@@ -939,8 +934,7 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 	ip_vs_fill_iph_skb(AF_INET6, skb, ipvsh);
 
 	*related = 1;
-
-	ic = skb_header_pointer(skb, ipvsh->len, sizeof(_icmph), &_icmph);
+	ic = frag_safe_skb_hp(skb, ipvsh->len, sizeof(_icmph), &_icmph, ipvsh);
 	if (ic == NULL)
 		return NF_DROP;
 
@@ -955,6 +949,11 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 		*related = 0;
 		return NF_ACCEPT;
 	}
+	/* Fragment header that is before ICMP header tells us that:
+	 * it's not an error message since they can't be fragmented.
+	 */
+	if (ipvsh->flags & IP6T_FH_F_FRAG)
+		return NF_DROP;
 
 	IP_VS_DBG(8, "Outgoing ICMPv6 (%d,%d) %pI6c->%pI6c\n",
 		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
@@ -1117,6 +1116,12 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
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
@@ -1124,7 +1129,6 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 
 			if (related)
 				return verdict;
-			ip_vs_fill_iph_skb(af, skb, &iph);
 		}
 	} else
 #endif
@@ -1134,7 +1138,6 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 
 			if (related)
 				return verdict;
-			ip_vs_fill_ip4hdr(skb_network_header(skb), &iph);
 		}
 
 	pd = ip_vs_proto_data_get(net, iph.protocol);
@@ -1167,8 +1170,8 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	     pp->protocol == IPPROTO_SCTP)) {
 		__be16 _ports[2], *pptr;
 
-		pptr = skb_header_pointer(skb, iph.len,
-					  sizeof(_ports), _ports);
+		pptr = frag_safe_skb_hp(skb, iph.len,
+					 sizeof(_ports), _ports, &iph);
 		if (pptr == NULL)
 			return NF_ACCEPT;	/* Not for me */
 		if (ip_vs_lookup_real_service(net, af, iph.protocol,
@@ -1468,7 +1471,7 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 
 	*related = 1;
 
-	ic = skb_header_pointer(skb, iph->len, sizeof(_icmph), &_icmph);
+	ic = frag_safe_skb_hp(skb, iph->len, sizeof(_icmph), &_icmph, iph);
 	if (ic == NULL)
 		return NF_DROP;
 
@@ -1483,6 +1486,11 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 		*related = 0;
 		return NF_ACCEPT;
 	}
+	/* Fragment header that is before ICMP header tells us that:
+	 * it's not an error message since they can't be fragmented.
+	 */
+	if (iph->flags & IP6T_FH_F_FRAG)
+		return NF_DROP;
 
 	IP_VS_DBG(8, "Incoming ICMPv6 (%d,%d) %pI6c->%pI6c\n",
 		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
@@ -1514,10 +1522,20 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 	IP_VS_DBG_PKT(11, AF_INET6, pp, skb, offs_ciph,
 		      "Checking incoming ICMPv6 for");
 
-	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_in_get(AF_INET6, skb, &ciph, ciph.len, 1);
+	/* The embedded headers contain source and dest in reverse order
+	 * if not from localhost
+	 */
+	cp = pp->conn_in_get(AF_INET6, skb, &ciph, ciph.len,
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
@@ -1590,6 +1608,12 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 
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
 			int verdict = ip_vs_in_icmp_v6(skb, &related, hooknum);
@@ -1614,13 +1638,16 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	pp = pd->pp;
 	/*
 	 * Check if the packet belongs to an existing connection entry
-	 * Only sched first IPv6 fragment.
 	 */
 	cp = pp->conn_in_get(af, skb, &iph, iph.len, 0);
 
 	if (unlikely(!cp) && !iph.fragoffs) {
+		/* No (second) fragments need to enter here, as nf_defrag_ipv6
+		 * replayed fragment zero will already have created the cp
+		 */
 		int v;
 
+		/* Schedule and create new connection entry into &cp */
 		if (!pp->conn_schedule(af, skb, pd, &v, &cp))
 			return v;
 	}
@@ -1629,6 +1656,14 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 		/* sorry, all this trouble for a no-hit :) */
 		IP_VS_DBG_PKT(12, af, pp, skb, 0,
 			      "ip_vs_in: packet continues traversal as normal");
+		if (iph.fragoffs && !skb_nfct_reasm(skb)) {
+			/* Fragment that couldn't be mapped to a conn entry
+			 * and don't have any pointer to a reasm skb
+			 * is missing module nf_defrag_ipv6
+			 */
+			IP_VS_DBG_RL("Unhandled frag, load nf_defrag_ipv6\n");
+			IP_VS_DBG_PKT(7, af, pp, skb, 0, "unhandled fragment");
+		}
 		return NF_ACCEPT;
 	}
 
@@ -1713,6 +1748,38 @@ ip_vs_local_request4(unsigned int hooknum, struct sk_buff *skb,
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
@@ -1851,6 +1918,14 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
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
index 428de75..a8b75fc 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -496,13 +496,15 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		     struct ip_vs_protocol *pp)
 {
 	struct rt6_info *rt;			/* Route to the other host */
-	struct ipv6hdr  *iph = ipv6_hdr(skb);
+	struct ip_vs_iphdr iph;
 	int    mtu;
 
 	EnterFunction(10);
+	ip_vs_fill_iph_skb(cp->af, skb, &iph);
 
-	if (!(rt = __ip_vs_get_out_rt_v6(skb, NULL, &iph->daddr, NULL, 0,
-					 IP_VS_RT_MODE_NON_LOCAL)))
+	rt = __ip_vs_get_out_rt_v6(skb, NULL, &iph.daddr.in6, NULL, 0,
+				   IP_VS_RT_MODE_NON_LOCAL);
+	if (!rt)
 		goto tx_error_icmp;
 
 	/* MTU checking */
@@ -513,7 +515,9 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 			skb->dev = net->loopback_dev;
 		}
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+		/* only send ICMP too big on first fragment */
+		if (!iph.fragoffs)
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		dst_release(&rt->dst);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error;
@@ -685,7 +689,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	ip_vs_fill_iph_skb(cp->af, skb, &iph);
 
 	/* check if it is a connection of no-client-port */
-	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT)) {
+	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT && !iph.fragoffs)) {
 		__be16 _pt, *p;
 		p = skb_header_pointer(skb, iph.len, sizeof(_pt), &_pt);
 		if (p == NULL)
@@ -735,7 +739,9 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 			skb->dev = net->loopback_dev;
 		}
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+		/* only send ICMP too big on first fragment */
+		if (!iph.fragoffs)
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		IP_VS_DBG_RL_PKT(0, AF_INET6, pp, skb, 0,
 				 "ip_vs_nat_xmit_v6(): frag needed for");
 		goto tx_error_put;
@@ -940,8 +946,10 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	unsigned int max_headroom;	/* The extra header space needed */
 	int    mtu;
 	int ret;
+	struct ip_vs_iphdr ipvsh;
 
 	EnterFunction(10);
+	ip_vs_fill_iph_skb(cp->af, skb, &ipvsh);
 
 	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6,
 					 &saddr, 1, (IP_VS_RT_MODE_LOCAL |
@@ -970,7 +978,9 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 			skb->dev = net->loopback_dev;
 		}
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+		/* only send ICMP too big on first fragment */
+		if (!ipvsh.fragoffs)
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error_put;
 	}
@@ -1116,8 +1126,10 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 {
 	struct rt6_info *rt;			/* Route to the other host */
 	int    mtu;
+	struct ip_vs_iphdr iph;
 
 	EnterFunction(10);
+	ip_vs_fill_iph_skb(cp->af, skb, &iph);
 
 	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
 					 0, (IP_VS_RT_MODE_LOCAL |
@@ -1136,7 +1148,9 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 			skb->dev = net->loopback_dev;
 		}
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+		/* only send ICMP too big on first fragment */
+		if (!iph.fragoffs)
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		dst_release(&rt->dst);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error;
@@ -1308,8 +1322,10 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	int rc;
 	int local;
 	int rt_mode;
+	struct ip_vs_iphdr iph;
 
 	EnterFunction(10);
+	ip_vs_fill_iph_skb(cp->af, skb, &iph);
 
 	/* The ICMP packet for VS/TUN, VS/DR and LOCALNODE will be
 	   forwarded directly here, because there is no need to
@@ -1372,7 +1388,9 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 			skb->dev = net->loopback_dev;
 		}
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+		/* only send ICMP too big on first fragment */
+		if (!iph.fragoffs)
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error_put;
 	}

