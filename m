From: Simon Horman <horms@verge.net.au>
Subject: [rfc 1/3] ipvs: handle PARTIAL_CHECKSUM
Date: Mon, 08 Sep 2008 12:04:21 +1000
Message-ID: <20080908021535.063462678@vergenet.net>
References: <20080908020420.313463898@vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=ipvs-partial_csum-update.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: =?ISO-8859-15?q?Siim=20P=C3=B5der?= <siim@p6drad-teel.net>, Julian Anastasov <ja@ssi.bg>, Malcolm Turnbull <malcolm@loadbalancer.org>, Julius Volz <juliusv@google.com>, Vince Busam <vbusam@google.com>, Herbert Xu <herbert@gondor.apana.org.au>

Now that LVS can load balance locally generated traffic, packets may come
from the loopback device and thus may have a partial checksum.

The existing code allows for the case where there is no checksum at all for
TCP, however Herbert Xu has confirmed that this is not legal.

Signed-off-by: Simon Horman <horms@verge.net.au>

--- 

This patch implements *_partial_csum_update() in the style
of the existing *_fast_csum_update() code. A subsequent patch
will reimplement these functions in terms of the more standard
inet_proto_csum_replace*() functions.

 net/ipv4/ipvs/ip_vs_proto_tcp.c |   37 +++++++++++++++++++++++++++++++++++--
 net/ipv4/ipvs/ip_vs_proto_udp.c |   37 +++++++++++++++++++++++++++++++++++--
 2 files changed, 70 insertions(+), 4 deletions(-)
Index: lvs-2.6/net/ipv4/ipvs/ip_vs_proto_tcp.c
===================================================================
--- lvs-2.6.orig/net/ipv4/ipvs/ip_vs_proto_tcp.c	2008-09-08 11:46:28.000000000 +1000
+++ lvs-2.6/net/ipv4/ipvs/ip_vs_proto_tcp.c	2008-09-08 11:56:10.000000000 +1000
@@ -134,12 +134,34 @@ tcp_fast_csum_update(int af, struct tcph
 }
 
 
