Received: from smtp-relay-internal-1.canonical.com (smtp-relay-internal-1.canonical.com [185.125.188.123])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5CD9F13CFAA
	for <lvs-devel@vger.kernel.org>; Mon,  6 May 2024 14:15:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=185.125.188.123
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1715004914; cv=none; b=uQfnMazRHHwWxWfHTufIZcg3Rh4AriRJcy5elyIF900a1dyH8xNWqP8pO32Iy6Nx9LTXAV3kYFxIawPA9R8iMMmmiJ+XSS111WGrPaghQKZxDdD0LodpR1pqjpqfut8iUV44g5wpEaP2X9jlsDXUAX/8BSunDTzYtzJ72oLDIkE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1715004914; c=relaxed/simple;
	bh=+Z/Lsq8TfQLRqsZxO6NPI1XpawG5p6DBMinswkhWeM8=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=tnQIGV3l7/DD8zX0Jmdem/48PfWciukACYS2o2kfMHkRYS7bvJy0/FzD8UMxWGdSKe7kCAmWFzn+VylHL7W2SZdyuc3guSwuWpkvjDOi2kpQZXv/uplsn+DxQcaLws+tMfG6Fm9aXTuBHD2TZBYmcdXybhS+soBkEUyLNPxpSV4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=canonical.com; spf=pass smtp.mailfrom=canonical.com; dkim=pass (2048-bit key) header.d=canonical.com header.i=@canonical.com header.b=qL5ZwHPB; arc=none smtp.client-ip=185.125.188.123
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=canonical.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=canonical.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=canonical.com header.i=@canonical.com header.b="qL5ZwHPB"
Received: from mail-ej1-f69.google.com (mail-ej1-f69.google.com [209.85.218.69])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-relay-internal-1.canonical.com (Postfix) with ESMTPS id C02773FE63
	for <lvs-devel@vger.kernel.org>; Mon,  6 May 2024 14:15:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=canonical.com;
	s=20210705; t=1715004904;
	bh=OqRb1xOZql2PU0k7U3099kOtm3MQu6nOgdSdRzcue2o=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version;
	b=qL5ZwHPBaaZ1otsmBSwNF8zaxbfLaWgEtRl05ARh2pH1G0Kg8Uv88S+dF/LgZHVSa
	 AC4biBkAvJ9rTETEPtp9UV9qp8K8sHddUNQbYUKR43BNwwlvexFcY8/Mno4IkN0jis
	 BtJmDJ8gokeoEgCV14EDTJUJafLI0tjcgTM9QsVPeAoPR8d3tKxLU8sqY4e4I4LrlG
	 /288krH1zdbXgJs+M5mHjDa0i7MEMvpB6Fjel+w2sAvBiCA5oMcAxzhs2lndvI1cUt
	 BfOYhpT9JYgjyNahclZgH0UHW9vOLJSFIFEUniV8GRb7lXT/yd/Ihc9fTbCuMsmVSi
	 xtXSCtjhMYJeA==
Received: by mail-ej1-f69.google.com with SMTP id a640c23a62f3a-a59a18de270so111589066b.3
        for <lvs-devel@vger.kernel.org>; Mon, 06 May 2024 07:15:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1715004897; x=1715609697;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=OqRb1xOZql2PU0k7U3099kOtm3MQu6nOgdSdRzcue2o=;
        b=pZxiYLwlbaQTNwWs25UKnJpYBIa2Kw384xlpXxn1y6NUz8d68QmHNX8XcyE8E6Glfy
         HG6PiLuh+oDupHNiEqyUuZ2NEc7s+KyL4CMKLshtjYusoKt3gn26IMFQodNLqZLQalPY
         WI4K4VqjhX1PcxvoOjXLDXLm4sEH245CFWjahBpEuvVB4TTiN03dH0NcnFqEcDbjiocn
         u7wier/yfWSfXlYWRjhslD3uDrpOkaW5/9Ha/k4YRzi7xvjwzjeWhPcGunC3Az7H3ws8
         jwaH/Brx0Lm1Fc8GmFjIwyRu7gCrXH6j6udwsLKby9258yBZMB4D0FPkmwryE43+ZJe1
         XegQ==
