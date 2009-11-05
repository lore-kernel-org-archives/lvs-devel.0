From: Simon Kirby <sim@hostway.ca>
Subject: Re: [PATCH] Fix ip_vs_lblcr_full_check to remove unused entries instead of used entries.
Date: Thu, 5 Nov 2009 01:43:58 -0800
Message-ID: <20091105094358.GA19068@hostway.ca>
References: <20091105003801.GA20042@hostway.ca> <20091105013511.GA12797@verge.net.au> <20091105083716.GE5244@hostway.ca>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091105083716.GE5244@hostway.ca>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

D'oh.  Don't apply this -- the argument order makes the original correct.

Simon-

On Thu, Nov 05, 2009 at 12:37:16AM -0800, Simon Kirby wrote:

> Tested with real packets -- seems to work.
> 
> Signed-off-by: Simon Kirby <sim@hostway.ca>
> 
> ---
>  net/netfilter/ipvs/ip_vs_lblcr.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
> index 715b57f..937743f 100644
> --- a/net/netfilter/ipvs/ip_vs_lblcr.c
> +++ b/net/netfilter/ipvs/ip_vs_lblcr.c
> @@ -432,7 +432,7 @@ static inline void ip_vs_lblcr_full_check(struct ip_vs_service *svc)
>  
>  		write_lock(&svc->sched_lock);
>  		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
> -			if (time_after(en->lastuse+sysctl_ip_vs_lblcr_expiration,
> +			if (time_before(en->lastuse+sysctl_ip_vs_lblcr_expiration,
>  				       now))
>  				continue;
>  
> -- 
> 1.6.5.2
