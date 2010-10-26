From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH 5/9] ipvs network name space aware
Date: Wed, 27 Oct 2010 06:03:22 +0900
Message-ID: <20101026210321.GE13167@verge.net.au>
References: <201010081317.04167.hans.schillstrom@ericsson.com>
 <20101022190548.GA24978@verge.net.au>
 <201010261507.39734.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201010261507.39734.hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "ja@ssi.bg" <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>

On Tue, Oct 26, 2010 at 03:07:38PM +0200, Hans Schillstrom wrote:
> On Friday 22 October 2010 21:05:48 Simon Horman wrote:
> > On Fri, Oct 08, 2010 at 01:17:02PM +0200, Hans Schillstrom wrote:
> > > This patch just contains ip_vs_ctl
> > >
> > > Signed-off-by:Hans Schillstrom <hans.schillstrom@ericsson.com>
> > >
> > > diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> > > index ca8ec8c..7e99cbc 100644
> > > --- a/net/netfilter/ipvs/ip_vs_ctl.c
> > > +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> >
> > [ snip ]
> > Hi Hans,
> >
> > is there a reason that the order some of the entries in
> > vs_vars has been switched around?
> >
> Yes there is, when vars will be copied to it's own NS it's a lot easier
> when they are in sequence and without a potential insert in the middle
> the #if 0 ...
> 
> have a look at __ip_vs_control_init(struct net *net)

Ok, I suspected something like that.
In that case I think there may be a problem with
the way that I handled sysctl_ip_vs_conntrack.
