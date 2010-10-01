From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [patch v2 04/12] [PATCH 04/12] IPVS: Add struct
 ip_vs_conn_param
Date: Fri, 1 Oct 2010 23:58:04 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010012347290.2194@ja.ssi.bg>
References: <20101001143517.645421976@akiko.akashicho.tokyo.vergenet.net> <20101001143942.035496196@akiko.akashicho.tokyo.vergenet.net>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101001143942.035496196@akiko.akashicho.tokyo.vergenet.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Patrick McHardy <kaber@trash.net>


 	Hello,

On Fri, 1 Oct 2010, Simon Horman wrote:

> +static int
> +ip_vs_conn_fill_param_proto(int af, const struct sk_buff *skb,
> +			    const struct ip_vs_iphdr *iph,
> +			    unsigned int proto_off, int inverse,
> +			    struct ip_vs_conn_param *p)
> +{
> +	__be16 _ports[2], *pptr;
> +
> +	pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
> +	if (pptr == NULL)
> +		return 1;
> +
> +	if (likely(!inverse))
> +		ip_vs_conn_fill_param(af, iph->protocol, &iph->saddr, pptr[0],
> +				      &iph->daddr, pptr[1], p);
> +	else

 	Next line is wrong for inverse=1, must be
 	&iph->daddr, pptr[1], &iph->saddr, pptr[0]

> +		ip_vs_conn_fill_param(af, iph->protocol, &iph->saddr, pptr[0],
> +				      &iph->daddr, pptr[1], p);
> +	return 0;
> +}
> +

 	May be comments before ip_vs_conn_out_get should be
changed:

> @@ -341,9 +351,7 @@ struct ip_vs_conn *ip_vs_ct_in_get
>  *	s_addr, s_port: pkt source address (inside host)
>  *	d_addr, d_port: pkt dest address (foreign host)
>  */
> -struct ip_vs_conn *ip_vs_conn_out_get
> -(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
> - const union nf_inet_addr *d_addr, __be16 d_port)
> +struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)


> ===================================================================
> --- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_core.c	2010-10-01 22:06:23.000000000 +0900
> +++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_core.c	2010-10-01 22:10:46.000000000 +0900
> @@ -193,14 +193,11 @@ ip_vs_sched_persist(struct ip_vs_service
> 	struct ip_vs_iphdr iph;
> 	struct ip_vs_dest *dest;
> 	struct ip_vs_conn *ct;
> -	int protocol = iph.protocol;
> 	__be16 dport = 0;		/* destination port to forward */
> -	__be16 vport = 0;		/* virtual service port */
> 	unsigned int flags;
> 	union nf_inet_addr snet;	/* source network of the client,
> 					   after masking */
> -	const union nf_inet_addr fwmark = { .ip = htonl(svc->fwmark) };
> -	const union nf_inet_addr *vaddr = &iph.daddr;
> +	struct ip_vs_conn_param param;
>
> 	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
>
> @@ -232,6 +229,11 @@ ip_vs_sched_persist(struct ip_vs_service
> 	 * is created for other persistent services.
> 	 */
> 	{
> +		int protocol = iph.protocol;
> +		const union nf_inet_addr *vaddr = &iph.daddr;
> +		const union nf_inet_addr fwmark = { .ip = htonl(svc->fwmark) };
> +		__be16 vport = 0;
> +
> 		if (ports[1] == svc->port) {
> 			/* non-FTP template:
> 			 * <protocol, caddr, 0, vaddr, vport, daddr, dport>
> @@ -253,11 +255,12 @@ ip_vs_sched_persist(struct ip_vs_service
> 				vaddr = &fwmark;
> 			}
> 		}
> +		ip_vs_conn_fill_param(svc->af, protocol, &snet, 0,
> +				      vaddr, vport, &param);
> 	}
>
> 	/* Check if a template already exists */
> -	ct = ip_vs_ct_in_get(svc->af, protocol, &snet, 0, vaddr, vport);
> -
> +	ct = ip_vs_ct_in_get(&param);
> 	if (!ct || !ip_vs_check_template(ct)) {
> 		/* No template found or the dest of the connection
> 		 * template is not available.
> @@ -272,8 +275,7 @@ ip_vs_sched_persist(struct ip_vs_service
> 			dport = dest->port;
>
> 		/* Create a template */
> -		ct = ip_vs_conn_new(svc->af, protocol, &snet, 0,vaddr, vport,
> -				    &dest->addr, dport,
> +		ct = ip_vs_conn_new(&param, &dest->addr, dport,
> 				    IP_VS_CONN_F_TEMPLATE, dest);
> 		if (ct == NULL)
> 			return NULL;
> @@ -291,12 +293,7 @@ ip_vs_sched_persist(struct ip_vs_service
> 	/*
> 	 *    Create a new connection according to the template
> 	 */

 	Missing ip_vs_conn_fill_param here?

> -	cp = ip_vs_conn_new(svc->af, iph.protocol,
> -			    &iph.saddr, ports[0],
> -			    &iph.daddr, ports[1],
> -			    &dest->addr, dport,
> -			    flags,
> -			    dest);
> +	cp = ip_vs_conn_new(&param, &dest->addr, dport, flags, dest);
> 	if (cp == NULL) {
> 		ip_vs_conn_put(ct);
> 		return NULL;

> ===================================================================
> --- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_proto_ah_esp.c	2010-10-01 21:55:19.000000000 +0900
> +++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_proto_ah_esp.c	2010-10-01 22:23:33.000000000 +0900
> @@ -40,6 +40,19 @@ struct isakmp_hdr {
>
> #define PORT_ISAKMP	500
>
> +static void
> +ah_esp_conn_fill_param_proto(int af, const struct ip_vs_iphdr *iph,
> +			     int inverse, struct ip_vs_conn_param *p)
> +{
> +	if (likely(!inverse))
> +		ip_vs_conn_fill_param(af, IPPROTO_UDP,
> +				      &iph->saddr, htons(PORT_ISAKMP),
> +				      &iph->daddr, htons(PORT_ISAKMP), p);
> +	else

 	For inverse=1 iph->protocol must be IPPROTO_UDP
and &iph->daddr before &iph->saddr:

> +		ip_vs_conn_fill_param(af, iph->protocol,
> +				      &iph->saddr, htons(PORT_ISAKMP),
> +				      &iph->daddr, htons(PORT_ISAKMP), p);
> +}

Regards

--
Julian Anastasov <ja@ssi.bg>
