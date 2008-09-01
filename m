From: Julius Volz <juliusv@google.com>
Subject: [PATCHv2 RFC 14/25] IPVS: Add and bind IPv6 xmit functions
Date: Mon,  1 Sep 2008 14:56:11 +0200
Message-ID: <1220273782-19901-15-git-send-email-juliusv@google.com>
References: <1220273782-19901-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220273824; bh=upn4KGQbBV9li2vNo6xcLHPCm0g=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=G64C63vix/AP3mQQ1NO5yPvX81xITfnRk4QAaSeh
	bYrBMMHanUy6IfdiROKm/wIdpVV4FQKrVkICuFRhtv1l/Q==
In-Reply-To: <1220273782-19901-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Add xmit functions for IPv6. Also add the already needed __ip_vs_get_out_rt_v6()
to ip_vs_core.c. Bind the new xmit functions to v6 connections.

Signed-off-by: Julius Volz <juliusv@google.com>

 4 files changed, 462 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 7de9eb4..a7eda08 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -855,6 +855,18 @@ extern int ip_vs_icmp_xmit
 (struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp, int offset);
 extern void ip_vs_dst_reset(struct ip_vs_dest *dest);
 
+#ifdef CONFIG_IP_VS_IPV6
+extern int ip_vs_bypass_xmit_v6
+(struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
+extern int ip_vs_nat_xmit_v6
+(struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
+extern int ip_vs_tunnel_xmit_v6
+(struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
+extern int ip_vs_dr_xmit_v6
+(struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
+extern int ip_vs_icmp_xmit_v6
+(struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp, int offset);
+#endif
 
 /*
  *	This is a simple mechanism to ignore packets when
@@ -899,7 +911,12 @@ static inline char ip_vs_fwd_tag(struct ip_vs_conn *cp)
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
 
diff --git a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
index 664b42c..814d416 100644
--- a/net/ipv4/ipvs/ip_vs_conn.c
+++ b/net/ipv4/ipvs/ip_vs_conn.c
@@ -388,6 +388,33 @@ static inline void ip_vs_bind_xmit(struct ip_vs_conn *cp)
 	}
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static inline void ip_vs_bind_xmit_v6(struct ip_vs_conn *cp)
+{
+	switch (IP_VS_FWD_METHOD(cp)) {
+	case IP_VS_CONN_F_MASQ:
+		cp->packet_xmit = ip_vs_nat_xmit_v6;
+		break;
+
+	case IP_VS_CONN_F_TUNNEL:
+		cp->packet_xmit = ip_vs_tunnel_xmit_v6;
+		break;
+
+	case IP_VS_CONN_F_DROUTE:
+		cp->packet_xmit = ip_vs_dr_xmit_v6;
+		break;
+
+	case IP_VS_CONN_F_LOCALNODE:
+		cp->packet_xmit = ip_vs_null_xmit;
+		break;
+
+	case IP_VS_CONN_F_BYPASS:
+		cp->packet_xmit = ip_vs_bypass_xmit_v6;
+		break;
+	}
+}
+#endif
+
 
 static inline int ip_vs_dest_totalconns(struct ip_vs_dest *dest)
 {
@@ -693,7 +720,12 @@ ip_vs_conn_new(int af, int proto, const union nf_inet_addr *caddr, __be16 cport,
 	cp->timeout = 3*HZ;
 
 	/* Bind its packet transmitter */
-	ip_vs_bind_xmit(cp);
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		ip_vs_bind_xmit_v6(cp);
+	else
+#endif
+		ip_vs_bind_xmit(cp);
 
 	if (unlikely(pp && atomic_read(&pp->appcnt)))
 		ip_vs_bind_app(cp, pp);
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 2d5a433..d6f5bf9 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -570,6 +570,49 @@ void ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
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
diff --git a/net/ipv4/ipvs/ip_vs_xmit.c b/net/ipv4/ipvs/ip_vs_xmit.c
index 7bebd5c..15c59aa 100644
--- a/net/ipv4/ipvs/ip_vs_xmit.c
+++ b/net/ipv4/ipvs/ip_vs_xmit.c
@@ -269,6 +269,68 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	return NF_STOLEN;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+int
+ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
+		     struct ip_vs_protocol *pp)
+{
+	struct rt6_info *rt;			/* Route to the other host */
+	struct ipv6hdr  *iph = ipv6_hdr(skb);
+	int    mtu;
+	struct flowi fl = {
+		.oif = 0,
+		.nl_u = {
+			.ip6_u = {
+				.daddr = iph->daddr,
+				.saddr = { .s6_addr32 = {0, 0, 0, 0} }, } },
+	};
+
+	EnterFunction(10);
+
+	if (!(rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl))) {
+		IP_VS_DBG_RL("ip_vs_bypass_xmit_v6(): ip6_route_output error, "
+			     "dest: " NIP6_FMT "\n", NIP6(iph->daddr));
+		goto tx_error_icmp;
+	}
+
+	/* MTU checking */
+	mtu = dst_mtu(&rt->u.dst);
+	if (skb->len > mtu) {
+		dst_release(&rt->u.dst);
+		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
+		IP_VS_DBG_RL("ip_vs_bypass_xmit_v6(): frag needed\n");
+		goto tx_error;
+	}
+
+	/*
+	 * Call ip_send_check because we are not sure it is called
+	 * after ip_defrag. Is copy-on-write needed?
+	 */
+	if (unlikely((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)) {
+		dst_release(&rt->u.dst);
+		return NF_STOLEN;
+	}
+
+	/* drop old route */
+	dst_release(skb->dst);
+	skb->dst = &rt->u.dst;
+
+	/* Another hack: avoid icmp_send in ip_fragment */
+	skb->local_df = 1;
+
+	IP_VS_XMIT(PF_INET6, skb, rt);
+
+	LeaveFunction(10);
+	return NF_STOLEN;
+
+ tx_error_icmp:
+	dst_link_failure(skb);
+ tx_error:
+	kfree_skb(skb);
+	LeaveFunction(10);
+	return NF_STOLEN;
+}
+#endif
 
 /*
  *      NAT transmitter (only for outside-to-inside nat forwarding)
@@ -348,6 +410,80 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	goto tx_error;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+int
+ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
+	          struct ip_vs_protocol *pp)
+{
+	struct rt6_info *rt;		/* Route to the other host */
+	int mtu;
+
+	EnterFunction(10);
+
+	/* check if it is a connection of no-client-port */
+	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT)) {
+		__be16 _pt, *p;
+		p = skb_header_pointer(skb, sizeof(struct ipv6hdr), sizeof(_pt), &_pt);
+		if (p == NULL)
+			goto tx_error;
+		ip_vs_conn_fill_cport(cp, *p);
+		IP_VS_DBG(10, "filled cport=%d\n", ntohs(*p));
+	}
+
+	if (!(rt = __ip_vs_get_out_rt_v6(cp)))
+		goto tx_error_icmp;
+
+	/* MTU checking */
+	mtu = dst_mtu(&rt->u.dst);
+	if (skb->len > mtu) {
+		dst_release(&rt->u.dst);
+		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
+		IP_VS_DBG_RL_PKT(0, pp, skb, 0, "ip_vs_nat_xmit_v6(): frag needed for");
+		goto tx_error;
+	}
+
+	/* copy-on-write the packet before mangling it */
+	if (!skb_make_writable(skb, sizeof(struct ipv6hdr)))
+		goto tx_error_put;
+
+	if (skb_cow(skb, rt->u.dst.dev->hard_header_len))
+		goto tx_error_put;
+
+	/* drop old route */
+	dst_release(skb->dst);
+	skb->dst = &rt->u.dst;
+
+	/* mangle the packet */
+	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp))
+		goto tx_error;
+	ipv6_hdr(skb)->daddr = cp->daddr.in6;
+
+	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");
+
+	/* FIXME: when application helper enlarges the packet and the length
+	   is larger than the MTU of outgoing device, there will be still
+	   MTU problem. */
+
+	/* Another hack: avoid icmp_send in ip_fragment */
+	skb->local_df = 1;
+
+	IP_VS_XMIT(PF_INET6, skb, rt);
+
+	LeaveFunction(10);
+	return NF_STOLEN;
+
+  tx_error_icmp:
+	dst_link_failure(skb);
+  tx_error:
+	LeaveFunction(10);
+	kfree_skb(skb);
+	return NF_STOLEN;
+  tx_error_put:
+	dst_release(&rt->u.dst);
+	goto tx_error;
+}
+#endif
+
 
 /*
  *   IP Tunneling transmitter
@@ -479,6 +615,111 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	return NF_STOLEN;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+int
+ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
+		     struct ip_vs_protocol *pp)
+{
+	struct rt6_info *rt;			/* Route to the other host */
+	struct net_device *tdev;		/* Device to other host */
+	struct ipv6hdr  *old_iph = ipv6_hdr(skb);
+	sk_buff_data_t old_transport_header = skb->transport_header;
+	struct ipv6hdr  *iph;			/* Our new IP header */
+	unsigned int max_headroom;		/* The extra header space needed */
+	int    mtu;
+
+	EnterFunction(10);
+
+	if (skb->protocol != htons(ETH_P_IPV6)) {
+		IP_VS_DBG_RL("ip_vs_tunnel_xmit_v6(): protocol error, "
+			     "ETH_P_IPV6: %d, skb protocol: %d\n",
+			     htons(ETH_P_IPV6), skb->protocol);
+		goto tx_error;
+	}
+
+	if (!(rt = __ip_vs_get_out_rt_v6(cp)))
+		goto tx_error_icmp;
+
+	tdev = rt->u.dst.dev;
+
+	mtu = dst_mtu(&rt->u.dst) - sizeof(struct ipv6hdr);
+	/* TODO IPv6: do we need this check in IPv6? */
+	if (mtu < 1280) {
+		dst_release(&rt->u.dst);
+		IP_VS_DBG_RL("ip_vs_tunnel_xmit_v6(): mtu less than 1280\n");
+		goto tx_error;
+	}
+	if (skb->dst)
+		skb->dst->ops->update_pmtu(skb->dst, mtu);
+
+	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr)) {
+		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
+		dst_release(&rt->u.dst);
+		IP_VS_DBG_RL("ip_vs_tunnel_xmit_v6(): frag needed\n");
+		goto tx_error;
+	}
+
+	/*
+	 * Okay, now see if we can stuff it in the buffer as-is.
+	 */
+	max_headroom = LL_RESERVED_SPACE(tdev) + sizeof(struct ipv6hdr);
+
+	if (skb_headroom(skb) < max_headroom
+	    || skb_cloned(skb) || skb_shared(skb)) {
+		struct sk_buff *new_skb =
+			skb_realloc_headroom(skb, max_headroom);
+		if (!new_skb) {
+			dst_release(&rt->u.dst);
+			kfree_skb(skb);
+			IP_VS_ERR_RL("ip_vs_tunnel_xmit_v6(): no memory\n");
+			return NF_STOLEN;
+		}
+		kfree_skb(skb);
+		skb = new_skb;
+		old_iph = ipv6_hdr(skb);
+	}
+
+	skb->transport_header = old_transport_header;
+
+	skb_push(skb, sizeof(struct ipv6hdr));
+	skb_reset_network_header(skb);
+	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
+
+	/* drop old route */
+	dst_release(skb->dst);
+	skb->dst = &rt->u.dst;
+
+	/*
+	 *	Push down and install the IPIP header.
+	 */
+	iph			=	ipv6_hdr(skb);
+	iph->version		=	6;
+	iph->nexthdr		=	IPPROTO_IPV6;
+	iph->payload_len	=	old_iph->payload_len + sizeof(old_iph);
+	iph->priority		=	old_iph->priority;
+	memset(&iph->flow_lbl, 0, sizeof(iph->flow_lbl));
+	iph->daddr		=	rt->rt6i_dst.addr;
+	iph->saddr		=	cp->vaddr.in6; /* rt->rt6i_src.addr; */
+	iph->hop_limit		=	old_iph->hop_limit;
+
+	/* Another hack: avoid icmp_send in ip_fragment */
+	skb->local_df = 1;
+
+	ip6_local_out(skb);
+
+	LeaveFunction(10);
+
+	return NF_STOLEN;
+
+  tx_error_icmp:
+	dst_link_failure(skb);
+  tx_error:
+	kfree_skb(skb);
+	LeaveFunction(10);
+	return NF_STOLEN;
+}
+#endif
+
 
 /*
  *      Direct Routing transmitter
@@ -536,6 +777,58 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	return NF_STOLEN;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+int
+ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
+	         struct ip_vs_protocol *pp)
+{
+	struct rt6_info *rt;			/* Route to the other host */
+	int    mtu;
+
+	EnterFunction(10);
+
+	if (!(rt = __ip_vs_get_out_rt_v6(cp)))
+		goto tx_error_icmp;
+
+	/* MTU checking */
+	mtu = dst_mtu(&rt->u.dst);
+	if (skb->len > mtu) {
+		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
+		dst_release(&rt->u.dst);
+		IP_VS_DBG_RL("ip_vs_dr_xmit_v6(): frag needed\n");
+		goto tx_error;
+	}
+
+	/*
+	 * Call ip_send_check because we are not sure it is called
+	 * after ip_defrag. Is copy-on-write needed?
+	 */
+	if (unlikely((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)) {
+		dst_release(&rt->u.dst);
+		return NF_STOLEN;
+	}
+
+	/* drop old route */
+	dst_release(skb->dst);
+	skb->dst = &rt->u.dst;
+
+	/* Another hack: avoid icmp_send in ip_fragment */
+	skb->local_df = 1;
+
+	IP_VS_XMIT(PF_INET6, skb, rt);
+
+	LeaveFunction(10);
+	return NF_STOLEN;
+
+  tx_error_icmp:
+	dst_link_failure(skb);
+  tx_error:
+	kfree_skb(skb);
+	LeaveFunction(10);
+	return NF_STOLEN;
+}
+#endif
+
 
 /*
  *	ICMP packet transmitter
@@ -613,3 +906,78 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	ip_rt_put(rt);
 	goto tx_error;
 }
+
+#ifdef CONFIG_IP_VS_IPV6
+int
+ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
+		struct ip_vs_protocol *pp, int offset)
+{
+	struct rt6_info	*rt;	/* Route to the other host */
+	int mtu;
+	int rc;
+
+	EnterFunction(10);
+
+	/* The ICMP packet for VS/TUN, VS/DR and LOCALNODE will be
+	   forwarded directly here, because there is no need to
+	   translate address/port back */
+	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
+		if (cp->packet_xmit)
+			rc = cp->packet_xmit(skb, cp, pp);
+		else
+			rc = NF_ACCEPT;
+		/* do not touch skb anymore */
+		atomic_inc(&cp->in_pkts);
+		goto out;
+	}
+
+	/*
+	 * mangle and send the packet here (only for VS/NAT)
+	 */
+
+	if (!(rt = __ip_vs_get_out_rt_v6(cp)))
+		goto tx_error_icmp;
+
+	/* MTU checking */
+	mtu = dst_mtu(&rt->u.dst);
+	if (skb->len > mtu) {
+		dst_release(&rt->u.dst);
+		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
+		IP_VS_DBG_RL("ip_vs_in_icmp(): frag needed\n");
+		goto tx_error;
+	}
+
+	/* copy-on-write the packet before mangling it */
+	if (!skb_make_writable(skb, offset))
+		goto tx_error_put;
+
+	if (skb_cow(skb, rt->u.dst.dev->hard_header_len))
+		goto tx_error_put;
+
+	/* drop the old route when skb is not shared */
+	dst_release(skb->dst);
+	skb->dst = &rt->u.dst;
+
+	ip_vs_nat_icmp_v6(skb, pp, cp, 0);
+
+	/* Another hack: avoid icmp_send in ip_fragment */
+	skb->local_df = 1;
+
+	IP_VS_XMIT(PF_INET6, skb, rt);
+
+	rc = NF_STOLEN;
+	goto out;
+
+  tx_error_icmp:
+	dst_link_failure(skb);
+  tx_error:
+	dev_kfree_skb(skb);
+	rc = NF_STOLEN;
+  out:
+	LeaveFunction(10);
+	return rc;
+  tx_error_put:
+	dst_release(&rt->u.dst);
+	goto tx_error;
+}
+#endif
-- 
1.5.4.5

