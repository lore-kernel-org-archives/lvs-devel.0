From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH nf-next] ipvs: use nf_ct_kill helper
Date: Wed, 3 Aug 2016 10:37:21 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1608031029420.1768@ja.home.ssi.bg>
References: <1470185465-17983-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1470185465-17983-1-git-send-email-fw@strlen.de>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>
Cc: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org


	Hello,

On Wed, 3 Aug 2016, Florian Westphal wrote:

> Once timer is removed from nf_conn struct we cannot open-code
> the removal sequence like this anymore.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  ipvs maintainers:
> 
>  Alternatively I can do a 1:1 replacement of the del_timer() with a
>  test_and_set_bit().
> 
>  Please let me know if you would prefer this,
> 
> diff --git a/net/netfilter/ipvs/ip_vs_nfct.c b/net/netfilter/ipvs/ip_vs_nfct.c
> index f04fd8d..69ce16e 100644
> --- a/net/netfilter/ipvs/ip_vs_nfct.c
> +++ b/net/netfilter/ipvs/ip_vs_nfct.c
> @@ -281,18 +281,7 @@ void ip_vs_conn_drop_conntrack(struct ip_vs_conn *cp)
>  	h = nf_conntrack_find_get(cp->ipvs->net, &nf_ct_zone_dflt, &tuple);
>  	if (h) {
>  		ct = nf_ct_tuplehash_to_ctrack(h);
> -		/* Show what happens instead of calling nf_ct_kill() */
> -		if (del_timer(&ct->timeout)) {

	May be it would be better to preserve the debug
messages, i.e. if we replace del_timer with nf_ct_kill and
remove the ct->timeout.function call below. I assume nf_ct_kill
still returns such bool result. Then the debug messages should
not be affected, I think.

> -			IP_VS_DBG(7, "%s: ct=%p, deleted conntrack timer for tuple="
> -				FMT_TUPLE "\n",
> -				__func__, ct, ARG_TUPLE(&tuple));
> -			if (ct->timeout.function)
> -				ct->timeout.function(ct->timeout.data);
> -		} else {
> -			IP_VS_DBG(7, "%s: ct=%p, no conntrack timer for tuple="
> -				FMT_TUPLE "\n",
> -				__func__, ct, ARG_TUPLE(&tuple));
> -		}
> +		nf_ct_kill(ct);
>  		nf_ct_put(ct);
>  	} else {
>  		IP_VS_DBG(7, "%s: no conntrack for tuple=" FMT_TUPLE "\n",
> -- 
> 2.7.3

Regards

--
Julian Anastasov <ja@ssi.bg>
