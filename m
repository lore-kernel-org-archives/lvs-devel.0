From: shengyong <shengyong1@huawei.com>
Subject: Re: Question: should local address be expired when updating PMTU?
Date: Tue, 3 Feb 2015 11:21:17 +0800
Message-ID: <54D03EAD.5060307@huawei.com>
References: <54CF3348.40207@huawei.com> <54D01BEA.2070501@fb.com> <20150203021007.GA1866582@mail.thefacebook.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20150203021007.GA1866582@mail.thefacebook.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Calvin Owens <calvinowens@fb.com>, Alex Gartrell <agartrell@fb.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org, yangyingling@huawei.com, steffen.klassert@secunet.com, hannes@redhat.com, lvs-devel@vger.kernel.org, kernel-team@fb.com



=E5=9C=A8 2015/2/3 10:10, Calvin Owens =E5=86=99=E9=81=93:
> On Monday 02/02 at 16:52 -0800, Alex Gartrell wrote:
>> Hello Shengyong,
>>
>>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>>> index b2614b2..b80317a 100644
>>> --- a/net/ipv6/route.c
>>> +++ b/net/ipv6/route.c
>>> @@ -1136,6 +1136,9 @@ static void ip6_rt_update_pmtu(struct
>> dst_entry *dst, struct sock *sk,
>>>   {
>>>          struct rt6_info *rt6 =3D (struct rt6_info*)dst;
>>>
>>> +       if (rt6->rt6i_flags & RTF_LOCAL)
>>> +               return;
>>> +
>>>          dst_confirm(dst);
>>>          if (mtu < dst_mtu(dst) && rt6->rt6i_dst.plen =3D=3D 128) {
>>>                  struct net *net =3D dev_net(dst->dev);
>>>
>>> So is this modification correct? Or how can we avoid such expiring?=
=20
>>
>> FWIW, we encountered this problem with IPVS tunneling.  Here's a
>> patch done by Calvin (cc'ed) that fixes my attempted fix for this.
>> We're not particularly proud of this...
>>
>> At a high level, I don't think the RTF_LOCAL check was sufficient,
>> but I didn't investigate deeply enough and hopefully Calvin can say
>> why.
>=20
> I honestly didn't spend much time at all finding the underlying cause
> because it appeared to be fixed upstream: on 3.19-rc5 you get all 3
> expected routes after the last step of my repro below.
Hi,
I do my test on 3.19.0-rc7 just now, it seems it still doesn't solve th=
e
local-addr-expired problem.
 I just really
> needed to get this working at the time, and the gross disgusting
> horrible ugly awful [more negative adjectives] patch included below m=
ade
> it work.
>=20
> FWIW, the explanation I wrote down in my notes was:
>=20
> "The absence of RTF_NONEXTHOP is causing COWs to happen, which are
> always marked as RTF_CACHE. Somehow that's screwing things up in
> rt6_do_redirect()"
>=20
> That could be BS though, I don't at all remember how I came to that
> conclusion.=20
>=20
> (/me resolves to write better notes in the future...)
>=20
> Here's how to get the weird behavior on 3.10 (+stable):
>=20
> $ sudo ip addr add local 4444::1 dev lo
> ### Now I have 2 routes in /proc/net/ipv6_route, a local and a non-lo=
cal
> ### Both have the RTF_NONEXTHOP flag set (0x00200000)
> $ sudo ip route add local 4444::1 dev lo
> ### Now I have 3 routes in /proc/net/ipv6_route to 4444::1
> ### Notice the new route does NOT have the RTF_NONEXTHOP flag set
> $ sudo ip addr del local 4444::1 dev lo
> ### Now I just have the one route I created before
> $ sudo ip addr add local 4444::1 dev lo
> ### And now I have 3 routes again
> $ sudo ping6 4444::1
> [blah blah blah successful ping]
> $ sudo ip addr del local 4444::1 dev lo
> $ sudo ip addr add local 4444::1 dev lo
> ### Still have 3 routes
> $ sudo ip addr del local 4444::1 dev lo
> ### Now I just have my one route yet again
> ### Now, *without the address on lo*, talk to it (it works), then re-=
add it
> $ ping6 4444::1
> [blah blah blah successful ping]
> $ sudo ip addr add local 4444::1 dev lo
> ### Now I only have 2 routes... WAT!?
> ### Notice the LOCAL (0x80000000) route doesn't have the RTF_NONEXTHO=
P flag set
Looks like we meet different problems. Here is how I do my test (as wel=
l as on 3.10
+stable):
      Host only
PC <------------> Virtual Machine
create and send a packet using scapy:
-----------------------------------
| IPv6 (src=3DPC-addr, dst=3DVM-addr) |
|---------------------------------|
|     ICMPv6 (Packet Too Big)     |
|---------------------------------|
| IPv6 (src=3DVM-addr, dst=3DVM-addr) |
|---------------------------------|
| ICMPv6 (Neighbor Advertisement) |
-----------------------------------
Then the local-addr is set to expire. After expired, the VM is unreacha=
ble from
PC side.

thanks,
Sheng
>=20
> Thanks,
> Calvin
>=20
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index f14d49b..c607a42 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -1159,18 +1159,18 @@ static void ip6_rt_update_pmtu(struct
>> dst_entry *dst, struct sock *sk,
>>                 }
>>                 dst_metric_set(dst, RTAX_MTU, mtu);
>>
>> -               /* FACEBOOK HACK: We need to not expire local non-ex=
piring
>> -                * routes so that we don't accidentally start blackh=
oling
>> -                * ipvs traffic when we happen to use it locally for
>> -                * healthchecking (see ip_vs_xmit.c --
>> -                * __ip_vs_get_out_rt_v6 invokes update_pmtu if the =
rt is
>> -                * associated with a socket)
>> -                * Alex Gartrell <agartrell@fb.com>
>> +               /*
>> +                * FACEBOOK HACK: Only expire routes that aren't des=
tined for
>> +                * the loopback interface.
>> +                *
>> +                * This prevents the strange route coalescing that h=
appens when
>> +                * you add an address to the loopback that had a rou=
te that had
>> +                * been used when the address didn't exist from gett=
ing expired
>> +                * and causing packet loss in shiv.
>>                  */
>> -               if (!(rt6->rt6i_flags & RTF_LOCAL) ||
>> -                   (rt6->rt6i_flags & (RTF_EXPIRES | RTF_CACHE)))
>> -                       rt6_update_expires(
>> -                               rt6, net->ipv6.sysctl.ip6_rt_mtu_exp=
ires);
>> +               if (!(dst->dev->flags & IFF_LOOPBACK))
>> +                       rt6_update_expires(rt6,
>> + net->ipv6.sysctl.ip6_rt_mtu_expires);
>>         }
>>  }
>>
>>
>> Cheers,
>> --=20
>> Alex Gartrell <agartrell@fb.com>
>=20
> .
>=20

