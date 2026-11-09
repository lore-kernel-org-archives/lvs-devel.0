Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=91.218.175.199
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794193148;
	b=icl9pBHE9TSbTmgEHgawTFqAqOJlF5JRtAF2UFgddN/h/JOoBBDFuevemuqHWiF9JxUw
	 OeLC2XVytJs+GAtRjDqHj7Wgig7ZVKmOWubJzb7jSqck+MQBiyX/h1m/PlBAQxGOLEy4U
	 S+lPe54/SZRMRb8t5R/T7IAmfuAvAyReWliLc6NRo5Eu/l8ETZTegC3UV+tE/NRqVdqZL
	 1Nr5qOEjoZlLPIkZy8xZSxIyw477p3HX3+zuEldrYZKQC4EYA9XNHnSEWjiG5bROqN6mv
	 5uJ6fOwEX9Rx0SH/dQVicc0eKg6iOQMdPHgJ3dCwCgj47obWfKOL/3HtAxbyFDb4w6w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794193148;
	h=DMARC-Filter:X-Envelope-To:DKIM-Signature:X-Envelope-To:Received:
	 X-Mizu-Trace-ID:X-Migadu-Flow:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=Bf366jHWd70EAZxhB5o3abb57M9eXTcgP/XKjct5Mvo=;
	b=QtZBq7m5lBvDbkK0ddAVT45Kt/imf2KxfaV2UWWpT2+oYzHRFve8WVeHG838IeqaVqxh
	 AupgyVcxMmpNKHHKJtZ6QYJJz0qoozT+dRB0ACvICmS24ysQ497If+7+zgGDsvIqdCOt8
	 Qd/qNz/vHUUa3XuE7dnTQTNkRblSV3MXSbUo8sEZiHl+eVyXb5dt1AgNzESvK/GGqy8Oe
	 0wM0/ds3npV+XKuBv43+42DijeNdjPw+h8h1dShpeSW1r6QJBmEnQWDfZw8A4+W3MDv8e
	 WpOucam8kNkD1kzjWK3GLLX0w3EzcRMxU15Oo92kglkWt4klTEB9A0iDCx15GrmwkYA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.dev;
	spf=pass smtp.mailfrom=linux.dev;
	dkim=pass header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=IRQORUdB;
	arc=none smtp.remote-ip=91.218.175.199
Received: from mta0.migadu.com (out-199.mta0.migadu.com [91.218.175.199])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F7FA606A326
	for <lvs-devel@vger.kernel.org>; Mon,  9 Nov 2026 02:59:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 7F7FA606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=IRQORUdB
X-Envelope-To: lvs-devel@vger.kernel.org
DKIM-Signature: a=rsa-sha256; bh=kTMeXMJ8wNOkF6r1V79QLXG8fPqTu8ASin9IvheY5BU=;
 c=simple/simple; d=linux.dev;
 h=from:to:subject:date:message-id:mime-version:content-type; s=key1;
 t=1794193145; v=1; x=1794797945;
 b=IRQORUdBNT8Gy3XEx5iwbeYMEx3BAlmow0+YzNDwcmXAHFI9Ryam93FabDhmH/AfNAWAhaM0
 BwP81kBHrUR3DfbV+EvjQIgqFWM8iQgE2HCZ5rV+hx1MSIUhc3+5wccm0eWOYIun0yavdh8aMOW
 Dgbmxn+Q6nkFop23jQXNdDos=
X-Envelope-To: lvs-devel@vger.kernel.org
Received: by smtp.migadu.com with ESMTPS id 3a8f53b14e41c8af;
	Mon, 09 Nov 2026 02:59:05 +0000
X-Mizu-Trace-ID: 3a8f53b14e41c8af
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
Subject: [PATCH net-next 09/14] netfilter: conntrack: annotate data-races around conntrack sysctls
Date: Mon,  9 Nov 2026 10:52:08 +0800
Message-ID: <20261109025425.328445-10-jiayuan.chen@linux.dev>
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

nf_conntrack_acct, nf_conntrack_events, nf_conntrack_timestamp,
nf_conntrack_checksum, nf_conntrack_log_invalid, nf_conntrack_max and
nf_conntrack_expect_max are read without any lock while their sysctl
handlers update them with WRITE_ONCE(), and nf_ct_set_acct() stores
sysctl_acct with a plain write. Add READ_ONCE() to the readers and
WRITE_ONCE() to nf_ct_set_acct().

