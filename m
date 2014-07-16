From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH ipvs-next] ipvs: Maintain all DSCP and ECN bits for ipv6
 tun forwarding
Date: Wed, 16 Jul 2014 09:41:49 +0900
Message-ID: <20140716004149.GF25244@verge.net.au>
References: <1405411323-28802-1-git-send-email-agartrell@fb.com>
 <alpine.LFD.2.11.1407152305010.2027@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1407152305010.2027@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Alex Gartrell <agartrell@fb.com>, lvs-devel@vger.kernel.org, kernel-team@fb.com

On Wed, Jul 16, 2014 at 12:36:38AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 15 Jul 2014, Alex Gartrell wrote:
> 
> > Previously, only the four high bits of the tclass were maintained in the
> > ipv6 case.  This matches the behavior of ipv4, though whether or not we
> > should reflect ECN bits may be up for debate.
> 
> 	Agreed, RFC 3168 9.1 has some recommendations
> and more changes may be needed, eg. by using
> INET_ECN_encapsulate as in other tunnels:
> 
> ip6_flow_hdr(iph, INET_ECN_encapsulate(inner_dsfield, inner_dsfield), 0);
> 
> > Signed-off-by: Alex Gartrell <agartrell@fb.com>
> 
> 	So far,
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Hi Alex,

Somehow this patch did not reach my inbox.
Could you repost it with Julian's ack and me CCed?

> > ---
> >  net/netfilter/ipvs/ip_vs_xmit.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> > index c47444e..28ee592 100644
> > --- a/net/netfilter/ipvs/ip_vs_xmit.c
> > +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> > @@ -967,8 +967,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
> >  	iph->nexthdr		=	IPPROTO_IPV6;
> >  	iph->payload_len	=	old_iph->payload_len;
> >  	be16_add_cpu(&iph->payload_len, sizeof(*old_iph));
> > -	iph->priority		=	old_iph->priority;
> >  	memset(&iph->flow_lbl, 0, sizeof(iph->flow_lbl));
> > +	ipv6_change_dsfield(iph, 0, ipv6_get_dsfield(old_iph));
> >  	iph->daddr = cp->daddr.in6;
> >  	iph->saddr = saddr;
> >  	iph->hop_limit		=	old_iph->hop_limit;
> > -- 
> > 1.8.1
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
