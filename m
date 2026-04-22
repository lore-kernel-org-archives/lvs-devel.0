Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5CE1A3E715A;
	Wed, 22 Apr 2026 12:51:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776862323; cv=none; b=Spw1f6pvYu+mfiSEy+UWOsH3NP0aJVBaYZP8YFWluj7yxEVVkua3RBaNGSJgwI9+GVYMosbRyUfVv2cxuX7+EtohrY4TZEDhkNn+LJ3vGtO7joq6YkRN8+UvsiFHhj19+yzooRmtK9M7ovzZuibGkELNS67xO+TmrPzVYcvjVX8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776862323; c=relaxed/simple;
	bh=ar6QhbBTGpoh8YkQrOJHPFvEc1ZFfPCoNn4GackDFjg=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=EUMBKtkQFnzW+jtzZ3HT/WPfO5einjxJWZmWehMfxMZmYdJBjYAkqa240BhfYXmurirgNjiWRP+4LDe0WeFlKilkklFUGedo7ZIjYou2vFq9vN2gQEw73aJgt3KYPgPEbhXP+tvpB8kpRqmQInhq6fCL/AZmz1pqQhBBA0goYZo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=38oiYPEE; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="38oiYPEE"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 77D12211D2;
	Wed, 22 Apr 2026 15:51:50 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=SHxZ9pQG
	07lPJRVye6HXIdFTsN+sau0DOK777qnIUb4=; b=38oiYPEEr2J17D7oWosPshPz
	CP0IIFIU8tmVe5JXDLuw9L4tvNEtBP1DZ64QXoqyZMBtmjzAskK7IDWdna4HsHZ5
	LO1F09UTBw/zLoRDgmBzVyareuAo7AKZDCeSfv2P6YgfC6gfS+SKNg/ucyl0i75d
	ofZSmklNR1bK3qvkLq+r5EBn4pCAUIdt9aTWqH2km48GYdAXKovAU7QU1YtU4QJ1
	zAbZa4RcyC+lPukk9sWiGPghbN8aNyS1hevHLLUt7kdoF1iLz4Yks1IgBRS7K3xQ
	oxg0V6/5u/JaPn0IZvM5KnCn2Zt24SGVATyQDi2CtSWs6PU5CAzggJWe+Rq7RHxo
	bhyEpTZ+VniD+soMQ9hTtQnTFKcEi0aPBRlU7goreORZIrdRdGa0KA6xVWViEpXL
	2ugYgB0bZ/BiMS+/Dlme2FyKvrgQDEIpXwyauMLG+wrzzkN34/aq5tBXii15R8pv
	EDibAheyY9sLvGdo//bs346vzlu+IdXkmGqHgynbsSQlutIebFQuCsvqnrB2HgnF
	pIdEJ8yH/p9DJce/EdEy3AjAVLxLbPPaRdFY17uxccAdiN3tee5+3majnD3t4HYj
	RWHHpHFderXYp8NIp+johzJ6k/Voxghek6E0sHwEt2zmE+xTS/DhPicCUKuwo6TC
	jvuUV4kPOIzm8kupXfo=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 22 Apr 2026 15:51:48 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id C3F0460EE6;
	Wed, 22 Apr 2026 15:51:47 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63MCpkeg040676;
	Wed, 22 Apr 2026 15:51:46 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63MCpggu040675;
	Wed, 22 Apr 2026 15:51:42 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCHv2 net] ipvs: fix races around est_mutex and est_cpulist
Date: Wed, 22 Apr 2026 15:51:23 +0300
Message-ID: <20260422125123.40658-1-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Sashiko reports for races and possible crash around
the usage of est_cpulist_valid and sysctl_est_cpulist.
The problem is that we do not lock est_mutex in some
places which can lead to wrong write ordering and
as result problems when calling cpumask_weight()
and cpumask_empty().

Fix them by moving the est_max_threads read/write under
locked est_mutex. Do the same for one ip_vs_est_reload_start()
call to protect the cpumask_empty() usage of sysctl_est_cpulist.

To remove the chance of deadlock while stopping the
estimation kthreads, use the service_mutex to walk the
array with kthreads and hold it during kthread_stop().
OTOH, est_mutex is needed only while starting the
kthreads, not for stopping. Reorganize the code in
kthread 0 to use mutex_trylock() for the service_mutex
to ensure kthread_should_stop() is not true while we
attempt to lock the mutex.

