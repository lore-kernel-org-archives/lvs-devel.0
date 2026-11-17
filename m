Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.160.178
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794922862;
	b=gyupNaC0kW8NKTBcQU6CqCV9wotMEEeAkZmEESFuDNWFheOL0sYA/Yl3ZCZ2eAIpg4Ye
	 tuVee52KOXWD1inlypRDZAaPq2g5r6s0QVDRA01KQKwZA4uCXCwZcdekqyFntOCakPMKU
	 oa68uSUUmtiRfFMD7IrOSHU2HlnSokTxriUUbkO8jvhqZwNM1YmfU3hyEez9BaRHK2jw+
	 dRpTOv/lG7hAt50IQKMY6e74LWQL8JjBttEiEQmBlO6taQmU+JXSmVeIzTn2xZXQuYWOr
	 K1RomrvlFa0nFPALbR1lguQ73g0IFxFTXjSz3UK/MYhiNdnDiEUgttJNRJ263X4GZ2A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794922862;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=xbM/8NkFsyBNUIt/zB1tHx2aYKgPjS1RSmbEYKw0CLs=;
	b=LfAEF/bF6YkCOESBFmtGvdmlqAQCuz8uBchoPWBn1lJxJllNXme0UmcqPaXNnUQztqhf
	 SOkrAq4peIh8e7hYtKvmFVMNVwKUQlY9mTmb/84liI2XtCKZQVHCZB9WrgF27L4dvi08e
	 aUdUl2OhdRer+msxaQdN+qweyMa9vsmCGAxemtg7Y3MHClyxZo25z+jYWj2kHpOP5EJwt
	 v6rhKSXn1K8JvNJikRqEQ7QcjdwGoF8hj2DVzAnguN6TjCkKqNQUaXFxuH8toMTJQgzpO
	 f9CrkXCUClQRvXPCAHJMI7FgYriFY3gpOV92iVpPQrVvIEhziGZRtioTzGDpwszfyfg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=1password.com;
	spf=pass smtp.mailfrom=agilebits.com;
	dkim=pass header.d=1password.com header.i=@1password.com header.a=rsa-sha256 header.s=google header.b=foXaldXx;
	arc=none smtp.remote-ip=209.85.160.178
Received: from mail-qt1-f178.google.com (mail-qt1-f178.google.com [209.85.160.178])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4F3FD606A33B
	for <lvs-devel@vger.kernel.org>; Tue, 17 Nov 2026 13:41:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4F3FD606A33B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=1password.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=agilebits.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=1password.com header.i=@1password.com header.a=rsa-sha256 header.s=google header.b=foXaldXx
Received: by mail-qt1-f178.google.com with SMTP id d75a77b69052e-5365d26ccbdso33433491cf.0
        for <lvs-devel@vger.kernel.org>; Tue, 17 Nov 2026 05:41:01 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1password.com; s=google; t=1794922860; x=1795527660; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=xbM/8NkFsyBNUIt/zB1tHx2aYKgPjS1RSmbEYKw0CLs=;
        b=foXaldXxEEH54V2YER/HHxt3jQlsWT7az36Ckd/VVrISFU+poHoFoVbuu7oDwkMqzU
         qb2Irozt25K9uH+74SzjT1PdSdXH54erl8ewjyR8naD8oGSgnVqYFLAsTrAhqK+ZjDqk
         stYd45245HPCPLkxFvpF7zkqwuKxfJCeAjwcM=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794922860; x=1795527660;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=xbM/8NkFsyBNUIt/zB1tHx2aYKgPjS1RSmbEYKw0CLs=;
        b=nc2FyXT2NiSm60Fxv1ovpAeFdIwSwQN260HGaIWzPMKtuD1f3Y4488CGqTBx7CaIGf
         1lfLKyp2jTivj1YPqVX/cRHe4NJh40QcT7x/zvOR05Uog2VUb+HSeaNynmXR96e9hlg7
         0kPa0gL3nc2sjXABkQmm3cv8rdZTOBK6hXfDNnN0VF70KqlXUSIc4qeg7aHlDXU84gSs
         8PUUI7LnWQsvxD0S/x7vcneK9jwfQ09MTv8H+lIwZs11p5WjY1U1/lcT9BUHtxLh/yFt
         a3KVA2/23+zKPfRqSzMbROp4HBH0u3aRn3/7ECUNSLPtWi91bB8DqHSg1YGnaFHupFl9
         SIoQ==
X-Forwarded-Encrypted: i=1; AL+hErGCtkLdIxvQ8z3zESI2Y42XuG84xdtyVH6RzafN8ozISLcNM063NRuR4LKgdM7Xs0l6jAEeP550WCw=@vger.kernel.org
X-Gm-Message-State: APuU4Z8ZjhrieDIy5HpTAN7jngX+WWpROcdnvzioKqEEdJiavM5vwlip
	3X6gnBxxh9e4S/T6eT4IwSqSuVokU57FRUKHAvzjXRautmOY9g7uUgMEpM4GRNJS4nw=
