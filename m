Received: from stravinsky.debian.org (stravinsky.debian.org [82.195.75.108])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9BDF414A614
	for <lvs-devel@vger.kernel.org>; Sun, 12 Jan 2025 20:04:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=82.195.75.108
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1736712287; cv=none; b=EN002RMdPYthSGYa4kxPJtaab2T/5iQOl8XesO0JYxjwZhjZ1D/gO12qMxQDo4/yOs+Pw4YG1oQGjrnQD1VLelBV5cRNVJnczgMnGkWAy8a3s10TCicAetsE/U+thaDf8+JtlU9862swjGszUJ2tLsj3FlJ7U+wW4D03CTrOPjg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1736712287; c=relaxed/simple;
	bh=+Beei2pa8xBI4e9sVBiRXvb2qXcFLE4qRlemXzOPDe0=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=D16Tfi4J6uw8cT06zZ71cSLncEbf7KoWbOYchmn3Q2RPVI/eLfs5rxnal9Vmvfd40jjUrhEWj+iXKWF096IIx89/7i+yHryfkOq1QfAtkV4ATVMD7KbrQoBmXn8fdsr+ZII0fnLp9wsxvkeodVQaYPgNvbXhLfl0UZAkCSvL+Rw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org; spf=none smtp.mailfrom=debian.org; dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b=Msv6RbLY; arc=none smtp.client-ip=82.195.75.108
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=debian.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b="Msv6RbLY"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=debian.org;
	s=smtpauto.stravinsky; h=X-Debian-User:Content-Transfer-Encoding:MIME-Version
	:References:In-Reply-To:Message-ID:Date:Subject:To:From:Reply-To:Cc:
	Content-Type:Content-ID:Content-Description;
	bh=PD/X8iew7OgXoYEZvHUdOKEcH/Xy5h8jGkOetENpahk=; b=Msv6RbLYuvBRjEJkyxt1PJ9r0U
	s36ytBh/5Nb+Z+PRxmgNXoF0lih3fDoc9i5R1rM5Q6t3uagatoPG9VHetyFEm8xsLn8VeUc8WkHdy
	8vrdB041g2a7rLY0G+9qONPLtUm+m/KlRXg8aYW+/eX+fEnZeoehX6zNynL1H7ZPzprLvo3d7YwGd
	cZfATl1iaLGf8uI2OwAUoG2r4x/A2cbGoe/MQ5FFY2KNt3HugIwORqu+vveSj+1GtI8al8Sf7RN8n
	kErn7GNJrsxtzrACZQUNqaz0O8lF3MV62f1jcLNqtklmjC4LE8P5P3jgahnwNKbkIPBz2zTzGy+Am
	xU2uuyoA==;
Received: from authenticated user
	by stravinsky.debian.org with esmtpsa (TLS1.3:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256)
	(Exim 4.94.2)
	(envelope-from <azazel@debian.org>)
	id 1tX4CK-00H6ml-JO
	for lvs-devel@vger.kernel.org; Sun, 12 Jan 2025 20:04:36 +0000
Received: from ulthar.dreamlands.azazel.net ([2001:8b0:fb7d:d6d7:2e4d:54ff:fe4b:a9ae])
	by taras.nevrast.org with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.96)
	(envelope-from <azazel@debian.org>)
	id 1tX4CJ-000H3S-1F
	for lvs-devel@vger.kernel.org;
	Sun, 12 Jan 2025 20:04:35 +0000
From: Jeremy Sowden <azazel@debian.org>
To: LVS Devel <lvs-devel@vger.kernel.org>
Subject: [PATCH ipvsadm 5/5] Make sure libipvs.a is built before ipvsadm
Date: Sun, 12 Jan 2025 20:03:33 +0000
Message-ID: <20250112200333.3180808-6-azazel@debian.org>
X-Mailer: git-send-email 2.45.2
In-Reply-To: <20250112200333.3180808-1-azazel@debian.org>
References: <20250112200333.3180808-1-azazel@debian.org>
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

There is no explicit rule in the top-level Makefile to build libipvs.a.  It is
built by the phony target `libs`.  However, there is no guarantee of the order
in which the prerequisites of the `all` target are built, so make may attempt to
link ipvsadm to libipvs.a before it has finished building libipvs.a.

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

