Received: from mail-ed1-f53.google.com (mail-ed1-f53.google.com [209.85.208.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1E9CE3AFCE6
	for <lvs-devel@vger.kernel.org>; Sun, 23 Aug 2026 22:12:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.53
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787523166; cv=none; b=fpbTR7CjAT5DzknrgbeF9HPggbyutMqLFQ/rqPpoybGIq5zLGyER+O81tvuELrYTPtC3hWFsEs/ByBdL9UTsF8bTDwLMAo7Fo695XWLnSFIEArHKDgjU5aOnwi/+mhsbRC6bK5NVvyaCRD66HR69ZgRIu8+iEemdwBTYtbKBgaA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787523166; c=relaxed/simple;
	bh=GqPg7liRNMqrm8j4qggfPJWb6w6iifsnP6+v+SgJcSk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Tktkz8hN48s+x/SYH6gt1WgyQW13pnCJIXiCAYHqqh6EpBLjxbBIBSUeBXaHmVEaunLoZl3+1bC5N4ewd6lRKNRm+esywWl7Mpvou7Pw+MT/IpJKEHqUOcdCX56Fnjny2lolgmcmuUb4jncF0/EB4dR8RTH1zsNk7n4o0e3lfgo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=baylibre.com; spf=pass smtp.mailfrom=baylibre.com; dkim=pass (2048-bit key) header.d=baylibre.com header.i=@baylibre.com header.b=HtAiPHmN; arc=none smtp.client-ip=209.85.208.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=baylibre.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=baylibre.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=baylibre.com header.i=@baylibre.com header.b="HtAiPHmN"
Received: by mail-ed1-f53.google.com with SMTP id 4fb4d7f45d1cf-6a0c8283146so4834043a12.0
        for <lvs-devel@vger.kernel.org>; Sun, 23 Aug 2026 15:12:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=baylibre.com; s=google; t=1787523160; x=1788127960; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=//7iEXuM0dwaErrYwlxiIsbco7Xb10BSWAJJRQqIeEQ=;
        b=HtAiPHmN2cDwcdR57+nVPm79Bqmt5EFmrechceL9eOdPqvtm7XlhCdN90EfvrYvC30
         xyiSqLbWFXgRVJ2uF7cDWOuOSFM/OtpL9Jq06wbBN9U7hl0Z1+3VDXlwRWJA1JGakqoF
         GF5k0u5gF97lYRquh2NIOw3Jj6kZTKKJbn9W1dujbFmfFlYKMGyWLz7i98bVU34bfhD9
         FKug+jvyVP1TCFBby0MAFYlfcWF7S2nPMhtwgA1iLzf7NwHw5j3a3vdbQVKQGzaaeqVE
         UAmGHSVqkpdxdl8cqRT18mdu9gBcHZrbPXo/N9A9zPnVIflAQ5qUJyxZlOEMu5wwzbod
         89ng==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787523160; x=1788127960;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=//7iEXuM0dwaErrYwlxiIsbco7Xb10BSWAJJRQqIeEQ=;
        b=fWLAOv/h/GtWFk21alu0KvbscK7an4+8EurpIE4HY61PSpoUr221zhBc61qmHWUnV8
         eY/Q3T0ejSNXdjqQnsi8KSlVLGfMgsLI+6APG7ZaYnaeU/VpQivpgJK9QAyVoDbHDqLA
         EcOEtyZAPsg8swOGVKVE+aH49nNVWjYQwCjRp7iY9a19xsVsP+BthEHhLPcjoZgTvRwI
         GFfMZ6seEr/3E0BbJ005lH0DxqbU3QY0C47sSqRIfwR1Zs50PWJuyJ3A8iBMjynOUGHs
         amyQGf1YnAmoT9nz16TRsOstr4PnitLKHmmtqsuXU14imKEl8FS+Dm3E/GBfgwABW5hs
         M1Ew==
X-Forwarded-Encrypted: i=1; AHgh+RrpaDWIgq8vOXkymLSADMuLl3YC5cYCv5r9J0L7J9G83OIdTudUYClRpIlnucOPLFcXmkD5OSiaK/E=@vger.kernel.org
X-Gm-Message-State: AFuF++khI2WXhQ2t7IWZUy58JCHIUZ+ovCJQPU8Rczz7lSESdFq+Fu8s
	xBoY+qzVDkIheHqOKxnyB5C3qYvgT0CFxvsk/GzRJEZ6lyFBrPq8syQx/CzpbhoR4So=
X-Gm-Gg: AR+sD13EanaA9DJPpE+OE20q4qae/L0/xOFHKLt2+oFiondnS8/IH49UtbkmepwE9mF
	bXkd2/R848Tgp2oNbAKv4jEogneX/ErLig5EtePZTG2rFjMmLUXVuDTtGmgyp+UufCdJ/BAUwgb
	QaXsyi6zwIYEsJ2c6Ut4Ul9zEPFciRuWr8d3SRq7hA5ippNA2+PSAfNHiz32UMardYXT7DoTr2w
	AtHL8glih6qy9CxG4SMbgR0vUDFWygywVCd93iG0XD2N57R75L9sbYGMXHGsfH+/V2iG/7qQhrm
	5jLwav1cCBzdhcqxYyYZej3F5Z7HcfU/oIFc78QW2wztQHw/iY0efgPLwPgHgkh/makJZtCGzOy
	lEzaYIcUxKs14jjN5JnboSAp9AgGwAmvISbm/BhbcA26X5zJYeIt0OBXKrOUolBfn01U136Wo2M
	BGVchMOp1jAFYoZIiDlQv6GkehkUytpXTeaWL7XzFlQ4jRR4u5DmNem279zb/223W2OZDnNc0Qf
	sIP
X-Received: by 2002:a05:6402:505b:b0:69c:811f:8f5 with SMTP id 4fb4d7f45d1cf-6a42f1b9325mr25356134a12.6.1787523160405;
        Sun, 23 Aug 2026 15:12:40 -0700 (PDT)
Received: from localhost ([2a02:8071:56d1:2de0:1d24:d58d:2b65:c291])
        by smtp.gmail.com with UTF8SMTPSA id 4fb4d7f45d1cf-6a59e00108asm7547158a12.2.2026.08.23.15.12.39
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 23 Aug 2026 15:12:39 -0700 (PDT)
Date: Mon, 24 Aug 2026 00:12:38 +0200
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
Message-ID: <aotteDcc588iwC6g@monoceros>
References: <20260819-sysctl-module-aliases-v3-0-aab90569365d@igalia.com>
 <20260819-sysctl-module-aliases-v3-3-aab90569365d@igalia.com>
 <aomlfGJM61qZKxx2@monoceros>
 <4e3eaf1d3419e808be046035f114bf6c@igalia.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="6dsww6grbwx7uy7i"
Content-Disposition: inline
In-Reply-To: <4e3eaf1d3419e808be046035f114bf6c@igalia.com>


--6dsww6grbwx7uy7i
Content-Type: text/plain; protected-headers=v1; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH RFC v3 03/13] sysctl, mod_devicetable: add macro
 MODULE_SYSCTL_TABLE
MIME-Version: 1.0

Hello Mauricio,

On Sat, Aug 22, 2026 at 01:57:24PM -0300, Mauricio Faria de Oliveira wrote:
> On 2026-08-22 10:41, Uwe Kleine-K=F6nig wrote:
> > On Wed, Aug 19, 2026 at 03:16:16PM -0300, Mauricio Faria de Oliveira wr=
ote:
> >> The MODULE_SYSCTL_TABLE macro emits a struct module_sysctl_table varia=
ble
> >> with pointers to a sysctl table's path and entries, and table/entry si=
zes.
> >=20
> > That new struct doesn't seem to contain any pointer?
>=20
> The struct module_sysctl_table fields .path and .table are pointers,
> although with kernel_ulong_t type so that the same 32/64-bit size is
> used in file2alias.c based on KERNEL_ELFCLASS (and not on the host,
> which might differ with CROSS_COMPILE).

Cross compilation isn't an issue for the already existing device id
structures; many of them also contain pointers.
(While modpost doesn't use the pointers, the size of the structures must
be known to correctly interpret the arrays.)
Also sizeof(long) differs between architectures and I can compile for
arm(32) just fine on amd64.

Additionally there is hardware out there that has sizeof(void *) =3D 16
but sizeof(long) =3D 8. Up until recently I worked on mainlining that (and
it has business reasons only I stopped, so I guess and hope I will
continue at some point in the future). See
https://lwn.net/Articles/1037974/ for some details if you're interested.

I would be great if your series didn't introduce a new obstacle for
that.

> >> That symbol will be handled by file2alias.c (modpost) with the changes=
 in
> >> mod_devicetable.h and devicetable-offsets.c.
> >>=20
> >> The option macros MODULE_SYSCTL_TABLE_{DISABLE,UNIQUE_ID} can be used =
on
> >> a per-file basis to disable the macro and change the symbol name patte=
rn.
> >>=20
> >> Signed-off-by: Mauricio Faria de Oliveira <mfo@igalia.com>
> >> ---
> >>  include/linux/mod_devicetable.h   |  7 +++++++
> >>  include/linux/sysctl.h            | 42 ++++++++++++++++++++++++++++++=
+++++++++
> >>  scripts/mod/devicetable-offsets.c |  6 ++++++
> >>  3 files changed, 55 insertions(+)
> >=20
> > Please put the new struct in a separate header. Apart from not being
> > about a device table, I'm currently work on removing
> > <linux/mod_devicetable.h>. See commit
> > ad428f5811bd7fb3d91fa002174de533f9da94d7 for more details.
>=20
> Sure; I looked at that earlier (thanks for the instructive commit
> message, by the way) and found the new struct to be similar to "struct
> cpu_feature isn't really a device_id struct" (not moved), but apparently
> missed the trailing "fow now", which is clearer now. Fixed for v4.

Yeah, I didn't move that because it was an outlier in the header as it's
not a device id. IMHO it should go to something like
include/linux/cpu_feature.h.

Best regards
Uwe

--6dsww6grbwx7uy7i
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEP4GsaTp6HlmJrf7Tj4D7WH0S/k4FAmqLcFMACgkQj4D7WH0S
/k74fgf+L2E+C5s7/Uv60MggM8SluqqYOIYVRQMrJ0YZ292Po2lSpcrxuhUuQU2B
oXhO4fsc1HgZsK331x/O/bMuTOPLltQaKOsxLiMi24UglNQqmujyzSUFLnsr9NlL
1xjI1icd6tMaie8k1PK7ynotnvtfYE9Fbl/52MAUgNFbTbWqnaXhNv+fzm/C72Cc
xjp+GuDi0DimbriiFBYP3aUccUEUCgsrwh3Zwss3iQSaV2gZ3Y+jYlUBB3YlBSZQ
+m5a8ZWC4FeqCD+8NXyqc01adbOF9gkilqmoa2KsUhRY9+jPqn0pQhpfPxEl6Lf9
/YNG96sk855Er0BHcQ1R8Pg+AcsRrg==
=t37g
-----END PGP SIGNATURE-----

--6dsww6grbwx7uy7i--
