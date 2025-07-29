Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 04708290BBD;
	Tue, 29 Jul 2025 12:26:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1753791980; cv=none; b=EB7eqlTIzi1LjbhP3/rXKKYUjvqsVrROLlKeGNKwBdE9V8gU65RBVRRJq0Lor8QsDEIjBizBshYDHcw/m4x/tBISbIXtKvIC/mau8gQaiUDUtMELm7GfQHVYdWBDY519QaJlZr+Zghtz0K5s1tZJY3q0w3rn8wobT+sjMq6K//c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1753791980; c=relaxed/simple;
	bh=nquTTUMIrwc+nEkVUf/cLkSfGQBgHYB50kSvfwd2NeA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=owxc6ZLVsV6ybqQ2UZJ4SKetWD98VLq/R32YItKcoJvTY3yBVWOKw7ZunkoAR6jNb7Iw1YpX9jljoh/gvVf2tlX1uVNoOFuZ0cMnIsdIwuBQtvw/rWze6aZZKaUinFDBa3RyRvMX3w41Ghzzb7alSMqp7qwBMT1aAQVzfsNYqug=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=rZMzeYqw; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="rZMzeYqw"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5AA31C4CEF4;
	Tue, 29 Jul 2025 12:26:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1753791979;
	bh=nquTTUMIrwc+nEkVUf/cLkSfGQBgHYB50kSvfwd2NeA=;
	h=From:To:Cc:Subject:Date:From;
	b=rZMzeYqwaOItoGjqO2pD+ucnzn3PyfgDywLUjx7mqsjiXyT8Ptb5Mjmk3iYWo8a0a
	 A9FDgu8TnyEM/PlcWjON1/nm56nbgMMPVpyp/Z6dVPIwjXq/pGp3te/L3LwUTy7buC
	 TnURpsEg/Cblwro7tDY/a7uiWj77N11X77G/YFel1HaSh7P0ryrI7YRwyAC4yQcOE9
	 p7zTIPK20EaLCOBY3Re0sYUq+vDGarEChL2NLMZam38WAJN8BJ0xWQ1+hXeqJuZd5C
	 yHHpAOua18ye6VTQmVXlLm8jLNSI+wPrwdZLLbhjRgNPR4xgUWT33o049vjCb95oH9
	 HT7H8xFvxF9Og==
From: Frederic Weisbecker <frederic@kernel.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Frederic Weisbecker <frederic@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	David Ahern <dsahern@kernel.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@netfilter.org>,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org
Subject: [PATCH v2 net] ipvs: Fix estimator kthreads preferred affinity
Date: Tue, 29 Jul 2025 14:26:11 +0200
Message-ID: <20250729122611.247368-1-frederic@kernel.org>
X-Mailer: git-send-email 2.48.1
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The estimator kthreads' affinity are defined by sysctl overwritten
preferences and applied through a plain call to the scheduler's affinity
API.

However since the introduction of managed kthreads preferred affinity,
such a practice shortcuts the kthreads core code which eventually
overwrites the target to the default unbound affinity.

Fix this with using the appropriate kthread's API.

Fixes: d1a89197589c ("kthread: Default affine kthread to its preferred NUMA node")
Signed-off-by: Frederic Weisbecker <frederic@kernel.org>
---
 include/net/ip_vs.h            | 13 +++++++++++++
 kernel/kthread.c               |  1 +
 net/netfilter/ipvs/ip_vs_est.c |  3 ++-
 3 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index ff406ef4fd4a..29a36709e7f3 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1163,6 +1163,14 @@ static inline const struct cpumask *sysctl_est_cpulist(struct netns_ipvs *ipvs)
 		return housekeeping_cpumask(HK_TYPE_KTHREAD);
 }
 
+static inline const struct cpumask *sysctl_est_preferred_cpulist(struct netns_ipvs *ipvs)
+{
+	if (ipvs->est_cpulist_valid)
+		return ipvs->sysctl_est_cpulist;
+	else
+		return NULL;
+}
+
 static inline int sysctl_est_nice(struct netns_ipvs *ipvs)
 {
 	return ipvs->sysctl_est_nice;
@@ -1270,6 +1278,11 @@ static inline const struct cpumask *sysctl_est_cpulist(struct netns_ipvs *ipvs)
 	return housekeeping_cpumask(HK_TYPE_KTHREAD);
 }
 
+static inline const struct cpumask *sysctl_est_preferred_cpulist(struct netns_ipvs *ipvs)
+{
+	return NULL;
+}
+
 static inline int sysctl_est_nice(struct netns_ipvs *ipvs)
 {
 	return IPVS_EST_NICE;
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 85e29b250107..adf06196b844 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -899,6 +899,7 @@ int kthread_affine_preferred(struct task_struct *p, const struct cpumask *mask)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(kthread_affine_preferred);
 
 static int kthreads_update_affinity(bool force)
 {
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index f821ad2e19b3..15049b826732 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -265,7 +265,8 @@ int ip_vs_est_kthread_start(struct netns_ipvs *ipvs,
 	}
 
 	set_user_nice(kd->task, sysctl_est_nice(ipvs));
-	set_cpus_allowed_ptr(kd->task, sysctl_est_cpulist(ipvs));
+	if (sysctl_est_preferred_cpulist(ipvs))
+		kthread_affine_preferred(kd->task, sysctl_est_preferred_cpulist(ipvs));
 
 	pr_info("starting estimator thread %d...\n", kd->id);
 	wake_up_process(kd->task);
-- 
2.48.1

