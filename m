From: Simon Horman <horms@verge.net.au>
Subject: [rfc 2/3] ipvs: Use inet_proto_csum_replace*()
Date: Mon, 08 Sep 2008 12:04:22 +1000
Message-ID: <20080908021535.275124207@vergenet.net>
References: <20080908020420.313463898@vergenet.net>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline; filename=inet_proto_csum_replace16.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: =?ISO-8859-15?q?Siim=20P=C3=B5der?= <siim@p6drad-teel.net>, Julian Anastasov <ja@ssi.bg>, Malcolm Turnbull <malcolm@loadbalancer.org>, Julius Volz <juliusv@google.com>, Vince Busam <vbusam@google.com>, Herbert Xu <herbert@gondor.apana.org.au>

Implement IPVS checksuming functions using the common
inet_proto_csum_replace*() functions. This patch adds
inet_proto_csum_replace16() to handle IPv6, which isn't
provided by netfilter as it doesn't handle IPv6 NAT.

Signed-off-by: Simon Horman <horms@verge.net.au>

--- 

 include/net/ip_vs.h             |   31 +++---------------
 net/ipv4/ipvs/ip_vs_proto.c     |   23 +++++++++++++
 net/ipv4/ipvs/ip_vs_proto_tcp.c |   62 +++++++++++++++---------------------
 net/ipv4/ipvs/ip_vs_proto_udp.c |   67 +++++++++++++++++----------------------
 4 files changed, 86 insertions(+), 97 deletions(-)
Index: lvs-2.6/include/net/ip_vs.h
===================================================================
--- lvs-2.6.orig/include/net/ip_vs.h	2008-09-08 10:55:51.000000000 +1000
+++ lvs-2.6/include/net/ip_vs.h	2008-09-08 11:16:55.000000000 +1000
@@ -932,34 +932,15 @@ extern void ip_vs_nat_icmp(struct sk_buf
 #ifdef CONFIG_IP_VS_IPV6
 extern void ip_vs_nat_icmp_v6(struct sk_buff *skb, struct ip_vs_protocol *pp,
 			      struct ip_vs_conn *cp, int dir);
-#endif
-
-extern __sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset);
-
-static inline __wsum ip_vs_check_diff4(__be32 old, __be32 new, __wsum oldsum)
-{
-	__be32 diff[2] = { ~old, new };
-
-	return csum_partial((char *) diff, sizeof(diff), oldsum);
-}
 
-#ifdef CONFIG_IP_VS_IPV6
-static inline __wsum ip_vs_check_diff16(const __be32 *old, const __be32 *new,
-					__wsum oldsum)
-{
-	__be32 diff[8] = { ~old[3], ~old[2], ~old[1], ~old[0],
-			    new[3],  new[2],  new[1],  new[0] };
-
-	return csum_partial((char *) diff, sizeof(diff), oldsum);
-}
+#if defined(CONFIG_IP_VS_PROTO_TCP) || defined(CONFIG_IP_VS_PROTO_UDP)
+extern void inet_proto_csum_replace16(__sum16 *sum, struct sk_buff *skb,
+				      __be32 from[4], __be32 to[4],
+				      int pseudohdr);
+#endif
 #endif
 
-static inline __wsum ip_vs_check_diff2(__be16 old, __be16 new, __wsum oldsum)
-{
-	__be16 diff[2] = { ~old, new };
-
-	return csum_partial((char *) diff, sizeof(diff), oldsum);
-}
+extern __sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset);
 
 #endif /* __KERNEL__ */
 
Index: lvs-2.6/net/ipv4/ipvs/ip_vs_proto.c
===================================================================
--- lvs-2.6.orig/net/ipv4/ipvs/ip_vs_proto.c	2008-09-08 10:55:51.000000000 +1000
+++ lvs-2.6/net/ipv4/ipvs/ip_vs_proto.c	2008-09-08 11:16:55.000000000 +1000
@@ -286,3 +286,26 @@ void ip_vs_protocol_cleanup(void)
 			unregister_ip_vs_protocol(pp);
 	}
 }
