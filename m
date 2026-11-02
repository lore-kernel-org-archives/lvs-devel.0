Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793607676;
	b=mGvXbyTDox//F6R+mIG5TY+PfCimESj9HbHw+/m+p/0gGdr8/WWduz1lWNhJxf1S0SU4
	 nsGGAshiU91TZvX6I/vpjybBLkeFEMb+C9Ju3v3uqrcS/1snQBhYBjKdZ8X5D4Gbkb6kp
	 s2mQB2c9+bAvNYxDUw3XsujJA8+RocXvIu8/55iI6+76fXt0fsG6jftV9KlWaS/nn8xl9
	 w9JQ7Xsfl7N/6RSeYZgRQyMX3atRWlOrPbh5MKFNswUkAtNCX0eLFKFllEIK7LKOCc0SZ
	 L/6g60EU5aMy9rRNRUSZpjfP78CPQYxuTAYWtZGKDag+6hw4vfl9GkHVfD4TNjZlvXA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793607676;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=qiDBsXSwzIr2xcGIItImI4ixycOn9QTE4b/eDJI9F5Q=;
	b=ym92bAQY1P/2It4cH7GyARifMXSNsbzOJtQ5YNuH0mn6pldHSI/4+b+ZNgBWvVspfJ9G
	 DMHksSftcP4MIaSHj6jfwGtN5g42CHumWbe+xiRhKEF9EhXVDwRC0r1Uj+1/UJ9A2oktX
	 9jc/+Hmobx+u3BZC6+nihwxYuNteZeA24b68xt831aUIeb36nM2vjam0W9tkOWfyJa6Ij
	 K0P3JZU6BDkgFY+MTuYlCDFP5LdHWXtoONmLf195TvINlddH+SoplM4bPHcZa2V138kh2
	 NkVcabziKLHT+TnsHnf+YWTTy5dKRi262C3u+BNpL8Qe+zSbKulaxxQFMES3pXfoQcA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=JDfYE61F;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C1589606A333;
	Mon,  2 Nov 2026 08:21:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C1589606A333
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=JDfYE61F
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 9C55221F89;
	Mon, 02 Nov 2026 10:21:12 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=qiDBsXSw
	zIr2xcGIItImI4ixycOn9QTE4b/eDJI9F5Q=; b=JDfYE61F+EgWix6Wp+On/p0A
	K3CN8SWDx0XMn+JoVWjm8aCnB1woyl8q1GVe41FakOY5PCFBFNwZn7AKsdNIEADd
	FnRNsLmP61U6WU8CxWDQffAi6beairJBGmbdXrt5kPuBz4rW0hL3ReF2YOIT11dI
	4rtGmLa1ajSus6CvegbX2VHIvzzyTTksq9cEiJQ9ZjQ21D0QIZgIgn//iiKwY2cY
	TZWdB/sqjcsCqan0H4i6cyj1zjBroqpC37k7pT2v0cJT5BAYWIqmPeE+rjP0Hnxd
	2wnN+kYAgit8d/ADgPuUpMn4PxH55If5Avg0opZ0oPEED1yc95QXDdbQpJSNgrkD
	FXAGZ9QR8tKiIvqxPv3WtLAO1cdFQNReEPdWKFS+nY2CyUDPsSG9+FHOwF0Q/HVx
	gJ9FdJSzQ5G2dve1dr6PY5tQFdyanTlt27m3q2GtQIJiROwdcIpmXqES7bq58weC
	p8ym54VItiGNEdZcYxhFyFYJciNAFUebaJkDufZPzE8UYShJD8E2xkW+u761AIQF
	0+W1AwwMZmbqZBFBdKxDRxMhzGr0jct4r4Q/uEPj5BcpWMgmw5/0vz1FDBCeRIGM
	Oe5DW8IhqL4dG9aaGE+tyrYltnIvDdU7eyHg5rDzcn4HVg/Kj9HfyOezDgFhDynz
	04+5pqp/8Qm/bKE1WNY=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 02 Nov 2026 10:21:12 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 26D4B60050;
	Mon,  2 Nov 2026 10:21:12 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6A28LAVP023454;
	Mon, 2 Nov 2026 10:21:10 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 6A28LAPZ023453;
	Mon, 2 Nov 2026 10:21:10 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf] ipvs: pass correct sk to update_pmtu and on tunneling
