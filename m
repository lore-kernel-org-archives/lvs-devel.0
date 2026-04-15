Received: from out162-62-57-49.mail.qq.com (out162-62-57-49.mail.qq.com [162.62.57.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 079CF34A78F;
	Wed, 15 Apr 2026 14:41:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=162.62.57.49
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776264083; cv=none; b=Hwmu+4pMCgOlebdLvQF5QX/HcXIbLdQxAJ2CdQ8m19Ro/MvGvs/IWDWYJ9MFiYjp6bbyVJSd4uzoRRcV1wcwwXSzB6GuPMztQOOuVrvK0bEw7J36x6PqW2VHMvanHAHY2lMZA50qF12iukZHkyxLK+iUtvhQq1mH8phJ84J86V8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776264083; c=relaxed/simple;
	bh=NLdFmBcpcThoyIQcsmRJNRdMjiBLR4JkAP3J1LwUNLI=;
	h=Message-ID:From:To:Cc:Subject:Date:MIME-Version; b=aUrqZFqb6ZPsHe0onVX+fpOrkO/h/ppBTkIL1lRXUIMIpLsM09p76cpRqd6VRSy95rWAWe7X0P1SvMQMb1quYTnUfFFIUAOM1Vl2/6aej+EmeOAb4fcSsOLHqSu7yGdL5wJyYAF9kijLhu5MFQWKLmRIV3HfbXr+QYW8p5WJMuc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=qq.com; spf=pass smtp.mailfrom=qq.com; dkim=pass (1024-bit key) header.d=qq.com header.i=@qq.com header.b=M27oVr6C; arc=none smtp.client-ip=162.62.57.49
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=qq.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=qq.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=qq.com header.i=@qq.com header.b="M27oVr6C"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=qq.com; s=s201512;
	t=1776264070; bh=ccKpOWW8f06p267HUyKJnI4zbqOhJE6jpn/wLRRikCE=;
	h=From:To:Cc:Subject:Date;
	b=M27oVr6CBoNlysvkipCuzUimTEwpVug8SWmbz72HGcC1onmG7u8etub4oCDXgrOb0
	 cPXuqARnNw9xjVwetIr7NLydT4mAqVfDcvLqilNqY8zojR9q94YPH2+3ClYnKUipQD
	 eH+G0AvBcKypMxBLDI6Fp2kK5KjER3Z0kxpggKtE=
Received: from Lego ([2409:8a1e:9553:b2d0:d44a:f28c:2e52:3bf6])
	by newxmesmtplogicsvrszb51-0.qq.com (NewEsmtp) with SMTP
	id A44AA2FE; Wed, 15 Apr 2026 22:41:04 +0800
X-QQ-mid: xmsmtpt1776264064ts5m2jgd8
Message-ID: <tencent_7F7B107ECA750C095D05C19C3B723AFFA60A@qq.com>
X-QQ-XMAILINFO: NAuAIaytDrXpIaFOVq8MbWxJeDYlYBG7iDbjLUP6zeQpSH4AXQJW/jyXiHC//d
	 2Ru48s7GIF7Sr3foIe7x32/NA2gp+B6zHnNHWOFyr9bXdz3+7QbqEqKa/xzUiLynD6Sey+fZxUFD
	 D7beR6o/Kvxsowq0ZjXhjULVujUzPOb4AhC7jWFEvfswRNCEdbheepAD2/p63LDt2yWn0lRhGbMD
	 cPHNEYMHgU1jBomBdOqpnFurmD/dsCT/nftrXNUymSjN8gO5GOZD4T6WS5NNCn6117WCQnAHQfCx
	 x2L7Iy4ieinaRE4S8iH7BYv8HTdTCiR2H+kyp72jzmh1a+ZDd3oi+bfrBwvubfuJgs4tvDDCPWoE
	 oly7SoJ/Z4CvZJV5YyBgvCFgzTGbQtw5OVHZVxsMpbfZc2LYmcuAIgcD5fH8n2PpKqKyuTGIrb5X
	 fNxDunRcicX6CigjksoeXG1/F1jyV+1Z+78QGSVYaB9v7cmN2l/hy+tMZ5GsHaSUzW4Zax7zwnuw
	 y4lNHJ/nuYox9r0JUeQDUusu31YJ3OzoAOwfYPaVLlMds2puvMreF+b/bpjDaYFSD01UzWVRZIPe
	 DShIo3FjDlmdUmkaCrLiJ2YkDK4CHhkQ9v0QemF+TLh+oQHd5eLzvcNRwJ3FKr29ReCXGPDZufn5
	 MNq1tFCJiKR6Epi1ww04Mi3ZnbmwMl91UIff2ABLmGqLWUxSj6HUHZBB+43RwVP1/z1DQBkEHXYx
	 qVQvsBnSpqGQnWIg4keBn7Pao7yw2VDxX0w8ARinj6AUhRPxba9v8bKrYRkunGoRCR77CHRHjygU
	 cNtYCLZGu7kw9Lq++QjxyzVvTEWAqdm3Jv0M0taw/0s4TMiRL/CUAweeJ2qD8wetY4uJATKsc9Va
	 LjZ3LQVtyKax5S375gqi//sjcoxmF4CSYOqhHAUj7H9+PU0z68OSsfgZQCCW6DXa1MfJicgvTyoA
	 C+v82iTBHHmq4yGMGGdSU4tKXtFrHj8VufsllNGc5TmC3I87xzEO0pvh48+odjEYMJiuyMwCAixG
	 ndy4C3uiuNX/xMurzceEmDXp9hEnPYVp5t3c2pb7nM5Boz8UVm
X-QQ-XMRINFO: MPJ6Tf5t3I/ylTmHUqvI8+Wpn+Gzalws3A==
From: Yingnan Zhang <342144303@qq.com>
To: ja@ssi.bg,
	pablo@netfilter.org
Cc: coreteam@netfilter.org,
	davem@davemloft.net,
	edumazet@google.com,
	fw@strlen.de,
	horms@verge.net.au,
	kuba@kernel.org,
	linux-kernel@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	pabeni@redhat.com,
	phil@nwl.cc,
	Yingnan Zhang <342144303@qq.com>
Subject: [PATCH net v4] ipvs: fix MTU check for GSO packets in tunnel mode
Date: Wed, 15 Apr 2026 22:40:29 +0800
X-OQ-MSGID: <20260415144030.531-1-342144303@qq.com>
X-Mailer: git-send-email 2.51.0.windows.1
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

Fix this by properly validating GSO packets using
skb_gso_validate_network_len(). This function correctly validates
whether the GSO segments will fit within the MTU after segmentation. If
validation fails, send an ICMP Fragmentation Needed message to enable
proper PMTU discovery.

Fixes: 4cdd34084d53 ("netfilter: nf_conntrack_ipv6: improve fragmentation handling")
Signed-off-by: Yingnan Zhang <342144303@qq.com>

---
v4:
- Introduce a new helper function ip_vs_exceeds_mtu() to improve readability (reviewer feedback)

v3: https://lore.kernel.org/netdev/tencent_73010FBD5FA1C05C3BC23A07A50B11CEC90A@qq.com/
v2: https://lore.kernel.org/netdev/tencent_CA2C1C219C99D315086BE55E8654AF7E6009@qq.com/
v1: https://lore.kernel.org/netdev/tencent_4A3E1C339C75D359093BE4F08648AFAA6009@qq.com/
---
---
 net/netfilter/ipvs/ip_vs_xmit.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 0fb5162992e5..64dfdf8b00c4 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -102,6 +102,18 @@ __ip_vs_dst_check(struct ip_vs_dest *dest)
 	return dest_dst;
 }
 
+/* Based on ip_exceeds_mtu(). */
+static bool ip_vs_exceeds_mtu(const struct sk_buff *skb, unsigned int mtu)
+{
+	if (skb->len <= mtu)
+		return false;
+
+	if (skb_is_gso(skb) && skb_gso_validate_network_len(skb, mtu))
+		return false;
+
+	return true;
+}
+
 static inline bool
 __mtu_check_toobig_v6(const struct sk_buff *skb, u32 mtu)
 {
@@ -112,7 +124,7 @@ __mtu_check_toobig_v6(const struct sk_buff *skb, u32 mtu)
 		if (IP6CB(skb)->frag_max_size > mtu)
 			return true; /* largest fragment violate MTU */
 	}
-	else if (skb->len > mtu && !skb_is_gso(skb)) {
+	else if (ip_vs_exceeds_mtu(skb, mtu)) {
 		return true; /* Packet size violate MTU size */
 	}
 	return false;
@@ -232,7 +244,7 @@ static inline bool ensure_mtu_is_adequate(struct netns_ipvs *ipvs, int skb_af,
 			return true;
 
 		if (unlikely(ip_hdr(skb)->frag_off & htons(IP_DF) &&
-			     skb->len > mtu && !skb_is_gso(skb) &&
+			     ip_vs_exceeds_mtu(skb, mtu) &&
 			     !ip_vs_iph_icmp(ipvsh))) {
 			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 				  htonl(mtu));
-- 
2.51.0.windows.1

