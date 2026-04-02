Received: from out162-62-57-64.mail.qq.com (out162-62-57-64.mail.qq.com [162.62.57.64])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2EB11363C58;
	Thu,  2 Apr 2026 12:09:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=162.62.57.64
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775131773; cv=none; b=BbVNZbX3hkFE/z3K+EsOecvpButU2FoMb5FuD5sB6oVTDqxmJ89Xtgs8PzsMWKVFFgotF4bpBMTkP6z1vhfvGdpMXCGD+pjRcoAM36dJyPq8jKFdXkW3bWyuIDvhq3dp6IHo0Mc/qyMvW6OCTRoyw2n/v4C/6r3bLy3LsVWo7Qw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775131773; c=relaxed/simple;
	bh=b+9L5LQLOhav8R2arLAKnEpdDRfvsoNAdIw1w5wHpFQ=;
	h=Message-ID:From:To:Cc:Subject:Date:MIME-Version; b=f/bvwD0wGtjg2oHR90Y/I96isCgGwklABA53JR0jpmZ3L/qtH3Qz+eFqJwzKZrKKdrLwsorStjMN9r+ljEVceX+eLSHyUZjNC+KY35DPcVQHk72H4Vo8xVRHbX3rfgDYuPSEnvOyTLUM4xZONbdpkkop8lEHvu4U0/T9GmRnWHo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=qq.com; spf=pass smtp.mailfrom=qq.com; dkim=pass (1024-bit key) header.d=qq.com header.i=@qq.com header.b=GdvER3tJ; arc=none smtp.client-ip=162.62.57.64
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=qq.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=qq.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=qq.com header.i=@qq.com header.b="GdvER3tJ"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=qq.com; s=s201512;
	t=1775131760; bh=RmtlHvZOwAie1YTRTwuhFcaBQSJO8/cIioGvkZTYkAQ=;
	h=From:To:Cc:Subject:Date;
	b=GdvER3tJgPktadJ/C2Sj+6nvGUyjpkj3uBQFCOa38PFOV5/m6rqCsCuMBf8PDK4Qj
	 fcGXumyqbdEH9onzKy93+EOH5u+Tf5yXydAyg0NE6dpzyUe2rYHsMGIZUoQGp3z+cB
	 8a0P9j+LegJPdPAB4SH4gvyrOI7FYlb31DWfDrEs=
Received: from CGG7X9MGDG.corp.ebay.com ([216.113.165.51])
	by newxmesmtplogicsvrsza63-0.qq.com (NewEsmtp) with SMTP
	id 2451F248; Thu, 02 Apr 2026 20:09:05 +0800
X-QQ-mid: xmsmtpt1775131745trvi87vni
Message-ID: <tencent_CA2C1C219C99D315086BE55E8654AF7E6009@qq.com>
X-QQ-XMAILINFO: NnBlO8MsmACrsUteY4DPMPgKLxLK4Dw2HrnUpXbtSd7EXOMYELykBPLuHvPjEV
	 j8GwAHDEnuRMlN6+iZksg0YafnLCSCySK+qzG4anB4atJxpkFZlY583XRANwLvOSLkgEteAvggsG
	 9fSg1rlwaN5NROtov1xdVfTDs5SsS4/zjtXuPY+uoilTfqt6s/utfVcZgHoFMp0IoAzCr4lVqqxq
	 1/q/rehsUM2l2dkdy8RA2WEHH+OT7qhj0MbhzSrGH+W3reQQNRLvav5JvMBiXLzWKeF0fw2bY/jq
	 CGW3goyp/BExnzwfMZCQMcVzTBmdesTYRQ+0Fs5t/vrsj8lEPa30ycyB7uHV6Tkg4xO4BrEqlcw7
	 sn1L4f7gJ78dz0eivC28rygpoHo9WBLCurJZ1ZpXmDoGDEjmia5OKYzThKKP8Eb5NwCVreBMqoU9
	 6zngNP4T3wZZkDagZKSJg8uQt6xGCJr5VJN9+32rrRlbcAjmEt5RX9AtPIbS1v214RNqEZDy9BOc
	 /jSCu1kecUYW2tr2Ya6vuXC32e2Ld0+2PgGW1vpJKx6zvuMLnoAxK0tWXSTOVgRX6UVpXyfyOyas
	 nOX8e3cwJ3rf2lTxHNnpq4CQ08tht+/1ZyNZq6Fqy8gNy1YUGZAvWA9OvM5Dz/a4AHwhGvzuT8UH
	 Eq+c9+wZN4epZ4kJjhiPKCfGeqSmgkB+gyVnGTYA2pna8w9E+egCt+3Wsnwh4Lo7pfwVdmYum4vx
	 tnWZ+i4cSTlWdyLXXRjoGOz5Fe/QgKkUKEenqYoGpfDZ61A7gJKeQZU7X7lzQKrLC+c0An0Mb2Fl
	 28Qd8NrCeZF0d8ThMV+1SkLulrshHZN/hlBarcVGKBx0u7GtHxo+52a0mihv/rwNVQMJGaiJ73Un
	 lNBHEwrGPiwMA40fhY9ieX38/15ZfN+t/Gz9SwO8/kwmsOYD0hj/0XKqzSZKNWvGvHNenCwgK3hH
	 9zs3ZgzYu3qF0duukiH2q5cE0lhg/tMBIr9lUUDbe0q+cjZhbeWi1W/oF+pKoipAjjuWhLvJZMOE
	 d3Jp6son2bbPAEl5MqpBQu0DHL5H7EUGuD+E+OIQ==
