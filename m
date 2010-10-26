From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [RFC PATCH 5/9] ipvs network name space aware
Date: Tue, 26 Oct 2010 15:07:38 +0200
Message-ID: <201010261507.39734.hans.schillstrom@ericsson.com>
References: <201010081317.04167.hans.schillstrom@ericsson.com> <20101022190548.GA24978@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101022190548.GA24978@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "ja@ssi.bg" <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>

On Friday 22 October 2010 21:05:48 Simon Horman wrote:
> On Fri, Oct 08, 2010 at 01:17:02PM +0200, Hans Schillstrom wrote:
> > This patch just contains ip_vs_ctl
> >
> > Signed-off-by:Hans Schillstrom <hans.schillstrom@ericsson.com>
> >
> > diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> > index ca8ec8c..7e99cbc 100644
> > --- a/net/netfilter/ipvs/ip_vs_ctl.c
> > +++ b/net/netfilter/ipvs/ip_vs_ctl.c
>
> [ snip ]
> Hi Hans,
>
> is there a reason that the order some of the entries in
> vs_vars has been switched around?
>
Yes there is, when vars will be copied to it's own NS it's a lot easier
when they are in sequence and without a potential insert in the middle
the #if 0 ...

have a look at __ip_vs_control_init(struct net *net)

--
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
