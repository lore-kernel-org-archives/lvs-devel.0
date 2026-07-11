Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9CA6721ABBB;
	Sat, 11 Jul 2026 17:17:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783790245; cv=none; b=tlGXmV/hNvQeajPxg487D16+Q86DYjhx9uCD3EDY0iqgMAtzo5lYZfpDlkNWSkeNEct1QUCTWQfTwl/r6OZgPircnGYLqaD2Mo6JvZCL8B/C4cSXAslB3liH4Ug5SxAJBNeWm67C3YKvs/wcAf2kGNU9+BhbOEErmaTV8rLpUZ0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783790245; c=relaxed/simple;
	bh=pmmG46B+j2gfAcSZj1gE7RQW/eAHZuPUKanmy59ZrB4=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=FiXnoM0uKqCfG3VPX0FACT6M4Tzcolo+4BFIuEdUPsvlYI0yd4rch9wXZE2f7XbSe5Zogny7xTMmHxbmFu11M5romMSV8V7PcJ3AyyJOC4rdAtiaUR0JjYL5fHSoxbfFczr7I+XtuCzYva7ox7eap5DaylpleXIAAvum85VZ270=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=IRmJNcRV; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="IRmJNcRV"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 07D6320259;
	Sat, 11 Jul 2026 20:17:09 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=a5WcwgPpgbRpwxvyWM4zEyCq8vz2iBvoZybBwQMvEBA=; b=IRmJNcRVaSuB
	cPEQqxrBrpOcMlRp3CzOy1bQa9RQoXdsDGq4Hx3h3U7v4r5ed0f10bbo7tQCDzXS
	RH7klgSgLFQ2i5UTo0WlkXtIiHZykTnDxgce8ZN/NHa+aJ2iB4dRr0e5XFX9WJlJ
	NGRZob/FVcIJmPAVEAdjq7rCgpxG9udLyIpXo8hEvZ343S8QOQeKhX1zuroYOXq6
	mdD7F9KQBrlR4ItX8XpmWepq8ZZe0xRjGdxA1TNTRp6QjDlFuVpvcvM8UxcxeFQ0
	Lfedz/2l9/SR76VKD4EnVEMw8KSogeIp4XZcKMs2DwtKF0FF3F+mFxcSiTBZ+DOU
	cdDsPS9mfiW6NBE1/MpLnDGxqnRAczD5ymsy1KLCNFFBaPScCL+AqOFErLZDauLe
	6V0T+Y2FtIlvcLXax4nfm+dqIPKlUG7fIXLSaoFIOYabGnK47QQbrPwf1LNEPl0s
	4A8Em+JTU5zar+7CWCuxgHJDXBLd0ZUQUN/EN5c5yVTWCTqOemKhXt3vRNpnlP/3
	fJ/GpXA+vNjDPjwy/Rp02gzPi25HFOYxWd9Rm3T4y5dS+I6J9P9ONibCc9QSSgGe
	0Jbb4Amm6pDcHkXXajtxDJOsDS22Jy8nlZRyE1H/ATKQy0FqDZlspobwk8CI/H/v
	PHQYRDbDffyb9sBYr3SpRVv1h1vN4TY=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 11 Jul 2026 20:17:08 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id D0B1061BBF;
	Sat, 11 Jul 2026 20:17:08 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66BHH3Qv052268;
	Sat, 11 Jul 2026 20:17:06 +0300
Date: Sat, 11 Jul 2026 20:17:03 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH nf] ipvs: fix the checksum validations
In-Reply-To: <20260709202356.104307-1-ja@ssi.bg>
Message-ID: <014e0c4c-eab0-d7ce-d82f-d410c5fec5c7@ssi.bg>
References: <20260709202356.104307-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Thu, 9 Jul 2026, Julian Anastasov wrote:

> TCP/UDP checksum validation for CHECKSUM_COMPLETE is broken
> before the git history.
> 
> Expecting skb->csum to cover data starting from the protocol
> header is wrong. As IPVS works at the IP layer, the csum for
> the IP header is not subtracted yet.
> 
> ip_vs_in_icmp_v6() is missing checksum validation for ICMPv6
> packets from clients.
> 
> Also, Sashiko points out that handle_response_icmp() being
> common for IPv4 and IPv6 is missing the pseudo-header
> calculation while validating ICMPv6 messages from real
> servers which is a problem if checksum is not validated
> by the hardware.
> 
> Fix the problems by creating ip_vs_checksum_common_check()
> helper and use it for TCP/UDP/ICMP both for IPv4 and IPv6.
> 
> Also, ip_vs_checksum_complete() can be marked static.
> 
> Fixes: 2a3b791e6e11 ("IPVS: Add/adjust Netfilter hook functions and helpers for v6")
> Link: https://sashiko.dev/#/patchset/20260708180315.77413-1-ja%40ssi.bg
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

	This patch needs changes, will send v2.

