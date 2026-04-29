Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 009293FE67B;
	Wed, 29 Apr 2026 14:14:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777472095; cv=none; b=N1Fb56TRcKRCeg42HSkPI7U8igtFo+qaLn4z7zJK7KqrXg3sQDyntyQzSOUUuyPlXPIWjS3VVeXE9Ali1gJtBzDifFwPsHatwTqlr1RHBRb7p6roq+fhZDlcdkBEDy7kZYuTrYXVcpCYPSENgk1+HzCEMpnzw0UzYnn6+CBv2Gs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777472095; c=relaxed/simple;
	bh=xNKfHpUnbuQgCKWAd0/rPtiBRJsZj1IasreB0uU5dCA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=TYOelLX/4TsjaAiBseS0l/yvOdWVTpL9lI1RYrsp8ASGpaf+rsOMiXQbsz52yLokBMHfXyUOZhm6Z4kX5s4bqGyZuDuwHgu048U5qCPhY32Tfea09v+toCdVzbUmRUzhahAB2+IdWvDvGcm8X6/MAFcNKhKxHGxwaFb5S63QZiw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=VKgHt1Yo; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="VKgHt1Yo"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 426A621C55;
	Wed, 29 Apr 2026 17:14:15 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=Q+1wYlj2TMWDMHUtxtFR1v3/AEpQpZ/nztQnYdp4dz8=; b=VKgHt1YoEbi2
	Ablb/Q6gqEArTIyW3rRifxPbjCaBNb5HU/njeMk59XC06DfMsaTSpBwzgr7p2JJF
	3kBt+ZKGplpOxu4tGU2G+5sSbuMbQpi9L2rhR5Gr7EABvrhVePsL9meFoU1PLn+M
	A794A2/nuJX6DCTLERmBRyDS20Nxk9mvvohWSX3rT5HuT8LhHAxrCi1qfO6OG0kk
	gDIWJyLWyYMQMCHsMYC8YWbIScifpvoFfRlJL3Ox+j/q1qAH61JtNwdn/j4RS2/W
	0PuSwWkPmJwpNpiRHUUxwm8pftRxHSwKZju7MhCoJhG4N72/2k8s/XD0/P4Bkl8N
	6soG8TrTWnOR5on8ZcCEIxlHD2yfULIkBoSRkH5s9j/M2s1uRvEVANwPcEs819rH
	/fZqjZ8gN1gjWKBk0ubsCeF5z9twmSM6ZtUn1SKnokdEwAqXu28WWVLQQijn2mHs
	HRDE/R3DJgNfA01Gw6q7vpvI/wypMX/WkghzROnxQj7Qyy0sy/D05939kAEXgl76
	DrmRbqZAJTTnqdZL2qOHEXTR4Yb3odYp2IIXUQmmVzjXsuag81ZmpYose73pmOwX
	+PEWPJpKlrYnm/g7PLx+dpG0Um+48wZ7c7pYkKPwaKyLGx/MbfnMZWFivABVY1s2
	xSC9MaUnZpoCywsws4IHXLxXrqGwTuo=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 29 Apr 2026 17:14:13 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 6E62F62AE2;
	Wed, 29 Apr 2026 17:14:12 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63TEBM0X085093;
	Wed, 29 Apr 2026 17:11:22 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63TEBLGk085092;
	Wed, 29 Apr 2026 17:11:21 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        Waiman Long <longman@redhat.com>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org
Subject: [PATCHv2 nf 3/8] ipvs: fix the spin_lock usage for RT build
Date: Wed, 29 Apr 2026 17:10:50 +0300
Message-ID: <20260429141055.85052-4-ja@ssi.bg>
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
where now the cp->lock is locked before the other locks to
ensure other packets do not modify the cp->flags in non-atomic
way. Here we make sure cport and flags are changed only once
if two or more packets race to fill the cport. Also, we fill
cport early, so that if we race with resizing there will be
valid cport key for the hashing. Add a warning if too many
hash table changes occur for our RCU read-side critical
section which is error condition but minor because the
connection still can expire gracefully. Still, restore the
cport to 0 to allow retransmitted packet to properly fill
the cport. Problems reported by Sashiko.

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
Link: https://sashiko.dev/#/patchset/20260415200216.79699-1-ja%40ssi.bg
Link: https://sashiko.dev/#/patchset/20260420165539.85174-4-ja%40ssi.bg
Link: https://sashiko.dev/#/patchset/20260422135823.50489-4-ja%40ssi.bg
Fixes: 2fa7cc9c7025 ("ipvs: switch to per-net connection table")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

