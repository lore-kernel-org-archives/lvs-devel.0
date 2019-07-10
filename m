From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: remove unnecessary space
Date: Wed, 10 Jul 2019 10:06:09 +0200
Message-ID: <20190710080609.smxjqe2d5jyro4hv@verge.net.au>
References: <20190710074552.74394-1-xingwu.yang@gmail.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20190710074552.74394-1-xingwu.yang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: yangxingwu <xingwu.yang@gmail.com>
Cc: wensong@linux-vs.org, ja@ssi.bg, pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Wed, Jul 10, 2019 at 03:45:52PM +0800, yangxingwu wrote:
> this patch removes the extra space.
> 
> Signed-off-by: yangxingwu <xingwu.yang@gmail.com>

Thanks, this looks good to me.

Acked-by: Simon Horman <horms@verge.net.au>

Pablo, please consider including this in nf-next.


> ---
>  net/netfilter/ipvs/ip_vs_mh.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_mh.c b/net/netfilter/ipvs/ip_vs_mh.c
> index 94d9d34..98e358e 100644
> --- a/net/netfilter/ipvs/ip_vs_mh.c
> +++ b/net/netfilter/ipvs/ip_vs_mh.c
> @@ -174,8 +174,8 @@ static int ip_vs_mh_populate(struct ip_vs_mh_state *s,
>  		return 0;
>  	}
>  
> -	table =  kcalloc(BITS_TO_LONGS(IP_VS_MH_TAB_SIZE),
> -			 sizeof(unsigned long), GFP_KERNEL);
> +	table =	kcalloc(BITS_TO_LONGS(IP_VS_MH_TAB_SIZE),
> +			sizeof(unsigned long), GFP_KERNEL);
>  	if (!table)
>  		return -ENOMEM;
>  
> -- 
> 1.8.3.1
> 
