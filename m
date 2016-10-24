From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs does not decrement IP ttl
Date: Mon, 24 Oct 2016 22:19:13 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1610242200270.2276@ja.home.ssi.bg>
References: <1477329478-26305-1-git-send-email-dwip@linux.vnet.ibm.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1477329478-26305-1-git-send-email-dwip@linux.vnet.ibm.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dwip Banerjee <dwip@linux.vnet.ibm.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Mon, 24 Oct 2016, Dwip Banerjee wrote:

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
> ---
>  net/netfilter/ipvs/ip_vs_xmit.c |   55 +++++++++++++++++++++++++++++++++++++++
>  1 files changed, 55 insertions(+), 0 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 01d3d89..8b11e92 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -254,6 +254,55 @@ static inline bool ensure_mtu_is_adequate(struct netns_ipvs *ipvs, int skb_af,
>  	return true;
>  }
>  
> +static inline bool decrement_ttl(int skb_af, struct sk_buff *skb)
> +{
> +#ifdef CONFIG_IP_VS_IPV6
> +	if (skb_af == AF_INET6) {
> +		struct ipv6hdr *hdr = ipv6_hdr(skb);
> +		struct dst_entry *dst = skb_dst(skb);
> +		struct net *net = dev_net(dst->dev);

	dev_net should not be used anymore, you can check
the latest changes by Eric W. Biederman:

git log -p -- net/netfilter/ipvs/ip_vs_xmit.c

	Better to use ipvs->net.

> +
> +		/* check and decrement ttl */
> +		if (hdr->hop_limit <= 1) {
> +			/* Force OUTPUT device used as source address */
> +			skb->dev = dst->dev;
> +			icmpv6_send(skb, ICMPV6_TIME_EXCEED,
> +					 ICMPV6_EXC_HOPLIMIT, 0);
> +			__IP6_INC_STATS(net, ip6_dst_idev(dst),
> +					IPSTATS_MIB_INHDRERRORS);
> +
> +			return false;
> +		}
> +
> +		/* don't propagate ttl change to cloned packets */
> +		if (!skb_make_writable(skb, sizeof(struct ipv6hdr)))
> +			return false;

	Now I see that using hdr after skb_make_writable is
risky because skb data can be reallocated. Better to use
ip[v6]_hdr(skb) for all places, i.e. without any hdr/iph ptrs.

> +
> +		hdr->hop_limit--;
> +	} else
> +#endif
> +	{
> +		struct iphdr  *iph = ip_hdr(skb);
> +
> +		if (iph->ttl <= 1) {
> +			/* Tell the sender its packet died... */
> +			__IP_INC_STATS(dev_net(skb_dst(skb)->dev),
> +				       IPSTATS_MIB_INHDRERRORS);
> +			icmp_send(skb, ICMP_TIME_EXCEEDED, ICMP_EXC_TTL, 0);
> +			return false;
> +		}
> +
> +		/* don't propagate ttl change to cloned packets */
> +		if (!skb_make_writable(skb, sizeof(struct iphdr)))
> +			return false;
> +
> +		/* Decrease ttl */
> +		ip_decrease_ttl(iph);
> +	}
> +
> +	return true;
> +}
> +

Regards

--
Julian Anastasov <ja@ssi.bg>
