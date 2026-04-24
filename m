Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2275C3E717C;
	Fri, 24 Apr 2026 17:59:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777053568; cv=none; b=YlG2dlE1HO3ieg0+baOj88Wy/9rdMJURxuxnuKKI9tsw/m0x+YiKiHPBeKadiT2fj0XVxLpn/IXKkpw6lY8hn8T7S1rTC690wjMaKrMuZ4aGTxW48I2rjuUmSeBvZ6QsAJdn5vpWLJWltV4gGfEIAqxmCdw+a4uda7erYfUeUTY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777053568; c=relaxed/simple;
	bh=z/t+fSz72dq0G2JylXTEdUSyRJoXqRC3G+jLL/q+DvI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=dr4xhnW9NhC8SitTRh2qGKITJPAHQiKVahfS6ZPLi1zMj80T2NfkTo27xOHprXWMQ/jFaCUPHZrKiHTLRxadX0z8sC7LKk03xL2bHojD7Vx08NxQZzckTKb2XFFiGLse/3lKg2MPm7bpeZSe9HC/cYPSdyKBZYWuCu2kj/0GkKY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=uwOxBeaO; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="uwOxBeaO"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 31CC121269;
	Fri, 24 Apr 2026 20:59:21 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=WpL2zKdc
	IhHUeH35RlEtS1aIrxH1tIze4FzLrE7lzw4=; b=uwOxBeaO6DRfvf3OJ3/CD3zW
	3DyiiQqfokqtJTiVBQLnVjddioSUqEQRGA35ladSpelUz/W6GwM+ggNgsdJNXIOy
	WNi/KsY68HysliC2eIAKk79TEfAN+miiJsKK2ebYn9SR4VtDOOwuDexH6eLgSibr
	gFfEYM17P5y3gDF18b4wUbMzIBNWw1KXFR5c4xQSCF/VjbvFx46APHOqaKPM29GY
	jueT6AcQyTk5TTQ9I7X906woUKtCyvl7cSwCeBaUTM4dPXxNd2TcUeBrrq21D280
	KSYu3lPfLZcNOGwDkxhqNTTKahD4OBEAZZXykHpB5SN2a93XTro1FEeOywsVfHEv
	Zh67rS3MmN+mxcun5U3StWA4HbNWZGun0CA001TlpMjqwm/wHr5bwxkA58PXkmnf
	gzBtapmE4oY83N1E9HZjNml5ot6qTKyqnvn4zhp8oP2ervgavqjEhMsEUZ7WJKq+
	9gtCz6e6URVAyBNhmkkRnaucb7sL72aySZBL6Q8AB5KvpgLaKnshO/N4Pz1MUCCT
	UWx1O6ne95tqJM01M4JlHE0YLiiawmYXcKhZw17nfM9vjmDQ1XwQpsvM7CudmxIx
	9OxbxMLm3vQ/Uz4FxMrQrbaysguQ8kHXpgFkAHQSI+Bdnt4glyam+YknHQxlI5mf
	O8lXV+OuaSijJJwUvl0=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 24 Apr 2026 20:59:18 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 069DD60863;
	Fri, 24 Apr 2026 20:59:17 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63OHxFhh054771;
	Fri, 24 Apr 2026 20:59:15 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63OHxCe8054764;
	Fri, 24 Apr 2026 20:59:12 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCHv3 net] ipvs: fix races around est_mutex and est_cpulist
Date: Fri, 24 Apr 2026 20:58:58 +0300
Message-ID: <20260424175858.54752-1-ja@ssi.bg>
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
estimation kthreads, keep the data structure for kthread 0
even after last estimator is removed and do not hold mutexes
while stopping this task. Now we will use a new flag 'needed'
to know when kthread 0 should run. The kthreads above 0
do not use mutexes, so stop them under est_mutex because
their kthread data still can be destroyed if they do not
serve estimators. Now all kthreads will be started by
the est_reload_work to properly serialize the stop/start
for kthread 0.

Reduce the use of service_mutex in ip_vs_est_calc_limits()
because under est_mutex we can safely walk est_kt_arr to
stop the kthreads above slot 0.

