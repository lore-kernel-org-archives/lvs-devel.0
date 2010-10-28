From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [RFC PATCH 1/4] IPVS: Prepare for transferring firewall marks (fwmark) to the backup daemon.
Date: Thu, 28 Oct 2010 14:51:55 +0200
Message-ID: <201010281451.55630.hans.schillstrom@ericsson.com>
References: <1288090823-31135-1-git-send-email-hans.schillstrom@ericsson.com> <20101028120847.GB16206@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101028120847.GB16206@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "ja@ssi.bg" <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>

Hello,

On Thursday 28 October 2010 14:08:47 Simon Horman wrote:
> On Tue, Oct 26, 2010 at 01:00:20PM +0200, Hans Schillstrom wrote:
> > Two structs will have fwmark added:
> >  * ip_vs_conn
> >  * ip_vs_conn_param
> >
> > ip_vs_conn_fill_param will have an extra param - fwmark
> > The effects of that is in this patch.
>
> This looks good to me, with the exception of
> the minor formatting nit below.
>
> I have fixed it as I describe below and queued it up for nf-next-2.6
> once it opens.
>
> > Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
>
> [ snip ]
>
> > diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> > index b4e51e9..61abf39 100644
> > --- a/net/netfilter/ipvs/ip_vs_core.c
> > +++ b/net/netfilter/ipvs/ip_vs_core.c
>
> [ snip ]
>
> > @@ -485,8 +486,8 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
> >  		{
> >  			struct ip_vs_conn_param p;
> >  			ip_vs_conn_fill_param(svc->af, iph.protocol,
> > -					      &iph.saddr, pptr[0],
> > -					      &iph.daddr, pptr[1], &p);
> > +					      &iph.saddr, pptr[0],&iph.daddr,
> > +					      pptr[1], skb->mark, &p);
>
> Could you please put a space after the ,?
> For the record, the following is my preferred formatting.

I prefer that too ;-)

I will prepare and send a version 2 of the patch set today, with
the comments included from you and Julian.

--
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