X-Gm-Gg: AYBFou0oQzPkgKQTzIRf37fIN1/CaE2G3FKDCYCX3CNPRTUcO9+qdghOsqjMNMGDE+q
	T2GYZtdrEaFTXR0lo9liZ/3t5aq+dj6x7a+1T00Me/Rzy+8gUHsmNIfr+jXQv/N1F3z+elChFjJ
	/pmxfE1RpsNvDQzebY6IkI22GKGbchrO5LcTqTKkz1yUeeb+IOaW3l/c8VgHL9YZzUgOMxly1FL
	m2fGyKczL3EZWkEjhpKV5kBJnDlK9dv7t8qVFo+RHMNsVXC9LAYmLA4u7Iy5W+p0yY9OEAO4z6f
	DJmes/dm6e57iWWfUUdx4I9Fs1Av+NpIzI2vtbNc8Dc4/q2gIE+54sISJiB2LaazNjTo5ItdHq9
	PpPZZiv6ozCnrFi9sQq3vNuVfP4N6vr049GxgiXDrwGgri+zrq99elKXO1j8plIdDnsCfYAO5Qf
	n7PXUKrqur5reri1Z8dB+Bqyk97PvXMzdF35vZN69L4VKDhCq0ZCWc+1B6v7O4wvH73MvnyG7Lv
	DKEby+fY+s+b0qXyVaAFi2Ugij7+/k9/7Pj5TTh/GuyrbNs0iuIx5v76gxi79vTdWYhTzmQGexm
	OraEBHbdY2NhWwEmC9uT66tlgfiak1HG4CvIW7XUPwJcrpc=
X-Received: by 2002:ac8:5d04:0:b0:55c:8b2d:bb41 with SMTP id d75a77b69052e-55d4a6ce73amr38497231cf.57.1794922860216;
        Tue, 17 Nov 2026 05:41:00 -0800 (PST)
Received: from localhost ([96.239.0.47])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-55ad0534196sm104516571cf.9.2026.11.17.05.40.59
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 17 Nov 2026 05:40:59 -0800 (PST)
From: Axel Mierczuk <axel.mierczuk@1password.com>
To: ja@ssi.bg,
	horms@verge.net.au,
	pablo@netfilter.org
Cc: fw@strlen.de,
	phil@nwl.cc,
	dsahern@kernel.org,
	kuba@kernel.org,
	edumazet@kernel.org,
	pabeni@redhat.com,
	davem@davemloft.net,
	netfilter-devel@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	coreteam@netfilter.org,
	netdev@vger.kernel.org,
	w@1wt.eu,
	Axel Mierczuk <axel.mierczuk@1password.com>,
	stable@vger.kernel.org
Subject: [PATCH nf v2 1/2] ipvs: avoid out-of-bounds write in ip_vs_nat_icmp_v6
Date: Tue, 17 Nov 2026 08:40:48 -0500
Message-ID: <20261117134049.52386-2-axel.mierczuk@1password.com>
X-Mailer: git-send-email 2.50.1
In-Reply-To: <20261117134049.52386-1-axel.mierczuk@1password.com>
References: <20261117134049.52386-1-axel.mierczuk@1password.com>
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

When an ICMPv6 error embeds a non-first fragment, ipv6_find_hdr()
returns at the Fragment header without updating *offset, so
ip_vs_fill_iph_skb_icmp() leaves ciph.len equal to ciph.off, the
start of the embedded IPv6 header.

ip_vs_out_icmp_v6() and ip_vs_in_icmp_v6() pass embedded non-first
TCP, UDP and SCTP fragments through before any lookup. AH and ESP set
pp->dont_defrag, so their fragments continue. Their lookups read only
the addresses and never use ciph.len, but handle_response_icmp() and
ip_vs_icmp_xmit_v6() size skb_ensure_writable() from ciph.len, which
then covers nothing of the embedded header. ip_vs_nat_icmp_v6()
rewrites the embedded destination or source address, 16 bytes
located 8 or 24 bytes past the end of the validated area.

Include the embedded IPv6 header in ciph.len at both call sites when
ipv6_find_hdr() stopped at a non-first fragment. Only the size of the
writable check changes; the AH and ESP lookups do not use ciph.len.

This fix does not depend on patch 2. Stable kernels without commit
342e24a339b9 ("ipvs: do not mangle ICMP replies for non-first fragments")
also need that commit to handle incoming ICMPv6 errors quoting
non-first ESP fragments.

Fixes: 63dca2c0b0e7 ("ipvs: Fix faulty IPv6 extension header handling in IPVS")
Cc: stable@vger.kernel.org
Suggested-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Axel Mierczuk <axel.mierczuk@1password.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index fd503f0efb57..d5da16ff9673 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1206,6 +1206,16 @@ static int ip_vs_out_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
 				     true, &ciph))
 		return NF_ACCEPT; /* The packet looks wrong, ignore */
 
+	/* ipv6_find_hdr() stops at the Fragment header of a non-first
+	 * fragment and leaves ciph.len == ciph.off. Only AH and ESP
+	 * (pp->dont_defrag) pass the fragoffs check below and their
+	 * lookup reads only the addresses, but handle_response_icmp()
+	 * sizes skb_ensure_writable() from ciph.len before
+	 * ip_vs_nat_icmp_v6() rewrites the embedded header. Include it.
+	 */
+	if (ciph.len == ciph.off)
+		ciph.len += sizeof(struct ipv6hdr);
+
 	pp = ip_vs_proto_get(ciph.protocol);
 	if (!pp)
 		return NF_ACCEPT;
@@ -2036,6 +2046,16 @@ static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
 	if (!ip_vs_fill_iph_skb_icmp(AF_INET6, skb, offset, true, &ciph))
 		return NF_ACCEPT;
 
+	/* ipv6_find_hdr() stops at the Fragment header of a non-first
+	 * fragment and leaves ciph.len == ciph.off. Only AH and ESP
+	 * (pp->dont_defrag) pass the fragoffs check below and their
+	 * lookup reads only the addresses, but ip_vs_icmp_xmit_v6()
+	 * sizes skb_ensure_writable() from ciph.len before
+	 * ip_vs_nat_icmp_v6() rewrites the embedded header. Include it.
+	 */
+	if (ciph.len == ciph.off)
+		ciph.len += sizeof(struct ipv6hdr);
+
 	pd = ip_vs_proto_data_get(ipvs, ciph.protocol);
 	if (!pd)
 		return NF_ACCEPT;
-- 
2.50.1 (Apple Git-155)

