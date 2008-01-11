From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: [PATCH] Transparent proxy support for LVS with localnode and
 realservers (WORKING)
Date: Fri, 11 Jan 2008 05:29:32 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0801110438550.2416@wm7d.net>
References: <C704FCFC-455C-4CFC-AB8C-51604D3CF844@endian.com>
 <Pine.LNX.4.64.0801100432180.28592@wm7d.net> <1C7F5BEB-8169-40DA-B7A2-2B4BB85B6FFD@endian.com>
 <20080111041426.GF13135@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080111041426.GF13135@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: LVS Devel <lvs-devel@vger.kernel.org>

On Fri, 11 Jan 2008, Simon Horman wrote:

> But you do make some good points there, and I'm begining to think
> that PREROUTING is correct.

Having LVS in LOCAL_IN was a reasonable idea at the time, 
but then people came up with new things to do for LVS that 
didn't work real well with the LOCAL_IN approach, eg 
VIP-less directors. As well people quite reasonably expected 
any iptables rule to work and they didn't.

Since the evolution of LVS has been helped by ideas from 
people who weren't present for the original design, is it 
possible to enumerate the reasons for/against 
PREROUTING/FORWARD. At least then after we've made a 
decision and then later a new idea breaks LVS, we can at 
least look back to see if we should have seen it coming.

o Will either approach allow F5-SNAT? It would be nice to 
have a scheme where a machine did not have to be 
reconfigured to run as a realserver.

http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.non-modified_realservers.html#F5_snat

o Will it be possible for clients on realservers to be 
clients of the LVS? (It would be nice to be able to stack 
LVS calls to arbitary depth, but I can imagine it would be 
easy to get an infinite loop if not setup properly). 
Currently not being able to do this requires redesign of the 
application(s) running on the realserver, which in any 
setting where you must pay a programmer, or recertify the 
application, will be too expensive and people will just go 
buy a loadbalancer.

o Will iptables rules get the incoming packets before LVS on 
the way in and after LVS on the way out? ie will you be able 
to write arbitary iptables rules knowing that the incoming 
packet has dst_addr:port and outgoing packet has 
new_dst_addr:new_port? If LVS hooks PREROUTING, presumably 
it will have to be after iptables. Presumably after LVS 
hooks the packets they appear in POSTROUTING where you can 
apply arbitary iptables rules to the packets?

o Will either approach work better with SSL accelerators?

http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.services.single-port.html#SSL_accelerator

People have to use these because they're cheaper than buying 
a certificate for each realserver.

o Will either approach make it easier to code up an 
active/active version of LVS?

o Just in case, is it possible to code up the FORWARD 
version too in case someone thinks of a bright idea that we 
haven't thought of?


Thanks
Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
