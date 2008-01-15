From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] Runtime interception method switch
Date: Tue, 15 Jan 2008 17:25:53 +0900
Message-ID: <20080115082551.GB8826@verge.net.au>
References: <07C2E63F-FDF8-45D5-A20C-0B294C119A5E@endian.com> <Pine.LNX.4.64.0801130758580.32303@wm7d.net> <47C3AD3C-1A21-43AC-B109-EE32E8B4B66A@endian.com> <Pine.LNX.4.64.0801140137470.32097@wm7d.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801140137470.32097@wm7d.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: LVS Devel <lvs-devel@vger.kernel.org>

On Mon, Jan 14, 2008 at 01:42:00AM -0800, Joseph Mack NA3T wrote:
> On Mon, 14 Jan 2008, Raphael Vallazza wrote:
>
>> I think this has nothing to with the input method,
>
> I'd assumed that it would be fixed by hooking the FORWARD chain because 
> then the packets wouldn't bypass netfilter.
>
>> it's more a problem of the *xmit* function. Packets for realservers 
>> don't seem to flow through the SNAT chain, this way it's not possible 
>> to change the source IP.
>
> OK
>
>> This could probably be implemented either by letting the packets flow 
>> through the iptables/SNAT (it seems that the patch on  
>> http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.non-modified_realservers.html 
>> does this),
>
> can this be put into the standard ipvs?

In principle yes, though I am a bit wary about what
side-effects it might have.

>> or to implement SNAT in the IPVS/NAT method.
>
> can you do either of these?

-- 
Horms
