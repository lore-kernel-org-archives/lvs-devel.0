Received: from stravinsky.debian.org (stravinsky.debian.org [82.195.75.108])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9BD2F2A8C1
	for <lvs-devel@vger.kernel.org>; Sun, 12 Jan 2025 20:04:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=82.195.75.108
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1736712286; cv=none; b=a9QBua60MKwShtTC9WtRA6e/9WykzpOIXw9SCD1jn40UirGQ1b1pcqiPs/S0yEn91j2QPHnTGikgCoUKRe7Nqhy0j3Y/IBx8mVnR5QxG+Xx2TPOuU8OUnv7ClDgnXN3PhZy/qSQPTAqLz59mOG5pTv+BcvnbmMOZ5l8XjENOuBM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1736712286; c=relaxed/simple;
	bh=32NIhZHWLAvCu6MsRz1W+o/uiU1Ig2bse9rUPmbrKek=;
	h=From:To:Subject:Date:Message-ID:MIME-Version; b=W6Jeoh1if13c7tXWhFPKcRv2Ts98jya1UoDY4Or5XQTn47yogi6dt1pJYJ1sW1TCdnkd8f1LIRJgHalj5uyXY3PQ/mWMfIwgSxqx9nwWKeriW4g2DlG7/t+EmNWScHjMMXFNZGMuk8rf5morvgI+X9wAObraquSd9rEx5Offro8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org; spf=none smtp.mailfrom=debian.org; dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b=dbl42agv; arc=none smtp.client-ip=82.195.75.108
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=debian.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b="dbl42agv"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=debian.org;
	s=smtpauto.stravinsky; h=X-Debian-User:Content-Transfer-Encoding:MIME-Version
	:Message-ID:Date:Subject:To:From:Reply-To:Cc:Content-Type:Content-ID:
	Content-Description:In-Reply-To:References;
	bh=uO1mnxKyKyCRTAOXuNOMPuLIArRgDa2ifs8/cyngpqQ=; b=dbl42agvQcxOsrn3b67maxQ+Sz
	nJDYc8JICGAN+6vLvTY+q4po6L4ps4W58f54Jab1El+Y2xXT4JLv7XeCIbuJcQ/ppnk4bfTyJwtPi
	/7+qRItSD/L6yB+R7A6F6bppkUENiQih1E+FVlkl4gcrbF22X7SR3lU3Q3FuqiEzRKScKhgYtud/M
	89j9cv1av2UcfJiONdvyIRza5MrYDXVYe6R9ygu3D4Eqmu0i/43/2ZPotyoQpwAjTRl4zZyDjkuSU
	dIemfjQyuTX+9QMBJ5m4D7EWl6/iuaApHhcf2xBJparYkJjTjz9I0kABK/AAcGTMAgdDRdCBAbvy7
	Gyj9dylg==;
Received: from authenticated user
	by stravinsky.debian.org with esmtpsa (TLS1.3:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256)
	(Exim 4.94.2)
	(envelope-from <azazel@debian.org>)
	id 1tX4CK-00H6mg-GR
	for lvs-devel@vger.kernel.org; Sun, 12 Jan 2025 20:04:36 +0000
Received: from ulthar.dreamlands.azazel.net ([2001:8b0:fb7d:d6d7:2e4d:54ff:fe4b:a9ae])
	by taras.nevrast.org with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.96)
	(envelope-from <azazel@debian.org>)
	id 1tX4CJ-000H3S-0W
	for lvs-devel@vger.kernel.org;
	Sun, 12 Jan 2025 20:04:35 +0000
From: Jeremy Sowden <azazel@debian.org>
To: LVS Devel <lvs-devel@vger.kernel.org>
Subject: [PATCH ipvsadm 0/5] Debian package fixes
Date: Sun, 12 Jan 2025 20:03:28 +0000
Message-ID: <20250112200333.3180808-1-azazel@debian.org>
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

Jeremy Sowden (5):
  ipvsadm: increase maximum weight value
  ipvsadm: fix ambiguous usage error message
  Use variable for pkg-config in Makefiles
  Support environmental and command-line `*FLAGS` variable in Makefiles
  Make sure libipvs.a is built before ipvsadm

 Makefile         | 19 +++++++++++--------
 ipvsadm.8        |  2 +-
 ipvsadm.c        | 19 +++++++++++--------
 libipvs/Makefile | 29 +++++++++++++++--------------
 4 files changed, 38 insertions(+), 31 deletions(-)

-- 
2.45.2

