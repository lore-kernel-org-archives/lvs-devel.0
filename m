From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence support
Date: Mon, 1 Nov 2010 11:04:28 +0100
Message-ID: <201011011104.29280.hans.schillstrom@ericsson.com>
References: <201010291415.35299.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1010301741280.2294@ja.ssi.bg> <20101030231601.GA5908@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101030231601.GA5908@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>

On Sunday 31 October 2010 01:16:02 Simon Horman wrote:
> On Sat, Oct 30, 2010 at 05:55:32PM +0300, Julian Anastasov wrote:
> >
[ snip ]
> >
> > 	- What is the right thing to do in ip_vs_conn_fill_param_sync
> > 	when ip_vs_pe_get() does not find PE? May be to drop
> > 	connection? May be in ip_vs_process_message() we should
> > 	use one pointer for end of message (it was 'p' before now),
> > 	so that we can skip connections, for example, when some
> > 	mandatory parameter as PE is not supported. We should not
> > 	drop the whole sync message. When message is invalid it
> > 	should be dropped but lack of support should not hurt
> > 	other connections. In the case for PE may be
> > 	ip_vs_conn_fill_param_sync() should return 1 if
> > 	PE is unknown (ip_vs_pe_get). Then caller will continue
> > 	with next connection if result > 0 or will drop message
> > 	if result < 0 as in current patch. May be the pe_name
> > 	presence should be the first check in
> > 	ip_vs_conn_fill_param_sync.
>
> 	Yes, I agree with this.

I will fix that.

>
> >	Also note that p->pe is
> > 	pointer without reference while called in ip_vs_sched_persist.
> > 	In our case with ip_vs_conn_fill_param_sync we should
> > 	put this reference after calling ip_vs_proc_conn().
> > 	May be ip_vs_find_dest should check that p->pe matches
> > 	svc->pe. ip_vs_try_bind_dest should provide p->pe too
> > 	for this check. But we must somehow ignore new conns
> > 	with PE if they don't have cp->dest (service) because
> > 	it is risky to attach PE that is not held by svc.
> > 	It is bad that the check for p->pe is before
> > 	ip_vs_find_dest.
>
> 	I have a patch, "IPVS: Add persistence engine to connection entry"
> 	that attaches the pe to the connection rather than the dest.
> 	In this case, if pe is NULL, then the connection doesn't use
> 	pe, which is fine. If its non-NULL, its there so there is no
> 	problem in that case either.
>
> 	I think this resolves the issue that you raise.

As mention before I will include that patch.

[ snip ]

> >
> > 	- Note that pe_data is leaked when ip_vs_proc_conn() fails
> > 	to create connection. May be PE info for non-templates
> > 	should be ignored?
>
> 	Yes I think it should be ignored in that case.

OK

>
> > 	And we need a way to know if
> > 	ip_vs_proc_conn called ip_vs_conn_new at all and that
> > 	it succeeded so that we can safely free pe_data.
>
> 	Perhaps ip_vs_proc_conn() could just free pe_data if
> 	it is present but ip_vs_conn_new() is not called.
>
Hmmm, I missed that one....

> >
> > 	Simon should tell what happens if some PE updates
> > 	ct->pe_data, may be we should replace it too for the
> > 	case when ip_vs_proc_conn works with existing template?
>
> 	At this stage there is no facility for updating PE data.
> 	But I think replacing it should be fine, so long as
> 	the appropriate locking is in place.

OK

>
> > v2 PATCH 4/4
> > 	May be we should add configuration option if sync is enabled
> > 	to default to version 0 because how we solve the problem if
> > 	backup can not be upgraded?
>
> 	I think that defaulting to v1 and having an option
> 	to move back to v0 would make more sense. Initially
> 	I would expect people to need to use v0 for the reason
> 	that you describe. But once the backup has been upgraded then,
> 	bugs not withstanding, there shouldn't be a reason not to use v1
> 	moving forward.
OK, but then I need to add sending of version_0

[ snip ]

I will start cooking a v3 soon

--
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
