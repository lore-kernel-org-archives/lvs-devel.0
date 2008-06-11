From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 09/26] IPVS: Add IPv6 handler functions to TCP protocol handler.
Date: Wed, 11 Jun 2008 19:11:52 +0200
Message-ID: <1213204329-10973-10-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213204337; bh=ewrvD07VA4MYVAlYERHnZNOyTkc=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=EYZyScgV9NEtH33EBnpFuvK1WhNhxeuQ4P3q1HWE
	HHBe5L6nI70H8Crsw3wUYFMtm5SwcYNL1RmAE/CTyWQUBA==
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com, "Julius R. Volz" <juliusv@google.com>

Define new IPv6-specific handler functions in TCP protocol handler. Set new
function pointers in ip_vs_protocol struct to point to these functions.

Introduce new ip_vs_check_diff16() function for recalculating IPv6 address
checksums.

Signed-off-by: Julius R. Volz <juliusv@google.com>

 2 files changed, 260 insertions(+), 1 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 9ae04d0..a6e7438 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1094,6 +1094,17 @@ static inline __wsum ip_vs_check_diff4(__be32 old, __be32 new, __wsum oldsum)
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
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 0efb3e4..02bf859 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -47,6 +47,29 @@ tcp_conn_in_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 	}
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static struct ip_vs_conn *
+tcp_conn_in_get_v6(const struct sk_buff *skb, struct ip_vs_protocol *pp,
+		const struct ipv6hdr *iph, unsigned int proto_off, int inverse)
+{
+	__be16 _ports[2], *pptr;
+
+	pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
+	if (pptr == NULL)
+		return NULL;
+
+	if (likely(!inverse)) {
+		return ip_vs_conn_in_get_v6(iph->nexthdr,
+					    &iph->saddr, pptr[0],
+					    &iph->daddr, pptr[1]);
+	} else {
+		return ip_vs_conn_in_get_v6(iph->nexthdr,
+					    &iph->daddr, pptr[1],
+					    &iph->saddr, pptr[0]);
+	}
+}
+#endif
+
 static struct ip_vs_conn *
 tcp_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 		 const struct iphdr *iph, unsigned int proto_off, int inverse)
