From: Simon Horman <horms@verge.net.au>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence support
Date: Sat, 6 Nov 2010 09:56:14 +0900
Message-ID: <20101106005614.GA11220@verge.net.au>
References: <201010291415.35299.hans.schillstrom@ericsson.com>
 <alpine.LFD.2.00.1010301741280.2294@ja.ssi.bg>
 <20101030231601.GA5908@verge.net.au>
 <201011032108.07311.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201011032108.07311.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Julian Anastasov <ja@ssi.bg>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>

On Wed, Nov 03, 2010 at 09:08:06PM +0100, Hans Schillstrom wrote:
> Hello again
> On Sunday 31 October 2010 01:16:02 Simon Horman wrote:
> > On Sat, Oct 30, 2010 at 05:55:32PM +0300, Julian Anastasov wrote:
> [ snip ]
> > >
> > > 	- What is the right thing to do in ip_vs_conn_fill_param_sync
> > > 	when ip_vs_pe_get() does not find PE? May be to drop
> > > 	connection? May be in ip_vs_process_message() we should
> > > 	use one pointer for end of message (it was 'p' before now),
> > > 	so that we can skip connections, for example, when some
> > > 	mandatory parameter as PE is not supported. We should not
> > > 	drop the whole sync message. When message is invalid it
> > > 	should be dropped but lack of support should not hurt
> > > 	other connections. In the case for PE may be
> > > 	ip_vs_conn_fill_param_sync() should return 1 if
> > > 	PE is unknown (ip_vs_pe_get). Then caller will continue
> > > 	with next connection if result > 0 or will drop message
> > > 	if result < 0 as in current patch. May be the pe_name
> > > 	presence should be the first check in
> > > 	ip_vs_conn_fill_param_sync.
> >
> > 	Yes, I agree with this.
> >
> > >	Also note that p->pe is
> > > 	pointer without reference while called in ip_vs_sched_persist.
> > > 	In our case with ip_vs_conn_fill_param_sync we should
> > > 	put this reference after calling ip_vs_proc_conn().
> > > 	May be ip_vs_find_dest should check that p->pe matches
> > > 	svc->pe. ip_vs_try_bind_dest should provide p->pe too
> > > 	for this check. But we must somehow ignore new conns
> > > 	with PE if they don't have cp->dest (service) because
> > > 	it is risky to attach PE that is not held by svc.
> > > 	It is bad that the check for p->pe is before
> > > 	ip_vs_find_dest.
> >
> > 	I have a patch, "IPVS: Add persistence engine to connection entry"
> > 	that attaches the pe to the connection rather than the dest.
> > 	In this case, if pe is NULL, then the connection doesn't use
> > 	pe, which is fine. If its non-NULL, its there so there is no
> > 	problem in that case either.
> >
> > 	I think this resolves the issue that you raise.
> 
> There is a little Ooops with this, a locking problem.
> We are in a local_bh_disable() when trying to load a module...
> 
> in the sync_thread()
>  ...
>    local_bh_disable();
>    ip_vs_process_message(tinfo->buf, len);
>    local_bh_enable();
> 
> When ip_vs_process_message() get pe_data it calls
>  -> ip_vs_conn_fill_param_sync() and it calls
>  --> ip_vs_pe_getbyname()  and it might call
>  ----> request_module(..)
> 
> My suggestion is to avoid modul loading by calling "__ip_vs_pe_getbyname()" instead,
> and if it fails just drop that single sync_conn.

I wonder if we could just remove the modular aspect of persistence engines
as there is currently only one module and no plans on the drawing board
for any more at this time. That is, compile ip_vs_pe_sip directly
into ip_vs.ko

I'm happy to make a patch for that.

