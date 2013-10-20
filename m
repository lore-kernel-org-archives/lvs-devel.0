From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by
 IPVS
Date: Sun, 20 Oct 2013 09:39:26 +0300 (EEST)
Message-ID: <alpine.LFD.2.03.1310200936590.1538@ssi.bg>
References: <1381881751-6719-1-git-send-email-horms@verge.net.au> <alpine.LFD.2.03.1310180153250.4554@ssi.bg> <20131018021008.GH18135@order.stressinduktion.org> <alpine.LFD.2.03.1310191919290.1469@ssi.bg> <20131019183433.GC31333@order.stressinduktion.org>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20131019183433.GC31333@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Simon Horman <horms@verge.net.au>, =?UTF-8?Q?YOSHIFUJI_Hideaki_=2F_=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?= <yoshfuji@linux-ipv6.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Mark Brooks <mark@loadbalancer.org>, Phil Oester <kernel@linuxace.com>


	Hello,

On Sat, 19 Oct 2013, Hannes Frederic Sowa wrote:

> On Sat, Oct 19, 2013 at 07:37:10PM +0300, Julian Anastasov wrote:
> > 
> > 	Problem with process stack? May be some packet loop
> > happens? Because I can not reproduce such problem in my
> > virtual setup, I tested TEE too, with careful packet
> > matching and 1 CPU. Should I assume that you don't have such
> > oops when the patch is not applied, with the same TEE rule?
> 
> Oh, sorry, you are right. It happens with an unpatched net-next  kernel, too.
> 
> I inserted the TEE rule in mangel/OUTGOING and had only one route, ip -6 r a
> default via fe80::1 dev eth0 which at the time of the panic was actually not
> reachable.

	Thanks for the confirmation! I'll try later
to reproduce such problem with TEE, it is interesting
to know the real reason for this loop.

Regards

--
Julian Anastasov <ja@ssi.bg>
