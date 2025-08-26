Received: from mail-yw1-f171.google.com (mail-yw1-f171.google.com [209.85.128.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 54C03362065
	for <lvs-devel@vger.kernel.org>; Tue, 26 Aug 2025 14:41:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.171
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1756219266; cv=none; b=IXRmPlDsugBzDtzAsUMKOdBkxs3M0l2QIgaE0vJ25ccAoTUURY+oVXKiMe/qglZ0XAwsHQbCBOEoaBQwvCxUVFNbeRgD6tJ4+sfFuF8LFxj9VauYaVvRv2Qh/uNGCirPuCT8XxEm5BwlIEz37WVbhQSGz0vkiJPCM9ZN/kbkr5M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1756219266; c=relaxed/simple;
	bh=hyCxhAYM+PA3OYD2qg0SHMzPnPjwfrsqspLLMQYlk24=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=dVpS3EZldQb47MJ/Bxp5GFB4V4/xsJc0fAskwvc5GP6thRn/Z5iX3AxDqinPCDCOk7/MgkkvPyuvrGBUUmHBCNEWYC5/POMQlKbaqrjtWTI6MgwoUZAN3V6Onyn4r+sYihBG6ilbiquwFSXWT+H1AoTJbE2r2/3/cObUDPIOYog=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=LpgD5X+i; arc=none smtp.client-ip=209.85.128.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="LpgD5X+i"
Received: by mail-yw1-f171.google.com with SMTP id 00721157ae682-71d60504bf8so46354797b3.2
        for <lvs-devel@vger.kernel.org>; Tue, 26 Aug 2025 07:41:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20230601; t=1756219263; x=1756824063; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=mgJng7gbUZZ9Z6XUdf92AxiN5YcMf9KcpRV4KEnk74I=;
        b=LpgD5X+iRVIpc7002zZNLT/jPDE/Eqnv4uPJOrJFij7XRTiamoXMB9hVvhagjG3ECM
         HxdCokSOVy3Z6HvQ4BGigcl+34NkdpPcgillz/WqpOVHmeb/HdG8Q5iK0hKZqQb3Z904
         72CgoMGzUo04XlTCqvN/y60WtuTnXrswXgPLa2X9mVN+quuLm7/m/vsayxIXtrgJ/SRY
         LyhqP7Qq4ZBYqVohotNuYeUSVp8t61rv/wOF0y2kTaTg9rZ8zZbFVzWsWUhlWthrtgsC
         qP/9VtIgo/WCCkmFzYo1qZMDGOjLkT011q+sKGVhd8vzg7Mtu7p5Zkx39eRehAqWaGWK
         +c9g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1756219263; x=1756824063;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=mgJng7gbUZZ9Z6XUdf92AxiN5YcMf9KcpRV4KEnk74I=;
        b=G2yrlTJDCf0/gVvQlV+/JBaEKp3XwdS1rdmIkj+6Yq7XbXwRX+DYdqjf6r7o3R6LYq
         l3er+5tac2hIvImsOGG528GepUDSvamz88OntvEfhD9yVLA6GTV+sXTnF/IVh8BC7rny
         ooqDIcTd2rFOtG8Ci9aC+Rut3TiYBUvVu1ZvACASASSmkJf8qcGF7ujE5Kt9xiZbltpJ
         XhfKPlwQ87gc/gy2MZrd9KWLY1w4iW6HdfLWh9lCbMZDa+hzPS4jxQ7RyK5RCU4Au7Sx
         +xku//8IDEY5BciIBbib2ZaIR74ssypLxRV3ip8d/d8vvLRQA19AC0jdwYi7rWOZyLEU
         Snlw==
X-Forwarded-Encrypted: i=1; AJvYcCVZ6UsUduFxvCR7Q6NGA32vT00ym+rsUFlNPAe0ZQmI5r4vvmDl+70uEuvQ/06WveciWniVbhquqrY=@vger.kernel.org
X-Gm-Message-State: AOJu0YxV0Tu0eSeaIXZRDvS2b17i6tuzeHjJDgSWJcQeQoe3z0WBEdqf
	e/nZn2lQQxfqBqL5LDi/6L18lPRnXqaRNdTsyTkcAoFiRheVEiuukzTpRnmNEui96fJryzuacTp
	YbHXGi9VTXoUv6Fx/CCE9TYX6XOoFMV0E9K8P34G6
X-Gm-Gg: ASbGncvonIpYgDBXATDRpgtmwSlVBxszzjvCuIOthfCkkkPXsfPoNG1ufIWRfx60dMQ
	WmTICIyszmfze4QLSwGN7p7FpDyFCPefBXi+zcj/54SPenRPmZiTdCPeQwZynv1vITPQgznK98p
	4LEd0qAp6K2swPxo9E7k7Fp8bLS8wSA83U+vR2qLRbI0sjT0D/gJIz+7/6dJRwKuQb/MOKHYHG6
	07QV6SpZYd4
X-Google-Smtp-Source: AGHT+IFesp/oI9Ak46NqKRSQa8N7DRHfHsYS7xFO5jugYlbdLYp0PlK7Sg2D2EF0K5ksP+hlagrHvGHb7VSuD4ocbTw=
X-Received: by 2002:a05:690c:fca:b0:721:1fda:e32e with SMTP id
 00721157ae682-7211fdb5f88mr57202097b3.23.1756219262794; Tue, 26 Aug 2025
 07:41:02 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20250826133104.212975-1-zhtfdev@gmail.com> <aK3CQ1yNTtP4NgP4@strlen.de>
In-Reply-To: <aK3CQ1yNTtP4NgP4@strlen.de>
From: Eric Dumazet <edumazet@google.com>
Date: Tue, 26 Aug 2025 07:40:51 -0700
X-Gm-Features: Ac12FXy0DZXDFBRohoO9_uQKI_gYe4HZYQAW7aKbGnFlHhCAnD0bLM7ago9sXzA
Message-ID: <CANn89i+p=jBtqS6ijvQ5RWovk_DgZTBPnTLBMjpj2ppdVc_W_g@mail.gmail.com>
Subject: Re: [PATCH] net/netfilter/ipvs: Fix data-race in ip_vs_add_service / ip_vs_out_hook
To: Florian Westphal <fw@strlen.de>
Cc: Zhang Tengfei <zhtfdev@gmail.com>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, 
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, 
	Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, 
	"David S . Miller" <davem@davemloft.net>, David Ahern <dsahern@kernel.org>, 
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, coreteam@netfilter.org, 
	syzbot+1651b5234028c294c339@syzkaller.appspotmail.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 26, 2025 at 7:18=E2=80=AFAM Florian Westphal <fw@strlen.de> wro=
te:
>
> Zhang Tengfei <zhtfdev@gmail.com> wrote:
> > A data-race was detected by KCSAN between ip_vs_add_service() which
> > acts as a writer, and ip_vs_out_hook() which acts as a reader. This
> > can lead to unpredictable behavior and crashes.
>
> Really?  How can this cause a crash?

KCSAN + panic_on_warn=3D1  : Only in debug environment

>
> > The race occurs on the `enable` flag within the `netns_ipvs`
> > struct. This flag was being written in the configuration path without
> > any protection, while concurrently being read in the packet processing
> > path. This lack of synchronization means a reader on one CPU could see =
a
> > partially initialized service, leading to incorrect behavior.
> >
> > To fix this, convert the `enable` flag from a plain integer to an
> > atomic_t. This ensures that all reads and writes to the flag are atomic=
.
> > More importantly, using atomic_set() and atomic_read() provides the
> > necessary memory barriers to guarantee that changes to other fields of
> > the service are visible to the reader CPU before the service is marked
> > as enabled.
>
> > -     int                     enable;         /* enable like nf_hooks d=
o */
> > +     atomic_t        enable;         /* enable like nf_hooks do */
>
> Julian, Simon, I will defer to your judgment but I dislike this,
> because I see no reason for atomic_t.  To me is seems better to use
> READ/WRITE_ONCE as ->enable is only ever set but not modified
> (increment for instance).

+2
