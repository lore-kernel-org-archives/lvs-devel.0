Received: from mail-pf1-f179.google.com (mail-pf1-f179.google.com [209.85.210.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 80D1A24886A;
	Wed, 27 Aug 2025 14:58:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.179
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1756306703; cv=none; b=j5+/Kif3j3DyiFVcArgldDggGLMl8MBCVpGc3w7+y0LpQs5ZzGf3kC9hEsAsi4RzbeTClaMaJ2cMEpXjuHy/xoay5nfEa1+/lV4aNkj939Vo+v7Dyq544Av0c95RmkrhQOUMaDQOjNyWn4rI6bq00k07DbrgEHFivEsclA3hh80=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1756306703; c=relaxed/simple;
	bh=ckxWfz1FBdft4yaVHOd+eVzD1AoKGlBbZM+qXxo97Ls=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=uxZNewEU47p/OfhETYMZ5U3i29hM7lBk0RIiqLI6QIqGw6cavDnpWpVeEoFpJFwjqlVlt6XFVvFP7PYP20kxLjvWf8SGYvto8FlRCZy/z8NQtgnDx9ahl1MAoPRtgPBvejrPk8KwJQJr0vcWTByXPPF9m0K56K32fFTYtiEAWTU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=NmvOFqy9; arc=none smtp.client-ip=209.85.210.179
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NmvOFqy9"
Received: by mail-pf1-f179.google.com with SMTP id d2e1a72fcca58-771f3f89952so901565b3a.0;
        Wed, 27 Aug 2025 07:58:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1756306701; x=1756911501; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=a6gxieyBUng5G94gfeOtxq/ZcvffE+TWMQLvYcXqjN8=;
        b=NmvOFqy9FgPehDXY/axm5UTZX1tXD/itXP9PZhV6x/tUMebMNnnO6YyTlDSpp0TmUE
         G01toSTnEu+pf+noqZDfLsh8Q+BovQC7qVJ3UVW2+MaCKCioC1EGdhZhPGnasYM8TPEP
         fsedsxv1UrEC4qisfvC+15vNhyj2LNSu/+ga+raezBgntzTX+S/TLn4ngizRMGuu76YF
         AccRW7XeRutPSX3pNesBe7e75jsFm9rChspB5zVBW13S5xqGzguhNvDHr7IvSjEt3xQt
         ktOPxnzLUlgnOcpeEfi3NHapKH5ZEqpnAnhnexy4nuIZ4+6s3110TzImV68hsko+vhfo
         64nw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1756306701; x=1756911501;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=a6gxieyBUng5G94gfeOtxq/ZcvffE+TWMQLvYcXqjN8=;
        b=NC1Iijvgt0bWZ1euW7EzXQ4EmV+eAuDQGzzHFIO67vsxTVhxu7aN9XAkd9HGEfnx7b
         kv3ZaPKA5WwxlpeiE6RZf9XjKdCe/wWUIwAYfTFtLufywCjnjpUVOum537huzc3sYDXU
         QVpN9pze9MlEIfdrL20lP2xzPgNxVZo2+oPlJ8TC8vZLQVOGMPh498TlpXDN1TZxBogr
         K6mFXCgpsVxbDVD0nhi118qTwEVUGJlESNbyLhw9pqvzqtY33WJ9/ByZHDIQP0ziMzw7
         5jALorXloq/01xUs2eGWAAGlRmoWJ5FeAXz/8eHty4fKhIOKr+jhWzmDSOlLh1DOB7Vd
         I0JA==
X-Forwarded-Encrypted: i=1; AJvYcCUz5JtuZwHUe5Sy39uEESjHVpQb07w8mvi6ve0Lu6xF9f0ip3ByO9hEFeiPzIv10OuOFND4dNIFvp/ndSaDORhW@vger.kernel.org, AJvYcCWcuqQheisUTxYpn5DH2T7lGr3agmLHC3L1mtd8QnKx4p0DEAPJc2cGLNyOcpMJR58dUCg6HdzgqEM=@vger.kernel.org
X-Gm-Message-State: AOJu0YxntPc4xvHuoAr5I1WfNGMIfQLOI3pC+ZdyEmWwozlJeKi4BEfY
	dANPoMlLHNaxjmugVjHRPq/0+A/OTDtF9kFwPuaR5+kTw0287DPJnfa8
X-Gm-Gg: ASbGncsy91Cm+UBEm6VNSIkufYlUH48/Pw60/dQiKI2DEoyINzTnz8298A26NnIKGXp
	W64nxJ8FzllLNe7d1kyIJoz6OTMRBeVOlFNZ1FIyk6Lxvb7jAfow20ztwCyiSaZPYMmEWmBP4vM
	5XhitKKfezsdFSBzW9PmlArlqt5aLE85wCp2LWhi94p8wZTb16i7FItD/eIn1V8WG/OKx/B2QKd
	MrKrDNW8wTpcEZgkpsqjPH0lAAiU9qJRecUwmFrVwh0mI6uwDSyNNAK2qT1SaTMvbdEFWXcqHbA
	W8kWacDrdDHTrz6lWMT4TnwywQz3MjO1QEnMts46I1nxZy+5BXltKykdBky5ZW/iE85Oj5jUwA5
	BYfvVihsETiTvCWHOvLvNE57iWsG/YfVKEo+PMlRr
X-Google-Smtp-Source: AGHT+IEV3VfkMhxXKfttT7vMJwOim7l0/oAS6zgZslfZOE4hBHdypQSZJzjFrn45nrefyf5xRq5RDQ==
X-Received: by 2002:a05:6a00:39a8:b0:771:1b70:2d1d with SMTP id d2e1a72fcca58-771fc296d88mr7008559b3a.6.1756306700598;
        Wed, 27 Aug 2025 07:58:20 -0700 (PDT)
Received: from DESKTOP-EOHBD4V.localdomain ([180.110.79.182])
        by smtp.gmail.com with ESMTPSA id d2e1a72fcca58-771e6535272sm8044249b3a.24.2025.08.27.07.58.15
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 27 Aug 2025 07:58:20 -0700 (PDT)
From: Zhang Tengfei <zhtfdev@gmail.com>
To: ja@ssi.bg
Cc: coreteam@netfilter.org,
	davem@davemloft.net,
	dsahern@kernel.org,
	edumazet@google.com,
	fw@strlen.de,
	horms@verge.net.au,
	kadlec@netfilter.org,
	kuba@kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	pabeni@redhat.com,
	pablo@netfilter.org,
	syzbot+1651b5234028c294c339@syzkaller.appspotmail.com,
	zhtfdev@gmail.com
Subject: 
Date: Wed, 27 Aug 2025 22:43:42 +0800
Message-Id: <20250827144337.34792-1-zhtfdev@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <2189fc62-e51e-78c9-d1de-d35b8e3657e3@ssi.bg>
References: <2189fc62-e51e-78c9-d1de-d35b8e3657e3@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi everyone,

Here is the v2 patch that incorporates the feedback.

Many thanks to Julian for his thorough review and for providing 
the detailed plan for this new version, and thanks to Florian 
and Eric for suggestions.

Subject: [PATCH v2] net/netfilter/ipvs: Use READ_ONCE/WRITE_ONCE for
 ipvs->enable

KCSAN reported a data-race on the `ipvs->enable` flag, which is
written in the control path and read concurrently from many other
contexts.

Following a suggestion by Julian, this patch fixes the race by
converting all accesses to use `WRITE_ONCE()/READ_ONCE()`.
This lightweight approach ensures atomic access and acts as a
compiler barrier, preventing unsafe optimizations where the flag
is checked in loops (e.g., in ip_vs_est.c).

Additionally, the now-obsolete `enable` checks in the fast path
hooks (`ip_vs_in_hook`, `ip_vs_out_hook`, `ip_vs_forward_icmp`)
are removed. These are unnecessary since commit 857ca89711de
("ipvs: register hooks only with services").

Reported-by: syzbot+1651b5234028c294c339@syzkaller.appspotmail.com
Closes: https://syzkaller.appspot.com/bug?extid=1651b5234028c294c339
Suggested-by: Julian Anastasov <ja@ssi.bg>
Link: https://lore.kernel.org/lvs-devel/2189fc62-e51e-78c9-d1de-d35b8e3657e3@ssi.bg/
Signed-off-by: Zhang Tengfei <zhtfdev@gmail.com>

---
v2:
- Switched from atomic_t to the suggested READ_ONCE()/WRITE_ONCE().
- Removed obsolete checks from the packet processing hooks.
- Polished commit message based on feedback.
---
 net/netfilter/ipvs/ip_vs_conn.c |  4 ++--
 net/netfilter/ipvs/ip_vs_core.c | 11 ++++-------
 net/netfilter/ipvs/ip_vs_ctl.c  |  6 +++---
 net/netfilter/ipvs/ip_vs_est.c  | 16 ++++++++--------
 4 files changed, 17 insertions(+), 20 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 965f3c8e5..37ebb0cb6 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -885,7 +885,7 @@ static void ip_vs_conn_expire(struct timer_list *t)
 			 * conntrack cleanup for the net.
 			 */
 			smp_rmb();
-			if (ipvs->enable)
+			if (READ_ONCE(ipvs->enable))
 				ip_vs_conn_drop_conntrack(cp);
 		}
 
@@ -1439,7 +1439,7 @@ void ip_vs_expire_nodest_conn_flush(struct netns_ipvs *ipvs)
 		cond_resched_rcu();
 
 		/* netns clean up started, abort delayed work */
-		if (!ipvs->enable)
+		if (!READ_ONCE(ipvs->enable))
 			break;
 	}
 	rcu_read_unlock();
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index c7a8a08b7..5ea7ab8bf 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1353,9 +1353,6 @@ ip_vs_out_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *stat
 	if (unlikely(!skb_dst(skb)))
 		return NF_ACCEPT;
 
