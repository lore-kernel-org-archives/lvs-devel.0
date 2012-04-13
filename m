From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 1/2] ipvs: reset ipvs pointer in netns
Date: Fri, 13 Apr 2012 15:41:50 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1204131339340.1806@ja.ssi.bg>
References: <1334306642-3765-1-git-send-email-ja@ssi.bg> <1334306642-3765-2-git-send-email-ja@ssi.bg> <201204131129.10283.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201204131129.10283.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Simon Horman <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>


	Hello,

On Fri, 13 Apr 2012, Hans Schillstrom wrote:

> > --- a/net/netfilter/ipvs/ip_vs_core.c
> > +++ b/net/netfilter/ipvs/ip_vs_core.c
> > @@ -1924,6 +1924,7 @@ protocol_fail:
> >  control_fail:
> >  	ip_vs_estimator_net_cleanup(net);
> >  estimator_fail:
> > +	net->ipvs = NULL;
> 
> You can't do this since name space cleanup will call __ip_vs_cleanup later
> and that will cause  NULL pointer problems

	This is not true. __ip_vs_init must free everything
on error as a netns init handler. What will happen if
net_generic fails and netns tries cleanup on such failed
subsys? __ip_vs_cleanup is called only after successful
__ip_vs_init.

	Looking at setup_net() it correctly uses
_continue_ list walking variant to call exit handler only
after successful init. Also, there is comment about this:

        /* Walk through the list backwards calling the exit functions
         * for the pernet modules whose init functions did not fail.
         */

	IPVS actually reaches __register_pernet_operations
where every net is added in net_exit_list for cleanup only
on successful init.

	It is true that some places such as ip_vs_in
and ip_vs_out touch net_ipvs(net) without any checks
for net->ipvs. This is not a problem because during
netns cleanup the devices are unregistered before
subsys (eg. IPVS), so we can not see packets during
cleanup. And on netns creation net is registered only
when all init handlers succeed. So, net->ipvs is
always safe to access in hooks.

	So, this patch should be not needed if only
one subsys was registered (IPVS core) but now we register
more:

- applications
- schedulers

	LBLC and LBLCR suffer from same problem. They
attach to net->ipvs without any checks for net->ipvs.

> Note that any netns init faiulure will be rolled back later by net_namespace.c
> And you will not receive any trafic into a namepace until all init is OK

	What I know about netns is:

- all registrations are in one list, all subsys before all devices

- exit handlers are called only on successful init

- exit handlers are called in reverse registration order: last
device, ... first device, last subsys ... first subsys

	So, if IPVS modules register any pernet handlers
they must check if net->ipvs (IPVS core) is successfully
initialized for netns. If Simon confirms that the patches
work I have to provide similar fix for the LBLC* schedulers.

	Simon, do you have IPVS core in kernel? I assume
this is the case, right? Not as a module?

Regards

--
Julian Anastasov <ja@ssi.bg>
