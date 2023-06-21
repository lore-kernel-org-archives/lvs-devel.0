From: Joel Granados <j.granados@samsung.com>
Subject: Re: [PATCH 09/11] sysctl: Remove the end
 element in sysctl table arrays
Date: Wed, 21 Jun 2023 15:43:48 +0200
Message-ID: <20230621134348.rcdzl7fi7yq2uj6h@localhost>
References: <20230621091000.424843-1-j.granados@samsung.com>
 <CGME20230621094824eucas1p2b6adfbd3f15ff3665674917f419b25d3@eucas1p2.samsung.com>
 <20230621094817.433842-1-j.granados@samsung.com> <87o7l92hg8.fsf@intel.com>
 <20230621130614.s36w4u7dzmb5d5p3@localhost> <878rcd2by5.fsf@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1903914140375033651=="
Return-path: <openipmi-developer-bounces@lists.sourceforge.net>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
 d=sourceforge.net; s=x; h=References:In-Reply-To:Content-Type:MIME-Version:
 Message-ID:Subject:CC:To:From:Date:Sender:Reply-To:Content-Transfer-Encoding:
 Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
 Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:List-Unsubscribe:
 List-Subscribe:List-Post:List-Owner:List-Archive;
 bh=SetH/myydi6dk+ldkx72EVQztsegim0VSf5FSMMJW28=; b=WblWLZiNAWpKf9FPCqwi5bMnBT
 /o68FUkhHUXrZDblDzHQswOXGhn9IQY2sYgUO1m3FDLFn5mhv8YusBhSVprXaCVE7buDIm7AU0j3x
 8VJEI1TAHaVhIgc+Xpq8BHP1g2J9Bpnlby1OF/G4YELH68VLLl/QLDO9C6sPyOKI5Q2w=;
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=sf.net; s=x
 ;
 h=References:In-Reply-To:Content-Type:MIME-Version:Message-ID:Subject:CC:To
 :From:Date:Sender:Reply-To:Content-Transfer-Encoding:Content-ID:
 Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
 :Resent-Message-ID:List-Id:List-Help:List-Unsubscribe:List-Subscribe:
 List-Post:List-Owner:List-Archive;
 bh=SetH/myydi6dk+ldkx72EVQztsegim0VSf5FSMMJW28=; b=haswjyJTMFtVPMTGayxuNW+x0O
 xDTi6ukfWWXJUPY5AFb2kuiGpf3hOrYTDNmUZyoWKdP1xaSTx2Yun96kMnsy/GwxQseezV4B4sfWS
 VVKiYjjIb5k5BNGGhKA3EUC6YlapuQG4rfj4EUrqXCZ9oy1ImOpHMIBa1wKC94mYvUts=;
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout2.w1.samsung.com
 20230621134353euoutp02d57583f1260e1c228507969bf2dd64df~qsHaHGgl22310523105euoutp02y
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
 s=mail20170921; t=1687355033;
 bh=SetH/myydi6dk+ldkx72EVQztsegim0VSf5FSMMJW28=;
 h=Date:From:To:CC:Subject:In-Reply-To:References:From;
 b=PTZBv1Kz5BEVObNa7leJ/yxGfQakTivesF5jb6tBj4a7mw0z2DwCV8KG/lz6Htp2A
 zjthU/P8T1sIWZ42nVHC5ArvGqiQK48scKj0Re/P/DwFQFC0M/FPQnfLTFYC/Ucswv
 L2oK3I/5AOGeZQ+wBCu+TIiCshDxA9TJNwfHFkfQ=
In-Reply-To: <878rcd2by5.fsf@intel.com>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/openipmi-developer>, 
 <mailto:openipmi-developer-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=openipmi-developer>
List-Post: <mailto:openipmi-developer@lists.sourceforge.net>
List-Help: <mailto:openipmi-developer-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/openipmi-developer>, 
 <mailto:openipmi-developer-request@lists.sourceforge.net?subject=subscribe>
