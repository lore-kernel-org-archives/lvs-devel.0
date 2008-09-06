From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/2] ipvs: load balance IPv4 connections from a local
	process
Date: Sat, 6 Sep 2008 13:56:26 +1000
Message-ID: <20080906035624.GA21521@verge.net.au>
References: <20080905013609.GD14128@verge.net.au> <f4845fc0809050402x5552f526pc8511026d7faa359@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0809050402x5552f526pc8511026d7faa359@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Malcolm Turnbull <malcolm@loadbalancer.org>, Siim =?iso-8859-1?Q?P=F5der?= <siim@p6drad-teel.net>, Vince Busam <vbusam@google.com>

On Fri, Sep 05, 2008 at 01:02:44PM +0200, Julius Volz wrote:
> On Fri, Sep 5, 2008 at 3:36 AM, Simon Horman <horms@verge.net.au> wrote:
> > @@ -1244,11 +1278,12 @@ ip_vs_in(unsigned int hooknum, struct sk
> >        ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
> >
> >        /*
> > -        *      Big tappo: only PACKET_HOST (neither loopback nor mcasts)
> > -        *      ... don't know why 1st test DOES NOT include 2nd (?)
> > +        *      Big tappo: only PACKET_HOST, including loopback for local client
> > +        *      Don't handle local packets on IPv6 for now
> >         */
> > -       if (unlikely(skb->pkt_type != PACKET_HOST
> > -                    || skb->dev->flags & IFF_LOOPBACK || skb->sk)) {
> > +       if (unlikely(skb->pkt_type != PACKET_HOST ||
> > +                    (af == AF_INET6 || (skb->dev->flags & IFF_LOOPBACK ||
> > +                                        skb->sk)))) {
> 
> Hm, shouldn't this be (af == AF_INET6 && ...) instead of "||"? The
> current expression just NF_ACCEPTs _any_ incoming IPv6 packets, even
> non-local ones.

Yes, sorry about that. It should have been &&.
This check was removed alltogether by the subsequent patch.

