Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 53B8523A562;
	Sat, 14 Feb 2026 15:18:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771082284; cv=none; b=etK5AR3F6bLqZ+M0ZouteNzeodNCQFFtE44JCrf9GTRX4TIzkqfYNMFPKzevW8qcguONO6mR0OFvzLHkYgnpG59HbM4/CYjTCuIeG1xsWg6Y8vLeVcuIs/aU5pvH4Tqi5CJCOnMefKcaLLqYnoJmn1VBXHPsQWPlD3NS6a/Jcn0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771082284; c=relaxed/simple;
	bh=SenVcpQz6rH5qWqU0EOVJPMJYixjW9+d3hrqGVQoEJA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=u6cIbe1UeRsnOcgSdwsBOCv1z8XuQien7mpEAZpiNch+0y/EB+VkOL7267q34zF1PaanksoFhKfY8AA85bcJU546oBUipFWS1pYof1ZAc5N8oiGCG8pjOx3ckwE1nuhI2zU3/dVG0q0wjd+/sYVGi59ATy7lCPVE5O9uTTPeyUk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=Oji2DOTc; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="Oji2DOTc"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 96E0421D61;
	Sat, 14 Feb 2026 17:17:48 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=q18sUM3m0kDIHv3aF+8/odre02oFOVdoFiWHcqq5eIU=; b=Oji2DOTc8L2N
	eEFtJ4EhG32ldcYPcFDYPk2xtROpfVZK3qAIwMUWnsLGssll/oSyMn3hb0EaD7gt
	3JILW1BJTUuCYfGGnuHL1jkxZhTH+1v70dld1+8ETUksEAW3cJuGJ18IQJbWDpQU
	WyzxRXkzMke3IZw01GLhoJbz4uuePPN31Ue19Dvps7qkue2+kFRjPoRjnb0Dn9sD
	K92gwAaKkkD5d6vzrBPFX60ZV6fhrmBak8uUAJAy4DWDMMbSb74oyltm+bo1wj0F
	RqhvSMcVmNzvGUQGg7Mg9hb1DQ+XSKSt+Zk4imlwhbdphxdNwNgizkR/0Yvex/Ak
	EZv8ZXPN0giBf+nHpgI/hORHFCce7Agl5vctE6UpjmFUuo7q/7W7pDnFNIVNqOT+
	lCtzDbeWN1oKQ000SpGMvzpQuYRyBCGISbCuiPbK2qgaiwuAGHs7zPDsMBiU1Dvh
	Z8IJCCCw8ue7g46RKk9iKT+YUo3xAD6gDOS6nauHRfNBa6DrnbchrnGik9eywwPi
	iQEO2HwixWNMfSOuQoIFCxsddT1nK2StQRb53hwWoeW/cawTZ8NVsuqo9uUgNGRS
	ZLDBBejQu03/TuaGs4tjkklRtnYd1xdO5pfUmtyHt2gpmvCf1oUc9fuwZBOghfwu
	hI4HtBfzrDMD+AgdazaDJ7J0M9n1CPE=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 14 Feb 2026 17:17:46 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 67EFD628AF;
	Sat, 14 Feb 2026 17:17:46 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 61EFCwUj019366;
	Sat, 14 Feb 2026 17:12:58 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 61EFCw61019365;
	Sat, 14 Feb 2026 17:12:58 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>
Subject: [PATCH nf-next 6/6] ipvs: no_cport and dropentry counters can be per-net
Date: Sat, 14 Feb 2026 17:12:30 +0200
Message-ID: <20260214151230.18970-7-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260214151230.18970-1-ja@ssi.bg>
References: <20260214151230.18970-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Change the no_cport counters to be per-net and address family.
This should reduce the extra conn lookups done during present
NO_CPORT connections.

