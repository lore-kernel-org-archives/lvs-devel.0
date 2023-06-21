From: Joel Granados <j.granados@samsung.com>
Subject: Re: [PATCH 06/11] sysctl: Add size to register_net_sysctl function
Date: Wed, 21 Jun 2023 13:49:27 +0200
Message-ID: <20230621114927.woeidgxx5jhtchxt@localhost>
References: <20230621091000.424843-1-j.granados@samsung.com>
        <CGME20230621091022eucas1p1c097da50842b23e902e1a674e117e1aa@eucas1p1.samsung.com>
        <20230621091000.424843-7-j.granados@samsung.com>
        <dab06c20-f8b0-4e34-b885-f3537e442d54@kadam.mountain>
        <f95b7489-8654-435c-bc74-da1eac479fba@kadam.mountain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="xne6trb3st3pnm7t"
Return-path: <linux-hams-owner@vger.kernel.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout1.w1.samsung.com 20230621114930euoutp01007ea2375933ef64cd5e6966fc60621f~qqjiTWtbe2666626666euoutp017
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
        s=mail20170921; t=1687348170;
        bh=PzMFvtKImw0dyYUTQxJ85oPhNKqG7Ykb5TiTJxlLD3g=;
        h=Date:From:To:CC:Subject:In-Reply-To:References:From;
        b=gk+dh4W96w3bDafhN3F6jFGT6xHg1On7iXDg6B0+71afDjwkoxfY27aCQ/7ZeiTBH
         iahKK2uIJ+DLBiybih0z2KlK6SBqsdOaavCW3V3VHOFYqFOtUkHUaCvVcyOQOZcIjq
         vF2IY+axGL3C9MOa7pO2em8ceYC7jhMcJ2l8xAIU=
Content-Disposition: inline
In-Reply-To: <f95b7489-8654-435c-bc74-da1eac479fba@kadam.mountain>
List-ID: <lvs-devel.vger.kernel.org>
To: Dan Carpenter <dan.carpenter@linaro.org>
Cc: mcgrof@kernel.org, Jason Gunthorpe <jgg@ziepe.ca>, Leon Romanovsky <leon@kernel.org>, David Ahern <dsahern@kernel.org>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Joerg Reuter <jreuter@yaina.de>, Ralf Baechle <ralf@linux-mips.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, Roopa Prabhu <roopa@nvidia.com>, Nikolay Aleksandrov <razor@blackwall.org>, Alexander Aring <alex.aring@gmail.com>, Stefan Schmidt <stefan@datenfreihafen.org>, Miquel Raynal <miquel.raynal@bootlin.com>, Steffen Klassert <steffen.klassert@secunet.com>, Herbert Xu <herbert@gondor.apana.org.au>, Matthi

--xne6trb3st3pnm7t
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 21, 2023 at 01:49:54PM +0300, Dan Carpenter wrote:
> On Wed, Jun 21, 2023 at 12:47:30PM +0300, Dan Carpenter wrote:
> > The patchset doesn't include the actual interesting changes, just a
> > bunch of mechanical prep work.
> >=20
>=20
> I was wrong here, the patchset just hadn't all hit the mailing lists.
not even. It was that the patch got mangled by some error on my side.

> I can't apply this patchset to anything.  I tried linux-next, net, and
> net-next.  So it's hard to review.
All this applies cleanly to mcgrof's sysctl-next branch here
https://git.kernel.org/pub/scm/linux/kernel/git/mcgrof/linux.git/log/?h=3Ds=
ysctl-next

>=20
> It looks like ensure_safe_net_sysctl() never got update to use
> table_size...
Done. I realized this while checking out your other comments. thx.

>=20
> You could easily write a static checker test to print a warning any time
> that ->procname is checked for NULL.  I have attached a Smatch check.
> You would need to added to check_list.h and recompile.
Awesome!!!, I had been doing this with coccinelle, I'll recompile with
smatch and see if I get extra hits. Thx!
>=20
> net/sysctl_net.c:130 ensure_safe_net_sysctl() warn: checking ->procname '=
ent->procname'
Done. Will be available in V2

>=20
> regards,
> dan carpenter
>=20

Best
--=20

Joel Granados

--xne6trb3st3pnm7t
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQGzBAABCgAdFiEErkcJVyXmMSXOyyeQupfNUreWQU8FAmSS48UACgkQupfNUreW
QU8P6wv+JBI5ELQO0rQlbgdRdUTqyimzPcdhSxOT8QeXa/qKyYDEV+KhvzEMZap0
0yiZFvImIwiv6dp/2opPovNRg1qLPT6jIoadBpMtglkCwRcyEH9HCX77M+R75wnz
eGelorE8pyLVRRRfz0vIOe+cSOT3K3W6t+JeaaVpDKIUQk/5RNsirkOjC/499F+3
QphT45CRPGAdiVjtKnEmkiCYwBVu4w2WiZn6MgN8Poq8eS+g88bfq1X33HbbOrAE
+xgFe/74kvzkeOAQ25zYT1oQVslt4dkE7ypD3JY5TC7PaFIa4/bVSQ233awpvNgP
0gdYX5kqUjjS5kDE5Br2kToneRo8n4D8xO3Q/0uXjvqjonOmarRtfBXuxkIvfpTL
y4aAcmIcU4xLvQdYoETV+2vNqUfxaHzIlRukxzVIZNcRYU4FN2jUKjQv5fNf2frE
CGQ8KJwhsUjQVIkm5jyVdhxrw8AmWbzthNWUKJW82kxDAQ6AOJbZWb+C4HPQ+39P
70ZNs++G
=sqdF
-----END PGP SIGNATURE-----

--xne6trb3st3pnm7t--
