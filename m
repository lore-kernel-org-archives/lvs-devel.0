From: Raphael Vallazza <raphael@endian.com>
Subject: Re: [PATCH] Runtime interception method switch
Date: Mon, 14 Jan 2008 09:39:48 +0100
Message-ID: <47C3AD3C-1A21-43AC-B109-EE32E8B4B66A@endian.com>
References: <07C2E63F-FDF8-45D5-A20C-0B294C119A5E@endian.com> <Pine.LNX.4.64.0801130758580.32303@wm7d.net>
Mime-Version: 1.0 (Apple Message framework v915)
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0801130758580.32303@wm7d.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"; delsp="yes"
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: LVS Devel <lvs-devel@vger.kernel.org>

I think this has nothing to with the input method, it's more a problem  
of the *xmit* function. Packets for realservers don't seem to flow  
through the SNAT chain, this way it's not possible to change the  
source IP.

This could probably be implemented either by letting the packets flow  
through the iptables/SNAT (it seems that the patch on http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.non-modified_realservers.html 
  does this), or to implement SNAT in the IPVS/NAT method.

Raphael

Am 13.01.2008 um 18:59 schrieb Joseph Mack NA3T:

> On Sun, 13 Jan 2008, Raphael Vallazza wrote:
>
>> 3. PREROUTING Intercept incoming connections before DNAT and input  
>> filtering has been applied, this enables transparent proxying on  
>> realnodes and localnode.
>
> Raphael,
>
> 	What's the best way of implementing F5-SNAT? All packets must  
> arrive at the realservers with src_addr=DIP. Where should ipvs be  
> hooked and where should the iptables rules be to NAT the packets?
>
> client: CIP->VIP:80
>
> ipvs on LVS-NAT director: CIP->RIP:80
>
> iptables rules on director (in POSTROUTING?) DIP->RIP:80
>
> realserver: RIP:80->DIP
>
> iptables rules on director RIP:80->CIP
>
> ipvs on LVS-NAT director: VIP:80->CIP
>
> client: gets packet VIP:80->CIP
>
> Thanks Joe
> -- 
> Joseph Mack NA3T EME(B,D), FM05lw North Carolina
> jmack (at) wm7d (dot) net - azimuthal equidistant map
> generator at http://www.wm7d.net/azproj.shtml
> Homepage http://www.austintek.com/ It's GNU/Linux!
> -
> To unsubscribe from this list: send the line "unsubscribe lvs-devel"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 

:: e n d i a n
:: open source - open minds

:: raphael vallazza
:: phone +39 0471 631763  :: fax +39 0471 631764
:: http://www.endian.com  :: raphael (AT) endian.com
