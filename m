From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] ipvs: ensure RCU read unlock when connection
 flushing and ipvs is disabled
Date: Thu, 16 Jul 2020 20:26:53 +0300 (EEST)
Message-ID: <alpine.LFD.2.23.451.2007162025220.5182@ja.home.ssi.bg>
References: <20200716170314.9617-1-kim.andrewsy@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20200716170314.9617-1-kim.andrewsy@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Sy Kim <kim.andrewsy@gmail.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


	Hello,

On Thu, 16 Jul 2020, Andrew Sy Kim wrote:

> When ipvs is disabled in ip_vs_expire_nodest_conn_flush,
> we should break instead of return so that rcu_read_unlock()
> is run.
> 
> Signed-off-by: Andrew Sy Kim <kim.andrewsy@gmail.com>

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_conn.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index a5e9b2d55e57..a90b8eac16ac 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -1422,7 +1422,7 @@ void ip_vs_expire_nodest_conn_flush(struct netns_ipvs *ipvs)
>  
>  		/* netns clean up started, abort delayed work */
>  		if (!ipvs->enable)
> -			return;
> +			break;
>  	}
>  	rcu_read_unlock();
>  }
> -- 
> 2.20.1

Regards

--
Julian Anastasov <ja@ssi.bg>