Link: https://sashiko.dev/#/patchset/20260331165015.2777765-1-longman%40redhat.com
Link: https://sashiko.dev/#/patchset/20260420171308.87192-1-ja%40ssi.bg
Fixes: f0be83d54217 ("ipvs: add est_cpulist and est_nice sysctl vars")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 11 +++++--
 net/netfilter/ipvs/ip_vs_est.c | 59 ++++++++++++++++++++++------------
 2 files changed, 47 insertions(+), 23 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index caec516856e9..fda166aca4fb 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -250,7 +250,7 @@ static void est_reload_work_handler(struct work_struct *work)
 	int genid;
 	int id;
 
-	mutex_lock(&ipvs->est_mutex);
+	mutex_lock(&ipvs->service_mutex);
 	genid = atomic_read(&ipvs->est_genid);
 	for (id = 0; id < ipvs->est_kt_count; id++) {
 		struct ip_vs_est_kt_data *kd = ipvs->est_kt_arr[id];
@@ -263,12 +263,14 @@ static void est_reload_work_handler(struct work_struct *work)
 		/* New config ? Stop kthread tasks */
 		if (genid != genid_done)
 			ip_vs_est_kthread_stop(kd);
+		mutex_lock(&ipvs->est_mutex);
 		if (!kd->task && !ip_vs_est_stopped(ipvs)) {
 			/* Do not start kthreads above 0 in calc phase */
 			if ((!id || !ipvs->est_calc_phase) &&
 			    ip_vs_est_kthread_start(ipvs, kd) < 0)
 				repeat = true;
 		}
+		mutex_unlock(&ipvs->est_mutex);
 	}
 
 	atomic_set(&ipvs->est_genid_done, genid);
@@ -278,7 +280,7 @@ static void est_reload_work_handler(struct work_struct *work)
 				   delay);
 
 unlock:
-	mutex_unlock(&ipvs->est_mutex);
+	mutex_unlock(&ipvs->service_mutex);
 }
 
 static int get_conn_tab_size(struct netns_ipvs *ipvs)
@@ -1812,11 +1814,16 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 	*svc_p = svc;
 
 	if (!READ_ONCE(ipvs->enable)) {
+		mutex_lock(&ipvs->est_mutex);
+
 		/* Now there is a service - full throttle */
 		WRITE_ONCE(ipvs->enable, 1);
 
+		ipvs->est_max_threads = ip_vs_est_max_threads(ipvs);
+
 		/* Start estimation for first time */
 		ip_vs_est_reload_start(ipvs);
+		mutex_unlock(&ipvs->est_mutex);
 	}
 
 	return 0;
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 433ba3cab58c..216e3c354125 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -68,6 +68,10 @@
     and the limit of estimators per kthread
   - est_add_ktid: ktid where to add new ests, can point to empty slot where
     we should add kt data
+  - data protected by service_mutex: est_temp_list, est_add_ktid,
+    est_kt_count, est_kt_arr, est_genid_done, kd->task
+  - data protected by est_mutex: est_genid, est_max_threads, sysctl_est_cpulist,
+    est_cpulist_valid, sysctl_est_nice, est_stopped, sysctl_run_estimation
  */
 
 static struct lock_class_key __ipvs_est_key;
