Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=91.218.175.38
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794193279;
	b=pSJU6io2B56Pu/anJA2yp2mVe0iiN3vSDCL4jWgFlxc6Tkp/gXxe8c5VINUEk+ABLdk6
	 5S6Fi64wSQMBAOXJYIDkJOJp+ufbjdIwlJWYKDuyRK4OFPo267S9RfzAuLQ56H9ryipQS
	 BznuE1Jr/beouwhrimZx913Xri7xxl/j/ylxIC5sywBgiPvTUz2LVv1c85UBQZ1aQYsQC
	 vTDelqbAqiJQ0DtiK5+35HSmkGAaR07Y4rCubbV5A7uGvwTHflSC3ZKpljpsSwg++BdmU
	 /rXGKmgDcnVr087rfzNhbbD7W6ReH4ADDxsNci0niZa4VaBSttRLXD8Ze2kCV3T2Gtw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794193279;
	h=DMARC-Filter:X-Envelope-To:DKIM-Signature:X-Envelope-To:Received:
	 X-Mizu-Trace-ID:X-Migadu-Flow:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=ElpF8lyMTNM3CY/Q7H+PHvM2mganMySTQf0T9s8n4s8=;
	b=3AFMURm9UULCU4xAvRSo0Z3ssSPL9yDqN1DNuFlnhbOSEVYKeOX7kVOA2GfOjVHQJMB+
	 Y/qsExY73Mc5MrIWH35v6eJDBYcSPawKPmyeoXacsKCXFni2wrmI+DHrB1fKzJxHic3g8
	 rIhyoHER5qGy2pzi92ZxP/oRFrbWeBcOmmwEhe0f5TxJ92l0SdWEZfHdPgErKvuL361ZJ
	 xpu8CWmYyUl4Gmm/Xspo/gNgwmA/MF7TKRaRBPzA0L3kmDL26QTX4CevyGA+UzNoo3JCt
	 Sw+eQH9Cdx8r9HelQQwlbwPJleB+dCVZHgBO7Xo2mlrxBmF9/mk/RDI1v328Ui/tzkw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.dev;
	spf=pass smtp.mailfrom=linux.dev;
	dkim=pass header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=GrEN9fRA;
	arc=none smtp.remote-ip=91.218.175.38
Received: from mta0.migadu.com (out-38.mta0.migadu.com [91.218.175.38])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 227CE606A322
	for <lvs-devel@vger.kernel.org>; Mon,  9 Nov 2026 03:01:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 227CE606A322
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=GrEN9fRA
X-Envelope-To: lvs-devel@vger.kernel.org
DKIM-Signature: a=rsa-sha256; bh=Ih9CwEp2gbLM2jko2WNdjiHmZUiAMosQAIGReidnZCw=;
 c=simple/simple; d=linux.dev;
 h=from:to:subject:date:message-id:mime-version:content-type; s=key1;
 t=1794193276; v=1; x=1794798076;
 b=GrEN9fRA1xbsRTlRLhGI+gs7+LrSm0/oTo7akPy2plqWUJAglSn+tryBRS0yZN4/g4GSh4DF
 e73PdRhBWE05fz5VxKJKb0s2x1ucz8Ot02pyCjvWLZk4amvUZzwNCQ7m6iJObZEL9O6Dp5exw4C
 w3ESKNokQD75M5T+rYmf4/Fc=
X-Envelope-To: lvs-devel@vger.kernel.org
Received: by smtp.migadu.com with ESMTPS id 9046617f223305a1;
	Mon, 09 Nov 2026 03:01:15 +0000
X-Mizu-Trace-ID: 9046617f223305a1
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
Subject: [PATCH net-next 14/14] netfilter: cttimeout: annotate data-races around the default timeouts
Date: Mon,  9 Nov 2026 10:52:13 +0800
Message-ID: <20261109025425.328445-15-jiayuan.chen@linux.dev>
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

