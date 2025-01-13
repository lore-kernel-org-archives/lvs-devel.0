Received: from stravinsky.debian.org (stravinsky.debian.org [82.195.75.108])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3204B1C5F20
	for <lvs-devel@vger.kernel.org>; Mon, 13 Jan 2025 19:25:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=82.195.75.108
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1736796303; cv=none; b=Li+tyvmvdsLW3ejejlhDCSHXKmesIvSlyiKFs9HaTtWNmX7oyIc8M8bl6HZT//NHQmRPe4l+76Mi7XhQnIYef3r2cfQlkEeT5EaxWbzezEP/NyD4WVCnuBxhCPc7kERfbDZgiyG+bo/Vc7Uni4ZiSIiN4InwUEL0n7R1BBmm/MI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1736796303; c=relaxed/simple;
	bh=Auw4N6fDDSC6dS3IXR0ciZKaaden0gg0uBUHY+WKx4g=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=DSZMPk8nV7uKwjn6gvBLnYf7BJnxcpM4srdUYVr3+zTjGSQXthvqKGryZcUUlLguCOhvJM312oSPRurBnVIas579AelvzpRFahRQn3LDEhV2+oLRfqG53JwqjdN0j3rgCov2F2b7Bu5NNmWwnLbGrcCeDE17UD6CnCmoQbmftIc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org; spf=none smtp.mailfrom=debian.org; dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b=UXUn85mO; arc=none smtp.client-ip=82.195.75.108
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=debian.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b="UXUn85mO"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=debian.org;
	s=smtpauto.stravinsky; h=X-Debian-User:Content-Transfer-Encoding:MIME-Version
	:References:In-Reply-To:Message-ID:Date:Subject:To:From:Reply-To:Cc:
	Content-Type:Content-ID:Content-Description;
	bh=LuoWwOb0wSf4ZEEqhgEKs2VEBV5YX2//HP/+biFdsnE=; b=UXUn85mOvIwq1aEipmlcQB1F7f
	tAm7ZpoCAMWffO0zh+PjR3BRL871rqSt6cTvwk/K4jqAqRnsdEJSJQrsR3510qNFkT2k3RC/rZo34
	DOb1QqEot57jp9zsz273zDC/4CYfzk8Ww/1vuwfG4kDGaaFoLgPD8ri6jCOqV0FtZGZ2IhCdGpnVF
	NUTJMP0yBdLEUKNE0pNtEyjEWsrSrKBPP9VyJTYTuSX3/SCx9kZENu/hk90uKyzDpUMHHrVaDjmjr
	LFvwpSJCjb+kvBwycsdgHozWvcnC6fD9G/xCT0/jwQ/IIZb8AXpnR6snENU7RmmejB0JhOnFcEvgj
	43YrF/Ag==;
Received: from authenticated user
	by stravinsky.debian.org with esmtpsa (TLS1.3:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256)
	(Exim 4.94.2)
	(envelope-from <azazel@debian.org>)
	id 1tXQ3X-000JbN-5P
	for lvs-devel@vger.kernel.org; Mon, 13 Jan 2025 19:24:59 +0000
Received: from ulthar.dreamlands.azazel.net ([2001:8b0:fb7d:d6d7:2e4d:54ff:fe4b:a9ae])
	by taras.nevrast.org with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.96)
	(envelope-from <azazel@debian.org>)
	id 1tXQ3W-001Uuz-11
	for lvs-devel@vger.kernel.org;
	Mon, 13 Jan 2025 19:24:58 +0000
From: Jeremy Sowden <azazel@debian.org>
To: LVS Devel <lvs-devel@vger.kernel.org>
Subject: [PATCH ipvsadm v2 1/5] ipvsadm: increase maximum weight value
Date: Mon, 13 Jan 2025 19:24:46 +0000
Message-ID: <20250113192450.3302635-2-azazel@debian.org>
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

The IPVS kernel module accepts weight up to 2,147,483,647 (INT_MAX), but ipvsadm
limits it to 65,535.  Raise the user space maximum to match the kernel.

Link: https://bugs.debian.org/814348
Signed-off-by: Jeremy Sowden <azazel@debian.org>
---
 ipvsadm.8 | 2 +-
 ipvsadm.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ipvsadm.8 b/ipvsadm.8
index b3bc822aaafc..3d7541a4bf62 100644
--- a/ipvsadm.8
+++ b/ipvsadm.8
@@ -386,7 +386,7 @@ servers are added or modified.
 .B -w, --weight \fIweight\fP
 \fIWeight\fP is an integer specifying the capacity  of a server
 relative to the others in the pool. The valid values of \fIweight\fP
-are 0 through to 65535. The default is 1. Quiescent servers are
+are 0 through to 2147483647. The default is 1. Quiescent servers are
 specified with a weight of zero. A quiescent server will receive no
 new jobs but still serve the existing jobs, for all scheduling
 algorithms distributed with the Linux Virtual Server. Setting a
diff --git a/ipvsadm.c b/ipvsadm.c
index 663d47ab1138..42f31a20e596 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -762,7 +762,7 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 		case 'w':
 			set_option(options, OPTC_WEIGHT);
 			if ((ce->dest.weight =
-			     string_to_number(optarg, 0, 65535)) == -1)
+			     string_to_number(optarg, 0, INT_MAX)) == -1)
 				fail(2, "illegal weight specified");
 			break;
 		case 'x':
-- 
2.45.2