+
+
+#if defined(CONFIG_IP_VS_IPV6) &&					\
+	(defined(CONFIG_IP_VS_PROTO_TCP) || defined(CONFIG_IP_VS_PROTO_UDP))
+void
+inet_proto_csum_replace16(__sum16 *sum, struct sk_buff *skb,
+			  __be32 from[4], __be32 to[4], int pseudohdr)
+{
+	__be32 diff[8] = { ~from[3], ~from[2], ~from[1], ~from[0],
+			   to[3],  to[2],  to[1], to[0] };
+
+	if (skb->ip_summed != CHECKSUM_PARTIAL) {
+		*sum = csum_fold(csum_partial(diff, sizeof(diff),
+				~csum_unfold(*sum)));
+		if (skb->ip_summed == CHECKSUM_COMPLETE && pseudohdr)
+			skb->csum = ~csum_partial(diff, sizeof(diff),
+						~skb->csum);
+	} else if (pseudohdr)
+		*sum = ~csum_fold(csum_partial(diff, sizeof(diff),
+				csum_unfold(*sum)));
+}
+#endif
+
Index: lvs-2.6/net/ipv4/ipvs/ip_vs_proto_tcp.c
===================================================================
--- lvs-2.6.orig/net/ipv4/ipvs/ip_vs_proto_tcp.c	2008-09-08 10:56:14.000000000 +1000
+++ lvs-2.6/net/ipv4/ipvs/ip_vs_proto_tcp.c	2008-09-08 11:16:55.000000000 +1000
@@ -114,44 +114,36 @@ tcp_conn_schedule(int af, struct sk_buff
 
 
 static inline void
-tcp_fast_csum_update(int af, struct tcphdr *tcph,
-		     const union nf_inet_addr *oldip,
-		     const union nf_inet_addr *newip,
-		     __be16 oldport, __be16 newport)
+__tcp_csum_update(int af, __sum16 *sum, struct sk_buff *skb,
+		     union nf_inet_addr *oldip, union nf_inet_addr *newip,
+		     __be16 old2, __be16 new2, int pseudo2)
 {
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6)
-		tcph->check =
-			csum_fold(ip_vs_check_diff16(oldip->ip6, newip->ip6,
-					 ip_vs_check_diff2(oldport, newport,
-						~csum_unfold(tcph->check))));
+		inet_proto_csum_replace16(sum, skb, oldip->ip6, newip->ip6, 1);
 	else
 #endif
-	tcph->check =
-		csum_fold(ip_vs_check_diff4(oldip->ip, newip->ip,
-				 ip_vs_check_diff2(oldport, newport,
-						~csum_unfold(tcph->check))));
+		inet_proto_csum_replace4(sum, skb, oldip->ip, newip->ip, 1);
+	if (old2 != new2)
+		inet_proto_csum_replace2(sum, skb, old2, new2, pseudo2);
 }
 
 
 static inline void
