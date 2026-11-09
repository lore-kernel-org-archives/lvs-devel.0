Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=95.215.58.45
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794193255;
	b=gQM8oWZynuwT3t0s2hSQBGMlKl4IKvcoiqWk4RET9xsCOGUdUiV3GUQ4PK2NyvGuULpg
	 68uxhyPxcpurDLcv1+GA8hDBFro2TEVQZhRiLUXapdl1ZTli3b2exjfrlpYH/KIrSVsPC
	 sPr/OBwPtkAV1aJDTuwh6wGptw4y9ud0LIwXnmnaY9hb6CqPYDtNbB6CG0Rf//DNQMe+A
	 MKKbQn1QBbH2ttYwsgOchGDMA+ICGSoPfkTt+qmVNOEt74mMEOzuNV6l2CxPYpfiCMzRU
	 DtIPquK+4hSLLruTv8kF5ti9DVgcKDwzm4w6HIQOn57veK8ewmgjXI/f1dlU52WJ/HQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794193255;
	h=DMARC-Filter:X-Envelope-To:DKIM-Signature:X-Envelope-To:Received:
	 X-Mizu-Trace-ID:X-Migadu-Flow:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=wYVZ0P5/eAsoYUi0aFWJ9LmLt55byvw4m/iS5WUHZOc=;
	b=CjeyjyIFFBT/CZs/uZRopo2ibESw74IXwVsQXVfrAl0GuR0iTqP8s5VzCPEUtXjn4E7U
	 T96E0EbIbGBB0UXSkcY5bITNYD/KCNJxXSUNM8m0dhYouLQFYSGagbg2nWHqGpPaImRLL
	 peKAFViVzzlcLEXqxU94YPfVyiCe+XkpvjX4tc5ZfDmcPmc3cjKUbvMYCNbWpWjjjOdTn
	 5HN5mExvzoPSGp0FZR5e7AtjUnITxFpiY1DPlIAtYdc3TksiioiIuTaPiMUAQqno6IFux
	 Ytd0VnnagUI1LtCxPP/Ks/SxnTyMuWGvNOc0kwyZBNmlfK8FXmRM3IScQGSfAm+N/iA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.dev;
	spf=pass smtp.mailfrom=linux.dev;
	dkim=pass header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=Wbo6wBni;
	arc=none smtp.remote-ip=95.215.58.45
Received: from mta1.migadu.com (out-45.mta1.migadu.com [95.215.58.45])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A940E606A323
	for <lvs-devel@vger.kernel.org>; Mon,  9 Nov 2026 03:00:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A940E606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=Wbo6wBni
X-Envelope-To: lvs-devel@vger.kernel.org
DKIM-Signature: a=rsa-sha256; bh=k7dL8zfVh+rV28GwLPocCPAc9UOjmFfDkZielwri1g8=;
 c=simple/simple; d=linux.dev;
 h=from:to:subject:date:message-id:mime-version:content-type; s=key1;
 t=1794193253; v=1; x=1794798053;
 b=Wbo6wBni0g4SPXV+Wq2l95nRdJ7C5I2DGYKrW9ZJ9+VpVOGDrcXugmljCv1P2EkBARxDBwre
 kqFZ4DqviKzlddwnaM9KT8NNc8HYGB1gxAU4quDvz8p7dXLOO4JxahDU6ZctAmZ+nOjXQRx0QTR
 IMdT/XdVaKonvMm/O1Dn6qXQ=
X-Envelope-To: lvs-devel@vger.kernel.org
Received: by smtp.migadu.com with ESMTPS id 70de1fc2d87f3c36;
	Mon, 09 Nov 2026 03:00:49 +0000
X-Mizu-Trace-ID: 70de1fc2d87f3c36
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
Subject: [PATCH net-next 13/14] netfilter: conntrack: annotate data-races around timeout and tcp sysctls
Date: Mon,  9 Nov 2026 10:52:12 +0800
Message-ID: <20261109025425.328445-14-jiayuan.chen@linux.dev>
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

The nf_conntrack_*_timeout* knobs, nf_flowtable_tcp_timeout,
nf_flowtable_udp_timeout and nf_conntrack_tcp_{loose,be_liberal,
max_retrans,ignore_invalid_rst} are read in the packet path without any
lock while their sysctl handlers update them with WRITE_ONCE(). Add
READ_ONCE() to the readers.

