Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 448572459DC;
	Tue,  5 May 2026 00:17:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.190.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777940230; cv=none; b=uo8jhPngq0o6l3fuoPxFtaN6WmZitLas8bukKlkrHUvQDbn7xfPFSnLNpq0H9rpPHxm3fCCZWIxPi0PpL7HjJu/vXwZ/VqrzaRd6mryg/cYItIDLttZFCDYtnqbUi0+RZNZtBLQJQoM5zxm9il/BN+omdv2aPioRQquJ1oeOLk8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777940230; c=relaxed/simple;
	bh=P7RpJCaWvKNevet+YaHQXxVvbcyauWdE87MPVGKibBc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=OxG6RQTNFgksyGJGyR3r0tfT0UqtD2a0LFP/pjGuW4kTEybX2KOWgOepqhUBfoGb+Sef73JGX/8epbsO/U3FqTJkHHrJBS9tPzfEwjwDg/HAK5On7RcSBIVpcrsdx50FyTesHyHnz9g8Tiu4MuMrPfrBEYwDp7OQZwIzYfwImHw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=netfilter.org; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=kDEGlyQH; arc=none smtp.client-ip=217.70.190.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="kDEGlyQH"
Received: from localhost.localdomain (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with ESMTPSA id 9B0B560181;
	Tue,  5 May 2026 02:17:06 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1777940227;
	bh=ukWs2OVa3jq5rt5WHPc5B5MT6sw31F+zegXISpxEB38=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=kDEGlyQHbZh/h2oecmF1Xa/WUdBnLiMiL1a2ugo6KBN2RK9079e5RCuqK7WKA4t2A
	 Ek5mftF2XP6Z9sYtUXRwg8pHbaXBTbADjgE3D6qGUfeH3WlbskxrSvTmhTbC36mRra
	 H9Q69eg5olXp8NyK4wsxmD9M1qIO5Z4WbvullmXvguvnznhpI7j51bLPv7CXPjQ10A
	 XnsOgXtxvp57VSQ5Nf1aEvqkwYh+YztfwW/4GQhIoBTMAKGoKziR4TTMfv4tXhSmU7
	 UhFjwdBh//iEOpHFLHJftwBZVRP2a8n0SrJXmjD3J+IN6tJa+7Iuv2hEmHSGH67a5p
	 Fj1g0PhkHeobA==
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
Subject: [PATCH net 7/8] ipvs: Guard access of HK_TYPE_KTHREAD cpumask with RCU
Date: Tue,  5 May 2026 02:16:47 +0200
Message-ID: <20260505001648.360569-8-pablo@netfilter.org>
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
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
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
2.47.3

