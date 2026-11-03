Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793719571;
	b=HG3ESd/6k1X0FjLgmHXDaSW0a7wsPW3ui+GX5kn9pefl/Nk+DtQB+4t6QCSyKHYpCAg1
	 p0z+EfpXepgzmb4Y0ul0k0052xV+ugunQ0dKvjylK1+yL2W5W3ZI8BDOyUG1ngubqyhjk
	 NoU9qSGsMdut1OBet8Mp975y/uo+RWcWxNmL6qxNu6IJ4UxFHHvGhHPAhOWhqP5FBF8Um
	 DYp0hR+j+JL8v4zQUcKI/8liB9wsa/XaKluZeR2qvh1Y+6lh21nQ5MEoEaDfl6RfM+2qq
	 Zoau0m39O7tj8RLguprCSDVHKUS1U6n46x432NaJffSRJgV4v6VRcRZbDN0mMHqooDA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793719571;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=O/r9/pJwH15snlPsz/c0YkuVh+U8OgohRp7h2NoARHk=;
	b=BlMu8LjwuTXfA1R6niEsHo2yXzIEh26guOHWy6YvwZXoefu5P1jATzAGwawThpn/nLUZ
	 wTjUig8vG8PWp779uDH7WDYFRlhCNYGH2b075ySV7eDyaZX0K/H9/t5c3kBVSFgaSJUdI
	 2LEkADn2YbszoK0soO8jFNCASyfcVCfbO1JXilhUlHF47Y1ZwGhOG47nDYH3nDvgV2wjG
	 hS2jBSQ0J5y/e/SUXUMnogYXVJq1TWhOaQbFtCuw1wwXrGS2TW92TBXsZWmb/Ek/lCcsZ
	 MeyQ9j4hLzKmgC2cKGbHrNL3zoSfXYEQB+ciQRzOZ4WkEVb+wlre0J7jkzOBB9oIqaA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=vv6N73JH;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B52B8606A324;
	Tue,  3 Nov 2026 15:26:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B52B8606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=vv6N73JH
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 8EFC921F88;
	Tue, 03 Nov 2026 17:26:05 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=O/r9/pJw
	H15snlPsz/c0YkuVh+U8OgohRp7h2NoARHk=; b=vv6N73JHvkT6sjyp6foNrVy0
	ls1/NPXUDf4UnKAzh9iWkBTVGmGeKq7Pno6YyOVT4YY4hbH0NZQd9gx2ABLwQkw5
	m1sbNnkz+6OWR3M7hNYEC5i8U0UDXt2nxcpCSn37lQ7spxxHosMWP/xHAQP0PAz4
	FFZwkMaCPZkUzJ2NZ17uOoMW+VMkZeH50S1DRLrWFJgTWW4Xx6HZWUxe5Y/fiOOW
	Q4GuA9XyqG3PKs5qRTrXIyYtcvtYdJDHayhKgsw6/96Mfl7n1yD64oXNolAU8K1n
	egb/1S8DgN2EClicpZdSGLgN+h0i3Q/EO6ltJns6KzvDTTAsW2MpbErg55794iuz
	srI5tYfdhoRQNXPH5ymerEHPl1aUcRlO0vZD7MtN+0sSuHh1pBlgl0iYF/PG8rbv
	tBxkKzQ+wnV9ZN4hLP3y0KZC60tp7V3jMUja2myQEbrXdhIwJen/ut8I3g5/6zVB
	tGZP1dr/rjRutNGs1dCn3BHV+e+nfowR56delCeoNUZodEbfk84von7n2Sj/4b0/
	t6+oWc/uumWqAYE/bH+Adcx4McEmYdL0JamFLJza0mffsYzL/hJHAiexpwZ+MBmr
	WZMjErTs29N9vrk4ntvRCtkOG3MPheW2RYnpTA36sSeGueOm7iDgviE7mTLPRM4w
	cuouj9SdKQbK49QcVF0=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 03 Nov 2026 17:26:05 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 2B752604D5;
	Tue,  3 Nov 2026 17:26:05 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6A3FQ45a060464;
	Tue, 3 Nov 2026 17:26:04 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 6A3FQ3AU060463;
	Tue, 3 Nov 2026 17:26:03 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf v2] ipvs: pass correct sk to update_pmtu and on tunneling