-	if (!ipvs->enable)
-		return NF_ACCEPT;
-
 	ip_vs_fill_iph_skb(af, skb, false, &iph);
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
@@ -1940,7 +1937,7 @@ ip_vs_in_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state
 		return NF_ACCEPT;
 	}
 	/* ipvs enabled in this netns ? */
-	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
+	if (unlikely(sysctl_backup_only(ipvs)))
 		return NF_ACCEPT;
 
 	ip_vs_fill_iph_skb(af, skb, false, &iph);
@@ -2108,7 +2105,7 @@ ip_vs_forward_icmp(void *priv, struct sk_buff *skb,
 	int r;
 
 	/* ipvs enabled in this netns ? */
-	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
+	if (unlikely(sysctl_backup_only(ipvs)))
 		return NF_ACCEPT;
 
 	if (state->pf == NFPROTO_IPV4) {
@@ -2295,7 +2292,7 @@ static int __net_init __ip_vs_init(struct net *net)
 		return -ENOMEM;
 
 	/* Hold the beast until a service is registered */
-	ipvs->enable = 0;
+	WRITE_ONCE(ipvs->enable, 0);
 	ipvs->net = net;
 	/* Counters used for creating unique names */
 	ipvs->gen = atomic_read(&ipvs_netns_cnt);
@@ -2367,7 +2364,7 @@ static void __net_exit __ip_vs_dev_cleanup_batch(struct list_head *net_list)
 		ipvs = net_ipvs(net);
 		ip_vs_unregister_hooks(ipvs, AF_INET);
 		ip_vs_unregister_hooks(ipvs, AF_INET6);
-		ipvs->enable = 0;	/* Disable packet reception */
+		WRITE_ONCE(ipvs->enable, 0);	/* Disable packet reception */
 		smp_wmb();
 		ip_vs_sync_net_cleanup(ipvs);
 	}
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 6a6fc4478..4c8fa22be 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -256,7 +256,7 @@ static void est_reload_work_handler(struct work_struct *work)
 		struct ip_vs_est_kt_data *kd = ipvs->est_kt_arr[id];
 
 		/* netns clean up started, abort delayed work */
-		if (!ipvs->enable)
+		if (!READ_ONCE(ipvs->enable))
 			goto unlock;
 		if (!kd)
 			continue;
@@ -1483,9 +1483,9 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 
 	*svc_p = svc;
 
-	if (!ipvs->enable) {
+	if (!READ_ONCE(ipvs->enable)) {
 		/* Now there is a service - full throttle */
-		ipvs->enable = 1;
+		WRITE_ONCE(ipvs->enable, 1);
 
 		/* Start estimation for first time */
 		ip_vs_est_reload_start(ipvs);
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 15049b826..93a925f1e 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -231,7 +231,7 @@ static int ip_vs_estimation_kthread(void *data)
 void ip_vs_est_reload_start(struct netns_ipvs *ipvs)
 {
 	/* Ignore reloads before first service is added */
-	if (!ipvs->enable)
+	if (!READ_ONCE(ipvs->enable))
 		return;
 	ip_vs_est_stopped_recalc(ipvs);
 	/* Bump the kthread configuration genid */
@@ -306,7 +306,7 @@ static int ip_vs_est_add_kthread(struct netns_ipvs *ipvs)
 	int i;
 
 	if ((unsigned long)ipvs->est_kt_count >= ipvs->est_max_threads &&
-	    ipvs->enable && ipvs->est_max_threads)
+	    READ_ONCE(ipvs->enable) && ipvs->est_max_threads)
 		return -EINVAL;
 
 	mutex_lock(&ipvs->est_mutex);
@@ -343,7 +343,7 @@ static int ip_vs_est_add_kthread(struct netns_ipvs *ipvs)
 	}
 
 	/* Start kthread tasks only when services are present */
-	if (ipvs->enable && !ip_vs_est_stopped(ipvs)) {
+	if (READ_ONCE(ipvs->enable) && !ip_vs_est_stopped(ipvs)) {
 		ret = ip_vs_est_kthread_start(ipvs, kd);
 		if (ret < 0)
 			goto out;
@@ -486,7 +486,7 @@ int ip_vs_start_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
 	struct ip_vs_estimator *est = &stats->est;
 	int ret;
 
-	if (!ipvs->est_max_threads && ipvs->enable)
+	if (!ipvs->est_max_threads && READ_ONCE(ipvs->enable))
 		ipvs->est_max_threads = ip_vs_est_max_threads(ipvs);
 
 	est->ktid = -1;
@@ -663,7 +663,7 @@ static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max)
 			/* Wait for cpufreq frequency transition */
 			wait_event_idle_timeout(wq, kthread_should_stop(),
 						HZ / 50);
-			if (!ipvs->enable || kthread_should_stop())
+			if (!READ_ONCE(ipvs->enable) || kthread_should_stop())
 				goto stop;
 		}
 
@@ -681,7 +681,7 @@ static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max)
 		rcu_read_unlock();
 		local_bh_enable();
 
-		if (!ipvs->enable || kthread_should_stop())
+		if (!READ_ONCE(ipvs->enable) || kthread_should_stop())
 			goto stop;
 		cond_resched();
 
@@ -757,7 +757,7 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
 	mutex_lock(&ipvs->est_mutex);
 	for (id = 1; id < ipvs->est_kt_count; id++) {
 		/* netns clean up started, abort */
-		if (!ipvs->enable)
+		if (!READ_ONCE(ipvs->enable))
 			goto unlock2;
 		kd = ipvs->est_kt_arr[id];
 		if (!kd)
@@ -787,7 +787,7 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
 	id = ipvs->est_kt_count;
 
 next_kt:
-	if (!ipvs->enable || kthread_should_stop())
+	if (!READ_ONCE(ipvs->enable) || kthread_should_stop())
 		goto unlock;
 	id--;
 	if (id < 0)
-- 
2.34.1

