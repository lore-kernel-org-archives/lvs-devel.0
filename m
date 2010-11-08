From: Simon Horman <horms@verge.net.au>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence support
Date: Tue, 9 Nov 2010 06:49:43 +0900
Message-ID: <20101108214943.GC6502@verge.net.au>
References: <20101030231601.GA5908@verge.net.au>
 <201011032108.07311.hans.schillstrom@ericsson.com>
 <20101106005614.GA11220@verge.net.au>
 <alpine.LFD.2.00.1011061543130.4009@ja.ssi.bg>
 <20101106143405.GB27212@verge.net.au>
 <alpine.LFD.2.00.1011061959370.5280@ja.ssi.bg>
 <20101108062121.GA17685@verge.net.au>
 <alpine.LFD.2.00.1011081027080.1504@ja.ssi.bg>
 <20101108111600.GA14454@verge.net.au>
 <alpine.LFD.2.00.1011082245360.1690@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1011082245360.1690@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>

On Mon, Nov 08, 2010 at 10:59:39PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 8 Nov 2010, Simon Horman wrote:
> 
> >>today. May be if Hans uses ip_vs_pe_getbyname instead of
> >>ip_vs_pe_get that should solve the request_module problem.
> >
> >I changed things around a bit in "IPVS: Add persistence engine to
> >connection entry".
> >
> >	ip_vs_pe_getbyname() became __ip_vs_pe_getbyname()
> >	ip_vs_pe_get() became ip_vs_pe_getbyname()
> >	And ip_vs_pe_get() now just takes a reference on the module if its
> >	loaded.
> >
> >So yes I agree, except that __ip_vs_pe_getbyname() is the name
> >of the function that should be called, which needs to be made
> >un-static and possibly renamed (again).
> >
> >Also, to __ip_vs_pe_getbyname() calls try_module_get().
> >Is that safe from interrupt context?
> 
> 	Yes, we already use it for cp->app: ip_vs_bind_app ->
> tcp_app_conn_bind -> ip_vs_app_inc_get -> ip_vs_app_get
> 
> >>	What should we do if PE module is not loaded
> >>while we are creating connection in backup? We can not
> >>load modules, may be when connection is bound to
> >>dest+svc we should inherit the PE from svc->pe ?
> >
> >If the modules isn't loaded, then svc->pe can't be non-NULL, right?
> 
> 	Adding svc will load the PE module, for example:
> 
> - backup creates template but there is no PE => cp->pe remains NULL if
> 	we want to keep conn entry. Option 2 is that we can ignore
> 	the conn entry if the PE module is not loaded before this step

I think that is better to drop the entry as (at least the way PE SIP works)
its entirely likely that it could be used by the scheduler to use
the wont real server if the pe_data is missing. Or in other words,
it is no better than the entry being missing all together.

If later we have PE engines that behave differently, and creating
templates without pe_data makes sense, we can revisit this.

> - svc is added => PE module is loaded (request_module)
> 
> - next sync message comes and we bind cp->dest => if cp->pe
> is NULL we should set cp->pe to svc->pe. The problem here is
> that svc can be added without PE, then this template will not
> work as expected.

I'm unsure what you mean by "svc can be added without PE"

