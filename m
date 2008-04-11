From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: moving ipvs() to POST/PREROUTING
Date: Fri, 11 Apr 2008 14:00:12 +0900
Message-ID: <200804111400.12331.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_cBv/HdQ1KUL2ljn"
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: LVS Devel <lvs-devel@vger.kernel.org>

--Boundary-00=_cBv/HdQ1KUL2ljn
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Greetings,

Ok, things are mostly working now. The patch is a little messy as in there'=
s=20
old comments remaining and function names are left as is, but hopefully=20
reviewable. If it's not, I'll split it up and add appropriate comments...

=46unctions I've tested with the patch:
* LVS-NAT
* LVS-NAT + SNAT
* LVS-DR
* local node

With local node, 127.0.0.1 doesn't work but an IP address on a local interf=
ace=20
does. When the address is 127.0.0.1, the SYN makes it all the way through=20
INPUT, but the SYN/ACK doesn't come into OUTPUT. Something to investigate=20
further... Also, null_xmit doesn't work as ipvs_in is being done in=20
POSTROUTING, so I've simple aliased LOCAL to MASQ for the time being.

What I haven't tested:
* LVS-TUN
* ICMP for LVS-NAT
* IP_VS_CONN_F_BYPASS - what is this?
* likely others ;)

LVS-TUN should work as LVS-DR didn't require any direct modification, but i=
t's=20
a little bit of a pain to set up for testing at this stage. I'm not sure ho=
w=20
I should go about testing the others.

I realized I haven't explained at all why I chose POST/PRE as the hook poin=
ts.=20
=46irstly the cropped output from a LOG target in every mangle table for th=
e=20
SYN SYN/ACK of a LVS-NAT connection:

PREROUTING IN=3Deth0 OUT=3D SRC=3D192.168.0.104 DST=3D192.168.0.SYN
=46ORWARD IN=3Deth0 OUT=3Deth0 SRC=3D192.168.0.104 DST=3D192.168.0.7 SYN
POSTROUTING IN=3D OUT=3Deth0 SRC=3D192.168.0.104 DST=3D192.168.0.7 SYN
POSTROUTING IN=3D OUT=3Deth1 SRC=3D192.168.0.104 DST=3D192.168.1.3 SYN

PREROUTING IN=3Deth1 OUT=3D SRC=3D192.168.0.7 DST=3D192.168.0.104 ACK SYN
=46ORWARD IN=3Deth1 OUT=3Deth0 SRC=3D192.168.0.7 DST=3D192.168.0.104 ACK SYN
POSTROUTING IN=3D OUT=3Deth0 SRC=3D192.168.0.7 DST=3D192.168.0.104 ACK SYN

192.168.0.104 is the client, 192.168.0.7 is the VIP and 192.168.1.3 is the=
=20
real server. Other than the second POSTROUTING entry on the SYN side,=20
netfilter isn't dealing with the real server's IP at all. This will=20
theoretically make writing firewall rules much easier and also limits what=
=20
netfilter's conntracking has to deal with.

Actually, I don't know why the second POSTROUTING entry is there at all. It=
=20
seems that after the packet is injected into the end of POSTROUTING, a=20
routing decision is being made again and POSTROUTING is rerun. Preferable t=
he=20
packet would go straight out the appropriate interface after ipvs_in is run.

Similar behaviour happens with a local node:

PREROUTING IN=3Deth0 OUT=3D SRC=3D192.168.0.104 DST=3D192.168.0.7 SYN
=46ORWARD IN=3Deth0 OUT=3Deth0 SRC=3D192.168.0.104 DST=3D192.168.0.7 SYN
POSTROUTING IN=3D OUT=3Deth0 SRC=3D192.168.0.104 DST=3D192.168.0.7 SYN
POSTROUTING IN=3D OUT=3Dlo SRC=3D192.168.0.104 DST=3D192.168.0.5 SYN
PREROUTING IN=3Dlo OUT=3D SRC=3D192.168.0.104 DST=3D192.168.0.5 SYN
INPUT IN=3Dlo OUT=3D SRC=3D192.168.0.104 DST=3D192.168.0.5 SYN

OUTPUT IN=3D OUT=3Deth0 SRC=3D192.168.0.7 DST=3D192.168.0.104 ACK SYN
POSTROUTING IN=3D OUT=3Deth0 SRC=3D192.168.0.7 DST=3D192.168.0.104 ACK SYN

192.168.0.5 is an IP local to the director. I had to add the ipvs_out hooks=
 to=20
the beginning of OUTPUT as the local reply never hits PREROUTING. Again wit=
h=20
the above, I'd prefer the POST/PRE/INPUT disappear.

Anyway, that's pretty much my intention. Is there any problem with essentia=
lly=20
hiding the real servers from netfilter? Is there a way to get the packet ou=
t=20
of the netfilter loop earlier?

=2D-=20
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
=E6=9D=B1=E4=BA=AC=E9=83=BD=E6=B8=8B=E8=B0=B7=E5=8C=BA=E6=A1=9C=E3=83=B6=E4=
=B8=98=E7=94=BA22-14 N.E.S S=E6=A3=9F 3F
TEL 03-5728-4772  FAX 03-5728-4773

