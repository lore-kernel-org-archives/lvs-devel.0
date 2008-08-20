From: Julius Volz <juliusv@google.com>
Subject: [PATCH RFC 11/24] IPVS: Add IPv6 xmit functions
Date: Wed, 20 Aug 2008 18:15:18 +0200
Message-ID: <1219248931-15064-12-git-send-email-juliusv@google.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219248978; bh=r/44kHLohZhIhf6TaPOLozimxWw=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=slwzPbprP2K30cE6DnjA9aVm3xEI6zQxuhp2DrYy
	MlNBnCllwaVNA2NsUXkJbEXItB35XE30pp+YRvW9iOb0Og==
In-Reply-To: <1219248931-15064-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Add xmit functions for IPv6 and a function ip_vs_bind_xmit_v6() for
binding them to a connection. Also add support for v6 to IP_VS_XMIT() and
the routing cache functions.

Much duplication here, since the new functions are copied from the old ones
and then modified for IPv6. Hard to efficiently factor out the common parts
though?

Signed-off-by: Julius Volz <juliusv@google.com>

 3 files changed, 476 insertions(+), 13 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 352807b..565121e 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -857,6 +857,18 @@ extern int ip_vs_icmp_xmit
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
diff --git a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
index ea921dc..4eae6bf 100644
--- a/net/ipv4/ipvs/ip_vs_conn.c
+++ b/net/ipv4/ipvs/ip_vs_conn.c
@@ -369,6 +369,33 @@ static inline void ip_vs_bind_xmit(struct ip_vs_conn *cp)
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
diff --git a/net/ipv4/ipvs/ip_vs_xmit.c b/net/ipv4/ipvs/ip_vs_xmit.c
index 9892d4a..15c59aa 100644
--- a/net/ipv4/ipvs/ip_vs_xmit.c
+++ b/net/ipv4/ipvs/ip_vs_xmit.c
@@ -20,6 +20,9 @@
 #include <net/udp.h>
 #include <net/icmp.h>                   /* for icmp_send */
 #include <net/route.h>                  /* for ip_route_output */
+#include <net/ipv6.h>
+#include <net/ip6_route.h>
+#include <linux/icmpv6.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
 
@@ -47,7 +50,8 @@ __ip_vs_dst_check(struct ip_vs_dest *dest, u32 rtos, u32 cookie)
 
 	if (!dst)
 		return NULL;
-	if ((dst->obsolete || rtos != dest->dst_rtos) &&
+	if ((dst->obsolete
+	     || (dest->af == AF_INET && rtos != dest->dst_rtos)) &&
 	    dst->ops->check(dst, cookie) == NULL) {
 		dest->dst_cache = NULL;
 		dst_release(dst);
@@ -71,7 +75,7 @@ __ip_vs_get_out_rt(struct ip_vs_conn *cp, u32 rtos)
 				.oif = 0,
 				.nl_u = {
 					.ip4_u = {
-						.daddr = dest->addr,
+						.daddr = dest->addr.ip,
 						.saddr = 0,
 						.tos = rtos, } },
 			};
@@ -80,12 +84,12 @@ __ip_vs_get_out_rt(struct ip_vs_conn *cp, u32 rtos)
 				spin_unlock(&dest->dst_lock);
 				IP_VS_DBG_RL("ip_route_output error, "
 					     "dest: %u.%u.%u.%u\n",
-					     NIPQUAD(dest->addr));
+					     NIPQUAD(dest->addr.ip));
 				return NULL;
 			}
 			__ip_vs_dst_set(dest, rtos, dst_clone(&rt->u.dst));
 			IP_VS_DBG(10, "new dst %u.%u.%u.%u, refcnt=%d, rtos=%X\n",
-				  NIPQUAD(dest->addr),
+				  NIPQUAD(dest->addr.ip),
 				  atomic_read(&rt->u.dst.__refcnt), rtos);
 		}
 		spin_unlock(&dest->dst_lock);