Link: https://sashiko.dev/#/patchset/20260331165015.2777765-1-longman%40redhat.com
Link: https://sashiko.dev/#/patchset/20260420171308.87192-1-ja%40ssi.bg
Link: https://sashiko.dev/#/patchset/20260422125123.40658-1-ja%40ssi.bg
Fixes: f0be83d54217 ("ipvs: add est_cpulist and est_nice sysctl vars")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h            |  3 +-
 net/netfilter/ipvs/ip_vs_ctl.c | 37 ++++++++++++----
 net/netfilter/ipvs/ip_vs_est.c | 79 ++++++++++++++++++++--------------
 3 files changed, 78 insertions(+), 41 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 72d325c81313..da375e372bee 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -491,6 +491,7 @@ struct ip_vs_est_kt_data {
 	DECLARE_BITMAP(avail, IPVS_EST_NTICKS);	/* tick has space for ests */
 	unsigned long		est_timer;	/* estimation timer (jiffies) */
 	struct ip_vs_stats	*calc_stats;	/* Used for calculation */
+	int			needed;		/* task is needed */
 	int			tick_len[IPVS_EST_NTICKS];	/* est count */
 	int			id;		/* ktid per netns */
 	int			chain_max;	/* max ests per tick chain */
@@ -1884,7 +1885,7 @@ int ip_vs_start_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats);
 void ip_vs_stop_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats);
 void ip_vs_zero_estimator(struct ip_vs_stats *stats);
 void ip_vs_read_estimator(struct ip_vs_kstats *dst, struct ip_vs_stats *stats);
-void ip_vs_est_reload_start(struct netns_ipvs *ipvs);
+void ip_vs_est_reload_start(struct netns_ipvs *ipvs, bool restart);
 int ip_vs_est_kthread_start(struct netns_ipvs *ipvs,
 			    struct ip_vs_est_kt_data *kd);
 void ip_vs_est_kthread_stop(struct ip_vs_est_kt_data *kd);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index caec516856e9..d50ba6ce5743 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -261,12 +261,28 @@ static void est_reload_work_handler(struct work_struct *work)
 		if (!kd)
 			continue;
 		/* New config ? Stop kthread tasks */
-		if (genid != genid_done)
-			ip_vs_est_kthread_stop(kd);
+		if (genid != genid_done) {
+			if (!id) {
+				/* Only we can stop kt 0 but not under mutex */
+				mutex_unlock(&ipvs->est_mutex);
+				ip_vs_est_kthread_stop(kd);
+				mutex_lock(&ipvs->est_mutex);
+				if (!READ_ONCE(ipvs->enable))
+					goto unlock;
+				/* kd for kt 0 is never destroyed */
+			} else {
+				ip_vs_est_kthread_stop(kd);
+			}
+		}
 		if (!kd->task && !ip_vs_est_stopped(ipvs)) {
+			bool start;
+
 			/* Do not start kthreads above 0 in calc phase */
-			if ((!id || !ipvs->est_calc_phase) &&
-			    ip_vs_est_kthread_start(ipvs, kd) < 0)
+			if (id)
+				start = !ipvs->est_calc_phase;
+			else
+				start = kd->needed;
+			if (start && ip_vs_est_kthread_start(ipvs, kd) < 0)
 				repeat = true;
 		}
 	}
@@ -1812,11 +1828,16 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 	*svc_p = svc;
 
 	if (!READ_ONCE(ipvs->enable)) {
+		mutex_lock(&ipvs->est_mutex);
+
 		/* Now there is a service - full throttle */
 		WRITE_ONCE(ipvs->enable, 1);
 
+		ipvs->est_max_threads = ip_vs_est_max_threads(ipvs);
+
 		/* Start estimation for first time */
-		ip_vs_est_reload_start(ipvs);
+		ip_vs_est_reload_start(ipvs, true);
+		mutex_unlock(&ipvs->est_mutex);
 	}
 
 	return 0;
