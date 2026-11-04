Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793823352;
	b=rcEb1sN+yQoaNUs7zg4+qZNu/JvHOrGvRoCnAEVSB6+c6hV6FNBrP7tEOjL0oNc8BbN6
	 ZF1N7ndxdRsje9YMiZzHq20A9iI9eXkVKNZ8BjGUI+vvgtv6W18oIHsrhnoqNOI5HN6py
	 y5tHVM1lv8VKjoertwxRitLB8cFRYo07wwqnsBqxWDccF8CFuYwh2GcQ6dA36LUc64POi
	 YgozaFlTNsGWMdVgtsMKTROAO7E9sijqoi6tZ6cR2Q8imNM54vPLkUrKgmRYGfEmn9bdP
	 AaPBlk2EGmZwE3MWcFkiQF7oV/W+vySr2Sl83emyJDJgHxTPu2SNQ8H5OU120xVsS3w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793823352;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=J+F/M6JjHFkqB5PZQhlDSfh5yN51kNnyBd6UV+ZKrmI=;
	b=W6VSzHweAkoEPm9hiwxewU/IZxNT6co6dvk56rDBfawNQpBIjVYK/1SAWV2KsBeDAd0X
	 CZmzISUi63nxCtMwlfitY8PGJQLJ7jFliVi5/viuK9wMVqxWfaJwxbmXNZ8EGqIzqrLnv
	 qCQdKYjbEnyCjKGakqvs5oRPJ+GGLd6OQ91eD2CuSnZOS5k3Ey9B0/sJ0LAOnjVvpVzb8
	 ib6UVpozqtM2sc0qCPsYQu94axP4qAB3hqIGikl1PCMzwTV/Kk1x5+Q3V0XMpawNjNO0/
	 b+bIE2e93uREd8yKEJ9OldErij+kEWMcXgnUX8pEUsyKpjWBdYt++Fm9ezPldqeu/9w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=D8xOOqIt;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1F61A6071A07;
	Wed,  4 Nov 2026 20:15:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1F61A6071A07
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=D8xOOqIt
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id BCE2D21DBE;
	Wed, 04 Nov 2026 22:15:48 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=J+F/M6Jj
	HFkqB5PZQhlDSfh5yN51kNnyBd6UV+ZKrmI=; b=D8xOOqItO0zk5Kkb5mZtdipp
	2oklsITritx13ZhmFokOS9Sv7CyIkD0dvbGA86kEqF6bymY9BU+NJAr8Qdbmm3tD
	pz6T6iY9+5z2bMiG5uxvoRn86LL292wLOt+Fr62iAJm4gaaQ6GabL//Ti61BRiO7
	DRUaTVIgZi5TB05TM5idAQ65CNfUUUWzcwCqwgEFlkHFyV/qCtlv4pkw9xCfIldY
	V9DuH/ijW88QG9NMmid1e8rNizVKviBwJmmep90UFLVxN8tx5ZqkFb1fDfh8qvZY
	aj30KgQbAeEy+u8f2lawM265mO0nmGydNOmEfx20ifwumeNddp+dGHviKNtjkW/Z
	v+bQ5Ch/OvvcrhIW/1VZbSH3t0iBmTCDh5moD/Ym/7oasT2DhPtHG1RvboreIUJI
	ei4vGiPy3MX8iKgmAbMLAg0YlX85g6YtHyszI4oRBvHuoVxvR4K/S7wfhSCaxar9
	DJqek51r8zBknyFWHLaTt2J6UG+/xjsGetpeVDj131OqMiYot9d/s385cbVxiAcY
	pxE9ICpxwPKklBCHopm7rgOztXVC2MNIDt5wZrJSEDRGJf5HA4PFSXYR1OTCqOSh
	evIb8G54JQTiyRAp64++Ahgyn7X/BErEonO1qsoIJgwC9dzxa1h/w2K2XhpOPo1t
	ONPJzRSqSQ5d6rC8hNg=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 04 Nov 2026 22:15:48 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 2791D60B48;
	Wed,  4 Nov 2026 22:15:48 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6A4KFleC147314;
	Wed, 4 Nov 2026 22:15:47 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 6A4KFlNw147313;
	Wed, 4 Nov 2026 22:15:47 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf v2] ipvs: do not create conns from packets with port 0
Date: Wed,  4 Nov 2026 22:15:30 +0200
Message-ID: <20261104201530.147292-1-ja@ssi.bg>
X-Mailer: git-send-email 2.56.0
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

We should disallow normal connections with cport 0 to be
created from packets by the scheduler (from clients) or
by ip_vs_new_conn_out (from real servers) because later
such traffic can not hit the connection due to the
NO_CPORT requirement. As result, it can lead to duplicate
connection for every packet. Do the same for vport 0.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20261103140308.591690-3-pablo%40netfilter.org
Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260925141115.16126-1-axel.mierczuk%401password.com
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 Changes in v2:
 * Drop the packets with port 0 instead of passing them to the local
   server

 net/netfilter/ipvs/ip_vs_core.c       | 3 ++-
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 4 +++-
 net/netfilter/ipvs/ip_vs_proto_tcp.c  | 4 +++-
 net/netfilter/ipvs/ip_vs_proto_udp.c  | 3 ++-
 4 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index fd503f0efb57..0ed5f6c95ad8 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1305,6 +1305,7 @@ static inline bool is_new_conn_expected(const struct ip_vs_conn *cp,
  *    In fwmark-VS actual vaddr and vport are unknown to IPVS
  * 2) Real Server and Virtual Service were NOT configured without port:
  *    This is to allow match of different VS to the same RS ip-addr
+ * 3) Client port is not 0
  */
 struct ip_vs_conn *ip_vs_new_conn_out(struct ip_vs_service *svc,
 				      struct ip_vs_dest *dest,
@@ -1328,7 +1329,7 @@ struct ip_vs_conn *ip_vs_new_conn_out(struct ip_vs_service *svc,
 	/* check pre-requisites are satisfied */
 	if (svc->fwmark)
 		return NULL;
-	if (!vport || !dport)
+	if (!vport || !dport || !cport)
 		return NULL;
 
 	/* for persistent service first create connection template */
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index fb8af6b15a39..31431094073d 100644
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
@@ -42,7 +43,8 @@ sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 			skb, iph->len, sizeof(_ports), &_ports);
 	}
 
-	if (!ports) {
+	/* Do not create connection for port 0 */
+	if (!ports || !ports[0] || !ports[1]) {
 		*verdict = NF_DROP;
 		return 0;
 	}
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index fec0e8b47b71..6f1cc9165e0c 100644
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
@@ -57,7 +58,8 @@ tcp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 			skb, iph->len, sizeof(_ports), &_ports);
 	}
 
-	if (!ports) {
+	/* Do not create connection for port 0 */
+	if (!ports || !ports[0] || !ports[1]) {
 		*verdict = NF_DROP;
 		return 0;
 	}
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index f32785682402..0e7b4427d258 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -47,7 +47,8 @@ udp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 			skb, iph->len, sizeof(_ports), &_ports);
 	}
 
-	if (!ports) {
+	/* Do not create connection for port 0 */
+	if (!ports || !ports[0] || !ports[1]) {
 		*verdict = NF_DROP;
 		return 0;
 	}
-- 
2.56.0


