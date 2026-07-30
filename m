Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A98FE2DA775;
	Thu, 30 Jul 2026 18:39:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785436788; cv=none; b=sE4nuN6MnOHZg6N9i5/l0f1KgNb5dAUBA+fovr8blvChqwKMz30492IeWjfixtmEucDtJIktxVr+Lg2Mv7UxysnWg6+wzmclRUrwrR/xlaK4X7UcU8LVP76OBx+wpo9srEnbkmYSs8/QDPbzwPkHHNssS5IOf4Bd4XOFTNRBKMY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785436788; c=relaxed/simple;
	bh=bniUsQ6u1JZRM59YUbs8Kwvx7wTHHn8ldOx/wm0Q9HQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=lBzBe9dsA7ojY6OUESbUrFI8NFce8jHBHCS5uqAZ7Mo9Nl3j7u/Kmv0Ys6YYIQeFkDpQxcH/S8gGNcOgPn3ElWmAN6VcBf8o5OzV58e/Y2lRMEus89ds51nMVK1bOvbQQF5FAs1h3QDEz7ezuIVzrB+46zKqAbxWYUixQhZOohk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=RcVmhR9C; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="RcVmhR9C"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id D45A3216C7;
	Thu, 30 Jul 2026 21:39:00 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=xX9uUmHaYlCktnwIS88QJ+fzr5Cdm5BEUmee6TVCCmQ=; b=RcVmhR9C2U/m
	aTpfzbDGKSzckFGF+apSti94FgTVO6vUqmPF1Xk35TyRZpYzUsRmXNum9/3Pjn68
	iPeHgz0wiAgV06j4Y8QAS/Ak2AEaXHFnLmRPJItbicKJpNZeHzZYhbuH4vT3Ea5a
	PznnUpnlaNzOquph0wRrDQy66V0VW54ivFYoSRo+Z+8DtUyheQc4Iq702l4g+b7C
	v+4078M9wPA0gjTlZ1Qu4f76i7W43oN6wq66H8/7xGCqWiVJzAvlyyj61+dCY68N
	9OZ/KtjxnQsIXscC9BUNHINBBMhFLC1OJBJN5XphVI/oikBIu/hWYFysulejmGiv
	4Nj4LCyk/8DAAfSkipk1Hp2PMFWU9eewdDIbp0nJRjY6rRYh2y5Z0j0zufVUO14x
	5R+i1q0CubUdcHyTT1Co89clAhxNEqbvIz8a5uMpwUlyLFazT6EpBTICxjZz4AQJ
	T30DBSQOTGL6OBImsb6/7v1pFUuCA1absTLwkvRhiB2GiWKYlaL6/rY4NTsIfhGq
	YE/ec37H7seCjFoS2cP8+FOHYNjtooI5w6ODoftj1G0M69hP59ErIVku8r70/bMo
	kzybV6emR9TQr2Bz36oVtD26Y76thlPTKMqxiNHuIlYWSte7qnMUyIpPND4Fq6/F
	1qA262E10ZuV1KdMk41fzK3N7VJQffU=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 30 Jul 2026 21:39:00 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id C0C7A61BEF;
	Thu, 30 Jul 2026 21:39:01 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66UIaDhY087547;
	Thu, 30 Jul 2026 21:36:13 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 66UIaD1x087546;
	Thu, 30 Jul 2026 21:36:13 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf v3 1/2] ipvs: avoid out-of-bounds write in ip_vs_nat_icmp
Date: Thu, 30 Jul 2026 21:35:05 +0300
Message-ID: <20260730183506.87473-2-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260730183506.87473-1-ja@ssi.bg>
References: <20260730183506.87473-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Sashiko warns that local attacker can modify the packet
while it is processed by IPVS. Some places read the
IP ihl field multiple times which can cause out-of-bounds
access. One such place is ip_vs_nat_icmp where we
can write after the validated area.

Fix it by providing ciph argument just like it is done for
IPv6 and use ciph->len as offset to the embedded transport
header.

Modify some IPv4 header checks by reading the ihl field
only once.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Link: https://sashiko.dev/#/patchset/20260722101517.36313-1-ja%40ssi.bg
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |  2 +-
 net/netfilter/ipvs/ip_vs_core.c | 67 +++++++++++++++++----------------
 net/netfilter/ipvs/ip_vs_xmit.c |  2 +-
 3 files changed, 36 insertions(+), 35 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index e6ca930a3507..1235f1934e94 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -2062,7 +2062,7 @@ static inline bool ip_vs_conn_use_hash2(struct ip_vs_conn *cp)
 
 void ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		    struct ip_vs_conn *cp, int dir, unsigned int toff,
