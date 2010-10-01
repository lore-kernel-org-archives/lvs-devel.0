From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [patch v2 07/12] [PATCH 07/12] IPVS: Add struct ip_vs_pe
Date: Sat, 2 Oct 2010 00:45:52 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010020030590.2320@ja.ssi.bg>
References: <20101001143517.645421976@akiko.akashicho.tokyo.vergenet.net> <20101001143942.297844368@akiko.akashicho.tokyo.vergenet.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101001143942.297844368@akiko.akashicho.tokyo.vergenet.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Patrick McHardy <kaber@trash.net>


 	Hello,

On Fri, 1 Oct 2010, Simon Horman wrote:

> ===================================================================
> --- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c	2010-10-01 22:48:42.000000000 +0900
> +++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_conn.c	2010-10-01 22:49:15.000000000 +0900
> @@ -148,6 +148,29 @@ static unsigned int ip_vs_conn_hashkey(i
> 		& ip_vs_conn_tab_mask;
> }
>
> +static unsigned int ip_vs_conn_hashkey_param(const struct ip_vs_conn_param *p)
> +{
> +	if (p->pe && p->pe->hashkey_raw)
> +		return p->pe->hashkey_raw(p, ip_vs_conn_rnd) &
> +			ip_vs_conn_tab_mask;
> +	return ip_vs_conn_hashkey(p->af, p->protocol, p->caddr, p->cport);
> +}
> +
> +static unsigned int ip_vs_conn_hashkey_conn(const struct ip_vs_conn *cp)
> +{
> +	struct ip_vs_conn_param p;
> +
> +	ip_vs_conn_fill_param(cp->af, cp->protocol, &cp->caddr, cp->cport,
> +			      NULL, 0, &p);
> +

 	cp->dest is optional, line should be
'if (cp->dest && cp->dest->svc->pe) {':

> +	if (cp->dest->svc->pe) {
> +		p.pe = cp->dest->svc->pe;
> +		p.pe_data = cp->pe_data;
> +		p.pe_data_len = cp->pe_data_len;
> +	}
> +
> +	return ip_vs_conn_hashkey_param(&p);
> +}
>


> @@ -359,7 +387,7 @@ struct ip_vs_conn *ip_vs_conn_out_get(co
> 	/*
> 	 *	Check for "full" addressed entries
> 	 */

 	Here ip_vs_conn_out_get expects client data in
p->vaddr and p->vport (was daddr before) but ip_vs_conn_hashkey_param 
hashes client data from p->caddr and p->cport:

> -	hash = ip_vs_conn_hashkey(p->af, p->protocol, p->vaddr, p->vport);
> +	hash = ip_vs_conn_hashkey_param(p);
>
> 	ct_read_lock(hash);

Regards

--
Julian Anastasov <ja@ssi.bg>
