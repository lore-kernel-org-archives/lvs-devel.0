Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D406E3DFC78;
	Wed, 15 Apr 2026 15:35:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776267340; cv=none; b=eA4Qv39ZiEKNYtHB9akUbcz/Iwn/zzY8NxWRoCP8GfsoJwgiHQF1EXe9S+kkEo57YRlzBDXnzqypeKkI1AnRnW6Rq561RXJ4EBxnURw1BD0Gv8B0SNjd338gbkpP1oJkiYb6YN50uaMp0AyUCdP3/Mj7q/CF+raGgdkdWo3zj8s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776267340; c=relaxed/simple;
	bh=PSHo872UTpSY7Pd7+/Sgn/7YWlvCJs+jK6EXZQzMhfY=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=p+8nI0uuHGY0afAprBdykRZJdpGf6FN9T9I5oZWm8wdyOq4MUXQMcqhNTQjpCiL16HxeHiNlnDhP8ov7pCoarUR6HIDpYrTMQjTx3PeFIY/IBWtEa8NyDzhWYyRRDe1tnqrBCEz3PIthEqRvlf4TD14eN15TY+LZDI/HiW1EGQo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=UVO4X2mZ; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="UVO4X2mZ"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 236FC21107;
	Wed, 15 Apr 2026 18:35:19 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=OUQKghrpmJGe/+qFiqhRsCk1OBnY75g47ZnibPNkAnc=; b=UVO4X2mZF2We
	YVrfnNa0vWaQN0olivm7j5OAMUwiElxHCRXUs94wj/4nEx8wilxOmesQp8Bt7xy5
	lwXre+RBqyqO8oS1NJ+VSQwsT6YVHT5AW/mFKB0gjXjEkYByMhUabrdVbAo4+aHJ
	AQauZbAAdazl0pLxlZg7fVDEbVrWPvuI7sEUF561IVThPDhqb4B/VgjO22eJ737A
	PWQ5XCfeVzcAvLNl3NMwX5BjO8eeVr9vD/hV5YL8Ai3Z/ZZOx+FoIOTxydpdoOL+
	t28e2pWuBHw38a7NzSVIBKL6EQ9q0uk+9LSXR1/2Hv6SeucZivtIDhU0tgcOikFT
	BcugsptzPtDh2XGFByYPN5yrOHJzn3W0M7hrmwZ9MqIJJYgqufD40+Ic6724CIYg
	sj6inbLzVWyMbPbLWrnzGJHZSDQyHJtS8E3Y935SlerFqYYu+SeRX4TI9GwL7VU3
	mCsr2qt3dIkVlc/zWj5dLdH3FXl0vEhObLI0qQLvHIgVYomIR/PxbBOItn5plr+q
	sh2RsTHxzb227gSg/94ioFntkUpeRtrIfjMaR31bDSdmf2G8uHYdL3D2U+9r2Pi7
	dE+3lAqfuW1qIZUeE+/4CFUZZ2GRqf2TQ/zeDTO9Tp0cOB1U1xAuyRInFJkgD5rB
	6QgjYmtva8tB115e2VMj/4X43HCf+Xw=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 15 Apr 2026 18:35:17 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 450DF608CD;
	Wed, 15 Apr 2026 18:35:15 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63FFZ3hV058241;
	Wed, 15 Apr 2026 18:35:04 +0300
Date: Wed, 15 Apr 2026 18:35:03 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Yingnan Zhang <342144303@qq.com>
cc: pablo@netfilter.org, coreteam@netfilter.org, davem@davemloft.net,
        edumazet@google.com, fw@strlen.de, horms@verge.net.au, kuba@kernel.org,
        linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org,
        netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        pabeni@redhat.com, phil@nwl.cc
Subject: Re: [PATCH net v4] ipvs: fix MTU check for GSO packets in tunnel
 mode
In-Reply-To: <tencent_7F7B107ECA750C095D05C19C3B723AFFA60A@qq.com>
Message-ID: <72814fe9-7abc-111e-6142-d2f3455aa220@ssi.bg>
References: <tencent_7F7B107ECA750C095D05C19C3B723AFFA60A@qq.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Wed, 15 Apr 2026, Yingnan Zhang wrote:

