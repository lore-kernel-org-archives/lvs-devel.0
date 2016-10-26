From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH V3] ipvs does not decrement IP ttl
Date: Wed, 26 Oct 2016 21:35:18 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1610262131150.1829@ja.home.ssi.bg>
References: <1477502082-24852-1-git-send-email-dwip@linux.vnet.ibm.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1477502082-24852-1-git-send-email-dwip@linux.vnet.ibm.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dwip Banerjee <dwip@linux.vnet.ibm.com>
Cc: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>


	Hello,

On Wed, 26 Oct 2016, Dwip Banerjee wrote:

> We decrement the IP ttl in all the modes in order to prevent infinite
> route loops. The changes were done based on Julian Anastasov's
> suggestions in a prior thread.
> 
> The ttl based check/discard and the actual decrement are done in
> __ip_vs_get_out_rt() and in __ip_vs_get_out_rt_v6(), for the IPv6
> case. decrement_ttl() implements the actual functionality for the
> two cases.
> 
> 
> Signed-off-by: Dwip Banerjee <dwip@linux.vnet.ibm.com>

	Looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

	Simon, please apply to ipvs-next tree, may be
after fixing the Subject line to contains ipvs: prefix.

> ---
>  net/netfilter/ipvs/ip_vs_xmit.c |   54 +++++++++++++++++++++++++++++++++++++++
>  1 files changed, 54 insertions(+), 0 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 01d3d89..4e1a98f 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -254,6 +254,54 @@ static inline bool ensure_mtu_is_adequate(struct netns_ipvs *ipvs, int skb_af,
>  	return true;
>  }
>  
> +static inline bool decrement_ttl(struct netns_ipvs *ipvs,
> +				 int skb_af,
> +				 struct sk_buff *skb)
> +{
> +	struct net *net = ipvs->net;
> +
> +#ifdef CONFIG_IP_VS_IPV6
> +	if (skb_af == AF_INET6) {
> +		struct dst_entry *dst = skb_dst(skb);
> +
> +		/* check and decrement ttl */
> +		if (ipv6_hdr(skb)->hop_limit <= 1) {
> +			/* Force OUTPUT device used as source address */
> +			skb->dev = dst->dev;
> +			icmpv6_send(skb, ICMPV6_TIME_EXCEED,
> +				    ICMPV6_EXC_HOPLIMIT, 0);
> +			__IP6_INC_STATS(net, ip6_dst_idev(dst),
> +					IPSTATS_MIB_INHDRERRORS);
> +
> +			return false;
> +		}
> +
> +		/* don't propagate ttl change to cloned packets */
> +		if (!skb_make_writable(skb, sizeof(struct ipv6hdr)))
> +			return false;
> +
> +		ipv6_hdr(skb)->hop_limit--;
> +	} else
> +#endif
> +	{
> +		if (ip_hdr(skb)->ttl <= 1) {
> +			/* Tell the sender its packet died... */
> +			__IP_INC_STATS(net, IPSTATS_MIB_INHDRERRORS);
> +			icmp_send(skb, ICMP_TIME_EXCEEDED, ICMP_EXC_TTL, 0);
> +			return false;
> +		}
> +
> +		/* don't propagate ttl change to cloned packets */
> +		if (!skb_make_writable(skb, sizeof(struct iphdr)))
> +			return false;
> +
> +		/* Decrease ttl */
> +		ip_decrease_ttl(ip_hdr(skb));
> +	}
> +
> +	return true;
> +}
> +
>  /* Get route to destination or remote server */
>  static int
>  __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
> @@ -326,6 +374,9 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
>  		return local;
>  	}
>  
> +	if (!decrement_ttl(ipvs, skb_af, skb))
> +		goto err_put;
> +
>  	if (likely(!(rt_mode & IP_VS_RT_MODE_TUNNEL))) {
>  		mtu = dst_mtu(&rt->dst);
>  	} else {
> @@ -473,6 +524,9 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
>  		return local;
>  	}
>  
> +	if (!decrement_ttl(ipvs, skb_af, skb))
> +		goto err_put;
> +
>  	/* MTU checking */
>  	if (likely(!(rt_mode & IP_VS_RT_MODE_TUNNEL)))
>  		mtu = dst_mtu(&rt->dst);
> -- 
> 1.7.1

Regards

--
Julian Anastasov <ja@ssi.bg>
