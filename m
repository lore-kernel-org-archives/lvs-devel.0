From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: ipvs netns exit causes crash in conntrack.
Date: Fri, 10 Jun 2011 11:02:39 +0200
Message-ID: <201106101102.41234.hans.schillstrom@ericsson.com>
References: <201106091457.29205.hans@schillstrom.com> <201106092146.35494.hans@schillstrom.com> <alpine.LFD.2.00.1106092325350.1472@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1106092325350.1472@ja.ssi.bg>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Hans Schillstrom <hans@schillstrom.com>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>

On Thursday 09 June 2011 23:13:33 Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 9 Jun 2011, Hans Schillstrom wrote:
> 
> > > This looks like nfnetlink.c excited and destroyed the nfnl socket, but
> > > ip_vs was still holding a reference to a conntrack. When the conntrack
> > > got destroyed it created a ctnetlink event, causing an oops in
> > > netlink_has_listeners when trying to use the destroyed nfnetlink
> > > socket.
> > > 
> > > Usually this shouldn't happen since network namespace cleanup
> > > happens in reverse order from registration. In this case the
> > > reason might be that IPVS has no dependencies on conntrack
> > > or ctnetlink and therefore can get loaded first, meaning it
> > > will get cleaned up afterwards.
> > > 
> > > Does that make any sense?
> > > 
> > Yes,  
> > >From what I can see is ip_vs have a dependency on nf_conntrack but not on nf_conntrack_netlink
> > i.e. nf_conntrack is loded first and then ip_vs and last nf_conntrack_netlink
> 
> 	Yes, may be nfnetlink subsys is unregistered first,
> before ipvs and net->nfnl is already NULL. Note that
> nf_conntrack_find_get returns existing conntrack, so
> this module is still active for the net. Then I'm wondering,
> may be this can happen even without IPVS if conntrack flushes
> connections after nfnetlink is unregistered. Not sure, may be
> nfnetlink_has_listeners() and other funcs need proper
> rcu_dereference for net->nfnl under rcu. Also, nfnetlink_send
> should free the skb if net->nfnl is NULL.
> 
> > It's hard to tell exactly what was going on in user-space when the lxc container get killed....
> > Basically there is a lot of traffic (and connections) through the container with ipvs inside,
> > - ipvs conntrack support is turned on
> > - iptables with conntrack 
> > - conntrackd is running 
> > - ~50 iptables rules
> > I'm not sure if it's only IPv4 traffic ...
> > 
> > Hmmm... I think I know,  the culprit is conntrackd !! (i.e. it causes loading of ct_netlink)
> > conntrackd will definitely get killed before the namespace exit starts 
> > I think it is like you describe, I will make some test tomorrow.
> > How to solve this is another question....
> 
> 	In IPVS we can add checks to exit ip_vs_conn_drop_conntrack()
> early if net cleanup is in progress because conntrack can be
> loaded after IPVS and its cleanup called before IPVS.
> We do not need to delete conntrack while in IPVS cleanup.

This is a quite simple patch ... 
The enable flag is set to 0 already when an exit begins 
So it's just to check it
maybe it should be atomic, but for my quick test "volatile" will do.

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index bf28ac2..ae5e9e2 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -775,8 +775,8 @@ static void ip_vs_conn_expire(unsigned long data)
                /* does anybody control me? */
                if (cp->control)
                        ip_vs_control_del(cp);
