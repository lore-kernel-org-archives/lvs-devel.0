Received: from mail-pl1-f176.google.com (mail-pl1-f176.google.com [209.85.214.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 20F2E28DF36;
	Wed, 27 Aug 2025 22:35:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.176
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1756334145; cv=none; b=pbTWYbPQaz/CVZyTwFpDStXk0ejju5TTf7nHj1GpKbG+OEOic+CPUSYhGGmNKI7PQq3HdIFbhBvAB0AeDYRIyOYmy80Srmz8oh7BI96B/dzVyj87lu3sI7DPYRearxk4/r6aJxMc748cld1UkypUJqZkwpyrjts0UeCiMOBxGWY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1756334145; c=relaxed/simple;
	bh=Zseok7iygYibNq+XnNefzQ3eNBG1q61PZaWsFbT6Sdk=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=PVT+hqmyc4XBUmxFTMO8yszuG4BcPalv2YUr8OWTKVIGqAZFiVe/Q3Wn3pxSqgMiHjK+Npz7RQgQHEDZIxBxq0y+Qvh30dxoHHL/EbbmzM84W14Tp/XL6rrVO0DHg6hX2WBY9pg1KD/FcxE16D8F2k/rA03b+K5lMIqdiIiNZqk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=kSiIaWQp; arc=none smtp.client-ip=209.85.214.176
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kSiIaWQp"
Received: by mail-pl1-f176.google.com with SMTP id d9443c01a7336-2445826fd9dso4196015ad.3;
        Wed, 27 Aug 2025 15:35:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1756334143; x=1756938943; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=dxnVJIDK5ip9R6miI8YdyXzbPHYJLYPOHXsFv1ZHPUQ=;
        b=kSiIaWQpp8mCwVQ1H8d4WTcEj69O9E5TNwOqaZGRK26gYwUL+nUOIbxQSao8Qf6fLQ
         QWA40NWr9Ni/9VDEBTjNCDokZJvHhWz52o18/+tgMSjmFcGtShkTW/oWFwhAc8Z2CO15
         Qvlt7AHY7jTGPcduNkcnn40qEejlPHj3fyznQt9hZmIntdTfdjBII/D6Ny5yjDs207kO
         c+fNt5Y8UfjdHUefEicomofhz6r5tfib7bte+crE0HcN3iNxRJsbKm5YwcIFpcETlwMP
         BmT2RaI2BXCWVN0umuVE+zIORVE66JQ7mPKI+KmspKM3QAtJ76A3byQL7cJSAMZyuk62
         EUTg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1756334143; x=1756938943;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=dxnVJIDK5ip9R6miI8YdyXzbPHYJLYPOHXsFv1ZHPUQ=;
        b=KHs/U3KhhGPw/MUQ2MqKfiUIujGjqnKOiwAY5rU4YtAfuvzB26tkMJbdrgii/we7TL
         vR5bkwsHf7I637PrzLPstZRjf4cp2ZdHqID9IVU5b+3Fd3xvPg8zUPj+HocC7uXOnjJN
         6PWHzkS3jg2krVQpoKpUcEn2aOjO5c0ukkp6DKOiZiN50OqCu0TmYHGP/hzDMljU/kmd
         cmenDxUKT28nGUlOtfRzMr6ZOloYVh85OEMUyvno9im0lcscCARBco9B3FSJuAwiKoOH
         OQfSV8GvrTNHLPzZlBdaMkbv1ovMKlWRBnpbihtikQW1j8eJDhNs3BIwl7XQHSafufBj
         iuPw==
X-Forwarded-Encrypted: i=1; AJvYcCVQnCT3TDWSwolS+OhRjPJyWPo5U5/b+9y13OUYc1/7IdGdbVFolPewdqmF3A+FOGpu/yUz8bGMXK4=@vger.kernel.org, AJvYcCXH9/+KIsDpsMdYzd3R5u6BKeoxBPadJFFXc3KNrlfh9FckkYdMcOYN+CrzF7ugmYsmvcMwNcGQzYsXiZvSMSfa@vger.kernel.org
X-Gm-Message-State: AOJu0YwXjwKn3eWBOINFDZZNw5hIm5uNoy5qisG5cUc2ccbIaRuyVbtz
	3UANiT4cmP0obsSseP+LJGr6vGFCBWvC+0Opu+rxKClVl1xVbhztbLwE
X-Gm-Gg: ASbGncvB2z+SscwwrCpR6T2C47vvesK8+Emacws295tfHZ1QzG/7isxllLAEkpBvyQE
	RL+hP8q+sYy+rE5oErnuRN7lo3NsuozBN7/gTHnp8MKJGUz/OULCF6zIvoE16fMQucMFMbdzAEM
	zu7rj9vDs7CLzmK3NfSbDkBAHVuxRcacgakprxdCz+5hegf2QckYTA4yNPqE4VikOSEmfbCgrU7
	3QMOAWrjlf+Yf3XHRA26cvGkAbt3agfA7bSA3pkUV8NQ4B2GWDPkKPtlC+Z3WTsLuHGa916BLsM
	p8xOe1xpmnHSQGeSvSQ9aj7SKCAhzhnxtjru5bw/SqSF2QRxfQ2z7lVvGBhBHtjQ4BdQIRibY8d
	IXaHIogJ6GHvls9MneGSL6esYDvLQgu5uYSMH0o+x
X-Google-Smtp-Source: AGHT+IE3TAUTFlqh80IWoy2e0V97RtWKqlhpWobYI1MSTHXUgZKEsaDwpSr1+mn4JaFuJf2wKzOiOA==
X-Received: by 2002:a17:902:e847:b0:246:e621:96f2 with SMTP id d9443c01a7336-246e621a7f1mr149122855ad.31.1756334143212;
        Wed, 27 Aug 2025 15:35:43 -0700 (PDT)
Received: from DESKTOP-EOHBD4V.localdomain ([180.110.79.182])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3276f57b23dsm3033187a91.1.2025.08.27.15.35.39
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 27 Aug 2025 15:35:42 -0700 (PDT)
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
Subject: [PATCH v2] net/netfilter/ipvs: Use READ_ONCE/WRITE_ONCE for ipvs->enable
Date: Thu, 28 Aug 2025 06:33:23 +0800
Message-Id: <20250827223322.4896-1-zhtfdev@gmail.com>
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

KCSAN reported a data-race on the `ipvs->enable` flag, which is
written in the control path and read concurrently from many other
contexts.

Following a suggestion by Julian, this patch fixes the race by
converting all accesses to use `WRITE_ONCE()/READ_ONCE()`.
This lightweight approach ensures atomic access and acts as a
compiler barrier, preventing unsafe optimizations where the flag
is checked in loops (e.g., in ip_vs_est.c).

Additionally, the `enable` checks in the fast-path hooks
(`ip_vs_in_hook`, `ip_vs_out_hook`, `ip_vs_forward_icmp`) are
removed. They are considered unnecessary because the `enable=0`
condition they check for can only occur in two rare and non-fatal
scenarios: 1) after hooks are registered but before the flag is set,
and 2) after hooks are unregistered on cleanup_net. In the worst
case, a single packet might be mishandled (e.g., dropped), which
does not lead to a system crash or data corruption. Adding a check
in the performance-critical fast-path to handle this harmless
condition is not a worthwhile trade-off.

Reported-by: syzbot+1651b5234028c294c339@syzkaller.appspotmail.com
Closes: https://syzkaller.appspot.com/bug?extid=1651b5234028c294c339
Suggested-by: Julian Anastasov <ja@ssi.bg>
Link: https://lore.kernel.org/lvs-devel/2189fc62-e51e-78c9-d1de-d35b8e3657e3@ssi.bg/
Signed-off-by: Zhang Tengfei <zhtfdev@gmail.com>

---
v2:
- Switched from atomic_t to the suggested READ_ONCE()/WRITE_ONCE().
- Removed obsolete checks from the packet processing hooks.
- Polished commit message based on feedback from maintainers.
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

