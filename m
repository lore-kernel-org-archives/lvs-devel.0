From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: [PATCH 3/6] move ipvs to PRE/POSTROUTING
Date: Tue, 15 Apr 2008 15:41:50 +0900
Message-ID: <200804151541.50766.j.stubbs@linkthink.co.jp>
References: <200804151540.04006.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_u4EBIAi2vh/9c8w"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804151540.04006.j.stubbs@linkthink.co.jp>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: LVS Devel <lvs-devel@vger.kernel.org>

--Boundary-00=_u4EBIAi2vh/9c8w
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I'm not entirely certain of what these two chunks are meant to do but
they prevent things from working with my other changes. Please let me
know if any of it may still be required.

-- 
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
東京都渋谷区桜ヶ丘町22-14 N.E.S S棟 3F
TEL 03-5728-4772  FAX 03-5728-4773

--Boundary-00=_u4EBIAi2vh/9c8w
Content-Type: text/x-diff;
  charset="iso-2022-jp";
  name="3-routing.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="3-routing.patch"

diff -urp linux.2.xmit/net/ipv4/ipvs/ip_vs_core.c linux.3.routing/net/ipv4/ipvs/ip_vs_core.c
--- linux.2.xmit/net/ipv4/ipvs/ip_vs_core.c	2008-04-15 13:06:36.599471434 +0900
+++ linux.3.routing/net/ipv4/ipvs/ip_vs_core.c	2008-04-15 13:06:50.942660390 +0900
@@ -748,15 +748,6 @@ ip_vs_out(unsigned int hooknum, struct s
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
@@ -886,19 +877,6 @@ ip_vs_in(unsigned int hooknum, struct sk
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
-		return NF_ACCEPT;
-	}
--Boundary-00=_u4EBIAi2vh/9c8w--
