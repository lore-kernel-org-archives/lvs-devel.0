From: Allen Parker <parker@isohunt.com>
Subject: Re: IPVS_IPV6 Kconfig fix
Date: Sat, 10 Oct 2009 07:55:18 -0700
Message-ID: <1259D422-9F4D-4F13-A9E4-42938C67615B@isohunt.com>
References: <BF3B9AC4-D881-4EC7-812B-58BDFA793D68@isohunt.com> <43ca39800910100738pa3a55f0g7db877303846db2f@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v1076)
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <43ca39800910100738pa3a55f0g7db877303846db2f@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"; delsp="yes"
To: Julius Volz <julius.volz@gmail.com>
Cc: davem@davemloft.net, lvs-devel@vger.kernel.org


On Oct 10, 2009, at 7:38 AM, Julius Volz wrote:

> Hi Allen,
>
> On Sat, Oct 10, 2009 at 4:03 PM, Allen Parker <parker@isohunt.com>  
> wrote:
>> Unless there's a very good reason to exclude CONFIG_IPV6=m from
>> CONFIG_IPVS_IPV6, you probably shouldn't do it. This patch fixes the
>> "hidden" IPVS_IPV6 when IPV6=m.
>>
>> diff -Nur linux-2.6.30.4/net/netfilter/ipvs/Kconfig
>> linux-2.6.30.4-fixed/net/netfilter/ipvs/Kconfig
>> --- linux-2.6.30.4/net/netfilter/ipvs/Kconfig   2009-10-10
>> 13:59:50.000000000 +0000
>> +++ linux-2.6.30.4-fixed/net/netfilter/ipvs/Kconfig     2009-10-10
>> 13:59:24.000000000 +0000
>> @@ -26,7 +26,7 @@
>>
>>  config IP_VS_IPV6
>>        bool "IPv6 support for IPVS"
>> -       depends on EXPERIMENTAL && (IPV6 = y|| IP_VS = IPV6)
>> +       depends on EXPERIMENTAL && (IPV6 || IP_VS = IPV6)
>>        ---help---
>>          Add IPv6 support to IPVS. This is incomplete and might be
>> dangerous.
>
> The problem is that IP_VS_IPV6 doesn't support modularity, so it has
> to depend on IPV6 being statically compiled in as well.
>
> An alternative to the current configuration is to automatically select
> IPV6=y in the background when selecting IP_VS_IPV6 (and always showing
> IP_VS_IPV6). I remember a thread on lkml about that a long while ago,
> but don't know the current Kconfig policies regarding this.
>
> Julius

I realize that compile != run, but could you possibly point me in the  
direction of _why_ IPVS_IPV6 won't work when built in a modular  
fashion? My personal preference for things like ipvs is that they're  
built as a module, so that if I do or don't need them, I don't have to  
compile+reboot a production machine in order to support new projects.  
Additionally, if a module's misbehaving, it's generally pretty easy to  
rmmod and insmod, without actually having to take the machine down.

Allen Parker