By changing from global to per-net dropentry counters, one net
will not affect the drop rate of another net.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |  2 ++
 net/netfilter/ipvs/ip_vs_conn.c | 64 ++++++++++++++++++++-------------
 2 files changed, 41 insertions(+), 25 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index f2291be36409..ad8a16146ac5 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -948,6 +948,7 @@ struct netns_ipvs {
 #endif
 	/* ip_vs_conn */
 	atomic_t		conn_count;      /* connection counter */
+	atomic_t		no_cport_conns[IP_VS_AF_MAX];
 
 	/* ip_vs_ctl */
 	struct ip_vs_stats_rcu	*tot_stats;      /* Statistics & est. */
@@ -973,6 +974,7 @@ struct netns_ipvs {
 	int			drop_counter;
 	int			old_secure_tcp;
 	atomic_t		dropentry;
+	s8			dropentry_counters[8];
 	/* locks in ctl.c */
 	spinlock_t		dropentry_lock;  /* drop entry handling */
 	spinlock_t		droppacket_lock; /* drop packet handling */
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 50cc492c7553..66057db63d02 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -59,9 +59,6 @@ static struct hlist_head *ip_vs_conn_tab __read_mostly;
 /*  SLAB cache for IPVS connections */
 static struct kmem_cache *ip_vs_conn_cachep __read_mostly;
 
-/*  counter for no client port connections */
-static atomic_t ip_vs_conn_no_cport_cnt = ATOMIC_INIT(0);
-
 /* random value for IPVS connection hash */
 static unsigned int ip_vs_conn_rnd __read_mostly;
 
@@ -294,10 +291,16 @@ struct ip_vs_conn *ip_vs_conn_in_get(const struct ip_vs_conn_param *p)
 	struct ip_vs_conn *cp;
 
 	cp = __ip_vs_conn_in_get(p);
-	if (!cp && atomic_read(&ip_vs_conn_no_cport_cnt)) {
-		struct ip_vs_conn_param cport_zero_p = *p;
-		cport_zero_p.cport = 0;
-		cp = __ip_vs_conn_in_get(&cport_zero_p);
+	if (!cp) {
+		struct netns_ipvs *ipvs = p->ipvs;
+		int af_id = ip_vs_af_index(p->af);
+
+		if (atomic_read(&ipvs->no_cport_conns[af_id])) {
+			struct ip_vs_conn_param cport_zero_p = *p;
+
+			cport_zero_p.cport = 0;
+			cp = __ip_vs_conn_in_get(&cport_zero_p);
+		}
 	}
 
 	IP_VS_DBG_BUF(9, "lookup/in %s %s:%d->%s:%d %s\n",
@@ -490,9 +493,12 @@ void ip_vs_conn_put(struct ip_vs_conn *cp)
 void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport)
 {
 	if (ip_vs_conn_unhash(cp)) {
+		struct netns_ipvs *ipvs = cp->ipvs;
+		int af_id = ip_vs_af_index(cp->af);
+
 		spin_lock_bh(&cp->lock);
 		if (cp->flags & IP_VS_CONN_F_NO_CPORT) {
-			atomic_dec(&ip_vs_conn_no_cport_cnt);
+			atomic_dec(&ipvs->no_cport_conns[af_id]);
 			cp->flags &= ~IP_VS_CONN_F_NO_CPORT;
 			cp->cport = cport;
 		}
@@ -891,8 +897,11 @@ static void ip_vs_conn_expire(struct timer_list *t)
 		if (unlikely(cp->app != NULL))
 			ip_vs_unbind_app(cp);
 		ip_vs_unbind_dest(cp);
-		if (cp->flags & IP_VS_CONN_F_NO_CPORT)
-			atomic_dec(&ip_vs_conn_no_cport_cnt);
+		if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT)) {
+			int af_id = ip_vs_af_index(cp->af);
+
+			atomic_dec(&ipvs->no_cport_conns[af_id]);
+		}
 		if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
 			ip_vs_conn_rcu_free(&cp->rcu_head);
 		else
@@ -999,8 +1008,11 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p, int dest_af,
 	cp->out_seq.delta = 0;
 
 	atomic_inc(&ipvs->conn_count);
-	if (flags & IP_VS_CONN_F_NO_CPORT)
-		atomic_inc(&ip_vs_conn_no_cport_cnt);
+	if (unlikely(flags & IP_VS_CONN_F_NO_CPORT)) {
+		int af_id = ip_vs_af_index(cp->af);
+
+		atomic_inc(&ipvs->no_cport_conns[af_id]);
+	}
 
 	/* Bind the connection with a destination server */
 	cp->dest = NULL;
@@ -1257,6 +1269,7 @@ static const struct seq_operations ip_vs_conn_sync_seq_ops = {
 };
 #endif
 
+#ifdef CONFIG_SYSCTL
 
 /* Randomly drop connection entries before running out of memory
  * Can be used for DATA and CTL conns. For TPL conns there are exceptions:
@@ -1266,12 +1279,7 @@ static const struct seq_operations ip_vs_conn_sync_seq_ops = {
  */
 static inline int todrop_entry(struct ip_vs_conn *cp)
 {
-	/*
-	 * The drop rate array needs tuning for real environments.
-	 * Called from timer bh only => no locking
-	 */
-	static const signed char todrop_rate[9] = {0, 1, 2, 3, 4, 5, 6, 7, 8};
-	static signed char todrop_counter[9] = {0};
+	struct netns_ipvs *ipvs = cp->ipvs;
 	int i;
 
 	/* if the conn entry hasn't lasted for 60 seconds, don't drop it.
@@ -1280,15 +1288,17 @@ static inline int todrop_entry(struct ip_vs_conn *cp)
 	if (time_before(cp->timeout + jiffies, cp->timer.expires + 60*HZ))
 		return 0;
 
-	/* Don't drop the entry if its number of incoming packets is not
-	   located in [0, 8] */
+	/* Drop only conns with number of incoming packets in [1..8] range */
 	i = atomic_read(&cp->in_pkts);
-	if (i > 8 || i < 0) return 0;
+	if (i > 8 || i < 1)
+		return 0;
 
-	if (!todrop_rate[i]) return 0;
-	if (--todrop_counter[i] > 0) return 0;
+	i--;
+	if (--ipvs->dropentry_counters[i] > 0)
+		return 0;
 
-	todrop_counter[i] = todrop_rate[i];
+	/* Prefer to drop conns with less number of incoming packets */
+	ipvs->dropentry_counters[i] = i + 1;
 	return 1;
 }
 
@@ -1368,7 +1378,7 @@ void ip_vs_random_dropentry(struct netns_ipvs *ipvs)
 	}
 	rcu_read_unlock();
 }
-
+#endif
 
 /*
  *      Flush all the connection entries in the ip_vs_conn_tab
@@ -1450,7 +1460,11 @@ void ip_vs_expire_nodest_conn_flush(struct netns_ipvs *ipvs)
  */
 int __net_init ip_vs_conn_net_init(struct netns_ipvs *ipvs)
 {
+	int idx;
+
 	atomic_set(&ipvs->conn_count, 0);
+	for (idx = 0; idx < IP_VS_AF_MAX; idx++)
+		atomic_set(&ipvs->no_cport_conns[idx], 0);
 
 #ifdef CONFIG_PROC_FS
 	if (!proc_create_net("ip_vs_conn", 0, ipvs->net->proc_net,
-- 
2.53.0


