Received: from mgamail.intel.com (mgamail.intel.com [198.175.65.10])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2D1A9352017;
	Mon, 27 Jul 2026 11:37:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.175.65.10
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785152250; cv=none; b=StVNMgqL3Yn8IaCO8damfonXlCr5+O7iz17wQdB2Qv/f2E/uSHGWJbBt/TFsl7vU+FWYdWO6sQQPulCJjmPNCRXolgZbIkPhhF5EEpGPzW/rrR69WOj1frv31AMfzCUtLOd+2AAK1BuLef/R0V8zgOnd3tfmNv8+nZnI/EbdM4k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785152250; c=relaxed/simple;
	bh=/6ix+2ekyEjmxtNQWG+EytAOJTxYlBnpiXnHByYObJw=;
	h=From:To:Cc:Subject:In-Reply-To:References:Date:Message-ID:
	 MIME-Version:Content-Type; b=T8Q9Yn6qOUfIA9u4MC45acgW1yYREOr/ZVZWM6ihZhAEaALV5hlkj7wMSM/iZN1PA/PxNT2FM5nkVaUlcdh+fS0AwAaos8AuLF4JBitxh4VNkuL/b0MtU0nd+LwjNp9ByfsS8gXQ9L9HmZ9AGeCjecnG3XhiC4rlCtc1tl0jVaY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com; spf=pass smtp.mailfrom=intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=UoVN6kUH; arc=none smtp.client-ip=198.175.65.10
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="UoVN6kUH"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1785152248; x=1816688248;
  h=from:to:cc:subject:in-reply-to:references:date:
   message-id:mime-version:content-transfer-encoding;
  bh=/6ix+2ekyEjmxtNQWG+EytAOJTxYlBnpiXnHByYObJw=;
  b=UoVN6kUHLiqMxrbRU8IJEgPiYMR8IKkp3NoPmD1OnE5fjUuAfFPFjr4G
   bHHInFdIQmvdUM19WhToQdrE8gW4HdEnKt6rr+eKq0cTT1h9MhUTU9VXC
   eO7nMi7eU0ozgp+AQ8Bi94Du+SCxGRZU3jAYgQt9pt8SMFlGa7YCQSKqX
   VcT6TEGMoan/uLXIpKIQZvbWa0hiygZ0b0basx1dVSq5T1yJezDwIImTo
   JroHWhSBD/PLEoCCbsEUQzjLctrdcolGwwLLcMXz3OnwEcrZq9I2lYJa0
   wHadG3tkd4YPJQ71C4slYbuG8iRUe3uuhWtpAIp5Uc4zdWZictK7ferHY
   A==;
X-CSE-ConnectionGUID: zt7rixJmR9uzoVcdOyX/sw==
X-CSE-MsgGUID: Zq6WKCFqT5iyB5vcgAcCyg==
X-IronPort-AV: E=McAfee;i="6800,10657,11857"; a="103128666"
X-IronPort-AV: E=Sophos;i="6.25,188,1779174000"; 
   d="scan'208";a="103128666"
Received: from orviesa001.jf.intel.com ([10.64.159.141])
  by orvoesa102.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 27 Jul 2026 04:37:27 -0700
X-CSE-ConnectionGUID: jc740gvBSCmfJ/AOeJRN5Q==
X-CSE-MsgGUID: 4x0a30kMTGOmwHJgJde0/Q==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.25,188,1779174000"; 
   d="scan'208";a="297617694"
Received: from rvuia-mobl.ger.corp.intel.com (HELO localhost) ([10.245.245.197])
  by smtpauth.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 27 Jul 2026 04:37:02 -0700
