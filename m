Received: from smtp-relay-internal-0.canonical.com (smtp-relay-internal-0.canonical.com [185.125.188.122])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7E2DE16C84E
	for <lvs-devel@vger.kernel.org>; Thu, 18 Apr 2024 14:57:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=185.125.188.122
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1713452278; cv=none; b=P+hXl/5YSnq5AjJFtpmlxiO1cFO2cdXvSr79yKSQHfDqdKPhoNfo47VHtVyJ8plXpRk5OZ7WpBYd5P2i4PoqjOqzJoeJ9geyXASWLIJrGLrWEvh6UoEbj7Blrj08dfGrD0aOE4qEfPzag7i1ZwZyF9GEiZZjFT9QHgWw33M+A7w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1713452278; c=relaxed/simple;
	bh=j1OY0T879lcbTo/Rtg5u2e8BORsJdDS072NnPHn0yIA=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version:Content-Type; b=jLd7cYInnCLTmOzfBXzm1XQ5uqZYVDbwwx4TL8uAyyt4XQ9yhJkAtJYCsI4CE3w1S000TlbiwtrynrLoMXauqTNPOhCQIyjg/5zRO584Vae9sBJVXE6k4SuAmameJ3bhTKwtT55GeF5PbhRRNd3ea7JAZTH9QaXCWj07sVicOUU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=canonical.com; spf=pass smtp.mailfrom=canonical.com; dkim=pass (2048-bit key) header.d=canonical.com header.i=@canonical.com header.b=eiHbFnr6; arc=none smtp.client-ip=185.125.188.122
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=canonical.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=canonical.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=canonical.com header.i=@canonical.com header.b="eiHbFnr6"
Received: from mail-ej1-f70.google.com (mail-ej1-f70.google.com [209.85.218.70])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-relay-internal-0.canonical.com (Postfix) with ESMTPS id EBAA03F8E7
	for <lvs-devel@vger.kernel.org>; Thu, 18 Apr 2024 14:57:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=canonical.com;
	s=20210705; t=1713452274;
	bh=P9cfzGdFw85QMaHvElbpMa0bAXpO82OWeZGP3EPPeSc=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version:Content-Type;
	b=eiHbFnr6E+UTkKsoX/mMlubXphA0Q4Q7sMlLl6oEgNrFGtfpjBrFstxgbVk5BUOxf
	 H6+Ix+hAOIMmuA4Roitvw5u0sbeRmmmeL/2iz6Ej/Txy26R5MD/jStbtC/YIb9LbKV
	 fqz+IJ7ZlyN0HXR7PmOtZaV/CE2sVqZVaQ5VqVdHwkrhgn9NiS6K2sPcbiR5JR6jjc
	 9hHBjfc01gB81LChZtYn4kqlsh73MC6AXWkeRMNZtwjxTYF1PAcpoyW/3kJI2oKe2Q
	 tbp9xlJmqWG/R7it4DIewUKSyzclsoE5pcsTBA7vAVe2+tMF9a6l7BBozm+KyTltna
	 YVeU+TKrMk4SA==
Received: by mail-ej1-f70.google.com with SMTP id a640c23a62f3a-a46cc88be5fso52319766b.2
        for <lvs-devel@vger.kernel.org>; Thu, 18 Apr 2024 07:57:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1713452274; x=1714057074;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=P9cfzGdFw85QMaHvElbpMa0bAXpO82OWeZGP3EPPeSc=;
        b=D1XePa//JXpDE2ugwjHrXgh45qTnlKRnrejZUESCSDPjM1ZjMcFeoo44yy06BPArh0
         zn0AGYPZM5TQWoH/YddkkOAqKraqcVisUD9t88d2BqhTVkHAzpDNyZVS/IADY/sTmb3D
         FVNAMFe85cCl5lgbRcSrJ3474jyb3/Fh0FleiEB/Etx19866ghnwZduDkeuvWc1A5Cbu
         oTtsYMZFpKjFfnz+OZ2OUH2skECdLsagXw7RFujleyRYxJEyhZNgMDE71oF0xznRioaK
         UF7u7mH7nXbVc8Lo3JYNqpa2qofeZOqmaRfnYUyryrV38WQK0bxET9ef9iGj4d0xIzxe
         mRXA==
X-Forwarded-Encrypted: i=1; AJvYcCUxDhaxRKbkI3s86sHZZ7WLuxNsEr5umOpCDb7ZrC43lBtvtwHRHb9P8dm7ldMmohbHah5Gkr4AqkXvTmSwo0rylua55AoLIdxu
X-Gm-Message-State: AOJu0YxG27aItQG0u4dJrq0nDnOmHCEe2j/nXiQWM/O+e68TET74muXz
	saofqa4hLmTxhucy6kcgSnkb+kciNbg3+wx4h8Nf3XD+Jspo2kbXD8zhQajdJvLIsKRIJ9MqS07
	iY2ik7gd+RBj5wGhOyAvpC2zy/dabDn1C/K7/1FOXOj1+TK9TTUDGz6Rk3AF6+sQGMLjeeC/5ag
	==
X-Received: by 2002:a17:906:abc5:b0:a51:ae39:d385 with SMTP id kq5-20020a170906abc500b00a51ae39d385mr2031029ejb.1.1713452274010;
        Thu, 18 Apr 2024 07:57:54 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IFRD732CssEKFMVZ1ag7deR/XTNnVYkFjxEketr3SQgrrRHiOAgZRldqOSxuaIowUAoOABZOQ==
X-Received: by 2002:a17:906:abc5:b0:a51:ae39:d385 with SMTP id kq5-20020a170906abc500b00a51ae39d385mr2031015ejb.1.1713452273632;
        Thu, 18 Apr 2024 07:57:53 -0700 (PDT)
Received: from amikhalitsyn.lan ([2001:470:6d:781:320c:9c91:fb97:fbfc])
        by smtp.gmail.com with ESMTPSA id jj17-20020a170907985100b00a522a073a64sm993665ejc.187.2024.04.18.07.57.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 18 Apr 2024 07:57:53 -0700 (PDT)
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
Subject: [PATCH net-next v3 2/2] ipvs: allow some sysctls in non-init user namespaces
Date: Thu, 18 Apr 2024 16:57:43 +0200
Message-Id: <20240418145743.248109-2-aleksandr.mikhalitsyn@canonical.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20240418145743.248109-1-aleksandr.mikhalitsyn@canonical.com>
References: <20240418145743.248109-1-aleksandr.mikhalitsyn@canonical.com>
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

Link: https://github.com/lxc/lxc/issues/4278 [1]
Link: https://github.com/kubernetes/kubernetes/blob/b722d017a34b300a2284b890448e5a605f21d01e/pkg/proxy/ipvs/proxier.go#L103 [2]
Link: https://github.com/moby/libnetwork/blob/3797618f9a38372e8107d8c06f6ae199e1133ae8/osl/namespace_linux.go#L682 [3]

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
index 32be24f0d4e4..c3ba71aa2654 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -4270,6 +4270,7 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 	struct ctl_table *tbl;
 	int idx, ret;
 	size_t ctl_table_size = ARRAY_SIZE(vs_vars);
+	bool unpriv = net->user_ns != &init_user_ns;
 
 	atomic_set(&ipvs->dropentry, 0);
 	spin_lock_init(&ipvs->dropentry_lock);
@@ -4284,12 +4285,6 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
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
@@ -4315,10 +4310,17 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
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
@@ -4341,15 +4343,22 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
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

