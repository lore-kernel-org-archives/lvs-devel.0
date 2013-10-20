From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 2/3] ipv6: fill rt6i_gateway with nexthop address
Date: Sun, 20 Oct 2013 20:33:04 +0200
Message-ID: <20131020183304.GG27787@order.stressinduktion.org>
References: <1382272985-1528-1-git-send-email-ja@ssi.bg> <1382272985-1528-3-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1382272985-1528-3-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

On Sun, Oct 20, 2013 at 03:43:04PM +0300, Julian Anastasov wrote:
> Make sure rt6i_gateway contains nexthop information in
> all routes returned from lookup or when routes are directly
> attached to skb for generated ICMP packets.
> 
> The effect of this patch should be a faster version of
> rt6_nexthop() and the consideration of local addresses as
> nexthop.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  include/net/ip6_route.h | 6 ++----
>  net/ipv6/ip6_output.c   | 4 ++--
>  net/ipv6/route.c        | 8 ++++++--
>  3 files changed, 10 insertions(+), 8 deletions(-)
> 
> diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
> index 481404a..2b786b7 100644
> --- a/include/net/ip6_route.h
> +++ b/include/net/ip6_route.h
> @@ -194,11 +194,9 @@ static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
>  	       skb_dst(skb)->dev->mtu : dst_mtu(skb_dst(skb));
>  }
>  
> -static inline struct in6_addr *rt6_nexthop(struct rt6_info *rt, struct in6_addr *dest)
> +static inline struct in6_addr *rt6_nexthop(struct rt6_info *rt)
>  {
> -	if (rt->rt6i_flags & RTF_GATEWAY || !ipv6_addr_any(&rt->rt6i_gateway))
> -		return &rt->rt6i_gateway;
> -	return dest;
> +	return &rt->rt6i_gateway;
>  }
>  

Hm, looks good. Will test is soon.

One small remark:

Maybe we can kill rt6_nexthop completly and use rt6i_gateway directly so a
reader does not have to lookup this function.

Thanks,

  Hannes

