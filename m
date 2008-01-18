From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: [PATCH] Runtime interception method switch
Date: Fri, 18 Jan 2008 05:12:20 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0801180511120.14095@wm7d.net>
References: <07C2E63F-FDF8-45D5-A20C-0B294C119A5E@endian.com>
 <Pine.LNX.4.64.0801130758580.32303@wm7d.net> <47C3AD3C-1A21-43AC-B109-EE32E8B4B66A@endian.com>
 <Pine.LNX.4.64.0801140137470.32097@wm7d.net> <20080115082551.GB8826@verge.net.au>
 <Pine.LNX.4.64.0801150501120.22826@wm7d.net> <20080116075044.GA19249@verge.net.au>
 <Pine.LNX.4.64.0801160651530.313@wm7d.net> <20080118085852.GC10957@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080118085852.GC10957@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: LVS Devel <lvs-devel@vger.kernel.org>, Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>

On Fri, 18 Jan 2008, Simon Horman wrote:

>> What the users want is to be able to put unmodified servers behind a
>> director - they can't even change the default gw. The only thing they can
>> change is the RIP. So the servers would have to be realservers behind an
>> LVS-NAT director which is outputting packets with src_addr=DIP, ie the
>> realservers see connect requests only from the DIP. I'd assumed the
>> director would be running a new version of standard LVS-NAT, with
>> iptables doing the SNAT in POSTROUTING.
>
> Sorry to be picky. It seems to me that Janusz does achive the goal in
> mind, in a fairly simple way. I will review ASAP.

not picky at all. I'm happy for anything that achieves the 
functionality.

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