Date: Tue,  3 Nov 2026 17:25:50 +0200
Message-ID: <20261103152550.60449-1-ja@ssi.bg>
X-Mailer: git-send-email 2.56.0
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This commit fixes two cases of providing sk on tunneling,
one to the update_pmtu handler and the second case is to
the ip_local_out() call.

For local clients, we can see at LOCAL_OUT a netfilter hook's
state->sk that is different from the protocol's skb->sk. This
can be the case for UDP_TUNNEL where different sk is provided to
ip_local_out. If such packet is then forwarded via IPVS tunnel
we may need to provide state->sk to the update_pmtu handler.

Fix that by passing the netfilter's hook state via the
packet_xmit and conn_schedule handlers to call the update_pmtu
handler with state->sk instead of skb->sk.

While here, change maybe_update_pmtu() to be family independent
by using dst and do not request neigh confirm via the last
update_pmtu arg because we do not generate the event based on
remote signal.

The second problem is that on tunnel forwarding we call
ip_local_out() with skb->sk. As we push our own outer IP header
in ip_vs_tunnel_xmit*(), the right thing is to provide NULL
instead.

For consistency, even if we do not walk the netfilter hooks and
just pass the packet with NF_ACCEPT, provide ip_vs_null_xmit_v6
handler to properly indicate that we are sending IPv6 packet.
Before now we used ip_vs_null_xmit for both families.

Fixes: 79b16aadea32 ("udp_tunnel: Pass UDP socket down through udp_tunnel{, 6}_xmit_skb().")
Fixes: 7026b1ddb6b8 ("netfilter: Pass socket pointer down through okfn().")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 Changes in v2:
 * v1 was wrongly made against old nf tree with a missing fix in
   ip_vs_bypass_xmit
 * remove some empty lines around ip_vs_null_xmit_v6

 include/net/ip_vs.h                     |  45 +++++++----
 net/netfilter/ipvs/ip_vs_conn.c         |   2 +-
 net/netfilter/ipvs/ip_vs_core.c         |  41 ++++++----
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |   2 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |   5 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |   5 +-
 net/netfilter/ipvs/ip_vs_proto_udp.c    |   5 +-
 net/netfilter/ipvs/ip_vs_xmit.c         | 103 +++++++++++++++---------
 8 files changed, 131 insertions(+), 77 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 9a83bff32569..398d748f01ec 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -731,7 +731,8 @@ struct ip_vs_protocol {
 			     int af, struct sk_buff *skb,
 			     struct ip_vs_proto_data *pd,
 			     int *verdict, struct ip_vs_conn **cpp,
-			     struct ip_vs_iphdr *iph);
+			     struct ip_vs_iphdr *iph,
+			     const struct nf_hook_state *state);
 
 	struct ip_vs_conn *
 	(*conn_in_get)(struct netns_ipvs *ipvs,
@@ -872,7 +873,8 @@ struct ip_vs_conn {
 	 * NF_ACCEPT can be returned when destination is local.
 	 */
 	int (*packet_xmit)(struct sk_buff *skb, struct ip_vs_conn *cp,
-			   struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+			   struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph,
+			   const struct nf_hook_state *state);
 
 	struct rcu_head		rcu_head;
 };
@@ -1871,7 +1873,8 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	       struct ip_vs_proto_data *pd, int *ignored,
 	       struct ip_vs_iphdr *iph);
 int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
-		struct ip_vs_proto_data *pd, struct ip_vs_iphdr *iph);
+		struct ip_vs_proto_data *pd, struct ip_vs_iphdr *iph,
+		const struct nf_hook_state *state);
 
 void ip_vs_scheduler_err(struct ip_vs_service *svc, const char *msg);
 
