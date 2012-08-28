From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/2] ipvs: Extend MTU check to account for IPv6 NAT
 defrag changes
Date: Tue, 28 Aug 2012 17:28:54 +0900
Message-ID: <20120828082854.GA10687@verge.net.au>
References: <20120827144024.5754.23872.stgit@dragon>
 <20120827144059.5754.55303.stgit@dragon>
 <alpine.LFD.2.00.1208271810070.24809@ja.ssi.bg>
 <Pine.GSO.4.63.1208281020530.18770@stinky-local.trash.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.63.1208281020530.18770@stinky-local.trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>
Cc: Julian Anastasov <ja@ssi.bg>, Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Hans Schillstrom <hans@schillstrom.com>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org

On Tue, Aug 28, 2012 at 10:22:05AM +0200, Patrick McHardy wrote:
> On Mon, 27 Aug 2012, Julian Anastasov wrote:
> 
> >
> >	Hello,
> >
> >On Mon, 27 Aug 2012, Jesper Dangaard Brouer wrote:
> >
> >>This patch is necessary, to make IPVS work, after Patrick McHardys
> >>IPv6 NAT defragmentation changes.
> >>
> >>Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> >>---
> >>
> >>I would appriciate, if someone (e.g. Julian) double check the tunnel mode code.
> >
> >	Sure
> >
> >>--Jesper
> >>
> >> net/netfilter/ipvs/ip_vs_xmit.c |   16 +++++++++++++---
> >> 1 files changed, 13 insertions(+), 3 deletions(-)
> >>
> >>@@ -956,8 +963,11 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
> >> 		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
> >>
> >> 	/* MTU checking: Special for tunnel mode */
> >>-	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr) &&
> >>-	    !skb_is_gso(skb)) {
> >>+	if ((!IP6CB(skb)->frag_max_size &&
> >>+	     (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr) &&
> >>+	      !skb_is_gso(skb)))
> >>+	    || IP6CB(skb)->frag_max_size + sizeof(struct ipv6hdr) > mtu) {
> >>+
> >
> >	mtu is already reduced with the new outer header size,
> >may be we can just call __mtu_check_toobig_v6 with mtu?
> >
> >> 		if (!skb->dev) {
> >> 			struct net *net = dev_net(skb_dst(skb)->dev);
> >
> >	All other changes in patch 1 and 2 look ok and
> >I'll ack them next time.
> 
> I'd like to take the final patches through my nat-ipv6 tree in order
> to avoid temporary regressions. Please let me know when they're ready
> for applying.

I'm fine with these changes going through your tree (rather than my IPVS tree)
once they are ready.
