From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: [PATCH] Transparent proxy support for LVS with localnode and
 realservers (WORKING) (fwd)
Date: Thu, 10 Jan 2008 09:00:15 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0801100845180.18904@wm7d.net>
References: <Pine.LNX.4.64.0801100651590.6469@wm7d.net>
 <45E2E319-10B1-4E5A-8679-B039D11A733F@endian.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <45E2E319-10B1-4E5A-8679-B039D11A733F@endian.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Raphael Vallazza <raphael@endian.com>
Cc: LVS Devel <lvs-devel@vger.kernel.org>

On Thu, 10 Jan 2008, Raphael Vallazza wrote:

>> o there will not be a VIP on the director. Presumably the director will 
>> advertise any VIPs.
>
> Work, with the PREROUTING method.

sorry don't understand. Are you saying that there won't be a 
VIP on the director with ipvs in PREROUTING either? (in 
which case I'm happy)

>> o all filtering/fwmarks/NAT/firewalling that normally happens on 
>> ingress/egress will not collide with ipvs.
>
> Right, with the PREROUTING only fwmarks are set, filtering and NAT happens 
> after ipvs.

it would be nice not to have to handle the ipvs packets with 
a separate set of rules or thinking.

>>> hmm, what's the NAT problem with having ipvs in the FORWARD chain? (or 
>>> have I missed your point?)
>
> For transparent proxying there has to be a DNAT/REDIRECT to the local 
> machine, if the director/localnode applies the DNAT/REDIRECT rule it only 
> works on the localnode. The realservers get already NATed packets, and 
> replies have the wrong destination ports set.

you seem to be more interested in transparent proxy and 
localnode than most other people on the ml so maybe you have 
a different interest in it.

I regard transparent proxy only as a way of avoiding having 
the VIP on the director (perhaps it has other virtues I've 
ignored), which was pretty neat at the time and I was sorry 
we lost that capability with 2.4.x kernels. With ipvs no 
longer in LOCAL_IN, you don't have a requirement for the VIP 
anymore and presumably you wouldn't need transparent proxy 
either.

People rarely use localnode. I wouldn't miss it if it didn't 
exist. Do you want it for other reasons (eg sorry server)? 
If for a sorry server, could we invoke something like 
Julian's iproute2 trick that's currently being used to 
emulate transparent proxy?

> Yes, you're right. FORWARD could be interesting if the 
> localnode feature isn't required, but it wouldn't solve 
> the transparent proxy problem with localnode + 
> realservers. Well if i add a choice for a FORWARD method 
> the user could choose...

what's the localnode + realserver problem with transparent 
proxy?

>>> The only negative thing is that traffic can't be filtered in a regular 
>>> way,
>> 
>> it would be nice to avoid the collisions with firewall rules that we have 
>> now.
>
> Yes, but i can't find a good solution for that if used together with 
> transparent proxying, the only one i've found was the PREROUTING one, any 
> thoughts?

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