Date: Mon,  2 Nov 2026 10:21:01 +0200
Message-ID: <20261102082101.23437-1-ja@ssi.bg>
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
 include/net/ip_vs.h                     |  45 ++++++----
 net/netfilter/ipvs/ip_vs_conn.c         |   2 +-
 net/netfilter/ipvs/ip_vs_core.c         |  41 +++++----
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |   2 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |   5 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |   5 +-
 net/netfilter/ipvs/ip_vs_proto_udp.c    |   5 +-
 net/netfilter/ipvs/ip_vs_xmit.c         | 106 +++++++++++++++---------
 8 files changed, 134 insertions(+), 77 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index f5fe2e0af64a..737a2982f857 100644
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
@@ -1870,7 +1872,8 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	       struct ip_vs_proto_data *pd, int *ignored,
 	       struct ip_vs_iphdr *iph);
 int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
-		struct ip_vs_proto_data *pd, struct ip_vs_iphdr *iph);
+		struct ip_vs_proto_data *pd, struct ip_vs_iphdr *iph,
+		const struct nf_hook_state *state);
 
 void ip_vs_scheduler_err(struct ip_vs_service *svc, const char *msg);
 
@@ -1985,32 +1988,46 @@ static inline int ip_vs_est_max_threads(struct netns_ipvs *ipvs)
 
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
index 2895b2b11968..7f20e8ea5598 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1084,7 +1084,7 @@ static inline void ip_vs_bind_xmit_v6(struct ip_vs_conn *cp)
 		break;
 
 	case IP_VS_CONN_F_LOCALNODE:
-		cp->packet_xmit = ip_vs_null_xmit;
+		cp->packet_xmit = ip_vs_null_xmit_v6;
 		break;
 
 	case IP_VS_CONN_F_BYPASS:
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 8cdcab7d6edf..38dcd2d49f34 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -761,7 +761,8 @@ static inline int ip_vs_addr_is_unicast(struct net *net, int af,
  *  no destination is available for a new connection.
  */
 int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
-		struct ip_vs_proto_data *pd, struct ip_vs_iphdr *iph)
+		struct ip_vs_proto_data *pd, struct ip_vs_iphdr *iph,
+		const struct nf_hook_state *state)
 {
 	__be16 _ports[2], *pptr, dport;
 	struct netns_ipvs *ipvs = svc->ipvs;
@@ -806,7 +807,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd, iph->len);
 
 		/* transmit the first SYN packet */
-		ret = cp->packet_xmit(skb, cp, pd->pp, iph);
+		ret = cp->packet_xmit(skb, cp, pd->pp, iph, state);
 		/* do not touch skb anymore */
 
 		if ((cp->flags & IP_VS_CONN_F_ONE_PACKET) && cp->control)
@@ -1649,7 +1650,8 @@ static unsigned int
 ip_vs_try_to_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		      struct ip_vs_proto_data *pd,
 		      int *verdict, struct ip_vs_conn **cpp,
-		      struct ip_vs_iphdr *iph)
+		      struct ip_vs_iphdr *iph,
+		      const struct nf_hook_state *state)
 {
 	struct ip_vs_protocol *pp = pd->pp;
 
@@ -1659,7 +1661,8 @@ ip_vs_try_to_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		 */
 
 		/* Schedule and create new connection entry into cpp */
-		if (!pp->conn_schedule(ipvs, af, skb, pd, verdict, cpp, iph))
+		if (!pp->conn_schedule(ipvs, af, skb, pd, verdict, cpp, iph,
+				       state))
 			return 0;
 	}
 
