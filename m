From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/2] ipvs: load balance IPv4 connections from a local
	process
Date: Fri, 5 Sep 2008 11:36:11 +1000
Message-ID: <20080905013609.GD14128@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Malcolm Turnbull <malcolm@loadbalancer.org>, Siim =?iso-8859-1?Q?P=F5der?= <siim@p6drad-teel.net>, Julius Volz <juliusv@google.com>, Vince Busam <vbusam@google.com>

=46rom: Malcolm Turnbull <malcolm@loadbalancer.org>

ipvs: load balance IPv4 connections from a local process

This allows IPVS to load balance connections made by a local process.
=46or example a proxy server running locally.

External client --> pound:443 -> Local:443 --> IPVS:80 --> RealServer

Signed-off-by: Siim P=F5der <siim@p6drad-teel.net>
Signed-off-by: Malcolm Turnbull <malcolm@loadbalancer.org>
Signed-off-by: Simon Horman <horms@verge.net.au>

---=20

 net/ipv4/ipvs/ip_vs_core.c      |  224 ++++++++++++++++++++++---------=
--------
 net/ipv4/ipvs/ip_vs_proto_tcp.c |    4=20
 2 files changed, 134 insertions(+), 94 deletions(-)

* Simon Horman, Wed, 03 Sep 2008 14:50:36 +1000

  I have updated this patch so that it will apply on top
  of the current IPv6 patches.

  http://marc.info/?l=3Dlinux-netdev&m=3D122036407428246&w=3D2

  I have also updated the patch so that it does not handle IPv6 packets=
=2E

  I have an additional patch that I will provide to exetend
  the code to handle IPv6 connections.

* Simon Horman, Fri, 05 Sep 2008 11:32:38 +1000

  I have applied this patch to the net-next-2.6 branck of lvs-2.6

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-2.6.git

Index: lvs-2.6/net/ipv4/ipvs/ip_vs_core.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- lvs-2.6.orig/net/ipv4/ipvs/ip_vs_core.c	2008-09-03 11:01:38.0000000=
00 +1000
+++ lvs-2.6/net/ipv4/ipvs/ip_vs_core.c	2008-09-03 12:17:49.000000000 +1=
000
@@ -651,12 +651,53 @@ void ip_vs_nat_icmp_v6(struct sk_buff *s
 }
 #endif
