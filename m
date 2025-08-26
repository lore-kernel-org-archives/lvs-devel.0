Received: from mail-pf1-f177.google.com (mail-pf1-f177.google.com [209.85.210.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BC14D307491;
	Tue, 26 Aug 2025 13:31:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.177
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1756215098; cv=none; b=aBFrar1Ugpej1L4rIFDs+V1T0nAAW84wwTN8SZ6BcNTPQ2EMps8Di7UDC/JlIhZFqNo07BZz9bjDNHZsK9KyHawGygpF5v9pP0MqD5Yhblfe/YOixPB02YC6E3XPyM6lE2nEWA36pI7x0WB/EbNLESO4YWFnFkKw8BSfUsdmbyk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1756215098; c=relaxed/simple;
	bh=gu1DIXx1f4Ff67mjgSQLZlK+D2O5SeGL11TXRbjtt24=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=m4GHWyKVNsxZxv9ta18Y+PEWuGiR3qIPONVezMyfOrolekNeamPlw8g+7WHR1z0WG9VU25U8i3+QL5HjSmQeAeftaRZovXZJdiQcDMl7lzlHlMyxcMxNeWgOkeS4T0Rv3BMr43p89uFwbEam5Ui/3S/d9WGC/EQ/waXAp28HakE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=i9TtcprR; arc=none smtp.client-ip=209.85.210.177
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="i9TtcprR"
Received: by mail-pf1-f177.google.com with SMTP id d2e1a72fcca58-76e2e6038cfso6264707b3a.0;
        Tue, 26 Aug 2025 06:31:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1756215095; x=1756819895; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=PHfrwmE9YtTrltGGBOrYH6WqY6dtiEDpy/X4rKWV3Dc=;
        b=i9TtcprRDq73jPBlK6vSfpwMVFMcW7R6HbneupJe1E4umAufpaw2NSVbkasJhU9B4z
         yv+QYgpWzCc/GILHQelC/bTnWfC5TgqXBmDsMn6ALN1yHCXLykH3rIjisP6+r/hamHYs
         8BaCFXdvIS1mtJin5jBD10C6Gn8uBIIp7l5htyKDQwcmdQNR5cmMA6EJUvWiJEF6VuAU
         64SVUqehVYWf2tR/cK+oE37+mpaMMAuduyDz7wuUU8vBqILabvYS6MJp4/05rly/QKrZ
         qWG1EbYZDM1MzxGzas05hxGGFNpaehvb9idfSRSUwoXGpSi+2iJUNcAxiSIWSMk2ZZ8F
         EeDg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1756215095; x=1756819895;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=PHfrwmE9YtTrltGGBOrYH6WqY6dtiEDpy/X4rKWV3Dc=;
        b=SqmNcV1W/Tl8wJEQTy6X+JmxJL3X69s5vUYUiPG73Y7197lk+DMUkebY+er7KpcRHZ
         uqTOpPAnmBSNsvm3A3twWckSMibj8H0PnzGiq4cnqD4P4H68D7R4vjT9ns41m8CBC1vn
         B7Ey3QA5df5YIiZcsF5lwnqiljPblGGzMwCmavJYCqonIDEP2hc8yw3oKq6itlz3UnVm
         VSL4A8rUK+g1n3jewiMcKjq1CwYLTWeb0JX6ZeKjNX8ZKDVLysyfUfJAnCN7/yc3NEvE
         UxBSn5GnkULdBgoG/5y2QBNM1mtKxrKQIy1G7Kk3fpOh3xAoMjESSjupYw+pqHOw2E3n
         xbnw==
X-Forwarded-Encrypted: i=1; AJvYcCUT1NUiBSX/5Ru+gmBh1FLQtpf+90t6ZV0k9E89SmdlnRfq4s7w4xv6cId+M47O6GtNzHKmIlNKmX4=@vger.kernel.org, AJvYcCVYQFyQYA1jzxVnJY5FlAYS1busodzVz4l84HeO7AAYV/I/RckqOZDIWpZQKTt1WajQTEXlsVSujpew/UxgZOlc@vger.kernel.org
X-Gm-Message-State: AOJu0Yxv7PqSgcM3GV5mpCgISOhyNaXEpo8eq6qdziX6DAoeF9paNcN8
	CCyewBqvZNCdPwPtBnxwMD8kXYOZQkZDCkhnLVf8g4oPstMOC0O4bcmi
X-Gm-Gg: ASbGnctbmUibvi8m6ktC3HwW5Dj9Nz1/NKpnbzZe5GHD8qGBlgrd2NcwG/+VOni+UeW
	Bq6iQ1kru4a0tpvwVgJnmy77xjYB6E6QrlPEvXJ2hf96UDOGtxtAD0P43NaPDWwSGMvHbLXisIr
	prcGw0qXU5xDAz8+FxIFNwTfrrQe/tUf1L3Lcv/YYIA7tvPzYG3PxnhbTV1ycjag53te8v16Ltn
	SFsSYpAzIB6pAliTHbCOmcyZbKu8H8kZtoxmVeCI27mD2XIoHMUoKZWK/2xqLeMde979WRdpFKM
	GvnGl238s6WwDNy+4dGtazqP9x2LFcygpRzcBfAvALthZQQxaVH5uREZpxQCfc0eQ/34849KVz3
	UwCz3hED5eTLPYcHIY8DkiPbWgb91bJCoz5mzND01745+T8zWjnjBo8py9S3lzJWAr/kzXNsZBI
	8H
X-Google-Smtp-Source: AGHT+IFsdkRVzBHP//3wvAKQNkeTod1q/tfIUxfBP1e22JGafF6k5sARRsKnygxdHqm/PWQqXfQdpw==
X-Received: by 2002:a17:903:11c5:b0:243:1203:404b with SMTP id d9443c01a7336-2462ef445b8mr194819745ad.28.1756215094610;
        Tue, 26 Aug 2025 06:31:34 -0700 (PDT)
Received: from localhost.localdomain (66-175-223-235.ip.linodeusercontent.com. [66.175.223.235])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2466889f188sm96598295ad.146.2025.08.26.06.31.29
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 26 Aug 2025 06:31:34 -0700 (PDT)
From: Zhang Tengfei <zhtfdev@gmail.com>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@netfilter.org>,
	Florian Westphal <fw@strlen.de>
Cc: "David S . Miller" <davem@davemloft.net>,
	David Ahern <dsahern@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	coreteam@netfilter.org,
	Zhang Tengfei <zhtfdev@gmail.com>,
	syzbot+1651b5234028c294c339@syzkaller.appspotmail.com
Subject: [PATCH] net/netfilter/ipvs: Fix data-race in ip_vs_add_service / ip_vs_out_hook
Date: Tue, 26 Aug 2025 21:31:04 +0800
Message-ID: <20250826133104.212975-1-zhtfdev@gmail.com>
X-Mailer: git-send-email 2.47.3
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A data-race was detected by KCSAN between ip_vs_add_service() which
acts as a writer, and ip_vs_out_hook() which acts as a reader. This
can lead to unpredictable behavior and crashes. One observed symptom
is the "no destination available" error when processing packets.

The race occurs on the `enable` flag within the `netns_ipvs`
struct. This flag was being written in the configuration path without
any protection, while concurrently being read in the packet processing
path. This lack of synchronization means a reader on one CPU could see a
partially initialized service, leading to incorrect behavior.

To fix this, convert the `enable` flag from a plain integer to an
atomic_t. This ensures that all reads and writes to the flag are atomic.
More importantly, using atomic_set() and atomic_read() provides the
necessary memory barriers to guarantee that changes to other fields of
the service are visible to the reader CPU before the service is marked
as enabled.

Reported-by: syzbot+1651b5234028c294c339@syzkaller.appspotmail.com
Closes: https://syzkaller.appspot.com/bug?extid=1651b5234028c294c339
Signed-off-by: Zhang Tengfei <zhtfdev@gmail.com>
---
 include/net/ip_vs.h             |  2 +-
 net/netfilter/ipvs/ip_vs_conn.c |  4 ++--
 net/netfilter/ipvs/ip_vs_core.c | 10 +++++-----
 net/netfilter/ipvs/ip_vs_ctl.c  |  6 +++---
 net/netfilter/ipvs/ip_vs_est.c  | 16 ++++++++--------
 5 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 29a36709e7f3..58b2ad7906e8 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -895,7 +895,7 @@ struct ipvs_sync_daemon_cfg {
 /* IPVS in network namespace */
 struct netns_ipvs {
 	int			gen;		/* Generation */
-	int			enable;		/* enable like nf_hooks do */
+	atomic_t	enable;		/* enable like nf_hooks do */
 	/* Hash table: for real service lookups */
 	#define IP_VS_RTAB_BITS 4
 	#define IP_VS_RTAB_SIZE (1 << IP_VS_RTAB_BITS)
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 965f3c8e5089..5c97f85929b4 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -885,7 +885,7 @@ static void ip_vs_conn_expire(struct timer_list *t)
 			 * conntrack cleanup for the net.
 			 */
 			smp_rmb();
-			if (ipvs->enable)
+			if (atomic_read(&ipvs->enable))
 				ip_vs_conn_drop_conntrack(cp);
 		}
 
@@ -1439,7 +1439,7 @@ void ip_vs_expire_nodest_conn_flush(struct netns_ipvs *ipvs)
 		cond_resched_rcu();
 
 		/* netns clean up started, abort delayed work */
-		if (!ipvs->enable)
+		if (!atomic_read(&ipvs->enable))
 			break;
 	}
 	rcu_read_unlock();
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index c7a8a08b7308..84eed2e45927 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1353,7 +1353,7 @@ ip_vs_out_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *stat
 	if (unlikely(!skb_dst(skb)))
 		return NF_ACCEPT;
 
-	if (!ipvs->enable)
+	if (!atomic_read(&ipvs->enable))
 		return NF_ACCEPT;
 
 	ip_vs_fill_iph_skb(af, skb, false, &iph);
@@ -1940,7 +1940,7 @@ ip_vs_in_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state
 		return NF_ACCEPT;
 	}
 	/* ipvs enabled in this netns ? */
-	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
+	if (unlikely(sysctl_backup_only(ipvs) || !atomic_read(&ipvs->enable)))
 		return NF_ACCEPT;
 
 	ip_vs_fill_iph_skb(af, skb, false, &iph);
@@ -2108,7 +2108,7 @@ ip_vs_forward_icmp(void *priv, struct sk_buff *skb,
 	int r;
 
 	/* ipvs enabled in this netns ? */
-	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
+	if (unlikely(sysctl_backup_only(ipvs) || !atomic_read(&ipvs->enable)))
 		return NF_ACCEPT;
 
 	if (state->pf == NFPROTO_IPV4) {
@@ -2295,7 +2295,7 @@ static int __net_init __ip_vs_init(struct net *net)
 		return -ENOMEM;
 
 	/* Hold the beast until a service is registered */
-	ipvs->enable = 0;
+	atomic_set(&ipvs->enable, 0);
 	ipvs->net = net;
 	/* Counters used for creating unique names */
 	ipvs->gen = atomic_read(&ipvs_netns_cnt);
@@ -2367,7 +2367,7 @@ static void __net_exit __ip_vs_dev_cleanup_batch(struct list_head *net_list)
 		ipvs = net_ipvs(net);
 		ip_vs_unregister_hooks(ipvs, AF_INET);
 		ip_vs_unregister_hooks(ipvs, AF_INET6);
-		ipvs->enable = 0;	/* Disable packet reception */
+		atomic_set(&ipvs->enable, 0);	/* Disable packet reception */
 		smp_wmb();
 		ip_vs_sync_net_cleanup(ipvs);
 	}
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 6a6fc4478533..ad7e1c387c1f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -256,7 +256,7 @@ static void est_reload_work_handler(struct work_struct *work)
 		struct ip_vs_est_kt_data *kd = ipvs->est_kt_arr[id];
 
 		/* netns clean up started, abort delayed work */
-		if (!ipvs->enable)
+		if (!atomic_read(&ipvs->enable))
 			goto unlock;
 		if (!kd)
 			continue;
@@ -1483,9 +1483,9 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 
 	*svc_p = svc;
 
-	if (!ipvs->enable) {
+	if (!atomic_read(&ipvs->enable)) {
 		/* Now there is a service - full throttle */
-		ipvs->enable = 1;
+		atomic_set(&ipvs->enable, 1);
 
 		/* Start estimation for first time */
 		ip_vs_est_reload_start(ipvs);
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 15049b826732..c5aa2660de92 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -231,7 +231,7 @@ static int ip_vs_estimation_kthread(void *data)
 void ip_vs_est_reload_start(struct netns_ipvs *ipvs)
 {
 	/* Ignore reloads before first service is added */
-	if (!ipvs->enable)
+	if (!atomic_read(&ipvs->enable))
 		return;
 	ip_vs_est_stopped_recalc(ipvs);
 	/* Bump the kthread configuration genid */
@@ -306,7 +306,7 @@ static int ip_vs_est_add_kthread(struct netns_ipvs *ipvs)
 	int i;
 
 	if ((unsigned long)ipvs->est_kt_count >= ipvs->est_max_threads &&
-	    ipvs->enable && ipvs->est_max_threads)
+	    atomic_read(&ipvs->enable) && ipvs->est_max_threads)
 		return -EINVAL;
 
 	mutex_lock(&ipvs->est_mutex);
@@ -343,7 +343,7 @@ static int ip_vs_est_add_kthread(struct netns_ipvs *ipvs)
 	}
 
 	/* Start kthread tasks only when services are present */
-	if (ipvs->enable && !ip_vs_est_stopped(ipvs)) {
+	if (atomic_read(&ipvs->enable) && !ip_vs_est_stopped(ipvs)) {
 		ret = ip_vs_est_kthread_start(ipvs, kd);
 		if (ret < 0)
 			goto out;
@@ -486,7 +486,7 @@ int ip_vs_start_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
 	struct ip_vs_estimator *est = &stats->est;
 	int ret;
 
-	if (!ipvs->est_max_threads && ipvs->enable)
+	if (!ipvs->est_max_threads && atomic_read(&ipvs->enable))
 		ipvs->est_max_threads = ip_vs_est_max_threads(ipvs);
 
 	est->ktid = -1;
@@ -663,7 +663,7 @@ static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max)
 			/* Wait for cpufreq frequency transition */
 			wait_event_idle_timeout(wq, kthread_should_stop(),
 						HZ / 50);
-			if (!ipvs->enable || kthread_should_stop())
+			if (!atomic_read(&ipvs->enable) || kthread_should_stop())
 				goto stop;
 		}
 
@@ -681,7 +681,7 @@ static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max)
 		rcu_read_unlock();
 		local_bh_enable();
 
-		if (!ipvs->enable || kthread_should_stop())
+		if (!atomic_read(&ipvs->enable) || kthread_should_stop())
 			goto stop;
 		cond_resched();
 
@@ -757,7 +757,7 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
 	mutex_lock(&ipvs->est_mutex);
 	for (id = 1; id < ipvs->est_kt_count; id++) {
 		/* netns clean up started, abort */
-		if (!ipvs->enable)
+		if (!atomic_read(&ipvs->enable))
 			goto unlock2;
 		kd = ipvs->est_kt_arr[id];
 		if (!kd)
@@ -787,7 +787,7 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
 	id = ipvs->est_kt_count;
 
 next_kt:
-	if (!ipvs->enable || kthread_should_stop())
+	if (!atomic_read(&ipvs->enable) || kthread_should_stop())
 		goto unlock;
 	id--;
 	if (id < 0)
-- 
2.47.3