@@ -2337,7 +2358,7 @@ static int ipvs_proc_est_cpumask_set(const struct ctl_table *table,
 	/* est_max_threads may depend on cpulist size */
 	ipvs->est_max_threads = ip_vs_est_max_threads(ipvs);
 	ipvs->est_calc_phase = 1;
-	ip_vs_est_reload_start(ipvs);
+	ip_vs_est_reload_start(ipvs, true);
 
 unlock:
 	mutex_unlock(&ipvs->est_mutex);
@@ -2417,7 +2438,7 @@ static int ipvs_proc_est_nice(const struct ctl_table *table, int write,
 			mutex_lock(&ipvs->est_mutex);
 			if (*valp != val) {
 				*valp = val;
-				ip_vs_est_reload_start(ipvs);
+				ip_vs_est_reload_start(ipvs, true);
 			}
 			mutex_unlock(&ipvs->est_mutex);
 		}
@@ -2444,7 +2465,7 @@ static int ipvs_proc_run_estimation(const struct ctl_table *table, int write,
 		mutex_lock(&ipvs->est_mutex);
 		if (*valp != val) {
 			*valp = val;
-			ip_vs_est_reload_start(ipvs);
+			ip_vs_est_reload_start(ipvs, true);
 		}
 		mutex_unlock(&ipvs->est_mutex);
 	}
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 433ba3cab58c..c77337a32b6f 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -68,6 +68,11 @@
     and the limit of estimators per kthread
   - est_add_ktid: ktid where to add new ests, can point to empty slot where
     we should add kt data
+  - data protected by service_mutex: est_temp_list, est_add_ktid,
+    est_kt_count(R/W), est_kt_arr(R/W), est_genid_done, kd->needed(R/W)
+  - data protected by est_mutex: est_genid, est_max_threads, sysctl_est_cpulist,
+    est_cpulist_valid, sysctl_est_nice, est_stopped, sysctl_run_estimation,
+    est_kt_count(R), est_kt_arr(R), kd->needed(R), kd->task (id > 0)
  */
 
 static struct lock_class_key __ipvs_est_key;
@@ -227,14 +232,17 @@ static int ip_vs_estimation_kthread(void *data)
 }
 
 /* Schedule stop/start for kthread tasks */
-void ip_vs_est_reload_start(struct netns_ipvs *ipvs)
+void ip_vs_est_reload_start(struct netns_ipvs *ipvs, bool restart)
 {
+	lockdep_assert_held(&ipvs->est_mutex);
+
 	/* Ignore reloads before first service is added */
 	if (!READ_ONCE(ipvs->enable))
 		return;
 	ip_vs_est_stopped_recalc(ipvs);
-	/* Bump the kthread configuration genid */
-	atomic_inc(&ipvs->est_genid);
+	/* Bump the kthread configuration genid if stopping is requested */
+	if (restart)
+		atomic_inc(&ipvs->est_genid);
 	queue_delayed_work(system_long_wq, &ipvs->est_reload_work, 0);
 }
 
@@ -304,12 +312,17 @@ static int ip_vs_est_add_kthread(struct netns_ipvs *ipvs)
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
@@ -333,6 +346,7 @@ static int ip_vs_est_add_kthread(struct netns_ipvs *ipvs)
 	kd->est_timer = jiffies;
 	kd->id = id;
 	ip_vs_est_set_params(ipvs, kd);
+	kd->needed = 1;
 
 	/* Pre-allocate stats used in calc phase */
 	if (!id && !kd->calc_stats) {
@@ -341,12 +355,8 @@ static int ip_vs_est_add_kthread(struct netns_ipvs *ipvs)
 			goto out;
 	}
 
-	/* Start kthread tasks only when services are present */
-	if (READ_ONCE(ipvs->enable) && !ip_vs_est_stopped(ipvs)) {
-		ret = ip_vs_est_kthread_start(ipvs, kd);
-		if (ret < 0)
-			goto out;
-	}
+	/* Request kthread to be started */
+	ip_vs_est_reload_start(ipvs, false);
 
 	if (arr)
 		ipvs->est_kt_count++;
