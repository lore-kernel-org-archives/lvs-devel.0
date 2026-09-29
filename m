Received: from cvsmtppost25.nm.naver.com (cvsmtppost25.nm.naver.com [114.111.35.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 05F4D4FECE6
	for <lvs-devel@vger.kernel.org>; Tue, 29 Sep 2026 17:18:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=114.111.35.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790702287; cv=none; b=hyq5AmF5Q0PsNuRSDBjN7t89mPO9CBaYf/7L3J6l8rrZnWn44f9tYgyeCQuVwW/zlQuMGxvAJ+12i7ggcAdG+hnCYRzKYP+GoUS46dojOkwY8H0C/LE3kdd+qodAv7IbNxOvwHGwDuWqjxt22dXzT3OZL/e4YQndxP/S4l46URo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790702287; c=relaxed/simple;
	bh=Ah+N9JpMko5sERUk9AQw5UhOQPPu+/j0pR/GGXsNR14=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=PVgMof63kPKaS3bSZCLhX8ODLJx/kIzQNMt/LL9bhYBUhDtn+K6Ceq6/RxAEY2Ajvg67S9nhrHAPfzv1pwiY3ZG7DPk5YFzfLbyEX5vrb8EvI90C0icR1skqWjuKu9xdgL9xY2YN00EtW8FVG31iFVyA4xViYlkoFZ8tRDNmHFI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=naver.com; spf=pass smtp.mailfrom=naver.com; dkim=pass (2048-bit key) header.d=naver.com header.i=@naver.com header.b=nWJpjB9R; arc=none smtp.client-ip=114.111.35.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=naver.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=naver.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=naver.com header.i=@naver.com header.b="nWJpjB9R"
Received: from cvsendbo024.nm ([10.112.24.41])
  by cvsmtppost25.nm.naver.com with ESMTP id NMfth7H+RFK5AGnnPcsBTA
  for <lvs-devel@vger.kernel.org>;
  Tue, 29 Sep 2026 17:07:55 -0000
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=naver.com; s=s20171208;
	t=1790701675; bh=Ah+N9JpMko5sERUk9AQw5UhOQPPu+/j0pR/GGXsNR14=;
	h=From:To:Subject:Date:Message-ID:From:Subject:Feedback-ID:
	 X-Works-Security;
	b=nWJpjB9RyTBrd6th3UTdAN57myUbBX4O+FojFxdAaFWpAEf9SX7hozQXAIEpwZUJj
	 woswWG5wPLNMVGnR45Nn+z2nLYrVo33bXCdXC78JljalruCAlF4RDzQ873GfJ8maWT
	 zWEJf68qNvGNavqCtWRdF2hG5y/Bls7ZncOzdDo/9Y/qwhsPpvnHJ/CgHhFdluUeQW
	 o+IzCeBqD3/04RNnvpM6hhNx2TITPFWFb1ZRYLkbqvxqL8I3hNgFLcJ1HiVPoJBf+z
	 axcRPEQkIxb/BrIoxirvQ7P+EhthkJZHO9TfFKjzjTNxg4dQMYQLCDLW6SQO8MkIJw
	 8+14cSl/ExD6g==
X-Session-ID: 3Ub9UiOHQKWjxSK0PxMgyg
X-Works-Send-Opt: OsFwpzGdjHmdKHFOMr39Ko3YKBmXjAudFqM9KqMqFxIYkEljxBmwjAg=
X-Works-Smtp-Source: ednrFoglFqJZ+HmdFqUl+6E=
Received: from localhost.localdomain ([115.136.205.4])
  by cvnsmtp012.nm.naver.com with ESMTP id 3Ub9UiOHQKWjxSK0PxMgyg
  for <multiple recipients>
  (version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384);
  Tue, 29 Sep 2026 17:07:54 -0000
From: tjdqudcks0424@naver.com
To: horms@verge.net.au,
	ja@ssi.bg
Cc: pablo@netfilter.org,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	=?UTF-8?q?=EC=84=B1=EB=B3=91=EC=B0=AC?= <tjdqudcks0424@naver.com>,
	stable@vger.kernel.org
Subject: [PATCH net] ipvs: prevent LBLCR destination leak after entry expiry
Date: Wed, 30 Sep 2026 02:07:46 +0900
Message-ID: <20260929170747.503223-1-tjdqudcks0424@naver.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

From: 성병찬 <tjdqudcks0424@naver.com>

ip_vs_lblcr_schedule() looks up a cache entry under RCU before taking
svc->sched_lock.  The expiry timer can remove that entry from the hash
table and erase its destination set before the scheduler takes the lock.

RCU keeps the stale entry itself alive, so the scheduler can continue and
insert a new destination-set element into it.  Since the entry is already
unhashed and its set was already erased, no later path finds the new
element.  Both the element and its destination reference are leaked when
the parent entry is freed.

Recheck the address mapping while holding svc->sched_lock and update the
set only when the hash table still maps the address to the entry obtained
by the scheduler.

This was found during an AI-assisted source audit.  Diagnostic-only timing
instrumentation forced expiry after lookup on a two-vCPU x86-64 QEMU
guest.  The unmodified code inserted into the stale entry and left one
element outstanding in each of three runs; kmemleak reported the related
allocation in one run.  With this change, the same stale-entry condition
was reached in three runs, but no stale insertion or outstanding element
remained.

An unforced 679-second run processed 65,536 marked packets without hitting
the race.  The result therefore confirms the lifetime leak and the effect
of the fix under forced timing, but does not establish practical remote
resource exhaustion.

Fixes: c5549571f975 ("ipvs: convert lblcr scheduler to rcu")
Cc: stable@vger.kernel.org
Signed-off-by: 성병찬 <tjdqudcks0424@naver.com>
---
 net/netfilter/ipvs/ip_vs_lblcr.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index f53f05ceea36..ef18f3c9d5da 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -686,7 +686,8 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 
 		/* Update our cache entry */
 		spin_lock_bh(&svc->sched_lock);
-		if (!tbl->dead)
+		if (!tbl->dead &&
+		    ip_vs_lblcr_get(svc->af, tbl, &iph->daddr) == en)
 			ip_vs_dest_set_insert(&en->set, dest, true);
 		spin_unlock_bh(&svc->sched_lock);
 		goto out;
-- 
2.43.0

