Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 964F11D95A3;
	Tue, 18 Aug 2026 20:17:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787084238; cv=none; b=uhQ6bouyuk7j1fgxa/sjpaulFvG5U8JyVksrhbhOTOJawz0KBYvfdZdplI6p+55c/timjj2KBC9WdbguvbUZB8kmnrbZKvJCxtabogd/4If4a2jzeL/ztjldVAT9yFP72jxdw3j45MPrPB+M0vL3c7oKzo+E5rswoIA8ut4fhec=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787084238; c=relaxed/simple;
	bh=94qhbi6pyFm4If/BtWqn7G0ONGu+AcaIEXnUN0Cx8+o=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=mSiNW7gvsPyhbSGnhfCHfUl2HczLBfxSoM7gdMB+a2tkK++/xbczhXadQtYsCEQq1e7zYOlkUtq6qstBwlSBKBKnxsO+9sXZUA5o9ERz1oym35SDNLdzE4NNLcKTT0pqMHuILovFhAcSggslWvjKi5ZYYK0zGQiiRg3XsNREHKc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=A2NIA12/; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="A2NIA12/"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 87B5421CE9;
	Tue, 18 Aug 2026 23:17:03 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=fRLNpFaZ
	0tkkNnxbihf0vjUcCjyQrQDIbbLvxFCXbsw=; b=A2NIA12/HPE3J9HJqn7wSG4g
	u6SWjwise7GIrreldnvoTiK3XiItHUMYMJ0it1/tbCxsal6Uu94n0d91OaMj5q5o
	4RHI6b0WeNRqfwozVBF9giMXfgG04sAs2BeddyZE7Msy2tCdYVphLw0HQhwgqrzW
	BDsTTVDFpz+PWloU6nDgfxV2VFHaaaE/k8KV5xz8YRXZGUeVaz7SL9qqylTkyQja
	auy8GGB696+wdRlhlEalKbXCbeB0pDYJEALz4BCetnA5EHwAAxlwepPxAN8lE38/
	CrVzb2OHvpwiM4kuT2Gwl8QPzgDN8IEUFxY/te7lojAU0pHcbcrImjJ+VuxTkCgp
	WJMGmGg3Vskwt6yd2G1eTmQK3gZOWomWNAyv+zNawmzJnnVZE23fXLxjUHY13iBY
	38YI+0ugT+miDIHVDtd7mVflazRB4MC1waVFiJGpH/L6lrcrA4pf2KEjCdYM1Fwg
	7iPS/ue42g0wJW76XHPm6vRBEKCJHnMw+sYBdLquA3OgNAGFWwPB3gG/2dcalAPW
	l+7T6Q/SohOOriYMrkDDH2egR1pLq+osk1DVjmbuS8mBru19DPwHPnvMDGmP2W1t
	TelR/0VW3g9Z3AgwIUYgisCfAiVCoSKZ7vfcCoJXQbKInqsmhGIPpshhBwYesgQU
	ImVj4B+e5H8X/Bz7kKU=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 18 Aug 2026 23:17:03 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 8041B61DD5;
	Tue, 18 Aug 2026 23:17:05 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 67IKH4Xc121471;
	Tue, 18 Aug 2026 23:17:04 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 67IKH1ei121467;
	Tue, 18 Aug 2026 23:17:01 +0300
From: Julian Anastasov <ja@ssi.bg>
To: stable@vger.kernel.org
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org
Subject: [PATCH -stable 0/1] ipvs: backport cdcc4e46180d
Date: Tue, 18 Aug 2026 23:16:37 +0300
Message-ID: <20260818201638.121446-1-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

        Hello,

        The following patch is a backport of
commit cdcc4e46180d ("ipvs: separate destination availability state")
for the stable queues for 6.18, 6.12, 6.6, 6.1, 5.15, 5.10.
I just removed the hunks from ip_vs_xmit.c which are present
only in new kernels.

Yizhou Zhao (1):
  ipvs: separate destination availability state

 include/net/ip_vs.h              | 7 +++++++
 include/uapi/linux/ip_vs.h       | 6 ------
 net/netfilter/ipvs/ip_vs_conn.c  | 4 ++--
 net/netfilter/ipvs/ip_vs_core.c  | 6 +++---
 net/netfilter/ipvs/ip_vs_ctl.c   | 4 ++--
 net/netfilter/ipvs/ip_vs_dh.c    | 4 ++--
 net/netfilter/ipvs/ip_vs_lblc.c  | 2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c | 8 ++++----
 8 files changed, 21 insertions(+), 20 deletions(-)

-- 
2.55.0


