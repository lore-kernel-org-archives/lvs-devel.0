Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6FCCB3FE65D;
	Wed, 29 Apr 2026 14:14:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777472089; cv=none; b=N54Q1ixDUrBF7E9ystvXmdMntZ0djp9w6g1tNmsOom0I7VlmniJwEuAJHbeZtD5L3ukZWUlqDE5U0WeySMQEjIas2c09grIiJbxftdP2JWrOWDgO2zh0gwF/aKbSpAmEUsunUQadO1LpE6cwXn46NLD7q2+ZfW2vHrS6AkKsQ8w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777472089; c=relaxed/simple;
	bh=jkm7r/R3dWnnO03jj/+18wNZJ5urLHsZyk9p+l5sH2M=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=WOR33gz2iBGlMn84wepeSCnbWc0TrYy01eytuOfzo9h0ONk307iTYt3OmTm4aD934LbXGAoGUrbPwbUgKfWkMrIsACXLWKNq2bUrHriShoavLGhLLxkQG0JLhqvfwlQF720ZV+AOutbk887EmrwDjzj7qeowficuu/hIlAV2sEM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=llxe4TFF; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="llxe4TFF"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 0910B21CFC;
	Wed, 29 Apr 2026 17:14:14 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=yGih8EcvEzdVGxUHmXhJRDRnWAJYxMzx8DbWAxAe2F8=; b=llxe4TFFjFGy
	fWlrMxbmbd9xD3bkwf3hW5JcNZlWmvl2UVRoqMZdNhleZqP2+0LrUDnGD5/Qa7Xl
	GDHw3dwWGQ2LHhBhpHrWrNXBNrhKX7FX4zSOptUf/SkZLYVWLyngXv3S7KHvgwM8
	A0u56Jp/PRHAGhs7vTqMDbs7dDRxmBtk3lFudh8rS74nQ0XCUMh48DKx9JbQbbuX
	WLerwfrxy09+zAbHTqT33LvNV5rNcRetzuD+izaP4uRxKTP4VMri8JjK5lZg+rHu
	gQneNw/baJNtvdpd8kGm9/XyDbRf2Ym4m0sFn//ryJgzVT0Yy/goUHHQBP57u42v
	z0LUDlr9jEh/4DsKwMMLzR2Jb1FuK+FE3WJSJhR4WnXTYQMLVas3KzMdvCZxy3/P
	4tcgR0p8dvgMHIrNKjaH0bBqaCEYaTHYPik98Q4zzMenT6ouTulCpxZrx8s5uqk1
	BoIvWIGXeWiiFehqpA/kSNT8mK/bMhB2fZeOwJ2lfZERedi0LSxJgKMCD1YjkxyJ
	M36F6CnmnueikS5jD9x8KI1P153RLUI3nR5HkHsvpWlpgM1P4A5WEHaLPFKHcpBH
	A8qDPvROAUHT6VTlIwLP0PhaDK7mD30PB8f85AehyFLl1bidwjn6gs9r3lUNxoy/
	S/mUIkVWkkcMvQcDuw2KjkBId0FXdDg=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 29 Apr 2026 17:14:12 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 658CE61BAA;
	Wed, 29 Apr 2026 17:14:11 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63TEBLAK085085;
	Wed, 29 Apr 2026 17:11:21 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63TEBL4S085084;
	Wed, 29 Apr 2026 17:11:21 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        Waiman Long <longman@redhat.com>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org
Subject: [PATCHv2 nf 1/8] ipvs: fixes for the new ip_vs_status info
Date: Wed, 29 Apr 2026 17:10:48 +0300
Message-ID: <20260429141055.85052-2-ja@ssi.bg>
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

Sashiko reports some problems for the recently added
/proc/net/ip_vs_status:

* ip_vs_status_show() as a table reader may run long after the
conn_tab and svc_table table are released. While ip_vs_conn_flush()
properly changes the conn_tab_changes counter when conn_tab is removed,
ip_vs_del_service() and ip_vs_flush() were missing such change for
the svc_table_changes counter. As result, readers like
ip_vs_dst_event() and ip_vs_status_show() may continue to use
a freed table after a cond_resched_rcu() call.

