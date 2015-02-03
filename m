From: shengyong <shengyong1@huawei.com>
Subject: Re: Question: should local address be expired when updating PMTU?
Date: Tue, 3 Feb 2015 09:28:44 +0800
Message-ID: <54D0244C.40301@huawei.com>
References: <54CF3348.40207@huawei.com> <54D01BEA.2070501@fb.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <54D01BEA.2070501@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Alex Gartrell <agartrell@fb.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org, yangyingliang@huawei.com, steffen.klassert@secunet.com, hannes@redhat.com, lvs-devel@vger.kernel.org, Calvin Owens <calvinowens@fb.com>, kernel-team@fb.com



=E5=9C=A8 2015/2/3 8:52, Alex Gartrell =E5=86=99=E9=81=93:
> Hello Shengyong,
>=20
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index b2614b2..b80317a 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -1136,6 +1136,9 @@ static void ip6_rt_update_pmtu(struct dst_entr=
y *dst, struct sock *sk,
>>   {
>>          struct rt6_info *rt6 =3D (struct rt6_info*)dst;
>>
>> +       if (rt6->rt6i_flags & RTF_LOCAL)
>> +               return;
>> +
>>          dst_confirm(dst);
>>          if (mtu < dst_mtu(dst) && rt6->rt6i_dst.plen =3D=3D 128) {
>>                  struct net *net =3D dev_net(dst->dev);
>>
>> So is this modification correct? Or how can we avoid such expiring?
>=20
>=20
> FWIW, we encountered this problem with IPVS tunneling.  Here's a patc=
h done by Calvin (cc'ed) that fixes my attempted fix for this.  We're n=
ot particularly proud of this...
>=20
> At a high level, I don't think the RTF_LOCAL check was sufficient, bu=
t I didn't investigate deeply enough and hopefully Calvin can say why.
>=20
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index f14d49b..c607a42 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1159,18 +1159,18 @@ static void ip6_rt_update_pmtu(struct dst_ent=
ry *dst, struct sock *sk,
>                 }
>                 dst_metric_set(dst, RTAX_MTU, mtu);
>=20
> -               /* FACEBOOK HACK: We need to not expire local non-exp=
iring
> -                * routes so that we don't accidentally start blackho=
ling
> -                * ipvs traffic when we happen to use it locally for
> -                * healthchecking (see ip_vs_xmit.c --
> -                * __ip_vs_get_out_rt_v6 invokes update_pmtu if the r=
t is
> -                * associated with a socket)
> -                * Alex Gartrell <agartrell@fb.com>
> +               /*
> +                * FACEBOOK HACK: Only expire routes that aren't dest=
ined for
> +                * the loopback interface.
> +                *
> +                * This prevents the strange route coalescing that ha=
ppens when
> +                * you add an address to the loopback that had a rout=
e that had
> +                * been used when the address didn't exist from getti=
ng expired
> +                * and causing packet loss in shiv.
>                  */
> -               if (!(rt6->rt6i_flags & RTF_LOCAL) ||
> -                   (rt6->rt6i_flags & (RTF_EXPIRES | RTF_CACHE)))
> -                       rt6_update_expires(
> -                               rt6, net->ipv6.sysctl.ip6_rt_mtu_expi=
res);
> +               if (!(dst->dev->flags & IFF_LOOPBACK))
> +                       rt6_update_expires(rt6,
> + net->ipv6.sysctl.ip6_rt_mtu_expires);
>         }
>  }
Thanks, your approach can also solve the problem I met. I just a bit co=
nfuse that
is this kind of packets (like I sent in the first mail) normal?  and if=
 they are
abnormal, I think we'd better drop them before update rt6i_flags.

thx,
Sheng
>=20
>=20
> Cheers,

