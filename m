Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C38E619E839;
	Mon, 27 Jul 2026 12:12:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785154377; cv=none; b=tJP4sgEJ54f1+s4OjJZ4OE5DvA/mclt0nTcmFR2ksL93euUYPv9KQTuTUEmT9vqAZgfvSIBe6ghUesPa1tZ8gb/C7num4xHneymoqIFWBPW18M1QpqLt3KzmhA15C4TfEGRr2jbaUeCKOqIxUbM5CJrxfLCut8k6o377HWTbOB8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785154377; c=relaxed/simple;
	bh=sotcfwjK3nAZniHL7JHKW15PRk/FoJrztaMoXgSNYfY=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=ZmVRKsHCVs1Z7hF1gAfmoNfQIhsnWD0M2Jv4P4rgo6lrrCsK+fHbLcu0lCCrGvQW1SBT3ePTtAvrSFaLWqzheRS+pbEXz6bSH7fJQBb/M8dAet8dBvlL+zfUT5nARIHFx05WYBm5l0QrRk5WWApPjrXr75DjrJpXP7PbiBQNh6c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=cJUiNzz1; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="cJUiNzz1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0753E1F000E9;
	Mon, 27 Jul 2026 12:12:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785154376;
	bh=NuMpyXi203gMNqb11rcfOKZmtmuJN0EPDdTrfGAbmqA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=cJUiNzz1prDmu0GWRwCZ182TsRp83BQvTp0/rURfnkMQzP20L6fG8sazv0cYKgUtW
	 pg9MCuVlTFHqe3x/O6EVkylNOZs7wcPPsZhmCr3XEWEcOo26weH2DM61fSqQ+OmbrP
	 tvyWB2eboDXUxX9deZuSx028Hbg9foCFt8d+5Bw+IlFteVi3skzllTVeGL1XafPYbe
	 08wppeqNa8S6eH5zJPQgihAdalyGQJliwPyAS5P+AP5v8yaQxZyfcN5KNznMD5HYbU
	 HA3HDDWzzh9ixbV9ramHSWGxONVFCvMxk3yVAI+jirrpd4gfEm0DA5Mx/fNCvUjATc
	 xHtThaOzcAK8w==