@@ -1986,32 +1989,46 @@ static inline int ip_vs_est_max_threads(struct netns_ipvs *ipvs)
 
 /* Various IPVS packet transmitters (from ip_vs_xmit.c) */
 int ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		    struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+		    struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph,
+		    const struct nf_hook_state *state);
 int ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		      struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+		      struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph,
+		      const struct nf_hook_state *state);
 int ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		   struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+		   struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph,
+		   const struct nf_hook_state *state);
 int ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		      struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+		      struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph,
+		      const struct nf_hook_state *state);
 int ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph,
+		  const struct nf_hook_state *state);
 int ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		    struct ip_vs_protocol *pp, unsigned int toff,
-		    unsigned int hooknum, struct ip_vs_iphdr *ciph);
+		    const struct nf_hook_state *state,
+		    struct ip_vs_iphdr *ciph);
 void ip_vs_dest_dst_rcu_free(struct rcu_head *head);
 
 #ifdef CONFIG_IP_VS_IPV6
+int ip_vs_null_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
+		       struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph,
+		       const struct nf_hook_state *state);
 int ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-			 struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+			 struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph,
+			 const struct nf_hook_state *state);
 int ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		      struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+		      struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph,
+		      const struct nf_hook_state *state);
 int ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-			 struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+			 struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph,
+			 const struct nf_hook_state *state);
 int ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph,
+		     const struct nf_hook_state *state);
 int ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		       struct ip_vs_protocol *pp, unsigned int toff,
-		       unsigned int hooknum, struct ip_vs_iphdr *ciph);
+		       const struct nf_hook_state *state,
+		       struct ip_vs_iphdr *ciph);
 #endif
 
 #ifdef CONFIG_SYSCTL
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 94f25fb7d87e..0c2eeb987f00 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1070,7 +1070,7 @@ static inline void ip_vs_bind_xmit_v6(struct ip_vs_conn *cp)
 		break;
 
 	case IP_VS_CONN_F_LOCALNODE:
-		cp->packet_xmit = ip_vs_null_xmit;
+		cp->packet_xmit = ip_vs_null_xmit_v6;
 		break;
 
 	case IP_VS_CONN_F_BYPASS:
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index fd503f0efb57..bb649a9f00c7 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -760,7 +760,8 @@ static inline int ip_vs_addr_is_unicast(struct net *net, int af,
  *  no destination is available for a new connection.
  */
 int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
-		struct ip_vs_proto_data *pd, struct ip_vs_iphdr *iph)
+		struct ip_vs_proto_data *pd, struct ip_vs_iphdr *iph,
+		const struct nf_hook_state *state)
 {
 	__be16 _ports[2], *pptr, dport;
 	struct netns_ipvs *ipvs = svc->ipvs;
@@ -805,7 +806,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd, iph->len);
 
 		/* transmit the first SYN packet */
-		ret = cp->packet_xmit(skb, cp, pd->pp, iph);
+		ret = cp->packet_xmit(skb, cp, pd->pp, iph, state);
 		/* do not touch skb anymore */
 
 		if ((cp->flags & IP_VS_CONN_F_ONE_PACKET) && cp->control)
@@ -1647,7 +1648,8 @@ static unsigned int
 ip_vs_try_to_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		      struct ip_vs_proto_data *pd,
 		      int *verdict, struct ip_vs_conn **cpp,
-		      struct ip_vs_iphdr *iph)
+		      struct ip_vs_iphdr *iph,
+		      const struct nf_hook_state *state)
 {
 	struct ip_vs_protocol *pp = pd->pp;
 
@@ -1657,7 +1659,8 @@ ip_vs_try_to_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		 */
 
 		/* Schedule and create new connection entry into cpp */
-		if (!pp->conn_schedule(ipvs, af, skb, pd, verdict, cpp, iph))
+		if (!pp->conn_schedule(ipvs, af, skb, pd, verdict, cpp, iph,
+				       state))
 			return 0;
 	}
 