KCSAN reports it when nf_conntrack_checksum is changed while packets go
through conntrack:

  BUG: KCSAN: data-race in nf_conntrack_icmpv4_error / proc_dou8vec_minmax

  write (marked) to 0xffffffff8ee29b6d of 1 bytes by task 568 on cpu 0:
   proc_dou8vec_minmax+0x1ab/0x1f0
   proc_sys_call_handler+0x282/0x3a0
   proc_sys_write+0x13/0x20
   ...

  read to 0xffffffff8ee29b6d of 1 bytes by interrupt on cpu 2:
   nf_conntrack_icmpv4_error+0xb3/0x240
   nf_conntrack_in+0xa85/0xb20
   ipv4_conntrack_local+0xb0/0x120
   nf_hook_slow+0x7e/0x180
   nf_hook+0x1fa/0x4e0
   __ip_local_out+0x1ac/0x3f0
   ip_push_pending_frames+0x65/0x160
   icmp_push_reply+0x17a/0x200
   __icmp_send+0xb7d/0x1a10
   udp_rcv+0x95c/0x14e0
   ...

  value changed: 0x00 -> 0x01

Signed-off-by: Jiayuan Chen <jiayuan.chen@linux.dev>
---
 include/net/netfilter/nf_conntrack_acct.h      | 6 +++---
 include/net/netfilter/nf_conntrack_timestamp.h | 2 +-
 net/netfilter/nf_conntrack_core.c              | 6 +++---
 net/netfilter/nf_conntrack_ecache.c            | 2 +-
 net/netfilter/nf_conntrack_expect.c            | 2 +-
 net/netfilter/nf_conntrack_netlink.c           | 2 +-
 net/netfilter/nf_conntrack_proto.c             | 6 +++---
 net/netfilter/nf_conntrack_proto_icmp.c        | 2 +-
 net/netfilter/nf_conntrack_proto_icmpv6.c      | 2 +-
 net/netfilter/nf_conntrack_proto_sctp.c        | 2 +-
 net/netfilter/nf_conntrack_proto_tcp.c         | 2 +-
 net/netfilter/nf_conntrack_proto_udp.c         | 2 +-
 12 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_acct.h b/include/net/netfilter/nf_conntrack_acct.h
index a120685cac932..4e5a46b628831 100644
--- a/include/net/netfilter/nf_conntrack_acct.h
+++ b/include/net/netfilter/nf_conntrack_acct.h
@@ -33,7 +33,7 @@ struct nf_conn_acct *nf_ct_acct_ext_add(struct nf_conn *ct, gfp_t gfp)
 	struct net *net = nf_ct_net(ct);
 	struct nf_conn_acct *acct;
 
-	if (!net->ct.sysctl_acct)
+	if (!READ_ONCE(net->ct.sysctl_acct))
 		return NULL;
 
 	acct = nf_ct_ext_add(ct, NF_CT_EXT_ACCT, gfp);
