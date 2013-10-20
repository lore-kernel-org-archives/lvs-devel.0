From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by
 IPVS
Date: Sun, 20 Oct 2013 11:33:54 +0300 (EEST)
Message-ID: <alpine.LFD.2.03.1310201118331.1538@ssi.bg>
References: <1381881751-6719-1-git-send-email-horms@verge.net.au> <alpine.LFD.2.03.1310180153250.4554@ssi.bg> <20131018021008.GH18135@order.stressinduktion.org> <alpine.LFD.2.03.1310191919290.1469@ssi.bg> <20131019183433.GC31333@order.stressinduktion.org>
 <20131019223657.GH31333@order.stressinduktion.org> <alpine.LFD.2.03.1310200939330.1538@ssi.bg> <20131020073308.GE27787@order.stressinduktion.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20131020073308.GE27787@order.stressinduktion.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Simon Horman <horms@verge.net.au>, =?UTF-8?Q?YOSHIFUJI_Hideaki_=2F_=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?= <yoshfuji@linux-ipv6.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Mark Brooks <mark@loadbalancer.org>, Phil Oester <kernel@linuxace.com>


	Hello,

On Sun, 20 Oct 2013, Hannes Frederic Sowa wrote:

> The caller I found was ip6t_do_table which does deactivate bottom halves.
> Maybe there are others I did not see, so double checking is better.

	Aha, I see.

> > 	In my test I used link route to local subnet, --gateway to IP
> > that is not present. I'll try other variants.
> 
> Is your kernel compiled with CONFIG_IPV6_ROUTER_PREF?

	Hm, no. I'll enable it. But it works for
RTF_GATEWAY, something I didn't tested before now.

> I cannot test my patch today any more, so I just leave it here. It is only
> compile tested. Maybe you can make use of it:

	I'll try it. But note that my test setup has
no any routers around.

Regards

--
Julian Anastasov <ja@ssi.bg>
