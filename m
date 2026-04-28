Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D79CF3290DE;
	Tue, 28 Apr 2026 18:01:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777399272; cv=none; b=KIJaWgyq0ROWqUlZIf6yxC9QpqCFH96DUIwRJGd2DpdE52YCTs0KD2koa93znv60CcoIv1QKWWzgnPwSoK/wEVpZ1CAUHyshpfl6PrrsopjscMIAKsD6/sc8oK+U5Qq3STmHeBnHG5AJEQdGDNVpW+IO006/JYtKMCX/las7inY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777399272; c=relaxed/simple;
	bh=oUFlTiGYqw73lHnw86juUKMkGTiWASsaJfIxIyDpvY8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=oAXewMCtXEivUC3z0GqJ+kWRiLziSOpaV4Wwu+5/EUp6XMJpZ6Y1UIbhSUHFlm9beMIQd5lV/RHk/4QbblGSGZ71cCaM5WvmGEvoa7ExxPN0WY9YF0ICqZalVsoHZLEyOzdVMNP6OuBCpHrPoNqMAPBb2hDMqal8dSOdt5hsxDs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=E5+lJux/; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="E5+lJux/"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 5CAD9213AE;
	Tue, 28 Apr 2026 21:00:55 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=+N8l8xhO6EweGkIZO6SUeyy8/92nakMTqZK+u/GGXGQ=; b=E5+lJux/OpJz
	HVweWmZS1f8CpNvgRPE1Mhnk6B2Xtb6FFkIGhj1yOHiLRcfJIkrxx4rGeDsO9xdG
	Ltf0Y8vHtlS/h2yfvXDOrKKPR/dRjPQVldSXrlSnZyLERzNYqHME3Svu6G7Gwyz3
	t6e6D+acpmuB7DPjfQb7y1IHyTuKiLChOD6gAtBzVMO+gd+xs+xRrtOa67KIGTZd
	wHQDnJcrSNHRsn1Tr4hZvZHsUfSaSsyupdulRDezeBdq+TFbfyqXDRUU21p3kIpP
	w2ItFqNMaIhv2J72BQKhibKHTelOFDwhXjLwGz5c32grSCOroxC0IWnr08EhEAmm
	YUM+j0M/k+OcEZpWL9AYV2ZKCGgnThZ8pQ7IsBkwuBE9xxQH5+0FM72K2dftJ3Ye
	VRY5sJ3UveDufSLXQnztI0lNwnWGB6eMKq7jXwIWnHem5wdiYI9HKgn4Ps32Scfl
	Jg/9aY9D1fUikFshxCwFJN7srjZwz5eWOF/wgiV5RHKp4rWdy6r03cjocR+QDs7K
	EveoxjIhjm5IwWJJZJ+pPtH+lgTAPGZRxCABBHupSfD2w4lP0c7KkENgevqVej7m
	dEqsEakVRxuIQXftWt/KNsKOjEqDEVFpc38cvSqvBVNKDQ3SjZCPXh2MwJBi0w4r
	Gib8jR7p5MTwV0nmcyx7KtZ4C11qZbY=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 28 Apr 2026 21:00:54 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 8A9D76089A;
	Tue, 28 Apr 2026 21:00:53 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63SHvnTG072098;
	Tue, 28 Apr 2026 20:57:49 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63SHvnTL072097;
	Tue, 28 Apr 2026 20:57:49 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        Waiman Long <longman@redhat.com>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org
Subject: [PATCH nf 5/7] ipvs: fix shift-out-of-bounds in ip_vs_rht_desired_size
Date: Tue, 28 Apr 2026 20:57:23 +0300
Message-ID: <20260428175725.72050-6-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260428175725.72050-1-ja@ssi.bg>
References: <20260428175725.72050-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Calling roundup_pow_of_two() with 0 has undefined result:

UBSAN: shift-out-of-bounds in ./include/linux/log2.h:57:13
shift exponent 64 is too large for 64-bit type 'unsigned long'
CPU: 1 UID: 0 PID: 77 Comm: kworker/u8:4 Not tainted syzkaller #0 PREEMPT(full)
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 04/18/2026
Workqueue: events_unbound conn_resize_work_handler
Call Trace:
 <TASK>
 dump_stack_lvl+0xe8/0x150 lib/dump_stack.c:120
 ubsan_epilogue+0xa/0x30 lib/ubsan.c:233
 __ubsan_handle_shift_out_of_bounds+0x385/0x410 lib/ubsan.c:494
 __roundup_pow_of_two include/linux/log2.h:57 [inline]
 ip_vs_rht_desired_size+0x2cf/0x410 net/netfilter/ipvs/ip_vs_core.c:240
 ip_vs_conn_desired_size net/netfilter/ipvs/ip_vs_conn.c:765 [inline]
 conn_resize_work_handler+0x1b6/0x14c0 net/netfilter/ipvs/ip_vs_conn.c:822
 process_one_work kernel/workqueue.c:3302 [inline]
 process_scheduled_works+0xb5d/0x1860 kernel/workqueue.c:3385
 worker_thread+0xa53/0xfc0 kernel/workqueue.c:3466
 kthread+0x388/0x470 kernel/kthread.c:436
 ret_from_fork+0x514/0xb70 arch/x86/kernel/process.c:158
 ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245
 </TASK>

Reported-by: syzbot+217f1db9c791e27fe54a@syzkaller.appspotmail.com
Fixes: b655388111cf ("ipvs: add resizable hash tables")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index f5b7a2047291..ea450944465f 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -237,7 +237,7 @@ int ip_vs_rht_desired_size(struct netns_ipvs *ipvs, struct ip_vs_rht *t, int n,
 {
 	if (!t)
 		return 1 << min_bits;
-	n = roundup_pow_of_two(n);
+	n = n ? roundup_pow_of_two(n) : 1;
 	if (lfactor < 0) {
 		int factor = min(-lfactor, max_bits);
 
-- 
2.53.0


