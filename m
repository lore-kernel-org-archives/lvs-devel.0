From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [lvs-users] Micro ipvsadm patch
Date: Mon, 23 Mar 2020 09:09:03 +0100
Message-ID: <20200323090903.0753d01a@carbon>
References: <CAH57y_TcVNdCe7ciAXX85HzWXPhWgUWvXn2f7r8yWjM2TUNecQ@mail.gmail.com>
        <20200320133137.3cc59704@carbon>
        <CAH57y_R=xUY-MPkFfeoOpH_f3eCLWDKuwW+wtNOKD9JJMjRkTw@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1584950956;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=DatnUF98BCsDDqz4v1cS5fMH4kzRB69WiMI1dy/omLE=;
        b=h3F6DkfqrrHEUFznbO4wK9lj/ItYgKVtAkzocdgVIBBvrtpWVrIZ8mEfbsJa80j4XrQet9
        hadCZybYuDYMEnvJJDfu6Di+pzBH4XXkQguzGXfLbdLCufhQ2mzTTYkwL4z6D0KobCKlEL
        4c9pUn662BwA4knIrO1XBsezbJ7rlLI=
In-Reply-To: <CAH57y_R=xUY-MPkFfeoOpH_f3eCLWDKuwW+wtNOKD9JJMjRkTw@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Alexander Petrovsky <askjuise@gmail.com>
Cc: Julian Anastasov <ja@ssi.bg>, "LinuxVirtualServer.org users mailing list." <lvs-users@linuxvirtualserver.org>, Simon Horman <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, brouer@redhat.com

On Fri, 20 Mar 2020 21:16:47 +0300
Alexander Petrovsky <askjuise@gmail.com> wrote:

> Oh, thanks.
>=20
> Where I can find out the full procedure?

As this is a tool that is closely related to the kernel, I/we try to
follow the kernel submitting patch guidelines, but losely:

 https://www.kernel.org/doc/html/latest/process/submitting-patches.html

--Jesper


> =D0=BF=D1=82, 20 =D0=BC=D0=B0=D1=80=D1=82=D0=B0 2020 =D0=B3. =D0=B2 15:32=
, Jesper Dangaard Brouer <brouer@redhat.com>:
>=20
> > On Wed, 11 Mar 2020 15:05:58 +0300
> > Alexander Petrovsky <askjuise@gmail.com> wrote:
> > =20
> > > Hello!
> > >
> > > This micro ipvsadm patch fixes wrong (negative) FWMARK values
> > > representation:
> > >
> > > # ipvsadm -L -f 2882430849
> > > Prot LocalAddress:Port Scheduler Flags =20
> > >   -> RemoteAddress:Port           Forward Weight ActiveConn InActConn=
 =20
> > > FWM  -1412536447 wlc =20
> > >   -> abc.my.host.net. Tunnel  1      0          0 =20
> > > =20
> >
> > Hi Alexander,
> >
> > Your patch submission does not follow all the procedures, but given
> > this is fairly trivial, and Julian didn't object, I went ahead and
> > applied the patch with (your SoB and credit to you), here:
> >
> >
> > https://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git/commit/=
?id=3De61c8cdd1dcad
> >
> > --
> > Best regards,
> >   Jesper Dangaard Brouer
> >   MSc.CS, Principal Kernel Engineer at Red Hat
> >   LinkedIn: http://www.linkedin.com/in/brouer
> >
> > -- =20
> Alexander Petrovsky



--=20
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

