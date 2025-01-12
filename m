Received: from stravinsky.debian.org (stravinsky.debian.org [82.195.75.108])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4559F15575D
	for <lvs-devel@vger.kernel.org>; Sun, 12 Jan 2025 21:57:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=82.195.75.108
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1736719029; cv=none; b=afOTotv7ytTB3iqSY2GrHrbJTxHoKoViYZMzz9vIC8T0qMXUIH8Q3umJaZali7yaHQRiOhpdQXyKzyiG/eWeRniQ+f4tJWcgwZGZrsMPlbzwQJntqqskAMnEmdh0OMngU0J0LWSk7lyjIC0By0WPgmOCDSMSxJH/etf5T4ZEu0o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1736719029; c=relaxed/simple;
	bh=vINmR6zx8pL4StXUqnT7nVRAyAAHAK4pr5HM56m9neU=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=OJn1NdiwRrOdfIozPypopFi42pZ5OU1mOM+co9aEUncXuNeXFsgbfs0BQHr5jnni060DSWc2edA3AcFL22/K6qTJPz0RPQ7fd5SiYYAt+KM5kB31aYm/LZLEu5Cmtn6zwHttP41cunA2beECetuc2ePS5FTn2CmTfcUmueEVLFg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org; spf=none smtp.mailfrom=debian.org; dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b=VYHw2Xdz; arc=none smtp.client-ip=82.195.75.108
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=debian.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b="VYHw2Xdz"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=debian.org;
	s=smtpauto.stravinsky; h=X-Debian-User:In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=eY6sT0Ew/Puw/2TX+7jTtqU0oV+K4xbsTaqjMMq11yA=; b=VYHw2Xdzoi/MDNBK0WEchxFM1d
	WSly3n7jNlZwRI+i1itliIh7GEpboybEJ2PegyxqkSKnUHBOVG6TsCT+SNtQTLebS3lYcvKtd+lmi
	ce+Fs85xSYao2EVbeMG6+I0aEImZuBGUwKW4ySog6vlB+SV4txCVp+KyC8uTdWdPkC1UqmHupIPMj
	xPjProhr5RDqP3g4UbiMXRewgKs1gjgdzew68mMZ9ZV4raElOHDHqeSC42u4n1FnzzzXWCicxtRpl
	s+xvl3cdrWlcxjaSALR51XdfSgT1oP0hzOdxavAwkfuRzEWGhJ3oDrZP86wQ5e8Kub9DHUzNjfnaQ
	O1pOuKlA==;
Received: from authenticated user
	by stravinsky.debian.org with esmtpsa (TLS1.3:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256)
	(Exim 4.94.2)
	(envelope-from <azazel@debian.org>)
	id 1tX5x9-00HAad-RM; Sun, 12 Jan 2025 21:57:04 +0000
Received: from celephais.dreamlands.azazel.net ([2001:8b0:fb7d:d6d7:3c21:9cff:fe2f:35f] helo=celephais.dreamlands)
	by taras.nevrast.org with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.96)
	(envelope-from <azazel@debian.org>)
	id 1tX5x8-000Kfx-2K;
	Sun, 12 Jan 2025 21:57:02 +0000
Date: Sun, 12 Jan 2025 21:57:01 +0000
From: Jeremy Sowden <azazel@debian.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: LVS Devel <lvs-devel@vger.kernel.org>
Subject: Re: [PATCH ipvsadm 2/5] ipvsadm: fix ambiguous usage error message
Message-ID: <20250112215701.GA2068886@celephais.dreamlands>
References: <20250112200333.3180808-1-azazel@debian.org>
 <20250112200333.3180808-3-azazel@debian.org>
 <67c5c2f3-5a47-b636-96f5-f088019170d7@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="bYC5hqrX2waPVdqb"
Content-Disposition: inline
In-Reply-To: <67c5c2f3-5a47-b636-96f5-f088019170d7@ssi.bg>
X-SA-Exim-Connect-IP: 2001:8b0:fb7d:d6d7:3c21:9cff:fe2f:35f
X-SA-Exim-Mail-From: azazel@debian.org
X-SA-Exim-Scanned: No (on taras.nevrast.org); SAEximRunCond expanded to false
X-Debian-User: azazel


--bYC5hqrX2waPVdqb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2025-01-12, at 23:18:43 +0200, Julian Anastasov wrote:
> On Sun, 12 Jan 2025, Jeremy Sowden wrote:
> > If `-6` is used without `-f`, the usage error message is "-6 used befor=
e -f",
> > which can be misconstrued as warning that both options were used but in=
 the
