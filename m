Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=95.215.58.201
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794193171;
	b=3Zt08zkDMvcogX/hyfSZiJAVMs/FyzQmY+Re9F5TYgavj8IcDmP4QWzTwQDo+xeIMP1p
	 Al6d5qk20zZ+F6eaZc4w3jAIMeQX2LyJDMegslag6L7C32UDIArs7/8bqssgzNnI28zb6
	 hY+EiwVs7v4nngypZcieLBV2QC0NbMi4CPdR1hWaoRDglz8ykzhYjj1bmYCTdKMhgenI+
	 h3/TvDdpM3Y1ywuzO6KUojMzxEZoemuJfJq4ukwaInBPuibFUtMCvNPHvCxmrGSm5doVk
	 K4vSfMP6msCeNDtHhinedzYC5KNf9MArOsbCmfol1hmNRei3TRi21gV3nl393g16uDQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794193171;
	h=DMARC-Filter:X-Envelope-To:DKIM-Signature:X-Envelope-To:Received:
	 X-Mizu-Trace-ID:X-Migadu-Flow:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=0LOz5L54nWXPFnHL/Mb3fPQeqh/eofMGeNrfaibpa3c=;
	b=EhAwstcOyV1EbOpAjkDWR2S0Ut4v7/DT9JBE29RluvRazzBdBuwDZzPdpDIGRuew2cfe
	 LsTfM0ifTfKXv+IUEeBa3yHi3ALmE+8jetkFfXPKJIdzxJmVZy8BSQw+U90yVhV/0T1Ma
	 JrAozRP20gKeDJ9f51M5Tn3MokcAQ+3U3xlIT2grHejNEvRIDBR1WTK0LnBIP4eXUvxr9
	 obn8LZ6ID2aHnMa/vF/e8y0KUtjdKbKOqJZbkmyzjHj9yaT2ciOstBnq1en2JW5YLqJ5o
	 ewlRv8rb7IRklI6XDp7MZvLsa5nzGA+U04W5IFguka85PQpNJXFwd39SnXisf0f4byg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.dev;
	spf=pass smtp.mailfrom=linux.dev;
	dkim=pass header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=ckwWJYna;
	arc=none smtp.remote-ip=95.215.58.201
Received: from mta1.migadu.com (out-201.mta1.migadu.com [95.215.58.201])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6044E606A331
	for <lvs-devel@vger.kernel.org>; Mon,  9 Nov 2026 02:59:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6044E606A331
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=ckwWJYna
X-Envelope-To: lvs-devel@vger.kernel.org
DKIM-Signature: a=rsa-sha256; bh=v8X1DpkjtfbDlgHCJDasGfHlMnkFTI38sTWUwIHdKjY=;
 c=simple/simple; d=linux.dev;
 h=from:to:subject:date:message-id:mime-version:content-type; s=key1;
 t=1794193168; v=1; x=1794797968;
 b=ckwWJYnaim0Q1IIfjBwnZgv/sq+mCLAlHhvNQX8O8FZXVWtRzlYGI/bGRMhzGRrPhRMbO9hl
 FGMN/UNeAIiB7+LxPiP2GgFgHhKUUTyojNYMY/8RTFJzwlRhQoafdpTWruk3mgzL4ZvBYbpLLlu
 HlGw6Dj7Xz09BFe797qFit4U=
X-Envelope-To: lvs-devel@vger.kernel.org
Received: by smtp.migadu.com with ESMTPS id c4c637c1dc94c2eb;
	Mon, 09 Nov 2026 02:59:28 +0000
X-Mizu-Trace-ID: c4c637c1dc94c2eb
X-Migadu-Flow: FLOW_OUT
From: Jiayuan Chen <jiayuan.chen@linux.dev>
To: netdev@vger.kernel.org
Cc: Jiayuan Chen <jiayuan.chen@linux.dev>,
	David Ahern <dsahern@kernel.org>,
	Ido Schimmel <idosch@nvidia.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@kernel.org>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Paul Moore <paul@paul-moore.com>,
	Matthieu Baerts <matttbe@kernel.org>,
	Mat Martineau <martineau@kernel.org>,
	Geliang Tang <geliang@kernel.org>,
	Julian Anastasov <ja@ssi.bg>,
	Allison Henderson <achender@kernel.org>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Xin Long <lucien.xin@gmail.com>,
	"D. Wythe" <alibuda@linux.alibaba.com>,
	Dust Li <dust.li@linux.alibaba.com>,
	Sidraya Jayagond <sidraya@linux.ibm.com>,
	Mahanta Jambigi <mjambigi@linux.ibm.com>,
	Tony Lu <tonylu@linux.alibaba.com>,
	Wen Gu <guwen@linux.alibaba.com>,
	linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	bridge@lists.linux.dev,
	linux-security-module@vger.kernel.org,
	mptcp@lists.linux.dev,
	lvs-devel@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	rds-devel@oss.oracle.com,
	linux-sctp@vger.kernel.org,
	linux-s390@vger.kernel.org
