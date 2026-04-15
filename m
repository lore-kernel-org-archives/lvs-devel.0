Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D456F21CC4F;
	Wed, 15 Apr 2026 20:02:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776283370; cv=none; b=o9KpPJHCSPa5oL3zGQU+RaNgIne0cS9dnlGUjQZJbRpRPibd8R1cBldwU3ixxT2jZ5s9JoZKepkilv4pMbmD9cXOdZ9dVoxLE7ZeJvVhx6lpF1fgKfaoHHyIkFG5PCCmyn5WUkyjk+n7A3UcJwbLBL1Yvw769Vg9BpQzWkuAsTA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776283370; c=relaxed/simple;
	bh=ESQGX+cRvpHg9f9dgN/KoPjl+j51cyuiJGxyTkm+pkk=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=RxqNOsL8kfS4sJujsQ98ox8crVIfYSmtnFp0chDY1KX7LqSQCKOdzBtvACOle7Hgyt/lMMU9pAyFpmjWidnoRuCxLVrvTTnpkyxxXjy+qNNc86HNFIDQRFGL2kIbGX60we4xHJ8WS5vkkOIktJr5RGgVczQdHggwrwcBeqhekd8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=V4eZZoLq; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="V4eZZoLq"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id E131521107;
	Wed, 15 Apr 2026 23:02:42 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=Pno7Bsc5
	I+N5vuvfEiCpEDovT/l1jpKtzeMGjwjOwIs=; b=V4eZZoLqiNATLLFnv2pAcFfE
	Ie4NrIdaAdlB/j6L8eLsPPjDbBsGFguZCTf1XIFSBo2MVtcqSmKgvG9lkExRTac6
	cSSVItYxQnKW35dgfknw9Py415OyxdsdgovMMuuXDYQMEhoPbnguLFAVwrtguDm9
	Zl+dMPEi6O+I/dEZLjMM2/AIRZR79uTBwvZ352Pgfc8fRuj4juwN+VnyDpx95yt7
	XWmlcrpARdg4YFmVeCu8oYbVG1sl4aL4MiFfpCnHIT+rdPH3Em1fN1P8O0WBp12L
	Xeo+kUPHk0f91PGrXEIK8AFbSgQ3yIiSRxx+AfCrz5AjUrR0/sEB6hQPNZ6mmHIJ
	nrycPQjMgT8nYWWu/jmchf1EDQ6Y0XTaZXmA+hIFJvYSs/wE+hnpFdTtx8jyCaqd
	7TgSJ3JUAqmH3hmTWOtFxT5zwwPvKi8yRUpxyyFnpzo9eKDyNUvFuFIShqaIeDAY
	K1PFEJH//Zu9FZDFXx60IapVEhxLbojclzE+fEbK2sQKYUuDgYDsxPsdGU37GIq6
	PFe0488k8wFw568xZ04bZlAAe4+Oywsq7NB/u1zwYIkdcJ7aL8Y3zkx8u+L/zIQj
	aPim7roCaHeKCqj5KExqQyCLs0B9fBr8szLO2IY2qX6T2R10nQtRFT06dsvzX+Dg
	eiPUsu8rs1bbcCvU7Ho=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 15 Apr 2026 23:02:42 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id BCC4B63051;
	Wed, 15 Apr 2026 23:02:40 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63FK2cS7079727;
	Wed, 15 Apr 2026 23:02:38 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63FK2ZYL079725;
	Wed, 15 Apr 2026 23:02:35 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH net 0/3] IPVS: fixes after the new hash tables
Date: Wed, 15 Apr 2026 23:02:13 +0300
Message-ID: <20260415200216.79699-1-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

        Hello,

        This patchset contains fixes after the recent net-next
work for resizable hash tables. We target 2 reports from
Sashiko and one from syzkaller. The patches are based on the
net tree where the fixed commits are present...

Julian Anastasov (3):
  ipvs: fixes for the new ip_vs_status info
  ipvs: fix races around the conn_lfactor and svc_lfactor sysctl vars
  ipvs: fix the spin_lock usage for RT build

 net/netfilter/ipvs/ip_vs_conn.c | 51 ++++++++++++--------------
 net/netfilter/ipvs/ip_vs_ctl.c  | 63 +++++++++++++++++++++++----------
 2 files changed, 67 insertions(+), 47 deletions(-)

-- 
2.53.0


