From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 06/34] ipvs: no need to reroute anymore on DNAT over loopback
Date: Fri, 29 Mar 2013 18:44:06 +0400
Message-ID: <5155A8B6.9030303@cogentembedded.com>
References: <1364530311-11512-1-git-send-email-horms@verge.net.au> <1364530311-11512-7-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1364530311-11512-7-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Hello.

On 29-03-2013 8:11, Simon Horman wrote:

> From: Julian Anastasov <ja@ssi.bg>

> After commit 70e7341673 (ipv4: Show that ip_send_reply()
> is purely unicast routine.) we do not need to reroute DNAT-ed
> traffic over loopback because reply uses iph daddr and not
> rt_spec_dst.

> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> Signed-off by: Hans Schillstrom <hans@schillstrom.com>
> Signed-off-by: Simon Horman <horms@verge.net.au>
> ---
>   net/netfilter/ipvs/ip_vs_xmit.c |   58 ++-------------------------------------
>   1 file changed, 2 insertions(+), 56 deletions(-)

> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 6448a2e..c942d36 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
[...]
> @@ -635,16 +597,8 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
>   		/* drop old route */
>   		skb_dst_drop(skb);
>   		skb_dst_set(skb, &rt->dst);
> -	} else {
> +	} else

    {} should be kept after *else*, according to Documentation/CodingStyle, 
chapter 3.

>   		ip_rt_put(rt);
> -		/*
> -		 * Some IPv4 replies get local address from routes,
> -		 * not from iph, so while we DNAT after routing
> -		 * we need this second input/output route.
> -		 */
> -		if (!__ip_vs_reroute_locally(skb))
> -			goto tx_error;
> -	}
>
>   	IP_VS_DBG_PKT(10, AF_INET, pp, skb, 0, "After DNAT");
>
> @@ -1269,16 +1223,8 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
>   		/* drop the old route when skb is not shared */
>   		skb_dst_drop(skb);
>   		skb_dst_set(skb, &rt->dst);
> -	} else {
> +	} else

    Same here.

>   		ip_rt_put(rt);
> -		/*
> -		 * Some IPv4 replies get local address from routes,
> -		 * not from iph, so while we DNAT after routing
> -		 * we need this second input/output route.
> -		 */
> -		if (!__ip_vs_reroute_locally(skb))
> -			goto tx_error;
> -	}
>
>   	/* Another hack: avoid icmp_send in ip_fragment */
>   	skb->local_df = 1;
>

