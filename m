From: Hannes Eder <heder@google.com>
Subject: Re: [patch v2.2 1/4] [PATCH v2.1 1/4] netfilter: xt_ipvs (netfilter 
	matcher for IPVS)
Date: Mon, 3 May 2010 13:29:46 +0200
Message-ID: <AANLkTikIzHuzxo4z1_8_fEGLBC2-0Uz0X8SOc8n2msuX@mail.gmail.com>
References: <20100501032014.406353538@vergenet.net>
	 <20100501032120.298829234@vergenet.net> <4BDC543F.7060500@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1272886199; bh=+dU6WPEwkR13G5U6xxzmeOetATI=;
	h=MIME-Version:In-Reply-To:References:Date:Message-ID:Subject:From:
	 To:Cc:Content-Type:Content-Transfer-Encoding;
	b=ETKzKo+3KMWrPUchUsr7cjJbaJs/sC+Ut0jTTjiKZhtxo41WStVj/IJQzVMKY0RqP
	 u6JqmJ2qpmcDSaaypBkqA==
In-Reply-To: <4BDC543F.7060500@trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Patrick McHardy <kaber@trash.net>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julius Volz <julius.volz@gmail.com>, "David S. Miller" <davem@davemloft.net>, Netfilter Development Mailinglist <netfilter-devel@vger.kernel.org>

Thank you for picking this series of patches up again and thanks for
the feedback.

I'll send an updated version in the next days.

Cheers, -Hannes

On Sat, May 1, 2010 at 18:18, Patrick McHardy <kaber@trash.net> wrote:
> Simon Horman wrote:
>
>> @@ -0,0 +1,25 @@
>> +#ifndef _XT_IPVS_H
>> +#define _XT_IPVS_H 1
>
> You don't need to define a value.
>
>> +config NETFILTER_XT_MATCH_IPVS
>> + =A0 =A0 tristate '"ipvs" match support'
>> + =A0 =A0 depends on IP_VS
>> + =A0 =A0 depends on NETFILTER_ADVANCED
>> + =A0 =A0 help
>> + =A0 =A0 =A0 This option allows you to match against IPVS propertie=
s of a packet.
>> +
>> + =A0 =A0 =A0 If unsure, say N.
>
> You're using conntrack symbols, so this seems to need a dependency
> on NF_CONNTRACK.
>
>> +static bool ipvs_mt_check(const struct xt_mtchk_param *par)
>
> We've changed the signature to "int" in nf-next to be able to
> return errno codes. Please rebase your patches onto nf-next-2.6.git.
>
> Please also CC netfilter-devel at least for those parts that affect
> non-IPVS netfilter.
>
>> +{
>> + =A0 =A0 if (par->family !=3D NFPROTO_IPV4
>> +#ifdef CONFIG_IP_VS_IPV6
>> + =A0 =A0 =A0 =A0 && par->family !=3D NFPROTO_IPV6
>> +#endif
>> + =A0 =A0 =A0 =A0 =A0 =A0 ) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 pr_info("protocol family %u not supported\=
n", par->family);
>> + =A0 =A0 =A0 =A0 =A0 =A0 return false;
>> + =A0 =A0 }
>> +
>> + =A0 =A0 return true;
>> +}
>
>
