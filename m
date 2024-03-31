Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C35ED144D27;
	Sun, 31 Mar 2024 14:07:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1711894049; cv=none; b=UWpeee2m0ilP46nn3QP1auIoN63Xcuf4oSWfZd7VB7EMfaL3ky9yb54Szn5rR/YIr09L215TZrGtvzLAQ5bBRrxS7h5unr/1qlzECyDzIc28AuzffmLkqdlMp+uCoDpf+ievySc9KRKlHdmHA9FOGn4wmyZMNnxVVOnpoOMVwCQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1711894049; c=relaxed/simple;
	bh=P7tpdAiJPxU0qvYDVwMSW+PboO0BGFez3fxoLpoPIh4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=bPqcMzwD+dQPWnHXuP3BB92AgpMLoTzeLiXaVY40skWwB8GKUWkqpclZgBw8ed79BDoAz8vAt+yn6kR6qNj8aWpyeqtnlMJmqXpQBvsP1F15ETjJy6Z9j2UA1Q+ZrUc/FXaFPn3HqD+lx1X3IByGlhLmEULghLmnVBKYoFjvpX8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=aOJQo5d5; arc=none smtp.client-ip=193.238.174.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="aOJQo5d5"
Received: from mg.ssi.bg (localhost [127.0.0.1])
	by mg.ssi.bg (Proxmox) with ESMTP id 337FA31DC6;
	Sun, 31 Mar 2024 17:07:26 +0300 (EEST)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.ssi.bg (Proxmox) with ESMTPS id EAADC31D58;
	Sun, 31 Mar 2024 17:07:24 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id 84652900DEF;
	Sun, 31 Mar 2024 17:07:04 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1711894024; bh=P7tpdAiJPxU0qvYDVwMSW+PboO0BGFez3fxoLpoPIh4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=aOJQo5d5NWeH6frvQ7Y3XLxDNzd+qDRBg9aZaSGM9L/SmJJ4idsRcQt7K0+ymPugj
	 0gAEBKQVBhLbix1zFnyzAQ7rmcIHp8YvTDl6a4NV8mz/HtdAgGnv5LD80nm1T3CfDT
	 CV4CuQNooMG4jtK5q4dt8WIQQ+xV/yV3isVq2Byc=
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.17.1/8.17.1) with ESMTP id 42VE46nV077736;
	Sun, 31 Mar 2024 17:04:06 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.17.1/8.17.1/Submit) id 42VE46po077735;
	Sun, 31 Mar 2024 17:04:06 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: [PATCHv3 net-next 11/14] ipvs: no_cport and dropentry counters can be per-net
Date: Sun, 31 Mar 2024 17:03:58 +0300
Message-ID: <20240331140401.77657-12-ja@ssi.bg>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20240331140401.77657-1-ja@ssi.bg>
References: <20240331140401.77657-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

With using per-net conn_tab these counters do not need to be
global anymore.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |  2 ++
 net/netfilter/ipvs/ip_vs_conn.c | 62 ++++++++++++++++++++-------------
 2 files changed, 39 insertions(+), 25 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 074f45f89c80..e091c84c8a11 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1158,6 +1158,7 @@ struct netns_ipvs {
 #endif
 	/* ip_vs_conn */
 	atomic_t		conn_count;      /* connection counter */
+	atomic_t		no_cport_conns[IP_VS_AF_MAX];
 	struct delayed_work	conn_resize_work;/* resize conn_tab */
 
 	/* ip_vs_ctl */
@@ -1188,6 +1189,7 @@ struct netns_ipvs {
 	int			drop_counter;
 	int			old_secure_tcp;
 	atomic_t		dropentry;
+	s8			dropentry_counters[8];
 	/* locks in ctl.c */
 	spinlock_t		dropentry_lock;  /* drop entry handling */
 	spinlock_t		droppacket_lock; /* drop packet handling */
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 68d25dbb38a5..ad45fb4e1cc2 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -54,9 +54,6 @@ int ip_vs_conn_tab_size __read_mostly;
 /*  SLAB cache for IPVS connections */
 static struct kmem_cache *ip_vs_conn_cachep __read_mostly;
 
-/*  counter for no client port connections */
-static atomic_t ip_vs_conn_no_cport_cnt = ATOMIC_INIT(0);
-
 /* We need an addrstrlen that works with or without v6 */
 #ifdef CONFIG_IP_VS_IPV6
 #define IP_VS_ADDRSTRLEN INET6_ADDRSTRLEN
@@ -319,10 +316,16 @@ struct ip_vs_conn *ip_vs_conn_in_get(const struct ip_vs_conn_param *p)
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
@@ -535,6 +538,7 @@ void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport)
 {
 	struct hlist_bl_head *head, *head2, *head_new;
 	struct netns_ipvs *ipvs = cp->ipvs;
+	int af_id = ip_vs_af_index(cp->af);
 	u32 hash_r = 0, hash_key_r = 0;
 	struct ip_vs_rht *t, *tp, *t2;
 	u32 hash_key, hash_key_new;
@@ -613,7 +617,7 @@ void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport)
 			hlist_bl_del_rcu(&cp->c_list);
 			hlist_bl_add_head_rcu(&cp->c_list, head_new);
 		}
-		atomic_dec(&ip_vs_conn_no_cport_cnt);
+		atomic_dec(&ipvs->no_cport_conns[af_id]);
 		cp->flags &= ~IP_VS_CONN_F_NO_CPORT;
 		cp->cport = cport;
 	}
@@ -1169,8 +1173,11 @@ static void ip_vs_conn_expire(struct timer_list *t)
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
@@ -1277,8 +1284,11 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p, int dest_af,
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
@@ -1554,6 +1564,7 @@ static const struct seq_operations ip_vs_conn_sync_seq_ops = {
 };
 #endif
 
+#ifdef CONFIG_SYSCTL
 
 /* Randomly drop connection entries before running out of memory
  * Can be used for DATA and CTL conns. For TPL conns there are exceptions:
@@ -1563,12 +1574,7 @@ static const struct seq_operations ip_vs_conn_sync_seq_ops = {
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
@@ -1577,15 +1583,17 @@ static inline int todrop_entry(struct ip_vs_conn *cp)
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
 
@@ -1679,7 +1687,7 @@ void ip_vs_random_dropentry(struct netns_ipvs *ipvs)
 out:
 	rcu_read_unlock();
 }
-
+#endif
 
 /* Flush all the connection entries in the conn_tab */
 static void ip_vs_conn_flush(struct netns_ipvs *ipvs)
@@ -1804,7 +1812,11 @@ void ip_vs_expire_nodest_conn_flush(struct netns_ipvs *ipvs)
  */
 int __net_init ip_vs_conn_net_init(struct netns_ipvs *ipvs)
 {
+	int idx;
+
 	atomic_set(&ipvs->conn_count, 0);
+	for (idx = 0; idx < IP_VS_AF_MAX; idx++)
+		atomic_set(&ipvs->no_cport_conns[idx], 0);
 	INIT_DELAYED_WORK(&ipvs->conn_resize_work, conn_resize_work_handler);
 	RCU_INIT_POINTER(ipvs->conn_tab, NULL);
 	atomic_set(&ipvs->conn_tab_changes, 0);
-- 
2.44.0


