From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by
 IPVS
Date: Sun, 20 Oct 2013 15:27:40 +0300 (EEST)
Message-ID: <alpine.LFD.2.03.1310201521580.1388@ssi.bg>
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

> Is your kernel compiled with CONFIG_IPV6_ROUTER_PREF?

	I tested with this flag, even with your patch,
added printk in rt6_probe_deferred() to be sure. But
in my setup without router I can not test it fully.

	I'm on 32-bit platform, so may be the shorter structs
fit in stack and I don't see oops.

Regards

--
Julian Anastasov <ja@ssi.bg>
