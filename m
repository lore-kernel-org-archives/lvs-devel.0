Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795104437;
	b=dfS4BKHo/q/nCIotcc1o5ZxtGWW26gzSgbBDfmg0MYTcw3hsiZsRBW7AjSw6CUzdiBrp
	 O6vCs1NHnFkG51/7RC32gMv3fjeX7m7JBI5Dpgb4mG0KimF3yuOggy7616j0nGkHXe0G+
	 cRJC4UW7fP7ans1yQ1Dr470stuP7urLXd1x355PRPqyD72H1OzENTMXWoQISPH7ZWwgSF
	 Tg5N7u1Su0PvjCtHvtEg/8okFniiRqOvENYCCY/jKByZV2h04XOu+KOohjadgs7YmJgcb
	 PEhrN/pCP6L4EwX/f8wQRqodG7+JH38Jw5y80vpWKo24+EQkxM54+qosocJ14hh2kjQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795104437;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=oZgXZnywRGOQioS9bDN7vxQJ+5fTybP6gCNIxuc4Wr4=;
	b=o8hAIZ/vd7ZlMM9GoskG1chi/vdt/QNvOVkFIanyBr6MNdSpjUPyjKID53GVpNmO2+n3
	 mxGIYL/lqYebYYHaS1Vv1u4V7Zr1kATkLSP9EexaP9gDN4w15rjb3FMQRixoa/XT/zUn6
	 TPEse5qED027FbUBpcKlLw9OuQp4imgtefaYYKTjNIY2jSVKPCKZsAUrbAQzYe6hlyMXa
	 oUI1Lb16IQKW4zNUt1m7Ynwonrgk5Al58OdpCgGV/+qOp1ToXjx/i9PTR0y4KksBicPFV
	 HWI7d13z6dyUgyjFr0DvHMBhkv7JA9IanJTLBF5142e71vBtfULcOa/GexCfFCaZN/A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=67uXkCpz;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 754FF606A32C;
	Thu, 19 Nov 2026 16:07:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 754FF606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=67uXkCpz
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id BBDF621FD8;
	Thu, 19 Nov 2026 18:07:06 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=oZgXZnyw
	RGOQioS9bDN7vxQJ+5fTybP6gCNIxuc4Wr4=; b=67uXkCpz+FPVx/3YiL3OWb36
	IPCcu0QYQiyHX1VY0lvrRHG15GGnyBdrOZX5AuFB8IUaEd2r8ymepqb184zHrNjU
	rfGhppar/AfG1f579Weep/uxuJFyvK9qRuo2JmYBNgm+gO7d+pPBU3kKJ14kReBF
	NAvwmCu1vK/XIUeR/mxgpw4WUnoysA6l+qHVvKXGEBTD643B21YjqDHfUb9cqsL5
	ohm2ELFUQIxUgQ/MiVA94Cy5yeDmP8t8Oc8DcUZRdjvwKvaWvQ6PQMkb6hhwid5L
	Waj3BZYPoDWC+TPdP5Q0umfebyoJAzZ0/qA2xglylAi7zZ+A/NeRp+Ofv4B02SSl
	en7YYpAEyk27LluFqugjJsGa4NnsEmDtSK06O3rRAhwVgepDeI4z2U9/mL1lUbUC
	596YzOttJAImcFxnY9t6rnL5ZXJw4zq46Za/YWxX3RC2/6alj77tNOtz0th+Bd4n
	VBhCsApR7ktFhXZ2NzIDKfzeYOq6Bof3/wkSXrR5lwQtE7saasznpUE3MI0WAbdX
	CTNnjMXR6250RcjryTkmu/w31lZHJnVF2/ZAZ+Fn5aQm4UZXJhxvZCNXYhhQBXWd
	l2gfLW35NseyYuqgLjAyjRmz1FlFxV5mFWvyBOkEyVKFJXGJ2JwzVidI2mBjyVqu
	/cHv4WqKjLWMMcyCQ3o=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 19 Nov 2026 18:07:06 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 3FCFC60AD9;
	Thu, 19 Nov 2026 18:07:06 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6AJG6xiN133079;
	Thu, 19 Nov 2026 18:06:59 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 6AJG6uia133076;
	Thu, 19 Nov 2026 18:06:56 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf v5] ipvs: pass correct sk to update_pmtu and on tunneling
