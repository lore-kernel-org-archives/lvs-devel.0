From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by IPVS
Date: Wed, 16 Oct 2013 09:28:07 +0900
Message-ID: <20131016002807.GM22321@verge.net.au>
References: <1381881751-6719-1-git-send-email-horms@verge.net.au>
 <1381882426.2045.85.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1381882426.2045.85.camel@edumazet-glaptop.roam.corp.google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Mark Brooks <mark@loadbalancer.org>

On Tue, Oct 15, 2013 at 05:13:46PM -0700, Eric Dumazet wrote:
> On Wed, 2013-10-16 at 09:02 +0900, Simon Horman wrote:
> > In v3.9 6fd6ce2056de2709 ("ipv6: Do not depend on rt->n in
> > ip6_finish_output2()") changed the behaviour of ip6_finish_output2()
> > such that it creates and uses a neigh entry if none is found.
> > Subsequently the 'n' field was removed from struct rt6_info.
> > 
> > Unfortunately my analysis is that in the case of IPVS direct routing this
> > change leads to incorrect behaviour as in this case packets may be output
> > to a destination other than where they would be output according to the
> > route table. In particular, the destination address may actually be a local
> > address and empirically a neighbour lookup seems to result in it becoming
> > unreachable.
> > 
> > This patch resolves the problem by providing the destination address
> > determined by IPVS to ip6_finish_output2() in the skb callback.  Although
> > this seems to work I can see several problems with this approach:
> > 
> > * It is rather ugly, stuffing an IPVS exception right in
> >   the middle of IPv6 code. The overhead could be eliminated for many users
> >   by using a staic key. But none the less it is not attractive.
> > 
> > * The use of the skb callback is may not be valid
> >   as it crosses from IPVS to IPv6 code. A possible, though unpleasant,
> >   alternative is to add a new field to struct sk_buff.
> 
> Please no ;)

I thought of you when I wrote that comment :)

> > * This covers all IPv6 packets output by IPVS but actually
> >   only those output using IPVS Direct-Routing need this.  One way to
> >   resolve this would be to add a more fine-grained ipvs_property to
> >   struct sk_buff.
> > 
> > Reported-by: Mark Brooks <mark@loadbalancer.org>
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> > ---
> >  include/net/ip_vs.h             | 6 ++++++
> >  net/ipv6/ip6_output.c           | 9 +++++++--
> >  net/netfilter/ipvs/ip_vs_xmit.c | 2 ++
> >  3 files changed, 15 insertions(+), 2 deletions(-)
> > 
> > diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> > index 1c2e1b9..11d90a6 100644
> > --- a/include/net/ip_vs.h
> > +++ b/include/net/ip_vs.h
> > @@ -1649,4 +1649,10 @@ ip_vs_dest_conn_overhead(struct ip_vs_dest *dest)
> >  		atomic_read(&dest->inactconns);
> >  }
> >  
> > +struct ipvs_skb_cb {
> > +	struct in6_addr *daddr;
> > +};
> 
> So we pass a reference.
>
> > +
> > +#define IP_VS_SKB_CB(skb) ((struct ipvs_skb_cb *)&(skb)->cb)
> > +
> >  #endif	/* _NET_IP_VS_H */
> > diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> > index a54c45c..a340180 100644
> > --- a/net/ipv6/ip6_output.c
> > +++ b/net/ipv6/ip6_output.c
> > @@ -52,6 +52,7 @@
> >  #include <net/addrconf.h>
> >  #include <net/rawv6.h>
> >  #include <net/icmp.h>
> > +#include <net/ip_vs.h>
> >  #include <net/xfrm.h>
> >  #include <net/checksum.h>
> >  #include <linux/mroute6.h>
> > @@ -61,7 +62,7 @@ static int ip6_finish_output2(struct sk_buff *skb)
> >  	struct dst_entry *dst = skb_dst(skb);
> >  	struct net_device *dev = dst->dev;
> >  	struct neighbour *neigh;
> > -	struct in6_addr *nexthop;
> > +	struct in6_addr *nexthop, *daddr;
> >  	int ret;
> >  
> >  	skb->protocol = htons(ETH_P_IPV6);
> > @@ -105,7 +106,11 @@ static int ip6_finish_output2(struct sk_buff *skb)
> >  	}
> >  
> >  	rcu_read_lock_bh();
> > -	nexthop = rt6_nexthop((struct rt6_info *)dst, &ipv6_hdr(skb)->daddr);
> > +	if (unlikely(IS_ENABLED(CONFIG_IP_VS) && skb->ipvs_property))
> > +		daddr = IP_VS_SKB_CB(skb)->daddr;
> 
> What guarantee do we have daddr points to valid memory (not already
> freed/reused) ?

I can change that to passing a value if there is a risk
the reference could become invalid. To be honest I am more
worried that skb->cb might be clobbered entirely.

> I guess things like NFQUEUE could happen ?

Could you expand a little?
