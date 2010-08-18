From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch nf-next] IPVS: ICMPv6 checksum calculation
Date: Wed, 18 Aug 2010 14:57:16 +0900
Message-ID: <20100818055716.GA32429@verge.net.au>
References: <20100817070036.GB742@verge.net.au>
 <Pine.LNX.4.58.1008171143500.2771@u.domain.uli>
 <20100818002149.GA18114@verge.net.au>
 <20100817.172602.193696444.davem@davemloft.net>
 <AANLkTimW6UszuFspN+S3m8WdS1dPcwTmy+m2kT4X+7MR@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTimW6UszuFspN+S3m8WdS1dPcwTmy+m2kT4X+7MR@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: xiaoyu Du <tingsrain@gmail.com>
Cc: David Miller <davem@davemloft.net>, ja@ssi.bg, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, kaber@trash.net

On Wed, Aug 18, 2010 at 12:20:14PM +0800, xiaoyu Du wrote:
> 2010/8/18 David Miller <davem@davemloft.net>:
> > From: Simon Horman <horms@verge.net.au>
> > Date: Wed, 18 Aug 2010 09:21:49 +0900
> >
> >> [ CCing netdev for comment ]
> >>
> >> On Tue, Aug 17, 2010 at 12:25:56PM +0300, Julian Anastasov wrote:
> > =C2=A0...
> >>> =C2=A0 =C2=A0 =C2=A0May be ip_vs_checksum_complete() is not neede=
d here?
> >>> Also, skb->csum is not valid for every ip_summed value.
> >>> May be we need to apply CHECKSUM_PARTIAL kind of setup for the IP=
v6.
> >>> Such example is net/ipv6/udp.c:udp6_ufo_send_check().
> >>> Later dev_queue_xmit() and skb_checksum_help() should take care
> >>> for the next steps. Something like this can be tested:
> >>>
> >>> =C2=A0 =C2=A0 =C2=A0icmph->icmp6_cksum =3D csum_ipv6_magic(&iph->=
saddr,
> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&iph->daddr,
> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0skb->len - icmp_o=
ffset, IPPROTO_ICMPV6,
> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00);
> >>> =C2=A0 =C2=A0 =C2=A0skb->csum_start =3D skb_network_header(skb) -=
 skb->head +
> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0icmp_offset;
> >>> =C2=A0 =C2=A0 =C2=A0skb->csum_offset =3D offsetof(struct icmp6hdr=
, icmp6_cksum);
> >>> =C2=A0 =C2=A0 =C2=A0skb->ip_summed =3D CHECKSUM_PARTIAL;
> >>>
> >
> > Yes, using CHECKSUM_PARTIAL unconditionally would work.
> >
> Thanks, I learned this. You gave me a big cake.

[ please don't top-post ]

Xiaoyu, are you in a position to test the code proposed by Julian?