cttimeout_default_set() and cttimeout_default_get() hand the per-netns
default timeout arrays to the l4proto nlattr_to_obj() and obj_to_nlattr()
callbacks, which write and read them with plain accesses while the
nf_conntrack_*_timeout* sysctl handlers update the same fields with
WRITE_ONCE(). Use WRITE_ONCE() and READ_ONCE() in the callbacks.

KCSAN reports both sides when the UDP default timeouts are set over
nfnetlink while UDP traffic goes through conntrack, or while the sysctl
is written:

  BUG: KCSAN: data-race in nf_conntrack_udp_packet / udp_timeout_nlattr_to_obj

  write to 0xffffffffb0829bc4 of 4 bytes by task 457 on cpu 1:
   udp_timeout_nlattr_to_obj+0x3b/0xf0
   ctnl_timeout_parse_policy+0xc0/0x100
   cttimeout_default_set+0x8f/0xc0
   nfnetlink_rcv_msg+0x64c/0xc90
   netlink_rcv_skb+0x9c/0x1b0
   nfnetlink_rcv+0x9b/0x1e0
   netlink_unicast+0x418/0x5c0
   netlink_sendmsg+0x3fc/0x750
   ...

  read to 0xffffffffb0829bc4 of 4 bytes by task 459 on cpu 0:
   nf_conntrack_udp_packet+0x27b/0x550
   nf_conntrack_in+0x767/0xb20
   ipv4_conntrack_local+0xb0/0x120
   nf_hook_slow+0x7e/0x180
   ...

  value changed: 0x00001e46 -> 0x00001d4c

  BUG: KCSAN: data-race in proc_int_u2k_conv_uop / udp_timeout_nlattr_to_obj

  write (marked) to 0xffffffffb0829bc4 of 4 bytes by task 475 on cpu 1:
   proc_int_u2k_conv_uop+0x92/0xa0
   ...
   proc_dointvec_jiffies+0x15/0x30
   proc_sys_call_handler+0x282/0x3a0
   proc_sys_write+0x13/0x20
   ...

  read to 0xffffffffb0829bc4 of 4 bytes by task 474 on cpu 0:
   udp_timeout_nlattr_to_obj+0x2c/0xf0
   ctnl_timeout_parse_policy+0xc0/0x100
   cttimeout_default_set+0x8f/0xc0
   nfnetlink_rcv_msg+0x64c/0xc90
   ...

  value changed: 0x00001d4c -> 0x00001e46

