Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 03E92495527;
	Wed,  1 Jul 2026 12:58:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782910713; cv=none; b=lfD61Waoyk21lTdpj8vM8EEUQ5LADbTcFv9RfRBHqkZ6v64JputuXhhu4Xsis8ZE/kfjaZxCdQMTPherPfEySij/iOhiizi5UBU7r9CgEhJzOzzJUfciTUUFEXgNZmpTEhRq2nP/Q5Ls0NL2+d2WA2Zg8mG5yS4Fc/5JSs594ng=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782910713; c=relaxed/simple;
	bh=MNnNF6aqKKWPoGFSYiIOGC6pM3ndilJbEB5mQda/JZs=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=CkvvQ/Jmft70DQ9DlrECP9UgnunYhH8fAn0uunLMvopl7WlsMIme7WwdwPrLsKiuafMlVm+8priRuyfycjUiXDEnPpr8GZIPnWh9/byaFq8jDyepkBqqJOj1/0LeHAzjiSSwWSdSzmMw/Ais2Mqj7P8U1ukYwQFwOpYwZ3Aa5vU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=BFriuHLn; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="BFriuHLn"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id A484E229E5;
	Wed, 01 Jul 2026 15:58:23 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=FbsxZDGlGm1ZDRal0BJRWSKMr6tW8cq7eQhkh5ZB/bg=; b=BFriuHLng6oy
	qKXUSdOnPdpHPo2L31yeS6RBfGxcc9VRXnReZ7qxGvgLF6/uhydUnNrYgsOr7mCV
	ehrp98XrrimPPDvRYahzKE7jjIal+4edNl3SMDmLSrA8SUON0PDJm/VVVeg3KiX8
	8TRxkX9B/IEDV/W9rBU1E6aab8fFmJP3oQN4e6VQ8hwKMBxjpl0mh8WP2v1DD/C+
	FINxoxS7M9J/fSNNmLOpF4uf0FKJ576Jdk9FmolvkD3vwxFEFV10CncZLcx2CUON
	pL0zk9cVp/IosG7afeHCLDP0aXSt2A/aqgd+Vo8sJ67MtQ27+4r2htxkGTGi7j70
	ungiNsZptnAto9n2sm4N1NR4v9+muzaXlicoY9I2rsuLL0d9MpKZZKKK30uDx7Yy
	4O6ltRbKUPN6j32nZk4GlLR7J5rpqWPOKG58U3WAew/de4AErY5EIvrzApFejpja
	Tkq/3D4QdnlESoNC/ZRF+T+DoDQOM4xxT0Q65iGtpJOlRQpP7ZDgr5cuuEwq86N7
	84G81l8jlvIj0nt+iVpYb9Rl2gnk7bXLD7ZHUQLliZs0qJ/lBhMlZHwx7BWRAuD6
	aaMDFo1511h2rAVj5YX4BqV1EgBnPAYbVME44R1jRnnc+IvGQD47XAxmAmfXvS/X
	gUzQumO7NlsqjU3ic1difK+U7rximZc=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 01 Jul 2026 15:58:23 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 0FCC460672;
	Wed,  1 Jul 2026 15:58:18 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 661Cw6mQ044569;
	Wed, 1 Jul 2026 15:58:07 +0300
Date: Wed, 1 Jul 2026 15:58:06 +0300 (EEST)
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
Subject: Re: [PATCH net] ipvs: fix PMTU for GUE/GRE tunnel ICMP errors
In-Reply-To: <20260701065941.46249-1-zhaoyz24@mails.tsinghua.edu.cn>
Message-ID: <b9ebd0cb-9aea-7b57-5ae4-bf379860171f@ssi.bg>
References: <20260701065941.46249-1-zhaoyz24@mails.tsinghua.edu.cn>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Wed, 1 Jul 2026, Yizhou Zhao wrote:

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
> Assisted-by: Claude Code:GLM-5.2
> Signed-off-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
> ---
>  net/netfilter/ipvs/ip_vs_core.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index d40b404c1bf62..74c5bd8b5f48 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1765,8 +1765,9 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
>  	struct ip_vs_proto_data *pd;
>  	unsigned int offset, offset2, ihl, verdict;
>  	bool tunnel, new_cp = false;
>  	union nf_inet_addr *raddr;
>  	char *outer_proto = "IPIP";
> +	int ulen = 0;
>  
>  	*related = 1;
>  

	The change look correct but there is something to fix:

1. first hunk is bad, does not apply to the nf tree (-8+9 vs -6+7
lines):

# patch -p1 --dry-run < /tmp/file.patch
checking file net/netfilter/ipvs/ip_vs_core.c
Hunk #1 succeeded at 1765 with fuzz 2.

2. the first two words in Assisted-by line should not contain
white spaces:

# scripts/checkpatch.pl --strict /tmp/file.patch

WARNING: Assisted-by expects 'AGENT_NAME:MODEL_VERSION [TOOL1] [TOOL2]' format
#40: Assisted-by: Claude Code:GLM-5.2

	Please send v2 after solving the above problems. Thanks!

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

