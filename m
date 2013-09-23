From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ipvs: improved SH fallback strategy
Date: Mon, 23 Sep 2013 23:42:50 +0400
Message-ID: <524099BA.5020303@cogentembedded.com>
References: <20130923115139.GA15034@eldamar.org.uk>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130923115139.GA15034@eldamar.org.uk>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Alexander Frolkin <avf@eldamar.org.uk>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org

Hello.

On 09/23/2013 03:51 PM, Alexander Frolkin wrote:

> Improve the SH fallback realserver selection strategy.

> With sh and sh-fallback, if a realserver is down, this attempts to
> distribute the traffic that would have gone to that server evenly
> among the remaining servers.

> Signed-off-by: Alexander Frolkin <avf@eldamar.org.uk>
> ---
> diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
> index f16c027..1676354 100644
> --- a/net/netfilter/ipvs/ip_vs_sh.c
> +++ b/net/netfilter/ipvs/ip_vs_sh.c
> @@ -120,22 +120,35 @@ static inline struct ip_vs_dest *
>   ip_vs_sh_get_fallback(struct ip_vs_service *svc, struct ip_vs_sh_state *s,
>   		      const union nf_inet_addr *addr, __be16 port)
>   {
> -	unsigned int offset;
> -	unsigned int hash;
> +	unsigned int offset, roffset;
> +	unsigned int hash, ihash;
>   	struct ip_vs_dest *dest;
>
> -	for (offset = 0; offset < IP_VS_SH_TAB_SIZE; offset++) {
> -		hash = ip_vs_sh_hashkey(svc->af, addr, port, offset);
> -		dest = rcu_dereference(s->buckets[hash].dest);
> -		if (!dest)
> -			break;
> -		if (is_unavailable(dest))
> -			IP_VS_DBG_BUF(6, "SH: selected unavailable server "
> -				      "%s:%d (offset %d)",
> +	ihash = ip_vs_sh_hashkey(svc->af, addr, port, 0);
> +	dest = rcu_dereference(s->buckets[ihash].dest);
> +

    Empty line net needed here (and it wasn't there in the original code).

> +	if (!dest)
> +		return NULL;
> +

    Here too.

> +	if (is_unavailable(dest)) {
> +		IP_VS_DBG_BUF(6, "SH: selected unavailable server "
> +		      "%s:%d, reselecting",
> +		      IP_VS_DBG_ADDR(svc->af, &dest->addr),
> +		      ntohs(dest->port));
> +		for (offset = 0; offset < IP_VS_SH_TAB_SIZE; offset++) {
> +			roffset = (offset + ihash) % IP_VS_SH_TAB_SIZE;
> +			hash = ip_vs_sh_hashkey(svc->af, addr, port, roffset);
> +			dest = rcu_dereference(s->buckets[hash].dest);
> +			if (is_unavailable(dest))
> +				IP_VS_DBG_BUF(6, "SH: selected unavailable "
> +				      "server %s:%d (offset %d), reselecting",
>   				      IP_VS_DBG_ADDR(svc->af, &dest->addr),

WBR, Sergei

