Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 398282D8370;
	Wed, 29 Apr 2026 14:11:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777471892; cv=none; b=oJOpUUTBwmbUOv0uXcDsyz1p3flLg7h3GXnj6N9+kAUXPkkjI7VmZDJioAASwBqaS5quLpKGw4j/QNW0ggdk/fKinQOCJC6PGczfk43px8neoFKp8gj8pvx//f6VKUFIKahh5Qz9Y6kkvJVPkrRvBtpR3ljfHDu5WznHt9WaMpQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777471892; c=relaxed/simple;
	bh=MRIWJT3Arup1XB/LpeZr3s0ADCn57ZIBAFVEgSEDovo=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=MUlPqSurmhQcP8WE9AGzwzhfehNJUZE4zfiqeYNadRg4WSiDw6SDjqPbSQdZsuvOAoDZzkYUhR6Lc45ijjNxh0TnmGiL4hMCdGDrrLisR1xH8UiCZgZjJH++UNlRmnZaX6zy+WyN0UT6RM3ofCCq9FjrtM+rrOS9X+NhaFt1LCY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=JW0YG1N1; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="JW0YG1N1"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 8D36A21C31;
	Wed, 29 Apr 2026 17:11:26 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=elJNi65f
	qX1AUS4d4CN/PY6KMNv4fGwG8egrE2GAzNg=; b=JW0YG1N1idXmJgyo16Xlg1iF
	KjrRfZ6N2AYABeHZE8VHCdZYwaBiZ5fNCN/aTL2xUxzbzlqqYPbmQ28p3UTXC/Ez
	bvZJSVorFs+dpN5VmTtGoG49S1WQF2np1MBtpRGGj/zIR68hijjqgpIdoJgvz8PH
	ytO0zAoaSC9bEI+WjquHLPOr2pBEKy0aLryQCXVC4gsTRTdMxPBQmXyfKUcLXAQ+
	QsinD9BEpQiu/VD1QpPsq9xx5AWqUh+mwYKctwAwpTq/SpAodOm29Rz548AldKMx
	gKq1rr7NOi22XL7uj9h4nhSe2JdHL3ZAuHhjAeimtgwwK4xlhAqH5VtYeRyscXyS
	ChHmR1TOL/f+Fisc4vteVKPdiS9CMl0Wa11Q3LcMwS0F4+eXns2S/sByUwXMa7Fh
	1TAV6OgpJo53dwC4LX36z0vI5VXup7mDmkHr4JK5gJAkCreaPT4tzGxFhk7HjxxS
	BiIaUfCNwveSsmwHlbSUEI1NslFgEAYuc5h0mqC3D7Ae6CRQUv+5zqWHl4goornW
	OTDABat7qhKeA6mg4oWWh/KAP9NPuMg/EtQl+rI6UGxjmPiL/0YPT0Sk4r+3b8l4
	Fhr9AABsgXCZJXRcvraqxGTxxXg0b3soLtUybXuwWFKmQbdoDcPeXLkLirUBrVvh
	rHOER2wG7MNbyodwusw=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 29 Apr 2026 17:11:25 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id D162B6088F;
	Wed, 29 Apr 2026 17:11:22 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63TEBL7v085080;
	Wed, 29 Apr 2026 17:11:21 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63TEBI2j085076;
	Wed, 29 Apr 2026 17:11:18 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        Waiman Long <longman@redhat.com>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org
Subject: [PATCHv2 nf 0/8] IPVS fixes for nf
Date: Wed, 29 Apr 2026 17:10:47 +0300
Message-ID: <20260429141055.85052-1-ja@ssi.bg>
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

v2:
* Reports: https://sashiko.dev/#/patchset/20260428175725.72050-1-ja%40ssi.bg
* introduce new patch at position 4 (dest leak)
* patch 6: check for n > 1 before roundup_pow_of_two
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