Signed-off-by: Jiayuan Chen <jiayuan.chen@linux.dev>
---
 net/netfilter/nf_conntrack_proto_generic.c |  8 +--
 net/netfilter/nf_conntrack_proto_gre.c     | 16 ++---
 net/netfilter/nf_conntrack_proto_icmp.c    |  8 +--
 net/netfilter/nf_conntrack_proto_icmpv6.c  |  8 +--
 net/netfilter/nf_conntrack_proto_sctp.c    |  9 +--
 net/netfilter/nf_conntrack_proto_tcp.c     | 71 +++++++++++-----------
 net/netfilter/nf_conntrack_proto_udp.c     | 16 ++---
 7 files changed, 69 insertions(+), 67 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index cb260eb3d012c..08b8d44c9f402 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -27,11 +27,11 @@ static int generic_timeout_nlattr_to_obj(struct nlattr *tb[],
 		timeout = &gn->timeout;
 
 	if (tb[CTA_TIMEOUT_GENERIC_TIMEOUT])
-		*timeout =
-		    ntohl(nla_get_be32(tb[CTA_TIMEOUT_GENERIC_TIMEOUT])) * HZ;
+		WRITE_ONCE(*timeout,
+			   ntohl(nla_get_be32(tb[CTA_TIMEOUT_GENERIC_TIMEOUT])) * HZ);
 	else {
 		/* Set default generic timeout. */
-		*timeout = gn->timeout;
+		WRITE_ONCE(*timeout, READ_ONCE(gn->timeout));
 	}
 
 	return 0;
@@ -42,7 +42,7 @@ generic_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
 {
 	const unsigned int *timeout = data;
 
-	if (nla_put_be32(skb, CTA_TIMEOUT_GENERIC_TIMEOUT, htonl(*timeout / HZ)))
+	if (nla_put_be32(skb, CTA_TIMEOUT_GENERIC_TIMEOUT, htonl(READ_ONCE(*timeout) / HZ)))
 		goto nla_put_failure;
 
 	return 0;
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index d8bca1e29797b..e1b99c5a7c7a2 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -318,16 +318,16 @@ static int gre_timeout_nlattr_to_obj(struct nlattr *tb[],
 	if (!timeouts)
 		timeouts = gre_get_timeouts(net);
 	/* set default timeouts for GRE. */
-	timeouts[GRE_CT_UNREPLIED] = net_gre->timeouts[GRE_CT_UNREPLIED];
-	timeouts[GRE_CT_REPLIED] = net_gre->timeouts[GRE_CT_REPLIED];
+	WRITE_ONCE(timeouts[GRE_CT_UNREPLIED], READ_ONCE(net_gre->timeouts[GRE_CT_UNREPLIED]));
+	WRITE_ONCE(timeouts[GRE_CT_REPLIED], READ_ONCE(net_gre->timeouts[GRE_CT_REPLIED]));
 
 	if (tb[CTA_TIMEOUT_GRE_UNREPLIED]) {
-		timeouts[GRE_CT_UNREPLIED] =
-			ntohl(nla_get_be32(tb[CTA_TIMEOUT_GRE_UNREPLIED])) * HZ;
+		WRITE_ONCE(timeouts[GRE_CT_UNREPLIED],
+			   ntohl(nla_get_be32(tb[CTA_TIMEOUT_GRE_UNREPLIED])) * HZ);
 	}
 	if (tb[CTA_TIMEOUT_GRE_REPLIED]) {
-		timeouts[GRE_CT_REPLIED] =
-			ntohl(nla_get_be32(tb[CTA_TIMEOUT_GRE_REPLIED])) * HZ;
+		WRITE_ONCE(timeouts[GRE_CT_REPLIED],
+			   ntohl(nla_get_be32(tb[CTA_TIMEOUT_GRE_REPLIED])) * HZ);
 	}
 	return 0;
 }
@@ -338,9 +338,9 @@ gre_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
 	const unsigned int *timeouts = data;
 
 	if (nla_put_be32(skb, CTA_TIMEOUT_GRE_UNREPLIED,
-			 htonl(timeouts[GRE_CT_UNREPLIED] / HZ)) ||
+			 htonl(READ_ONCE(timeouts[GRE_CT_UNREPLIED]) / HZ)) ||
 	    nla_put_be32(skb, CTA_TIMEOUT_GRE_REPLIED,
-			 htonl(timeouts[GRE_CT_REPLIED] / HZ)))
+			 htonl(READ_ONCE(timeouts[GRE_CT_REPLIED]) / HZ)))
 		goto nla_put_failure;
 	return 0;
 
diff --git a/net/netfilter/nf_conntrack_proto_icmp.c b/net/netfilter/nf_conntrack_proto_icmp.c
index 0f6ef0443c6fa..0d8499b54f878 100644
--- a/net/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/netfilter/nf_conntrack_proto_icmp.c
@@ -327,11 +327,11 @@ static int icmp_timeout_nlattr_to_obj(struct nlattr *tb[],
 	if (tb[CTA_TIMEOUT_ICMP_TIMEOUT]) {
 		if (!timeout)
 			timeout = &in->timeout;
-		*timeout =
-			ntohl(nla_get_be32(tb[CTA_TIMEOUT_ICMP_TIMEOUT])) * HZ;
+		WRITE_ONCE(*timeout,
+			   ntohl(nla_get_be32(tb[CTA_TIMEOUT_ICMP_TIMEOUT])) * HZ);
 	} else if (timeout) {
 		/* Set default ICMP timeout. */
-		*timeout = in->timeout;
+		WRITE_ONCE(*timeout, READ_ONCE(in->timeout));
 	}
 	return 0;
 }
