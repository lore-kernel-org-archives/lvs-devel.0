Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9AB0F3B9950;
	Mon, 20 Jul 2026 20:15:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784578544; cv=none; b=uMPjSkBTOb2r8iId+86Xu8WDVRJDAK3YuB1nT6skU7TaTzPfGRncWW5+CXlVbhnwh9THtpjasIpOdPcwxJnQsuhRjDSORSZZ7qB/mi3WRCR7YusIxT5Qno3eZvR9rMWKnNB924NEesgxwO45ZQOfIYICKm/xdgg0pWli6rBuwRU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784578544; c=relaxed/simple;
	bh=VeFWq9Sv1Ijs0e5McFxn7U1S+jhAWQL3AeOWranh9Qo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MAtF3/SnbfLSMTGTZsX/SoHBdJ8u9X8exHzhpfEO2FBbQzDN6Kzeu5b3ihgf85edeT1JlKZBc/j5pc7fmSOIDnk8HUUuMRY2x0QsyW26jAgnbkEINLeeUyaXqwqw1hM09oPSpxVdwlQAZBnN8xgbMSWNstDO8oDZVkz3T1gAWXM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=g+Mm80Ul; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="g+Mm80Ul"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 1CF0522AFA;
	Mon, 20 Jul 2026 23:15:00 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=RizEZrVSdfqfprqYmiqAUvEzPwyeQgDvMTvc2q6vLAs=; b=g+Mm80UlAHkL
	bRsV1LRisUCEWW9XxaXS0n2SUqx25mTN2rOllFHMQ9ryRENo4AZVgSx+mnW/+p0N
	8LBSoe/JL2SNHcLZEIQjefE46FcNOhbm2zFoKF8XFjLsEnFSe1G6RxDOTaIA7YFK
	41RfzAZ1Y/UPQKP91ffB2+MzyZWf3+JisXPpLHTHdyNWd7fXPatfRpJI8tK6VCp3
	5OXf1cXVvybkU6mdyuHyOhgmlzVyBNhVxTk78xhabps9/Uvg5NPlvlz8RJUye373
	si5+Z9yOEIsWSPMErFJOJMcKNuEBek6vhmgekqMVYM/GEXinwmnGXLliPz2If1+u
	6dNpHTKK3219fWM0K1dQ/06SCiZUPzA5UnLusNefX0fFDpxZQGzCGBdZaM83T6n6
	FsimXbBRcqYOme6rmO188L4bWqBBe64QupLrjtBhmvsFT/A/JzmpsyLfpUzA3fLQ
	/gcD7heuZNY8ZDzd1VHbGYrFizX55Po/zdoegUQf1USbCpgdy1Nqc72Ug1grVNkl
	USlpyQYQ1PgBUIQ+MZi6rjZV4M5E+elfQdJ0ywnchmOVB8ltMkTkFAOj7x68naIm
	lcqL15BEvXULr3Hn6OBvLxqPTgzB0tAR78L62l+jiiUspHAkm8amzfF2REE0+9ul
	npDCGb1ZyOO/Kcszi7Exp9oqn6q1rq0=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 20 Jul 2026 23:14:59 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 72F1561E8B;
	Mon, 20 Jul 2026 23:15:01 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66KKBkGk079911;
	Mon, 20 Jul 2026 23:11:46 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 66KKBkMj079910;
	Mon, 20 Jul 2026 23:11:46 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf v2 2/2] ipvs: fix places with wrong packet offsets
Date: Mon, 20 Jul 2026 23:11:22 +0300
Message-ID: <20260720201122.79882-3-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260720201122.79882-1-ja@ssi.bg>
References: <20260720201122.79882-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The offsets we use to packet headers and payloads should be
based on skb->data. We even already respect non-zero
network offset in ip_vs_fill_iph_skb() but some places
do it wrongly and support only zero offset which is expected
for the IP layer where IPVS has hooks.

Change all places that instead of skb->data use offsets based
on the network header (skb_network_header, ip_hdr, etc) because
this doubles the network offset as noted by Sashiko.

