Received: from mail-lr2-f12.google.com (mail-lr2-f12.google.com [74.125.230.76])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F37173AFAF8
	for <lvs-devel@vger.kernel.org>; Mon, 21 Sep 2026 07:10:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.230.76
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789974643; cv=pass; b=QsLWKVizPN308eGFU5Et1yMGeV5tC9RTtiQ2KQ5QKVwqkC8tsgHAW9pfO1Fsikx9QXl3QIoOaBJWsC315DFaqWVXeoedyRcJVcGfYO5n5IW55sTD7P4l97Y8BsuAoahxKitIjR+LkmtEp/VHxu3raj83jgrLjV0JXPMT7lZgbIo=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789974643; c=relaxed/simple;
	bh=kJH7+kos1l9lkpvaZyjlUUt9NhEpQOT2pMMtBb2piIw=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=iua0+vAVp10erPWO/n65wxB29Ohi/rp2I/eKcC8vHO0MqLZDg7GHupLcbsLbDHVV1IjcPTY1XpI2qZzAfUfOnJzZTLV/Jrz2OkrP1Td4dD0+Pe9vio/ZQOHLqnzEqp96NwVDG0WR02YTMX51cUfz2XogWgPkAk/tCvZrZxytHoM=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b=Hb/5K9Kq; arc=pass smtp.client-ip=74.125.230.76
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b="Hb/5K9Kq"
Received: by mail-lr2-f12.google.com with SMTP id 38308e7fff4ca-3a2ff04155bso22112521fa.1
        for <lvs-devel@vger.kernel.org>; Mon, 21 Sep 2026 00:10:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1789974638; cv=none;
        d=google.com; s=arc-20260327;
        b=DS7mc/EI22Ib3FSJOW9+iZq9qNNgYHx9IJVAZ+xgI+Dh0jQ3HYsziAtg09Nq/Vwyj1
         cwgjScB3g0ob3d3PpLM2Nh30bBPe/aLAycs2MHN/F/OpQOxil4+ZSecvm9LQIE2Fc1mY
         W32ClU2zX8eFdLo9TTV7IFMJHua5Jpwz0EBPTKs5kyWPQvY94OGQJyQHL7gWmQ4SLhXr
         innIzhzPq1IX/jfektnQrB6TagNe7v1YqimmNiicRKz8l64u0yrDCbOxar28WKJ9jrXw
         Wi9DM95FhI20dWRG7X5VYbAOpxVtiUB6sab8naCOZ1JoEgvbWr8MVHTMzEzqZKqrICjU
         rnSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=ohcBhfXjMZ0w/piBj8Wfzyl/Cc0Gtqk0dL3r6ReUuIg=;
        fh=0ZVt1fPummLERL2lX7P5bUXxL6KOErM5M0CW8BtuKwE=;
        b=S8Bm5BZJTkOWMnOzkI0HvcQ9yUXCbBnNUswNDx/Udr1soxMKESo1dfwwFWfcia6wur
         yrCk8Ygy1ioLUP2PNHShGXaZunC45yXfUmWq9Z1mC053/E9GAy2mR6xESFgAxsNcPRJJ
         PMxe0LW1RqgOyggiI75A/xAOtUVxRIr9HQDdAzIZUjFswZecUXYfUjDLP2yxQs/sAtq7
         JFkiqG/bNu+DJFFLK7ximf08nawq22SF6rj9E8oFPR1+PYUWmVII0IsF/nv0SOymFc9M
         h0RkubGQ6dbmd67OmTrxlrSk+P/qPTZsj7Nl9ta1YD6ZlnGy6VgqkSQztfFEqSCvpmXW
         tYeQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1789974638; x=1790579438; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=ohcBhfXjMZ0w/piBj8Wfzyl/Cc0Gtqk0dL3r6ReUuIg=;
        b=Hb/5K9KqMJ3aBi2GtHACmHMerZlDcswpnDm0o6VCgfQNYkS51BtgBLF/vzt5rS9WD5
         RCYM6xRGh1iUJpVeGwJM8qGnBh747L3cHn1P3aygbG3GFjLxe9mCKoK+eNZF1SsfxP8U
         sqXF3U5vkCzbLJl+zHiuofQ2CdNcPi4Nn577x2yti2l5TxTXttPjKz5ESWApzFFvsDnY
         LQK8CAbU6WFrvJd1pYQ2OQkDB+6J99qvYaq6NDrQESh2mjN4JXCxkTIM+UXwqS1joo/Q
         OqVodN9Eiqw2N0YXKJis5u8XS+1FXZKSo8bKDANYcNzuACGASmnmPQhowBvu2f9f5aap
         SjMw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789974638; x=1790579438;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=ohcBhfXjMZ0w/piBj8Wfzyl/Cc0Gtqk0dL3r6ReUuIg=;
        b=MZaN09IrsN0oOkg6pISdGFwtzfpwifEqLeiF8zxTFfbO2klwr6f3I3wNS90DeT7nNH
         5sUu6g/6JtWYhHO06xNdo0ylVi6m52/cNqqXFdb0kN+QTvm5P5h2BLtAAP6VIEPvJfFC
         JheeP7LJZDNRVtKST31MH746L+ulQL1qCuwgDxInATWZe/MZBiEfQvhjxG/u9JkwOQyu
         Z474XZdxu5IAZ+cBdQCIS6ZGrGI+cw3LBstkFe9s0pWSTDcLfNj+irQRv8W5u4eRkhai
         jCwY7OT/rlG8yzJ2A9GWp7BYQWCAnRQOC2h/SkdtIbD4hd3Kk11qUoj8PW6XV/BqiT/P
         PAqA==
