Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 099B52D5C8E;
	Fri, 10 Apr 2026 01:11:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.190.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775783486; cv=none; b=pWseH+DEs7fhCehsmccln6a4dt9CrAxozgz7WSCWADE1mNcnsCiPkri3FOrRBnBz8sx4wVo/4hwAQn3iWXGVyZ74RAGQ3TcGzqPMjooEeEc7ZdPPLo7w9ch4eiMLWAW8u7Rsqn36hR4U0xHtys+WOzqt6jG4sA1UHUz6iYZ6TIQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775783486; c=relaxed/simple;
	bh=87h/Xu7wS8geKggg/q13T8v9/3cx/DJOSoRVzQn7DNk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Rpv4q9OYYzNnG/Uy4f+GwQVSD3l4YyUA1ivowo9Gdhuir4KkvnOq0WdR9Mu0xiXKtx1DRcQDWFS5kL/Ik1UWndr7Pp3T/7CecN8oi7RuV8EnVtMKc+kUejgvFzZ5XcxDMFvpB5oNlXZ8oeDX+F3ITu0u3x9Jn3eCyoWZ118I/Ts=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=netfilter.org; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=DFxhTFz3; arc=none smtp.client-ip=217.70.190.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="DFxhTFz3"
Received: from netfilter.org (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with UTF8SMTPSA id 0800860255;
	Fri, 10 Apr 2026 03:11:23 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1775783483;
	bh=/3ol8TcYNhnm6h5sjGfmupw+IQV4fRUDrGmbRxPlP+w=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=DFxhTFz3o/lCrJ0LjqNl/f/F7JU5N+e++YwDRMyiBUVHMsnMx7U1bbp5j7xs3H21I
	 jgplTSI//zsIzxD8uCOoJA/596Nk55lIEe8VhQfNw5hq1saHjshBtcASOONdAUVukr
	 yYE5qCpvm8hrtn3f5ek7C+zehy9KnMOKNcIx9f9NR5xowumqGaKi5BaPq9xldb8MEK
	 eXPX+XiTD/0RZJpLw/OZX0lixzkiIbIPvfIRHe4v71DMXZF3UVF2dR/tRLQbsjKyaY
	 2qk7ftRg3EKrMbrX7vjWWNVmFooQlUiwSWtcyz2eYRYyA2T4YYjjRJ7yOoZsMY4mlX
	 cC3WWiPUJL/Ww==
Date: Fri, 10 Apr 2026 03:11:20 +0200
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: Yingnan Zhang <342144303@qq.com>
Cc: horms@verge.net.au, ja@ssi.bg, fw@strlen.de, phil@nwl.cc,
	davem@davemloft.net, edumazet@google.com, kuba@kernel.org,
	pabeni@redhat.com, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH net v3] ipvs: fix MTU check for GSO packets in tunnel mode
Message-ID: <adhOOC6hF_vNDl1g@chamomile>
References: <tencent_73010FBD5FA1C05C3BC23A07A50B11CEC90A@qq.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <tencent_73010FBD5FA1C05C3BC23A07A50B11CEC90A@qq.com>

On Thu, Apr 02, 2026 at 10:46:16PM +0800, Yingnan Zhang wrote:
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

Maybe helper function helps make this more readable?

/* Based on ip_exceeds_mtu(). */
static bool ip_vs_exceeds_mtu(const struct sk_buff *skb, unsigned int mtu)
{
        if (skb->len <= mtu)
                return false;

        if (skb_is_gso(skb) && skb_gso_validate_network_len(skb, mtu))
                return false;

        return true;
}


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
> 
