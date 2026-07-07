Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3E82B3FFAC1;
	Tue,  7 Jul 2026 18:26:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783448809; cv=none; b=AV60lEB9mvm10K7Go1f64XMH7vVeRM6IZhN3IrpbHHx0AHuKN49ht3oe7sTztFtyRhHLKzH3gHnj7Z6IYybP4kI0ZJdWkQt9w0iqgSGtjiIDJ6rXxZ42IfGXaOSVzDhPlfZu2uc+x/+BamOcSsTXng2e/M/weMrB1DSkThQmIcE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783448809; c=relaxed/simple;
	bh=yZD8oR++9S2wxnOCST5oaAhX1F9FUGjEvaZ/wDJD1L4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=bpRJWU7gdJnwLoAHaXDs21GPEky4roXTW4vsiWJLxePkjzYc1Rtg8MZn0YOJGc1a37mbcWPMj42VsJTPRV9meLCJeHtSTQEbECsG9LIDn6R7+SygJ4c0ktS6AqrsYA71Ji4sp/Sbb4EmEsXQuZzHkM6rXaHDnhu5VeYClORD/CI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=VsAnP6Pr; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="VsAnP6Pr"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 74C9B210B6;
	Tue, 07 Jul 2026 21:26:36 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=UFCidkJL
	pLfiIFJgNkgEBet8t+STzc5zYOPodKZqJhM=; b=VsAnP6Pr4L0RaOknb6l92HoF
	QabeJdM0lZ/iYw0XXbiPhxunMeUK5RqlqqGlRB9scc8WshQEV9kBy7/eDCrneWTZ
	1R61jBDbZIY9NiSSgv4qUNoMwVMkhWPUOwa8T87dXby6z7ms5fQHgC+UgvCqehxe
	Izv7TgmXHTlhoz/X6rSrrOclmXYxWO+oKJnZfSH+2MNdd+NnZ5qkxawwQCEAPzJF
	yfyyhCOSeu/jGe5UjpL6bN3sZwIIwToOiqwCTEirng9nE+pjwN+UXKv0lrPvITzC
	olMN2FAW1TuM2KwC/SRjFRtj4M4MeEhigyRHuv6/4FH8W4F2kgI4JFD6fRtMABiP
	k2unY87IC9kFsLglLDGysSczG3ELksG4O9sHoJVsyCfBZYThr+eYvc4hqxceggQ2
	JWgBM9l7ayNWVhNx5YPKxeqCi+pv/fKOoaPSYfXoMylcuA5M6oIGyqlXY0m9Ztt/
	j97ieqJHqStU8haIyR97xt62YbXCAi5/bTPq4mL2LOJ9e23PM8nf85rfM5QdxRV8
	AtGRW7mhv2WR3voHs/3u9emXs+DMR50s6ltaPs7v3/OKbw9A1lXTrIFS0diIlbWe
	pquuUzCvhyORnYhNDujDYMuoNSZ/5t4sCEU7JujOPnXRDg11vRvUJgnpecioQVMf
	r5evduqykbYPi336usQ=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 07 Jul 2026 21:26:36 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 5FACB607AC;
	Tue,  7 Jul 2026 21:26:34 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 667IQQsh071704;
	Tue, 7 Jul 2026 21:26:26 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 667IQP84071699;
	Tue, 7 Jul 2026 21:26:25 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf v2] ipvs: ensure inner headers in ICMP errors are in headroom
Date: Tue,  7 Jul 2026 21:25:46 +0300
Message-ID: <20260707182547.71680-1-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Sashiko points out that after stripping the outer headers
with pskb_pull() we should ensure the inner IP headers
in ICMP errors from tunnels are present in the skb headroom
for functions like ipv4_update_pmtu(), icmp_send() and
IP_VS_DBG().

Also, add more checks for the length of the inner headers.

Fixes: f2edb9f7706d ("ipvs: implement passive PMTUD for IPIP packets")
Link: https://sashiko.dev/#/patchset/20260702073430.67680-1-zhaoyz24%40mails.tsinghua.edu.cn
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_core.c | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 906f2c361676..5b427349a257 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1767,6 +1767,7 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 	bool tunnel, new_cp = false;
 	union nf_inet_addr *raddr;
 	char *outer_proto = "IPIP";