> Currently, IPVS skips MTU checks for GSO packets by excluding them with
> the !skb_is_gso(skb) condition. This creates problems when IPVS tunnel
> mode encapsulates GSO packets with IPIP headers.
> 
> The issue manifests in two ways:
> 
> 1. MTU violation after encapsulation:
>    When a GSO packet passes through IPVS tunnel mode, the original MTU
>    check is bypassed. After adding the IPIP tunnel header, the packet
>    size may exceed the outgoing interface MTU, leading to unexpected
>    fragmentation at the IP layer.
> 
> 2. Fragmentation with problematic IP IDs:
>    When net.ipv4.vs.pmtu_disc=1 and a GSO packet with multiple segments
>    is fragmented after encapsulation, each segment gets a sequentially
>    incremented IP ID (0, 1, 2, ...). This happens because:
> 
>    a) The GSO packet bypasses MTU check and gets encapsulated
>    b) At __ip_finish_output, the oversized GSO packet is split into
>       separate SKBs (one per segment), with IP IDs incrementing
>    c) Each SKB is then fragmented again based on the actual MTU
> 
>    This sequential IP ID allocation differs from the expected behavior
>    and can cause issues with fragment reassembly and packet tracking.
> 
> Fix this by properly validating GSO packets using
> skb_gso_validate_network_len(). This function correctly validates
> whether the GSO segments will fit within the MTU after segmentation. If
> validation fails, send an ICMP Fragmentation Needed message to enable
> proper PMTU discovery.
> 
> Fixes: 4cdd34084d53 ("netfilter: nf_conntrack_ipv6: improve fragmentation handling")
> Signed-off-by: Yingnan Zhang <342144303@qq.com>

	Looks good to me for the nf tree, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
> v4:
> - Introduce a new helper function ip_vs_exceeds_mtu() to improve readability (reviewer feedback)
> 
> v3: https://lore.kernel.org/netdev/tencent_73010FBD5FA1C05C3BC23A07A50B11CEC90A@qq.com/
> v2: https://lore.kernel.org/netdev/tencent_CA2C1C219C99D315086BE55E8654AF7E6009@qq.com/
> v1: https://lore.kernel.org/netdev/tencent_4A3E1C339C75D359093BE4F08648AFAA6009@qq.com/
> ---
> ---
>  net/netfilter/ipvs/ip_vs_xmit.c | 16 ++++++++++++++--
>  1 file changed, 14 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 0fb5162992e5..64dfdf8b00c4 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -102,6 +102,18 @@ __ip_vs_dst_check(struct ip_vs_dest *dest)
>  	return dest_dst;
>  }
>  
> +/* Based on ip_exceeds_mtu(). */
> +static bool ip_vs_exceeds_mtu(const struct sk_buff *skb, unsigned int mtu)
> +{
> +	if (skb->len <= mtu)
> +		return false;
> +
> +	if (skb_is_gso(skb) && skb_gso_validate_network_len(skb, mtu))
> +		return false;
> +
> +	return true;
> +}
> +
>  static inline bool
>  __mtu_check_toobig_v6(const struct sk_buff *skb, u32 mtu)
>  {
> @@ -112,7 +124,7 @@ __mtu_check_toobig_v6(const struct sk_buff *skb, u32 mtu)
>  		if (IP6CB(skb)->frag_max_size > mtu)
>  			return true; /* largest fragment violate MTU */
>  	}
> -	else if (skb->len > mtu && !skb_is_gso(skb)) {
> +	else if (ip_vs_exceeds_mtu(skb, mtu)) {
>  		return true; /* Packet size violate MTU size */
>  	}
>  	return false;
> @@ -232,7 +244,7 @@ static inline bool ensure_mtu_is_adequate(struct netns_ipvs *ipvs, int skb_af,
>  			return true;
>  
>  		if (unlikely(ip_hdr(skb)->frag_off & htons(IP_DF) &&
> -			     skb->len > mtu && !skb_is_gso(skb) &&
> +			     ip_vs_exceeds_mtu(skb, mtu) &&
>  			     !ip_vs_iph_icmp(ipvsh))) {
>  			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
>  				  htonl(mtu));
> -- 
> 2.51.0.windows.1

Regards

--
Julian Anastasov <ja@ssi.bg>