@@ -1757,7 +1760,7 @@ static int ipvs_gre_decap(struct netns_ipvs *ipvs, struct sk_buff *skb,
  */
 static int
 ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
-	      unsigned int hooknum, struct ip_vs_iphdr *iph)
+	      const struct nf_hook_state *state, struct ip_vs_iphdr *iph)
 {
 	struct icmphdr	_icmph, *ic;
 	struct iphdr	_ciph, *cih;	/* The ip header contained within the ICMP */
@@ -1776,7 +1779,8 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 
 	/* reassemble IP fragments */
 	if (ip_is_fragment(ip_hdr(skb))) {
-		if (ip_vs_gather_frags(ipvs, skb, ip_vs_defrag_user(hooknum)))
+		if (ip_vs_gather_frags(ipvs, skb,
+				       ip_vs_defrag_user(state->hook)))
 			return NF_STOLEN;
 		if (!ip_vs_fill_iph_skb(AF_INET, skb, false, iph))
 			return NF_ACCEPT;
@@ -1893,7 +1897,8 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 		if (tunnel || !sysctl_schedule_icmp(ipvs))
 			return NF_ACCEPT;
 
-		if (!ip_vs_try_to_schedule(ipvs, AF_INET, skb, pd, &v, &cp, &ciph))
+		if (!ip_vs_try_to_schedule(ipvs, AF_INET, skb, pd, &v, &cp,
+					   &ciph, state))
 			return v;
 		new_cp = true;
 	}
@@ -1981,7 +1986,7 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 
 	/* do the statistics and put it back */
 	ip_vs_in_stats(cp, skb);
-	verdict = ip_vs_icmp_xmit(skb, cp, pp, iph->len, hooknum, &ciph);
+	verdict = ip_vs_icmp_xmit(skb, cp, pp, iph->len, state, &ciph);
 
 out:
 	if (likely(!new_cp))
@@ -1994,7 +1999,7 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 
 #ifdef CONFIG_IP_VS_IPV6
 static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
-			    int *related, unsigned int hooknum,
+			    int *related, const struct nf_hook_state *state,
 			    struct ip_vs_iphdr *iph)
 {
 	struct icmp6hdr	_icmph, *ic;
@@ -2060,7 +2065,8 @@ static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
 		if (!sysctl_schedule_icmp(ipvs))
 			return NF_ACCEPT;
 
-		if (!ip_vs_try_to_schedule(ipvs, AF_INET6, skb, pd, &v, &cp, &ciph))
+		if (!ip_vs_try_to_schedule(ipvs, AF_INET6, skb, pd, &v, &cp,
+					   &ciph, state))
 			return v;
 
 		new_cp = true;
@@ -2081,7 +2087,7 @@ static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
 	/* do the statistics and put it back */
 	ip_vs_in_stats(cp, skb);
 
-	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, iph->len, hooknum, &ciph);
+	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, iph->len, state, &ciph);
 
 out:
 	if (likely(!new_cp))
@@ -2150,7 +2156,7 @@ ip_vs_in_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
 			int related;
 			int verdict = ip_vs_in_icmp_v6(ipvs, skb, &related,
-						       hooknum, &iph);
+						       state, &iph);
 
 			if (related)
 				return verdict;
@@ -2160,7 +2166,7 @@ ip_vs_in_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state
 		if (unlikely(iph.protocol == IPPROTO_ICMP)) {
 			int related;
 			int verdict = ip_vs_in_icmp(ipvs, skb, &related,
-						    hooknum, &iph);
+						    state, &iph);
 
 			if (related)
 				return verdict;
@@ -2248,7 +2254,8 @@ ip_vs_in_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state
 	if (unlikely(!cp)) {
 		int v;
 
-		if (!ip_vs_try_to_schedule(ipvs, af, skb, pd, &v, &cp, &iph))
+		if (!ip_vs_try_to_schedule(ipvs, af, skb, pd, &v, &cp, &iph,
+					   state))
 			return v;
 	}
 