Date: Mon, 27 Jul 2026 13:12:37 +0100
From: Mark Brown <broonie@kernel.org>
To: Sang-Heon Jeon <ekffu200098@gmail.com>
Cc: Julia.Lawall@inria.fr, Alex Deucher <alexander.deucher@amd.com>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Alexandre Belloni <alexandre.belloni@bootlin.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Andrew Morton <akpm@linux-foundation.org>,
	Arkadiusz Kubalewski <arkadiusz.kubalewski@intel.com>,
	Borislav Petkov <bp@alien8.de>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Daniel Lezcano <daniel.lezcano@kernel.org>,
	David Airlie <airlied@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Eric Dumazet <edumazet@google.com>, Florian Westphal <fw@strlen.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Hans de Goede <hansg@kernel.org>,
	Hans Verkuil <hverkuil@kernel.org>,
	Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@linux.intel.com>,
	Jakub Kicinski <kuba@kernel.org>,
	"James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Jaroslav Kysela <perex@perex.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
	Jiri Pirko <jiri@resnulli.us>,
	"Joerg Roedel (AMD)" <joro@8bytes.org>,
	Johan Hovold <johan@kernel.org>,
	Jonathan Cameron <jic23@kernel.org>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Julian Anastasov <ja@ssi.bg>, Leon Romanovsky <leon@kernel.org>,
	Liam Girdwood <lgirdwood@gmail.com>,
	Linus Walleij <linusw@kernel.org>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	"Martin K. Petersen" <martin.petersen@oracle.com>,
	Matthew Sakai <msakai@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Maxime Ripard <mripard@kernel.org>,
	Michael Turquette <mturquette@baylibre.com>,
	Mike Rapoport <rppt@kernel.org>,
	Miri Korenblit <miriam.rachel.korenblit@intel.com>,
	Nicolas Palix <nicolas.palix@imag.fr>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Paolo Abeni <pabeni@redhat.com>, Ping-Ke Shih <pkshih@realtek.com>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Sebastian Reichel <sre@kernel.org>, Shuah Khan <shuah@kernel.org>,
	Simona Vetter <simona@ffwll.ch>, Simon Horman <horms@verge.net.au>,
	Stephen Boyd <sboyd@kernel.org>, Steve French <sfrench@samba.org>,
	Takashi Iwai <tiwai@suse.com>, Thomas Renninger <trenn@suse.com>,
	Thomas Zimmermann <tzimmermann@suse.de>,
	Tony Luck <tony.luck@intel.com>,
	Tvrtko Ursulin <tursulin@ursulin.net>,
	Vadim Fedorenko <vadim.fedorenko@linux.dev>,
	Vinod Koul <vkoul@kernel.org>, Will Deacon <will@kernel.org>,
	Yazen Ghannam <Yazen.Ghannam@amd.com>, cocci@inria.fr,
	amd-gfx@lists.freedesktop.org, dmaengine@vger.kernel.org,
	dm-devel@lists.linux.dev, dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org, intel-wired-lan@lists.osuosl.org,
	iommu@lists.linux.dev, linux-cifs@vger.kernel.org,
	linux-clk@vger.kernel.org, linux-crypto@vger.kernel.org,
	linux-edac@vger.kernel.org, linux-gpio@vger.kernel.org,
	linux-iio@vger.kernel.org, linux-input@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
	linux-mm@kvack.org, linux-pm@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-rtc@vger.kernel.org,
	linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-sound@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-wireless@vger.kernel.org, lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	nouveau@lists.freedesktop.org, platform-driver-x86@vger.kernel.org
Subject: Re: [PATCH 00/36] treewide: remove conditional returns with no effect
Message-ID: <adcfc6f2-3309-4496-8331-1ae31e85d363@sirena.org.uk>
References: <20260723184538.3888637-1-ekffu200098@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="2ViMWcNJN7tv3iXJ"
Content-Disposition: inline
In-Reply-To: <20260723184538.3888637-1-ekffu200098@gmail.com>
X-Cookie: It's OKAY -- I'm an INTELLECTUAL, too.


--2ViMWcNJN7tv3iXJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Jul 24, 2026 at 03:45:02AM +0900, Sang-Heon Jeon wrote:

> All patches are independent and can be applied separately, but for
> everyone's convenience, it would be nice if they were merged through
> a single tree.

Please don't do this, it does not make anything more convenient - it
results in huge CC lists and makes it more difficult to work out who
will actually apply things.  If there's no dependencies just send to
each subsystem independently.

--2ViMWcNJN7tv3iXJ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAmpnSzQACgkQJNaLcl1U
h9DhKwf/RoCnDee69F9hZ06/HOdC8gDpovt8IjWRgC8X3EQmHZkTxcKWoky17APD
5D8K2eKoz+FEDKrtFChR3EfGX0AhpmXhKtwaUanH/Qm+clf4ZjOTiguGtDpB4EVm
bTQ0cWSCcNpHm4yfpRk8XJVw/leZO0YIsDDi9rHzgeKJVY5zWBXi6azVk3svE2Ut
E9u3jmn1vStzN8uV36mRJ2+hgzFQOVilP6XSNNxMrdu6GJXHk/T6ZUlANNAxGcbL
/fZLJuq1gzwgfEJevdiqJ+O9U3OQl0DV9ZELQBaghYKq6Lv3nMs3PFSromeerfgv
GqK0jSpzheWN4gsenCQKqgt3POQM+g==
=WTGT
-----END PGP SIGNATURE-----

--2ViMWcNJN7tv3iXJ--