@@ -51,7 +51,7 @@ struct nf_conn_acct *nf_ct_acct_ext_add(struct nf_conn *ct, gfp_t gfp)
 static inline bool nf_ct_acct_enabled(struct net *net)
 {
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
-	return net->ct.sysctl_acct != 0;
+	return READ_ONCE(net->ct.sysctl_acct) != 0;
 #else
 	return false;
 #endif
@@ -61,7 +61,7 @@ static inline bool nf_ct_acct_enabled(struct net *net)
 static inline void nf_ct_set_acct(struct net *net, bool enable)
 {
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
-	net->ct.sysctl_acct = enable;
+	WRITE_ONCE(net->ct.sysctl_acct, enable);
 #endif
 }
 
diff --git a/include/net/netfilter/nf_conntrack_timestamp.h b/include/net/netfilter/nf_conntrack_timestamp.h
index 57138d974a9f7..59751be856ce9 100644
--- a/include/net/netfilter/nf_conntrack_timestamp.h
+++ b/include/net/netfilter/nf_conntrack_timestamp.h
@@ -29,7 +29,7 @@ struct nf_conn_tstamp *nf_ct_tstamp_ext_add(struct nf_conn *ct, gfp_t gfp)
 #ifdef CONFIG_NF_CONNTRACK_TIMESTAMP
 	struct net *net = nf_ct_net(ct);
 
-	if (!net->ct.sysctl_tstamp)
+	if (!READ_ONCE(net->ct.sysctl_tstamp))
 		return NULL;
 
 	return nf_ct_ext_add(ct, NF_CT_EXT_TSTAMP, gfp);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 931b76aacd934..5c7054753722e 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1508,7 +1508,7 @@ static void gc_worker(struct work_struct *work)
 
 	i = gc_work->next_bucket;
 	if (gc_work->early_drop)
-		nf_conntrack_max95 = nf_conntrack_max / 100u * 95u;
+		nf_conntrack_max95 = READ_ONCE(nf_conntrack_max) / 100u * 95u;
 
 	if (i == 0) {
 		gc_work->avg_timeout = GC_SCAN_INTERVAL_INIT;
@@ -1658,7 +1658,7 @@ __nf_conntrack_alloc(struct net *net,
 	/* We don't want any race condition at early drop stage */
 	ct_count = atomic_inc_return(&cnet->count);
 
-	if (unlikely(ct_count > nf_conntrack_max)) {
+	if (unlikely(ct_count > READ_ONCE(nf_conntrack_max))) {
 		if (!early_drop(net, hash)) {
 			if (!conntrack_gc_work.early_drop)
 				conntrack_gc_work.early_drop = true;
@@ -1793,7 +1793,7 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
 	ecache = tmpl ? nf_ct_ecache_find(tmpl) : NULL;
 
-	if ((ecache || net->ct.sysctl_events) &&
+	if ((ecache || READ_ONCE(net->ct.sysctl_events)) &&
 	    !nf_ct_ecache_ext_add(ct, ecache ? ecache->ctmask : 0,
 				  ecache ? ecache->expmask : 0,
 				  GFP_ATOMIC)) {
diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index fb731ee235d89..2846511c5318c 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -321,7 +321,7 @@ bool nf_ct_ecache_ext_add(struct nf_conn *ct, u16 ctmask, u16 expmask, gfp_t gfp
 	struct net *net = nf_ct_net(ct);
 	struct nf_conntrack_ecache *e;
 
-	switch (net->ct.sysctl_events) {
+	switch (READ_ONCE(net->ct.sysctl_events)) {
 	case 0:
 		 /* assignment via template / ruleset? ignore sysctl. */
 		if (ctmask || expmask)
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 06242c86e1dc8..43594283bcc76 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -518,7 +518,7 @@ static inline int __nf_ct_expect_check(struct nf_conntrack_expect *expect,
 	}
 
 	cnet = nf_ct_pernet(net);
-	if (cnet->expect_count >= nf_ct_expect_max) {
+	if (cnet->expect_count >= READ_ONCE(nf_ct_expect_max)) {
 		net_warn_ratelimited("nf_conntrack: expectation table full\n");
 		ret = -EMFILE;
 	}
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 1f8d94a052403..0f1d42a10b347 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2591,7 +2591,7 @@ ctnetlink_stat_ct_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	if (nla_put_be32(skb, CTA_STATS_GLOBAL_ENTRIES, htonl(nr_conntracks)))
 		goto nla_put_failure;
 
-	if (nla_put_be32(skb, CTA_STATS_GLOBAL_MAX_ENTRIES, htonl(nf_conntrack_max)))
+	if (nla_put_be32(skb, CTA_STATS_GLOBAL_MAX_ENTRIES, htonl(READ_ONCE(nf_conntrack_max))))
 		goto nla_put_failure;
 
 	nlmsg_end(skb, nlh);
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 7a40e4e0e33e6..83dc169f87df5 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -51,12 +51,12 @@ void nf_l4proto_log_invalid(const struct sk_buff *skb,
 			    u8 protonum,
 			    const char *fmt, ...)
 {
+	u8 log_invalid = READ_ONCE(state->net->ct.sysctl_log_invalid);
 	struct net *net = state->net;
 	struct va_format vaf;
 	va_list args;
 
-	if (net->ct.sysctl_log_invalid != protonum &&
-	    net->ct.sysctl_log_invalid != IPPROTO_RAW)
+	if (log_invalid != protonum && log_invalid != IPPROTO_RAW)
 		return;
 
 	va_start(args, fmt);
@@ -86,7 +86,7 @@ void nf_ct_l4proto_log_invalid(const struct sk_buff *skb,
 	lockdep_assert_not_held(&ct->lock);
 
 	net = nf_ct_net(ct);
-	if (likely(net->ct.sysctl_log_invalid == 0))
+	if (likely(READ_ONCE(net->ct.sysctl_log_invalid) == 0))
 		return;
 
 	va_start(args, fmt);
diff --git a/net/netfilter/nf_conntrack_proto_icmp.c b/net/netfilter/nf_conntrack_proto_icmp.c
index 32148a3a8509a..330c6d83d670a 100644
--- a/net/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/netfilter/nf_conntrack_proto_icmp.c
@@ -217,7 +217,7 @@ int nf_conntrack_icmpv4_error(struct nf_conn *tmpl,
 	}
 
 	/* See nf_conntrack_proto_tcp.c */
-	if (state->net->ct.sysctl_checksum &&
+	if (READ_ONCE(state->net->ct.sysctl_checksum) &&
 	    state->hook == NF_INET_PRE_ROUTING &&
 	    nf_ip_checksum(skb, state->hook, dataoff, IPPROTO_ICMP)) {
 		icmp_error_log(skb, state, "bad hw icmp checksum");
diff --git a/net/netfilter/nf_conntrack_proto_icmpv6.c b/net/netfilter/nf_conntrack_proto_icmpv6.c
index e508b3aa370a7..803221781de39 100644
--- a/net/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/netfilter/nf_conntrack_proto_icmpv6.c
@@ -198,7 +198,7 @@ int nf_conntrack_icmpv6_error(struct nf_conn *tmpl,
 	}
 
 	if (state->hook == NF_INET_PRE_ROUTING &&
-	    state->net->ct.sysctl_checksum &&
+	    READ_ONCE(state->net->ct.sysctl_checksum) &&
 	    nf_ip6_checksum(skb, state->hook, dataoff, IPPROTO_ICMPV6)) {
 		icmpv6_error_log(skb, state, "ICMPv6 checksum failed");
 		return -NF_ACCEPT;
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 71cc920f68568..49ec8478746ad 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -304,7 +304,7 @@ static bool sctp_error(struct sk_buff *skb,
 		goto out_invalid;
 	}
 	if (state->hook == NF_INET_PRE_ROUTING &&
-	    state->net->ct.sysctl_checksum &&
+	    READ_ONCE(state->net->ct.sysctl_checksum) &&
 	    skb->ip_summed == CHECKSUM_NONE) {
 		if (skb_ensure_writable(skb, dataoff + sizeof(*sh))) {
 			logmsg = "nf_ct_sctp: failed to read header ";
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index ad6f1986d52a6..b859e409f0796 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -856,7 +856,7 @@ static bool tcp_error(const struct tcphdr *th,
 	 * because the checksum is assumed to be correct.
 	 */
 	/* FIXME: Source route IP option packets --RR */
-	if (state->net->ct.sysctl_checksum &&
+	if (READ_ONCE(state->net->ct.sysctl_checksum) &&
 	    state->hook == NF_INET_PRE_ROUTING &&
 	    nf_checksum(skb, state->hook, dataoff, IPPROTO_TCP, state->pf)) {
 		tcp_error_log(skb, state, "bad checksum");
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index a7edfefd6fd14..9ea4062752238 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -82,7 +82,7 @@ static bool udp_error(struct sk_buff *skb,
 	 * because the checksum is assumed to be correct.
 	 * FIXME: Source route IP option packets --RR */
 	if (state->hook == NF_INET_PRE_ROUTING &&
-	    state->net->ct.sysctl_checksum &&
+	    READ_ONCE(state->net->ct.sysctl_checksum) &&
 	    nf_checksum(skb, state->hook, dataoff, IPPROTO_UDP, state->pf)) {
 		udp_error_log(skb, state, "bad checksum");
 		return true;
-- 
2.43.0

