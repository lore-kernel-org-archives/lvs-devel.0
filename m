Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.167.42
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794827172;
	b=PBRPH1bgwlMRx+jgbmPyNXYqiWDmRY0pGIwCxFRitx6C9krOFY3DBH7Bv89otM8X5cKv
	 h+6gDv5yD42UVGO/NxlIfr0jTruSGOUwriuuHc+voXIteFUma6w7uxNng+b5G5dHmHsvn
	 P++9cFTwKv+o4bkPqGYLFA4Sh7LzzvUr5KrS+wbJwNJfVt5F+Z/iOhtEExVzEIzPG5Trl
	 d4NJiCw1ATSqRGeFoblgWtvl9D7SdcXCKLm+OARy0zsZXg3x3ocadt5DSYjGrowV6/h8F
	 f6TOZlklktnYq7Bwy/r8Rsg7U1TjGTeEttfdQbi9ZkFfM/FvdIu6e/YvawAiQXcsHVQ==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827172;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=dLN8aiRoaQl9Ve8XJrxdhrN1+k0tOuthcaE5ENMWVqk=;
	b=xODMku+vFio3h/nqz+tHa4Lb4S+V98NWyKo/7nQcr6vG6I3EwpbaptgcD/S2LzNzKzCy
	 raT0Xhsh6Si2qGJJaFMykxzzduyFgt79a3zSmPvSxMwozAVZ5s9TGutWmWVq/IhVw9ebS
	 CiU3kCzbicCUynDUlPG1BbFLNnlHiLAzGSTAU37+EuFjp6WWyldtFRffe707bu79evPux
	 +1jFGq2hs4jQ8JcZ8p7Ll3eJU2GQNBbN8W0hgcJKvLE27Cr9Xx0/x69rEsVxpo1tjpBS9
	 SHqEGDnT2hCmR+ZZ/4HaCnOIlLxBq1BBakb6haglpRPU646D9R9QyU47pGERKH373lw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=MM7aY2mS;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.167.42
Received: from mail-lf1-f42.google.com (mail-lf1-f42.google.com [209.85.167.42])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A2EFC606AB5B
	for <lvs-devel@vger.kernel.org>; Mon, 16 Nov 2026 11:06:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A2EFC606AB5B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=MM7aY2mS
Received: by mail-lf1-f42.google.com with SMTP id 2adb3069b0e04-5c1479be604so2779549e87.1
        for <lvs-devel@vger.kernel.org>; Mon, 16 Nov 2026 03:06:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794827170; cv=none;
        d=google.com; s=arc-20260327;
        b=JSu3JvHbbS8rxAoNyv4aQTE/tVW8QySwq2H2EFg+7yfrr9rZTjmStAc9T2joo8s9N9
         B8AgiqNdsMIzN3+LjzYML/5+r9/sBMheI5ie7yVPFsuDdWwJ88OMIP+L8pEpnPdhAAz6
         3m4GbkEQ+FWLm7BW3ZWIY8SpHqGUOy9TX1fNYZUJoGY5k0+GqWmXR2NGZEAOx4FWS6dp
         EAllqTfJEB2jJMCA5sbIWzGLekNy0AtXLkrUQ8H1NcHQXMGLpufTM+vFusb257LIQQ0z
         IgavAP+TQRjCMOqn4dTO9f+rxA64/jtMGcOafClGuOthOayeDDowmDizc1FonSUn5BTH
         ga2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=dLN8aiRoaQl9Ve8XJrxdhrN1+k0tOuthcaE5ENMWVqk=;
        fh=8leny7kpZLYZCPmIugElpoMflzvH++/7cpgDyercuEU=;
        b=mChdD6BcqIp5/GUTP+L64atMMUwB6iMGAH+6jWXZ2RF6EutEx2pA88o5rBd6kMUJMp
         UBaKWLMuu821HoTVbKhy3kFO4QONVi4Oh8+EIBnxNK/WwpcMw/o6mC1xk1jmhhLsKSUd
         634BjV6aLhLMckwujyDgpDoPZi+yUk9ievseqIX0pAZlvL3Er++oHIxyftayc78I1wfz
         vwXNs+VYuLJeAE1v1Qip5eNlj56fMHvtTiyRooy9JWolG6ZmnBkqPY4FTotjSYTBz+wl
         BCczONKLHBpMW3Co0w3UBJ2F6m4hDeI2c+o0ygJdzgzKt0n46UDQ5oOrqwW1eu5Om4O0
         ILqA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794827170; x=1795431970; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=dLN8aiRoaQl9Ve8XJrxdhrN1+k0tOuthcaE5ENMWVqk=;
        b=MM7aY2mSPEIQVllfpNqh5bwQ6QbU+aOeRwC7qRaM5rD5klClW3/VM1rOJGlbmpwv0m
         VbNtyOjqW+qjIa1vdDiDqjyuaRF3LaV4qNsG+xLJu466G1oeke4oJZE43pyO0yQRXsUT
         EXcFxoWpshrvLyPuKlh+M9hHMlR+NYb9OUdmyOHG3X1p/36rOa/onGLUJwFABHG5nYPO
         YUsY7kfBvBV2IDKkzlQM83sk90sNxfmkYWOCoiJcrX7F0nB5rblZQOM1l2YAZmQ67cUv
         nCLtEue31h4D+xqdaWnii1YKaRjJqeLGkvlRmS5iN/ayFSNyU6VbiIm7scCBxpkcA2ho
         S2xQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794827170; x=1795431970;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=dLN8aiRoaQl9Ve8XJrxdhrN1+k0tOuthcaE5ENMWVqk=;
        b=RpURhHb3M33UVFcmSLx/UesB4Cn6MRAp2nkdh2A/rYz90+TYvho5p0BL6gNfn+Rcma
         7cPPtWBxitOblr5vb+dH1BwqO70jwzqjEj+NexdO/x6V8V0+wj+1zL0t/nzL1CG+/l5+
         OASJo9BUWBExxE+LKjSpWY/wP5EVcVPOELBRfRqe8aJ5kTJNFXGOpsTVNwDdXmmfQ6sl
         7BRWqjSbufQrkUek6PoGHMJV4KFhrj8D1n/u9NOXrU9vbxu8DpdvuAJI+oiSySPNVHJx
         /k2atseQ5HIO/6WmukZKyzfekUHvimOWY7aBfxjR4bOSwgUiV26MF8IvggUi/SHSAoaX
         Lizw==