v5:
  restore cp->cport to 0 when ntbl reaches 2 to allow
  connection to continue on retransmission

v4:
  add error message for too many hash table changes in
  ip_vs_conn_fill_cport()

v3:
* use cp->lock in ip_vs_conn_fill_cport() to protect the
  cp->flags modifications

v2:
* remove cp->lock from ip_vs_conn_fill_cport() and avoid
  races with resizing and possible multiple attempts to fill cport.

 net/netfilter/ipvs/ip_vs_conn.c | 74 ++++++++++++++++++---------------
 1 file changed, 41 insertions(+), 33 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 84a4921a7865..9ea6b4fa78bf 100644
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
+	bool by_me = false;
 	int ntbl;
 	int dir;
 
@@ -664,8 +656,16 @@ void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport)
 		t = rcu_dereference(t->new_tbl);
 		ntbl++;
 		/* We are lost? */
-		if (ntbl >= 2)
+		if (ntbl >= 2) {
+			spin_lock_bh(&cp->lock);
+			if (cp->flags & IP_VS_CONN_F_NO_CPORT && by_me)
+				cp->cport = 0;
+			/* hn1 will be rehashed on next packet */
+			spin_unlock_bh(&cp->lock);
+			IP_VS_ERR_RL("%s(): Too many ht changes for dir %d\n",
+				     __func__, dir);
 			return;
+		}
 	}
 
 	/* Rehashing during resize? Use the recent table for adds */
@@ -683,10 +683,13 @@ void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport)
 	if (head > head2 && t == t2)
 		swap(head, head2);
 
+	/* Protect the cp->flags modification */
+	spin_lock_bh(&cp->lock);
+
 	/* Lock seqcount only for the old bucket, even if we are on new table
 	 * because it affects the del operation, not the adding.
 	 */
-	spin_lock_bh(&t->lock[hash_key & t->lock_mask].l);
+	spin_lock(&t->lock[hash_key & t->lock_mask].l);
 	preempt_disable_nested();
 	write_seqcount_begin(&t->seqc[hash_key & t->seqc_mask]);
 
@@ -704,14 +707,23 @@ void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport)
 		hlist_bl_unlock(head);
 		write_seqcount_end(&t->seqc[hash_key & t->seqc_mask]);
 		preempt_enable_nested();
-		spin_unlock_bh(&t->lock[hash_key & t->lock_mask].l);
+		spin_unlock(&t->lock[hash_key & t->lock_mask].l);
+		spin_unlock_bh(&cp->lock);
 		hash_key = hash_key_new;
 		goto retry;
 	}
 
-	spin_lock(&cp->lock);
-	if ((cp->flags & IP_VS_CONN_F_NO_CPORT) &&
-	    (cp->flags & IP_VS_CONN_F_HASHED)) {
+	/* Fill cport once, even if multiple packets try to do it */
+	if (cp->flags & IP_VS_CONN_F_NO_CPORT && (!cp->cport || by_me)) {
+		/* If we race with resizing make sure cport is set for dir 1 */
+		if (!cp->cport) {
+			cp->cport = cport;
+			by_me = true;
+		}
+		if (!dir) {
+			atomic_dec(&ipvs->no_cport_conns[af_id]);
+			cp->flags &= ~IP_VS_CONN_F_NO_CPORT;
+		}
 		/* We do not recalc hash_key_r under lock, we assume the
 		 * parameters in cp do not change, i.e. cport is
 		 * the only possible change.
@@ -726,21 +738,17 @@ void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport)
 			hlist_bl_del_rcu(&hn->node);
 			hlist_bl_add_head_rcu(&hn->node, head_new);
 		}
-		if (!dir) {
-			atomic_dec(&ipvs->no_cport_conns[af_id]);
-			cp->flags &= ~IP_VS_CONN_F_NO_CPORT;
-			cp->cport = cport;
-		}
 	}
-	spin_unlock(&cp->lock);
 
 	if (head != head2)
 		hlist_bl_unlock(head2);
 	hlist_bl_unlock(head);
 	write_seqcount_end(&t->seqc[hash_key & t->seqc_mask]);
 	preempt_enable_nested();
-	spin_unlock_bh(&t->lock[hash_key & t->lock_mask].l);
-	if (dir--)
+	spin_unlock(&t->lock[hash_key & t->lock_mask].l);
+
+	spin_unlock_bh(&cp->lock);
+	if (dir-- && by_me)
 		goto next_dir;
 }
 
-- 
2.53.0