Date: Thu, 19 Nov 2026 18:06:50 +0200
Message-ID: <20261119160650.133060-1-ja@ssi.bg>
X-Mailer: git-send-email 2.56.1
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
can be the case for tunnels where different sk is provided to
ip_local_out. If such packet is then forwarded via IPVS tunnel
we may need to provide state->sk to the update_pmtu handler,
not skb->sk.

Fix that by passing the netfilter's hook state via the
packet_xmit and conn_schedule handlers to call the update_pmtu
handler with state->sk.

While here, change maybe_update_pmtu() to be family independent
by using dst and do not request neigh confirm via the last
update_pmtu arg because we do not generate the event based on
remote signal.

Sashiko has some warnings for the update_pmtu handlers because
we provide only sk, not skb:

- we do not provide skb because the handlers assume they are
called from tunnel transmitters where skb->dev is present
but for IPVS skb->dev is not set yet

- without skb, the zero destination address for unconnected
sockets can be blindly used for FIB nexthop or route exceptions.
So, we now restrict the sk to be for TCP_ESTABLISHED state
where the sk is connected to destination address. All other
sockets can receive the PMTU update via the ICMP replies.

- as we provide the original sk (from state->sk) for the original
IP header, make sure we do not provide sk from one family to
the update_pmtu handler for different family. Still, allow
IPv4 packets to update PMTU for IPv6 dual sockets.

The second problem is that on tunnel forwarding we call
ip_local_out() with skb->sk. As we push our own outer IP header
in ip_vs_tunnel_xmit*(), the right thing is to provide NULL
instead, as done by other tunnels (IPIP/SIT/GRE).

For consistency, even if we do not walk the netfilter hooks and
just pass the packet with NF_ACCEPT, provide ip_vs_null_xmit_v6
handler to properly indicate that we are sending IPv6 packet.
Before now we used ip_vs_null_xmit for both families.

Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20261113011447.2357709-1-pablo%40netfilter.org
Link: https://sashiko.dev/#/patchset/20261113121303.42549-1-ja%40ssi.bg
Link: https://sashiko.dev/#/patchset/20261103152550.60449-1-ja%40ssi.bg
Fixes: 79b16aadea32 ("udp_tunnel: Pass UDP socket down through udp_tunnel{, 6}_xmit_skb().")
Fixes: 7026b1ddb6b8 ("netfilter: Pass socket pointer down through okfn().")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 Changes in v5:
 * Match the packet's daddr with the socket's connected address
 * IPv6 dual sockets connected to IPv4 mapped address can be updated too

 Link to v4:
 https://lore.kernel.org/all/20261113121303.42549-1-ja@ssi.bg/

 include/net/ip_vs.h                     |  45 +++++---
 net/netfilter/ipvs/ip_vs_conn.c         |  16 +--
 net/netfilter/ipvs/ip_vs_core.c         |  41 ++++---
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |   2 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |   5 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |   5 +-
 net/netfilter/ipvs/ip_vs_proto_udp.c    |   5 +-
 net/netfilter/ipvs/ip_vs_xmit.c         | 135 +++++++++++++++++-------
 8 files changed, 169 insertions(+), 85 deletions(-)

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
index 94f25fb7d87e..dde65923b45d 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1040,13 +1040,13 @@ static inline void ip_vs_bind_xmit(struct ip_vs_conn *cp)
 		cp->packet_xmit = ip_vs_dr_xmit;
 		break;
 
-	case IP_VS_CONN_F_LOCALNODE:
-		cp->packet_xmit = ip_vs_null_xmit;
-		break;
-
 	case IP_VS_CONN_F_BYPASS:
 		cp->packet_xmit = ip_vs_bypass_xmit;
 		break;
+
+	case IP_VS_CONN_F_LOCALNODE:
+		cp->packet_xmit = ip_vs_null_xmit;
+		break;
 	}
 }
 
@@ -1069,13 +1069,13 @@ static inline void ip_vs_bind_xmit_v6(struct ip_vs_conn *cp)
 		cp->packet_xmit = ip_vs_dr_xmit_v6;
 		break;
 
-	case IP_VS_CONN_F_LOCALNODE:
-		cp->packet_xmit = ip_vs_null_xmit;
-		break;
-
 	case IP_VS_CONN_F_BYPASS:
 		cp->packet_xmit = ip_vs_bypass_xmit_v6;
 		break;
