From: Simon Horman <simon@horms.net>
Subject: Re: [RFC v2] ipvs: allow transmit of GRO aggregated skbs
Date: Mon, 8 Nov 2010 20:45:42 +0900
Message-ID: <20101108114542.GF14454@verge.net.au>
References: <20101105135222.GA8714@verge.net.au>
 <20101105235411.GA2443@verge.net.au>
 <alpine.LFD.2.00.1011061608510.4009@ja.ssi.bg>
 <20101106142817.GA27212@verge.net.au>
 <20101108073149.GA31384@verge.net.au>
 <alpine.LFD.2.00.1011081104310.1687@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1011081104310.1687@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>

On Mon, Nov 08, 2010 at 11:36:21AM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 8 Nov 2010, Simon Horman wrote:
> 
> >[ CCing Herbet Xu ]
> >
> >>>>This is a first attempt at allowing LVS to transmit
> >>>>skbs of greater than MTU length that have been aggregated by GRO.
> >>>>
> >>>>I have lightly tested the ip_vs_dr_xmit() portion of this patch and
> >>>>although it seems to work I am unsure that netif_needs_gso() is the correct
> >>>>test to use.
> >>>
> >>>	ip_forward() uses !skb_is_gso(skb), so may be it is
> >>>enough to check for GRO instead of using netif_needs_gso?
> >>
> >>Thanks, I'll look into that.
> >
> >Hi Julian,
> >
> >just to clarify, you think that !skb_is_gso(skb) should be
> >used in ip_vs_xmit.c? If so, yes I think that makes sense
> >and I'll re-spin my patch accordingly.
> 
> 	Yes, I think we should check for !skb_is_gso(skb)
> as it looks as correct check to avoid FRAG_NEEDED after GRO
> but lets wait for confirmation from Herbert Xu.

Yes, lets try and get a word from Herbert Xu on this.

> Also, !skb->local_df check should help for local IPVS clients
> that set local_df.
> 
> 	If you prefer you can create such helper in ip_vs_xmit.c:
> 
> /* Check if packet exceeds MTU */
> static inline int ip_vs_mtu_exceeded(struct sk_buff *skb, unsigned int mtu)
> {
> 	return skb->len > mtu && !skb_is_gso(skb) && !skb->local_df;
> }

Good thinking.