+static inline void
+tcp_partial_csum_update(int af, struct tcphdr *tcph,
+		     const union nf_inet_addr *oldip,
+		     const union nf_inet_addr *newip,
+		     __be16 oldlen, __be16 newlen)
+{
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		tcph->check =
+			csum_fold(ip_vs_check_diff16(oldip->ip6, newip->ip6,
+					 ip_vs_check_diff2(oldlen, newlen,
+						~csum_unfold(tcph->check))));
+	else
+#endif
+	tcph->check =
+		csum_fold(ip_vs_check_diff4(oldip->ip, newip->ip,
+				ip_vs_check_diff2(oldlen, newlen,
+						~csum_unfold(tcph->check))));
+}
+
+
 static int
 tcp_snat_handler(struct sk_buff *skb,
 		 struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
 {
 	struct tcphdr *tcph;
 	unsigned int tcphoff;
+	int oldlen;
 
 #ifdef CONFIG_IP_VS_IPV6
 	if (cp->af == AF_INET6)
@@ -147,6 +169,7 @@ tcp_snat_handler(struct sk_buff *skb,
 	else
 #endif
 		tcphoff = ip_hdrlen(skb);
+	oldlen = skb->len - tcphoff;
 
 	/* csum_check requires unshared skb */
 	if (!skb_make_writable(skb, tcphoff+sizeof(*tcph)))
@@ -166,7 +189,11 @@ tcp_snat_handler(struct sk_buff *skb,
 	tcph->source = cp->vport;
 
 	/* Adjust TCP checksums */
-	if (!cp->app && (tcph->check != 0)) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		tcp_partial_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
+					htonl(oldlen),
+					htonl(skb->len - tcphoff));
+	} else if (!cp->app) {
 		/* Only port and addr are changed, do fast csum update */
 		tcp_fast_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
 				     cp->dport, cp->vport);
@@ -204,6 +231,7 @@ tcp_dnat_handler(struct sk_buff *skb,
 {
 	struct tcphdr *tcph;
 	unsigned int tcphoff;
+	int oldlen;
 
 #ifdef CONFIG_IP_VS_IPV6
 	if (cp->af == AF_INET6)
@@ -211,6 +239,7 @@ tcp_dnat_handler(struct sk_buff *skb,
 	else
 #endif
 		tcphoff = ip_hdrlen(skb);
+	oldlen = skb->len - tcphoff;
 
 	/* csum_check requires unshared skb */
 	if (!skb_make_writable(skb, tcphoff+sizeof(*tcph)))
@@ -235,7 +264,11 @@ tcp_dnat_handler(struct sk_buff *skb,
 	/*
 	 *	Adjust TCP checksums
 	 */
-	if (!cp->app && (tcph->check != 0)) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		tcp_partial_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
+					htonl(oldlen),
+					htonl(skb->len - tcphoff));
+	} else if (!cp->app) {
 		/* Only port and addr are changed, do fast csum update */
 		tcp_fast_csum_update(cp->af, tcph, &cp->vaddr, &cp->daddr,
 				     cp->vport, cp->dport);
Index: lvs-2.6/net/ipv4/ipvs/ip_vs_proto_udp.c
===================================================================
--- lvs-2.6.orig/net/ipv4/ipvs/ip_vs_proto_udp.c	2008-09-08 11:46:28.000000000 +1000
+++ lvs-2.6/net/ipv4/ipvs/ip_vs_proto_udp.c	2008-09-08 11:56:10.000000000 +1000
@@ -141,12 +141,34 @@ udp_fast_csum_update(int af, struct udph
 		uhdr->check = CSUM_MANGLED_0;
 }
 
+static inline void
+udp_partial_csum_update(int af, struct udphdr *uhdr,
+		     const union nf_inet_addr *oldip,
+		     const union nf_inet_addr *newip,
+		     __be16 oldlen, __be16 newlen)
+{
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		uhdr->check =
+			csum_fold(ip_vs_check_diff16(oldip->ip6, newip->ip6,
+					 ip_vs_check_diff2(oldlen, newlen,
+						~csum_unfold(uhdr->check))));
+	else
+#endif
+	uhdr->check =
+		csum_fold(ip_vs_check_diff4(oldip->ip, newip->ip,
+				ip_vs_check_diff2(oldlen, newlen,
+						~csum_unfold(uhdr->check))));
+}
+
+
 static int
 udp_snat_handler(struct sk_buff *skb,
 		 struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
 {
 	struct udphdr *udph;
 	unsigned int udphoff;
+	int oldlen;
 
 #ifdef CONFIG_IP_VS_IPV6
 	if (cp->af == AF_INET6)
@@ -154,6 +176,7 @@ udp_snat_handler(struct sk_buff *skb,
 	else
 #endif
 		udphoff = ip_hdrlen(skb);
+	oldlen = skb->len - udphoff;
 
 	/* csum_check requires unshared skb */
 	if (!skb_make_writable(skb, udphoff+sizeof(*udph)))
@@ -177,7 +200,11 @@ udp_snat_handler(struct sk_buff *skb,
 	/*
 	 *	Adjust UDP checksums
 	 */
-	if (!cp->app && (udph->check != 0)) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		udp_partial_csum_update(cp->af, udph, &cp->daddr, &cp->vaddr,
+					htonl(oldlen),
+					htonl(skb->len - udphoff));
+	} else if (!cp->app && (udph->check != 0)) {
 		/* Only port and addr are changed, do fast csum update */
 		udp_fast_csum_update(cp->af, udph, &cp->daddr, &cp->vaddr,
 				     cp->dport, cp->vport);
@@ -216,6 +243,7 @@ udp_dnat_handler(struct sk_buff *skb,
 {
 	struct udphdr *udph;
 	unsigned int udphoff;
+	int oldlen;
 
 #ifdef CONFIG_IP_VS_IPV6
 	if (cp->af == AF_INET6)
@@ -223,6 +251,7 @@ udp_dnat_handler(struct sk_buff *skb,
 	else
 #endif
 		udphoff = ip_hdrlen(skb);
+	oldlen = skb->len - udphoff;
 
 	/* csum_check requires unshared skb */
 	if (!skb_make_writable(skb, udphoff+sizeof(*udph)))
@@ -247,7 +276,11 @@ udp_dnat_handler(struct sk_buff *skb,
 	/*
 	 *	Adjust UDP checksums
 	 */
-	if (!cp->app && (udph->check != 0)) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		udp_partial_csum_update(cp->af, udph, &cp->daddr, &cp->vaddr,
+					htonl(oldlen),
+					htonl(skb->len - udphoff));
+	} else if (!cp->app && (udph->check != 0)) {
 		/* Only port and addr are changed, do fast csum update */
 		udp_fast_csum_update(cp->af, udph, &cp->vaddr, &cp->daddr,
 				     cp->vport, cp->dport);

-- 
