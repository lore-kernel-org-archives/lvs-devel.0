From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by
 IPVS
Date: Sun, 20 Oct 2013 10:11:16 +0300 (EEST)
Message-ID: <alpine.LFD.2.03.1310200939330.1538@ssi.bg>
References: <1381881751-6719-1-git-send-email-horms@verge.net.au> <alpine.LFD.2.03.1310180153250.4554@ssi.bg> <20131018021008.GH18135@order.stressinduktion.org> <alpine.LFD.2.03.1310191919290.1469@ssi.bg> <20131019183433.GC31333@order.stressinduktion.org>
 <20131019223657.GH31333@order.stressinduktion.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20131019223657.GH31333@order.stressinduktion.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Simon Horman <horms@verge.net.au>, =?UTF-8?Q?YOSHIFUJI_Hideaki_=2F_=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?= <yoshfuji@linux-ipv6.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Mark Brooks <mark@loadbalancer.org>, Phil Oester <kernel@linuxace.com>


	Hello,

On Sun, 20 Oct 2013, Hannes Frederic Sowa wrote:

> > Hm, maybe. I don't have too much insight into netfilter stack and
> > what are the differences between OUTPUT and FORWARD path but plan to
> > investigate. ;)
> 
> It seems tables are processed with bh disabled, so no preemption while
> recursing. So I guess the use of tee_active is safe for breaking the
> tie here.

	May be, I'll check it again, for now I see only
rcu_read_lock() in nf_hook_slow() which is preemptable.
Looking at rcu_preempt_note_context_switch, many levels of
RCU locks are preemptable too.

> The reason I exhaust stack space is that we can actually send out packets
> while looking up routes (rt6_probe). The nonreachability of the default
> gateway and the to-teed-to box does the rest.

	In my test I used link route to local subnet,
--gateway to IP that is not present. I'll try other
variants.

> We need to change the route lookup of the duplicated packet in xt_tee to not
> cause ndisc probes to be generated.
> 
> The more I review the patch the more I think it is ok. But we could actually
> try to just always return rt6i_gateway, as we should always be handed a cloned
> rt6_info where the gateway is already filled in, no?

	Yes, this patch is ok and after spending the whole
saturday I'm preparing a new patch that will convert
rt6_nexthop() to return just rt6i_gateway, without daddr.
This can happen after filling rt6i_gateway in all places.

	For your concern for loopback, I don't see problem,
local/anycast route will have rt6i_gateway=IP, they are
simple DST_HOST routes. I'm preparing now the patches and
will post them in following hours.

Regards

--
Julian Anastasov <ja@ssi.bg>
