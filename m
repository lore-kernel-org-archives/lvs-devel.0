From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: Re: [PATCH 0/6] move ipvs to PRE/POSTROUTING
Date: Tue, 15 Apr 2008 21:16:55 +0900
Message-ID: <200804152116.55089.j.stubbs@linkthink.co.jp>
References: <200804151540.04006.j.stubbs@linkthink.co.jp> <Pine.LNX.4.64.0804150438270.4433@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0804150438270.4433@wm7d.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: LVS Devel <lvs-devel@vger.kernel.org>

On Tuesday 15 April 2008 20:49:42 JST, Joseph Mack NA3T wrote:
> On Tue, 15 Apr 2008, Jason Stubbs wrote:
> > I'm a newbie at all of this so forgive me if I'm doing anything wrong. ;)
>
> you're doing great.

Cheers :)

> > incoming => de-lvs packets => netfilter => lvs packets => outgoing
> >
> > The goal is for netfilter to only have to deal with CIP/VIP packets and
> > for any translations netfilter might do of CIP to be transparent to LVS.
>
> can you give me an example of a translation of the CIP (I
> can't think of anything, presumably the F5-SNAT will be done
> in outgoing).
>
> > There are three main downfalls with this patch at present:
> > 1) Having a VIP on a local interface
>
> I thought with the hooks in the new place that there'd be no
> VIP on the director anymore. The director would be acting as
> a router for dst_addr=VIP. Presumbly routing would handle
> sending packets for the VIP to the director (eg the director
> would proxy arp for the VIP).
>
> Are you talking about a case where the director is
> misconfigured?
>
> >   causes the traffic to be delivered
> >   locally as VIP checks have been moved to the end of POST_ROUTING.
> > 2) Localnode with address of 127.0.0.1 does not work as packets with a
> >   destination of 127.0.0.1 and a non-local source address are
> >   unconditionally dropped.
> > 3) Firewall rules on existing installations will most likely break.
>
> no problem. This is a new setup and will have new rules.

The above three points are issues that would need to be overcome before the 
changes could be merged. I can of course maintain it out of tree myself, but 
I'd rather try and overcome any obstacles against getting it merged.

You have highlighted another issue though. I've been assuming that the 
director is already in the routing path in which case arp replies for the VIP 
aren't necessary. I have no idea how arp advertisements should be handled.

> > The first issue can probably be dealt with by The
> > localnode issue could probably be dealt with by using a
> > hook at the end of PREROUTING and the second issue could
> > be handled like ipt_REDIRECT.
>
> I thought with netfilter, that REDIRECT delivers a packet
> that now has the wrong address for LVS.

REDIRECT is a special case of DNAT where the destination is changed to 
127.0.0.1 for local generated traffic and the first IP on the first interface 
for any other traffic.

> > I can't see a way to handle firewall rules though
>
> you haven't figured it out yet, or you've looked and there
> is no way of having firewall rules?

All the firewall rules I've tested work fine. I'm referring to existing 
installations where, for example, FORWARD rules don't take into account LVS 
traffic. Moving LVS hooks around will invariably break these rules in 
different ways.

--
Jason Stubbs
