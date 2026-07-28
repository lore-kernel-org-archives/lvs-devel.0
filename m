Received: from mail-qv1-f43.google.com (mail-qv1-f43.google.com [209.85.219.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 35F2D3A2E2B
	for <lvs-devel@vger.kernel.org>; Tue, 28 Jul 2026 04:21:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.219.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785212504; cv=none; b=i/0S9hTrnUYfOVX3MWgE17fp17xBNg+IBrWsEidzmrB1f2D04lswe38SX4vo04pM1lgbBwBT4iCsNc4I/YKn3h+BiGsLt8YEXxWb0niwwr8woe0j1J6uhfpE6WoRZXmpXSPDtJ2n3u6Gav6DQDkGo21JROqWpJzjUr/WbuEy660=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785212504; c=relaxed/simple;
	bh=z9YDVT9dO7eY3oONRZrnB8Un+kTHwUZmgKWSt69DsFU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=FXOtzCwu2xL29g+vDc5SR7Nk3TnNDm67Qqjx+7pn6/Ee0PfgDGwDEYOHl3n+VqRHE4iZLIp9eKhb/O9KAmPvYIvYpSgzCVAeO3L90YEtMSnrxy/rN8cC46pVVIIYKaNhGYV07TONXb+FxuFbar5/QnHLzWatgupEWuSZ3kfUq78=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b=XgHKgA97; arc=none smtp.client-ip=209.85.219.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b="XgHKgA97"
Received: by mail-qv1-f43.google.com with SMTP id 6a1803df08f44-8f256eaedf8so35624036d6.2
        for <lvs-devel@vger.kernel.org>; Mon, 27 Jul 2026 21:21:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1785212500; x=1785817300; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=wIfReckQIvU7mcolyJLQK/Nsuz3ePy+9i+ZRkaCU5Kc=;
        b=XgHKgA97fDN3gSBgJZa41SvzwmhSb3izPkMpnopAJI474//YQz0Gv9uTw0J6qxoCdC
         iC1Wb+4BdSH8PKh/dH3Uaj31Q5TW8QE29JL8PFr6fRk+XsrnvA5zKcQeoOjCjkzyQ+Yt
         fixb0bHy5NyFmAFQs17slmV7F4U1X0JGgMAQ8qVToCUPYnlNd87Z69v8W3rnk1SUigoy
         q3KzQmEt3Jgrnv6Le7YezTzDLjxmPbKKUrzEqmkgrFQXZNTU4bn3QBQmB6xmIpAJFpyc
         2T1PvCm5jbzbxPGdllMUL4jPvNTFiUh1tqLk0nCkNfroYWCP+iOYvdlzTqQ5cdIMYqw4
         IgYA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785212500; x=1785817300;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=wIfReckQIvU7mcolyJLQK/Nsuz3ePy+9i+ZRkaCU5Kc=;
        b=kzmWFYTd4yeadHj7kVwr7zxjiqxCpJr9mYr39hsatJDdzxkn7s27Jd8q3/pP0WobtL
         KzdIMfgcXXM9oL+oUiSKYwwzUJvd9sY7XD3ROgMRfIWb9k8CywTzILuK6faT6dlGsTXF
         Y9NlHexUaHfrjxj0g0nwuUNt3L7S340wx+ooYFtMbWEoMzD0ivtZKDQ5HuDg8XpddXJU
         vqPV3kPc4B5zex2CmoYgfawZMn4LnMoORiLxcmLuSGUeOAAVHyz0e0lknJi9gAacDzxD
         JihvdGFBU4HowiOJ6u2OKBRRr7MHskoCdzJdIfSMkgIiwZmpxrqnoeKGJIeQS5HnGXo0
         Koxg==
X-Forwarded-Encrypted: i=1; AHgh+RqBd0pvXs4fhoaEG8aJQwCEHvdWqRE+5/OI8NR18D01u7n7HghN9NdWLB/rmBLwPtUwC+O6mlGLl3I=@vger.kernel.org
X-Gm-Message-State: AOJu0YwEbw8bkA8eD2ELanrZSBKXNpcPsuAO6SXo3/RlHU3dkVuKG1fL
	/gkscDE8v0rktJUBbsb/xpDvs8a8pECW4XECqZf0GsS1MQMIzLzSIFJPZ1rNZi8az2N3
X-Gm-Gg: AR+sD10AiHJ2ib0f8gucB3YK7iviby+Ycxp56X6x3jS/BsI4BXPwQcYWckH1f1dfy/F
	op2UDq1LpimsOV9dwn+4kx4ReXg1lNIBHDeNaLeFcKWFoVpZ41kGlLsipzppTmY0Mqpe4BWGkwV
	dQ8LZ2QUGwSmvsWLiuYuPn7opUBh+gMtnFvirHe5nvTM6mgYnFag8RyIBPN0hs126glY04NZbyH
	VMa/bfyVCArbn/ZDFJUcnu4h3IYv5cJbcTZw04GLFgc0R3CWkFCMQHeQl+7CvgwcOq3KSblCyMc
	tW+COKzwDovKKK6rxlRY+f8gfe9WP3syXpWKZqsHyh3s8f6kkf/7ZkTbQJqPO8gPob68E6gglcI
	Rl/hSy+xEfvDkk2MOhewen4JpzFgL0jJpP/LT3f+rnuIbHOrzm1CQXgS/6jswh+SJvWLcXAMb5P
	Wo4vcXQeN+A8tNQRpVCg==
X-Received: by 2002:ad4:5e8b:0:b0:8fd:6e32:2bff with SMTP id 6a1803df08f44-908173a13fcmr7841726d6.64.1785212499622;
        Mon, 27 Jul 2026 21:21:39 -0700 (PDT)
Received: from Roxy.localdomain ([203.175.14.58])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-907e86d499dsm79520786d6.42.2026.07.27.21.21.36
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 27 Jul 2026 21:21:39 -0700 (PDT)
From: Zhiling Zou <zhilinz@nebusec.ai>
To: ja@ssi.bg,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Cc: horms@verge.net.au,
	pablo@netfilter.org,
	fw@strlen.de,
	phil@nwl.cc,
	jwiesner@suse.de,
	vega@nebusec.ai,
	zhilinz@nebusec.ai
Subject: [PATCH nf v2 1/1] ipvs: stop estimator after disabled calc phase
Date: Tue, 28 Jul 2026 12:21:28 +0800
Message-ID: <03a7ee4873f9dfc51add97df5b67bf0b0d793dbe.1785211268.git.zhilinz@nebusec.ai>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

IPVS estimator kthread 0 starts with zeroed chain and tick limits until
its initial calculation phase completes. If network namespace teardown
clears ipvs->enable during that phase, ip_vs_est_calc_phase() can return
without installing positive limits.

The kthread can then continue into its main loop and drain
est_temp_list with zero chain_max, tick_max and est_max_count values.
Each enqueue consumes one available tick row, but est_count never
reaches the zero est_max_count value. After all rows are consumed, the
row lookup returns IPVS_EST_NTICKS and ip_vs_enqueue_estimator() writes
past the ticks and tick_len arrays.

Exit kthread 0 after the calculation phase if the kthread is stopping or
IPVS has been disabled. That keeps temporary estimators from being
drained after the limits failed to initialize.

Fixes: 705dd3444081 ("ipvs: use kthreads for stats estimation")
Cc: stable@vger.kernel.org
Reported-by: Vega <vega@nebusec.ai>
Signed-off-by: Zhiling Zou <zhilinz@nebusec.ai>
---
changes in v2:
- Exit the estimator kthread after the calculation phase if IPVS
  has been disabled or the kthread is stopping, as suggested by
  Julian Anastasov.
- Drop the later enqueue and drain guards from v1.
- v1 Link: https://lore.kernel.org/all/6359e0031f0ee7cc969bae3483308de362d3c709.1784878022.git.zhilinz@nebusec.ai

 net/netfilter/ipvs/ip_vs_est.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index ab09f51829512..86d20f19fe317 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -191,8 +191,11 @@ static int ip_vs_estimation_kthread(void *data)
 		}
 
 		/* kthread 0 will handle the calc phase */
-		if (ipvs->est_calc_phase)
+		if (ipvs->est_calc_phase) {
 			ip_vs_est_calc_phase(ipvs);
+			if (kthread_should_stop() || !READ_ONCE(ipvs->enable))
+				return 0;
+		}
 	}
 
 	while (1) {
-- 
2.43.0

