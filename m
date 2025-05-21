Received: from mail-ej1-f51.google.com (mail-ej1-f51.google.com [209.85.218.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ED4D21804A;
	Wed, 21 May 2025 02:04:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.218.51
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1747793098; cv=none; b=SPQBdAcCf1gUral3kc7gyqs6jx2XbddOVHNdJSt7INxqa7o6ONIRCYFJISjyb6uKMHeJpoSno/sjrN7UMk/I2ET0RErE/LPX1g5qKEKkn/a3NYcy5EBprSeRuo29/ZP0tpqmUIiBRZGntzqt+2cnuNLxJg836M6gyE1Z0ZeGCeM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1747793098; c=relaxed/simple;
	bh=gfzz+J+BeDn4kF5iQsbD2m+kMeWaUSPWSZ28nquy0FI=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=LHXANmGTwlnjutqM64AzQjUmYzhz9TX1od7zLHzE5K4M1q1BOJrOFRWIFpSH291DjcdGSHVxDfo9xlFYGbSO28Wp37iLHRfYAKtzj1fcCrHD86IsoRwnufBug5Sx8XY7/1tbGBhYg5dSzY9yaBzuSCP7T9ldqXSmWFSv4iwN5gg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=QDhq85Np; arc=none smtp.client-ip=209.85.218.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QDhq85Np"
Received: by mail-ej1-f51.google.com with SMTP id a640c23a62f3a-ad1a87d93f7so997983666b.0;
        Tue, 20 May 2025 19:04:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1747793095; x=1748397895; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=d2Xcm4H8Njcxmtxa8mvu1ygrd/LStDTr+e8G+gLLOHk=;
        b=QDhq85NphJH2Xk75J1GdHPDRJsxwQWENYmcvvM9jsHyEkCXwX1TCRBoLh+h7UlFIo+
         IW4cGZypGXZiscvjslM7r1ntny9prdtdolLsr6XMkluwGJMZcFinBj4H+gtTBETDdWwJ
         BFfY8zSL7XTcj7KHb3NkNNgubmUfKzyoLimbX956D8a3pM5jJEuSJZz9mWqlSn1bkaW5
         uoe27QMW+qLRHuWBVdloMefhHlQC6O2VTUDrWILumP6uBsBS8j8Q7JF2jQ8u4/obmyae
         XB6xKEI4lP8jyccwXneJ7pLd9yWBeWJuvLVGtA1jhBJThQxkK3pUsMeGBzaNBoote2wo
         81xw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1747793095; x=1748397895;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=d2Xcm4H8Njcxmtxa8mvu1ygrd/LStDTr+e8G+gLLOHk=;
        b=eMPqnHFni9chsrcURVIWC7V1Js4oFnm9RyQMiaC7ZKBMeqtug03N/bWBRMj+hDH8C4
         qU+WDhM8JMCYe+iDVdwa1worcKmA+oFCCbDzOYW9IL7UArg1iAWd7nhI2QJxvQMVeHPu
         FlTyjrh6bKP7JfWBEa+CKJckH00fpDnEvdRzZtgW1S+LdYyAVXwOSLHzxtJ6rg8uTYyq
         BDUMdGJ3mcEaVC9kUi38Tjc3THWp6/ArkkhM4QDcgjM6tUAeTbFykPJ2Wj48KdujtA1B
         L44GvKP8ZozxsSAOrbJMFekpHFieJK2HtaBU2ws4ZCXruIgyBVB7yZ1uvk0mjXhaZL5+
         ZnhQ==
X-Forwarded-Encrypted: i=1; AJvYcCWEK41MG11pCJJjx9Q7VdAi+hh3AE95WWX8k858NYFT14D5usjXkK/Y8f8uIFqfZzd/3I1tetGcGxA=@vger.kernel.org, AJvYcCWo0+gbNSMSd7+1HKFey4g5SkOYlLRe+8vsjQz190MMdTWqLD/GoGe2bMXYsyNxFoqJAyDVl5Jw@vger.kernel.org
X-Gm-Message-State: AOJu0Yy7zqEkAN/Uqxh/aSumJnYt6esfhh4A+twYCB+Dgmy1xDGHxGcz
	sg7bBSf9RDkCH//JA7w0PfZ2G4t7WICJET2omgrWalH42G/iXMlq2oKzHNtZsuQgrG0BzUQz+NN
	7BOfI4n30BwEaGXehvqdpWKxq4w6oBeE=
X-Gm-Gg: ASbGnctEDsVfh11FZYU7q2hD8GQm0Ng87iG/+CNRzm2N+skmhDStdRxs6Ne/R5mVoMw
	oVFLn5YWf1cx0q+YBn2b8846H4rAI9W8rNEK4MR3iGpdCzbm+MOSNfecxsSUJzAVP+0pKXEZkY2
	Ji1ZCHaD2tiPNO8vxo5RZLgkmoSIbWslrmvoM=
X-Google-Smtp-Source: AGHT+IHpDqdaLZB6T/nmNygA52fifUNmJlO9CD6omu1Sx5GIU8RfuXMexWge+bMko6J72goXz+1uo8BAKyveiY+7T+E=
X-Received: by 2002:a17:906:4789:b0:ad5:4cd4:5bfd with SMTP id
 a640c23a62f3a-ad54cd46015mr1320904766b.12.1747793095054; Tue, 20 May 2025
 19:04:55 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20250519103203.17255-1-djduanjiong@gmail.com> <aef5ec1d-c62f-9a1c-c6f3-c3e275494234@ssi.bg>
 <CALttK1Sn=D4x81NpEq1ELHoXnEaiMboYBzYeOUX8qKHzDDxk0A@mail.gmail.com>
 <df6af9cc-35ff-5c3e-3e67-ed2f93a17691@ssi.bg> <aCyHRcHJOhU9Ieih@strlen.de>
In-Reply-To: <aCyHRcHJOhU9Ieih@strlen.de>
From: Duan Jiong <djduanjiong@gmail.com>
Date: Wed, 21 May 2025 10:04:43 +0800
X-Gm-Features: AX0GCFuUnhuQUNL7rMu4Rd53ZqNdCohSwduRtUISg1XjHKD_9cdib7366Lw47aA
Message-ID: <CALttK1SaxBT-iuRDixBd-2o8SF25DXujV+dfZEoR7bNOFFuPbA@mail.gmail.com>
Subject: Re: [PATCH] ipvs: skip ipvs snat processing when packet dst is not vip
To: Florian Westphal <fw@strlen.de>
Cc: Julian Anastasov <ja@ssi.bg>, pablo@netfilter.org, netdev@vger.kernel.org, 
	lvs-devel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, May 20, 2025 at 9:45=E2=80=AFPM Florian Westphal <fw@strlen.de> wro=
te:
>
> Julian Anastasov <ja@ssi.bg> wrote:
> >       But the following packet is different from your
> > initial posting. Why client connects directly to the real server?
> > Is it allowed to have two conntracks with equal reply tuple
> > 192.168.99.4:8080 -> 192.168.99.6:15280 and should we support
> > such kind of setups?
>
> I don't even see how it would work, if you allow
>
> C1 -> S
> C2 -> S
>
> ... in conntrack and you receive packet from S, does that need to
> go to C1 or C2?
>
> Such duplicate CT entries are free'd (refused) at nf_confirm (
> conntrack table insertion) time.

iptables -t nat -A POSTROUTING -p TCP -j MASQUERADE

Indeed, there is nothing wrong with this logic, but after I added the MASQU=
ERADE
rule, it seems that I did snat before confirm causing the source port to ch=
ange