-		    bool has_ports);
+		    bool has_ports, struct ip_vs_iphdr *ciph);
 
 #ifdef CONFIG_IP_VS_IPV6
 void ip_vs_nat_icmp_v6(struct sk_buff *skb, struct ip_vs_protocol *pp,
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 6b79e0c4d9e2..0bdaeb4ed61e 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -925,28 +925,27 @@ static int ip_vs_route_me_harder(struct netns_ipvs *ipvs, int af,
  */
 void ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		    struct ip_vs_conn *cp, int inout, unsigned int toff,
-		    bool has_ports)
+		    bool has_ports, struct ip_vs_iphdr *ciph)
 {
 	struct iphdr *iph	 = ip_hdr(skb);
 	struct icmphdr *icmph	 = (struct icmphdr *)(skb->data + toff);
-	struct iphdr *ciph	 = (struct iphdr *)(icmph + 1);
-	unsigned int coff __maybe_unused = toff + sizeof(struct icmphdr);
+	struct iphdr *cih	 = (struct iphdr *)(icmph + 1);
 
 	if (inout) {
 		iph->saddr = cp->vaddr.ip;
 		ip_send_check(iph);
-		ciph->daddr = cp->vaddr.ip;
-		ip_send_check(ciph);
+		cih->daddr = cp->vaddr.ip;
+		ip_send_check(cih);
 	} else {
 		iph->daddr = cp->daddr.ip;
 		ip_send_check(iph);
-		ciph->saddr = cp->daddr.ip;
-		ip_send_check(ciph);
+		cih->saddr = cp->daddr.ip;
+		ip_send_check(cih);
 	}
 
 	/* the TCP/UDP/SCTP port */
 	if (has_ports) {
-		__be16 *ports = (void *)ciph + ciph->ihl*4;
+		__be16 *ports = (void *)(skb->data + ciph->len);
 
 		if (inout)
 			ports[1] = cp->vport;
@@ -960,10 +959,10 @@ void ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 	if (inout)
-		IP_VS_DBG_PKT(11, AF_INET, pp, skb, coff,
+		IP_VS_DBG_PKT(11, AF_INET, pp, skb, ciph->off,
 			      "Forwarding altered outgoing ICMP");
 	else
-		IP_VS_DBG_PKT(11, AF_INET, pp, skb, coff,
+		IP_VS_DBG_PKT(11, AF_INET, pp, skb, ciph->off,
 			      "Forwarding altered incoming ICMP");
 }
 
@@ -1056,7 +1055,7 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 		ip_vs_nat_icmp_v6(skb, pp, cp, 1, toff, has_ports, ciph);
 	else
 #endif
-		ip_vs_nat_icmp(skb, pp, cp, 1, toff, has_ports);
+		ip_vs_nat_icmp(skb, pp, cp, 1, toff, has_ports, ciph);
 
 	if (ip_vs_route_me_harder(cp->ipvs, af, skb, hooknum))
 		goto out;
@@ -1092,7 +1091,7 @@ static int ip_vs_out_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb,
 	struct ip_vs_iphdr ciph;
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
-	unsigned int offset, ihl;
+	unsigned int offset;
 	union nf_inet_addr snet;
 
 	*related = 1;
@@ -1105,7 +1104,6 @@ static int ip_vs_out_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb,
 			return NF_ACCEPT;
 	}
 
-	ihl = ipvsh->len;
 	offset = ipvsh->len;
 	ic = skb_header_pointer(skb, offset, sizeof(_icmph), &_icmph);
 	if (ic == NULL)
@@ -1131,11 +1129,15 @@ static int ip_vs_out_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb,
 
 	/* Now find the contained IP header */
 	offset += sizeof(_icmph);
+	if (!ip_vs_fill_iph_skb_icmp(AF_INET, skb, offset, true, &ciph))
+		return NF_ACCEPT; /* The packet looks wrong, ignore */
+
 	cih = skb_header_pointer(skb, offset, sizeof(_ciph), &_ciph);
-	if (!(cih && cih->version == 4 && cih->ihl >= 5))
+	if (!(cih && cih->version == 4 &&
+	      ciph.len - ciph.off >= sizeof(struct iphdr)))
 		return NF_ACCEPT; /* The packet looks wrong, ignore */
 
-	pp = ip_vs_proto_get(cih->protocol);
+	pp = ip_vs_proto_get(ciph.protocol);
 	if (!pp)
 		return NF_ACCEPT;
 
@@ -1146,8 +1148,6 @@ static int ip_vs_out_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb,
 	IP_VS_DBG_PKT(11, AF_INET, pp, skb, offset,
 		      "Checking outgoing ICMP for");
 
-	ip_vs_fill_iph_skb_icmp(AF_INET, skb, offset, true, &ciph);
-
 	/* The embedded headers contain source and dest in reverse order */
 	cp = INDIRECT_CALL_1(pp->conn_out_get, ip_vs_conn_out_get_proto,
 			     ipvs, AF_INET, skb, &ciph);
@@ -1155,8 +1155,8 @@ static int ip_vs_out_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb,
 		return NF_ACCEPT;
 
 	snet.ip = ipvsh->saddr.ip;
-	return handle_response_icmp(AF_INET, skb, &snet, cp, pp, &ciph, ihl,
-				    hooknum);
+	return handle_response_icmp(AF_INET, skb, &snet, cp, pp, &ciph,
+				    ipvsh->len, hooknum);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1803,10 +1803,12 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 	/* Now find the contained IP header */
 	offset += sizeof(_icmph);
 	cih = skb_header_pointer(skb, offset, sizeof(_ciph), &_ciph);
-	if (!(cih && cih->version == 4 && cih->ihl >= 5))
+	if (!cih)
 		return NF_ACCEPT; /* The packet looks wrong, ignore */
-	raddr = (union nf_inet_addr *)&cih->daddr;
 	hlen_ipip = cih->ihl * 4;
+	if (!(cih->version == 4 && hlen_ipip >= sizeof(struct iphdr)))
+		return NF_ACCEPT; /* The packet looks wrong, ignore */
+	raddr = (union nf_inet_addr *)&cih->daddr;
 
 	/* Special case for errors for IPIP/UDP/GRE tunnel packets */
 	tunnel = false;
@@ -1823,9 +1825,6 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 		if (!dest || dest->tun_type != IP_VS_CONN_F_TUNNEL_TYPE_IPIP)
 			return NF_ACCEPT;
 		offset += hlen_ipip;
-		cih = skb_header_pointer(skb, offset, sizeof(_ciph), &_ciph);
-		if (!(cih && cih->version == 4 && cih->ihl >= 5))
-			return NF_ACCEPT; /* The packet looks wrong, ignore */
 		tunnel = true;
 	} else if ((cih->protocol == IPPROTO_UDP ||	/* Can be UDP encap */
 		    cih->protocol == IPPROTO_GRE) &&	/* Can be GRE encap */
@@ -1850,21 +1849,25 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 			/* Skip IP and UDP/GRE tunnel headers */
 			offset = offset2 + ulen;
 			/* Now we should be at the original IP header */
-			cih = skb_header_pointer(skb, offset, sizeof(_ciph),
-						 &_ciph);
-			if (cih && cih->version == 4 && cih->ihl >= 5 &&
-			    iproto == IPPROTO_IPIP)
+			if (iproto == IPPROTO_IPIP)
 				tunnel = true;
 			else
 				return NF_ACCEPT;
 		}
 	}
 
