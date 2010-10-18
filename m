From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [RFC PATCH 1/9] ipvs network name space aware
Date: Mon, 18 Oct 2010 11:54:34 +0200
Message-ID: <201010181154.35792.hans.schillstrom@ericsson.com>
References: <201010081316.46690.hans.schillstrom@ericsson.com> <4CBC0C6D.1080303@free.fr>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4CBC0C6D.1080303@free.fr>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Daniel Lezcano <daniel.lezcano@free.fr>
Cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "horms@verge.net.au" <horms@verge.net.au>, "ja@ssi.bg" <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>

On Monday 18 October 2010 10:59:25 Daniel Lezcano wrote:
> On 10/08/2010 01:16 PM, Hans Schillstrom wrote:
> > This part contains the include files
> > where include/net/netns/ip_vs.h is new and contains all moved vars.
> >
> > SUMMARY
> >
> >   include/net/ip_vs.h                     |  136 ++++---
> >   include/net/net_namespace.h             |    2 +
> >   include/net/netns/ip_vs.h               |  112 +++++
> >
> > Signed-off-by:Hans Schillstrom<hans.schillstrom@ericsson.com>
> > ---
> >
> >    
> 
> [ ... ]
> 
> >   #ifdef CONFIG_IP_VS_IPV6
> > diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
> > index bd10a79..b59cdc5 100644
> > --- a/include/net/net_namespace.h
> > +++ b/include/net/net_namespace.h
> > @@ -15,6 +15,7 @@
> >   #include<net/netns/ipv4.h>
> >   #include<net/netns/ipv6.h>
> >   #include<net/netns/dccp.h>
> > +#include<net/netns/ip_vs.h>
> >   #include<net/netns/x_tables.h>
> >   #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
> >   #include<net/netns/conntrack.h>
> > @@ -91,6 +92,7 @@ struct net {
> >   	struct sk_buff_head	wext_nlevents;
> >   #endif
> >   	struct net_generic	*gen;
> > +	struct netns_ipvs       *ipvs;
> >   };
> >    
> 
> IMHO, it would be better to use the net_generic infra-structure instead 
> of adding a new field in the netns structure.
> 
> 
I realized that to, but the performance penalty is quite high with net_generic :-(
But on the other hand if you are going to backport it, (without recompiling the kernel)
you gonna need it!

My sugestion, take both with a configuration switch like:
(i.e. avoid the rcu locking)

--- net/ip_vs.h ---
...
extern int ip_vs_net_id;		/* net id for ip_vs */


static inline struct netns_ipvs * net_ipvs(struct net* net, int id) {
#ifdef CONFIG_IP_VS_FAST_NETNS
	return net->ipvs;
#else
	return (struct netns_ipvs *)net_generic(net, id);
#endif
}
...

and where you need the netns_ipvs struct ptr,
[snip]
struct ip_vs_conn *ip_vs_conn_in_get(struct net *net, ....
{
	struct netns_ipvs *ipvs = net_ipvs(net, ip_vs_net_id);
...

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
