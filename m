From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] Runtime interception method switch
Date: Fri, 18 Jan 2008 17:58:54 +0900
Message-ID: <20080118085852.GC10957@verge.net.au>
References: <07C2E63F-FDF8-45D5-A20C-0B294C119A5E@endian.com> <Pine.LNX.4.64.0801130758580.32303@wm7d.net> <47C3AD3C-1A21-43AC-B109-EE32E8B4B66A@endian.com> <Pine.LNX.4.64.0801140137470.32097@wm7d.net> <20080115082551.GB8826@verge.net.au> <Pine.LNX.4.64.0801150501120.22826@wm7d.net> <20080116075044.GA19249@verge.net.au> <Pine.LNX.4.64.0801160651530.313@wm7d.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801160651530.313@wm7d.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: LVS Devel <lvs-devel@vger.kernel.org>, Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>

On Wed, Jan 16, 2008 at 07:09:26AM -0800, Joseph Mack NA3T wrote:
> On Wed, 16 Jan 2008, Simon Horman wrote:
>
>> For starters could we clarify that the patch in question is the 
>> following one by Janusz Krzysztofik?
>
> I see Janusz has replied to this.

Yes I see. I'll take a look over the code a bit more.
But if he says its working then that is certainly a plus.

For the record, I am in favour of this change.

> I had assumed that if Raphael could output the packets to the right spot 
> (before POSTROUTING on the inbound direction?) that iptables could handle 
> the NAT'ing and no extra ipvs code would be neccessary.
>
> What I didn't know was the original reason the packets were output to a 
> place where iptables couldn't manipulate them. Was this for speed? to get 
> ipvs to work at all? If for speed, the director has always been limited 
> by wirespeed, not by anything in ipvs, so any increase in latency through 
> ipvs may not be seen.

I don't know the answer to that. But I guess speed. And you are right,
speed has never been much of a problem. Flexibilty on the other hand
and in particular interaction with contrack has always been problematic.

>> Also can I clarify that the aim is to be able to SNAT LVS-DR
>> connections
>
> I didn't realise Janusz was SNAT'ing LVS-DR.
>
>> (and if possible LVS-NAT and LVS-TUN)?
>> Or is the aim to add a new method, LVS-FULL-NAT?
>
> What the users want is to be able to put unmodified servers behind a 
> director - they can't even change the default gw. The only thing they can 
> change is the RIP. So the servers would have to be realservers behind an 
> LVS-NAT director which is outputting packets with src_addr=DIP, ie the  
> realservers see connect requests only from the DIP. I'd assumed the 
> director would be running a new version of standard LVS-NAT, with 
> iptables doing the SNAT in POSTROUTING.

Sorry to be picky. It seems to me that Janusz does achive the goal in
mind, in a fairly simple way. I will review ASAP.

-- 
Horms
