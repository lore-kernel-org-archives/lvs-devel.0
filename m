From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: ip_vs_pe.c, use strncmp to be safe.
Date: Thu, 28 Oct 2010 16:56:50 +0900
Message-ID: <20101028075650.GC5305@verge.net.au>
References: <1288191900-24613-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1288191900-24613-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: lvs-devel@vger.kernel.org, ja@ssi.bg, wensong@linux-vs.org, Patrick McHardy <kaber@trash.net>

On Wed, Oct 27, 2010 at 05:05:00PM +0200, Hans Schillstrom wrote:
> With pe data traveling between master and backup,
> strcmp should not be used. 
> How knows what size it will have in future.
> 
> To be safe use strncmp.

Hi Hans,

I'm not entirely convinced this is necessary, but
its better to be safe than sorry.

> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>

Patrick, I assume that nf-next-2.6 is currently closed.
I'll push this to you once it opens again.

> ---
>  net/netfilter/ipvs/ip_vs_pe.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_pe.c b/net/netfilter/ipvs/ip_vs_pe.c
> index 3414af7..baab44f 100644
> --- a/net/netfilter/ipvs/ip_vs_pe.c
> +++ b/net/netfilter/ipvs/ip_vs_pe.c
> @@ -46,7 +46,7 @@ ip_vs_pe_getbyname(const char *pe_name)
>  			/* This pe is just deleted */
>  			continue;
>  		}
> -		if (strcmp(pe_name, pe->name)==0) {
> +		if (strncmp(pe_name, pe->name, IP_VS_PENAME_MAXLEN )==0) {
>  			/* HIT */
>  			spin_unlock_bh(&ip_vs_pe_lock);
>  			return pe;
> @@ -104,7 +104,7 @@ int register_ip_vs_pe(struct ip_vs_pe *pe)
>  	 * in the pe list.
>  	 */
>  	list_for_each_entry(tmp, &ip_vs_pe, n_list) {
> -		if (strcmp(tmp->name, pe->name) == 0) {
> +		if (strncmp(tmp->name, pe->name, IP_VS_PENAME_MAXLEN) == 0) {
>  			spin_unlock_bh(&ip_vs_pe_lock);
>  			ip_vs_use_count_dec();
>  			pr_err("%s(): [%s] pe already existed "
> -- 
> 1.6.0.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
