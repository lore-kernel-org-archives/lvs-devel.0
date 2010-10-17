From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 12/12] ipvs: provide address family for debugging
Date: Sun, 17 Oct 2010 16:46:17 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010171643370.20665@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


 	As skb->protocol is not valid in LOCAL_OUT add
parameter for address family in packet debugging functions.
Even if ports are not present in AH and ESP change them to
use ip_vs_tcpudp_debug_packet to show at least valid addresses
as before. This patch removes the last user of skb->protocol
in IPVS.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp nf-next-2.6-a91fd26/linux/include/net/ip_vs.h linux/include/net/ip_vs.h
--- nf-next-2.6-a91fd26/linux/include/net/ip_vs.h	2010-10-16 19:35:04.718355828 +0300
+++ linux/include/net/ip_vs.h	2010-10-17 14:03:59.594374582 +0300
@@ -136,24 +136,24 @@ static inline const char *ip_vs_dbg_addr
  		if (net_ratelimit())					\
  			printk(KERN_DEBUG pr_fmt(msg), ##__VA_ARGS__);	\
  	} while (0)
-#define IP_VS_DBG_PKT(level, pp, skb, ofs, msg)				\
+#define IP_VS_DBG_PKT(level, af, pp, skb, ofs, msg)			\
  	do {								\
  		if (level <= ip_vs_get_debug_level())			\
-			pp->debug_packet(pp, skb, ofs, msg);		\
+			pp->debug_packet(af, pp, skb, ofs, msg);	\
  	} while (0)
-#define IP_VS_DBG_RL_PKT(level, pp, skb, ofs, msg)			\
+#define IP_VS_DBG_RL_PKT(level, af, pp, skb, ofs, msg)			\
  	do {								\
  		if (level <= ip_vs_get_debug_level() &&			\
  		    net_ratelimit())					\
-			pp->debug_packet(pp, skb, ofs, msg);		\
+			pp->debug_packet(af, pp, skb, ofs, msg);	\
  	} while (0)
  #else	/* NO DEBUGGING at ALL */
  #define IP_VS_DBG_BUF(level, msg...)  do {} while (0)
  #define IP_VS_ERR_BUF(msg...)  do {} while (0)
  #define IP_VS_DBG(level, msg...)  do {} while (0)
  #define IP_VS_DBG_RL(msg...)  do {} while (0)
-#define IP_VS_DBG_PKT(level, pp, skb, ofs, msg)		do {} while (0)
-#define IP_VS_DBG_RL_PKT(level, pp, skb, ofs, msg)	do {} while (0)
+#define IP_VS_DBG_PKT(level, af, pp, skb, ofs, msg)	do {} while (0)
+#define IP_VS_DBG_RL_PKT(level, af, pp, skb, ofs, msg)	do {} while (0)
  #endif

  #define IP_VS_BUG() BUG()
