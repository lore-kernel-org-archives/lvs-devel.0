From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH V2 2/2] ipvs: Extend MTU check to account for IPv6 NAT
 defrag changes
Date: Wed, 29 Aug 2012 11:04:13 +0200
Message-ID: <1346231053.3069.443.camel@localhost>
References: <20120828142051.11475.63775.stgit@dragon>
	 <20120828142248.11475.15917.stgit@dragon>
	 <1346165359.3571.9.camel@edumazet-glaptop>
	 <1346223759.3069.429.camel@localhost>
	 <1346229785.2522.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1346229785.2522.8.camel@edumazet-glaptop>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Hans Schillstrom <hans@schillstrom.com>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org

On Wed, 2012-08-29 at 01:43 -0700, Eric Dumazet wrote:
> On Wed, 2012-08-29 at 09:02 +0200, Jesper Dangaard Brouer wrote:
> > On Tue, 2012-08-28 at 07:49 -0700, Eric Dumazet wrote:
> > > On Tue, 2012-08-28 at 16:23 +0200, Jesper Dangaard Brouer wrote:
> > > > This patch is necessary, to make IPVS work, after Patrick McHardys
> > > > IPv6 NAT defragmentation changes.
> > > > 
> > > > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > > > ---
> > > > In V2: the tunnel mode is no longer a special case.
> > > > 
> > > >  net/netfilter/ipvs/ip_vs_xmit.c |    9 ++++++++-
> > > >  1 files changed, 8 insertions(+), 1 deletions(-)
> > > > 
> > > > diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> > > > index 67a3978..56f6d5d 100644
> > > > --- a/net/netfilter/ipvs/ip_vs_xmit.c
> > > > +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> > > > @@ -88,7 +88,14 @@ __ip_vs_dst_check(struct ip_vs_dest *dest, u32 rtos)
> > > >  static inline bool
> > > >  __mtu_check_toobig_v6(const struct sk_buff *skb, u32 mtu)
> > > >  {
> > > > -	if (skb->len > mtu && !skb_is_gso(skb)) {
> > > > +	if (IP6CB(skb)->frag_max_size) {
> > > > +		/* frag_max_size tell us that, this packet have been
> > > > +		 * defragmented by netfilter IPv6 conntrack module.
> > > > +		 */
> > > > +		if (IP6CB(skb)->frag_max_size > mtu)
> > > > +			return true; /* largest fragment violate MTU */
> > Implicit:         else
> >      			return false
> > 
> > (if it makes it more clear, not sure)
> > > > +	}
> > > > +	else if (skb->len > mtu && !skb_is_gso(skb)) {
> > > >  		return true; /* Packet size violate MTU size */
> > > >  	}
> > > 
> > > Couldnt you use a single test ?
> > > 
> > > if (IP6CB(skb)->frag_max_size > mtu)
> > > 	return true;
> > > 
> > > if (skb->len > mtu && !skb_is_gso(skb))
> > > 	return true;
> > > 
> > 
> > Nope, this will not work.
> > 
> > If (IP6CB(skb)->frag_max_size > 0) then we have a defragmented packet,
> > this means that skb->len cannot be used for MTU checking, because
> > skb->len is now the total length of all the fragments (which your
> > solution will fall-through to)
> > 
> 
> If the packet was not fragmented, its was a single frame.
> 
> But if this frame length is above mtu, packet is not too big ?

Nope... not if its a defragmented/reassembled packet.

> Sorry if its a stupid question.

These changes have to be seen together with Patrick's patch:
 "netfilter: nf_conntrack_ipv6: improve fragmentation handling"
 http://thread.gmane.org/gmane.linux.network/241517/focus=241518

The IPv6 packet arriving have been defragmented/reassembled by the
nf_conntrack_ipv6 module.  Thus, they look like a normal, but big,
packet to us.   We let it through, because it will be re-fragmented
again later, but first we need to check if the largest fragment would
violate the MTU.

Hope it makes it more clear.