* While counting the buckets in ip_vs_status_show() make sure we
traverse only the needed number of entries in the chain. This also
prevents possible overflow of the 'count' variable.

* Add check for 'loops' to prevent infinite loops while restarting
the traversal on table change.

* While IP_VS_CONN_TAB_MAX_BITS is 20 on 32-bit platforms and
there is no risk to overflow when multiplying the number of
conn_tab buckets to 100, prefer the div_u64() helper to make
the following dividing safer.

* Use 0440 permissions for ip_vs_status to restrict the
info only to root due to the exported information for hash
distribution.

Link: https://sashiko.dev/#/patchset/20260410112352.23599-1-fw%40strlen.de
Fixes: 9a9ccef907a7 ("ipvs: add ip_vs_status info")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 51 ++++++++++++++++++++++++----------
 1 file changed, 36 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 6632daa87ded..27e50afe9a54 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2032,6 +2032,9 @@ static int ip_vs_del_service(struct ip_vs_service *svc)
 		cancel_delayed_work_sync(&ipvs->svc_resize_work);
 		if (t) {
 			rcu_assign_pointer(ipvs->svc_table, NULL);
+			/* Inform readers that table is removed */
+			smp_mb__before_atomic();
+			atomic_inc(&ipvs->svc_table_changes);
 			while (1) {
 				p = rcu_dereference_protected(t->new_tbl, 1);
 				call_rcu(&t->rcu_head, ip_vs_rht_rcu_free);
@@ -2078,6 +2081,9 @@ static int ip_vs_flush(struct netns_ipvs *ipvs, bool cleanup)
 	t = rcu_dereference_protected(ipvs->svc_table, 1);
 	if (t) {
 		rcu_assign_pointer(ipvs->svc_table, NULL);
+		/* Inform readers that table is removed */
+		smp_mb__before_atomic();
+		atomic_inc(&ipvs->svc_table_changes);
 		while (1) {
 			p = rcu_dereference_protected(t->new_tbl, 1);
 			call_rcu(&t->rcu_head, ip_vs_rht_rcu_free);
@@ -3004,7 +3010,8 @@ static int ip_vs_status_show(struct seq_file *seq, void *v)
 	int old_gen, new_gen;
 	u32 counts[8];
 	u32 bucket;
-	int count;
+	u32 count;
+	int loops;
 	u32 sum1;
 	u32 sum;
 	int i;
@@ -3020,6 +3027,7 @@ static int ip_vs_status_show(struct seq_file *seq, void *v)
 	if (!atomic_read(&ipvs->conn_count))
 		goto after_conns;
 	old_gen = atomic_read(&ipvs->conn_tab_changes);
+	loops = 0;
 
 repeat_conn:
 	smp_rmb(); /* ipvs->conn_tab and conn_tab_changes */
@@ -3032,8 +3040,11 @@ static int ip_vs_status_show(struct seq_file *seq, void *v)
 			resched_score++;
 			ip_vs_rht_walk_bucket_rcu(t, bucket, head) {
 				count = 0;
-				hlist_bl_for_each_entry_rcu(hn, e, head, node)
+				hlist_bl_for_each_entry_rcu(hn, e, head, node) {
 					count++;
+					if (count >= ARRAY_SIZE(counts) - 1)
+						break;
+				}
 			}
 			resched_score += count;
 			if (resched_score >= 100) {
@@ -3042,37 +3053,41 @@ static int ip_vs_status_show(struct seq_file *seq, void *v)
 				new_gen = atomic_read(&ipvs->conn_tab_changes);
 				/* New table installed ? */
 				if (old_gen != new_gen) {
+					/* Too many changes? */
+					if (++loops >= 5)
+						goto after_conns;
 					old_gen = new_gen;
 					goto repeat_conn;
 				}
 			}
-			counts[min(count, (int)ARRAY_SIZE(counts) - 1)]++;
+			counts[count]++;
 		}
 	}
 	for (sum = 0, i = 0; i < ARRAY_SIZE(counts); i++)
 		sum += counts[i];
 	sum1 = sum - counts[0];
-	seq_printf(seq, "Conn buckets empty:\t%u (%lu%%)\n",
-		   counts[0], (unsigned long)counts[0] * 100 / max(sum, 1U));
+	seq_printf(seq, "Conn buckets empty:\t%u (%llu%%)\n",
+		   counts[0], div_u64((u64)counts[0] * 100U, max(sum, 1U)));
 	for (i = 1; i < ARRAY_SIZE(counts); i++) {
 		if (!counts[i])
 			continue;
-		seq_printf(seq, "Conn buckets len-%d:\t%u (%lu%%)\n",
+		seq_printf(seq, "Conn buckets len-%d:\t%u (%llu%%)\n",
 			   i, counts[i],
-			   (unsigned long)counts[i] * 100 / max(sum1, 1U));
+			   div_u64((u64)counts[i] * 100U, max(sum1, 1U)));
 	}
 
 after_conns:
 	t = rcu_dereference(ipvs->svc_table);
 
 	count = ip_vs_get_num_services(ipvs);
-	seq_printf(seq, "Services:\t%d\n", count);
+	seq_printf(seq, "Services:\t%u\n", count);
 	seq_printf(seq, "Service buckets:\t%d (%d bits, lfactor %d)\n",
 		   t ? t->size : 0, t ? t->bits : 0, t ? t->lfactor : 0);
 
 	if (!count)
 		goto after_svc;
 	old_gen = atomic_read(&ipvs->svc_table_changes);
+	loops = 0;
 
 repeat_svc:
 	smp_rmb(); /* ipvs->svc_table and svc_table_changes */
@@ -3086,8 +3101,11 @@ static int ip_vs_status_show(struct seq_file *seq, void *v)
 			ip_vs_rht_walk_bucket_rcu(t, bucket, head) {
 				count = 0;
 				hlist_bl_for_each_entry_rcu(svc, e, head,
-							    s_list)
+							    s_list) {
 					count++;
+					if (count >= ARRAY_SIZE(counts) - 1)
+						break;
+				}
 			}
 			resched_score += count;
 			if (resched_score >= 100) {
@@ -3096,24 +3114,27 @@ static int ip_vs_status_show(struct seq_file *seq, void *v)
 				new_gen = atomic_read(&ipvs->svc_table_changes);
 				/* New table installed ? */
 				if (old_gen != new_gen) {
+					/* Too many changes? */
+					if (++loops >= 5)
+						goto after_svc;
 					old_gen = new_gen;
 					goto repeat_svc;
 				}
 			}
-			counts[min(count, (int)ARRAY_SIZE(counts) - 1)]++;
+			counts[count]++;
 		}
 	}
 	for (sum = 0, i = 0; i < ARRAY_SIZE(counts); i++)
 		sum += counts[i];
 	sum1 = sum - counts[0];
