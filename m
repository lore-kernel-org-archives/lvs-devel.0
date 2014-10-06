From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] ipvs: Avoid null-pointer deref in debug code
Date: Mon, 6 Oct 2014 22:01:08 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1410062159290.2258@ja.home.ssi.bg>
References: <20141006073232.GA10073@verge.net.au> <1412610379-6295-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1412610379-6295-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, dan.carpenter@oracle.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, kernel-team@fb.com


	Hello,

On Mon, 6 Oct 2014, Alex Gartrell wrote:

> Use daddr instead of reaching into dest.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Alex Gartrell <agartrell@fb.com>

	Thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_xmit.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 91f17c1..437a366 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -316,7 +316,7 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
>  	if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
>  						  local))) {
>  		IP_VS_DBG_RL("We are crossing local and non-local addresses"
> -			     " daddr=%pI4\n", &dest->addr.ip);
> +			     " daddr=%pI4\n", &daddr);
>  		goto err_put;
>  	}
>  
> @@ -458,7 +458,7 @@ __ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
>  	if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
>  						  local))) {
>  		IP_VS_DBG_RL("We are crossing local and non-local addresses"
> -			     " daddr=%pI6\n", &dest->addr.in6);
> +			     " daddr=%pI6\n", daddr);
>  		goto err_put;
>  	}
>  
> -- 
> Alex Gartrell <agartrell@fb.com>

Regards

--
Julian Anastasov <ja@ssi.bg>
