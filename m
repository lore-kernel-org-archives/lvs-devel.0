From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH nf v2] ipvs: fix AF assignment in ip_vs_conn_new()
Date: Tue, 4 Feb 2014 18:08:00 +0900
Message-ID: <20140204090800.GC8144@verge.net.au>
References: <alpine.LFD.2.11.1401292319030.1844@ja.home.ssi.bg>
 <20140130075020.7A903E916F@unicorn.suse.cz>
 <alpine.LFD.2.11.1401301022170.1644@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1401301022170.1644@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Michal Kubecek <mkubecek@suse.cz>, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>

On Thu, Jan 30, 2014 at 10:29:22AM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 30 Jan 2014, Michal Kubecek wrote:
> 
> > If a fwmark is passed to ip_vs_conn_new(), it is passed in
> > vaddr, not daddr. Therefore we should set AF to AF_UNSPEC in
> > vaddr assignment (like we do in ip_vs_ct_in_get()), otherwise we
> > may copy only first 4 bytes of an IPv6 address into cp->daddr.
> > 
> > v2: fix messed up {d,v}addr and p->{d,v}addr, add info about the
> > outcome (thanks to Julian Anastasov)
> > 
> > Signed-off-by: Bogdano Arendartchuk <barendartchuk@suse.com>
> > Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Looks like problem comes from
> commit be8be9eccbf2d908a7e56b3f7a71105cd88da06b
> "ipvs: Fix IPv4 FWMARK virtual services" (2.6.30).

Thanks, I'll queue this up.

> 
> > ---
> >  net/netfilter/ipvs/ip_vs_conn.c | 8 ++++----
> >  1 file changed, 4 insertions(+), 4 deletions(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> > index 59a1a85..a8eb0a8 100644
> > --- a/net/netfilter/ipvs/ip_vs_conn.c
> > +++ b/net/netfilter/ipvs/ip_vs_conn.c
> > @@ -871,11 +871,11 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
> >  	cp->protocol	   = p->protocol;
> >  	ip_vs_addr_set(p->af, &cp->caddr, p->caddr);
> >  	cp->cport	   = p->cport;
> > -	ip_vs_addr_set(p->af, &cp->vaddr, p->vaddr);
> > -	cp->vport	   = p->vport;
> > -	/* proto should only be IPPROTO_IP if d_addr is a fwmark */
> > +	/* proto should only be IPPROTO_IP if p->vaddr is a fwmark */
> >  	ip_vs_addr_set(p->protocol == IPPROTO_IP ? AF_UNSPEC : p->af,
> > -		       &cp->daddr, daddr);
> > +		       &cp->vaddr, p->vaddr);
> > +	cp->vport	   = p->vport;
> > +	ip_vs_addr_set(p->af, &cp->daddr, daddr);
> >  	cp->dport          = dport;
> >  	cp->flags	   = flags;
> >  	cp->fwmark         = fwmark;
> > -- 
> > 1.8.1.4
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