@@ -1759,7 +1762,7 @@ static int ipvs_gre_decap(struct netns_ipvs *ipvs, struct sk_buff *skb,
  */
 static int
 ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
-	      unsigned int hooknum, struct ip_vs_iphdr *iph)
+	      const struct nf_hook_state *state, struct ip_vs_iphdr *iph)
 {
 	struct icmphdr	_icmph, *ic;
 	struct iphdr	_ciph, *cih;	/* The ip header contained within the ICMP */
@@ -1778,7 +1781,8 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 
 	/* reassemble IP fragments */
 	if (ip_is_fragment(ip_hdr(skb))) {
-		if (ip_vs_gather_frags(ipvs, skb, ip_vs_defrag_user(hooknum)))
+		if (ip_vs_gather_frags(ipvs, skb,
+				       ip_vs_defrag_user(state->hook)))
 			return NF_STOLEN;
 		if (!ip_vs_fill_iph_skb(AF_INET, skb, false, iph))
 			return NF_ACCEPT;
@@ -1895,7 +1899,8 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 		if (tunnel || !sysctl_schedule_icmp(ipvs))
 			return NF_ACCEPT;
 
-		if (!ip_vs_try_to_schedule(ipvs, AF_INET, skb, pd, &v, &cp, &ciph))
+		if (!ip_vs_try_to_schedule(ipvs, AF_INET, skb, pd, &v, &cp,
+					   &ciph, state))
 			return v;
 		new_cp = true;
 	}
@@ -1982,7 +1987,7 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 
 	/* do the statistics and put it back */
 	ip_vs_in_stats(cp, skb);
-	verdict = ip_vs_icmp_xmit(skb, cp, pp, iph->len, hooknum, &ciph);
+	verdict = ip_vs_icmp_xmit(skb, cp, pp, iph->len, state, &ciph);
 
 out:
 	if (likely(!new_cp))
@@ -1995,7 +2000,7 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 
 #ifdef CONFIG_IP_VS_IPV6
 static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
-			    int *related, unsigned int hooknum,
+			    int *related, const struct nf_hook_state *state,
 			    struct ip_vs_iphdr *iph)
 {
 	struct icmp6hdr	_icmph, *ic;
@@ -2061,7 +2066,8 @@ static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
 		if (!sysctl_schedule_icmp(ipvs))
 			return NF_ACCEPT;
 
-		if (!ip_vs_try_to_schedule(ipvs, AF_INET6, skb, pd, &v, &cp, &ciph))
+		if (!ip_vs_try_to_schedule(ipvs, AF_INET6, skb, pd, &v, &cp,
+					   &ciph, state))
 			return v;
 
 		new_cp = true;
@@ -2082,7 +2088,7 @@ static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
 	/* do the statistics and put it back */
 	ip_vs_in_stats(cp, skb);
 
-	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, iph->len, hooknum, &ciph);
+	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, iph->len, state, &ciph);
 
 out:
 	if (likely(!new_cp))
@@ -2151,7 +2157,7 @@ ip_vs_in_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
 			int related;
 			int verdict = ip_vs_in_icmp_v6(ipvs, skb, &related,
-						       hooknum, &iph);
+						       state, &iph);
 
 			if (related)
 				return verdict;
@@ -2161,7 +2167,7 @@ ip_vs_in_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state
 		if (unlikely(iph.protocol == IPPROTO_ICMP)) {
 			int related;
 			int verdict = ip_vs_in_icmp(ipvs, skb, &related,
-						    hooknum, &iph);
+						    state, &iph);
 
 			if (related)
 				return verdict;
@@ -2249,7 +2255,8 @@ ip_vs_in_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state
 	if (unlikely(!cp)) {
 		int v;
 
-		if (!ip_vs_try_to_schedule(ipvs, af, skb, pd, &v, &cp, &iph))
+		if (!ip_vs_try_to_schedule(ipvs, af, skb, pd, &v, &cp, &iph,
+					   state))
 			return v;
 	}
 
@@ -2258,7 +2265,7 @@ ip_vs_in_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state
 	ip_vs_in_stats(cp, skb);
 	ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd, iph.len);
 	if (cp->packet_xmit)
-		ret = cp->packet_xmit(skb, cp, pp, &iph);
+		ret = cp->packet_xmit(skb, cp, pp, &iph, state);
 		/* do not touch skb anymore */
 	else {
 		IP_VS_DBG_RL("warning: packet_xmit is null");
@@ -2321,11 +2328,11 @@ ip_vs_forward_icmp(void *priv, struct sk_buff *skb,
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
index 83d1443ebe01..c8a5b9362a5b 100644
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
@@ -76,7 +76,8 @@ sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
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
index 2e55b62445c6..ef016938eb58 100644
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
@@ -95,7 +95,8 @@ tcp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
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
index 92c0b76c1a02..6a118783863f 100644
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
@@ -82,7 +82,8 @@ udp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
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
index f5f72a2135e1..931ecd849fe5 100644
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
@@ -720,13 +723,29 @@ static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
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
+
+
 /*
  *      Bypass transmitter
  *      Let packets bypass the destination when the destination is not
@@ -734,12 +753,14 @@ ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
  */
 int
 ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		  const struct nf_hook_state *state)
 {
 	struct iphdr  *iph = ip_hdr(skb);
 
 	if (__ip_vs_get_out_rt(cp->ipvs, cp->af, skb, NULL, iph->daddr,
-			       IP_VS_RT_MODE_NON_LOCAL, NULL, ipvsh) < 0)
+			       IP_VS_RT_MODE_NON_LOCAL, NULL, ipvsh,
+			       state) < 0)
 		goto tx_error;
 
 	ip_send_check(iph);
