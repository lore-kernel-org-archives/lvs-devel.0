Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 871BA27E045;
	Tue, 28 Apr 2026 18:01:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777399264; cv=none; b=NnqDyfOvQ+4IyMAnM1n+gy8dERrEfHXSIhNrweeBEW85qN3KBXbVRSLMEYvvaBwdbGgySyj7lM+1JWcAkuEXAdd4oRmSD8xjxjCXYNaLCA92dMBEwbpfyP2yG2yoRIo/hozpF5b8dSZjKaCJ88lj4a7hKphofJ0vCiArqw3nJh8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777399264; c=relaxed/simple;
	bh=P5oh7R4o0xFOfhPvD27lFRyTEccAfIrpV5bZ6UfOayw=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=jwYPKHVuheLCr/1dWssFOxnFJFB4g4ZzJqTBp+i1Ot32icbNAgs24uf+rSe8NoTIx6pgbZhtIuSa/JHEFIIbm/rnFbmtETll4bju5CM97h2iFEr7cUeSZCB81aGdM33I7PFAbL2cwcYGbxRY6cGFg2tIFq+9Y5gG2XayFUsK/UY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=OK6PhHZV; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="OK6PhHZV"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id AB608212E8;
	Tue, 28 Apr 2026 21:00:54 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=tw7H3kER
	OqKJbQMovylro4lI5okdam/U9KOsRQsbeZU=; b=OK6PhHZVt51eyUlW8q0Yhh0x
	wRzuvwz6/KhRmqqhoWkHWj/i63IT77Gyma1Q6mpTr6R1FK2xp+6ahfiOHOujhVgy
	FEnws7eoD3FZv54bdjiB3VLjf5CnkNAsTNF+ysRaCgCy2NrhMFEhSxAkvHTKZW/i
	7lCSY2+CXBDcy8xxcVuH4iZJMzTWTzTplL3hGR5DmA/gqYY2hyn9rUc1Y70hfem6
	6GUJIWSd1R25VsmUWOfrN9++44iK2fhZhAf9RR2PjY7iYAoDFXx4y7AK+SijC7I1
	sdGCt0KK2/tToMAuFJa+/4FmeILqJtoXVMUfbj5FhxJO8iQi9ThaxHgU3tgzar95
	ZFV3V9mgqAM2Vsj6XidPUZhdolzUsATrV2zrbZuq0PtmTaaBryb73aVKnjHxrQgX
	P7a7Ia0bHjbs5eR6WDcIPtcgZM8NxS+ngF4uWIF1wDT4oAre7U2b6JGt04fJQR5e
	UqOt18XJ9kozVNQr4vBYLjyHDaOld3J2ROVKuZks4bfNA1Nqm3IGEaEalfp0ldUR
	FjFijR6GjzVBMF/P9/4Xg7L4Lc8mWIFp0nSiJAAChtjuJztvqp8DPREzWvVqicHX
	FTuYwhnbeF6h3gapVCog1GYjlr5xvd0/x3dD8+2aODkyrX4P/N70p5fwdhzpJPeb
	KFIEc5ACEBfUbVqfgDo=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 28 Apr 2026 21:00:53 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 9E9D462902;
	Tue, 28 Apr 2026 21:00:52 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63SHvmJD072078;
	Tue, 28 Apr 2026 20:57:48 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63SHvkB6072076;
	Tue, 28 Apr 2026 20:57:46 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        Waiman Long <longman@redhat.com>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org
Subject: [PATCH nf 0/7] IPVS fixes for nf
Date: Tue, 28 Apr 2026 20:57:18 +0300
Message-ID: <20260428175725.72050-1-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

        Hello,

        This patchset contains accumulated fixes for the nf tree:

1-3) Fixes for the recently added resizable hash tables (v5)

4) fixed races and locking for the estimation kthreads (v5)

5) fix for wrong roundup_pow_of_two() usage in the resizable hash
   tables

6-7) v2 of the changes from Waiman Long to properly guard against
  the housekeeping_cpumask() updates:

  https://lore.kernel.org/netfilter-devel/20260331165015.2777765-1-longman@redhat.com/

  I added Fixes tag to the 7th patch. The original description:

  Since commit 041ee6f3727a ("kthread: Rely on HK_TYPE_DOMAIN for preferred
  affinity management"), the HK_TYPE_KTHREAD housekeeping cpumask may no
  longer be correct in showing the actual CPU affinity of kthreads that
  have no predefined CPU affinity. As the ipvs networking code is still
  using HK_TYPE_KTHREAD, we need to make HK_TYPE_KTHREAD reflect the
  reality.

  This patch series makes HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
  and uses RCU to protect access to the HK_TYPE_KTHREAD housekeeping
  cpumask.

Julian Anastasov (5):
  ipvs: fixes for the new ip_vs_status info
  ipvs: fix races around the conn_lfactor and svc_lfactor sysctl vars
  ipvs: fix the spin_lock usage for RT build
  ipvs: fix races around est_mutex and est_cpulist
  ipvs: fix shift-out-of-bounds in ip_vs_rht_desired_size

Waiman Long (2):
  sched/isolation: Make HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
  ipvs: Guard access of HK_TYPE_KTHREAD cpumask with RCU

 include/linux/sched/isolation.h |   6 +-
 include/net/ip_vs.h             |  31 ++++++--
 net/netfilter/ipvs/ip_vs_conn.c |  76 ++++++++++---------
 net/netfilter/ipvs/ip_vs_core.c |   2 +-
 net/netfilter/ipvs/ip_vs_ctl.c  | 127 ++++++++++++++++++++++++--------
 net/netfilter/ipvs/ip_vs_est.c  |  83 ++++++++++++---------
 6 files changed, 217 insertions(+), 108 deletions(-)

-- 
2.53.0


