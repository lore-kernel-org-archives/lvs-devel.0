From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: [PATCH] Transparent proxy support for LVS with localnode and
 realservers (WORKING) (fwd)
Date: Thu, 10 Jan 2008 06:52:20 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0801100651590.6469@wm7d.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: LVS Devel <lvs-devel@vger.kernel.org>

Am cc:'ing LVS-devel

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!

---------- Forwarded message ----------
Date: Thu, 10 Jan 2008 06:49:01 -0800 (PST)
From: Joseph Mack NA3T <jmack@wm7d.net>
To: Raphael Vallazza <raphael@endian.com>
Subject: Re: [PATCH] Transparent proxy support for LVS with localnode and
     realservers (WORKING)

On Thu, 10 Jan 2008, Raphael Vallazza wrote:

>> neat. I thought it was hard enough to move that it wouldn't be just an 
>> option :-)
> 
> Hehe, yes, it was pretty easy ;)

OK, if you say so.

> 
>> what we'd really like is ipvs hooked into the FORWARD chain. Can you do this 
>> too?
> 
> To be honest i don't understand the reason for hooking LVS into the FORWARD 
> chain,

Horms would be a better person to speak about this. The general idea is to have 
the director be a router

o there will not be a VIP on the director. Presumably the director will 
advertise any VIPs.

o all filtering/fwmarks/NAT/firewalling that normally happens on ingress/egress 
will not collide with ipvs.

> because this way it would not get the LOCAL_IN traffic and at the same time 
> it would have the same NAT problem as with the LOCAL_IN hook.

hmm, what's the NAT problem with having ipvs in the FORWARD chain? (or have I 
missed your point?)

> Maybe i'm missing something, but it seems that PREROUTING is the best point 
> for LVS to act like a real router, because it gets packets that haven't been 
> NATed yet.

A while ago Horms move ipvs to PREROUTING and then decided it was the wrong 
place and it would be better in the FORWARD chain.

We'll change our minds if we're wrong.

If there are problems and advantages in special cases for FORWARD and 
PREROUTING, then perhaps we need both versions.

> The only negative thing is that traffic can't be filtered in a regular way,

it would be nice to avoid the collisions with firewall rules that we have now.

> but using fwmark and the mangle table the user can select the traffic that 
> has to be handled by LVS.

OK

> Ok, i'll try to write a short document/example ASAP.

thanks

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
