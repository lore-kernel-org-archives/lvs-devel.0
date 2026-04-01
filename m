Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 447F6451064;
	Wed,  1 Apr 2026 16:04:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775059447; cv=none; b=oBwdb0xfeigjNhfPHvvkk7vfVY1O4YkPE5xp7TexVxp4we8/3XoFPt74Pb6yo0Dv7penKvSiDKG1wBTO6H2/UI1O/C98XvRsETDmtZomgP4y35OR+sXlMnrnfMkR5WxNTwMkdjSfLxqOVyUrYZUsqc1qZbsgbMEM+G/ir2nTOss=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775059447; c=relaxed/simple;
	bh=rpg0i6T8aadfe14vKBy8l3ekA9dB7SOFqA7C/gnPHto=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=sseKgDhdR2suD9Fzx5j0/9hJ2sP2taJvlmpauyuVh+kGssVStb9G3Z4zA1R1NeRD8rRrOS+SVwlMYUjQvs+nUAtOZTLsWlwYjC2VKMExJ03xQEhP9B3H8b74ditTaH7Dnt4w/VagDDY2mr+EGJjFujpqal5/VeeJ/GwZbfKxNbU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=wZ8V1M6h; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="wZ8V1M6h"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 4720B21C4D;
	Wed, 01 Apr 2026 19:03:58 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=NJ3hkVDy30yTd4rqEGxy01hJzKruWpO4a037MyODrLA=; b=wZ8V1M6hYu9H
	hO25qTliOHUL9LSSQpLHo/JGeTUThJG7qRg8mkCj4WXQNMdBjx63FhdjggunmeCi
	n2PuD0ayCw5RaiCB2doIXXTBnw0bKRRYjgNjNljQoqvpbX/FVqpa8DQVkYWE+oKD
	T+7AaICAdx9O9XBDwdbx5EImtzy/tKw+Sq+TJyGLgq5BurhUCtz4Ac4iCuaZGRhi
	+45YwiezEKfHY69bdktrLXwZG64oPlEg60E/Sv8jWjZQuSMe0t5hR9Y090zj7KxC
	uDMmNm+tUL4JWFVNUuza0dzyHUsfnJyiWrVHouJ6QdqIAQ33XmLZP1e4cKmBUZ79
	5pr935kyYPSpyZQKM1fWNGPRzmtUi6vuF+uTKk9v8qeIcZsSOs2vtalRrFrDl19c
	XrZJQqWdfCeM1Fdp9/uq87obFDoc/ta2ICaS8ldz3Bb5+8EwQPqmB/YPDLrXPNwX
	3ImaYRSF+Nu5zI3sFx369Vay2uCKydXtM4buzROeT286164iDqTcMGlw63nJHokx
	AZcovmFx57aQNI/GK1HeDEVG27nXPx5Uyshz575wQq2DCxHBdHpB9XtD04ozeBSk
	2XzDW7LQyBwzLCzh1HjEBTAWkm0awH2q5nsyhYA0zOD67ydw2wd8HT9KDv9f6mJB
	uVr5PR/FQFkbWvRGeaRw24Mk4yFIOSs=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 01 Apr 2026 19:03:57 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id B63A1607AC;
	Wed,  1 Apr 2026 19:03:55 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 631G3kH0060367;
	Wed, 1 Apr 2026 19:03:47 +0300
Date: Wed, 1 Apr 2026 19:03:46 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Yingnan Zhang <342144303@qq.com>
cc: horms@verge.net.au, pablo@netfilter.org, fw@strlen.de, phil@nwl.cc,
        davem@davemloft.net, edumazet@google.com, kuba@kernel.org,
        pabeni@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH net] ipvs: fix MTU check for GSO packets in tunnel mode
In-Reply-To: <tencent_4A3E1C339C75D359093BE4F08648AFAA6009@qq.com>
Message-ID: <5c480579-fc15-738c-0c94-f0e812d2dbf3@ssi.bg>
References: <tencent_4A3E1C339C75D359093BE4F08648AFAA6009@qq.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Wed, 1 Apr 2026, Yingnan Zhang wrote:

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
> Fix this by removing the GSO packet exception from the MTU check and
> properly validating GSO packets using skb_gso_validate_network_len().
> This function correctly validates whether the GSO segments will fit
> within the MTU after segmentation. If validation fails, send an ICMP
> Fragmentation Needed message to enable proper PMTU discovery.
> 
> Fixes: 4cdd34084d53 ("netfilter: nf_conntrack_ipv6: improve fragmentation handling")
> Signed-off-by: Yingnan Zhang <342144303@qq.com>
> ---
>  net/netfilter/ipvs/ip_vs_xmit.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 3601eb86d..82f2e7a32 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -232,8 +232,15 @@ static inline bool ensure_mtu_is_adequate(struct netns_ipvs *ipvs, int skb_af,
>  			return true;
>  
>  		if (unlikely(ip_hdr(skb)->frag_off & htons(IP_DF) &&
> -			     skb->len > mtu && !skb_is_gso(skb) &&
> +			     skb->len > mtu &&
>  			     !ip_vs_iph_icmp(ipvsh))) {
> +			if (skb_is_gso(skb)) {
> +				if (skb_gso_validate_network_len(skb, mtu))
> +					return true;

	Should we add the same function call in
__mtu_check_toobig_v6() for IPv6 ? Comparing it with
net/ipv6/ip6_output.c:ip6_pkt_too_big()...

> +				icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
> +				IP_VS_DBG(1, "frag needed for %pI4\n", &ip_hdr(skb)->saddr);
> +				return false;
> +			}
>  			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
>  				  htonl(mtu));
>  			IP_VS_DBG(1, "frag needed for %pI4\n",
> -- 
> 2.51.0

Regards

--
Julian Anastasov <ja@ssi.bg>