@@ -2257,7 +2264,7 @@ ip_vs_in_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state
 	ip_vs_in_stats(cp, skb);
 	ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd, iph.len);
 	if (cp->packet_xmit)
-		ret = cp->packet_xmit(skb, cp, pp, &iph);
+		ret = cp->packet_xmit(skb, cp, pp, &iph, state);
 		/* do not touch skb anymore */
 	else {
 		IP_VS_DBG_RL("warning: packet_xmit is null");
@@ -2320,11 +2327,11 @@ ip_vs_forward_icmp(void *priv, struct sk_buff *skb,
 		if (iphdr.protocol != IPPROTO_ICMPV6)
 			return NF_ACCEPT;
 
-		return ip_vs_in_icmp_v6(ipvs, skb, &r, state->hook, &iphdr);
+		return ip_vs_in_icmp_v6(ipvs, skb, &r, state, &iphdr);
 #endif
 	}
 
-	return ip_vs_in_icmp(ipvs, skb, &r, state->hook, &iphdr);
+	return ip_vs_in_icmp(ipvs, skb, &r, state, &iphdr);
 }
 
 static const struct nf_hook_ops ip_vs_ops4[] = {
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index 44e14acc187e..c7f90b29be51 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -102,7 +102,7 @@ static int
 ah_esp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		     struct ip_vs_proto_data *pd,
 		     int *verdict, struct ip_vs_conn **cpp,
-		     struct ip_vs_iphdr *iph)
+		     struct ip_vs_iphdr *iph, const struct nf_hook_state *state)
 {
 	/*
 	 * AH/ESP is only related traffic. Pass the packet to IP stack.
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index fb8af6b15a39..c5810f86846e 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -17,7 +17,7 @@ static int
 sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		   struct ip_vs_proto_data *pd,
 		   int *verdict, struct ip_vs_conn **cpp,
-		   struct ip_vs_iphdr *iph)
+		   struct ip_vs_iphdr *iph, const struct nf_hook_state *state)
 {
 	struct ip_vs_service *svc;
 	struct sctp_chunkhdr _schunkh, *sch;
@@ -71,7 +71,8 @@ sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		*cpp = ip_vs_schedule(svc, skb, pd, &ignored, iph);
 		if (!*cpp && ignored <= 0) {
 			if (!ignored)
-				*verdict = ip_vs_leave(svc, skb, pd, iph);
+				*verdict = ip_vs_leave(svc, skb, pd, iph,
+						       state);
 			else
 				*verdict = NF_DROP;
 			return 0;
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index fec0e8b47b71..66ae924b04f3 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -35,7 +35,7 @@ static int
 tcp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		  struct ip_vs_proto_data *pd,
 		  int *verdict, struct ip_vs_conn **cpp,
-		  struct ip_vs_iphdr *iph)
+		  struct ip_vs_iphdr *iph, const struct nf_hook_state *state)
 {
 	struct ip_vs_service *svc;
 	struct tcphdr _tcph, *th;
@@ -90,7 +90,8 @@ tcp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		*cpp = ip_vs_schedule(svc, skb, pd, &ignored, iph);
 		if (!*cpp && ignored <= 0) {
 			if (!ignored)
-				*verdict = ip_vs_leave(svc, skb, pd, iph);
+				*verdict = ip_vs_leave(svc, skb, pd, iph,
+						       state);
 			else
 				*verdict = NF_DROP;
 			return 0;
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index f32785682402..58b880c84216 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -31,7 +31,7 @@ static int
 udp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		  struct ip_vs_proto_data *pd,
 		  int *verdict, struct ip_vs_conn **cpp,
-		  struct ip_vs_iphdr *iph)
+		  struct ip_vs_iphdr *iph, const struct nf_hook_state *state)
 {
 	struct ip_vs_service *svc;
 	struct udphdr _udph, *uh;
@@ -78,7 +78,8 @@ udp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		*cpp = ip_vs_schedule(svc, skb, pd, &ignored, iph);
 		if (!*cpp && ignored <= 0) {
 			if (!ignored)
-				*verdict = ip_vs_leave(svc, skb, pd, iph);
+				*verdict = ip_vs_leave(svc, skb, pd, iph,
+						       state);
 			else
 				*verdict = NF_DROP;
 			return 0;
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index ebc6b697ae51..649d687b90f3 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -205,13 +205,15 @@ static inline bool crosses_local_route_boundary(int skb_af, struct sk_buff *skb,
 	return false;
 }
 
-static inline void maybe_update_pmtu(int skb_af, struct sk_buff *skb, int mtu)
+static inline void maybe_update_pmtu(int skb_af, struct sk_buff *skb, int mtu,
+				     const struct nf_hook_state *state)
 {
-	struct sock *sk = skb->sk;
-	struct rtable *ort = skb_rtable(skb);
+	struct dst_entry *dst = skb_dst(skb);
+	struct sock *sk = state->sk;
 
-	if (!skb->dev && sk && sk_fullsock(sk))
-		ort->dst.ops->update_pmtu(&ort->dst, sk, NULL, mtu, true);
+	if (state->hook == NF_INET_LOCAL_OUT && sk && sk_is_inet(sk) &&
+	    sk_fullsock(sk))
+		dst->ops->update_pmtu(dst, sk, NULL, mtu, false);
 }
 
 static inline bool ensure_mtu_is_adequate(struct netns_ipvs *ipvs, int skb_af,
@@ -316,7 +318,7 @@ static int
 __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 		   struct ip_vs_dest *dest,
 		   __be32 daddr, int rt_mode, __be32 *ret_saddr,
-		   struct ip_vs_iphdr *ipvsh)
+		   struct ip_vs_iphdr *ipvsh, const struct nf_hook_state *state)
 {
 	struct net *net = ipvs->net;
 	struct ip_vs_dest_dst *dest_dst;
@@ -417,7 +419,7 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 			IP_VS_DBG_RL("%s(): mtu less than 68\n", __func__);
 			goto err_put;
 		}
-		maybe_update_pmtu(skb_af, skb, mtu);
+		maybe_update_pmtu(skb_af, skb, mtu, state);
 	}
 
 	if (!ensure_mtu_is_adequate(ipvs, skb_af, rt_mode, ipvsh, skb, mtu))
@@ -489,7 +491,8 @@ static int
 __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 		      struct ip_vs_dest *dest,
 		      struct in6_addr *daddr, struct in6_addr *ret_saddr,
-		      struct ip_vs_iphdr *ipvsh, int do_xfrm, int rt_mode)
+		      struct ip_vs_iphdr *ipvsh, int do_xfrm, int rt_mode,
+		      const struct nf_hook_state *state)
 {
 	struct net *net = ipvs->net;
 	struct ip_vs_dest_dst *dest_dst;
@@ -596,7 +599,7 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 				     IPV6_MIN_MTU);
 			goto err_put;
 		}
-		maybe_update_pmtu(skb_af, skb, mtu);
+		maybe_update_pmtu(skb_af, skb, mtu, state);
 	}
 
 	if (!ensure_mtu_is_adequate(ipvs, skb_af, rt_mode, ipvsh, skb, mtu))
@@ -720,12 +723,26 @@ static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
  */
 int
 ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		const struct nf_hook_state *state)
 {
 	/* we do not touch skb and do not need pskb ptr */
 	return ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 1);
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+/*
+ *      NULL transmitter (do nothing except return NF_ACCEPT)
+ */
+int
+ip_vs_null_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
+		   struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		   const struct nf_hook_state *state)
+{
+	/* we do not touch skb and do not need pskb ptr */
+	return ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 1);
+}
+#endif
 
 /*
  *      Bypass transmitter
@@ -734,10 +751,11 @@ ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
  */
 int
 ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		  const struct nf_hook_state *state)
 {
 	if (__ip_vs_get_out_rt(cp->ipvs, cp->af, skb, NULL, ip_hdr(skb)->daddr,
-			       IP_VS_RT_MODE_NON_LOCAL, NULL, ipvsh) < 0)
+			       IP_VS_RT_MODE_NON_LOCAL, NULL, ipvsh, state) < 0)
 		goto tx_error;
 
 	ip_send_check(ip_hdr(skb));
