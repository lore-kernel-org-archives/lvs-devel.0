Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=95.215.58.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794193020;
	b=3cWcC5MU2y9ob6y/BlQITUDo49FGz/sr39xVrcnhn6frUwEdIUO8B1aXJNnjD2vqh24l
	 To26a2Ra4ncdx2mh6F3SuNf6iF9NHQhpeoJrW73q0Zg/f3whNKi2Cbnk6mNLeWLrschTo
	 kwBpfLJ1jr9US6vdbW9S3fgbGMtDLlAuQL7S4ygKLo0z1OAoUF4QOCWDp2hzFLTS4cG9f
	 dBc73N/QNbygeTc5eQ+vD1Zq8IaQM3kwdFu0AvPDUsansM6muFg7vAcJLMXVmR3CVhHe8
	 Pa2vZJSJULRmDcRfjNKV4bGmoyjzle/1mNE9y93S32ZE3bD1LljqzTMxKlLY1Budbcw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794193020;
	h=DMARC-Filter:X-Envelope-To:DKIM-Signature:X-Envelope-To:Received:
	 X-Mizu-Trace-ID:X-Migadu-Flow:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=amf3Y3vtqWCfA+hYsW3iaFHpj/KPEsqLUTq3odUhe94=;
	b=5Hwy3pfkeTYOvoRq1mYtkdhkZH0L+VVh7d/wl8eIi0ocJXE6ZymiWwmYV+imA0p8B2bQ
	 TCjlk5RFxF72SLEZiWK7z6BkcTHp8oToCRjbCJhLzlWzQivppDq54W0sf/IEJcoonFBt6
	 bXVGS9v1+p1jPs5NK29msXMP/m/HsHCfAHheSfeRK3FTVgrJl7WWPa1RuxiOQ6eRVyKVv
	 vgIDI6T4Dto8FOqaf3WX8VU62mf3Sa7G7YLdRlm1Rmsj8EAp4FAtD0/DGgBoEOEu+MRj4
	 NG4KBlaMx9pFzbfbqemNrD69s8quZhYq7qtJPEsSDB8u7rA3L+NI9sqYQC2r2OkrpLg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.dev;
	spf=pass smtp.mailfrom=linux.dev;
	dkim=pass header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=n6+sH+Ns;
	arc=none smtp.remote-ip=95.215.58.39
Received: from mta1.migadu.com (out-39.mta1.migadu.com [95.215.58.39])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4138B606A32A
	for <lvs-devel@vger.kernel.org>; Mon,  9 Nov 2026 02:56:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4138B606A32A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=n6+sH+Ns
X-Envelope-To: lvs-devel@vger.kernel.org
DKIM-Signature: a=rsa-sha256; bh=gggsKdF+pSJpQv0nyo1SbJUQxyRR8b7X9hlpNF2qsEM=;
 c=simple/simple; d=linux.dev;
 h=from:to:subject:date:message-id:mime-version:content-type; s=key1;
 t=1794193018; v=1; x=1794797818;
 b=n6+sH+Ns42vQuuPh1M9IBHLusBfQG2hdiGYrRtTS2sxa+am2Yahzab+JT4kpQWsAwTQJBi/B
 An+lIKaf4MsLr82tv0KvMad01v/w8AkaF9o146wk80sAz0SbphfN0I4pGCEprCcjN3XP8GPWOuK
 xWcm3TgrFvX/XGbSmy0i2BcY=
X-Envelope-To: lvs-devel@vger.kernel.org
Received: by smtp.migadu.com with ESMTPS id 3ab2d1445e65b102;
	Mon, 09 Nov 2026 02:56:58 +0000
X-Mizu-Trace-ID: 3ab2d1445e65b102
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
Subject: [PATCH net-next 04/14] ipv6: annotate data-races around icmpv6 reply sysctls
Date: Mon,  9 Nov 2026 10:52:03 +0800
Message-ID: <20261109025425.328445-5-jiayuan.chen@linux.dev>
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

