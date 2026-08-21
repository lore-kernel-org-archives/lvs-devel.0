Received: from nabal.armitage.org.uk (unknown [92.27.6.192])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 596F53DDB0A
	for <lvs-devel@vger.kernel.org>; Fri, 21 Aug 2026 19:45:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=92.27.6.192
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787341562; cv=none; b=j+3pszsL5MJvbtXxAI8VQWrCbnSqqru06XtbQuaPj1R8Y2Cu9zvwUN6/XVEEybwqz3xgPmwoA2jCFpdv1YKt/jNYkoinot+l3DQ9GVyc4z/APaS2PeoXgb3ahq5tXNdXK73ZZGikkw/Oh6eHMPCyIzUjHWjZiEMXT8LyZ3kwO+A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787341562; c=relaxed/simple;
	bh=7vegqpyUthMm+teAXvT09n7B2hwsqFDALVBOlE+fjVI=;
	h=Message-ID:Date:MIME-Version:To:From:Subject:Content-Type; b=fUGYmYbvGyoSp/2IGbM8h04tHBwQ1OmLZds2gh+Y6U44CtvZoMDAjnnPNiIAXQXr/VDBK+KpsMprPmUc3mK3HQGqVMTEIhmV0uIAXiL4S/9fgrzYFqIZUKhCQg0ZOlLSw2ut3uaUldPNNxyL+21sysw8J2C3eCtNzdHLWbf9fk4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=armitage.org.uk; spf=pass smtp.mailfrom=armitage.org.uk; dkim=pass (1024-bit key) header.d=armitage.org.uk header.i=@armitage.org.uk header.b=CbDGHYu0; arc=none smtp.client-ip=92.27.6.192
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=armitage.org.uk
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=armitage.org.uk
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=armitage.org.uk header.i=@armitage.org.uk header.b="CbDGHYu0"
Received: from localhost (nabal.armitage.org.uk [127.0.0.1])
	by nabal.armitage.org.uk (Postfix) with ESMTP id CA6FE2E5D8B
	for <lvs-devel@vger.kernel.org>; Fri, 21 Aug 2026 20:35:14 +0100 (BST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=armitage.org.uk;
	 h=content-transfer-encoding:content-type:content-type:subject
	:subject:from:from:content-language:user-agent:mime-version:date
	:date:message-id:received; s=20200110; t=1787340899; x=
	1788204900; bh=7vegqpyUthMm+teAXvT09n7B2hwsqFDALVBOlE+fjVI=; b=C
	bDGHYu0TfJ6QVHfvO8DrBo8OSQrfIp++ya/gSoxnKBaQRLuMlo6tOV2kX64XekpB
	7dWuDSjfJyMwoZI2fBr8lUMz2HA721J0LRRblEqTTtFv6WpcqC6faF8JruEwTQFg
	VBXWna9dzHBkHxhaFgxfsJTA2T+fWbplcGaTceSyd0=
X-Virus-Scanned: amavisd-new at armitage.org.uk
Received: from [IPV6:2001:470:69dd:35::215] (elijah.armitage.org.uk [IPv6:2001:470:69dd:35::215])
	by nabal.armitage.org.uk (Postfix) with ESMTPSA id 290E32E5D2B
	for <lvs-devel@vger.kernel.org>; Fri, 21 Aug 2026 20:34:59 +0100 (BST)
Message-ID: <57320483-a739-4516-969c-0befbb8d4e74@armitage.org.uk>
Date: Fri, 21 Aug 2026 20:34:58 +0100
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Content-Language: en-GB
To: lvs-devel@vger.kernel.org
From: Quentin Armitage <quentin@armitage.org.uk>
Subject: [PATCH] Document support of twos scheduler
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

The Linux kernel has supported the twos scheduler since v5.12. Make
sure ipvsadm users know it exists.

Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
---
  SCHEDULERS | 2 +-
  ipvsadm.8  | 5 +++++
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


