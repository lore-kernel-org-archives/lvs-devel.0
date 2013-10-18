From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by IPVS
Date: Fri, 18 Oct 2013 18:33:53 +0200
Message-ID: <20131018163353.GK18135@order.stressinduktion.org>
References: <1381881751-6719-1-git-send-email-horms@verge.net.au> <alpine.LFD.2.03.1310180153250.4554@ssi.bg> <20131018021008.GH18135@order.stressinduktion.org> <alpine.LFD.2.03.1310180921200.1581@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.03.1310180921200.1581@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Mark Brooks <mark@loadbalancer.org>, Phil Oester <kernel@linuxace.com>

On Fri, Oct 18, 2013 at 09:33:13AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 18 Oct 2013, Hannes Frederic Sowa wrote:
> 
> > I played around with your patch and tested xt_TEE. I added a TEE rule to
> > mangle/OUTPUT and pinged. This happend, I have not yet analyzed it:
> 
> 	May be a side effect of using some multicast address?
> Can you test it with such address check?:

I don't think that is the reason.

> 
> 	if (rt->rt6i_flags & RTF_GATEWAY ||
> 	    ipv6_addr_type(&rt->rt6i_gateway) & IPV6_ADDR_UNICAST)

Just checked, I had the same panic.

Greetings,

  Hannes

