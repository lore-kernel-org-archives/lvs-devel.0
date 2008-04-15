From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: [PATCH 4/6] move ipvs to PRE/POSTROUTING
Date: Tue, 15 Apr 2008 15:42:23 +0900
Message-ID: <200804151542.23772.j.stubbs@linkthink.co.jp>
References: <200804151540.04006.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_P5EBIiiP92Q8eyq"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804151540.04006.j.stubbs@linkthink.co.jp>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: LVS Devel <lvs-devel@vger.kernel.org>

--Boundary-00=_P5EBIiiP92Q8eyq
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Packets that have been processed by LVS are being sent out immediately
meaning that there's no chance for looping in ip_vs_out so I removed
the ipvs_property sets/checks from those paths. Packets that have been
sent out first go through POSTROUTING (again) and aren't changed in the
case of LVS-DR and LVS-TUN so I've used the flag to prevent an infinite
loop in ip_vs_in.

-- 
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
東京都渋谷区桜ヶ丘町22-14 N.E.S S棟 3F
TEL 03-5728-4772  FAX 03-5728-4773

--Boundary-00=_P5EBIiiP92Q8eyq
Content-Type: text/x-diff;
  charset="iso-2022-jp";
  name="4-recursion.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="4-recursion.patch"

diff -urp linux.3.routing/net/ipv4/ipvs/ip_vs_core.c linux.4.recursion/net/ipv4/ipvs/ip_vs_core.c
--- linux.3.routing/net/ipv4/ipvs/ip_vs_core.c	2008-04-15 13:06:50.942660390 +0900
+++ linux.4.recursion/net/ipv4/ipvs/ip_vs_core.c	2008-04-15 13:07:04.424842262 +0900
@@ -640,7 +640,6 @@ static int ip_vs_out_icmp(struct sk_buff
 	/* do the statistics and put it back */
 	ip_vs_out_stats(cp, skb);
 
-	skb->ipvs_property = 1;
 	verdict = NF_ACCEPT;
 
   out:
@@ -676,9 +675,6 @@ ip_vs_out(unsigned int hooknum, struct s
 
 	EnterFunction(11);
 
-	if (skb->ipvs_property)
-		return NF_ACCEPT;
-
 	iph = ip_hdr(skb);
 	if (unlikely(iph->protocol == IPPROTO_ICMP)) {
 		int related, verdict = ip_vs_out_icmp(skb, &related);
@@ -754,8 +750,6 @@ ip_vs_out(unsigned int hooknum, struct s
 	ip_vs_set_state(cp, IP_VS_DIR_OUTPUT, skb, pp);
 	ip_vs_conn_put(cp);
 
-	skb->ipvs_property = 1;
--Boundary-00=_P5EBIiiP92Q8eyq--
