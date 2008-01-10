From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: [PATCH] Transparent proxy support for LVS with localnode and
 realservers (WORKING) (fwd)
Date: Thu, 10 Jan 2008 10:56:38 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0801101027470.29308@wm7d.net>
References: <Pine.LNX.4.64.0801100651590.6469@wm7d.net>
 <45E2E319-10B1-4E5A-8679-B039D11A733F@endian.com> <Pine.LNX.4.64.0801100845180.18904@wm7d.net>
 <25A4F6E7-27EE-490E-894C-F2B91EE5425B@endian.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <25A4F6E7-27EE-490E-894C-F2B91EE5425B@endian.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: LVS Devel <lvs-devel@vger.kernel.org>

On Thu, 10 Jan 2008, Raphael Vallazza wrote:

I'm getting arithmetically increasing numbers of replies, so 
I'm only replying to lvs-devel this time.

> Yes, it should also work without a VIP.
>
> Transparent proxying is very important for us because we 
> use IPVS to cluster application level proxies on 
> firewalls. I.E. we have 2 nodes and one of the two acts as 
> master/director, balancing traffic between node 1 
> (himself, localnode) and node 2 (slave, realnode).

are you using transparent proxy for localnode?

> We would like support transparent proxying for squid and 
> let the master/director node act as the gateway, outgoing 
> web traffic to port 80 balanced over the node and 
> tranparently redirected to port 8080 (squid). Probably 
> it's an unusual setup for IPVS ;)

sorry if I'm being thick and miss the point of your :-) 
here, but you must know that squids were the first major use 
of lvs. I haven't kept track of how people are load 
balancing squids now. I guess I'd assumed they were putting 
a fwmark on anything to 0/80 (or equivalently NAT'ing it to 
3128 and then fwmarking it).

>> what's the localnode + realserver problem with transparent proxy?
>
> It's the NAT problem i've described in the previous mail...

I didn't get it then and I'm still having trouble with it.

> if LVS resides in LOCAL_IN, traffic has to be DNATed 
> before LVS comes into play and the realservers return 
> packets with the wrong/NATed destination port to the 
> client.

you're talking about the original LOCAL_IN ipvs. Packets to 
localnode is just forced to be accept locally. You have 
LVS-NAT with packets being accepted by transparent proxy.
Can't remember what I thought happened with LVS-NAT and 
transparent proxy. Just looked at the HOWTO and see the 
httpds receiving packets by transparent proxy have to be 
setup to reply on the VIP, but I don't know your problem 
yet. Can you show the path of the packets and the IPs 
involved?

> Hmmm, i think i've just understood the solution with 
> FORWARD :) It should also work with transparent proxies, 
> LVS has to nat the traffic for the localnode, instead of 
> letting netfilter DNAT/REDIRECT it.

sounds like part of the problem above that I don't 
understand.

> I'll try to put LVS inside the FORWARD chain and see what 
> happens :)

OK. good luck.

The user expects that incoming packets will be messed with 
by iptables/conntrack before LVS gets them (and the reverse 
on sending packets out to the realservers). If ipvs is in 
PREROUTING, you're going to have to make sure that nothing 
ever gets put in the PREROUTING chain after LVS. If ipvs is 
in FOWARD then the user will already know that they have to 
know the order in which packets are hooked (I don't expect 
much chain hooking goes on in FORWARD)

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
