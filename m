From: Joel Granados <j.granados@samsung.com>
Subject: Re: [PATCH v2 00/14] sysctl: Add a size argument to register
 functions in sysctl
Date: Tue, 8 Aug 2023 15:59:53 +0200
Message-ID: <20230808135953.l2y6gj7j272434fw@localhost>
References: <20230731071728.3493794-1-j.granados@samsung.com>
        <ZMgpck0rjqHR74sl@bombadil.infradead.org>
        <ZNFlqwwvE6w6HyHl@bombadil.infradead.org>
        <CANnsUMG3WO_19GpnsNaXPqu6eEnpBvYUpkrf1QbHwsc9wEoCZQ@mail.gmail.com>
        <ZNGBrkP7J2g/BAWV@bombadil.infradead.org>
        <CANnsUMGRBnatKB4-3eYjb5aG7YnXDiZG6cjuwSgtjvVF6ErJNg@mail.gmail.com>
        <ZNGv3Q5VBsS2/w4e@bombadil.infradead.org>
        <CGME20230808030739eucas1p2192f620771cb9655afdbcd624775b4c8@eucas1p2.samsung.com>
        <CANnsUMGHnurbph9F7mex=1s0mxhwpNgeQbKJ6j1r37Qmd6LAMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="h3c25ibwzmlgmjj3"
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout1.w1.samsung.com 20230809071323euoutp015d2b996c65b2b9125c2fa606849b0eb7~5pZb-us8e0911009110euoutp01F
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
        s=mail20170921; t=1691565203;
        bh=pd0rkBBl239hWUg1rHcfh8BtHyeO6HyV2u6nDFSCWm0=;
        h=Date:From:To:CC:Subject:In-Reply-To:References:From;
        b=XJ3SeBQkhJ7ZaOnSLxtM3BytZFFQVnU3UGIPJpukUn8AgLqEqNqS+MstyY5OdroTM
         GdbqsR2lXlr3UHMyvKPDA5ajb5C5q9GmO7KzPcM796hL5FqKq2HOoxqmLBBjhJqVjQ
         Hs5UChvxttSTzpTOYv5BpP1svXsa/HlFU8gSljBw=
Content-Disposition: inline
In-Reply-To: <CANnsUMGHnurbph9F7mex=1s0mxhwpNgeQbKJ6j1r37Qmd6LAMQ@mail.gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
To: Chris Maness <christopher.maness@gmail.com>
Cc: Luis Chamberlain <mcgrof@kernel.org>, Alexander Aring <alex.aring@gmail.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, "D. Wythe" <alibuda@linux.alibaba.com>, David Ahern <dsahern@kernel.org>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Florian Westphal <fw@strlen.de>, Heiko Carstens <hca@linux.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Iurii Zaikin <yzaikin@google.com>, Jakub Kicinski <kuba@kernel.org>, Jan Karcher <jaka@linux.ibm.com>, Joerg Reuter <jreuter@yaina.de>, Jozsef Kadlecsik <kadlec@netfilter.org>, Julian Anastasov <ja@ssi.bg>, Karsten Graul <kgraul@linux.ibm.com>, Kees Cook <keescook@c>

--h3c25ibwzmlgmjj3
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 07, 2023 at 08:07:24PM -0700, Chris Maness wrote:
> >
> > Are you reporting a separate regression that goes all the way back to v=
4 kernels?
> >
>=20
> I am not certain what you mean by regression.
>=20
> > > v2 is fine there.
> >
> > What does this mean?
>=20
> I have to go all the way back to kernel version 2 for the serial 6PACK
> driver to work.  If I try to use it in Kernel version 4, 5, or 6 the
> kernel panics as soon as I attempt to connect to another station.
Again. Have you reached out to Andreas Koensgen
<ajk@comnets.uni-bremen.de>? Maybe he has more info on this.

Best

>=20
> >
> >   Luis
>=20
> Chris KQ6UP
>=20
>=20
> --=20
> Thanks,
> Chris Maness

--=20

Joel Granados

--h3c25ibwzmlgmjj3
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQGzBAABCgAdFiEErkcJVyXmMSXOyyeQupfNUreWQU8FAmTSSlkACgkQupfNUreW
QU8zQQv/csq4fZgijsNRirYRY4BuHiERw8G3UuPFIPemEFB+C72FHbLDK66oqfKN
8AvTZLmXSA90J1kikzqAhrHgXqDgl4lOVwf6XZ+n2rBYuPlay1XSyC3/RlBrDOiS
cmddkmwrrbZpE3aW7uXV5H5eLFmnLds5C5I6Ui9bEbnJthaJGXCXTbwUXpFFh8B/
EMsFVsOG+Ek2KycdHGtsm6Lcrst2N0+cSWLSu35IXZEi2jB22fhn2PEF0kvtrL4X
bCQVgIPuWI4Q7PtdmMG4ewdSZFbVnbg+42EFMTGjdjOu7DkrTFMwl93/febfP84X
oUz7KjNP/ez3A54qqcjN1YgUIQKJLhO95BZTl9ZI1eqcrsg0HuxUGd6cpWxOT1ZD
xiJNJUhscRd1xE592veXF6+aXotpJvyEWWb39/bf1HAE0Kjr2DljSslkr8lsjQEh
4wP3OB5LIp/YVT6urTAiHoL+vJGA3TWIMfLwSWTmvu6ePiLpFZwEpmcBQNnGzm67
jHdxey6Y
=slPS
-----END PGP SIGNATURE-----

--h3c25ibwzmlgmjj3--
