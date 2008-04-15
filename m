From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: [PATCH 0/6] move ipvs to PRE/POSTROUTING
Date: Tue, 15 Apr 2008 15:40:03 +0900
Message-ID: <200804151540.04006.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_E3EBI8djD8ae5ZR"
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: LVS Devel <lvs-devel@vger.kernel.org>

--Boundary-00=_E3EBI8djD8ae5ZR
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

I'm a newbie at all of this so forgive me if I'm doing anything wrong. ;)
I've attached the full patch here should anybody like to give it a try.

This patch set aims to separate LVS processing from netfilter
processing in order to allow netfilter's capabilities to be fully
utilized. The flow of traffic can visualized as:

incoming =3D> de-lvs packets =3D> netfilter =3D> lvs packets =3D> outgoing

The goal is for netfilter to only have to deal with CIP/VIP packets and
for any translations netfilter might do of CIP to be transparent to LVS.

There are three main downfalls with this patch at present:
1) Having a VIP on a local interface causes the traffic to be delivered
   locally as VIP checks have been moved to the end of POST_ROUTING.
2) Localnode with address of 127.0.0.1 does not work as packets with a
   destination of 127.0.0.1 and a non-local source address are
   unconditionally dropped.
3) Firewall rules on existing installations will most likely break.

The first issue can probably be dealt with by The localnode issue could
probably be dealt with by using a hook at the end of PREROUTING and the
second issue could be handled like ipt_REDIRECT. I can't see a way to
handle firewall rules though which implies that this needs to be
optional and defaulting to off should it be considered for inclusion.
I'd appreciate any suggestions on how that can be done elegantly.

=2D-=20
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
=E6=9D=B1=E4=BA=AC=E9=83=BD=E6=B8=8B=E8=B0=B7=E5=8C=BA=E6=A1=9C=E3=83=B6=E4=
=B8=98=E7=94=BA22-14 N.E.S S=E6=A3=9F 3F
TEL 03-5728-4772  FAX 03-5728-4773

--Boundary-00=_E3EBI8djD8ae5ZR
Content-Type: text/x-diff;
  charset="us-ascii";
  name="full.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="full.patch"