X-Forwarded-Encrypted: i=1; AKwUvBy/4gluSQCw2mu3YrDJw0eJFL3E1F9Hl0mN+z5TbclqxeUasX1EOz29nCwYmOsyHTHMI1OD7LGjH9U=@vger.kernel.org
X-Gm-Message-State: AFuF++klIjaufoJFwRwhhAGQk/97/Tpi2EM0FkTY2xgH0pvMfusJZoee
	h8Ftaq9OZT6905P+mf+piYGKUlRN8MOafC4g7KPPrR4+LlKxEbxxcllKuST6clVSNb0AAM6dMmk
	C8xg7S3qSv7pVN9uWkU1Xm/K2dKuFijx6A9zcuVVc7sY=
X-Gm-Gg: AYBFou1nHnUqBUAjkvcqokEZ17x3pCZiJow7j3pjHViDXnnWb/Do9d0WG3pbhD5qEjR
	qMlY9Li+Uw3+ujtIQwYb9m356VsEJhcK4KHhfwLOZpyc3Yvw5b3IYvYMvgwur+au7E9ZWWu6mt9
	as2jdv8XcRgHcNZgzayxueF09C++s8tz1WL075un6iMZyE7E7R+wb3ZIASw51NPBglZC6T0AdUg
	iEQ/EKVjFaU9thgzFzR1ZuaqP4s4hUWVTA3GgqowhCDUQ6K/9lUrtymCUqsBq1ZyChwpnMyYVmV
	VGneSuQMYwHiZYqSK7uOVftTFWVaItJDynBiZaf6R64w8euE2vu+IcyYsMCReBY1k8KEtRS7cM5
	f0mfHEkDplg==
X-Received: by 2002:a2e:a98c:0:b0:3a5:b187:c7a1 with SMTP id
 38308e7fff4ca-3a5fbf0215emr21570991fa.9.1789974637997; Mon, 21 Sep 2026
 00:10:37 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260917030301.5502-1-zihanx@nebusec.ai> <178996076640.2160803.16028832049809238100@kernel.org>
 <e1efae34-24a7-3b24-22b0-6a838aa93d52@ssi.bg>