@@ -341,7 +341,7 @@ icmp_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
 {
 	const unsigned int *timeout = data;
 
-	if (nla_put_be32(skb, CTA_TIMEOUT_ICMP_TIMEOUT, htonl(*timeout / HZ)))
+	if (nla_put_be32(skb, CTA_TIMEOUT_ICMP_TIMEOUT, htonl(READ_ONCE(*timeout) / HZ)))
 		goto nla_put_failure;
 	return 0;
 
diff --git a/net/netfilter/nf_conntrack_proto_icmpv6.c b/net/netfilter/nf_conntrack_proto_icmpv6.c
index e4eebf13950cb..6ed0f7ba60c3d 100644
--- a/net/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/netfilter/nf_conntrack_proto_icmpv6.c
@@ -305,11 +305,11 @@ static int icmpv6_timeout_nlattr_to_obj(struct nlattr *tb[],
 	if (!timeout)
 		timeout = icmpv6_get_timeouts(net);
 	if (tb[CTA_TIMEOUT_ICMPV6_TIMEOUT]) {
-		*timeout =
-		    ntohl(nla_get_be32(tb[CTA_TIMEOUT_ICMPV6_TIMEOUT])) * HZ;
+		WRITE_ONCE(*timeout,
+			   ntohl(nla_get_be32(tb[CTA_TIMEOUT_ICMPV6_TIMEOUT])) * HZ);
 	} else {
 		/* Set default ICMPv6 timeout. */
-		*timeout = in->timeout;
+		WRITE_ONCE(*timeout, READ_ONCE(in->timeout));
 	}
 	return 0;
 }
@@ -319,7 +319,7 @@ icmpv6_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
 {
 	const unsigned int *timeout = data;
 
-	if (nla_put_be32(skb, CTA_TIMEOUT_ICMPV6_TIMEOUT, htonl(*timeout / HZ)))
+	if (nla_put_be32(skb, CTA_TIMEOUT_ICMPV6_TIMEOUT, htonl(READ_ONCE(*timeout) / HZ)))
 		goto nla_put_failure;
 	return 0;
 
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 047bf69113bf9..ea6dd1ef3df89 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -650,16 +650,17 @@ static int sctp_timeout_nlattr_to_obj(struct nlattr *tb[],
 
 	/* set default SCTP timeouts. */
 	for (i=0; i<SCTP_CONNTRACK_MAX; i++)
-		timeouts[i] = sn->timeouts[i];
+		WRITE_ONCE(timeouts[i], READ_ONCE(sn->timeouts[i]));
 
 	/* there's a 1:1 mapping between attributes and protocol states. */
 	for (i=CTA_TIMEOUT_SCTP_UNSPEC+1; i<CTA_TIMEOUT_SCTP_MAX+1; i++) {
 		if (tb[i]) {
-			timeouts[i] = ntohl(nla_get_be32(tb[i])) * HZ;
+			WRITE_ONCE(timeouts[i], ntohl(nla_get_be32(tb[i])) * HZ);
 		}
 	}
 
-	timeouts[CTA_TIMEOUT_SCTP_UNSPEC] = timeouts[CTA_TIMEOUT_SCTP_CLOSED];
+	WRITE_ONCE(timeouts[CTA_TIMEOUT_SCTP_UNSPEC],
+		   READ_ONCE(timeouts[CTA_TIMEOUT_SCTP_CLOSED]));
 	return 0;
 }
 
@@ -670,7 +671,7 @@ sctp_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
 	int i;
 
 	for (i=CTA_TIMEOUT_SCTP_UNSPEC+1; i<CTA_TIMEOUT_SCTP_MAX+1; i++) {
-	        if (nla_put_be32(skb, i, htonl(timeouts[i] / HZ)))
+		if (nla_put_be32(skb, i, htonl(READ_ONCE(timeouts[i]) / HZ)))
 			goto nla_put_failure;
 	}
         return 0;
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 0c61a16fca400..e1db372b9e530 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1523,55 +1523,56 @@ static int tcp_timeout_nlattr_to_obj(struct nlattr *tb[],
 		timeouts = tn->timeouts;
 	/* set default TCP timeouts. */
 	for (i=0; i<TCP_CONNTRACK_TIMEOUT_MAX; i++)
-		timeouts[i] = tn->timeouts[i];
+		WRITE_ONCE(timeouts[i], READ_ONCE(tn->timeouts[i]));
 
 	if (tb[CTA_TIMEOUT_TCP_SYN_SENT]) {
-		timeouts[TCP_CONNTRACK_SYN_SENT] =
-			ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_SYN_SENT]))*HZ;
+		WRITE_ONCE(timeouts[TCP_CONNTRACK_SYN_SENT],
+			   ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_SYN_SENT])) * HZ);
 	}
 
 	if (tb[CTA_TIMEOUT_TCP_SYN_RECV]) {
-		timeouts[TCP_CONNTRACK_SYN_RECV] =
-			ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_SYN_RECV]))*HZ;
+		WRITE_ONCE(timeouts[TCP_CONNTRACK_SYN_RECV],
+			   ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_SYN_RECV])) * HZ);
 	}
 	if (tb[CTA_TIMEOUT_TCP_ESTABLISHED]) {
-		timeouts[TCP_CONNTRACK_ESTABLISHED] =
-			ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_ESTABLISHED]))*HZ;
+		WRITE_ONCE(timeouts[TCP_CONNTRACK_ESTABLISHED],
+			   ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_ESTABLISHED])) * HZ);
 	}
 	if (tb[CTA_TIMEOUT_TCP_FIN_WAIT]) {
-		timeouts[TCP_CONNTRACK_FIN_WAIT] =
-			ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_FIN_WAIT]))*HZ;
+		WRITE_ONCE(timeouts[TCP_CONNTRACK_FIN_WAIT],
+			   ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_FIN_WAIT])) * HZ);
 	}
 	if (tb[CTA_TIMEOUT_TCP_CLOSE_WAIT]) {
-		timeouts[TCP_CONNTRACK_CLOSE_WAIT] =
-			ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_CLOSE_WAIT]))*HZ;
+		WRITE_ONCE(timeouts[TCP_CONNTRACK_CLOSE_WAIT],
+			   ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_CLOSE_WAIT])) * HZ);
 	}
 	if (tb[CTA_TIMEOUT_TCP_LAST_ACK]) {
-		timeouts[TCP_CONNTRACK_LAST_ACK] =
-			ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_LAST_ACK]))*HZ;
+		WRITE_ONCE(timeouts[TCP_CONNTRACK_LAST_ACK],
+			   ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_LAST_ACK])) * HZ);
 	}
 	if (tb[CTA_TIMEOUT_TCP_TIME_WAIT]) {
-		timeouts[TCP_CONNTRACK_TIME_WAIT] =
-			ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_TIME_WAIT]))*HZ;
+		WRITE_ONCE(timeouts[TCP_CONNTRACK_TIME_WAIT],
+			   ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_TIME_WAIT])) * HZ);
 	}
 	if (tb[CTA_TIMEOUT_TCP_CLOSE]) {
-		timeouts[TCP_CONNTRACK_CLOSE] =
-			ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_CLOSE]))*HZ;
+		WRITE_ONCE(timeouts[TCP_CONNTRACK_CLOSE],
+			   ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_CLOSE])) * HZ);
 	}
 	if (tb[CTA_TIMEOUT_TCP_SYN_SENT2]) {
-		timeouts[TCP_CONNTRACK_SYN_SENT2] =
-			ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_SYN_SENT2]))*HZ;
+		WRITE_ONCE(timeouts[TCP_CONNTRACK_SYN_SENT2],
+			   ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_SYN_SENT2])) * HZ);
 	}
 	if (tb[CTA_TIMEOUT_TCP_RETRANS]) {
-		timeouts[TCP_CONNTRACK_RETRANS] =
-			ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_RETRANS]))*HZ;
+		WRITE_ONCE(timeouts[TCP_CONNTRACK_RETRANS],
+			   ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_RETRANS])) * HZ);
 	}
 	if (tb[CTA_TIMEOUT_TCP_UNACK]) {
-		timeouts[TCP_CONNTRACK_UNACK] =
-			ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_UNACK]))*HZ;
+		WRITE_ONCE(timeouts[TCP_CONNTRACK_UNACK],
+			   ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_UNACK])) * HZ);
 	}
 