@@ -757,13 +775,15 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		     const struct nf_hook_state *state)
 {
 	struct ipv6hdr *iph = ipv6_hdr(skb);
 
 	if (__ip_vs_get_out_rt_v6(cp->ipvs, cp->af, skb, NULL,
 				  &iph->daddr, NULL,
-				  ipvsh, 0, IP_VS_RT_MODE_NON_LOCAL) < 0)
+				  ipvsh, 0, IP_VS_RT_MODE_NON_LOCAL,
+				  state) < 0)
 		goto tx_error;
 
 	/* Another hack: avoid icmp_send in ip_fragment */
@@ -785,7 +805,8 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
  */
 int
 ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-	       struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+	       struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+	       const struct nf_hook_state *state)
 {
 	struct rtable *rt;		/* Route to the other host */
 	int local, rc, was_input;
@@ -805,7 +826,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	local = __ip_vs_get_out_rt(cp->ipvs, cp->af, skb, cp->dest, cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
-				   IP_VS_RT_MODE_RDR, NULL, ipvsh);
+				   IP_VS_RT_MODE_RDR, NULL, ipvsh, state);
 	if (local < 0)
 		goto tx_error;
 	rt = skb_rtable(skb);
@@ -869,7 +890,8 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		  const struct nf_hook_state *state)
 {
 	struct rt6_info *rt;		/* Route to the other host */
 	int local, rc;
@@ -889,7 +911,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 				      NULL, ipvsh, 0,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL |
-				      IP_VS_RT_MODE_RDR);
+				      IP_VS_RT_MODE_RDR, state);
 	if (local < 0)
 		goto tx_error;
 	rt = dst_rt6_info(skb_dst(skb));
