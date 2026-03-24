Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EA3A8406272
	for <lvs-devel@vger.kernel.org>; Tue, 24 Mar 2026 15:19:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774365560; cv=none; b=kTUE+AdK1Sk2KyMD3MXpNjUf7dWEOoLa1bURLZ9XuTIxoQ0QRURsRazHwR0iJYN16sGppNR1TX1Vl0LtpzIRVUt8CwErEym/HpBELKUEPqRPtta/oHyBtPwV4+yEiy3GL1V2EbMLgdZc3x8tFCGvlyZ0GYy26zlJo4Xu199OOEE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774365560; c=relaxed/simple;
	bh=yQu+yg14FNYHLy+s+BbhOlgj6hTn6x3xR7kw0ed5ygA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=QsrAQzEjAkD7XRpdCaIgIJU3rt55wQFWxImC4QieoR9mo2P/1YkDDnPZGKhUDiqbIFoR+4VgxqbOL10W8HgeI8Ki7VWZnq7HJi64rLJz/alXybP8t3rVmOHySxfBkrF8Qjrr5goJlpzaNGgXgt61BIAsVvCoxsZBqwKNwR2RwK8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=DgZTSMk8; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="DgZTSMk8"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1774365555;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=47K4ukq6ERapPLsJPgxXf1k9UvvwaRytR4+a7cgPSYw=;
	b=DgZTSMk8MUQwgAX1/wPeE5pBySz9IhkNrmfu9Y4t/noRwZpAVR6aLBqAXGB7IbAk18j2xh
	s3T0csefPxFehSgU5jxtVKMGFWyuZiQ9zM8yqdceQJHasgxVVqehcjQ/zJHp87VjyCTBuL
	agYBmver4BNqwR4PlFNqNff3xxHMTYA=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-265-fwC_8vFtNWuKSKRWqW9RmQ-1; Tue,
 24 Mar 2026 11:19:11 -0400
X-MC-Unique: fwC_8vFtNWuKSKRWqW9RmQ-1
X-Mimecast-MFC-AGG-ID: fwC_8vFtNWuKSKRWqW9RmQ_1774365549
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id E95361956046;
	Tue, 24 Mar 2026 15:19:08 +0000 (UTC)
Received: from llong-thinkpadp16vgen1.westford.csb (unknown [10.22.65.192])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 8BBCA1800764;
	Tue, 24 Mar 2026 15:19:04 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	"David S. Miller" <davem@davemloft.net>,
	David Ahern <dsahern@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	Frederic Weisbecker <frederic@kernel.org>,
	Chen Ridong <chenridong@huawei.com>,
	Phil Auld <pauld@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	sheviks <sheviks@gmail.com>,
	Waiman Long <longman@redhat.com>
Subject: [PATCH 2/2] ipvs: Guard access of HK_TYPE_KTHREAD cpumask with RCU
Date: Tue, 24 Mar 2026 11:18:27 -0400
Message-ID: <20260324151827.2006656-3-longman@redhat.com>
In-Reply-To: <20260324151827.2006656-1-longman@redhat.com>
References: <20260324151827.2006656-1-longman@redhat.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

The ip_vs_ctl.c file and the associated ip_vs.h file are the only places
in the kernel where HK_TYPE_KTHREAD cpumask is being retrieved and used.
Now that HK_TYPE_KTHREAD/HK_TYPE_DOMAIN cpumask can be changed at run
time. We need to use RCU to guard access to this cpumask to avoid a
potential UAF problem as the returned cpumask may be freed before it
is being used.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 include/net/ip_vs.h            | 20 ++++++++++++++++----
 net/netfilter/ipvs/ip_vs_ctl.c | 13 ++++++++-----
 2 files changed, 24 insertions(+), 9 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 29a36709e7f3..17c85a575ef4 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1155,7 +1155,7 @@ static inline int sysctl_run_estimation(struct netns_ipvs *ipvs)
 	return ipvs->sysctl_run_estimation;
 }
 
-static inline const struct cpumask *sysctl_est_cpulist(struct netns_ipvs *ipvs)
+static inline const struct cpumask *__sysctl_est_cpulist(struct netns_ipvs *ipvs)
 {
 	if (ipvs->est_cpulist_valid)
 		return ipvs->sysctl_est_cpulist;
@@ -1273,7 +1273,7 @@ static inline int sysctl_run_estimation(struct netns_ipvs *ipvs)
 	return 1;
 }
 
-static inline const struct cpumask *sysctl_est_cpulist(struct netns_ipvs *ipvs)
+static inline const struct cpumask *__sysctl_est_cpulist(struct netns_ipvs *ipvs)
 {
 	return housekeeping_cpumask(HK_TYPE_KTHREAD);
 }
@@ -1290,6 +1290,18 @@ static inline int sysctl_est_nice(struct netns_ipvs *ipvs)
 
 #endif
 
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
@@ -1604,7 +1616,7 @@ static inline void ip_vs_est_stopped_recalc(struct netns_ipvs *ipvs)
 	/* Stop tasks while cpulist is empty or if disabled with flag */
 	ipvs->est_stopped = !sysctl_run_estimation(ipvs) ||
 			    (ipvs->est_cpulist_valid &&
-			     cpumask_empty(sysctl_est_cpulist(ipvs)));
+			     sysctl_est_cpulist_empty(ipvs));
 #endif
 }
 
@@ -1620,7 +1632,7 @@ static inline bool ip_vs_est_stopped(struct netns_ipvs *ipvs)
 static inline int ip_vs_est_max_threads(struct netns_ipvs *ipvs)
 {
 	unsigned int limit = IPVS_EST_CPU_KTHREADS *
-			     cpumask_weight(sysctl_est_cpulist(ipvs));
+			     sysctl_est_cpulist_weight(ipvs);
 
 	return max(1U, limit);
 }
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 35642de2a0fe..f38a2e2a9dc5 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1973,11 +1973,14 @@ static int ipvs_proc_est_cpumask_get(const struct ctl_table *table,
 
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

