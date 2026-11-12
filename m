Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794465041;
	b=3n2qVEAGwzdo0qDQXEprikUh3UXNkx36/AQM8TmCEJfbx6DW51YbZlDvVIG9VzuzpQ18
	 69K//y2QwO2NcsxuGP1agmIzi5f+lIyvnA3Q8pTSEYHEaUc7m8DY3dlnCg8P6/dH/QvzU
	 /JNF9swc56zgSo6nyAleNNJcuxTj30DM7pIBF7i95FQNAbh8qIWzKi07kbmuBtCmXKmFT
	 gSDuhcacy+19+ghYLQy71VeTsj8ebV9dc436kM3DNeja1Ioox4JS+e+t8/mg7389OCZJe
	 +SGV3/9FY4eLDc8BXtOQXSlXy1G05a2dNEX2Bj0z2d+nGs228+Z/gZHnF3wzD9F7+VA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794465041;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=un+yA6mJeACzwpj72yLiHOtQnG3yMeLf0nqktdDSbVc=;
	b=17vuf0ptYdc1W7t/jBu9wnRz5ObVAztb0u3JoKKhg3CYwaezv0TEMnith6ctbOUEab78
	 lpxzC938CiaeZuKlnWAqiin8jXinZki0E96O72Uh8MGZc91IEAJyTHIF4l35E0VqProMy
	 gCElmUP5L5KiRXEYw9Hrv3VC9YwLwnmQg7c5MfHxPOZqzMij61QyYdqAok3SSVOqv8ybZ
	 6Pa3blPYYHMFTKR4LrllRPyNQwxFKyVg/UcW5OZ0SUZJ5zgZAaLvN3ZEi9nAONndbDO+Y
	 iO1tUiNBxvdbwp8CL+tkVvHly2ruhzQr+AdHrs/4V+QGLzF7xqqz2WQFc9phibEoD4A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=lcxEBejH;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C1F9C606A31C;
	Thu, 12 Nov 2026 06:30:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C1F9C606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=lcxEBejH
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 13C5322392;
	Thu, 12 Nov 2026 08:30:39 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=un+yA6mJ
	eACzwpj72yLiHOtQnG3yMeLf0nqktdDSbVc=; b=lcxEBejHeh+EPpjaFsmcHYnc
	TXaoik8eu711sAXKLFw5vBuu2mdpbagqTfAa9XOpFeDAFCXAzzTUdZo20gIhTY3I
	9+9RuoLQR2+9oipa3uWBXT1leAku4my4qLhSvmmeH+zrEkCBDorer3En3VKlvMsd
	JdkIAyA99v4pHc7Yp0+x4MwkipEYgXsQ4XFCJMEEAhB8W+FLbnte8pW5ycXhGQ+y
	uu4PkS2u8YZqWFyABhaRgQAyENDwgmX4mfhttiE/cfOCfw5+VlcD4ZZ42ad3Umqh
	dzoWnYcInMfRZHILOaj6ptn2yexwLapov+UN0/T2Ffem7KCsSYPjrmnG6mef1kWI
	+5Cy5i8fIulV+vX15CT9MVk5fjurxFtQBzXPtu6joXfcRBMPc7U69sQs99NoHWGN
	Sy4IoqllfGZfpHYH2Dfmv9QkrQ+kK7IH/Z/4yyourEzgE9wRASIyLT3oiFgWRNOD
	YRguiONepzTfIzi2NuC2/dvpKSfwUaxmNjfoUsFRfOsTifmeu8HKo2qBPI69jCV2
	IoKWE3FczYASGG+8yO2aChhBnnmwV/vN9GX6cvAAQ696oDbLknTMoXmEBMXQJx4+
	hKr4M7nlvi8sJlpGD+FiaxBZg8lVtTxuPU3WlsQh/0zR2MFEp2g8p5BodsgNeE2h
	qvQF5QPWN8xOgNyqAlU=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 12 Nov 2026 08:30:38 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 7FB2160B9F;
	Thu, 12 Nov 2026 08:30:38 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6AC6UblE015336;
	Thu, 12 Nov 2026 08:30:37 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 6AC6Ubwi015335;
	Thu, 12 Nov 2026 08:30:37 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf] ipvs: drop the packets with port 0
Date: Thu, 12 Nov 2026 08:29:53 +0200
Message-ID: <20261112062953.15277-1-ja@ssi.bg>
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

Sashiko warns that ignoring connection with port 0 passes
it to the local listener where it can be accepted. Instead
of passing it we should drop it but after ensuring it is
for IPVS service.

Link: https://sashiko.dev/#/patchset/20261104201530.147292-1-ja%40ssi.bg
Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20261103140308.591690-3-pablo%40netfilter.org
Fixes: 3c3ff3b998fd ("ipvs: do not create conns from packets with port 0")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 10 ++++++----
 net/netfilter/ipvs/ip_vs_proto_tcp.c  | 10 ++++++----
 net/netfilter/ipvs/ip_vs_proto_udp.c  | 10 ++++++----
 3 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 83d1443ebe01..cb34bcceb4f6 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -48,10 +48,6 @@ sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		return 0;
 	}
 
-	/* Do not create connection for port 0, skip the packet */
-	if (!ports[0] || !ports[1])
-		return 1;
-
 	if (likely(!ip_vs_iph_inverse(iph)))
 		svc = ip_vs_service_find(ipvs, af, skb->mark, iph->protocol,
 					 &iph->daddr, ports[1]);
@@ -61,6 +57,12 @@ sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
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
index 2e55b62445c6..25d4576d0e12 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -63,10 +63,6 @@ tcp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		return 0;
 	}
 
-	/* Do not create connection for port 0, skip the packet */
-	if (!ports[0] || !ports[1])
-		return 1;
-
 	/* No !th->ack check to allow scheduling on SYN+ACK for Active FTP */
 
 	if (likely(!ip_vs_iph_inverse(iph)))
@@ -79,6 +75,12 @@ tcp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
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
index 92c0b76c1a02..ab3ab9524168 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -52,10 +52,6 @@ udp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		return 0;
 	}
 
-	/* Do not create connection for port 0, skip the packet */
-	if (!ports[0] || !ports[1])
-		return 1;
-
 	if (likely(!ip_vs_iph_inverse(iph)))
 		svc = ip_vs_service_find(ipvs, af, skb->mark, iph->protocol,
 					 &iph->daddr, ports[1]);
@@ -66,6 +62,12 @@ udp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
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


