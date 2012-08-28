From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 2/2] ipvs: Extend MTU check to account for IPv6 NAT
 defrag changes
Date: Tue, 28 Aug 2012 11:03:27 +0200
Message-ID: <1346144607.3069.415.camel@localhost>
References: <20120827144024.5754.23872.stgit@dragon>
	 <20120827144059.5754.55303.stgit@dragon>
	 <alpine.LFD.2.00.1208271810070.24809@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1208271810070.24809@ja.ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Hans Schillstrom <hans@schillstrom.com>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org

On Mon, 2012-08-27 at 18:20 +0300, Julian Anastasov wrote:
> 	Hello,
> 
> On Mon, 27 Aug 2012, Jesper Dangaard Brouer wrote:
> 
> > This patch is necessary, to make IPVS work, after Patrick McHardys
> > IPv6 NAT defragmentation changes.
> > 
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > ---
> > 
> > I would appriciate, if someone (e.g. Julian) double check the tunnel mode code.
> 
> 	Sure
> 
> > --Jesper
> > 
> >  net/netfilter/ipvs/ip_vs_xmit.c |   16 +++++++++++++---
> >  1 files changed, 13 insertions(+), 3 deletions(-)
> > 
> > @@ -956,8 +963,11 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
> >  		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
> >  
> >  	/* MTU checking: Special for tunnel mode */
> > -	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr) &&

I guess:
 ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr)
Is the same as:
 skb->len

> > -	    !skb_is_gso(skb)) {
> > +	if ((!IP6CB(skb)->frag_max_size &&
> > +	     (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr) &&
> > +	      !skb_is_gso(skb)))
> > +	    || IP6CB(skb)->frag_max_size + sizeof(struct ipv6hdr) > mtu) {

> 
> 	mtu is already reduced with the new outer header size,
> may be we can just call __mtu_check_toobig_v6 with mtu?

To Julian, is the extra sizeof(struct ipv6hdr) addition to
frag_max_size, wrong? (as the mtu is already reduced)

If above statements hold, I think we can simply use
__mtu_check_toobig_v6() also for the tunnel case :-)

--Jesper

