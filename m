Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B0B2839DBC3;
	Thu,  2 Apr 2026 12:59:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775134784; cv=none; b=laOBmk6dUbvyG0VXlCj5/Hppn059CNNogNhCjt9CzYQXQooUuZYReaQU+gS69QzxN/8aBJH6WZ1bO6vxkEvr+WDbVtXJakrL4kWo8aGuKPvA4q+RkUcGkZumUuI2C5nqGpc38aQFZuY3qKukLqRSeEm+L0k7rCk6kZqugcXnT8Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775134784; c=relaxed/simple;
	bh=GpTKSsPQis8JmixA5Puhzjs8NazzWDMx0MuXfJDcGlM=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=NujOT3xdwGw649Xkh1Z78s5Jn19iRJ03LUCkjbpIpAsIBgBp2P+LDo5BGIg1PPfEurLPwTI1cOnpDH06oGae11/dLJv4XXShk7U1U9h9KyULCo4IyQesAmFxafj05ecuhhirew/ue35kleS97j9cAJe8SKu+tGq77tq1IkFwG18=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=lz5ffsq5; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="lz5ffsq5"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 477DE21C4D;
	Thu, 02 Apr 2026 15:59:21 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=MuezM3xnd950a5gFnNRCzv+I/b9PjCrkZt4BLcO3eh8=; b=lz5ffsq5TLJa
	4vjkm2LhCDoQd4wf1Uchg1UCtVk8Dm7XcGYwHrOg9iO+cUKsJx/yhcoqTvyIZ687
	Ka9rBcrQ8HcNytWP0oiwFimHua7KhctgBJH/5FBS5HIzvBeq1LuKno9CXRr4CQpu
	pihmJ4jkxHNGEIJrUdS6jR33P21bUpU9McTEtyOQdBnx74Oh9ynPtkisBc8VD5rE
	mw8VDfxR8rS54rQqLUqyPebzjjl91Lh0zKh+3aG7hI20iOtKCUYF0SwtdnTrLHRn
	XH8bDcLLw6iVXlDaw1Cd+EllT4grD+7ZBoWxMXELr8ChPpqkcXxIuqdSWQASDXIf
	nazVQ1qvzuhkhXcuur/3HUi6nYISlEZiNkVxpkowJgEmKO0l4bcR28F7NSG4IxZS
	rHZQk8C9bNz3bVFNcq15SuhY/jk6vvS1Q271LPsBvOw1FQx8OnTfT0p2t45f4Xfg
	xI5fd0M+fm502JT1TLRuFVclmok2bt5bW6v2+PdMX2929vQCmWakTsoftsH0yaJy
	8DqQ+F/bwZ/yxO4aGKC8bKTueBgiT07LaMtgRjIF2z1Bws1HigMQPvn+dNsw/bPT
	haPZuJ62AgpBce/+jH2YBCVQxbcDtyTYCgGRcAYYX/16Q3OINt3FFy5zzqYBR/X4
	whUmGgXrTkJDtuqfkXPNOO+GUcF1b7A=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 02 Apr 2026 15:59:19 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 98C18609A6;
	Thu,  2 Apr 2026 15:59:17 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 632CxAGR045254;
	Thu, 2 Apr 2026 15:59:12 +0300
Date: Thu, 2 Apr 2026 15:59:10 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Yingnan Zhang <342144303@qq.com>
cc: horms@verge.net.au, pablo@netfilter.org, fw@strlen.de, phil@nwl.cc,
        davem@davemloft.net, edumazet@google.com, kuba@kernel.org,
        pabeni@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH net v2] ipvs: fix MTU check for GSO packets in tunnel
 mode
In-Reply-To: <tencent_CA2C1C219C99D315086BE55E8654AF7E6009@qq.com>
Message-ID: <841b490f-c01e-293c-9c5d-5871b9a5a383@ssi.bg>
References: <tencent_CA2C1C219C99D315086BE55E8654AF7E6009@qq.com>
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
> the !skb_is_gso(skb) condition in both IPv4 and IPv6 code paths. This
> creates problems when IPVS tunnel mode encapsulates GSO packets with
> IPIP or IPv6 tunnel headers.
> 
> The issue manifests in two ways:
> 
> 1. MTU violation after encapsulation:
>    When a GSO packet passes through IPVS tunnel mode, the original MTU
>    check is bypassed. After adding the tunnel header, the packet size
>    may exceed the outgoing interface MTU, leading to unexpected
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
> Fix this by removing the GSO packet exception from the MTU check in both
> IPv4 and IPv6 paths, and properly validating GSO packets using
> skb_gso_validate_network_len(). The condition is refactored to avoid
> code duplication.
> 
> Fixes: 4cdd34084d53 ("netfilter: nf_conntrack_ipv6: improve fragmentation handling")
> Signed-off-by: Yingnan Zhang <342144303@qq.com>
> ---
> Changes in v2:
> - Added IPv6 fix in __mtu_check_toobig_v6() per Julian's review
> - Refactored to avoid code duplication per Julian's suggestion
> - Applied same validation pattern to both IPv4 and IPv6 paths
> 
> v1: https://lore.kernel.org/netdev/20260401152228.31190-1-342144303@qq.com/
> 
>  net/netfilter/ipvs/ip_vs_xmit.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 3601eb86d..ac2ad7518 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -112,7 +112,8 @@ __mtu_check_toobig_v6(const struct sk_buff *skb, u32 mtu)
>  		if (IP6CB(skb)->frag_max_size > mtu)
>  			return true; /* largest fragment violate MTU */
>  	}

	You should remove the above line because compilation fails...

> -	else if (skb->len > mtu && !skb_is_gso(skb)) {
> +	} else if (skb->len > mtu &&
> +		   !(skb_is_gso(skb) && skb_gso_validate_network_len(skb, mtu))) {
>  		return true; /* Packet size violate MTU size */
>  	}
>  	return false;
> @@ -232,8 +233,9 @@ static inline bool ensure_mtu_is_adequate(struct netns_ipvs *ipvs, int skb_af,
>  			return true;
>  
>  		if (unlikely(ip_hdr(skb)->frag_off & htons(IP_DF) &&
> -			     skb->len > mtu && !skb_is_gso(skb) &&
> -			     !ip_vs_iph_icmp(ipvsh))) {
> +		     skb->len > mtu && !ip_vs_iph_icmp(ipvsh) &&
> +		     !(skb_is_gso(skb) &&
> +		       skb_gso_validate_network_len(skb, mtu)))) {

	Please keep the indentation, just like in my example

>  			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
>  				  htonl(mtu));
>  			IP_VS_DBG(1, "frag needed for %pI4\n",
> -- 
> 2.51.0

Regards

--
Julian Anastasov <ja@ssi.bg>

