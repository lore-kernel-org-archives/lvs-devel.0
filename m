From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: no need to update skb route entry for local
 destination packets.
Date: Mon, 30 Sep 2019 21:49:38 +0300 (EEST)
Message-ID: <alpine.LFD.2.21.1909302146530.2706@ja.home.ssi.bg>
References: <20190930051455.GA20692@toolchain>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20190930051455.GA20692@toolchain>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: zhang kai <zhangkaiheb@126.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org


	Hello,

On Mon, 30 Sep 2019, zhang kai wrote:

> In the end of function __ip_vs_get_out_rt/__ip_vs_get_out_rt_v6,the
> 'local' variable is always zero.
> 
> Signed-off-by: zhang kai <zhangkaiheb@126.com>

	Looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

	Simon, this is for -next kernels...

> ---
>  net/netfilter/ipvs/ip_vs_xmit.c | 18 ++++++------------
>  1 file changed, 6 insertions(+), 12 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 9c464d24beec..037c7c91044e 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -407,12 +407,9 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
>  		goto err_put;
>  
>  	skb_dst_drop(skb);
> -	if (noref) {
> -		if (!local)
> -			skb_dst_set_noref(skb, &rt->dst);
> -		else
> -			skb_dst_set(skb, dst_clone(&rt->dst));
> -	} else
> +	if (noref)
> +		skb_dst_set_noref(skb, &rt->dst);
> +	else
>  		skb_dst_set(skb, &rt->dst);
>  
>  	return local;
> @@ -574,12 +571,9 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
>  		goto err_put;
>  
>  	skb_dst_drop(skb);
> -	if (noref) {
> -		if (!local)
> -			skb_dst_set_noref(skb, &rt->dst);
> -		else
> -			skb_dst_set(skb, dst_clone(&rt->dst));
> -	} else
> +	if (noref)
> +		skb_dst_set_noref(skb, &rt->dst);
> +	else
>  		skb_dst_set(skb, &rt->dst);
>  
>  	return local;
> -- 
> 2.17.1

Regards