--Boundary-00=_cBv/HdQ1KUL2ljn
Content-Type: text/x-diff;
  charset="utf-8";
  name="ip_vs_prepost.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="ip_vs_prepost.patch"

--- linux-2.6.24-gentoo-r4/net/ipv4/ipvs/ip_vs_core.c	2008-01-25 07:58:37.000000000 +0900
+++ linux-2.6.24-gentoo-r4-jason/net/ipv4/ipvs/ip_vs_core.c	2008-04-11 12:56:38.000000000 +0900
@@ -480,25 +480,6 @@
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
@@ -767,15 +748,6 @@
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
@@ -905,18 +877,8 @@
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
@@ -1032,8 +994,8 @@
 	.hook		= ip_vs_in,
 	.owner		= THIS_MODULE,
 	.pf		= PF_INET,
-	.hooknum        = NF_IP_LOCAL_IN,
-	.priority       = 100,
+	.hooknum        = NF_IP_POST_ROUTING,
+	.priority       = NF_IP_PRI_LAST,
 };
 
 /* After packet filtering, change source only for VS/NAT */
@@ -1041,8 +1003,17 @@
 	.hook		= ip_vs_out,
 	.owner		= THIS_MODULE,
 	.pf		= PF_INET,
-	.hooknum        = NF_IP_FORWARD,
-	.priority       = 100,
+	.hooknum        = NF_IP_PRE_ROUTING,
+	.priority       = NF_IP_PRI_FIRST+1,
+};
+
+/* After packet filtering, change source only for VS/NAT */
+static struct nf_hook_ops ip_vs_local_out_ops = {
+	.hook		= ip_vs_out,
+	.owner		= THIS_MODULE,
+	.pf		= PF_INET,
+	.hooknum        = NF_IP_LOCAL_OUT,
+	.priority       = NF_IP_PRI_FIRST+1,
 };
 
 /* After packet filtering (but before ip_vs_out_icmp), catch icmp
@@ -1051,17 +1022,18 @@
 	.hook		= ip_vs_forward_icmp,
 	.owner		= THIS_MODULE,
 	.pf		= PF_INET,
-	.hooknum        = NF_IP_FORWARD,
-	.priority       = 99,
+	.hooknum        = NF_IP_PRE_ROUTING,
+	.priority       = NF_IP_PRI_FIRST,
 };
 
-/* Before the netfilter connection tracking, exit from POST_ROUTING */
-static struct nf_hook_ops ip_vs_post_routing_ops = {
-	.hook		= ip_vs_post_routing,
+/* After packet filtering (but before ip_vs_out_icmp), catch icmp
+   destined for 0.0.0.0/0, which is for incoming IPVS connections */
+static struct nf_hook_ops ip_vs_local_icmp_ops = {
+	.hook		= ip_vs_forward_icmp,
 	.owner		= THIS_MODULE,
 	.pf		= PF_INET,
-	.hooknum        = NF_IP_POST_ROUTING,
-	.priority       = NF_IP_PRI_NAT_SRC-1,
+	.hooknum        = NF_IP_LOCAL_OUT,
+	.priority       = NF_IP_PRI_FIRST,
 };
 
 
@@ -1103,22 +1075,32 @@
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
@@ -1137,7 +1119,6 @@
 static void __exit ip_vs_cleanup(void)
 {
 	nf_unregister_hook(&ip_vs_forward_icmp_ops);
-	nf_unregister_hook(&ip_vs_post_routing_ops);
 	nf_unregister_hook(&ip_vs_out_ops);
 	nf_unregister_hook(&ip_vs_in_ops);
 	ip_vs_conn_cleanup();
--- linux-2.6.24-gentoo-r4/net/ipv4/ipvs/ip_vs_ctl.c	2008-01-25 07:58:37.000000000 +0900
+++ linux-2.6.24-gentoo-r4-jason/net/ipv4/ipvs/ip_vs_ctl.c	2008-04-11 12:23:59.000000000 +0900
@@ -706,7 +706,7 @@
 	/* check if local node and update the flags */
 	if (inet_addr_type(udest->addr) == RTN_LOCAL) {
 		conn_flags = (conn_flags & ~IP_VS_CONN_F_FWD_MASK)
-			| IP_VS_CONN_F_LOCALNODE;
+			| IP_VS_CONN_F_MASQ;
 	}
 
 	/* set the IP_VS_CONN_F_NOOUTPUT flag if not masquerading/NAT */
--- linux-2.6.24-gentoo-r4/net/ipv4/ipvs/ip_vs_xmit.c	2008-04-10 18:20:03.000000000 +0900
+++ linux-2.6.24-gentoo-r4-jason/net/ipv4/ipvs/ip_vs_xmit.c	2008-04-11 12:15:14.000000000 +0900
@@ -129,8 +129,8 @@
 do {							\
 	(skb)->ipvs_property = 1;			\
 	skb_forward_csum(skb);				\
-	NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, (skb), NULL,	\
-		(rt)->u.dst.dev, dst_output);		\
+	NF_HOOK_THRESH(PF_INET, NF_IP_POST_ROUTING, (skb), NULL,	\
+		(rt)->u.dst.dev, dst_output, NF_IP_PRI_LAST);		\
 } while (0)
 
 

--Boundary-00=_cBv/HdQ1KUL2ljn--
