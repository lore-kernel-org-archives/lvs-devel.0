Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C61CB346AD6;
	Fri,  3 Apr 2026 14:20:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775226059; cv=none; b=RmtcYryuCcB9svlfaxy20EejiroaZhHyBM35luuR0x/4AnWxS3jVoYygsDKg+77xVjWNsUmt9AJOcBvvKiA0CMBBQ2G/oBy9TMtpwdES0tu/cYM5e0LLXUugCdhq1nsRtD57/q4r0pX7TNekZD/bSD5Ia0LRHAOmNkmt78O5qMo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775226059; c=relaxed/simple;
	bh=0V4h/5aTxZCmeKMm6XGQjdOuXtv/j7qdwVdMoh8vWpM=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=l05Ajz6Jmn2D/Hx9VekNWV8MFJYK+Cp6m5ce6W9d4kahdv5NC97Rlf11sfe/EArRXS2iZQdelv4do62NhSJy6BImA58Gz8lFL197MqsnikFMKtv8ep+ZGcCdeQlRoZQWg5Q8Y5Xufeeli0K/YA0+ZtkHLXpMSvDNs630AoZzByg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=azT2dpY9; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="azT2dpY9"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id E9B5621C55;
	Fri, 03 Apr 2026 17:20:54 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=3WfIBvLHzi2xCqibDwh64TIeSYwy5tR6pEXljcbdkQU=; b=azT2dpY93qJA
	jvMFsjDZwoiqJrp/rXA12/2pZc1P4ixfOKl7fKCVW27i7MLu8JcnSzflQQA1c5xu
	pdUj6FX4P6Tqa/MRT5XDzkf5t3qQvxHJ530lH/uuqA6IKQVlhqrymIV3zrBabW8I
	2TdPEcGyJ8hzKlzx1cvSiDQcrHu7sGUNpKioOm46AhugyC4fGFfyJH3BiAA4aKCJ
	PkkvQTyFMrUBGif9814wYQkoSN94ZpM/6Qk9BnTQPIjb1fYewQNQCEisz3S//bGq
	gPmRT2+QAMSOWVsjCFd7CPOn+i/XqAwMNetHuHlHQYBhjMuf936vCQDAobcFZBzq
	U709n373eJ5LZQMqU/AMJDyup/u0Ua+z+vcuHts9nO5if+UuUoyD5TXwIqKyGXaJ
	qHiWomyYaOHlERV0d1Th9doHocd3BcZtjYs+NGHg5SjHsQGcVoqYY35FcdQdny/X
	df7ze+iblpSFX4FCnAaiDmnpGp1Zuz/jJk9tbndTneuNc34kKJjjDbyOgpdgI1Vt
	vd2iOZ1WaZm0suQvo07hVFuDwNNhC062eOrJwhu/VGp80s0F4Ib8tvGTIqU7fLRY
	/CnV9cwjZOiKEqFGwVZ7jTv52JJ9ZaTC4+I2HDpLCj63ROh3BNjdCUmbLAhmooLi
	MJB3j7BYI8hQlyLgyJ0ZO45k6Yiugz8=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 03 Apr 2026 17:20:53 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 4D3A4609FA;
	Fri,  3 Apr 2026 17:20:53 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 633EKoo7036674;
	Fri, 3 Apr 2026 17:20:52 +0300
Date: Fri, 3 Apr 2026 17:20:50 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Yingnan Zhang <342144303@qq.com>
cc: horms@verge.net.au, pablo@netfilter.org, fw@strlen.de, phil@nwl.cc,
        davem@davemloft.net, edumazet@google.com, kuba@kernel.org,
        pabeni@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH net v3] ipvs: fix MTU check for GSO packets in tunnel
 mode
In-Reply-To: <tencent_73010FBD5FA1C05C3BC23A07A50B11CEC90A@qq.com>
Message-ID: <7a4ae8da-744e-3729-91aa-d91aaa903c9b@ssi.bg>
References: <tencent_73010FBD5FA1C05C3BC23A07A50B11CEC90A@qq.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Thu, 2 Apr 2026, Yingnan Zhang wrote:

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
> v3:
> - Fixed compilation error (removed extra closing brace in IPv6 function)
> - Fixed indentation to match kernel style
> 
> v2: https://lore.kernel.org/netdev/20260402030541.27855-1-342144303@qq.com/
> v1: https://lore.kernel.org/netdev/20260401152228.31190-1-342144303@qq.com/
> ---
>  net/netfilter/ipvs/ip_vs_xmit.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 3601eb86d..a4ca7cad0 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -111,8 +111,8 @@ __mtu_check_toobig_v6(const struct sk_buff *skb, u32 mtu)
>  		 */
>  		if (IP6CB(skb)->frag_max_size > mtu)
>  			return true; /* largest fragment violate MTU */
> -	}
> -	else if (skb->len > mtu && !skb_is_gso(skb)) {
> +	} else if (skb->len > mtu &&
> +		   !(skb_is_gso(skb) && skb_gso_validate_network_len(skb, mtu))) {
>  		return true; /* Packet size violate MTU size */
>  	}
>  	return false;
> @@ -232,8 +232,9 @@ static inline bool ensure_mtu_is_adequate(struct netns_ipvs *ipvs, int skb_af,
>  			return true;
>  
>  		if (unlikely(ip_hdr(skb)->frag_off & htons(IP_DF) &&
> -			     skb->len > mtu && !skb_is_gso(skb) &&
> -			     !ip_vs_iph_icmp(ipvsh))) {
> +			     skb->len > mtu && !ip_vs_iph_icmp(ipvsh) &&
> +			     !(skb_is_gso(skb) &&
> +			       skb_gso_validate_network_len(skb, mtu)))) {
>  			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
>  				  htonl(mtu));
>  			IP_VS_DBG(1, "frag needed for %pI4\n",
> -- 
> 2.51.0

Regards

--
Julian Anastasov <ja@ssi.bg>

