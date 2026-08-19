Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2C69C3BA25F;
	Wed, 19 Aug 2026 02:29:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787106601; cv=none; b=axzeoLze9qS8EQYhRk/0UTIkOuXrBStZBJ4ztDxrVqXZBtODngSSIEMMhliXMlRedvhapOTtdby1/1EtnITEmR9rUw9pvesaDWpY75XXDQHwdSKQwNBZ47kfbDjoe3C/x0O+Dz97hLOu3IsMeSjm7ow3TmsjzMXZrj5FLavaJMQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787106601; c=relaxed/simple;
	bh=ghXZ0pNg3bc/gxhG0S2yq9sZf92+3XHOPiwZNweiMFQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Pnlfvh1NMkSYOKjCD4RHXl24MOaW74pF8d3Inc1jPEOwuVtb/XvCMAwSac9nM+iva3/7DshHSoFQQm/HI6PrJrT814d2N+ARTHI3l06cJZS0i0dAIBGdvSpHoBR/Q7a6mGzXxytAf2c91466peagNT3p1tewsnUEL7EDoUaerJ8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=XPk4rLYY; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="XPk4rLYY"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Cc:To:Message-Id:Content-Transfer-Encoding:Content-Type:
	MIME-Version:Subject:Date:From:From:Reply-To;
	bh=/zj38NG0Jtad2NvlMhx+0HTiUM61a7Li0ehqHM7SWK0=; b=XPk4rLYYea+UjJ3gc10vX9S0V0
	7vACMIblrAKfnZtCbh/Qp1UmLOJf7Lz8Pzu9HsmWEY3RxGpRxfn5VWSCih7uA7my0XFnrEILGCHjg
	XgpAJrKDuCPQMfsNqqHwwrVN5LCKtjwNqLroEeu2R6Z4f3VnzuQtTthCtjbFYtQ/VtxN1N00CKdyB
	heVH+v3DcYYNnl5tt8fBmK/784dmDAxk+Q4COfOQM9+a8riijWTFT3IElPHkjba3cJmwfviTbJnAn
	gyVDPWk9YnCbMZZogfMQP/PkqSZQzYzFFWZ6aU4ztxOGeX6A1n79N9F1P9aX6/1XS+/wTC+UdaLwB
	R4m/0GCQ==;