@@ -229,6 +233,8 @@ static int ip_vs_estimation_kthread(void *data)
 /* Schedule stop/start for kthread tasks */
 void ip_vs_est_reload_start(struct netns_ipvs *ipvs)
 {
+	lockdep_assert_held(&ipvs->est_mutex);
+
 	/* Ignore reloads before first service is added */
 	if (!READ_ONCE(ipvs->enable))
 		return;
@@ -304,12 +310,17 @@ static int ip_vs_est_add_kthread(struct netns_ipvs *ipvs)
 	void *arr = NULL;
 	int i;
 
-	if ((unsigned long)ipvs->est_kt_count >= ipvs->est_max_threads &&
-	    READ_ONCE(ipvs->enable) && ipvs->est_max_threads)
-		return -EINVAL;
-
 	mutex_lock(&ipvs->est_mutex);
 
+	/* Allow kt 0 data to be created before the services are added
+	 * and limit the kthreads when services are present.
+	 */
+	if ((unsigned long)ipvs->est_kt_count >= ipvs->est_max_threads &&
+	    READ_ONCE(ipvs->enable) && ipvs->est_max_threads) {
+		ret = -EINVAL;
+		goto out;
+	}
+
 	for (i = 0; i < id; i++) {
 		if (!ipvs->est_kt_arr[i])
 			break;
@@ -485,9 +496,6 @@ int ip_vs_start_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
 	struct ip_vs_estimator *est = &stats->est;
 	int ret;
 
-	if (!ipvs->est_max_threads && READ_ONCE(ipvs->enable))
-		ipvs->est_max_threads = ip_vs_est_max_threads(ipvs);
-
 	est->ktid = -1;
 	est->ktrow = IPVS_EST_NTICKS - 1;	/* Initial delay */
 
@@ -561,7 +569,6 @@ void ip_vs_stop_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
 	}
 
 	if (ktid > 0) {
-		mutex_lock(&ipvs->est_mutex);
 		ip_vs_est_kthread_destroy(kd);
 		ipvs->est_kt_arr[ktid] = NULL;
 		if (ktid == ipvs->est_kt_count - 1) {
@@ -570,7 +577,6 @@ void ip_vs_stop_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
 			       !ipvs->est_kt_arr[ipvs->est_kt_count - 1])
 				ipvs->est_kt_count--;
 		}
-		mutex_unlock(&ipvs->est_mutex);
 
 		/* This slot is now empty, prefer another available kt slot */
 		if (ktid == ipvs->est_add_ktid)
@@ -582,13 +588,11 @@ void ip_vs_stop_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
 	if (ipvs->est_kt_count == 1 && hlist_empty(&ipvs->est_temp_list)) {
 		kd = ipvs->est_kt_arr[0];
 		if (!kd || !kd->est_count) {
-			mutex_lock(&ipvs->est_mutex);
 			if (kd) {
 				ip_vs_est_kthread_destroy(kd);
 				ipvs->est_kt_arr[0] = NULL;
 			}
 			ipvs->est_kt_count--;
-			mutex_unlock(&ipvs->est_mutex);
 			ipvs->est_add_ktid = 0;
 		}
 	}
@@ -602,13 +606,17 @@ static void ip_vs_est_drain_temp_list(struct netns_ipvs *ipvs)
 	while (1) {
 		int max = 16;
 
-		mutex_lock(&ipvs->service_mutex);
+		while (!mutex_trylock(&ipvs->service_mutex)) {
+			if (kthread_should_stop() || !READ_ONCE(ipvs->enable))
+				return;
+			cond_resched();
+		}
 
 		while (max-- > 0) {
 			est = hlist_entry_safe(ipvs->est_temp_list.first,
 					       struct ip_vs_estimator, list);
 			if (est) {
-				if (kthread_should_stop())
+				if (!READ_ONCE(ipvs->enable))
 					goto unlock;
 				hlist_del_init(&est->list);
 				if (ip_vs_enqueue_estimator(ipvs, est) >= 0)
@@ -647,7 +655,11 @@ static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max)
 	u64 val;
 
 	INIT_HLIST_HEAD(&chain);
-	mutex_lock(&ipvs->service_mutex);
+	while (!mutex_trylock(&ipvs->service_mutex)) {
+		if (kthread_should_stop() || !READ_ONCE(ipvs->enable))
+			return 0;
+		cond_resched();
+	}
 	kd = ipvs->est_kt_arr[0];
 	mutex_unlock(&ipvs->service_mutex);
 	s = kd ? kd->calc_stats : NULL;
@@ -748,22 +760,24 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
 	if (!ip_vs_est_calc_limits(ipvs, &chain_max))
 		return;
 
-	mutex_lock(&ipvs->service_mutex);
+	while (!mutex_trylock(&ipvs->service_mutex)) {
+		if (kthread_should_stop() || !READ_ONCE(ipvs->enable))
+			return;
+		cond_resched();
+	}
 
 	/* Stop all other tasks, so that we can immediately move the
 	 * estimators to est_temp_list without RCU grace period
 	 */
-	mutex_lock(&ipvs->est_mutex);
 	for (id = 1; id < ipvs->est_kt_count; id++) {
 		/* netns clean up started, abort */
-		if (!READ_ONCE(ipvs->enable))
-			goto unlock2;
+		if (kthread_should_stop() || !READ_ONCE(ipvs->enable))
+			goto unlock;
 		kd = ipvs->est_kt_arr[id];
 		if (!kd)
 			continue;
 		ip_vs_est_kthread_stop(kd);
 	}
-	mutex_unlock(&ipvs->est_mutex);
 
 	/* Move all estimators to est_temp_list but carefully,
 	 * all estimators and kthread data can be released while
@@ -817,7 +831,11 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
 		 */
 		mutex_unlock(&ipvs->service_mutex);
 		cond_resched();
-		mutex_lock(&ipvs->service_mutex);
+		while (!mutex_trylock(&ipvs->service_mutex)) {
+			if (kthread_should_stop() || !READ_ONCE(ipvs->enable))
+				return;
+			cond_resched();
+		}
 
 		/* Current kt released ? */
 		if (id >= ipvs->est_kt_count)
@@ -889,7 +907,6 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
 	if (genid == atomic_read(&ipvs->est_genid))
 		ipvs->est_calc_phase = 0;
 
-unlock2:
 	mutex_unlock(&ipvs->est_mutex);
 
 unlock:
-- 
2.53.0


