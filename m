Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4354C287277;
	Tue, 29 Jul 2025 12:07:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1753790829; cv=none; b=tgjWgOwIytiAmxIIz03q/Sf34CbYgio2MHf8Zna3K17YsiaZw09hqhnRA/hlomrdbPGXpZw1wAEaCwKoZV3Zo5c1BDTWkOsjkf6SLxo43JWKypHuumjc0P/ygQ3dQyYqubRAjXgYoZcq522+AV5vHjNEPkkvThXONJgL4eyVV98=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1753790829; c=relaxed/simple;
	bh=7YhtsUEU1Up/r8idYFYHePWpNtdtgVuOvjGPjk66O9k=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=svjE+eGFAGoKZxaEfIDE0OKTOsbMas5SRuv6/CL0UeE25TEFH06U3mC1ZagBKXzbH4dJSgaX8JXYFnEZhGrMtzyZrIDUEg486Edk05qzSW4LndO7ltDoieJqj2RD9MShbzb5edwBVXjCq4h/gVItJWpttTEE1MNVvq7GTLcrVCI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=HYhxrXq8; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="HYhxrXq8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D7FF2C4CEEF;
	Tue, 29 Jul 2025 12:07:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1753790828;
	bh=7YhtsUEU1Up/r8idYFYHePWpNtdtgVuOvjGPjk66O9k=;
	h=From:To:Cc:Subject:Date:From;
	b=HYhxrXq8f+ZyZnoclNb7lMWL9rVhw1Lw7bthITUu8d0Mqq/7T6wvJfuVynYrcEwOn
	 uBAgwwaMAk3CX3biGmSp2Hn2c/qk/EOPKExYC1W00mLi037bzmvyLkKqODTpjZvlCW
	 hhY/kDaKxPSfikpH1BY+7/UNvmKcKWvpPLDgtLYcvXAIJgsVzGAEENQOy3743uumVk
	 gM6hmK2epBu/P57wATnd+Syfrsj7nb4A+D1New1QqTnLZIT1BT1RfVwLA+sO5SQUTJ
	 EKAxP/K8owqPpk3pTdh+Whm029jmnsM5vkt3EBRyNQ3WBTNYlbUcLCxvnCngQOExYL
	 Tfimp8/hkddsg==
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
Subject: [PATCH net] ipvs: Fix estimator kthreads preferred affinity
Date: Tue, 29 Jul 2025 14:06:59 +0200
Message-ID: <20250729120659.201095-1-frederic@kernel.org>
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

Fix this with using the appropriate kthread's API which will carry the
desired affinity and maintain it across CPU hotplug events and CPU
isolation constraints.

Fixes: d1a89197589c ("kthread: Default affine kthread to its preferred NUMA node")
Signed-off-by: Frederic Weisbecker <frederic@kernel.org>
---
 include/net/ip_vs.h            | 13 +++++++++++++
 net/netfilter/ipvs/ip_vs_est.c |  3 ++-
 2 files changed, 15 insertions(+), 1 deletion(-)

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

