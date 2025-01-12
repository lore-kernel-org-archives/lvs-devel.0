Received: from stravinsky.debian.org (stravinsky.debian.org [82.195.75.108])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9BD7113E03A
	for <lvs-devel@vger.kernel.org>; Sun, 12 Jan 2025 20:04:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=82.195.75.108
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1736712286; cv=none; b=ac7cBV45jStK1OmNKwUiaywtJlwaEqXBSgNQjrSaJzz1Y2OpmGzDdfYape4kv5xU/c5kxKIChpmLY1biD4IXh9VGPjtXisiLBza0M+CT5OaT8ujdBFAZ8X58j0qa0lshF1nAXJW5X8yl9UmqQR/w3SceQwSvmzCINWGbqrshQg0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1736712286; c=relaxed/simple;
	bh=J3RWlJ+BnkSkCg/Geh18b7RDvqQ9Q68+ap7QYTep0Yg=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=g6cJ+iKiq36FaxqtGGQ89b+62fhe71HBe36MCvuksujf29MipTykKrRS8a9fD3bHb6Dwk29ArpA1GLoIpRjcNbwwbcbMqj6bVNBKTssYg/7qwppYRMWdsx0qAom5e/yQ5sc4YhRsxNazjXXhvvgbi3NtkNsG/Q9wA2OUsS31gJo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org; spf=none smtp.mailfrom=debian.org; dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b=LUTT0gI2; arc=none smtp.client-ip=82.195.75.108
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=debian.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b="LUTT0gI2"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=debian.org;
	s=smtpauto.stravinsky; h=X-Debian-User:Content-Transfer-Encoding:MIME-Version
	:References:In-Reply-To:Message-ID:Date:Subject:To:From:Reply-To:Cc:
	Content-Type:Content-ID:Content-Description;
	bh=BkHWum09Hd/brSUs+JRy8izUogeEr0XLm0OgxPgEaj4=; b=LUTT0gI2xBL6i7sGhZMfWiEsws
	ff+U+hgl5anelBKQl5DtT9zL80v9aaCK0yDU9RDuRyTC7TF4OfrmMShsLndCK3yhy0NN5t1PUR4XR
	e4wWY+2hn31Y0AGbrFKkQamiSRbWbolb8o3KT5HhAYX5WXGbbWr7B7JNj0KSUsfSq/JgJPv1UXJyQ
	RSAc5HDZwDRLi0nhxjZ3ZP4gp5eY3b34G2ndSUwCM/zRzxvmXCoGyMGIIkDviSWeJ/4TfdJavwTm2
	sjfcpd0yfNjenPgOs8ZCqJTK65WUHB2svOOYAAcKQeN0iOs4q1+UBoFONlBdMbwptc28R1p7WMsPA
	dAGisZkg==;
Received: from authenticated user
	by stravinsky.debian.org with esmtpsa (TLS1.3:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256)
	(Exim 4.94.2)
	(envelope-from <azazel@debian.org>)
	id 1tX4CK-00H6mi-Gx
	for lvs-devel@vger.kernel.org; Sun, 12 Jan 2025 20:04:36 +0000
Received: from ulthar.dreamlands.azazel.net ([2001:8b0:fb7d:d6d7:2e4d:54ff:fe4b:a9ae])
	by taras.nevrast.org with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.96)
	(envelope-from <azazel@debian.org>)
	id 1tX4CJ-000H3S-0o
	for lvs-devel@vger.kernel.org;
	Sun, 12 Jan 2025 20:04:35 +0000
From: Jeremy Sowden <azazel@debian.org>
To: LVS Devel <lvs-devel@vger.kernel.org>
Subject: [PATCH ipvsadm 2/5] ipvsadm: fix ambiguous usage error message
Date: Sun, 12 Jan 2025 20:03:30 +0000
Message-ID: <20250112200333.3180808-3-azazel@debian.org>
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

If `-6` is used without `-f`, the usage error message is "-6 used before -f",
which can be misconstrued as warning that both options were used but in the
wrong order.

Change the option-parsing to allow `-6` to appear before `-f` and the error-
message in the case that `-6` was used without `-f`.

Link: http://bugs.debian.org/610596
Signed-off-by: Jeremy Sowden <azazel@debian.org>
---
 ipvsadm.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/ipvsadm.c b/ipvsadm.c
index 42f31a20e596..889128017bd1 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -523,7 +523,7 @@ static int
 parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 	      unsigned long long *options, unsigned int *format)
 {
-	int c, parse;
+	int c, parse, ipv6 = 0;
 	poptContext context;
 	char *optarg = NULL, sched_flags_arg[128];
 	struct poptOption options_table[] = {
@@ -829,12 +829,7 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 			*format |= FMT_EXACT;
 			break;
 		case '6':
-			if (ce->svc.fwmark) {
-				ce->svc.af = AF_INET6;
-				ce->svc.netmask = 128;
-			} else {
-				fail(2, "-6 used before -f\n");
-			}
+			ipv6 = 1;
 			break;
 		case 'o':
 			set_option(options, OPTC_ONEPACKET);
@@ -935,6 +930,14 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 		return -1;
 	}
 
+	if (ipv6) {
+		if (ce->svc.fwmark) {
+			ce->svc.af = AF_INET6;
+			ce->svc.netmask = 128;
+		} else
+			fail(2, "-6 used without -f\n");
+	}
+
 	if (ce->cmd == CMD_TIMEOUT) {
 		char *optarg1, *optarg2;
 
-- 
2.45.2

