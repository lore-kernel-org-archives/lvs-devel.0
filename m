Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793920572;
	b=pUuq2jDnRlxKr6UeMNe1NkcAaUFWlHSeQdxG0pdDlDd+MgEWbg8x0WMrTPy8SUKAI8j3
	 dxeffQ11dbHkSvx/djsLlI/4o0dk8IMasxkYRi3jzIO/LdGogkm4YhZEeD4Xvyv9bdctX
	 a/XgLEuIW1YkNltuGOsaqyy/iYp2CeNKP8z9XTswZPzrZsymOr6sgS0OvVVc0pFbhFI/J
	 te6d3dvDq3S3UUm2z9D5ItEBJb0Gh5UvYgfrhlsqvIq5/gTzPWB/gASSv4sxtMTSLER9f
	 5aMJ0zs+WwANJH1OUd6pSQQYeVd47fb1GXrY0s6oC2+vKjB8taXJVvmP4yrPQqNdNtQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793920572;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=D7Q++FD/jRVg3s80kvw4ZQIirLuCUU1KeM0XdAHkGM8=;
	b=JUAASThtYnK/YWuFOUVj1se4OVQve+39dpJCOGJlcWgLYY7ArupZY9fiBq0NcRr+Ow/u
	 kG4dwQDKzaWV9qlPzTvqv86OqO9uZDb1i4rrFLK+MxbQR+v8GoRfW2m1RRN3OS06NGWON
	 ADcC82BDr9HV0C5dCEC4H5QQzdK2Y3e4Lkzr/t0TTOKLTnGZtb54h7+NrUF8H/LQ5LBbj
	 jb+ZZmALpIE0LInMHi1VHVRaXDs2OAN1iF4AH5u+mosCHy+h5AqIDlYE8ihGN5nV3blWt
	 nCJfHN1yLzmkQotUPkwre2MB9oHrHPMaFAu6JiG0eZt8ZIxMJc6+DuFOC/xJrbbI6nw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 805CC606A329;
	Thu,  5 Nov 2026 23:16:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 805CC606A329
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 203EE213E6;
	Fri, 06 Nov 2026 01:15:55 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=D7Q++FD/
	jRVg3s80kvw4ZQIirLuCUU1KeM0XdAHkGM8=; b=l+r/aD3bRACGXUk9tmk0kU10
	NpC3fqkFo/5uKkgIX+ofzd0hMxl0kHqhiCiJWd/JmgKHsQfcrpZh3SF+z864V6vo
	rAtgmL/MWIvb9McqKJTQMfmMy367fmMdyRLqFQrtWoNlP1QAaTWjARlq9dTjR/xe
	I/2ysQkRBDM4t2x1yy1oXc8x2x8+6JapmVum3l2q4nAPOlQL3uhm0erf2sAnp5+Q
	Gcw99j3rUsJaixmT057jiASohBueDx39vAbeLyhebu2Af6S50tEWoh9si5vzDGn2
	RQFbXwkyytRAPpb/7urJ36ITNtqQIuf2mbuMqYkp0VcDTsL5ONu9RqIKOFEqbgcY
	j7/z2zYAn6V0CVAHLh83c/0JzuME+TODUGJTqsxkxvQBZXL7iCdLgINuaZ+OCuhg
	wK/3LI4Egfp0xjbgV8eSk6HzOp3SNBLDFqrc6mH3BXmI0SHDbJi/qWqYZSV3RJTz
	7ynWLuh7obQP07rbJ/PCyLVWApwYRMI2BbRagVnxwuwvofdSIhEO2RBauK0x6uK+
	lbJW7r8EnWVm9nIEo0nLKO/lD3/T4M360tJ9Cpl19NmhxYG8Xfg6hsLtcswR86Hx
	rRs8GuYkkPESA1HmMxkUg7bZE9Lbp4sa2tqUblZbPXdovEEjTyL2b+wpKGkREqjO
	cAKbsvTJHxPseg2nrjs=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 06 Nov 2026 01:15:54 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id B50DC61EC1;
	Fri,  6 Nov 2026 01:15:54 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6A5NFjF3005559;
	Fri, 6 Nov 2026 01:15:45 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 6A5NFhpI005558;
	Fri, 6 Nov 2026 01:15:43 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf v3] ipvs: do not create conns from packets with port 0
Date: Fri,  6 Nov 2026 01:15:34 +0200
Message-ID: <20261105231534.5542-1-ja@ssi.bg>
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
Link: https://sashiko.dev/#/patchset/20261104201530.147292-1-ja%40ssi.bg
Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20261103140308.591690-3-pablo%40netfilter.org
Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260925141115.16126-1-axel.mierczuk%401password.com
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 Changes in v3:
 * Check the ports and drop port 0 only for traffic handled by IPVS

 Changes in v2:
 * Drop the packets with port 0 instead of passing them to the local
   server

 net/netfilter/ipvs/ip_vs_core.c       | 3 ++-
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 7 +++++++
 net/netfilter/ipvs/ip_vs_proto_tcp.c  | 7 +++++++
 net/netfilter/ipvs/ip_vs_proto_udp.c  | 6 ++++++
 4 files changed, 22 insertions(+), 1 deletion(-)

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
index fb8af6b15a39..cb34bcceb4f6 100644
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
@@ -56,6 +57,12 @@ sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 	if (svc) {
 		int ignored;
 
+		/* Do not create connection for port 0 */
+		if (!ports[0] || !ports[1]) {
+			*verdict = NF_DROP;
+			return 0;
+		}
+
 		if (ip_vs_todrop(ipvs)) {
 			/*
 			 * It seems that we are very loaded.
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index fec0e8b47b71..25d4576d0e12 100644
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
@@ -74,6 +75,12 @@ tcp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 	if (svc) {
 		int ignored;
 
+		/* Do not create connection for port 0 */
+		if (!ports[0] || !ports[1]) {
+			*verdict = NF_DROP;
+			return 0;
+		}
+
 		if (ip_vs_todrop(ipvs)) {
 			/*
 			 * It seems that we are very loaded.
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index f32785682402..ab3ab9524168 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -62,6 +62,12 @@ udp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 	if (svc) {
 		int ignored;
 
+		/* Do not create connection for port 0 */
+		if (!ports[0] || !ports[1]) {
+			*verdict = NF_DROP;
+			return 0;
+		}
+
 		if (ip_vs_todrop(ipvs)) {
 			/*
 			 * It seems that we are very loaded.
-- 
2.56.0


