Received: from out162-62-57-87.mail.qq.com (out162-62-57-87.mail.qq.com [162.62.57.87])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 60EA12DB795;
	Wed,  1 Apr 2026 15:39:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=162.62.57.87
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775057981; cv=none; b=BxBaVX4nNrbK22azVIdgu5ZORPNbvPHEKUNsGfbm5U5Ms0jlMGB7sDv2cTidUsWXCW6v4vOJmNhIphsWPRT8SeUoZpLmZdDO0o69zZ7y4+Xgxjy9BDdy0DRIBD/HNO9WM4bXkItso5HRT4hB11IfFE5ZrabfXwoM4pmxmMOgdP0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775057981; c=relaxed/simple;
	bh=Mu6hKdatik9ZMJJtwZgql98CyxOVff4TkwCo1o6/JaU=;
	h=Message-ID:From:To:Cc:Subject:Date:MIME-Version; b=KjgEPnGvn2oKQwgrjtZoHlLKOjejOIZT2R0EXWfvIi31mgpRCehvLhPj3iMngLz3ujponlIRKIvvOfarRgSBYL+q2HAUvFkhcQfU2C8YmfuKaWdjx9rNNk0YdZYbvVPavABSGBioncl0Aow2b0vOE5QI+CFkxAl9YJp43KY0+fA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=qq.com; spf=pass smtp.mailfrom=qq.com; dkim=pass (1024-bit key) header.d=qq.com header.i=@qq.com header.b=x+7tO0Fo; arc=none smtp.client-ip=162.62.57.87
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=qq.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=qq.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=qq.com header.i=@qq.com header.b="x+7tO0Fo"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=qq.com; s=s201512;
	t=1775057967; bh=rWJTDXtf7btF2BKyo9SNlIT4oe/5A/4pOHharg1NEmk=;
	h=From:To:Cc:Subject:Date;
	b=x+7tO0FoLpxjqsY/zR56hqlfGhqT1xUE3QQ1ZIZJRhfFd1loPrac2fAZqM+0CPSHX
	 ntR1MRCBiFMbyC9/RP0Yf6xYeOhbnZgOPdNIyopq4qIwVBfku0aysnapkDmQga5Grr
	 HgrI6n9N/L3/smfoQugDAI4vufiRItPmGMZdKcII=
Received: from CGG7X9MGDG.corp.ebay.com ([216.113.165.51])
	by newxmesmtplogicsvrszb51-1.qq.com (NewEsmtp) with SMTP
	id 9C4B5ED3; Wed, 01 Apr 2026 23:39:04 +0800
X-QQ-mid: xmsmtpt1775057944te0b7xgb9
Message-ID: <tencent_4A3E1C339C75D359093BE4F08648AFAA6009@qq.com>
X-QQ-XMAILINFO: Nx5J06Esz7r7L/P7JjrRw2OQ96/QQu1sjbUpPUf/S8cXgzPtZ2f3uIQXACb/wH
	 tkBJeAETqlzjuQtZCE0raxVeHmg/LJvlmUiZDn/Boir0G+gJ3OlTulAoVCT6QO7DtdodPaajMaKg
	 D5wGUhVZyYLbOTN7VE+nuLm1ZKHVOXANNAW6iGarRWoeVBz4qee0/yT+E3jw/G9nU7GJAT0v5E32
	 pfk9IW+EWV24WJmHsYceb/lYWrqXPxEyxsWDl4VvY5LfqAAkX5SR9jAk+hgs13LP8UPTA/XDyAdx
	 6bwbi0bTHLCZJcSD8kx6Z3HSiyCSUrrUCpMgj5aTq6MkZIY8DiUkhWPiM4U3kiyGYP+PHt078GP/
	 kcKCbfIaIEiVTRdyXPQUdLkQt6TshFYagr01HY34NIZrX/X57T0NuKwAIS4iiTPUIWslSaXetyLJ
	 ytole5zgpB7SEKs4ntKkG6BTMPkOcDu4MdJmDjib3Ow0/vg3xsJmscXucSMZ4o0PB491CNqJ2Y50
	 QMqUv8pkNrWm5TT0TCyetLKVjPwgl3zidyxwWJI/PuNsjz6oDSPxpkMlpFswhikn9ZlmBJjCGWRL
	 x9V0qyMckigOAn+pQxtiXVUW8+Kjwkoi+aay8v1LzP/8T7N/A8WjfzfZPN3B5fCP84SW+Geaf0Cx
	 Bd7SMYRb+mn7WuKcnEZ/hK9tislZgKNIyjfOQHVCnzKxyzn/9xQKS2FpPex90ADwcO1gHaBe7kxR
	 L53clAF12YSHsSfazgbcCwq3TH4LUB/2WKjmn3g3I7A0dHnlY2TlH4k8fgCnVXBMXoDnlBztkOfN
	 HZm/vl1LlFMCV/QnM2bkenDwQUusjIZIviVjCxj0M/vYPsrI0NmVu8vYZ4z+DHOrmWBtfU03vVRy
	 S8x5Km4lqWhFJj3CWBcAYoif1OQYHuNVd+ZOMb+1ZTalNALCNPzN4nktswa6+FWM25GCXCrpl+0O
	 NniofjFa+TWNOHuYtshq5e8sHmwq507U7ZOcGzr+2+0uRJvymYHpKz73t4YWj+
