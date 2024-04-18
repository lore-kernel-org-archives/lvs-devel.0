Received: from smtp-relay-internal-0.canonical.com (smtp-relay-internal-0.canonical.com [185.125.188.122])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3BDF915AD9F
	for <lvs-devel@vger.kernel.org>; Thu, 18 Apr 2024 15:02:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=185.125.188.122
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1713452526; cv=none; b=g6qE/9tusY+WDJ6Y6oaSO/L+S+XlLIqCSju5RhXm79xfBAPs5RQ0gY/vhFILZrelHD5t7mSqzKZHY8KcyKeAfLJ4NyrTe5TBX0M6oXjqNWSjDa3KzrHuuYKW2ftTeNSFTWZYX0YuoI4g2aKddw7HdOwnqEcHYE9meT7qXzPEnmQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1713452526; c=relaxed/simple;
	bh=DQg9N9NsmAiomB3YevtTSMmyEr0U2U0LM9Xrfnum6ck=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=IFffoXKdDLrrqpPPhZYEnesvTt7/Zd+m28rILJlB2OxMG+AcIzWSf9EhTBtLwjbgYv35o4tklcLp/8wDNomBH0EOPgbhapD/2xSW5bb1dAVrVz4lNKHXxocr4zh7PBD+1EBanWLV+1cM/355gqsVU7WcC51xZqfYdKxZUYuyC+Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=canonical.com; spf=pass smtp.mailfrom=canonical.com; dkim=pass (2048-bit key) header.d=canonical.com header.i=@canonical.com header.b=AM4TGwSG; arc=none smtp.client-ip=185.125.188.122
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=canonical.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=canonical.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=canonical.com header.i=@canonical.com header.b="AM4TGwSG"
Received: from mail-qv1-f69.google.com (mail-qv1-f69.google.com [209.85.219.69])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-relay-internal-0.canonical.com (Postfix) with ESMTPS id E3FF73F85E
	for <lvs-devel@vger.kernel.org>; Thu, 18 Apr 2024 15:02:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=canonical.com;
	s=20210705; t=1713452521;
	bh=Uwv3V9NnGMB5Wj85PeZTAIoBr809/UIjglv9mvQKrBw=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type;
	b=AM4TGwSGA2KJpiZtkjoweIXNpMhxetHTGIYNuXvQ+aJzpaI/k75iXn+D9z0fUuVaK
	 GbJFPuZqSowhUIrqfo4eNZx1RBqRFZ1Sh8EhfumNNbKA5sOzbUBW3nIUZ6Dk4QiWrs
	 jxJ7ku7/2gTgr/UgLBLvvaW2MBXPOENCXSAp2ZwIEQULrd8pSMk9s3PhwQhb3H/A1j
	 pcUq0jiiCpARQ/wJzqHqe0NF95JXWJJgRAIPA3yMY9xgux8mkXsrvsjuDRIHVQqNiA
	 haXOIf38WkHH2aF+AJY1yrpDDrFqhn4W0xayhpE6SEHhBrCMxNst25T7jNGAdbtgn3
	 /vbR9xfpExpgA==
Received: by mail-qv1-f69.google.com with SMTP id 6a1803df08f44-6a025a08cfaso12640376d6.1
        for <lvs-devel@vger.kernel.org>; Thu, 18 Apr 2024 08:02:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1713452521; x=1714057321;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=Uwv3V9NnGMB5Wj85PeZTAIoBr809/UIjglv9mvQKrBw=;
        b=enCVJbYfelG3z5fbu5TVW8huVohBhz7PLdf7VLlCkZXGjxK7FuHHdubEOFKEX0U2WA
         CjUO+IGZw+hGGwV2gRiWAeooQbPBNtjgswT5XRIbgInt8Tocp2TXE/qZLjdhYaY8qfho
         ufkMkZ+yB3E8Ih/vomBNx3rXJGkcOyovwC4opLmrbhl753bA+hxJTbLcJoycLWV4jzGH
         pOpgkqo750nE1jFurYwOSBsLURaX+y1XBZw/4Q143FHLHy7+69Jr8zqEUQq6EqqeONir
         9+tB6Hbn6IiFcPUFK7sNjkf3u5p9Q9AGEEdUhQJ2ZgTdUHRZUJN2lfW7Ne/1ca5rLYs8
         doXA==
X-Forwarded-Encrypted: i=1; AJvYcCX6/KZf4wBPO1/6teMo3A0YLBubxPnw5Dlp4bzYphljr5ow9sYhN+KGgM+E8wOBfXD8ib51LVhUf5U3/ASdmmWZquYqkT0dZHzm
X-Gm-Message-State: AOJu0Yzx2PE2+JU3adzrCDLMHp4X8uaJsYlinVncXbn6suJcSbgxEw8q
	tGZW+mGvS7wFc1fRFOkAbNi4tyZuyRL20EtIiD5ROVyVborp86czqwf78jXakNBCMuju9HcAeXM
	OhgBZaP4S3r+7iimw1uTHeDerJlbb+xGGXbGR6Bo7tUrXAxCUYspqtuH/Ev6TPDQUgK3q2qcbZQ
	2LS+fuEVTIgvfuhI14hxqJe3AGuC1VuY/O+OlRYBeUTllEgPf0