diff -urp linux.0.orig/include/net/ip_vs.h linux.6.localhooks/include/net/ip_vs.h
--- linux.0.orig/include/net/ip_vs.h	2008-04-15 12:12:00.427673367 +0900
+++ linux.6.localhooks/include/net/ip_vs.h	2008-04-15 12:08:48.345270930 +0900
@@ -901,8 +901,6 @@ extern void ip_vs_zero_estimator(struct 
 /*
  *	Various IPVS packet transmitters (from ip_vs_xmit.c)
  */
-extern int ip_vs_null_xmit
-(struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
 extern int ip_vs_bypass_xmit
 (struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
 extern int ip_vs_nat_xmit
diff -urp linux.0.orig/net/ipv4/ipvs/ip_vs_conn.c linux.6.localhooks/net/ipv4/ipvs/ip_vs_conn.c
--- linux.0.orig/net/ipv4/ipvs/ip_vs_conn.c	2008-04-15 12:11:31.231179230 +0900
+++ linux.6.localhooks/net/ipv4/ipvs/ip_vs_conn.c	2008-04-15 12:09:44.191321209 +0900
@@ -350,6 +350,7 @@ static inline void ip_vs_bind_xmit(struc
 {
 	switch (IP_VS_FWD_METHOD(cp)) {
 	case IP_VS_CONN_F_MASQ:
+	case IP_VS_CONN_F_LOCALNODE:
 		cp->packet_xmit = ip_vs_nat_xmit;
 		break;
 
@@ -361,10 +362,6 @@ static inline void ip_vs_bind_xmit(struc
 		cp->packet_xmit = ip_vs_dr_xmit;
 		break;
 
-	case IP_VS_CONN_F_LOCALNODE:
-		cp->packet_xmit = ip_vs_null_xmit;
-		break;
-
 	case IP_VS_CONN_F_BYPASS:
 		cp->packet_xmit = ip_vs_bypass_xmit;
 		break;
diff -urp linux.0.orig/net/ipv4/ipvs/ip_vs_core.c linux.6.localhooks/net/ipv4/ipvs/ip_vs_core.c
--- linux.0.orig/net/ipv4/ipvs/ip_vs_core.c	2008-04-15 12:11:31.241178382 +0900
+++ linux.6.localhooks/net/ipv4/ipvs/ip_vs_core.c	2008-04-15 13:16:34.159728801 +0900
@@ -480,25 +480,6 @@ int ip_vs_leave(struct ip_vs_service *sv
 }
 
 
-/*
- *      It is hooked before NF_IP_PRI_NAT_SRC at the NF_IP_POST_ROUTING
- *      chain, and is used for VS/NAT.
- *      It detects packets for VS/NAT connections and sends the packets
- *      immediately. This can avoid that iptable_nat mangles the packets
- *      for VS/NAT.
- */
-static unsigned int ip_vs_post_routing(unsigned int hooknum,
-				       struct sk_buff *skb,
-				       const struct net_device *in,
-				       const struct net_device *out,
-				       int (*okfn)(struct sk_buff *))
-{
-	if (!skb->ipvs_property)
-		return NF_ACCEPT;
-	/* The packet was sent from IPVS, exit this chain */
-	return NF_STOP;
-}
-
 __sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset)
 {
 	return csum_fold(skb_checksum(skb, offset, skb->len - offset, 0));
@@ -659,7 +640,6 @@ static int ip_vs_out_icmp(struct sk_buff
 	/* do the statistics and put it back */
 	ip_vs_out_stats(cp, skb);
 
-	skb->ipvs_property = 1;
 	verdict = NF_ACCEPT;
 
   out:
@@ -695,9 +675,6 @@ ip_vs_out(unsigned int hooknum, struct s
 
 	EnterFunction(11);
 
-	if (skb->ipvs_property)
-		return NF_ACCEPT;
-
 	iph = ip_hdr(skb);
 	if (unlikely(iph->protocol == IPPROTO_ICMP)) {
 		int related, verdict = ip_vs_out_icmp(skb, &related);
@@ -767,23 +744,12 @@ ip_vs_out(unsigned int hooknum, struct s
 	ip_hdr(skb)->saddr = cp->vaddr;
 	ip_send_check(ip_hdr(skb));
 
-	/* For policy routing, packets originating from this
-	 * machine itself may be routed differently to packets
-	 * passing through.  We want this packet to be routed as
-	 * if it came from this machine itself.  So re-compute
-	 * the routing information.
-	 */
-	if (ip_route_me_harder(skb, RTN_LOCAL) != 0)
-		goto drop;
-
 	IP_VS_DBG_PKT(10, pp, skb, 0, "After SNAT");
 
 	ip_vs_out_stats(cp, skb);
 	ip_vs_set_state(cp, IP_VS_DIR_OUTPUT, skb, pp);
 	ip_vs_conn_put(cp);
 
-	skb->ipvs_property = 1;
-
 	LeaveFunction(11);
 	return NF_ACCEPT;
 
@@ -905,18 +871,8 @@ ip_vs_in(unsigned int hooknum, struct sk
 	int ret, restart;
 	int ihl;
 
-	/*
-	 *	Big tappo: only PACKET_HOST (neither loopback nor mcasts)
-	 *	... don't know why 1st test DOES NOT include 2nd (?)
-	 */
-	if (unlikely(skb->pkt_type != PACKET_HOST
-		     || skb->dev->flags & IFF_LOOPBACK || skb->sk)) {
-		IP_VS_DBG(12, "packet type=%d proto=%d daddr=%d.%d.%d.%d ignored\n",
-			  skb->pkt_type,
-			  ip_hdr(skb)->protocol,
-			  NIPQUAD(ip_hdr(skb)->daddr));
+	if (skb->ipvs_property)
 		return NF_ACCEPT;
-	}
 
 	iph = ip_hdr(skb);
 	if (unlikely(iph->protocol == IPPROTO_ICMP)) {
@@ -1032,8 +988,8 @@ static struct nf_hook_ops ip_vs_in_ops =
 	.hook		= ip_vs_in,
 	.owner		= THIS_MODULE,
 	.pf		= PF_INET,
-	.hooknum        = NF_IP_LOCAL_IN,
-	.priority       = 100,
+	.hooknum        = NF_IP_POST_ROUTING,
+	.priority       = NF_IP_PRI_LAST,
 };
 
 /* After packet filtering, change source only for VS/NAT */
@@ -1041,8 +997,8 @@ static struct nf_hook_ops ip_vs_out_ops 
 	.hook		= ip_vs_out,
 	.owner		= THIS_MODULE,
 	.pf		= PF_INET,
-	.hooknum        = NF_IP_FORWARD,
-	.priority       = 100,
+	.hooknum        = NF_IP_PRE_ROUTING,
+	.priority       = NF_IP_PRI_FIRST + 1,
 };
 
 /* After packet filtering (but before ip_vs_out_icmp), catch icmp
@@ -1051,17 +1007,27 @@ static struct nf_hook_ops ip_vs_forward_
 	.hook		= ip_vs_forward_icmp,
 	.owner		= THIS_MODULE,
 	.pf		= PF_INET,
-	.hooknum        = NF_IP_FORWARD,
-	.priority       = 99,
+	.hooknum        = NF_IP_PRE_ROUTING,
+	.priority       = NF_IP_PRI_FIRST + 1,
 };
 
-/* Before the netfilter connection tracking, exit from POST_ROUTING */
-static struct nf_hook_ops ip_vs_post_routing_ops = {
-	.hook		= ip_vs_post_routing,
+/* After packet filtering, change source only for VS/NAT */
+static struct nf_hook_ops ip_vs_local_out_ops = {
+	.hook		= ip_vs_out,
 	.owner		= THIS_MODULE,
 	.pf		= PF_INET,
-	.hooknum        = NF_IP_POST_ROUTING,
-	.priority       = NF_IP_PRI_NAT_SRC-1,
+	.hooknum        = NF_IP_LOCAL_OUT,
+	.priority       = NF_IP_PRI_FIRST,
+};
+
+/* After packet filtering (but before ip_vs_out_icmp), catch icmp
+   destined for 0.0.0.0/0, which is for incoming IPVS connections */
+static struct nf_hook_ops ip_vs_local_icmp_ops = {
+	.hook		= ip_vs_forward_icmp,
+	.owner		= THIS_MODULE,
+	.pf		= PF_INET,
+	.hooknum        = NF_IP_LOCAL_OUT,
+	.priority       = NF_IP_PRI_FIRST,
 };
 
 
@@ -1103,22 +1069,32 @@ static int __init ip_vs_init(void)
 		IP_VS_ERR("can't register out hook.\n");
 		goto cleanup_inops;
 	}
-	ret = nf_register_hook(&ip_vs_post_routing_ops);
+
+	ret = nf_register_hook(&ip_vs_forward_icmp_ops);
 	if (ret < 0) {
-		IP_VS_ERR("can't register post_routing hook.\n");
+		IP_VS_ERR("can't register forward_icmp hook.\n");
 		goto cleanup_outops;
 	}
-	ret = nf_register_hook(&ip_vs_forward_icmp_ops);
+
+	ret = nf_register_hook(&ip_vs_local_out_ops);
 	if (ret < 0) {
-		IP_VS_ERR("can't register forward_icmp hook.\n");
-		goto cleanup_postroutingops;
+		IP_VS_ERR("can't register local out hook.\n");
+		goto cleanup_icmpops;
+	}
+
+	ret = nf_register_hook(&ip_vs_local_icmp_ops);
+	if (ret < 0) {
+		IP_VS_ERR("can't register local icmp hook.\n");
+		goto cleanup_localout;
 	}
 
 	IP_VS_INFO("ipvs loaded.\n");
 	return ret;
 
-  cleanup_postroutingops:
-	nf_unregister_hook(&ip_vs_post_routing_ops);
+  cleanup_localout:
+    nf_unregister_hook(&ip_vs_local_out_ops);
+  cleanup_icmpops:
+    nf_unregister_hook(&ip_vs_forward_icmp_ops);
   cleanup_outops:
 	nf_unregister_hook(&ip_vs_out_ops);
   cleanup_inops:
@@ -1136,8 +1112,9 @@ static int __init ip_vs_init(void)
 
 static void __exit ip_vs_cleanup(void)
 {
+	nf_unregister_hook(&ip_vs_local_icmp_ops);
+	nf_unregister_hook(&ip_vs_local_out_ops);
 	nf_unregister_hook(&ip_vs_forward_icmp_ops);
-	nf_unregister_hook(&ip_vs_post_routing_ops);
 	nf_unregister_hook(&ip_vs_out_ops);
 	nf_unregister_hook(&ip_vs_in_ops);
 	ip_vs_conn_cleanup();
diff -urp linux.0.orig/net/ipv4/ipvs/ip_vs_proto_tcp.c linux.6.localhooks/net/ipv4/ipvs/ip_vs_proto_tcp.c
--- linux.0.orig/net/ipv4/ipvs/ip_vs_proto_tcp.c	2008-04-15 12:11:31.252178512 +0900
+++ linux.6.localhooks/net/ipv4/ipvs/ip_vs_proto_tcp.c	2008-04-15 12:10:10.866798465 +0900
@@ -535,7 +535,8 @@ tcp_app_conn_bind(struct ip_vs_conn *cp)
 	int result = 0;
 
 	/* Default binding: bind app only for NAT */
-	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
+	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ &&
+	    IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_LOCALNODE)
 		return 0;
 
 	/* Lookup application incarnations and bind the right one */
diff -urp linux.0.orig/net/ipv4/ipvs/ip_vs_proto_udp.c linux.6.localhooks/net/ipv4/ipvs/ip_vs_proto_udp.c
--- linux.0.orig/net/ipv4/ipvs/ip_vs_proto_udp.c	2008-04-15 12:11:31.260178071 +0900
+++ linux.6.localhooks/net/ipv4/ipvs/ip_vs_proto_udp.c	2008-04-15 12:10:12.805830487 +0900
@@ -329,7 +329,8 @@ static int udp_app_conn_bind(struct ip_v
 	int result = 0;
 
 	/* Default binding: bind app only for NAT */
-	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
+	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ &&
+	    IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_LOCALNODE)
 		return 0;
 
 	/* Lookup application incarnations and bind the right one */
diff -urp linux.0.orig/net/ipv4/ipvs/ip_vs_xmit.c linux.6.localhooks/net/ipv4/ipvs/ip_vs_xmit.c
--- linux.0.orig/net/ipv4/ipvs/ip_vs_xmit.c	2008-04-15 12:11:31.268178049 +0900
+++ linux.6.localhooks/net/ipv4/ipvs/ip_vs_xmit.c	2008-04-15 12:53:51.163488224 +0900
@@ -125,28 +125,15 @@ ip_vs_dst_reset(struct ip_vs_dest *dest)
 	dst_release(old_dst);
 }
 
-#define IP_VS_XMIT(skb, rt)				\
+#define IP_VS_XMIT(skb)				\
 do {							\
 	(skb)->ipvs_property = 1;			\
 	skb_forward_csum(skb);				\
-	NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, (skb), NULL,	\
-		(rt)->u.dst.dev, dst_output);		\
+	dst_output(skb);				\
 } while (0)
 
 
 /*
- *      NULL transmitter (do nothing except return NF_ACCEPT)
- */
-int
-ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		struct ip_vs_protocol *pp)
-{
-	/* we do not touch skb and do not need pskb ptr */
-	return NF_ACCEPT;
-}
-
-
-/*
  *      Bypass transmitter
  *      Let packets bypass the destination when the destination is not
  *      available, it may be only used in transparent cache cluster.
@@ -202,7 +189,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, s
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	IP_VS_XMIT(skb);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -278,7 +265,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, stru
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	IP_VS_XMIT(skb);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -413,7 +400,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, s
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	IP_VS_XMIT(skb);
 
 	LeaveFunction(10);
 
@@ -471,7 +458,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struc
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	IP_VS_XMIT(skb);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -502,7 +489,8 @@ ip_vs_icmp_xmit(struct sk_buff *skb, str
 	/* The ICMP packet for VS/TUN, VS/DR and LOCALNODE will be
 	   forwarded directly here, because there is no need to
 	   translate address/port back */
-	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
+	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ &&
+	    IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_LOCALNODE) {
 		if (cp->packet_xmit)
 			rc = cp->packet_xmit(skb, cp, pp);
 		else
@@ -544,7 +532,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, str
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	IP_VS_XMIT(skb);
 
 	rc = NF_STOLEN;
 	goto out;

--Boundary-00=_E3EBI8djD8ae5ZR--
