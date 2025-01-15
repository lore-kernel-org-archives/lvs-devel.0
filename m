Received: from stravinsky.debian.org (stravinsky.debian.org [82.195.75.108])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 875901D63EC
	for <lvs-devel@vger.kernel.org>; Wed, 15 Jan 2025 18:33:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=82.195.75.108
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1736966029; cv=none; b=o4oF45uYR4x+LHECaVB3SenoAAAdIRUq8JuMV0Q1coKXPsFoQNZTG497kbZ2LuGuzPhAGOUlj0uBQvLzJzLTK2tZ3O3Iej+5xAro2ih5iOG+ayyvx1uNIRIUwaFeCuvYlvr/i4Q6jjkBjUcQqQMlzW5EMKaJj6/kEt2CkbDzxrE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1736966029; c=relaxed/simple;
	bh=owscTd4rm/gKmXNWuTK0wRSjrbQnN4AhwN9EglF1n+k=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=XUFEBrxogbhGzkfQFlNRvDjuR+EONGKVc8Th2GvjF08PGsUF1vS9UJbWQaQtolW9jOamOxz7J/tlz4BHGuhD1KOL+K9kwM11++dBazTb8Dx1rWkWfuIEeXAk9djtEr2OwVJ86nLEIrv5ffV9wWbj7ncVCljP9ztTDIeSPg5nZkE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org; spf=none smtp.mailfrom=debian.org; dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b=ux3B7WiN; arc=none smtp.client-ip=82.195.75.108
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=debian.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b="ux3B7WiN"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=debian.org;
	s=smtpauto.stravinsky; h=X-Debian-User:Content-Transfer-Encoding:MIME-Version
	:References:In-Reply-To:Message-ID:Date:Subject:To:From:Reply-To:Cc:
	Content-Type:Content-ID:Content-Description;
	bh=kzE6svUIHvojUqreArs3cT/7JV7zojuUKIyfLdFxUec=; b=ux3B7WiNYZyp3yU8q7cvjQlnaV
	nYgICibMZKzinfj1FBPGCkZrN0b8jXGfPt+PwtLSpJa8k+UGaAR6haDI3+7cCEzBmr0cM6Vg0aKg6
	iCS1EEMp4rR4/VSESV1W3xNpBb+w8+QxNbxxHYKUU9uey5qkB08fyWrHKDFerGow2qNEBmyFK8DCS
	LSrY/ltVBJOqg97L0waCy/DGtYpy7tzT/uEs7afdmde+SbxVDrSTYdS9eyn5sPo5MoQX78vHxPiVX
	kXOYjde+Wbc8e05gUKx2An0fuJPf1WLcb5amic8Erc7OZkUAKCIWv+/cW4U6ePB8K9HKfVUOy6lS3
	BoSKgwCQ==;
Received: from authenticated user
	by stravinsky.debian.org with esmtpsa (TLS1.3:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256)
	(Exim 4.94.2)
	(envelope-from <azazel@debian.org>)
	id 1tY8Cx-001zdL-VK
	for lvs-devel@vger.kernel.org; Wed, 15 Jan 2025 18:33:40 +0000
Received: from ulthar.dreamlands.azazel.net ([2001:8b0:fb7d:d6d7:2e4d:54ff:fe4b:a9ae])
	by taras.nevrast.org with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.96)
	(envelope-from <azazel@debian.org>)
	id 1tY8Cn-000D3I-1N
	for lvs-devel@vger.kernel.org;
	Wed, 15 Jan 2025 18:33:29 +0000
From: Jeremy Sowden <azazel@debian.org>
To: LVS Devel <lvs-devel@vger.kernel.org>
Subject: [PATCH ipvsadm v3 5/5] Make sure libipvs.a is built before ipvsadm
Date: Wed, 15 Jan 2025 18:33:11 +0000
Message-ID: <20250115183311.3386192-6-azazel@debian.org>
X-Mailer: git-send-email 2.45.2
In-Reply-To: <20250115183311.3386192-1-azazel@debian.org>
References: <20250115183311.3386192-1-azazel@debian.org>
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

There is no explicit rule in the top-level Makefile to build libipvs.a.  It
is built by the phony target `libs`.  However, there is no guarantee of the
order in which the prerequisites of the `all` target are built, so make may
attempt to link ipvsadm to libipvs.a before it has finished building
libipvs.a.

Add a rule to express the dependency of `$(STATIC_LIBS)` on `libs`.

Signed-off-by: Jeremy Sowden <azazel@debian.org>
---
 Makefile | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Makefile b/Makefile
index d79f72496000..2dda19072365 100644
--- a/Makefile
+++ b/Makefile
@@ -90,6 +90,8 @@ libs:
 ipvsadm:	$(OBJS) $(STATIC_LIBS)
 		$(CC) $(DEFAULT_CFLAGS) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)
 
+$(STATIC_LIBS): libs
+
 install:        all
 		if [ ! -d $(SBIN) ]; then $(MKDIR) -p $(SBIN); fi
 		$(INSTALL) -m 0755 ipvsadm $(SBIN)
-- 
2.45.2

