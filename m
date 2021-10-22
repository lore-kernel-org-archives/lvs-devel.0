From: Alexis Vachette <avachette@deezer.com>
Subject: Re: netfilter: ipvs: using maglev scheduler algorithm
Date: Fri, 22 Oct 2021 12:23:44 +0200
Message-ID: <CAP962rS3rks8e4gMkC7fX_F8guCC7heizR_iR=MsFjBizt863g@mail.gmail.com>
References: <CAP962rShHbVtXNONwRWda6xAZ_L8kVWTSNZc_bC=gCetUMpNHw@mail.gmail.com>
 <2bb21c12-d8fa-acf1-73f1-67a996e6b98@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=deezer.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=MXGH3MZ+pzf1bW32CZ7M3ZvMV1qmAWAqVbL5mLNM/kA=;
        b=Wq7vE7pFLz/iEgYymPg0cZUUaNZcPdVltBULD5fphkqFx7wT4ABVXf7wx2sX9bEnoO
         JWkk3w8sqdlhck74YoU7Z3G7Z+M54Xgo12iIal3/h7KyF7W4p0s3tOAJYO/Zb8W9YJDy
         PzzxLXYZJ1snjV7feg/EHQaejMeRF8SFb+34U=
In-Reply-To: <2bb21c12-d8fa-acf1-73f1-67a996e6b98@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hi Julian,

Thank you for your help.

Indeed it's working as expected when this option is set.

I will check on keepalived side if I can improve the option
description on the manpage.

Regards,
Alexis Vachette.

On Thu, 21 Oct 2021 at 20:47, Julian Anastasov <ja@ssi.bg> wrote:
>
>
>         Hello,
>
> On Thu, 21 Oct 2021, Alexis Vachette wrote:
>
> > Hello everyone,
> >
> > If this is not the correct list to address my issue feel free to tell m=
e.
> >
> > We are heavily using Netfilter/IPVS with maglev scheduler algorithm
> > and it's working great on most use case.
> >
> > The only case when we face issue is when inhibit_on_failure option is e=
nabled.
> >
> > Here is our setup:
> >
> > - 2 LVS director in active/passive mode
> > - 2 backend node
> >
> > Exposed service is SSH using port 2222.
> >
> > You can find below the LVS state when issue is occurring:
> >
> > root@dev-lvstest-01 ~ =E2=9D=B1 ipvsadm -L -n
> > IP Virtual Server version 1.2.1 (size=3D1048576)
> > Prot LocalAddress:Port Scheduler Flags
> >   -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
> > TCP  172.16.42.170:2222 mh (mh-port)
>
>         If inhibit_on_failure sets weight to 0 you may need
> to add the mh-fallback scheduler flag to allow traffic to
> use fallback server(s).
>
> >   -> 172.16.42.168:2222            Route   100    0          0
> >   -> 172.16.42.169:2222            Route   0      0          0
> >
> > Here is a working example output:
> >
> > root@dev-lvstest-01 ~ =E2=9D=B1 tail -f /var/log/kern.20211021 | grep "=
172.16.42.170"
>
> ...
>
> > Oct 21 09:17:34 dev-lvstest-01 kernel: [   75.590633] IPVS: lookup
> > service: fwm 0 TCP 172.16.42.170:2222 hit
> > Oct 21 09:17:34 dev-lvstest-01 kernel: [   75.590637] IPVS: mh: TCP
> > 172.16.42.170:2222 - no destination available
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
