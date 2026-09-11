Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E24B23C4B79;
	Fri, 11 Sep 2026 11:43:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789127020; cv=none; b=BTee0hm+OYYeciLyEoZ28c8XZ1BpYtF4iFvdkGrYCfsL/O4z/feGCXeHYSqJkgkFj1flaOSHDEylwakhWFHYz0PzHY7b3znRM47zTnhWKn5Zn8DOBWYxXXnhiDHly7Brw82vJ/rb+BxXYr/2YlzKGGf9eMq4/yCQoU2CnowPztQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789127020; c=relaxed/simple;
	bh=juGPED8ROS63nWcf/gZsRRcmIFSxqcwbAeB4pBzEHrU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=o2NjKO9sdZ6KFwCVueu5mdFjYL4mSgaEkkh4njf6QaETYvDmhRaw0TCPkD3DuKzYaZkclNx26lHeMhOZYm45GX8v7VQKuzPmmfsY3mrtVRxs/BthYluxrrlBQsHkFa7uHjUr/NWqVVtV1sazZ+loK5UFckaDvL3vfHPufhHADnk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=tKDRcbuS; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="tKDRcbuS"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id D86F522741;
	Fri, 11 Sep 2026 14:43:28 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=U5qlHzDy
	MBPEx+BynQaHftC9ifFeOcJTskl5VCgbYGk=; b=tKDRcbuSF8RtKiS5GkgvWyW+
	Tl8LLmNztemYnN9hPBAwQZQ9ndw1Lj4qXo3P3mvHLr1+X5fl+iUvmVGp6ZfR2w9H
	O2J6uDiu+nmeX9VzR+69ispbLnAgI1U1PmgjQ3dp63Enm3DGfAXCEj0KxvcrigH6
	EQ/2DTJUocOu9jImJosNTCMq+aHnUUj6399e+oRM8VuOarZswrbAqT9nzC+07TpN
	sLLARpb0DRmIpybhWiGa7LulZwBU3cBAatek4LQHER905lTC2QeQtkbtr+N3BZMR
	LBdZcyQGoBCxSoI5t+aahhG22rXyhTr9AEMvVzXP4R4ik8b7wmy/+vl6gRp5Ni8v
	MCVlMDR5JXTP3yYC+yLAuXHX1TfBM6b4HAJhoLi1kqKyyLxV1vRq6cSpKitwPJ5o
	McfzaXTXhaCaEQg7O56vyx7KylntYAiAV42yFvFOtkO+MDvTTClvkVMXGd0tmLor
	5Xp1uN6nKbOgNW1Uqy0lVXcmwvlfa375lqWJxDZevytLiMo2kxQ+rjsHyQ8eh+t0
	OctJNRaeHccYKS00udKjxU9Fr9SxzqzJtzSuIoE7Tl1rZ+EQcQg/d3FSlA7WIM5b
	4Ai1zS2mMhcHhlm47ioPJMaEcP2q9JsdHWqJr2j12QaPHT5N4R0HRtY1b0nEs97R
	00wVc+8R8YCAT+Fq5eE=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 11 Sep 2026 14:43:28 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 837676084A;
	Fri, 11 Sep 2026 14:43:30 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68BBhTJU030859;
	Fri, 11 Sep 2026 14:43:29 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 68BBhQFV030857;
	Fri, 11 Sep 2026 14:43:26 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH v2 nf] ipvs: revalidate ihl before icmp_send
Date: Fri, 11 Sep 2026 14:43:15 +0300
Message-ID: <20260911114315.30845-1-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

While the outer IP header is already pulled into the skb head,
we must be careful and revalidate the embedded headers after
reading them from the skb frags to prevent possible
out-of-bounds access.

One such place reported by Sashiko is ip_vs_in_icmp() where
local process can change the ihl field and after
pskb_may_pull() we can see larger value. Even if icmp_send()
has checks to prevent out-of-bounds access, play safe and
add check to drop the packet if the ihl field is changed.
As the outer headers are pulled, make sure the transport
header is updated too, it was used before commit 7fcc2fe39fed
("net: icmp: avoid invalid transport header access in icmp_send
tracepoint")

Fixes: f2edb9f7706d ("ipvs: implement passive PMTUD for IPIP packets")
Link: https://sashiko.dev/#/patchset/20260806105211.34622-1-ja%40ssi.bg
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 Changes:
 v1->v2:
 * do not provide protocol to ipv4_update_pmtu() that is not
   provided also to the route lookup
 * update the commit message to better explain that even if
   icmp_send has no problems it is better to have valid
   ihl and transport header

 net/netfilter/ipvs/ip_vs_core.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 1a0661d19d9f..397d5392ebed 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1960,6 +1960,12 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 		/* Ensure the IP header is present in headroom */
 		if (!pskb_may_pull(skb, hlen_orig))
 			goto ignore_tunnel;
+		skb_set_transport_header(skb, hlen_orig);
+		/* Before now we may used ihl from skb frag, revalidate it after
+		 * copying it into skb head to prevent out-of-bounds access
+		 */
+		if (ip_hdr(skb)->ihl * 4 != hlen_orig)
+			goto ignore_tunnel;
 		IP_VS_DBG(12, "Sending ICMP for %pI4->%pI4: t=%u, c=%u, i=%u\n",
 			&ip_hdr(skb)->saddr, &ip_hdr(skb)->daddr,
 			type, code, ntohl(info));
-- 
2.55.0


