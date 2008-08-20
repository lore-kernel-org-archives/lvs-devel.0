From: Julius Volz <juliusv@google.com>
Subject: [PATCH RFC 08/24] IPVS: Make protocol handler functions support IPv6
Date: Wed, 20 Aug 2008 18:15:15 +0200
Message-ID: <1219248931-15064-9-git-send-email-juliusv@google.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219248945; bh=PoLOSVjjKcUoXLTgS28dXVpNMsQ=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=F1vH0PAhmCQaL3s/WX2CNzVe0aYlq/1HnEsQFzDM
	lJ5RbEIr7RFQ+K/Oah96XKGAhSGcnWhSQ0sF+JKjjbLWMQ==
In-Reply-To: <1219248931-15064-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Add 'af' argument to protocol handler functions and make them handle both
IPv4 and IPv6 in the same function. Change the protocol debugging functions
to detect the AF from the skb and generate the appropriate output. Probably
still too much duplication here.

Signed-off-by: Julius Volz <juliusv@google.com>

 6 files changed, 430 insertions(+), 160 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index fbf57c2..9ba9ee7 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -298,21 +298,23 @@ struct ip_vs_protocol {
 
 	void (*exit)(struct ip_vs_protocol *pp);
 
-	int (*conn_schedule)(struct sk_buff *skb,
+	int (*conn_schedule)(int af, struct sk_buff *skb,
 			     struct ip_vs_protocol *pp,
 			     int *verdict, struct ip_vs_conn **cpp);
 
 	struct ip_vs_conn *
-	(*conn_in_get)(const struct sk_buff *skb,
+	(*conn_in_get)(int af,
+		       const struct sk_buff *skb,
 		       struct ip_vs_protocol *pp,
-		       const struct iphdr *iph,
+		       const struct ip_vs_iphdr *iph,
 		       unsigned int proto_off,
 		       int inverse);
 
 	struct ip_vs_conn *
-	(*conn_out_get)(const struct sk_buff *skb,
+	(*conn_out_get)(int af,
+			const struct sk_buff *skb,
 			struct ip_vs_protocol *pp,
-			const struct iphdr *iph,
+			const struct ip_vs_iphdr *iph,
 			unsigned int proto_off,
 			int inverse);
 
@@ -322,7 +324,8 @@ struct ip_vs_protocol {
 	int (*dnat_handler)(struct sk_buff *skb,
 			    struct ip_vs_protocol *pp, struct ip_vs_conn *cp);
 
-	int (*csum_check)(struct sk_buff *skb, struct ip_vs_protocol *pp);
+	int (*csum_check)(int af, struct sk_buff *skb,
+			  struct ip_vs_protocol *pp);
 
 	const char *(*state_name)(int state);
 
@@ -909,6 +912,17 @@ static inline __wsum ip_vs_check_diff4(__be32 old, __be32 new, __wsum oldsum)
 	return csum_partial((char *) diff, sizeof(diff), oldsum);
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static inline __wsum ip_vs_check_diff16(const __be32 *old, const __be32 *new,
+					__wsum oldsum)
+{
+	__be32 diff[8] = { ~old[3], ~old[2], ~old[1], ~old[0],
+			    new[3],  new[2],  new[1],  new[0] };
+
+	return csum_partial((char *) diff, sizeof(diff), oldsum);
+}
+#endif
+
 static inline __wsum ip_vs_check_diff2(__be16 old, __be16 new, __wsum oldsum)
 {
 	__be16 diff[2] = { ~old, new };
diff --git a/net/ipv4/ipvs/ip_vs_proto.c b/net/ipv4/ipvs/ip_vs_proto.c
index 6099a88..301b779 100644
--- a/net/ipv4/ipvs/ip_vs_proto.c
+++ b/net/ipv4/ipvs/ip_vs_proto.c
@@ -152,10 +152,10 @@ const char * ip_vs_state_name(__u16 proto, int state)
 
 
 void
-ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp,
-			  const struct sk_buff *skb,
-			  int offset,
-			  const char *msg)
+ip_vs_tcpudp_debug_packet_v4(struct ip_vs_protocol *pp,
+			     const struct sk_buff *skb,
+			     int offset,
+			     const char *msg)
 {
 	char buf[128];
 	struct iphdr _iph, *ih;
@@ -168,8 +168,8 @@ ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp,
 			pp->name, NIPQUAD(ih->saddr),
 			NIPQUAD(ih->daddr));
 	else {
-		__be16 _ports[2], *pptr
-;
+		__be16 _ports[2], *pptr;
+
 		pptr = skb_header_pointer(skb, offset + ih->ihl*4,
 					  sizeof(_ports), _ports);
 		if (pptr == NULL)
@@ -189,6 +189,61 @@ ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp,
 	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+void
+ip_vs_tcpudp_debug_packet_v6(struct ip_vs_protocol *pp,
+			     const struct sk_buff *skb,
+			     int offset,
+			     const char *msg)
+{
+	char buf[192];
+	struct ipv6hdr _iph, *ih;
+
+	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
+	if (ih == NULL)
+		sprintf(buf, "%s TRUNCATED", pp->name);
+	else if (ih->nexthdr == IPPROTO_FRAGMENT)
+		sprintf(buf, "%s " NIP6_FMT "->" NIP6_FMT " frag",
+			pp->name, NIP6(ih->saddr),
+			NIP6(ih->daddr));
+	else {
+		__be16 _ports[2], *pptr;
+
+		pptr = skb_header_pointer(skb, offset + sizeof(struct ipv6hdr),
+					  sizeof(_ports), _ports);
+		if (pptr == NULL)
+			sprintf(buf, "%s TRUNCATED " NIP6_FMT "->" NIP6_FMT,
+				pp->name,
+				NIP6(ih->saddr),
+				NIP6(ih->daddr));
+		else
+			sprintf(buf, "%s " NIP6_FMT ":%u->" NIP6_FMT ":%u",
+				pp->name,
+				NIP6(ih->saddr),
+				ntohs(pptr[0]),
+				NIP6(ih->daddr),
+				ntohs(pptr[1]));
+	}
+
+	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
+}
+#endif
+
+
+void
+ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp,
+			  const struct sk_buff *skb,
+			  int offset,
+			  const char *msg)
+{
+#ifdef CONFIG_IP_VS_IPV6
+	if (skb->protocol == __constant_htons(ETH_P_IPV6))
+		ip_vs_tcpudp_debug_packet_v6(pp, skb, offset, msg);
+	else
+#endif
+		ip_vs_tcpudp_debug_packet_v4(pp, skb, offset, msg);
+}
+
 
 int __init ip_vs_protocol_init(void)
 {
diff --git a/net/ipv4/ipvs/ip_vs_proto_ah.c b/net/ipv4/ipvs/ip_vs_proto_ah.c
index ee40aef..843936c 100644
--- a/net/ipv4/ipvs/ip_vs_proto_ah.c
+++ b/net/ipv4/ipvs/ip_vs_proto_ah.c
@@ -39,25 +39,23 @@ struct isakmp_hdr {
 
 
 static struct ip_vs_conn *
-ah_conn_in_get(const struct sk_buff *skb,
-	       struct ip_vs_protocol *pp,
-	       const struct iphdr *iph,
-	       unsigned int proto_off,
+ah_conn_in_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
+	       const struct ip_vs_iphdr *iph, unsigned int proto_off,
 	       int inverse)
 {
 	struct ip_vs_conn *cp;
 
 	if (likely(!inverse)) {
-		cp = ip_vs_conn_in_get(IPPROTO_UDP,
-				       iph->saddr,
+		cp = ip_vs_conn_in_get(af, IPPROTO_UDP,
+				       &iph->saddr,
 				       htons(PORT_ISAKMP),
-				       iph->daddr,
+				       &iph->daddr,
 				       htons(PORT_ISAKMP));
 	} else {
-		cp = ip_vs_conn_in_get(IPPROTO_UDP,
-				       iph->daddr,
+		cp = ip_vs_conn_in_get(af, IPPROTO_UDP,
+				       &iph->daddr,
 				       htons(PORT_ISAKMP),
-				       iph->saddr,
+				       &iph->saddr,
 				       htons(PORT_ISAKMP));
 	}
 
@@ -79,22 +77,23 @@ ah_conn_in_get(const struct sk_buff *skb,
 
 
 static struct ip_vs_conn *
-ah_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
-		const struct iphdr *iph, unsigned int proto_off, int inverse)
+ah_conn_out_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
+	       const struct ip_vs_iphdr *iph, unsigned int proto_off,
+	       int inverse)
 {
 	struct ip_vs_conn *cp;
 
 	if (likely(!inverse)) {
-		cp = ip_vs_conn_out_get(IPPROTO_UDP,
-					iph->saddr,
+		cp = ip_vs_conn_out_get(af, IPPROTO_UDP,
+					&iph->saddr,
 					htons(PORT_ISAKMP),
-					iph->daddr,
+					&iph->daddr,
 					htons(PORT_ISAKMP));
 	} else {
-		cp = ip_vs_conn_out_get(IPPROTO_UDP,
-					iph->daddr,
+		cp = ip_vs_conn_out_get(af, IPPROTO_UDP,
+					&iph->daddr,
 					htons(PORT_ISAKMP),
-					iph->saddr,
+					&iph->saddr,
 					htons(PORT_ISAKMP));
 	}
 
@@ -112,8 +111,7 @@ ah_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 
 static int
-ah_conn_schedule(struct sk_buff *skb,
-		 struct ip_vs_protocol *pp,
+ah_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		 int *verdict, struct ip_vs_conn **cpp)
 {
 	/*
@@ -125,8 +123,8 @@ ah_conn_schedule(struct sk_buff *skb,
 
 
 static void
-ah_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
-		int offset, const char *msg)
+ah_debug_packet_v4(struct ip_vs_protocol *pp, const struct sk_buff *skb,
+		   int offset, const char *msg)
 {
 	char buf[256];
 	struct iphdr _iph, *ih;
@@ -142,6 +140,38 @@ ah_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
 	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static void
+ah_debug_packet_v6(struct ip_vs_protocol *pp, const struct sk_buff *skb,
+		   int offset, const char *msg)
+{
+	char buf[256];
+	struct ipv6hdr _iph, *ih;
+
+	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
+	if (ih == NULL)
+		sprintf(buf, "%s TRUNCATED", pp->name);
+	else
+		sprintf(buf, "%s " NIP6_FMT "->" NIP6_FMT,
+			pp->name, NIP6(ih->saddr),
+			NIP6(ih->daddr));
+
+	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
+}
+#endif
+
+static void
+ah_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
+		int offset, const char *msg)
+{
+#ifdef CONFIG_IP_VS_IPV6
+	if (skb->protocol == __constant_htons(ETH_P_IPV6))
+		ah_debug_packet_v6(pp, skb, offset, msg);
+	else
+#endif
+		ah_debug_packet_v4(pp, skb, offset, msg);
+}
+
 
 static void ah_init(struct ip_vs_protocol *pp)
 {
diff --git a/net/ipv4/ipvs/ip_vs_proto_esp.c b/net/ipv4/ipvs/ip_vs_proto_esp.c
index 51950e3..9c36930 100644
--- a/net/ipv4/ipvs/ip_vs_proto_esp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_esp.c
@@ -39,25 +39,23 @@ struct isakmp_hdr {
 
 
 static struct ip_vs_conn *
-esp_conn_in_get(const struct sk_buff *skb,
-		struct ip_vs_protocol *pp,
-		const struct iphdr *iph,
-		unsigned int proto_off,
+esp_conn_in_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
+		const struct ip_vs_iphdr *iph, unsigned int proto_off,
 		int inverse)
 {
 	struct ip_vs_conn *cp;
 
 	if (likely(!inverse)) {
-		cp = ip_vs_conn_in_get(IPPROTO_UDP,
-				       iph->saddr,
+		cp = ip_vs_conn_in_get(af, IPPROTO_UDP,
+				       &iph->saddr,
 				       htons(PORT_ISAKMP),
-				       iph->daddr,
+				       &iph->daddr,
 				       htons(PORT_ISAKMP));
 	} else {
-		cp = ip_vs_conn_in_get(IPPROTO_UDP,
-				       iph->daddr,
+		cp = ip_vs_conn_in_get(af, IPPROTO_UDP,
+				       &iph->daddr,
 				       htons(PORT_ISAKMP),
-				       iph->saddr,
+				       &iph->saddr,
 				       htons(PORT_ISAKMP));
 	}
 
@@ -79,22 +77,23 @@ esp_conn_in_get(const struct sk_buff *skb,
 
 
 static struct ip_vs_conn *
-esp_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
-		 const struct iphdr *iph, unsigned int proto_off, int inverse)
+esp_conn_out_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
+		 const struct ip_vs_iphdr *iph, unsigned int proto_off,
+		 int inverse)
 {
 	struct ip_vs_conn *cp;
 
 	if (likely(!inverse)) {
-		cp = ip_vs_conn_out_get(IPPROTO_UDP,
-					iph->saddr,
+		cp = ip_vs_conn_out_get(af, IPPROTO_UDP,
+					&iph->saddr,
 					htons(PORT_ISAKMP),
-					iph->daddr,
+					&iph->daddr,
 					htons(PORT_ISAKMP));
 	} else {
-		cp = ip_vs_conn_out_get(IPPROTO_UDP,
-					iph->daddr,
+		cp = ip_vs_conn_out_get(af, IPPROTO_UDP,
+					&iph->daddr,
 					htons(PORT_ISAKMP),
-					iph->saddr,
+					&iph->saddr,
 					htons(PORT_ISAKMP));
 	}
 
@@ -112,7 +111,7 @@ esp_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 
 static int
-esp_conn_schedule(struct sk_buff *skb, struct ip_vs_protocol *pp,
+esp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		  int *verdict, struct ip_vs_conn **cpp)
 {
 	/*
@@ -124,8 +123,8 @@ esp_conn_schedule(struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 
 static void
-esp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
-		 int offset, const char *msg)
+esp_debug_packet_v4(struct ip_vs_protocol *pp, const struct sk_buff *skb,
+		    int offset, const char *msg)
 {
 	char buf[256];
 	struct iphdr _iph, *ih;
@@ -141,6 +140,37 @@ esp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
 	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static void
+esp_debug_packet_v6(struct ip_vs_protocol *pp, const struct sk_buff *skb,
+		    int offset, const char *msg)
+{
+	char buf[256];
+	struct ipv6hdr _iph, *ih;
+
+	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
+	if (ih == NULL)
+		sprintf(buf, "%s TRUNCATED", pp->name);
+	else
+		sprintf(buf, "%s " NIP6_FMT "->" NIP6_FMT,
+			pp->name, NIP6(ih->saddr),
+			NIP6(ih->daddr));
+
+	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
+}
+#endif
+
+static void
+esp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
+		 int offset, const char *msg)
+{
+#ifdef CONFIG_IP_VS_IPV6
+	if (skb->protocol == __constant_htons(ETH_P_IPV6))
+		esp_debug_packet_v6(pp, skb, offset, msg);
+	else
+#endif
+		esp_debug_packet_v4(pp, skb, offset, msg);
+}
 
 static void esp_init(struct ip_vs_protocol *pp)
 {
diff --git a/net/ipv4/ipvs/ip_vs_proto_tcp.c b/net/ipv4/ipvs/ip_vs_proto_tcp.c
index 4689d94..c59b737 100644
--- a/net/ipv4/ipvs/ip_vs_proto_tcp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_tcp.c
@@ -10,6 +10,7 @@
  *              2 of the License, or (at your option) any later version.
  *
  * Changes:
+ * 	Julius Volz			add first IPv6 support
  *
  */
 
@@ -25,8 +26,9 @@
 
 
 static struct ip_vs_conn *
-tcp_conn_in_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
-		const struct iphdr *iph, unsigned int proto_off, int inverse)
+tcp_conn_in_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
+		const struct ip_vs_iphdr *iph, unsigned int proto_off,
+		int inverse)
 {
 	__be16 _ports[2], *pptr;
 
@@ -35,19 +37,20 @@ tcp_conn_in_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 		return NULL;
 
 	if (likely(!inverse)) {
-		return ip_vs_conn_in_get(iph->protocol,
-					 iph->saddr, pptr[0],
-					 iph->daddr, pptr[1]);
+		return ip_vs_conn_in_get(af, iph->protocol,
+					 &iph->saddr, pptr[0],
+					 &iph->daddr, pptr[1]);
 	} else {
-		return ip_vs_conn_in_get(iph->protocol,
-					 iph->daddr, pptr[1],
-					 iph->saddr, pptr[0]);
+		return ip_vs_conn_in_get(af, iph->protocol,
+					 &iph->daddr, pptr[1],
+					 &iph->saddr, pptr[0]);
 	}
 }
 
 static struct ip_vs_conn *
-tcp_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
-		 const struct iphdr *iph, unsigned int proto_off, int inverse)
+tcp_conn_out_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
+		 const struct ip_vs_iphdr *iph, unsigned int proto_off,
+		 int inverse)
 {
 	__be16 _ports[2], *pptr;
 
@@ -56,34 +59,35 @@ tcp_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 		return NULL;
 
 	if (likely(!inverse)) {
-		return ip_vs_conn_out_get(iph->protocol,
-					  iph->saddr, pptr[0],
-					  iph->daddr, pptr[1]);
+		return ip_vs_conn_out_get(af, iph->protocol,
+					  &iph->saddr, pptr[0],
+					  &iph->daddr, pptr[1]);
 	} else {
-		return ip_vs_conn_out_get(iph->protocol,
-					  iph->daddr, pptr[1],
-					  iph->saddr, pptr[0]);
+		return ip_vs_conn_out_get(af, iph->protocol,
+					  &iph->daddr, pptr[1],
+					  &iph->saddr, pptr[0]);
 	}
 }
 
-
 static int
-tcp_conn_schedule(struct sk_buff *skb,
-		  struct ip_vs_protocol *pp,
+tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		  int *verdict, struct ip_vs_conn **cpp)
 {
 	struct ip_vs_service *svc;
 	struct tcphdr _tcph, *th;
+	struct ip_vs_iphdr iph;
+
+	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 
-	th = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(_tcph), &_tcph);
+	th = skb_header_pointer(skb, iph.len, sizeof(_tcph), &_tcph);
 	if (th == NULL) {
 		*verdict = NF_DROP;
 		return 0;
 	}
 
 	if (th->syn &&
-	    (svc = ip_vs_service_get(skb->mark, ip_hdr(skb)->protocol,
-				     ip_hdr(skb)->daddr, th->dest))) {
+	    (svc = ip_vs_service_get(af, skb->mark, iph.protocol, &iph.daddr,
+				     th->dest))) {
 		if (ip_vs_todrop()) {
 			/*
 			 * It seems that we are very loaded.
@@ -110,11 +114,21 @@ tcp_conn_schedule(struct sk_buff *skb,
 
 
 static inline void
-tcp_fast_csum_update(struct tcphdr *tcph, __be32 oldip, __be32 newip,
+tcp_fast_csum_update(int af, struct tcphdr *tcph,
+		     const union nf_inet_addr *oldip,
+		     const union nf_inet_addr *newip,
 		     __be16 oldport, __be16 newport)
 {
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		tcph->check =
+			csum_fold(ip_vs_check_diff16(oldip->ip6, newip->ip6,
+					 ip_vs_check_diff2(oldport, newport,
+						~csum_unfold(tcph->check))));
+	else
+#endif
 	tcph->check =
-		csum_fold(ip_vs_check_diff4(oldip, newip,
+		csum_fold(ip_vs_check_diff4(oldip->ip, newip->ip,
 				 ip_vs_check_diff2(oldport, newport,
 						~csum_unfold(tcph->check))));
 }
@@ -125,7 +139,14 @@ tcp_snat_handler(struct sk_buff *skb,
 		 struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
 {
 	struct tcphdr *tcph;
-	const unsigned int tcphoff = ip_hdrlen(skb);
+	unsigned int tcphoff;
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (cp->af == AF_INET6)
+		tcphoff = sizeof(struct ipv6hdr);
+	else
+#endif
+		tcphoff = ip_hdrlen(skb);
 
 	/* csum_check requires unshared skb */
 	if (!skb_make_writable(skb, tcphoff+sizeof(*tcph)))
@@ -133,7 +154,7 @@ tcp_snat_handler(struct sk_buff *skb,
 
 	if (unlikely(cp->app != NULL)) {
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->csum_check(skb, pp))
+		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
 			return 0;
 
 		/* Call application helper if needed */
@@ -141,13 +162,13 @@ tcp_snat_handler(struct sk_buff *skb,
 			return 0;
 	}
 
-	tcph = (void *)ip_hdr(skb) + tcphoff;
+	tcph = (void *)skb_network_header(skb) + tcphoff;
 	tcph->source = cp->vport;
 
 	/* Adjust TCP checksums */
 	if (!cp->app) {
 		/* Only port and addr are changed, do fast csum update */
-		tcp_fast_csum_update(tcph, cp->daddr, cp->vaddr,
+		tcp_fast_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
 				     cp->dport, cp->vport);
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
 			skb->ip_summed = CHECKSUM_NONE;
@@ -155,9 +176,20 @@ tcp_snat_handler(struct sk_buff *skb,
 		/* full checksum calculation */
 		tcph->check = 0;
 		skb->csum = skb_checksum(skb, tcphoff, skb->len - tcphoff, 0);
-		tcph->check = csum_tcpudp_magic(cp->vaddr, cp->caddr,
-						skb->len - tcphoff,
-						cp->protocol, skb->csum);
+#ifdef CONFIG_IP_VS_IPV6
+		if (cp->af == AF_INET6)
+			tcph->check = csum_ipv6_magic(&cp->vaddr.in6,
+						      &cp->caddr.in6,
+						      skb->len - tcphoff,
+						      cp->protocol, skb->csum);
+		else
+#endif
+			tcph->check = csum_tcpudp_magic(cp->vaddr.ip,
+							cp->caddr.ip,
+							skb->len - tcphoff,
+							cp->protocol,
+							skb->csum);
+
 		IP_VS_DBG(11, "O-pkt: %s O-csum=%d (+%zd)\n",
 			  pp->name, tcph->check,
 			  (char*)&(tcph->check) - (char*)tcph);
@@ -171,7 +203,14 @@ tcp_dnat_handler(struct sk_buff *skb,
 		 struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
 {
 	struct tcphdr *tcph;
-	const unsigned int tcphoff = ip_hdrlen(skb);
+	unsigned int tcphoff;
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (cp->af == AF_INET6)
+		tcphoff = sizeof(struct ipv6hdr);
+	else
+#endif
+		tcphoff = ip_hdrlen(skb);
 
 	/* csum_check requires unshared skb */
 	if (!skb_make_writable(skb, tcphoff+sizeof(*tcph)))
@@ -179,7 +218,7 @@ tcp_dnat_handler(struct sk_buff *skb,
 
 	if (unlikely(cp->app != NULL)) {
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->csum_check(skb, pp))
+		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
 			return 0;
 
 		/*
@@ -190,7 +229,7 @@ tcp_dnat_handler(struct sk_buff *skb,
 			return 0;
 	}
 
-	tcph = (void *)ip_hdr(skb) + tcphoff;
+	tcph = (void *)skb_network_header(skb) + tcphoff;
 	tcph->dest = cp->dport;
 
 	/*
@@ -198,7 +237,7 @@ tcp_dnat_handler(struct sk_buff *skb,
 	 */
 	if (!cp->app) {
 		/* Only port and addr are changed, do fast csum update */
-		tcp_fast_csum_update(tcph, cp->vaddr, cp->daddr,
+		tcp_fast_csum_update(cp->af, tcph, &cp->vaddr, &cp->daddr,
 				     cp->vport, cp->dport);
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
 			skb->ip_summed = CHECKSUM_NONE;
@@ -206,9 +245,19 @@ tcp_dnat_handler(struct sk_buff *skb,
 		/* full checksum calculation */
 		tcph->check = 0;
 		skb->csum = skb_checksum(skb, tcphoff, skb->len - tcphoff, 0);
-		tcph->check = csum_tcpudp_magic(cp->caddr, cp->daddr,
-						skb->len - tcphoff,
-						cp->protocol, skb->csum);
+#ifdef CONFIG_IP_VS_IPV6
+		if (cp->af == AF_INET6)
+			tcph->check = csum_ipv6_magic(&cp->caddr.in6,
+						      &cp->daddr.in6,
+						      skb->len - tcphoff,
+						      cp->protocol, skb->csum);
+		else
+#endif
+			tcph->check = csum_tcpudp_magic(cp->caddr.ip,
+							cp->daddr.ip,
+							skb->len - tcphoff,
+							cp->protocol,
+							skb->csum);
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 	return 1;
@@ -216,21 +265,43 @@ tcp_dnat_handler(struct sk_buff *skb,
 
 
 static int
-tcp_csum_check(struct sk_buff *skb, struct ip_vs_protocol *pp)
+tcp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
 {
-	const unsigned int tcphoff = ip_hdrlen(skb);
+	unsigned int tcphoff;
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		tcphoff = sizeof(struct ipv6hdr);
+	else
+#endif
+		tcphoff = ip_hdrlen(skb);
 
 	switch (skb->ip_summed) {
 	case CHECKSUM_NONE:
 		skb->csum = skb_checksum(skb, tcphoff, skb->len - tcphoff, 0);
 	case CHECKSUM_COMPLETE:
-		if (csum_tcpudp_magic(ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
-				      skb->len - tcphoff,
-				      ip_hdr(skb)->protocol, skb->csum)) {
-			IP_VS_DBG_RL_PKT(0, pp, skb, 0,
-					 "Failed checksum for");
-			return 0;
-		}
+#ifdef CONFIG_IP_VS_IPV6
+		if (af == AF_INET6) {
+			if (csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+					    &ipv6_hdr(skb)->daddr,
+					    skb->len - tcphoff,
+					    ipv6_hdr(skb)->nexthdr,
+					    skb->csum)) {
+				IP_VS_DBG_RL_PKT(0, pp, skb, 0,
+						 "Failed checksum for");
+				return 0;
+			}
+		} else
+#endif
+			if (csum_tcpudp_magic(ip_hdr(skb)->saddr,
+					      ip_hdr(skb)->daddr,
+					      skb->len - tcphoff,
+					      ip_hdr(skb)->protocol,
+					      skb->csum)) {
+				IP_VS_DBG_RL_PKT(0, pp, skb, 0,
+						 "Failed checksum for");
+				return 0;
+			}
 		break;
 	default:
 		/* No need to checksum. */
@@ -463,8 +534,13 @@ tcp_state_transition(struct ip_vs_conn *cp, int direction,
 		     struct ip_vs_protocol *pp)
 {
 	struct tcphdr _tcph, *th;
+#ifdef CONFIG_IP_VS_IPV6
+	int ihl = cp->af == AF_INET ? ip_hdrlen(skb) : sizeof(struct ipv6hdr);
+#else
+	int ihl = ip_hdrlen(skb);
+#endif
 
-	th = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(_tcph), &_tcph);
+	th = skb_header_pointer(skb, ihl, sizeof(_tcph), &_tcph);
 	if (th == NULL)
 		return 0;
 
diff --git a/net/ipv4/ipvs/ip_vs_proto_udp.c b/net/ipv4/ipvs/ip_vs_proto_udp.c
index e06020b..0ac6c74 100644
--- a/net/ipv4/ipvs/ip_vs_proto_udp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_udp.c
@@ -10,6 +10,7 @@
  *              2 of the License, or (at your option) any later version.
  *
  * Changes:
+ * 	Julius Volz			add first IPv6 support
  *
  */
 
@@ -24,8 +25,9 @@
 #include <net/ip.h>
 
 static struct ip_vs_conn *
-udp_conn_in_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
-		const struct iphdr *iph, unsigned int proto_off, int inverse)
+udp_conn_in_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
+		const struct ip_vs_iphdr *iph, unsigned int proto_off,
+		int inverse)
 {
 	struct ip_vs_conn *cp;
 	__be16 _ports[2], *pptr;
@@ -35,61 +37,61 @@ udp_conn_in_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 		return NULL;
 
 	if (likely(!inverse)) {
-		cp = ip_vs_conn_in_get(iph->protocol,
-				       iph->saddr, pptr[0],
-				       iph->daddr, pptr[1]);
+		cp = ip_vs_conn_in_get(af, iph->protocol,
+				       &iph->saddr, pptr[0],
+				       &iph->daddr, pptr[1]);
 	} else {
-		cp = ip_vs_conn_in_get(iph->protocol,
-				       iph->daddr, pptr[1],
-				       iph->saddr, pptr[0]);
+		cp = ip_vs_conn_in_get(af, iph->protocol,
+				       &iph->daddr, pptr[1],
+				       &iph->saddr, pptr[0]);
 	}
 
 	return cp;
 }
 
-
 static struct ip_vs_conn *
-udp_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
-		 const struct iphdr *iph, unsigned int proto_off, int inverse)
+udp_conn_out_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
+		 const struct ip_vs_iphdr *iph, unsigned int proto_off,
+		 int inverse)
 {
 	struct ip_vs_conn *cp;
 	__be16 _ports[2], *pptr;
 
-	pptr = skb_header_pointer(skb, ip_hdrlen(skb),
-				  sizeof(_ports), _ports);
+	pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
 	if (pptr == NULL)
 		return NULL;
 
 	if (likely(!inverse)) {
-		cp = ip_vs_conn_out_get(iph->protocol,
-					iph->saddr, pptr[0],
-					iph->daddr, pptr[1]);
+		cp = ip_vs_conn_out_get(af, iph->protocol,
+					&iph->saddr, pptr[0],
+					&iph->daddr, pptr[1]);
 	} else {
-		cp = ip_vs_conn_out_get(iph->protocol,
-					iph->daddr, pptr[1],
-					iph->saddr, pptr[0]);
+		cp = ip_vs_conn_out_get(af, iph->protocol,
+					&iph->daddr, pptr[1],
+					&iph->saddr, pptr[0]);
 	}
 
 	return cp;
 }
 
-
 static int
-udp_conn_schedule(struct sk_buff *skb, struct ip_vs_protocol *pp,
+udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		  int *verdict, struct ip_vs_conn **cpp)
 {
 	struct ip_vs_service *svc;
 	struct udphdr _udph, *uh;
+	struct ip_vs_iphdr iph;
 
-	uh = skb_header_pointer(skb, ip_hdrlen(skb),
-				sizeof(_udph), &_udph);
+	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+
+	uh = skb_header_pointer(skb, iph.len, sizeof(_udph), &_udph);
 	if (uh == NULL) {
 		*verdict = NF_DROP;
 		return 0;
 	}
 
-	if ((svc = ip_vs_service_get(skb->mark, ip_hdr(skb)->protocol,
-				     ip_hdr(skb)->daddr, uh->dest))) {
+	if ((svc = ip_vs_service_get(af, skb->mark, iph.protocol, &iph.daddr,
+				     uh->dest))) {
 		if (ip_vs_todrop()) {
 			/*
 			 * It seems that we are very loaded.
@@ -114,25 +116,42 @@ udp_conn_schedule(struct sk_buff *skb, struct ip_vs_protocol *pp,
 	return 1;
 }
 
-
 static inline void
-udp_fast_csum_update(struct udphdr *uhdr, __be32 oldip, __be32 newip,
+udp_fast_csum_update(int af, struct udphdr *uhdr,
+		     const union nf_inet_addr *oldip,
+		     const union nf_inet_addr *newip,
 		     __be16 oldport, __be16 newport)
 {
-	uhdr->check =
-		csum_fold(ip_vs_check_diff4(oldip, newip,
-				 ip_vs_check_diff2(oldport, newport,
-					~csum_unfold(uhdr->check))));
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		uhdr->check =
+			csum_fold(ip_vs_check_diff16(oldip->ip6, newip->ip6,
+					 ip_vs_check_diff2(oldport, newport,
+						~csum_unfold(uhdr->check))));
+	else
+#endif
+		uhdr->check =
+			csum_fold(ip_vs_check_diff4(oldip->ip, newip->ip,
+					 ip_vs_check_diff2(oldport, newport,
+						~csum_unfold(uhdr->check))));
 	if (!uhdr->check)
 		uhdr->check = CSUM_MANGLED_0;
 }
 
+
 static int
 udp_snat_handler(struct sk_buff *skb,
 		 struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
 {
 	struct udphdr *udph;
-	const unsigned int udphoff = ip_hdrlen(skb);
+	unsigned int udphoff;
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (cp->af == AF_INET6)
+		udphoff = sizeof(struct ipv6hdr);
+	else
+#endif
+		udphoff = ip_hdrlen(skb);
 
 	/* csum_check requires unshared skb */
 	if (!skb_make_writable(skb, udphoff+sizeof(*udph)))
@@ -140,7 +159,7 @@ udp_snat_handler(struct sk_buff *skb,
 
 	if (unlikely(cp->app != NULL)) {
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->csum_check(skb, pp))
+		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
 			return 0;
 
 		/*
@@ -150,7 +169,7 @@ udp_snat_handler(struct sk_buff *skb,
 			return 0;
 	}
 
-	udph = (void *)ip_hdr(skb) + udphoff;
+	udph = (void *)skb_network_header(skb) + udphoff;
 	udph->source = cp->vport;
 
 	/*
@@ -158,7 +177,7 @@ udp_snat_handler(struct sk_buff *skb,
 	 */
 	if (!cp->app && (udph->check != 0)) {
 		/* Only port and addr are changed, do fast csum update */
-		udp_fast_csum_update(udph, cp->daddr, cp->vaddr,
+		udp_fast_csum_update(cp->af, udph, &cp->daddr, &cp->vaddr,
 				     cp->dport, cp->vport);
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
 			skb->ip_summed = CHECKSUM_NONE;
@@ -166,9 +185,19 @@ udp_snat_handler(struct sk_buff *skb,
 		/* full checksum calculation */
 		udph->check = 0;
 		skb->csum = skb_checksum(skb, udphoff, skb->len - udphoff, 0);
-		udph->check = csum_tcpudp_magic(cp->vaddr, cp->caddr,
-						skb->len - udphoff,
-						cp->protocol, skb->csum);
+#ifdef CONFIG_IP_VS_IPV6
+		if (cp->af == AF_INET6)
+			udph->check = csum_ipv6_magic(&cp->vaddr.in6,
+						      &cp->caddr.in6,
+						      skb->len - udphoff,
+						      cp->protocol, skb->csum);
+		else
+#endif
+			udph->check = csum_tcpudp_magic(cp->vaddr.ip,
+							cp->caddr.ip,
+							skb->len - udphoff,
+							cp->protocol,
+							skb->csum);
 		if (udph->check == 0)
 			udph->check = CSUM_MANGLED_0;
 		IP_VS_DBG(11, "O-pkt: %s O-csum=%d (+%zd)\n",
@@ -184,7 +213,14 @@ udp_dnat_handler(struct sk_buff *skb,
 		 struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
 {
 	struct udphdr *udph;
-	unsigned int udphoff = ip_hdrlen(skb);
+	unsigned int udphoff;
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (cp->af == AF_INET6)
+		udphoff = sizeof(struct ipv6hdr);
+	else
+#endif
+		udphoff = ip_hdrlen(skb);
 
 	/* csum_check requires unshared skb */
 	if (!skb_make_writable(skb, udphoff+sizeof(*udph)))
@@ -192,7 +228,7 @@ udp_dnat_handler(struct sk_buff *skb,
 
 	if (unlikely(cp->app != NULL)) {
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->csum_check(skb, pp))
+		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
 			return 0;
 
 		/*
@@ -203,7 +239,7 @@ udp_dnat_handler(struct sk_buff *skb,
 			return 0;
 	}
 
-	udph = (void *)ip_hdr(skb) + udphoff;
+	udph = (void *)skb_network_header(skb) + udphoff;
 	udph->dest = cp->dport;
 
 	/*
@@ -211,7 +247,7 @@ udp_dnat_handler(struct sk_buff *skb,
 	 */
 	if (!cp->app && (udph->check != 0)) {
 		/* Only port and addr are changed, do fast csum update */
-		udp_fast_csum_update(udph, cp->vaddr, cp->daddr,
+		udp_fast_csum_update(cp->af, udph, &cp->vaddr, &cp->daddr,
 				     cp->vport, cp->dport);
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
 			skb->ip_summed = CHECKSUM_NONE;
@@ -219,9 +255,19 @@ udp_dnat_handler(struct sk_buff *skb,
 		/* full checksum calculation */
 		udph->check = 0;
 		skb->csum = skb_checksum(skb, udphoff, skb->len - udphoff, 0);
-		udph->check = csum_tcpudp_magic(cp->caddr, cp->daddr,
-						skb->len - udphoff,
-						cp->protocol, skb->csum);
+#ifdef CONFIG_IP_VS_IPV6
+		if (cp->af == AF_INET6)
+			udph->check = csum_ipv6_magic(&cp->caddr.in6,
+						      &cp->daddr.in6,
+						      skb->len - udphoff,
+						      cp->protocol, skb->csum);
+		else
+#endif
+			udph->check = csum_tcpudp_magic(cp->caddr.ip,
+							cp->daddr.ip,
+							skb->len - udphoff,
+							cp->protocol,
+							skb->csum);
 		if (udph->check == 0)
 			udph->check = CSUM_MANGLED_0;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -231,10 +277,17 @@ udp_dnat_handler(struct sk_buff *skb,
 
 
 static int
-udp_csum_check(struct sk_buff *skb, struct ip_vs_protocol *pp)
+udp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
 {
 	struct udphdr _udph, *uh;
-	const unsigned int udphoff = ip_hdrlen(skb);
+	unsigned int udphoff;
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		udphoff = sizeof(struct ipv6hdr);
+	else
+#endif
+		udphoff = ip_hdrlen(skb);
 
 	uh = skb_header_pointer(skb, udphoff, sizeof(_udph), &_udph);
 	if (uh == NULL)
@@ -246,15 +299,28 @@ udp_csum_check(struct sk_buff *skb, struct ip_vs_protocol *pp)
 			skb->csum = skb_checksum(skb, udphoff,
 						 skb->len - udphoff, 0);
 		case CHECKSUM_COMPLETE:
-			if (csum_tcpudp_magic(ip_hdr(skb)->saddr,
-					      ip_hdr(skb)->daddr,
-					      skb->len - udphoff,
-					      ip_hdr(skb)->protocol,
-					      skb->csum)) {
-				IP_VS_DBG_RL_PKT(0, pp, skb, 0,
-						 "Failed checksum for");
-				return 0;
-			}
+#ifdef CONFIG_IP_VS_IPV6
+			if (af == AF_INET6) {
+				if (csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+						    &ipv6_hdr(skb)->daddr,
+						    skb->len - udphoff,
+						    ipv6_hdr(skb)->nexthdr,
+						    skb->csum)) {
+					IP_VS_DBG_RL_PKT(0, pp, skb, 0,
+							 "Failed checksum for");
+					return 0;
+				}
+			} else
+#endif
+				if (csum_tcpudp_magic(ip_hdr(skb)->saddr,
+						      ip_hdr(skb)->daddr,
+						      skb->len - udphoff,
+						      ip_hdr(skb)->protocol,
+						      skb->csum)) {
+					IP_VS_DBG_RL_PKT(0, pp, skb, 0,
+							 "Failed checksum for");
+					return 0;
+				}
 			break;
 		default:
 			/* No need to checksum. */
@@ -406,7 +472,6 @@ static void udp_exit(struct ip_vs_protocol *pp)
 {
 }
 
-
 struct ip_vs_protocol ip_vs_protocol_udp = {
 	.name =			"UDP",
 	.protocol =		IPPROTO_UDP,
-- 
1.5.4.5

