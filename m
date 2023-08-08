From: Joel Granados <j.granados@samsung.com>
Subject: Re: [PATCH v2 00/14] sysctl: Add a size argument to register
 functions in sysctl
Date: Tue, 8 Aug 2023 15:58:47 +0200
Message-ID: <20230808135847.46ln434mbpiiklvz@localhost>
References: <20230731071728.3493794-1-j.granados@samsung.com>
        <ZMgpck0rjqHR74sl@bombadil.infradead.org>
        <ZNFlqwwvE6w6HyHl@bombadil.infradead.org>
        <CANnsUMG3WO_19GpnsNaXPqu6eEnpBvYUpkrf1QbHwsc9wEoCZQ@mail.gmail.com>
        <ZNGBrkP7J2g/BAWV@bombadil.infradead.org>
        <CGME20230808025059eucas1p24caeb224edb8f4fce693364913a37841@eucas1p2.samsung.com>
        <CANnsUMGRBnatKB4-3eYjb5aG7YnXDiZG6cjuwSgtjvVF6ErJNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="x4zdqo2w6ogqmllb"
Return-path: <linux-hams-owner@vger.kernel.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout1.w1.samsung.com 20230809071321euoutp01daffd5f6a01edf39fc36d5af9cc9ab2d~5pZa-JLBS0907609076euoutp01F
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
        s=mail20170921; t=1691565202;
        bh=V7AXA3XKbCTJdCLCEcFa9yONVo03/VAYcmjCmAIVm/0=;
        h=Date:From:To:CC:Subject:In-Reply-To:References:From;
        b=PbTANdOUFchwh/zQnW95iisuOL+LirFf8CuGNyW/Oa7KXicswQbaSCFd0qWjoU5sm
         TwaZARytYxnAfU11yAZNn/ZXPrBy/vqVu84xMjebQSH0XOYXEuG/Zh0hyMdQcUrAaU
         jrG4mDGWwLdWv3/TIZjPL8jtNkNRvz2u9E9bbhkg=
Content-Disposition: inline
In-Reply-To: <CANnsUMGRBnatKB4-3eYjb5aG7YnXDiZG6cjuwSgtjvVF6ErJNg@mail.gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
To: Chris Maness <christopher.maness@gmail.com>
Cc: Luis Chamberlain <mcgrof@kernel.org>, Alexander Aring <alex.aring@gmail.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, "D. Wythe" <alibuda@linux.alibaba.com>, David Ahern <dsahern@kernel.org>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Florian Westphal <fw@strlen.de>, Heiko Carstens <hca@linux.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Iurii Zaikin <yzaikin@google.com>, Jakub Kicinski <kuba@kernel.org>, Jan Karcher <jaka@linux.ibm.com>, Joerg Reuter <jreuter@yaina.de>, Jozsef Kadlecsik <kadlec@netfilter.org>, Julian Anastasov <ja@ssi.bg>, Karsten Graul <kgraul@linux.ibm.com>, Kees Cook <keescook@c>

--x4zdqo2w6ogqmllb
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hey Chris

My questions inline
On Mon, Aug 07, 2023 at 07:50:44PM -0700, Chris Maness wrote:
> I tried running the current mainline kernel (current Arch Linux) with
What kernel version are we talking about exactly here? Please notice the
base that I used in the cover letter (rc2 or rc3). They should also
rebase cleanly on top of v6.5-rc5.

I'm not sure what the patches will do if you apply them to an older
kernel.

> simple single MUX socket (ax0) using LinFBB.  I was a happy camper as
> it seemed to work fine at first, then the system just slowed to a
> crawl.  I am wondering if any of these patches are addressing this
> behavior.  No kernel panic like before, but not what I was hoping for.
So you have been experiencing kernel panics from before? What does
before mean? And can you bisect to pinpoint what commit fixed it?

> I have also tried sixpack, and that explodes instantly the last time I
> have checked.   That goes all the way back to the v4 kernels.  v2 is
> fine there.
You mean that 6pack is broken in all the major versions up until v2? If
this is the case, then it might be an issue that is not related to this
patchset.I see that Andreas Koensgen <ajk@comnets.uni-bremen.de> is the
maintainer of 6pack, maybe he can chime in on the issue?

>=20
> 73 de Chris KQ6UP
>=20
> On Mon, Aug 7, 2023 at 4:43=E2=80=AFPM Luis Chamberlain <mcgrof@kernel.or=
g> wrote:
> >
> > On Mon, Aug 07, 2023 at 04:00:49PM -0700, Chris Maness wrote:
> > > When are these likely to hit the mainline release code?
> >
> > linux-next tomorrow. The first 7 patches are scheduled for mainline
> > as they were merged + tested without any hiccups. These last few patches
> > I'll wait and see. If nothing blows up on linux-next perhaps I'll
> > include them to Linux for mainline during the next merge window.
> >
> >   Luis
>=20
>=20
>=20
> --=20
> Thanks,
> Chris Maness

--=20

Joel Granados

--x4zdqo2w6ogqmllb
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQGzBAABCgAdFiEErkcJVyXmMSXOyyeQupfNUreWQU8FAmTSShUACgkQupfNUreW
QU9V5Qv9EPEpi2TR8AnLqIPU7OhWjIi17BiRDGt3v4ld7gPtc9IDscWkSVOlkMHp
CJsDbzP6uifAXxWYA/eqroOI7XNJn4YT96BVArmjzPBNAtMyqIyKQtqWvtlmLxnQ
1XsF8kk8rkIguKbfvLeU26KBKXpy4ET8XODODPl1jVqo+/ztgRB85ZujCqeqwLah
Qk249z8JImXEI4zYMoh7TPqKNSWFCkWoyRsVc+nlDPoPvl82b0pDATR5N5j4uU9+
QB1sNVZkgWXqu7Z+Pfmy7UgtSd5AO9juaaCpVdROh6FXtrP1xxnIS4qdL71H4n57
hpLxWSjLlm4S24sfl46pbCAfGU5iWM1QSe0nMquMfG+SR0uLyuDs3FvHsEeXzATE
KzjhrFGiEXkBUtJW4L/rKGMa2vJBs6TWEuA9tlWvJF7U6E6WapKJNI8TrZjt1DlX
TeV+PipASlYIhVb2o+ZRbbSJIVkr88vGBEBlsn8LOODSL/BACgWfhvrwmVDFqf8m
LXyRMUq6
=mpca
-----END PGP SIGNATURE-----

--x4zdqo2w6ogqmllb--