@@ -94,14 +98,14 @@ __ip_vs_get_out_rt(struct ip_vs_conn *cp, u32 rtos)
 			.oif = 0,
 			.nl_u = {
 				.ip4_u = {
-					.daddr = cp->daddr,
+					.daddr = cp->daddr.ip,
 					.saddr = 0,
 					.tos = rtos, } },
 		};
 
 		if (ip_route_output_key(&init_net, &rt, &fl)) {
 			IP_VS_DBG_RL("ip_route_output error, dest: "
-				     "%u.%u.%u.%u\n", NIPQUAD(cp->daddr));
+				     "%u.%u.%u.%u\n", NIPQUAD(cp->daddr.ip));
 			return NULL;
 		}
 	}
@@ -109,6 +113,58 @@ __ip_vs_get_out_rt(struct ip_vs_conn *cp, u32 rtos)
 	return rt;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static struct rt6_info *
+__ip_vs_get_out_rt_v6(struct ip_vs_conn *cp)
+{
+	struct rt6_info *rt;			/* Route to the other host */
+	struct ip_vs_dest *dest = cp->dest;
+
+	if (dest) {
+		spin_lock(&dest->dst_lock);
+		if (!(rt = (struct rt6_info *)
+		      __ip_vs_dst_check(dest, 0, 0))) {
+			struct flowi fl = {
+				.oif = 0,
+				.nl_u = {
+					.ip6_u = {
+						.daddr = dest->addr.in6,
+						.saddr = { .s6_addr32 = {0, 0, 0, 0} }, } },
+			};
+
+			if (!(rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl))) {
+				spin_unlock(&dest->dst_lock);
+				IP_VS_DBG_RL("ip6_route_output error, "
+					     "dest: " NIP6_FMT "\n",
+					     NIP6(dest->addr.in6));
+				return NULL;
+			}
+			__ip_vs_dst_set(dest, 0, dst_clone(&rt->u.dst));
+			IP_VS_DBG(10, "new dst " NIP6_FMT ", refcnt=%d\n",
+				  NIP6(dest->addr.in6),
+				  atomic_read(&rt->u.dst.__refcnt));
+		}
+		spin_unlock(&dest->dst_lock);
+	} else {
+		struct flowi fl = {
+			.oif = 0,
+			.nl_u = {
+				.ip6_u = {
+					.daddr = cp->daddr.in6,
+					.saddr = { .s6_addr32 = {0, 0, 0, 0}}, } },
+		};
+
+		if (!(rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl))) {
+			IP_VS_DBG_RL("ip6_route_output error, dest: "
+				     NIP6_FMT "\n", NIP6(cp->daddr.in6));
+			return NULL;
+		}
+	}
+
+	return rt;
+}
+#endif
+
 
 /*
  *	Release dest->dst_cache before a dest is removed
@@ -123,11 +179,11 @@ ip_vs_dst_reset(struct ip_vs_dest *dest)
 	dst_release(old_dst);
 }
 
-#define IP_VS_XMIT(skb, rt)				\
+#define IP_VS_XMIT(pf, skb, rt)				\
 do {							\
 	(skb)->ipvs_property = 1;			\
 	skb_forward_csum(skb);				\
-	NF_HOOK(PF_INET, NF_INET_LOCAL_OUT, (skb), NULL,	\
+	NF_HOOK(pf, NF_INET_LOCAL_OUT, (skb), NULL,	\
 		(rt)->u.dst.dev, dst_output);		\
 } while (0)
 
@@ -200,7 +256,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	IP_VS_XMIT(PF_INET, skb, rt);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -213,6 +269,68 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
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
@@ -264,7 +382,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* mangle the packet */
 	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp))
 		goto tx_error;
-	ip_hdr(skb)->daddr = cp->daddr;
+	ip_hdr(skb)->daddr = cp->daddr.ip;
 	ip_send_check(ip_hdr(skb));
 
 	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");
@@ -276,7 +394,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	IP_VS_XMIT(PF_INET, skb, rt);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -292,6 +410,80 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
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
@@ -423,6 +615,111 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
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
@@ -467,7 +764,58 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	IP_VS_XMIT(PF_INET, skb, rt);
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
+
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
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -479,6 +827,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	LeaveFunction(10);
 	return NF_STOLEN;
 }
+#endif
 
 
 /*
@@ -540,7 +889,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	IP_VS_XMIT(PF_INET, skb, rt);
 
 	rc = NF_STOLEN;
 	goto out;
@@ -557,3 +906,78 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
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

