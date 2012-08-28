From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/2] ipvs: Extend MTU check to account for IPv6 NAT defrag
 changes
Date: Tue, 28 Aug 2012 12:47:40 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1208281235080.1693@ja.ssi.bg>
References: <20120827144024.5754.23872.stgit@dragon>  <20120827144059.5754.55303.stgit@dragon>  <alpine.LFD.2.00.1208271810070.24809@ja.ssi.bg> <1346144607.3069.415.camel@localhost>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1346144607.3069.415.camel@localhost>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Hans Schillstrom <hans@schillstrom.com>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org


	Hello,

On Tue, 28 Aug 2012, Jesper Dangaard Brouer wrote:

> On Mon, 2012-08-27 at 18:20 +0300, Julian Anastasov wrote:
> > 
> > > @@ -956,8 +963,11 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
> > >  		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
> > >  
> > >  	/* MTU checking: Special for tunnel mode */
> > > -	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr) &&
> 
> I guess:
>  ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr)
> Is the same as:
>  skb->len

	I think so. You can think of this in different way:
all transmitters are called from same place, there is no
difference in the packets we see. When we can use
__mtu_check_toobig_v6 for other methods relying on skb->len
being correct, we can do the same for tunnels, only that
tunnels have lower MTU, that is the only difference.

> > > -	    !skb_is_gso(skb)) {
> > > +	if ((!IP6CB(skb)->frag_max_size &&
> > > +	     (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr) &&
> > > +	      !skb_is_gso(skb)))
> > > +	    || IP6CB(skb)->frag_max_size + sizeof(struct ipv6hdr) > mtu) {
> 
> > 
> > 	mtu is already reduced with the new outer header size,
> > may be we can just call __mtu_check_toobig_v6 with mtu?
> 
> To Julian, is the extra sizeof(struct ipv6hdr) addition to
> frag_max_size, wrong? (as the mtu is already reduced)

	Yes, sizeof(struct ipv6hdr) is needed only together
with payload_len because payload_len does not include the
first header.

> If above statements hold, I think we can simply use
> __mtu_check_toobig_v6() also for the tunnel case :-)

	Yep

> --Jesper

Regards

--
Julian Anastasov <ja@ssi.bg>
