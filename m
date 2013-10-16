From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by IPVS
Date: Wed, 16 Oct 2013 16:32:46 +0200
Message-ID: <20131016143246.GB18135@order.stressinduktion.org>
References: <1381881751-6719-1-git-send-email-horms@verge.net.au> <alpine.LFD.2.03.1310161015550.1560@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.03.1310161015550.1560@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Mark Brooks <mark@loadbalancer.org>

On Wed, Oct 16, 2013 at 10:27:47AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Wed, 16 Oct 2013, Simon Horman wrote:
> 
> > In v3.9 6fd6ce2056de2709 ("ipv6: Do not depend on rt->n in
> > ip6_finish_output2()") changed the behaviour of ip6_finish_output2()
> > such that it creates and uses a neigh entry if none is found.
> > Subsequently the 'n' field was removed from struct rt6_info.
> 
> 	Similar change in IPv4 opened the Pandora box:
> IPVS, xt_TEE, raw.c (IP_HDRINCL). May be the corrsponding
> places in IPv6 have the same problem.
> 
> 	I don't know the IPv6 routing but if we find a way
> to keep the desired nexthop in rt6i_gateway and to add
> RTF_GATEWAY checks here and there such solution would be more
> general. FLOWI_FLAG_KNOWN_NH flag can help, if needed.

I thought about this yesterday but did not see an easy way. How does the IPv4
implementation accomplish this?

ipvs caches the dst in its own infrastructure, so we need to be sure we don't
disconnect this dst from the ipv6 routing table, otherwise ip6_dst_check won't
recognize when relookups should be done. Playing games with RTF_GATEWAY seems
dangerous then.

I am currently thinking about using a new flag to replace the nexthop
information with rt6i_dst in these circumstances. The flag would have
to be included in the skb somewhere.

Greetings,

  Hannes

