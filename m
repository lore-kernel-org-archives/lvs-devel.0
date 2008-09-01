From: Julius Volz <juliusv@google.com>
Subject: [PATCHv2 RFC 09/25] IPVS: Add 'af' args to protocol handler functions
Date: Mon,  1 Sep 2008 14:56:06 +0200
Message-ID: <1220273782-19901-10-git-send-email-juliusv@google.com>
References: <1220273782-19901-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220273824; bh=hFrjG0IhAHGyv1NJISLpEuwQIsY=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=Z42RatZTfJFqLK78ivhO9votYhwFJ+LdQ+cwLCKD
	wSaIpVIhfx6qp1fHXki407dXyWhrVET+sF+XNjBfdaPlOA==
In-Reply-To: <1220273782-19901-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Add 'af' arguments to conn_schedule(), conn_in_get(), conn_out_get() and
csum_check() function pointers in struct ip_vs_protocol. Extend the
respective functions for TCP, UDP, AH and ESP and adjust the callers.

The changes in the callers need to be somewhat extensive, since they now
need to pass a filled out struct ip_vs_iphdr * to the modified functions
instead of a struct iphdr *.

Signed-off-by: Julius Volz <juliusv@google.com>

 5 files changed, 173 insertions(+), 126 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 881e60a..3305d1b 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -296,21 +296,23 @@ struct ip_vs_protocol {
 
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
 
@@ -320,7 +322,8 @@ struct ip_vs_protocol {
 	int (*dnat_handler)(struct sk_buff *skb,
 			    struct ip_vs_protocol *pp, struct ip_vs_conn *cp);
 
-	int (*csum_check)(struct sk_buff *skb, struct ip_vs_protocol *pp);
+	int (*csum_check)(int af, struct sk_buff *skb,
+			  struct ip_vs_protocol *pp);
 
 	const char *(*state_name)(int state);
 
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index a07e5b7..43d7eb2 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -572,6 +572,7 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related)
 	struct iphdr *iph;
 	struct icmphdr	_icmph, *ic;
 	struct iphdr	_ciph, *cih;	/* The ip header contained within the ICMP */
+	struct ip_vs_iphdr ciph;
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
 	unsigned int offset, ihl, verdict;
@@ -627,8 +628,9 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related)
 
 	offset += cih->ihl * 4;
 