X-Forwarded-Encrypted: i=1; AJvYcCXFsnknYvfWYLK0IeSvwH8rzpGRtz7LsF9+etn1kNpJ2GRWAxjCK7MGWGKD3fKIfBGjhOEsaGs71PelJiTCUCdTEZEI2LY0Mnbd
X-Gm-Message-State: AOJu0YyqpFVh0rKputpKtIeJ6+e2/VGTSJFfAljO/E3fDE4Imb/abk0Q
	wIncowWDxt6XeWaNkkpSD2Q0xuKVw4Vw85o+qNzDPkPuMEZD+fP4EDbH2QqQrgfpE/Fg21TFwQT
	eLkUNE0Am0KDks9MvaWJOYHPHMYLvTaZBn+8l3W1yB2y6IQijyTrVfOyjaAMFkHiD7VgpMN1YmQ
	==
X-Received: by 2002:a17:906:6a1b:b0:a59:ba18:2fb9 with SMTP id qw27-20020a1709066a1b00b00a59ba182fb9mr3733804ejc.12.1715004897350;
        Mon, 06 May 2024 07:14:57 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IHa1Vw6hfo0afKISW9+EzWZA3flJUxebMlVAlpg8F9CpQGamqKcFf6weBYpMVMzl1sqbbZYOA==
X-Received: by 2002:a17:906:6a1b:b0:a59:ba18:2fb9 with SMTP id qw27-20020a1709066a1b00b00a59ba182fb9mr3733786ejc.12.1715004897093;
        Mon, 06 May 2024 07:14:57 -0700 (PDT)
Received: from amikhalitsyn.lan ([2001:470:6d:781:4703:a034:4f89:f1de])
        by smtp.gmail.com with ESMTPSA id xh9-20020a170906da8900b00a597ff2fc0dsm4663754ejb.69.2024.05.06.07.14.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 06 May 2024 07:14:56 -0700 (PDT)
From: Alexander Mikhalitsyn <aleksandr.mikhalitsyn@canonical.com>
To: horms@verge.net.au
Cc: netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexander Mikhalitsyn <aleksandr.mikhalitsyn@canonical.com>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@netfilter.org>,
	Florian Westphal <fw@strlen.de>
Subject: [PATCH v4 2/2] ipvs: allow some sysctls in non-init user namespaces
Date: Mon,  6 May 2024 16:14:44 +0200
Message-Id: <20240506141444.145946-2-aleksandr.mikhalitsyn@canonical.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20240506141444.145946-1-aleksandr.mikhalitsyn@canonical.com>
References: <20240506141444.145946-1-aleksandr.mikhalitsyn@canonical.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
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

Link: https://github.com/lxc/lxc/issues/4278 [1]
Link: https://github.com/kubernetes/kubernetes/blob/b722d017a34b300a2284b890448e5a605f21d01e/pkg/proxy/ipvs/proxier.go#L103 [2]
Link: https://github.com/moby/libnetwork/blob/3797618f9a38372e8107d8c06f6ae199e1133ae8/osl/namespace_linux.go#L682 [3]

Cc: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Jozsef Kadlecsik <kadlec@netfilter.org>
Cc: Florian Westphal <fw@strlen.de>
Signed-off-by: Alexander Mikhalitsyn <aleksandr.mikhalitsyn@canonical.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index e122fa367b81..b6d0dcf3a5c3 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -4269,6 +4269,7 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 	struct ctl_table *tbl;
 	int idx, ret;
 	size_t ctl_table_size = ARRAY_SIZE(vs_vars);
+	bool unpriv = net->user_ns != &init_user_ns;
 
 	atomic_set(&ipvs->dropentry, 0);
 	spin_lock_init(&ipvs->dropentry_lock);
@@ -4283,10 +4284,6 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 		tbl = kmemdup(vs_vars, sizeof(vs_vars), GFP_KERNEL);
 		if (tbl == NULL)
 			return -ENOMEM;
-
-		/* Don't export sysctls to unprivileged users */
-		if (net->user_ns != &init_user_ns)
-			ctl_table_size = 0;
 	} else
 		tbl = vs_vars;
 	/* Initialize sysctl defaults */
@@ -4312,10 +4309,17 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
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
@@ -4338,15 +4342,22 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
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

