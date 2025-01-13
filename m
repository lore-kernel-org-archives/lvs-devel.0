Received: from stravinsky.debian.org (stravinsky.debian.org [82.195.75.108])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 321101C5F28
	for <lvs-devel@vger.kernel.org>; Mon, 13 Jan 2025 19:25:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=82.195.75.108
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1736796304; cv=none; b=k3RZVhzkKzZpTiSUHOW3QGOnR48+WuCwY3sEZmYh78ilUiDdDDj79Vit3wnPX2bYcZkUdoaJBmNnMe+eTB/pPaWfxCCTTryhq+/mpsXPTpBNvpOLGkWSgpYtGaSwt3U8O4DUQTOFQkfbnfja+hVlZFNjDLDVIOgtKupr1TRVs/c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1736796304; c=relaxed/simple;
	bh=M9g98XTlVletL7U4SsL6UTRVE/COVtYpqCveCDiLRZE=;
	h=From:To:Subject:Date:Message-ID:MIME-Version; b=bHED0FiFhDwQPdwwduXFmU4d9x9rOQRl0S1OANT48jjEsDtj9YtodlfSc8cXzF2chUJXhjAfgBQUy3BZ7AePuyC2B2VDeOsH7xDCxgefRtN945fHzdsP0Ee+v0bAPMsM50ufbFce/ug5U7ewG14uiwNYtdOEvV1NLE/FDbazfxg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org; spf=none smtp.mailfrom=debian.org; dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b=fDv4lNwM; arc=none smtp.client-ip=82.195.75.108
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=debian.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b="fDv4lNwM"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=debian.org;
	s=smtpauto.stravinsky; h=X-Debian-User:Content-Transfer-Encoding:MIME-Version
	:Message-ID:Date:Subject:To:From:Reply-To:Cc:Content-Type:Content-ID:
	Content-Description:In-Reply-To:References;
	bh=HdFgm9b272d2W6ZTSysAVWs/UQoi4zCkReL8dbXn1V4=; b=fDv4lNwMgIrTtoGUihzx62fBPg
	yyBZPy6LbfbHmi+Y6gJdcEXsS5UgD9JwtRYroB6M83H3fxLWhs0uy9N4Lz7RxRD90kzprpFx6kbDA
	hNkhQwRd3so/AylmfDywHDwkCkQiO6TN/doq5o+ASbYkNn1mL/CNHDhWVy9fWGjL/JEY7lgVziwrk
	AZ+rC3duUaLz7c4LC8+6+CUwAcpSRQS+XMDpT9JoWmx9k6iIXPd6+0Zh6fekpH2VDUKkn4MevxZYf
	VrqOR9iAFMrZRaawy7Vc6QElsLDdqrzb27bKPm+9AkxqJmYm5jrMlisA3wpciL7/xM4oVOU/6vmSZ
	KxFJTH9w==;
Received: from authenticated user
	by stravinsky.debian.org with esmtpsa (TLS1.3:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256)
	(Exim 4.94.2)
	(envelope-from <azazel@debian.org>)
	id 1tXQ3X-000JbM-8S
	for lvs-devel@vger.kernel.org; Mon, 13 Jan 2025 19:24:59 +0000
Received: from ulthar.dreamlands.azazel.net ([2001:8b0:fb7d:d6d7:2e4d:54ff:fe4b:a9ae])
	by taras.nevrast.org with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.96)
	(envelope-from <azazel@debian.org>)
	id 1tXQ3W-001Uuz-0s
	for lvs-devel@vger.kernel.org;
	Mon, 13 Jan 2025 19:24:58 +0000
From: Jeremy Sowden <azazel@debian.org>
To: LVS Devel <lvs-devel@vger.kernel.org>
Subject: [PATCH ipvsadm v2 0/5] Debian package fixes
Date: Mon, 13 Jan 2025 19:24:45 +0000
Message-ID: <20250113192450.3302635-1-azazel@debian.org>
X-Mailer: git-send-email 2.45.2
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SA-Exim-Connect-IP: 2001:8b0:fb7d:d6d7:2e4d:54ff:fe4b:a9ae
X-SA-Exim-Mail-From: azazel@debian.org
X-SA-Exim-Scanned: No (on taras.nevrast.org); SAEximRunCond expanded to false
X-Debian-User: azazel

The Debian package of ipvsadm carries a few patches.  Some of them have been
around for years.  None of them is specific to Debian, so I'm forwarding them
upstream.

Patch 1 bumps the maximum weight accepted by ipvsadm.
Patch 2 fixes an unclear usage error message.
Patches 3-5 make some improvements to the Makefiles.

Changes since v1:

* The previous version of patch 2 changed the logic of the option parsing in
  such a way that using `-M` after `-6` no longer worked correctly.  This version 
  just rewords the error message.

Jeremy Sowden (5):
  ipvsadm: increase maximum weight value
  ipvsadm: fix ambiguous usage error message
  Use variable for pkg-config in Makefiles
  Support environmental and command-line `*FLAGS` variable in Makefiles
  Make sure libipvs.a is built before ipvsadm

 Makefile         | 19 +++++++++++--------
 ipvsadm.8        |  2 +-
 ipvsadm.c        |  4 ++--
 libipvs/Makefile | 29 +++++++++++++++--------------
 4 files changed, 29 insertions(+), 25 deletions(-)

-- 
2.45.2

