Received: from stravinsky.debian.org (stravinsky.debian.org [82.195.75.108])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8DFB61D63F9
	for <lvs-devel@vger.kernel.org>; Wed, 15 Jan 2025 18:33:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=82.195.75.108
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1736966029; cv=none; b=nO0O8ewmDATti7A49Y4/xfDMhmJ7Z9hUARecmMrjA953ChrW80DxA30OlE3Stb92lY0G4XSI3UuaOZxnn1FT+xJTrlXw2/qBfoTjt4RdDDK6FLpnbVKPGF+j4YsrzRvSXZhLXIz8bUWH0jYvXkZWaVsxJaLXnZ3RWX8sVJsLv/0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1736966029; c=relaxed/simple;
	bh=MBNBD9utT1iUzOW88KQUi/YdduqG2srWbICTuogTIs0=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=aOPNi8dvaYD6T4kFx6ALortw75mQA8PkJP7nfdJV7UnSH8Vo3q4zA6sMhysYsbP5H4Ic7TLET1EIFy9MPdgPmPMHRVvEFyyDvwNN2U3fuJxKXUR/t9+OPXfRO+ttM4HGtnEjVW+/DTcwrosa3kuPbi+Ogqp2/Ow0WLoOMGggNvE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org; spf=none smtp.mailfrom=debian.org; dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b=KekFRvBq; arc=none smtp.client-ip=82.195.75.108
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=debian.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b="KekFRvBq"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=debian.org;
	s=smtpauto.stravinsky; h=X-Debian-User:Content-Transfer-Encoding:MIME-Version
	:References:In-Reply-To:Message-ID:Date:Subject:To:From:Reply-To:Cc:
	Content-Type:Content-ID:Content-Description;
	bh=piaBvGt8fEC0FXKaF8yH4epboCiQ2Yfqvdqol7NaZls=; b=KekFRvBqPodwSg8MHdO7nrSA5R
	EnDXgT9tGkPdc2/dgu6SSpZNgsJ2pNPJ6OSaI/8lCDY2yOMPnVHbYHyZ1zq+UfGFds2w8Kvj1amug
	NJb9TD0fEzb+/nsTyLZyIezacNYmdlYEvhs8Z6bJCnYpkektfwPh0XMilp5Gtq1k17WyQzLv3nEKu
	RhPwuNoxnsNWKpeuLtVzM4csy2pNH4BXy9hN5FVJC1IEGfNxxl41vxSt1hxhiL4xgNO2BzjTJ2U8K
	Xt+okkzi7p5PEKvhqJb3VGcBSzafYY310gpjDx2XcCA3Sw8ujZ9hln4tIZuKJxuf+qTuFoCJvz+iP
	g9k4M1Qg==;
Received: from authenticated user
	by stravinsky.debian.org with esmtpsa (TLS1.3:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256)
	(Exim 4.94.2)
	(envelope-from <azazel@debian.org>)
	id 1tY8Cx-001zdJ-R6
	for lvs-devel@vger.kernel.org; Wed, 15 Jan 2025 18:33:39 +0000
Received: from ulthar.dreamlands.azazel.net ([2001:8b0:fb7d:d6d7:2e4d:54ff:fe4b:a9ae])
	by taras.nevrast.org with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.96)
	(envelope-from <azazel@debian.org>)
	id 1tY8Cn-000D3I-0x
	for lvs-devel@vger.kernel.org;
	Wed, 15 Jan 2025 18:33:29 +0000
From: Jeremy Sowden <azazel@debian.org>
To: LVS Devel <lvs-devel@vger.kernel.org>
Subject: [PATCH ipvsadm v3 3/5] Use variable for pkg-config in Makefiles
Date: Wed, 15 Jan 2025 18:33:09 +0000
Message-ID: <20250115183311.3386192-4-azazel@debian.org>
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

Replace hard-coded `pkg-config` with a variable to allow it to be
overridden, which is helpful for cross-building.

Link: https://bugs.debian.org/901275
Signed-off-by: Jeremy Sowden <azazel@debian.org>
---
 Makefile         |  9 +++++----
 libipvs/Makefile | 17 +++++++++--------
 2 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/Makefile b/Makefile
