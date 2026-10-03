Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5C19C1E1024;
	Sat,  3 Oct 2026 09:50:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791021040; cv=none; b=nzEM+7ZSrqiVKLZ2+fenwAodAtmP10ccWHtXADDAGSVnhfbcmo7A0VDDeDJ/cITnpxSfYng6JQoOffn6ia8oBTMhpp2OeAqJ7fgY0LBX02ubrKL3M2+8/6r5BG9VD8ts/tIeHgwESp6Z357o2LCyB9j3XvB6FM4kpq2WMCKmzN8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791021040; c=relaxed/simple;
	bh=5Kv4fuBqkMaeNBiO+e/QHg30VS7aF45uXKESuqpv2EI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Sp+layad8FByk/onMIXS1AlQSxSIM+3hHc2kDCV/wpBnIuILj1ugeTTQhGlDixQjozL33oRUUMPmoaL9otIUtjmVmtXsAsJTZwakpDrBJVbdZIXZMQpFCgJZLHwzkAq+ofiUoX2t38dRP2MeURkgfmJStjjrFIrPiD3J7s8baLw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=3moMhFpp; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="3moMhFpp"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 63B2E22277;
	Sat, 03 Oct 2026 12:50:30 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=hv8Sf+tI
	GKjDEgGuRBy3CeL92C9s3sV5Qd5qcCnxqSQ=; b=3moMhFppBynUNDfhrMn3vFYo
	2C8CJ8E7q+uRhsK+sC084fdx7IOLYf0zBrnDMd3YJojYTMZCKJg5FZhAqQgpANkf
	JcwYJce/RfA5uZskhiNPdw3nAe9lpjknZc53pc0LlaNZzKlFxT9BJj6bwYSr9Os+
	WhYIPBPgvBxRyFAV/IlffKWqLyF7hIolAAJP0N+wVbyBiZlg+dqRh0N2ThTFcK+J
	2W8SSG6VZUpRBFsIhNuvRaaoZ4R0oVCIUAX1RtsE5RQ6UN+pbCM+FySoJBfd67WF
	miufDY8yNo4Bu/slMMetnyyJBt3inyJLiwgKvpGdAClKF9vr7Yr+ysPHd+UXafo+
	DTK5jnaqFBm05UdSFYfBjAQ7zEAtZ5wUp9bW8kj/h23rQcDOmhC7vSj5rjXV16G4
	4jzRUf3lLnGZfybXeZAzYxqGIUBjoPP0hxQwfMZq0f7JpFVUaaBRFKHPcYSzJsKP
	gxXwtkhS3HKfuCIqh/Q6P0/xAIHh5JmiuIHcIiwacJXG34w1RxTNiNqRsykkeck2
	F0oHE/OsYn58k967HocWp1XTD4flnh+FU1LY01b2QXSsEHErLorQSk/Lv9es0Dkr
	2hOujyRb7/6Z33bBNGuOroIHwmO4E3x3l82B9mIUlSrgWawX5XRlMeXfTrjtXNyg
	HL4oCeIQcwwPWsvatpU=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 03 Oct 2026 12:50:30 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id E05896088F;
	Sat,  3 Oct 2026 12:50:30 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6939oTtj020962;
	Sat, 3 Oct 2026 12:50:29 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 6939oOnv020605;
	Sat, 3 Oct 2026 12:50:24 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Axel Mierczuk <axel.mierczuk@1password.com>
Subject: [PATCH nf] ipvs: do not create conns from packets with port 0
Date: Sat,  3 Oct 2026 12:50:01 +0300
Message-ID: <20261003095001.20587-1-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

We should disallow normal connections with cport 0 to be
created from packets by the scheduler (from clients) or
by ip_vs_new_conn_out (from real servers) because later
such traffic can not hit the connection due to the
NO_CPORT requirement. As result, it can lead to duplicate
connection for every packet. Do the same for vport 0.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260925141115.16126-1-axel.mierczuk%401password.com
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_core.c       | 3 ++-
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 5 +++++
 net/netfilter/ipvs/ip_vs_proto_tcp.c  | 5 +++++
 net/netfilter/ipvs/ip_vs_proto_udp.c  | 4 ++++
 4 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 397d5392ebed..8cdcab7d6edf 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1306,6 +1306,7 @@ static inline bool is_new_conn_expected(const struct ip_vs_conn *cp,
  *    In fwmark-VS actual vaddr and vport are unknown to IPVS
  * 2) Real Server and Virtual Service were NOT configured without port:
  *    This is to allow match of different VS to the same RS ip-addr
+ * 3) Client port is not 0
  */
 struct ip_vs_conn *ip_vs_new_conn_out(struct ip_vs_service *svc,
 				      struct ip_vs_dest *dest,
@@ -1329,7 +1330,7 @@ struct ip_vs_conn *ip_vs_new_conn_out(struct ip_vs_service *svc,
 	/* check pre-requisites are satisfied */
 	if (svc->fwmark)
 		return NULL;
-	if (!vport || !dport)
+	if (!vport || !dport || !cport)
 		return NULL;
 
 	/* for persistent service first create connection template */
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index fb8af6b15a39..83d1443ebe01 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -30,6 +30,7 @@ sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 			sch = skb_header_pointer(skb, iph->len + sizeof(_sctph),
 						 sizeof(_schunkh), &_schunkh);
 			if (sch) {
+				/* Accept packet without scheduling? */
 				if (sch->type == SCTP_CID_ABORT ||
 				    !(sysctl_sloppy_sctp(ipvs) ||
 				      sch->type == SCTP_CID_INIT))
@@ -47,6 +48,10 @@ sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		return 0;
 	}
 
+	/* Do not create connection for port 0, skip the packet */
+	if (!ports[0] || !ports[1])
+		return 1;
+
 	if (likely(!ip_vs_iph_inverse(iph)))
 		svc = ip_vs_service_find(ipvs, af, skb->mark, iph->protocol,
 					 &iph->daddr, ports[1]);
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index fec0e8b47b71..2e55b62445c6 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -48,6 +48,7 @@ tcp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 	if (likely(!ip_vs_iph_icmp(iph))) {
 		th = skb_header_pointer(skb, iph->len, sizeof(_tcph), &_tcph);
 		if (th) {
+			/* Accept packet without scheduling? */
 			if (th->rst || !(sysctl_sloppy_tcp(ipvs) || th->syn))
 				return 1;
 			ports = &th->source;
@@ -62,6 +63,10 @@ tcp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		return 0;
 	}
 
+	/* Do not create connection for port 0, skip the packet */
+	if (!ports[0] || !ports[1])
+		return 1;
+
 	/* No !th->ack check to allow scheduling on SYN+ACK for Active FTP */
 
 	if (likely(!ip_vs_iph_inverse(iph)))
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index f32785682402..92c0b76c1a02 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -52,6 +52,10 @@ udp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		return 0;
 	}
 
+	/* Do not create connection for port 0, skip the packet */
+	if (!ports[0] || !ports[1])
+		return 1;
+
 	if (likely(!ip_vs_iph_inverse(iph)))
 		svc = ip_vs_service_find(ipvs, af, skb->mark, iph->protocol,
 					 &iph->daddr, ports[1]);
-- 
2.55.0


