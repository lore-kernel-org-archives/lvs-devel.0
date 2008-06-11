From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 10/26] IPVS: Add IPv6 handler functions to UDP protocol handler.
Date: Wed, 11 Jun 2008 19:11:53 +0200
Message-ID: <1213204329-10973-11-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213204337; bh=kV40FAEYEjpvMc/DVSp5GVQjzlk=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=nagZ86PvqenjQ3pr5bp65wZ5MUZWa+oNzqsOzwr4
	x4IQKokpWpgm4x9j4kUEQ2+fL0Jt1BOVJJOXkWxWTS8tRA==
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com, "Julius R. Volz" <juliusv@google.com>

Define new IPv6-specific handler functions in UDP protocol handler. Set new
function pointers in ip_vs_protocol struct to point to these functions.

Signed-off-by: Julius R. Volz <juliusv@google.com>

 1 files changed, 264 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 76e97ef..ef0d921 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -49,6 +49,31 @@ udp_conn_in_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 	return cp;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static struct ip_vs_conn *
+udp_conn_in_get_v6(const struct sk_buff *skb, struct ip_vs_protocol *pp,
+		   const struct ipv6hdr *iph, unsigned int proto_off, int inverse)
+{
+	struct ip_vs_conn *cp;
+	__be16 _ports[2], *pptr;
+
+	pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
+	if (pptr == NULL)
+		return NULL;
+
+	if (likely(!inverse)) {
+		cp = ip_vs_conn_in_get_v6(iph->nexthdr,
+				          &iph->saddr, pptr[0],
+				          &iph->daddr, pptr[1]);
+	} else {
+		cp = ip_vs_conn_in_get_v6(iph->nexthdr,
+				          &iph->daddr, pptr[1],
+				          &iph->saddr, pptr[0]);
+	}
+
+	return cp;
+}
+#endif
 
 static struct ip_vs_conn *
 udp_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
