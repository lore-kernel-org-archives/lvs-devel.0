Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.167.52
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794207198;
	b=JR7dJYSBaXFIWsxqACHGpp83zxUfOCo0n1qWEgeLwKgh2UBZFHj5cfUaIGvm6wbNVuhv
	 NrtgkQ7gRjFCz1qqtW5DLM22qC6qSSmmuc0Gk2zPsHreA55R2WW6flhlNPZBo41W0q/sJ
	 xNqAdPVP4eXyFPncUmD5iOyzo9t5QyB+qSjqLd8zCLyGe4bOT/1ioCP/C8tgKyT/PUk3s
	 wSoilkZpChwLQLTWkTko9QSLB08c5A6Ni04Lupbc1Z0iLc6P0BVXYs7yP/4Eb30hmFQyh
	 xNG7eLPssfkfGGI19OEZ0/JPJBpWgkPmLuqyJpsqC4P+mtIDNoRyIcIWapAm5gmTAPQ==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794207198;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=kdfSMn5qmUAvXVccrNmls1DypVGRaJ++jbiwGI14+kg=;
	b=xU2ccQOr43QgK2f0kQ4uzFLVTEayCDKlHBQ3H8xnYfjExDR2uXYxC/W7dkD8mP0R4gkR
	 Cvl8/01qXB0sLGYoHxtJ5lqWQvPOQpga/qwDUOT0UR2oogjzQAkKQa+VBlAG128Z5e3Tu
	 4DwydV/sCdqFr5hkjbciUiWm9gzRWbQzeLG0439gitOyWHIduUzkjr/f+lS4jB3f5Er0y
	 NWrRidazyes4hudVYx8w1vzishIwm3aZmp4P8Vq2lp985RCyxEwGhj4Ys5xxGODbO2txI
	 HJ65e8CzFBBIee4cD5MTT4amM9HmjauqzNcuR99TexT6Z2crGZmBFfAGVlZn8V6gpYA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=sgWujCEB;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.167.52
Received: from mail-lf1-f52.google.com (mail-lf1-f52.google.com [209.85.167.52])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 53DDE606A322
	for <lvs-devel@vger.kernel.org>; Mon,  9 Nov 2026 06:53:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 53DDE606A322
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=sgWujCEB
Received: by mail-lf1-f52.google.com with SMTP id 2adb3069b0e04-5c1465bbbdaso302612e87.3
        for <lvs-devel@vger.kernel.org>; Sun, 08 Nov 2026 22:53:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794207196; cv=none;
        d=google.com; s=arc-20260327;
        b=V/wW+4gPG3eUbApnNB47X/EgnvqkjZWJIeAqicKKUqX4RqGRoqLvB4B8eWLtVgnzXx
         jS7oMwBO2QMmlnu78H/lh4Ga9oDM7EEGK3ZLO0cwggvw2ulo5CXY39uT4DbRKCZW8W90
         sqL/PBGQon9wJCMbA0RiFcTo64zptHnqbPvjG0BnfF0WQaBLW+nal0ZLV0r6wnv15gPI
         5HCGy56jvbsi8qEoR+blLl1RgHWRjlTdz7/wKYTDLy2zyJ5zOMjjWytMg/ZGb9kShQ7I
         LS94wpmnP+/9pGI7j+jb4V1mSH9sTg2ZzYfKdmXa+mFitK5nXUthHX2UKuHCSvnyu9b4
         vP6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=kdfSMn5qmUAvXVccrNmls1DypVGRaJ++jbiwGI14+kg=;
        fh=WK/R2UH8q68NFEmP2VrUisdE1gUxnAovY8uBtKO91do=;
        b=Ebo9HJBVSHzNeZPs3R93iKcijf976QDNrxXRslo+cFA+gbwil1EV2hCWByHipwdyYR
         vShq7FlwOI2VxPkx4/qOqpncVOvRQPgvqClACfoVR5l81uo6zkoqnzoly64gzjwYsoot
         ntoeMZuc8PBRV7EwYNG1NET5iwfHwI1roXKc0McjBiYYevpayoE3JOYSc4iBqKyDib47
         olOP5True5G6jj0SU1xM7Omz/2a2uLf13LO/A3osLRtnrMGFuqy+bgmnBVje+UIs5oZo
         3yTDHb8nOcIRoauaJ9GiyZJ/HQzc79ynzgwm+gJSN6Om8Kqw63tzQWfsXWE0/rCXxDLF
         o3Rw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794207196; x=1794811996; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=kdfSMn5qmUAvXVccrNmls1DypVGRaJ++jbiwGI14+kg=;
        b=sgWujCEBcLnI2rCZx2+HrV0hdHuKHGWZkbP/T95hfWdHOsdro1qJU1Fvk+8OO9MdfB
         0BqsBZTh492PGUlz+uiD5cFVvZc+vlVmSZhYzi+w/tlD80Sl6tEzuWFCWZhv/N6pbH35
         rLWt1UHkkGkHK24Z/h6vBhtLRJVzr1jbqDl3LlT+eJtmAmj2BiR6ABZnJcxKkIEwjeuj
         rKb8qVeksOei/N1ZYTOxCXuIYcRzPS0XXno11fSFmwYvkRxmBZ3+yYmHEczZNKiPx5RZ
         oHt9g8LUVuNFkbZtPXFWBtwsCaMo3xAJFO6XAxUED9WmEkoDJbCWdP6YC+ZT/ijPGBxT
         E53A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794207196; x=1794811996;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=kdfSMn5qmUAvXVccrNmls1DypVGRaJ++jbiwGI14+kg=;
        b=Ot/JwHVu6ET7bHKs6SsmLaBb5DdFVeywf7ym5T1bLquBCPR0UMGSf77tx7J9aIZY72
         jmKY28KAHvNzCOc3mMX3mawKY9NJWqJbCmrTiuivBev3x1ehDdHMYK35hfQBJnSGimse
         1rUsR+Y3MvjCi0ANgbfD9xJm2oXXoiRgMWxZZKz2BeGHmmWC6OH1aikDkc8ngW/Uik7Z
         SyW01QDzoZ+dttJqxVrOu2aD022CbVKzCLfA4dXj3BKIDbL2zX7pkGvarduS77G5P077
         kwSRtYU3kmvqR38ImRVqYV3fnIex/n2Z6hB4PM5Vgy+U8eIHHlY5zWgRTO1yL/Fxr3Oo
         Sghw==
