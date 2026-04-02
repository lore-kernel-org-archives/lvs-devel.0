Received: from out162-62-57-137.mail.qq.com (out162-62-57-137.mail.qq.com [162.62.57.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EE425314B6A;
	Thu,  2 Apr 2026 14:46:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=162.62.57.137
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775141211; cv=none; b=RPgttQ2+ndi54rUNMRDg5SeN4Z16E6qZM3sF77T79yxUgtHe/XvEFIznsnR9PqnCy1BcxXFhAuj6v87BgPNtWmH0EpqPUrj8dInmSZ1JkazrorvHxZ4y1CbSlyRb9UEv1coRP/OFtoCidjMBO/zJ1nSqZ7+RP3tua/mJ9Ht+duE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775141211; c=relaxed/simple;
	bh=FQHo6U9VEoZMugXQr0YOzn6Rm9Cu5lBl/ry6GmnS8YI=;
	h=Message-ID:From:To:Cc:Subject:Date:MIME-Version; b=SwMveA7fGxJxSpdgyEdHJUEfx74B9jhIhbNfv3n5SnSLPKOu5R3F4GILOUgcKKyQlQcgs7YQIBAcK8/goirDBwffvAVWmTI0znfiuJpUv6LKKXb74N9EuIWSCQp6wzfGzkreaBmlcrMtjN/bt5yxWIDnmBQlBwe3ChjONIBQWvo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=qq.com; spf=pass smtp.mailfrom=qq.com; dkim=pass (1024-bit key) header.d=qq.com header.i=@qq.com header.b=zoqgMluG; arc=none smtp.client-ip=162.62.57.137
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=qq.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=qq.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=qq.com header.i=@qq.com header.b="zoqgMluG"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=qq.com; s=s201512;
	t=1775141203; bh=lOqkosB1cy8FAZlTKkIIXR4ABmZ8edQgswyaTcSUgEg=;
	h=From:To:Cc:Subject:Date;
	b=zoqgMluGHAZSMKUF6kJ2193MDgkFlQR1d3PrcuAXXR+kj8RS0U+6837r0Fpd4zQnQ
	 gryHGKgOKZpoDWA+6Aq3Nhi6on5GnUgmcypPF/DIY60ANFzXe1LupOIZmTCFZ9E8si
	 Tjox3VBWUEvYYMzJhuXpnuqwcWaOu2Nvsx/j5T5I=
Received: from CGG7X9MGDG.corp.ebay.com ([216.113.165.51])
	by newxmesmtplogicsvrsza63-0.qq.com (NewEsmtp) with SMTP
	id B93814B2; Thu, 02 Apr 2026 22:46:19 +0800
X-QQ-mid: xmsmtpt1775141179te7ao89w8
Message-ID: <tencent_73010FBD5FA1C05C3BC23A07A50B11CEC90A@qq.com>
X-QQ-XMAILINFO: MEDSETqIY7u4C1UcUwfTjaOD1C7TOZh+316zk7NiEpZe+6lJyBd1dHEKCRTwoL
	 kYce6S30ORgrYiGhHmOvVhaOYWxlRdW5e1GEgNZ44rjVK69MHT9neMZd9VXQpls1O8tJRVZc/bIe
	 Zj8ORqpX3zGXgakDEk1fqKIBl6jGKIntlKMNGsgOZgTnSlxOZOrVg/1cnX5GxUQ+1rKNwgr+liXt
	 GONW6vGP72zxABES6Yk/ClZLgVyJepAy8QpTeuT3Y+4/yIOjfJSErgIvXEZ8/6WGGD/N0K17lG5n
	 NToL2WsjeiwyrONDR85bEQeOOpvyWmXBvttFtuhptCKTjFDpQqr06Qhwgd0N2/hXYZaLOk9sSTrf
	 /QLmaY/T/kGsBXtkTj7n+sPlxQbfJ16/3oURoNWobPXBamlPI2TTBZo0OvLrlmjGvoT7yhVU3EA6
	 Yj6aAyxscdsSDTaTEKB57asp35F3m5caves50HW1qBTDoYBeMGqE9rgjHT5nlrRyKFaZJ059/90h
	 f1U3/NB9Cn6fimPhVoQ4GxRQLvkPCfEnsgRpUm+hcUmXcIQz8oMjT79295agIn6UrKBgVuOkLezS
	 pqPMU2Cp98kCnHZRm+c0L75Ss1B+8I1PDlDMPdsap5DXuEunlPA8yJ+FZpRz2om7DmDLdW0ijmoR
	 6qKXoriCJ7KcZ14vpLbYauDdTenxSlkxk0VtVT1dhmFJA6dGZx2N1P54kuWp4qE2zZp0mINlJo+C
	 RwI0blfPZDKm/4+sapu1y7E869T2gmC6dLGGjzKu4Xo+fA8rTho3E/cI9k2Ozuu3Jkx93VhSRm83
	 lpSBY3/rSxVNgkTDJPrsGnrtj03tnMgnDjLB529hMHxocYp0Q9WiSMrxdbctD47BmOiWiDgx+/Jl
	 W5V6cs8NUqsyKB3IOVn7j2Zw6WIbgpQpNedor+9bS3ZSpEWju7ge784qNpnLWJtLVEEAhkSLINpy
	 MzUYTtOgPSKH2AqmpaKqkV2mIe5Ty5SF88jzOtiP9MpsZdrQn/gUT8E4O4mLX/ZwTI51Pmvof0kv
	 8hN7n/jyVCN5vzVjcWtiFKgYz8A3VsQlA1MYOk0wjLssPX5ieshhi241+eJNbT7ot+Efzyn3CskS
	 CArUz1
X-QQ-XMRINFO: M/715EihBoGS47X28/vv4NpnfpeBLnr4Qg==
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
Subject: [PATCH net v3] ipvs: fix MTU check for GSO packets in tunnel mode
Date: Thu,  2 Apr 2026 22:46:16 +0800
X-OQ-MSGID: <20260402144616.53289-1-342144303@qq.com>
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

Fix this by properly validating GSO packets using
skb_gso_validate_network_len(). This function correctly validates
whether the GSO segments will fit within the MTU after segmentation. If
validation fails, send an ICMP Fragmentation Needed message to enable
proper PMTU discovery.

Fixes: 4cdd34084d53 ("netfilter: nf_conntrack_ipv6: improve fragmentation handling")
Signed-off-by: Yingnan Zhang <342144303@qq.com>
---
v3:
- Fixed compilation error (removed extra closing brace in IPv6 function)
- Fixed indentation to match kernel style

v2: https://lore.kernel.org/netdev/20260402030541.27855-1-342144303@qq.com/
v1: https://lore.kernel.org/netdev/20260401152228.31190-1-342144303@qq.com/
---
 net/netfilter/ipvs/ip_vs_xmit.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 3601eb86d..a4ca7cad0 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -111,8 +111,8 @@ __mtu_check_toobig_v6(const struct sk_buff *skb, u32 mtu)
 		 */
 		if (IP6CB(skb)->frag_max_size > mtu)
 			return true; /* largest fragment violate MTU */
-	}
-	else if (skb->len > mtu && !skb_is_gso(skb)) {
+	} else if (skb->len > mtu &&
+		   !(skb_is_gso(skb) && skb_gso_validate_network_len(skb, mtu))) {
 		return true; /* Packet size violate MTU size */
 	}
 	return false;
@@ -232,8 +232,9 @@ static inline bool ensure_mtu_is_adequate(struct netns_ipvs *ipvs, int skb_af,
 			return true;
 
 		if (unlikely(ip_hdr(skb)->frag_off & htons(IP_DF) &&
-			     skb->len > mtu && !skb_is_gso(skb) &&
-			     !ip_vs_iph_icmp(ipvsh))) {
+			     skb->len > mtu && !ip_vs_iph_icmp(ipvsh) &&
+			     !(skb_is_gso(skb) &&
+			       skb_gso_validate_network_len(skb, mtu)))) {
 			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 				  htonl(mtu));
 			IP_VS_DBG(1, "frag needed for %pI4\n",
-- 
2.51.0