@@ -345,7 +345,7 @@ struct ip_vs_protocol {

  	int (*app_conn_bind)(struct ip_vs_conn *cp);

-	void (*debug_packet)(struct ip_vs_protocol *pp,
+	void (*debug_packet)(int af, struct ip_vs_protocol *pp,
  			     const struct sk_buff *skb,
  			     int offset,
  			     const char *msg);
@@ -828,7 +828,8 @@ extern int
  ip_vs_set_state_timeout(int *table, int num, const char *const *names,
  			const char *name, int to);
  extern void
-ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
+ip_vs_tcpudp_debug_packet(int af, struct ip_vs_protocol *pp,
+			  const struct sk_buff *skb,
  			  int offset, const char *msg);

  extern struct ip_vs_protocol ip_vs_protocol_tcp;
diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_core.c linux/net/netfilter/ipvs/ip_vs_core.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_core.c	2010-10-17 14:54:12.470377773 +0300
+++ linux/net/netfilter/ipvs/ip_vs_core.c	2010-10-17 14:54:55.158377092 +0300
@@ -365,7 +365,8 @@ ip_vs_schedule(struct ip_vs_service *svc
  	 * with persistence the connection is created on SYN+ACK.
  	 */
  	if (pptr[0] == FTPDATA) {
-		IP_VS_DBG_PKT(12, pp, skb, 0, "Not scheduling FTPDATA");
+		IP_VS_DBG_PKT(12, svc->af, pp, skb, 0,
+			      "Not scheduling FTPDATA");
  		return NULL;
  	}

@@ -376,7 +377,7 @@ ip_vs_schedule(struct ip_vs_service *svc
  	if ((!skb->dev || skb->dev->flags & IFF_LOOPBACK) &&
  	    (svc->flags & IP_VS_SVC_F_PERSISTENT || svc->fwmark) &&
  	    (cp = pp->conn_in_get(svc->af, skb, pp, &iph, iph.len, 1))) {
-		IP_VS_DBG_PKT(12, pp, skb, 0,
+		IP_VS_DBG_PKT(12, svc->af, pp, skb, 0,
  			      "Not scheduling reply for existing connection");
  		__ip_vs_conn_put(cp);
  		return NULL;
@@ -617,10 +618,10 @@ void ip_vs_nat_icmp(struct sk_buff *skb,
  	skb->ip_summed = CHECKSUM_UNNECESSARY;

  	if (inout)
-		IP_VS_DBG_PKT(11, pp, skb, (void *)ciph - (void *)iph,
+		IP_VS_DBG_PKT(11, AF_INET, pp, skb, (void *)ciph - (void *)iph,
  			"Forwarding altered outgoing ICMP");
  	else
-		IP_VS_DBG_PKT(11, pp, skb, (void *)ciph - (void *)iph,
+		IP_VS_DBG_PKT(11, AF_INET, pp, skb, (void *)ciph - (void *)iph,
  			"Forwarding altered incoming ICMP");
  }

@@ -662,11 +663,13 @@ void ip_vs_nat_icmp_v6(struct sk_buff *s
  	skb->ip_summed = CHECKSUM_PARTIAL;

  	if (inout)
-		IP_VS_DBG_PKT(11, pp, skb, (void *)ciph - (void *)iph,
-			"Forwarding altered outgoing ICMPv6");
+		IP_VS_DBG_PKT(11, AF_INET6, pp, skb,
+			      (void *)ciph - (void *)iph,
+			      "Forwarding altered outgoing ICMPv6");
  	else
-		IP_VS_DBG_PKT(11, pp, skb, (void *)ciph - (void *)iph,
-			"Forwarding altered incoming ICMPv6");
+		IP_VS_DBG_PKT(11, AF_INET6, pp, skb,
+			      (void *)ciph - (void *)iph,
+			      "Forwarding altered incoming ICMPv6");
  }
  #endif

@@ -798,7 +801,8 @@ static int ip_vs_out_icmp(struct sk_buff
  		     pp->dont_defrag))
  		return NF_ACCEPT;

-	IP_VS_DBG_PKT(11, pp, skb, offset, "Checking outgoing ICMP for");
+	IP_VS_DBG_PKT(11, AF_INET, pp, skb, offset,
+		      "Checking outgoing ICMP for");

  	offset += cih->ihl * 4;

@@ -874,7 +878,8 @@ static int ip_vs_out_icmp_v6(struct sk_b
  	if (unlikely(cih->nexthdr == IPPROTO_FRAGMENT && pp->dont_defrag))
  		return NF_ACCEPT;

-	IP_VS_DBG_PKT(11, pp, skb, offset, "Checking outgoing ICMPv6 for");
+	IP_VS_DBG_PKT(11, AF_INET6, pp, skb, offset,
+		      "Checking outgoing ICMPv6 for");

  	offset += sizeof(struct ipv6hdr);

@@ -922,7 +927,7 @@ static unsigned int
  handle_response(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
  		struct ip_vs_conn *cp, int ihl)
  {
-	IP_VS_DBG_PKT(11, pp, skb, 0, "Outgoing packet");
+	IP_VS_DBG_PKT(11, af, pp, skb, 0, "Outgoing packet");

  	if (!skb_make_writable(skb, ihl))
  		goto drop;
@@ -967,7 +972,7 @@ handle_response(int af, struct sk_buff *
  		    ip_route_me_harder(skb, RTN_LOCAL) != 0)
  			goto drop;

-	IP_VS_DBG_PKT(10, pp, skb, 0, "After SNAT");
+	IP_VS_DBG_PKT(10, af, pp, skb, 0, "After SNAT");

  	ip_vs_out_stats(cp, skb);
  	ip_vs_set_state(cp, IP_VS_DIR_OUTPUT, skb, pp);
@@ -1117,7 +1122,7 @@ ip_vs_out(unsigned int hooknum, struct s
  			}
  		}
  	}
-	IP_VS_DBG_PKT(12, pp, skb, 0,
+	IP_VS_DBG_PKT(12, af, pp, skb, 0,
  		      "ip_vs_out: packet continues traversal as normal");
  	return NF_ACCEPT;
  }
@@ -1253,7 +1258,8 @@ ip_vs_in_icmp(struct sk_buff *skb, int *
  		     pp->dont_defrag))
  		return NF_ACCEPT;

-	IP_VS_DBG_PKT(11, pp, skb, offset, "Checking incoming ICMP for");
+	IP_VS_DBG_PKT(11, AF_INET, pp, skb, offset,
+		      "Checking incoming ICMP for");

  	offset += cih->ihl * 4;

@@ -1364,7 +1370,8 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, in
  	if (unlikely(cih->nexthdr == IPPROTO_FRAGMENT && pp->dont_defrag))
  		return NF_ACCEPT;

-	IP_VS_DBG_PKT(11, pp, skb, offset, "Checking incoming ICMPv6 for");
+	IP_VS_DBG_PKT(11, AF_INET6, pp, skb, offset,
+		      "Checking incoming ICMPv6 for");

  	offset += sizeof(struct ipv6hdr);

@@ -1492,12 +1499,12 @@ ip_vs_in(unsigned int hooknum, struct sk

  	if (unlikely(!cp)) {
  		/* sorry, all this trouble for a no-hit :) */
-		IP_VS_DBG_PKT(12, pp, skb, 0,
+		IP_VS_DBG_PKT(12, af, pp, skb, 0,
  			      "ip_vs_in: packet continues traversal as normal");
  		return NF_ACCEPT;
  	}

-	IP_VS_DBG_PKT(11, pp, skb, 0, "Incoming packet");
+	IP_VS_DBG_PKT(11, af, pp, skb, 0, "Incoming packet");

  	/* Check the server status */
  	if (cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto.c linux/net/netfilter/ipvs/ip_vs_proto.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto.c	2010-10-13 22:22:35.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_proto.c	2010-10-17 13:51:28.474434727 +0300
@@ -172,8 +172,8 @@ ip_vs_tcpudp_debug_packet_v4(struct ip_v
  	else if (ih->frag_off & htons(IP_OFFSET))
  		sprintf(buf, "%pI4->%pI4 frag", &ih->saddr, &ih->daddr);
  	else {
-		__be16 _ports[2], *pptr
-;
+		__be16 _ports[2], *pptr;
+
  		pptr = skb_header_pointer(skb, offset + ih->ihl*4,
  					  sizeof(_ports), _ports);
  		if (pptr == NULL)
@@ -223,13 +223,13 @@ ip_vs_tcpudp_debug_packet_v6(struct ip_v


  void
-ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp,
+ip_vs_tcpudp_debug_packet(int af, struct ip_vs_protocol *pp,
  			  const struct sk_buff *skb,
  			  int offset,
  			  const char *msg)
  {
  #ifdef CONFIG_IP_VS_IPV6
-	if (skb->protocol == htons(ETH_P_IPV6))
+	if (af == AF_INET6)
  		ip_vs_tcpudp_debug_packet_v6(pp, skb, offset, msg);
  	else
  #endif
diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto_ah_esp.c linux/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto_ah_esp.c	2010-10-13 22:22:35.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_proto_ah_esp.c	2010-10-17 13:44:01.680375472 +0300
@@ -117,54 +117,6 @@ ah_esp_conn_schedule(int af, struct sk_b
  	return 0;
  }

-
-static void
-ah_esp_debug_packet_v4(struct ip_vs_protocol *pp, const struct sk_buff *skb,
-		       int offset, const char *msg)
-{
-	char buf[256];
-	struct iphdr _iph, *ih;
-
-	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
-	if (ih == NULL)
-		sprintf(buf, "TRUNCATED");
-	else
-		sprintf(buf, "%pI4->%pI4", &ih->saddr, &ih->daddr);
-
-	pr_debug("%s: %s %s\n", msg, pp->name, buf);
-}
-
-#ifdef CONFIG_IP_VS_IPV6
-static void
-ah_esp_debug_packet_v6(struct ip_vs_protocol *pp, const struct sk_buff *skb,
-		       int offset, const char *msg)
-{
-	char buf[256];
-	struct ipv6hdr _iph, *ih;
-
-	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
-	if (ih == NULL)
-		sprintf(buf, "TRUNCATED");
-	else
-		sprintf(buf, "%pI6->%pI6", &ih->saddr, &ih->daddr);
-
-	pr_debug("%s: %s %s\n", msg, pp->name, buf);
-}
-#endif
-
-static void
-ah_esp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
-		    int offset, const char *msg)
-{
-#ifdef CONFIG_IP_VS_IPV6
-	if (skb->protocol == htons(ETH_P_IPV6))
-		ah_esp_debug_packet_v6(pp, skb, offset, msg);
-	else
-#endif
-		ah_esp_debug_packet_v4(pp, skb, offset, msg);
-}
-
-
  static void ah_esp_init(struct ip_vs_protocol *pp)
  {
  	/* nothing to do now */
@@ -195,7 +147,7 @@ struct ip_vs_protocol ip_vs_protocol_ah
  	.register_app =		NULL,
  	.unregister_app =	NULL,
  	.app_conn_bind =	NULL,
-	.debug_packet =		ah_esp_debug_packet,
+	.debug_packet =		ip_vs_tcpudp_debug_packet,
  	.timeout_change =	NULL,		/* ISAKMP */
  	.set_state_timeout =	NULL,
  };
@@ -219,7 +171,7 @@ struct ip_vs_protocol ip_vs_protocol_esp
  	.register_app =		NULL,
  	.unregister_app =	NULL,
  	.app_conn_bind =	NULL,
-	.debug_packet =		ah_esp_debug_packet,
+	.debug_packet =		ip_vs_tcpudp_debug_packet,
  	.timeout_change =	NULL,		/* ISAKMP */
  };
  #endif
diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto_sctp.c linux/net/netfilter/ipvs/ip_vs_proto_sctp.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto_sctp.c	2010-10-16 15:14:05.631355648 +0300
+++ linux/net/netfilter/ipvs/ip_vs_proto_sctp.c	2010-10-17 13:28:20.866374440 +0300
@@ -176,7 +176,7 @@ sctp_csum_check(int af, struct sk_buff *

  	if (val != cmp) {
  		/* CRC failure, dump it. */
-		IP_VS_DBG_RL_PKT(0, pp, skb, 0,
+		IP_VS_DBG_RL_PKT(0, af, pp, skb, 0,
  				"Failed checksum for");
  		return 0;
  	}
diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto_tcp.c linux/net/netfilter/ipvs/ip_vs_proto_tcp.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto_tcp.c	2010-10-16 15:14:05.631355648 +0300
+++ linux/net/netfilter/ipvs/ip_vs_proto_tcp.c	2010-10-17 13:28:56.724375202 +0300
@@ -300,7 +300,7 @@ tcp_csum_check(int af, struct sk_buff *s
  					    skb->len - tcphoff,
  					    ipv6_hdr(skb)->nexthdr,
  					    skb->csum)) {
-				IP_VS_DBG_RL_PKT(0, pp, skb, 0,
+				IP_VS_DBG_RL_PKT(0, af, pp, skb, 0,
  						 "Failed checksum for");
  				return 0;
  			}
@@ -311,7 +311,7 @@ tcp_csum_check(int af, struct sk_buff *s
  					      skb->len - tcphoff,
  					      ip_hdr(skb)->protocol,
  					      skb->csum)) {
-				IP_VS_DBG_RL_PKT(0, pp, skb, 0,
+				IP_VS_DBG_RL_PKT(0, af, pp, skb, 0,
  						 "Failed checksum for");
  				return 0;
  			}
diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto_udp.c linux/net/netfilter/ipvs/ip_vs_proto_udp.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto_udp.c	2010-10-16 15:14:05.632355394 +0300
+++ linux/net/netfilter/ipvs/ip_vs_proto_udp.c	2010-10-17 13:29:23.373375694 +0300
@@ -314,7 +314,7 @@ udp_csum_check(int af, struct sk_buff *s
  						    skb->len - udphoff,
  						    ipv6_hdr(skb)->nexthdr,
  						    skb->csum)) {
-					IP_VS_DBG_RL_PKT(0, pp, skb, 0,
+					IP_VS_DBG_RL_PKT(0, af, pp, skb, 0,
  							 "Failed checksum for");
  					return 0;
  				}
@@ -325,7 +325,7 @@ udp_csum_check(int af, struct sk_buff *s
  						      skb->len - udphoff,
  						      ip_hdr(skb)->protocol,
  						      skb->csum)) {
-					IP_VS_DBG_RL_PKT(0, pp, skb, 0,
+					IP_VS_DBG_RL_PKT(0, af, pp, skb, 0,
  							 "Failed checksum for");
  					return 0;
  				}
diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_xmit.c linux/net/netfilter/ipvs/ip_vs_xmit.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_xmit.c	2010-10-16 20:14:22.341354963 +0300
+++ linux/net/netfilter/ipvs/ip_vs_xmit.c	2010-10-17 13:27:03.767374886 +0300
@@ -542,7 +542,8 @@ ip_vs_nat_xmit(struct sk_buff *skb, stru
  		struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);

  		if (ct && !nf_ct_is_untracked(ct)) {
-			IP_VS_DBG_RL_PKT(10, pp, skb, 0, "ip_vs_nat_xmit(): "
+			IP_VS_DBG_RL_PKT(10, AF_INET, pp, skb, 0,
+					 "ip_vs_nat_xmit(): "
  					 "stopping DNAT to local address");
  			goto tx_error_put;
  		}
@@ -551,7 +552,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, stru

  	/* From world but DNAT to loopback address? */
  	if (local && ipv4_is_loopback(rt->rt_dst) && skb_rtable(skb)->fl.iif) {
-		IP_VS_DBG_RL_PKT(1, pp, skb, 0, "ip_vs_nat_xmit(): "
+		IP_VS_DBG_RL_PKT(1, AF_INET, pp, skb, 0, "ip_vs_nat_xmit(): "
  				 "stopping DNAT to loopback address");
  		goto tx_error_put;
  	}
@@ -560,7 +561,8 @@ ip_vs_nat_xmit(struct sk_buff *skb, stru
  	mtu = dst_mtu(&rt->dst);
  	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF))) {
  		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
-		IP_VS_DBG_RL_PKT(0, pp, skb, 0, "ip_vs_nat_xmit(): frag needed for");
+		IP_VS_DBG_RL_PKT(0, AF_INET, pp, skb, 0,
+				 "ip_vs_nat_xmit(): frag needed for");
  		goto tx_error_put;
  	}

@@ -592,7 +594,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, stru
  			goto tx_error;
  	}

-	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");
+	IP_VS_DBG_PKT(10, AF_INET, pp, skb, 0, "After DNAT");

  	/* FIXME: when application helper enlarges the packet and the length
  	   is larger than the MTU of outgoing device, there will be still
@@ -653,7 +655,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, s
  		struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);

  		if (ct && !nf_ct_is_untracked(ct)) {
-			IP_VS_DBG_RL_PKT(10, pp, skb, 0,
+			IP_VS_DBG_RL_PKT(10, AF_INET6, pp, skb, 0,
  					 "ip_vs_nat_xmit_v6(): "
  					 "stopping DNAT to local address");
  			goto tx_error_put;
@@ -664,7 +666,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, s
  	/* From world but DNAT to loopback address? */
  	if (local && skb->dev && !(skb->dev->flags & IFF_LOOPBACK) &&
  	    ipv6_addr_type(&rt->rt6i_dst.addr) & IPV6_ADDR_LOOPBACK) {
-		IP_VS_DBG_RL_PKT(1, pp, skb, 0,
+		IP_VS_DBG_RL_PKT(1, AF_INET6, pp, skb, 0,
  				 "ip_vs_nat_xmit_v6(): "
  				 "stopping DNAT to loopback address");
  		goto tx_error_put;
@@ -679,7 +681,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, s
  			skb->dev = net->loopback_dev;
  		}
  		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-		IP_VS_DBG_RL_PKT(0, pp, skb, 0,
+		IP_VS_DBG_RL_PKT(0, AF_INET6, pp, skb, 0,
  				 "ip_vs_nat_xmit_v6(): frag needed for");
  		goto tx_error_put;
  	}
@@ -705,7 +707,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, s
  		dst_release(&rt->dst);
  	}

-	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");
+	IP_VS_DBG_PKT(10, AF_INET6, pp, skb, 0, "After DNAT");

  	/* FIXME: when application helper enlarges the packet and the length
  	   is larger than the MTU of outgoing device, there will be still
