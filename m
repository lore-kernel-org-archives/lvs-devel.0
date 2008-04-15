From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: [PATCH 2/6] move ipvs to PRE/POSTROUTING
Date: Tue, 15 Apr 2008 15:41:17 +0900
Message-ID: <200804151541.17117.j.stubbs@linkthink.co.jp>
References: <200804151540.04006.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_N4EBIxmP4uE/TFq"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804151540.04006.j.stubbs@linkthink.co.jp>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: LVS Devel <lvs-devel@vger.kernel.org>

--Boundary-00=_N4EBIxmP4uE/TFq
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Currently, LVS steals packets from the INPUT chain, processes them and
then asks netfilter to run them through the OUTPUT chain and to run
dst_output if the packet is accepted. With the previous patch, packets
are now being stolen from the end of POSTROUTING. This patch makes
processed packets sent straight to dst_output, which then recalculates
routing information and sends the packet through POSTROUTING again.

I'm not completely certain on the conntrack behaviour for the second
POSTROUTING run, but it is not causing any issues.

I am also not certain of how traffic control will handle this. This
patch may be causing traffic to be accounted for twice depending on when
tcp_output is actually run.

There is also the chance that the routing decision made based on
sending to the VIP caused a packet to be fragmented when it didn't need
to be. This could cause some performance issues.

Finally, as rt isn't being passed to IP_VS_XMIT any more, some of the
operations with rt prior to IP_VS_XMIT may no longer be necessary. I've
left them as is for the time being.

-- 
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
東京都渋谷区桜ヶ丘町22-14 N.E.S S棟 3F
TEL 03-5728-4772  FAX 03-5728-4773

--Boundary-00=_N4EBIxmP4uE/TFq
Content-Type: text/x-diff;
  charset="iso-2022-jp";
  name="2-xmit.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="2-xmit.patch"

diff -urp linux.1.rehook/net/ipv4/ipvs/ip_vs_xmit.c linux.2.xmit/net/ipv4/ipvs/ip_vs_xmit.c
--- linux.1.rehook/net/ipv4/ipvs/ip_vs_xmit.c	2008-04-15 12:11:31.000000000 +0900
+++ linux.2.xmit/net/ipv4/ipvs/ip_vs_xmit.c	2008-04-15 12:54:11.381207284 +0900
@@ -125,12 +125,11 @@ ip_vs_dst_reset(struct ip_vs_dest *dest)
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
 
 
@@ -202,7 +201,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, s
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	IP_VS_XMIT(skb);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -278,7 +277,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, stru
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	IP_VS_XMIT(skb);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -413,7 +412,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, s
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	IP_VS_XMIT(skb);
 
 	LeaveFunction(10);
 
@@ -471,7 +470,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struc
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	IP_VS_XMIT(skb);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -544,7 +543,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, str
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(skb, rt);
+	IP_VS_XMIT(skb);
 
 	rc = NF_STOLEN;
 	goto out;

--Boundary-00=_N4EBIxmP4uE/TFq--
