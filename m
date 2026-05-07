Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE4122ECEB9;
	Thu,  7 May 2026 19:24:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778181860; cv=none; b=WDv0o/XM0kkptiAsvzJJdFdBItEpl1uDx9oB8xSDijwGKBxCcJVUsjUQgFtk8xt5Fh1GI70QMfD2ajsOrDpklki60t21iG19FG/CXBUt1YYfnGdExaXzv56NCYKgK4bm2F5sW1qjiJZm0Y1NAeNN21GRGwRvV3kj3gahmPptDOE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778181860; c=relaxed/simple;
	bh=pSXCJvTU/m7Oko+eP0cS+Vh9Qy6xlpwFkjrZthG05VI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=GR0waT9R103GS1r6Lzy61tjSPVzXJaiNmLBQDOAMSvEdgewBdppqVciVqa2jZeT7Mcg2Ss02PxipYTx62/CKsXriz77Ub2fBC4C87cqCiHGuPW4cF7nvk9tvvp1jrDdjtyVv76/b2j51nJUaclgoYjEdEhc9x778phlnqup5QT8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=3EarRq9z; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="3EarRq9z"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 122FE2294C;
	Thu, 07 May 2026 22:24:06 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=yF0ppnsN
	muVBvRu7eJbKZHQJKM0pMWtLWsZvJZV9AFY=; b=3EarRq9zMPClMjjz4APVvEv0
	k6gImfqKDk4Bnbi9MJHnw9JQCwE6Ra07rCeCtihg3cIiLU7v7PPxAQFo//BadXd1
	gD+iBHp2q7XCYbv9db+CeAi91NBKLYszKUwPWWTR4bShvIsoc2vpW59ce94rTsog
	JI1IgesG3+FzA2OWpus8K35i/Upu7nH8z5KsW1Hs8rIN28WWaZ981dUaQNhuYw+G
	FalAH4gjFK8OYzat51cHJLxaQxOG5SbrZtXma9dXovvNULbTCZETvd8KVLu/PRhF
	c5LbDn3Bp7bOnDLEaO2rvV3UtYGobskXQvozIdm4KJgtCeqhk/rcvLhRVDEvRS+X
	MnNyAlacQ6RIuSQPnz9YA5Z57b+uLn+uxK0KEamjKCCNYCTqb1WEYd5gWKk/UUpj
	6i37g/lmqH54QVd1yOSOcpbKIck5Z6b28M2t7ijOcoGnElSfOUAJQBHzn9BDZ3M8
	zetTyuCKFcg+9PchNskeiSAW3Y5kiq6bs4gF+1ue6rQoMCIDuXulHqFnpYT+/c7W
	VsYhvZERaW0epk6j2Td570tqzE87EvbIL/xYYVX7wL6/mV5nzByqQdP6rRIZQmPi
	RAMaxzsE1yIEg3Bd1tvGoy93/gPHk+8O4Pvvax13Sf8sMJee9omsZ7wd/IOmTQC5
	q8238uyFl+KdWd2Ck4I=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 07 May 2026 22:24:05 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 32AF861C9C;
	Thu,  7 May 2026 22:24:05 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 647JNvRD079995;
	Thu, 7 May 2026 22:23:57 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 647JNtYA079993;
	Thu, 7 May 2026 22:23:55 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH v2 nf] ipvs: avoid possible loop in ip_vs_dst_event on resizing
Date: Thu,  7 May 2026 22:23:36 +0300
Message-ID: <20260507192336.79978-1-ja@ssi.bg>
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
services. We should also consider the possible effects
if the user triggers many NETDEV_DOWN events.

One way to solve it is to hold svc_resize_sem in
ip_vs_dst_event() but this can block the dev notifier
during the whole resizing process.

Instead, use new rw_semaphore svc_replace_sem to protect just
the svc_table replacement which is a short code section.
Then hold svc_replace_sem in ip_vs_dst_event() to serialize
with replacing the svc_table. As result, loop is avoided
as there is no need to repeat the table walking from the
start. By this way changes in svc_table_changes can happen
only when all services are removed and all dev references
dropped which allows us to abort the table walking.