For ip_vs_nat_icmp_v6() we can even rely on the IPv6 header
parsing done by the caller.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Link: https://sashiko.dev/#/patchset/20260710143733.29741-2-fw%40strlen.de
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h                   |  15 +--
 net/netfilter/ipvs/ip_vs_app.c        |   4 +-
 net/netfilter/ipvs/ip_vs_core.c       | 131 +++++++++++++-------------
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   4 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |   4 +-
 net/netfilter/ipvs/ip_vs_proto_udp.c  |   4 +-
 net/netfilter/ipvs/ip_vs_xmit.c       |  26 ++---
 7 files changed, 96 insertions(+), 92 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index bf85ad6b1b42..a9a5589b8069 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1976,8 +1976,9 @@ int ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 int ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
 int ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		    struct ip_vs_protocol *pp, int offset,
-		    unsigned int hooknum, struct ip_vs_iphdr *iph);
+		    struct ip_vs_protocol *pp, unsigned int toff,
+		    unsigned int wlen, unsigned int hooknum,
+		    struct ip_vs_iphdr *ciph);
 void ip_vs_dest_dst_rcu_free(struct rcu_head *head);
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1990,8 +1991,9 @@ int ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 int ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
 int ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		       struct ip_vs_protocol *pp, int offset,
-		       unsigned int hooknum, struct ip_vs_iphdr *iph);
+		       struct ip_vs_protocol *pp, unsigned int toff,
+		       unsigned int wlen, unsigned int hooknum,
+		       struct ip_vs_iphdr *ciph);
 #endif
 
 #ifdef CONFIG_SYSCTL
@@ -2063,11 +2065,12 @@ static inline bool ip_vs_conn_use_hash2(struct ip_vs_conn *cp)
 }
 
 void ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
-		    struct ip_vs_conn *cp, int dir);
+		    struct ip_vs_conn *cp, int dir, unsigned int toff);
 
 #ifdef CONFIG_IP_VS_IPV6
 void ip_vs_nat_icmp_v6(struct sk_buff *skb, struct ip_vs_protocol *pp,
-		       struct ip_vs_conn *cp, int dir);
+		       struct ip_vs_conn *cp, int dir, unsigned int toff,
+		       struct ip_vs_iphdr *ciph);
 #endif
 
 static inline __wsum ip_vs_check_diff4(__be32 old, __be32 new, __wsum oldsum)
diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index b0e00be85cb1..11cbdbaf561d 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -367,7 +367,7 @@ static inline int app_tcp_pkt_out(struct ip_vs_conn *cp, struct sk_buff *skb,
 	if (skb_ensure_writable(skb, ipvsh->len + sizeof(*th)))
 		return 0;
 
-	th = (struct tcphdr *)(skb_network_header(skb) + ipvsh->len);
+	th = (struct tcphdr *)(skb->data + ipvsh->len);
 
 	/*
 	 *	Remember seq number in case this pkt gets resized
@@ -443,7 +443,7 @@ static inline int app_tcp_pkt_in(struct ip_vs_conn *cp, struct sk_buff *skb,
 	if (skb_ensure_writable(skb, ipvsh->len + sizeof(*th)))
 		return 0;
 
-	th = (struct tcphdr *)(skb_network_header(skb) + ipvsh->len);
+	th = (struct tcphdr *)(skb->data + ipvsh->len);
 
 	/*
 	 *	Remember seq number in case this pkt gets resized
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index c8b512725e6e..21db6af220eb 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -924,13 +924,12 @@ static int ip_vs_route_me_harder(struct netns_ipvs *ipvs, int af,
  * - inout: 1=in->out, 0=out->in
  */
 void ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
-		    struct ip_vs_conn *cp, int inout)
+		    struct ip_vs_conn *cp, int inout, unsigned int toff)
 {
 	struct iphdr *iph	 = ip_hdr(skb);
-	unsigned int icmp_offset = iph->ihl*4;
-	struct icmphdr *icmph	 = (struct icmphdr *)(skb_network_header(skb) +
-						      icmp_offset);
+	struct icmphdr *icmph	 = (struct icmphdr *)(skb->data + toff);
 	struct iphdr *ciph	 = (struct iphdr *)(icmph + 1);
+	unsigned int coff = toff + sizeof(struct icmphdr);
 
 	if (inout) {
 		iph->saddr = cp->vaddr.ip;
@@ -957,48 +956,45 @@ void ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 	/* And finally the ICMP checksum */
 	icmph->checksum = 0;
-	icmph->checksum = ip_vs_checksum_complete(skb, icmp_offset);
+	icmph->checksum = ip_vs_checksum_complete(skb, toff);
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 	if (inout)
-		IP_VS_DBG_PKT(11, AF_INET, pp, skb, (void *)ciph - (void *)iph,
-			"Forwarding altered outgoing ICMP");
+		IP_VS_DBG_PKT(11, AF_INET, pp, skb, coff,
+			      "Forwarding altered outgoing ICMP");
 	else
-		IP_VS_DBG_PKT(11, AF_INET, pp, skb, (void *)ciph - (void *)iph,
-			"Forwarding altered incoming ICMP");
+		IP_VS_DBG_PKT(11, AF_INET, pp, skb, coff,
+			      "Forwarding altered incoming ICMP");
 }
 
 #ifdef CONFIG_IP_VS_IPV6
 void ip_vs_nat_icmp_v6(struct sk_buff *skb, struct ip_vs_protocol *pp,
-		    struct ip_vs_conn *cp, int inout)
+		       struct ip_vs_conn *cp, int inout, unsigned int toff,
+		       struct ip_vs_iphdr *ciph)
 {
 	struct ipv6hdr *iph	 = ipv6_hdr(skb);
-	unsigned int icmp_offset = 0;
-	unsigned int offs	 = 0; /* header offset*/
 	int protocol;
 	struct icmp6hdr *icmph;
-	struct ipv6hdr *ciph;
-	unsigned short fragoffs;
+	struct ipv6hdr *cih;
 
-	ipv6_find_hdr(skb, &icmp_offset, IPPROTO_ICMPV6, &fragoffs, NULL);
-	icmph = (struct icmp6hdr *)(skb_network_header(skb) + icmp_offset);
-	offs = icmp_offset + sizeof(struct icmp6hdr);
-	ciph = (struct ipv6hdr *)(skb_network_header(skb) + offs);
+	icmph = (struct icmp6hdr *)(skb->data + toff);
+	cih = (struct ipv6hdr *)(skb->data + ciph->off);
 
-	protocol = ipv6_find_hdr(skb, &offs, -1, &fragoffs, NULL);
+	protocol = ciph->protocol;
 
 	if (inout) {
 		iph->saddr = cp->vaddr.in6;
-		ciph->daddr = cp->vaddr.in6;
+		cih->daddr = cp->vaddr.in6;
 	} else {
 		iph->daddr = cp->daddr.in6;
-		ciph->saddr = cp->daddr.in6;
+		cih->saddr = cp->daddr.in6;
 	}
 
 	/* the TCP/UDP/SCTP port */
-	if (!fragoffs && (IPPROTO_TCP == protocol || IPPROTO_UDP == protocol ||
-			  IPPROTO_SCTP == protocol)) {
-		__be16 *ports = (void *)(skb_network_header(skb) + offs);
+	if (!ciph->fragoffs &&
+	    (protocol == IPPROTO_TCP  || protocol == IPPROTO_UDP ||
+	     protocol == IPPROTO_SCTP)) {
+		__be16 *ports = (void *)(skb->data + ciph->len);
 
 		IP_VS_DBG(11, "%s() changed port %d to %d\n", __func__,
 			      ntohs(inout ? ports[1] : ports[0]),
@@ -1011,19 +1007,17 @@ void ip_vs_nat_icmp_v6(struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 	/* And finally the ICMP checksum */
 	icmph->icmp6_cksum = ~csum_ipv6_magic(&iph->saddr, &iph->daddr,
-					      skb->len - icmp_offset,
+					      skb->len - toff,
 					      IPPROTO_ICMPV6, 0);
-	skb->csum_start = skb_network_header(skb) - skb->head + icmp_offset;
+	skb->csum_start = skb_headroom(skb) + toff;
 	skb->csum_offset = offsetof(struct icmp6hdr, icmp6_cksum);
 	skb->ip_summed = CHECKSUM_PARTIAL;
 
 	if (inout)
-		IP_VS_DBG_PKT(11, AF_INET6, pp, skb,
-			      (void *)ciph - (void *)iph,
+		IP_VS_DBG_PKT(11, AF_INET6, pp, skb, ciph->off,
 			      "Forwarding altered outgoing ICMPv6");
 	else
-		IP_VS_DBG_PKT(11, AF_INET6, pp, skb,
-			      (void *)ciph - (void *)iph,
+		IP_VS_DBG_PKT(11, AF_INET6, pp, skb, ciph->off,
 			      "Forwarding altered incoming ICMPv6");
 }
 #endif
@@ -1033,37 +1027,38 @@ void ip_vs_nat_icmp_v6(struct sk_buff *skb, struct ip_vs_protocol *pp,
  */
 static int handle_response_icmp(int af, struct sk_buff *skb,
 				union nf_inet_addr *snet,
-				__u8 protocol, struct ip_vs_conn *cp,
+				struct ip_vs_conn *cp,
 				struct ip_vs_protocol *pp,
-				unsigned int offset, unsigned int ihl,
-				unsigned int hooknum)
+				struct ip_vs_iphdr *ciph,
+				unsigned int toff, unsigned int hooknum)
 {
 	int iproto = af == AF_INET6 ? IPPROTO_ICMPV6 : IPPROTO_ICMP;
 	unsigned int verdict = NF_DROP;
+	unsigned int ctoff = ciph->len;
 
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
 		goto after_nat;
 
 	/* Ensure the checksum is correct */
-	if (!ip_vs_checksum_common_check(skb, ihl, iproto, af)) {
+	if (!ip_vs_checksum_common_check(skb, toff, iproto, af)) {
 		/* Failed checksum! */
 		IP_VS_DBG_BUF(1, "Forward ICMP: failed checksum from %s!\n",
 			      IP_VS_DBG_ADDR(af, snet));
 		goto out;
 	}
 
-	if (IPPROTO_TCP == protocol || IPPROTO_UDP == protocol ||
-	    IPPROTO_SCTP == protocol)
-		offset += 2 * sizeof(__u16);
-	if (skb_ensure_writable(skb, offset))
+	if (ciph->protocol == IPPROTO_TCP || ciph->protocol == IPPROTO_UDP ||
+	    ciph->protocol == IPPROTO_SCTP)
+		ctoff += 2 * sizeof(__u16);
+	if (skb_ensure_writable(skb, ctoff))
 		goto out;
 
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6)
-		ip_vs_nat_icmp_v6(skb, pp, cp, 1);
+		ip_vs_nat_icmp_v6(skb, pp, cp, 1, toff, ciph);
 	else
 #endif
-		ip_vs_nat_icmp(skb, pp, cp, 1);
+		ip_vs_nat_icmp(skb, pp, cp, 1, toff);
 
 	if (ip_vs_route_me_harder(cp->ipvs, af, skb, hooknum))
 		goto out;
@@ -1091,9 +1086,9 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
  *	Currently handles error types - unreachable, quench, ttl exceeded.
  */
 static int ip_vs_out_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb,
-			  int *related, unsigned int hooknum)
+			  int *related, unsigned int hooknum,
+			  struct ip_vs_iphdr *ipvsh)
 {
-	struct iphdr *iph;
 	struct icmphdr	_icmph, *ic;
 	struct iphdr	_ciph, *cih;	/* The ip header contained within the ICMP */
 	struct ip_vs_iphdr ciph;
@@ -1108,17 +1103,19 @@ static int ip_vs_out_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb,
 	if (ip_is_fragment(ip_hdr(skb))) {
 		if (ip_vs_gather_frags(ipvs, skb, ip_vs_defrag_user(hooknum)))
 			return NF_STOLEN;
+		if (!ip_vs_fill_iph_skb(AF_INET, skb, false, ipvsh))
+			return NF_ACCEPT;
 	}
 
-	iph = ip_hdr(skb);
-	offset = ihl = iph->ihl * 4;
+	ihl = ipvsh->len;
+	offset = ipvsh->len;
 	ic = skb_header_pointer(skb, offset, sizeof(_icmph), &_icmph);
 	if (ic == NULL)
 		return NF_DROP;
 
 	IP_VS_DBG(12, "Outgoing ICMP (%d,%d) %pI4->%pI4\n",
 		  ic->type, ntohs(icmp_id(ic)),
-		  &iph->saddr, &iph->daddr);
+		  &ipvsh->saddr.ip, &ipvsh->daddr.ip);
 
 	/*
 	 * Work through seeing if this is for us.
@@ -1137,7 +1134,7 @@ static int ip_vs_out_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb,
 	/* Now find the contained IP header */
 	offset += sizeof(_icmph);
 	cih = skb_header_pointer(skb, offset, sizeof(_ciph), &_ciph);
-	if (cih == NULL)
+	if (!(cih && cih->version == 4 && cih->ihl >= 5))
 		return NF_ACCEPT; /* The packet looks wrong, ignore */
 
 	pp = ip_vs_proto_get(cih->protocol);
@@ -1160,9 +1157,9 @@ static int ip_vs_out_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb,
 	if (!cp)
 		return NF_ACCEPT;
 
-	snet.ip = iph->saddr;
-	return handle_response_icmp(AF_INET, skb, &snet, cih->protocol, cp,
-				    pp, ciph.len, ihl, hooknum);
+	snet.ip = ipvsh->saddr.ip;
+	return handle_response_icmp(AF_INET, skb, &snet, cp, pp, &ciph, ihl,
+				    hooknum);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1175,7 +1172,6 @@ static int ip_vs_out_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
 	union nf_inet_addr snet;
-	unsigned int offset;
 
 	*related = 1;
 	ic = frag_safe_skb_hp(skb, ipvsh->len, sizeof(_icmph), &_icmph);
@@ -1218,9 +1214,8 @@ static int ip_vs_out_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
 		return NF_ACCEPT;
 
 	snet.in6 = ciph.saddr.in6;
-	offset = ciph.len;
-	return handle_response_icmp(AF_INET6, skb, &snet, ciph.protocol, cp,
-				    pp, offset, ipvsh->len, hooknum);
+	return handle_response_icmp(AF_INET6, skb, &snet, cp, pp, &ciph,
+				    ipvsh->len, hooknum);
 }
 #endif
 
@@ -1546,7 +1541,8 @@ ip_vs_out_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *stat
 #endif
 		if (unlikely(iph.protocol == IPPROTO_ICMP)) {
 			int related;
-			int verdict = ip_vs_out_icmp(ipvs, skb, &related, hooknum);
+			int verdict = ip_vs_out_icmp(ipvs, skb, &related,
+						     hooknum, &iph);
 
 			if (related)
 				return verdict;
@@ -1754,9 +1750,8 @@ static int ipvs_gre_decap(struct netns_ipvs *ipvs, struct sk_buff *skb,
  */
 static int
 ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
-	      unsigned int hooknum)
+	      unsigned int hooknum, struct ip_vs_iphdr *iph)
 {
-	struct iphdr *iph;
 	struct icmphdr	_icmph, *ic;
 	struct iphdr	_ciph, *cih;	/* The ip header contained within the ICMP */
 	struct ip_vs_iphdr ciph;
@@ -1776,17 +1771,19 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 	if (ip_is_fragment(ip_hdr(skb))) {
 		if (ip_vs_gather_frags(ipvs, skb, ip_vs_defrag_user(hooknum)))
 			return NF_STOLEN;
+		if (!ip_vs_fill_iph_skb(AF_INET, skb, false, iph))
+			return NF_ACCEPT;
 	}
 
-	iph = ip_hdr(skb);
-	offset = ihl = iph->ihl * 4;
+	ihl = iph->len;
+	offset = iph->len;
 	ic = skb_header_pointer(skb, offset, sizeof(_icmph), &_icmph);
 	if (ic == NULL)
 		return NF_DROP;
 
 	IP_VS_DBG(12, "Incoming ICMP (%d,%d) %pI4->%pI4\n",
 		  ic->type, ntohs(icmp_id(ic)),
-		  &iph->saddr, &iph->daddr);
+		  &iph->saddr.ip, &iph->daddr.ip);
 
 	/*
 	 * Work through seeing if this is for us.
@@ -1903,7 +1900,7 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 	    !ip_vs_checksum_common_check(skb, ihl, IPPROTO_ICMP, AF_INET)) {
 		/* Failed checksum! */
 		IP_VS_DBG(1, "Incoming ICMP: failed checksum from %pI4!\n",
-			  &iph->saddr);
+			  &iph->saddr.ip);
 		goto out;
 	}
 
@@ -1974,7 +1971,8 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 	if (IPPROTO_TCP == cih->protocol || IPPROTO_UDP == cih->protocol ||
 	    IPPROTO_SCTP == cih->protocol)
 		offset += 2 * sizeof(__u16);
-	verdict = ip_vs_icmp_xmit(skb, cp, pp, offset, hooknum, &ciph);
+	verdict = ip_vs_icmp_xmit(skb, cp, pp, iph->len, offset, hooknum,
+				  &ciph);
 
 out:
 	if (likely(!new_cp))
@@ -2087,7 +2085,8 @@ static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
 	    IPPROTO_SCTP == ciph.protocol)
 		offset += 2 * sizeof(__u16); /* Also mangle ports */
 
-	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, offset, hooknum, &ciph);
+	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, iph->len, offset, hooknum,
+				     &ciph);
 
 out:
 	if (likely(!new_cp))
