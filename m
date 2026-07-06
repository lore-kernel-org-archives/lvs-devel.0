Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 74BBF38B7D2;
	Mon,  6 Jul 2026 17:49:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783360192; cv=none; b=XJv1+UgQHWgjWK4S+IS9gJ2u5CCAMsKkt9jbg9qi/8ltpuvxpwjKAxVtxBTP9QegWDagOIeo4cOfWrPBywU4UCqZxG/YaXFeejXs4TjZ8o8v82mKbWNjPsUXn/d68+Bxl+XsDa8PsstOErE4uB1f7mg4dURICr95XilVFn+wSdI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783360192; c=relaxed/simple;
	bh=9mgN9FBObo5jfv2jVyWw9wE/5/6AY8KOxsZPvgFu9Fw=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=hV3BsZ2vkHGDEe6qG71xtAPwFodvEXbBYGXt9uexx2dpPDPuEwDP8XM/oC0NM5MifjRho0xe0c5NrsxjLY5i2DxRQK2lvFJ+CUGfXlmBnWOO2p38WHRnMEUUb2k3qPZL2ed/M63F/Y3sbJau+RH56nCysExZLyeL4aJ+wj7c0As=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=jcHs1NCc; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="jcHs1NCc"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id D39A62121E;
	Mon, 06 Jul 2026 20:49:39 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=IbLlxJn2gQ5pGB9X0b0W9uzW2omQ2lnoGr+RQKENeqg=; b=jcHs1NCc6Ll+
	pM2JyKL+q4WObx1lO8yYUp5tmGkHgALTpuKQ2ptNoQr7KgGaJ8X5QGoR0WuylWGW
	tjVBASNwPA16uuFrBNB+CptC/f9fnxrQGPpWGKOYhX1SErdjMwySmso5mlmz3gmp
	zOLS95E7tU1c5WZ5huomjQjyRnxgUv/iUCT8VKH0QWT5rIFeiD4Jk59iBiziYfgw
	Edck8wl8+97yPhWw3xHe6NlQOXwZ9uZxF6DijhJeNalHYf5Dp1dqoVya9Aa+7fOt
	K4QuS5AS4FBf6PbVWpMQjZLsKRPU5SGRt1/fHOrSl4P6zsvgOFFrHsPhma8HTzpw
	rVXThkBte/540fcvUz4gk+gzw4tHuUuBJyb7dxhmsrj/KFvvnzMmE7lfkFrsrYul
	LFf/YdNHEss7ORoxY/+Jih1XDKwjsbP2/YF5O9wwJVFSb0jKxpFd4UJwaX134CX9
	SLaWCBcVriF0KnXwFAxgDLSr2w2a366v5eq1BdNlWqhsv72QJMkwPp5DpmfyTT+s
	mogaGxCNfTvCACZUSQ6J2xxvnTND+kEKwdgWfhaEw5UCGi937GV2PSGQf5cTsSNq
	tXZ9tmoL6QhmeE5K+G+9jTTx/T/HNFUrzyI+SE/RV7f/oBTvhkVO1ZsmYO19aZ1J
	G80Gcs41Nga/aCPxm2k1lonJXzX8gaU=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 06 Jul 2026 20:49:39 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id D9B3B60546;
	Mon,  6 Jul 2026 20:49:38 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 666HnTnf078467;
	Mon, 6 Jul 2026 20:49:30 +0300
Date: Mon, 6 Jul 2026 20:49:29 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH nf] ipvs: ensure inner headers in ICMP errors are in
 headroom
In-Reply-To: <20260706151041.62630-1-ja@ssi.bg>
Message-ID: <cf9af9ab-8404-9609-5e0c-81e175e69781@ssi.bg>
References: <20260706151041.62630-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 6 Jul 2026, Julian Anastasov wrote:

> Sashiko points out that after stripping the outer headers
> with pskb_pull() we should ensure the inner IP headers
> in ICMP errors from tunnels are present in the skb headroom
> for functions like ipv4_update_pmtu(), icmp_send() and
> IP_VS_DBG().
> 
> Also, add more checks for the length of the inner headers.
> 
> Fixes: f2edb9f7706d ("ipvs: implement passive PMTUD for IPIP packets")
> Link: https://sashiko.dev/#/patchset/20260702073430.67680-1-zhaoyz24%40mails.tsinghua.edu.cn
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

	Ignore this, will send v2 with more checks...
        
