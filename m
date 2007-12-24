From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: A question regarding Load Balancer in LVS and the ARP problem
Date: Mon, 24 Dec 2007 06:19:51 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0712240617540.30031@wm7d.net>
References: <31436f4a0712230720k59f19455q346f0bd4fa0023d4@mail.gmail.com> 
 <Pine.LNX.4.64.0712231836400.16352@wm7d.net>
 <31436f4a0712240012u24087a72lc0b440c3a358f9d8@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <31436f4a0712240012u24087a72lc0b440c3a358f9d8@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: David Shwatrz <dshwatrz@gmail.com>
Cc: lvs-devel@vger.kernel.org

On Mon, 24 Dec 2007, David Shwatrz wrote:

> Joseph,
> Thanks for your answer !
>> but all you're looking for is an address that will
>> deliver packets locally.
>
> I just want to verify that I understand correctly; suppose the real
> server is a web server. Suppose we configure its lo:0 as the VIP
> address.  Does it mean that it will get requests on the
> VIP address and will send Responses from the real device (say eth0)
> with the IP on eth0 as source IP ? (since the loopback lo:0 we
> configured as the VIP is only in order to deliver packets locally, as
> you said)?

the replies will be routed through the real device.

Joe

>
> Regards,
> DS
>
>
> Regards,
>
>
> On Dec 24, 2007 4:42 AM, Joseph Mack NA3T <jmack@wm7d.net> wrote:
>> On Sun, 23 Dec 2007, David Shwatrz wrote:
>>
>>> My question is : suppose I have 2 NICs on each real
>>> server. Is there any advantage of configuring the VIP on
>>> the loopback device against configuring it on eth1 ?
>>> should configuring the VIP on eth1 work ?
>>
>> In the early days (<=2.2) any device on the realserver was
>> OK for the VIP (eg dummy0, eth1). I haven't checked since
>> then, but all you're looking for is an address that will
>> deliver packets locally. Since then the linux kernel has
>> gotten a lot more anal/precise about such things and much
>> that we used to be able to do in 2.0.x doesn't work anymore
>> and I can't see any reason why the old behaviour was wrong.
>> So it's reasonable to think that eth1 should work, but I
>> haven't checked it for recent kernels
>>
>>
>> Joe
>>
>> --
>> Joseph Mack NA3T EME(B,D), FM05lw North Carolina
>> jmack (at) wm7d (dot) net - azimuthal equidistant map
>> generator at http://www.wm7d.net/azproj.shtml
>> Homepage http://www.austintek.com/ It's GNU/Linux!
>>
>

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
