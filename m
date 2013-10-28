From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v3 ipvs-next] net: ipvs: sctp: do not recalc sctp csum
 when ports didn't change
Date: Mon, 28 Oct 2013 12:43:26 +0200 (EET)
Message-ID: <alpine.LFD.2.03.1310281242130.2984@ssi.bg>
References: <1382954180-8264-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1382954180-8264-1-git-send-email-dborkman@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Borkmann <dborkman@redhat.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, linux-sctp@vger.kernel.org


	Hello,

On Mon, 28 Oct 2013, Daniel Borkmann wrote:

> Unlike UDP or TCP, we do not take the pseudo-header into
> account in SCTP checksums. So in case port mapping is the
> very same, we do not need to recalculate the whole SCTP
> checksum in software, which is very expensive.
> 
> Also, similarly as in TCP, take into account when a private
> helper mangled the packet. In that case, we also need to
> recalculate the checksum even if ports might be same.
> 
> Thanks for feedback regarding skb->ip_summed checks from
> Julian Anastasov; here's a discussion on these checks for
> snat and dnat:
> 
> * For snat_handler(), we can see CHECKSUM_PARTIAL from
>   virtual devices, and from LOCAL_OUT, otherwise it
>   should be CHECKSUM_UNNECESSARY. In general, in snat it
>   is more complex. skb contains the original route and
>   ip_vs_route_me_harder() can change the route after
>   snat_handler. So, for locally generated replies from
>   local server we can not preserve the CHECKSUM_PARTIAL
>   mode. It is an chicken or egg dilemma: snat_handler
>   needs the device after rerouting (to check for
>   NETIF_F_SCTP_CSUM), while ip_route_me_harder() wants
>   the snat_handler() to put the new saddr for proper
>   rerouting.
> 
> * For dnat_handler(), we should not see CHECKSUM_COMPLETE
>   for SCTP, in fact the small set of drivers that support
>   SCTP offloading return CHECKSUM_UNNECESSARY on correctly
>   received SCTP csum. We can see CHECKSUM_PARTIAL from
>   local stack or received from virtual drivers. The idea is
>   that SCTP decides to avoid csum calculation if hardware
>   supports offloading. IPVS can change the device after
>   rerouting to real server but we can preserve the
>   CHECKSUM_PARTIAL mode if the new device supports
>   offloading too. This works because skb dst is changed
>   before dnat_handler and we see the new device. So, checks
>   in the 'if' part will decide whether it is ok to keep
>   CHECKSUM_PARTIAL for the output. If the packet was with
>   CHECKSUM_NONE, hence we deal with unknown checksum. As we
>   recalculate the sum for IP header in all cases, it should
>   be safe to use CHECKSUM_UNNECESSARY. We can forward wrong
>   checksum in this case (without cp->app). In case of
>   CHECKSUM_UNNECESSARY, the csum was valid on receive.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

	Looks good, thanks!

Signed-off-by: Julian Anastasov <ja@ssi.bg>

> ---
>  v1->v2: - Applied skb->ip_summed feedback from Julian, thanks!
>  v2->v3: - Minor cosmetic change to fix checkpatch warning
> 
>  net/netfilter/ipvs/ip_vs_proto_sctp.c | 39 +++++++++++++++++++++++++++++------
>  1 file changed, 33 insertions(+), 6 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> index 9ca7aa0..2f7ea75 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> @@ -81,6 +81,7 @@ sctp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
>  {
>  	sctp_sctphdr_t *sctph;
>  	unsigned int sctphoff = iph->len;
> +	bool payload_csum = false;
>  
>  #ifdef CONFIG_IP_VS_IPV6
>  	if (cp->af == AF_INET6 && iph->fragoffs)
> @@ -92,19 +93,31 @@ sctp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
>  		return 0;
>  
>  	if (unlikely(cp->app != NULL)) {
> +		int ret;
> +
>  		/* Some checks before mangling */
>  		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
>  			return 0;
>  
>  		/* Call application helper if needed */
> -		if (!ip_vs_app_pkt_out(cp, skb))
> +		ret = ip_vs_app_pkt_out(cp, skb);
> +		if (ret == 0)
>  			return 0;
> +		/* ret=2: csum update is needed after payload mangling */
> +		if (ret == 2)
> +			payload_csum = true;
>  	}
>  
>  	sctph = (void *) skb_network_header(skb) + sctphoff;
> -	sctph->source = cp->vport;
>  
> -	sctp_nat_csum(skb, sctph, sctphoff);
> +	/* Only update csum if we really have to */
> +	if (sctph->source != cp->vport || payload_csum ||
> +	    skb->ip_summed == CHECKSUM_PARTIAL) {
> +		sctph->source = cp->vport;
> +		sctp_nat_csum(skb, sctph, sctphoff);
> +	} else {
> +		skb->ip_summed = CHECKSUM_UNNECESSARY;
> +	}
>  
>  	return 1;
>  }
> @@ -115,6 +128,7 @@ sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
>  {
>  	sctp_sctphdr_t *sctph;
>  	unsigned int sctphoff = iph->len;
> +	bool payload_csum = false;
>  
>  #ifdef CONFIG_IP_VS_IPV6
>  	if (cp->af == AF_INET6 && iph->fragoffs)
> @@ -126,19 +140,32 @@ sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
>  		return 0;
>  
>  	if (unlikely(cp->app != NULL)) {
> +		int ret;
> +
>  		/* Some checks before mangling */
>  		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
>  			return 0;
>  
>  		/* Call application helper if needed */
> -		if (!ip_vs_app_pkt_in(cp, skb))
> +		ret = ip_vs_app_pkt_in(cp, skb);
> +		if (ret == 0)
>  			return 0;
> +		/* ret=2: csum update is needed after payload mangling */
> +		if (ret == 2)
> +			payload_csum = true;
>  	}
>  
>  	sctph = (void *) skb_network_header(skb) + sctphoff;
> -	sctph->dest = cp->dport;
>  
> -	sctp_nat_csum(skb, sctph, sctphoff);
> +	/* Only update csum if we really have to */
> +	if (sctph->dest != cp->dport || payload_csum ||
> +	    (skb->ip_summed == CHECKSUM_PARTIAL &&
> +	     !(skb_dst(skb)->dev->features & NETIF_F_SCTP_CSUM))) {
> +		sctph->dest = cp->dport;
> +		sctp_nat_csum(skb, sctph, sctphoff);
> +	} else if (skb->ip_summed != CHECKSUM_PARTIAL) {
> +		skb->ip_summed = CHECKSUM_UNNECESSARY;
> +	}
>  
>  	return 1;
>  }
> -- 
> 1.7.11.7

Regards

--
Julian Anastasov <ja@ssi.bg>
