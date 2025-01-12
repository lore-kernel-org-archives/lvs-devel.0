Received: from stravinsky.debian.org (stravinsky.debian.org [82.195.75.108])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9BCBC2CAB
	for <lvs-devel@vger.kernel.org>; Sun, 12 Jan 2025 20:04:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=82.195.75.108
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1736712286; cv=none; b=gKMEMRzWb7sMJuajU08shruWLC0CbbEHdbvtp/OfGlv0me8UZwrJejqKynwIZPK/3Y2q+9zQWI3OXEYn4F3cWLEumZ7LHNhSBKqaKaMis6nB1mv/d5APPyHKf4qVyQJLss5ZcrD5KsP1zfbhCwxWSuJqX7HUL2K/o6SI0LbpQJo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1736712286; c=relaxed/simple;
	bh=Auw4N6fDDSC6dS3IXR0ciZKaaden0gg0uBUHY+WKx4g=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=YJt0lJEwI7iaJ4ye2Dm/AdnTAXdaJ3QN84sER4uXoplKMBfxrzDo5EAVAcirQMeo09RXRIYn1J8s+ulbzcZjRS/bQLUEElesF3pVuv8PS0exs3ve170s4hkI0zQPrnMipSnqfsKeHDs9cEHBjwUbyJYZzvdKsjmLZeMkuoXlkeY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org; spf=none smtp.mailfrom=debian.org; dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b=DbN12j3v; arc=none smtp.client-ip=82.195.75.108
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=debian.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b="DbN12j3v"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=debian.org;
	s=smtpauto.stravinsky; h=X-Debian-User:Content-Transfer-Encoding:MIME-Version
	:References:In-Reply-To:Message-ID:Date:Subject:To:From:Reply-To:Cc:
	Content-Type:Content-ID:Content-Description;
	bh=LuoWwOb0wSf4ZEEqhgEKs2VEBV5YX2//HP/+biFdsnE=; b=DbN12j3vKs8i+mYodKXYS0Q/AR
	5/wAlX7rZbDFQPCnC3t7hiLVs8lJbaoKoK6w7pn8xxJSohZGdsAcOt/QuAzBEjFRTpBq3g7f/74xD
	cvGDXS4FnPgieC3fqiQmZQyIPrLfLSm12B0ZxqpXoSc3LvmKp6tRGNUXmz7W1qsH3vDI6tgHwP3/7
	pT4ScaKeGwpdT/cQhtiKxMnSWZrjWwqxQpkw5RDkvlXSRpFDWcFYTQXAJACQspra5EpU+Jp92u1/3
	SRT8CAJcXqkLY0l9Woye0bMgAHgpLMgcACNIND/ikwJwR1K4khfU31tBXpiXEvFtRGZWz6Q+4/XsN
	HMOMWtqQ==;
Received: from authenticated user
	by stravinsky.debian.org with esmtpsa (TLS1.3:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256)
	(Exim 4.94.2)
	(envelope-from <azazel@debian.org>)
	id 1tX4CK-00H6mh-H3
	for lvs-devel@vger.kernel.org; Sun, 12 Jan 2025 20:04:36 +0000
Received: from ulthar.dreamlands.azazel.net ([2001:8b0:fb7d:d6d7:2e4d:54ff:fe4b:a9ae])
	by taras.nevrast.org with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.96)
	(envelope-from <azazel@debian.org>)
	id 1tX4CJ-000H3S-0f
	for lvs-devel@vger.kernel.org;
	Sun, 12 Jan 2025 20:04:35 +0000
From: Jeremy Sowden <azazel@debian.org>
To: LVS Devel <lvs-devel@vger.kernel.org>
Subject: [PATCH ipvsadm 1/5] ipvsadm: increase maximum weight value
Date: Sun, 12 Jan 2025 20:03:29 +0000
Message-ID: <20250112200333.3180808-2-azazel@debian.org>
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

