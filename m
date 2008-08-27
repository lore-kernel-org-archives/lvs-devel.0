From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH RFC 10/24] IPVS: Extend scheduling functions for IPv6
	support
Date: Wed, 27 Aug 2008 16:28:23 +1000
Message-ID: <20080827062822.GC3816@verge.net.au>
References: <1219248931-15064-1-git-send-email-juliusv@google.com> <1219248931-15064-11-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1219248931-15064-11-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Wed, Aug 20, 2008 at 06:15:17PM +0200, Julius Volz wrote:
> Convert ip_vs_schedule() and ip_vs_sched_persist() to support scheduling
> IPv6 connections.
> 
> Signed-off-by: Julius Volz <juliusv@google.com>
> 
>  1 files changed, 58 insertions(+), 43 deletions(-)
> 
> diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
> index 99e8938..0f9a0a2 100644
> --- a/net/ipv4/ipvs/ip_vs_core.c
> +++ b/net/ipv4/ipvs/ip_vs_core.c
> @@ -183,14 +183,21 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
>  		    __be16 ports[2])
>  {
>  	struct ip_vs_conn *cp = NULL;
> -	struct iphdr *iph = ip_hdr(skb);
> +	struct ip_vs_iphdr iph;
>  	struct ip_vs_dest *dest;
>  	struct ip_vs_conn *ct;
> -	__be16  dport;	 /* destination port to forward */
> -	__be32  snet;	 /* source network of the client, after masking */
> +	__be16  dport;			/* destination port to forward */
> +	union nf_inet_addr snet;	/* source network of the client, after masking */

Can you break the line above so that it is <= 80 columns wide?

	union nf_inet_addr snet;	/* source network of the client,
					 * after masking */

> +
> +	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
>  
>  	/* Mask saddr with the netmask to adjust template granularity */
> -	snet = iph->saddr & svc->netmask;
> +#ifdef CONFIG_IP_VS_IPV6
> +	if (svc->af == AF_INET6)
> +		ipv6_addr_prefix(&snet.in6, &iph.saddr.in6, svc->netmask);
> +	else
> +#endif
> +		snet.ip = iph.saddr.ip & svc->netmask;
>  
>  	IP_VS_DBG_BUF(6, "p-schedule: src %s:%u dest %s:%u "
>  		      "mnet %s\n",
> @@ -214,11 +221,11 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
>  	if (ports[1] == svc->port) {
>  		/* Check if a template already exists */
>  		if (svc->port != FTPPORT)
> -			ct = ip_vs_ct_in_get(iph->protocol, snet, 0,
> -					       iph->daddr, ports[1]);
> +			ct = ip_vs_ct_in_get(svc->af, iph.protocol, &snet, 0,
> +					     &iph.daddr, ports[1]);
>  		else
> -			ct = ip_vs_ct_in_get(iph->protocol, snet, 0,
> -					       iph->daddr, 0);
> +			ct = ip_vs_ct_in_get(svc->af, iph.protocol, &snet, 0,
> +					     &iph.daddr, 0);
>  
>  		if (!ct || !ip_vs_check_template(ct)) {
>  			/*
> @@ -238,18 +245,18 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
>  			 * for ftp service.
>  			 */
>  			if (svc->port != FTPPORT)
> -				ct = ip_vs_conn_new(iph->protocol,
> -						    snet, 0,
> -						    iph->daddr,
> +				ct = ip_vs_conn_new(svc->af, iph.protocol,
> +						    &snet, 0,
> +						    &iph.daddr,
>  						    ports[1],
> -						    dest->addr, dest->port,
> +						    &dest->addr, dest->port,
>  						    IP_VS_CONN_F_TEMPLATE,
>  						    dest);
>  			else
> -				ct = ip_vs_conn_new(iph->protocol,
> -						    snet, 0,
> -						    iph->daddr, 0,
> -						    dest->addr, 0,
> +				ct = ip_vs_conn_new(svc->af, iph.protocol,
> +						    &snet, 0,
> +						    &iph.daddr, 0,
> +						    &dest->addr, 0,
>  						    IP_VS_CONN_F_TEMPLATE,
>  						    dest);
>  			if (ct == NULL)
> @@ -268,12 +275,16 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
>  		 * fwmark template: <IPPROTO_IP,caddr,0,fwmark,0,daddr,0>
>  		 * port zero template: <protocol,caddr,0,vaddr,0,daddr,0>
>  		 */
> -		if (svc->fwmark)
> -			ct = ip_vs_ct_in_get(IPPROTO_IP, snet, 0,
> -					       htonl(svc->fwmark), 0);
> -		else
> -			ct = ip_vs_ct_in_get(iph->protocol, snet, 0,
> -					       iph->daddr, 0);
> +		if (svc->fwmark) {
> +			union nf_inet_addr fwmark = {
> +				.all = { 0, 0, 0, htonl(svc->fwmark) }
> +			};
> +
> +			ct = ip_vs_ct_in_get(svc->af, IPPROTO_IP, &snet, 0,
> +					     &fwmark, 0);
> +		} else
> +			ct = ip_vs_ct_in_get(svc->af, iph.protocol, &snet, 0,
> +					     &iph.daddr, 0);
>  
>  		if (!ct || !ip_vs_check_template(ct)) {
>  			/*
> @@ -292,18 +303,22 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
>  			/*
>  			 * Create a template according to the service
>  			 */
> -			if (svc->fwmark)
> -				ct = ip_vs_conn_new(IPPROTO_IP,
> -						    snet, 0,
> -						    htonl(svc->fwmark), 0,
> -						    dest->addr, 0,
> +			if (svc->fwmark) {
> +				union nf_inet_addr fwmark = {
> +					.all = { 0, 0, 0, htonl(svc->fwmark) }
> +				};
> +
> +				ct = ip_vs_conn_new(svc->af, IPPROTO_IP,
> +						    &snet, 0,
> +						    &fwmark, 0,
> +						    &dest->addr, 0,
>  						    IP_VS_CONN_F_TEMPLATE,
>  						    dest);
> -			else
> -				ct = ip_vs_conn_new(iph->protocol,
> -						    snet, 0,
> -						    iph->daddr, 0,
> -						    dest->addr, 0,
> +			} else
> +				ct = ip_vs_conn_new(svc->af, iph.protocol,
> +						    &snet, 0,
> +						    &iph.daddr, 0,
> +						    &dest->addr, 0,
>  						    IP_VS_CONN_F_TEMPLATE,
>  						    dest);
>  			if (ct == NULL)
> @@ -320,10 +335,10 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
>  	/*
>  	 *    Create a new connection according to the template
>  	 */
> -	cp = ip_vs_conn_new(iph->protocol,
> -			    iph->saddr, ports[0],
> -			    iph->daddr, ports[1],
> -			    dest->addr, dport,
> +	cp = ip_vs_conn_new(svc->af, iph.protocol,
> +			    &iph.saddr, ports[0],
> +			    &iph.daddr, ports[1],
> +			    &dest->addr, dport,
>  			    0,
>  			    dest);
>  	if (cp == NULL) {
> @@ -352,12 +367,12 @@ struct ip_vs_conn *
>  ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
>  {
>  	struct ip_vs_conn *cp = NULL;
> -	struct iphdr *iph = ip_hdr(skb);
> +	struct ip_vs_iphdr iph;
>  	struct ip_vs_dest *dest;
>  	__be16 _ports[2], *pptr;
>  
> -	pptr = skb_header_pointer(skb, iph->ihl*4,
> -				  sizeof(_ports), _ports);
> +	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
> +	pptr = skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
>  	if (pptr == NULL)
>  		return NULL;
>  
> @@ -387,10 +402,10 @@ ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
>  	/*
>  	 *    Create a connection entry.
>  	 */
> -	cp = ip_vs_conn_new(iph->protocol,
> -			    iph->saddr, pptr[0],
> -			    iph->daddr, pptr[1],
> -			    dest->addr, dest->port?dest->port:pptr[1],
> +	cp = ip_vs_conn_new(svc->af, iph.protocol,
> +			    &iph.saddr, pptr[0],
> +			    &iph.daddr, pptr[1],
> +			    &dest->addr, dest->port ? dest->port : pptr[1],
>  			    0,
>  			    dest);
>  	if (cp == NULL)
> -- 
> 1.5.4.5
