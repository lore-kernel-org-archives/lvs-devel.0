Received: from mail-pl1-f182.google.com (mail-pl1-f182.google.com [209.85.214.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BA6063D994;
	Mon,  1 Sep 2025 13:47:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1756734454; cv=none; b=bYgjpzJxrBsv3P3yic9iMmXU1HPLqEJpSXESETl4YzrXdSfoj/zTDNqs0QRpdU8Fv7lg5XjkLiMSCdbISnvnoigOLSThllpuKJAX0iKooFTMPy2eWV2baZP2a+Yc4CABNB/JnmSYvpHQ3okXRpBoP+nFy+IZelGI47p7kVG0Dzk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1756734454; c=relaxed/simple;
	bh=Ltqzli40U6bcR60lC6sFadREzNshVpFGu9u3HID3kdY=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=SJOPSH9KVdcXwsUAvUs6WynYn1yGhcMZKgwOsMyiHH881c2Tcr8fWvFO08u2JlVqA6b7Pm0NkLHUooXg4YSDz8n4idFayKYQV1jNkraxe2lAI/HjGiIHxe2mNt9YrtH8Xt5QX9c5qvavcMMXTggIXIWgjRwfvYs1vQDSUY1tYYE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=lCLfxRja; arc=none smtp.client-ip=209.85.214.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lCLfxRja"
Received: by mail-pl1-f182.google.com with SMTP id d9443c01a7336-24a1274cfb1so11607965ad.2;
        Mon, 01 Sep 2025 06:47:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1756734452; x=1757339252; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=AKQIpAzh63C4DGZVZbgWp4xGHX77D7MzrkqQF4dklFM=;
        b=lCLfxRjazuUsdA0VeTpatPZ2OU5Jdp6QZnx7hqctunT9NFBE/qPqiUvDjsEvkdH2lu
         NyjgoONQLf8GJtrMheVA2sDWK220Gv3C1vFSsK6MewXLyyk51hFWhkqz6/UrYKn0/iH8
         I3iZXiUiwvZj9pHIv43a64vxLdfaUH0+yjt0VNjWQ9+SuSMiXaG0jNjcvu0kkJaq8T4j
         EBjhLhL1tJc5241iwA8vIhp385dbkJ4wC4qDuDdZcSIgiEcuM8x2yA4AiBrkGaPAobE/
         HG9vPgtQI0wWY1Ir2zPx4JpipSDqbW/3pKHSNrWHiTRFMgBf+QELb0R04kogbMlFt4rX
         4Uaw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1756734452; x=1757339252;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=AKQIpAzh63C4DGZVZbgWp4xGHX77D7MzrkqQF4dklFM=;
        b=UIQDP2wuXag73nZcSF/zU9+w2c2w7tPrUTHo2MFHy1/nFopeORllaq1lxeJVXei+1T
         kf5Pyw78YV9kargkNOaF9dkAEXMk7iJQg6B3032T3qS1noG7+6xP/CS6oP+8cqwG5JO3
         F5JJb01AqrMcWQq81DoqRpSqwPQixQ3fIgqSDmuw3CvCvUipQtyoAeNd7n1mztrKJTu5
         A6sdWtpOoLyIkHuNbenHvb9iVl6pbd7Sn6PNYp4GkUkk0LyyJkuGCa4VxZJ62SMhBW2Y
         C6XK0fZfHlTFvjlQNk2M8s5UsY5/08QApPKkZybdkvgx85BDbmYarhy+SjpusLx00LAK
         X43Q==
X-Forwarded-Encrypted: i=1; AJvYcCUakv7UaztYSMC/+fI+YPI7zOXsbGbzWpuQU2MYFG48MRDGhxcAl43D2C64aNkegQy1hJokDEmuoZQ=@vger.kernel.org, AJvYcCWQFvIYraWB6KRaUGLz5DSQHqTkGdFfZxrvzdYy05BYjouJf2pWUNCqw0eYLQyV+eZI9pTBatBxyIIRH3v+foSe@vger.kernel.org
X-Gm-Message-State: AOJu0Ywtfq9deV3BEfP/o8zNpaZa+oci/sfwALLW+k2kq3QzBf8XRyAY
	dJke2jepncHYAwAcRfq+dOZ2ZyI7KS1y9NpwNFUcaSkjQwcWqFQtVjtj
X-Gm-Gg: ASbGncvElWpA9AU3du13o0U36stKwYgLpldkEfQYjclzJ5ZpWPrCQX3kQre5Pvh1Mrc
	HgwWmx6UCipQIcAIUSr96AbYHjz4tM77KI7RyTSNC83Y3WIXCXtJHBl30VuIHDRqOM75bxtWv2j
	4qnQTElGDvTSaF61ZF3T7BQuXqBXy377c+Ch7hnf/Zf8//QXe3TDeJF7IbXCFT4qRv5ipVN3fCZ
	/jvd75dXMK4zypXMtjknz4q3W3F2HioEs26p8cL8JlkXP+/bCp4EP1fGB0VIvCDcYpLtfvCxB3n
	ZryPgrCNBN00rpHitRTq8kLddGcGMYOxKl9ZV7LG4w5tezHeQJuYLHSSCFTawdWjkuS4tDzHofG
	gP8zo2eaPNhXdr0AC+BGWFK/AIKVcATgg8hIuAB0sAMc6povcBlWHM3ZDlqqRmrj/NavO292FiX
	Do6sYw6y5PRU6z2f9FgIA=
X-Google-Smtp-Source: AGHT+IGkIIv/ohKjKzeBeeE2KELu8ZH2b0FroogJiuLniH9VSWiID2VkMbD400ngrpIitDM52Jf1zg==
X-Received: by 2002:a17:903:8c8:b0:24b:25f:5f81 with SMTP id d9443c01a7336-24b025f6800mr4478745ad.17.1756734451761;
        Mon, 01 Sep 2025 06:47:31 -0700 (PDT)
Received: from DESKTOP-EOHBD4V.localdomain (66-175-223-235.ip.linodeusercontent.com. [66.175.223.235])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3276f5961e4sm16896367a91.11.2025.09.01.06.47.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 01 Sep 2025 06:47:31 -0700 (PDT)
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
Subject: [PATCH v3 nf-next] ipvs: Use READ_ONCE/WRITE_ONCE for ipvs->enable
Date: Mon,  1 Sep 2025 21:46:54 +0800
Message-Id: <20250901134653.1308-1-zhtfdev@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <3a737b68-5a80-845d-ff36-6a1926b792a0@ssi.bg>
References: <3a737b68-5a80-845d-ff36-6a1926b792a0@ssi.bg>
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
removed. These are unnecessary since commit 857ca89711de
("ipvs: register hooks only with services"). The `enable=0`
condition they check for can only occur in two rare and non-fatal
scenarios: 1) after hooks are registered but before the flag is set,
and 2) after hooks are unregistered on cleanup_net. In the worst
case, a single packet might be mishandled (e.g., dropped), which
does not lead to a system crash or data corruption. Adding a check
in the performance-critical fast-path to handle this harmless
condition is not a worthwhile trade-off.

Fixes: 857ca89711de ("ipvs: register hooks only with services")
Reported-by: syzbot+1651b5234028c294c339@syzkaller.appspotmail.com
Closes: https://syzkaller.appspot.com/bug?extid=1651b5234028c294c339
Suggested-by: Julian Anastasov <ja@ssi.bg>
Link: https://lore.kernel.org/lvs-devel/2189fc62-e51e-78c9-d1de-d35b8e3657e3@ssi.bg/
Signed-off-by: Zhang Tengfei <zhtfdev@gmail.com>
---
v3:
- Restore reference to commit 857ca89711de in commit message.
- Add corresponding Fixes tag.
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
index 965f3c8e508..37ebb0cb62b 100644
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
index c7a8a08b730..5ea7ab8bf4d 100644
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
index 6a6fc447853..4c8fa22be88 100644
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
index 15049b82673..93a925f1ed9 100644
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

