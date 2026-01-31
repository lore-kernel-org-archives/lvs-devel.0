Received: from cvsmtppost101.wmail.worksmobile.com (cvsmtppost101.wmail.worksmobile.com [125.209.209.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F06CB2FBDE0
	for <lvs-devel@vger.kernel.org>; Sat, 31 Jan 2026 08:21:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=125.209.209.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769847681; cv=none; b=EFmpy/uDXoKtQc1NesYpzCGrfbLcQZdz04f0eqjBO3EjgDg/9Yyn9vktJKxscQL6hHmynSF4pwq9IJMEW+Dohc9fWP2Akm7hXDfDXQDM2hUAzmc/GxbBfjvHs//Zlx4L2AKh3bFu6mcNLNbl/vfGh5c3Wdg4toCcYjPNdcanPWc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769847681; c=relaxed/simple;
	bh=oOtYN2kA/KhRhXaBKoweJN/C8Bl5LOclilXIlHnmYsA=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=cbe3uAjuMpsm+8tedAzatzclVp9d5KNsfGmNYkIIX+c/Gtqx3YSXO1rVaH90uzWJANjEJZXbY5vOIRXC7R1ZVYL8KS9LStzuTfbw28sdKZnNhF1jkv5CWN1Xb4U+h7qhuDal6dmubxhhKw7j8EJinmLQ6BASq5mJV4Pt/Z8AoGA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=korea.ac.kr; spf=pass smtp.mailfrom=korea.ac.kr; dkim=pass (2048-bit key) header.d=worksmobile.com header.i=@worksmobile.com header.b=pEqFFeTi; dkim=pass (1024-bit key) header.d=korea.ac.kr header.i=@korea.ac.kr header.b=ZLJz3c7k; arc=none smtp.client-ip=125.209.209.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=korea.ac.kr
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=korea.ac.kr
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=worksmobile.com header.i=@worksmobile.com header.b="pEqFFeTi";
	dkim=pass (1024-bit key) header.d=korea.ac.kr header.i=@korea.ac.kr header.b="ZLJz3c7k"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=worksmobile.com;
	s=s20171120; t=1769847069;
	bh=oOtYN2kA/KhRhXaBKoweJN/C8Bl5LOclilXIlHnmYsA=;
	h=From:To:Subject:Date:Message-Id:From:Subject:Feedback-ID:
	 X-Works-Security;
	b=pEqFFeTi/6qeAnbMOn/UJyl7ZmjRLXgdXRsYVtgDBElsNa7tZHlPm+GxOaPbjxxuj
	 fRQ5TdiO8unFTNaXFklv/R5GLVg+M3uE83QzurWdrOqT/M8fq0rJ3paXShCrAjgGjJ
	 BwGNvOhvbi2Hm7KyOGNFtaE47yM9P3hr/JJIBmEryBqB0EPiOv0rxmu74VZhERjmgG
	 Lzy9+nACBX4NBOs1eNbjhn1N3zMZnsVnac3Uh0k+v3dv3ukiUJ5AJEM/ITxNfQNDPY
	 z77UdJ/JmZrnpJO1wQnak9r2YxLzDf8v4LW7f2blOI+/jH3PH4ozC/kAuOkI+9FLRR
	 b3kaxBqieuayQ==
Received: from cvsendbo003.wmail ([10.113.20.165])
  by cvsmtppost101.wmail.worksmobile.com with ESMTP id Sh7X0sPvR1CUn6KdmIh8qg
  for <lvs-devel@vger.kernel.org>;
  Sat, 31 Jan 2026 08:11:09 -0000
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=korea.ac.kr;
	s=naverworks; t=1769847069;
	bh=oOtYN2kA/KhRhXaBKoweJN/C8Bl5LOclilXIlHnmYsA=;
	h=From:To:Subject:Date:Message-Id:From:Subject:Feedback-ID:
	 X-Works-Security;
	b=ZLJz3c7kuhUh5pbLQquVcgzqtjenTmLF5bPcrhObxefrvIStka52Daofm8741+Yfv
	 MA+C6P3if7ziqkb/eSc6jj+ngvUyOR/NkBxUvveFTJIsk3snfHYXHObvdOmDf5jSUg
	 pfMePKejgVXAdxHvUmx14ZOA+tjq4W6TZ+sYlgfk=
X-Session-ID: 3Jt6y6jxTj+sdFgQ3eE80w
X-Works-Send-Opt: kendjAJYjHm/FqM9FqJYFxMqFNwYjAg=
X-Works-Smtp-Source: g9KwaAvrFqJZ+Hm/FoMd+6E=
Received: from s2lab05.. ([163.152.163.130])
  by jvnsmtp401.gwmail.worksmobile.com with ESMTP id 3Jt6y6jxTj+sdFgQ3eE80w
  for <multiple recipients>
  (version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384);
  Sat, 31 Jan 2026 08:11:08 -0000
From: Ingyu Jang <ingyujang25@korea.ac.kr>
To: lvs-devel@vger.kernel.org
Cc: horms@verge.net.au,
	ja@ssi.bg,
	netdev@vger.kernel.org,
	Ingyu Jang <ingyujang25@korea.ac.kr>
Subject: [Question] Dead code in __ip_vs_init() net init functions?
Date: Sat, 31 Jan 2026 17:11:07 +0900
Message-Id: <20260131081107.2919353-1-ingyujang25@korea.ac.kr>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi,

I noticed that in net/netfilter/ipvs/ip_vs_core.c, the function
__ip_vs_init() checks the return values of two initialization functions:

  - ip_vs_estimator_net_init()
  - ip_vs_sync_net_init()

However, both functions always return 0:

  ip_vs_estimator_net_init() in ip_vs_est.c only initializes struct
  fields and calls __mutex_init(), then returns 0.

  ip_vs_sync_net_init() in ip_vs_sync.c only calls __mutex_init()
  and spin_lock_init(), then returns 0.

The error handling code (goto estimator_fail, goto sync_fail) can
never be reached.

Is this intentional defensive coding for potential future changes
(e.g., adding memory allocation), or could this be cleaned up?

Thanks,
Ingyu Jang
