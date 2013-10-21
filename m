From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net 0/3] ipv6: use rt6i_gateway as nexthop
Date: Mon, 21 Oct 2013 23:02:57 +0300 (EEST)
Message-ID: <alpine.LFD.2.03.1310212237001.1785@ssi.bg>
References: <1382272985-1528-1-git-send-email-ja@ssi.bg> <20131021093541.GG28333@order.stressinduktion.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20131021093541.GG28333@order.stressinduktion.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>


	Hello,

On Mon, 21 Oct 2013, Hannes Frederic Sowa wrote:

> Not related to the patch:
> 
> That reminds me that Yoshifuji had the idea to cache the results for
> ipv6_addr_type in IP6CB to avoid calling this function over and over again.
> Maybe we can do the same for rt6_infos to save some cycles here and there.

	Yes, ipv6_addr_type has little price. May be only
DNAT and IPSec can complicate such caching.

> Also, what do you think about this site:
> 
> net/ipv6/ip6_output.c:
>     411 
>     412                 rt = (struct rt6_info *) dst;
>     413                 if (rt->rt6i_flags & RTF_GATEWAY)
>     414                         target = &rt->rt6i_gateway;
>     415                 else
>     416                         target = &hdr->daddr;
>     417 
> 
> Our provided skb_dst should come from ip6_route_input, thus ip6_pol_route. So
> I assume we have rt6i_gateway == hdr->daddr there, too. It is a bit more
> complicated because of possible routing extension headers. Maybe you already
> looked at this already?

	Yes, I checked every site that uses rt6i_gateway but
not with the perspective to use rt6_nexthop(). It seems
this is a rt6_nexthop() candidate.

> I just found it while searching which other code paths do emit packets
> while xt_TEE is processing (generation of redirects) and could also lead
> to stack exhaustion. But the path in ip6_forward seems fine.

	Yes. I found only one place more dangerous:
fib6_add_rt2node(). But I think its checks are still valid.

Regards

--
Julian Anastasov <ja@ssi.bg>