X-Received: by 2002:ad4:414f:0:b0:69b:5961:1ff4 with SMTP id z15-20020ad4414f000000b0069b59611ff4mr2636823qvp.63.1713452520910;
        Thu, 18 Apr 2024 08:02:00 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IFwnD/dVrXbHRIjywyojR4601i9J6JDecCBPGXdOo9n2JxohMovJ/J3JuT2jIjVRTbNhUbSWJ19JUCG2v0M57o=
X-Received: by 2002:ad4:414f:0:b0:69b:5961:1ff4 with SMTP id
 z15-20020ad4414f000000b0069b59611ff4mr2636758qvp.63.1713452520029; Thu, 18
 Apr 2024 08:02:00 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20240418110153.102781-1-aleksandr.mikhalitsyn@canonical.com> <eb0b4b89-9a1f-0e1b-9744-6eb3396048bd@ssi.bg>
In-Reply-To: <eb0b4b89-9a1f-0e1b-9744-6eb3396048bd@ssi.bg>
From: Aleksandr Mikhalitsyn <aleksandr.mikhalitsyn@canonical.com>
Date: Thu, 18 Apr 2024 17:01:49 +0200
Message-ID: <CAEivzxd_Lz3o8Qmqq6wyfK_UduVL1Qm9jQ9UJaoE_O7wWPrg-Q@mail.gmail.com>
Subject: Re: [PATCH net-next v2 1/2] ipvs: add READ_ONCE barrier for ipvs->sysctl_amemthresh
To: Julian Anastasov <ja@ssi.bg>
Cc: horms@verge.net.au, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, 
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, 
	Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, 
	Florian Westphal <fw@strlen.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 18, 2024 at 3:23=E2=80=AFPM Julian Anastasov <ja@ssi.bg> wrote:
>
>
>         Hello,

Dear Julian,

>
> On Thu, 18 Apr 2024, Alexander Mikhalitsyn wrote:
>
> > Cc: Julian Anastasov <ja@ssi.bg>
> > Cc: Simon Horman <horms@verge.net.au>
> > Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> > Cc: Jozsef Kadlecsik <kadlec@netfilter.org>
> > Cc: Florian Westphal <fw@strlen.de>
> > Suggested-by: Julian Anastasov <ja@ssi.bg>
> > Signed-off-by: Alexander Mikhalitsyn <aleksandr.mikhalitsyn@canonical.c=
om>
> > ---
> >  net/netfilter/ipvs/ip_vs_ctl.c | 12 +++++++-----
> >  1 file changed, 7 insertions(+), 5 deletions(-)
> >
> > diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_=
ctl.c
> > index 143a341bbc0a..daa62b8b2dd1 100644
> > --- a/net/netfilter/ipvs/ip_vs_ctl.c
> > +++ b/net/netfilter/ipvs/ip_vs_ctl.c
>
> > @@ -105,7 +106,8 @@ static void update_defense_level(struct netns_ipvs =
*ipvs)
> >       /* si_swapinfo(&i); */
> >       /* availmem =3D availmem - (i.totalswap - i.freeswap); */
> >
> > -     nomem =3D (availmem < ipvs->sysctl_amemthresh);
> > +     amemthresh =3D max(READ_ONCE(ipvs->sysctl_amemthresh), 0);
> > +     nomem =3D (availmem < amemthresh);
> >
> >       local_bh_disable();
> >
> > @@ -146,8 +148,8 @@ static void update_defense_level(struct netns_ipvs =
*ipvs)
> >       case 1:
> >               if (nomem) {
> >                       ipvs->drop_rate =3D ipvs->drop_counter
> > -                             =3D ipvs->sysctl_amemthresh /
> > -                             (ipvs->sysctl_amemthresh-availmem);
> > +                             =3D amemthresh /
> > +                             (amemthresh-availmem);
>
>         Thanks, both patches look ok except that the old styling
> is showing warnings for this patch:
>
> scripts/checkpatch.pl --strict /tmp/file1.patch
>
>         It would be great if you silence them somehow in v3...

Yeah, I have fixed this in v3. Also, I had to split multiple
assignments into different
lines because of:
>CHECK: multiple assignments should be avoided

Now everything looks fine.

>
>         BTW, est_cpulist is masked with current->cpus_mask of the
> sysctl writer process, if that is of any help. That is why I skipped
> it but lets keep it read-only for now...

That's a good point! Probably I'm too conservative ;-)

>
> >                       ipvs->sysctl_drop_packet =3D 2;
> >               } else {
> >                       ipvs->drop_rate =3D 0;
> > @@ -156,8 +158,8 @@ static void update_defense_level(struct netns_ipvs =
*ipvs)
> >       case 2:
> >               if (nomem) {
> >                       ipvs->drop_rate =3D ipvs->drop_counter
> > -                             =3D ipvs->sysctl_amemthresh /
> > -                             (ipvs->sysctl_amemthresh-availmem);
> > +                             =3D amemthresh /
> > +                             (amemthresh-availmem);
> >               } else {
> >                       ipvs->drop_rate =3D 0;
> >                       ipvs->sysctl_drop_packet =3D 1;
>
> Regards

Kind regards,
Alex

>
> --
> Julian Anastasov <ja@ssi.bg>
>
