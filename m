From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCHv2] ipvs: improved SH fallback strategy
Date: Fri, 27 Sep 2013 22:20:42 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1309272218180.1725@ja.ssi.bg>
References: <20130923115139.GA15034@eldamar.org.uk> <524099BA.5020303@cogentembedded.com> <20130924093238.GD18494@eldamar.org.uk> <20130925003033.GG26081@verge.net.au> <20130925092638.GD19768@eldamar.org.uk> <alpine.LFD.2.00.1309260817290.1640@ja.ssi.bg>
 <20130926100540.GB27583@eldamar.org.uk> <alpine.LFD.2.00.1309262255400.1949@ja.ssi.bg> <20130927100622.GC28974@eldamar.org.uk>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20130927100622.GC28974@eldamar.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Frolkin <avf@eldamar.org.uk>
Cc: Simon Horman <horms@verge.net.au>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org


	Hello,

On Fri, 27 Sep 2013, Alexander Frolkin wrote:

> Improve the SH fallback realserver selection strategy.
> 
> With sh and sh-fallback, if a realserver is down, this attempts to
> distribute the traffic that would have gone to that server evenly
> among the remaining servers.
> 
> Signed-off-by: Alexander Frolkin <avf@eldamar.org.uk>

	Thanks! Looks good to me.

Acked-by: Julian Anastasov <ja@ssi.bg>

> --
> diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
> index 3588fae..cc65b2f 100644
> --- a/net/netfilter/ipvs/ip_vs_sh.c
> +++ b/net/netfilter/ipvs/ip_vs_sh.c
> @@ -115,27 +115,46 @@ ip_vs_sh_get(struct ip_vs_service *svc, struct ip_vs_sh_state *s,
>  }
>  
>  
> -/* As ip_vs_sh_get, but with fallback if selected server is unavailable */
> +/* As ip_vs_sh_get, but with fallback if selected server is unavailable
> + *
> + * The fallback strategy loops around the table starting from a "random"
> + * point (in fact, it is chosen to be the original hash value to make the
> + * algorithm deterministic) to find a new server.
> + */
>  static inline struct ip_vs_dest *
>  ip_vs_sh_get_fallback(struct ip_vs_service *svc, struct ip_vs_sh_state *s,
>  		      const union nf_inet_addr *addr, __be16 port)
>  {
> -	unsigned int offset;
> -	unsigned int hash;
> +	unsigned int offset, roffset;
> +	unsigned int hash, ihash;
>  	struct ip_vs_dest *dest;
>  
> +	/* first try the dest it's supposed to go to */
> +	ihash = ip_vs_sh_hashkey(svc->af, addr, port, 0);
> +	dest = rcu_dereference(s->buckets[ihash].dest);
> +	if (!dest)
> +		return NULL;
> +	if (!is_unavailable(dest))
> +		return dest;
> +
> +	IP_VS_DBG_BUF(6, "SH: selected unavailable server %s:%d, reselecting",
> +		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port));
> +
> +	/* if the original dest is unavailable, loop around the table
> +	 * starting from ihash to find a new dest
> +	 */
>  	for (offset = 0; offset < IP_VS_SH_TAB_SIZE; offset++) {
> -		hash = ip_vs_sh_hashkey(svc->af, addr, port, offset);
> +		roffset = (offset + ihash) % IP_VS_SH_TAB_SIZE;
> +		hash = ip_vs_sh_hashkey(svc->af, addr, port, roffset);
>  		dest = rcu_dereference(s->buckets[hash].dest);
>  		if (!dest)
>  			break;
> -		if (is_unavailable(dest))
> -			IP_VS_DBG_BUF(6, "SH: selected unavailable server "
> -				      "%s:%d (offset %d)",
> -				      IP_VS_DBG_ADDR(svc->af, &dest->addr),
> -				      ntohs(dest->port), offset);
> -		else
> +		if (!is_unavailable(dest))
>  			return dest;
> +		IP_VS_DBG_BUF(6, "SH: selected unavailable "
> +			      "server %s:%d (offset %d), reselecting",
> +			      IP_VS_DBG_ADDR(svc->af, &dest->addr),
> +			      ntohs(dest->port), roffset);
>  	}
>  
>  	return NULL;

Regards

--
Julian Anastasov <ja@ssi.bg>
