From: Hannes Eder <heder@google.com>
Subject: Re: [PATCH 1/3] netfilter: xt_ipvs (netfilter matcher for IPVS)
Date: Wed, 2 Sep 2009 18:05:54 +0200
Message-ID: <b5ddba180909020905p2dd209ay435c4e161a5d2057@mail.gmail.com>
References: <20090902101417.11561.45663.stgit@jazzy.zrh.corp.google.com>
	 <20090902101527.11561.59498.stgit@jazzy.zrh.corp.google.com>
	 <4A9E8711.1070807@trash.net>
	 <b5ddba180909020833w1739bd54t11fded8150007abc@mail.gmail.com>
	 <4A9E90E4.9080805@trash.net>
	 <alpine.LSU.2.00.0909021748310.25091@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1251907558; bh=M8+r14iBWf3t7L7/h98pR3vVASQ=;
	h=DomainKey-Signature:MIME-Version:In-Reply-To:References:Date:
	 Message-ID:Subject:From:To:Cc:Content-Type:
	 Content-Transfer-Encoding:X-System-Of-Record; b=FpxiahbCLW/VNsYJ53
	vJso4osXxu7zaZ8QnNdjgSPRvprRgeRViFVXT2uEK1iyhrCoRUz45OrEh9g1XIG2hEN
	Q==
In-Reply-To: <alpine.LSU.2.00.0909021748310.25091@fbirervta.pbzchgretzou.qr>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Jan Engelhardt <jengelh@medozas.de>
Cc: Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, =?ISO-8859-1?Q?Fabien_Duch=EAne?= <mad_fab@skynet.be>, Jean-Luc Fortemaison <jl.fortemaison@uclouvain.be>, Julian Anastasov <ja@ssi.bg>, Julius Volz <julius.volz@gmail.com>, Laurent Grawet <laurent.grawet@uclouvain.be>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>

On Wed, Sep 2, 2009 at 17:49, Jan Engelhardt<jengelh@medozas.de> wrote:
>
> On Wednesday 2009-09-02 17:36, Patrick McHardy wrote:
>>>
>>> Nice, I'll use par->family.
>>>
>>> So in theory I do not even need a check like the following in the b=
eginning?
>>>
>>> =A0 =A0 =A0if (family !=3D NFPROTO_IPV4
>>> #ifdef CONFIG_IP_VS_IPV6
>>> =A0 =A0 =A0 =A0 =A0&& family !=3D NFPROTO_IPV6
>>> #endif
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0match =3D false;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>>> =A0 =A0 =A0}
>>
>>With the AF_UNSPEC registration of your match, it might be used
>
> par->family always contains the NFPROTO of the invoking implementatio=
n,
> which can never be UNSPEC (except, in future, xtables2 ;-)
>
> par->match->family however may be UNSPEC if the module works that way=
=2E
> Which is why we have par->family.
>

I'll a check_entry function:

static bool ipvs_mt_check(const struct xt_mtchk_param *par)
{
	if (par->family !=3D NFPROTO_IPV4
#ifdef CONFIG_IP_VS_IPV6
	    && par->family !=3D NFPROTO_IPV6
#endif
		)
		return false;

	return true;
}

and remove the runtime check in ipvs_mt.
