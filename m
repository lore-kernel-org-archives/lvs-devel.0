From: xiaoyu Du <tingsrain@gmail.com>
Subject: Re: IPVS: Incorrect helper use for SCTP [was: wensong@linux-vs.org, 
	horms@verge.net.au]
Date: Thu, 8 Jul 2010 09:33:13 +0800
Message-ID: <AANLkTimBVoEYPt8uyATIw_TX290_xJqHKZQU1uWgWvNu@mail.gmail.com>
References: <AANLkTinEKn_UBpjf3k2DZn1euMM6z2UM_yeDPvdEQkav@mail.gmail.com>
	<20100707122110.GF17967@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:received:in-reply-to
         :references:date:message-id:subject:from:to:cc:content-type
         :content-transfer-encoding;
        bh=5eDLlr8PpM3aWYPmz0fmpjGK1vySWyl3CS2CVkwIMDI=;
        b=acFPMkoZO/xvb9qrc1Ga7/s14MiAb01wj/RQ45SOkqOpKwJd22r0ZiOlH+plTF/80V
         kZRaGeY4mbdnIFvoDfm8/jMXRHBD64KN0JukUTfuRXpl0OBAEEeGUfQPtWrwmWDsupu6
         3pDTajJe8lEyItZCUX9zfwsvgGnTWHKsu0aEY=
In-Reply-To: <20100707122110.GF17967@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

This function is used  for sctp app heplers.
since  there's no sctp helpers yet at present, it does nothing.
If I make sure this is a bug. I will resend the pathch.


2010/7/7 Simon Horman <horms@verge.net.au>:
> [CCed netdev]
>
> Thanks,
>
> that looks correct to me. Have you tested this change?
> If so could you provided a Signed-off-by line
> as per section 12 of Documentation/SubmittingPatches?
>
> On Wed, Jul 07, 2010 at 05:19:06PM +0800, xiaoyu Du wrote:
>> Hi=EF=BC=8Call
>>
>> After I compared the sctp with tcp and udp, I thinkt his a bug that
>> sctp_dnat_handler Incorrectly invoked ip_vs_app_pkt_out.
>> below is the patch.
>>
>> ---
>> =C2=A0net/netfilter/ipvs/ip_vs_proto_sctp.c | =C2=A0 =C2=A02 +-
>> =C2=A01 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c
>> b/net/netfilter/ipvs/ip_vs_proto_sctp.c
>> index c9a3f7a..db55759 100644
>> --- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
>> +++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
>> @@ -173,7 +173,7 @@ sctp_dnat_handler(struct sk_buff *skb,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return 0;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Call appli=
cation helper if needed */
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!ip_vs_app_pk=
t_out(cp, skb))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!ip_vs_app_pk=
t_in(cp, skb))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return 0;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>
>> --
>> --
>> To unsubscribe from this list: send the line "unsubscribe lvs-devel"=
 in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.h=
tml
>
