From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  Re[2]: [PATCH] netfilter: ipvs: Verify that IP_VS 
	protocol has been registered
Date: Fri, 6 Apr 2012 11:39:50 +0200 (CEST)
Message-ID: <6dfqp4f.4ae84ae68d6556b1585957b381280d94@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, wensong@linux-vs.org, ja@ssi.bg, kaber@trash.net, davem@davemloft.net, davej@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org

Hello Sasha

>---- Original Message ----
>From: Sasha Levin <levinsasha928@gmail.com>
>To: "Hans Schillstrom" <hans@schillstrom.com>
>Cc: "Simon Horman" <horms@verge.net.au>, wensong@linux-vs.org, ja@ssi.=
bg, kaber@trash.net, davem@davemloft.net, davej@redhat.com, netdev@vger=
=2Ekernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.o=
rg, linux-kernel@vger.kernel.org
>Sent: Fri, Apr 6, 2012, 11:22 AM
>Subject: Re: Re[2]: [PATCH] netfilter: ipvs: Verify that IP_VS protoco=
l has been registered
>
>On Fri, Apr 6, 2012 at 10:59 AM, Hans Schillstrom <hans@schillstrom.co=
m> wrote:
>> Hello Simon
>>
>>>---- Original Message ----
>>>From: Simon Horman <horms@verge.net.au>
>>>To: "Sasha Levin" <levinsasha928@gmail.com>
>>>Cc: wensong@linux-vs.org, ja@ssi.bg, kaber@trash.net, davem@davemlof=
t.net, davej@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.=
org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org
>>>Sent: Fri, Apr 6, 2012, 1:19 AM
>>>Subject: Re: [PATCH] netfilter: ipvs: Verify that IP_VS protocol has=
 been registered
>>>
>>>On Thu, Apr 05, 2012 at 07:24:33PM -0400, Sasha Levin wrote:
>>>> The registration of a protocol might fail, there were no checks
>>>> and all registrations were assumed to be correct. This lead to
>>>> NULL ptr dereferences when apps tried registering.
>>>
>>>Thanks, I will queue up this fix.
>>>
>>>Do you have a real-world example of this failing, if so it
>>>might be worth pushing your change into stable.
>>
>> I don't think this is a big thing, the only thing that can cause it =
is out of memory,
>> and that will cause a "kernel death" anyway :-(
>>
>> here is the code :
>>
>> register_ip_vs_proto_netns(struct net *net, struct ip_vs_protocol *p=
p)
>> {
>> ...
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ip_vs_proto_data *pd =3D
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0kzalloc(sizeof(struct ip_vs_proto_data), GFP_ATOMIC);
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!pd)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -ENOME=
M;
>>
>>
>
>Considering that the allocation gfp flag here is GFP_ATOMIC (why is it
>GFP_ATOMIC btw?), it might fail for a variety of reasons which may
>occur when the system is "healthy", for example - if it needs disk I/O
>to allocate.

Hmm, I think it should be GFP_KERNEL
I will have a look at this, and make it consistent with the rest of the=
 netns allocations,

>
>Either way, you shouldn't be dereferencing NULL ptrs even when the
>system is really low on memory.

Of course not, it's a bug =20

Simon:
I think you should push this one into stable=20


Thanks Sasha


Regards
Hans=20


