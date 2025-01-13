Received: from stravinsky.debian.org (stravinsky.debian.org [82.195.75.108])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 450DA1C8FB5
	for <lvs-devel@vger.kernel.org>; Mon, 13 Jan 2025 19:25:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=82.195.75.108
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1736796303; cv=none; b=tXFBSAXVzTyw7ogGFvcDZG/0O3/88eZe3CJTRYZh/VbXP3S3udkJrxofuNzCqgzbuAzl1DLTu0QbIizcscGf+8NIosfeTGbvmJv78OSumiNU2bq6jZGehqf+X2FckqLkQN8vFIEOHIgbumrXaNp7N7VPetWmjvF1Lo/Ygk5pRBY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1736796303; c=relaxed/simple;
	bh=hWkL+9pPKsAHFjOk/uA/+I1XCsohmMErVb9w8C1SF00=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=oZ6GS2hq7oefGZUrSlJZNA7aR4agRSUIPUhZB6zCuqXSoAQV4KKbIBvGK2z9riXJlf0Si2zxZrKMKhLVEgTBkPvsivkyD989mqg6M1WGzfSByHWI6c/J85+qanpAdcWGsdheUf8CdG9u2xM4VQ808mWsKqipD5Wc6nT0i+O27Lk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org; spf=none smtp.mailfrom=debian.org; dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b=oaHs1n/8; arc=none smtp.client-ip=82.195.75.108
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=debian.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b="oaHs1n/8"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=debian.org;
	s=smtpauto.stravinsky; h=X-Debian-User:Content-Transfer-Encoding:MIME-Version
	:References:In-Reply-To:Message-ID:Date:Subject:To:From:Reply-To:Cc:
	Content-Type:Content-ID:Content-Description;
	bh=9ffuQdHVf+24u+R9nlOmg+H2CPISo0TrH4Ft6ql9bgg=; b=oaHs1n/8XF3lcStUyAMsk/Txhx
	O1QTCuvv3YFj9lJVY7caovnf0thp4mvP4HkC/VDl28Qrq8UMptXXXWSeSz9brTsQ79w/KPhOnrVVa
	2nO6e4BAGwuTBNTY3ADzmG1O6FeqWA4Qo0yrao9l2XA0KHaMf6I+NZwQKd0RVZXbHjDT4lh0mX0OE
	6NRUx1+3FJyMOGcOFbfb0lxBuy4seBaGjmS5CoXIvzXCF0NER8WO55woowedAG+oFnqI52E+d5Lsk
	5FheHgGW2wEneKfjVn0TsK0MM0GbtE6vqOdOfevFkB+sc6M92Tl+95SdJQd8dgpofPAdCfdk2vOkA
	oNsyllXw==;
Received: from authenticated user
	by stravinsky.debian.org with esmtpsa (TLS1.3:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256)
	(Exim 4.94.2)
	(envelope-from <azazel@debian.org>)
	id 1tXQ3X-000JbO-8t
	for lvs-devel@vger.kernel.org; Mon, 13 Jan 2025 19:24:59 +0000
Received: from ulthar.dreamlands.azazel.net ([2001:8b0:fb7d:d6d7:2e4d:54ff:fe4b:a9ae])
	by taras.nevrast.org with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.96)
	(envelope-from <azazel@debian.org>)
	id 1tXQ3W-001Uuz-1A
	for lvs-devel@vger.kernel.org;
	Mon, 13 Jan 2025 19:24:58 +0000
From: Jeremy Sowden <azazel@debian.org>
To: LVS Devel <lvs-devel@vger.kernel.org>
Subject: [PATCH ipvsadm v2 2/5] ipvsadm: fix ambiguous usage error message
Date: Mon, 13 Jan 2025 19:24:47 +0000
Message-ID: <20250113192450.3302635-3-azazel@debian.org>
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

If `-6` is used without `-f`, the usage error message is "-6 used before -f",
which can be misconstrued as warning that both options were used but in the
wrong order.  Reword it.

Link: http://bugs.debian.org/610596
Signed-off-by: Jeremy Sowden <azazel@debian.org>
---
 ipvsadm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ipvsadm.c b/ipvsadm.c
index 42f31a20e596..10bf84c85fbe 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -833,7 +833,7 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 				ce->svc.af = AF_INET6;
 				ce->svc.netmask = 128;
 			} else {
-				fail(2, "-6 used before -f\n");
+				fail(2, "-6 must follow -f\n");
 			}
 			break;
 		case 'o':
-- 
2.45.2

