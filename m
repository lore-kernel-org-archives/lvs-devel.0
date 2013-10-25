From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH ipvs 2/2] net: ipvs: sctp: do not recalc sctp checksum
 when not needed
Date: Fri, 25 Oct 2013 09:01:35 -0400
Message-ID: <20131025130134.GB9281@hmsreliant.think-freely.org>
References: <cover.1382689350.git.dborkman@redhat.com>
 <8390127344501c35ed3c23f3690b8a671d353870.1382689350.git.dborkman@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8390127344501c35ed3c23f3690b8a671d353870.1382689350.git.dborkman@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Borkmann <dborkman@redhat.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, linux-sctp@vger.kernel.org

On Fri, Oct 25, 2013 at 11:05:05AM +0200, Daniel Borkmann wrote:
> Unlike UDP or TCP, we do not take the pseudo-header into account
> in SCTP checksums [1]. So in case port mapping is the very same, we
> do not need to recalculate the whole SCTP checksum in software, which
> is expensive.
> 
> Also, similarly as in IPVS/TCP, take into account when a private
> helper mangled the packet. In that case, we also need to recalculate
> the checksum even if ports might be same.
> 
>  [1] http://tools.ietf.org/html/rfc4960#section-6.8
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>

> ---
>  net/netfilter/ipvs/ip_vs_proto_sctp.c | 30 ++++++++++++++++++++++++------
>  1 file changed, 24 insertions(+), 6 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> index 9ca7aa0..e56661e 100644
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
> @@ -92,19 +93,27 @@ sctp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
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
> +		if (!(ret = ip_vs_app_pkt_out(cp, skb)))
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
> +	if (sctph->source != cp->vport || payload_csum) {
> +		sctph->source = cp->vport;
> +		sctp_nat_csum(skb, sctph, sctphoff);
> +	}
>  
>  	return 1;
>  }
> @@ -115,6 +124,7 @@ sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
>  {
>  	sctp_sctphdr_t *sctph;
>  	unsigned int sctphoff = iph->len;
> +	bool payload_csum = false;
>  
>  #ifdef CONFIG_IP_VS_IPV6
>  	if (cp->af == AF_INET6 && iph->fragoffs)
> @@ -126,19 +136,27 @@ sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
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
> +		if (!(ret = ip_vs_app_pkt_in(cp, skb)))
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
> +	if (sctph->dest != cp->dport || payload_csum) {
> +		sctph->dest = cp->dport;
> +		sctp_nat_csum(skb, sctph, sctphoff);
> +	}
>  
>  	return 1;
>  }
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
