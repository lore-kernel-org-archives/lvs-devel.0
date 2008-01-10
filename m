From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: [PATCH] Transparent proxy support for LVS with localnode and
 realservers (WORKING)
Date: Thu, 10 Jan 2008 04:35:06 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0801100432180.28592@wm7d.net>
References: <C704FCFC-455C-4CFC-AB8C-51604D3CF844@endian.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <C704FCFC-455C-4CFC-AB8C-51604D3CF844@endian.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Raphael Vallazza <raphael@endian.com>
Cc: LVS Devel <lvs-devel@vger.kernel.org>

On Thu, 10 Jan 2008, Raphael Vallazza wrote:

> Hello,
>
> i wrote a very simple patch for ipvs that enables a kernel config option that 
> allows to choose where IPVS intercepts incoming connections. These are the 
> options:
> - LOCAL_IN (default: works as usual)
> - PRE_ROUTING (puts LVS input right after the mangle PREROUTING and before 
> the nat PREROUTING chain)

neat. I thought it was hard enough to move that it wouldn't 
be just an option :-)

> By selecting the PRE_ROUTING option transparent proxying is possible (i've 
> tried in DR and NAT mode), because packets are sent to real servers before 
> NAT, this way the realserver can do a DNAT/REDIRECT etc. to send the packets 
> to the proxy application. This also works for the localnode, because packets 
> go thru the PREROUTING after LVS, and ther could be DNATed/REDIRECTed.

great.

what we'd really like is ipvs hooked into the FORWARD chain. 
Can you do this too?

> I tried it on some test boxes and it seems to work pretty well, i'll do some 
> stress testing in the next few days. I could send you a setup example if you 
> like...

yes please

Thanks Joe
-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
