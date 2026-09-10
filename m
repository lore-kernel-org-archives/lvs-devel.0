Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D92F53BB67B;
	Thu, 10 Sep 2026 10:08:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789034946; cv=none; b=LqZEXlyPkbUVvca5tuaoY5vLRf2SK5IduqyznXKnD610PZSe/JCS4kcXp4Fqyfi+Gcq0Kuecl89fmNCZBGkXzqWgQkT53oQdp9xnqo3tUM2Inn+qzsXPguWADgF2S7TuhD9Jh/uHTddllIvyWVkRKzQ3oG1Z27iEMRmQubtMfUI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789034946; c=relaxed/simple;
	bh=FX9XDAbDZWnoMTIqZDv/VgnpuqfCuSRsP+R8RsclWmc=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=hoAU4nSTFrI3vFAzVkoOlHqtRG5J8+9St64ErknlMhiv0KhwamyRl8E0892OVbScIAF1TtfpEwfq7HmzTkuk4LjfJdnTlqW26dE/fSyER9DmyvRTseIY3+HYJ5hSixEuq5ZyM1VX8tDaC4BQO/AF0IK2twlsDddiwkKPIY3lGf0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=cxfNRHAS; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="cxfNRHAS"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 23C6A2273D;
	Thu, 10 Sep 2026 13:08:51 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=pSM5IFkA
	3yMbofT6O98BZjd9m9fATl6Q0dOKsONnyco=; b=cxfNRHASTeZNtY+7+T0ImYrl
	qUHLTUBau64NShI1fjFtXXF7vd1OHbusiZgGwCBBRypnKe/sgikYgg87KvmSda9u
	kwkK1KDJILyawgmWR0PpMhcu/ut+iIkvOU6ZGDDB37AILDKv166+oGU39ezH9OpQ
	yXLR8X2430srKuPvAp47aHgvc6r/EZpQ2hd9xvWTRZjwbRFSWWJCX8ZLnhI+Bjm7
	ueUBNOqnEAE+YiEs1m0+2pnTwiYLzVDVHYuJaTT3Py6Ub8nGKY393bwvQQqj2V7L
	9urBK7OoIA0uDnKiqR1ZJgmoTeevzc8PF7iIpWoSeYSGCKbXo0zuOdKye7cf2G3Z
	5w/FNmUWuq3IyzQQuXJ3QFR2vB83CtkX0oUn4PMK16SmG//tIH0BiywulnVye3Yk
	5BS9oATtWpB8YbLwhet0UBjG1lA7Ss1/aKgFg5VbRxn9VzqXNrdvgiVdQsw3Aiy1
	CjGJDj/nyaI1hQYf5gdDmWDFTam2bWkRppnRX1UYsXWvcO4I+9k4SLuWEm0dy8ML
	SJoXr24RdvlorUGagYyyVF4jczEoocMH/O8PHd43cYCdgBZtMnYruxVn+0cD2VVc
	L4DqeYWIIBcMt6DDNbEuQ7GUPaKC5/7P9tXOrvvozS1E60r5gmLaIbquVxp1HEy2
	ZgGDCajdU8ooEoDWNeI=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 10 Sep 2026 13:08:51 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 9C7A860FC3;
	Thu, 10 Sep 2026 13:08:52 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68AA8oIn036022;
	Thu, 10 Sep 2026 13:08:50 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 68AA8ljX036019;
	Thu, 10 Sep 2026 13:08:47 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Zhiling Zou <zhilinz@nebusec.ai>, vega@nebusec.ai
Subject: [PATCH v4 nf 0/2] ipvs: fix LBLC and LBLCR cache growth
Date: Thu, 10 Sep 2026 13:08:30 +0300
Message-ID: <20260910100832.36004-1-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit


        Hello,

        Following is a patchset with two changes:

1. fix for a missing decrement in LBLC

2. v3 of the LBLC/LBLCR patch from Zhiling Zou applied on top of the
first patch, as v4

        Zhiling Zou <zhilinz@nebusec.ai> explained the problem in v3:

We found and validated an issue in net/netfilter/ipvs/ip_vs_lblcr.c.
The bug is reachable by a non-root user through a new user and network
namespace. The same cache growth bound is also missing from the sibling
LBLC scheduler in net/netfilter/ipvs/ip_vs_lblc.c.

Bug details:

ip_vs_lblcr_new() allocates and publishes an LBLCR cache entry for
every previously unseen destination address. Although tbl->max_size is
initialized to 16384 entries, it is only used by the periodic collector
after cache growth has already exceeded the limit. The collector runs
once per minute and does not reclaim recently used entries.

An attacker can configure a fwmark-based LBLCR service and
continuously send UDP packets to distinct destination addresses. Each
new address creates an entry, allowing the table to grow without bound.
The allocations use GFP_ATOMIC and are not charged to the originating
socket or memory cgroup.

LBLC uses the same cache model and periodic collector. Bound new LBLC
cache entries the same way so both scheduler variants stop growing after
their table reaches max_size * 3 / 2.

The scheduler selects a destination before attempting to cache it and
already continues to use that destination when cache creation fails.
The fix therefore rejects only new cache entries once the table reaches
max_size * 3 / 2, while normal traffic to new addresses remains
serviceable without further cache growth.


Julian Anastasov (1):
  ipvs: fix missing counter decrement in lblc

Zhiling Zou (1):
  ipvs: bound LBLCR and LBLC cache growth

 net/netfilter/ipvs/ip_vs_lblc.c  | 4 ++++
 net/netfilter/ipvs/ip_vs_lblcr.c | 3 +++
 2 files changed, 7 insertions(+)

-- 
2.55.0


