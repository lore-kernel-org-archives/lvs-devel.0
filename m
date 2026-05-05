Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ECDDF218845;
	Tue,  5 May 2026 00:17:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.190.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777940227; cv=none; b=cMjZwVJLJax6jntSrcOmvgHgnmeMT0+ENVPtn71GVeYjJhze2HJX+zVGD1EVioM2tsKqhmC2Cu84rHRwl/04mYYxAOlYcdZyWfWZ+Uvgzp0pc8W/jQL4OXzShzz4o8zv2AIi8kXDXmcHxwErL7Dd9QU/sw/BLSnIG19s7m+N4iE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777940227; c=relaxed/simple;
	bh=PPEzu6FPZsqB/LlfaBIGKggTjqVM4Im49Khl8Tmh1VY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=tsaFRF3caFTnImxny9pVX/jtPHcm9pEXFwXHdvCojyT9NtDP3UlDDJ6gnpBgM+8zaUPcN5GABJvMRmUUL9ivt2xH4fukyRx7EspPyh0f9ViGGBH9MKxSL3cZZjhkiNSLLQdFJ7rM1L1/bRTckZwfbwtSBSAZnNwbzFAkJKGb8Bc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=netfilter.org; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=JALwqddb; arc=none smtp.client-ip=217.70.190.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="JALwqddb"
Received: from localhost.localdomain (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with ESMTPSA id C7FCF6024E;
	Tue,  5 May 2026 02:17:01 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1777940222;
	bh=vLDF9MaLEvt27/D+of+9lqviu5Cxz2MaM3jxoD8Olzo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=JALwqddbCLiF+7PV2jBObepK10A+A5J1j+zHakIEquiATlPWe5fKvNNnYbes/28AG
	 mKQ1JNXykKnK5U/2RT8D9w27apuKjPhNcNcNrcoVqV34/Gt6ndNWfUvNNRy7qg5beU
	 ivZqe9hvayH4W1zr8LZvYuZOxlHzXTQgbJx9wZsPwa708QHBUrqk5BunBvwBVfnwtT
	 rpM8ZbPnE/tFbQwYnIU5ewnlXpmLb/FMLBD2jEAZGr7Av730/xwH3t2/qJbVWUXZAa
	 AF0QwDw5GFnOlcqjgFQxsvQgkVbfsVk4rCefIyXfsNrMf4XRCYVfrZ9IO/MIQ4XAe3
	 oE8yBuME00//w==
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
Subject: [PATCH net 5/8] ipvs: fix races around est_mutex and est_cpulist
Date: Tue,  5 May 2026 02:16:45 +0200
Message-ID: <20260505001648.360569-6-pablo@netfilter.org>
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

Reduce the use of service_mutex in ip_vs_est_calc_phase()
because under est_mutex we can safely walk est_kt_arr to
stop the kthreads above slot 0.

As ip_vs_stop_estimator() for tot_stats should be called
under service_mutex, do it early in the netns exit path
in ip_vs_flush() to avoid locking the mutex again later.
It still should be called in ip_vs_control_net_cleanup_sysctl()
when we are called during netns init error. Use -2 for ktid
as indicator if estimator was already stopped.

Finally, fix use-after-free for kd->est_row in
ip_vs_est_calc_phase(). est->ktrow should simply switch to
a delay value while estimator is linked to est_temp_list.

Link: https://sashiko.dev/#/patchset/20260331165015.2777765-1-longman%40redhat.com
Link: https://sashiko.dev/#/patchset/20260420171308.87192-1-ja%40ssi.bg
Link: https://sashiko.dev/#/patchset/20260422125123.40658-1-ja%40ssi.bg
Link: https://sashiko.dev/#/patchset/20260424175858.54752-1-ja%40ssi.bg
Link: https://sashiko.dev/#/patchset/20260425103918.7447-1-ja%40ssi.bg
Fixes: f0be83d54217 ("ipvs: add est_cpulist and est_nice sysctl vars")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/ip_vs.h            | 11 ++++-
 net/netfilter/ipvs/ip_vs_ctl.c | 51 +++++++++++++++++----
 net/netfilter/ipvs/ip_vs_est.c | 83 ++++++++++++++++++++--------------
 3 files changed, 100 insertions(+), 45 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 72d325c81313..d28ad8a0541f 100644
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
@@ -1884,11 +1885,19 @@ int ip_vs_start_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats);
 void ip_vs_stop_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats);
 void ip_vs_zero_estimator(struct ip_vs_stats *stats);
 void ip_vs_read_estimator(struct ip_vs_kstats *dst, struct ip_vs_stats *stats);
