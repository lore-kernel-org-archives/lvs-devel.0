Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 861582765D7;
	Sat,  4 Apr 2026 15:37:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775317058; cv=none; b=OqxmT1HNaZYF9RI6XT7X3uycKVC5nKHCWIr6WuVb12klMrVlaxxL8a50Te6Pi5RnpDuHOOVnKJzi0a8biyKa7LsxqrCdxzAErG/KJ0kF/t/1Yy4b1kJwZ8XLO8PGlUJgL5tOpOyRa/XdIyhctXIh62ZoQJNLzkaN50B7Wk3lUdU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775317058; c=relaxed/simple;
	bh=y3Ru4CWtXCvrUn02IqehNzekb527kTsA+m3qWY19bV0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=gRwoZTt+64AXq6QT7D/0EfuC3a3pMhrfPg4o4mlNI7Y2ASSGuLfwGwwFa6iCdc72KJ6ho8331StgyEEoIibWun+anQUFfIfjTtW43AGrXxrb/YNxCrMUHTRPr7ymYDQd5YwqQx2xkR8FwOOMZBRV7aR59Ow+SCG2joAvTBUhCQI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=szfrh2UC; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="szfrh2UC"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id E787A21C5F;
	Sat, 04 Apr 2026 18:37:21 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=JBOfbLh6Kd7sYujwAwhUlqY4NGBayISrUkseZw5brU8=; b=szfrh2UCFLm5
	pLZKUCurtAkqOk9ts+rsW9xAROF3FqjeSs7Tq8gsAiYx7dkFWPwJkA+7FvdJ32CY
	gX2r4jydWIkfVKRdrCZXLGeRmTc6X30PJuGuVxfSgflwwmoqTvWQUJm8vVFefoyj
	U15dhk4vwHYl5UO02IUcAVUFjHdKqQ/Rlm9+se42QuAwoKg79u74MLkef1F6dJkt
	luLnvFqTG3BRoapRgZeD60bgGde23LU7wN5XMVMw8tZ5rxXreEIbZu6+OWwO2RO8
	xaqKv36DIeDlUhp8zNkSEWZmT3IrJ4cconRRaxtlNqaX8jLSWEDA3iazfAQzlsGA
	+4Q2DVBYFc3cM8cquFky5PuvP/zIVGKSEBBkKlguoBbbGoPf+bFhsXbNvuohk3Qi
	zPZsmFrfJFGPNLTlYWZpT1BOkAdzRy7xlDX6Ys2nmAuFnaTIsbeVQ8zB7kLtWG2A
	5R6Rxxe7LU3L+Ei8c9enZXu9kaybl1FZnDSAYy2pPIIuEaDvZyvTVfP6vtcc4FUP
	xgEKFslGGwQ+T4w/AtPL9KweWHAJJqNOwbrBl6b6DVHgEnuoZQmH1hEfmNRWmmyF
	gxny5PqtvKiCEwAh1FLC5HZiudmfOCUfEckp5f1lLSP+TPcCN/lVYHxNAurOxc0G
	zMTepk37dlQmOQGDFc9mNYxY/n7dNO0=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 04 Apr 2026 18:37:20 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 997BA60F8A;
	Sat,  4 Apr 2026 18:37:20 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 634FZDGU030107;
	Sat, 4 Apr 2026 18:35:13 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 634FZDVO030106;
	Sat, 4 Apr 2026 18:35:13 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>
Subject: [PATCHv2 nf-next 2/3] ipvs: add ip_vs_status info
Date: Sat,  4 Apr 2026 18:34:38 +0300
Message-ID: <20260404153439.30077-3-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260404153439.30077-1-ja@ssi.bg>
References: <20260404153439.30077-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Add /proc/net/ip_vs_status to show current state of IPVS.

The motivation for this new /proc interface is to provide the output
for the users to help them decide when to tune the load factor for
hash tables, which is possible with the new sysctl knobs coming in
followup patch.

The output also includes information for the kthreads used for stats.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 145 +++++++++++++++++++++++++++++++++
 1 file changed, 145 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index d06d710dac83..b536799a725f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2925,6 +2925,144 @@ static int ip_vs_stats_percpu_show(struct seq_file *seq, void *v)
 
 	return 0;
 }
