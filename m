Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3CB87373C04;
	Wed, 15 Apr 2026 20:05:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776283536; cv=none; b=lkvgCAZxTIYq5mc1xLC4GDa/1LpH+Qtjdk9Hwz2XgJTTHnM85EXqK/K9VLwIB8EQ0xaV6Nq9qtZSXW1OBspjxxG68RPpU/HW+fXk3GIkquT07YjPokQOkKTi1YwDlUNwIpjZWhAojkPTWVlVshMbB2OCgW+UZcJ2yYkKYvMrZ/A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776283536; c=relaxed/simple;
	bh=e9yXjpHxlDuMvK+1gBHVgiUCambJT29h/6ksorUkIFU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=L6NifiKHCo6F9wnbXJijOVa8lIM392j+T2gyIPQ8/25DhFro6dla8A+5UWJwoJ6sVgVtsp4jL3bQOk6+RzIy6ib4aQKZi0kW9tnyAuZSeU6Bsh7vDwPi9ON9/17F+8CEMLfkx2VFwpoZH2+aJCV2u2Mqx14kRoAHl7mUPpAfRxQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=pLTAgD/m; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="pLTAgD/m"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 70EAB21109;
	Wed, 15 Apr 2026 23:05:18 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=01UtdVvsTe+NU8pEfyanQjMt2ACQt6xn0yg+GScOdbQ=; b=pLTAgD/mSO1R
	kjEpcucCQ4zKMw01Zt/PiBBOFwZ7TA8v63XMYP8ccVqz8CWdRycoD1A/b2CjGrx9
	H23nqDeVEpA/N35mPb/dGo1mGorcDaPJLwIseUBiIsNzavxoSsM4RvUEcA+eNVYW
	+nfwQ4WC42gPiGZpWgupAF0RkW7WksMQTs5kxy4JRnvhRQ61FVa6Q1+lfmRAjioF
	wln7Nnvuc4z149QMhHyp0IEfqVrGv5k/bxcWqcu79OZU7WzVtNUHd/lEDt38uaCi
	a74+MwjW8PZAHWoMbv1siiLrLYMYk69A3MYSKYPi5l/F3v5PQJ6nOYUmDHgUBLZZ
	ua19DQtiAUL2ti3yTKS6Wl3SHvbZvYDxHRWrXzPy3vk0vI2suKjV7cVBuXIdZzn+
	gTOQxByyNZgZDiaGYpBYjQFOMWA8MJlZDjDX5E7MTmh9UX8Sl6S7UG+B83o0XGEX
	HjpQC6jJde3lEtjQKLHwAILXfJdXLCBqtR0dLUsp+1V3g/0ZNiY2T5ihAAWBJk+w
	IWpPdUC9Caiy3ouoo7cnWNdB50ls8uH9Nww9QVy3mSDVnWFcKgFs+Is5U7IuHNPu
	T8yyj91HVu2UlmLML/LwiWjsqEQWuV6p+TGbAmuKovavpRhpAhDzVD5qhUx4SSWZ
	YoMDKI3G8p9i6QlE3Cjc1/KKqmxSkW8=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 15 Apr 2026 23:05:16 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 4DF7F659B9;
	Wed, 15 Apr 2026 23:05:16 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63FK2dBd079739;
	Wed, 15 Apr 2026 23:02:39 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63FK2dCr079738;
	Wed, 15 Apr 2026 23:02:39 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH net 3/3] ipvs: fix the spin_lock usage for RT build
Date: Wed, 15 Apr 2026 23:02:16 +0300
Message-ID: <20260415200216.79699-4-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260415200216.79699-1-ja@ssi.bg>
References: <20260415200216.79699-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

syzbot reports for sleeping function called from invalid context [1].
The recently added code for resizable hash tables uses
hlist_bl bit locks in combination with spin_lock for
the connection fields (cp->lock).

Fix the following problems:

* avoid using spin_lock(&cp->lock) under locked bit lock
because it sleeps on PREEMPT_RT

* as the recent changes call ip_vs_conn_hash() only for newly
allocated connection, the spin_lock can be removed there because
the connection is still not linked to table and does not need
cp->lock protection.

* the lock can be removed also from ip_vs_conn_unlink() where we
are the last connection user.

* the last place that is fixed is ip_vs_conn_fill_cport()
where the locks can be reordered to follow the RT rules.