-void ip_vs_est_reload_start(struct netns_ipvs *ipvs);
+void ip_vs_est_reload_start(struct netns_ipvs *ipvs, bool restart);
 int ip_vs_est_kthread_start(struct netns_ipvs *ipvs,
 			    struct ip_vs_est_kt_data *kd);
 void ip_vs_est_kthread_stop(struct ip_vs_est_kt_data *kd);
 
+static inline void ip_vs_stop_estimator_tot_stats(struct netns_ipvs *ipvs)
+{
+#ifdef CONFIG_SYSCTL
+	ip_vs_stop_estimator(ipvs, &ipvs->tot_stats->s);
+	ipvs->tot_stats->s.est.ktid = -2;
+#endif
+}
+
 static inline void ip_vs_est_stopped_recalc(struct netns_ipvs *ipvs)
 {
 #ifdef CONFIG_SYSCTL
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index d81077c2457a..5c9f8e0e238f 100644
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
@@ -1823,11 +1839,16 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
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
@@ -2103,6 +2124,11 @@ static int ip_vs_flush(struct netns_ipvs *ipvs, bool cleanup)
 			t = p;
 		}
 	}
+	/* Stop the tot_stats estimator early under service_mutex
+	 * to avoid locking it again later.
+	 */
+	if (cleanup)
+		ip_vs_stop_estimator_tot_stats(ipvs);
 	return 0;
 }
 
@@ -2348,7 +2374,7 @@ static int ipvs_proc_est_cpumask_set(const struct ctl_table *table,
 	/* est_max_threads may depend on cpulist size */
 	ipvs->est_max_threads = ip_vs_est_max_threads(ipvs);
 	ipvs->est_calc_phase = 1;
-	ip_vs_est_reload_start(ipvs);
+	ip_vs_est_reload_start(ipvs, true);
 
 unlock:
 	mutex_unlock(&ipvs->est_mutex);
@@ -2428,7 +2454,7 @@ static int ipvs_proc_est_nice(const struct ctl_table *table, int write,
 			mutex_lock(&ipvs->est_mutex);
 			if (*valp != val) {
 				*valp = val;
-				ip_vs_est_reload_start(ipvs);
+				ip_vs_est_reload_start(ipvs, true);
 			}
 			mutex_unlock(&ipvs->est_mutex);
 		}
@@ -2455,7 +2481,7 @@ static int ipvs_proc_run_estimation(const struct ctl_table *table, int write,
 		mutex_lock(&ipvs->est_mutex);
 		if (*valp != val) {
 			*valp = val;
-			ip_vs_est_reload_start(ipvs);
+			ip_vs_est_reload_start(ipvs, true);
 		}
 		mutex_unlock(&ipvs->est_mutex);
 	}
@@ -5005,7 +5031,14 @@ static void __net_exit ip_vs_control_net_cleanup_sysctl(struct netns_ipvs *ipvs)
 	cancel_delayed_work_sync(&ipvs->defense_work);
 	cancel_work_sync(&ipvs->defense_work.work);
 	unregister_net_sysctl_table(ipvs->sysctl_hdr);
-	ip_vs_stop_estimator(ipvs, &ipvs->tot_stats->s);
+	if (ipvs->tot_stats->s.est.ktid != -2) {
+		/* Not stopped yet? This happens only on netns init error and
+		 * we even do not need to lock the service_mutex for this case.
+		 */
+		mutex_lock(&ipvs->service_mutex);
+		ip_vs_stop_estimator(ipvs, &ipvs->tot_stats->s);
+		mutex_unlock(&ipvs->service_mutex);
+	}
 
 	if (ipvs->est_cpulist_valid)
 		free_cpumask_var(ipvs->sysctl_est_cpulist);
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 433ba3cab58c..ab09f5182951 100644
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
 
@@ -849,9 +865,7 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
 	ip_vs_stop_estimator(ipvs, stats);
 	/* Tasks are stopped, move without RCU grace period */
 	est->ktid = -1;
-	est->ktrow = row - kd->est_row;
-	if (est->ktrow < 0)
-		est->ktrow += IPVS_EST_NTICKS;
+	est->ktrow = delay;
 	hlist_add_head(&est->list, &ipvs->est_temp_list);
 	/* kd freed ? */
 	if (last)
@@ -889,7 +903,6 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
 	if (genid == atomic_read(&ipvs->est_genid))
 		ipvs->est_calc_phase = 0;
 
-unlock2:
 	mutex_unlock(&ipvs->est_mutex);
 
 unlock:
-- 
2.47.3