-	pd = ip_vs_proto_data_get(ipvs, cih->protocol);
+	if (!ip_vs_fill_iph_skb_icmp(AF_INET, skb, offset, !tunnel, &ciph))
+		return NF_ACCEPT;
+	pd = ip_vs_proto_data_get(ipvs, ciph.protocol);
 	if (!pd)
 		return NF_ACCEPT;
 	pp = pd->pp;
 
+	cih = skb_header_pointer(skb, offset, sizeof(_ciph), &_ciph);
+	if (!(cih && cih->version == 4 &&
+	      ciph.len - ciph.off >= sizeof(struct iphdr)))
+		return NF_ACCEPT; /* The packet looks wrong, ignore */
+
 	/* Is the embedded protocol header present? */
 	if (unlikely(cih->frag_off & htons(IP_OFFSET) && !pp->dont_defrag))
 		return NF_ACCEPT;
@@ -1872,9 +1875,6 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 	IP_VS_DBG_PKT(11, AF_INET, pp, skb, offset,
 		      "Checking incoming ICMP for");
 
-	offset2 = offset;
-	ip_vs_fill_iph_skb_icmp(AF_INET, skb, offset, !tunnel, &ciph);
-
 	/* The embedded headers contain source and dest in reverse order.
 	 * For IPIP/UDP/GRE tunnel this is error for request, not for reply.
 	 */
@@ -1904,11 +1904,12 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 	}
 
 	if (tunnel) {
-		unsigned int hlen_orig = cih->ihl * 4;
+		unsigned int hlen_orig = ciph.len - ciph.off;
 		__be32 info = ic->un.gateway;
 		__u8 type = ic->type;
 		__u8 code = ic->code;
 
+		offset2 = offset;
 		/* Update the MTU */
 		if (ic->type == ICMP_DEST_UNREACH &&
 		    ic->code == ICMP_FRAG_NEEDED) {
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index cdc567ceabf4..4469dcc4bb1e 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -1582,7 +1582,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (skb_cow(skb, rt->dst.dev->hard_header_len))
 		goto tx_error;
 
-	ip_vs_nat_icmp(skb, pp, cp, 0, toff, has_ports);
+	ip_vs_nat_icmp(skb, pp, cp, 0, toff, has_ports, ciph);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->ignore_df = 1;
-- 
2.55.0


