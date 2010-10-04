From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch v3 00/12] IPVS: SIP Persistence Engine
Date: Mon, 4 Oct 2010 17:07:04 +0900
Message-ID: <20101004080704.GA10230@verge.net.au>
References: <20101002023056.536217499@akiko.akashicho.tokyo.vergenet.net>
 <alpine.LFD.2.00.1010021155520.2055@ja.ssi.bg>
 <20101003050725.GA5817@verge.net.au>
 <alpine.LFD.2.00.1010032356550.2597@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1010032356550.2597@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Mon, Oct 04, 2010 at 12:08:32AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sun, 3 Oct 2010, Simon Horman wrote:
> 
> >>>REVISIONS
> >>>
> >>>This is v3 of the patch series with addresses serveral problems
> >>>raised by Julian Anastasov on the lvs-devel mailing list.
> >>
> >>	No other obvious problems in v3 1-12. So,
> >>Acked-by: Julian Anastasov <ja@ssi.bg>
> >
> >Thanks.
> >
> >
> >>	May be next days I'll test my changes on top of PE v3
> >
> >I think that could save a bit of porting work later
> >and perhaps you might notice some more bugs too :-)
> 
> 	Appending fixes from my tests:
> 
> - initialize compat structures to avoid crash in
> ip_vs_add_service for pe_name
> 
> - fix ip_vs_conn_out_get_proto to properly check the
> ip_vs_conn_fill_param_proto result
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
> 
> diff -urp net-next-2.6-e548833-test_pe3/linux/net/netfilter/ipvs/ip_vs_conn.c linux/net/netfilter/ipvs/ip_vs_conn.c
> --- net-next-2.6-e548833-test_pe3/linux/net/netfilter/ipvs/ip_vs_conn.c	2010-10-03 23:08:47.928356111 +0300
> +++ linux/net/netfilter/ipvs/ip_vs_conn.c	2010-10-03 23:32:47.309353117 +0300
> @@ -439,7 +439,7 @@ ip_vs_conn_out_get_proto(int af, const s
>  {
>  	struct ip_vs_conn_param p;
> 
> -	if (!ip_vs_conn_fill_param_proto(af, skb, iph, proto_off, inverse, &p))
> +	if (ip_vs_conn_fill_param_proto(af, skb, iph, proto_off, inverse, &p))
>  		return NULL;
> 
>  	return ip_vs_conn_out_get(&p);

Thanks, I'll roll that into "IPVS: Add struct ip_vs_conn_param" and repost.

> diff -urp net-next-2.6-e548833-test_pe3/linux/net/netfilter/ipvs/ip_vs_ctl.c linux/net/netfilter/ipvs/ip_vs_ctl.c
> --- net-next-2.6-e548833-test_pe3/linux/net/netfilter/ipvs/ip_vs_ctl.c	2010-10-03 22:33:53.881353731 +0300
> +++ linux/net/netfilter/ipvs/ip_vs_ctl.c	2010-10-03 22:49:48.279355927 +0300
> @@ -2057,6 +2057,7 @@ static const unsigned char set_arglen[SE
>  static void ip_vs_copy_usvc_compat(struct ip_vs_service_user_kern *usvc,
>  				  struct ip_vs_service_user *usvc_compat)
>  {
> +	memset(usvc, 0, sizeof(*usvc));
>  	usvc->af		= AF_INET;
>  	usvc->protocol		= usvc_compat->protocol;
>  	usvc->addr.ip		= usvc_compat->addr;
> @@ -2074,6 +2075,7 @@ static void ip_vs_copy_usvc_compat(struc
>  static void ip_vs_copy_udest_compat(struct ip_vs_dest_user_kern *udest,
>  				   struct ip_vs_dest_user *udest_compat)
>  {
> +	memset(udest, 0, sizeof(*udest));
>  	udest->addr.ip		= udest_compat->addr;
>  	udest->port		= udest_compat->port;
>  	udest->conn_flags	= udest_compat->conn_flags;
> 

Thanks, I'll add this as a new patch the persistence engine series,
though unless I'm mistaken its resolves existing concerns not new ones.

