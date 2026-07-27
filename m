Received: from mgamail.intel.com (mgamail.intel.com [192.198.163.17])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A8DC137B00E;
	Mon, 27 Jul 2026 08:30:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=192.198.163.17
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785141041; cv=none; b=VKI5bW6DwjrdrPlLz+R1G58m3Jg+vjdxNOOKhEQ5z1ySQ+rhzzgh+DCSrN7sihfFjvfkO1DqECWSvcKw7oMJCCygguMXpTS8SNkAy/d/w9orowKIjpZqqHtdqo6dr9QbBSuToy2nyjc7rtB3y+PtStaEGaH7OwOPSLfIoPS/8jo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785141041; c=relaxed/simple;
	bh=qWnqu6VCUiwZWG189ixa/W9uGeC6PMG4tY9t7kvdnXI=;
	h=From:To:Cc:Subject:In-Reply-To:References:Date:Message-ID:
	 MIME-Version:Content-Type; b=h8LKZ8EVsai8wMrYj/fT0xVSgPTrl6DOh04/nUgZtFoRkGUPmdEqBdwE+VdRVHNKYYPYr8u+qMLJeJGWgH7glJdNWS6Amw1ytL7A1XMPHxgDaVTsiau46edgGKidGiYhptvON8UGHYeJRIfP1yJhpgmVpJCTvFCOacKBXdHd9K4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com; spf=pass smtp.mailfrom=intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=bn7dLIip; arc=none smtp.client-ip=192.198.163.17
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="bn7dLIip"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1785141039; x=1816677039;
  h=from:to:cc:subject:in-reply-to:references:date:
   message-id:mime-version;
  bh=qWnqu6VCUiwZWG189ixa/W9uGeC6PMG4tY9t7kvdnXI=;
  b=bn7dLIipZCNqvW289b61vT4b6u+LiCajh52WIL+tFfRrmJloKWtUXBG+
   ZVDoonEWBjxGTWB+TpaP1dMgq905yih2+PZN8ueg2IgP/evaSIknEaQAL
   sOKMLvBHqFYLDjGevHnwVch9P4Ys6B6dOm9LdKPySPt8mEYMMGnH2QoJC
   aF5JBvyQDaYcJ0j4N4y7zOns8t8E4CNEzASqkc1P8xkX3THpp4bsMdc1r
   4+3C/8LmINhYo2vRvUxZOSY6tooBcFJdahJfewgCAoBHpOnR3ol8IO/Kg
   t6VRYs0MkffinszzXhu5i2/2b1QBE07PokaNo3Am7W/dJ1Y/8SCMhSsNn
   Q==;
X-CSE-ConnectionGUID: mgZgOQ5BQgGfhlx+0PVe4w==
X-CSE-MsgGUID: I0V/57TmQ1qX9+TI9szaWA==
X-IronPort-AV: E=McAfee;i="6800,10657,11857"; a="85573917"
X-IronPort-AV: E=Sophos;i="6.25,188,1779174000"; 
   d="scan'208";a="85573917"
Received: from orviesa007.jf.intel.com ([10.64.159.147])
  by fmvoesa111.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 27 Jul 2026 01:30:34 -0700
X-CSE-ConnectionGUID: zuBRshsISau4U4oJl9pq1g==
X-CSE-MsgGUID: S6JnVra9Qs26laDkF7yO1A==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.25,188,1779174000"; 
   d="scan'208";a="259417611"
Received: from rvuia-mobl.ger.corp.intel.com (HELO localhost) ([10.245.245.197])
  by orviesa007-auth.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 27 Jul 2026 01:30:04 -0700