pw-bot: changes-requested

> ---
>  net/netfilter/ipvs/ip_vs_core.c | 20 +++++++++++++++-----
>  1 file changed, 15 insertions(+), 5 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 906f2c361676..f332ba422a65 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1767,6 +1767,7 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
>  	bool tunnel, new_cp = false;
>  	union nf_inet_addr *raddr;
>  	char *outer_proto = "IPIP";
> +	unsigned int hlen_ipip = 0;
>  	int ulen = 0;
>  
>  	*related = 1;
> @@ -1822,9 +1823,10 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
>  		/* Only for known tunnel */
>  		if (!dest || dest->tun_type != IP_VS_CONN_F_TUNNEL_TYPE_IPIP)
>  			return NF_ACCEPT;
> -		offset += cih->ihl * 4;
> +		hlen_ipip = cih->ihl * 4;
> +		offset += hlen_ipip;
>  		cih = skb_header_pointer(skb, offset, sizeof(_ciph), &_ciph);
> -		if (cih == NULL)
> +		if (!(cih && cih->version == 4 && cih->ihl >= 5))
>  			return NF_ACCEPT; /* The packet looks wrong, ignore */
>  		tunnel = true;
>  	} else if ((cih->protocol == IPPROTO_UDP ||	/* Can be UDP encap */
> @@ -1836,7 +1838,8 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
>  		/* Non-first fragment has no UDP/GRE header */
>  		if (unlikely(cih->frag_off & htons(IP_OFFSET)))
>  			return NF_ACCEPT;
> -		offset2 = offset + cih->ihl * 4;
> +		hlen_ipip = cih->ihl * 4;
> +		offset2 = offset + hlen_ipip;
>  		if (cih->protocol == IPPROTO_UDP) {
>  			ulen = ipvs_udp_decap(ipvs, skb, offset2, AF_INET,
>  					      raddr, &iproto);
> @@ -1905,6 +1908,7 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
>  	}
>  
>  	if (tunnel) {
> +		unsigned int hlen_orig = cih->ihl * 4;
>  		__be32 info = ic->un.gateway;
>  		__u8 type = ic->type;
>  		__u8 code = ic->code;
> @@ -1921,6 +1925,9 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
>  				goto ignore_tunnel;
>  			offset2 -= ihl + sizeof(_icmph);
>  			skb_reset_network_header(skb);
> +			/* Ensure the IP header is present in headroom */
> +			if (!pskb_may_pull(skb, hlen_ipip))
> +				goto ignore_tunnel;
>  			IP_VS_DBG(12, "ICMP for %s %pI4->%pI4: mtu=%u\n",
>  				  outer_proto, &ip_hdr(skb)->saddr,
>  				  &ip_hdr(skb)->daddr, mtu);
> @@ -1936,8 +1943,8 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
>  				if (dest_dst)
>  					mtu = dst_mtu(dest_dst->dst_cache);
>  			}
> -			if (mtu > 68 + sizeof(struct iphdr) + ulen)
> -				mtu -= sizeof(struct iphdr) + ulen;
> +			if (mtu > 68 + hlen_ipip + ulen)
> +				mtu -= hlen_ipip + ulen;
>  			info = htonl(mtu);
>  		}
>  		/* Strip outer IP, ICMP and IPIP/UDP/GRE, go to IP header of
> @@ -1946,6 +1953,9 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
>  		if (pskb_pull(skb, offset2) == NULL)
>  			goto ignore_tunnel;
>  		skb_reset_network_header(skb);
> +		/* Ensure the IP header is present in headroom */
> +		if (!pskb_may_pull(skb, hlen_orig))
> +			goto ignore_tunnel;
>  		IP_VS_DBG(12, "Sending ICMP for %pI4->%pI4: t=%u, c=%u, i=%u\n",
>  			&ip_hdr(skb)->saddr, &ip_hdr(skb)->daddr,
>  			type, code, ntohl(info));
> -- 
> 2.55.0

Regards

--
Julian Anastasov <ja@ssi.bg>

