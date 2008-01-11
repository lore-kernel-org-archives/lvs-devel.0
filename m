From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] Transparent proxy support for LVS with localnode and
	realservers (WORKING)
Date: Fri, 11 Jan 2008 13:28:34 +0900
Message-ID: <20080111042832.GG13135@verge.net.au>
References: <C704FCFC-455C-4CFC-AB8C-51604D3CF844@endian.com> <Pine.LNX.4.64.0801100432180.28592@wm7d.net> <1C7F5BEB-8169-40DA-B7A2-2B4BB85B6FFD@endian.com> <20080111041426.GF13135@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080111041426.GF13135@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Raphael Vallazza <raphael@endian.com>
Cc: LVS Devel <lvs-devel@vger.kernel.org>

Sorry, I was a bit to fast on the trigger-button when I sent the
previous patch. I checked that it applied against net-2.4.25, but I
hadn't yet checked that it compiled. I have now done that for both of
the new options and also checked that it boots, though I have not
checked that it does anything sensible with packets.

> Index: net-2.6.25/net/ipv4/ipvs/ip_vs_core.c
> ===================================================================
> --- net-2.6.25.orig/net/ipv4/ipvs/ip_vs_core.c	2008-01-11 12:57:55.000000000 +0900
> +++ net-2.6.25/net/ipv4/ipvs/ip_vs_core.c	2008-01-11 13:00:09.000000000 +0900
> @@ -1026,6 +1026,7 @@ ip_vs_forward_icmp(unsigned int hooknum,
>  
>  
>  static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
> +#ifdef CONFIG_IP_VS_INPUT_LOCAL_IN
>  	/* After packet filtering, forward packet through VS/DR, VS/TUN,
>  	 * or VS/NAT(change destination), so that filtering rules can be
>  	 * applied to IPVS. */
> @@ -1036,6 +1037,20 @@ static struct nf_hook_ops ip_vs_ops[] __
>  		.hooknum        = NF_INET_LOCAL_IN,
>  		.priority       = 100,
>  	},
> +#endif
> +#ifdef CONFIG_IP_VS_INPUT_PRE_ROUTING
> +	/* Intercept incoming connections before DNAT and input filtering
> +	 * has been applied, this enables ransparent proxying on realnodes
> +	 * and localnode. Hook right after MANGLE and before NAT_DST.
> +	 */
> +	static struct nf_hook_ops ip_vs_in_ops = {

This should be:
	ip_vs_in_ops = {

> +		.hook		= ip_vs_in,
> +		.owner		= THIS_MODULE,
> +		.pf		= PF_INET,
> +		.hooknum	= NF_IP_PRE_ROUTING,

This should be:
		.hooknum	= NF_INET_PRE_ROUTING,

> +		.priority	= NF_IP_PRI_NAT_DST - 1,

> +	},
> +#endif
>  	/* After packet filtering, change source only for VS/NAT */
>  	{
>  		.hook		= ip_vs_out,

If you could incoporate those changes, write a comment (the intial mail
will do) and add a sign-off, then I'll send the patch up to net-dev for
further review. If you could also test against net-2.4.25, that would
be awsome.

-- 
Horms