X-QQ-XMRINFO: Mp0Kj//9VHAxzExpfF+O8yhSrljjwrznVg==
From: Yingnan Zhang <342144303@qq.com>
To: horms@verge.net.au,
	ja@ssi.bg
Cc: pablo@netfilter.org,
	fw@strlen.de,
	phil@nwl.cc,
	davem@davemloft.net,
	edumazet@google.com,
	kuba@kernel.org,
	pabeni@redhat.com,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	linux-kernel@vger.kernel.org,
	Yingnan Zhang <342144303@qq.com>
Subject: [PATCH net] ipvs: fix MTU check for GSO packets in tunnel mode
Date: Wed,  1 Apr 2026 23:38:57 +0800
X-OQ-MSGID: <20260401153857.31562-1-342144303@qq.com>
X-Mailer: git-send-email 2.51.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Currently, IPVS skips MTU checks for GSO packets by excluding them with
the !skb_is_gso(skb) condition. This creates problems when IPVS tunnel
mode encapsulates GSO packets with IPIP headers.

The issue manifests in two ways:

1. MTU violation after encapsulation:
   When a GSO packet passes through IPVS tunnel mode, the original MTU
   check is bypassed. After adding the IPIP tunnel header, the packet
   size may exceed the outgoing interface MTU, leading to unexpected
   fragmentation at the IP layer.

2. Fragmentation with problematic IP IDs:
   When net.ipv4.vs.pmtu_disc=1 and a GSO packet with multiple segments
   is fragmented after encapsulation, each segment gets a sequentially
   incremented IP ID (0, 1, 2, ...). This happens because:

   a) The GSO packet bypasses MTU check and gets encapsulated
   b) At __ip_finish_output, the oversized GSO packet is split into
      separate SKBs (one per segment), with IP IDs incrementing
   c) Each SKB is then fragmented again based on the actual MTU

   This sequential IP ID allocation differs from the expected behavior
   and can cause issues with fragment reassembly and packet tracking.

Fix this by removing the GSO packet exception from the MTU check and
properly validating GSO packets using skb_gso_validate_network_len().
This function correctly validates whether the GSO segments will fit
within the MTU after segmentation. If validation fails, send an ICMP
Fragmentation Needed message to enable proper PMTU discovery.

Fixes: 4cdd34084d53 ("netfilter: nf_conntrack_ipv6: improve fragmentation handling")
Signed-off-by: Yingnan Zhang <342144303@qq.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 3601eb86d..82f2e7a32 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -232,8 +232,15 @@ static inline bool ensure_mtu_is_adequate(struct netns_ipvs *ipvs, int skb_af,
 			return true;
 
 		if (unlikely(ip_hdr(skb)->frag_off & htons(IP_DF) &&
-			     skb->len > mtu && !skb_is_gso(skb) &&
+			     skb->len > mtu &&
 			     !ip_vs_iph_icmp(ipvsh))) {
+			if (skb_is_gso(skb)) {
+				if (skb_gso_validate_network_len(skb, mtu))
+					return true;
+				icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
+				IP_VS_DBG(1, "frag needed for %pI4\n", &ip_hdr(skb)->saddr);
+				return false;
+			}
 			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 				  htonl(mtu));
 			IP_VS_DBG(1, "frag needed for %pI4\n",
-- 
2.51.0

