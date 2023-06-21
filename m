From: Joel Granados <j.granados@samsung.com>
Subject: Re: [PATCH 09/11] sysctl: Remove the end element in sysctl table
 arrays
Date: Wed, 21 Jun 2023 15:06:14 +0200
Message-ID: <20230621130614.s36w4u7dzmb5d5p3@localhost>
References: <20230621091000.424843-1-j.granados@samsung.com>
	<CGME20230621094824eucas1p2b6adfbd3f15ff3665674917f419b25d3@eucas1p2.samsung.com>
	<20230621094817.433842-1-j.granados@samsung.com> <87o7l92hg8.fsf@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="avrt2cz7yepdubk6"
Return-path: <bpf+bounces-3016-glkb-bpf=m.gmane-mx.org@vger.kernel.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout2.w1.samsung.com 20230621130618euoutp029d7307487d761f7bf2f8f6f0c9e5bc6d~qrmmZaJYP1283412834euoutp024
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
	s=mail20170921; t=1687352779;
	bh=tF4riIzozstFHcZHBtz5SQAzztgzSEi85C6+BMxI57A=;
	h=Date:From:To:CC:Subject:In-Reply-To:References:From;
	b=KizIn4h/+VubKpimOPqcdjHWTOSNrdxhq52NIdlcN6uvcXLAB6nFiyBh7t4SmSiCP
	 td604+vg7J45oRN7XVDY0MruktIM6Tfp+rbOoX3PpG3N0t8hckrvJWga2W8NV3jyeY
	 H1l5Lg0B87tZSR6VD/1dW5vkoQMqYyIu+p+NXDVs=
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:bpf+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:bpf+unsubscribe@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87o7l92hg8.fsf@intel.com>
To: Jani Nikula <jani.nikula@linux.intel.com>
Cc: mcgrof@kernel.org, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Gerald Schaefer <gerald.schaefer@linux.ibm.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, Russ Weight <russell.h.weight@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Phillip Potter <phil@philpotter.co.uk>, Clemens Ladisch <clemens@ladisch.de>, Arnd Bergmann <arnd@arndb.de>, Corey Minyard <minyard@acm.org>, Theodore Ts'o <tytso@mit.edu>, Ja

--avrt2cz7yepdubk6
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 21, 2023 at 02:16:55PM +0300, Jani Nikula wrote:
> On Wed, 21 Jun 2023, Joel Granados <j.granados@samsung.com> wrote:
> > Remove the empty end element from all the arrays that are passed to the
> > register sysctl calls. In some files this means reducing the explicit
> > array size by one. Also make sure that we are using the size in
> > ctl_table_header instead of evaluating the .procname element.
>=20
> Where's the harm in removing the end elements driver by driver? This is
> an unwieldy patch to handle.

I totally agree. Its a big one!!! but I'm concerned of breaking bisectibili=
ty:
* I could for example separate all the removes into separate commits and
  then have a final commit that removes the check for the empty element.
  But this will leave the tree in a state where the for loop will have
  undefined behavior when it looks for the empty end element. It might
  or might not work (probably not :) until the final commit where I fix
  that.

* I could also change the logic that looks for the final element,
  commit that first and then remove the empty element one commit per
  driver after that. But then for all the arrays that still have an
  empty element, there would again be undefined behavior as it would
  think that the last element is valid (when it is really the sentinel).

