From: xiaoyu Du <tingsrain@gmail.com>
Subject: Re: [patch nf-next] IPVS: ICMPv6 checksum calculation
Date: Wed, 18 Aug 2010 12:20:14 +0800
Message-ID: <AANLkTimW6UszuFspN+S3m8WdS1dPcwTmy+m2kT4X+7MR@mail.gmail.com>
References: <20100817070036.GB742@verge.net.au>
	<Pine.LNX.4.58.1008171143500.2771@u.domain.uli>
	<20100818002149.GA18114@verge.net.au>
	<20100817.172602.193696444.davem@davemloft.net>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:received:in-reply-to
         :references:date:message-id:subject:from:to:cc:content-type
         :content-transfer-encoding;
        bh=7LZ8YRdYQPj+9VF2y3TVq0WE9Z5+CK4g/+p9QPeeQqo=;
        b=x9YcZlMDewA6NCgbkp2JzVZrG81BbSNXXhzFaVKJkDSG2q19qiOI6eI7AvDqxpa4l2
         NkxotcB3lUGlUEfvSbM75OVMxLieFKLxQkiYW63IDCFJv2keBpJbryi3bZrVGZmFmJVR
         S/s2Z5oSWpKYa7iv5QMw0vnrDG6Rg4wqIDxdA=
In-Reply-To: <20100817.172602.193696444.davem@davemloft.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: David Miller <davem@davemloft.net>
Cc: horms@verge.net.au, ja@ssi.bg, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, kaber@trash.net

Thanks, I learned this. You gave me a big cake.


2010/8/18 David Miller <davem@davemloft.net>:
> From: Simon Horman <horms@verge.net.au>
> Date: Wed, 18 Aug 2010 09:21:49 +0900
>
>> [ CCing netdev for comment ]
>>
>> On Tue, Aug 17, 2010 at 12:25:56PM +0300, Julian Anastasov wrote:
> =C2=A0...
>>> =C2=A0 =C2=A0 =C2=A0May be ip_vs_checksum_complete() is not needed =
here?
>>> Also, skb->csum is not valid for every ip_summed value.
>>> May be we need to apply CHECKSUM_PARTIAL kind of setup for the IPv6=
=2E
>>> Such example is net/ipv6/udp.c:udp6_ufo_send_check().
>>> Later dev_queue_xmit() and skb_checksum_help() should take care
>>> for the next steps. Something like this can be tested:
>>>
>>> =C2=A0 =C2=A0 =C2=A0icmph->icmp6_cksum =3D csum_ipv6_magic(&iph->sa=
ddr,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&iph->daddr,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0skb->len - icmp_off=
set, IPPROTO_ICMPV6,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00);
>>> =C2=A0 =C2=A0 =C2=A0skb->csum_start =3D skb_network_header(skb) - s=
kb->head +
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0icmp_offset;
>>> =C2=A0 =C2=A0 =C2=A0skb->csum_offset =3D offsetof(struct icmp6hdr, =
icmp6_cksum);
>>> =C2=A0 =C2=A0 =C2=A0skb->ip_summed =3D CHECKSUM_PARTIAL;
>>>
>
> Yes, using CHECKSUM_PARTIAL unconditionally would work.
>
