From: Joel Granados <joel.granados@gmail.com>
Subject: Re: [PATCH v2 03/14] sysctl: Add ctl_table_size to
	ctl_table_header
Date: Tue, 1 Aug 2023 12:03:15 +0200
Message-ID: <20230801100315.ymcahsxu6qpw7kct@localhost>
References: <20230731071728.3493794-1-j.granados@samsung.com>
 <20230731071728.3493794-4-j.granados@samsung.com>
 <ZMf9vZpGE98oM9W2@kernel.org>
 <CGME20230731190724eucas1p14cc08261cd20815797958bbebc0fafe7@eucas1p1.samsung.com>
 <ZMgGWm4sT+VqDZ3u@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature"; boundary="d62tnfuywe5q6aej"
Return-path: <bridge-bounces@lists.linux-foundation.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org AC5E860FF0
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org 6CD2460D52
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp2.osuosl.org 5666C4052C
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp2.osuosl.org E47A340914
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20221208; t=1690884198; x=1691488998;
 h=in-reply-to:content-disposition:mime-version:references:message-id
 :subject:cc:to:from:date:from:to:cc:subject:date:message-id:reply-to;
 bh=6xzFd6kXeaygrI5Ej8/AL8nxngfv7zWbrLM3nGa6LwE=;
 b=eXsvFh6BK+B4iuEJYMTnBcTL7rHnOTSND3P9MAnpkjJqEpLCdcVuq/3LHC8WhWxlOi
 AYVHc0UleUBBoRaduveJnpBbMfklz/v7bfVQyhDeoiCpwWcDLTvnVdKzWsATvnXRFrIQ
 4sxETc63wfFaT1bcwPenmbK5Cd68zjDF7/mwm/QlGSxaYKSqfPBfKA0mGUHtfQgxDKuN
 bfckck3WXSVwZdpmMoaLqOAU0MAofGr+AO2UcfWw2DAsMdq42RxNJsTnAee8Lvikj6hM
 UobnKUJtXdI2bFxeUV6lKnu0txtKROjJB89U3UM49XZz3hMCMQfPajpd2YztNuqg5bYr
 w4qQ==
Content-Disposition: inline
In-Reply-To: <ZMgGWm4sT+VqDZ3u@kernel.org>
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
To: Simon Horman <horms@kernel.org>
Cc: Wen Gu <guwen@linux.alibaba.com>, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Pablo Neira Ayuso <pablo@netfilter.org>, Catalin Marinas <catalin.marinas@arm.com>, Nikolay Aleksandrov <razor@blackwall.org>, Alexander Aring <alex.aring@gmail.com>, linux-sctp@vger.kernel.org, Miquel Raynal <miquel.raynal@bootlin.com>, Jan Karcher <jaka@linux.ibm.com>, Mat Martineau <martineau@kernel.org>, Will Deacon <will@kernel.org>, Alexander Gordeev <agordeev@linux.ibm.com>, Stefan Schmidt <stefan@datenfreihafen.org>, Steffen Klassert <steffen.klassert@secunet.com>, linux-s390@vger.kernel.org, rds-devel@oss.oracle.com, Xin Long <lucien.xin@gmail.com>, Herbert Xu <herbert@gondor.apana.org.au>, linux-rdma@vger.kernel.org, Tony Lu <tonylu@linux.alibaba.com>, bridge@lists.linux-foundation.org, willy@infradead.org, Jozsef Kadlecsik <kadlec@netfilter.org>, lvs-devel@vger.kernel.org