X-Forwarded-Encrypted: i=1; AL+hErHYLK4TY7nnR6gjyTyGM/WScS9upoY7LZ6gzkox+I7URnNg/1Dqhq3ItyFlLjulyUIqWDphkfrUFkY=@vger.kernel.org
X-Gm-Message-State: APuU4Z/6D7YzggVrvmv+uOeGjIvzMIAMnvXX6lLoWupgYZWEqzJdE28N
	BW4d2MV7vZtGVDLWHtgf/pMydb2npm8XmM+iuR54ZPMERu3Y78GSAfYOcUPl6M3MaJ/1gQrasx2
	s26BjRTMLM004GLBE+CyjaxyjJ29F664=
X-Gm-Gg: AYBFou2aoByNSmeIPywexI0v5O0hOkPJAWCqUYCs9LzolpN/WcDGPeyVMpNL2vEQclF
	frd3zSB+B08rD0pnOos9TJBpLl10hSqXxpTZFONBPr7Mx6amZ/RoouDlFAkgi99BEPAOxzR3hTO
	z4vtqDhQG8KX4+V7mXuvb96c+wD7OYoO82MqsxezYTeXG/fHtAaWvkkymXyCCUVoU1x1CJnk/+q
	CveY8BAjTT8kwSqJBPUf7yNQmGj5I9yAVY8b5XQpjF1jAgBfObRMR1NPy9NcoMU1QoCK5JIroWB
	hyM70AKiJv+iD9Asx/gJ5lggQeFB9ELg3M4lAOGyTyvyrFX/7V6sbc1dmrBneS+bntRMV2mKSq5
	xQoXr4G8vwc2R6fSNgMWQbhzrHfTzeWl1dqeVdP7S/W8fw1YTAlGV/ZVvc/erDgqp+HMuR7qdMS
	vOjoXnqIhHVrxDY1hFSBW4Uy7DySNDLt4YhPqLk5WT/Q3lWmlfSXU=
X-Received: by 2002:a05:6512:3e1c:b0:5c1:4a48:c2db with SMTP id
 2adb3069b0e04-5c14c01f805mr810751e87.43.1794207196170; Sun, 08 Nov 2026
 22:53:16 -0800 (PST)
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261109025425.328445-1-jiayuan.chen@linux.dev>
 <CAL+tcoDvFNAZubOjw9+Z1eyaVeiBzt_Xg3KMNucY879bg-ZLow@mail.gmail.com> <dbdb9385-89cd-4e4f-bfb8-b72510e8801b@linux.dev>