+	unsigned int hlen_ipip;
 	int ulen = 0;
 
 	*related = 1;
@@ -1804,9 +1805,10 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 	/* Now find the contained IP header */
 	offset += sizeof(_icmph);
 	cih = skb_header_pointer(skb, offset, sizeof(_ciph), &_ciph);
-	if (cih == NULL)
+	if (!(cih && cih->version == 4 && cih->ihl >= 5))
 		return NF_ACCEPT; /* The packet looks wrong, ignore */
 	raddr = (union nf_inet_addr *)&cih->daddr;
+	hlen_ipip = cih->ihl * 4;
 
 	/* Special case for errors for IPIP/UDP/GRE tunnel packets */
 	tunnel = false;
@@ -1822,9 +1824,9 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 		/* Only for known tunnel */
 		if (!dest || dest->tun_type != IP_VS_CONN_F_TUNNEL_TYPE_IPIP)
 			return NF_ACCEPT;
-		offset += cih->ihl * 4;
+		offset += hlen_ipip;
 		cih = skb_header_pointer(skb, offset, sizeof(_ciph), &_ciph);
-		if (cih == NULL)
+		if (!(cih && cih->version == 4 && cih->ihl >= 5))
 			return NF_ACCEPT; /* The packet looks wrong, ignore */
 		tunnel = true;
 	} else if ((cih->protocol == IPPROTO_UDP ||	/* Can be UDP encap */
@@ -1836,7 +1838,7 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 		/* Non-first fragment has no UDP/GRE header */
 		if (unlikely(cih->frag_off & htons(IP_OFFSET)))
 			return NF_ACCEPT;
-		offset2 = offset + cih->ihl * 4;
+		offset2 = offset + hlen_ipip;
 		if (cih->protocol == IPPROTO_UDP) {
 			ulen = ipvs_udp_decap(ipvs, skb, offset2, AF_INET,
 					      raddr, &iproto);
@@ -1905,6 +1907,7 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 	}
 
 	if (tunnel) {
+		unsigned int hlen_orig = cih->ihl * 4;
 		__be32 info = ic->un.gateway;
 		__u8 type = ic->type;
 		__u8 code = ic->code;
@@ -1921,6 +1924,9 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 				goto ignore_tunnel;
 			offset2 -= ihl + sizeof(_icmph);
 			skb_reset_network_header(skb);
+			/* Ensure the IP header is present in headroom */
+			if (!pskb_may_pull(skb, hlen_ipip))
+				goto ignore_tunnel;
 			IP_VS_DBG(12, "ICMP for %s %pI4->%pI4: mtu=%u\n",
 				  outer_proto, &ip_hdr(skb)->saddr,
 				  &ip_hdr(skb)->daddr, mtu);
@@ -1936,8 +1942,8 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 				if (dest_dst)
 					mtu = dst_mtu(dest_dst->dst_cache);
 			}
-			if (mtu > 68 + sizeof(struct iphdr) + ulen)
-				mtu -= sizeof(struct iphdr) + ulen;
+			if (mtu > 68 + hlen_ipip + ulen)
+				mtu -= hlen_ipip + ulen;
 			info = htonl(mtu);
 		}
 		/* Strip outer IP, ICMP and IPIP/UDP/GRE, go to IP header of
@@ -1946,6 +1952,9 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 		if (pskb_pull(skb, offset2) == NULL)
 			goto ignore_tunnel;
 		skb_reset_network_header(skb);
+		/* Ensure the IP header is present in headroom */
+		if (!pskb_may_pull(skb, hlen_orig))
+			goto ignore_tunnel;
 		IP_VS_DBG(12, "Sending ICMP for %pI4->%pI4: t=%u, c=%u, i=%u\n",
 			&ip_hdr(skb)->saddr, &ip_hdr(skb)->daddr,
 			type, code, ntohl(info));
-- 
2.55.0


