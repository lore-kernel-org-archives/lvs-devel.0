From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 06/34] ipvs: no need to reroute anymore on DNAT over
 loopback
Date: Fri, 29 Mar 2013 23:47:01 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1303292318090.1804@ja.ssi.bg>
References: <1364530311-11512-1-git-send-email-horms@verge.net.au> <1364530311-11512-7-git-send-email-horms@verge.net.au> <5155A8B6.9030303@cogentembedded.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <5155A8B6.9030303@cogentembedded.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>


	Hello,

On Fri, 29 Mar 2013, Sergei Shtylyov wrote:

> On 29-03-2013 8:11, Simon Horman wrote:
> 
> > From: Julian Anastasov <ja@ssi.bg>
> 
> > After commit 70e7341673 (ipv4: Show that ip_send_reply()
> > is purely unicast routine.) we do not need to reroute DNAT-ed
> > traffic over loopback because reply uses iph daddr and not
> > rt_spec_dst.
> 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > Signed-off by: Hans Schillstrom <hans@schillstrom.com>
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> > ---
> >   net/netfilter/ipvs/ip_vs_xmit.c |   58
> > ++-------------------------------------
> >   1 file changed, 2 insertions(+), 56 deletions(-)
> 
> > diff --git a/net/netfilter/ipvs/ip_vs_xmit.c
> > b/net/netfilter/ipvs/ip_vs_xmit.c
> > index 6448a2e..c942d36 100644
> > --- a/net/netfilter/ipvs/ip_vs_xmit.c
> > +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> [...]
> > @@ -635,16 +597,8 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn
> > *cp,
> >   		/* drop old route */
> >   		skb_dst_drop(skb);
> >   		skb_dst_set(skb, &rt->dst);
> > -	} else {
> > +	} else
> 
>    {} should be kept after *else*, according to Documentation/CodingStyle,
> chapter 3.

	Sigh. I missed this rule from Nov 2011.
It seems checkpatch.pl can not stop such crimes to occur :)

> >   		ip_rt_put(rt);
> > -		/*
> > -		 * Some IPv4 replies get local address from routes,
> > -		 * not from iph, so while we DNAT after routing
> > -		 * we need this second input/output route.
> > -		 */
> > -		if (!__ip_vs_reroute_locally(skb))
> > -			goto tx_error;
> > -	}
> > 
> >   	IP_VS_DBG_PKT(10, AF_INET, pp, skb, 0, "After DNAT");
> > 
> > @@ -1269,16 +1223,8 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct
> > ip_vs_conn *cp,
> >   		/* drop the old route when skb is not shared */
> >   		skb_dst_drop(skb);
> >   		skb_dst_set(skb, &rt->dst);
> > -	} else {
> > +	} else
> 
>    Same here.
> 
> >   		ip_rt_put(rt);
> > -		/*
> > -		 * Some IPv4 replies get local address from routes,
> > -		 * not from iph, so while we DNAT after routing
> > -		 * we need this second input/output route.
> > -		 */
> > -		if (!__ip_vs_reroute_locally(skb))
> > -			goto tx_error;
> > -	}
> > 
> >   	/* Another hack: avoid icmp_send in ip_fragment */
> >   	skb->local_df = 1;

Regards

--
Julian Anastasov <ja@ssi.bg>
