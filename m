Received: from mail-ej1-f41.google.com (mail-ej1-f41.google.com [209.85.218.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A79F238DC43
	for <lvs-devel@vger.kernel.org>; Sat, 22 Aug 2026 13:41:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.218.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787406119; cv=none; b=ejHNnWsN36vn2YqjwFmk9gN8QwQbtyMbEOXO+sS0uR0EX+bgudy+gxayEgx60GyZT/EkzqEA2Q02eLU8HlWm8fEpu5ng3n3XALejWf4B90apK0eufufQQvGjX9Wu4fYdrt0ETVMOUUAj5UyY5NRPhJ5gYEhs6Hiy7tjcaqU4ouQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787406119; c=relaxed/simple;
	bh=ShtTkIU3ezbFJIydaBLYCMvhC/wGsulze2uz5bQe5G4=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=fqDGkBcvOV4xbBLMGAdU9fQ/H4OYs+AUyAr5vrXzmzHlJh6M3cM3CnGETa4CKEGlmqOPRQHCA5iklS+YDBwu5uV259R72NbUwG40arytROg8JR2kTc5KBXKjXq7kPfyKIRsTYEV/uFHZsUx6GidjKkOBNPIK3P2tIF+1ucutFFY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=baylibre.com; spf=pass smtp.mailfrom=baylibre.com; dkim=pass (2048-bit key) header.d=baylibre.com header.i=@baylibre.com header.b=NWr95Y6+; arc=none smtp.client-ip=209.85.218.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=baylibre.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=baylibre.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=baylibre.com header.i=@baylibre.com header.b="NWr95Y6+"
Received: by mail-ej1-f41.google.com with SMTP id a640c23a62f3a-c15cb6f5c12so352919866b.0
        for <lvs-devel@vger.kernel.org>; Sat, 22 Aug 2026 06:41:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=baylibre.com; s=google; t=1787406114; x=1788010914; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=Aj3ZYubTvLgnR11pZYHVat4EVUJdKX6AnHgTVge4+Wc=;
        b=NWr95Y6+8gr1dd6kImBWVKkc9Ow7+W1hOqUbome1tczYJ0l7VolXq0eP+XhSlE2lop
         cfrU27AzjWjNSHtmZZ6RuHDw63H/Aw3j1SR3ZUJxRQSBgNqaamZlv7pWt8qP16vXkNr8
         RFuxFu+K2wzi5JQkrBzAM56wOg7B0Pw6h7m1cwa5fQL+1N4vZ9VmnU0fSvXmiMFSSbLp
         PwxvZznnm7VHgzn3KPh0fvhzv105HloBofPB+0hansRG9f8EL4WMC1/pwoxYuig5g5ac
         rHPjkA9B4VHQUiuu3DSUboCniUrCCNStbMPToZGTj1YRemJ0JduZoppZNUOsUtWyRRr6
         6eqA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787406114; x=1788010914;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=Aj3ZYubTvLgnR11pZYHVat4EVUJdKX6AnHgTVge4+Wc=;
        b=MJob+WItpvDyo7HlQl1EEPeJPR4Gf843ULGA0gdB8rYcRMqzVUH39ZE3xDRzWuuSFz
         EgRrF2vvdMyQCNMKdBw2YzxesD69+DT11HMG38TOieqnhXJGu/103dgRhnDQh8a/EACv
         1ekq1rkkIDlLrtfcw7K/YM3F0wGfhVAGZ2qi+V7at61NaMRZi7EiB/OG6EBLSHgnoRot
         H3k52oXKdirqyGr92SBLTvufEWRrMWoCH7JlSNnATPr/P/qJcr4R43r/ipZ7aaDNxiTS
         UOoclmlbA2GidysjKPQXX24lWhzk798bJJwl51ie9+friWrhO3XDSvPCqmjrS0mtQSHj
         Wr7w==
X-Forwarded-Encrypted: i=1; AHgh+Rrlb7Z/1dYDGMtSzgvBaZI8ujqJ26lXUnnReRLV/lpmS6YGFaYTf61wpX1JbE+wSAncSbAsSx+OIXE=@vger.kernel.org
X-Gm-Message-State: AFuF++l96QT30yP5Nwj41U8NTmmm137MVIPn1dirwegdJPc/NKN/DMXH
	YRzaxICcUsg83E8BRMk9ZV0XiNGh/ghsX4sOAyugyLThfwK8+oaXXcJC8tdke0WYODH6SYMc0et
	llIFoQxQ=
X-Gm-Gg: AR+sD11+Kuc96lLV0a/U+c/KVr0wR3oTFoaXmNYI1fYIkOs5dRLjamvZsa/dg07DbC0
	6G0fjmY0RRr9IuNd3Qqv9GxHFyDESzebHYRLcexnV+vokyG7crY5U36igYggiyVMAJzr9Y0FsMZ
	V9GqiLCRGu7DCP/azduvtr110IXsLUhdLYzL80T6c8+f5FRsAtClqVA37iyxXCq8acT5kD+FyTe
	8aUM5O35bvG9qmL6xHwuLuRZOBGOsPn+6x0Ou6WccqNDY3/Fr6xFX3Wt++mUWPJQDAQqT97aaMf
	5PhusYRCqHdfXeKtnsdJyCX/tlaDzHEbyiNyIulHgXF6nJDBnCicOr2KYqyguarOZeVU1Zvog6E
	2/xcFunSRxpRTADe53UPqCOyys6E7WS/aiJhH6myyg/TgcfVh+PxUPlJ66Z1+sCASkNTOyFFMuA
	UkLCXMo+MSHpSBrg8SpAhMkYo1MyWYtN+/qt60sibd3yikhpgcCqIineMqOGPtcbt4bA==
X-Received: by 2002:a17:907:8908:b0:c21:35d0:f435 with SMTP id a640c23a62f3a-c24924db408mr547750766b.10.1787406113365;
        Sat, 22 Aug 2026 06:41:53 -0700 (PDT)
Received: from localhost ([2a02:8071:56d1:2de0:1d24:d58d:2b65:c291])
        by smtp.gmail.com with UTF8SMTPSA id a640c23a62f3a-c249606a8fasm387614266b.8.2026.08.22.06.41.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 22 Aug 2026 06:41:52 -0700 (PDT)
Date: Sat, 22 Aug 2026 15:41:50 +0200
From: Uwe =?utf-8?Q?Kleine-K=C3=B6nig?= <u.kleine-koenig@baylibre.com>
To: Mauricio Faria de Oliveira <mfo@igalia.com>
Cc: Kees Cook <kees@kernel.org>, Joel Granados <joel.granados@kernel.org>, 
	Nathan Chancellor <nathan@kernel.org>, Nicolas Schier <nsc@kernel.org>, 
	"David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, 
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
	kernel-dev@igalia.com, linux-riscv@lists.infradead.org, linux-kernel@vger.kernel.org, 
	fsverity@lists.linux.dev, keyrings@vger.kernel.org, bpf@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, linux-kbuild@vger.kernel.org, netdev@vger.kernel.org, 
	linux-wpan@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, 
	coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-rdma@vger.kernel.org, 
	linux-s390@vger.kernel.org, bridge@lists.linux.dev, mptcp@lists.linux.dev, 
	rds-devel@oss.oracle.com, virtualization@lists.linux.dev
Subject: Re: [PATCH RFC v3 03/13] sysctl, mod_devicetable: add macro
 MODULE_SYSCTL_TABLE
Message-ID: <aomlfGJM61qZKxx2@monoceros>
References: <20260819-sysctl-module-aliases-v3-0-aab90569365d@igalia.com>
 <20260819-sysctl-module-aliases-v3-3-aab90569365d@igalia.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="akn7oxv4v2qk2wdq"
Content-Disposition: inline
In-Reply-To: <20260819-sysctl-module-aliases-v3-3-aab90569365d@igalia.com>


--akn7oxv4v2qk2wdq
Content-Type: text/plain; protected-headers=v1; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH RFC v3 03/13] sysctl, mod_devicetable: add macro
 MODULE_SYSCTL_TABLE
MIME-Version: 1.0

Hello,

On Wed, Aug 19, 2026 at 03:16:16PM -0300, Mauricio Faria de Oliveira wrote:
> The MODULE_SYSCTL_TABLE macro emits a struct module_sysctl_table variable
> with pointers to a sysctl table's path and entries, and table/entry sizes.

That new struct doesn't seem to contain any pointer?

> That symbol will be handled by file2alias.c (modpost) with the changes in
> mod_devicetable.h and devicetable-offsets.c.
>=20
> The option macros MODULE_SYSCTL_TABLE_{DISABLE,UNIQUE_ID} can be used on
> a per-file basis to disable the macro and change the symbol name pattern.
>=20
> Signed-off-by: Mauricio Faria de Oliveira <mfo@igalia.com>
> ---
>  include/linux/mod_devicetable.h   |  7 +++++++
>  include/linux/sysctl.h            | 42 +++++++++++++++++++++++++++++++++=
++++++
>  scripts/mod/devicetable-offsets.c |  6 ++++++
>  3 files changed, 55 insertions(+)

Please put the new struct in a separate header. Apart from not being
about a device table, I'm currently work on removing
<linux/mod_devicetable.h>. See commit
ad428f5811bd7fb3d91fa002174de533f9da94d7 for more details.

Best regards
Uwe

--akn7oxv4v2qk2wdq
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEP4GsaTp6HlmJrf7Tj4D7WH0S/k4FAmqJpxsACgkQj4D7WH0S
/k5bfgf9HJoNnVEr9RCdAghOTP5QqFmH5ae7Kbmnodv6c6Pi9JGIjjGbeT5eKw3e
JkSKqdEnlVMrLoKrhneRsxwTDGPrZvrLZrPLdZwJmPWZn5Fg+kkOO9yFAGPeMsPX
S6UP1NY9kaCiBtlcsGT9EvMWz0jWVAWX1xb7Y2WcVZJsCWdcPhvWc3/lIbw3E4o7
PqLtSFblkQmtGl2OL4WkP6xhEPH6qQO9BAmhLVKKZwFW5/l4sHmXRrpgSJlroR3b
iH3liIeS6wxFp/fMYuFRryGHNMXn6gC447OnOCTmGNEj7+7Y3COwSGivgubcRIzI
RkmxkMf2Iuntnwp4oQzCbipE5EiKGA==
=SPY4
-----END PGP SIGNATURE-----

--akn7oxv4v2qk2wdq--