KCSAN reports it when nf_conntrack_udp_timeout is changed while UDP
traffic goes through conntrack:

  BUG: KCSAN: data-race in nf_conntrack_udp_packet / proc_int_u2k_conv_uop

  write (marked) to 0xffffffffb0829bc4 of 4 bytes by task 436 on cpu 0:
   proc_int_u2k_conv_uop+0x92/0xa0
   sysctl_u2k_int_conv_hz+0x21/0x30
   proc_int_conv+0xdf/0x130
   do_proc_int_conv_jiffies+0x1b/0x30
   proc_vec_conv+0x21/0x40
   proc_vec+0x21e/0x6f0
   proc_dointvec_conv+0x21/0x40
   proc_dointvec_jiffies+0x15/0x30
   proc_sys_call_handler+0x282/0x3a0
   proc_sys_write+0x13/0x20
   ...

  read to 0xffffffffb0829bc4 of 4 bytes by task 439 on cpu 3:
   nf_conntrack_udp_packet+0x27b/0x550
   nf_conntrack_in+0x767/0xb20
   ipv4_conntrack_local+0xb0/0x120
   nf_hook_slow+0x7e/0x180
   nf_hook+0x1fa/0x4e0
   __ip_local_out+0x1ac/0x3f0
   ip_send_skb+0x31/0x120
   udp_send_skb+0x4bf/0x640
   udp_sendmsg+0xdec/0x18a0
   ...

  value changed: 0x00001d4c -> 0x00001e46

Signed-off-by: Jiayuan Chen <jiayuan.chen@linux.dev>
---
 net/netfilter/nf_conntrack_core.c         |  2 +-
 net/netfilter/nf_conntrack_proto_gre.c    |  4 +--
 net/netfilter/nf_conntrack_proto_icmp.c   |  2 +-
 net/netfilter/nf_conntrack_proto_icmpv6.c |  2 +-
 net/netfilter/nf_conntrack_proto_sctp.c   |  2 +-
 net/netfilter/nf_conntrack_proto_tcp.c    | 37 ++++++++++++-----------
 net/netfilter/nf_conntrack_proto_udp.c    |  6 ++--
 net/netfilter/nf_flow_table_core.c        |  4 +--
 8 files changed, 31 insertions(+), 28 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 5c7054753722e..8e332e407529e 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1959,7 +1959,7 @@ static int generic_packet(struct nf_conn *ct, struct sk_buff *skb,
 	if (!timeout)
 		timeout = &nf_generic_pernet(nf_ct_net(ct))->timeout;
 
-	nf_ct_refresh_acct(ct, ctinfo, skb, *timeout);
+	nf_ct_refresh_acct(ct, ctinfo, skb, READ_ONCE(*timeout));
 	return NF_ACCEPT;
 }
 
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 616ab1e2fc5ed..d8bca1e29797b 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -279,8 +279,8 @@ int nf_conntrack_gre_packet(struct nf_conn *ct,
 
 		/* initialize to sane value.  Ideally a conntrack helper
 		 * (e.g. in case of pptp) is increasing them */
-		ct->proto.gre.stream_timeout = timeouts[GRE_CT_REPLIED];
-		ct->proto.gre.timeout = timeouts[GRE_CT_UNREPLIED];
+		ct->proto.gre.stream_timeout = READ_ONCE(timeouts[GRE_CT_REPLIED]);
+		ct->proto.gre.timeout = READ_ONCE(timeouts[GRE_CT_UNREPLIED]);
 	}
 
 	status = READ_ONCE(ct->status);
diff --git a/net/netfilter/nf_conntrack_proto_icmp.c b/net/netfilter/nf_conntrack_proto_icmp.c
index 330c6d83d670a..0f6ef0443c6fa 100644
--- a/net/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/netfilter/nf_conntrack_proto_icmp.c
@@ -98,7 +98,7 @@ int nf_conntrack_icmp_packet(struct nf_conn *ct,
 	if (!timeout)
 		timeout = &nf_icmp_pernet(nf_ct_net(ct))->timeout;
 
-	nf_ct_refresh_acct(ct, ctinfo, skb, *timeout);
+	nf_ct_refresh_acct(ct, ctinfo, skb, READ_ONCE(*timeout));
 	return NF_ACCEPT;
 }
 