As IP_VS_WORK_SVC_NORESIZE is the flag used to stop the
svc_resize_work under service_mutex, we should check only
this flag often but not while under service_mutex.

Link: https://sashiko.dev/#/patchset/20260505001648.360569-1-pablo%40netfilter.org
Fixes: 840aac3d900d ("ipvs: use resizable hash table for services")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 v2:
 * Do not check IP_VS_WORK_SVC_NORESIZE under service_mutex

 include/net/ip_vs.h            |  3 +-
 net/netfilter/ipvs/ip_vs_ctl.c | 70 +++++++++++++++++++++-------------
 2 files changed, 46 insertions(+), 27 deletions(-)

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
index c7c7f6a7a9f6..e0b19cfd2722 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -327,18 +327,22 @@ ip_vs_use_count_dec(void)
 /* Service hashing:
  * Operation			Locking order
  * ---------------------------------------------------------------------------
- * add table			service_mutex, svc_resize_sem(W)
- * del table			service_mutex
- * move between tables		svc_resize_sem(W), seqcount_t(W), bit lock
+ * add table			service_mutex
+ * replace table		service_mutex, svc_resize_sem(W),
+ *				svc_replace_sem(W)
+ * del table			service_mutex after stopped work
+ * move between tables (rehash)	svc_resize_sem(W), seqcount_t(W), bit lock
  * add/del service		service_mutex, bit lock
  * find service			RCU, seqcount_t(R)
  * walk services(blocking)	service_mutex, svc_resize_sem(R)
  * walk services(non-blocking)	RCU, seqcount_t(R)
+ * walk services(non-blocking)	svc_resize_sem(R), RCU, seqcount_t(R)
+ * walk services(non-blocking)	svc_replace_sem(R), RCU, seqcount_t(R)
  *
  * - new tables are linked/unlinked under service_mutex and svc_resize_sem
  * - new table is linked on resizing and all operations can run in parallel
  * in 2 tables until the new table is registered as current one
- * - two contexts can modify buckets: config and table resize, both in
+ * - two contexts can modify buckets: config and table resize (work), both in
  * process context
  * - only table resizer can move entries, so we do not protect t->seqc[]
  * items with t->lock[]
@@ -346,9 +350,13 @@ ip_vs_use_count_dec(void)
  * services are moved to new table
  * - move operations may disturb readers: find operation will not miss entries
  * but walkers may see same entry twice if they are forced to retry chains
- * - walkers using cond_resched_rcu() on !PREEMPT_RCU may need to hold
- * service_mutex to disallow new tables to be installed or to check
+ * or to walk the newly attached second table
+ * - walkers using cond_resched_rcu() on !PREEMPT_RCU may need to check
  * svc_table_changes and repeat the RCU read section if new table is installed
+ * - walkers may serialize with the whole resizing process (svc_resize_sem)
+ * to prevent seeing same service twice or just with the svc_table
+ * replace (svc_replace_sem) when we can see entries twice but we
+ * prefer to run concurrently with the rehashing.
  */
 
 /*
@@ -662,12 +670,12 @@ static void svc_resize_work_handler(struct work_struct *work)
 
 	if (!down_write_trylock(&ipvs->svc_resize_sem))
 		goto out;
+	/* The work is cancelled under service_mutex, so use mutex_trylock */
 	if (!mutex_trylock(&ipvs->service_mutex))
 		goto unlock_sem;
 	more_work = false;
 	clear_bit(IP_VS_WORK_SVC_RESIZE, &ipvs->work_flags);
-	if (!READ_ONCE(ipvs->enable) ||
-	    test_bit(IP_VS_WORK_SVC_NORESIZE, &ipvs->work_flags))
+	if (!READ_ONCE(ipvs->enable))
 		goto unlock_m;
 	t = rcu_dereference_protected(ipvs->svc_table, 1);
 	/* Do nothing if table is removed */
