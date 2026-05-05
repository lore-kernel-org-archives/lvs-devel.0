Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 67083C2FF;
	Tue,  5 May 2026 00:16:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.190.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777940220; cv=none; b=kxEYV2yjI2EnY4XuoTjdkIagMC7/v6VeMBWO9Pv6l5gBebGos5vaZvCkP7ti7O0xOT3HaM1IfX0W0DO9CDthLEsmdDQR9BfUD0kCvJnYE7NYNxWByB5uZ6Oh5i3LnopvRuvXNiKfCPkq4hOKPSUv9pSBzHmRGVfTZJWIcjX0vDo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777940220; c=relaxed/simple;
	bh=pxKidJHG4a3C/DZY1sB8S4jDIP4CpO8Xq9Myeol9zdA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=LVrYrZvEe+7yW1SHdku5u0MhiwWoGkn8NU+7yZ6djtPeTf1y6Hxups1v95ecL8Xuhbi10xdS9S68wJUd43sJnvABXAjjzeu9GO+5uNkLgszgSejIiEv1lIb50mlNjwhLENE+AQ2IQ4FOug/EYyoROpJ9tnwl8HxyY4Jym1qyjFg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=netfilter.org; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=CwTAXVim; arc=none smtp.client-ip=217.70.190.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="CwTAXVim"
Received: from localhost.localdomain (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with ESMTPSA id E850A60181;
	Tue,  5 May 2026 02:16:55 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1777940216;
	bh=uPZ896Zgh272488gEzE2HlBBz/KAOowvBbsGSKO5Pdc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=CwTAXVim5n7Hb/bh3+fXA49XmO29Z2iGi0JB4CFuckWdDkYlMirgVcnMwPFORHxyI
	 3XR3ZLo0A5423VVquNxov0M+2KlG9rwkgMDP4xJUSpe4+0f/AMcT4rongelUnWcwOe
	 nqjcLbSPN9EyRJBu+jCLuooOYZsorxAedb6dRBPKHKA5QInuvzibKQ5jq7Nl6ZisRZ
	 fv2/VGSnC48kureZgeDwieYa5KwBrF0sL7f0E1QdVxTO6iCZQ0BwAyCrn71yARfVhs
	 jSUyG1QOS6fxTBVu69zrwbF/8oWjzg5Mr/YAkN+FetIPaWJVqQ/ktsHRb2BUFUk94T
	 kGbDIoiDXkqFg==
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
Subject: [PATCH net 1/8] ipvs: fixes for the new ip_vs_status info
Date: Tue,  5 May 2026 02:16:41 +0200
Message-ID: <20260505001648.360569-2-pablo@netfilter.org>
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
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
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
2.47.3

