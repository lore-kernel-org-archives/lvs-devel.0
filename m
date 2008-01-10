From: Raphael Vallazza <raphael@endian.com>
Subject: Re: [PATCH] Transparent proxy support for LVS with localnode and realservers (WORKING) (fwd)
Date: Thu, 10 Jan 2008 19:24:07 +0100
Message-ID: <25A4F6E7-27EE-490E-894C-F2B91EE5425B@endian.com>
References: <Pine.LNX.4.64.0801100651590.6469@wm7d.net> <45E2E319-10B1-4E5A-8679-B039D11A733F@endian.com> <Pine.LNX.4.64.0801100845180.18904@wm7d.net>
Mime-Version: 1.0 (Apple Message framework v915)
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0801100845180.18904@wm7d.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"; delsp="yes"
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: LVS Devel <lvs-devel@vger.kernel.org>

>> Work, with the PREROUTING method.
>
> sorry don't understand. Are you saying that there won't be a VIP on  
> the director with ipvs in PREROUTING either? (in which case I'm happy)

Yes, it should also work without a VIP.

> you seem to be more interested in transparent proxy and localnode  
> than most other people on the ml so maybe you have a different  
> interest in it.
>
> I regard transparent proxy only as a way of avoiding having the VIP  
> on the director (perhaps it has other virtues I've ignored), which  
> was pretty neat at the time and I was sorry we lost that capability  
> with 2.4.x kernels. With ipvs no longer in LOCAL_IN, you don't have  
> a requirement for the VIP anymore and presumably you wouldn't need  
> transparent proxy either.
>
> People rarely use localnode. I wouldn't miss it if it didn't exist.  
> Do you want it for other reasons (eg sorry server)? If for a sorry  
> server, could we invoke something like Julian's iproute2 trick  
> that's currently being used to emulate transparent proxy?

Transparent proxying is very important for us because we use IPVS to  
cluster application level proxies on firewalls. I.E. we have 2 nodes  
and one of the two acts as master/director, balancing traffic between  
node 1 (himself, localnode) and node 2 (slave, realnode). We would  
like support transparent proxying for squid and let the master/ 
director node act as the gateway, outgoing web traffic to port 80  
balanced over the node and tranparently redirected to port 8080  
(squid). Probably it's an unusual setup for IPVS ;)
We could also use tproxy and haproxy, but LVS + keepalived work  
together like a charm, so we tried to find a solution with LVS.

> what's the localnode + realserver problem with transparent proxy?

It's the NAT problem i've described in the previous mail... if LVS  
resides in LOCAL_IN traffic has to be DNATed before LVS comes into  
play and the realservers return packets with the wrong/NATed  
destination port to the client.

>>>> The only negative thing is that traffic can't be filtered in a  
>>>> regular way,
>>> it would be nice to avoid the collisions with firewall rules that  
>>> we have now.
>>
>> Yes, but i can't find a good solution for that if used together  
>> with transparent proxying, the only one i've found was the  
>> PREROUTING one, any thoughts?


Hmmm, i think i've just understood the solution with FORWARD :) It  
should also work with transparent proxies, LVS has to nat the traffic  
for the localnode, instead of letting netfilter DNAT/REDIRECT it.

I'll try to put LVS inside the FORWARD chain and see what happens :)

Thanks,
Raphael

-- 

:: e n d i a n
:: open source - open minds

:: raphael vallazza
:: phone +39 0471 631763  :: fax +39 0471 631764
:: http://www.endian.com  :: raphael (AT) endian.com

