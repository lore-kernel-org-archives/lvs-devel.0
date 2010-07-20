From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch] ipvsadm: Don't report persistentconns as activeconns
Date: Tue, 20 Jul 2010 17:10:58 +0900
Message-ID: <20100720081058.GC19483@verge.net.au>
References: <20100221220751.GF5712@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100221220751.GF5712@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel <lvs-devel@vger.kernel.org>
Cc: Wensong Zhang <wensong@linux-vs.org>, Nigel Kukard <nkukard@lbsd.net>

On Mon, Feb 22, 2010 at 09:07:52AM +1100, Simon Horman wrote:
> This fixes what appears to be a typo in the netlink client code
> whereby the activeconns is read as activeconns and then
> overwritten by persistentconns. The result is that the active
> connection count reported by ipvsadm -L is wrong if the
> code is compiled to use the netlink interface.
> 
> Tested-by: Nigel Kukard <nkukard@lbsd.net>
> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> --- 
> 
> Wensong, please consider applying this patch to ipvsadm.

Wensong, Ping.

> Index: ipvsadm-1.25/libipvs/libipvs.c
> ===================================================================
> --- ipvsadm-1.25.orig/libipvs/libipvs.c	2010-02-18 16:57:46.000000000 +0900
> +++ ipvsadm-1.25/libipvs/libipvs.c	2010-02-18 16:57:49.000000000 +0900
> @@ -747,7 +747,7 @@ static int ipvs_dests_parse_cb(struct nl
>  	d->entrytable[i].l_threshold = nla_get_u32(dest_attrs[IPVS_DEST_ATTR_L_THRESH]);
>  	d->entrytable[i].activeconns = nla_get_u32(dest_attrs[IPVS_DEST_ATTR_ACTIVE_CONNS]);
>  	d->entrytable[i].inactconns = nla_get_u32(dest_attrs[IPVS_DEST_ATTR_INACT_CONNS]);
> -	d->entrytable[i].activeconns = nla_get_u32(dest_attrs[IPVS_DEST_ATTR_PERSIST_CONNS]);
> +	d->entrytable[i].persistconns = nla_get_u32(dest_attrs[IPVS_DEST_ATTR_PERSIST_CONNS]);
>  	d->entrytable[i].af = d->af;
>  
>  	if (ipvs_parse_stats(&(d->entrytable[i].stats),
> 
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
