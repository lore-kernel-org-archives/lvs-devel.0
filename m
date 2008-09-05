From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 1/2] ipvs: load balance IPv4 connections from a local
 process
Date: Fri, 5 Sep 2008 08:12:08 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0809050750550.2831@u.domain.uli>
References: <20080905013609.GD14128@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080905013609.GD14128@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Malcolm Turnbull <malcolm@loadbalancer.org>, Siim =?iso-8859-1?Q?P=F5der?= <siim@p6drad-teel.net>, Julius Volz <juliusv@google.com>, Vince Busam <vbusam@google.com>


	Hello,

	TCP checksum is not optional, why this change appeared?

On Fri, 5 Sep 2008, Simon Horman wrote:

> Index: lvs-2.6/net/ipv4/ipvs/ip_vs_proto_tcp.c
> ===================================================================
> --- lvs-2.6.orig/net/ipv4/ipvs/ip_vs_proto_tcp.c	2008-09-03 10:56:05.000000000 +1000
> +++ lvs-2.6/net/ipv4/ipvs/ip_vs_proto_tcp.c	2008-09-03 11:24:26.000000000 +1000
> @@ -166,7 +166,7 @@ tcp_snat_handler(struct sk_buff *skb,
>  	tcph->source = cp->vport;
>  
>  	/* Adjust TCP checksums */
> -	if (!cp->app) {
> +	if (!cp->app && (tcph->check != 0)) {
>  		/* Only port and addr are changed, do fast csum update */
>  		tcp_fast_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
>  				     cp->dport, cp->vport);
> @@ -235,7 +235,7 @@ tcp_dnat_handler(struct sk_buff *skb,
>  	/*
>  	 *	Adjust TCP checksums
>  	 */
> -	if (!cp->app) {
> +	if (!cp->app && (tcph->check != 0)) {
>  		/* Only port and addr are changed, do fast csum update */
>  		tcp_fast_csum_update(cp->af, tcph, &cp->vaddr, &cp->daddr,
>  				     cp->vport, cp->dport);
> --

Regards

--
Julian Anastasov <ja@ssi.bg>
