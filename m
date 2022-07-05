From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] netfilter: ipvs: Use the bitmap API to allocate
 bitmaps
Date: Tue, 5 Jul 2022 13:05:54 +0300 (EEST)
Message-ID: <b69d7ba1-22f8-80c3-c870-debd7aaf4cea@ssi.bg>
References: <420d8b70560e8711726ff639f0a55364e212ff26.1656962678.git.christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <420d8b70560e8711726ff639f0a55364e212ff26.1656962678.git.christophe.jaillet@wanadoo.fr>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, linux-kernel <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org


	Hello,

On Mon, 4 Jul 2022, Christophe JAILLET wrote:

> Use bitmap_zalloc()/bitmap_free() instead of hand-writing them.
> 
> It is less verbose and it improves the semantic.
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

	Looks good to me for -next! Thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_mh.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_mh.c b/net/netfilter/ipvs/ip_vs_mh.c
> index da0280cec506..e3d7f5c879ce 100644
> --- a/net/netfilter/ipvs/ip_vs_mh.c
> +++ b/net/netfilter/ipvs/ip_vs_mh.c
> @@ -174,8 +174,7 @@ static int ip_vs_mh_populate(struct ip_vs_mh_state *s,
>  		return 0;
>  	}
>  
> -	table = kcalloc(BITS_TO_LONGS(IP_VS_MH_TAB_SIZE),
> -			sizeof(unsigned long), GFP_KERNEL);
> +	table = bitmap_zalloc(IP_VS_MH_TAB_SIZE, GFP_KERNEL);
>  	if (!table)
>  		return -ENOMEM;
>  
> @@ -227,7 +226,7 @@ static int ip_vs_mh_populate(struct ip_vs_mh_state *s,
>  	}
>  
>  out:
> -	kfree(table);
> +	bitmap_free(table);
>  	return 0;
>  }
>  
> -- 
> 2.34.1

Regards

--
Julian Anastasov <ja@ssi.bg>

