From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by IPVS
Date: Wed, 16 Oct 2013 11:14:49 +0900
Message-ID: <20131016021449.GB17801@verge.net.au>
References: <1381881751-6719-1-git-send-email-horms@verge.net.au>
 <20131016005322.GA18135@order.stressinduktion.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131016005322.GA18135@order.stressinduktion.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Mark Brooks <mark@loadbalancer.org>

On Wed, Oct 16, 2013 at 02:53:22AM +0200, Hannes Frederic Sowa wrote:
> On Wed, Oct 16, 2013 at 09:02:31AM +0900, Simon Horman wrote:
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
> > 
> > * This covers all IPv6 packets output by IPVS but actually
> >   only those output using IPVS Direct-Routing need this.  One way to
> >   resolve this would be to add a more fine-grained ipvs_property to
> >   struct sk_buff.
> 
> Hmm, that reminds me on the following bug report which would be nice we could
> solve in one go, too: http://www.spinics.net/lists/netdev/msg250785.html

I think it should be possible to solve that using the
IP6CB() approach that Eric suggested. Hopefully we can make
that approach fly.