+
+	case IP_VS_CONN_F_LOCALNODE:
+		cp->packet_xmit = ip_vs_null_xmit_v6;
+		break;
 	}
 }
 #endif
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
index ebc6b697ae51..08b3bc011141 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -205,13 +205,45 @@ static inline bool crosses_local_route_boundary(int skb_af, struct sk_buff *skb,
 	return false;
 }
 
-static inline void maybe_update_pmtu(int skb_af, struct sk_buff *skb, int mtu)
+static inline void maybe_update_pmtu(int skb_af, struct sk_buff *skb, int mtu,
+				     const struct nf_hook_state *state)
 {
-	struct sock *sk = skb->sk;
-	struct rtable *ort = skb_rtable(skb);
-
-	if (!skb->dev && sk && sk_fullsock(sk))
-		ort->dst.ops->update_pmtu(&ort->dst, sk, NULL, mtu, true);
+	struct dst_entry *dst = skb_dst(skb);
+	struct sock *sk = state->sk;
+
+	/* The update_pmtu handlers are missing some checks for:
+	 * - skb->dev: present for tunnels, not for IPVS, so we do not
+	 * provide skb, only sk
+	 * - present daddr: so, we require TCP_ESTABLISHED (connected socket)
+	 *
+	 * In some states the senders ignore the PMTU events:
+	 * - sk_fullsock(): so use the TCP_ESTABLISHED check
+	 */
+	if (sk && sk->sk_state == TCP_ESTABLISHED &&
+	    state->hook == NF_INET_LOCAL_OUT) {
+		switch (sk->sk_family) {
+#ifdef CONFIG_IP_VS_IPV6
+		case AF_INET6:
+			if (skb_af == AF_INET6) {
+				if (ipv6_addr_cmp(&ipv6_hdr(skb)->daddr,
+						  &sk->sk_v6_daddr))
+					return;
+				break;
+			}
+			if (ipv6_only_sock(sk))
+				return;
+			fallthrough;
+			/* Dual sockets can be connected to IPv4 address */
+#endif
+		case AF_INET:
+			if (ip_hdr(skb)->daddr != sk->sk_daddr)
+				return;
+			break;
+		default:
+			return;
+		}
+		dst->ops->update_pmtu(dst, sk, NULL, mtu, false);
+	}
 }
 
 static inline bool ensure_mtu_is_adequate(struct netns_ipvs *ipvs, int skb_af,
@@ -316,7 +348,7 @@ static int
 __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 		   struct ip_vs_dest *dest,
 		   __be32 daddr, int rt_mode, __be32 *ret_saddr,
-		   struct ip_vs_iphdr *ipvsh)
+		   struct ip_vs_iphdr *ipvsh, const struct nf_hook_state *state)
 {
 	struct net *net = ipvs->net;
 	struct ip_vs_dest_dst *dest_dst;
@@ -417,7 +449,7 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 			IP_VS_DBG_RL("%s(): mtu less than 68\n", __func__);
 			goto err_put;
 		}
-		maybe_update_pmtu(skb_af, skb, mtu);
+		maybe_update_pmtu(skb_af, skb, mtu, state);
 	}
 
 	if (!ensure_mtu_is_adequate(ipvs, skb_af, rt_mode, ipvsh, skb, mtu))
@@ -489,7 +521,8 @@ static int
 __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 		      struct ip_vs_dest *dest,
 		      struct in6_addr *daddr, struct in6_addr *ret_saddr,
-		      struct ip_vs_iphdr *ipvsh, int do_xfrm, int rt_mode)
+		      struct ip_vs_iphdr *ipvsh, int do_xfrm, int rt_mode,
+		      const struct nf_hook_state *state)
 {
 	struct net *net = ipvs->net;
 	struct ip_vs_dest_dst *dest_dst;
@@ -596,7 +629,7 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 				     IPV6_MIN_MTU);
 			goto err_put;
 		}
-		maybe_update_pmtu(skb_af, skb, mtu);
+		maybe_update_pmtu(skb_af, skb, mtu, state);
 	}
 
 	if (!ensure_mtu_is_adequate(ipvs, skb_af, rt_mode, ipvsh, skb, mtu))