Any ideas on how to get around these?
>=20
> > diff --git a/drivers/gpu/drm/i915/i915_perf.c b/drivers/gpu/drm/i915/i9=
15_perf.c
> > index f43950219ffc..e4d7372afb10 100644
> > --- a/drivers/gpu/drm/i915/i915_perf.c
> > +++ b/drivers/gpu/drm/i915/i915_perf.c
> > @@ -4884,24 +4884,23 @@ int i915_perf_remove_config_ioctl(struct drm_de=
vice *dev, void *data,
> > =20
> >  static struct ctl_table oa_table[] =3D {
> >  	{
> > -	 .procname =3D "perf_stream_paranoid",
> > -	 .data =3D &i915_perf_stream_paranoid,
> > -	 .maxlen =3D sizeof(i915_perf_stream_paranoid),
> > -	 .mode =3D 0644,
> > -	 .proc_handler =3D proc_dointvec_minmax,
> > -	 .extra1 =3D SYSCTL_ZERO,
> > -	 .extra2 =3D SYSCTL_ONE,
> > -	 },
> > +		.procname =3D "perf_stream_paranoid",
> > +		.data =3D &i915_perf_stream_paranoid,
> > +		.maxlen =3D sizeof(i915_perf_stream_paranoid),
> > +		.mode =3D 0644,
> > +		.proc_handler =3D proc_dointvec_minmax,
> > +		.extra1 =3D SYSCTL_ZERO,
> > +		.extra2 =3D SYSCTL_ONE,
> > +	},
> >  	{
> > -	 .procname =3D "oa_max_sample_rate",
> > -	 .data =3D &i915_oa_max_sample_rate,
> > -	 .maxlen =3D sizeof(i915_oa_max_sample_rate),
> > -	 .mode =3D 0644,
> > -	 .proc_handler =3D proc_dointvec_minmax,
> > -	 .extra1 =3D SYSCTL_ZERO,
> > -	 .extra2 =3D &oa_sample_rate_hard_limit,
> > -	 },
> > -	{}
> > +		.procname =3D "oa_max_sample_rate",
> > +		.data =3D &i915_oa_max_sample_rate,
> > +		.maxlen =3D sizeof(i915_oa_max_sample_rate),
> > +		.mode =3D 0644,
> > +		.proc_handler =3D proc_dointvec_minmax,
> > +		.extra1 =3D SYSCTL_ZERO,
> > +		.extra2 =3D &oa_sample_rate_hard_limit,
> > +	}
> >  };
>=20
> The existing indentation is off, but fixing it doesn't really belong in
> this patch.

Agreed. But I actually was trying to fix something that checkpatch
flagged. I'll change these back (which will cause this patch to be
flagged).

An alternative solution would be to fix the indentation as part of the
preparation patches. Tell me what you think.

Thx

>=20
> BR,
> Jani.
>=20
>=20
> --=20
> Jani Nikula, Intel Open Source Graphics Center

--=20

Joel Granados

--avrt2cz7yepdubk6
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQGzBAABCgAdFiEErkcJVyXmMSXOyyeQupfNUreWQU8FAmSS9cQACgkQupfNUreW
QU/tWQv+LHqhRfLnActmTK06NicBnR3PUYRIMank4jSVG6jtvqu/VBMNmvKyRaeA
68kGzzIEbayPbBOL1M2GmrBgIaWp9OIWt4jKQeY4ARm9DcL2FWqUqLufGoPlwjX/
0GFjsIlBykddf6c3149Hf7D2Xz+hZyF8GgqMaIuty4hcNbIoeYs5zmwPaQmn+/q0
eoe07uBOs32ocQPIMJuRPMw6KSxHYOiWbNHxgQlIl7stObKOuvQXO2GLDgqHc13y
NKMTC6XNh4VAc7JHtrsEVEBiVro3IGh7cS5U5DK0jhlSLsRfJUkXmSO4H9EwGLBq
mWAl5Qr+YGnCrfE6jGc7uTM0etzscRGIlKIJ+7qcLgSfVgkqYeb5AmkZ8bvailD8
h66rr3XzwBKiQRaXpk6V7/IliqJcG7+N2yGsGJ3UXpvoF/1ieeb39kcSOFZ75BU5
USV/t5Fj0VqHetwv6dC5A8RLktlHNQZcTAXJkLL0QZ5xrmWC9kiIJ/EzJnCgJlSu
AwkfgT+P
=LLXc
-----END PGP SIGNATURE-----

--avrt2cz7yepdubk6--

