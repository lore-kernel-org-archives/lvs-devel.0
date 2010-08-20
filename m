From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [patch nf-next] IPVS: ICMPv6 checksum calculation
Date: Fri, 20 Aug 2010 16:48:20 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.1008201643260.4539@u.domain.uli>
References: <20100817070036.GB742@verge.net.au> <Pine.LNX.4.58.1008171143500.2771@u.domain.uli>
 <20100818002149.GA18114@verge.net.au> <20100817.172602.193696444.davem@davemloft.net>
 <AANLkTimW6UszuFspN+S3m8WdS1dPcwTmy+m2kT4X+7MR@mail.gmail.com>
 <20100818055716.GA32429@verge.net.au> <AANLkTi=tVieTnz1R=9Jh45LweUwJ=mtszM1U9XAEVrK7@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=tVieTnz1R=9Jh45LweUwJ=mtszM1U9XAEVrK7@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="utf-8"
To: xiaoyu Du <tingsrain@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, kaber@trash.net


	Hello,

On Fri, 20 Aug 2010, xiaoyu Du wrote:

> I just replied to thank for his idea then, as he gived me some ideas
> on how to manipulate
> checksum. I tested the code today, but it doesn't seem to work. (I ju=
st wrote a
> netfilter module and hooked the code on local_out , then ping6 the
> address on another PC,
> It failed.). I'll find out why.

	May be because I copied csum_ipv6_magic() code from
your patch. Please, try with one '~' before csum_ipv6_magic.

> >> >>> =C2=A0 =C2=A0 =C2=A0icmph->icmp6_cksum =3D csum_ipv6_magic(&ip=
h->saddr,
> >> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&iph->daddr,
> >> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0skb->len - icm=
p_offset, IPPROTO_ICMPV6,
> >> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00);
> >> >>> =C2=A0 =C2=A0 =C2=A0skb->csum_start =3D skb_network_header(skb=
) - skb->head +
> >> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0icmp_offset;
> >> >>> =C2=A0 =C2=A0 =C2=A0skb->csum_offset =3D offsetof(struct icmp6=
hdr, icmp6_cksum);
> >> >>> =C2=A0 =C2=A0 =C2=A0skb->ip_summed =3D CHECKSUM_PARTIAL;

Regards

--
Julian Anastasov <ja@ssi.bg>
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
