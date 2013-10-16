From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by IPVS
Date: Wed, 16 Oct 2013 23:59:53 +0200
Message-ID: <20131016215953.GD18135@order.stressinduktion.org>
References: <1381881751-6719-1-git-send-email-horms@verge.net.au> <alpine.LFD.2.03.1310161015550.1560@ssi.bg> <20131016143246.GB18135@order.stressinduktion.org> <alpine.LFD.2.03.1310162252220.1917@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.03.1310162252220.1917@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Mark Brooks <mark@loadbalancer.org>

On Wed, Oct 16, 2013 at 11:22:40PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Wed, 16 Oct 2013, Hannes Frederic Sowa wrote:
> 
> > On Wed, Oct 16, 2013 at 10:27:47AM +0300, Julian Anastasov wrote:
> > > 
> > > 	I don't know the IPv6 routing but if we find a way
> > > to keep the desired nexthop in rt6i_gateway and to add
> > > RTF_GATEWAY checks here and there such solution would be more
> > > general. FLOWI_FLAG_KNOWN_NH flag can help, if needed.
> > 
> > I thought about this yesterday but did not see an easy way. How does the IPv4
> > implementation accomplish this?
> 
> 	In IPv4 rt->rt_flags has no bit to indicate if the route
> is via gateway (like RTF_GATEWAY in IPv6). We added rt_uses_gateway
> for this purpose.
> 
> 	In the default case, rt_gateway may contain 0 if we return
> cached result, eg. when target is part of a local subnet.
> Then IPVS/TEE/RAW can request valid rt_gateway, even with the price
> of a cloned result, so that rt_gateway can remember the requested
> nexthop which may differ from daddr.

To have ip6_dst_check working, there must to be a valid link from
the rt6_info to the fib6_node. Otherwise we cannot check the serial
number. As I currently see we also need a link from the fib6_node down
to the dst entry for resource management. Thus we would have to insert
the special dst-entry with RTF_GATEWAY and non-null rt6i_gateway back
into the fib and have it globally visible. This could have unforseen
side effects. We still cache all dst entries in the fib. One think I
foresee as a possible problem is the automatic aggregation of ECMP routes,
too.

IPv4 does not seem to need this link at all.

> > ipvs caches the dst in its own infrastructure, so we need to be sure we don't
> > disconnect this dst from the ipv6 routing table, otherwise ip6_dst_check won't
> > recognize when relookups should be done. Playing games with RTF_GATEWAY seems
> > dangerous then.
> 
> 	dst_check works for IPVS. There is a problem only
> with the recent changes that moved the indication for PMTU
> change from dst_check to dst_mtu() calls. But this is safe 
> for IPVS, it handles FRAG_NEEDED for the tunneling mode itself.

Ok, I see.

> 	Initially, I thought IPv6 stores zeroes in rt6i_gateway.
> But now I see rt6_alloc_cow() to be called for the case I assumed
> to fail - when no gateway is used.
> 
> 	So, I'll try to test the IPVS case in the following 1-2 days
> and will report after adding some printks. If xt_TEE has
> the same problem then it should not be IPVS-specific. RAW not
> tested yet.

We should provide something similar to what IPv4 does with the
KNOWN_NH flag. I guess my idea with exchanging rt6i_dst as nexthop would
solve this without too much hassle but this would have to be checked by
implementing it.

I don't think that storing a changed nexthop in the ipv6 cb is that nice and
maintainable.

Greetings,

  Hannes

