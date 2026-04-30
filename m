Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0180239FCAB;
	Thu, 30 Apr 2026 07:45:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777535112; cv=none; b=pg73hSurDYYUkpGHTnndqBY1M/OiKZItJaa5yBS408UWqETY4JA5LoUJGamOk6dSJCeG2NwORV5qBthtu9cDR6J5TzHtlc18mn8IFiaeiDsRRBuJZ3Otdux9fPGKNqzWLCxipGcWtHl9HpvQnF3+SkAuHfhOHbuwredaYFb43+Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777535112; c=relaxed/simple;
	bh=5Ld+UoPTRqvU7pTo/RF/ygcQZEb6RW52N759VBWMCVM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=eYKBB5130gdMI+kFtE4pHSCsjIsOf0cVeDdhYQTDr0feTbNe4m7RS4HOC6sh9om0nIXR/LwoakVJvGE8DTS6qUh85c8yu3As2Q/xkJTWe4yE45obrp6iXnNDQkpnGS7J84mHpGTlKJC8Z4vmSjuEw9hAlwF/mlxtAOneG83M8Rw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=kIVtqznY; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="kIVtqznY"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 3566121C3E;
	Thu, 30 Apr 2026 10:45:01 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=T5r6Vps1
	tNW49y6E29S6HcT080eoG23lY/1VQ1+PxrE=; b=kIVtqznYkPKMkPkSDKT61PlG
	hKvIPERtdhhpP2WgxxA/Mex4CzLaJbPCIfJRAtJhxWbGm79tx/peYiMQCtGVrPMA
	eaQhi8pcKRmiyHjofeq90ONNP1Ny3gwXxxtdL+2NtdtZxcSTgxjP/DT078FLiVHp
	ePTrj6YQIgl4ctczEeDHrfajp7FUhrVdCwtJmH0gRCd6UzA2mQK+CRdxlgxIPt+h
	DJ/fAecW/4UO20BGwSQ7Jb+evbdmXAB5RC6ViNUMFrxEEvuHjCcGwUBiseu1HbQf
	Nr0GHKi87Z1HHbN9d78yRnnEPcatK3BdLK6s0xE4u4QEkNc35aPeL1biWNbXsJjy
	OjJgUWezehd93VtBiYJCESdsUzGoiE4EgG0lnjY2OBjUJtTrcmSjbZ78foZGr0kH
	mS25YLjEZkoZ2CUecmAyqyi7z7vQkqKU9qaxcx3JABgUwV7WliyOeUEgnnOhEsBJ
	DHvolUMpHJCQ8z+82BNAC7begGF4RKKlMRTYItPwSL+OYsGAykqMHXmrb381Eigi
	X9aZr1AO2Wj/3v9Sjmz46JFVFdQabxX3V7oW1QxhQ5n1X7HyD9siM4LPtrCXZ9Bz
	vLLQbXADTw9wvTMWaYJK4srJlqDw3LFazRkbum1Iv67SL0LRpjIYK2+Sag+ioeqA
	oMwdqmSCv+DiVPHzJic=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 30 Apr 2026 10:44:59 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 0473560721;
	Thu, 30 Apr 2026 10:44:58 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63U7ivKe027449;
	Thu, 30 Apr 2026 10:44:57 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63U7iviV027448;
	Thu, 30 Apr 2026 10:44:57 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        Waiman Long <longman@redhat.com>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org
Subject: [PATCHv3 nf 0/8] IPVS fixes for nf
Date: Thu, 30 Apr 2026 10:44:12 +0300
Message-ID: <20260430074420.26697-1-ja@ssi.bg>
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

4) dest from trash can be leaked if ip_vs_start_estimator() fails

5) fixed races and locking for the estimation kthreads (v5)

6) fix for wrong roundup_pow_of_two() usage in the resizable hash
   tables

7-8) v2 of the changes from Waiman Long to properly guard against
  the housekeeping_cpumask() updates:

  https://lore.kernel.org/netfilter-devel/20260331165015.2777765-1-longman@redhat.com/

  I added missing Fixes tag. The original description:

  Since commit 041ee6f3727a ("kthread: Rely on HK_TYPE_DOMAIN for preferred
  affinity management"), the HK_TYPE_KTHREAD housekeeping cpumask may no
  longer be correct in showing the actual CPU affinity of kthreads that
  have no predefined CPU affinity. As the ipvs networking code is still
  using HK_TYPE_KTHREAD, we need to make HK_TYPE_KTHREAD reflect the
  reality.

  This patch series makes HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
  and uses RCU to protect access to the HK_TYPE_KTHREAD housekeeping
  cpumask.

v3:
* Apply to recent nf tree. Changing the conn limit of 2^31 is
  still a work to do for boxes with 640GB+ memory (ipvs conn
  size is ~300 bytes on 64-bit)

v2:
* Reports: https://sashiko.dev/#/patchset/20260428175725.72050-1-ja%40ssi.bg
* introduce new patch at position 4 (dest leak)
* patch 6: check for n > 0 before roundup_pow_of_two
* patch 7 and 8 are now in reverse order to help bisection

Julian Anastasov (6):
  ipvs: fixes for the new ip_vs_status info
  ipvs: fix races around the conn_lfactor and svc_lfactor sysctl vars
  ipvs: fix the spin_lock usage for RT build
  ipvs: do not leak dest after get from dest trash
  ipvs: fix races around est_mutex and est_cpulist
  ipvs: fix shift-out-of-bounds in ip_vs_rht_desired_size

Waiman Long (2):
  ipvs: Guard access of HK_TYPE_KTHREAD cpumask with RCU
  sched/isolation: Make HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN

 include/linux/sched/isolation.h |   6 +-
 include/net/ip_vs.h             |  31 +++++-
 net/netfilter/ipvs/ip_vs_conn.c |  76 ++++++++-------
 net/netfilter/ipvs/ip_vs_core.c |   2 +-
 net/netfilter/ipvs/ip_vs_ctl.c  | 164 +++++++++++++++++++++++---------
 net/netfilter/ipvs/ip_vs_est.c  |  83 +++++++++-------
 6 files changed, 241 insertions(+), 121 deletions(-)

-- 
2.53.0