@@ -75,6 +100,33 @@ udp_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 	return cp;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static struct ip_vs_conn *
+udp_conn_out_get_v6(const struct sk_buff *skb, struct ip_vs_protocol *pp,
+		    const struct ipv6hdr *iph, unsigned int proto_off, int inverse)
+{
+	struct ip_vs_conn *cp;
+	__be16 _ports[2], *pptr;
+
+	pptr = skb_header_pointer(skb, sizeof(struct ipv6hdr),
+				  sizeof(_ports), _ports);
+	if (pptr == NULL)
+		return NULL;
+
+	if (likely(!inverse)) {
+		cp = ip_vs_conn_out_get_v6(iph->nexthdr,
+					   &iph->saddr, pptr[0],
+					   &iph->daddr, pptr[1]);
+	} else {
+		cp = ip_vs_conn_out_get_v6(iph->nexthdr,
+					   &iph->daddr, pptr[1],
+					   &iph->saddr, pptr[0]);
+	}
+
+	return cp;
+}
+#endif
+
 
 static int
 udp_conn_schedule(struct sk_buff *skb, struct ip_vs_protocol *pp,
@@ -116,6 +168,48 @@ udp_conn_schedule(struct sk_buff *skb, struct ip_vs_protocol *pp,
 	return 1;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static int
+udp_conn_schedule_v6(struct sk_buff *skb, struct ip_vs_protocol *pp,
+		     int *verdict, struct ip_vs_conn **cpp)
+{
+	struct ip_vs_service *svc;
+	struct udphdr _udph, *uh;
+
+	uh = skb_header_pointer(skb, sizeof(struct ipv6hdr),
+				sizeof(_udph), &_udph);
+	if (uh == NULL) {
+		*verdict = NF_DROP;
+		return 0;
+	}
+
+	if ((svc = ip_vs_service_get_v6(skb->mark, ipv6_hdr(skb)->nexthdr,
+					&ipv6_hdr(skb)->daddr, uh->dest))) {
+		if (ip_vs_todrop()) {
+			/*
+			 * It seems that we are very loaded.
+			 * We have to drop this packet :(
+			 */
+			ip_vs_service_put(svc);
+			*verdict = NF_DROP;
+			return 0;
+		}
+
+		/*
+		 * Let the virtual server select a real server for the
+		 * incoming connection, and create a connection entry.
+		 */
+		*cpp = ip_vs_schedule_v6(svc, skb);
+		if (!*cpp) {
+			*verdict = ip_vs_leave_v6(svc, skb, pp);
+			return 0;
+		}
+		ip_vs_service_put(svc);
+	}
+	return 1;
+}
+#endif
+
 
 static inline void
 udp_fast_csum_update(struct udphdr *uhdr, __be32 oldip, __be32 newip,
@@ -129,6 +223,21 @@ udp_fast_csum_update(struct udphdr *uhdr, __be32 oldip, __be32 newip,
 		uhdr->check = CSUM_MANGLED_0;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static inline void
+udp_fast_csum_update_v6(struct udphdr *uhdr, const struct in6_addr *oldip,
+			const struct in6_addr *newip, __be16 oldport,
+			__be16 newport)
+{
+	uhdr->check =
+		csum_fold(ip_vs_check_diff16(oldip->s6_addr32, newip->s6_addr32,
+				 ip_vs_check_diff2(oldport, newport,
+					~csum_unfold(uhdr->check))));
+	if (!uhdr->check)
+		uhdr->check = CSUM_MANGLED_0;
+}
+#endif
+
 static int
 udp_snat_handler(struct sk_buff *skb,
 		 struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
@@ -180,6 +289,59 @@ udp_snat_handler(struct sk_buff *skb,
 	return 1;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static int
+udp_snat_handler_v6(struct sk_buff *skb,
+		    struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
+{
+	struct udphdr *udph;
+	const unsigned int udphoff = sizeof(struct ipv6hdr);
+
+	/* csum_check requires unshared skb */
+	if (!skb_make_writable(skb, udphoff+sizeof(*udph)))
+		return 0;
+
+	if (unlikely(cp->app != NULL)) {
+		/* Some checks before mangling */
+		if (pp->csum_check_v6 && !pp->csum_check_v6(skb, pp))
+			return 0;
+
+		/*
+		 *	Call application helper if needed
+		 */
+		if (!ip_vs_app_pkt_out(cp, skb))
+			return 0;
+	}
+
+	udph = (void *)ipv6_hdr(skb) + udphoff;
+	udph->source = cp->vport;
+
+	/*
+	 *	Adjust UDP checksums
+	 */
+	if (!cp->app && (udph->check != 0)) {
+		/* Only port and addr are changed, do fast csum update */
+		udp_fast_csum_update_v6(udph, &cp->daddr.v6, &cp->vaddr.v6,
+					cp->dport, cp->vport);
+		if (skb->ip_summed == CHECKSUM_COMPLETE)
+			skb->ip_summed = CHECKSUM_NONE;
+	} else {
+		/* full checksum calculation */
+		udph->check = 0;
+		skb->csum = skb_checksum(skb, udphoff, skb->len - udphoff, 0);
+		udph->check = csum_ipv6_magic(&cp->vaddr.v6, &cp->caddr.v6,
+					      skb->len - udphoff,
+					      cp->protocol, skb->csum);
+		if (udph->check == 0)
+			udph->check = CSUM_MANGLED_0;
+		IP_VS_DBG(11, "O-pkt: %s O-csum=%d (+%zd)\n",
+			  pp->name, udph->check,
+			  (char*)&(udph->check) - (char*)udph);
+	}
+	return 1;
+}
+#endif
+
 
 static int
 udp_dnat_handler(struct sk_buff *skb,
@@ -231,6 +393,58 @@ udp_dnat_handler(struct sk_buff *skb,
 	return 1;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static int
+udp_dnat_handler_v6(struct sk_buff *skb,
+		    struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
+{
+	struct udphdr *udph;
+	unsigned int udphoff = sizeof(struct ipv6hdr);
+
+	/* csum_check requires unshared skb */
+	if (!skb_make_writable(skb, udphoff+sizeof(*udph)))
+		return 0;
+
+	if (unlikely(cp->app != NULL)) {
+		/* Some checks before mangling */
+		if (pp->csum_check_v6 && !pp->csum_check_v6(skb, pp))
+			return 0;
+
+		/*
+		 *	Attempt ip_vs_app call.
+		 *	It will fix ip_vs_conn
+		 */
+		if (!ip_vs_app_pkt_in(cp, skb))
+			return 0;
+	}
+
+	udph = (void *)ipv6_hdr(skb) + udphoff;
+	udph->dest = cp->dport;
+
+	/*
+	 *	Adjust UDP checksums
+	 */
+	if (!cp->app && (udph->check != 0)) {
+		/* Only port and addr are changed, do fast csum update */
+		udp_fast_csum_update_v6(udph, &cp->vaddr.v6, &cp->daddr.v6,
+					cp->vport, cp->dport);
+		if (skb->ip_summed == CHECKSUM_COMPLETE)
+			skb->ip_summed = CHECKSUM_NONE;
+	} else {
+		/* full checksum calculation */
+		udph->check = 0;
+		skb->csum = skb_checksum(skb, udphoff, skb->len - udphoff, 0);
+		udph->check = csum_ipv6_magic(&cp->caddr.v6, &cp->daddr.v6,
+					      skb->len - udphoff,
+					      cp->protocol, skb->csum);
+		if (udph->check == 0)
+			udph->check = CSUM_MANGLED_0;
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	}
+	return 1;
+}
+#endif
+
 
 static int
 udp_csum_check(struct sk_buff *skb, struct ip_vs_protocol *pp)
@@ -266,6 +480,42 @@ udp_csum_check(struct sk_buff *skb, struct ip_vs_protocol *pp)
 	return 1;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static int
+udp_csum_check_v6(struct sk_buff *skb, struct ip_vs_protocol *pp)
+{
+	struct udphdr _udph, *uh;
+	const unsigned int udphoff = sizeof(struct ipv6hdr);
+
+	uh = skb_header_pointer(skb, udphoff, sizeof(_udph), &_udph);
+	if (uh == NULL)
+		return 0;
+
+	if (uh->check != 0) {
+		switch (skb->ip_summed) {
+		case CHECKSUM_NONE:
+			skb->csum = skb_checksum(skb, udphoff,
+						 skb->len - udphoff, 0);
+		case CHECKSUM_COMPLETE:
+			if (csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+					    &ipv6_hdr(skb)->daddr,
+					    skb->len - udphoff,
+					    ipv6_hdr(skb)->nexthdr,
+					    skb->csum)) {
+				IP_VS_DBG_RL_PKT(0, pp, skb, 0,
+						 "Failed checksum for");
+				return 0;
+			}
+			break;
+		default:
+			/* No need to checksum. */
+			break;
+		}
+	}
+	return 1;
+}
+#endif
+
 
 /*
  *	Note: the caller guarantees that only one of register_app,
@@ -413,7 +663,6 @@ static void udp_exit(struct ip_vs_protocol *pp)
 {
 }
 
-
 struct ip_vs_protocol ip_vs_protocol_udp = {
 	.name =			"UDP",
 	.protocol =		IPPROTO_UDP,
@@ -422,11 +671,25 @@ struct ip_vs_protocol ip_vs_protocol_udp = {
 	.init =			udp_init,
 	.exit =			udp_exit,
 	.conn_schedule =	udp_conn_schedule,
+#ifdef CONFIG_IP_VS_IPV6
+	.conn_schedule_v6 =	udp_conn_schedule_v6,
+#endif
 	.conn_in_get =		udp_conn_in_get,
 	.conn_out_get =		udp_conn_out_get,
+#ifdef CONFIG_IP_VS_IPV6
+	.conn_in_get_v6 =	udp_conn_in_get_v6,
+	.conn_out_get_v6 =	udp_conn_out_get_v6,
+#endif
 	.snat_handler =		udp_snat_handler,
 	.dnat_handler =		udp_dnat_handler,
+#ifdef CONFIG_IP_VS_IPV6
+	.snat_handler_v6 =	udp_snat_handler_v6,
+	.dnat_handler_v6 =	udp_dnat_handler_v6,
+#endif
 	.csum_check =		udp_csum_check,
+#ifdef CONFIG_IP_VS_IPV6
+	.csum_check_v6 =	udp_csum_check_v6,
+#endif
 	.state_transition =	udp_state_transition,
 	.state_name =		udp_state_name,
 	.register_app =		udp_register_app,
-- 
1.5.3.6

