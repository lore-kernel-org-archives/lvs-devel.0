From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by IPVS
Date: Sun, 20 Oct 2013 08:47:33 +0200
Message-ID: <20131020064733.GD27787@order.stressinduktion.org>
References: <1381881751-6719-1-git-send-email-horms@verge.net.au> <alpine.LFD.2.03.1310180153250.4554@ssi.bg> <20131018021008.GH18135@order.stressinduktion.org> <alpine.LFD.2.03.1310191919290.1469@ssi.bg> <20131019183433.GC31333@order.stressinduktion.org> <alpine.LFD.2.03.1310200936590.1538@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.03.1310200936590.1538@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Mark Brooks <mark@loadbalancer.org>, Phil Oester <kernel@linuxace.com>

On Sun, Oct 20, 2013 at 09:39:26AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sat, 19 Oct 2013, Hannes Frederic Sowa wrote:
> 
> > On Sat, Oct 19, 2013 at 07:37:10PM +0300, Julian Anastasov wrote:
> > > 
> > > 	Problem with process stack? May be some packet loop
> > > happens? Because I can not reproduce such problem in my
> > > virtual setup, I tested TEE too, with careful packet
> > > matching and 1 CPU. Should I assume that you don't have such
> > > oops when the patch is not applied, with the same TEE rule?
> > 
> > Oh, sorry, you are right. It happens with an unpatched net-next  kernel, too.
> > 
> > I inserted the TEE rule in mangel/OUTGOING and had only one route, ip -6 r a
> > default via fe80::1 dev eth0 which at the time of the panic was actually not
> > reachable.
> 
> 	Thanks for the confirmation! I'll try later
> to reproduce such problem with TEE, it is interesting
> to know the real reason for this loop.

Yup, I have a patch in works wich defers the ndisc_send_ns call in
rt6_probe into a workqueue out of the call stack. This should solve
the problem.

Still wonder if there is a nicer api as to create a new structure and pass the
arguments via container_of dereferencing to the deferred function (and I
don't think async calls are useable there).

Greetings,

  Hannes