@@ -698,8 +706,8 @@ static void svc_resize_work_handler(struct work_struct *work)
 	ip_vs_rht_for_each_bucket(t, bucket, head) {
 same_bucket:
 		if (++limit >= 16) {
-			if (!READ_ONCE(ipvs->enable) ||
-			    test_bit(IP_VS_WORK_SVC_NORESIZE,
+			/* Not under service_mutex, check if work is stopped */
+			if (test_bit(IP_VS_WORK_SVC_NORESIZE,
 				     &ipvs->work_flags))
 				goto unlock_sem;
 			if (resched_score >= 100) {
@@ -764,16 +772,18 @@ static void svc_resize_work_handler(struct work_struct *work)
 			goto same_bucket;
 	}
 
-	/* Tables can be switched only under service_mutex */
-	while (!mutex_trylock(&ipvs->service_mutex)) {
+	/* Tables can be switched only under service_mutex, svc_replace_sem */
+	for (;;) {
+		/* Serialize with readers that don't like svc_table changes */
+		down_write(&ipvs->svc_replace_sem);
+		if (mutex_trylock(&ipvs->service_mutex))
+			break;
+		up_write(&ipvs->svc_replace_sem);
 		cond_resched();
 		if (!READ_ONCE(ipvs->enable) ||
 		    test_bit(IP_VS_WORK_SVC_NORESIZE, &ipvs->work_flags))
 			goto unlock_sem;
 	}
-	if (!READ_ONCE(ipvs->enable) ||
-	    test_bit(IP_VS_WORK_SVC_NORESIZE, &ipvs->work_flags))
-		goto unlock_m;
 
 	rcu_assign_pointer(ipvs->svc_table, t_new);
 	/* Inform readers that new table is installed */
@@ -781,6 +791,8 @@ static void svc_resize_work_handler(struct work_struct *work)
 	atomic_inc(&ipvs->svc_table_changes);
 	t_free = t;
 
+	up_write(&ipvs->svc_replace_sem);
+
 unlock_m:
 	mutex_unlock(&ipvs->service_mutex);
 
@@ -2184,17 +2196,21 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
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
@@ -2207,17 +2223,17 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
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
@@ -3503,7 +3519,7 @@ __ip_vs_get_service_entries(struct netns_ipvs *ipvs,
 	int ret = 0;
 
 	lockdep_assert_held(&ipvs->svc_resize_sem);
-	/* All service modifications are disabled, go ahead */
+	/* All svc_table modifications are disabled, go ahead */
 	ip_vs_rht_walk_buckets(ipvs->svc_table, head) {
 		hlist_bl_for_each_entry(svc, e, head, s_list) {
 			/* Only expose IPv4 entries to old interface */
@@ -3687,7 +3703,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 			pr_err("length: %u != %zu\n", *len, size);
 			return -EINVAL;
 		}
-		/* Protect against table resizer moving the entries.
+		/* Prevent modifications to the list with services.
 		 * Try reverse locking, so that we do not hold the mutex
 		 * while waiting for semaphore.
 		 */
@@ -4029,6 +4045,7 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 	int start = cb->args[0];
 	int idx = 0;
 
+	/* Make sure we do not see same service twice during resize */
 	down_read(&ipvs->svc_resize_sem);
 	rcu_read_lock();
 	ip_vs_rht_walk_buckets_safe_rcu(ipvs->svc_table, head) {
@@ -5072,6 +5089,7 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 	/* Initialize service_mutex, svc_table per netns */
 	__mutex_init(&ipvs->service_mutex, "ipvs->service_mutex", &__ipvs_service_key);
 	init_rwsem(&ipvs->svc_resize_sem);
+	init_rwsem(&ipvs->svc_replace_sem);
 	INIT_DELAYED_WORK(&ipvs->svc_resize_work, svc_resize_work_handler);
 	atomic_set(&ipvs->svc_table_changes, 0);
 	RCU_INIT_POINTER(ipvs->svc_table, NULL);
-- 
2.53.0