pw-bot: changes-requested

> ---
>  include/net/ip_vs.h                  |  5 ++-
>  net/netfilter/ipvs/ip_vs_core.c      | 63 ++++++++++++++++++++++++++--
>  net/netfilter/ipvs/ip_vs_proto_tcp.c | 35 ++--------------
>  net/netfilter/ipvs/ip_vs_proto_udp.c | 39 +++--------------
>  4 files changed, 71 insertions(+), 71 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 49297fec448a..fd18b1cd6471 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -2065,8 +2065,6 @@ void ip_vs_nat_icmp_v6(struct sk_buff *skb, struct ip_vs_protocol *pp,
>  		       struct ip_vs_conn *cp, int dir);
>  #endif
>  
> -__sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset);
> -
>  static inline __wsum ip_vs_check_diff4(__be32 old, __be32 new, __wsum oldsum)
>  {
>  	__be32 diff[2] = { ~old, new };
> @@ -2092,6 +2090,9 @@ static inline __wsum ip_vs_check_diff2(__be16 old, __be16 new, __wsum oldsum)
>  	return csum_partial(diff, sizeof(diff), oldsum);
>  }
>  
> +bool ip_vs_checksum_common_check(int af, struct sk_buff *skb, int proto,
> +				 int offset);
> +
>  /* Forget current conntrack (unconfirmed) and attach notrack entry */
>  static inline void ip_vs_notrack(struct sk_buff *skb)
>  {
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index c9c88c99d07b..ceb1cbf33dd7 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -867,11 +867,56 @@ static int sysctl_nat_icmp_send(struct netns_ipvs *ipvs) { return 0; }
>  
>  #endif
>  
> -__sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset)
> +static __sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset)
>  {
>  	return csum_fold(skb_checksum(skb, offset, skb->len - offset, 0));
>  }
>  
> +/**
> + * ip_vs_checksum_common_check - validate checksum for TCP/UDP/ICMP
> + * @af: AF_INET/AF_INET6
> + * @skb: socket buffer
> + * @proto: IPPROTO_xxx
> + * @offset: offset of protocol header
> + */
> +bool ip_vs_checksum_common_check(int af, struct sk_buff *skb, int proto,
> +				 int offset)
> +{
> +	__wsum csum;
> +
> +	if (skb_csum_unnecessary(skb))
> +		return true;
> +	if (skb->ip_summed == CHECKSUM_NONE) {
> +		csum = skb_checksum(skb, offset, skb->len - offset, 0);
> +	} else if (skb->ip_summed == CHECKSUM_COMPLETE) {
> +		/* IPVS works at IP layer, so skb->csum covers data from
> +		 * IP header, strip it up to the protocol header
> +		 */
> +		csum = csum_sub(skb->csum, skb_checksum(skb, 0, offset, 0));
> +	} else {
> +		/* No need to checksum. */
> +		return true;
> +	}
> +#ifdef CONFIG_IP_VS_IPV6
> +	if (af == AF_INET6) {
> +		if (csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
> +				    &ipv6_hdr(skb)->daddr,
> +				    skb->len - offset, proto,
> +				    csum))
> +			return false;
> +	} else
> +#endif
> +		if (proto == IPPROTO_ICMP)
> +			return !csum_fold(csum);
> +		else if (csum_tcpudp_magic(ip_hdr(skb)->saddr,
> +					   ip_hdr(skb)->daddr,
> +					   skb->len - offset, proto,
> +					   csum))
> +			return false;
> +
> +	return true;
> +}
> +
>  static inline enum ip_defrag_users ip_vs_defrag_user(unsigned int hooknum)
>  {
>  	if (NF_INET_LOCAL_IN == hooknum)
> @@ -1039,12 +1084,13 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
>  				unsigned int hooknum)
>  {
>  	unsigned int verdict = NF_DROP;
> +	int iproto = af == AF_INET6 ? IPPROTO_ICMPV6 : IPPROTO_ICMP;
>  
>  	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
>  		goto after_nat;
>  
>  	/* Ensure the checksum is correct */
> -	if (!skb_csum_unnecessary(skb) && ip_vs_checksum_complete(skb, ihl)) {
> +	if (!ip_vs_checksum_common_check(af, skb, iproto, ihl)) {
>  		/* Failed checksum! */
>  		IP_VS_DBG_BUF(1, "Forward ICMP: failed checksum from %s!\n",
>  			      IP_VS_DBG_ADDR(af, snet));
> @@ -1898,7 +1944,7 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
>  	verdict = NF_DROP;
>  
>  	/* Ensure the checksum is correct */
> -	if (!skb_csum_unnecessary(skb) && ip_vs_checksum_complete(skb, ihl)) {
> +	if (!ip_vs_checksum_common_check(AF_INET, skb, IPPROTO_ICMP, ihl)) {
>  		/* Failed checksum! */
>  		IP_VS_DBG(1, "Incoming ICMP: failed checksum from %pI4!\n",
>  			  &iph->saddr);
> @@ -2064,6 +2110,17 @@ static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
>  		goto out;
>  	}
>  
> +	verdict = NF_DROP;
> +
> +	/* Ensure the checksum is correct */
> +	if (!ip_vs_checksum_common_check(AF_INET6, skb, IPPROTO_ICMPV6,
> +					 iph->len)) {
> +		/* Failed checksum! */
> +		IP_VS_DBG(1, "Incoming ICMPv6: failed checksum from %pI6c!\n",
> +			  &iph->saddr);
> +		goto out;
> +	}
> +
>  	/* do the statistics and put it back */
>  	ip_vs_in_stats(cp, skb);
>  
> diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> index 8cc0a8ce6241..147cf01708ff 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> @@ -304,39 +304,10 @@ static int
>  tcp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
>  	       unsigned int tcphoff)
>  {
> -	switch (skb->ip_summed) {
> -	case CHECKSUM_NONE:
> -		skb->csum = skb_checksum(skb, tcphoff, skb->len - tcphoff, 0);
> -		fallthrough;
> -	case CHECKSUM_COMPLETE:
> -#ifdef CONFIG_IP_VS_IPV6
> -		if (af == AF_INET6) {
> -			if (csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
> -					    &ipv6_hdr(skb)->daddr,
> -					    skb->len - tcphoff,
> -					    IPPROTO_TCP,
> -					    skb->csum)) {
> -				IP_VS_DBG_RL_PKT(0, af, pp, skb, 0,
> -						 "Failed checksum for");
> -				return 0;
> -			}
> -		} else
> -#endif
> -			if (csum_tcpudp_magic(ip_hdr(skb)->saddr,
> -					      ip_hdr(skb)->daddr,
> -					      skb->len - tcphoff,
> -					      ip_hdr(skb)->protocol,
> -					      skb->csum)) {
> -				IP_VS_DBG_RL_PKT(0, af, pp, skb, 0,
> -						 "Failed checksum for");
> -				return 0;
> -			}
> -		break;
> -	default:
> -		/* No need to checksum. */
> -		break;
> +	if (!ip_vs_checksum_common_check(af, skb, IPPROTO_TCP, tcphoff)) {
> +		IP_VS_DBG_RL_PKT(0, af, pp, skb, 0, "Failed checksum for");
> +		return 0;
>  	}
> -
>  	return 1;
>  }
>  
> diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
> index f9de632e38cd..d10713ca74f7 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_udp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
> @@ -306,40 +306,11 @@ udp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
>  	if (uh == NULL)
>  		return 0;
>  
> -	if (uh->check != 0) {
> -		switch (skb->ip_summed) {
> -		case CHECKSUM_NONE:
> -			skb->csum = skb_checksum(skb, udphoff,
> -						 skb->len - udphoff, 0);
> -			fallthrough;
> -		case CHECKSUM_COMPLETE:
> -#ifdef CONFIG_IP_VS_IPV6
> -			if (af == AF_INET6) {
> -				if (csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
> -						    &ipv6_hdr(skb)->daddr,
> -						    skb->len - udphoff,
> -						    IPPROTO_UDP,
> -						    skb->csum)) {
> -					IP_VS_DBG_RL_PKT(0, af, pp, skb, 0,
> -							 "Failed checksum for");
> -					return 0;
> -				}
> -			} else
> -#endif
> -				if (csum_tcpudp_magic(ip_hdr(skb)->saddr,
> -						      ip_hdr(skb)->daddr,
> -						      skb->len - udphoff,
> -						      ip_hdr(skb)->protocol,
> -						      skb->csum)) {
> -					IP_VS_DBG_RL_PKT(0, af, pp, skb, 0,
> -							 "Failed checksum for");
> -					return 0;
> -				}
> -			break;
> -		default:
> -			/* No need to checksum. */
> -			break;
> -		}
> +	if (!uh->check)
> +		return 1;
> +	if (!ip_vs_checksum_common_check(af, skb, IPPROTO_UDP, udphoff)) {
> +		IP_VS_DBG_RL_PKT(0, af, pp, skb, 0, "Failed checksum for");
> +		return 0;
>  	}
>  	return 1;
>  }
> -- 
> 2.55.0

Regards

--
Julian Anastasov <ja@ssi.bg>