-tcp_partial_csum_update(int af, struct tcphdr *tcph,
-		     const union nf_inet_addr *oldip,
-		     const union nf_inet_addr *newip,
+tcp_fast_csum_update(int af, __sum16 *sum, struct sk_buff *skb,
+		     union nf_inet_addr *oldip, union nf_inet_addr *newip,
+		     __be16 oldport, __be16 newport)
+{
+	__tcp_csum_update(af, sum, skb, oldip, newip, oldport, newport, 0);
+}
+
+
+static inline void
+tcp_partial_csum_update(int af, __sum16 *sum, struct sk_buff *skb,
+		     union nf_inet_addr *oldip, union nf_inet_addr *newip,
 		     __be16 oldlen, __be16 newlen)
 {
-#ifdef CONFIG_IP_VS_IPV6
-	if (af == AF_INET6)
-		tcph->check =
-			csum_fold(ip_vs_check_diff16(oldip->ip6, newip->ip6,
-					 ip_vs_check_diff2(oldlen, newlen,
-						~csum_unfold(tcph->check))));
-	else
-#endif
-	tcph->check =
-		csum_fold(ip_vs_check_diff4(oldip->ip, newip->ip,
-				ip_vs_check_diff2(oldlen, newlen,
-						~csum_unfold(tcph->check))));
+	__tcp_csum_update(af, sum, skb, oldip, newip, oldlen, newlen, 1);
 }
 
 
@@ -190,13 +182,13 @@ tcp_snat_handler(struct sk_buff *skb,
 
 	/* Adjust TCP checksums */
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		tcp_partial_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
-					htonl(oldlen),
+		tcp_partial_csum_update(cp->af, &tcph->check, skb, &cp->daddr,
+					&cp->vaddr, htonl(oldlen),
 					htonl(skb->len - tcphoff));
 	} else if (!cp->app) {
 		/* Only port and addr are changed, do fast csum update */
-		tcp_fast_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
-				     cp->dport, cp->vport);
+		tcp_fast_csum_update(cp->af, &tcph->check, skb, &cp->daddr,
+				     &cp->vaddr, cp->dport, cp->vport);
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
 			skb->ip_summed = CHECKSUM_NONE;
 	} else {
@@ -265,13 +257,13 @@ tcp_dnat_handler(struct sk_buff *skb,
 	 *	Adjust TCP checksums
 	 */
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		tcp_partial_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
-					htonl(oldlen),
+		tcp_partial_csum_update(cp->af, &tcph->check, skb, &cp->daddr,
+					&cp->vaddr, htonl(oldlen),
 					htonl(skb->len - tcphoff));
 	} else if (!cp->app) {
 		/* Only port and addr are changed, do fast csum update */
-		tcp_fast_csum_update(cp->af, tcph, &cp->vaddr, &cp->daddr,
-				     cp->vport, cp->dport);
+		tcp_fast_csum_update(cp->af, &tcph->check, skb, &cp->vaddr,
+				     &cp->daddr, cp->vport, cp->dport);
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
 			skb->ip_summed = CHECKSUM_NONE;
 	} else {
Index: lvs-2.6/net/ipv4/ipvs/ip_vs_proto_udp.c
===================================================================
--- lvs-2.6.orig/net/ipv4/ipvs/ip_vs_proto_udp.c	2008-09-08 10:56:14.000000000 +1000
+++ lvs-2.6/net/ipv4/ipvs/ip_vs_proto_udp.c	2008-09-08 11:16:55.000000000 +1000
@@ -120,45 +120,38 @@ udp_conn_schedule(int af, struct sk_buff
 
 
 static inline void
-udp_fast_csum_update(int af, struct udphdr *uhdr,
-		     const union nf_inet_addr *oldip,
-		     const union nf_inet_addr *newip,
-		     __be16 oldport, __be16 newport)
+__udp_csum_update(int af, __sum16 *sum, struct sk_buff *skb,
+		       union nf_inet_addr *oldip, union nf_inet_addr *newip,
+		       __be16 old2, __be16 new2, int pseudo2)
 {
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6)
-		uhdr->check =
-			csum_fold(ip_vs_check_diff16(oldip->ip6, newip->ip6,
-					 ip_vs_check_diff2(oldport, newport,
-						~csum_unfold(uhdr->check))));
+		inet_proto_csum_replace16(sum, skb, oldip->ip6, newip->ip6, 1);
 	else
 #endif
-		uhdr->check =
-			csum_fold(ip_vs_check_diff4(oldip->ip, newip->ip,
-					 ip_vs_check_diff2(oldport, newport,
-						~csum_unfold(uhdr->check))));
-	if (!uhdr->check)
-		uhdr->check = CSUM_MANGLED_0;
+		inet_proto_csum_replace4(sum, skb, oldip->ip, newip->ip, 1);
+	if (old2 != new2)
+		inet_proto_csum_replace2(sum, skb, old2, new2, pseudo2);
+	if (!*sum)
+		*sum = CSUM_MANGLED_0;
+}
+
+
+static inline void
+udp_fast_csum_update(int af, __sum16 *sum, struct sk_buff *skb,
+		     union nf_inet_addr *oldip, union nf_inet_addr *newip,
+		     __be16 oldport, __be16 newport)
+{
+	__udp_csum_update(af, sum, skb, oldip, newip, oldport, newport, 0);
 }
 
+
 static inline void
-udp_partial_csum_update(int af, struct udphdr *uhdr,
-		     const union nf_inet_addr *oldip,
-		     const union nf_inet_addr *newip,
+udp_partial_csum_update(int af, __sum16 *sum, struct sk_buff *skb,
+		     union nf_inet_addr *oldip, union nf_inet_addr *newip,
 		     __be16 oldlen, __be16 newlen)
 {
-#ifdef CONFIG_IP_VS_IPV6
-	if (af == AF_INET6)
-		uhdr->check =
-			csum_fold(ip_vs_check_diff16(oldip->ip6, newip->ip6,
-					 ip_vs_check_diff2(oldlen, newlen,
-						~csum_unfold(uhdr->check))));
-	else
-#endif
-	uhdr->check =
-		csum_fold(ip_vs_check_diff4(oldip->ip, newip->ip,
-				ip_vs_check_diff2(oldlen, newlen,
-						~csum_unfold(uhdr->check))));
+	__udp_csum_update(af, sum, skb, oldip, newip, oldlen, newlen, 1);
 }
 
 
@@ -201,13 +194,13 @@ udp_snat_handler(struct sk_buff *skb,
 	 *	Adjust UDP checksums
 	 */
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		udp_partial_csum_update(cp->af, udph, &cp->daddr, &cp->vaddr,
-					htonl(oldlen),
+		udp_partial_csum_update(cp->af, &udph->check, skb, &cp->daddr,
+					&cp->vaddr, htonl(oldlen),
 					htonl(skb->len - udphoff));
 	} else if (!cp->app && (udph->check != 0)) {
 		/* Only port and addr are changed, do fast csum update */
-		udp_fast_csum_update(cp->af, udph, &cp->daddr, &cp->vaddr,
-				     cp->dport, cp->vport);
+		udp_fast_csum_update(cp->af, &udph->check, skb, &cp->daddr,
+				     &cp->vaddr, cp->dport, cp->vport);
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
 			skb->ip_summed = CHECKSUM_NONE;
 	} else {
@@ -277,13 +270,13 @@ udp_dnat_handler(struct sk_buff *skb,
 	 *	Adjust UDP checksums
 	 */
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		udp_partial_csum_update(cp->af, udph, &cp->daddr, &cp->vaddr,
-					htonl(oldlen),
+		udp_partial_csum_update(cp->af, &udph->check, skb, &cp->daddr,
+					&cp->vaddr, htonl(oldlen),
 					htonl(skb->len - udphoff));
 	} else if (!cp->app && (udph->check != 0)) {
 		/* Only port and addr are changed, do fast csum update */
-		udp_fast_csum_update(cp->af, udph, &cp->vaddr, &cp->daddr,
-				     cp->vport, cp->dport);
+		udp_fast_csum_update(cp->af, &udph->check, skb, &cp->vaddr,
+				     &cp->daddr, cp->vport, cp->dport);
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
 			skb->ip_summed = CHECKSUM_NONE;
 	} else {

-- 
