From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by
 IPVS
Date: Thu, 17 Oct 2013 01:50:38 +0300 (EEST)
Message-ID: <alpine.LFD.2.03.1310170115320.1917@ssi.bg>
References: <1381881751-6719-1-git-send-email-horms@verge.net.au> <alpine.LFD.2.03.1310161015550.1560@ssi.bg> <20131016143246.GB18135@order.stressinduktion.org> <alpine.LFD.2.03.1310162252220.1917@ssi.bg> <20131016215953.GD18135@order.stressinduktion.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20131016215953.GD18135@order.stressinduktion.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Simon Horman <horms@verge.net.au>, =?UTF-8?Q?YOSHIFUJI_Hideaki_=2F_=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?= <yoshfuji@linux-ipv6.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Mark Brooks <mark@loadbalancer.org>


	Hello,

On Wed, 16 Oct 2013, Hannes Frederic Sowa wrote:

> To have ip6_dst_check working, there must to be a valid link from
> the rt6_info to the fib6_node. Otherwise we cannot check the serial
> number. As I currently see we also need a link from the fib6_node down
> to the dst entry for resource management. Thus we would have to insert
> the special dst-entry with RTF_GATEWAY and non-null rt6i_gateway back
> into the fib and have it globally visible. This could have unforseen
> side effects. We still cache all dst entries in the fib. One think I
> foresee as a possible problem is the automatic aggregation of ECMP routes,
> too.

	I'm still not sure what is needed. Looking at
ip6_pol_route(), I see that everything should just work: for
routes without RTF_GATEWAY flag we return cloned route
from rt6_alloc_cow() with valid rt6i_gateway. I still
didn't tested the problem myself, so I'll stop with the
comments before that.

> We should provide something similar to what IPv4 does with the
> KNOWN_NH flag. I guess my idea with exchanging rt6i_dst as nexthop would
> solve this without too much hassle but this would have to be checked by
> implementing it.
> 
> I don't think that storing a changed nexthop in the ipv6 cb is that nice and
> maintainable.

	Agreed. I'm not going to test that change. I'll test
latest net-next without any changes to see where exactly is
the failure because the IPv6 routing seems capable for what
we need. I have problems with my setup, so I'll need some
days. As Simon is also testing the problem, he can find the
reason before me.

Regards

--
Julian Anastasov <ja@ssi.bg>