--d62tnfuywe5q6aej
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 31, 2023 at 09:07:06PM +0200, Simon Horman wrote:
> On Mon, Jul 31, 2023 at 08:30:34PM +0200, Simon Horman wrote:
> > On Mon, Jul 31, 2023 at 09:17:17AM +0200, Joel Granados wrote:
> > > The new ctl_table_size element will hold the size of the ctl_table
> > > arrays contained in the ctl_table_header. This value should eventually
> > > be passed by the callers to the sysctl register infrastructure. And
> > > while this commit introduces the variable, it does not set nor use it
> > > because that requires case by case considerations for each caller.
> > >=20
> > > It provides two important things: (1) A place to put the
> > > result of the ctl_table array calculation when it gets introduced for
> > > each caller. And (2) the size that will be used as the additional
> > > stopping criteria in the list_for_each_table_entry macro (to be added
> > > when all the callers are migrated)
> > >=20
> > > Signed-off-by: Joel Granados <j.granados@samsung.com>
> > > ---
> > >  include/linux/sysctl.h | 14 ++++++++++++--
> > >  1 file changed, 12 insertions(+), 2 deletions(-)
> > >=20
> > > diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> > > index 59d451f455bf..33252ad58ebe 100644
> > > --- a/include/linux/sysctl.h
> > > +++ b/include/linux/sysctl.h
> > > @@ -159,12 +159,22 @@ struct ctl_node {
> > >  	struct ctl_table_header *header;
> > >  };
> > > =20
> > > -/* struct ctl_table_header is used to maintain dynamic lists of
> > > -   struct ctl_table trees. */
> > > +/**
> > > + * struct ctl_table_header - maintains dynamic lists of struct ctl_t=
able trees
> > > + * @ctl_table: pointer to the first element in ctl_table array
> > > + * @ctl_table_size: number of elements pointed by @ctl_table
> > > + * @used: The entry will never be touched when equal to 0.
> > > + * @count: Upped every time something is added to @inodes and downed=
 every time
> > > + *         something is removed from inodes
> > > + * @nreg: When nreg drops to 0 the ctl_table_header will be unregist=
ered.
> > > + * @rcu: Delays the freeing of the inode. Introduced with "unfuck pr=
oc_sysctl ->d_compare()"
> > > + *
> > > + */
> >=20
> > Hi Joel,
> >=20
> > Please consider also adding kernel doc entries for the other fields of
> > struct ctl_table_header. According to ./scripts/kernel-doc -none
> > they are:
> >=20
> >   unregistering
> >   ctl_table_arg
> >   root
> >   set
> >   parent
> >   node
> >   inodes
>=20
> Sorry, I now realise that I made the same comment on v1.
> And I didn't see your response to that until after I wrote the above.
np. I'll hold off adding this to the set until I get feedback from my
proposal. I do this as I'm unsure about the contents of the docs.


>=20
> >=20
> >=20
> > >  struct ctl_table_header {
> > >  	union {
> > >  		struct {
> > >  			struct ctl_table *ctl_table;
> > > +			int ctl_table_size;
> > >  			int used;
> > >  			int count;
> > >  			int nreg;
> > > --=20
> > > 2.30.2
> > >=20

--=20

Joel Granados

--d62tnfuywe5q6aej
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQGzBAABCgAdFiEErkcJVyXmMSXOyyeQupfNUreWQU8FAmTI2GIACgkQupfNUreW
QU/jnAv/XiexP2W1Y950obHBDBGWwb2QRwk7qg172MXMjFQl6+imM/lk9f2BbUyv
yHqtlJQeHzRDFmaanGI2f0Cd5i7XkupsNoINecjz4w7t3g4pgPxjYO+KRGJoQxRx
zfGIkM/UKYfW53TJRg0P0b9t7XnQ+yew+ZAEULLKb23ElXZ+hFXMtH8K938NEqxz
ETsCG4rlGIO3QMm0epmk4EaMr34faYtf8fzaY6T3PshcTq+vklW7M/gHjcMkICK5
GZM7Ijb2sU5Xd4d8hkoSpPh8TErgjuNVU2LpzlzjyC25WFM0xpPnKRDB5ENGa4m4
ZWu67LrebJoLjoE0vJUMMfZu9PCmvQp4Wijuc/ImQA4BA8hNwsarFhYlFMPp3Ixn
AC51TcUplS956Laxzjd51ql75jba5ul88ZGiqnkNL+IXKOjceJSKM68lVQELv1Lq
m9Il+S1C7xVBNvDQo9yE5jA7mdju9NyxvL2UXr4sZU7Gmp8qiY5Zw4H6T6dSQy8H
ELxemNee
=dUoN
-----END PGP SIGNATURE-----

--d62tnfuywe5q6aej--
