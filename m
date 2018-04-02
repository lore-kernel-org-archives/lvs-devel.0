From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v1] ipvs: add consistent source hashing
 scheduling
Date: Mon, 2 Apr 2018 10:33:27 -0700
Message-ID: <63c63fab-12ed-8b15-e00e-dc54e5c144eb@gmail.com>
References: <20180402172025.7380-1-vincent@bernat.im>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:references:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=kHlgGTLbbHqIUvTjepHXA+GrNGP069INxC/sJygcCE4=;
        b=MyeKXLBzkYy6uXVPKENtAM5lQHLSr0AIquQLChUGUJ6a44+eCY/Em66rvBEXcQKaMF
         pm0f5RM9gugXG6cmQv6x/TDQGciTjSb2Cl/lCYHop+JnuZCwmCxOVDj9Be3ZjZhXFPN0
         0lRWzGC+K0JDYjD6+usZNkSxFaw/p6PIZ/ObWL1xe/ftYuQxOQTmDwVSjBPI/q6C+Kyh
         FLnBJaA+7mOaUiQLuoFBjOZKf7DGBnxGYdfK1zWsHu8lqtiPcYsN+dBHBwSbY95R6MZU
         KBm6Y2Ix56nWuKELLKXw/NrbMHPFrEVNK7yLcEMOLYz6YTnauoMCNhFs+9qqXs1Q7kwt
         aU/g==
In-Reply-To: <20180402172025.7380-1-vincent@bernat.im>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Vincent Bernat <vincent@bernat.im>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org



On 04/02/2018 10:20 AM, Vincent Bernat wrote:

> +static inline u32
> +ip_vs_csh_permutation(struct ip_vs_dest *d, int j)
> +{
> +	u32 offset, skip;
> +	__be32 addr_fold = d->addr.ip;
> +
> +#ifdef CONFIG_IP_VS_IPV6
> +	if (d->af == AF_INET6)
> +		addr_fold = d->addr.ip6[0]^d->addr.ip6[1]^
> +			d->addr.ip6[2]^d->addr.ip6[3];
> +#endif
> +	addr_fold = ntohl(addr_fold) + ntohs(d->port);
> +	offset = hash_32(addr_fold, 32) % IP_VS_CSH_TAB_SIZE;
> +	skip = (hash_32(addr_fold + 1, 32) % (IP_VS_CSH_TAB_SIZE - 1)) + 1;
> +	return (offset + j * skip) % IP_VS_CSH_TAB_SIZE;
> +}
> +

This does not look very strong to me, particularly the IPv6 folding

I would rather use __ipv6_addr_jhash() instead of ipv6_addr_hash(), even if it is hard coded ;)