diff --git a/net/netfilter/nf_conntrack_proto_icmpv6.c b/net/netfilter/nf_conntrack_proto_icmpv6.c
index 803221781de39..e4eebf13950cb 100644
--- a/net/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/netfilter/nf_conntrack_proto_icmpv6.c
@@ -118,7 +118,7 @@ int nf_conntrack_icmpv6_packet(struct nf_conn *ct,
 	/* Do not immediately delete the connection after the first
 	   successful reply to avoid excessive conntrackd traffic
 	   and also to handle correctly ICMP echo reply duplicates. */
-	nf_ct_refresh_acct(ct, ctinfo, skb, *timeout);
+	nf_ct_refresh_acct(ct, ctinfo, skb, READ_ONCE(*timeout));
 
 	return NF_ACCEPT;
 }
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 49ec8478746ad..047bf69113bf9 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -523,7 +523,7 @@ int nf_conntrack_sctp_packet(struct nf_conn *ct,
 	if (!timeouts)
 		timeouts = nf_sctp_pernet(nf_ct_net(ct))->timeouts;
 
-	nf_ct_refresh_acct(ct, ctinfo, skb, timeouts[new_state]);
+	nf_ct_refresh_acct(ct, ctinfo, skb, READ_ONCE(timeouts[new_state]));
 
 	return NF_ACCEPT;
 
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index b859e409f0796..0c61a16fca400 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -505,7 +505,7 @@ nf_tcp_store_invalid(const struct nf_conn *ct,
 	const struct nf_tcp_net *tn = nf_tcp_pernet(nf_ct_net(ct));
 	bool be_liberal;
 
-	be_liberal = sender->flags & IP_CT_TCP_FLAG_BE_LIBERAL || tn->tcp_be_liberal;
+	be_liberal = sender->flags & IP_CT_TCP_FLAG_BE_LIBERAL || READ_ONCE(tn->tcp_be_liberal);
 	if (be_liberal)
 		return NFCT_TCP_ACCEPT;
 
@@ -904,7 +904,7 @@ static noinline bool tcp_new(struct nf_conn *ct, const struct sk_buff *skb,
 			ct->proto.tcp.seen[0].td_end;
 
 		tcp_options(skb, dataoff, th, &ct->proto.tcp.seen[0]);
-	} else if (tn->tcp_loose == 0) {
+	} else if (READ_ONCE(tn->tcp_loose) == 0) {
 		/* Don't try to pick up connections. */
 		return false;
 	} else {
@@ -979,7 +979,7 @@ void nf_conntrack_tcp_set_closing(struct nf_conn *ct)
 		timeouts = tn->timeouts;
 	}
 
-	timeout = timeouts[TCP_CONNTRACK_CLOSE];
+	timeout = READ_ONCE(timeouts[TCP_CONNTRACK_CLOSE]);
 	WRITE_ONCE(ct->timeout, timeout + nfct_time_stamp);
 
 	spin_unlock_bh(&ct->lock);
@@ -1010,6 +1010,7 @@ int nf_conntrack_tcp_packet(struct nf_conn *ct,
 	struct nf_tcp_invalid_log log = {};
 	unsigned int index, *timeouts;
 	bool lowered_timeout = false;
+	unsigned int retrans, unack;
 	enum nf_ct_tcp_action res;
 	enum ip_conntrack_dir dir;
 	const struct tcphdr *th;
@@ -1235,7 +1236,7 @@ int nf_conntrack_tcp_packet(struct nf_conn *ct,
 				break;
 
 			if (before(seq, ct->proto.tcp.seen[!dir].td_maxack) &&
-			    !tn->tcp_ignore_invalid_rst) {
+			    !READ_ONCE(tn->tcp_ignore_invalid_rst)) {
 				/* Invalid RST  */
 				spin_unlock_bh(&ct->lock);
 				nf_ct_l4proto_log_invalid(skb, ct, state, "invalid rst");
@@ -1322,22 +1323,24 @@ int nf_conntrack_tcp_packet(struct nf_conn *ct,
 	if (!timeouts)
 		timeouts = tn->timeouts;
 
-	if (ct->proto.tcp.retrans >= tn->tcp_max_retrans &&
-	    timeouts[new_state] > timeouts[TCP_CONNTRACK_RETRANS])
-		timeout = timeouts[TCP_CONNTRACK_RETRANS];
+	timeout = READ_ONCE(timeouts[new_state]);
+	retrans = READ_ONCE(timeouts[TCP_CONNTRACK_RETRANS]);
+	unack = READ_ONCE(timeouts[TCP_CONNTRACK_UNACK]);
+
+	if (ct->proto.tcp.retrans >= READ_ONCE(tn->tcp_max_retrans) &&
+	    timeout > retrans)
+		timeout = retrans;
 	else if (unlikely(index == TCP_RST_SET &&
 			  new_state == TCP_CONNTRACK_ESTABLISHED) &&
-		 timeouts[new_state] > timeouts[TCP_CONNTRACK_UNACK])
-		timeout = timeouts[TCP_CONNTRACK_UNACK];
+		 timeout > unack)
+		timeout = unack;
 	else if ((ct->proto.tcp.seen[0].flags | ct->proto.tcp.seen[1].flags) &
 		 IP_CT_TCP_FLAG_DATA_UNACKNOWLEDGED &&
-		 timeouts[new_state] > timeouts[TCP_CONNTRACK_UNACK])
-		timeout = timeouts[TCP_CONNTRACK_UNACK];
+		 timeout > unack)
+		timeout = unack;
 	else if (ct->proto.tcp.last_win == 0 &&
-		 timeouts[new_state] > timeouts[TCP_CONNTRACK_RETRANS])
-		timeout = timeouts[TCP_CONNTRACK_RETRANS];
-	else
-		timeout = timeouts[new_state];
+		 timeout > retrans)
+		timeout = retrans;
 	spin_unlock_bh(&ct->lock);
 
 	if (new_state != old_state)
@@ -1366,8 +1369,8 @@ int nf_conntrack_tcp_packet(struct nf_conn *ct,
 		 * pickup with loose=1. Avoid large ESTABLISHED timeout.
 		 */
 		if (new_state == TCP_CONNTRACK_ESTABLISHED &&
-		    timeout > timeouts[TCP_CONNTRACK_UNACK])
-			timeout = timeouts[TCP_CONNTRACK_UNACK];
+		    timeout > unack)
+			timeout = unack;
 	} else if (!test_bit(IPS_ASSURED_BIT, &ct->status)
 		   && (old_state == TCP_CONNTRACK_SYN_RECV
 		       || old_state == TCP_CONNTRACK_ESTABLISHED)
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 9ea4062752238..99eedaa2b1183 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -116,12 +116,12 @@ int nf_conntrack_udp_packet(struct nf_conn *ct,
 	 * stream. Set Assured.
 	 */
 	if (status & IPS_SEEN_REPLY) {
-		unsigned long extra = timeouts[UDP_CT_UNREPLIED];
+		unsigned long extra = READ_ONCE(timeouts[UDP_CT_UNREPLIED]);
 		bool stream = false;
 
 		/* Still active after two seconds? Extend timeout. */
 		if (time_after(jiffies, ct->proto.udp.stream_ts)) {
-			extra = timeouts[UDP_CT_REPLIED];
+			extra = READ_ONCE(timeouts[UDP_CT_REPLIED]);
 			stream = (status & IPS_ASSURED) == 0;
 		}
 
@@ -135,7 +135,7 @@ int nf_conntrack_udp_packet(struct nf_conn *ct,
 		if (stream && !test_and_set_bit(IPS_ASSURED_BIT, &ct->status))
 			nf_conntrack_event_cache(IPCT_ASSURED, ct);
 	} else {
-		nf_ct_refresh_acct(ct, ctinfo, skb, timeouts[UDP_CT_UNREPLIED]);
+		nf_ct_refresh_acct(ct, ctinfo, skb, READ_ONCE(timeouts[UDP_CT_UNREPLIED]));
 	}
 	return NF_ACCEPT;
 }
diff --git a/net/netfilter/nf_flow_table_core.c b/net/netfilter/nf_flow_table_core.c
index 0d72dc8ae47a1..fa25a641e9c38 100644
--- a/net/netfilter/nf_flow_table_core.c
+++ b/net/netfilter/nf_flow_table_core.c
@@ -322,11 +322,11 @@ unsigned long flow_offload_get_timeout(struct flow_offload *flow)
 	if (l4num == IPPROTO_TCP) {
 		struct nf_tcp_net *tn = nf_tcp_pernet(net);
 
-		timeout = tn->offload_timeout;
+		timeout = READ_ONCE(tn->offload_timeout);
 	} else if (l4num == IPPROTO_UDP) {
 		struct nf_udp_net *tn = nf_udp_pernet(net);
 
-		timeout = tn->offload_timeout;
+		timeout = READ_ONCE(tn->offload_timeout);
 	}
 
 	return timeout;
-- 
2.43.0

