From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: moving ipvs() to POST/PREROUTING
Date: Fri, 11 Apr 2008 09:14:08 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804110908240.13199@wm7d.net>
References: <200804111400.12331.j.stubbs@linkthink.co.jp>
 <200804112213.32476.j.stubbs@linkthink.co.jp> <Pine.LNX.4.64.0804110729030.3476@wm7d.net>
 <200804120015.41545.jasonbstubbs@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804120015.41545.jasonbstubbs@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Jason Stubbs <jasonbstubbs@gmail.com>
Cc: LVS Devel <lvs-devel@vger.kernel.org>

On Sat, 12 Apr 2008, Jason Stubbs wrote:

>> I would hope people don't do this. RIPs should be private,
>> for security reasons and to preserve the fiction that the
>> LVS setup is one machine.
>
> This is precisely why I chose the hooks that I did. My intention was for the
> netfilter chains to only ever see the VIP, but packets with the RIP are going
> through too after IP_VS_XMIT is called.

hmm. still don't know what you're referring to then. Is this 
LVS-NAT, LVS-DR...?

netfilter sees the source and dest on the packets. How can 
netfilter only see the VIP?

>> see
>> http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.LVS-DR.html#Pearthree

sounds like you have the same problem with what I'm saying.

> I didn't quite follow this. Are you referring to services such as FTP?

no. this webpage shows why clients shouldn't know about the 
RIP and what you can do to make sure they don't find out 
about it.

Joe
-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
