Received: from stravinsky.debian.org (stravinsky.debian.org [82.195.75.108])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8B1341D63F0
	for <lvs-devel@vger.kernel.org>; Wed, 15 Jan 2025 18:33:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=82.195.75.108
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1736966029; cv=none; b=ZbS+50CSURPsf9pgeoVMIy9UeIyNArCWRpQU+XYfO5raRFnZPf/mgDH1YoKOqVeorR3s86yeqoJL4+r0Fntc2TlyrH2eCziNNBLlY2Y8EFVSoAAwrccuvN5eW1vpIODu1C4xPXHCFcK8rBPt79fn6ESyA+yvv6g/NZGC9wLC5AM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1736966029; c=relaxed/simple;
	bh=q5bEoJxOg4b8/1hlcLA0HcpKu4MUeBRItLXdrT6IxXo=;
	h=From:To:Subject:Date:Message-ID:MIME-Version; b=UY2xqosAHfDVkmw0F4QGZOiXvwGboTHnaRIAttq3a7s1cNTig4vLVG7gydZTBLgxtrRrZrU3w4BwTeEz3ZYINPTrxnNHpuKozEteeXa+QFOExDIb9sG412aew0XWw5qHo30wOAicskyfCNt0LzJsN6tsqaTX7yFJrfnxkx9A83A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org; spf=none smtp.mailfrom=debian.org; dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b=HOKrqfw8; arc=none smtp.client-ip=82.195.75.108
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=debian.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b="HOKrqfw8"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=debian.org;
	s=smtpauto.stravinsky; h=X-Debian-User:Content-Transfer-Encoding:MIME-Version
	:Message-ID:Date:Subject:To:From:Reply-To:Cc:Content-Type:Content-ID:
	Content-Description:In-Reply-To:References;
	bh=NhMGjzWsdMeHTWR4GSyfV/cVY17nG1iqd4v3fahT25E=; b=HOKrqfw8qHxrRIoOUwFE9Pl9R5
	pYunY9xaVctYwq/g6FFbn3uTk8rX97H9Wz2wiCjAcJ1XpANV9LwOTRZismrvN0UUR4iokRxRNxC60
	nVvaZx4wLSw/Ja5VK5k7gkbFuyWnRY0qEx9PlRr+HNsbBaCdrPxx4PBXr1r01OuKm3jEhuEWoPyr5
	oyCPHC4qcFXgPelNckOkmMqWsBk0zW3UDakv1YedEK8SyDEKI1hoSasfKsP4ZeDleOlgUB1PBTOmb
	z1VoGwPhxDFlBZ7q0p0THBlfCqAaMKaWseciffxi14ZE6zfgXuz0trh/N7fNY/LkqFmcc/y2moZrj
	3jkZjOnA==;
Received: from authenticated user
	by stravinsky.debian.org with esmtpsa (TLS1.3:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256)
	(Exim 4.94.2)
	(envelope-from <azazel@debian.org>)
	id 1tY8Cx-001zdE-WC
	for lvs-devel@vger.kernel.org; Wed, 15 Jan 2025 18:33:40 +0000
Received: from ulthar.dreamlands.azazel.net ([2001:8b0:fb7d:d6d7:2e4d:54ff:fe4b:a9ae])
	by taras.nevrast.org with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.96)
	(envelope-from <azazel@debian.org>)
	id 1tY8Cn-000D3I-0V
	for lvs-devel@vger.kernel.org;
	Wed, 15 Jan 2025 18:33:29 +0000
From: Jeremy Sowden <azazel@debian.org>
To: LVS Devel <lvs-devel@vger.kernel.org>
Subject: [PATCH ipvsadm v3 0/5] Debian package fixes
Date: Wed, 15 Jan 2025 18:33:06 +0000
Message-ID: <20250115183311.3386192-1-azazel@debian.org>
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

The Debian package of ipvsadm carries a few patches.  Some of them have
been around for years.  None of them is specific to Debian, so I'm
forwarding them upstream.

Patch 1 bumps the maximum weight accepted by ipvsadm.
Patch 2 fixes an unclear usage error message.
Patches 3-5 make some improvements to the Makefiles.

Changes since v2:

* Reformat the commit messages of patches 1, 2 & 5 according to the
  kernel's preferred patch format.

Changes since v1:

* The previous version of patch 2 changed the logic of the option parsing
  in such a way that using `-M` after `-6` no longer worked correctly.
  Thisversion just rewords the error message.

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

