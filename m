From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 0/3] ipv6: use rt6i_gateway as nexthop
Date: Mon, 21 Oct 2013 11:35:41 +0200
Message-ID: <20131021093541.GG28333@order.stressinduktion.org>
References: <1382272985-1528-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1382272985-1528-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

On Sun, Oct 20, 2013 at 03:43:02PM +0300, Julian Anastasov wrote:
> 	The second patch is an optimization that makes sure
> all resulting routes have rt6i_gateway filled, so that we
> can avoid the complex ipv6_addr_any() call added to rt6_nexthop()
> by patch 1. And it sets rt6i_gateway for local routes, a case
> not handled by patch 1.

Not related to the patch:

That reminds me that Yoshifuji had the idea to cache the results for
ipv6_addr_type in IP6CB to avoid calling this function over and over again.
Maybe we can do the same for rt6_infos to save some cycles here and there.


Also, what do you think about this site:

net/ipv6/ip6_output.c:
    411 
    412                 rt = (struct rt6_info *) dst;
    413                 if (rt->rt6i_flags & RTF_GATEWAY)
    414                         target = &rt->rt6i_gateway;
    415                 else
    416                         target = &hdr->daddr;
    417 

Our provided skb_dst should come from ip6_route_input, thus ip6_pol_route. So
I assume we have rt6i_gateway == hdr->daddr there, too. It is a bit more
complicated because of possible routing extension headers. Maybe you already
looked at this already?

I just found it while searching which other code paths do emit packets
while xt_TEE is processing (generation of redirects) and could also lead
to stack exhaustion. But the path in ip6_forward seems fine.

Greetings,

  Hannes

