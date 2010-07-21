From: Wensong Zhang <wensong@linux-vs.org>
Subject: Re: [patch] ipvsadm: Don't report persistentconns as activeconns
Date: Thu, 22 Jul 2010 07:57:24 +0800
Message-ID: <AANLkTikhQTBUuz4Lp1ZvE2By8I5oOG2c0i45rwzesN7h@mail.gmail.com>
References: <20100221220751.GF5712@verge.net.au>
	<20100720081058.GC19483@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:sender:received
         :in-reply-to:references:date:x-google-sender-auth:message-id:subject
         :from:to:content-type:content-transfer-encoding;
        bh=4SgAr4g4s9YW1l+It3VBg99sf4q8cbDWXCf3wcDZxZ0=;
        b=FCfidD55sR1rZJ7oQEPpNf6mrzIYlp5lfm1hKnnaIKNvNVChkjx3nHtSk0Lvv+ushO
         VzYeQMW/OtfuicX8kxwx4VaJccUHStFjEM8xu9Zu0Y/5svsPHxnDuTtgRPbM0799P57m
         2aPzuHIxUmY7efj7+VrYljUZjHiJ+FiGGhzhE=
In-Reply-To: <20100720081058.GC19483@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: lvs-devel <lvs-devel@vger.kernel.org>

Applied, thanks a lot!

Wensong

On Tue, Jul 20, 2010 at 4:10 PM, Simon Horman <horms@verge.net.au> wrot=
e:
>
> On Mon, Feb 22, 2010 at 09:07:52AM +1100, Simon Horman wrote:
> > This fixes what appears to be a typo in the netlink client code
> > whereby the activeconns is read as activeconns and then
> > overwritten by persistentconns. The result is that the active
> > connection count reported by ipvsadm -L is wrong if the
> > code is compiled to use the netlink interface.
> >
> > Tested-by: Nigel Kukard <nkukard@lbsd.net>
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> >
> > ---
> >
> > Wensong, please consider applying this patch to ipvsadm.
>
> Wensong, Ping.
>
> > Index: ipvsadm-1.25/libipvs/libipvs.c
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > --- ipvsadm-1.25.orig/libipvs/libipvs.c =A0 =A0 =A0 2010-02-18 16:5=
7:46.000000000 +0900
> > +++ ipvsadm-1.25/libipvs/libipvs.c =A0 =A02010-02-18 16:57:49.00000=
0000 +0900
> > @@ -747,7 +747,7 @@ static int ipvs_dests_parse_cb(struct nl
> > =A0 =A0 =A0 d->entrytable[i].l_threshold =3D nla_get_u32(dest_attrs=
[IPVS_DEST_ATTR_L_THRESH]);
> > =A0 =A0 =A0 d->entrytable[i].activeconns =3D nla_get_u32(dest_attrs=
[IPVS_DEST_ATTR_ACTIVE_CONNS]);
> > =A0 =A0 =A0 d->entrytable[i].inactconns =3D nla_get_u32(dest_attrs[=
IPVS_DEST_ATTR_INACT_CONNS]);
> > - =A0 =A0 d->entrytable[i].activeconns =3D nla_get_u32(dest_attrs[I=
PVS_DEST_ATTR_PERSIST_CONNS]);
> > + =A0 =A0 d->entrytable[i].persistconns =3D nla_get_u32(dest_attrs[=
IPVS_DEST_ATTR_PERSIST_CONNS]);
> > =A0 =A0 =A0 d->entrytable[i].af =3D d->af;
> >
> > =A0 =A0 =A0 if (ipvs_parse_stats(&(d->entrytable[i].stats),
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe lvs-devel=
" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at =A0http://vger.kernel.org/majordomo-info.htm=
l