+
+static int ip_vs_status_show(struct seq_file *seq, void *v)
+{
+	struct net *net = seq_file_single_net(seq);
+	struct netns_ipvs *ipvs = net_ipvs(net);
+	unsigned int resched_score = 0;
+	struct ip_vs_conn_hnode *hn;
+	struct hlist_bl_head *head;
+	struct ip_vs_service *svc;
+	struct ip_vs_rht *t, *pt;
+	struct hlist_bl_node *e;
+	int old_gen, new_gen;
+	u32 counts[8];
+	u32 bucket;
+	int count;
+	u32 sum1;
+	u32 sum;
+	int i;
+
+	rcu_read_lock();
+
+	t = rcu_dereference(ipvs->conn_tab);
+
+	seq_printf(seq, "Conns:\t%d\n", atomic_read(&ipvs->conn_count));
+	seq_printf(seq, "Conn buckets:\t%d (%d bits, lfactor %d)\n",
+		   t ? t->size : 0, t ? t->bits : 0, t ? t->lfactor : 0);
+
+	if (!atomic_read(&ipvs->conn_count))
+		goto after_conns;
+	old_gen = atomic_read(&ipvs->conn_tab_changes);
+
+repeat_conn:
+	smp_rmb(); /* ipvs->conn_tab and conn_tab_changes */
+	memset(counts, 0, sizeof(counts));
+	ip_vs_rht_for_each_table_rcu(ipvs->conn_tab, t, pt) {
+		for (bucket = 0; bucket < t->size; bucket++) {
+			DECLARE_IP_VS_RHT_WALK_BUCKET_RCU();
+
+			count = 0;
+			resched_score++;
+			ip_vs_rht_walk_bucket_rcu(t, bucket, head) {
+				count = 0;
+				hlist_bl_for_each_entry_rcu(hn, e, head, node)
+					count++;
+			}
+			resched_score += count;
+			if (resched_score >= 100) {
+				resched_score = 0;
+				cond_resched_rcu();
+				new_gen = atomic_read(&ipvs->conn_tab_changes);
+				/* New table installed ? */
+				if (old_gen != new_gen) {
+					old_gen = new_gen;
+					goto repeat_conn;
+				}
+			}
+			counts[min(count, (int)ARRAY_SIZE(counts) - 1)]++;
+		}
+	}
+	for (sum = 0, i = 0; i < ARRAY_SIZE(counts); i++)
+		sum += counts[i];
+	sum1 = sum - counts[0];
+	seq_printf(seq, "Conn buckets empty:\t%u (%lu%%)\n",
+		   counts[0], (unsigned long)counts[0] * 100 / max(sum, 1U));
+	for (i = 1; i < ARRAY_SIZE(counts); i++) {
+		if (!counts[i])
+			continue;
+		seq_printf(seq, "Conn buckets len-%d:\t%u (%lu%%)\n",
+			   i, counts[i],
+			   (unsigned long)counts[i] * 100 / max(sum1, 1U));
+	}
+
+after_conns:
+	t = rcu_dereference(ipvs->svc_table);
+
+	count = ip_vs_get_num_services(ipvs);
+	seq_printf(seq, "Services:\t%d\n", count);
+	seq_printf(seq, "Service buckets:\t%d (%d bits, lfactor %d)\n",
+		   t ? t->size : 0, t ? t->bits : 0, t ? t->lfactor : 0);
+
+	if (!count)
+		goto after_svc;
+	old_gen = atomic_read(&ipvs->svc_table_changes);
+
+repeat_svc:
+	smp_rmb(); /* ipvs->svc_table and svc_table_changes */
+	memset(counts, 0, sizeof(counts));
+	ip_vs_rht_for_each_table_rcu(ipvs->svc_table, t, pt) {
+		for (bucket = 0; bucket < t->size; bucket++) {
+			DECLARE_IP_VS_RHT_WALK_BUCKET_RCU();
+
+			count = 0;
+			resched_score++;
+			ip_vs_rht_walk_bucket_rcu(t, bucket, head) {
+				count = 0;
+				hlist_bl_for_each_entry_rcu(svc, e, head,
+							    s_list)
+					count++;
+			}
+			resched_score += count;
+			if (resched_score >= 100) {
+				resched_score = 0;
+				cond_resched_rcu();
+				new_gen = atomic_read(&ipvs->svc_table_changes);
+				/* New table installed ? */
+				if (old_gen != new_gen) {
+					old_gen = new_gen;
+					goto repeat_svc;
+				}
+			}
+			counts[min(count, (int)ARRAY_SIZE(counts) - 1)]++;
+		}
+	}
+	for (sum = 0, i = 0; i < ARRAY_SIZE(counts); i++)
+		sum += counts[i];
+	sum1 = sum - counts[0];
+	seq_printf(seq, "Service buckets empty:\t%u (%lu%%)\n",
+		   counts[0], (unsigned long)counts[0] * 100 / max(sum, 1U));
+	for (i = 1; i < ARRAY_SIZE(counts); i++) {
+		if (!counts[i])
+			continue;
+		seq_printf(seq, "Service buckets len-%d:\t%u (%lu%%)\n",
+			   i, counts[i],
+			   (unsigned long)counts[i] * 100 / max(sum1, 1U));
+	}
+
+after_svc:
+	seq_printf(seq, "Stats thread slots:\t%d (max %lu)\n",
+		   ipvs->est_kt_count, ipvs->est_max_threads);
+	seq_printf(seq, "Stats chain max len:\t%d\n", ipvs->est_chain_max);
+	seq_printf(seq, "Stats thread ests:\t%d\n",
+		   ipvs->est_chain_max * IPVS_EST_CHAIN_FACTOR *
+		   IPVS_EST_NTICKS);
+
+	rcu_read_unlock();
+	return 0;
+}
+
 #endif
 
 /*
@@ -4826,6 +4964,9 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 				    ipvs->net->proc_net,
 				    ip_vs_stats_percpu_show, NULL))
 		goto err_percpu;
+	if (!proc_create_net_single("ip_vs_status", 0, ipvs->net->proc_net,
+				    ip_vs_status_show, NULL))
+		goto err_status;
 #endif
 
 	ret = ip_vs_control_net_init_sysctl(ipvs);
@@ -4836,6 +4977,9 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 
 err:
 #ifdef CONFIG_PROC_FS
+	remove_proc_entry("ip_vs_status", ipvs->net->proc_net);
+
+err_status:
 	remove_proc_entry("ip_vs_stats_percpu", ipvs->net->proc_net);
 
 err_percpu:
@@ -4861,6 +5005,7 @@ void __net_exit ip_vs_control_net_cleanup(struct netns_ipvs *ipvs)
 	ip_vs_control_net_cleanup_sysctl(ipvs);
 	cancel_delayed_work_sync(&ipvs->est_reload_work);
 #ifdef CONFIG_PROC_FS
+	remove_proc_entry("ip_vs_status", ipvs->net->proc_net);
 	remove_proc_entry("ip_vs_stats_percpu", ipvs->net->proc_net);
 	remove_proc_entry("ip_vs_stats", ipvs->net->proc_net);
 	remove_proc_entry("ip_vs", ipvs->net->proc_net);
-- 
2.53.0


