From: Raphael Vallazza <raphael@endian.com>
Subject: Re: [PATCH] Transparent proxy support for LVS with localnode and realservers (WORKING)
Date: Thu, 10 Jan 2008 15:14:23 +0100
Message-ID: <31DCF7B1-A5F8-4B3C-9DD9-622954FED5FE@endian.com>
References: <C704FCFC-455C-4CFC-AB8C-51604D3CF844@endian.com> <Pine.LNX.4.64.0801100432180.28592@wm7d.net>
Mime-Version: 1.0 (Apple Message framework v915)
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0801100432180.28592@wm7d.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"; delsp="yes"
To: Joseph Mack NA3T <jmack@wm7d.net>

Hello,

>> i wrote a very simple patch for ipvs that enables a kernel config  
>> option that allows to choose where IPVS intercepts incoming  
>> connections. These are the options:
>> - LOCAL_IN (default: works as usual)
>> - PRE_ROUTING (puts LVS input right after the mangle PREROUTING and  
>> before the nat PREROUTING chain)
>
> neat. I thought it was hard enough to move that it wouldn't be just  
> an option :-)

Hehe, yes, it was pretty easy ;)

> what we'd really like is ipvs hooked into the FORWARD chain. Can you  
> do this too?

To be honest i don't understand the reason for hooking LVS into the  
FORWARD chain, because this way it would not get the LOCAL_IN traffic  
and at the same time it would have the same NAT problem as with the  
LOCAL_IN hook. Maybe i'm missing something, but it seems that  
PREROUTING is the best point for LVS to act like a real router,  
because it gets packets that haven't been NATed yet.
The only negative thing is that traffic can't be filtered in a regular  
way, but using fwmark and the mangle table the user can select the  
traffic that has to be handled by LVS.

If you like i can also add this option, but i'm not sure if it's  
really useful :)

>> I tried it on some test boxes and it seems to work pretty well,  
>> i'll do some stress testing in the next few days. I could send you  
>> a setup example if you like...
>
> yes please


Ok, i'll try to write a short document/example ASAP.

Bye,
Raphael

-- 

:: e n d i a n
:: open source - open minds

:: raphael vallazza
:: phone +39 0471 631763  :: fax +39 0471 631764
:: http://www.endian.com  :: raphael (AT) endian.com