@@ -1145,7 +1167,8 @@ ipvs_gre_encap(struct net *net, struct sk_buff *skb,
  */
 int
 ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		  const struct nf_hook_state *state)
 {
 	struct netns_ipvs *ipvs = cp->ipvs;
 	struct net *net = ipvs->net;
@@ -1167,7 +1190,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
 				   IP_VS_RT_MODE_CONNECT |
-				   IP_VS_RT_MODE_TUNNEL, &saddr, ipvsh);
+				   IP_VS_RT_MODE_TUNNEL, &saddr, ipvsh, state);
 	if (local < 0)
 		goto tx_error;
 	if (local)
@@ -1276,7 +1299,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	ret = ip_vs_tunnel_xmit_prepare(skb, cp);
 	if (ret == NF_ACCEPT)
-		ip_local_out(net, skb->sk, skb);
+		ip_local_out(net, NULL, skb);
 	else if (ret == NF_DROP)
 		kfree_skb(skb);
 
@@ -1290,7 +1313,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		     const struct nf_hook_state *state)
 {
 	struct netns_ipvs *ipvs = cp->ipvs;
 	struct net *net = ipvs->net;
@@ -1312,7 +1336,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 				      &saddr, ipvsh, 1,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL |
-				      IP_VS_RT_MODE_TUNNEL);
+				      IP_VS_RT_MODE_TUNNEL, state);
 	if (local < 0)
 		goto tx_error;
 	if (local)
@@ -1418,7 +1442,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	ret = ip_vs_tunnel_xmit_prepare(skb, cp);
 	if (ret == NF_ACCEPT)
-		ip6_local_out(net, skb->sk, skb);
+		ip6_local_out(net, NULL, skb);
 	else if (ret == NF_DROP)
 		kfree_skb(skb);
 