@@ -482,12 +492,11 @@ static int ip_vs_enqueue_estimator(struct netns_ipvs *ipvs,
 /* Start estimation for stats */
 int ip_vs_start_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
 {
+	struct ip_vs_est_kt_data *kd = ipvs->est_kt_count > 0 ?
+				       ipvs->est_kt_arr[0] : NULL;
 	struct ip_vs_estimator *est = &stats->est;
 	int ret;
 
-	if (!ipvs->est_max_threads && READ_ONCE(ipvs->enable))
-		ipvs->est_max_threads = ip_vs_est_max_threads(ipvs);
-
 	est->ktid = -1;
 	est->ktrow = IPVS_EST_NTICKS - 1;	/* Initial delay */
 
@@ -496,8 +505,15 @@ int ip_vs_start_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
 	 * will not allocate much memory, just for kt 0.
 	 */
 	ret = 0;
-	if (!ipvs->est_kt_count || !ipvs->est_kt_arr[0])
+	if (!kd) {
 		ret = ip_vs_est_add_kthread(ipvs);
+	} else if (!kd->needed) {
+		mutex_lock(&ipvs->est_mutex);
+		/* We have job for the kt 0 task */
+		kd->needed = 1;
+		ip_vs_est_reload_start(ipvs, true);
+		mutex_unlock(&ipvs->est_mutex);
+	}
 	if (ret >= 0)
 		hlist_add_head(&est->list, &ipvs->est_temp_list);
 	else
@@ -578,16 +594,14 @@ void ip_vs_stop_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
 	}
 
 end_kt0:
-	/* kt 0 is freed after all other kthreads and chains are empty */
+	/* kt 0 task is stopped after all other kt slots and chains are empty */
 	if (ipvs->est_kt_count == 1 && hlist_empty(&ipvs->est_temp_list)) {
 		kd = ipvs->est_kt_arr[0];
-		if (!kd || !kd->est_count) {
+		if (kd && !kd->est_count) {
 			mutex_lock(&ipvs->est_mutex);
-			if (kd) {
-				ip_vs_est_kthread_destroy(kd);
-				ipvs->est_kt_arr[0] = NULL;
-			}
-			ipvs->est_kt_count--;
+			/* Keep the kt0 data but request kthread_stop */
+			kd->needed = 0;
+			ip_vs_est_reload_start(ipvs, true);
 			mutex_unlock(&ipvs->est_mutex);
 			ipvs->est_add_ktid = 0;
 		}
@@ -647,9 +661,9 @@ static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max)
 	u64 val;
 
 	INIT_HLIST_HEAD(&chain);
-	mutex_lock(&ipvs->service_mutex);
+	mutex_lock(&ipvs->est_mutex);
 	kd = ipvs->est_kt_arr[0];
-	mutex_unlock(&ipvs->service_mutex);
+	mutex_unlock(&ipvs->est_mutex);
 	s = kd ? kd->calc_stats : NULL;
 	if (!s)
 		goto out;
@@ -748,16 +762,16 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
 	if (!ip_vs_est_calc_limits(ipvs, &chain_max))
 		return;
 
-	mutex_lock(&ipvs->service_mutex);
-
 	/* Stop all other tasks, so that we can immediately move the
 	 * estimators to est_temp_list without RCU grace period
 	 */
 	mutex_lock(&ipvs->est_mutex);
 	for (id = 1; id < ipvs->est_kt_count; id++) {
 		/* netns clean up started, abort */
-		if (!READ_ONCE(ipvs->enable))
-			goto unlock2;
+		if (kthread_should_stop() || !READ_ONCE(ipvs->enable)) {
+			mutex_unlock(&ipvs->est_mutex);
+			return;
+		}
 		kd = ipvs->est_kt_arr[id];
 		if (!kd)
 			continue;
@@ -765,9 +779,11 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
 	}
 	mutex_unlock(&ipvs->est_mutex);
 
+	mutex_lock(&ipvs->service_mutex);
+
 	/* Move all estimators to est_temp_list but carefully,
 	 * all estimators and kthread data can be released while
-	 * we reschedule. Even for kthread 0.
+	 * we reschedule.
 	 */
 	step = 0;
 
@@ -889,7 +905,6 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
 	if (genid == atomic_read(&ipvs->est_genid))
 		ipvs->est_calc_phase = 0;
 
-unlock2:
 	mutex_unlock(&ipvs->est_mutex);
 
 unlock:
-- 
2.53.0


