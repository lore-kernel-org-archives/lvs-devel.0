Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4694137F011;
	Sat, 19 Sep 2026 18:07:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789841276; cv=none; b=JGk5nvH1+WMwoS6f36AAOdVVUF00YLi7DDkDJPDendA66HwG9SGQNkBTen5ycZyM7IIso0AF9EOX5Kw58KFZJEywnQAR2lB345dnCvnH7EhQ9wpmzliPwFjjtYse34UBi7XhuP+P+H5L7ih96xswAHP8DcDtchDf7dX/DBJ7sIg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789841276; c=relaxed/simple;
	bh=N8qRsZOlpYvHrtmpT3NWAA+zPDCTm/Ps91SHF+Z5rLY=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=MNlyHEHGKVZtzKYLzG6LRixoFtvQH2NqFbtHuTS5vP9NUKB4Sg2N5DSsQDOxS+fbm292k4wmB0Qqiq9SciHdCUswMk1zejPHLL92TrM9ajVanhh9CaZ3StleM4XBz1i2Cpe9/tzlQOiNzspUN/VADezyob4rVdbm+0hkZ6rA37w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=KjgWdep5; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="KjgWdep5"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id D75C0213A8;
	Sat, 19 Sep 2026 21:07:44 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=1uSrIgsZ
	8uFBfVJCKS4FzoIIJdObcmLUeET5Hls6QiA=; b=KjgWdep58u7oyODtOreFM+6y
	hSNLNyAxdsYaeEo9JpVkXvmHLWti0Ocwj5z5//dJWFrdU7Vm//R0Kts53MYMvTnB
	avBfQB9oaXk8SnduHZJQyUz6a2U6/xK8zL+ouwTa2OAaGmlz+fI388hvwjZF1ayV
	yY5NGp0GSnaqwpJM7hlUspujvGqKtNTm7XluHhj8ldGFKnQaQRL8glyQpaZrgym3
	nSZVKIs1oeVRDeaOyuXO4bvjbZwKdj1B+CXQqA/+1Y/edawqBuNqJLL30F3qSPd2
	PBuIyIVzU9YWqsMkqX7aAznO0wCHoAZB0AOBv3764iWlZSE1xI8TjFC0CpTPkmeU
	aGbg9J0KE4j5WXUZ0dAoKqaGdVAA3OsXqQDaYPdptspE3HYUMrngVFWlVH4QwCa5
	RQ2ltEsW3ZxPz4MucMiaqy1u8cQIjWiYA/dcWRP1Ef6uYmQ/VbqveZpPMHWGJFi5
	JJJgSGSshi2l+Y3KnfWDnFFoUMHdYAX8ruoSF4VXF2Vsmuwv1VexbELo8VGjncGY
	++ibJxpAFEaebNYmmfCz8zrAN8CLYLN90NW6G2GmaNhFFTsCv/cFbf1tkZO7/vlk
	PtKC4Hl+QE9EmK1ljvt7b8HjEiK91SQuJjfJ9qoQrA+uw2kkcS0iAmElCcLM4Gry
	YBKdLS1x4C7IM8oh4zI=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 19 Sep 2026 21:07:44 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 0E15C60627;
	Sat, 19 Sep 2026 21:07:47 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68JI7kqX049516;
	Sat, 19 Sep 2026 21:07:46 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 68JI7gP7049515;
	Sat, 19 Sep 2026 21:07:42 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH v2 nf 0/2] ipvs: filter some connection flags
Date: Sat, 19 Sep 2026 21:07:31 +0300
Message-ID: <20260919180733.49501-1-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit


        Hello,

        The patchset contains two changes:

1. Filter the ONE_PACKET flag for templates when inherited from
dest->conn_flags to allow reusing the templates from many
connections

2. Filter some flags or their combinations in the backup server
to avoid creating templates that are dropped immediately or
to avoid unexpected template hits.

        Followup patches should add more protections.

Changes in v2:
* add patch 1
* patch 2: explain in commit message that NO_CPORT is not sent
  because the master does not sync connections that are not
  established

Julian Anastasov (2):
  ipvs: do not create invisible templates
  ipvs: filter some flags received in the backup server

 net/netfilter/ipvs/ip_vs_conn.c |  3 +++
 net/netfilter/ipvs/ip_vs_sync.c | 33 ++++++++++++++++++++++++++++++---
 2 files changed, 33 insertions(+), 3 deletions(-)

-- 
2.55.0