@@ -720,12 +753,26 @@ static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
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
@@ -734,10 +781,11 @@ ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
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
@@ -757,13 +805,15 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
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
@@ -785,7 +835,8 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
  */
 int
 ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-	       struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+	       struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+	       const struct nf_hook_state *state)
 {
 	struct rtable *rt;		/* Route to the other host */
 	int local, rc, was_input;
@@ -805,7 +856,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	local = __ip_vs_get_out_rt(cp->ipvs, cp->af, skb, cp->dest, cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
-				   IP_VS_RT_MODE_RDR, NULL, ipvsh);
+				   IP_VS_RT_MODE_RDR, NULL, ipvsh, state);
 	if (local < 0)
 		goto tx_error;
 	rt = skb_rtable(skb);
@@ -869,7 +920,8 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		  const struct nf_hook_state *state)
 {
 	struct rt6_info *rt;		/* Route to the other host */
 	int local, rc;
@@ -889,7 +941,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 				      NULL, ipvsh, 0,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL |
-				      IP_VS_RT_MODE_RDR);
+				      IP_VS_RT_MODE_RDR, state);
 	if (local < 0)
 		goto tx_error;
 	rt = dst_rt6_info(skb_dst(skb));
@@ -1145,7 +1197,8 @@ ipvs_gre_encap(struct net *net, struct sk_buff *skb,
  */
 int
 ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		  const struct nf_hook_state *state)
 {
 	struct netns_ipvs *ipvs = cp->ipvs;
 	struct net *net = ipvs->net;
@@ -1167,7 +1220,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
 				   IP_VS_RT_MODE_CONNECT |
-				   IP_VS_RT_MODE_TUNNEL, &saddr, ipvsh);
+				   IP_VS_RT_MODE_TUNNEL, &saddr, ipvsh, state);
 	if (local < 0)
 		goto tx_error;
 	if (local)
@@ -1276,7 +1329,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	ret = ip_vs_tunnel_xmit_prepare(skb, cp);
 	if (ret == NF_ACCEPT)
-		ip_local_out(net, skb->sk, skb);
+		ip_local_out(net, NULL, skb);
 	else if (ret == NF_DROP)
 		kfree_skb(skb);
 
@@ -1290,7 +1343,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		     const struct nf_hook_state *state)
 {
 	struct netns_ipvs *ipvs = cp->ipvs;
 	struct net *net = ipvs->net;
@@ -1312,7 +1366,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 				      &saddr, ipvsh, 1,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL |
-				      IP_VS_RT_MODE_TUNNEL);
+				      IP_VS_RT_MODE_TUNNEL, state);
 	if (local < 0)
 		goto tx_error;
 	if (local)
@@ -1418,7 +1472,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	ret = ip_vs_tunnel_xmit_prepare(skb, cp);
 	if (ret == NF_ACCEPT)
-		ip6_local_out(net, skb->sk, skb);
+		ip6_local_out(net, NULL, skb);
 	else if (ret == NF_DROP)
 		kfree_skb(skb);
 
@@ -1437,14 +1491,15 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
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
@@ -1467,7 +1522,8 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		 struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
+		 struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
+		 const struct nf_hook_state *state)
 {
 	int local;
 
@@ -1476,7 +1532,7 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 				      NULL, ipvsh, 0,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL |
-				      IP_VS_RT_MODE_KNOWN_NH);
+				      IP_VS_RT_MODE_KNOWN_NH, state);
 	if (local < 0)
 		goto tx_error;
 	if (local)
@@ -1503,7 +1559,7 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 int
 ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		struct ip_vs_protocol *pp, unsigned int toff,
-		unsigned int hooknum, struct ip_vs_iphdr *ciph)
+		const struct nf_hook_state *state, struct ip_vs_iphdr *ciph)
 {
 	struct rtable	*rt;	/* Route to the other host */
 	int rc;
@@ -1517,7 +1573,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	   translate address/port back */
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
 		if (cp->packet_xmit)
-			rc = cp->packet_xmit(skb, cp, pp, ciph);
+			rc = cp->packet_xmit(skb, cp, pp, ciph, state);
 		else
 			rc = NF_ACCEPT;
 		/* do not touch skb anymore */
@@ -1531,11 +1587,11 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
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
@@ -1597,8 +1653,8 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
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
@@ -1612,7 +1668,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	   translate address/port back */
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
 		if (cp->packet_xmit)
-			rc = cp->packet_xmit(skb, cp, pp, ciph);
+			rc = cp->packet_xmit(skb, cp, pp, ciph, state);
 		else
 			rc = NF_ACCEPT;
 		/* do not touch skb anymore */
@@ -1625,11 +1681,12 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
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
2.56.1


