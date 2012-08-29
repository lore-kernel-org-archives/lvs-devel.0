From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V2 2/2] ipvs: Extend MTU check to account for IPv6 NAT
 defrag changes
Date: Wed, 29 Aug 2012 01:43:05 -0700
Message-ID: <1346229785.2522.8.camel@edumazet-glaptop>
References: <20120828142051.11475.63775.stgit@dragon>
	 <20120828142248.11475.15917.stgit@dragon>
	 <1346165359.3571.9.camel@edumazet-glaptop>
	 <1346223759.3069.429.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=subject:from:to:cc:in-reply-to:references:content-type:date
         :message-id:mime-version:x-mailer:content-transfer-encoding;
        bh=hEHyJUKZR2zblof6w6/pQ8VM8l+LBoVnyc9rxZStTwA=;
        b=jttye2eWROkdtWbTQgASoVPjQ63mIi7nN9p8vjtcruj0sLj+qWPh8d1Eg+QZRfIxNW
         MusNLynfgH8lAYt5D63sNP0zd5h8vgV3m+hCQBRELeTs6/d0rbRVvdRtZhhi+QPzNdxd
         yUkMsOvf0DrWSxI1S/kZvl4M7myg68t/3iuaP1kajt5VS541eUdfh9Uy3nkAQCPNnZgG
         4CzB/haKFsXhBRNH3YpXBb2O470ijJCC4qmqFaQLiIB26aJE7kSeE00r2NV/+BbRgKxF
         1c6Vbpgaoc276v2Ti3mdlFZ5GJyfD/omnsCfkZZxmpvuT26g1efn8X1pIzECpHMSz/D7
         TTMQ==
In-Reply-To: <1346223759.3069.429.camel@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Hans Schillstrom <hans@schillstrom.com>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org

On Wed, 2012-08-29 at 09:02 +0200, Jesper Dangaard Brouer wrote:
> On Tue, 2012-08-28 at 07:49 -0700, Eric Dumazet wrote:
> > On Tue, 2012-08-28 at 16:23 +0200, Jesper Dangaard Brouer wrote:
> > > This patch is necessary, to make IPVS work, after Patrick McHardys
> > > IPv6 NAT defragmentation changes.
> > > 
> > > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > > ---
> > > In V2: the tunnel mode is no longer a special case.
> > > 
> > >  net/netfilter/ipvs/ip_vs_xmit.c |    9 ++++++++-
> > >  1 files changed, 8 insertions(+), 1 deletions(-)
> > > 
> > > diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> > > index 67a3978..56f6d5d 100644
> > > --- a/net/netfilter/ipvs/ip_vs_xmit.c
> > > +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> > > @@ -88,7 +88,14 @@ __ip_vs_dst_check(struct ip_vs_dest *dest, u32 rtos)
> > >  static inline bool
> > >  __mtu_check_toobig_v6(const struct sk_buff *skb, u32 mtu)
> > >  {
> > > -	if (skb->len > mtu && !skb_is_gso(skb)) {
> > > +	if (IP6CB(skb)->frag_max_size) {
> > > +		/* frag_max_size tell us that, this packet have been
> > > +		 * defragmented by netfilter IPv6 conntrack module.
> > > +		 */
> > > +		if (IP6CB(skb)->frag_max_size > mtu)
> > > +			return true; /* largest fragment violate MTU */
> Implicit:         else
>      			return false
> 
> (if it makes it more clear, not sure)
> > > +	}
> > > +	else if (skb->len > mtu && !skb_is_gso(skb)) {
> > >  		return true; /* Packet size violate MTU size */
> > >  	}
> > 
> > Couldnt you use a single test ?
> > 
> > if (IP6CB(skb)->frag_max_size > mtu)
> > 	return true;
> > 
> > if (skb->len > mtu && !skb_is_gso(skb))
> > 	return true;
> > 
> 
> Nope, this will not work.
> 
> If (IP6CB(skb)->frag_max_size > 0) then we have a defragmented packet,
> this means that skb->len cannot be used for MTU checking, because
> skb->len is now the total length of all the fragments (which your
> solution will fall-through to)
> 

If the packet was not fragmented, its was a single frame.

But if this frame length is above mtu, packet is not too big ?

Sorry if its a stupid question.



