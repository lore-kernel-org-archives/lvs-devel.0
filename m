Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2DEC63803F3;
	Mon, 20 Apr 2026 17:13:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776705234; cv=none; b=BgIcCyck6VhvV6RpwqP8rdmTCYeYXi251WEeOtTTFF0bjs+BJJ9/5qlX/C/Mw22d3opCKQMD+f1u9zBV2JnjHo23xJaGj+AWu1CU5K8G3kUQfAtyZhkO6ewN42sY3FCX4mkZfWAh6ckRJdeWJEOUAQe2BZMA2jHzvbJDwCvUa18=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776705234; c=relaxed/simple;
	bh=vbBalwyLlxwHVPo+rRYd+pCZFRGpWMku+UKNxgElFXs=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=SdtgHtgd3IyL/sRqZ+V8frlv1+2lBeUMNJ9P8MDTyOMqCcFvqoRYEQnf0B5F6MQmKEptxwakdIbkbvsViVf6NFkjohZKMLmHvzGE0KJA6IIrvcmQ8pbWbV2UrZLU4M0e3ilaB1WO/6fBrKgwxQjs7zrvElJDDcNiNFqEWhvqcZM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=o+WpO+tF; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="o+WpO+tF"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 050B0210D3;
	Mon, 20 Apr 2026 20:13:50 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=DZixscu+
	o4afjZu0PixtPTvDZyQSbehndGDrvyrAB2k=; b=o+WpO+tFD8/YPVrXXRTHDTYK
	/Yy/i9GgWPWenmfJ9yDCpiRMLxNZBgCHju8Ebx1mD7SXdEOcwq1M4wOyk9VRUwNd
	Qa6QnH1Z+QRnEO6orYk77S6PCEEQrRupNpXWDdQ1F0iJdL5H2rzQITf/KCor4jxk
	3vS//irKZwfDOFTFNRJ5LWvjP8GHTUwOv/9+T+WQ0V4Tq0bMQYf7F+Ooqyg5F2kc
	naHWNKXzLeFUkvVkpmumjgG35r4bQJmXFTC6Pg3+INKGQ+3xuTPNbsBsL/00cCCy
	DyWBnRO1aLM6fhW3chAbIZUy6oZtrk1I3362CniKu0RmbEtZkuFPK76BtiCVhqhn
	kyIkXF0ysjzPaQMjINqArgjN6vKU1qgnDUEpPjADQzPQZMWHAN6L1DqcgGiPJb5p
	+upoEclFtTZaYnCMiI93g2/d/szQv6KJDjvl5DvEXNKp5gByR6ls60AryBEsNvwe
	VxPQzvJGk53FXjsUNeGZVebvRkJR9N4fyrv9ewpgBUQc9bkiPv+q9Ba1WrgC7BvM
	d/j4bSd4rgvvz57joCGT0fWLUF3+D84WPrB/V8gHoVavL7tGdGiCduz2mgNcvHy4
	wqUbvGMF7fWUthlNyyfjB3APaCd1hI/uQdPlCBamne345zSbce+gu/5Pia0VWC7o
	i31xt6GPeLinCby6+VA=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 20 Apr 2026 20:13:47 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id E49AF628C8;
	Mon, 20 Apr 2026 20:13:46 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63KHDj2B087216;
	Mon, 20 Apr 2026 20:13:45 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63KHDjr8087215;
	Mon, 20 Apr 2026 20:13:45 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH net] ipvs: fix races around est_mutex and est_cpulist
Date: Mon, 20 Apr 2026 20:13:08 +0300
Message-ID: <20260420171308.87192-1-ja@ssi.bg>
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

Link: https://sashiko.dev/#/patchset/20260331165015.2777765-1-longman%40redhat.com
Fixes: f0be83d54217 ("ipvs: add est_cpulist and est_nice sysctl vars")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

 Note that this patch complements v2 of patchset from 31-MAR-26
 "ipvs: Fix incorrect use of HK_TYPE_KTHREAD housekeeping cpumask"
 and can be applied before it to avoid the bad AI reviews:

 https://lore.kernel.org/all/20260331165015.2777765-1-longman@redhat.com/

 net/netfilter/ipvs/ip_vs_ctl.c |  5 +++++
 net/netfilter/ipvs/ip_vs_est.c | 22 +++++++++++++++-------
 2 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index caec516856e9..8778e174ef56 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1812,11 +1812,16 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
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
index 433ba3cab58c..6c9981d5611e 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -68,6 +68,10 @@
     and the limit of estimators per kthread
   - est_add_ktid: ktid where to add new ests, can point to empty slot where
     we should add kt data
+  - data protected by service_mutex: est_temp_list, est_add_ktid
+  - data protected by est_mutex: est_kt_count, est_kt_arr, est_max_threads,
+    sysctl_est_cpulist, est_cpulist_valid, sysctl_est_nice, est_stopped,
+    sysctl_run_estimation
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
 
-- 
2.53.0


