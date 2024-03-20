Received: from mail-ej1-f41.google.com (mail-ej1-f41.google.com [209.85.218.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B6F9DF9FD;
	Wed, 20 Mar 2024 02:42:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.218.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1710902545; cv=none; b=LcfyfpQ3KAxmEwJQdF1m8VQnV862Rt539SHP2OZEnmkdhrhkz6odDpJUN7Eb98XZgGygjk9voZ2a0EVy7mwXX96HJRc3HzQAH5dDVOImw81r8gYTwyjMgpFll1MiqRHXAkPk+PIX7LC7CeMY+qhB76JqaNA59rLLBBsIuj0w4nE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1710902545; c=relaxed/simple;
	bh=42KX8jGSZV2HlHMeF1znLCSctM7RtjjkNl0SRN0SFRc=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=JNSUv/y5njp98TR3VvlCpDRIW6VCuo8WQ6TJhgT0KaWs4ceInxiJW6csbpOVI61GdpTNuinGXHnttH4MdCHPYFAVTT+W5yOojTbocCveo9+Cbm89lI5REhshD8oWDIz7D2v0fKTRB4nfhDD+y8RLdFG7HQOEm28U+ZE6ZP7R428=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=IUWGYqRo; arc=none smtp.client-ip=209.85.218.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IUWGYqRo"
Received: by mail-ej1-f41.google.com with SMTP id a640c23a62f3a-a46ba1a05e0so395616166b.3;
        Tue, 19 Mar 2024 19:42:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1710902542; x=1711507342; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=EcSHk9hySYWRFdkj5awpMFmZVPHKVnBsyvYRWII/qB0=;
        b=IUWGYqRojKhzCRgV8fXppcIf/4DnACZ5/sXR4VaK8ek7GmKlWz0oImQO24Zqy+Q62f
         Jt6K7kjhhUjMDI2suyJvM1JdKhhaNBbyYoUP8W2gJK1xD7ehGIaZ4aC2Gy50v8wda0Yh
         sDn8NgZhrFw3pVL0VKMetp3HbXHS3kPzexs4qFdd/O0QT/24sPaPw9/etSXge8OdBbBT
         Zdrk4VKAkgVC2BU2ogwRrXVKxtX/gRifaTuzvklNlza1+VGrNVl3qcjhq/hw4qYbHaYC
         d09uviaQhhvCddA+DtIy+Tnb2G6NQlbCi4X3qg0k3xUoRAW7ejVhFqWyResJWoSf4qPi
         B7tQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1710902542; x=1711507342;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=EcSHk9hySYWRFdkj5awpMFmZVPHKVnBsyvYRWII/qB0=;
        b=g6o1aqtfygEOJq8Tzns0u0FR0WfbhVV/iabB9sUGFwu0adWLzIQujGNFx1KFYb8rtM
         3xc0SyMdLZC95JQ+yE3smVrFFdUTZiT5SSSjgNkRXhh5No0jAym/rbHD/g3dd/KlyFaA
         agKjMXx5xGhHJIX5IsrJEtEPamVMrfb1LuK1dBpXxrgT+OAhFGZLWR5/XIQ44D6c+rOm
         4iHbzj56WgJUgJcoK/2FoDDRBrlIBZlPVkLBMK02cRHsgvnPCRgcUMC1PT4IwXxPR2IT
         oeKHwdmPb4ptFWcLPlDywBZTvzXGeF5bvWKmZCw93qhpndpyhuAw73MX0ukS7TZU3LhF
         SVLw==
X-Forwarded-Encrypted: i=1; AJvYcCXKDAViFdhtgIZylCl9LX3Y5PX7s6Idq3bsrz8tV1ba6Dig0eq2c6FLlETQJh8qbxGqjjCh7dzAARiScSR7LhVc1xlMLViAmHFnQCyFeHHOOcTkLxBklAHibNugAEJlfLy8
X-Gm-Message-State: AOJu0YwkeVE7RJMU06qy+w7tVhBhbUCRSUABloAjlEG5MIRidGjIoWu4
	ppKp3ttNO7bK1J2f8OH+DGbAgnMwCaqAYxKmy4k5hSggdxQiz7DX2efkei8jCHRb/zAvDYJAUaS
	WmRJiJihwTfcd7zB2MArWTwf8J1c=
X-Google-Smtp-Source: AGHT+IH/FR830JT8pwRZd0wvBGtIkpZow1qP+kLmcCEVpk9fkEEa5/VxH+ePDVFzg1KiUDBxgT+/5lAjf9QXwxtlq74=
X-Received: by 2002:a17:906:3e07:b0:a46:8d30:b91c with SMTP id
 k7-20020a1709063e0700b00a468d30b91cmr2436519eji.34.1710902541936; Tue, 19 Mar
 2024 19:42:21 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <5fde8ace-a0ac-4870-a7fe-ec2a24697112@gmail.com>
In-Reply-To: <5fde8ace-a0ac-4870-a7fe-ec2a24697112@gmail.com>
From: Jason Xing <kerneljasonxing@gmail.com>
Date: Wed, 20 Mar 2024 10:41:44 +0800
Message-ID: <CAL+tcoDA2Mf9oxAFsmbfM3JcdSb=Er09R1+=j7CLSpLVcxN38w@mail.gmail.com>
Subject: Re: [net] Question about ipvs->sysctl_sync_threshold and READ_ONCE
To: Zijie Zhao <zzjas98@gmail.com>
Cc: horms@verge.net.au, ja@ssi.bg, davem@davemloft.net, dsahern@kernel.org, 
	edumazet@google.com, kuba@kernel.org, pabeni@redhat.com, 
	netdev@vger.kernel.org, lvs-devel@vger.kernel.org, chenyuan0y@gmail.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 20, 2024 at 6:49=E2=80=AFAM Zijie Zhao <zzjas98@gmail.com> wrot=
e:
>
> Dear IPVS maintainers,
>
> We encountered an unusual usage of sysctl parameter while analyzing
> kernel source code.
>
>
> In include/net/ip_vs.h, line 1062 - 1070:
>
> ```
> static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
> {
>         return ipvs->sysctl_sync_threshold[0];
> }
>
> static inline int sysctl_sync_period(struct netns_ipvs *ipvs)
> {
>         return READ_ONCE(ipvs->sysctl_sync_threshold[1]);
> }
> ```
>
> Here, sysctl_sync_threshold[1] is accessed behind `READ_ONCE`, but
> sysctl_sync_threshold[0] is not. Should sysctl_sync_threshold[0] also be
> guarded by `READ_ONCE`?

I'm not so sure and clear about the detailed history.

AFAIK, readers accessing this sysctl knob (sysctl_sync_threshold)
should be protected by READ_ONCE() because it can be changed
concurrently. Probably the commit 749c42b620a95 missed this point many
years ago and then commit 6aa7de059173a followed that.

Thanks,
Jason

>
> Please kindly let us know if we missed any key information and this is
> actually intended. We appreciate your information and time! Thanks!
>
>
> Links to the code:
> https://elixir.bootlin.com/linux/v6.8.1/source/include/net/ip_vs.h#L1064
> https://elixir.bootlin.com/linux/v6.8.1/source/include/net/ip_vs.h#L1069
>
> Best,
> Zijie
>
