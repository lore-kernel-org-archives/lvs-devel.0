Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A085450297;
	Tue, 28 May 2024 08:06:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1716883610; cv=none; b=lzXs3tSy7sFddt3Vx8vxdGFxQ4Xl4eGBP0NOR085mV3qK4o7PETYRNEMrq29OMkT4XwjoXFfL3eGsPKn0o6GtZeX52rYC+kS1ZsvnI9WcpvE7Rw3uEQBudRTZTOGENVhCBUcDnBUADqNwdeX4tUkl/0HEmiXwiFdrt509Y7SR9s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1716883610; c=relaxed/simple;
	bh=XC7O/aZ4sAiFYXgG9FXKm6vW6pQXTcFHr3xz1IFdQ9Q=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=JGz++4SxZkuvvzm+tBmfmiF/bF22GxQo80edS8vySz/XUSrVAKp9cWDMoypTibRkWgKGYRWQ9s2ljn53xXjwHleL8Ru3CBByuUbTwS+WVUDCxiKtfhRXYDjfhsHkF3EHN4ZuDqeGAO1jRaV6egoiTqUEe+1ti+2cYbIvxY6Z+F4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=uEFn6rer; arc=none smtp.client-ip=193.238.174.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="uEFn6rer"
Received: from mg.ssi.bg (localhost [127.0.0.1])
	by mg.ssi.bg (Proxmox) with ESMTP id 1445F87B0;
	Tue, 28 May 2024 11:06:47 +0300 (EEST)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.ssi.bg (Proxmox) with ESMTPS;
	Tue, 28 May 2024 11:06:45 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id D6909900899;
	Tue, 28 May 2024 11:06:33 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1716883593; bh=XC7O/aZ4sAiFYXgG9FXKm6vW6pQXTcFHr3xz1IFdQ9Q=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=uEFn6rerQChlsdC5geb4ek1uaTcZsRadu7zehgU4TiUiHxOc1ud42SZahIc0zhJTy
	 mPO7qfNZjd1X1FmdCG73bMySYtImAzAEKMV7WR71QL+xr/erpzI0kDk156k7ZHLnuV
	 1YYV6vxg8yk+RpRNgVDXYi6ztHMwrFFCBxgdBb1Y=
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 44S82thp010233;
	Tue, 28 May 2024 11:02:55 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 44S82tRf010232;
	Tue, 28 May 2024 11:02:55 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: [PATCHv4 net-next 13/14] ipvs: add ip_vs_status info
Date: Tue, 28 May 2024 11:02:33 +0300
Message-ID: <20240528080234.10148-14-ja@ssi.bg>
X-Mailer: git-send-email 2.45.1
In-Reply-To: <20240528080234.10148-1-ja@ssi.bg>
References: <20240528080234.10148-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Add /proc/net/ip_vs_status to show current state of IPVS.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 145 +++++++++++++++++++++++++++++++++
 1 file changed, 145 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 187a5e238231..6b84b6f17a32 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2913,6 +2913,144 @@ static int ip_vs_stats_percpu_show(struct seq_file *seq, void *v)
 
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
@@ -4836,6 +4974,9 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 				    ipvs->net->proc_net,
 				    ip_vs_stats_percpu_show, NULL))
 		goto err_percpu;
+	if (!proc_create_net_single("ip_vs_status", 0, ipvs->net->proc_net,
+				    ip_vs_status_show, NULL))
+		goto err_status;
 #endif
 
 	ret = ip_vs_control_net_init_sysctl(ipvs);
@@ -4846,6 +4987,9 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 
 err:
 #ifdef CONFIG_PROC_FS
+	remove_proc_entry("ip_vs_status", ipvs->net->proc_net);
+
+err_status:
 	remove_proc_entry("ip_vs_stats_percpu", ipvs->net->proc_net);
 
 err_percpu:
@@ -4871,6 +5015,7 @@ void __net_exit ip_vs_control_net_cleanup(struct netns_ipvs *ipvs)
 	ip_vs_control_net_cleanup_sysctl(ipvs);
 	cancel_delayed_work_sync(&ipvs->est_reload_work);
 #ifdef CONFIG_PROC_FS
+	remove_proc_entry("ip_vs_status", ipvs->net->proc_net);
 	remove_proc_entry("ip_vs_stats_percpu", ipvs->net->proc_net);
 	remove_proc_entry("ip_vs_stats", ipvs->net->proc_net);
 	remove_proc_entry("ip_vs", ipvs->net->proc_net);
-- 
2.44.0


