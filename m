From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH ipvs-next] ipvs: Maintain all DSCP and ECN bits for ipv6
 tun forwarding
Date: Thu, 17 Jul 2014 12:55:25 +0900
Message-ID: <20140717035524.GB14844@verge.net.au>
References: <1405551454-23327-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1405551454-23327-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: agartrell@fb.com
Cc: lvs-devel@vger.kernel.org

On Wed, Jul 16, 2014 at 03:57:34PM -0700, agartrell@fb.com wrote:
> From: Alex Gartrell <agartrell@fb.com>
> 
> Previously, only the four high bits of the tclass were maintained in the
> ipv6 case.  This matches the behavior of ipv4, though whether or not we
> should reflect ECN bits may be up for debate.
> 
> Signed-off-by: Alex Gartrell <agartrell@fb.com>
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks, I have queued this up for v3.16 in the ipvs tree.

> ---
>  net/netfilter/ipvs/ip_vs_xmit.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index c47444e..28ee592 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -967,8 +967,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	iph->nexthdr		=	IPPROTO_IPV6;
>  	iph->payload_len	=	old_iph->payload_len;
>  	be16_add_cpu(&iph->payload_len, sizeof(*old_iph));
> -	iph->priority		=	old_iph->priority;
>  	memset(&iph->flow_lbl, 0, sizeof(iph->flow_lbl));
> +	ipv6_change_dsfield(iph, 0, ipv6_get_dsfield(old_iph));
>  	iph->daddr = cp->daddr.in6;
>  	iph->saddr = saddr;
>  	iph->hop_limit		=	old_iph->hop_limit;
> -- 
> 1.8.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
