From: Simon Horman <horms@verge.net.au>
Subject: [rfc 3/3] ipvs: Consolidate checksuming code
Date: Mon, 08 Sep 2008 12:04:23 +1000
Message-ID: <20080908021535.451918198@vergenet.net>
References: <20080908020420.313463898@vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=ip_vs_fast_csum_update.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: =?ISO-8859-15?q?Siim=20P=C3=B5der?= <siim@p6drad-teel.net>, Julian Anastasov <ja@ssi.bg>, Malcolm Turnbull <malcolm@loadbalancer.org>, Julius Volz <juliusv@google.com>, Vince Busam <vbusam@google.com>, Herbert Xu <herbert@gondor.apana.org.au>

I'm not sure if this is a good idea, but a lot
of code is dublicated both within and between
ip_vs_proto_udp.c and ip_vs_proto_tcp.c.

This removes a small ammount of duplication.

Signed-off-by: Simon Horman <horms@verge.net.au>

--- 

 include/net/ip_vs.h             |   10 ++++++----
 net/ipv4/ipvs/ip_vs_proto.c     |   23 ++++++++++++++++++++---
 net/ipv4/ipvs/ip_vs_proto_tcp.c |   25 +++----------------------
 net/ipv4/ipvs/ip_vs_proto_udp.c |   14 ++------------
 4 files changed, 31 insertions(+), 41 deletions(-)
Index: lvs-2.6/include/net/ip_vs.h
===================================================================
--- lvs-2.6.orig/include/net/ip_vs.h	2008-09-08 10:56:29.000000000 +1000
+++ lvs-2.6/include/net/ip_vs.h	2008-09-08 11:16:46.000000000 +1000
@@ -933,11 +933,13 @@ extern void ip_vs_nat_icmp(struct sk_buf
 extern void ip_vs_nat_icmp_v6(struct sk_buff *skb, struct ip_vs_protocol *pp,
 			      struct ip_vs_conn *cp, int dir);
 
-#if defined(CONFIG_IP_VS_PROTO_TCP) || defined(CONFIG_IP_VS_PROTO_UDP)
-extern void inet_proto_csum_replace16(__sum16 *sum, struct sk_buff *skb,
-				      __be32 from[4], __be32 to[4],
-				      int pseudohdr);
 #endif
+
+#if defined(CONFIG_IP_VS_PROTO_TCP) || defined(CONFIG_IP_VS_PROTO_UDP)
+extern void ip_vs_fast_csum_update(int af, __sum16 *sum, struct sk_buff *skb,
+				   union nf_inet_addr *oldip,
+				   union nf_inet_addr *newip,
+				   __be16 old2, __be16 new2, int pseudo2);
 #endif
 
 extern __sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset);
Index: lvs-2.6/net/ipv4/ipvs/ip_vs_proto.c
===================================================================
--- lvs-2.6.orig/net/ipv4/ipvs/ip_vs_proto.c	2008-09-08 10:56:29.000000000 +1000
+++ lvs-2.6/net/ipv4/ipvs/ip_vs_proto.c	2008-09-08 11:16:46.000000000 +1000
@@ -288,9 +288,9 @@ void ip_vs_protocol_cleanup(void)
 }
 
 
