Received: from stravinsky.debian.org (stravinsky.debian.org [82.195.75.108])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8F83D1D63FB
	for <lvs-devel@vger.kernel.org>; Wed, 15 Jan 2025 18:33:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=82.195.75.108
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1736966029; cv=none; b=lSi2dLi/z3bKE/CKN+WC0mDv5sX0wSM2UgYeLVTIt1wUlYIlqrZW3y++Y6YGuMr29gsVxNaOaoPP830ohS0zPdzvcGIWSqHcQmUJ/yYGYNvaHgr9SW+cbf9EzZr8xjGoRt1KAryIcpoIK0/LpM9P+x9WM9cWx/bKE5E2Qrj7geU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1736966029; c=relaxed/simple;
	bh=JePOmTSNwdiHR6DIDCk+mp0Wyuh6PQNnaokvR7u1JbE=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Qtx3Dz7Pl6pTBISv7R9x+q0JQwB+wiJjeQ1pCBOzUAQYOgBfwo6OhKvnc2k999VStarD3LSvlF/Tl2MB8xO9lGGgHLh452KpgVl9oT0tGdsw9CEemh7ZSOBPDr2KOyCdHEx/SJisQLK08s2yitEgEp9UghAtJ9MUbmTUuoy6KfE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org; spf=none smtp.mailfrom=debian.org; dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b=D8/3vzY/; arc=none smtp.client-ip=82.195.75.108
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=debian.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b="D8/3vzY/"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=debian.org;
	s=smtpauto.stravinsky; h=X-Debian-User:Content-Transfer-Encoding:MIME-Version
	:References:In-Reply-To:Message-ID:Date:Subject:To:From:Reply-To:Cc:
	Content-Type:Content-ID:Content-Description;
	bh=ZcTy95mNCO9xs5f4o/qfxHKK2Xc8pPoKlt0fwOD9Rnc=; b=D8/3vzY/jlSOME0lt0Nmt1Csf2
	BKAIsvBzZ6Zj0/9BgZWGsNPeT09HXkSkMfQH41Jr61Oki2HeJeqY3EzKfg0cFr6n53AVlr2hjTGJi
	70rcNLY29e9oLPNy9BIi0he9PWGmdjlViViRDuEZ9+hRblO0GB+2t4g2YebJNY9gapPjiH7GZ/Mda
	rshUGeySPuuZma5oO5v5Kq/G3Y1V6B/PU96iqc7pNxHnIuTE5AwpnFgT9F/6OwoZd4dKs0ZUlZUkf
	OOgRwBNXrRH6X+cw8fb8I9YREF5HkYhROA4BqU/Lo1rSxPRqXSS73OS4NyfMnSpErF/X4OUjdddat
	eVVjPujA==;
Received: from authenticated user
	by stravinsky.debian.org with esmtpsa (TLS1.3:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256)
	(Exim 4.94.2)
	(envelope-from <azazel@debian.org>)
	id 1tY8Cx-001zdI-Rb
	for lvs-devel@vger.kernel.org; Wed, 15 Jan 2025 18:33:40 +0000
Received: from ulthar.dreamlands.azazel.net ([2001:8b0:fb7d:d6d7:2e4d:54ff:fe4b:a9ae])
	by taras.nevrast.org with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.96)
	(envelope-from <azazel@debian.org>)
	id 1tY8Cn-000D3I-0o
	for lvs-devel@vger.kernel.org;
	Wed, 15 Jan 2025 18:33:29 +0000
From: Jeremy Sowden <azazel@debian.org>
To: LVS Devel <lvs-devel@vger.kernel.org>
Subject: [PATCH ipvsadm v3 2/5] ipvsadm: fix ambiguous usage error message
Date: Wed, 15 Jan 2025 18:33:08 +0000
Message-ID: <20250115183311.3386192-3-azazel@debian.org>
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

If `-6` is used without `-f`, the usage error message is "-6 used before
-f", which can be misconstrued as warning that both options were used but
in the wrong order.  Reword it.

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