-	seq_printf(seq, "Service buckets empty:\t%u (%lu%%)\n",
-		   counts[0], (unsigned long)counts[0] * 100 / max(sum, 1U));
+	seq_printf(seq, "Service buckets empty:\t%u (%llu%%)\n",
+		   counts[0], div_u64((u64)counts[0] * 100U, max(sum, 1U)));
 	for (i = 1; i < ARRAY_SIZE(counts); i++) {
 		if (!counts[i])
 			continue;
-		seq_printf(seq, "Service buckets len-%d:\t%u (%lu%%)\n",
+		seq_printf(seq, "Service buckets len-%d:\t%u (%llu%%)\n",
 			   i, counts[i],
-			   (unsigned long)counts[i] * 100 / max(sum1, 1U));
+			   div_u64((u64)counts[i] * 100U, max(sum1, 1U)));
 	}
 
 after_svc:
@@ -5039,7 +5060,7 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 				    ipvs->net->proc_net,
 				    ip_vs_stats_percpu_show, NULL))
 		goto err_percpu;
-	if (!proc_create_net_single("ip_vs_status", 0, ipvs->net->proc_net,
+	if (!proc_create_net_single("ip_vs_status", 0440, ipvs->net->proc_net,
 				    ip_vs_status_show, NULL))
 		goto err_status;
 #endif
-- 
2.53.0


