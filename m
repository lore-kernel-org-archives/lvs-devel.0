Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F213248166;
	Mon, 27 Apr 2026 23:40:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777333251; cv=none; b=GU/Y0P/q5v08pF6bclC79TCN5iCxnMo/XlLApQx0jYVYPYSRuvhlPZ3R2ES7gUU3WzD9sRtbruhvB1I01ekXiwtdhLD8orO19e02v063iTz3lqjtGcmGCFsAOh1+2GSfzT9Pce2TuH0rShtozQgZM93jFgoDm0+NP6hzegXp4tk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777333251; c=relaxed/simple;
	bh=oUFlTiGYqw73lHnw86juUKMkGTiWASsaJfIxIyDpvY8=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=W9gmJN2FFfrME48YCCec0V5CM93lu3z6etLkbGPHoiLJ64nfDm9hfo535u0wKU67Jf1Xvi2KQJKxGO/1Jj3AHGgeY/FGLQEHCJ8ARiAjjsZzb5hhXyD5m5cEkOow33V/YkMyXqLAdbj/DFAI3Iat+LhMF5S/FcR9UR3goqYLu+g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=bE+pno7q; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="bE+pno7q"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id CD507210CD;
	Tue, 28 Apr 2026 02:40:43 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=+N8l8xhO
	6EweGkIZO6SUeyy8/92nakMTqZK+u/GGXGQ=; b=bE+pno7qsEoY9xS+GdCoyxYr
	c44u8l1CTEUqU0wbr1dNuIVphKO2353TJcLlFWmHca4bUEM0XAr0ASeA+63Wb2bz
	OF0kZP4u2DUGpj4Cb+O8u41QndsyDv0J/0pOl1gqs0hRcIqyNP2BsMoL2Yn81xI6
	QjzWkS0fy+FhRwpQiTe0Bh+O0WDt4IfdAU9x4AMOGpm8bk83Xo3XWlY0ofdYm39/
	8q2rPJcSVqGk5qAmy8si3oifw0805ynUov3nFRpgaVaS3qeinuKiM2TIlHmWj3nO
	771+r1VrP1L4RizGi0onE5A4305MHBSRO1sUhbo83o47vrlOvxJB8W8MGyrD1Gnv
	TiDt8KVKywhVKrWN4wUvNSiyKPSunmw8N8nEuKnHwrqW/MEtBKdsw3ve3+U/CbD2
	bfWe6Ub95Ta5biJBVM6S8wnTRFJ7WcA+BCYBQOjOODYj74USIRwcuH7G0aoK7Fnz
	Nw2HMnSb3ymcOdDITk99Pv8RTQeuZKYSTpcYt8dJP1GyqQCg37Fh7nts/nNGC1S4
	H0RfedQcppXrdJXbproe3JYPUTdDe11da60sT6OARDkjT6MQQv/m7HrEPXNj0z+z
	gUmnEidXm2noEdjxWIX3NBVJj7zEfsHmv5emZ2hc9xy2aJ042gseH4XKho6Oe2xn
	QYFiMfQBk18qXYeI2Zo=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 28 Apr 2026 02:40:42 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 07CAE608B8;
	Tue, 28 Apr 2026 02:40:42 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63RNeeG0086275;
	Tue, 28 Apr 2026 02:40:40 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63RNeeW0086274;
	Tue, 28 Apr 2026 02:40:40 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH net] ipvs: fix shift-out-of-bounds in ip_vs_rht_desired_size
Date: Tue, 28 Apr 2026 02:40:14 +0300
Message-ID: <20260427234014.86256-1-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
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