[1]:
BUG: sleeping function called from invalid context at kernel/locking/spinlock_rt.c:48
in_atomic(): 1, irqs_disabled(): 0, non_block: 0, pid: 16, name: ktimers/0
preempt_count: 2, expected: 0
RCU nest depth: 3, expected: 3
8 locks held by ktimers/0/16:
 #0: ffffffff8de5f260 (local_bh){.+.+}-{1:3}, at: __local_bh_disable_ip+0x3c/0x420 kernel/softirq.c:163
 #1: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: __local_bh_disable_ip+0x3c/0x420 kernel/softirq.c:163
 #2: ffff8880b8826360 (&base->expiry_lock){+...}-{3:3}, at: spin_lock include/linux/spinlock_rt.h:45 [inline]
 #2: ffff8880b8826360 (&base->expiry_lock){+...}-{3:3}, at: timer_base_lock_expiry kernel/time/timer.c:1502 [inline]
 #2: ffff8880b8826360 (&base->expiry_lock){+...}-{3:3}, at: __run_timer_base+0x120/0x9f0 kernel/time/timer.c:2384
 #3: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:300 [inline]
 #3: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:838 [inline]
 #3: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: __rt_spin_lock kernel/locking/spinlock_rt.c:50 [inline]
 #3: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: rt_spin_lock+0x1e0/0x400 kernel/locking/spinlock_rt.c:57
 #4: ffffc90000157a80 ((&cp->timer)){+...}-{0:0}, at: call_timer_fn+0xd4/0x5e0 kernel/time/timer.c:1745
 #5: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:300 [inline]
 #5: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:838 [inline]
 #5: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: ip_vs_conn_unlink net/netfilter/ipvs/ip_vs_conn.c:315 [inline]
 #5: ffffffff8dfc80c0 (rcu_read_lock){....}-{1:3}, at: ip_vs_conn_expire+0x257/0x2390 net/netfilter/ipvs/ip_vs_conn.c:1260
 #6: ffffffff8de5f260 (local_bh){.+.+}-{1:3}, at: __local_bh_disable_ip+0x3c/0x420 kernel/softirq.c:163
 #7: ffff888068d4c3f0 (&cp->lock#2){+...}-{3:3}, at: spin_lock include/linux/spinlock_rt.h:45 [inline]
 #7: ffff888068d4c3f0 (&cp->lock#2){+...}-{3:3}, at: ip_vs_conn_unlink net/netfilter/ipvs/ip_vs_conn.c:324 [inline]
 #7: ffff888068d4c3f0 (&cp->lock#2){+...}-{3:3}, at: ip_vs_conn_expire+0xd4a/0x2390 net/netfilter/ipvs/ip_vs_conn.c:1260
Preemption disabled at:
[<ffffffff898a6358>] bit_spin_lock include/linux/bit_spinlock.h:38 [inline]
[<ffffffff898a6358>] hlist_bl_lock+0x18/0x110 include/linux/list_bl.h:149
CPU: 0 UID: 0 PID: 16 Comm: ktimers/0 Tainted: G        W    L      syzkaller #0 PREEMPT_{RT,(full)}
Tainted: [W]=WARN, [L]=SOFTLOCKUP
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 03/18/2026
Call Trace:
 <TASK>
 dump_stack_lvl+0xe8/0x150 lib/dump_stack.c:120
 __might_resched+0x329/0x480 kernel/sched/core.c:9162
 __rt_spin_lock kernel/locking/spinlock_rt.c:48 [inline]
 rt_spin_lock+0xc2/0x400 kernel/locking/spinlock_rt.c:57
 spin_lock include/linux/spinlock_rt.h:45 [inline]
 ip_vs_conn_unlink net/netfilter/ipvs/ip_vs_conn.c:324 [inline]
 ip_vs_conn_expire+0xd4a/0x2390 net/netfilter/ipvs/ip_vs_conn.c:1260
 call_timer_fn+0x192/0x5e0 kernel/time/timer.c:1748
 expire_timers kernel/time/timer.c:1799 [inline]
 __run_timers kernel/time/timer.c:2374 [inline]
 __run_timer_base+0x6a3/0x9f0 kernel/time/timer.c:2386
 run_timer_base kernel/time/timer.c:2395 [inline]
 run_timer_softirq+0xb7/0x170 kernel/time/timer.c:2405
 handle_softirqs+0x1de/0x6d0 kernel/softirq.c:622
 __do_softirq kernel/softirq.c:656 [inline]
 run_ktimerd+0x69/0x100 kernel/softirq.c:1151
 smpboot_thread_fn+0x541/0xa50 kernel/smpboot.c:160
 kthread+0x388/0x470 kernel/kthread.c:436
 ret_from_fork+0x514/0xb70 arch/x86/kernel/process.c:158
 ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245
 </TASK>

