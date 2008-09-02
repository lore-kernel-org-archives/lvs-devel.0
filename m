From: Julius Volz <juliusv@google.com>
Subject: [PATCHv3 11/24] IPVS: Extend protocol DNAT/SNAT and state handlers
Date: Tue,  2 Sep 2008 15:55:42 +0200
Message-ID: <1220363755-9854-12-git-send-email-juliusv@google.com>
References: <1220363755-9854-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220363767; bh=F0mIGF5snM/IJYfwjTt+CEEOZEk=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=lSpfLQcB+sNsWlIC//AzBmVJafkOY0Z6JDiuDVGG
	/NjYmoOQIzms6da3azPRhk99Rm8BypFuI9q4fp0LdLBhsw==
In-Reply-To: <1220363755-9854-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Extend protocol DNAT/SNAT and state handlers to work with IPv6. Also
change/introduce new checksumming helper functions for this.

Signed-off-by: Julius Volz <juliusv@google.com>

 3 files changed, 142 insertions(+), 36 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 68f004f..c173f1a 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -904,6 +904,17 @@ static inline __wsum ip_vs_check_diff4(__be32 old, __be32 new, __wsum oldsum)
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
diff --git a/net/ipv4/ipvs/ip_vs_proto_tcp.c b/net/ipv4/ipvs/ip_vs_proto_tcp.c
index 9211afa..3daae43 100644
--- a/net/ipv4/ipvs/ip_vs_proto_tcp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_tcp.c
@@ -114,11 +114,21 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 
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
@@ -129,7 +139,14 @@ tcp_snat_handler(struct sk_buff *skb,
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
@@ -137,7 +154,7 @@ tcp_snat_handler(struct sk_buff *skb,
 
 	if (unlikely(cp->app != NULL)) {
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->csum_check(AF_INET, skb, pp))
+		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
 			return 0;
 
 		/* Call application helper if needed */
@@ -145,13 +162,13 @@ tcp_snat_handler(struct sk_buff *skb,
 			return 0;
 	}
 
-	tcph = (void *)ip_hdr(skb) + tcphoff;
+	tcph = (void *)skb_network_header(skb) + tcphoff;
 	tcph->source = cp->vport;
 
 	/* Adjust TCP checksums */
 	if (!cp->app) {
 		/* Only port and addr are changed, do fast csum update */
-		tcp_fast_csum_update(tcph, cp->daddr.ip, cp->vaddr.ip,
+		tcp_fast_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
 				     cp->dport, cp->vport);
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
 			skb->ip_summed = CHECKSUM_NONE;
@@ -159,9 +176,20 @@ tcp_snat_handler(struct sk_buff *skb,
 		/* full checksum calculation */
 		tcph->check = 0;
 		skb->csum = skb_checksum(skb, tcphoff, skb->len - tcphoff, 0);
-		tcph->check = csum_tcpudp_magic(cp->vaddr.ip, cp->caddr.ip,
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
@@ -175,7 +203,14 @@ tcp_dnat_handler(struct sk_buff *skb,
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
@@ -183,7 +218,7 @@ tcp_dnat_handler(struct sk_buff *skb,
 
 	if (unlikely(cp->app != NULL)) {
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->csum_check(AF_INET, skb, pp))
+		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
 			return 0;
 
 		/*
@@ -194,7 +229,7 @@ tcp_dnat_handler(struct sk_buff *skb,
 			return 0;
 	}
 
-	tcph = (void *)ip_hdr(skb) + tcphoff;
+	tcph = (void *)skb_network_header(skb) + tcphoff;
 	tcph->dest = cp->dport;
 
 	/*
@@ -202,7 +237,7 @@ tcp_dnat_handler(struct sk_buff *skb,
 	 */
 	if (!cp->app) {
 		/* Only port and addr are changed, do fast csum update */
-		tcp_fast_csum_update(tcph, cp->vaddr.ip, cp->daddr.ip,
+		tcp_fast_csum_update(cp->af, tcph, &cp->vaddr, &cp->daddr,
 				     cp->vport, cp->dport);
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
 			skb->ip_summed = CHECKSUM_NONE;
@@ -210,9 +245,19 @@ tcp_dnat_handler(struct sk_buff *skb,
 		/* full checksum calculation */
 		tcph->check = 0;
 		skb->csum = skb_checksum(skb, tcphoff, skb->len - tcphoff, 0);
-		tcph->check = csum_tcpudp_magic(cp->caddr.ip, cp->daddr.ip,
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
@@ -487,7 +532,13 @@ tcp_state_transition(struct ip_vs_conn *cp, int direction,
 {
 	struct tcphdr _tcph, *th;
 
-	th = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(_tcph), &_tcph);
+#ifdef CONFIG_IP_VS_IPV6
+	int ihl = cp->af == AF_INET ? ip_hdrlen(skb) : sizeof(struct ipv6hdr);
+#else
+	int ihl = ip_hdrlen(skb);
+#endif
+
+	th = skb_header_pointer(skb, ihl, sizeof(_tcph), &_tcph);
 	if (th == NULL)
 		return 0;
 
diff --git a/net/ipv4/ipvs/ip_vs_proto_udp.c b/net/ipv4/ipvs/ip_vs_proto_udp.c
index d3a1b1f..6cca0ad 100644
--- a/net/ipv4/ipvs/ip_vs_proto_udp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_udp.c
@@ -120,13 +120,23 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 
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
@@ -136,7 +146,14 @@ udp_snat_handler(struct sk_buff *skb,
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
@@ -144,7 +161,7 @@ udp_snat_handler(struct sk_buff *skb,
 
 	if (unlikely(cp->app != NULL)) {
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->csum_check(AF_INET, skb, pp))
+		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
 			return 0;
 
 		/*
@@ -154,7 +171,7 @@ udp_snat_handler(struct sk_buff *skb,
 			return 0;
 	}
 
-	udph = (void *)ip_hdr(skb) + udphoff;
+	udph = (void *)skb_network_header(skb) + udphoff;
 	udph->source = cp->vport;
 
 	/*
@@ -162,7 +179,7 @@ udp_snat_handler(struct sk_buff *skb,
 	 */
 	if (!cp->app && (udph->check != 0)) {
 		/* Only port and addr are changed, do fast csum update */
-		udp_fast_csum_update(udph, cp->daddr.ip, cp->vaddr.ip,
+		udp_fast_csum_update(cp->af, udph, &cp->daddr, &cp->vaddr,
 				     cp->dport, cp->vport);
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
 			skb->ip_summed = CHECKSUM_NONE;
@@ -170,9 +187,19 @@ udp_snat_handler(struct sk_buff *skb,
 		/* full checksum calculation */
 		udph->check = 0;
 		skb->csum = skb_checksum(skb, udphoff, skb->len - udphoff, 0);
-		udph->check = csum_tcpudp_magic(cp->vaddr.ip, cp->caddr.ip,
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
@@ -188,7 +215,14 @@ udp_dnat_handler(struct sk_buff *skb,
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
@@ -196,7 +230,7 @@ udp_dnat_handler(struct sk_buff *skb,
 
 	if (unlikely(cp->app != NULL)) {
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->csum_check(AF_INET, skb, pp))
+		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
 			return 0;
 
 		/*
@@ -207,7 +241,7 @@ udp_dnat_handler(struct sk_buff *skb,
 			return 0;
 	}
 
-	udph = (void *)ip_hdr(skb) + udphoff;
+	udph = (void *)skb_network_header(skb) + udphoff;
 	udph->dest = cp->dport;
 
 	/*
@@ -215,7 +249,7 @@ udp_dnat_handler(struct sk_buff *skb,
 	 */
 	if (!cp->app && (udph->check != 0)) {
 		/* Only port and addr are changed, do fast csum update */
-		udp_fast_csum_update(udph, cp->vaddr.ip, cp->daddr.ip,
+		udp_fast_csum_update(cp->af, udph, &cp->vaddr, &cp->daddr,
 				     cp->vport, cp->dport);
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
 			skb->ip_summed = CHECKSUM_NONE;
@@ -223,9 +257,19 @@ udp_dnat_handler(struct sk_buff *skb,
 		/* full checksum calculation */
 		udph->check = 0;
 		skb->csum = skb_checksum(skb, udphoff, skb->len - udphoff, 0);
-		udph->check = csum_tcpudp_magic(cp->caddr.ip, cp->daddr.ip,
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
-- 
1.5.4.5