Received: from 186-249-144-28.shared.desktop.com.br ([186.249.144.28] helo=[127.0.1.1])
	by fanzine2.igalia.com with esmtpsa 
	(Cipher TLS1.3:ECDHE_X25519__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1wwW3w-005tfG-Pt; Wed, 19 Aug 2026 04:29:57 +0200
From: Mauricio Faria de Oliveira <mfo@igalia.com>
Date: Tue, 18 Aug 2026 23:28:07 -0300
Subject: [PATCH RFC v2 08/13] sysctl, net: update
 register_net_sysctl_sz(ARRAY_SIZE(table_tmpl)) with template arguments
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260818-sysctl-module-aliases-v2-8-d5a69dae5798@igalia.com>
References: <20260818-sysctl-module-aliases-v2-0-d5a69dae5798@igalia.com>
In-Reply-To: <20260818-sysctl-module-aliases-v2-0-d5a69dae5798@igalia.com>
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

Reduce register_net_sysctl_sz(net, path, table, ARRAY_SIZE(table_tmpl)) to
register_net_sysctl(net, path, table, table_tmpl) which does it internally.

Signed-off-by: Mauricio Faria de Oliveira <mfo@igalia.com>
---
 drivers/net/vrf.c                       | 3 +--
 net/bridge/br_netfilter_hooks.c         | 3 +--
 net/ipv4/devinet.c                      | 3 +--
 net/ipv4/ip_fragment.c                  | 3 +--
 net/ipv4/xfrm4_policy.c                 | 3 +--
 net/ipv6/netfilter/nf_conntrack_reasm.c | 4 ++--
 net/ipv6/reassembly.c                   | 3 +--
 net/ipv6/xfrm6_policy.c                 | 3 +--
 net/mptcp/ctrl.c                        | 3 +--
 net/netfilter/ipvs/ip_vs_ctl.c          | 4 +---
 net/netfilter/nf_conntrack_standalone.c | 5 ++---
 net/rds/tcp.c                           | 4 ++--
 net/unix/sysctl_net_unix.c              | 3 +--
 net/vmw_vsock/af_vsock.c                | 4 ++--
 14 files changed, 18 insertions(+), 30 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index a0557a3a70260a404b2c2c6262e8466aec5be391..19dacbe69d6de81e2cf5cd2b6e750a25f9cef092 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -1875,8 +1875,7 @@ static int vrf_netns_init_sysctl(struct net *net, struct netns_vrf *nn_vrf)
 	/* init the extra1 parameter with the reference to current netns */
 	table[0].extra1 = net;
 
-	nn_vrf->ctl_hdr = register_net_sysctl_sz(net, "net/vrf", table,
-						 ARRAY_SIZE(vrf_table));
+	nn_vrf->ctl_hdr = register_net_sysctl(net, "net/vrf", table, vrf_table);
 	if (!nn_vrf->ctl_hdr) {
 		kfree(table);
 		return -ENOMEM;
diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 0a394e5f439168fc32f3beb08721bee063ca5f17..ce5deb724608cf01103581f7f3e57210ffb85657 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -1251,8 +1251,7 @@ static int br_netfilter_sysctl_init_net(struct net *net)
 
 	br_netfilter_sysctl_default(brnet);
 
-	brnet->ctl_hdr = register_net_sysctl_sz(net, "net/bridge", table,
-						ARRAY_SIZE(brnf_table));
+	brnet->ctl_hdr = register_net_sysctl(net, "net/bridge", table, brnf_table);
 	if (!brnet->ctl_hdr) {
 		if (!net_eq(net, &init_net))
 			kfree(table);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index a466163dad7fe7f8b5b1c2897dd5fe548c288442..fad5483287c29f75a0c09aa833af389e51f36cfb 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -2884,8 +2884,7 @@ static __net_init int devinet_init_net(struct net *net)
 		goto err_reg_dflt;
 
 	err = -ENOMEM;
-	forw_hdr = register_net_sysctl_sz(net, "net/ipv4", tbl,
-					  ARRAY_SIZE(ctl_forward_entry));
+	forw_hdr = register_net_sysctl(net, "net/ipv4", tbl, ctl_forward_entry);
 	if (!forw_hdr)
 		goto err_reg_ctl;
 	net->ipv4.forw_hdr = forw_hdr;
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index c790d2f494870e1debd7e73b2d67df017a29f8a8..122aae5b4a384c12db5786bc34314107b4794b63 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -604,8 +604,7 @@ static int __net_init ip4_frags_ns_ctl_register(struct net *net)
 	table[2].data	= &net->ipv4.fqdir->timeout;
 	table[3].data	= &net->ipv4.fqdir->max_dist;
 
-	hdr = register_net_sysctl_sz(net, "net/ipv4", table,
-				     ARRAY_SIZE(ip4_frags_ns_ctl_table));
+	hdr = register_net_sysctl(net, "net/ipv4", table, ip4_frags_ns_ctl_table);
 	if (!hdr)
 		goto err_reg;
 
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index ab7a01029d490416d36482f7a3189f83d6670f42..cdd69d31a2757b0a23d65fb4b7d6d7de97c08706 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -177,8 +177,7 @@ static __net_init int xfrm4_net_sysctl_init(struct net *net)
 			goto err_alloc;
 	}
 
-	hdr = register_net_sysctl_sz(net, "net/ipv4", table,
-				     ARRAY_SIZE(xfrm4_policy_table));
+	hdr = register_net_sysctl(net, "net/ipv4", table, xfrm4_policy_table);
 	if (!hdr)
 		goto err_reg;
 
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 599c49bf0a0afd5054e926a5f2b1f0677bcd8b4d..09c98f2b9c3a04f622b232987dbc6a72f41238b4 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -86,8 +86,8 @@ static int nf_ct_frag6_sysctl_register(struct net *net)
 	table[2].data	= &nf_frag->fqdir->high_thresh;
 	table[2].extra1	= &nf_frag->fqdir->low_thresh;
 
-	hdr = register_net_sysctl_sz(net, "net/netfilter", table,
-				     ARRAY_SIZE(nf_ct_frag6_sysctl_table));
+	hdr = register_net_sysctl(net, "net/netfilter", table,
+				  nf_ct_frag6_sysctl_table);
 	if (hdr == NULL)
 		goto err_reg;
 
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 05c51f669754a1a10e944bb7c4433565bcaacb40..372c85b253fa1c2fe1f54765e2dea02f8ba047f9 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -471,8 +471,7 @@ static int __net_init ip6_frags_ns_sysctl_register(struct net *net)
 	table[1].extra2	= &net->ipv6.fqdir->high_thresh;
 	table[2].data	= &net->ipv6.fqdir->timeout;
 
-	hdr = register_net_sysctl_sz(net, "net/ipv6", table,
-				     ARRAY_SIZE(ip6_frags_ns_ctl_table));
+	hdr = register_net_sysctl(net, "net/ipv6", table, ip6_frags_ns_ctl_table);
 	if (!hdr)
 		goto err_reg;
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 5ec063cb4aa4378e70fff002dd03abf2029b247f..1c5a0ba14a7d03542d0691ea4c0f6a60443c20f6 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -223,8 +223,7 @@ static int __net_init xfrm6_net_sysctl_init(struct net *net)
 			goto err_alloc;
 	}
 
-	hdr = register_net_sysctl_sz(net, "net/ipv6", table,
-				     ARRAY_SIZE(xfrm6_policy_table));
+	hdr = register_net_sysctl(net, "net/ipv6", table, xfrm6_policy_table);
 	if (!hdr)
 		goto err_reg;
 
diff --git a/net/mptcp/ctrl.c b/net/mptcp/ctrl.c
index 63c5747f0f63cf75e516f68ac6cdde5ba5522278..df87f20f72ab86506b69ea40b403002ebf828348 100644
--- a/net/mptcp/ctrl.c
+++ b/net/mptcp/ctrl.c
@@ -406,8 +406,7 @@ static int mptcp_pernet_new_table(struct net *net, struct mptcp_pernet *pernet)
 	/* table[12] is for available_path_managers which is read-only info */
 	table[13].data = &pernet->add_addr_v6_port_drop_ts;
 
-	hdr = register_net_sysctl_sz(net, MPTCP_SYSCTL_PATH, table,
-				     ARRAY_SIZE(mptcp_sysctl_table));
+	hdr = register_net_sysctl(net, MPTCP_SYSCTL_PATH, table, mptcp_sysctl_table);
 	if (!hdr)
 		goto err_reg;
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 4c1c739446b76ea455dab2958a844d05e31a46a7..c65ccdebc285926ed993aeddc21d17b0e2cbef40 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -5048,7 +5048,6 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 	struct net *net = ipvs->net;
 	struct ctl_table *tbl;
 	int idx, ret;
-	size_t ctl_table_size = ARRAY_SIZE(vs_vars);
 	bool unpriv = net->user_ns != &init_user_ns;
 
 	atomic_set(&ipvs->dropentry, 0);
@@ -5166,8 +5165,7 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 #endif
 
 	ret = -ENOMEM;
-	ipvs->sysctl_hdr = register_net_sysctl_sz(net, "net/ipv4/vs", tbl,
-						  ctl_table_size);
+	ipvs->sysctl_hdr = register_net_sysctl(net, "net/ipv4/vs", tbl, vs_vars);
 	if (!ipvs->sysctl_hdr)
 		goto err;
 	ipvs->sysctl_tbl = tbl;
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index f4f2d82192d54ed9831b9677743f1139820e5a2e..a2f70cf4cd665e55f8e182bdf45da89b39434e11 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -1043,9 +1043,8 @@ static int nf_conntrack_standalone_init_sysctl(struct net *net)
 		table[NF_SYSCTL_CT_BUCKETS].mode = 0444;
 	}
 