@@ -2166,7 +2165,7 @@ ip_vs_in_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state
 		if (unlikely(iph.protocol == IPPROTO_ICMP)) {
 			int related;
 			int verdict = ip_vs_in_icmp(ipvs, skb, &related,
-						    hooknum);
+						    hooknum, &iph);
 
 			if (related)
 				return verdict;
@@ -2302,6 +2301,7 @@ ip_vs_forward_icmp(void *priv, struct sk_buff *skb,
 		   const struct nf_hook_state *state)
 {
 	struct netns_ipvs *ipvs = net_ipvs(state->net);
+	struct ip_vs_iphdr iphdr;
 	int r;
 
 	/* ipvs enabled in this netns ? */
@@ -2311,10 +2311,9 @@ ip_vs_forward_icmp(void *priv, struct sk_buff *skb,
 	if (state->pf == NFPROTO_IPV4) {
 		if (ip_hdr(skb)->protocol != IPPROTO_ICMP)
 			return NF_ACCEPT;
+		ip_vs_fill_iph_skb(AF_INET, skb, false, &iphdr);
 #ifdef CONFIG_IP_VS_IPV6
 	} else {
-		struct ip_vs_iphdr iphdr;
-
 		ip_vs_fill_iph_skb(AF_INET6, skb, false, &iphdr);
 
 		if (iphdr.protocol != IPPROTO_ICMPV6)
@@ -2324,7 +2323,7 @@ ip_vs_forward_icmp(void *priv, struct sk_buff *skb,
 #endif
 	}
 
-	return ip_vs_in_icmp(ipvs, skb, &r, state->hook);
+	return ip_vs_in_icmp(ipvs, skb, &r, state->hook, &iphdr);
 }
 
 static const struct nf_hook_ops ip_vs_ops4[] = {
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index f6f732b7dfa8..3dbd3096e163 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -121,7 +121,7 @@ sctp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 			payload_csum = true;
 	}
 
-	sctph = (void *) skb_network_header(skb) + sctphoff;
+	sctph = (void *)skb->data + sctphoff;
 
 	/* Only update csum if we really have to */
 	if (sctph->source != cp->vport || payload_csum ||
@@ -169,7 +169,7 @@ sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 			payload_csum = true;
 	}
 
-	sctph = (void *) skb_network_header(skb) + sctphoff;
+	sctph = (void *)skb->data + sctphoff;
 
 	/* Only update csum if we really have to */
 	if (sctph->dest != cp->dport || payload_csum ||
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 533fce3e5e4e..99a286fdc90c 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -179,7 +179,7 @@ tcp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 			payload_csum = true;
 	}
 
-	tcph = (void *)skb_network_header(skb) + tcphoff;
+	tcph = (void *)skb->data + tcphoff;
 	tcph->source = cp->vport;
 
 	/* Adjust TCP checksums */
@@ -260,7 +260,7 @@ tcp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 			payload_csum = true;
 	}
 
-	tcph = (void *)skb_network_header(skb) + tcphoff;
+	tcph = (void *)skb->data + tcphoff;
 	tcph->dest = cp->dport;
 
 	/*
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index de3597347542..f32785682402 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -170,7 +170,7 @@ udp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 			payload_csum = true;
 	}
 
-	udph = (void *)skb_network_header(skb) + udphoff;
+	udph = (void *)skb->data + udphoff;
 	udph->source = cp->vport;
 
 	/*
@@ -254,7 +254,7 @@ udp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 			payload_csum = true;
 	}
 
-	udph = (void *)skb_network_header(skb) + udphoff;
+	udph = (void *)skb->data + udphoff;
 	udph->dest = cp->dport;
 
 	/*
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index ce542ed4b013..3b6a99fb4cf7 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -1504,8 +1504,9 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
  */
 int
 ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		struct ip_vs_protocol *pp, int offset, unsigned int hooknum,
-		struct ip_vs_iphdr *iph)
+		struct ip_vs_protocol *pp, unsigned int toff,
+		unsigned int wlen, unsigned int hooknum,
+		struct ip_vs_iphdr *ciph)
 {
 	struct rtable	*rt;	/* Route to the other host */
 	int rc;
@@ -1517,7 +1518,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	   translate address/port back */
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
 		if (cp->packet_xmit)
-			rc = cp->packet_xmit(skb, cp, pp, iph);
+			rc = cp->packet_xmit(skb, cp, pp, ciph);
 		else
 			rc = NF_ACCEPT;
 		/* do not touch skb anymore */
@@ -1535,7 +1536,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
 	local = __ip_vs_get_out_rt(cp->ipvs, cp->af, skb, cp->dest, cp->daddr.ip, rt_mode,
-				   NULL, iph);
+				   NULL, ciph);
 	if (local < 0)
 		goto tx_error;
 	rt = skb_rtable(skb);
