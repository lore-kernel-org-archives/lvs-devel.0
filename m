Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BA9FC345EBF;
	Tue, 11 Aug 2026 18:52:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786474330; cv=none; b=Pj6/64Q2VQS3MkjT9kau/RWQJbtptxfMqpHJArWkLIKaiUfmvmud+/i3tzsWUZQFaGqntXXh8oaMAD7Iws/4Pot7rRwe4Dt9IG+jquTkF1M9rsilwO1pU6P9NV9m4mwLf3HlIa6TVPkgSVcvT9CutUy3QxDfS2nKYuj9csqGS1w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786474330; c=relaxed/simple;
	bh=iG6kolHVo+LhrokzkJn9oo8OafaqsBYZtLW62gK7dbY=;
	h=From:To:Cc:In-Reply-To:References:Subject:Message-Id:Date:
	 MIME-Version:Content-Type; b=VhFZrjSH07ikb62SMZR70+VlVvcVEDiOHme77qSfitUFPGpXtqnvdWE9P8rdbbBneIIennFPN/bTW+3u5dxgMoDGpxv+o71fLw1iw88qISexVbrujOl5ycWQwgxarkrU29ZVkazVzy09kXi5siDugI+8ImqF+A1vynkHjhwgrN0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=f9fcK+NV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="f9fcK+NV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 64C9D1F00A3A;
	Tue, 11 Aug 2026 18:51:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786474329;
	bh=L0HTQS1LYVWSdc3RimfvMueRkxBKnov+tJfBP1Nzenc=;
	h=From:To:Cc:In-Reply-To:References:Subject:Date;
	b=f9fcK+NVNWrvcSOcKHy6zfAbJxAzV4H4fy8MVkzolSHyhTXevNA14uYiezSHzn6pQ
	 ycpaMxR2NK5BhnYOlevG/IFGX9tQA5Zq59bExZRq8ebTHdeuBPIJKdmorpcmlYiJYN
	 enPNXmLxCznd3cawK4k1uWZ7ls5UQ+kBsVAJbZyI9ASkk1wotZU4MuXOcOSURRiwqg
	 sT65TPpe9rPAxYbWb9c4r08z7q71qyz1ECpgE74A6BnSnCI7mMzF6uQjafv+S2Jyy3
	 tECe4u8tzT2Nvo9T8WlyH+ZxIb0wNqskL4SGoz+McXb9NEhgBdQAaCdq0Vli+in/qH
	 jqXBcNxLA7xiA==
