From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by IPVS
Date: Sat, 19 Oct 2013 20:34:33 +0200
Message-ID: <20131019183433.GC31333@order.stressinduktion.org>
References: <1381881751-6719-1-git-send-email-horms@verge.net.au> <alpine.LFD.2.03.1310180153250.4554@ssi.bg> <20131018021008.GH18135@order.stressinduktion.org> <alpine.LFD.2.03.1310191919290.1469@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.03.1310191919290.1469@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Mark Brooks <mark@loadbalancer.org>, Phil Oester <kernel@linuxace.com>

On Sat, Oct 19, 2013 at 07:37:10PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 18 Oct 2013, Hannes Frederic Sowa wrote:
> 
> > I played around with your patch and tested xt_TEE. I added a TEE rule to
> > mangle/OUTPUT and pinged. This happend, I have not yet analyzed it:
> > 
> > [  101.126649] ------------[ cut here ]------------
> > [  101.128436] BUG: unable to handle kernel paging request at fffffffb8a2fda88
> > [  101.129421] IP: [<ffffffff810c9737>] cpuacct_charge+0x97/0x200
> > [  101.129421] PGD 1c0f067 PUD 0
> > [  101.129421] Thread overran stack, or stack corrupted
> 
> 	Problem with process stack? May be some packet loop
> happens? Because I can not reproduce such problem in my
> virtual setup, I tested TEE too, with careful packet
> matching and 1 CPU. Should I assume that you don't have such
> oops when the patch is not applied, with the same TEE rule?

Oh, sorry, you are right. It happens with an unpatched net-next  kernel, too.

I inserted the TEE rule in mangel/OUTGOING and had only one route, ip -6 r a
default via fe80::1 dev eth0 which at the time of the panic was actually not
reachable.

> > [  101.129421] Oops: 0000 [#1] SMP
> 
> 	You don't appear to have PREEMPT in above line.
> I'm not sure when preemption is enabled if tee_tg6() does
> not have a problem with its anti-loop measures (tee_active).
> Is preemption possible in OUTPUT hook, i.e. can we change
> the CPU while playing with tee_active and as result change
> different flag?

Hm, maybe. I don't have too much insight into netfilter stack and
what are the differences between OUTPUT and FORWARD path but plan to
investigate. ;)

Anyways just wanted to let you know that unpatched kernels are affected, too.
Will have a closer look later.

Greetings,

  Hannes

