Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 255EE37C90A;
	Mon,  6 Jul 2026 15:10:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783350660; cv=none; b=VTG9dNi9tLgjgr4UQ50S9FON9+K53jtun/2NK1y0bjlYf/YAAlqzuEV408I5+Wy7OszQCWbXDe/cQTKlX7X68/a8yo7CeWrRCBicaxJZaFPCKXUdd7EIU6YCWjiiu3XXyPEAfkK7fhPuUaRiXrJXjG7aZ2smrg0m6ldn84HppNU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783350660; c=relaxed/simple;
	bh=aUTCf7JlOr7m8xK8dYpDL18oLPI6y1X0rtyc+Rp2mAE=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=G40vPEsM7fWBzscNWQezvco/E9UoVqRuo7NdPbRIDtuRI7ORfbvmOngBZV+LDtNljEyL5MI/wBh9ERL8ltVrCAdUP1DsBpacPhIM57ewBQjlrJjSI+XlaUcZw5huG2XGRlX7YsG1VBaRH5ez+emC2bzFQ463EAlTfTqHRqU9zs8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=nz2L0e+l; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="nz2L0e+l"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id E075E2121E;
	Mon, 06 Jul 2026 18:10:54 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=iIunyice
	AckuHAc3V345ZoiS4p5UOZL8SUxF7xBzAAs=; b=nz2L0e+lVLDe0vWDnWdBAldO
	xHuJNzClxaka6giJ4O7aPJTQvSj6Th/fprN13js6eM4z+xsOMnkdpK5DHbWJdeFm
	25p4E+089+bPptyTFF0fXxPZCAkse+Ywq1qXmRLL9FFqlFa74QdH8tx/uEgV5pUb
	tylhwNtmrqVys5JTslF2yDS0TMWuak7d6tNCU4MtCCMxFWEBccXH1De+5fAZN89Y
	mbIQEQ0+Z667wHqErmqr4UyiFXnycRKyTju7B+HmxVP3C0xATT1WV+gbcaLVy/Vp
	r4JDxmOP0p0LheXPAcVz7oEPKEJYewmqs/Yk5koMhGdCd4cjGk7i8Io3vSWLGAE+
	ErgzYhgp08RJtzXRTNvjk1VmR+JXabIX20VpYu5evUl+X5h6FrEuKKjTbUKbeuyU
	SL4N5QDUBNHno6V65rFqYoimxI9HsydS1YxZ2kd52ygShYP/iwq1Z6HNjWEdgmhM
	E7jeP1g39D6V3WL/hH8fNBxOsVnNLwXKqOYiTuS/k+CAWrqNiYCjU80ZuLSFgPue
	+34aYabRW9mKmWx2/PrqziQ6XC8CxgQyOM9uLT5BcTq0fyiKohTWjmt4uFWfXcDT
	PyUeDDOS57/mrEvKA93qRAXd3o/fdg0QwRbFX40Q8qO+sxPkubMf9TsMDfysT/Ix
	e25YTgXhpq2QgthfamM=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 06 Jul 2026 18:10:54 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 40BBE60744;
	Mon,  6 Jul 2026 18:10:53 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 666FAqIR062643;
	Mon, 6 Jul 2026 18:10:52 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 666FAqpD062642;
	Mon, 6 Jul 2026 18:10:52 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf] ipvs: ensure inner headers in ICMP errors are in headroom
Date: Mon,  6 Jul 2026 18:10:41 +0300
Message-ID: <20260706151041.62630-1-ja@ssi.bg>
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
 net/netfilter/ipvs/ip_vs_core.c | 20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 906f2c361676..f332ba422a65 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1767,6 +1767,7 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 	bool tunnel, new_cp = false;
 	union nf_inet_addr *raddr;
 	char *outer_proto = "IPIP";
+	unsigned int hlen_ipip = 0;
 	int ulen = 0;
 
 	*related = 1;
@@ -1822,9 +1823,10 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 		/* Only for known tunnel */
 		if (!dest || dest->tun_type != IP_VS_CONN_F_TUNNEL_TYPE_IPIP)
 			return NF_ACCEPT;
-		offset += cih->ihl * 4;
+		hlen_ipip = cih->ihl * 4;
+		offset += hlen_ipip;
 		cih = skb_header_pointer(skb, offset, sizeof(_ciph), &_ciph);
-		if (cih == NULL)
+		if (!(cih && cih->version == 4 && cih->ihl >= 5))
 			return NF_ACCEPT; /* The packet looks wrong, ignore */
 		tunnel = true;
 	} else if ((cih->protocol == IPPROTO_UDP ||	/* Can be UDP encap */
@@ -1836,7 +1838,8 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 		/* Non-first fragment has no UDP/GRE header */
 		if (unlikely(cih->frag_off & htons(IP_OFFSET)))
 			return NF_ACCEPT;
-		offset2 = offset + cih->ihl * 4;
+		hlen_ipip = cih->ihl * 4;
+		offset2 = offset + hlen_ipip;
 		if (cih->protocol == IPPROTO_UDP) {
 			ulen = ipvs_udp_decap(ipvs, skb, offset2, AF_INET,
 					      raddr, &iproto);
@@ -1905,6 +1908,7 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 	}
 
 	if (tunnel) {
+		unsigned int hlen_orig = cih->ihl * 4;
 		__be32 info = ic->un.gateway;
 		__u8 type = ic->type;
 		__u8 code = ic->code;
@@ -1921,6 +1925,9 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 				goto ignore_tunnel;
 			offset2 -= ihl + sizeof(_icmph);
 			skb_reset_network_header(skb);
+			/* Ensure the IP header is present in headroom */
+			if (!pskb_may_pull(skb, hlen_ipip))
+				goto ignore_tunnel;
 			IP_VS_DBG(12, "ICMP for %s %pI4->%pI4: mtu=%u\n",
 				  outer_proto, &ip_hdr(skb)->saddr,
 				  &ip_hdr(skb)->daddr, mtu);
@@ -1936,8 +1943,8 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
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
@@ -1946,6 +1953,9 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
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