icmpv6_echo_ignore_all, icmpv6_echo_ignore_multicast,
icmpv6_echo_ignore_anycast, anycast_src_echo_reply and fwmark_reflect are
read without any lock while their sysctl handlers update them with
WRITE_ONCE(). Add READ_ONCE() to the readers.

KCSAN reports it when net.ipv6.icmp.echo_ignore_all is changed while
ICMPv6 echo requests are received:

  BUG: KCSAN: data-race in icmpv6_rcv / proc_dou8vec_minmax

  write (marked) to 0xffffffff8ee2940d of 1 bytes by task 504 on cpu 0:
   proc_dou8vec_minmax+0x1ab/0x1f0
   proc_sys_call_handler+0x282/0x3a0
   proc_sys_write+0x13/0x20
   ...

  read to 0xffffffff8ee2940d of 1 bytes by interrupt on cpu 3:
   icmpv6_rcv+0x99d/0xd40
   ip6_protocol_deliver_rcu+0x787/0x9a0
   ip6_input_finish+0xb0/0x1b0
   ip6_input+0xa8/0x250
   ipv6_rcv+0x14b/0x1c0
   __netif_receive_skb_one_core+0x8f/0xe0
   ...

  value changed: 0x01 -> 0x00

Signed-off-by: Jiayuan Chen <jiayuan.chen@linux.dev>
---
 include/net/ipv6.h |  2 +-
 net/ipv6/icmp.c    | 10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 579df1516d251..b77dc5c3ea268 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -199,7 +199,7 @@ struct sk_buff *ip6_frag_next(struct sk_buff *skb,
 			      struct ip6_frag_state *state);
 
 #define IP6_REPLY_MARK(net, mark) \
-	((net)->ipv6.sysctl.fwmark_reflect ? (mark) : 0)
+	(READ_ONCE((net)->ipv6.sysctl.fwmark_reflect) ? (mark) : 0)
 
 #include <net/sock.h>
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index a95b0351824f3..3e95b1191c4f2 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -938,17 +938,17 @@ static enum skb_drop_reason icmpv6_echo_reply(struct sk_buff *skb)
 	u8 type;
 
 	if (ipv6_addr_is_multicast(&ipv6_hdr(skb)->daddr) &&
-	    net->ipv6.sysctl.icmpv6_echo_ignore_multicast)
+	    READ_ONCE(net->ipv6.sysctl.icmpv6_echo_ignore_multicast))
 		return reason;
 
 	saddr = &ipv6_hdr(skb)->daddr;
 
 	acast = ipv6_anycast_destination(skb_dst(skb), saddr);
-	if (acast && net->ipv6.sysctl.icmpv6_echo_ignore_anycast)
+	if (acast && READ_ONCE(net->ipv6.sysctl.icmpv6_echo_ignore_anycast))
 		return reason;
 
 	if (!ipv6_unicast_destination(skb) &&
-	    !(net->ipv6.sysctl.anycast_src_echo_reply && acast))
+	    !(READ_ONCE(net->ipv6.sysctl.anycast_src_echo_reply) && acast))
 		saddr = NULL;
 
 	if (icmph->icmp6_type == ICMPV6_EXT_ECHO_REQUEST)
@@ -1152,11 +1152,11 @@ static int icmpv6_rcv(struct sk_buff *skb)
 
 	switch (type) {
 	case ICMPV6_ECHO_REQUEST:
-		if (!net->ipv6.sysctl.icmpv6_echo_ignore_all)
+		if (!READ_ONCE(net->ipv6.sysctl.icmpv6_echo_ignore_all))
 			reason = icmpv6_echo_reply(skb);
 		break;
 	case ICMPV6_EXT_ECHO_REQUEST:
-		if (!net->ipv6.sysctl.icmpv6_echo_ignore_all &&
+		if (!READ_ONCE(net->ipv6.sysctl.icmpv6_echo_ignore_all) &&
 		    READ_ONCE(net->ipv4.sysctl_icmp_echo_enable_probe))
 			reason = icmpv6_echo_reply(skb);
 		break;
-- 
2.43.0