Errors-To: openipmi-developer-bounces@lists.sourceforge.net
To: Jani Nikula <jani.nikula@linux.intel.com>
Cc: Juri Lelli <juri.lelli@redhat.com>, Miaohe Lin <linmiaohe@huawei.com>, "Rafael J. Wysocki" <rafael@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, dri-devel@lists.freedesktop.org, Ben Segall <bsegall@google.com>, linux-sctp@vger.kernel.org, ocfs2-devel@oss.oracle.com, Miquel Raynal <miquel.raynal@bootlin.com>, Alexander Gordeev <agordeev@linux.ibm.com>, "K. Y. Srinivasan" <kys@microsoft.com>, Stefan Schmidt <stefan@datenfreihafen.org>, Wei Liu <wei.liu@kernel.org>, Vincent Guittot <vincent.guittot@linaro.org>, Michael Ellerman <mpe@ellerman.id.au>, bridge@lists.linux-foundation.org, James Morris <jmorris@namei.org>, Christophe Leroy <christophe.leroy@csgroup.eu>, Jozsef Kadlecsik <kadlec@netfilter.org>, Eric Biggers <ebiggers@kernel.org>, linux-cachefs@redhat.com, Mel Gorman <mgorman@suse.de>, "Darrick J.
 Wong" <djwong@kernel.org>, Waiman Long <longman@redhat.co>

--===============1903914140375033651==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="nwcq3i6cyedok5cv"
Content-Disposition: inline

--nwcq3i6cyedok5cv
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 21, 2023 at 04:15:46PM +0300, Jani Nikula wrote:
> On Wed, 21 Jun 2023, Joel Granados <j.granados@samsung.com> wrote:
> > On Wed, Jun 21, 2023 at 02:16:55PM +0300, Jani Nikula wrote:
> >> On Wed, 21 Jun 2023, Joel Granados <j.granados@samsung.com> wrote:
> >> > Remove the empty end element from all the arrays that are passed to =
the
> >> > register sysctl calls. In some files this means reducing the explicit
> >> > array size by one. Also make sure that we are using the size in
> >> > ctl_table_header instead of evaluating the .procname element.
> >>=20
> >> Where's the harm in removing the end elements driver by driver? This is
> >> an unwieldy patch to handle.
> >
> > I totally agree. Its a big one!!! but I'm concerned of breaking bisecti=
bility:
> > * I could for example separate all the removes into separate commits and
> >   then have a final commit that removes the check for the empty element.
> >   But this will leave the tree in a state where the for loop will have
> >   undefined behavior when it looks for the empty end element. It might
> >   or might not work (probably not :) until the final commit where I fix
> >   that.
> >
> > * I could also change the logic that looks for the final element,
> >   commit that first and then remove the empty element one commit per
> >   driver after that. But then for all the arrays that still have an
> >   empty element, there would again be undefined behavior as it would
> >   think that the last element is valid (when it is really the sentinel).
> >
> > Any ideas on how to get around these?
>=20
> First add size to the register calls, and allow the last one to be
> sentinel but do not require the sentinel.
>=20
> Start removing sentinels, adjusting the size passed in.
This is a great idea! and I think I don't even have to adjust the size
because if I change the logic to stop on the sentinel or the size; so when
the sentinel is there, it will stop before the size. And when the
sentinel is not there, it will stop on the correct size.

There might be issues with indirection calls. And there might also be
lots of places where I need to adjust a for loop (as dan has pointed
out) but its worth a try for V2.