-	timeouts[CTA_TIMEOUT_TCP_UNSPEC] = timeouts[CTA_TIMEOUT_TCP_SYN_SENT];
+	WRITE_ONCE(timeouts[CTA_TIMEOUT_TCP_UNSPEC],
+		   READ_ONCE(timeouts[CTA_TIMEOUT_TCP_SYN_SENT]));
 	return 0;
 }
 
@@ -1581,27 +1582,27 @@ tcp_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
 	const unsigned int *timeouts = data;
 
 	if (nla_put_be32(skb, CTA_TIMEOUT_TCP_SYN_SENT,
-			htonl(timeouts[TCP_CONNTRACK_SYN_SENT] / HZ)) ||
+			htonl(READ_ONCE(timeouts[TCP_CONNTRACK_SYN_SENT]) / HZ)) ||
 	    nla_put_be32(skb, CTA_TIMEOUT_TCP_SYN_RECV,
-			 htonl(timeouts[TCP_CONNTRACK_SYN_RECV] / HZ)) ||
+			 htonl(READ_ONCE(timeouts[TCP_CONNTRACK_SYN_RECV]) / HZ)) ||
 	    nla_put_be32(skb, CTA_TIMEOUT_TCP_ESTABLISHED,
-			 htonl(timeouts[TCP_CONNTRACK_ESTABLISHED] / HZ)) ||
+			 htonl(READ_ONCE(timeouts[TCP_CONNTRACK_ESTABLISHED]) / HZ)) ||
 	    nla_put_be32(skb, CTA_TIMEOUT_TCP_FIN_WAIT,
-			 htonl(timeouts[TCP_CONNTRACK_FIN_WAIT] / HZ)) ||
+			 htonl(READ_ONCE(timeouts[TCP_CONNTRACK_FIN_WAIT]) / HZ)) ||
 	    nla_put_be32(skb, CTA_TIMEOUT_TCP_CLOSE_WAIT,
-			 htonl(timeouts[TCP_CONNTRACK_CLOSE_WAIT] / HZ)) ||
+			 htonl(READ_ONCE(timeouts[TCP_CONNTRACK_CLOSE_WAIT]) / HZ)) ||
 	    nla_put_be32(skb, CTA_TIMEOUT_TCP_LAST_ACK,
-			 htonl(timeouts[TCP_CONNTRACK_LAST_ACK] / HZ)) ||
+			 htonl(READ_ONCE(timeouts[TCP_CONNTRACK_LAST_ACK]) / HZ)) ||
 	    nla_put_be32(skb, CTA_TIMEOUT_TCP_TIME_WAIT,
-			 htonl(timeouts[TCP_CONNTRACK_TIME_WAIT] / HZ)) ||
+			 htonl(READ_ONCE(timeouts[TCP_CONNTRACK_TIME_WAIT]) / HZ)) ||
 	    nla_put_be32(skb, CTA_TIMEOUT_TCP_CLOSE,
-			 htonl(timeouts[TCP_CONNTRACK_CLOSE] / HZ)) ||
+			 htonl(READ_ONCE(timeouts[TCP_CONNTRACK_CLOSE]) / HZ)) ||
 	    nla_put_be32(skb, CTA_TIMEOUT_TCP_SYN_SENT2,
-			 htonl(timeouts[TCP_CONNTRACK_SYN_SENT2] / HZ)) ||
+			 htonl(READ_ONCE(timeouts[TCP_CONNTRACK_SYN_SENT2]) / HZ)) ||
 	    nla_put_be32(skb, CTA_TIMEOUT_TCP_RETRANS,
-			 htonl(timeouts[TCP_CONNTRACK_RETRANS] / HZ)) ||
+			 htonl(READ_ONCE(timeouts[TCP_CONNTRACK_RETRANS]) / HZ)) ||
 	    nla_put_be32(skb, CTA_TIMEOUT_TCP_UNACK,
-			 htonl(timeouts[TCP_CONNTRACK_UNACK] / HZ)))
+			 htonl(READ_ONCE(timeouts[TCP_CONNTRACK_UNACK]) / HZ)))
 		goto nla_put_failure;
 	return 0;
 
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 99eedaa2b1183..777b21da3bcff 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -155,16 +155,16 @@ static int udp_timeout_nlattr_to_obj(struct nlattr *tb[],
 		timeouts = un->timeouts;
 
 	/* set default timeouts for UDP. */
-	timeouts[UDP_CT_UNREPLIED] = un->timeouts[UDP_CT_UNREPLIED];
-	timeouts[UDP_CT_REPLIED] = un->timeouts[UDP_CT_REPLIED];
+	WRITE_ONCE(timeouts[UDP_CT_UNREPLIED], READ_ONCE(un->timeouts[UDP_CT_UNREPLIED]));
+	WRITE_ONCE(timeouts[UDP_CT_REPLIED], READ_ONCE(un->timeouts[UDP_CT_REPLIED]));
 
 	if (tb[CTA_TIMEOUT_UDP_UNREPLIED]) {
-		timeouts[UDP_CT_UNREPLIED] =
-			ntohl(nla_get_be32(tb[CTA_TIMEOUT_UDP_UNREPLIED])) * HZ;
+		WRITE_ONCE(timeouts[UDP_CT_UNREPLIED],
+			   ntohl(nla_get_be32(tb[CTA_TIMEOUT_UDP_UNREPLIED])) * HZ);
 	}
 	if (tb[CTA_TIMEOUT_UDP_REPLIED]) {
-		timeouts[UDP_CT_REPLIED] =
-			ntohl(nla_get_be32(tb[CTA_TIMEOUT_UDP_REPLIED])) * HZ;
+		WRITE_ONCE(timeouts[UDP_CT_REPLIED],
+			   ntohl(nla_get_be32(tb[CTA_TIMEOUT_UDP_REPLIED])) * HZ);
 	}
 	return 0;
 }
@@ -175,9 +175,9 @@ udp_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
 	const unsigned int *timeouts = data;
 
 	if (nla_put_be32(skb, CTA_TIMEOUT_UDP_UNREPLIED,
-			 htonl(timeouts[UDP_CT_UNREPLIED] / HZ)) ||
+			 htonl(READ_ONCE(timeouts[UDP_CT_UNREPLIED]) / HZ)) ||
 	    nla_put_be32(skb, CTA_TIMEOUT_UDP_REPLIED,
-			 htonl(timeouts[UDP_CT_REPLIED] / HZ)))
+			 htonl(READ_ONCE(timeouts[UDP_CT_REPLIED]) / HZ)))
 		goto nla_put_failure;
 	return 0;
 
-- 
2.43.0

