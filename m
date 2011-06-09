From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ipvs netns exit causes crash in conntrack.
Date: Fri, 10 Jun 2011 00:13:33 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1106092325350.1472@ja.ssi.bg>
References: <201106091457.29205.hans@schillstrom.com> <4DF0C67B.8040300@trash.net> <201106092146.35494.hans@schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201106092146.35494.hans@schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>


	Hello,

On Thu, 9 Jun 2011, Hans Schillstrom wrote:

> > This looks like nfnetlink.c excited and destroyed the nfnl socket, but
> > ip_vs was still holding a reference to a conntrack. When the conntrack
> > got destroyed it created a ctnetlink event, causing an oops in
> > netlink_has_listeners when trying to use the destroyed nfnetlink
> > socket.
> > 
> > Usually this shouldn't happen since network namespace cleanup
> > happens in reverse order from registration. In this case the
> > reason might be that IPVS has no dependencies on conntrack
> > or ctnetlink and therefore can get loaded first, meaning it
> > will get cleaned up afterwards.
> > 
> > Does that make any sense?
> > 
> Yes,  
> >From what I can see is ip_vs have a dependency on nf_conntrack but not on nf_conntrack_netlink
> i.e. nf_conntrack is loded first and then ip_vs and last nf_conntrack_netlink

	Yes, may be nfnetlink subsys is unregistered first,
before ipvs and net->nfnl is already NULL. Note that
nf_conntrack_find_get returns existing conntrack, so
this module is still active for the net. Then I'm wondering,
may be this can happen even without IPVS if conntrack flushes
connections after nfnetlink is unregistered. Not sure, may be
nfnetlink_has_listeners() and other funcs need proper
rcu_dereference for net->nfnl under rcu. Also, nfnetlink_send
should free the skb if net->nfnl is NULL.

> It's hard to tell exactly what was going on in user-space when the lxc container get killed....
> Basically there is a lot of traffic (and connections) through the container with ipvs inside,
> - ipvs conntrack support is turned on
> - iptables with conntrack 
> - conntrackd is running 
> - ~50 iptables rules
> I'm not sure if it's only IPv4 traffic ...
> 
> Hmmm... I think I know,  the culprit is conntrackd !! (i.e. it causes loading of ct_netlink)
> conntrackd will definitely get killed before the namespace exit starts 
> I think it is like you describe, I will make some test tomorrow.
> How to solve this is another question....

	In IPVS we can add checks to exit ip_vs_conn_drop_conntrack()
early if net cleanup is in progress because conntrack can be
loaded after IPVS and its cleanup called before IPVS.
We do not need to delete conntrack while in IPVS cleanup.
It should solve this problem but may be nfnetlink needs some
protection for net->nfnl too.

Regards

--
Julian Anastasov <ja@ssi.bg>
