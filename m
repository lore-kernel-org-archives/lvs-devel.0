Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DD5B34BC002;
	Wed, 19 Aug 2026 18:16:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787163416; cv=none; b=XhSsVKSTf76HppgeL+wccqUDoU8sp5fEq9k7xnIYif4B7RF+jASDNivyyDTy5YWVNcfL1znri9F2C8ITzF+X9FgMpdIHhxIvu425HUKsRgLWSzHKAFMbc2pbomFr2bHtiFUFE/kDfJiY1gQhAFxo7nZcz+DgxRqXuyteDxt2ciw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787163416; c=relaxed/simple;
	bh=wRLwCiuqMttYVsCHPxBkzo19GaoHrSC1wLITrsCEBiI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ORLS5CALRS/o7w5aDZPh2max97gHvQrK+OCgWRMAY2Jz7iI5Iu8hdl7tQ3jrrQ0Q6OwmSJG/l5yxz3oeD0/Jwc8ANkTGv2lodeZuUg/y3pfsLjNAlmzjgpSRxnPOZTrxG3X2fuWJZMUhHGIUKl5FWWNPTVXIr3jLnKuKDPMx0wk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=iWuYsS5t; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="iWuYsS5t"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Cc:To:Message-Id:Content-Transfer-Encoding:Content-Type:
	MIME-Version:Subject:Date:From:From:Reply-To;
	bh=JxjRhJ2z8K0GvxyVrmaAYfCElgRxeZGrAv21+ElqaE4=; b=iWuYsS5tm52pjQ4kgmlptYTgtd
	aifA9yQgQdT+nxm3VOjYbywN6MsP1YBHVg3VDWxMP95M75P//gjgSE/tCcLHxdYSJPQJwL7Zey+08
	s5aNQLAqT1CKIgkEh9e4hdchMruAE6HyUHcm91q8zvnio4vZSyZJYqGoFIlO0/OrpPx5+xn1ST2JT
	S9jo+yqtNq88/mklFXnw3sCwDGuTtwESCA0etBxC1XhX23NEv6Kv36US6yvqzLp1dMNYB6pM+i6dz
	KsdX4yL/MP6ijbKTU9LOyc3VqhqMooKawKNoTKa4ueXetef9dCeDK+l36m8P3uyb7MrWguAGbk8Ki
	oISyBZFg==;
Received: from 186-249-147-181.shared.desktop.com.br ([186.249.147.181] helo=[127.0.1.1])
	by fanzine2.igalia.com with esmtpsa 
	(Cipher TLS1.3:ECDHE_X25519__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1wwkqK-006ENH-D5; Wed, 19 Aug 2026 20:16:52 +0200
From: Mauricio Faria de Oliveira <mfo@igalia.com>
Date: Wed, 19 Aug 2026 15:16:22 -0300
Subject: [PATCH RFC v3 09/13] sysctl, ipv6: update
 register_net_sysctl{_sz}() callers with template arguments
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260819-sysctl-module-aliases-v3-9-aab90569365d@igalia.com>
References: <20260819-sysctl-module-aliases-v3-0-aab90569365d@igalia.com>
In-Reply-To: <20260819-sysctl-module-aliases-v3-0-aab90569365d@igalia.com>
To: Kees Cook <kees@kernel.org>, Joel Granados <joel.granados@kernel.org>, 
 Nathan Chancellor <nathan@kernel.org>, Nicolas Schier <nsc@kernel.org>, 
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, 
 Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>
Cc: kernel-dev@igalia.com, linux-riscv@lists.infradead.org, 
 linux-kernel@vger.kernel.org, fsverity@lists.linux.dev, 
 keyrings@vger.kernel.org, bpf@vger.kernel.org, 
 linux-fsdevel@vger.kernel.org, linux-kbuild@vger.kernel.org, 
 netdev@vger.kernel.org, linux-wpan@vger.kernel.org, 
 lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, 
 coreteam@netfilter.org, linux-sctp@vger.kernel.org, 
 linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org, 
 bridge@lists.linux.dev, mptcp@lists.linux.dev, rds-devel@oss.oracle.com, 
 virtualization@lists.linux.dev, Mauricio Faria de Oliveira <mfo@igalia.com>
X-Mailer: b4 0.14.2

The sysctl table definition and registration must be in the same file,
in order for the macro to work.

Add plumbing to register ipv6_{route,icmp}_table in their own files.
With this, ipv6_{route,icmp}_sysctl_table_size() can be removed.

Signed-off-by: Mauricio Faria de Oliveira <mfo@igalia.com>
---
 include/net/ipv6.h         |  6 ++++--
 net/ipv6/icmp.c            |  6 ++++--
 net/ipv6/route.c           | 10 +++++++---
 net/ipv6/sysctl_net_ipv6.c | 10 ++--------
 4 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 3de07e738538f783e0fb4628c92ce50a7e36f9f5..29a095798abe8f5730ab0a046931ebf78f481bdf 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -1220,9 +1220,11 @@ static inline int snmp6_unregister_dev(struct inet6_dev *idev) { return 0; }
 
 #ifdef CONFIG_SYSCTL
 struct ctl_table *ipv6_icmp_sysctl_init(struct net *net);
-size_t ipv6_icmp_sysctl_table_size(void);
+struct ctl_table_header *ipv6_icmp_sysctl_register(struct net *net,
+						   const struct ctl_table *table);
 struct ctl_table *ipv6_route_sysctl_init(struct net *net);
-size_t ipv6_route_sysctl_table_size(struct net *net);
+struct ctl_table_header *ipv6_route_sysctl_register(struct net *net,
+						    const struct ctl_table *table);
 int ipv6_sysctl_register(void);
 void ipv6_sysctl_unregister(void);
 #endif
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index a95b0351824f3237815e43bf8448110070955884..bb170b8c867c3c6eaccc41aab8ab1c65eb0aa24b 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -1450,8 +1450,10 @@ struct ctl_table * __net_init ipv6_icmp_sysctl_init(struct net *net)
 	return table;
 }
 
