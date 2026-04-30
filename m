Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AC55E35836B;
	Thu, 30 Apr 2026 07:48:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777535292; cv=none; b=CyIGWWlufBMmKj03s0HfDrvYd1ihR82d6jFnMFjaV89gfX5Qx5Jq5/oAz3hNgquN8XfGSUBdjgukCOdmdtiHYwoPr7b8zPUsLJp+7sMzadIFQvZE+gKMdpNHDwhjN5eHyqjqo9n3Fm/jvdZ7q7izZZOkHN2OB6wN7Z3Mk2yRPhg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777535292; c=relaxed/simple;
	bh=VTwq0UWthz0QpJzYDrKRtfiupj+O/yP9vV5eAzWzF8g=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=psTnn4tSrHBZbNp3GrlImUkfEpuICgfL3ztFQuvAnUbm/IJMlFb/6PmkwlQ6bLXl5QR4LH52NWdlrzqrWWmfv32d+mtjJ41oUaZuP60okFWAkex4lvc5q2oKVnTfGPAc+IvX3BQKozJRtLrVFIkrIvfaXqq+pqPaQhtguiTKJRM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=wcdTu9ax; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="wcdTu9ax"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 3671622931;
	Thu, 30 Apr 2026 10:47:55 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=eDhsBF6QpJzkCaUZXdy+0cspQLn0pC7/3H/qKuY5fz4=; b=wcdTu9axOTmS
	eGDvTDhwld5GltvBJmznYhs6bhPtREzRFhJOZvpeAtrZeqzqrHmZ0KTs+8YIJQ9s
	iM5URSXZtTsic8XDHYuSdYYwmCv0Kt/yqz0UIX1KNA5ndSg13Hi+4I85A4uCH1uE
	sLRY44PC/GhS8R3GxnJ0zmkWHL6MGWhnIjrfZwb/GdQvz7QF9PXJ5xHRZCYJURxY
	Ouj3T+BtppuBgjcruzRMi0VYI4K6hz1ANZjKHdQNplt1T0wpTXAVqDJZBEieZbLE
	S0aCAYQrX0wMoT80+wgJ6yVqNocc3JcGW+wCq+WvUHiVN1r/EZjARBsrXSXK+pnd
	J+9BB0vDMNJaHrbBZdtBR928gWkJ4s4ZnSKIvC/LcHLlQWMRvXjGssXwb7YIYyiv
	YqiNBK2/oWDoiQnvQ64PT9XZmV52jzubfNiXqzPQE3h0Tb54K2aijIhv6aiBDJRR
	CiA4YGD/kLm6khHWGv5tAqzKSuB8ZHRBNGQIgSnF7Vl54J2aSu34ZUXUZkZy+prj
	BvHDPD6WGGSaCkCZSq6jf3g6uqSrytRUc09Kvxbsei5PmUTkT+mLDD5cRsTppPm2
	QvFr/G4ZWUxSM/25uNmatGenP+DRGS5QjyZ0KDsZmL+lwyxfHZOHub2eVXX0eEiU
	rbXEp7b3lOuWmvNPzLL+w2KDOw7gLRU=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 30 Apr 2026 10:47:53 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 25C9362BA9;
	Thu, 30 Apr 2026 10:47:53 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63U7ixZu027478;
	Thu, 30 Apr 2026 10:44:59 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63U7ixYV027477;
	Thu, 30 Apr 2026 10:44:59 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        Waiman Long <longman@redhat.com>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org
Subject: [PATCHv3 nf 7/8] ipvs: Guard access of HK_TYPE_KTHREAD cpumask with RCU
Date: Thu, 30 Apr 2026 10:44:19 +0300
Message-ID: <20260430074420.26697-8-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260430074420.26697-1-ja@ssi.bg>
References: <20260430074420.26697-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Waiman Long <longman@redhat.com>

The ip_vs_ctl.c file and the associated ip_vs.h file are the only places
in the kernel where HK_TYPE_KTHREAD cpumask is being retrieved and used.
Now that HK_TYPE_KTHREAD/HK_TYPE_DOMAIN cpumask can be changed at run
time. We need to use RCU to guard access to this cpumask to avoid a
potential UAF problem as the returned cpumask may be freed before it
is being used.

