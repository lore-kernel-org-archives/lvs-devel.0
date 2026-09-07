Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AE45C50C2B8;
	Mon,  7 Sep 2026 18:37:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788806274; cv=none; b=k/Pbrm8nXLhql36xGdEemNgWMvmR3GkRqlbL9OYELuGpBETVG5CRb4XJS50dy57oErq5kF/cDBBNs6HOvLssgc8XnxsLNHM+9FmoMsAZesbnItxhXceDK8oZ47xxESXEO3nyd4pYrRUr42yZg3r+A6GlnFnw0RF7Uah9pKn9ZXk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788806274; c=relaxed/simple;
	bh=j+04yLaXOxxF/JMcxJT0l+tVtWraHe/3GhPWMN4d9fw=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=NVowCf+sjd+ZUwBwC6+q7+6V+yOIhnlVHHPrEVO0IDvyoPaPEQ4v1ztKMR6xXcwv9Aysg1RxqH1s/vFYlMeeG0BPk5map9KTYORCtbATq3uN9vD4okGWg1mVbJKlu0kuvB07PnMt6Xk9asqhkcFcz/oy5lQmDvPqS/BHdVgP6gs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=Ti2+fzMe; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="Ti2+fzMe"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 216EF21CC4;
	Mon, 07 Sep 2026 21:37:47 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=0DZ4zUxJ
	MPyNPiPDm/w++zgc4v6I9MjC0Z1kv3EIiVI=; b=Ti2+fzMen9oLUCJ6sn4CpD2F
	OCOnpWFor+rJL2aGRzvOxNIeiaqlEmCrOZnwMNQ58k2G1I9eKn8+On262yT9vd63
	aIoXv7MjvQ7ALh3TcXX2Zsi5n0ni/WaTuJWnO2fl96Rca00UrLSVMX0yPjsIFlMZ
	MBbu1AxlLrMJtJTdy+ZN9BIrBNI6qceUuENyoe/KfF4WGlL3BU/7gYD4f0zCWNrz
	+65BXwyMGV9DcHPMRuNII9xiZNlSpcNLt15DPwTI3FqGPS3GybV83/IYW20HsUVx
	4dPI2Yfp/ayP5qqtFC7tEgLgO3xIXja0/sGDVxpcA8WZZGYbbpSwBzta575Ap4+S
	6q/EALsdp0J6kMx0YwOriEMC0dzAnKQf/0WJ58mfAZoHFPv45fYtx3ysqn0yjqgj
	RiXvXQ5XK17ovr00uw7daEFUlJffqk+dp+dMcJ7k2EBXe9KXrEhL2UmikDcCLl1N
	czdy60kbs++1Gyne6KMtUCZopthtlY4Dg8uQTvk+JYJY3sTOYX0UgEm4fOrEKtxp
	OJHxb2H9nERBZC9EpkiaYUngoHnUzGT3IokbVHGSUDTSGelpWAYiZ06tEhrYA7L1
	EKvw+T8TSsRUt+DizOHDKAiZS0QlZdQLxmdxYfRfyiKovLD4yjC0v2N/pMaOUP0b
	3ascCdt/GIj1zK/kur8=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 07 Sep 2026 21:37:47 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 31BC76069C;
	Mon,  7 Sep 2026 21:37:48 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 687IblHS112792;
	Mon, 7 Sep 2026 21:37:47 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 687Ibko0112791;
	Mon, 7 Sep 2026 21:37:46 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf] ipvs: revalidate ihl before icmp_send
Date: Mon,  7 Sep 2026 21:37:35 +0300
Message-ID: <20260907183735.112779-1-ja@ssi.bg>
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
reading them from the skb frags to prevent out-of-bounds
access.

One such place reported by Sashiko is ip_vs_in_icmp() where
local process can change the ihl field and after
pskb_may_pull() we can see larger value which is a problem
for the icmp_send() call.

Add check to drop the packet if the ihl field is changed and
make sure the transport header is updated.

Also, provide correct protocol to ipv4_update_pmtu().

Fixes: 7fcc2fe39fed ("net: icmp: avoid invalid transport header access in icmp_send tracepoint")
Fixes: f2edb9f7706d ("ipvs: implement passive PMTUD for IPIP packets")
Link: https://sashiko.dev/#/patchset/20260806105211.34622-1-ja%40ssi.bg
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_core.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 1a0661d19d9f..de6ae759cb29 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1935,7 +1935,8 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 			IP_VS_DBG(12, "ICMP for %s %pI4->%pI4: mtu=%u\n",
 				  outer_proto, &ip_hdr(skb)->saddr,
 				  &ip_hdr(skb)->daddr, mtu);
-			ipv4_update_pmtu(skb, ipvs->net, mtu, 0, 0);
+			ipv4_update_pmtu(skb, ipvs->net, mtu, 0,
+					 ip_hdr(skb)->protocol);
 			/* Client uses PMTUD? */
 			if (!(frag_off & htons(IP_DF)))
 				goto ignore_tunnel;
@@ -1960,6 +1961,12 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
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


