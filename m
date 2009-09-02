From: Hannes Eder <heder@google.com>
Subject: Re: [PATCH 1/3] netfilter: xt_ipvs (netfilter matcher for IPVS)
Date: Wed, 2 Sep 2009 17:33:12 +0200
Message-ID: <b5ddba180909020833w1739bd54t11fded8150007abc@mail.gmail.com>
References: <20090902101417.11561.45663.stgit@jazzy.zrh.corp.google.com>
	 <20090902101527.11561.59498.stgit@jazzy.zrh.corp.google.com>
	 <4A9E8711.1070807@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752768AbZIBPdS@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1251905597; bh=/K9pazL/QrJZJJ3bCPr/uUBRFOY=;
	h=DomainKey-Signature:MIME-Version:In-Reply-To:References:Date:
	 Message-ID:Subject:From:To:Cc:Content-Type:
	 Content-Transfer-Encoding:X-System-Of-Record; b=j2b4m818dPpI911q4x
	7q7hRLnB3D7edBapVoS+97YJzHXt0HgC04HKvCoEpPLeKs649f5BSKlOw6hPE9xqdoI
	Q==
In-Reply-To: <4A9E8711.1070807@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Patrick McHardy <kaber@trash.net>
Cc: lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, =?ISO-8859-1?Q?Fabien_Duch=EAne?= <mad_fab@skynet.be>, Jan Engelhardt <jengelh@medozas.de>, Jean-Luc Fortemaison <jl.fortemaison@uclouvain.be>, Julian Anastasov <ja@ssi.bg>, Julius Volz <julius.volz@gmail.com>, Laurent Grawet <laurent.grawet@uclouvain.be>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>

On Wed, Sep 2, 2009 at 16:54, Patrick McHardy<kaber@trash.net> wrote:
> Hannes Eder wrote:
>> This implements the kernel-space side of the netfilter matcher
>> xt_ipvs.
>
> Looks mostly fine to me, just one question:
>
>> +bool ipvs_mt(const struct sk_buff *skb, const struct xt_match_param=
 *par)
>> +{
>> + =A0 =A0 const struct xt_ipvs *data =3D par->matchinfo;
>> + =A0 =A0 const u_int8_t family =3D par->family;
>> + =A0 =A0 struct ip_vs_iphdr iph;
>> + =A0 =A0 struct ip_vs_protocol *pp;
>> + =A0 =A0 struct ip_vs_conn *cp;
>> + =A0 =A0 int af;
>> + =A0 =A0 bool match =3D true;
>> +
>> + =A0 =A0 if (data->bitmask =3D=3D XT_IPVS_IPVS_PROPERTY) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 match =3D skb->ipvs_property ^
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !!(data->invert & XT_IPVS_=
IPVS_PROPERTY);
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 }
>> +
>> + =A0 =A0 /* other flags than XT_IPVS_IPVS_PROPERTY are set */
>> + =A0 =A0 if (!skb->ipvs_property) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 match =3D false;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 }
>> +
>> + =A0 =A0 switch (skb->protocol) {
>> + =A0 =A0 case =A0htons(ETH_P_IP):
>> + =A0 =A0 =A0 =A0 =A0 =A0 af =3D AF_INET;
>> + =A0 =A0 =A0 =A0 =A0 =A0 break;
>> +#ifdef CONFIG_IP_VS_IPV6
>> + =A0 =A0 case =A0htons(ETH_P_IPV6):
>> + =A0 =A0 =A0 =A0 =A0 =A0 af =3D AF_INET6;
>> + =A0 =A0 =A0 =A0 =A0 =A0 break;
>> +#endif
>> + =A0 =A0 default:
>> + =A0 =A0 =A0 =A0 =A0 =A0 match =3D false;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 }
>
> In the NF_INET_LOCAL_OUT hook skb->protocol is invalid. So if you
> don't need this, it would make sense to restrict the match to the
> other hooks.
>
> Even easier would be to use par->family, which contains the address
> family and doesn't need any translation.

Nice, I'll use par->family.

So in theory I do not even need a check like the following in the begin=
ning?

	if (family !=3D NFPROTO_IPV4
#ifdef CONFIG_IP_VS_IPV6
	    && family !=3D NFPROTO_IPV6
#endif
		) {
		match =3D false;
		goto out;
	}

Thanks,
-Hannes
