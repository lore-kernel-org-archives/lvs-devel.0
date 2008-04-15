From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: [PATCH 0/6] move ipvs to PRE/POSTROUTING
Date: Tue, 15 Apr 2008 04:49:42 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804150438270.4433@wm7d.net>
References: <200804151540.04006.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804151540.04006.j.stubbs@linkthink.co.jp>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Jason Stubbs <j.stubbs@linkthink.co.jp>
Cc: LVS Devel <lvs-devel@vger.kernel.org>

On Tue, 15 Apr 2008, Jason Stubbs wrote:

> I'm a newbie at all of this so forgive me if I'm doing anything wrong. ;)

you're doing great.

> incoming => de-lvs packets => netfilter => lvs packets => outgoing
>
> The goal is for netfilter to only have to deal with CIP/VIP packets and
> for any translations netfilter might do of CIP to be transparent to LVS.

can you give me an example of a translation of the CIP (I 
can't think of anything, presumably the F5-SNAT will be done 
in outgoing).

> There are three main downfalls with this patch at present:
> 1) Having a VIP on a local interface

I thought with the hooks in the new place that there'd be no 
VIP on the director anymore. The director would be acting as 
a router for dst_addr=VIP. Presumbly routing would handle 
sending packets for the VIP to the director (eg the director 
would proxy arp for the VIP).

Are you talking about a case where the director is 
misconfigured?

>   causes the traffic to be delivered
>   locally as VIP checks have been moved to the end of POST_ROUTING.
> 2) Localnode with address of 127.0.0.1 does not work as packets with a
>   destination of 127.0.0.1 and a non-local source address are
>   unconditionally dropped.
> 3) Firewall rules on existing installations will most likely break.

no problem. This is a new setup and will have new rules.

> The first issue can probably be dealt with by The 
> localnode issue could probably be dealt with by using a 
> hook at the end of PREROUTING and the second issue could 
> be handled like ipt_REDIRECT.

I thought with netfilter, that REDIRECT delivers a packet 
that now has the wrong address for LVS.

> I can't see a way to handle firewall rules though

you haven't figured it out yet, or you've looked and there 
is no way of having firewall rules?

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