-size_t ipv6_icmp_sysctl_table_size(void)
+struct ctl_table_header *ipv6_icmp_sysctl_register(struct net *net,
+						   const struct ctl_table *table)
 {
-	return ARRAY_SIZE(ipv6_icmp_table_template);
+	return register_net_sysctl(net, "net/ipv6/icmp", table,
+				   ipv6_icmp_table_template);
 }
 #endif
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 16dfac54a259a11410ba736535f0462070979276..9e3f849d3564f4312d7b64157471f50c8168aafd 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -6698,13 +6698,17 @@ struct ctl_table * __net_init ipv6_route_sysctl_init(struct net *net)
 	return table;
 }
 
-size_t ipv6_route_sysctl_table_size(struct net *net)
+struct ctl_table_header *ipv6_route_sysctl_register(struct net *net,
+						    const struct ctl_table *table)
 {
+	size_t table_size = ARRAY_SIZE(ipv6_route_table_template);
+
 	/* Don't export sysctls to unprivileged users */
 	if (net->user_ns != &init_user_ns)
-		return 1;
+		table_size = 1;
 
-	return ARRAY_SIZE(ipv6_route_table_template);
+	return register_net_sysctl_sz(net, "net/ipv6/route", table,
+				      table_size, ipv6_route_table_template);
 }
 #endif
 
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 75ba17cb7c0ccb4769d61e74220c75d0b3e2bcd9..88138fbd42b85d54d00cd15dfd7d6848ebabd607 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -280,17 +280,11 @@ static int __net_init ipv6_sysctl_net_init(struct net *net)
 	if (!net->ipv6.sysctl.hdr)
 		goto out_ipv6_icmp_table;
 
-	net->ipv6.sysctl.route_hdr = register_net_sysctl_sz(net,
-							    "net/ipv6/route",
-							    ipv6_route_table,
-							    ipv6_route_sysctl_table_size(net));
+	net->ipv6.sysctl.route_hdr = ipv6_route_sysctl_register(net, ipv6_route_table);
 	if (!net->ipv6.sysctl.route_hdr)
 		goto out_unregister_ipv6_table;
 
-	net->ipv6.sysctl.icmp_hdr = register_net_sysctl_sz(net,
-							   "net/ipv6/icmp",
-							   ipv6_icmp_table,
-							   ipv6_icmp_sysctl_table_size());
+	net->ipv6.sysctl.icmp_hdr = ipv6_icmp_sysctl_register(net, ipv6_icmp_table);
 	if (!net->ipv6.sysctl.icmp_hdr)
 		goto out_unregister_route_table;
 

-- 
2.47.3

