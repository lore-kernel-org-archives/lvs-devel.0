Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3D4C13FE648;
	Wed, 29 Apr 2026 14:14:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777472062; cv=none; b=FnPg3AnCkepc9+P9Zx2cveVJHAuqhV4UXDYNTRZUvuHHdabZ+xSpeNnNjIdX9o74Rpwe/KjeI0CRRjgKAZt6Gb2ZZP2OUq8FfK5/mc05GcrFAEXvnzNr6gP6YgAco6YdBzfIuAGYqVoNP0qEa9pQPt4b7WqYI9Usa14kAcJVquc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777472062; c=relaxed/simple;
	bh=C2hWpN7sSjdGkm4rOVk6n/xWQGh7Kysu6wMLYYWievA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=F+47aVcZprkYP+SXYIYWMEQ2b+v9sYvi9MwHlUZxv/u6A/sfXIhPE/m2sATBOD8ROYxd4hX6Yx0DBrflJwRvx1ysSLMb8dwBHF+tn9igu6z7V7yUehCxq/Vy+35QqPxxGqCHcU7PbkqSv8D1wrjZV5/kYR3EHl8GkDJrWutu4ik=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=XF+2smIq; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="XF+2smIq"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 1004721CB4;
	Wed, 29 Apr 2026 17:14:10 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=Uqax325+N5JDs/S0EJd8JLZMGuyA5PI6DaXMbKDlAP4=; b=XF+2smIqstZY
	NtLl766WfAKO4UcWgPL4UZDQA8U2baPS3dr1ncXfylBRcFzJhc+37PwjUqDsuEZv
	gfOpOTRajc8DMFWT7SSZv9ZspbY8iS+QujmlyW5GgSUsu1keZjWTVWiVn/UjOHxP
	Rvteq7mAprGCHO2Ysh9sYnrgmDeWDzalhzL6h33I5AQflx7mGnOh8GmwDjWXM6jH
	zNSZtiCIgGbyrhcKhTW31miusFaqSYO88vIt32ECOzR0dw81KTZfBOpL7dtXP0VI
	F/IEICeEDlXEbuQ7xDfkYj9cK4/Uk3BeTEYacvAwRjIDHXszst1rVTWVJYVoJ3Qr
	O4VR/JigcRQX2zN2RcY0IN+HUASD3cGu9hdY3GZZ+/2WzLzJycOYkt/8krlOvDFR
	oe+YDOXeAB62a8sG6ouNNVJLsd1i7+u0aoHyUZtg6KnAh3e5HMDeLjmXbHE4uqSf
	P5iIiZd4k/xp65EToEit+mC5sNZFBSCop8Kwiqx6BclpbrTX587cY+Ulqoz1lifc
	ooPAeXzJCiKA3V8Mwm4SH6Zrd//ov25g0ys6ODLfPO9gUW7gbvFQ0LHdmTaiqFqv
	4a0iIUkeWoU9Fl/YrjbUe8AXR42Ee7c5vFVEJ8Uc6GIPDgSQF/aOQqdNtCHzNBfr
	bLLGefMpPCC9Ua5vQDG8DFM88WwpwIQ=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 29 Apr 2026 17:14:09 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 53D0D61BAA;
	Wed, 29 Apr 2026 17:14:08 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63TEBMuo085106;
	Wed, 29 Apr 2026 17:11:22 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63TEBMW4085105;
	Wed, 29 Apr 2026 17:11:22 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        Waiman Long <longman@redhat.com>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org
Subject: [PATCHv2 nf 6/8] ipvs: fix shift-out-of-bounds in ip_vs_rht_desired_size
Date: Wed, 29 Apr 2026 17:10:53 +0300
Message-ID: <20260429141055.85052-7-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260429141055.85052-1-ja@ssi.bg>
References: <20260429141055.85052-1-ja@ssi.bg>
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
2.53.0


