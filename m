From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH nf-next 4/4] netfilter: ipvs: merge ipv4 + ipv6 icmp
 reply handlers
Date: Tue, 12 Oct 2021 20:21:32 +0300 (EEST)
Message-ID: <8dba13d5-a250-bb1e-7db-ebb02c665af5@ssi.bg>
References: <20211012120608.21827-1-fw@strlen.de> <20211012120608.21827-5-fw@strlen.de>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20211012120608.21827-5-fw@strlen.de>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>
Cc: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, horms@verge.net.au


	Hello,

On Tue, 12 Oct 2021, Florian Westphal wrote:

> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  net/netfilter/ipvs/ip_vs_core.c | 37 +++++++++++++--------------------
>  1 file changed, 14 insertions(+), 23 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index ad5f5e50547f..c43b1eb61580 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -2106,40 +2106,31 @@ static unsigned int
>  ip_vs_forward_icmp(void *priv, struct sk_buff *skb,
>  		   const struct nf_hook_state *state)
>  {
> -	int r;
>  	struct netns_ipvs *ipvs = net_ipvs(state->net);
> -
> -	if (ip_hdr(skb)->protocol != IPPROTO_ICMP)
> -		return NF_ACCEPT;
> +	int r;
>  
>  	/* ipvs enabled in this netns ? */
>  	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
>  		return NF_ACCEPT;
>  
> -	return ip_vs_in_icmp(ipvs, skb, &r, state->hook);
> -}
> -
> +	if (state->pf == NFPROTO_IPV4 &&
> +	    ip_hdr(skb)->protocol != IPPROTO_ICMP) {
> +		return NF_ACCEPT;

	Can we split the above checks?:

	if (state->pf == NFPROTO_IPV4) {
		if (ip_hdr(skb)->protocol != IPPROTO_ICMP) {
			return NF_ACCEPT;
	} else {
#ifdef ...

	We don't want to call ip_vs_fill_iph_skb for IPv4
when IPPROTO_ICMP. Patches 1-3 look ok.

>  #ifdef CONFIG_IP_VS_IPV6
> -static unsigned int
> -ip_vs_forward_icmp_v6(void *priv, struct sk_buff *skb,
> -		      const struct nf_hook_state *state)
> -{
> -	int r;
> -	struct netns_ipvs *ipvs = net_ipvs(state->net);
> -	struct ip_vs_iphdr iphdr;
> +	} else {
> +		struct ip_vs_iphdr iphdr;
>  
> -	ip_vs_fill_iph_skb(AF_INET6, skb, false, &iphdr);
> -	if (iphdr.protocol != IPPROTO_ICMPV6)
> -		return NF_ACCEPT;
> +		ip_vs_fill_iph_skb(AF_INET6, skb, false, &iphdr);
>  
> -	/* ipvs enabled in this netns ? */
> -	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
> -		return NF_ACCEPT;
> +		if (iphdr.protocol != IPPROTO_ICMPV6)
> +			return NF_ACCEPT;
>  
> -	return ip_vs_in_icmp_v6(ipvs, skb, &r, state->hook, &iphdr);
> -}
> +		return ip_vs_in_icmp_v6(ipvs, skb, &r, state->hook, &iphdr);
>  #endif
> +	}
>  
> +	return ip_vs_in_icmp(ipvs, skb, &r, state->hook);
> +}
>  
>  static const struct nf_hook_ops ip_vs_ops4[] = {
>  	/* After packet filtering, change source only for VS/NAT */
> @@ -2224,7 +2215,7 @@ static const struct nf_hook_ops ip_vs_ops6[] = {
>  	/* After packet filtering (but before ip_vs_out_icmp), catch icmp
>  	 * destined for 0.0.0.0/0, which is for incoming IPVS connections */
>  	{
> -		.hook		= ip_vs_forward_icmp_v6,
> +		.hook		= ip_vs_forward_icmp,
>  		.pf		= NFPROTO_IPV6,
>  		.hooknum	= NF_INET_FORWARD,
>  		.priority	= 99,
> -- 
> 2.32.0

Regards

--
Julian Anastasov <ja@ssi.bg>