-#if defined(CONFIG_IP_VS_IPV6) &&					\
-	(defined(CONFIG_IP_VS_PROTO_TCP) || defined(CONFIG_IP_VS_PROTO_UDP))
-void
+#if defined(CONFIG_IP_VS_PROTO_TCP) || defined(CONFIG_IP_VS_PROTO_UDP)
+#ifdef CONFIG_IP_VS_IPV6
+static void
 inet_proto_csum_replace16(__sum16 *sum, struct sk_buff *skb,
 			  __be32 from[4], __be32 to[4], int pseudohdr)
 {
@@ -309,3 +309,20 @@ inet_proto_csum_replace16(__sum16 *sum, 
 }
 #endif
 
+void
+ip_vs_fast_csum_update(int af, __sum16 *sum, struct sk_buff *skb,
+		       union nf_inet_addr *oldip, union nf_inet_addr *newip,
+		       __be16 old2, __be16 new2, int pseudo2)
+{
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		inet_proto_csum_replace16(sum, skb, oldip->ip6, newip->ip6, 1);
+	else
+#endif
+		inet_proto_csum_replace4(sum, skb, oldip->ip, newip->ip, 1);
+	if (new2 != old2)
+		inet_proto_csum_replace2(sum, skb, old2, new2, pseudo2);
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		skb->ip_summed = CHECKSUM_NONE;
+}
+#endif
Index: lvs-2.6/net/ipv4/ipvs/ip_vs_proto_udp.c
===================================================================
--- lvs-2.6.orig/net/ipv4/ipvs/ip_vs_proto_udp.c	2008-09-08 11:06:15.000000000 +1000
+++ lvs-2.6/net/ipv4/ipvs/ip_vs_proto_udp.c	2008-09-08 11:16:46.000000000 +1000
@@ -124,14 +124,8 @@ __udp_csum_update(int af, __sum16 *sum, 
 		       union nf_inet_addr *oldip, union nf_inet_addr *newip,
 		       __be16 old2, __be16 new2, int pseudo2)
 {
-#ifdef CONFIG_IP_VS_IPV6
-	if (af == AF_INET6)
-		inet_proto_csum_replace16(sum, skb, oldip->ip6, newip->ip6, 1);
-	else
-#endif
-		inet_proto_csum_replace4(sum, skb, oldip->ip, newip->ip, 1);
-	if (old2 != new2)
-		inet_proto_csum_replace2(sum, skb, old2, new2, pseudo2);
+	ip_vs_fast_csum_update(af, sum, skb, oldip, newip,
+			       old2, new2, pseudo2);
 	if (!*sum)
 		*sum = CSUM_MANGLED_0;
 }
@@ -201,8 +195,6 @@ udp_snat_handler(struct sk_buff *skb,
 		/* Only port and addr are changed, do fast csum update */
 		udp_fast_csum_update(cp->af, &udph->check, skb, &cp->daddr,
 				     &cp->vaddr, cp->dport, cp->vport);
-		if (skb->ip_summed == CHECKSUM_COMPLETE)
-			skb->ip_summed = CHECKSUM_NONE;
 	} else {
 		/* full checksum calculation */
 		udph->check = 0;
@@ -277,8 +269,6 @@ udp_dnat_handler(struct sk_buff *skb,
 		/* Only port and addr are changed, do fast csum update */
 		udp_fast_csum_update(cp->af, &udph->check, skb, &cp->vaddr,
 				     &cp->daddr, cp->vport, cp->dport);
-		if (skb->ip_summed == CHECKSUM_COMPLETE)
-			skb->ip_summed = CHECKSUM_NONE;
 	} else {
 		/* full checksum calculation */
 		udph->check = 0;
Index: lvs-2.6/net/ipv4/ipvs/ip_vs_proto_tcp.c
===================================================================
--- lvs-2.6.orig/net/ipv4/ipvs/ip_vs_proto_tcp.c	2008-09-08 11:03:30.000000000 +1000
+++ lvs-2.6/net/ipv4/ipvs/ip_vs_proto_tcp.c	2008-09-08 11:16:46.000000000 +1000
@@ -114,27 +114,12 @@ tcp_conn_schedule(int af, struct sk_buff
 
 
 static inline void
-__tcp_csum_update(int af, __sum16 *sum, struct sk_buff *skb,
-		     union nf_inet_addr *oldip, union nf_inet_addr *newip,
-		     __be16 old2, __be16 new2, int pseudo2)
-{
-#ifdef CONFIG_IP_VS_IPV6
-	if (af == AF_INET6)
-		inet_proto_csum_replace16(sum, skb, oldip->ip6, newip->ip6, 1);
-	else
-#endif
-		inet_proto_csum_replace4(sum, skb, oldip->ip, newip->ip, 1);
-	if (old2 != new2)
-		inet_proto_csum_replace2(sum, skb, old2, new2, pseudo2);
-}
-
-
-static inline void
 tcp_fast_csum_update(int af, __sum16 *sum, struct sk_buff *skb,
 		     union nf_inet_addr *oldip, union nf_inet_addr *newip,
 		     __be16 oldport, __be16 newport)
 {
-	__tcp_csum_update(af, sum, skb, oldip, newip, oldport, newport, 0);
+	ip_vs_fast_csum_update(af, sum, skb, oldip, newip,
+			       oldport, newport, 0);
 }
 
 
@@ -143,7 +128,7 @@ tcp_partial_csum_update(int af, __sum16 
 		     union nf_inet_addr *oldip, union nf_inet_addr *newip,
 		     __be16 oldlen, __be16 newlen)
 {
-	__tcp_csum_update(af, sum, skb, oldip, newip, oldlen, newlen, 1);
+	ip_vs_fast_csum_update(af, sum, skb, oldip, newip, oldlen, newlen, 1);
 }
 
 
@@ -189,8 +174,6 @@ tcp_snat_handler(struct sk_buff *skb,
 		/* Only port and addr are changed, do fast csum update */
 		tcp_fast_csum_update(cp->af, &tcph->check, skb, &cp->daddr,
 				     &cp->vaddr, cp->dport, cp->vport);
-		if (skb->ip_summed == CHECKSUM_COMPLETE)
-			skb->ip_summed = CHECKSUM_NONE;
 	} else {
 		/* full checksum calculation */
 		tcph->check = 0;
@@ -264,8 +247,6 @@ tcp_dnat_handler(struct sk_buff *skb,
 		/* Only port and addr are changed, do fast csum update */
 		tcp_fast_csum_update(cp->af, &tcph->check, skb, &cp->vaddr,
 				     &cp->daddr, cp->vport, cp->dport);
-		if (skb->ip_summed == CHECKSUM_COMPLETE)
-			skb->ip_summed = CHECKSUM_NONE;
 	} else {
 		/* full checksum calculation */
 		tcph->check = 0;

-- 