Reported-by: syzbot+504e778ddaecd36fdd17@syzkaller.appspotmail.com
Fixes: 2fa7cc9c7025 ("ipvs: switch to per-net connection table")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_conn.c | 49 ++++++++++++++-------------------
 1 file changed, 21 insertions(+), 28 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 84a4921a7865..cf19dc06c65d 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -267,27 +267,20 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
 		hash_key2 = hash_key;
 		use2 = false;
 	}
+
 	conn_tab_lock(t, cp, hash_key, hash_key2, use2, true /* new_hash */,
 		      &head, &head2);
-	spin_lock(&cp->lock);
-
-	if (!(cp->flags & IP_VS_CONN_F_HASHED)) {
-		cp->flags |= IP_VS_CONN_F_HASHED;
-		WRITE_ONCE(cp->hn0.hash_key, hash_key);
-		WRITE_ONCE(cp->hn1.hash_key, hash_key2);
-		refcount_inc(&cp->refcnt);
-		hlist_bl_add_head_rcu(&cp->hn0.node, head);
-		if (use2)
-			hlist_bl_add_head_rcu(&cp->hn1.node, head2);
-		ret = 1;
-	} else {
-		pr_err("%s(): request for already hashed, called from %pS\n",
-		       __func__, __builtin_return_address(0));
-		ret = 0;
-	}
 
-	spin_unlock(&cp->lock);
+	cp->flags |= IP_VS_CONN_F_HASHED;
+	WRITE_ONCE(cp->hn0.hash_key, hash_key);
+	WRITE_ONCE(cp->hn1.hash_key, hash_key2);
+	refcount_inc(&cp->refcnt);
+	hlist_bl_add_head_rcu(&cp->hn0.node, head);
+	if (use2)
+		hlist_bl_add_head_rcu(&cp->hn1.node, head2);
+
 	conn_tab_unlock(head, head2);
+	ret = 1;
 
 	/* Schedule resizing if load increases */
 	if (atomic_read(&ipvs->conn_count) > t->u_thresh &&
@@ -321,7 +314,6 @@ static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
 
 	conn_tab_lock(t, cp, hash_key, hash_key2, use2, false /* new_hash */,
 		      &head, &head2);
-	spin_lock(&cp->lock);
 
 	if (cp->flags & IP_VS_CONN_F_HASHED) {
 		/* Decrease refcnt and unlink conn only if we are last user */
@@ -334,7 +326,6 @@ static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
 		}
 	}
 
-	spin_unlock(&cp->lock);
 	conn_tab_unlock(head, head2);
 
 	rcu_read_unlock();
@@ -637,6 +628,7 @@ void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport)
 	struct ip_vs_conn_hnode *hn;
 	u32 hash_key, hash_key_new;
 	struct ip_vs_conn_param p;
+	bool changed = false;
 	int ntbl;
 	int dir;
 
@@ -709,9 +701,7 @@ void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport)
 		goto retry;
 	}
 
-	spin_lock(&cp->lock);
-	if ((cp->flags & IP_VS_CONN_F_NO_CPORT) &&
-	    (cp->flags & IP_VS_CONN_F_HASHED)) {
+	if (cp->flags & IP_VS_CONN_F_NO_CPORT) {
 		/* We do not recalc hash_key_r under lock, we assume the
 		 * parameters in cp do not change, i.e. cport is
 		 * the only possible change.
@@ -726,19 +716,22 @@ void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport)
 			hlist_bl_del_rcu(&hn->node);
 			hlist_bl_add_head_rcu(&hn->node, head_new);
 		}
-		if (!dir) {
-			atomic_dec(&ipvs->no_cport_conns[af_id]);
-			cp->flags &= ~IP_VS_CONN_F_NO_CPORT;
-			cp->cport = cport;
-		}
+		if (!dir)
+			changed = true;
 	}
-	spin_unlock(&cp->lock);
 
 	if (head != head2)
 		hlist_bl_unlock(head2);
 	hlist_bl_unlock(head);
 	write_seqcount_end(&t->seqc[hash_key & t->seqc_mask]);
 	preempt_enable_nested();
+	if (changed) {
+		atomic_dec(&ipvs->no_cport_conns[af_id]);
+		spin_lock(&cp->lock);
+		cp->flags &= ~IP_VS_CONN_F_NO_CPORT;
+		cp->cport = cport;
+		spin_unlock(&cp->lock);
+	}
 	spin_unlock_bh(&t->lock[hash_key & t->lock_mask].l);
 	if (dir--)
 		goto next_dir;
-- 
2.53.0


