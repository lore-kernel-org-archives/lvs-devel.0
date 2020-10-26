From: =?UTF-8?Q?Cezar_S=C3=A1_Espinola?= <cezarsa@gmail.com>
Subject: Re: Possibility of adding a new netlink command to dump everything
Date: Mon, 26 Oct 2020 16:47:46 -0300
Message-ID: <CA++F93huu-Q_J2X89ndYwCGWwETmOPsDDdgVdVeDHUMU5qRg6g@mail.gmail.com>
References: <CA++F93g_WfKbVHLMUFYgQbR63o2-s8Ky_W9Z85qsFM77OaweEQ@mail.gmail.com>
 <68d574-d213-50-7617-f1d917625362@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=aUpIXWcge6Idt1Hrp2edKf6Gjxz9A/R87xsxAYGR+Ak=;
        b=P6VU55N5NHv1m2n3oDJ7t92/Gd0ZtnmXN4G11B+ta/a5ZDrV6WXW1SFIU5CTaIVBGL
         Uw9leeIdpOczYJsm7RMFdgWQKxwXhFrsc5RyxDTqm6FB2ZL5WESckT3LBBqlOLd8Mb4S
         EaNC1uBAhEYrWsg0Uv9C9ai2WZlof0MBIGbBF9Zot+YBaA84NenWFrFhCRZ9AV+8rXO2
         NZuLCCPzMo9gZYUasHJldc5RvpuwS5bV9N3a8zrAt4uH4RzdaxhtjshONcUCCUn3r55O
         LosWjIFhU21vocXyfRebEhMyxN4zeCurDFK3p6tU9GfSLEMPwpAYezmMsfQfglnkVel1
         zDFw==
In-Reply-To: <68d574-d213-50-7617-f1d917625362@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

> > 1. First of all is such a patch adding a new command something desirabl=
e and
> > could it possibly be merged or should I just drop it?
>
>         It depends on its complexity, are you changing
> the ipvsadm -S code or just the kernel part?

Thank you for the fast reply! Just the kernel part for now and some
crude standalone benchmarking code, although I intend to also change
the ipvsadm -S code to use this new cmd if available.

> > 2. I can see that besides the generic netlink interface there's also an=
other
> > interface based on getsockopt options, should the patch also add a new =
socket
> > option or is it okay for this new functionality to be exclusive to gene=
ric
> > netlink?
>
>         No, sockopt is old interface and it is not changed,
> it lacks IPv6 support, etc.

Great.

> > 3. Should this go forward, any advice on my next steps? Should I simply=
 send the
> > patch here?
>
>         You can post it with [PATCH RFC] tag, so that we
> can see how do you mix services and destinations in same
> packet. You can also add speed comparison after the --- line
> for more information.

I'll do that and we can discuss further then. Thanks a lot for your time!

Regards
--
Cezar S=C3=A1 Espinola
