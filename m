From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: [PATCH] Runtime interception method switch
Date: Tue, 15 Jan 2008 05:13:14 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0801150501120.22826@wm7d.net>
References: <07C2E63F-FDF8-45D5-A20C-0B294C119A5E@endian.com>
 <Pine.LNX.4.64.0801130758580.32303@wm7d.net> <47C3AD3C-1A21-43AC-B109-EE32E8B4B66A@endian.com>
 <Pine.LNX.4.64.0801140137470.32097@wm7d.net> <20080115082551.GB8826@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080115082551.GB8826@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: LVS Devel <lvs-devel@vger.kernel.org>

On Tue, 15 Jan 2008, Simon Horman wrote:

>> can this be put into the standard ipvs?

("this" == F5-SNAT

http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.non-modified_realservers.html#F5_snat

)

> In principle yes, though I am a bit wary about what
> side-effects it might have.
>
>>> or to implement SNAT in the IPVS/NAT method.
>>
>> can you do either of these?

I know I'm not the one doing the coding but since

o we're having a bit of a redesign

o people reasonably expect iptables rules to be able to NAT 
packets coming out of the director going to the realservers 
and it would be nice to restore that functionality for ipvs

o F5-SNAT is useful

this would be a good time to look at adding F5-SNAT.

What side effects might there be? Are they worse than not 
being able to NAT packets emerging from a director?

Joe

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
