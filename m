From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence support
Date: Mon, 8 Nov 2010 16:07:00 +0100
Message-ID: <201011081607.01385.hans.schillstrom@ericsson.com>
References: <201010291415.35299.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1011081027080.1504@ja.ssi.bg> <20101108111600.GA14454@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101108111600.GA14454@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>

On Monday 08 November 2010 12:16:02 Simon Horman wrote:
> On Mon, Nov 08, 2010 at 10:51:58AM +0200, Julian Anastasov wrote:
> >
> > 	Hello,
> >
> > On Mon, 8 Nov 2010, Simon Horman wrote:
> >
> > >>>But dest could be created as part of failover and thus
> > >>>exist by the time any packets need to be forwarded, right?
> > >>>
> > >>>There are cases, such as where the backup is also a real-server
> > >>>that its rather inconvenient for svc and dst to exist while
> > >>>synchronisation information is being received.
> > >>
> > >>	OK, then we should not reach request_module,
> > >>new arg to ip_vs_pe_get() can specify that we call it
> > >>from interrupt, so the PE must be already loaded as module.
> > >>Then cp->pe can hold the reference to PE until
> > >>we bind the template to svc and dest where svc->pe
> > >>should be compared to ct->pe. ct->pe is needed only
> > >>for this purpose because later it can be determined
> > >>from svc.
> > >
> > >Do you have a preference for this approach
> > >over making ip_vs_pe_sip non-modular?
> >
> > 	We already decided about "IPVS: Add persistence engine to
> > connection entry", so cp->pe should be attached to backup
> > and I hope Hans will add checks for same PE in ip_vs_find_dest
> > and ip_vs_try_bind_dest.

Sure.

> > Then the only problem remains
> > to change code so that request_module is not called by
> > softirq. If the svc is not created yet in backup to
> > load the PE module, it must be loaded manually to
> > allow connections with PE to be created. If you still
> > prefer to see some code I have to create fresh tree later
> > today. May be if Hans uses ip_vs_pe_getbyname instead of
> > ip_vs_pe_get that should solve the request_module problem.

From my point of view it's a configuration error,
if the pe modules aint loaded in the backup machine.

>
> I changed things around a bit in "IPVS: Add persistence engine to
> connection entry".
>
> 	ip_vs_pe_getbyname() became __ip_vs_pe_getbyname()
> 	ip_vs_pe_get() became ip_vs_pe_getbyname()
> 	And ip_vs_pe_get() now just takes a reference on the module if its
> 	loaded.
>
> So yes I agree, except that __ip_vs_pe_getbyname() is the name
> of the function that should be called, which needs to be made
> un-static and possibly renamed (again).
>
> Also, to __ip_vs_pe_getbyname() calls try_module_get().
> Is that safe from interrupt context?

I think so, or at least it seems to work :-)

> > 	What should we do if PE module is not loaded
> > while we are creating connection in backup? We can not
> > load modules, may be when connection is bound to
> > dest+svc we should inherit the PE from svc->pe ?

I think we shoud drop that conn.
(Still I think it's a configuration error)

>
> If the modules isn't loaded, then svc->pe can't be non-NULL, right?
>
> > May be using request_module_nowait is not an option
> > because we risk to try forever if module is not
> > present.
>
> That does not sound desirable.

I tried before and got a dump...

>
> > >> But I see another problem which is not backup
> > >> specific: how ip_vs_sip_ct_match knows that ct->pe_data
> > >> is created by ip_vs_sip_fill_param and not by another PE?
> > >> We need to compare p->pe with cp->pe in ip_vs_ct_in_get
> > >> before calling ct_match.
> > >
> > > Yes, I agree that is a problem.
> > >
> > > In practice it won't be affecting anyone at this time
> > > as there is only one pe.
> > >
> > > How about this, which applies on top of
> > > "IPVS: Add persistence engine to connection entry".
> >
> >	Yes, it is fine
>
> Thanks. I have pushed "IPVS: Add persistence engine to connection entry",
> the change below, and a few other (unrelated) changes that I have been
> sitting on into a staging branch of lvs-test-2.6.
>
> I may rebase the staging branch - by which I mean its intended
> to be a transient branch - but I figure its better than nothing.
>
Thanks

> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> >
> > > From: Simon Horman <horms@verge.net.au>
> > > Subject: IPVS: Only match pe_data created by the same pe
> > >
> > > Only match persistence engine data if it was
> > > created by the same persistence engine.
> > >
> > > Reported-by: Julian Anastasov <ja@ssi.bg>
> > > Signed-off-by: Simon Horman <horms@verge.net.au>
> > >
> > > Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_conn.c
> > > ===================================================================
> > > --- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c	2010-11-08 15:18:57.000000000 +0900
> > > +++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_conn.c	2010-11-08 15:19:02.000000000 +0900
> > > @@ -354,7 +354,7 @@ struct ip_vs_conn *ip_vs_ct_in_get(const
> > >
> > > 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
> > > 		if (p->pe_data && p->pe->ct_match) {
> > > -			if (p->pe->ct_match(p, cp))
> > > +			if (p->pe == cp->pe && p->pe->ct_match(p, cp))
> > > 				goto out;
> > > 			continue;
> > > 		}
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
