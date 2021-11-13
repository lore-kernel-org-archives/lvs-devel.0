From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: remove unused variable for ip_vs_new_dest
Date: Sat, 13 Nov 2021 11:56:36 +0200 (EET)
Message-ID: <25e945b7-9027-43cb-f79c-573fdce42a26@ssi.bg>
References: <1636112380-11040-1-git-send-email-zhenggy@chinatelecom.cn>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1636112380-11040-1-git-send-email-zhenggy@chinatelecom.cn>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: GuoYong Zheng <zhenggy@chinatelecom.cn>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, pablo@netfilter.org, netdev@vger.kernel.org, coreteam@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>


	Hello,

On Fri, 5 Nov 2021, GuoYong Zheng wrote:

> The dest variable is not used after ip_vs_new_dest anymore in
> ip_vs_add_dest, do not need pass it to ip_vs_new_dest, remove it.
> 
> Signed-off-by: GuoYong Zheng <zhenggy@chinatelecom.cn>

	Looks good to me for -next, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_ctl.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index e62b40b..494399d 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -959,8 +959,7 @@ static void ip_vs_trash_cleanup(struct netns_ipvs *ipvs)
>   *	Create a destination for the given service
>   */
>  static int
> -ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
> -	       struct ip_vs_dest **dest_p)
> +ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
>  {
>  	struct ip_vs_dest *dest;
>  	unsigned int atype, i;
> @@ -1020,8 +1019,6 @@ static void ip_vs_trash_cleanup(struct netns_ipvs *ipvs)
>  	spin_lock_init(&dest->stats.lock);
>  	__ip_vs_update_dest(svc, dest, udest, 1);
>  
> -	*dest_p = dest;
> -
>  	LeaveFunction(2);
>  	return 0;
>  
> @@ -1095,7 +1092,7 @@ static void ip_vs_trash_cleanup(struct netns_ipvs *ipvs)
>  		/*
>  		 * Allocate and initialize the dest structure
>  		 */
> -		ret = ip_vs_new_dest(svc, udest, &dest);
> +		ret = ip_vs_new_dest(svc, udest);
>  	}
>  	LeaveFunction(2);
>  
> -- 
> 1.8.3.1

Regards

--
Julian Anastasov <ja@ssi.bg>