From: Jani Nikula <jani.nikula@linux.intel.com>
To: Sang-Heon Jeon <ekffu200098@gmail.com>
Cc: Jakub Kicinski <kuba@kernel.org>, Julia.Lawall@inria.fr, Alex Deucher
 <alexander.deucher@amd.com>, Alexander Shishkin
 <alexander.shishkin@linux.intel.com>, Alexandre Belloni
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
 <James.Bottomley@hansenpartnership.com>, Jaroslav Kysela <perex@perex.cz>,
 Jason Gunthorpe <jgg@ziepe.ca>, Jiri Pirko <jiri@resnulli.us>, "Joerg
 Roedel (AMD)" <joro@8bytes.org>, Johan Hovold <johan@kernel.org>, Jonathan
 Cameron <jic23@kernel.org>, Joonas Lahtinen
 <joonas.lahtinen@linux.intel.com>, Julian Anastasov <ja@ssi.bg>, Leon
 Romanovsky <leon@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, Linus
 Walleij <linusw@kernel.org>, Maarten Lankhorst
 <maarten.lankhorst@linux.intel.com>, Mark Brown <broonie@kernel.org>,
 "Martin K. Petersen" <martin.petersen@oracle.com>, Matthew Sakai
 <msakai@redhat.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Maxime
 Ripard <mripard@kernel.org>, Michael Turquette <mturquette@baylibre.com>,
 Mike Rapoport <rppt@kernel.org>, Miri Korenblit
 <miriam.rachel.korenblit@intel.com>, Nicolas Palix
 <nicolas.palix@imag.fr>, Pablo Neira Ayuso <pablo@netfilter.org>, Paolo
 Abeni <pabeni@redhat.com>, Ping-Ke Shih <pkshih@realtek.com>, "Rafael J.
 Wysocki" <rafael@kernel.org>, Rodrigo Vivi <rodrigo.vivi@intel.com>,
 Sebastian Reichel <sre@kernel.org>, Shuah Khan <shuah@kernel.org>, Simona
 Vetter <simona@ffwll.ch>, Simon Horman <horms@verge.net.au>, Stephen Boyd
 <sboyd@kernel.org>, Steve French <sfrench@samba.org>, Takashi Iwai
 <tiwai@suse.com>, Thomas Renninger <trenn@suse.com>, Thomas Zimmermann
 <tzimmermann@suse.de>, Tony Luck <tony.luck@intel.com>, Tvrtko Ursulin
 <tursulin@ursulin.net>, Vadim Fedorenko <vadim.fedorenko@linux.dev>, Vinod
 Koul <vkoul@kernel.org>, Will Deacon <will@kernel.org>, Yazen Ghannam
 <Yazen.Ghannam@amd.com>, cocci@inria.fr, amd-gfx@lists.freedesktop.org,
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
Subject: Re: [PATCH 00/36] treewide: remove conditional returns with no effect
In-Reply-To: <CABFDxMFMOAZ_3kYxEGCutnGt1OSSmgvmwx-=M1RxGc3VGKORYQ@mail.gmail.com>
Organization: Intel Finland Oy - BIC 0357606-4 - c/o Alberga Business Park,
 6 krs Bertel Jungin Aukio 5, 02600 Espoo, Finland
References: <20260723184538.3888637-1-ekffu200098@gmail.com>
 <20260724144822.6af8213f@kernel.org>
 <0ee1ef4aa7daa908bf28397ccc639c89b6aabd9c@intel.com>
 <CABFDxMFMOAZ_3kYxEGCutnGt1OSSmgvmwx-=M1RxGc3VGKORYQ@mail.gmail.com>
Date: Mon, 27 Jul 2026 14:36:57 +0300
Message-ID: <a4703624643e1d2fd1a9dedc1d36ce5d34d3133f@intel.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Mon, 27 Jul 2026, Sang-Heon Jeon <ekffu200098@gmail.com> wrote:
> Hello,
>
> On Mon, Jul 27, 2026 at 5:30=E2=80=AFPM Jani Nikula <jani.nikula@linux.in=
tel.com> wrote:
>>
>> On Fri, 24 Jul 2026, Jakub Kicinski <kuba@kernel.org> wrote:
>> > On Fri, 24 Jul 2026 03:45:02 +0900 Sang-Heon Jeon wrote:
>> >> Patch 1 adds a Coccinelle script that matches the pattern, including
>> >> negation and constant-comparison variants. Where a local variable is
>> >> assigned right before the check, the assignment and the two returns
>> >> turn into a single return of the assigned expression.
>> >
>> > Huh, I thought we already had such script. Various script children have
>> > been sending such "cleanups" in the past.
>>
>> We did, and it was removed, I believe in 1a617a8475e8 ("coccinelle:
>> misc: remove "complex return code" warnings"), because people just don't
>> want this constant churn.
>>
>> It's perfectly fine to have the error case and happy day scenario
>> separated.
>
> Thanks for sharing the history.
>
> I checked the mailing list. The removed script looks similar to the
> new one, but it is different. The removed script reported a
> conditional return followed by an explicit return 0, where the error
> case and happy day scenario are separated as you mentioned, and Johan
> also complained about this 10 years ago.
>
> But the new script only reports when both branches return the same
> variable, not the explicit 0. So, I think the new script is close to
> the restricted version that Julia mentioned 10 years ago, and it
> should be acceptable.

ret =3D=3D=3D 0 after an if (ret) return.

BR,
Jani.


>
>>
>> BR,
>> Jani.
>>
>>
>> --
>> Jani Nikula, Intel
>
> Best Regards,
> Sang-Heon Jeon

--=20
Jani Nikula, Intel