Subject: [PATCH net-next 10/14] netfilter: bridge: annotate data-races around br_netfilter and nf_log sysctls
Date: Mon,  9 Nov 2026 10:52:09 +0800
Message-ID: <20261109025425.328445-11-jiayuan.chen@linux.dev>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20261109025425.328445-1-jiayuan.chen@linux.dev>
References: <20261109025425.328445-1-jiayuan.chen@linux.dev>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

bridge-nf-call-arptables, bridge-nf-call-iptables,
bridge-nf-call-ip6tables, bridge-nf-filter-vlan-tagged,
bridge-nf-filter-pppoe-tagged, bridge-nf-pass-vlan-input-dev and
nf_log_all_netns are read in the packet path without any lock while their
sysctl handlers update them, and brnf_sysctl_call_tables() normalizes the
value with a plain write. Add READ_ONCE() to the readers and WRITE_ONCE()
to that handler.

KCSAN reports it when bridge-nf-call-iptables is changed while packets
are bridged:

  BUG: KCSAN: data-race in br_nf_pre_routing / do_proc_int_conv

  write (marked) to 0xffff8d7242d8ec50 of 4 bytes by task 824 on cpu 0:
   do_proc_int_conv+0xa9/0xd0
   proc_vec_conv+0x21/0x40
   proc_vec+0x21e/0x6f0
   proc_dointvec+0x16/0x30
   brnf_sysctl_call_tables+0x19/0x70
   proc_sys_call_handler+0x282/0x3a0
   proc_sys_write+0x13/0x20
   ...

  read to 0xffff8d7242d8ec50 of 4 bytes by interrupt on cpu 1:
   br_nf_pre_routing+0x1a9/0x9d0
   br_handle_frame+0x523/0x990
   __netif_receive_skb_core.constprop.0+0x3b2/0x1cf0
   __netif_receive_skb_one_core+0x51/0xe0
   __netif_receive_skb+0x23/0xb0
   process_backlog+0x27a/0x950
   ...

  value changed: 0x00000001 -> 0x00000000

