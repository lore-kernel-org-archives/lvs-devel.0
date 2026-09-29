Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 52F72513573;
	Tue, 29 Sep 2026 11:37:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790681856; cv=none; b=m4gPd6kGooc1D1ffSJRyj+tEz5vKvL2eyT9sS6KfhgyzUnKMm7A5xEZQsrNfhvmbVjsieSY8uRBEVBj8LTRfQ32Ak1+jDLi+R/q0ORDlx3Rv7ZpmLYkFeb3F11aqEWwm0fZU6XkVqLfhu4ewBiFM8F+Ue8VWcfyxh85YUPxrCNY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790681856; c=relaxed/simple;
	bh=c8nwRX3904/ANTAW3qqP84xYaxCohsPJy6mXl5rPPuM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=k6Y0lSTC62U6KF2YqBZKxTTpJNe8vHfa+pV4Xiky3LUwBe5neqiLbybOgGQARDt7P/jqdDhnIIge0l9NKwynV6v6acEL9YHkVWwMmR5RkrebPhuHHW2obExXAH5zrJMd0LuKBynN/oW8bLZdvc/NMGVGWhsHztxO0NZeKVl6noc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=e1OWl+/m; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="e1OWl+/m"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 0CBAA213E4;
	Tue, 29 Sep 2026 14:37:28 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=X2u1J4lR
	vD8hFgydK8bb3e+A1LG4wIR2VWg4rzLBJKY=; b=e1OWl+/mJVG6SON05ASP+mNL
	FtzM6ov44Tlmycn8VBBCRHBQTOkZofnOtGnCxf/rpZT+5t5emRR+EdKNP6qowTLb
	Ex0r1e+HymVxixqlkkUy8XQvWh6ZCbplrfGpBToetfvPTSY9AIzkIsvxpKc3ELjx
	wP4Pg7nFbgXgEZ/QvhlmMjOJqbI3nvKJkJCDl5e7IidgJbUTPEq4J9TWikINMsMh
	ChX9ljXYbhQQIZ1BfctpU2+Nwx65zrijEC9O32M+jGm5FiBdEB5h775PZ+hLaz/F
	NGHA8os9QwxX7NRKxeAlwHYAXKQOXLFuwatJlivdkff+xzLCc0q6OkKWJVVG0Qfp
	L8qZF6W/w0C7tEw3nKZI8MFcRutuzL9uTPo/PGr7LPUm8QAWa4Yg/cXPsJvXbwjP
	2+Eew0q6+QbBmkHNcjU3AWOdFZlzlJoWPlhpzB/veMKkk13OGoq8SEOsJsewKr+l
	Y8bZieVVFcZQsnr6QGZxuHzcRAwG1HEKo1yZmT/nVAFRtJdoUy3acC/p6O2f0rO+
	pSXZEUpIGxI0MB4hBh1MjuwW+BmCiPevTOz+YihesMyuOR/nynVdjNB5ECekx/Pa
	OiKPeR4B9rPtfymLYmIVGlVFwobsQ3wro11D4lWZWIq0+KE1Kh8cjNb0G2jqFJex
	borzt9LfWBB5W+1O2QU=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 29 Sep 2026 14:37:27 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 7247F620E7;
	Tue, 29 Sep 2026 14:37:30 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68TBYt21044326;
	Tue, 29 Sep 2026 14:34:55 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 68TBYqfg044323;
	Tue, 29 Sep 2026 14:34:52 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf v2 0/2] ipvs: read conn fields during sync atomically
Date: Tue, 29 Sep 2026 14:34:34 +0300
Message-ID: <20260929113436.44306-1-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

        Hello,

        The following patches make sure the connection
fields such as flags, sync_conn_opt (seqs), state, old_state
and timeout are updated atomically in the backup server
and the first two also in the master server to avoid
buffer overflow.

v1->v2:
* add patch 1
* patch 2: read seqs with flags under lock

Julian Anastasov (2):
  ipvs: update flags and seqs in backup server under lock
  ipvs: fix buffer overflow when sending sync messages

 net/netfilter/ipvs/ip_vs_sync.c | 55 ++++++++++++++++++++++++---------
 1 file changed, 40 insertions(+), 15 deletions(-)

-- 
2.55.0


