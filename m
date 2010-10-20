From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 1/9] ipvs network name space aware
Date: Wed, 20 Oct 2010 09:02:06 -0700
Message-ID: <20101020160205.GB2386@linux.vnet.ibm.com>
References: <201010081316.46690.hans.schillstrom@ericsson.com>
 <201010181523.49568.hans.schillstrom@ericsson.com>
 <20101019184436.GG2362@linux.vnet.ibm.com>
 <201010201025.20950.hans.schillstrom@ericsson.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201010201025.20950.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Daniel Lezcano <daniel.lezcano@free.fr>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "horms@verge.net.au" <horms@verge.net.au>, "ja@ssi.bg" <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>

On Wed, Oct 20, 2010 at 10:25:19AM +0200, Hans Schillstrom wrote:
> On Tuesday 19 October 2010 20:44:36 Paul E. McKenney wrote:
> > On Mon, Oct 18, 2010 at 03:23:48PM +0200, Hans Schillstrom wrote:
> > > On Monday 18 October 2010 13:37:38 Daniel Lezcano wrote:
> > > > On 10/18/2010 11:54 AM, Hans Schillstrom wrote:
> > > > > On Monday 18 October 2010 10:59:25 Daniel Lezcano wrote:
> > > > >
> > > > >> On 10/08/2010 01:16 PM, Hans Schillstrom wrote:
> > > > >>
> > > > >>> This part contains the include files
> > > > >>> where include/net/netns/ip_vs.h is new and contains all moved vars.
> > > > >>>
> > > > >>> SUMMARY
> > > > >>>
> > > > >>>    include/net/ip_vs.h                     |  136 ++++---
> > > > >>>    include/net/net_namespace.h             |    2 +
> > > > >>>    include/net/netns/ip_vs.h               |  112 +++++
> > > > >>>
> > > > >>> Signed-off-by:Hans Schillstrom<hans.schillstrom@ericsson.com>
> > > > >>> ---
> > > > >>>
> > > > >>>
> > > > >>>
> > > > >> [ ... ]
> > > > >>
> > > > >>
> > > > >>>    #ifdef CONFIG_IP_VS_IPV6
> > > > >>> diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
> > > > >>> index bd10a79..b59cdc5 100644
> > > > >>> --- a/include/net/net_namespace.h
> > > > >>> +++ b/include/net/net_namespace.h
> > > > >>> @@ -15,6 +15,7 @@
> > > > >>>    #include<net/netns/ipv4.h>
> > > > >>>    #include<net/netns/ipv6.h>
> > > > >>>    #include<net/netns/dccp.h>
> > > > >>> +#include<net/netns/ip_vs.h>
> > > > >>>    #include<net/netns/x_tables.h>
> > > > >>>    #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
> > > > >>>    #include<net/netns/conntrack.h>
> > > > >>> @@ -91,6 +92,7 @@ struct net {
> > > > >>>    	struct sk_buff_head	wext_nlevents;
> > > > >>>    #endif
> > > > >>>    	struct net_generic	*gen;
> > > > >>> +	struct netns_ipvs       *ipvs;
> > > > >>>    };
> > > > >>>
> > > > >>>
> > > > >> IMHO, it would be better to use the net_generic infra-structure instead
> > > > >> of adding a new field in the netns structure.
> > > > >>
> > > > >>
> > > > >>
> > > > > I realized that to, but the performance penalty is quite high with net_generic :-(
> > > > > But on the other hand if you are going to backport it, (without recompiling the kernel)
> > > > > you gonna need it!
> > > > >
> > > >
> > > > Hmm, yes. We don't want to have the init_net_ns performances to be impacted.
> > > >
> > > > You use here a pointer which will be dereferenced like the net_generic,
> > > > I don't think there will be
> > > > a big difference between using net_generic and using a pointer in the
> > > > net namespace structure.
> > > >
> > > > The difference is the id usage, but this one is based on the idr which
> > > > is quite fast.
> > > >
> > >
> > > I'm not so sure about that, have a look at net_generic and rcu_read_lock
> > > and compare
> > >  ipvs = net->ipvs;
> > > vs.
> > >  ipvs = net_generic(net, id)
> > >
> > > static inline void *net_generic(struct net *net, int id)
> > > {
> > > 	struct net_generic *ng;
> > > 	void *ptr;
> > >
> > > 	rcu_read_lock();
> > > 	ng = rcu_dereference(net->gen);
> > > 	BUG_ON(id == 0 || id > ng->len);
> > > 	ptr = ng->ptr[id - 1];
> > > 	rcu_read_unlock();
> > >
> > > 	return ptr;
> > > }
> > > ...
> > > static inline void rcu_read_lock(void)
> > > {
> > >         __rcu_read_lock();
> > >         __acquire(RCU);
> > >         rcu_read_acquire();
> > > }
> > >
> > > Another way of doing it is to pass the ipvs ptr instead of the net ptr,
> > > and add *net to the ipvs struct.
> > >
> > > > We should experiment a bit here to compare both solutions.
> > > Agre
> > > >
> > > I single stepped through the rcu_read_lock() on a x86_64
> > > and it's quite many "stepi" that you need to enter :-(
> >
> > Was this by chance with lockdep enabled?  If not, could you please send
> > your .config?
> >
> > 							Thanx, Paul
> 
> No lockdep, but what I ment is that net_generic is not as fast as a plain ptr->xxx.
> IPVS has hooks in the netfilter chain, and gets a huge amount of packets .
> 
> I don't think IPVS is a candidate for net_generic, it should have its own part in "struct net"
> That was my point.
> ( No critic to locking or net_generic)

You said that there were a lot of "stepi" commands to get through
rcu_read_lock() on x86_64.  This is quite surprising, especially if you
built with CONFIG_RCU_TREE.  Even if you built with CONFIG_PREEMPT_RCU_TREE,
you should only see something like the following from rcu_read_lock():

000000b7 <__rcu_read_lock>:
      b7:	55                   	push   %ebp
      b8:	64 a1 00 00 00 00    	mov    %fs:0x0,%eax
      be:	ff 80 80 01 00 00    	incl   0x180(%eax)
      c4:	89 e5                	mov    %esp,%ebp
      c6:	5d                   	pop    %ebp
      c7:	c3                   	ret    

Unless you have some sort of debugging options turned on.  Or unless
six instructions counts for "quite many" stepi commands.  ;-)

So I am quite curious, independent of whether or not IPVS is a candidate
for net_generic.  That choice for IPVS is not mine to make, and I will
trust the relevant developers and maintainers to make the right choice,
whether that be RCU or something else.  Even I do not claim that RCU
is the right tool for all jobs!  ;-)

							Thanx, Paul
