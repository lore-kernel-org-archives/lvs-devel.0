From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH nf-next v2] ipvs: use nf_ct_kill helper
Date: Wed, 3 Aug 2016 21:37:16 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1608032134370.1914@ja.home.ssi.bg>
References: <1470230488-302-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1470230488-302-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>
Cc: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>


	Hello,

On Wed, 3 Aug 2016, Florian Westphal wrote:

> Once timer is removed from nf_conn struct we cannot open-code
> the removal sequence anymore.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

	Looks good to me,

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  V2: keep debug messages around.
> 
>  net/netfilter/ipvs/ip_vs_nfct.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_nfct.c b/net/netfilter/ipvs/ip_vs_nfct.c
> index f04fd8d..fc230d9 100644
> --- a/net/netfilter/ipvs/ip_vs_nfct.c
> +++ b/net/netfilter/ipvs/ip_vs_nfct.c
> @@ -281,13 +281,10 @@ void ip_vs_conn_drop_conntrack(struct ip_vs_conn *cp)
>  	h = nf_conntrack_find_get(cp->ipvs->net, &nf_ct_zone_dflt, &tuple);
>  	if (h) {
>  		ct = nf_ct_tuplehash_to_ctrack(h);
> -		/* Show what happens instead of calling nf_ct_kill() */
> -		if (del_timer(&ct->timeout)) {
> -			IP_VS_DBG(7, "%s: ct=%p, deleted conntrack timer for tuple="
> +		if (nf_ct_kill(ct)) {
> +			IP_VS_DBG(7, "%s: ct=%p, deleted conntrack for tuple="
>  				FMT_TUPLE "\n",
>  				__func__, ct, ARG_TUPLE(&tuple));
> -			if (ct->timeout.function)
> -				ct->timeout.function(ct->timeout.data);
>  		} else {
>  			IP_VS_DBG(7, "%s: ct=%p, no conntrack timer for tuple="
>  				FMT_TUPLE "\n",
> -- 
> 2.7.3

Regards

--
Julian Anastasov <ja@ssi.bg>