From: Jani Nikula <jani.nikula@linux.intel.com>
To: Jakub Kicinski <kuba@kernel.org>, Sang-Heon Jeon <ekffu200098@gmail.com>
Cc: Julia.Lawall@inria.fr, Alex Deucher <alexander.deucher@amd.com>,
 Alexander Shishkin <alexander.shishkin@linux.intel.com>, Alexandre Belloni
 <alexandre.belloni@bootlin.com>, Andrew Lunn <andrew@lunn.ch>, Andrew
 Morton <akpm@linux-foundation.org>, Arkadiusz Kubalewski
 <arkadiusz.kubalewski@intel.com>, Borislav Petkov <bp@alien8.de>,
 Christian =?utf-8?Q?K=C3=B6nig?= <christian.koenig@amd.com>, Daniel Lezcano
 <daniel.lezcano@kernel.org>, David Airlie <airlied@gmail.com>, "David S.
 Miller" <davem@davemloft.net>, Dmitry Torokhov
 <dmitry.torokhov@gmail.com>, Eric Dumazet <edumazet@google.com>, Florian
 Westphal <fw@strlen.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Hans de Goede <hansg@kernel.org>, Hans Verkuil <hverkuil@kernel.org>,
 Heikki Krogerus <heikki.krogerus@linux.intel.com>, Herbert Xu
 <herbert@gondor.apana.org.au>, Ilpo =?utf-8?Q?J=C3=A4rvinen?=
 <ilpo.jarvinen@linux.intel.com>, "James E.J. Bottomley"
 <James.Bottomley@HansenPartnership.com>, Jaroslav Kysela <perex@perex.cz>,
 Jason Gunthorpe <jgg@ziepe.ca>, Jiri Pirko <jiri@resnulli.us>, "Joerg
 Roedel
 (AMD)" <joro@8bytes.org>, Johan Hovold <johan@kernel.org>, Jonathan Cameron
 <jic23@kernel.org>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
 Julian Anastasov <ja@ssi.bg>, Leon Romanovsky <leon@kernel.org>, Liam
 Girdwood <lgirdwood@gmail.com>, Linus Walleij <linusw@kernel.org>, Maarten
 Lankhorst <maarten.lankhorst@linux.intel.com>, Mark Brown
 <broonie@kernel.org>, "Martin K. Petersen" <martin.petersen@oracle.com>,
 Matthew Sakai <msakai@redhat.com>, Mauro Carvalho Chehab
 <mchehab@kernel.org>, Maxime Ripard <mripard@kernel.org>, Michael
 Turquette <mturquette@baylibre.com>, Mike Rapoport <rppt@kernel.org>, Miri
 Korenblit <miriam.rachel.korenblit@intel.com>, Nicolas Palix
 <nicolas.palix@imag.fr>, Pablo Neira Ayuso <pablo@netfilter.org>, Paolo
 Abeni <pabeni@redhat.com>, Ping-Ke Shih <pkshih@realtek.com>, "Rafael J.
 Wysocki" <rafael@kernel.org>, Rodrigo Vivi <rodrigo.vivi@intel.com>,
 Sebastian Reichel <sre@kernel.org>, Shuah Khan <shuah@kernel.org>, Simona
 Vetter <simona@ffwll.ch>, Simon Horman <horms@verge.net.au>, Stephen Boyd
 <sboyd@kernel.org>, Steve French <sfrench@samba.org>, Takashi Iwai
 <tiwai@suse.com>, Thomas Renninger <trenn@suse.com>, Thomas Zimmermann
 <tzimmermann@suse.de>, Tony Luck <tony.luck@intel.com>, Tvrtko Ursulin
 <tursulin@ursulin.net>, Vadim Fedorenko <vadim.fedorenko@linux.dev>, Vinod
 Koul <vkoul@kernel.org>, Will
 Deacon <will@kernel.org>, Yazen Ghannam <Yazen.Ghannam@amd.com>,
 cocci@inria.fr, amd-gfx@lists.freedesktop.org, dmaengine@vger.kernel.org,
 dm-devel@lists.linux.dev, dri-devel@lists.freedesktop.org,
 intel-gfx@lists.freedesktop.org, intel-wired-lan@lists.osuosl.org,
 iommu@lists.linux.dev, linux-cifs@vger.kernel.org,
 linux-clk@vger.kernel.org, linux-crypto@vger.kernel.org,
 linux-edac@vger.kernel.org, linux-gpio@vger.kernel.org,
 linux-iio@vger.kernel.org, linux-input@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
 linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-rdma@vger.kernel.org,
 linux-rtc@vger.kernel.org, linux-s390@vger.kernel.org,
 linux-scsi@vger.kernel.org, linux-sound@vger.kernel.org,
 linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
 lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
 netfilter-devel@vger.kernel.org, nouveau@lists.freedesktop.org,
 platform-driver-x86@vger.kernel.org
Subject: Re: [PATCH 00/36] treewide: remove conditional returns with no effect
In-Reply-To: <20260724144822.6af8213f@kernel.org>
Organization: Intel Finland Oy - BIC 0357606-4 - c/o Alberga Business Park,
 6 krs Bertel Jungin Aukio 5, 02600 Espoo, Finland
References: <20260723184538.3888637-1-ekffu200098@gmail.com>
 <20260724144822.6af8213f@kernel.org>
Date: Mon, 27 Jul 2026 11:30:01 +0300
Message-ID: <0ee1ef4aa7daa908bf28397ccc639c89b6aabd9c@intel.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On Fri, 24 Jul 2026, Jakub Kicinski <kuba@kernel.org> wrote:
> On Fri, 24 Jul 2026 03:45:02 +0900 Sang-Heon Jeon wrote:
>> Patch 1 adds a Coccinelle script that matches the pattern, including
>> negation and constant-comparison variants. Where a local variable is
>> assigned right before the check, the assignment and the two returns
>> turn into a single return of the assigned expression.
>
> Huh, I thought we already had such script. Various script children have
> been sending such "cleanups" in the past.

We did, and it was removed, I believe in 1a617a8475e8 ("coccinelle:
misc: remove "complex return code" warnings"), because people just don't
want this constant churn.

It's perfectly fine to have the error case and happy day scenario
separated.


BR,
Jani.


-- 
Jani Nikula, Intel
