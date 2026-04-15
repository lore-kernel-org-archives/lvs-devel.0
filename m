Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 861CA373C04;
	Wed, 15 Apr 2026 20:05:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776283529; cv=none; b=AzXPHt8vYIHNi6xvTpulu2f9BXe5XcMDRGxt3XYlfx31MvYuz4cW7i9A6G3uBKh/OABzBxAR9vcUT0xnQw1IkIGeUksAH/H5ydW4WX73icBAKey9NV9mErAosOtT7TrKy2x3jm6AcgCt+tZREpkdq4PI4KfzgmVodsUOns5LXVA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776283529; c=relaxed/simple;
	bh=F4lUGPMdS/bvoUN+XN4+UZKi3zTbHNgMNCrxglybtcU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=S3piLQ8OWAcYsTkiWprGNXEhmV3cKK7qa7smwT5tIuIohiMIquNl2cE5+tvMitQjMM3F6qzMX5deHOX3H1bL8j4wGvoUuPV1CU7kwcY7czrfDci0cdv5EpkVsw6JnAYvP9khMc4PW5KBHlfnQxRRL3zJtFs8f91PIoIJYjB01SE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=g7qYDlCv; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="g7qYDlCv"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 60D322110C;
	Wed, 15 Apr 2026 23:05:17 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=gsAvRDH20KwST110vB0xZmQ42TWjJ6vjg6gG+LolkGU=; b=g7qYDlCvh39Q
	SKpUP59Dcun2M6dSvBuYc/x6ezVdCgyym0UCErzfzEh7blbRcotEiQqcJMCctsRv
	jam4+7eFLAMhxZ+qFN+mVbP/w6fh9f+W3HtAyNZ365sic1y2HqiOOzN5orTLdkgc
	5Fe8ggbNh663B0Jif+CR5iqmc5zsLQ3W8NMAAngy4w6zMCx8OxJJXQfyCy8iR7KN
	tg0Z9XKLWJqVru0Xvoh6wuh0ll72o/ffh92+ZVQmZyX8AJrFzWKhPIo8637yME9m
	CAiVL8TzmTNTyCh1aO+wg0arfwqs8j05qBD9fBcIErd6zUTFYI3OVO4xHONYoBcZ
	P/9hN6Qzi+ky5WuslWZExF8/8Sdl0FDq8pesXRC3h7AjM/t7RhAcIX6iEo20sRKh
	lhG7a15fyugf7xEccofJYl0+PuXZlbrnkTYukf5L79mYZ4O6YWIQg5yxMJRntNh5
	DJVDCbVPSl2cmVb/8UNxeOAz7rtMmXW7GdFpEh/xlkyX/Hdrwkf+ltCPjGxDCS5h
	aHr3R1YbdCz1QfaAZVoud0SCTkFLPq3KEuuAT5VhTGznGoLV+IWge/RFJMHHBU+5
	nI1j3GCgeRgjPRYRSb8nSrmx3lzKuBlBBVBQRZqyeIQ76rxj7gqHXa0KFy7ye9n2
	uUyqpHDfsF0NtpgnzHxnOfn9ugRBPJQ=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 15 Apr 2026 23:05:15 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 7207E64EC2;
	Wed, 15 Apr 2026 23:05:15 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63FK2cRI079731;
	Wed, 15 Apr 2026 23:02:38 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63FK2ctP079730;
	Wed, 15 Apr 2026 23:02:38 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH net 1/3] ipvs: fixes for the new ip_vs_status info
Date: Wed, 15 Apr 2026 23:02:14 +0300
Message-ID: <20260415200216.79699-2-ja@ssi.bg>
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