We can replace HK_TYPE_KTHREAD by HK_TYPE_DOMAIN as they are aliases
of each other, but keeping the HK_TYPE_KTHREAD name can highlight the
fact that it is the kthread initiated by ipvs that is being controlled.

Fixes: 03ff73510169 ("cpuset: Update HK_TYPE_DOMAIN cpumask from cpuset")
Signed-off-by: Waiman Long <longman@redhat.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h            | 20 ++++++++++++++++----
 net/netfilter/ipvs/ip_vs_ctl.c | 13 ++++++++-----
 2 files changed, 24 insertions(+), 9 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index d28ad8a0541f..02762ce73a0c 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1412,7 +1412,7 @@ static inline int sysctl_run_estimation(struct netns_ipvs *ipvs)
 	return ipvs->sysctl_run_estimation;
 }
 
-static inline const struct cpumask *sysctl_est_cpulist(struct netns_ipvs *ipvs)
+static inline const struct cpumask *__sysctl_est_cpulist(struct netns_ipvs *ipvs)
 {
 	if (ipvs->est_cpulist_valid)
 		return ipvs->sysctl_est_cpulist;
@@ -1530,7 +1530,7 @@ static inline int sysctl_run_estimation(struct netns_ipvs *ipvs)
 	return 1;
 }
 
-static inline const struct cpumask *sysctl_est_cpulist(struct netns_ipvs *ipvs)
+static inline const struct cpumask *__sysctl_est_cpulist(struct netns_ipvs *ipvs)
 {
 	return housekeeping_cpumask(HK_TYPE_KTHREAD);
 }
@@ -1565,6 +1565,18 @@ static inline int sysctl_svc_lfactor(struct netns_ipvs *ipvs)
 	return READ_ONCE(ipvs->sysctl_svc_lfactor);
 }
 
+static inline bool sysctl_est_cpulist_empty(struct netns_ipvs *ipvs)
+{
+	guard(rcu)();
+	return cpumask_empty(__sysctl_est_cpulist(ipvs));
+}
+
+static inline unsigned int sysctl_est_cpulist_weight(struct netns_ipvs *ipvs)
+{
+	guard(rcu)();
+	return cpumask_weight(__sysctl_est_cpulist(ipvs));
+}
+
 /* IPVS core functions
  * (from ip_vs_core.c)
  */
@@ -1904,7 +1916,7 @@ static inline void ip_vs_est_stopped_recalc(struct netns_ipvs *ipvs)
 	/* Stop tasks while cpulist is empty or if disabled with flag */
 	ipvs->est_stopped = !sysctl_run_estimation(ipvs) ||
 			    (ipvs->est_cpulist_valid &&
-			     cpumask_empty(sysctl_est_cpulist(ipvs)));
+			     sysctl_est_cpulist_empty(ipvs));
 #endif
 }
 
@@ -1920,7 +1932,7 @@ static inline bool ip_vs_est_stopped(struct netns_ipvs *ipvs)
 static inline int ip_vs_est_max_threads(struct netns_ipvs *ipvs)
 {
 	unsigned int limit = IPVS_EST_CPU_KTHREADS *
-			     cpumask_weight(sysctl_est_cpulist(ipvs));
+			     sysctl_est_cpulist_weight(ipvs);
 
 	return max(1U, limit);
 }
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 5c9f8e0e238f..c7c7f6a7a9f6 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2394,11 +2394,14 @@ static int ipvs_proc_est_cpumask_get(const struct ctl_table *table,
 
 	mutex_lock(&ipvs->est_mutex);
 
-	if (ipvs->est_cpulist_valid)
-		mask = *valp;
-	else
-		mask = (struct cpumask *)housekeeping_cpumask(HK_TYPE_KTHREAD);
-	ret = scnprintf(buffer, size, "%*pbl\n", cpumask_pr_args(mask));
+	/* HK_TYPE_KTHREAD cpumask needs RCU protection */
+	scoped_guard(rcu) {
+		if (ipvs->est_cpulist_valid)
+			mask = *valp;
+		else
+			mask = (struct cpumask *)housekeeping_cpumask(HK_TYPE_KTHREAD);
+		ret = scnprintf(buffer, size, "%*pbl\n", cpumask_pr_args(mask));
+	}
 
 	mutex_unlock(&ipvs->est_mutex);
 
-- 
2.53.0


