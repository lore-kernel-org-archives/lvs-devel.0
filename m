From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH nf-next] netfilter: ipvs: do not printk on netns
 creation
Date: Fri, 2 Apr 2021 06:07:23 +0300 (EEST)
Message-ID: <33419d34-c96-4eb5-b633-c73d5bcf4ee@ssi.bg>
References: <20210330064232.11960-1-fw@strlen.de>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20210330064232.11960-1-fw@strlen.de>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>
Cc: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>


	Hello,

On Tue, 30 Mar 2021, Florian Westphal wrote:

> This causes dmesg spew during normal operation, so remove this.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

	Looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_ftp.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> index cf925906f59b..ef1f45e43b63 100644
> --- a/net/netfilter/ipvs/ip_vs_ftp.c
> +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> @@ -591,8 +591,6 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
>  		ret = register_ip_vs_app_inc(ipvs, app, app->protocol, ports[i]);
>  		if (ret)
>  			goto err_unreg;
> -		pr_info("%s: loaded support on port[%d] = %u\n",
> -			app->name, i, ports[i]);
>  	}
>  	return 0;
>  
> -- 
> 2.26.3

Regards

--
Julian Anastasov <ja@ssi.bg>