-	cnet->sysctl_header = register_net_sysctl_sz(net, "net/netfilter",
-						     table,
-						     ARRAY_SIZE(nf_ct_sysctl_table));
+	cnet->sysctl_header = register_net_sysctl(net, "net/netfilter", table,
+						  nf_ct_sysctl_table);
 	if (!cnet->sysctl_header)
 		goto out_unregister_netfilter;
 
diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index b263634ac750d204a0d5726db6abe04023aa9c17..37fadb675faddf8e21f0aac04b96985ce3709bff 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -588,8 +588,8 @@ static __net_init int rds_tcp_init_net(struct net *net)
 	}
 	tbl[RDS_TCP_SNDBUF].data = &rtn->sndbuf_size;
 	tbl[RDS_TCP_RCVBUF].data = &rtn->rcvbuf_size;
-	rtn->rds_tcp_sysctl = register_net_sysctl_sz(net, "net/rds/tcp", tbl,
-						     ARRAY_SIZE(rds_tcp_sysctl_table));
+	rtn->rds_tcp_sysctl = register_net_sysctl(net, "net/rds/tcp", tbl,
+						  rds_tcp_sysctl_table);
 	if (!rtn->rds_tcp_sysctl) {
 		pr_warn("could not register sysctl\n");
 		err = -ENOMEM;
diff --git a/net/unix/sysctl_net_unix.c b/net/unix/sysctl_net_unix.c
index 47660d5726bbd7d812762f4feffa9a0a42499d7d..6d3d8d6905ace1c1b022951fab9b3f26c4a87c0a 100644
--- a/net/unix/sysctl_net_unix.c
+++ b/net/unix/sysctl_net_unix.c
@@ -48,8 +48,7 @@ int __net_init unix_sysctl_register(struct net *net)
 			goto err_alloc;
 	}
 
-	net->unx.ctl = register_net_sysctl_sz(net, "net/unix", table,
-					      ARRAY_SIZE(unix_table));
+	net->unx.ctl = register_net_sysctl(net, "net/unix", table, unix_table);
 	if (net->unx.ctl == NULL)
 		goto err_reg;
 
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index caebef73ea58d2b6043ca3fe3b6872f92fbe9fa6..b1fe08249050e95d4c945a8b670f21d5c444ebf4 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -2952,8 +2952,8 @@ static int __net_init vsock_sysctl_register(struct net *net)
 			goto err_alloc;
 	}
 
-	net->vsock.sysctl_hdr = register_net_sysctl_sz(net, "net/vsock", table,
-						       ARRAY_SIZE(vsock_table));
+	net->vsock.sysctl_hdr = register_net_sysctl(net, "net/vsock", table,
+						    vsock_table);
 	if (!net->vsock.sysctl_hdr)
 		goto err_reg;
 

-- 
2.47.3