From: Vinod Koul <vkoul@kernel.org>
To: Julia.Lawall@inria.fr, Alex Deucher <alexander.deucher@amd.com>, 
 Alexander Shishkin <alexander.shishkin@linux.intel.com>, 
 Alexandre Belloni <alexandre.belloni@bootlin.com>, 
 Andrew Lunn <andrew@lunn.ch>, Andrew Morton <akpm@linux-foundation.org>, 
 Arkadiusz Kubalewski <arkadiusz.kubalewski@intel.com>, 
 Borislav Petkov <bp@alien8.de>, 
 =?utf-8?q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
 Daniel Lezcano <daniel.lezcano@kernel.org>, 
 David Airlie <airlied@gmail.com>, "David S. Miller" <davem@davemloft.net>, 
 Dmitry Torokhov <dmitry.torokhov@gmail.com>, 
 Eric Dumazet <edumazet@google.com>, Florian Westphal <fw@strlen.de>, 
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
 Hans de Goede <hansg@kernel.org>, Hans Verkuil <hverkuil@kernel.org>, 
 Heikki Krogerus <heikki.krogerus@linux.intel.com>, 
 Herbert Xu <herbert@gondor.apana.org.au>, 
 =?utf-8?q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@linux.intel.com>, 
 Jakub Kicinski <kuba@kernel.org>, 
 "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, 
 Jani Nikula <jani.nikula@linux.intel.com>, Jaroslav Kysela <perex@perex.cz>, 
 Jason Gunthorpe <jgg@ziepe.ca>, Jiri Pirko <jiri@resnulli.us>, 
 "Joerg Roedel (AMD)" <joro@8bytes.org>, Johan Hovold <johan@kernel.org>, 
 Jonathan Cameron <jic23@kernel.org>, 
 Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, 
 Julian Anastasov <ja@ssi.bg>, Leon Romanovsky <leon@kernel.org>, 
 Liam Girdwood <lgirdwood@gmail.com>, Linus Walleij <linusw@kernel.org>, 
 Maarten Lankhorst <maarten.lankhorst@linux.intel.com>, 
 Mark Brown <broonie@kernel.org>, 
 "Martin K. Petersen" <martin.petersen@oracle.com>, 
 Matthew Sakai <msakai@redhat.com>, 
 Mauro Carvalho Chehab <mchehab@kernel.org>, 
 Maxime Ripard <mripard@kernel.org>, 
 Michael Turquette <mturquette@baylibre.com>, 
 Mike Rapoport <rppt@kernel.org>, 
 Miri Korenblit <miriam.rachel.korenblit@intel.com>, 
 Nicolas Palix <nicolas.palix@imag.fr>, 
 Pablo Neira Ayuso <pablo@netfilter.org>, Paolo Abeni <pabeni@redhat.com>, 
 Ping-Ke Shih <pkshih@realtek.com>, "Rafael J. Wysocki" <rafael@kernel.org>, 
 Rodrigo Vivi <rodrigo.vivi@intel.com>, Sebastian Reichel <sre@kernel.org>, 
 Shuah Khan <shuah@kernel.org>, Simona Vetter <simona@ffwll.ch>, 
 Simon Horman <horms@verge.net.au>, Stephen Boyd <sboyd@kernel.org>, 
 Steve French <sfrench@samba.org>, Takashi Iwai <tiwai@suse.com>, 
 Thomas Renninger <trenn@suse.com>, Thomas Zimmermann <tzimmermann@suse.de>, 
 Tony Luck <tony.luck@intel.com>, Tvrtko Ursulin <tursulin@ursulin.net>, 
 Vadim Fedorenko <vadim.fedorenko@linux.dev>, Will Deacon <will@kernel.org>, 
 Yazen Ghannam <Yazen.Ghannam@amd.com>, 
 Sang-Heon Jeon <ekffu200098@gmail.com>
Cc: cocci@inria.fr, amd-gfx@lists.freedesktop.org, 
 dmaengine@vger.kernel.org, dm-devel@lists.linux.dev, 
 dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, 
 intel-wired-lan@lists.osuosl.org, iommu@lists.linux.dev, 
 linux-cifs@vger.kernel.org, linux-clk@vger.kernel.org, 
 linux-crypto@vger.kernel.org, linux-edac@vger.kernel.org, 
 linux-gpio@vger.kernel.org, linux-iio@vger.kernel.org, 
 linux-input@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-media@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, 
 linux-rdma@vger.kernel.org, linux-rtc@vger.kernel.org, 
 linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org, 
 linux-sound@vger.kernel.org, linux-usb@vger.kernel.org, 
 linux-wireless@vger.kernel.org, lvs-devel@vger.kernel.org, 
 netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, 
 nouveau@lists.freedesktop.org, platform-driver-x86@vger.kernel.org
In-Reply-To: <20260723184538.3888637-1-ekffu200098@gmail.com>
References: <20260723184538.3888637-1-ekffu200098@gmail.com>
Subject: Re: (subset) [PATCH 00/36] treewide: remove conditional returns
 with no effect
Message-Id: <178647430099.1113716.2263974283705757692.b4-ty@kernel.org>
Date: Wed, 12 Aug 2026 00:21:40 +0530
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Mailer: b4 0.13.0


On Fri, 24 Jul 2026 03:45:02 +0900, Sang-Heon Jeon wrote:
> While reading mm/memblock, I found a conditional return where both
> branches return the same value:
> 
> 	err = do_something();
> 	if (err)
> 		return err;
> 	return err;
> 
> [...]

Applied, thanks!

[19/36] dmaengine: qcom_hidma: remove conditional return with no effect
        commit: 04b8c3de13871653a8ecbd9f1adfea4d0694ecfe

Best regards,
-- 
~Vinod