@@ -1437,14 +1461,15 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
  */
 int
 ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-	      struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+	      struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+	      const struct nf_hook_state *state)
 {
 	int local;
 
 	local = __ip_vs_get_out_rt(cp->ipvs, cp->af, skb, cp->dest, cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
-				   IP_VS_RT_MODE_KNOWN_NH, NULL, ipvsh);
+				   IP_VS_RT_MODE_KNOWN_NH, NULL, ipvsh, state);
 	if (local < 0)
 		goto tx_error;
 	if (local)
@@ -1467,7 +1492,8 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		 struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		 struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		 const struct nf_hook_state *state)
 {
 	int local;
 
@@ -1476,7 +1502,7 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 				      NULL, ipvsh, 0,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL |
-				      IP_VS_RT_MODE_KNOWN_NH);
+				      IP_VS_RT_MODE_KNOWN_NH, state);
 	if (local < 0)
 		goto tx_error;
 	if (local)
@@ -1503,7 +1529,7 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 int
 ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		struct ip_vs_protocol *pp, unsigned int toff,
-		unsigned int hooknum, struct ip_vs_iphdr *ciph)
+		const struct nf_hook_state *state, struct ip_vs_iphdr *ciph)
 {
 	struct rtable	*rt;	/* Route to the other host */
 	int rc;
@@ -1517,7 +1543,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	   translate address/port back */
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
 		if (cp->packet_xmit)
-			rc = cp->packet_xmit(skb, cp, pp, ciph);
+			rc = cp->packet_xmit(skb, cp, pp, ciph, state);
 		else
 			rc = NF_ACCEPT;
 		/* do not touch skb anymore */
@@ -1531,11 +1557,11 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	was_input = rt_is_input_route(skb_rtable(skb));
 
 	/* LOCALNODE from FORWARD hook is not supported */
-	rt_mode = (hooknum != NF_INET_FORWARD) ?
+	rt_mode = (state->hook != NF_INET_FORWARD) ?
 		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
-	local = __ip_vs_get_out_rt(cp->ipvs, cp->af, skb, cp->dest, cp->daddr.ip, rt_mode,
-				   NULL, ciph);
+	local = __ip_vs_get_out_rt(cp->ipvs, cp->af, skb, cp->dest,
+				   cp->daddr.ip, rt_mode, NULL, ciph, state);
 	if (local < 0)
 		goto tx_error;
 	rt = skb_rtable(skb);
@@ -1597,8 +1623,8 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		struct ip_vs_protocol *pp, unsigned int toff,
-		unsigned int hooknum, struct ip_vs_iphdr *ciph)
+		   struct ip_vs_protocol *pp, unsigned int toff,
+		   const struct nf_hook_state *state, struct ip_vs_iphdr *ciph)
 {
 	bool has_ports = false;
 	struct rt6_info	*rt;	/* Route to the other host */
@@ -1612,7 +1638,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	   translate address/port back */
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
 		if (cp->packet_xmit)
-			rc = cp->packet_xmit(skb, cp, pp, ciph);
+			rc = cp->packet_xmit(skb, cp, pp, ciph, state);
 		else
 			rc = NF_ACCEPT;
 		/* do not touch skb anymore */
@@ -1625,11 +1651,12 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	 */
 
 	/* LOCALNODE from FORWARD hook is not supported */
-	rt_mode = (hooknum != NF_INET_FORWARD) ?
+	rt_mode = (state->hook != NF_INET_FORWARD) ?
 		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
 	local = __ip_vs_get_out_rt_v6(cp->ipvs, cp->af, skb, cp->dest,
-				      &cp->daddr.in6, NULL, ciph, 0, rt_mode);
+				      &cp->daddr.in6, NULL, ciph, 0, rt_mode,
+				      state);
 	if (local < 0)
 		goto tx_error;
 	rt = dst_rt6_info(skb_dst(skb));
-- 
2.56.0


