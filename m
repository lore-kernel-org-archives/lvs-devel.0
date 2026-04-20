Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 49465477998;
	Mon, 20 Apr 2026 13:30:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776691842; cv=none; b=YPSHPG9JXqP+z0c5saY1Isp+fqRaFIqV1pM79gZvuIaJVdsTU7jE6Yvw6yGLzt+Gmd77a6031lo1Hp7ChlVfC62KOhdLlhDHh954gP45gn0GBDlN9jclNjJ+L17VMX0r5hwqNoZA9HsZa5XKVVC2aJwxfWIWE9sx7BVB84r4FM4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776691842; c=relaxed/simple;
	bh=5Vci4rslvWrPE8f1cEhuaoAf40dqNhLtP0lcKQwrv+s=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=B7cGOKLe/FnWzMRUppvOUAMDECVb4f/EblXvJk3CbuUYlnI4qIPyM+AaoFotw6RCF98RXG4+RiEZjxG2gFCVfwJ7w7MspIhck0Fus2gwwp/jHxmi5Ca4pw2HtAf0+4XQh/AIsNXZPaH00md4AvU0VPmiR9YfWCFAd8iaP+x0Gpg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VxZ0HzdD; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VxZ0HzdD"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4F5DCC2BCB4;
	Mon, 20 Apr 2026 13:30:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776691842;
	bh=5Vci4rslvWrPE8f1cEhuaoAf40dqNhLtP0lcKQwrv+s=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=VxZ0HzdDYDAi0P6Kqf5Fbc+JtRpkPeLI+0dNc0bG/CPpdNamfkSDSRtCz5JJhzvzR
	 BbfR8BEPDW/BwACR9PCWAhxQU7bJVU1svr06cBzWafmWwJfLpyw0Rqd+vvrT2ve9kQ
	 mDqU4m9KLuTl9zWW3mbhON9E0o6mOThlyVkLLJGNLJzMtLd1bx8VctvRohVqr95tOk
	 Z87YJzx2rBT011uHgSC2FEOeqkEyPnefYVT6aWgAHpgwEItQHY64HjpzjMo+2PBBkF
	 Pi9xovuVIsbF6m29QJBd9/soz2IXfa7bG/DuGClzHLZXaoR3p3tlJ0qwSJ6t3027no
	 26pCKvu/3RVRg==
From: Sasha Levin <sashal@kernel.org>
To: patches@lists.linux.dev,
	stable@vger.kernel.org
Cc: Weiming Shi <bestswngs@gmail.com>,
	Xiang Mei <xmei5@asu.edu>,
	Simon Horman <horms@kernel.org>,
	Julian Anastasov <ja@ssi.bg>,
	Florian Westphal <fw@strlen.de>,
	Sasha Levin <sashal@kernel.org>,
	horms@verge.net.au,
	pablo@netfilter.org,
	davem@davemloft.net,
	edumazet@google.com,
	kuba@kernel.org,
	pabeni@redhat.com,
	jwiesner@suse.de,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH AUTOSEL 6.18] ipvs: fix NULL deref in ip_vs_add_service error path
Date: Mon, 20 Apr 2026 09:20:20 -0400
Message-ID: <20260420132314.1023554-226-sashal@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260420132314.1023554-1-sashal@kernel.org>
References: <20260420132314.1023554-1-sashal@kernel.org>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
X-stable-base: Linux 6.18.23
Content-Transfer-Encoding: 8bit

From: Weiming Shi <bestswngs@gmail.com>

[ Upstream commit 9a91797e61d286805ae10a92cc48959c30800556 ]

When ip_vs_bind_scheduler() succeeds in ip_vs_add_service(), the local
variable sched is set to NULL.  If ip_vs_start_estimator() subsequently
fails, the out_err cleanup calls ip_vs_unbind_scheduler(svc, sched)
with sched == NULL.  ip_vs_unbind_scheduler() passes the cur_sched NULL
check (because svc->scheduler was set by the successful bind) but then
dereferences the NULL sched parameter at sched->done_service, causing a
kernel panic at offset 0x30 from NULL.

 Oops: general protection fault, [..] [#1] PREEMPT SMP KASAN NOPTI
 KASAN: null-ptr-deref in range [0x0000000000000030-0x0000000000000037]
 RIP: 0010:ip_vs_unbind_scheduler (net/netfilter/ipvs/ip_vs_sched.c:69)
 Call Trace:
  <TASK>
  ip_vs_add_service.isra.0 (net/netfilter/ipvs/ip_vs_ctl.c:1500)
  do_ip_vs_set_ctl (net/netfilter/ipvs/ip_vs_ctl.c:2809)
  nf_setsockopt (net/netfilter/nf_sockopt.c:102)
  [..]

Fix by simply not clearing the local sched variable after a successful
bind.  ip_vs_unbind_scheduler() already detects whether a scheduler is
installed via svc->scheduler, and keeping sched non-NULL ensures the
error path passes the correct pointer to both ip_vs_unbind_scheduler()
and ip_vs_scheduler_put().

While the bug is older, the problem popups in more recent kernels (6.2),
when the new error path is taken after the ip_vs_start_estimator() call.

Fixes: 705dd3444081 ("ipvs: use kthreads for stats estimation")
Reported-by: Xiang Mei <xmei5@asu.edu>
Signed-off-by: Weiming Shi <bestswngs@gmail.com>
Acked-by: Simon Horman <horms@kernel.org>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---

LLM Generated explanations, may be completely bogus:

Error: Failed to generate final synthesis

 net/netfilter/ipvs/ip_vs_ctl.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 4c8fa22be88ad..e442ba6033d5f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1453,7 +1453,6 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 		ret = ip_vs_bind_scheduler(svc, sched);
 		if (ret)
 			goto out_err;
-		sched = NULL;
 	}
 
 	ret = ip_vs_start_estimator(ipvs, &svc->stats);
-- 
2.53.0