=20
+/* Handle relevant response ICMP messages - forward to the right
+ * destination host. Used for NAT and local client.
+ */
+static int handle_response_icmp(struct sk_buff *skb, struct iphdr *iph=
,
+				struct iphdr *cih, struct ip_vs_conn *cp,
+				struct ip_vs_protocol *pp,
+				unsigned int offset, unsigned int ihl)
+{
+	unsigned int verdict =3D NF_DROP;
+
+	if (IP_VS_FWD_METHOD(cp) !=3D 0) {
+		IP_VS_ERR("shouldn't reach here, because the box is on the "
+			  "half connection in the tun/dr module.\n");
+	}
+
+	/* Ensure the checksum is correct */
+	if (!skb_csum_unnecessary(skb) && ip_vs_checksum_complete(skb, ihl)) =
{
+		/* Failed checksum! */
+		IP_VS_DBG(1,
+			  "Forward ICMP: failed checksum from %d.%d.%d.%d!\n",
+			  NIPQUAD(iph->saddr));
+		goto out;
+	}
+
+	if (IPPROTO_TCP =3D=3D cih->protocol || IPPROTO_UDP =3D=3D cih->proto=
col)
+		offset +=3D 2 * sizeof(__u16);
+	if (!skb_make_writable(skb, offset))
+		goto out;
+
+	ip_vs_nat_icmp(skb, pp, cp, 1);
+
+	/* do the statistics and put it back */
+	ip_vs_out_stats(cp, skb);
+
+	skb->ipvs_property =3D 1;
+	verdict =3D NF_ACCEPT;
+
+out:
+	__ip_vs_conn_put(cp);
+
+	return verdict;
+}
+
 /*
  *	Handle ICMP messages in the inside-to-outside direction (outgoing).
- *	Find any that might be relevant, check against existing connections=
,
- *	forward to the right destination host if relevant.
+ *	Find any that might be relevant, check against existing connections=
=2E
  *	Currently handles error types - unreachable, quench, ttl exceeded.
- *	(Only used in VS/NAT)
  */
 static int ip_vs_out_icmp(struct sk_buff *skb, int *related)
 {
@@ -666,7 +707,7 @@ static int ip_vs_out_icmp(struct sk_buff
 	struct ip_vs_iphdr ciph;
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
-	unsigned int offset, ihl, verdict;
+	unsigned int offset, ihl;
=20
 	*related =3D 1;
=20
@@ -725,38 +766,7 @@ static int ip_vs_out_icmp(struct sk_buff
 	if (!cp)
 		return NF_ACCEPT;
=20
-	verdict =3D NF_DROP;
-
-	if (IP_VS_FWD_METHOD(cp) !=3D 0) {
-		IP_VS_ERR("shouldn't reach here, because the box is on the "
-			  "half connection in the tun/dr module.\n");
-	}
-
-	/* Ensure the checksum is correct */
-	if (!skb_csum_unnecessary(skb) && ip_vs_checksum_complete(skb, ihl)) =
{
-		/* Failed checksum! */
-		IP_VS_DBG(1, "Forward ICMP: failed checksum from %d.%d.%d.%d!\n",
-			  NIPQUAD(iph->saddr));
-		goto out;
-	}
-
-	if (IPPROTO_TCP =3D=3D cih->protocol || IPPROTO_UDP =3D=3D cih->proto=
col)
-		offset +=3D 2 * sizeof(__u16);
-	if (!skb_make_writable(skb, offset))
-		goto out;
-
-	ip_vs_nat_icmp(skb, pp, cp, 1);
-
-	/* do the statistics and put it back */
-	ip_vs_out_stats(cp, skb);
-
-	skb->ipvs_property =3D 1;
-	verdict =3D NF_ACCEPT;
-
-  out:
-	__ip_vs_conn_put(cp);
-
-	return verdict;
+	return handle_response_icmp(skb, iph, cih, cp, pp, offset, ihl);
 }
=20
 #ifdef CONFIG_IP_VS_IPV6
@@ -875,10 +885,76 @@ static inline int is_tcp_reset(const str
 	return th->rst;
 }
=20
+/* Handle response packets: rewrite addresses and send away...
+ * Used for NAT and local client.
+ */
+static unsigned int
+handle_response(int af, struct sk_buff *skb, struct ip_vs_protocol *pp=
,
+		struct ip_vs_conn *cp, int ihl)
+{
+	IP_VS_DBG_PKT(11, pp, skb, 0, "Outgoing packet");
+
+	if (!skb_make_writable(skb, ihl))
+		goto drop;
+
+	/* mangle the packet */
+	if (pp->snat_handler && !pp->snat_handler(skb, pp, cp))
+		goto drop;
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (af =3D=3D AF_INET6)
+		ipv6_hdr(skb)->saddr =3D cp->vaddr.in6;
+	else
+#endif
+	{
+		ip_hdr(skb)->saddr =3D cp->vaddr.ip;
+		ip_send_check(ip_hdr(skb));
+	}
+
+	/* For policy routing, packets originating from this
+	 * machine itself may be routed differently to packets
+	 * passing through.  We want this packet to be routed as
+	 * if it came from this machine itself.  So re-compute
+	 * the routing information.
+	 */
+#ifdef CONFIG_IP_VS_IPV6
+	if (af =3D=3D AF_INET6) {
+		if (ip6_route_me_harder(skb) !=3D 0)
+			goto drop;
+	} else
+#endif
+		if (ip_route_me_harder(skb, RTN_LOCAL) !=3D 0)
+			goto drop;
+
+	/* For policy routing, packets originating from this
+	 * machine itself may be routed differently to packets
+	 * passing through.  We want this packet to be routed as
+	 * if it came from this machine itself.  So re-compute
+	 * the routing information.
+	 */
+	if (ip_route_me_harder(skb, RTN_LOCAL) !=3D 0)
+		goto drop;
+
+	IP_VS_DBG_PKT(10, pp, skb, 0, "After SNAT");
+
+	ip_vs_out_stats(cp, skb);
+	ip_vs_set_state(cp, IP_VS_DIR_OUTPUT, skb, pp);
+	ip_vs_conn_put(cp);
+
+	skb->ipvs_property =3D 1;
+
+	LeaveFunction(11);
+	return NF_ACCEPT;
+
+drop:
+	ip_vs_conn_put(cp);
+	kfree_skb(skb);
+	return NF_STOLEN;
+}
+
 /*
  *	It is hooked at the NF_INET_FORWARD chain, used only for VS/NAT.
- *	Check if outgoing packet belongs to the established ip_vs_conn,
- *      rewrite addresses of the packet and send it on its way...
+ *	Check if outgoing packet belongs to the established ip_vs_conn.
  */
 static unsigned int
 ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
@@ -987,55 +1063,7 @@ ip_vs_out(unsigned int hooknum, struct s
 		return NF_ACCEPT;
 	}
=20
-	IP_VS_DBG_PKT(11, pp, skb, 0, "Outgoing packet");
-
-	if (!skb_make_writable(skb, iph.len))
-		goto drop;
-
-	/* mangle the packet */
-	if (pp->snat_handler && !pp->snat_handler(skb, pp, cp))
-		goto drop;
-
-#ifdef CONFIG_IP_VS_IPV6
-	if (af =3D=3D AF_INET6)
-		ipv6_hdr(skb)->saddr =3D cp->vaddr.in6;
-	else
-#endif
-	{
-		ip_hdr(skb)->saddr =3D cp->vaddr.ip;
-		ip_send_check(ip_hdr(skb));
-	}
-
-	/* For policy routing, packets originating from this
-	 * machine itself may be routed differently to packets
-	 * passing through.  We want this packet to be routed as
-	 * if it came from this machine itself.  So re-compute
-	 * the routing information.
-	 */
-#ifdef CONFIG_IP_VS_IPV6
-	if (af =3D=3D AF_INET6) {
-		if (ip6_route_me_harder(skb) !=3D 0)
-			goto drop;
-	} else
-#endif
-		if (ip_route_me_harder(skb, RTN_LOCAL) !=3D 0)
-			goto drop;
-
-	IP_VS_DBG_PKT(10, pp, skb, 0, "After SNAT");
-
-	ip_vs_out_stats(cp, skb);
-	ip_vs_set_state(cp, IP_VS_DIR_OUTPUT, skb, pp);
-	ip_vs_conn_put(cp);
-
-	skb->ipvs_property =3D 1;
-
-	LeaveFunction(11);
-	return NF_ACCEPT;
-
-  drop:
-	ip_vs_conn_put(cp);
-	kfree_skb(skb);
-	return NF_STOLEN;
+	return handle_response(af, skb, pp, cp, iph.len);
 }
=20
=20
@@ -1111,8 +1139,14 @@ ip_vs_in_icmp(struct sk_buff *skb, int *
 	ip_vs_fill_iphdr(AF_INET, cih, &ciph);
 	/* The embedded headers contain source and dest in reverse order */
 	cp =3D pp->conn_in_get(AF_INET, skb, pp, &ciph, offset, 1);
-	if (!cp)
+	if (!cp) {
+		/* The packet could also belong to a local client */
+		cp =3D pp->conn_out_get(AF_INET, skb, pp, &ciph, offset, 1);
+		if (cp)
+			return handle_response_icmp(skb, iph, cih, cp, pp,
+						    offset, ihl);
 		return NF_ACCEPT;
+	}
=20
 	verdict =3D NF_DROP;
=20
@@ -1244,11 +1278,12 @@ ip_vs_in(unsigned int hooknum, struct sk
 	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
=20
 	/*
-	 *	Big tappo: only PACKET_HOST (neither loopback nor mcasts)
-	 *	... don't know why 1st test DOES NOT include 2nd (?)
+	 *	Big tappo: only PACKET_HOST, including loopback for local client
+	 *	Don't handle local packets on IPv6 for now
 	 */
-	if (unlikely(skb->pkt_type !=3D PACKET_HOST
-		     || skb->dev->flags & IFF_LOOPBACK || skb->sk)) {
+	if (unlikely(skb->pkt_type !=3D PACKET_HOST ||
+		     (af =3D=3D AF_INET6 || (skb->dev->flags & IFF_LOOPBACK ||
+					 skb->sk)))) {
 		IP_VS_DBG_BUF(12, "packet type=3D%d proto=3D%d daddr=3D%s ignored\n"=
,
 			      skb->pkt_type,
 			      iph.protocol,
@@ -1277,6 +1312,11 @@ ip_vs_in(unsigned int hooknum, struct sk
 	if (unlikely(!cp)) {
 		int v;
=20
+		/* For local client packets, it could be a response */
+		cp =3D pp->conn_out_get(af, skb, pp, &iph, iph.len, 0);
+		if (cp)
+			return handle_response(af, skb, pp, cp, iph.len);
+
 		if (!pp->conn_schedule(af, skb, pp, &v, &cp))
 			return v;
 	}
Index: lvs-2.6/net/ipv4/ipvs/ip_vs_proto_tcp.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- lvs-2.6.orig/net/ipv4/ipvs/ip_vs_proto_tcp.c	2008-09-03 10:56:05.00=
0000000 +1000
+++ lvs-2.6/net/ipv4/ipvs/ip_vs_proto_tcp.c	2008-09-03 11:24:26.0000000=
00 +1000
@@ -166,7 +166,7 @@ tcp_snat_handler(struct sk_buff *skb,
 	tcph->source =3D cp->vport;
=20
 	/* Adjust TCP checksums */
-	if (!cp->app) {
+	if (!cp->app && (tcph->check !=3D 0)) {
 		/* Only port and addr are changed, do fast csum update */
 		tcp_fast_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
 				     cp->dport, cp->vport);
@@ -235,7 +235,7 @@ tcp_dnat_handler(struct sk_buff *skb,
 	/*
 	 *	Adjust TCP checksums
 	 */
-	if (!cp->app) {
+	if (!cp->app && (tcph->check !=3D 0)) {
 		/* Only port and addr are changed, do fast csum update */
 		tcp_fast_csum_update(cp->af, tcph, &cp->vaddr, &cp->daddr,
 				     cp->vport, cp->dport);
