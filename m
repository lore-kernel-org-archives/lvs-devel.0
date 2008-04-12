From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: moving ipvs() to POST/PREROUTING
Date: Fri, 11 Apr 2008 17:46:03 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804111734190.32243@wm7d.net>
References: <200804111400.12331.j.stubbs@linkthink.co.jp>
 <200804120015.41545.jasonbstubbs@gmail.com> <Pine.LNX.4.64.0804110908240.13199@wm7d.net>
 <200804120906.09863.jasonbstubbs@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804120906.09863.jasonbstubbs@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Horms <horms@vergenet.net>
Cc: LVS Devel <lvs-devel@vger.kernel.org>

On Sat, 12 Apr 2008, Jason Stubbs wrote:

I'm not cc:ing you any more. There's no need to cc me, I 
read everything from lvs. I cc people when I think they may 
not be paying attention, Horms because he's busy, Julian 
because most traffic doesn't concern his patches.

>> netfilter sees the source and dest on the packets. How can
>> netfilter only see the VIP?
>
> Current LVS-NAT goes something like:
> PREROUTING  client => VIP
> LOCAL_IN    client => VIP
>    LVS in hook
> LOCAL_OUT   client => RIP
> POSTROUTING client => RIP

yup

> With my patch it goes like:
> PREROUTING  client => VIP
> FORWARD     client => VIP
> POSTROUTING client => VIP
>    LVS hook
> POSTROUTING client => RIP
>
> LVS-DR is pretty much the same flow except that the 
> packet's MAC destination is changed instead. What I mean 
> with netfilter only seeing the VIP is that I'd like the 
> second POSTROUTING run that happens with my patch to not 
> happen. Doing so makes rule writing on the director a 
> little easier as the rules don't need to know about the 
> RIPs at all.

hmm, maybe I see.

Let me see if I've got it.

1.
Because the packet is controlled by LVS-NAT, it should be 
accepted as OK and will never have to be inspected for 
bogosity (you will have done that already, if you'd needed 
it). ie you aren't going to be filtering on RIPs.

> The configuration I'm planning to use is a LVS-NAT 
> director/firewall that allows external traffic to VIPs, 
> SNATs traffic from RIPs to external (including to VIPs) 
> and drops everything else.

2.
your particular setup does this, and reasonably other 
LVS-NAT setups will be doing much the same.

> With LVS-DR, I am pretty sure that all the issues 
> mentioned in the page you linked to still apply as my 
> patch only changes the flow through the director. The 
> rules mentioned in the following link would be needed 
> whether the SERVER_GW is separate device to the director 
> or not.
>
> http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.non-lvs_clients_on_realservers.html#3-tier_routes

OK

You'd better run it by Horms. I'm happy to talk about this 
while he's busy, but he knows the code better than I do and 
will be able to cast a more critical eye

Hey Horms,
 	Can you give Jason's scheme the once over?

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
