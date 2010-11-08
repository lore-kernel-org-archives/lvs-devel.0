From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence support
Date: Mon, 8 Nov 2010 16:15:10 +0100
Message-ID: <201011081615.11335.hans.schillstrom@ericsson.com>
References: <201010291415.35299.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1011061959370.5280@ja.ssi.bg> <20101108062121.GA17685@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101108062121.GA17685@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>

On Monday 08 November 2010 07:21:23 Simon Horman wrote:
[ snip ]

> How about this, which applies on top of
> "IPVS: Add persistence engine to connection entry".
>
> From: Simon Horman <horms@verge.net.au>
> Subject: IPVS: Only match pe_data created by the same pe
>
> Only match persistence engine data if it was
> created by the same persistence engine.
>
> Reported-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Thanks I'll will use that one,
I think it's time to cook a new backup patch,
or do any one have more patches in the pipe ?

>
> Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_conn.c
> ===================================================================
> --- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c	2010-11-08 15:18:57.000000000 +0900
> +++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_conn.c	2010-11-08 15:19:02.000000000 +0900
> @@ -354,7 +354,7 @@ struct ip_vs_conn *ip_vs_ct_in_get(const
>
>  	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
>  		if (p->pe_data && p->pe->ct_match) {
> -			if (p->pe->ct_match(p, cp))
> +			if (p->pe == cp->pe && p->pe->ct_match(p, cp))
>  				goto out;
>  			continue;
>  		}
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
