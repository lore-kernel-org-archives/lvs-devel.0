Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 57EB14C6EE7;
	Wed,  6 May 2026 18:44:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778093095; cv=none; b=BDr33fmAfKGccXLYCteNRbL/G6UwyfF25uEAFFJGwn2Xwvighmg3u8PJ8oOMBNtlN380x6Dq44wsd1OOBwLfRAdY3FxD6bMdjwLasc6+WOujNQkEKkt1wzoxIt/9Jp02lbra7OADvQZj+M7qcuY0VG3sP4rG8OPA96btjENXREU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778093095; c=relaxed/simple;
	bh=8d+IIizGgCKNjjJayObceF+biQlIt26ts4IceoouJyc=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=b7CFdMynaXLnUGTDAOzfzOKgiogckEntFCpx3RUqlShZDVc2vpCjYHwDlCCZFp9hXxyd2jlKgBe0/fnr14OJzCXgZl7uA798Ulw4hXXBDe2LP7yI+8RGsdOCVbu1QJrUtHU0rWR6sz3Qp22hCcwTrObwjwRrKH6kRkcgJVvGUFE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=OdIWi7LQ; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="OdIWi7LQ"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 7A6ED2294C;
	Wed, 06 May 2026 21:44:47 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=5VGFny4e
	7hB1dp0UMCXIYzkxrH0bdXN+++aQEQYQoQs=; b=OdIWi7LQA9FQUNdCt0PkI7lg
	1sZUZMhTzK449Z38G+7JkHMyBkX9PWflMsODqgPTXZS+CnUnUGghaa1vIIG5HBTO
	+zQQttHukG/lr5mf75JQDtzGH8c3emVtvHkXz8h8eAyGHNhLTTVWWd8HsA0EEX5A
	SQy1KowMvcjWzF0N+LcUlbzeA0Nlm6nzywbvgGnRVchjzPDgpkVBfOfPS7VZhlp0
	EbhfaLqgXRpBLlpSpkb7cpi3wsXV4cecsCQQCUldy/GF9Y/AGlZVJCk8CR+oDJc8
	PWux988dCT63HKQRt000inZ73cBNIoKV+MUnkbVWElrZvY2uGqrW2kY81hqoap76
	B9hbhM0UzF5yina7sb4cxuHxg/r5kPix0b+00HAlvqU7wfUsMY0PxDBGL/E+HBN9
	FqpbfOnEgEJy/Yk7Beaftbfk2ktq1owqUv9VyXyDo+w/vriwQCvTTaWk7VT/qLxg
	MGRTue17k34+rbeJ60ioTr6h5QaKBkqdA0tgS8FyWlYeEET9Pjsy1YijQ5TS4K3n
	V0cYYSi3yzN8AXLQ8TUmWZ8vV9I6trpBnw8kYaSVtpKQ+ctR3mY2wn+KkVlTpNoM
	cMmaiN4u0fSsQiZeem+UhjHxF/hEhcoXGKjoQ7MP+R0nc69sX4mxIKLFpAKD50Tk
	GM+pWFCZZ8mxuafQXbE=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 06 May 2026 21:44:47 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id CD423608E8;
	Wed,  6 May 2026 21:44:46 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 646Iii1v075898;
	Wed, 6 May 2026 21:44:44 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 646IigQU075896;
	Wed, 6 May 2026 21:44:42 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf] ipvs: avoid possible loop in ip_vs_dst_event on resizing
Date: Wed,  6 May 2026 21:44:21 +0300
Message-ID: <20260506184421.75877-1-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Sashiko points out that unprivileged user can frequently
call ip_vs_flush() or ip_vs_del_service() to trigger
svc_table_changes updates that can lead to infinite loop
in ip_vs_dst_event(). This can also happen if the user
triggers frequent table resizing without deleting all
services.

One way to solve it is to hold svc_resize_work in
ip_vs_dst_event() but this can block the dev notifier
during the whole resizing process.

Instead, use new rw_semaphore svc_replace_sem to protect
the svc_table replacement which is a short code section.
Then hold svc_replace_sem in ip_vs_dst_event() to serialize
with replacing the svc_table. By this way changes in
svc_table_changes can happen only when all services are
removed and all dev references dropped which allows us
to exit the loop.

