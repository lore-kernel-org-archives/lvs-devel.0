Received: from smtp-relay-internal-1.canonical.com (smtp-relay-internal-1.canonical.com [185.125.188.123])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 53FEE1591FF
	for <lvs-devel@vger.kernel.org>; Thu, 18 Apr 2024 11:09:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=185.125.188.123
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1713438565; cv=none; b=N9izu2weBcZHPWYYm0vrRF5ucT5K6ljPazOJwe3vsbUR45ppSQQb579ut2PkQTsdsEP8xy/zz4fMcfSwmjm7EO46fjdlGpc3W0qn1hUcHPf9OE0CzEL2n6x7lBvFViPGV3bIYmBo6c4issEF5yMxdpAl2i6SqkYVpA4TTSd+UYY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1713438565; c=relaxed/simple;
	bh=aWz5Gig2xv2dqOzuJfPq1HgDbmDRmwb4+kS753Y/Y7o=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version:Content-Type; b=i33U9N1E3fw4PCwLDao+tr83mII0ebiSsIa8Da7+tVef1tFGX2wpTnLtKeBkaZCxRsfFzOANsg2YPgfhxtWf6EP/gJYLI2H8tZB/3cVDJQiolQhtWn5/mM0LtkSCRtrBBL1HpaqxOMk9IUqDcCGHVbC4er0UTxkCV5J1q0qCf5o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=canonical.com; spf=pass smtp.mailfrom=canonical.com; dkim=pass (2048-bit key) header.d=canonical.com header.i=@canonical.com header.b=YPa1yuy6; arc=none smtp.client-ip=185.125.188.123
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=canonical.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=canonical.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=canonical.com header.i=@canonical.com header.b="YPa1yuy6"
Received: from mail-ej1-f70.google.com (mail-ej1-f70.google.com [209.85.218.70])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-relay-internal-1.canonical.com (Postfix) with ESMTPS id A37153F36F
	for <lvs-devel@vger.kernel.org>; Thu, 18 Apr 2024 11:02:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=canonical.com;
	s=20210705; t=1713438128;
	bh=ktW00F9DIAhL7DS4TlvR8U57g+A/C2nEvJUjlW8cwMw=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version:Content-Type;
	b=YPa1yuy6jHLMmT5EM9hdKB5AvKvfEOHSKuAj5E7jV/uMds7RbV07k+i6G1So6Ogbq
	 urxCNbhHAa0P+IMRNG1s19LCKEKLuLJ+U+ZdNM2OwlvdZuDBJ1pxwE7i8KczfaeifT
	 V+6a2U68AMBqWn8kg0AwPNgrELPxcxf05LwwvjnUV/pX51M5/i9+aNXrizrTVFNsR7
	 Ae6NmVvlCmJzBvrxSg6FvsCym6Xen8iiWjrJ/RoU7RqB8Gzlenmwuibk9ZhYF6qfEj
	 CPPHVYJ8YJ9+u0gYMQCaMyLeRmQPVfIkacZqq3lDNht7t+T3C9q0wGpOrIG8BvJ9na
	 dXu5zdQsoHoEg==
Received: by mail-ej1-f70.google.com with SMTP id a640c23a62f3a-a5238ca77adso200503066b.1
        for <lvs-devel@vger.kernel.org>; Thu, 18 Apr 2024 04:02:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1713438128; x=1714042928;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=ktW00F9DIAhL7DS4TlvR8U57g+A/C2nEvJUjlW8cwMw=;
        b=HQ87G/SqT+BZgUKL7ao/rHOemp4g6l5TJKQ2dxykAWl82fZj/6aUzqy+rptDjQ8xI8
         uknUlo4nEM+IIUZjhtE79mW2mAwa0w3tY96rXtPaERDxytBUyc8DMHvmrTumk5XV3wHh
         f/2gVE3bWE7nHriYtAOATXa/OZX9J8XHR/T33HN9SyUGv3TXqQEPytNarGlpy32swDbk
         BcN2qnWOKDXPY4jtLhknHxkFKXC6z0t5uGrAhfElR3PrF2BxoAisF4y5rtr798phjtun
         OXH9YC99rogjmZ0os15C0fN2N89wv3XNNqjNA04qjOSNTE+ZF42H97PyxYUfP45MnrbQ
         X2nA==
X-Forwarded-Encrypted: i=1; AJvYcCWUsr6glBWP/tz8hI3plVVW0nO0mWKUaGOXHiB7TPLVB1U97IGE7i65U+WLvOmtAAjVcwWVnERiGUiVzmywvPcdjVatJibZnxo9
X-Gm-Message-State: AOJu0Yw71q3Vjn5knRecHZ1N6w+hORufXJJ/Q6KR0qSja3Hpp5gIdZbB
	EQiABpV311sadg+0Y4MATBJunvzHSCPOyK44K27909197TrDZSus3s5+w84r+1bHU3P2cvSZs7s
	Tg2FJ6C9ZCLC2wNBv90iWbkHrThiBo8OLonI/nSE1U1j3NM1QutPAz6nRWMqDPe38Q0T0ywzDBg
	==
X-Received: by 2002:a17:907:9447:b0:a52:30d4:20e6 with SMTP id dl7-20020a170907944700b00a5230d420e6mr1974025ejc.10.1713438128372;
        Thu, 18 Apr 2024 04:02:08 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IEv+5q9kt1eWZoXNQEPQAWf0LPsfHN7n2d9j+DQUT0Ja9+xBCd4zGciLDlc/mEh9WbiEhFr4w==