> > wrong order.
> >=20
> > Change the option-parsing to allow `-6` to appear before `-f` and the e=
rror-
> > message in the case that `-6` was used without `-f`.
> >=20
> > Link: http://bugs.debian.org/610596
> > Signed-off-by: Jeremy Sowden <azazel@debian.org>
> > ---
> >  ipvsadm.c | 17 ++++++++++-------
> >  1 file changed, 10 insertions(+), 7 deletions(-)
> >=20
> > diff --git a/ipvsadm.c b/ipvsadm.c
> > index 42f31a20e596..889128017bd1 100644
> > --- a/ipvsadm.c
> > +++ b/ipvsadm.c
> > @@ -523,7 +523,7 @@ static int
> >  parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
> >  	      unsigned long long *options, unsigned int *format)
> >  {
> > -	int c, parse;
> > +	int c, parse, ipv6 =3D 0;
> >  	poptContext context;
> >  	char *optarg =3D NULL, sched_flags_arg[128];
> >  	struct poptOption options_table[] =3D {
> > @@ -829,12 +829,7 @@ parse_options(int argc, char **argv, struct ipvs_c=
ommand_entry *ce,
> >  			*format |=3D FMT_EXACT;
> >  			break;
> >  		case '6':
> > -			if (ce->svc.fwmark) {
> > -				ce->svc.af =3D AF_INET6;
> > -				ce->svc.netmask =3D 128;
> > -			} else {
> > -				fail(2, "-6 used before -f\n");
> > -			}
> > +			ipv6 =3D 1;
> >  			break;
> >  		case 'o':
> >  			set_option(options, OPTC_ONEPACKET);
> > @@ -935,6 +930,14 @@ parse_options(int argc, char **argv, struct ipvs_c=
ommand_entry *ce,
> >  		return -1;
> >  	}
> > =20
> > +	if (ipv6) {
> > +		if (ce->svc.fwmark) {
> > +			ce->svc.af =3D AF_INET6;
>=20
> 	As ce->svc.af is set later after all options are processed,
> the -M option will always see AF_INET in ce->svc.af ...
>=20
> > +			ce->svc.netmask =3D 128;
>=20
> 	Now we override the value from -M, so we can not do
> this here.

Ah, right.  Thanks.  The simplest thing, then, would be just to reword
the error message to something like:

	fail(2, "-6 must follow -f\n");

Will respin.

J.

--bYC5hqrX2waPVdqb
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

wsG7BAABCgBvBYJnhDqhCRAphqwKvfEEDUcUAAAAAAAeACBzYWx0QG5vdGF0aW9u
cy5zZXF1b2lhLXBncC5vcmedD+sr+WF5N5eqoSnqSNxExzxcRQ6W+tcWi2Ozxck0
JxYhBGwdtFNj70A3vVbVFymGrAq98QQNAABHjg/6Ajr4VHW07kh4ImecBHXhzl1G
Mby/mhuek3jpp0KEB6USpnmm3OPvnaQA6Rx9iX23fWUn9ms0L0u/XL/vTyF5eepN
km7RryObP6prsZFfUnLGhdjRlRKZ53/mvyOOg1eWdYUuQaBGYL1FWoaXitXHLnic
YoyvylQuF1LCKNuLpjqAt3cyHTOsjwbqkBstOxqaYq6hv5r8/b/088Wn5VHF/EJJ
vXpXranAT5Bx5R5tmdt7ILbIHQmWAk85wqX/BESihPj0ecPWUOF1F+JKj/GvrPvk
Zpkkc08PNDwbRf6Ys5ao5xOmWExod0RcgkEuMUGYhWkfvGYEEGyl0PdQu8+fF6QV
alGTHd1zvYZasTf+QsKQR0yljFMeop/ZZv0OEbbT2aycHneSaGtLgVKcqBxNHjLJ
JcgBS44h88KeDLu7I6Xmgsw1GTRjNlUnpwhr6QmhNrc+AZTYaVcqu+3IQMKAiUAE
VjFjwD3/g7hi6oHgtxylB7y4cBZsMSIibkRNrJQWhVjgs6Rnih2P0HJuBkRbeJ93
/wFSK2iXGXCclQxPV4LkYeu3yU0M9B2w+NXPLbahCUko6AheQjv1SvxrJPKP93hM
stHMOotUiZNI9ny6BTxiho0kvU4Y7S771DCut2V3xK7xElRAcOV1X+chtBcjYCtw
fA24DeE15aES2sdUlc8=
=ldEv
-----END PGP SIGNATURE-----

--bYC5hqrX2waPVdqb--
