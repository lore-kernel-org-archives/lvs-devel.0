Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BA42E33D4F0;
	Mon,  8 Jun 2026 23:04:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780959884; cv=none; b=GHg7bsonbqpxcm6Igu5Xylizm2PKoO3Z6DLwDOb3lvHDV85laPbXSed6b0Zon0Y9789QweDF12Gl7eafhCyTcCaWEioPiUJTucbj3VP5+JUw7bYlGvxkCgbRbYrWa2qOyJw/EBpAygMVF7uUQOvedyxchUI4dEdO7168tRPl3DE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780959884; c=relaxed/simple;
	bh=Wql0R8j7Ytvy+xkLb0z5qm4WKT4KNPD/tzHhhRJPpRI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=fZbRkQ85pl9ZqlWOUJTz03V7utHdK/ti9TGMdQ08powLtreFTAsoEtHzhWwNywu4FYj7ZhgCf13On1fkSKnIt4UseuR5UYkCRcvY7w0lcuDj2X6lxV2ZRBNxWu05+5GjvZJvmv4HYnI4uptBHB5cL55wubKE1DLy3+hqNTUqHS0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=QzQXrX+S; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="QzQXrX+S"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 91E282106D;
	Tue, 09 Jun 2026 01:57:27 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=HqKunZkP
	Rqt8OpyevyZINtHURYnIqzuQFE0TIuchdxg=; b=QzQXrX+S1po8qOa9+K/cLWW1
	aRD23FIaX9aOjmUM/5PfWh0bukdKAWzQCNXUzg8Ilsa5a/spFeAiOkYHAJC7f3ae
	v+9yao6DWr4xe/ufE+CfeuLplMyvUqhUK4ws8v/MfjwrxgqdU3+8gpPvxjn0ydnZ
	U8wIWZ5c8tpMnxJg8mVYGgE/4tPYwhip8msnhipeaxRwZ3QtNIAt83bQmIB64TVQ
	fjTqbnGDaN9ZQVVUDSm04wuxQhOr0frLU6AyBUyIT4kM1VM78TX5RBXecC90ymSi
	OPaixc9ctgVFltrvEPGCg+286JDCP3EMTVnV/JAUuMs16n2tf37VUESQx8QCcYoj
	Z7mjfjrDNriqXogGRHcOpwmAoLANDRq+cJMjfNOcWpKhthPcHVf2BHidVy8b8SQw
	24lHUEn66Jg4qNGDqc2snnrdoHVpwnIu7ArX/5F3C8j6kdDJXfBGqf9XVqJlxKpB
	Hc+nDd1pnCR9UYFHfvzQyBbCOIHmh5vdCSj4zRpURm5KeJ+SBPiECe3xQ4jwj5Mg
	WYxAuL5VsDR/cOHcqZiVUD91frgCeHLEWcODF1Edzkv4IMtV1fCfVVzYA5qlQ13c
	ubDbOv81O4+hR6TS7qmvJgpbmnFyOW3t6Y8v465VOh6BwcooON2ga04JBta8Qt2C
	PgM826BoSZaTpmUuaUQ=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 09 Jun 2026 01:57:27 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 8429660B64;
	Tue,  9 Jun 2026 01:57:26 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.1) with ESMTP id 658MvIfm090963;
	Tue, 9 Jun 2026 01:57:18 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 658MvFx1090962;
	Tue, 9 Jun 2026 01:57:15 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH net-next] ipvs: fix doc syntax for conn_max sysctl
Date: Tue,  9 Jun 2026 01:56:55 +0300
Message-ID: <20260608225655.90943-1-ja@ssi.bg>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Fix the docutils error reported by kernel test robot
for the new conn_max sysctl:

Documentation/networking/ipvs-sysctl.rst:76: WARNING: Block quote ends
without a blank line; unexpected unindent. [docutils]
Documentation/networking/ipvs-sysctl.rst:76: ERROR: Unexpected section
title or transition.

Reported-by: kernel test robot <lkp@intel.com>
Closes: https://lore.kernel.org/oe-kbuild-all/202606071851.Dc1H7hOO-lkp@intel.com/
Fixes: 4a15044a2b06 ("ipvs: add conn_max sysctl to limit connections")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 Documentation/networking/ipvs-sysctl.rst | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/Documentation/networking/ipvs-sysctl.rst b/Documentation/networking/ipvs-sysctl.rst
index b6bac2612420..fe36f4fcd3a0 100644
--- a/Documentation/networking/ipvs-sysctl.rst
+++ b/Documentation/networking/ipvs-sysctl.rst
@@ -72,20 +72,29 @@ conn_max - INTEGER
 	Netfilter connection tracking) the connections can be
 	limited also by nf_conntrack_max.
 
-				soft limit	hard limit
-	=====================================================
-	init_net:
+	Limits for init_net:
+
+	======================= =============== =============
+	\			soft limit	hard limit
+	======================= =============== =============
 	create netns		platform	platform
 	priv admin		0 .. platform	0 .. platform
-	=====================================================
-	new netns:
+	======================= =============== =============
+
+	Limits for new netns:
+
+	======================= =============== =============
+	\			soft limit	hard limit
+	======================= =============== =============
 	create netns		init_net:soft	init_net:soft
 	priv admin		0 .. platform	0 .. platform
 	unpriv admin		0 .. hard	N/A
+	======================= =============== =============
 
 	Limits per platform:
-	1,073,741,824 (2^30 for 64-bit)
-	   16,777,216 (2^24 for 32-bit)
+
+	- 1,073,741,824 (2^30 for 64-bit)
+	- 16,777,216 (2^24 for 32-bit)
 
 	Possible values: 0 .. platform limit
 
-- 
2.54.0