X-Forwarded-Encrypted: i=1; AL+hErEHwuGgYlmqfhDNCDcW9eJSK60m+hoHc8g3ukBSPRh1rXlQtBGRN3BRduOEZNiLwR3HsX1CQVR2bf0=@vger.kernel.org
X-Gm-Message-State: APuU4Z/3mVe/n10QdBuaEWFePD5YPUNMd7cDahRmKkT2WeCRW0m1U+PE
	9vruF/JJ7bgjKiBvR7/zj4c9Ob5hZ0LKv5wPBUmUnB+WvyYiTGUgUdF/qBb3qZsP/tEQmcyfFhJ
	fXvjeZHttoC7T379WWxprbD+Wpl8w6Z1RtelT/tBw0LOKaB0=
X-Gm-Gg: AYBFou0uPSaC5LUENbHoVSegAOitVrB6xtFAwHQ2cvrhMTw1HNLbVH8j37Bv4rFA7Gj
	RZ8gRDlYKDFg+DoRY/i28RBNtffRFLKptxbHpNvbacNRd7M2YGQX28lvqiqx+hHqX2sVkGDDlda
	+YzSDRkWsoRP+LEV2PxOrag25rGiGjkJCJgtIcsbFHnz2BQpoOy5Fo+tjIHXvC1cQXUDTkc2XnR
	Uq4PFCnadis8cEa1+uq0umoy8zqh9VIvvhV5O3lxNG0dZ9vPQFP1d13c3MB83pEDEhxVHVROat7
	IirVRaGZ4qLjvRKDWuz1fyJInhX1m6uvTvBlKYgrlxS1SnlkWpgh06khMBnRnDQecmvEJ2mq6UT
	hVQFbzb0lwPtJx21Hqb4xqTTNxxvofexVLA==
X-Received: by 2002:a05:6512:3095:b0:5c1:4f34:922b with SMTP id
 2adb3069b0e04-5c1709ce6b6mr3796099e87.54.1794827169503; Mon, 16 Nov 2026
 03:06:09 -0800 (PST)
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261116101506.98853-1-theodorlarionov@gmail.com> <avrgKSO8nfTnv4iL@chamomile>
In-Reply-To: <avrgKSO8nfTnv4iL@chamomile>
From: Theodor Arsenij Larionov-Trichkine <theodorlarionov@gmail.com>
Date: Mon, 16 Nov 2026 14:05:52 +0300
X-Gm-Features: Aa3M54pAiVYB-SF9S5tDgvqy7iruWpi8tRRbNav85gpBLByNWhJijCPsvbACwPk
Message-ID: <CAEZyMPB+oNBrnxV09Ji-Ao7Bcs93Qg=qx0B_b=3ULFx3nEFo+Q@mail.gmail.com>
Subject: Re: [PATCH nf v3] ipvs: ftp: do not link expectations to unconfirmed conntracks
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Florian Westphal <fw@strlen.de>, 
	Phil Sutter <phil@nwl.cc>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, 
	netdev@vger.kernel.org, coreteam@netfilter.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 16, 2026 at 1:51=E2=80=AFPM Pablo Neira Ayuso <pablo@netfilter.=
org> wrote:
> I think this is coming a bit late?
>
> Maybe it is possible to check this earlier in this path?

You mean returning at the top of ip_vs_ftp_out() if the ct is not
confirmed, and letting the packet through untouched? Or even before
ip_vs_ftp_out() gets called?
