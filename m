From: Julius Volz <julius.volz@gmail.com>
Subject: Re: IPVS_IPV6 Kconfig fix
Date: Sat, 10 Oct 2009 17:17:05 +0200
Message-ID: <43ca39800910100817h6940d2cfoc0f25c93ce871ae1@mail.gmail.com>
References: <BF3B9AC4-D881-4EC7-812B-58BDFA793D68@isohunt.com>
	 <43ca39800910100738pa3a55f0g7db877303846db2f@mail.gmail.com>
	 <1259D422-9F4D-4F13-A9E4-42938C67615B@isohunt.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:in-reply-to:references
         :date:message-id:subject:from:to:cc:content-type
         :content-transfer-encoding;
        bh=jWuoMdA/N6+T/snrbFA4miQOXTQ4VLAvePYdrrMXJFs=;
        b=qFdZeYS95Nrt2q2qkpMSwD+ekzkUTFFfTGNAgSZ3GZIxoplbK5tqVj/cW0g3maME/A
         91L+aUbQLT1fpxva3czt1b2hcNCmPyprfbSgSKdCt4aoIAzae7Ds1YmvK4AfXaEWD+HS
         okS5rpYn3CthOLRQ2hwJ1vZizQPsl9/wiubGg=
In-Reply-To: <1259D422-9F4D-4F13-A9E4-42938C67615B@isohunt.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Allen Parker <parker@isohunt.com>
Cc: davem@davemloft.net, lvs-devel@vger.kernel.org

Hi Allen,

On Sat, Oct 10, 2009 at 4:55 PM, Allen Parker <parker@isohunt.com> wrot=
e:
>
> On Oct 10, 2009, at 7:38 AM, Julius Volz wrote:
>
>> Hi Allen,
>>
>> On Sat, Oct 10, 2009 at 4:03 PM, Allen Parker <parker@isohunt.com> w=
rote:
>>>
>>> Unless there's a very good reason to exclude CONFIG_IPV6=3Dm from
>>> CONFIG_IPVS_IPV6, you probably shouldn't do it. This patch fixes th=
e
>>> "hidden" IPVS_IPV6 when IPV6=3Dm.
>>>
>>> diff -Nur linux-2.6.30.4/net/netfilter/ipvs/Kconfig
>>> linux-2.6.30.4-fixed/net/netfilter/ipvs/Kconfig
>>> --- linux-2.6.30.4/net/netfilter/ipvs/Kconfig =A0 2009-10-10
>>> 13:59:50.000000000 +0000
>>> +++ linux-2.6.30.4-fixed/net/netfilter/ipvs/Kconfig =A0 =A0 2009-10=
-10
>>> 13:59:24.000000000 +0000
>>> @@ -26,7 +26,7 @@
>>>
>>> =A0config IP_VS_IPV6
>>> =A0 =A0 =A0 bool "IPv6 support for IPVS"
>>> - =A0 =A0 =A0 depends on EXPERIMENTAL && (IPV6 =3D y|| IP_VS =3D IP=
V6)
>>> + =A0 =A0 =A0 depends on EXPERIMENTAL && (IPV6 || IP_VS =3D IPV6)
>>> =A0 =A0 =A0 ---help---
>>> =A0 =A0 =A0 =A0 Add IPv6 support to IPVS. This is incomplete and mi=
ght be
>>> dangerous.
>>
>> The problem is that IP_VS_IPV6 doesn't support modularity, so it has
>> to depend on IPV6 being statically compiled in as well.
>>
>> An alternative to the current configuration is to automatically sele=
ct
>> IPV6=3Dy in the background when selecting IP_VS_IPV6 (and always sho=
wing
>> IP_VS_IPV6). I remember a thread on lkml about that a long while ago=
,
>> but don't know the current Kconfig policies regarding this.
>>
>> Julius
>
> I realize that compile !=3D run, but could you possibly point me in t=
he
> direction of _why_ IPVS_IPV6 won't work when built in a modular fashi=
on? My
> personal preference for things like ipvs is that they're built as a m=
odule,
> so that if I do or don't need them, I don't have to compile+reboot a
> production machine in order to support new projects. Additionally, if=
 a
> module's misbehaving, it's generally pretty easy to rmmod and insmod,
> without actually having to take the machine down.

Of course modularity is a nice feature to have, but making IPv6
support for IPVS modular would be a lot of work. The IPv6 code is very
intertwined with IPv4/common code in IPVS (in execution paths as well
as data structures). When compiling statically, you can simply #ifdef
the IPv6 parts away. But if you wanted to support modularity, you'd
need to extract all IPv6 parts and put them in a module, which would
require _a lot_ of refactoring. So I don't think it is likely to
happen in the near future... Hope that this explanation helps though
:)

Julius
