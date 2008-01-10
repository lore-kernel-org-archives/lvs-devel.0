From: Raphael Vallazza <raphael@endian.com>
Subject: Re: [PATCH] Transparent proxy support for LVS with localnode and realservers (WORKING) (fwd)
Date: Thu, 10 Jan 2008 16:15:19 +0100
Message-ID: <45E2E319-10B1-4E5A-8679-B039D11A733F@endian.com>
References: <Pine.LNX.4.64.0801100651590.6469@wm7d.net>
Mime-Version: 1.0 (Apple Message framework v915)
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0801100651590.6469@wm7d.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"; delsp="yes"
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: LVS Devel <lvs-devel@vger.kernel.org>

>>> what we'd really like is ipvs hooked into the FORWARD chain. Can  
>>> you do this too?
>> To be honest i don't understand the reason for hooking LVS into the  
>> FORWARD chain,
>
> Horms would be a better person to speak about this. The general idea  
> is to have the director be a router
>
> o there will not be a VIP on the director. Presumably the director  
> will advertise any VIPs.

Work, with the PREROUTING method.

> o all filtering/fwmarks/NAT/firewalling that normally happens on  
> ingress/egress will not collide with ipvs.

Right, with the PREROUTING only fwmarks are set, filtering and NAT  
happens after ipvs.


>> hmm, what's the NAT problem with having ipvs in the FORWARD chain?  
>> (or have I missed your point?)

For transparent proxying there has to be a DNAT/REDIRECT to the local  
machine, if the director/localnode applies the DNAT/REDIRECT rule it  
only works on the localnode. The realservers get already NATed  
packets, and replies have the wrong destination ports set.


>> Maybe i'm missing something, but it seems that PREROUTING is the  
>> best point for LVS to act like a real router, because it gets  
>> packets that haven't been NATed yet.
>
> A while ago Horms move ipvs to PREROUTING and then decided it was  
> the wrong place and it would be better in the FORWARD chain.
>
> We'll change our minds if we're wrong.
>
> If there are problems and advantages in special cases for FORWARD  
> and PREROUTING, then perhaps we need both versions.

Yes, you're right. FORWARD could be interesting if the localnode  
feature isn't required, but it wouldn't solve the transparent proxy  
problem with localnode + realservers. Well if i add a choice for a  
FORWARD method the user could choose...


>> The only negative thing is that traffic can't be filtered in a  
>> regular way,
>
> it would be nice to avoid the collisions with firewall rules that we  
> have now.

Yes, but i can't find a good solution for that if used together with  
transparent proxying, the only one i've found was the PREROUTING one,  
any thoughts?

Thanks,
Raphael

-- 

:: e n d i a n
:: open source - open minds

:: raphael vallazza
:: phone +39 0471 631763  :: fax +39 0471 631764
:: http://www.endian.com  :: raphael (AT) endian.com

