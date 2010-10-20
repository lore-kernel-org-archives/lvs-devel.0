From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [RFC PATCH 1/9] ipvs network name space aware
Date: Wed, 20 Oct 2010 10:25:19 +0200
Message-ID: <201010201025.20950.hans.schillstrom@ericsson.com>
References: <201010081316.46690.hans.schillstrom@ericsson.com> <201010181523.49568.hans.schillstrom@ericsson.com> <20101019184436.GG2362@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101019184436.GG2362@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>
Cc: Daniel Lezcano <daniel.lezcano@free.fr>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "horms@verge.net.au" <horms@verge.net.au>, "ja@ssi.bg" <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>

On Tuesday 19 October 2010 20:44:36 Paul E. McKenney wrote:
> On Mon, Oct 18, 2010 at 03:23:48PM +0200, Hans Schillstrom wrote:
> > On Monday 18 October 2010 13:37:38 Daniel Lezcano wrote:
> > > On 10/18/2010 11:54 AM, Hans Schillstrom wrote:
> > > > On Monday 18 October 2010 10:59:25 Daniel Lezcano wrote:
> > > >
> > > >> On 10/08/2010 01:16 PM, Hans Schillstrom wrote:
> > > >>
> > > >>> This part contains the include files
> > > >>> where include/net/netns/ip_vs.h is new and contains all moved vars.
> > > >>>
> > > >>> SUMMARY
> > > >>>
> > > >>>    include/net/ip_vs.h                     |  136 ++++---
> > > >>>    include/net/net_namespace.h             |    2 +
> > > >>>    include/net/netns/ip_vs.h               |  112 +++++
> > > >>>
> > > >>> Signed-off-by:Hans Schillstrom<hans.schillstrom@ericsson.com>
> > > >>> ---
> > > >>>
> > > >>>
> > > >>>
> > > >> [ ... ]
> > > >>
> > > >>
> > > >>>    #ifdef CONFIG_IP_VS_IPV6
> > > >>> diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
> > > >>> index bd10a79..b59cdc5 100644
> > > >>> --- a/include/net/net_namespace.h
> > > >>> +++ b/include/net/net_namespace.h
> > > >>> @@ -15,6 +15,7 @@
> > > >>>    #include<net/netns/ipv4.h>
> > > >>>    #include<net/netns/ipv6.h>
> > > >>>    #include<net/netns/dccp.h>
> > > >>> +#include<net/netns/ip_vs.h>
> > > >>>    #include<net/netns/x_tables.h>
> > > >>>    #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
> > > >>>    #include<net/netns/conntrack.h>
> > > >>> @@ -91,6 +92,7 @@ struct net {
> > > >>>    	struct sk_buff_head	wext_nlevents;
> > > >>>    #endif
> > > >>>    	struct net_generic	*gen;
> > > >>> +	struct netns_ipvs       *ipvs;
> > > >>>    };
> > > >>>
> > > >>>
> > > >> IMHO, it would be better to use the net_generic infra-structure instead
> > > >> of adding a new field in the netns structure.
> > > >>
> > > >>
> > > >>
> > > > I realized that to, but the performance penalty is quite high with net_generic :-(
> > > > But on the other hand if you are going to backport it, (without recompiling the kernel)
> > > > you gonna need it!
> > > >
> > >
> > > Hmm, yes. We don't want to have the init_net_ns performances to be impacted.
> > >
> > > You use here a pointer which will be dereferenced like the net_generic,
> > > I don't think there will be
> > > a big difference between using net_generic and using a pointer in the
> > > net namespace structure.
> > >
> > > The difference is the id usage, but this one is based on the idr which
> > > is quite fast.
> > >
> >
> > I'm not so sure about that, have a look at net_generic and rcu_read_lock
> > and compare
> >  ipvs = net->ipvs;
> > vs.
> >  ipvs = net_generic(net, id)
> >
> > static inline void *net_generic(struct net *net, int id)
> > {
> > 	struct net_generic *ng;
> > 	void *ptr;
> >
> > 	rcu_read_lock();
> > 	ng = rcu_dereference(net->gen);
> > 	BUG_ON(id == 0 || id > ng->len);
> > 	ptr = ng->ptr[id - 1];
> > 	rcu_read_unlock();
> >
> > 	return ptr;
> > }
> > ...
> > static inline void rcu_read_lock(void)
> > {
> >         __rcu_read_lock();
> >         __acquire(RCU);
> >         rcu_read_acquire();
> > }
> >
> > Another way of doing it is to pass the ipvs ptr instead of the net ptr,
> > and add *net to the ipvs struct.
> >
> > > We should experiment a bit here to compare both solutions.
> > Agre
> > >
> > I single stepped through the rcu_read_lock() on a x86_64
> > and it's quite many "stepi" that you need to enter :-(
>
> Was this by chance with lockdep enabled?  If not, could you please send
> your .config?
>
> 							Thanx, Paul

No lockdep, but what I ment is that net_generic is not as fast as a plain ptr->xxx.
IPVS has hooks in the netfilter chain, and gets a huge amount of packets .

I don't think IPVS is a candidate for net_generic, it should have its own part in "struct net"
That was my point.
( No critic to locking or net_generic)

--
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
