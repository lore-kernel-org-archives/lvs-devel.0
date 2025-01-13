Received: from stravinsky.debian.org (stravinsky.debian.org [82.195.75.108])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 321B01C7B62
	for <lvs-devel@vger.kernel.org>; Mon, 13 Jan 2025 19:25:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=82.195.75.108
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1736796303; cv=none; b=DDJBrxMjhTwPEJthMh5TCQef5hZMEOg8Yt/A5aIs6d8iIW07y0C7duYU4dahFGs23OiXKMAkLCaDQOFFmwCRBiAQnWGG8RFaaRz7c8UwKZsup2j+3IuTG6luzXOeAg6XpH6qD6MQUToFoH+uN3TnbQPZTE315VokDB+Ar1dodP4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1736796303; c=relaxed/simple;
	bh=+Beei2pa8xBI4e9sVBiRXvb2qXcFLE4qRlemXzOPDe0=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ciKf9EIS4g1qBy0HgNgdXPoSLpuwNDy+YSk8BkqJUDca1R2hknPAlWfi5HjVVYhWIU5LHXoE6l/p2ZVqcWJHjlZYLNNw0XTIqpHlq7b2WBZ3ZscsoBwjVJsD0jPLDPTqyaA0Oxhvqefo6iPI/ZE3sOV6OUE+Gob/anEKmcHhIX8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org; spf=none smtp.mailfrom=debian.org; dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b=OzU1+oCZ; arc=none smtp.client-ip=82.195.75.108
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=debian.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b="OzU1+oCZ"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=debian.org;
	s=smtpauto.stravinsky; h=X-Debian-User:Content-Transfer-Encoding:MIME-Version
	:References:In-Reply-To:Message-ID:Date:Subject:To:From:Reply-To:Cc:
	Content-Type:Content-ID:Content-Description;
	bh=PD/X8iew7OgXoYEZvHUdOKEcH/Xy5h8jGkOetENpahk=; b=OzU1+oCZCgyhzfM9FxDHbwwuAK
	q87qoCYtlo0fQwHQOSXrKkS1H9Lff/6W/AsKzcg+R/RAZvWDxYMoiZjivI9mqMGbi61vGUXeTE+Sk
	+gKmfWjdeQ35DFBLthmmJmpOXBJ09csTu/na3GREdAhUwtiIZjF6ldZAG9eCqhBfsaZcQLt5PXxNQ
	I91lO6TY2apMNF9P21vExsXwmEEezAjuijpKjD1r96sojA0DB/NUFrJbPAh1LuMMSSq9LXF++FY/s
	7INcGiamdF6xraVIVD45PUb8f2yAIcVELE1d81JihF6lnSVAkWyxDG9ocaeSy83KbFBkyNHoGrKn3
	3s2oDenw==;
Received: from authenticated user
	by stravinsky.debian.org with esmtpsa (TLS1.3:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256)
	(Exim 4.94.2)
	(envelope-from <azazel@debian.org>)
	id 1tXQ3X-000JbR-8L
	for lvs-devel@vger.kernel.org; Mon, 13 Jan 2025 19:24:59 +0000
Received: from ulthar.dreamlands.azazel.net ([2001:8b0:fb7d:d6d7:2e4d:54ff:fe4b:a9ae])
	by taras.nevrast.org with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.96)
	(envelope-from <azazel@debian.org>)
	id 1tXQ3W-001Uuz-1d
	for lvs-devel@vger.kernel.org;
	Mon, 13 Jan 2025 19:24:58 +0000
From: Jeremy Sowden <azazel@debian.org>
To: LVS Devel <lvs-devel@vger.kernel.org>
Subject: [PATCH ipvsadm v2 5/5] Make sure libipvs.a is built before ipvsadm
Date: Mon, 13 Jan 2025 19:24:50 +0000
Message-ID: <20250113192450.3302635-6-azazel@debian.org>
X-Mailer: git-send-email 2.45.2
In-Reply-To: <20250113192450.3302635-1-azazel@debian.org>
References: <20250113192450.3302635-1-azazel@debian.org>
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