index 91a2991f6746..d247d4075160 100644
--- a/Makefile
+++ b/Makefile
@@ -36,6 +36,7 @@ RPMSOURCEDIR	= $(shell rpm --eval '%_sourcedir')
 RPMSPECDIR	= $(shell rpm --eval '%_specdir')
 
 CC		= gcc
+PKG_CONFIG	?= pkg-config
 INCLUDE		=
 SBIN		= $(BUILD_ROOT)/sbin
 MANDIR		= usr/man
@@ -66,10 +67,10 @@ OBJS		= ipvsadm.o config_stream.o dynamic_array.o
 LIBS		= -lpopt
 ifneq (0,$(HAVE_NL))
 LIBS		+= $(shell \
-		if which pkg-config > /dev/null 2>&1; then \
-		  if   pkg-config --libs libnl-genl-3.0  2> /dev/null; then :;\
-		  elif pkg-config --libs libnl-2.0       2> /dev/null; then :;\
-		  elif pkg-config --libs libnl-1         2> /dev/null; then :;\
+		if which $(PKG_CONFIG) > /dev/null 2>&1; then \
+		  if   $(PKG_CONFIG) --libs libnl-genl-3.0  2> /dev/null; then :;\
+		  elif $(PKG_CONFIG) --libs libnl-2.0       2> /dev/null; then :;\
+		  elif $(PKG_CONFIG) --libs libnl-1         2> /dev/null; then :;\
 		  fi; \
 		else echo "-lnl"; fi)
 endif
diff --git a/libipvs/Makefile b/libipvs/Makefile
index f845c8b1675b..b31c8eac514d 100644
--- a/libipvs/Makefile
+++ b/libipvs/Makefile
@@ -1,14 +1,15 @@
 # Makefile for libipvs
 
 CC		= gcc
+PKG_CONFIG	?= pkg-config
 CFLAGS		= -Wall -Wunused -Wstrict-prototypes -g -fPIC
 ifneq (0,$(HAVE_NL))
 CFLAGS		+= -DLIBIPVS_USE_NL
 CFLAGS		+= $(shell \
-		if which pkg-config > /dev/null 2>&1; then \
-		  if   pkg-config --cflags libnl-3.0  2> /dev/null; then :; \
-		  elif pkg-config --cflags libnl-2.0  2> /dev/null; then :; \
-		  elif pkg-config --cflags libnl-1    2> /dev/null; then :; \
+		if which $(PKG_CONFIG) > /dev/null 2>&1; then \
+		  if   $(PKG_CONFIG) --cflags libnl-3.0  2> /dev/null; then :; \
+		  elif $(PKG_CONFIG) --cflags libnl-2.0  2> /dev/null; then :; \
+		  elif $(PKG_CONFIG) --cflags libnl-1    2> /dev/null; then :; \
 		  fi; \
 		fi)
 endif
@@ -17,10 +18,10 @@ INCLUDE		+= $(shell if [ -f ../../ip_vs.h ]; then	\
 		     echo "-I../../."; fi;)
 DEFINES		= $(shell if [ ! -f ../../ip_vs.h ]; then	\
 		    echo "-DHAVE_NET_IP_VS_H"; fi;)
-DEFINES		+= $(shell if which pkg-config > /dev/null 2>&1; then \
-			 if   pkg-config --exists libnl-3.0; then :; \
-			 elif pkg-config --exists libnl-2.0; then :; \
-			 elif pkg-config --exists libnl-1; \
+DEFINES		+= $(shell if which $(PKG_CONFIG) > /dev/null 2>&1; then \
+			 if   $(PKG_CONFIG) --exists libnl-3.0; then :; \
+			 elif $(PKG_CONFIG) --exists libnl-2.0; then :; \
+			 elif $(PKG_CONFIG) --exists libnl-1; \
 			 then echo "-DFALLBACK_LIBNL1"; fi; fi)
 
 .PHONY		= all clean install dist distclean rpm rpms
-- 
2.45.2