Link: https://sashiko.dev/#/patchset/20260505001648.360569-1-pablo%40netfilter.org
Fixes: 840aac3d900d ("ipvs: use resizable hash table for services")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h            |  3 +-
 net/netfilter/ipvs/ip_vs_ctl.c | 52 ++++++++++++++++++++++++----------
 2 files changed, 39 insertions(+), 16 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 02762ce73a0c..a02e569813d2 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1186,8 +1186,9 @@ struct netns_ipvs {
 	struct timer_list	dest_trash_timer; /* expiration timer */
 	struct mutex		service_mutex;    /* service reconfig */
 	struct rw_semaphore	svc_resize_sem;   /* svc_table resizing */
+	struct rw_semaphore	svc_replace_sem;  /* svc_table replace */
 	struct delayed_work	svc_resize_work;  /* resize svc_table */
-	atomic_t		svc_table_changes;/* ++ on new table */
+	atomic_t		svc_table_changes;/* ++ on table changes */
 	/* Service counters */
 	atomic_t		num_services[IP_VS_AF_MAX];   /* Services */
 	atomic_t		fwm_services[IP_VS_AF_MAX];   /* Services */
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c7c7f6a7a9f6..0c1f409f41ba 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -327,13 +327,17 @@ ip_vs_use_count_dec(void)
 /* Service hashing:
  * Operation			Locking order
  * ---------------------------------------------------------------------------
- * add table			service_mutex, svc_resize_sem(W)
+ * add table			service_mutex
+ * replace table		service_mutex, svc_resize_sem(W),
+ *				svc_replace_sem(W)
  * del table			service_mutex
  * move between tables		svc_resize_sem(W), seqcount_t(W), bit lock
  * add/del service		service_mutex, bit lock
  * find service			RCU, seqcount_t(R)
  * walk services(blocking)	service_mutex, svc_resize_sem(R)
  * walk services(non-blocking)	RCU, seqcount_t(R)
+ * walk services(non-blocking)	svc_resize_sem(R), RCU, seqcount_t(R)
+ * walk services(non-blocking)	svc_replace_sem(R), RCU, seqcount_t(R)
  *
  * - new tables are linked/unlinked under service_mutex and svc_resize_sem
  * - new table is linked on resizing and all operations can run in parallel
@@ -346,9 +350,14 @@ ip_vs_use_count_dec(void)
  * services are moved to new table
  * - move operations may disturb readers: find operation will not miss entries
  * but walkers may see same entry twice if they are forced to retry chains
+ * or to walk the newly attached second table
  * - walkers using cond_resched_rcu() on !PREEMPT_RCU may need to hold
  * service_mutex to disallow new tables to be installed or to check
  * svc_table_changes and repeat the RCU read section if new table is installed
+ * - walkers may serialize with the whole resizing process (svc_resize_sem)
+ * to prevent seeing same service twice or just with the svc_table
+ * replace (svc_replace_sem) when we can see entries twice but we
+ * prefer to run concurrently with the rehashing.
  */
 
 /*
@@ -764,8 +773,12 @@ static void svc_resize_work_handler(struct work_struct *work)
 			goto same_bucket;
 	}
 
-	/* Tables can be switched only under service_mutex */
-	while (!mutex_trylock(&ipvs->service_mutex)) {
+	/* Tables can be switched only under service_mutex, svc_replace_sem */
+	for (;;) {
+		down_write(&ipvs->svc_replace_sem);
+		if (mutex_trylock(&ipvs->service_mutex))
+			break;
+		up_write(&ipvs->svc_replace_sem);
 		cond_resched();
 		if (!READ_ONCE(ipvs->enable) ||
 		    test_bit(IP_VS_WORK_SVC_NORESIZE, &ipvs->work_flags))
@@ -773,7 +786,7 @@ static void svc_resize_work_handler(struct work_struct *work)
 	}
 	if (!READ_ONCE(ipvs->enable) ||
 	    test_bit(IP_VS_WORK_SVC_NORESIZE, &ipvs->work_flags))
-		goto unlock_m;
+		goto unlock_repl;
 
 	rcu_assign_pointer(ipvs->svc_table, t_new);
 	/* Inform readers that new table is installed */
@@ -781,6 +794,9 @@ static void svc_resize_work_handler(struct work_struct *work)
 	atomic_inc(&ipvs->svc_table_changes);
 	t_free = t;
 
+unlock_repl:
+	up_write(&ipvs->svc_replace_sem);
+
 unlock_m:
 	mutex_unlock(&ipvs->service_mutex);
 
@@ -2184,17 +2200,21 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 	struct ip_vs_service *svc;
 	struct hlist_bl_node *e;
 	struct ip_vs_dest *dest;
-	int old_gen, new_gen;
+	int old_gen;
 
 	if (event != NETDEV_DOWN || !ipvs)
 		return NOTIFY_DONE;
 	IP_VS_DBG(3, "%s() dev=%s\n", __func__, dev->name);
 
+	/* Allow concurrent rehashing on resize but to avoid loop
+	 * serialize with installing the new table.
+	 */
+	down_read(&ipvs->svc_replace_sem);
+
 	old_gen = atomic_read(&ipvs->svc_table_changes);
 
 	rcu_read_lock();
 
-repeat:
 	smp_rmb(); /* ipvs->svc_table and svc_table_changes */
 	ip_vs_rht_walk_buckets_rcu(ipvs->svc_table, head) {
 		hlist_bl_for_each_entry_rcu(svc, e, head, s_list) {
@@ -2207,17 +2227,17 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 		}
 		resched_score++;
 		if (resched_score >= 100) {
-			resched_score = 0;
 			cond_resched_rcu();
-			new_gen = atomic_read(&ipvs->svc_table_changes);
-			/* New table installed ? */
-			if (old_gen != new_gen) {
-				old_gen = new_gen;
-				goto repeat;
-			}
+			/* Flushed? So no more dev refs */
+			if (atomic_read(&ipvs->svc_table_changes) != old_gen)
+				goto done;
+			resched_score = 0;
 		}
 	}
+
+done:
 	rcu_read_unlock();
+	up_read(&ipvs->svc_replace_sem);
 
 	return NOTIFY_DONE;
 }
@@ -3503,7 +3523,7 @@ __ip_vs_get_service_entries(struct netns_ipvs *ipvs,
 	int ret = 0;
 
 	lockdep_assert_held(&ipvs->svc_resize_sem);
-	/* All service modifications are disabled, go ahead */
+	/* All svc_table modifications are disabled, go ahead */
 	ip_vs_rht_walk_buckets(ipvs->svc_table, head) {
 		hlist_bl_for_each_entry(svc, e, head, s_list) {
 			/* Only expose IPv4 entries to old interface */
@@ -3687,7 +3707,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 			pr_err("length: %u != %zu\n", *len, size);
 			return -EINVAL;
 		}
-		/* Protect against table resizer moving the entries.
+		/* Prevent modifications to the list with services.
 		 * Try reverse locking, so that we do not hold the mutex
 		 * while waiting for semaphore.
 		 */
@@ -4029,6 +4049,7 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 	int start = cb->args[0];
 	int idx = 0;
 
+	/* Make sure we do not see same service twice during resize */
 	down_read(&ipvs->svc_resize_sem);
 	rcu_read_lock();
 	ip_vs_rht_walk_buckets_safe_rcu(ipvs->svc_table, head) {
@@ -5072,6 +5093,7 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 	/* Initialize service_mutex, svc_table per netns */
 	__mutex_init(&ipvs->service_mutex, "ipvs->service_mutex", &__ipvs_service_key);
 	init_rwsem(&ipvs->svc_resize_sem);
+	init_rwsem(&ipvs->svc_replace_sem);
 	INIT_DELAYED_WORK(&ipvs->svc_resize_work, svc_resize_work_handler);
 	atomic_set(&ipvs->svc_table_changes, 0);
 	RCU_INIT_POINTER(ipvs->svc_table, NULL);
-- 
2.53.0


