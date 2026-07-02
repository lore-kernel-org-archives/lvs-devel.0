Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F28394189DD;
	Thu,  2 Jul 2026 11:31:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782991902; cv=none; b=r88YPtFoLqKvK2PHkH202q+78HcDwtE9/IkdPDs53kI4noWt0LZ2sCTgRpksPbLTjNuXZzI+J/YmLy8rTpi9139wBtpPeQOr62037rystVTUxlRaweuBavZA2BfiWJkgNtxxQVYC151NSAjR0Vu5mrJUa9ceZl3T1PfrL35h+N0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782991902; c=relaxed/simple;
	bh=tXGbtkdTZWAv2pqpZGDXd8E3ARFn2KxITER5JobuThU=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=G4RksqvHGS3Ud7cGOGkarkv4i1QG5u8to5WYw4A7t/8+r8qgV9QwTOnk8/AP6Zf8Af3odEA5eA3evI8Cv5Dof4wFttomxw8jxPECeOylW/MckuWEmYk822T1Dx5u9aoaCurk+ZLyHfL9bQrRY8Efuw60UuueGX7H6BL1MR6DIJU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=yCrjjBRw; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="yCrjjBRw"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id C0191229E7;
	Thu, 02 Jul 2026 14:31:32 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=vNIDsZvLWhESGHi31+8av3uZRVUZwCUmNhPwcwKeGuY=; b=yCrjjBRw9gkC
	LC0pjNMVHtdLgT+4Z7rzrnM45BFpaAYiM1fTte9FYqoza4tc7UhtwWV5yKLzdJFu
	yS6z3o/hlGo1Ig5qIxdv+Ozdokki15BT/xRE2fbrMUJA5cy7ikGFc997M458VIy3
	/pzXisJostq8f8Yn70GP1BwAnPiJQCcZa60K7uqETuRgTRXTAY/J5/mShiRPIBNH
	9ja+3JvqKfUssVsF91rSdYfKTLV3/ScVZbKjWCougWdrEf4fDXoMGpj2UxNysA28
	dWK7/dli4y236S0Aw/E9By1Uhh799Y3wtCrHqwg6eQ+EPR+5W41iZ19t5XzKXbBv
	7UT2cVNSY4F+pk+cDyolaMiLDhacfPlelmxWet3200LZB0Wo8Uq/v/Hh0uJo2BTL
	Baw43tgfw9HGGQ77Ne6Vi0vb+/pkPQrQnVc6hDaFiSwXLqf6wCXbKwq97YougY+z
	MQgR/BcjqELSCnEzOHF86PtXfBoaWO/OJJrLcg0Rmn8LSJIofO4YmHAXxQ01lmCw
	YPnSD1Gw5hTCIdKvJhB38jGiHQxrgo6EbFWQsDHEmtRD5Z/d/abbcredtURottvE
	vQsDL5vuT80dMFCTzcBOP9SIe2itXhfyxe7Ygdogc8M1RiT9Cyjn4rLMZeLgzuEP
	pPThQRfH7D540qdMGw0pr7mSZ4qVF70=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 02 Jul 2026 14:31:32 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 7602C60B21;
	Thu,  2 Jul 2026 14:31:31 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 662BVT4K038906;
	Thu, 2 Jul 2026 14:31:29 +0300
Date: Thu, 2 Jul 2026 14:31:29 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org, stable@vger.kernel.org,
        Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>,
        Ao Wang <wangao@seu.edu.cn>, Xuewei Feng <fengxw06@126.com>,
        Qi Li <qli01@tsinghua.edu.cn>, Ke Xu <xuke@tsinghua.edu.cn>
Subject: Re: [PATCH net v2] ipvs: fix PMTU for GUE/GRE tunnel ICMP errors
In-Reply-To: <20260702073430.67680-1-zhaoyz24@mails.tsinghua.edu.cn>
Message-ID: <c6664a17-eea8-edf3-30bc-9997265c9b57@ssi.bg>
References: <20260702073430.67680-1-zhaoyz24@mails.tsinghua.edu.cn>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Thu, 2 Jul 2026, Yizhou Zhao wrote:

> When an ICMP Fragmentation Needed error is received for a tunneled IPVS
> connection, ip_vs_in_icmp() recomputes the MTU that the original packet
> can use by subtracting the tunnel overhead from the reported next-hop
> MTU.
> 
> The current code always subtracts sizeof(struct iphdr), which is only
> the IPIP overhead. For GUE and GRE tunnels, ipvs_udp_decap() and
> ipvs_gre_decap() already compute the additional tunnel header length,
> but that value is scoped to the decapsulation block and is lost before
> the ICMP_FRAG_NEEDED handling. As a result, the ICMP error sent back to
> the client advertises an MTU that is too large, so PMTUD can fail to
> converge for GUE/GRE-tunneled real servers.
> 
> With a reported next-hop MTU of 1400, a GUE tunnel currently returns
> 1380 to the client. The correct value is 1368:
> 
>   1400 - sizeof(struct iphdr) - sizeof(struct udphdr) -
>   sizeof(struct guehdr)
> 
> Hoist the tunnel header length into the main ip_vs_in_icmp() scope and
> subtract sizeof(struct iphdr) + ulen in the Fragmentation Needed path.
> The IPIP path keeps ulen as 0, so its existing 1400 - 20 = 1380 result
> is unchanged.
> 
> Fixes: 508f744c0de3 ("ipvs: strip udp tunnel headers from icmp errors")
> Cc: stable@vger.kernel.org
> Reported-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
> Reported-by: Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>
> Reported-by: Ao Wang <wangao@seu.edu.cn>
> Reported-by: Xuewei Feng <fengxw06@126.com>
> Reported-by: Qi Li <qli01@tsinghua.edu.cn>
> Reported-by: Ke Xu <xuke@tsinghua.edu.cn>
> Assisted-by: Claude-Code:GLM-5.2
> Signed-off-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>

	Looks good to me for the nf tree, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
> Changes in v2:
>   - Use the short first hunk context so patch applies without fuzz.
>   - Adjust Assisted-by to checkpatch's agent-name format.
>   - Suggested by Julian.
>   - Link to v1: https://lore.kernel.org/netdev/20260701065941.46249-1-zhaoyz24@mails.tsinghua.edu.cn/
> ---
>  net/netfilter/ipvs/ip_vs_core.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index d40b404c1bf6..906f2c361676 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1767,6 +1767,7 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
>  	bool tunnel, new_cp = false;
>  	union nf_inet_addr *raddr;
>  	char *outer_proto = "IPIP";
> +	int ulen = 0;
>  
>  	*related = 1;
>  
> @@ -1831,7 +1832,6 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
>  		   /* Error for our tunnel must arrive at LOCAL_IN */
>  		   (skb_rtable(skb)->rt_flags & RTCF_LOCAL)) {
>  		__u8 iproto;
> -		int ulen;
>  
>  		/* Non-first fragment has no UDP/GRE header */
>  		if (unlikely(cih->frag_off & htons(IP_OFFSET)))
> @@ -1936,8 +1936,8 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
>  				if (dest_dst)
>  					mtu = dst_mtu(dest_dst->dst_cache);
>  			}
> -			if (mtu > 68 + sizeof(struct iphdr))
> -				mtu -= sizeof(struct iphdr);
> +			if (mtu > 68 + sizeof(struct iphdr) + ulen)
> +				mtu -= sizeof(struct iphdr) + ulen;
>  			info = htonl(mtu);
>  		}
>  		/* Strip outer IP, ICMP and IPIP/UDP/GRE, go to IP header of

Regards

--
Julian Anastasov <ja@ssi.bg>