Best
>=20
> Once enough sentinels have been removed, add warning if the final entry
> is a sentinel.
>=20
> Never really remove the check? (But surely you can rework the logic to
> not count the number of elements up front, only while iterating.)
>=20
>=20
> BR,
> Jani.
>=20
> >>=20
> >> > diff --git a/drivers/gpu/drm/i915/i915_perf.c b/drivers/gpu/drm/i915=
/i915_perf.c
> >> > index f43950219ffc..e4d7372afb10 100644
> >> > --- a/drivers/gpu/drm/i915/i915_perf.c
> >> > +++ b/drivers/gpu/drm/i915/i915_perf.c
> >> > @@ -4884,24 +4884,23 @@ int i915_perf_remove_config_ioctl(struct drm=
_device *dev, void *data,
> >> > =20
> >> >  static struct ctl_table oa_table[] =3D {
> >> >  	{
> >> > -	 .procname =3D "perf_stream_paranoid",
> >> > -	 .data =3D &i915_perf_stream_paranoid,
> >> > -	 .maxlen =3D sizeof(i915_perf_stream_paranoid),
> >> > -	 .mode =3D 0644,
> >> > -	 .proc_handler =3D proc_dointvec_minmax,
> >> > -	 .extra1 =3D SYSCTL_ZERO,
> >> > -	 .extra2 =3D SYSCTL_ONE,
> >> > -	 },
> >> > +		.procname =3D "perf_stream_paranoid",
> >> > +		.data =3D &i915_perf_stream_paranoid,
> >> > +		.maxlen =3D sizeof(i915_perf_stream_paranoid),
> >> > +		.mode =3D 0644,
> >> > +		.proc_handler =3D proc_dointvec_minmax,
> >> > +		.extra1 =3D SYSCTL_ZERO,
> >> > +		.extra2 =3D SYSCTL_ONE,
> >> > +	},
> >> >  	{
> >> > -	 .procname =3D "oa_max_sample_rate",
> >> > -	 .data =3D &i915_oa_max_sample_rate,
> >> > -	 .maxlen =3D sizeof(i915_oa_max_sample_rate),
> >> > -	 .mode =3D 0644,
> >> > -	 .proc_handler =3D proc_dointvec_minmax,
> >> > -	 .extra1 =3D SYSCTL_ZERO,
> >> > -	 .extra2 =3D &oa_sample_rate_hard_limit,
> >> > -	 },
> >> > -	{}
> >> > +		.procname =3D "oa_max_sample_rate",
> >> > +		.data =3D &i915_oa_max_sample_rate,
> >> > +		.maxlen =3D sizeof(i915_oa_max_sample_rate),
> >> > +		.mode =3D 0644,
> >> > +		.proc_handler =3D proc_dointvec_minmax,
> >> > +		.extra1 =3D SYSCTL_ZERO,
> >> > +		.extra2 =3D &oa_sample_rate_hard_limit,
> >> > +	}
> >> >  };
> >>=20
> >> The existing indentation is off, but fixing it doesn't really belong in
> >> this patch.
> >
> > Agreed. But I actually was trying to fix something that checkpatch
> > flagged. I'll change these back (which will cause this patch to be
> > flagged).
> >
> > An alternative solution would be to fix the indentation as part of the
> > preparation patches. Tell me what you think.
> >
> > Thx
> >
> >>=20
> >> BR,
> >> Jani.
> >>=20
> >>=20
> >> --=20
> >> Jani Nikula, Intel Open Source Graphics Center
>=20
> --=20
> Jani Nikula, Intel Open Source Graphics Center

--=20

Joel Granados

--nwcq3i6cyedok5cv
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQGzBAABCgAdFiEErkcJVyXmMSXOyyeQupfNUreWQU8FAmSS/pIACgkQupfNUreW
QU8FZgv+NJjIGObr29DU3w9gC84AcnW6dJTp9wHS00NxSXpo+c714JQ2xV0z8i/m
wZbyBR21D/CkjJCTL0pwjCh1xi+PdMHmpB9mDlQSxEg6i+fJXBb7GvWvkOfNagP8
Z2t/NzP/RPP+/BjBP3QOGNyQWgZ4Jl6lMvzlt0aJlHMx7/QD7PRgnNN3KYiFzB+I
FTf5QLbTT85TSPPoGBQCzF6Ych5vKNmIzRZxD2o1zPJFftGIcYOfYOC7vX/1tuOa
1l2+maHSi22uTAHFL3XKvcQBxuLeBCoAIgYOGeO0B+wApLgDVUdHb3PPMw74sOuD
RtgKG6gEgO937g+zKo5xP6M5iLH8xYavJRYPNGH5FBfL7DDROXI6t9tjBpvpUbPS
VQDducT3r8p7hbIhb+3MnRgJri1yF7SjRZF6iewJ9G3Rd7o8PlcLC3aTZLvilO9j
4YYKID1bOqsI9tcLY5oeM6HROqdmLhzFQQlzZCCz4Y/1XVO7ZKpJHP97wqBETkbq
DRVhBHDj
=lxdq
-----END PGP SIGNATURE-----

--nwcq3i6cyedok5cv--


--===============1903914140375033651==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1903914140375033651==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Openipmi-developer mailing list
Openipmi-developer@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/openipmi-developer

--===============1903914140375033651==--