Signed-off-by: Jiayuan Chen <jiayuan.chen@linux.dev>
---
 net/bridge/br_netfilter_hooks.c | 20 ++++++++++----------
 net/bridge/netfilter/ebt_log.c  |  2 +-
 net/netfilter/nf_log_syslog.c   |  2 +-
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index e15355ff215a7..8a47fe4e8eb61 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -94,7 +94,7 @@ static inline bool is_vlan_ip(const struct sk_buff *skb, const struct net *net)
 {
 	struct brnf_net *brnet = net_generic(net, brnf_net_id);
 
-	return vlan_proto(skb) == htons(ETH_P_IP) && brnet->filter_vlan_tagged;
+	return vlan_proto(skb) == htons(ETH_P_IP) && READ_ONCE(brnet->filter_vlan_tagged);
 }
 
 static inline bool is_vlan_ipv6(const struct sk_buff *skb,
@@ -103,14 +103,14 @@ static inline bool is_vlan_ipv6(const struct sk_buff *skb,
 	struct brnf_net *brnet = net_generic(net, brnf_net_id);
 
 	return vlan_proto(skb) == htons(ETH_P_IPV6) &&
-	       brnet->filter_vlan_tagged;
+	       READ_ONCE(brnet->filter_vlan_tagged);
 }
 
 static inline bool is_vlan_arp(const struct sk_buff *skb, const struct net *net)
 {
 	struct brnf_net *brnet = net_generic(net, brnf_net_id);
 
-	return vlan_proto(skb) == htons(ETH_P_ARP) && brnet->filter_vlan_tagged;
+	return vlan_proto(skb) == htons(ETH_P_ARP) && READ_ONCE(brnet->filter_vlan_tagged);
 }
 
 static inline __be16 pppoe_proto(const struct sk_buff *skb)
@@ -124,7 +124,7 @@ static inline bool is_pppoe_ip(const struct sk_buff *skb, const struct net *net)
 	struct brnf_net *brnet = net_generic(net, brnf_net_id);
 
 	return skb->protocol == htons(ETH_P_PPP_SES) &&
-	       pppoe_proto(skb) == htons(PPP_IP) && brnet->filter_pppoe_tagged;
+	       pppoe_proto(skb) == htons(PPP_IP) && READ_ONCE(brnet->filter_pppoe_tagged);
 }
 
 static inline bool is_pppoe_ipv6(const struct sk_buff *skb,
@@ -134,7 +134,7 @@ static inline bool is_pppoe_ipv6(const struct sk_buff *skb,
 
 	return skb->protocol == htons(ETH_P_PPP_SES) &&
 	       pppoe_proto(skb) == htons(PPP_IPV6) &&
-	       brnet->filter_pppoe_tagged;
+	       READ_ONCE(brnet->filter_pppoe_tagged);
 }
 
 /* largest possible L2 header, see br_nf_dev_queue_xmit() */
@@ -442,7 +442,7 @@ static struct net_device *brnf_get_logical_dev(struct sk_buff *skb,
 
 	br = bridge_parent(dev);
 
-	if (brnet->pass_vlan_indev == 0 || !skb_vlan_tag_present(skb))
+	if (READ_ONCE(brnet->pass_vlan_indev) == 0 || !skb_vlan_tag_present(skb))
 		return br;
 
 	vlan = __vlan_find_dev_deep_rcu(br, skb->vlan_proto,
@@ -502,7 +502,7 @@ static unsigned int br_nf_pre_routing(void *priv,
 	brnet = net_generic(state->net, brnf_net_id);
 	if (IS_IPV6(skb) || is_vlan_ipv6(skb, state->net) ||
 	    is_pppoe_ipv6(skb, state->net)) {
-		if (!brnet->call_ip6tables &&
+		if (!READ_ONCE(brnet->call_ip6tables) &&
 		    !br_opt_get(br, BROPT_NF_CALL_IP6TABLES))
 			return NF_ACCEPT;
 		if (!ipv6_mod_enabled()) {
@@ -514,7 +514,7 @@ static unsigned int br_nf_pre_routing(void *priv,
 		return br_nf_pre_routing_ipv6(priv, skb, state);
 	}
 
-	if (!brnet->call_iptables && !br_opt_get(br, BROPT_NF_CALL_IPTABLES))
+	if (!READ_ONCE(brnet->call_iptables) && !br_opt_get(br, BROPT_NF_CALL_IPTABLES))
 		return NF_ACCEPT;
 
 	if (!IS_IP(skb) && !is_vlan_ip(skb, state->net) &&
@@ -740,7 +740,7 @@ static unsigned int br_nf_forward_arp(struct sk_buff *skb,
 	br = p->br;
 
 	brnet = net_generic(state->net, brnf_net_id);
-	if (!brnet->call_arptables && !br_opt_get(br, BROPT_NF_CALL_ARPTABLES))
+	if (!READ_ONCE(brnet->call_arptables) && !br_opt_get(br, BROPT_NF_CALL_ARPTABLES))
 		return NF_ACCEPT;
 
 	if (is_vlan_arp(skb, state->net))
@@ -1178,7 +1178,7 @@ int brnf_sysctl_call_tables(const struct ctl_table *ctl, int write,
 	ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
 
 	if (write && *(int *)(ctl->data))
-		*(int *)(ctl->data) = 1;
+		WRITE_ONCE(*(int *)(ctl->data), 1);
 	return ret;
 }
 
diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index e2eea1daaf8ba..f360414a2814e 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -79,7 +79,7 @@ ebt_log_packet(struct net *net, u_int8_t pf, unsigned int hooknum,
 	unsigned int bitmask;
 
 	/* FIXME: Disabled from containers until syslog ns is supported */
-	if (!net_eq(net, &init_net) && !sysctl_nf_log_all_netns)
+	if (!net_eq(net, &init_net) && !READ_ONCE(sysctl_nf_log_all_netns))
 		return;
 
 	spin_lock_bh(&ebt_log_lock);
diff --git a/net/netfilter/nf_log_syslog.c b/net/netfilter/nf_log_syslog.c
index c3fd398ffcd77..2907f47c83423 100644
--- a/net/netfilter/nf_log_syslog.c
+++ b/net/netfilter/nf_log_syslog.c
@@ -43,7 +43,7 @@ struct arppayload {
 /* Guard against containers flooding syslog. */
 static bool nf_log_allowed(const struct net *net)
 {
-	return net_eq(net, &init_net) || sysctl_nf_log_all_netns;
+	return net_eq(net, &init_net) || READ_ONCE(sysctl_nf_log_all_netns);
 }
 
 static void nf_log_dump_vlan(struct nf_log_buf *m, const struct sk_buff *skb)
-- 
2.43.0