X-QQ-XMRINFO: Nq+8W0+stu50tPAe92KXseR0ZZmBTk3gLg==
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
Subject: [PATCH net v2] ipvs: fix MTU check for GSO packets in tunnel mode
Date: Thu,  2 Apr 2026 20:09:00 +0800
X-OQ-MSGID: <20260402120900.49778-1-342144303@qq.com>
X-Mailer: git-send-email 2.51.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Currently, IPVS skips MTU checks for GSO packets by excluding them with
the !skb_is_gso(skb) condition in both IPv4 and IPv6 code paths. This
creates problems when IPVS tunnel mode encapsulates GSO packets with
IPIP or IPv6 tunnel headers.

The issue manifests in two ways:

1. MTU violation after encapsulation:
   When a GSO packet passes through IPVS tunnel mode, the original MTU
   check is bypassed. After adding the tunnel header, the packet size
   may exceed the outgoing interface MTU, leading to unexpected
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

Fix this by removing the GSO packet exception from the MTU check in both
IPv4 and IPv6 paths, and properly validating GSO packets using
skb_gso_validate_network_len(). The condition is refactored to avoid
code duplication.

Fixes: 4cdd34084d53 ("netfilter: nf_conntrack_ipv6: improve fragmentation handling")
Signed-off-by: Yingnan Zhang <342144303@qq.com>
---
Changes in v2:
- Added IPv6 fix in __mtu_check_toobig_v6() per Julian's review
- Refactored to avoid code duplication per Julian's suggestion
- Applied same validation pattern to both IPv4 and IPv6 paths

v1: https://lore.kernel.org/netdev/20260401152228.31190-1-342144303@qq.com/

 net/netfilter/ipvs/ip_vs_xmit.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 3601eb86d..ac2ad7518 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -112,7 +112,8 @@ __mtu_check_toobig_v6(const struct sk_buff *skb, u32 mtu)
 		if (IP6CB(skb)->frag_max_size > mtu)
 			return true; /* largest fragment violate MTU */
 	}
-	else if (skb->len > mtu && !skb_is_gso(skb)) {
+	} else if (skb->len > mtu &&
+		   !(skb_is_gso(skb) && skb_gso_validate_network_len(skb, mtu))) {
 		return true; /* Packet size violate MTU size */
 	}
 	return false;
@@ -232,8 +233,9 @@ static inline bool ensure_mtu_is_adequate(struct netns_ipvs *ipvs, int skb_af,
 			return true;
 
 		if (unlikely(ip_hdr(skb)->frag_off & htons(IP_DF) &&
-			     skb->len > mtu && !skb_is_gso(skb) &&
-			     !ip_vs_iph_icmp(ipvsh))) {
+		     skb->len > mtu && !ip_vs_iph_icmp(ipvsh) &&
+		     !(skb_is_gso(skb) &&
+		       skb_gso_validate_network_len(skb, mtu)))) {
 			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 				  htonl(mtu));
 			IP_VS_DBG(1, "frag needed for %pI4\n",
-- 
2.51.0

