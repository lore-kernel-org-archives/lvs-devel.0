From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: [PATCH 5/6] move ipvs to PRE/POSTROUTING
Date: Tue, 15 Apr 2008 15:42:50 +0900
Message-ID: <200804151542.51050.j.stubbs@linkthink.co.jp>
References: <200804151540.04006.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_r5EBI3KJxS0o1Me"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804151540.04006.j.stubbs@linkthink.co.jp>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: LVS Devel <lvs-devel@vger.kernel.org>

--Boundary-00=_r5EBI3KJxS0o1Me
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Currently, VIPs are (usually) bound on local interfaces and LVS is
handled in the INPUT chain. This means that local node traffic can
simply be passed on. With VIPs not being on bound and LVS handled in
POSTROUTING, packets need to be redirected to a local address. This
patch essentially alises LOCALNODE to MASQ.

After dst_output and the second POSTROUTING, packets are then sent
through PREROUTING and INPUT and finally handled locally.

-- 
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
東京都渋谷区桜ヶ丘町22-14 N.E.S S棟 3F
TEL 03-5728-4772  FAX 03-5728-4773

--Boundary-00=_r5EBI3KJxS0o1Me
Content-Type: text/x-diff;
  charset="iso-2022-jp";
  name="5-localmasq.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="5-localmasq.patch"

diff -urp linux.4.recursion/include/net/ip_vs.h linux.5.localmasq/include/net/ip_vs.h
--- linux.4.recursion/include/net/ip_vs.h	2008-04-15 13:00:23.839450725 +0900
+++ linux.5.localmasq/include/net/ip_vs.h	2008-04-15 13:11:38.598267552 +0900
@@ -901,8 +901,6 @@ extern void ip_vs_zero_estimator(struct 
 /*
  *	Various IPVS packet transmitters (from ip_vs_xmit.c)
  */
-extern int ip_vs_null_xmit
-(struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
 extern int ip_vs_bypass_xmit
 (struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
 extern int ip_vs_nat_xmit
diff -urp linux.4.recursion/net/ipv4/ipvs/ip_vs_conn.c linux.5.localmasq/net/ipv4/ipvs/ip_vs_conn.c
--- linux.4.recursion/net/ipv4/ipvs/ip_vs_conn.c	2008-04-15 13:00:23.816451933 +0900
+++ linux.5.localmasq/net/ipv4/ipvs/ip_vs_conn.c	2008-04-15 13:12:02.369724437 +0900
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
diff -urp linux.4.recursion/net/ipv4/ipvs/ip_vs_proto_tcp.c linux.5.localmasq/net/ipv4/ipvs/ip_vs_proto_tcp.c
--- linux.4.recursion/net/ipv4/ipvs/ip_vs_proto_tcp.c	2008-04-15 13:00:23.831450461 +0900
+++ linux.5.localmasq/net/ipv4/ipvs/ip_vs_proto_tcp.c	2008-04-15 13:13:52.208208897 +0900
@@ -535,7 +535,8 @@ tcp_app_conn_bind(struct ip_vs_conn *cp)
 	int result = 0;
 
 	/* Default binding: bind app only for NAT */
-	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
+	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ &&
+	    IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_LOCALNODE)
 		return 0;
 
 	/* Lookup application incarnations and bind the right one */
diff -urp linux.4.recursion/net/ipv4/ipvs/ip_vs_proto_udp.c linux.5.localmasq/net/ipv4/ipvs/ip_vs_proto_udp.c
--- linux.4.recursion/net/ipv4/ipvs/ip_vs_proto_udp.c	2008-04-15 13:00:23.839450725 +0900
+++ linux.5.localmasq/net/ipv4/ipvs/ip_vs_proto_udp.c	2008-04-15 13:14:14.917502969 +0900
@@ -329,7 +329,8 @@ static int udp_app_conn_bind(struct ip_v
 	int result = 0;
 
 	/* Default binding: bind app only for NAT */
-	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
+	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ &&
+	    IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_LOCALNODE)
 		return 0;
 
 	/* Lookup application incarnations and bind the right one */
diff -urp linux.4.recursion/net/ipv4/ipvs/ip_vs_xmit.c linux.5.localmasq/net/ipv4/ipvs/ip_vs_xmit.c
--- linux.4.recursion/net/ipv4/ipvs/ip_vs_xmit.c	2008-04-15 13:00:23.839450725 +0900
+++ linux.5.localmasq/net/ipv4/ipvs/ip_vs_xmit.c	2008-04-15 13:15:13.495094478 +0900
@@ -134,18 +134,6 @@ do {							\
 
 
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
--Boundary-00=_r5EBI3KJxS0o1Me--
