From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: ipvs netns exit causes crash in conntrack.
Date: Fri, 10 Jun 2011 11:38:05 +0200
Message-ID: <201106101138.05940.hans.schillstrom@ericsson.com>
References: <201106091457.29205.hans@schillstrom.com> <4DF0C67B.8040300@trash.net> <201106092146.35494.hans@schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201106092146.35494.hans@schillstrom.com>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>
Cc: Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>

On Thursday 09 June 2011 21:46:34 Hans Schillstrom wrote:
> On Thursday, June 09, 2011 15:11:23 Patrick McHardy wrote:
> > On 09.06.2011 14:57, Hans Schillstrom wrote:
> > > Hello 
> > > I have a problem with ip_vs_conn_flush() and expiring timers ...
> > > After a couple of hours checking locks,  I'm still not closer to a solution
> > > Conntrack differs a bit between 2.6.32 vs .2.6.39 but I don't think that's the reason in this case.
> > > 
> > > I think the netns cleanup cased this, but I'm not a conntrack expert :)
> > > 
> > > The dump below is from a back-ported ipvs to 2.6.32.27 
> > > The extra patches that renamed the cleanup patches is there that I sent to Simon i.e
> > > __ip_vs_conn_cleanup renamed to ip_vs_conn_net_cleanup  etc.
> > > 
> > 
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
> From what I can see is ip_vs have a dependency on nf_conntrack but not on nf_conntrack_netlink
> i.e. nf_conntrack is loded first and then ip_vs and last nf_conntrack_netlink

Tested,
with nf_conntrack_netlink loaded before ip_vs there is no problem.

> 
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
> 
> Thanks a lot Patrick.
> 


-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
