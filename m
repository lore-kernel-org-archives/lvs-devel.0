Received: from nabal.armitage.org.uk (unknown [92.27.6.192])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 35ED738CFFA
	for <lvs-devel@vger.kernel.org>; Mon, 14 Sep 2026 11:38:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=92.27.6.192
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789385888; cv=none; b=p+5vIuQCIfPpDxxuTPRAJbfWicbF3n9jQCA7u47YPU4dG4QUs4R+KkwBrvG5iEIvN4uMJ5vfqvaa9ydNFturEPfTRRVbre1ZJ8fPuSk+AeW3+wcoyTRqebRaOYPOXeyivJ6mMh8zOneg6oxWtx3F4zQETxnaCLdk9+MDULWsTd4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789385888; c=relaxed/simple;
	bh=hY8vSbWNh3wjgU2LUG23jIItQYiR6CPVy1O11bR78Uc=;
	h=Message-ID:Subject:From:To:Date:Content-Type:MIME-Version; b=UIOpF6nsvuOoL9C0kegrOwblJirjwpj1WMGOaTkv/A3alZIwHv9gGjJxeOF8jFTloI+DitWtkXcAaOYmRAUgEbCbnMoS8SFQYR8IilZ1A1TcC1Io4+sSl8Y342GxKOQsGochoThFvd2112XqNQqy+jc1BaJBJjj/WnibkGeZj1w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=armitage.org.uk; spf=pass smtp.mailfrom=armitage.org.uk; dkim=pass (1024-bit key) header.d=armitage.org.uk header.i=@armitage.org.uk header.b=PyMM7b93; arc=none smtp.client-ip=92.27.6.192
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=armitage.org.uk
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=armitage.org.uk
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=armitage.org.uk header.i=@armitage.org.uk header.b="PyMM7b93"
Received: from localhost (nabal.armitage.org.uk [127.0.0.1])
	by nabal.armitage.org.uk (Postfix) with ESMTP id E7BC62E5B13
	for <lvs-devel@vger.kernel.org>; Mon, 14 Sep 2026 12:31:15 +0100 (BST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=armitage.org.uk;
	 h=mime-version:user-agent:content-transfer-encoding
	:content-type:content-type:date:date:from:from:subject:subject
	:message-id:received; s=20200110; t=1789385460; x=1790249461;
	 bh=hY8vSbWNh3wjgU2LUG23jIItQYiR6CPVy1O11bR78Uc=; b=PyMM7b93yG+j
	be2Y1nJXJAK15euAvZzt0XFzz5SA3LmcvXxaTLyo6jLVDLdX4qBAyBWuQsFGuB2U
	O/ertIqcug4HXknkoK8sDqUXfPkZP8Oz5fXPNJA8CdZnaRUylg1J/PAOP2NbOzkB
	l6EoVN+9wKK8RdZ4X0AIIZit6FHVqkw=
X-Virus-Scanned: amavisd-new at armitage.org.uk
Received: from zarepheth.armitage.org.uk (zarepheth.armitage.org.uk [IPv6:2001:470:69dd:35::124])
	by nabal.armitage.org.uk (Postfix) with ESMTPSA id 1AFEB2E5A60
	for <lvs-devel@vger.kernel.org>; Mon, 14 Sep 2026 12:30:59 +0100 (BST)
Message-ID: <d4ef159477c479f99c8d4a2e3e817eb0451da4e1.camel@armitage.org.uk>
Subject: [PATCH] Document support of twos scheduler - leading spaces now
 resolved
From: Quentin Armitage <quentin@armitage.org.uk>
To: lvs-devel@vger.kernel.org
Date: Mon, 14 Sep 2026 12:30:59 +0100
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

The Linux kernel has supported the twos scheduler since v6.12. Make
sure ipvsadm users know it exists.

Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
---
 SCHEDULERS | 2 +-
 ipvsadm.8  | 5 +++++
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/SCHEDULERS b/SCHEDULERS
index 06d3357..8ddef23 100644
--- a/SCHEDULERS
+++ b/SCHEDULERS
@@ -1 +1 @@
-rr|wrr|lc|wlc|lblc|lblcr|dh|sh|sed|nq|fo|ovf|mh
+rr|wrr|lc|wlc|lblc|lblcr|dh|sh|sed|nq|fo|ovf|mh|twos
diff --git a/ipvsadm.8 b/ipvsadm.8
index 3d7541a..fe0f481 100644
--- a/ipvsadm.8
+++ b/ipvsadm.8
@@ -286,6 +286,11 @@ server as it was before.
 This scheduler has two flags: mh-fallback, which enables fallback to a
 different server if the selected server was unavailable, and mh-port,
 which adds the source port number to the hash computation.
+.sp
+\fBtwos\fR - random twos choice: the algorithm picks two random
+servers based on weights then selects the server with the least
+amount of connections normalized by weight. The algorithm avoids
+the "herd behavior" problem.
 .TP
 .B -p, --persistent [\fItimeout\fP]
 Specify that a virtual service is persistent. If this option is

--
2.55.0
