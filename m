From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch 2/3] ipvs: supply a valid 0 address to ip_vs_conn_new()
Date: Tue, 16 Sep 2008 20:25:34 +1000
Message-ID: <20080916102533.GA570@verge.net.au>
References: <20080916071318.939200044@vergenet.net> <20080916071610.570391582@vergenet.net> <alpine.LNX.2.00.0809161119040.3805@titan.stealer.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.0809161119040.3805@titan.stealer.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sven Wegener <sven.wegener@stealer.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Julius Volz <juliusv@google.com>, Vince Busam <vbusam@google.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Tue, Sep 16, 2008 at 11:25:21AM +0200, Sven Wegener wrote:
> On Tue, 16 Sep 2008, Simon Horman wrote:
> 
> > ip_vs_conn_new expects a union nf_inet_addr as the type for its address
> > parameters, not a plain integer.
> > 
> > This problem was detected by sparse.
> > 
> > make C=1
> >   CHECK   net/ipv4/ipvs/ip_vs_core.c
> > net/ipv4/ipvs/ip_vs_core.c:469:9: warning: Using plain integer as NULL pointer
> > 
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> > 
> > Index: lvs-2.6/net/ipv4/ipvs/ip_vs_core.c
> > ===================================================================
> > --- lvs-2.6.orig/net/ipv4/ipvs/ip_vs_core.c	2008-09-16 15:28:40.000000000 +1000
> > +++ lvs-2.6/net/ipv4/ipvs/ip_vs_core.c	2008-09-16 15:28:47.000000000 +1000
> > @@ -457,6 +457,7 @@ int ip_vs_leave(struct ip_vs_service *sv
> >  	if (sysctl_ip_vs_cache_bypass && svc->fwmark && unicast) {
> >  		int ret, cs;
> >  		struct ip_vs_conn *cp;
> > +		union nf_inet_addr daddr =  { .all = { 0, 0, 0, 0 } };
> 
> Could be static and const, to avoid allocation and initialization on the 
> stack every time. But I don't think this a critical code path.

Agreed, but I think I would rather leave it as is for now.

> >  
> >  		ip_vs_service_put(svc);
> >  
> > @@ -465,7 +466,7 @@ int ip_vs_leave(struct ip_vs_service *sv
> >  		cp = ip_vs_conn_new(svc->af, iph.protocol,
> >  				    &iph.saddr, pptr[0],
> >  				    &iph.daddr, pptr[1],
> > -				    0, 0,
> > +				    &daddr, 0,
> >  				    IP_VS_CONN_F_BYPASS,
> >  				    NULL);
> >  		if (cp == NULL)

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

