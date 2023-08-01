From: Joel Granados <joel.granados@gmail.com>
Subject: Re: [PATCH v2 00/14] sysctl: Add a size argument to
 register functions in sysctl
Date: Tue, 1 Aug 2023 12:01:09 +0200
Message-ID: <20230801100109.ospf2gwsdewhhwzn@localhost>
References: <20230731071728.3493794-1-j.granados@samsung.com>
 <CGME20230731205134eucas1p1403a137418fcdaaaf78890de88d4a958@eucas1p1.samsung.com>
 <ZMgeoDT0t3NeALM0@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature"; boundary="g6vdqxyc5hdpujuz"
Return-path: <bridge-bounces@lists.linux-foundation.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp4.osuosl.org 652C0416CC
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp4.osuosl.org EEA8540888
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org 50AE7607F1
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org 523106076C
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20221208; t=1690884073; x=1691488873;
 h=in-reply-to:content-disposition:mime-version:references:message-id
 :subject:cc:to:from:date:from:to:cc:subject:date:message-id:reply-to;
 bh=e8Rmj6mejjDyMq10/c5ElVqxfT4Jc8y7fVBUerEHAFQ=;
 b=JYH38BiZyDWL0KXmQnng4sthQhdeV3NJBHfNi+ky1KBbpG9nVv/fbbULdTOLHrIkRc
 m+cW5Nuo1qJ+ZY/CEFkGrU+LjmOwtRZV5FZbO5P7+OM1zKnHgMDf1oBLHOA+NceI85gx
 JkZ47KaVpN9ZBvR6FoyVYB0FbHi8KbwxzoilvQtwUB2ij/UJya1TAMXC2C3UOm6p174z
 S6sbKiiIslls7win2DAPno+jCbJ72BXV6csVG9rjzIDvaWKjNZk+kKpKl91dwFSz63UN
 EHa/G4niaq852Xz2iz+Bde3Ap6qEvx6ZrdIxP94qmNM5EajZm2Xvu5/MSgK9i/6QI6uE
 Ds1A==
Content-Disposition: inline
In-Reply-To: <ZMgeoDT0t3NeALM0@bombadil.infradead.org>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>, 
 <mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
 <mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Errors-To: bridge-bounces@lists.linux-foundation.org
Sender: "Bridge" <bridge-bounces@lists.linux-foundation.org>
To: Luis Chamberlain <mcgrof@kernel.org>
Cc: Wen Gu <guwen@linux.alibaba.com>, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Pablo Neira Ayuso <pablo@netfilter.org>, Catalin Marinas <catalin.marinas@arm.com>, Nikolay Aleksandrov <razor@blackwall.org>, Alexander Aring <alex.aring@gmail.com>, linux-sctp@vger.kernel.org, Miquel Raynal <miquel.raynal@bootlin.com>, Jan Karcher <jaka@linux.ibm.com>, Mat Martineau <martineau@kernel.org>, Will Deacon <will@kernel.org>, Alexander Gordeev <agordeev@linux.ibm.com>, Stefan Schmidt <stefan@datenfreihafen.org>, Steffen Klassert <steffen.klassert@secunet.com>, linux-s390@vger.kernel.org, rds-devel@oss.oracle.com, Xin Long <lucien.xin@gmail.com>, Herbert Xu <herbert@gondor.apana.org.au>, linux-rdma@vger.kernel.org, Tony Lu <tonylu@linux.alibaba.com>, bridge@lists.linux-foundation.org, willy@infradead.org, Jozsef Kadlecsik <kadlec@netfilter.org>, lvs-devel@vger.kernel.org


--g6vdqxyc5hdpujuz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 31, 2023 at 01:50:40PM -0700, Luis Chamberlain wrote:
> On Mon, Jul 31, 2023 at 09:17:14AM +0200, Joel Granados wrote:
> > Why?
>=20
> It would be easier to read if the what went before the why.
haha. I totally misunderstood you in
lore.kernel.org/all/ZMFizKFkVxUFtSqa@bombadil.infradead.org I thought
you meant to put the why first. I'll switch it back to having the what
first for V3

>=20
> > This is a preparation patch set that will make it easier for us to apply
> > subsequent patches that will remove the sentinel element (last empty el=
ement)
> > in the ctl_table arrays.
> >=20
> > In itself, it does not remove any sentinels but it is needed to bring a=
ll the
> > advantages of the removal to fruition which is to help reduce the overa=
ll build
> > time size of the kernel and run time memory bloat by about ~64 bytes per
> > sentinel.
>=20
> s/sentinel/declared ctl array
>=20
> Because the you're suggesting we want to remove the sentinel but we
> want to help the patch reviewer know that a sentil is required per
> declared ctl array.
Ack

>=20
> You can also mention here briefly that this helps ensure that future move=
s of
> sysctl arrays out from kernel/sysctl.c to their own subsystem won't
> penalize in enlarging the kernel build size or run time memory consumptio=
n.
I worked it in

Thx for the review
>=20
> Thanks for spinning this up again!
>=20
>   Luis

--=20

Joel Granados

--g6vdqxyc5hdpujuz
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQGzBAABCgAdFiEErkcJVyXmMSXOyyeQupfNUreWQU8FAmTI1+QACgkQupfNUreW
QU/tvQv8DSOiRBrGHskMVKuasQMrQO4cj/zOagQExBMcJnGj7M+jr4pvCvBo1Rce
fRZBBVfKDjeV4svmqKus54sNM27JPAJALJlnePPgsBqhuOeL6kKLSsCDyDv6bKOS
e0J6ZLE6EAqudCJqsxjGkPNEalpooX1Ip9OQqdPQxyfoSdDZQcKucP/rPx+Q4yzy
lKv9SqcK/1j7q8fMkiucrjwQF2woB16q6iXZmokZTt7vTX0rSfKFJ8isQOgimpll
Xv+hxQaRZEueIIc45dAL7MRYn/zukf8rExbIRNXCtUCsyfJxcdo6V0ubKfMAj/u3
X2J5FIUpf1ua/QX0idONlXIXU1kOWnFapnBPprKBKuBhO6xwSnrQhxgt7aKbbDGl
dBwWRbN59m3q7jrz17McOb+LjfA5ZMcs3K58bfg0PnrugQZA537GFL19es1dAssc
fy06XeNWXeUhvCjgQW53D2twqvhAhY4WU1D4sbV+8xwQihB416Zkc+ReqQs2cS6Y
zhTPrhl+
=F1x8
-----END PGP SIGNATURE-----

--g6vdqxyc5hdpujuz--
