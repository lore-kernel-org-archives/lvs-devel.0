From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH 3/9] ipvs network name space aware
Date: Thu, 21 Oct 2010 10:22:50 +0200
Message-ID: <20101021082250.GC835@verge.net.au>
References: <201010081316.57914.hans.schillstrom@ericsson.com>
 <20101020140318.GA17760@verge.net.au>
 <201010210951.40914.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201010210951.40914.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "ja@ssi.bg" <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>

On Thu, Oct 21, 2010 at 09:51:40AM +0200, Hans Schillstrom wrote:
> On Wednesday 20 October 2010 16:03:24 Simon Horman wrote:
> > On Fri, Oct 08, 2010 at 01:16:57PM +0200, Hans Schillstrom wrote:

[ snip ]

> > > @@ -278,35 +271,41 @@ ip_vs_conn_in_get_proto(int af, const struct sk_buff *skb,
> > >                       unsigned int proto_off, int inverse)
> > >  {
> > >       __be16 _ports[2], *pptr;
> > > +     struct net *net = dev_net(skb->dev);
> > >
> > >       pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
> > >       if (pptr == NULL)
> > >               return NULL;
> > >
> > > +     BUG_ON(!net);
> >
> > Can you explain why BUG_ON is here?
> 
> Yes, I forgot to remove it.
> I had them every where to make sure that net ptr was set,
> - don't call me paranoid ;-)

Thanks, I thought it was something like that.
I'll remove them as part of my rebase.

[ strip ]
