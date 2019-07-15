From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] ipvs: remove unnecessary space
Date: Mon, 15 Jul 2019 09:57:03 +0200
Message-ID: <20190715075703.ak6nk3sbnqksjh72@salvia>
References: <80a4e132f3be48899904eccdc023f5c53229840b.camel@perches.com>
 <20190712130721.7168-1-xingwu.yang@gmail.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20190712130721.7168-1-xingwu.yang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: yangxingwu <xingwu.yang@gmail.com>
Cc: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, joe@perches.com

On Fri, Jul 12, 2019 at 09:07:21PM +0800, yangxingwu wrote:
> this patch removes the extra space and use bitmap_zalloc instead
> 
> Signed-off-by: yangxingwu <xingwu.yang@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_mh.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_mh.c b/net/netfilter/ipvs/ip_vs_mh.c
> index 94d9d34..3229867 100644
> --- a/net/netfilter/ipvs/ip_vs_mh.c
> +++ b/net/netfilter/ipvs/ip_vs_mh.c
> @@ -174,8 +174,7 @@ static int ip_vs_mh_populate(struct ip_vs_mh_state *s,
>  		return 0;
>  	}
>  
> -	table =  kcalloc(BITS_TO_LONGS(IP_VS_MH_TAB_SIZE),
> -			 sizeof(unsigned long), GFP_KERNEL);
> +	table = bitmap_zalloc(IP_VS_MH_TAB_SIZE, GFP_KERNEL);

By doing:

        git grep "=  " ...

on the netfilter folders, I see more of these, it would be good if you
fix them at once or, probably, you want to use coccinelle for this.

Thanks.
