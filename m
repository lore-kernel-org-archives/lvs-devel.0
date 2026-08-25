Received: from mail-ej1-f45.google.com (mail-ej1-f45.google.com [209.85.218.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6D5FA3DDDD0
	for <lvs-devel@vger.kernel.org>; Tue, 25 Aug 2026 08:24:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.218.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787646261; cv=none; b=FT43+hQ168TEZKe+7aVJBlDlObdSbrW3Qv/vqul3WOBNTAtbNZj8CMMWqzK+FFeVaEjCtpFgg2xBYevBsd6IuvtujhTeOUy09b1k24K4nX6L/A4XkM2RTtd5J1eq42xtgeAUIsismMtvGIpcEFBgWuPbbqdK6m8GLDz4GeLWYOg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787646261; c=relaxed/simple;
	bh=DZQvgMF9MtoSMKn9/xxgPT3t+kYxUHeBLkPFZwmxGy0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=CCLQ2OsQdlvNQXBPQSrB3pEuust6mBTTC0qFY9cFJ4CF83bB0ZNAn0M5j3sLmgEKrJzb1BGxCEnffix/bNjLxNokmTUGbz2hDVgRW8tCcF6O+pHW6fW64xuz5Tj+7y+4peg24fQqpKdQ0rjUnJwKgCttxn2UyZ3YVDSChKKSI6A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=baylibre.com; spf=pass smtp.mailfrom=baylibre.com; dkim=pass (2048-bit key) header.d=baylibre.com header.i=@baylibre.com header.b=BFeqlQ0q; arc=none smtp.client-ip=209.85.218.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=baylibre.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=baylibre.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=baylibre.com header.i=@baylibre.com header.b="BFeqlQ0q"
Received: by mail-ej1-f45.google.com with SMTP id a640c23a62f3a-c15b1da6b82so483341366b.1
        for <lvs-devel@vger.kernel.org>; Tue, 25 Aug 2026 01:24:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=baylibre.com; s=google; t=1787646255; x=1788251055; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=DZQvgMF9MtoSMKn9/xxgPT3t+kYxUHeBLkPFZwmxGy0=;
        b=BFeqlQ0q/iI/Y9xCCyZW9DcLrNuxdKfN+Y+//0GtDmUjYy2yEe/So/1C91iOhFggaa
         w+PoJMpJllcqUOV1XX00bD7B84xNhMcsllE/0Nmh9dN8tZqJJBTNzbShKDQnxPsEmaEB
         ADAFZ+g3kLKRuXMS8OJko/112mNWDH4sfjFIo4ughfQq/cnFDH/p9Dc0K0AtS70+B4FM
         F9fsHPDaiztrmyZ3lyUZT3jElm9oP2eZVU4cOzQu3ucYmiskPZDEWm9d/KJQ6ZtJ4Xeu
         uIa0swNl0ttsWWPbGXJPM6SHTBQ7jF+5mcgT6fWzV+zAaPzszidX3t44XfJa0Wfi3HSP
         gdqw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787646255; x=1788251055;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=DZQvgMF9MtoSMKn9/xxgPT3t+kYxUHeBLkPFZwmxGy0=;
        b=fFYEEiz4FoKfixcpfnKTiBvJ1oc4mIurWUol2tH03BaDlQHxlwOmCjNpp/+W+z8yeL
         5Sy7epglvo4CD7gH2RQEatUsdl9iW7kyjKY/JEQQ6Hb5vqktT/bZaPYrTFgkMFElpnr6
         SqQ3S3tJx8ujhXkSjup5SXheEMN2EAxkc/mvk4T3xsJiVLg9+qlo+taC5BhAC07WrTNG
         BP+YN3wFy/b2zmQvMEWBcP8GrB2VmMC3jREU3lS8e3/0ZyduDMUy4b6HnF23reEAyjuT
         6UDPJnSz7Ytz0LyxVywiTqKYDceF54UrfPyv5+0jtMZy/fcruDeaUV5TxnPIx7JK/eKU
         G7Cg==
X-Forwarded-Encrypted: i=1; AHgh+RoRfkMUjm6M3RzH1eXnD6VKk6Pj8zLNmKMKVd9bw3hdivT1iF1Dv0wqgmp/w5tJujXoui8GR7KFmKs=@vger.kernel.org
X-Gm-Message-State: AFuF++mXBNhP+mN54i3K5qqJPCe9mUQdoLhy/U0DHh1Oz+5K3+ckg+Ek
	NN8fGiGPiweoIyel9RjT0eEpjUFOaSUTVL69DQ7ufa2tii8Xh359eT+iesKpBM2LAFU=
X-Gm-Gg: AR+sD11+1YIYAKzu2FmMEsbd6dgVEoMoXJGuXi5vZi3xFTnycIUXN8OBUo+fAOc2/YJ
	Ph4WK2sshI04nP7/kDUIB+uFlbUXlj/MOeIBqZEEDuagTAyxqdX4fUTUtQCUuJGmlTJHGR3AbV4
	p8S7Ssd8yEJkBBB4T1KWeZ2De3fhQSwqlr/BwzhWEPDLwz9m4AHlWEx5VYzTY9ovp7UzQgoGa5q
	Qc9nmGIOraFBB+Z2uBcYqt5HrQvr4XsJc2tn5FhYfo6jZrM0vthraPpl4N7mmFRlQ+lISA9IRFn
	JWqolgsy07aWZuM4hye0PfTe0Sb+u6zLL4wjJxqWD530GaPL78LUZ6lSzBqjDwISKmBdOVFFwMY
	W5ygCw1vR5cGY5LdyCcodSTx9rrTXoziIE4wsr51mLJTnEkaOko4ofShlQsycMW0WmF1V5dgxIU
	KP9r0bTZhIsX18MRprRJhboMhnD0Eixq062Q5x/EN7x/86AUAGRH9/0ChpSiZIol3ELHSo8MEME
	taxxLgQmEk8PeUs6L2UviYupgmCXIjitBGjOc2Y3sA6itdOdw==
X-Received: by 2002:a17:907:1c07:b0:c15:f26a:3438 with SMTP id a640c23a62f3a-c24e5c1ffd3mr497229766b.24.1787646255345;
        Tue, 25 Aug 2026 01:24:15 -0700 (PDT)
Received: from localhost (p200300f65f19a904037016a565660d5e.dip0.t-ipconnect.de. [2003:f6:5f19:a904:370:16a5:6566:d5e])
        by smtp.gmail.com with UTF8SMTPSA id a640c23a62f3a-c24966f9cbcsm1874351966b.29.2026.08.25.01.24.13
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 25 Aug 2026 01:24:14 -0700 (PDT)
Date: Tue, 25 Aug 2026 10:24:12 +0200
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
Message-ID: <ao1P_mEJdyRExG3v@monoceros>
References: <20260819-sysctl-module-aliases-v3-0-aab90569365d@igalia.com>
 <20260819-sysctl-module-aliases-v3-3-aab90569365d@igalia.com>
 <aomlfGJM61qZKxx2@monoceros>
 <4e3eaf1d3419e808be046035f114bf6c@igalia.com>
 <aotteDcc588iwC6g@monoceros>
 <4aa22e41e8ff4bab6638cf0baaa9d07b@igalia.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="ajsyed3ibfmsggn6"
Content-Disposition: inline
In-Reply-To: <4aa22e41e8ff4bab6638cf0baaa9d07b@igalia.com>


--ajsyed3ibfmsggn6
Content-Type: text/plain; protected-headers=v1; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH RFC v3 03/13] sysctl, mod_devicetable: add macro
 MODULE_SYSCTL_TABLE
MIME-Version: 1.0

Hello,

On Mon, Aug 24, 2026 at 06:04:03PM -0300, Mauricio Faria de Oliveira wrote:
> On 2026-08-23 19:12, Uwe Kleine-K=F6nig wrote:
> > On Sat, Aug 22, 2026 at 01:57:24PM -0300, Mauricio Faria de Oliveira wr=
ote:
> >> On 2026-08-22 10:41, Uwe Kleine-K=F6nig wrote:
> >> > On Wed, Aug 19, 2026 at 03:16:16PM -0300, Mauricio Faria de Oliveira=
 wrote:
> >> >> The MODULE_SYSCTL_TABLE macro emits a struct module_sysctl_table va=
riable
> >> >> with pointers to a sysctl table's path and entries, and table/entry=
 sizes.
> >> >=20
> >> > That new struct doesn't seem to contain any pointer?
> >>=20
> >> The struct module_sysctl_table fields .path and .table are pointers,
> >> although with kernel_ulong_t type so that the same 32/64-bit size is
> >> used in file2alias.c based on KERNEL_ELFCLASS (and not on the host,
> >> which might differ with CROSS_COMPILE).
> >=20
> > Cross compilation isn't an issue for the already existing device id
> > structures; many of them also contain pointers.
> > (While modpost doesn't use the pointers, the size of the structures must
> > be known to correctly interpret the arrays.)
>=20
> Indeed. I missed some device_id structures with pointers, and that
> devicetable-offsets.c is cross-compiled to generate
> devicetable-offsets.h for file2alias.c to use offsets and sizes of the
> target architecture.
>=20
> I'll change .path and .table to pointers in the next version.

I *think* the existing device-id structs use char[] for strings that are
relevant for modpost. I look forward to you finding out if there is
still a justification for that :-D

> > I would be great if your series didn't introduce a new obstacle for
> > [CHERI].
>=20
> Absolutely. I'll be happy to adjust the series and testing for that.
>=20
> Could you please confirm one should just follow [1], which uses [2] to
> build the LLVM toolchain, and use it to build the kernel [3]?
>=20
> [1] https://github.com/cheri-linux#building-and-running
> [2] https://github.com/cheri-linux/buildroot
> [3] https://github.com/CHERI-Alliance/linux/tree/codasip-cheri-riscv-7.1

I used
https://github.com/CHERI-Alliance/meta-cheri/tree/codasip-scarthgap and
didn't care about toolchain and rootfs. It also has qemu integrated, so
you can actually test it.

Best regards
Uwe

--ajsyed3ibfmsggn6
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEP4GsaTp6HlmJrf7Tj4D7WH0S/k4FAmqNUSoACgkQj4D7WH0S
/k5rHwf/eQKyjSm4dfYOnpO+kyESzhGSDXacrU0BK/nrQ7Z3BN+QipNdHe9BZ4f7
k+3uxaB8pZmyHeh98alfg/5Bq9HBt62YSsVo0f1LrxdEuw+otojZstZ5BajlC1fB
uCZWsGYJ1lROqcGUkm3WTuwmO+VkI4no1e0+OMnKjMkIdarwm+SRxroNmGXPxjFS
0c5XzO8ufI4T330xBhTtUCfIGtmOib0XeyZT/dCtT8wNoKlznA36ojMl4ZOArWgW
VYBN9/JdmoDGTZxdbWqXoETzY//dT0yaCQF2J8+eM7vMW+ay0vkBIpxXkR9QmIGF
KIDH4l3txv82X35T5GJP5y9myooT6g==
=Ph6i
-----END PGP SIGNATURE-----

--ajsyed3ibfmsggn6--
