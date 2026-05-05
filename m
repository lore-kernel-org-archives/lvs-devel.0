Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 522843D544;
	Tue,  5 May 2026 00:17:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.190.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777940228; cv=none; b=Q94Oqwd3rjRxuoVA5IN5Mgx+PTuU1cmIQLFTE5trymEiJyj2Jm4+kJUOTS3gbWWJ6/n7yQgaMSwJlHt/Jttj+IVXuwmfA9U7um3hIKbKVTVKzF5W1LV131klGMvQMZLGnKgr0k64uYW8IY37W58Ia8cOPbA9SR2CTj1BPM7Y/Pk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777940228; c=relaxed/simple;
	bh=5RlN+0wnE6bwlZ6hI+1LSdLaozfMOIsiR3Y7M+6M/Yk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Anc1JqvRRPLBDnDtO9yXVv976gWH0khbhfHIl0n2gG3+Tr9b4le6IZ4WqHSHthTVy2T93pZqnAFA8eTHmORmRjUf1ai8CowtiIUFDiBAcabaMELSTXosSz0+0BjY6FnMkl9DDeKNwbdqcN2TyO/l0nU+LEdQQrs0gJUZbGqR1qE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=netfilter.org; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=PwfqFSmE; arc=none smtp.client-ip=217.70.190.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="PwfqFSmE"
Received: from localhost.localdomain (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with ESMTPSA id 1763D60251;
	Tue,  5 May 2026 02:17:05 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1777940225;
	bh=BrcsPN65p0Hx/4PX8W3RwJL6DXDf0dTZlRLldrNse9c=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=PwfqFSmEB9p3IHarQt0HZrLj1F8nRkHLDRHuficwnu76sIi7ftkUEfgvYae8hxwME
	 7RU2fru5r7key3K12StJcoeLYaONGNpwGXU5bq+5PGBiFJY/M96f6M4f5XTFelHMgx
	 RxvlWUtuIBnzUXrEuLBc7z03Jrw7IG3BaLy+kfGy1wvaZX2jAGVws8YpqSOPv0Oe3Y
	 km7WQcTZrCwUACSCzdFng+U9fajh1O4apMPS408PZDXsMQmDrdNf44TOWfTz+8Bv90
	 xb1a9blaFafst9qlEYnsHQbvOCs9juhH/Kn0xtYwh2x3bR8liPL9IqUuESOz+hPdP6
	 T9BVF8NtddFFQ==
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: netfilter-devel@vger.kernel.org
Cc: davem@davemloft.net,
	netdev@vger.kernel.org,
	kuba@kernel.org,
	pabeni@redhat.com,
	edumazet@google.com,
	fw@strlen.de,
	horms@kernel.org,
	ja@ssi.bg,
	longman@redhat.com,
	lvs-devel@vger.kernel.org
Subject: [PATCH net 6/8] ipvs: fix shift-out-of-bounds in ip_vs_rht_desired_size
Date: Tue,  5 May 2026 02:16:46 +0200
Message-ID: <20260505001648.360569-7-pablo@netfilter.org>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20260505001648.360569-1-pablo@netfilter.org>
References: <20260505001648.360569-1-pablo@netfilter.org>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Julian Anastasov <ja@ssi.bg>

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
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipvs/ip_vs_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index f5b7a2047291..d40b404c1bf6 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -237,7 +237,7 @@ int ip_vs_rht_desired_size(struct netns_ipvs *ipvs, struct ip_vs_rht *t, int n,
 {
 	if (!t)
 		return 1 << min_bits;
-	n = roundup_pow_of_two(n);
+	n = n > 0 ? roundup_pow_of_two(n) : 1;
 	if (lfactor < 0) {
 		int factor = min(-lfactor, max_bits);
 
-- 
2.47.3