In-Reply-To: <dbdb9385-89cd-4e4f-bfb8-b72510e8801b@linux.dev>
From: Jason Xing <kerneljasonxing@gmail.com>
Date: Mon, 9 Nov 2026 14:52:37 +0800
X-Gm-Features: AclHuK9hO_h4FFhel_M7AacjBweA615sygy6vgIfEMNG5ukVHhzyCYoysXzMOxw
Message-ID: <CAL+tcoA6_gROiprd7YgxvwbaiuzEUPfuWTNMjKu6vDkbUJ5KPw@mail.gmail.com>
Subject: Re: [PATCH net-next 00/14] net: annotate data-races around sysctl knobs
To: Jiayuan Chen <jiayuan.chen@linux.dev>
Cc: netdev@vger.kernel.org, David Ahern <dsahern@kernel.org>, 
	Ido Schimmel <idosch@nvidia.com>, "David S. Miller" <davem@davemloft.net>, 
	Eric Dumazet <edumazet@kernel.org>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
	Simon Horman <horms@kernel.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>, 
	Phil Sutter <phil@nwl.cc>, Nikolay Aleksandrov <razor@blackwall.org>, Paul Moore <paul@paul-moore.com>, 
	Matthieu Baerts <matttbe@kernel.org>, Mat Martineau <martineau@kernel.org>, 
	Geliang Tang <geliang@kernel.org>, Julian Anastasov <ja@ssi.bg>, Allison Henderson <achender@kernel.org>, 
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Xin Long <lucien.xin@gmail.com>, 
	"D. Wythe" <alibuda@linux.alibaba.com>, Dust Li <dust.li@linux.alibaba.com>, 
	Sidraya Jayagond <sidraya@linux.ibm.com>, Mahanta Jambigi <mjambigi@linux.ibm.com>, 
	Tony Lu <tonylu@linux.alibaba.com>, Wen Gu <guwen@linux.alibaba.com>, 
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, 
	coreteam@netfilter.org, bridge@lists.linux.dev, 
	linux-security-module@vger.kernel.org, mptcp@lists.linux.dev, 
	lvs-devel@vger.kernel.org, linux-rdma@vger.kernel.org, 
	rds-devel@oss.oracle.com, linux-sctp@vger.kernel.org, 
	linux-s390@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 9, 2026 at 11:33=E2=80=AFAM Jiayuan Chen <jiayuan.chen@linux.de=
v> wrote:
>
>
> On 11/9/26 11:11 AM, Jason Xing wrote:
> > On Mon, Nov 9, 2026 at 10:55=E2=80=AFAM Jiayuan Chen <jiayuan.chen@linu=
x.dev> wrote:
> >> While testing the recent sysctl range fixes I noticed that a lot of ou=
r
> >> sysctl knobs are read with plain loads while the handlers update them
> >> with WRITE_ONCE() and no lock, so KCSAN reports them as data races. I
> >> then used an LLM to go through every ctl_table under net/ and list the
> >> readers that were left behind. This series annotates them with
> >> READ_ONCE(), and adds WRITE_ONCE() to a few custom handlers and netlin=
k
> >> paths that store to the same fields with plain writes. Most of it is a
> >> plain READ_ONCE() at each read; where a function reads the same knob
> >> twice to make one decision, it now reads it once into a local, so the
> >> comparison and the value it acts on cannot come from two different
> >> writes.
> >>
> >> There are no Fixes tags. Done one knob per patch this would be well ov=
er
> >> a hundred commits, so I grouped them by subsystem and feature instead =
to
> >> keep the review manageable. If maintainers prefer, I can split it up
> >> further with a Fixes tag on each one, as several smaller series.
> > Over the last year, I've been thinking about the annotation stuff
> > especially around sysctls, which, I suppose, shouldn't actually affect
> > the real workload but does affect the outcome of the syzbot.
> >
> > Out of sheer curiosity, my question would be what is the point of
> > trying to change all of them? Or what kind of benefits can we get from
> > the big series?
>
>
> Three things:
>
> 1. A plain load may be emitted twice by the compiler. ip_error() compares
> peer->rate_tokens against ip_rt_error_cost and then subtracts it again;
> if the sysctl changes in between, the u32 wraps. A few readers have that
> shape and now read the knob once into a local.
>
> 2. Tearing is not involved here, all the fields are at most word sized.
>
> 3. The rest is the memory model: a lockless read of a field written with
> WRITE_ONCE() is a data race unless it is marked
> (tools/memory-model/Documentation/access-marking.txt). That is what KCSAN
> reports, and why most of the series is plain READ_ONCE().
>
>
> I think the benefit is doing it in one pass.
>
>

I was curious about the REAL impact. If this thing really matters, we
have a lot of work to do even not only in the networking subsystem.
Sorry, I still think none of those points are convincing enough, but
that doesn't mean I object to this series. Anyway, it's just my
2-cents.

Thanks,
Jason
