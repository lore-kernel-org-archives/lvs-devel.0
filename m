From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: [PATCH] Runtime interception method switch
Date: Wed, 16 Jan 2008 07:09:26 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0801160651530.313@wm7d.net>
References: <07C2E63F-FDF8-45D5-A20C-0B294C119A5E@endian.com>
 <Pine.LNX.4.64.0801130758580.32303@wm7d.net> <47C3AD3C-1A21-43AC-B109-EE32E8B4B66A@endian.com>
 <Pine.LNX.4.64.0801140137470.32097@wm7d.net> <20080115082551.GB8826@verge.net.au>
 <Pine.LNX.4.64.0801150501120.22826@wm7d.net> <20080116075044.GA19249@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080116075044.GA19249@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: LVS Devel <lvs-devel@vger.kernel.org>, Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>

On Wed, 16 Jan 2008, Simon Horman wrote:

> For starters could we clarify that the patch in question 
> is the following one by Janusz Krzysztofik?

I see Janusz has replied to this.

I had assumed that if Raphael could output the packets to 
the right spot (before POSTROUTING on the inbound 
direction?) that iptables could handle the NAT'ing and no 
extra ipvs code would be neccessary.

What I didn't know was the original reason the packets were 
output to a place where iptables couldn't manipulate them. 
Was this for speed? to get ipvs to work at all? If for 
speed, the director has always been limited by wirespeed, 
not by anything in ipvs, so any increase in latency through 
ipvs may not be seen.

> Also can I clarify that the aim is to be able to SNAT LVS-DR
> connections

I didn't realise Janusz was SNAT'ing LVS-DR.

> (and if possible LVS-NAT and LVS-TUN)?
> Or is the aim to add a new method, LVS-FULL-NAT?

What the users want is to be able to put unmodified servers 
behind a director - they can't even change the default gw. 
The only thing they can change is the RIP. So the servers 
would have to be realservers behind an LVS-NAT director 
which is outputting packets with src_addr=DIP, ie the 
realservers see connect requests only from the DIP. I'd 
assumed the director would be running a new version of 
standard LVS-NAT, with iptables doing the SNAT in 
POSTROUTING.

Joe
-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
