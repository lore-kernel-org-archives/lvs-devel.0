Received: from dvalin.narfation.org (dvalin.narfation.org [213.160.73.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 93CBB3905F9;
	Sun,  2 Aug 2026 08:44:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.160.73.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785660264; cv=none; b=mWlM9PTpebBCLcyQAMUyRMII70mQCoz29eZBt4GVRZTbysR3Z4NphL8GvDgFpN1S3yObyT9X09nIj1BtTWsd8I9w+x4u4M5In/XSGbpcJMxdMUsVUcOPdFOl1DlMLYCyShgPEWqlXJIThd1BK4XKbUCvW5HKWFmHiFp7USncGNg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785660264; c=relaxed/simple;
	bh=WPvNJ9OfqPBXgIaK4+bgM+pCfrhZbsmVBB2ZXSRoPZE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=oqjNgMJU7n8cDoFlZIiRJwW0GShpkKTWnwf/fri9EN89CJbtpH3BuSVFjGRl5d91+aOJbldTF9JmbjaRPzcI7jLYYRoh1avOgU2SYDyAAt+ash4EDusd1n0ZmMlazoHetFMUFe8uZCmOH4FbTiGC9n+v6vz+AuSoYmI4V46vRxk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=narfation.org; spf=pass smtp.mailfrom=narfation.org; dkim=pass (1024-bit key) header.d=narfation.org header.i=@narfation.org header.b=KHK3/zjo; arc=none smtp.client-ip=213.160.73.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=narfation.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=narfation.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=narfation.org header.i=@narfation.org header.b="KHK3/zjo"
Received: by dvalin.narfation.org (Postfix) id 89F75207F7;
	Sun, 02 Aug 2026 08:44:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=narfation.org;
	s=20121; t=1785660257;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=DoRGegAQrMXVj9vfjdYtiiDqXPNn8IszMcPROOA/1qE=;
	b=KHK3/zjoEG8YV2a8JG6qhxXi9vAllC4+5XwQ+hfMmBpxRgx7u0cE79P4EtuNxLfDyZr4zi
	AQVBqXAGeyGWVGhRWK1f1Dc5EiFexzBwQdvPGZdR7zyT7vWcprSu+wfPyVrlQ28AjG6ws7
	4ecHCytqkp0xP8do3NutG4pu3vfe4xo=
From: Sven Eckelmann <sven@narfation.org>
To: horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, fw@strlen.de,
 davem@davemloft.net, edumazet@google.com, kuba@kernel.org, pabeni@redhat.com,
 David Lee <david.lee@trailofbits.com>, Kyle Zeng <kylebot@openai.com>
Cc: Dominik 'Disconnect3d' Czarnota <dominik.czarnota@trailofbits.com>,
 phil@nwl.cc, netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
 netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
 linux-kernel@vger.kernel.org, stable@vger.kernel.org
Subject:
 Re: [PATCH] ipvs: clear IPv4 options after rebasing tunnel ICMP errors
Date: Sun, 02 Aug 2026 10:44:15 +0200
Message-ID: <23471153.EfDdHjke4D@sven-desktop>
In-Reply-To: <20260731140822.567128-1-david.lee@trailofbits.com>
References: <20260731140822.567128-1-david.lee@trailofbits.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart8252458.EvYhyI6sBW";
 micalg="pgp-sha512"; protocol="application/pgp-signature"

--nextPart8252458.EvYhyI6sBW
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"; protected-headers="v1"
From: Sven Eckelmann <sven@narfation.org>
Date: Sun, 02 Aug 2026 10:44:15 +0200
Message-ID: <23471153.EfDdHjke4D@sven-desktop>
In-Reply-To: <20260731140822.567128-1-david.lee@trailofbits.com>
References: <20260731140822.567128-1-david.lee@trailofbits.com>
MIME-Version: 1.0

On Friday, 31 July 2026 16:08:22 CEST David Lee wrote:
> Fixes: f2edb9f7706d ("ipvs: implement passive PMTUD for IPIP packets")
> Cc: stable@vger.kernel.org
> Bug found and triaged by OpenAI Security Research and 
> validated by Trail of Bits.
> 
> Assisted-by: Codex:gpt-5.6-sol gpt-5.5-cyber
> Signed-off-by: Kyle Zeng <kylebot@openai.com>

1. weird text (advertisement) + newlines in the tags section which shouldn't be there
   https://docs.kernel.org/process/submitting-patches.html#sign-your-work-the-developer-s-certificate-of-origin
   (and all these tag/format related sections below)

2. author didn't sign off the patch (see below)

3. odd unrelated Signed-off-by without any obvious connection to 
   the patch

   - I actually would guess that Kyle Zeng <kylebot@openai.com> is the author 
     and David Lee removed its authorship (From: ) before sending the patch.
     But in its current form, David is claiming to be the author. And even
     when it is the case, David must still add the the non-Author SoB at the
     end.

Regards,
	Sven
--nextPart8252458.EvYhyI6sBW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQS81G/PswftH/OW8cVND3cr0xT1ywUCam8DXwAKCRBND3cr0xT1
y23mAQCRh61gIcZEFMdnDMpxQKnLNejoyvremhxy//miWt93KwD/fmuizOlqmkKk
G9YMwTMDuJWK7btMKLTt2q1CK7f37wg=
=Kisi
-----END PGP SIGNATURE-----

--nextPart8252458.EvYhyI6sBW--



