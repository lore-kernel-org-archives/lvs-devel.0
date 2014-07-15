From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvs-next] ipvs: Maintain all DSCP and ECN bits for ipv6
 tun forwarding
Date: Wed, 16 Jul 2014 00:36:38 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1407152305010.2027@ja.home.ssi.bg>
References: <1405411323-28802-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1405411323-28802-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com


	Hello,

On Tue, 15 Jul 2014, Alex Gartrell wrote:

> Previously, only the four high bits of the tclass were maintained in the
> ipv6 case.  This matches the behavior of ipv4, though whether or not we
> should reflect ECN bits may be up for debate.

	Agreed, RFC 3168 9.1 has some recommendations
and more changes may be needed, eg. by using
INET_ECN_encapsulate as in other tunnels:

ip6_flow_hdr(iph, INET_ECN_encapsulate(inner_dsfield, inner_dsfield), 0);

> Signed-off-by: Alex Gartrell <agartrell@fb.com>

	So far,

Acked-by: Julian Anastasov <ja@ssi.bg>

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

Regards

--
Julian Anastasov <ja@ssi.bg>