@@ -1567,13 +1568,13 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	}
 
 	/* copy-on-write the packet before mangling it */
-	if (skb_ensure_writable(skb, offset))
+	if (skb_ensure_writable(skb, wlen))
 		goto tx_error;
 
 	if (skb_cow(skb, rt->dst.dev->hard_header_len))
 		goto tx_error;
 
-	ip_vs_nat_icmp(skb, pp, cp, 0);
+	ip_vs_nat_icmp(skb, pp, cp, 0, toff);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->ignore_df = 1;
@@ -1589,8 +1590,9 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		struct ip_vs_protocol *pp, int offset, unsigned int hooknum,
-		struct ip_vs_iphdr *ipvsh)
+		struct ip_vs_protocol *pp, unsigned int toff,
+		unsigned int wlen, unsigned int hooknum,
+		struct ip_vs_iphdr *ciph)
 {
 	struct rt6_info	*rt;	/* Route to the other host */
 	int rc;
@@ -1602,7 +1604,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	   translate address/port back */
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
 		if (cp->packet_xmit)
-			rc = cp->packet_xmit(skb, cp, pp, ipvsh);
+			rc = cp->packet_xmit(skb, cp, pp, ciph);
 		else
 			rc = NF_ACCEPT;
 		/* do not touch skb anymore */
@@ -1619,7 +1621,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
 	local = __ip_vs_get_out_rt_v6(cp->ipvs, cp->af, skb, cp->dest,
-				      &cp->daddr.in6, NULL, ipvsh, 0, rt_mode);
+				      &cp->daddr.in6, NULL, ciph, 0, rt_mode);
 	if (local < 0)
 		goto tx_error;
 	rt = dst_rt6_info(skb_dst(skb));
@@ -1651,13 +1653,13 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	}
 
 	/* copy-on-write the packet before mangling it */
-	if (skb_ensure_writable(skb, offset))
+	if (skb_ensure_writable(skb, wlen))
 		goto tx_error;
 
 	if (skb_cow(skb, rt->dst.dev->hard_header_len))
 		goto tx_error;
 
-	ip_vs_nat_icmp_v6(skb, pp, cp, 0);
+	ip_vs_nat_icmp_v6(skb, pp, cp, 0, toff, ciph);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->ignore_df = 1;
-- 
2.55.0


