From: xiaoyu Du <tingsrain@gmail.com>
Subject: Re: [patch nf-next] IPVS: ICMPv6 checksum calculation
Date: Mon, 23 Aug 2010 10:54:32 +0800
Message-ID: <AANLkTikwd8Tfj2tZrfgFi+OGhJGOSMAFhPqSVtSrAX-f@mail.gmail.com>
References: <20100817070036.GB742@verge.net.au>
	<Pine.LNX.4.58.1008171143500.2771@u.domain.uli>
	<20100818002149.GA18114@verge.net.au>
	<20100817.172602.193696444.davem@davemloft.net>
	<AANLkTimW6UszuFspN+S3m8WdS1dPcwTmy+m2kT4X+7MR@mail.gmail.com>
	<20100818055716.GA32429@verge.net.au>
	<AANLkTi=tVieTnz1R=9Jh45LweUwJ=mtszM1U9XAEVrK7@mail.gmail.com>
	<Pine.LNX.4.58.1008201643260.4539@u.domain.uli>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:received:in-reply-to
         :references:date:message-id:subject:from:to:cc:content-type
         :content-transfer-encoding;
        bh=uWBpprUNQE1XRCUt9LZzZ6Bv5fm006STl/L/bI3ohKM=;
        b=CmJJBvhh040bee30SNOOMziiNtjv9113XS1rQfIZN6SvCwkVsAimv5RHzG62K+T63+
         S4vJvgIAyOxKhkEwkXU6e59fdEcjOxXxkhUIogx/rOM5mx3J4VLvArZrdBDhZ6Wl0ae1
         f6lSkzwk7yTj5nvEy2X8WepdbBqXjsVrSPqCE=
In-Reply-To: <Pine.LNX.4.58.1008201643260.4539@u.domain.uli>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, kaber@trash.net

Yes, I had added it and test it, it works.

2010/8/20 Julian Anastasov <ja@ssi.bg>:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Hello,
>
> On Fri, 20 Aug 2010, xiaoyu Du wrote:
>
>> I just replied to thank for his idea then, as he gived me some ideas
>> on how to manipulate
>> checksum. I tested the code today, but it doesn't seem to work. (I j=
ust wrote a
>> netfilter module and hooked the code on local_out , then ping6 the
>> address on another PC,
>> It failed.). I'll find out why.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0May be because I copied csum_ipv6_magic() =
code from
> your patch. Please, try with one '~' before csum_ipv6_magic.
>
>> >> >>> =C2=A0 =C2=A0 =C2=A0icmph->icmp6_cksum =3D csum_ipv6_magic(&i=
ph->saddr,
>> >> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&iph->daddr,
>> >> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0skb->len - ic=
mp_offset, IPPROTO_ICMPV6,
>> >> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00);
>> >> >>> =C2=A0 =C2=A0 =C2=A0skb->csum_start =3D skb_network_header(sk=
b) - skb->head +
>> >> >>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0icmp_offset;
>> >> >>> =C2=A0 =C2=A0 =C2=A0skb->csum_offset =3D offsetof(struct icmp=
6hdr, icmp6_cksum);
>> >> >>> =C2=A0 =C2=A0 =C2=A0skb->ip_summed =3D CHECKSUM_PARTIAL;
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>