+	ip_vs_fill_iphdr(AF_INET, cih, &ciph);
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_out_get(skb, pp, cih, offset, 1);
+	cp = pp->conn_out_get(AF_INET, skb, pp, &ciph, offset, 1);
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -686,43 +688,41 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 	  const struct net_device *in, const struct net_device *out,
 	  int (*okfn)(struct sk_buff *))
 {
-	struct iphdr	*iph;
+	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_conn *cp;
-	int ihl;
 
 	EnterFunction(11);
 
 	if (skb->ipvs_property)
 		return NF_ACCEPT;
 
-	iph = ip_hdr(skb);
-	if (unlikely(iph->protocol == IPPROTO_ICMP)) {
+	ip_vs_fill_iphdr(AF_INET, skb_network_header(skb), &iph);
+	if (unlikely(iph.protocol == IPPROTO_ICMP)) {
 		int related, verdict = ip_vs_out_icmp(skb, &related);
 
 		if (related)
 			return verdict;
-		iph = ip_hdr(skb);
+		ip_vs_fill_iphdr(AF_INET, skb_network_header(skb), &iph);
 	}
 
-	pp = ip_vs_proto_get(iph->protocol);
+	pp = ip_vs_proto_get(iph.protocol);
 	if (unlikely(!pp))
 		return NF_ACCEPT;
 
 	/* reassemble IP fragments */
-	if (unlikely(iph->frag_off & htons(IP_MF|IP_OFFSET) &&
+	if (unlikely(ip_hdr(skb)->frag_off & htons(IP_MF|IP_OFFSET) &&
 		     !pp->dont_defrag)) {
 		if (ip_vs_gather_frags(skb, IP_DEFRAG_VS_OUT))
 			return NF_STOLEN;
-		iph = ip_hdr(skb);
-	}
 
-	ihl = iph->ihl << 2;
+		ip_vs_fill_iphdr(AF_INET, skb_network_header(skb), &iph);
+	}
 
 	/*
 	 * Check if the packet belongs to an existing entry
 	 */
-	cp = pp->conn_out_get(skb, pp, iph, ihl, 0);
+	cp = pp->conn_out_get(AF_INET, skb, pp, &iph, iph.len, 0);
 
 	if (unlikely(!cp)) {
 		if (sysctl_ip_vs_nat_icmp_send &&
@@ -730,18 +730,18 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 		     pp->protocol == IPPROTO_UDP)) {
 			__be16 _ports[2], *pptr;
 
-			pptr = skb_header_pointer(skb, ihl,
+			pptr = skb_header_pointer(skb, iph.len,
 						  sizeof(_ports), _ports);
 			if (pptr == NULL)
 				return NF_ACCEPT;	/* Not for me */
-			if (ip_vs_lookup_real_service(iph->protocol,
-						      iph->saddr, pptr[0])) {
+			if (ip_vs_lookup_real_service(iph.protocol,
+						      iph.saddr.ip, pptr[0])) {
 				/*
 				 * Notify the real server: there is no
 				 * existing entry if it is not RST
 				 * packet or not TCP packet.
 				 */
-				if (iph->protocol != IPPROTO_TCP
+				if (iph.protocol != IPPROTO_TCP
 				    || !is_tcp_reset(skb)) {
 					icmp_send(skb,ICMP_DEST_UNREACH,
 						  ICMP_PORT_UNREACH, 0);
@@ -756,7 +756,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 
 	IP_VS_DBG_PKT(11, pp, skb, 0, "Outgoing packet");
 
-	if (!skb_make_writable(skb, ihl))
+	if (!skb_make_writable(skb, iph.len))
 		goto drop;
 
 	/* mangle the packet */
@@ -804,6 +804,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	struct iphdr *iph;
 	struct icmphdr	_icmph, *ic;
 	struct iphdr	_ciph, *cih;	/* The ip header contained within the ICMP */
+	struct ip_vs_iphdr ciph;
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
 	unsigned int offset, ihl, verdict;
@@ -860,8 +861,9 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 
 	offset += cih->ihl * 4;
 
+	ip_vs_fill_iphdr(AF_INET, cih, &ciph);
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_in_get(skb, pp, cih, offset, 1);
+	cp = pp->conn_in_get(AF_INET, skb, pp, &ciph, offset, 1);
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -897,11 +899,12 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 	 const struct net_device *in, const struct net_device *out,
 	 int (*okfn)(struct sk_buff *))
 {
-	struct iphdr	*iph;
+	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_conn *cp;
 	int ret, restart;
-	int ihl;
+
+	ip_vs_fill_iphdr(AF_INET, skb_network_header(skb), &iph);
 
 	/*
 	 *	Big tappo: only PACKET_HOST (neither loopback nor mcasts)
@@ -909,38 +912,35 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 	 */
 	if (unlikely(skb->pkt_type != PACKET_HOST
 		     || skb->dev->flags & IFF_LOOPBACK || skb->sk)) {
-		IP_VS_DBG(12, "packet type=%d proto=%d daddr=%d.%d.%d.%d ignored\n",
-			  skb->pkt_type,
-			  ip_hdr(skb)->protocol,
-			  NIPQUAD(ip_hdr(skb)->daddr));
+		IP_VS_DBG_BUF(12, "packet type=%d proto=%d daddr=%s ignored\n",
+			      skb->pkt_type,
+			      iph.protocol,
+			      IP_VS_DBG_ADDR(AF_INET, &iph.daddr));
 		return NF_ACCEPT;
 	}
 
-	iph = ip_hdr(skb);
-	if (unlikely(iph->protocol == IPPROTO_ICMP)) {
+	if (unlikely(iph.protocol == IPPROTO_ICMP)) {
 		int related, verdict = ip_vs_in_icmp(skb, &related, hooknum);
 
 		if (related)
 			return verdict;
-		iph = ip_hdr(skb);
+		ip_vs_fill_iphdr(AF_INET, skb_network_header(skb), &iph);
 	}
 
 	/* Protocol supported? */
-	pp = ip_vs_proto_get(iph->protocol);
+	pp = ip_vs_proto_get(iph.protocol);
 	if (unlikely(!pp))
 		return NF_ACCEPT;
 
-	ihl = iph->ihl << 2;
-
 	/*
 	 * Check if the packet belongs to an existing connection entry
 	 */
-	cp = pp->conn_in_get(skb, pp, iph, ihl, 0);
+	cp = pp->conn_in_get(AF_INET, skb, pp, &iph, iph.len, 0);
 
 	if (unlikely(!cp)) {
 		int v;
 
-		if (!pp->conn_schedule(skb, pp, &v, &cp))
+		if (!pp->conn_schedule(AF_INET, skb, pp, &v, &cp))
 			return v;
 	}
 
diff --git a/net/ipv4/ipvs/ip_vs_proto_ah_esp.c b/net/ipv4/ipvs/ip_vs_proto_ah_esp.c
index 3f9ebd7..899df2e 100644
--- a/net/ipv4/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_ah_esp.c
@@ -39,25 +39,23 @@ struct isakmp_hdr {
 
 
 static struct ip_vs_conn *
-ah_esp_conn_in_get(const struct sk_buff *skb,
-		   struct ip_vs_protocol *pp,
-		   const struct iphdr *iph,
-		   unsigned int proto_off,
-		   int inverse)
+ah_esp_conn_in_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
+	           const struct ip_vs_iphdr *iph, unsigned int proto_off,
+	           int inverse)
 {
 	struct ip_vs_conn *cp;
 
 	if (likely(!inverse)) {
 		cp = ip_vs_conn_in_get(IPPROTO_UDP,
-				       iph->saddr,
+				       iph->saddr.ip,
 				       htons(PORT_ISAKMP),
-				       iph->daddr,
+				       iph->daddr.ip,
 				       htons(PORT_ISAKMP));
 	} else {
 		cp = ip_vs_conn_in_get(IPPROTO_UDP,
-				       iph->daddr,
+				       iph->daddr.ip,
 				       htons(PORT_ISAKMP),
-				       iph->saddr,
+				       iph->saddr.ip,
 				       htons(PORT_ISAKMP));
 	}
 
@@ -66,12 +64,12 @@ ah_esp_conn_in_get(const struct sk_buff *skb,
 		 * We are not sure if the packet is from our
 		 * service, so our conn_schedule hook should return NF_ACCEPT
 		 */
-		IP_VS_DBG(12, "Unknown ISAKMP entry for outin packet "
-			  "%s%s %u.%u.%u.%u->%u.%u.%u.%u\n",
-			  inverse ? "ICMP+" : "",
-			  pp->name,
-			  NIPQUAD(iph->saddr),
-			  NIPQUAD(iph->daddr));
+		IP_VS_DBG_BUF(12, "Unknown ISAKMP entry for outin packet "
+			      "%s%s %s->%s\n",
+			      inverse ? "ICMP+" : "",
+			      pp->name,
+			      IP_VS_DBG_ADDR(af, &iph->saddr),
+			      IP_VS_DBG_ADDR(af, &iph->daddr));
 	}
 
 	return cp;
@@ -79,32 +77,35 @@ ah_esp_conn_in_get(const struct sk_buff *skb,
 
 
 static struct ip_vs_conn *
-ah_esp_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
-		    const struct iphdr *iph, unsigned int proto_off, int inverse)
+ah_esp_conn_out_get(int af, const struct sk_buff *skb,
+		    struct ip_vs_protocol *pp,
+	            const struct ip_vs_iphdr *iph,
+		    unsigned int proto_off,
+	            int inverse)
 {
 	struct ip_vs_conn *cp;
 
 	if (likely(!inverse)) {
 		cp = ip_vs_conn_out_get(IPPROTO_UDP,
-					iph->saddr,
+					iph->saddr.ip,
 					htons(PORT_ISAKMP),
-					iph->daddr,
+					iph->daddr.ip,
 					htons(PORT_ISAKMP));
 	} else {
 		cp = ip_vs_conn_out_get(IPPROTO_UDP,
-					iph->daddr,
+					iph->daddr.ip,
 					htons(PORT_ISAKMP),
-					iph->saddr,
+					iph->saddr.ip,
 					htons(PORT_ISAKMP));
 	}
 
 	if (!cp) {
-		IP_VS_DBG(12, "Unknown ISAKMP entry for inout packet "
-			  "%s%s %u.%u.%u.%u->%u.%u.%u.%u\n",
-			  inverse ? "ICMP+" : "",
-			  pp->name,
-			  NIPQUAD(iph->saddr),
-			  NIPQUAD(iph->daddr));
+		IP_VS_DBG_BUF(12, "Unknown ISAKMP entry for inout packet "
+			      "%s%s %s->%s\n",
+			      inverse ? "ICMP+" : "",
+			      pp->name,
+			      IP_VS_DBG_ADDR(af, &iph->saddr),
+			      IP_VS_DBG_ADDR(af, &iph->daddr));
 	}
 
 	return cp;
@@ -112,8 +113,7 @@ ah_esp_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 
 static int
-ah_esp_conn_schedule(struct sk_buff *skb,
-		     struct ip_vs_protocol *pp,
+ah_esp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		     int *verdict, struct ip_vs_conn **cpp)
 {
 	/*
diff --git a/net/ipv4/ipvs/ip_vs_proto_tcp.c b/net/ipv4/ipvs/ip_vs_proto_tcp.c
index fe93c9e..9211afa 100644
--- a/net/ipv4/ipvs/ip_vs_proto_tcp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_tcp.c
@@ -25,8 +25,9 @@
 
 
 static struct ip_vs_conn *
-tcp_conn_in_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
-		const struct iphdr *iph, unsigned int proto_off, int inverse)
+tcp_conn_in_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
+		const struct ip_vs_iphdr *iph, unsigned int proto_off,
+		int inverse)
 {
 	__be16 _ports[2], *pptr;
 
@@ -36,18 +37,19 @@ tcp_conn_in_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 	if (likely(!inverse)) {
 		return ip_vs_conn_in_get(iph->protocol,
-					 iph->saddr, pptr[0],
-					 iph->daddr, pptr[1]);
+					 iph->saddr.ip, pptr[0],
+					 iph->daddr.ip, pptr[1]);
 	} else {
 		return ip_vs_conn_in_get(iph->protocol,
-					 iph->daddr, pptr[1],
-					 iph->saddr, pptr[0]);
+					 iph->daddr.ip, pptr[1],
+					 iph->saddr.ip, pptr[0]);
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
 
@@ -57,26 +59,25 @@ tcp_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 	if (likely(!inverse)) {
 		return ip_vs_conn_out_get(iph->protocol,
-					  iph->saddr, pptr[0],
-					  iph->daddr, pptr[1]);
+					  iph->saddr.ip, pptr[0],
+					  iph->daddr.ip, pptr[1]);
 	} else {
 		return ip_vs_conn_out_get(iph->protocol,
-					  iph->daddr, pptr[1],
-					  iph->saddr, pptr[0]);
+					  iph->daddr.ip, pptr[1],
+					  iph->saddr.ip, pptr[0]);
 	}
 }
 
 
 static int
-tcp_conn_schedule(struct sk_buff *skb,
-		  struct ip_vs_protocol *pp,
+tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		  int *verdict, struct ip_vs_conn **cpp)
 {
 	struct ip_vs_service *svc;
 	struct tcphdr _tcph, *th;
 	struct ip_vs_iphdr iph;
 
-	ip_vs_fill_iphdr(AF_INET, skb_network_header(skb), &iph);
+	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 
 	th = skb_header_pointer(skb, iph.len, sizeof(_tcph), &_tcph);
 	if (th == NULL) {
@@ -85,8 +86,8 @@ tcp_conn_schedule(struct sk_buff *skb,
 	}
 
 	if (th->syn &&
-	    (svc = ip_vs_service_get(AF_INET, skb->mark, iph.protocol,
-				     &iph.daddr, th->dest))) {
+	    (svc = ip_vs_service_get(af, skb->mark, iph.protocol, &iph.daddr,
+				     th->dest))) {
 		if (ip_vs_todrop()) {
 			/*
 			 * It seems that we are very loaded.
@@ -136,7 +137,7 @@ tcp_snat_handler(struct sk_buff *skb,
 
 	if (unlikely(cp->app != NULL)) {
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->csum_check(skb, pp))
+		if (pp->csum_check && !pp->csum_check(AF_INET, skb, pp))
 			return 0;
 
 		/* Call application helper if needed */
@@ -182,7 +183,7 @@ tcp_dnat_handler(struct sk_buff *skb,
 
 	if (unlikely(cp->app != NULL)) {
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->csum_check(skb, pp))
+		if (pp->csum_check && !pp->csum_check(AF_INET, skb, pp))
 			return 0;
 
 		/*
@@ -219,21 +220,43 @@ tcp_dnat_handler(struct sk_buff *skb,
 
 
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
diff --git a/net/ipv4/ipvs/ip_vs_proto_udp.c b/net/ipv4/ipvs/ip_vs_proto_udp.c
index 5aefdf5..5d9e684 100644
--- a/net/ipv4/ipvs/ip_vs_proto_udp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_udp.c
@@ -24,8 +24,9 @@
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
@@ -36,12 +37,12 @@ udp_conn_in_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 	if (likely(!inverse)) {
 		cp = ip_vs_conn_in_get(iph->protocol,
-				       iph->saddr, pptr[0],
-				       iph->daddr, pptr[1]);
+				       iph->saddr.ip, pptr[0],
+				       iph->daddr.ip, pptr[1]);
 	} else {
 		cp = ip_vs_conn_in_get(iph->protocol,
-				       iph->daddr, pptr[1],
-				       iph->saddr, pptr[0]);
+				       iph->daddr.ip, pptr[1],
+				       iph->saddr.ip, pptr[0]);
 	}
 
 	return cp;
@@ -49,25 +50,25 @@ udp_conn_in_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 
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
 		cp = ip_vs_conn_out_get(iph->protocol,
-					iph->saddr, pptr[0],
-					iph->daddr, pptr[1]);
+					iph->saddr.ip, pptr[0],
+					iph->daddr.ip, pptr[1]);
 	} else {
 		cp = ip_vs_conn_out_get(iph->protocol,
-					iph->daddr, pptr[1],
-					iph->saddr, pptr[0]);
+					iph->daddr.ip, pptr[1],
+					iph->saddr.ip, pptr[0]);
 	}
 
 	return cp;
@@ -75,14 +76,14 @@ udp_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 
 static int
-udp_conn_schedule(struct sk_buff *skb, struct ip_vs_protocol *pp,
+udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		  int *verdict, struct ip_vs_conn **cpp)
 {
 	struct ip_vs_service *svc;
 	struct udphdr _udph, *uh;
 	struct ip_vs_iphdr iph;
 
-	ip_vs_fill_iphdr(AF_INET, skb_network_header(skb), &iph);
+	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 
 	uh = skb_header_pointer(skb, iph.len, sizeof(_udph), &_udph);
 	if (uh == NULL) {
@@ -90,8 +91,8 @@ udp_conn_schedule(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		return 0;
 	}
 
-	if ((svc = ip_vs_service_get(AF_INET, skb->mark, iph.protocol,
-				     &iph.daddr, uh->dest))) {
+	if ((svc = ip_vs_service_get(af, skb->mark, iph.protocol, &iph.daddr,
+				     uh->dest))) {
 		if (ip_vs_todrop()) {
 			/*
 			 * It seems that we are very loaded.
@@ -142,7 +143,7 @@ udp_snat_handler(struct sk_buff *skb,
 
 	if (unlikely(cp->app != NULL)) {
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->csum_check(skb, pp))
+		if (pp->csum_check && !pp->csum_check(AF_INET, skb, pp))
 			return 0;
 
 		/*
@@ -194,7 +195,7 @@ udp_dnat_handler(struct sk_buff *skb,
 
 	if (unlikely(cp->app != NULL)) {
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->csum_check(skb, pp))
+		if (pp->csum_check && !pp->csum_check(AF_INET, skb, pp))
 			return 0;
 
 		/*
@@ -233,10 +234,17 @@ udp_dnat_handler(struct sk_buff *skb,
 
 
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
@@ -248,15 +256,28 @@ udp_csum_check(struct sk_buff *skb, struct ip_vs_protocol *pp)
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
-- 
1.5.4.5