In-Reply-To: <e1efae34-24a7-3b24-22b0-6a838aa93d52@ssi.bg>
From: zihan xi <zihanx@nebusec.ai>
Date: Mon, 21 Sep 2026 15:10:26 +0800
X-Gm-Features: AcwNN1UcIHa_FP3_g69sLth774wwgDQwaw2Ruj6A1N9ozW6m1CE6EgqsboVPQSM
Message-ID: <CAANe3eSYSxU_OhSSsp8aML6XH2a8qm2+nZSmdJAzZ6Q6uxwN2A@mail.gmail.com>
Subject: Re: [PATCH net v2 1/2] ipvs: avoid stack overflow from recursive
 connection expiration
To: Julian Anastasov <ja@ssi.bg>
Cc: netdev-bot+sashiko@kernel.org, horms@verge.net.au, pablo@netfilter.org, 
	fw@strlen.de, phil@nwl.cc, davem@davemloft.net, edumazet@google.com, 
	kuba@kernel.org, pabeni@redhat.com, netdev@vger.kernel.org, 
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, 
	coreteam@netfilter.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 21, 2026 at 2:50=E2=80=AFPM Julian Anastasov <ja@ssi.bg> wrote:
>
>
>         Hello,
>
> On Mon, 21 Sep 2026, netdev-bot+sashiko@kernel.org wrote:
>
> > Thank you for your contribution! Sashiko AI review found 2 potential
> > issue(s) to consider.
> >
> > Critical: 0 =C2=B7 High: 1 (1) =C2=B7 Medium: 0 =C2=B7 Low: 1
> >
> > If you believe none of the issues are legitimate, please reply to each
> > issue of Medium severity or higher and explain why the AI is wrong.
> > If any of them are legitimate and you plan to respin, please let patchw=
ork
> > know by including "pw-bot: cr" as a separate line at the end of your re=
ply
> > (one such reply per series is enough).
> >
> > - [High] ipvs: use-after-free in ip_vs_conn_expire() due to timer re-
> >   arming race
> > - [Low] ip_vs_conn_del_put() (net/netfilter/ipvs/ip_vs_conn.c:1333-1346=
)
> >   keeps its old comment "Try to delete connection while holding=E2=80=
=A6
> >
> > Pre-existing issues:
> > - [High] ip_vs_conn_del_put() (net/netfilter/ipvs/ip_vs_conn.c:1336-134=
1)
> >   cancels the controller's timer, drops the caller's only reference on=
=E2=80=A6
> >
> > --
> >
> > ipvs: avoid stack overflow from recursive connection expiration
> >
> > This changes ip_vs_conn_del_put() to return whether it managed to delet=
e
> > the controller's timer, and makes ip_vs_conn_expire() loop back with th=
e
> > controller instead of recursing into itself.  The stated goal is to kee=
p
> > chain cleanup synchronous while using a single stack frame.
> >
> > v1 Link: https://lore.kernel.org/all/cover.1789110326.git.zihanx@nebuse=
c.ai/
>
>         Zihan, IPVS has conn refcounting which does not look
> natural: the hash table has reference and the timer callback
> has no reference. Let me try today to change the refcounting,
> so that unhashing occurs after last reference is dropped,
> the conn lookups already use inc_not_zero, so we will try
> to consider the timer_delete as successful stealing of
> the refcnt from the timer callback (yes, the callback should
> hold refcnt, not the hashing). But first let me try if the
> idea would be successful. As result, your change should
> be small as before, we should be able to delete conns safely.
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>

Hello Julian,

Thanks for looking into this.

The Sashiko report was generated for v2. I have already sent v3:
https://lore.kernel.org/all/cover.1789877273.git.zihanx@nebusec.ai/

I'll wait for your refcounting changes and then rework the iterative
expiration fix on top of them.

Regards,
Zihan
