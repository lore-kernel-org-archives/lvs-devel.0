From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch v2.8 1/4] netfilter: xt_ipvs (netfilter matcher for IPVS)
Date: Fri, 23 Jul 2010 12:44:51 +0200
Message-ID: <4C4972A3.7070508@trash.net>
References: <20100722073547.504156161@vergenet.net> <20100722075012.385241097@vergenet.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100722075012.385241097@vergenet.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Malcolm Turnbull <malcolm@loadbalancer.org>, Mark Brooks <mark@loadbalancer.org>, Wensong Zhang <wensong@linux-vs.org>, Julius Volz <julius.volz@gmail.com>, "David S. Miller" <davem@davemloft.net>, Hannes Eder <heder@google.com>, Jan Engelhardt <jengelh@medozas.de>

Am 22.07.2010 09:35, schrieb Simon Horman:
> From:	Hannes Eder <heder@google.com>
> 
> This implements the kernel-space side of the netfilter matcher xt_ipvs.
> 
> [ minor fixes by Simon Horman <horms@verge.net.au> ]
> Signed-off-by: Hannes Eder <heder@google.com>
> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> --- 
> 
>  include/linux/netfilter/xt_ipvs.h |   27 ++++
>  net/netfilter/Kconfig             |   10 +
>  net/netfilter/Makefile            |    1 
>  net/netfilter/ipvs/ip_vs_proto.c  |    1 
>  net/netfilter/xt_ipvs.c           |  189 +++++++++++++++++++++++++++++++++++++

I added xt_ipvs.h to Kbuild and applied the patch, thanks.