@@ -759,13 +780,15 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
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
@@ -787,7 +810,8 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
  */
 int
 ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-	       struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+	       struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+	       const struct nf_hook_state *state)
 {
 	struct rtable *rt;		/* Route to the other host */
 	int local, rc, was_input;
@@ -807,7 +831,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	local = __ip_vs_get_out_rt(cp->ipvs, cp->af, skb, cp->dest, cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
-				   IP_VS_RT_MODE_RDR, NULL, ipvsh);
+				   IP_VS_RT_MODE_RDR, NULL, ipvsh, state);
 	if (local < 0)
 		goto tx_error;
 	rt = skb_rtable(skb);
@@ -871,7 +895,8 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		  const struct nf_hook_state *state)
 {
 	struct rt6_info *rt;		/* Route to the other host */
 	int local, rc;
@@ -891,7 +916,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 				      NULL, ipvsh, 0,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL |
-				      IP_VS_RT_MODE_RDR);
+				      IP_VS_RT_MODE_RDR, state);
 	if (local < 0)
 		goto tx_error;
 	rt = dst_rt6_info(skb_dst(skb));
@@ -1147,7 +1172,8 @@ ipvs_gre_encap(struct net *net, struct sk_buff *skb,
  */
 int
 ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		  const struct nf_hook_state *state)
 {
 	struct netns_ipvs *ipvs = cp->ipvs;
 	struct net *net = ipvs->net;
@@ -1169,7 +1195,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
 				   IP_VS_RT_MODE_CONNECT |
-				   IP_VS_RT_MODE_TUNNEL, &saddr, ipvsh);
+				   IP_VS_RT_MODE_TUNNEL, &saddr, ipvsh, state);
 	if (local < 0)
 		goto tx_error;
 	if (local)
@@ -1278,7 +1304,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	ret = ip_vs_tunnel_xmit_prepare(skb, cp);
 	if (ret == NF_ACCEPT)
-		ip_local_out(net, skb->sk, skb);
+		ip_local_out(net, NULL, skb);
 	else if (ret == NF_DROP)
 		kfree_skb(skb);
 
@@ -1292,7 +1318,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		     const struct nf_hook_state *state)
 {
 	struct netns_ipvs *ipvs = cp->ipvs;
 	struct net *net = ipvs->net;
@@ -1314,7 +1341,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 				      &saddr, ipvsh, 1,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL |
-				      IP_VS_RT_MODE_TUNNEL);
+				      IP_VS_RT_MODE_TUNNEL, state);
 	if (local < 0)
 		goto tx_error;
 	if (local)
@@ -1420,7 +1447,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	ret = ip_vs_tunnel_xmit_prepare(skb, cp);
 	if (ret == NF_ACCEPT)
-		ip6_local_out(net, skb->sk, skb);
+		ip6_local_out(net, NULL, skb);
 	else if (ret == NF_DROP)
 		kfree_skb(skb);
 
@@ -1439,14 +1466,15 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
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
@@ -1469,7 +1497,8 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		 struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		 struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		 const struct nf_hook_state *state)
 {
 	int local;
 
@@ -1478,7 +1507,7 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 				      NULL, ipvsh, 0,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL |
-				      IP_VS_RT_MODE_KNOWN_NH);
+				      IP_VS_RT_MODE_KNOWN_NH, state);
 	if (local < 0)
 		goto tx_error;
 	if (local)
@@ -1505,7 +1534,7 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 int
 ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		struct ip_vs_protocol *pp, unsigned int toff,
-		unsigned int hooknum, struct ip_vs_iphdr *ciph)
+		const struct nf_hook_state *state, struct ip_vs_iphdr *ciph)
 {
 	struct rtable	*rt;	/* Route to the other host */
 	int rc;
@@ -1519,7 +1548,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	   translate address/port back */
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
 		if (cp->packet_xmit)
-			rc = cp->packet_xmit(skb, cp, pp, ciph);
+			rc = cp->packet_xmit(skb, cp, pp, ciph, state);
 		else
 			rc = NF_ACCEPT;
 		/* do not touch skb anymore */
@@ -1533,11 +1562,11 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
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
@@ -1599,8 +1628,8 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
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
@@ -1614,7 +1643,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	   translate address/port back */
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
 		if (cp->packet_xmit)
-			rc = cp->packet_xmit(skb, cp, pp, ciph);
+			rc = cp->packet_xmit(skb, cp, pp, ciph, state);
 		else
 			rc = NF_ACCEPT;
 		/* do not touch skb anymore */
@@ -1627,11 +1656,12 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
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