@@ -68,6 +91,29 @@ tcp_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 	}
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static struct ip_vs_conn *
+tcp_conn_out_get_v6(const struct sk_buff *skb, struct ip_vs_protocol *pp,
+		 const struct ipv6hdr *iph, unsigned int proto_off, int inverse)
+{
+	__be16 _ports[2], *pptr;
+
+	pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
+	if (pptr == NULL)
+		return NULL;
+
+	if (likely(!inverse)) {
+		return ip_vs_conn_out_get_v6(iph->nexthdr,
+					     &iph->saddr, pptr[0],
+					     &iph->daddr, pptr[1]);
+	} else {
+		return ip_vs_conn_out_get_v6(iph->nexthdr,
+					     &iph->daddr, pptr[1],
+					     &iph->saddr, pptr[0]);
+	}
+}
+#endif
+
 
 static int
 tcp_conn_schedule(struct sk_buff *skb,
@@ -110,6 +156,50 @@ tcp_conn_schedule(struct sk_buff *skb,
 	return 1;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static int
+tcp_conn_schedule_v6(struct sk_buff *skb,
+		     struct ip_vs_protocol *pp,
+		     int *verdict, struct ip_vs_conn **cpp)
+{
+	struct ip_vs_service *svc;
+	struct tcphdr _tcph, *th;
+
+	th = skb_header_pointer(skb, sizeof(struct ipv6hdr), sizeof(_tcph),
+				&_tcph);
+	if (th == NULL) {
+		*verdict = NF_DROP;
+		return 0;
+	}
+
+	if (th->syn &&
+	    (svc = ip_vs_service_get_v6(skb->mark, ipv6_hdr(skb)->nexthdr,
+				        &ipv6_hdr(skb)->daddr, th->dest))) {
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
 tcp_fast_csum_update(struct tcphdr *tcph, __be32 oldip, __be32 newip,
@@ -121,6 +211,19 @@ tcp_fast_csum_update(struct tcphdr *tcph, __be32 oldip, __be32 newip,
 						~csum_unfold(tcph->check))));
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static inline void
+tcp_fast_csum_update_v6(struct tcphdr *tcph, const struct in6_addr *oldip,
+		        const struct in6_addr *newip, __be16 oldport,
+			__be16 newport)
+{
+	tcph->check =
+		csum_fold(ip_vs_check_diff16(oldip->s6_addr32, newip->s6_addr32,
+				 ip_vs_check_diff2(oldport, newport,
+						~csum_unfold(tcph->check))));
+}
+#endif
+
 
 static int
 tcp_snat_handler(struct sk_buff *skb,
@@ -167,6 +270,53 @@ tcp_snat_handler(struct sk_buff *skb,
 	return 1;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static int
+tcp_snat_handler_v6(struct sk_buff *skb,
+		    struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
+{
+	struct tcphdr *tcph;
+	const unsigned int tcphoff = sizeof(struct ipv6hdr);
+
+	/* csum_check_v6 requires unshared skb */
+	if (!skb_make_writable(skb, tcphoff+sizeof(*tcph)))
+		return 0;
+
+	if (unlikely(cp->app != NULL)) {
+		/* Some checks before mangling */
+		if (pp->csum_check_v6 && !pp->csum_check_v6(skb, pp))
+			return 0;
+
+		/* Call application helper if needed */
+		if (!ip_vs_app_pkt_out(cp, skb))
+			return 0;
+	}
+
+	tcph = (void *)ipv6_hdr(skb) + tcphoff;
+	tcph->source = cp->vport;
+
+	/* Adjust TCP checksums */
+	if (!cp->app) {
+		/* Only port and addr are changed, do fast csum update */
+		tcp_fast_csum_update_v6(tcph, &cp->daddr.v6, &cp->vaddr.v6,
+				        cp->dport, cp->vport);
+		if (skb->ip_summed == CHECKSUM_COMPLETE)
+			skb->ip_summed = CHECKSUM_NONE;
+	} else {
+		/* full checksum calculation */
+		tcph->check = 0;
+		skb->csum = skb_checksum(skb, tcphoff, skb->len - tcphoff, 0);
+		tcph->check = csum_ipv6_magic(&cp->vaddr.v6, &cp->caddr.v6,
+					      skb->len - tcphoff,
+					      cp->protocol, skb->csum);
+		IP_VS_DBG(11, "O-pkt: %s O-csum=%d (+%zd)\n",
+			  pp->name, tcph->check,
+			  (char*)&(tcph->check) - (char*)tcph);
+	}
+	return 1;
+}
+#endif
+
 
 static int
 tcp_dnat_handler(struct sk_buff *skb,
@@ -216,6 +366,56 @@ tcp_dnat_handler(struct sk_buff *skb,
 	return 1;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static int
+tcp_dnat_handler_v6(struct sk_buff *skb,
+		    struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
+{
+	struct tcphdr *tcph;
+	const unsigned int tcphoff = sizeof(struct ipv6hdr);
+
+	/* csum_check_v6 requires unshared skb */
+	if (!skb_make_writable(skb, tcphoff+sizeof(*tcph)))
+		return 0;
+
+	if (unlikely(cp->app != NULL)) {
+		/* Some checks before mangling */
+		if (pp->csum_check_v6 && !pp->csum_check_v6(skb, pp))
+			return 0;
+
+		/*
+		 *	Attempt ip_vs_app call.
+		 *	It will fix ip_vs_conn and iph ack_seq stuff
+		 */
+		if (!ip_vs_app_pkt_in(cp, skb))
+			return 0;
+	}
+
+	tcph = (void *)ipv6_hdr(skb) + tcphoff;
+	tcph->dest = cp->dport;
+
+	/*
+	 *	Adjust TCP checksums
+	 */
+	if (!cp->app) {
+		/* Only port and addr are changed, do fast csum update */
+		tcp_fast_csum_update_v6(tcph, &cp->vaddr.v6, &cp->daddr.v6,
+					cp->vport, cp->dport);
+		if (skb->ip_summed == CHECKSUM_COMPLETE)
+			skb->ip_summed = CHECKSUM_NONE;
+	} else {
+		/* full checksum calculation */
+		tcph->check = 0;
+		skb->csum = skb_checksum(skb, tcphoff, skb->len - tcphoff, 0);
+		tcph->check = csum_ipv6_magic(&cp->caddr.v6, &cp->daddr.v6,
+					      skb->len - tcphoff,
+					      cp->protocol, skb->csum);
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	}
+	return 1;
+}
+#endif
+
 
 static int
 tcp_csum_check(struct sk_buff *skb, struct ip_vs_protocol *pp)
@@ -242,6 +442,35 @@ tcp_csum_check(struct sk_buff *skb, struct ip_vs_protocol *pp)
 	return 1;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static int
+tcp_csum_check_v6(struct sk_buff *skb, struct ip_vs_protocol *pp)
+{
+	const unsigned int tcphoff = sizeof(struct ipv6hdr);
+	return 1;
+
+	switch (skb->ip_summed) {
+	case CHECKSUM_NONE:
+		skb->csum = skb_checksum(skb, tcphoff, skb->len - tcphoff, 0);
+	case CHECKSUM_COMPLETE:
+		if (csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+				    &ipv6_hdr(skb)->daddr,
+				    skb->len - tcphoff,
+				    ipv6_hdr(skb)->nexthdr, skb->csum)) {
+			IP_VS_DBG_RL_PKT(0, pp, skb, 0,
+					 "Failed checksum for");
+			return 0;
+		}
+		break;
+	default:
+		/* No need to checksum. */
+		break;
+	}
+
+	return 1;
+}
+#endif
+
 
 #define TCP_DIR_INPUT		0
 #define TCP_DIR_OUTPUT		4
@@ -477,8 +706,13 @@ tcp_state_transition(struct ip_vs_conn *cp, int direction,
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
 
@@ -625,11 +859,25 @@ struct ip_vs_protocol ip_vs_protocol_tcp = {
 	.register_app =		tcp_register_app,
 	.unregister_app =	tcp_unregister_app,
 	.conn_schedule =	tcp_conn_schedule,
+#ifdef CONFIG_IP_VS_IPV6
+	.conn_schedule_v6 =	tcp_conn_schedule_v6,
+#endif
 	.conn_in_get =		tcp_conn_in_get,
 	.conn_out_get =		tcp_conn_out_get,
+#ifdef CONFIG_IP_VS_IPV6
+	.conn_in_get_v6 =	tcp_conn_in_get_v6,
+	.conn_out_get_v6 =	tcp_conn_out_get_v6,
+#endif
 	.snat_handler =		tcp_snat_handler,
 	.dnat_handler =		tcp_dnat_handler,
+#ifdef CONFIG_IP_VS_IPV6
+	.snat_handler_v6 =	tcp_snat_handler_v6,
+	.dnat_handler_v6 =	tcp_dnat_handler_v6,
+#endif
 	.csum_check =		tcp_csum_check,
+#ifdef CONFIG_IP_VS_IPV6
+	.csum_check_v6 =	tcp_csum_check_v6,
+#endif
 	.state_name =		tcp_state_name,
 	.state_transition =	tcp_state_transition,
 	.app_conn_bind =	tcp_app_conn_bind,
-- 
1.5.3.6