X-Received: by 2002:a17:907:9447:b0:a52:30d4:20e6 with SMTP id dl7-20020a170907944700b00a5230d420e6mr1974004ejc.10.1713438128069;
        Thu, 18 Apr 2024 04:02:08 -0700 (PDT)
Received: from amikhalitsyn.lan ([2001:470:6d:781:320c:9c91:fb97:fbfc])
        by smtp.gmail.com with ESMTPSA id yk18-20020a17090770d200b00a51983e6190sm728594ejb.205.2024.04.18.04.02.06
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 18 Apr 2024 04:02:07 -0700 (PDT)
From: Alexander Mikhalitsyn <aleksandr.mikhalitsyn@canonical.com>
To: horms@verge.net.au
Cc: netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexander Mikhalitsyn <aleksandr.mikhalitsyn@canonical.com>,
	=?UTF-8?q?St=C3=A9phane=20Graber?= <stgraber@stgraber.org>,
	Christian Brauner <brauner@kernel.org>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@netfilter.org>,
	Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next v2 2/2] ipvs: allow some sysctls in non-init user namespaces
Date: Thu, 18 Apr 2024 13:01:53 +0200
Message-Id: <20240418110153.102781-2-aleksandr.mikhalitsyn@canonical.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20240418110153.102781-1-aleksandr.mikhalitsyn@canonical.com>
References: <20240418110153.102781-1-aleksandr.mikhalitsyn@canonical.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Let's make all IPVS sysctls writtable even when
network namespace is owned by non-initial user namespace.

Let's make a few sysctls to be read-only for non-privileged users:
- sync_qlen_max
- sync_sock_size
- run_estimation
- est_cpulist
- est_nice

I'm trying to be conservative with this to prevent
introducing any security issues in there. Maybe,
we can allow more sysctls to be writable, but let's
do this on-demand and when we see real use-case.

This patch is motivated by user request in the LXC
project [1]. Having this can help with running some
Kubernetes [2] or Docker Swarm [3] workloads inside the system
containers.

[1] https://github.com/lxc/lxc/issues/4278
[2] https://github.com/kubernetes/kubernetes/blob/b722d017a34b300a2284b890448e5a605f21d01e/pkg/proxy/ipvs/proxier.go#L103
[3] https://github.com/moby/libnetwork/blob/3797618f9a38372e8107d8c06f6ae199e1133ae8/osl/namespace_linux.go#L682

Cc: Stéphane Graber <stgraber@stgraber.org>
Cc: Christian Brauner <brauner@kernel.org>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Jozsef Kadlecsik <kadlec@netfilter.org>
Cc: Florian Westphal <fw@strlen.de>
Signed-off-by: Alexander Mikhalitsyn <aleksandr.mikhalitsyn@canonical.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index daa62b8b2dd1..f84f091626ef 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -4272,6 +4272,7 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 	struct ctl_table *tbl;
 	int idx, ret;
 	size_t ctl_table_size = ARRAY_SIZE(vs_vars);
+	bool unpriv = net->user_ns != &init_user_ns;
 
 	atomic_set(&ipvs->dropentry, 0);
 	spin_lock_init(&ipvs->dropentry_lock);
@@ -4286,12 +4287,6 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 		tbl = kmemdup(vs_vars, sizeof(vs_vars), GFP_KERNEL);
 		if (tbl == NULL)
 			return -ENOMEM;
-
-		/* Don't export sysctls to unprivileged users */
-		if (net->user_ns != &init_user_ns) {
-			tbl[0].procname = NULL;
-			ctl_table_size = 0;
-		}
 	} else
 		tbl = vs_vars;
 	/* Initialize sysctl defaults */
@@ -4317,10 +4312,17 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 	ipvs->sysctl_sync_ports = 1;
 	tbl[idx++].data = &ipvs->sysctl_sync_ports;
 	tbl[idx++].data = &ipvs->sysctl_sync_persist_mode;
+
 	ipvs->sysctl_sync_qlen_max = nr_free_buffer_pages() / 32;
+	if (unpriv)
+		tbl[idx].mode = 0444;
 	tbl[idx++].data = &ipvs->sysctl_sync_qlen_max;
+
 	ipvs->sysctl_sync_sock_size = 0;
+	if (unpriv)
+		tbl[idx].mode = 0444;
 	tbl[idx++].data = &ipvs->sysctl_sync_sock_size;
+
 	tbl[idx++].data = &ipvs->sysctl_cache_bypass;
 	tbl[idx++].data = &ipvs->sysctl_expire_nodest_conn;
 	tbl[idx++].data = &ipvs->sysctl_sloppy_tcp;
@@ -4343,15 +4345,22 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 	tbl[idx++].data = &ipvs->sysctl_conn_reuse_mode;
 	tbl[idx++].data = &ipvs->sysctl_schedule_icmp;
 	tbl[idx++].data = &ipvs->sysctl_ignore_tunneled;
+
 	ipvs->sysctl_run_estimation = 1;
+	if (unpriv)
+		tbl[idx].mode = 0444;
 	tbl[idx].extra2 = ipvs;
 	tbl[idx++].data = &ipvs->sysctl_run_estimation;
 
 	ipvs->est_cpulist_valid = 0;
+	if (unpriv)
+		tbl[idx].mode = 0444;
 	tbl[idx].extra2 = ipvs;
 	tbl[idx++].data = &ipvs->sysctl_est_cpulist;
 
 	ipvs->sysctl_est_nice = IPVS_EST_NICE;
+	if (unpriv)
+		tbl[idx].mode = 0444;
 	tbl[idx].extra2 = ipvs;
 	tbl[idx++].data = &ipvs->sysctl_est_nice;
 
-- 
2.34.1

