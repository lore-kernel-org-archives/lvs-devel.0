Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 44C624C6EF3;
	Wed, 22 Jul 2026 10:20:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784715636; cv=none; b=dLD5pTDyilScJOtwChJ88WueWKqZpbMrekD6oWOlvp764Qlnz3BKxhrRdz6T1xW0zwZ2bQ7LnJZlr3onI+R4UU4wXyQWhTLkhXtN68lUf7CFjSIodoWbz9LOk0HbqjbtGm0RjCTiM5bkdi+JaR10DAKm1awMehOJLfqIMu9Ds1M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784715636; c=relaxed/simple;
	bh=4cNnNtZVzU7ZWIj+ZJRk57K+TezU5nT01EaqfkuOuYU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=LDLpWxrCWnjsiCEJOShtNi2DroToVvvnABOyxPx6aPu49PnlM8cc7NffCYP4T6NVtJtR9yNn8DoTFf+4Ou5uBAoGtWocEAdzHPKFBC7lZ9FIdSWxaCJBztjOuuGAixglcdkuE5dI0ZA7eG82xaXrsM6qyV4aPSJaUPrQgywjnVM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=XBjJYWL9; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="XBjJYWL9"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id A6A922188A;
	Wed, 22 Jul 2026 13:20:22 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=/ZemEsr/7VdJCFRkn/jiB9qgZdUHBjFSVtmSgYUPKB0=; b=XBjJYWL9OY6V
	sW/4xiIdVEiZBZZozKpj0gIoLsQi2olkU3Eckh5CZZHxWD4xX8arf+yW2XszrU01
	UtsMOy5vyNu0BfSn8fFVWjgDr2bfm5i8x+D+bvvOuIV0t+PSgwH5dLEkHcr+i0/l
	8sqcgIS3sBH9d2Xk86DTwb2ArFXlXH1JFG23KzOPNGdgvvwAoCeLB7E+MnIRKWlq
	Zntwtkc6zXDbAvTJ0RdFZuR+DOm5Ethqa7/ov8ORQRlfB+c3pR4K5JrQKyp9nd4T
	o6MVzYUg1a1trIKQ0mHUbIcqO54PcrdPT3jDSBo1sV14DrgZQzCFlxgQeqWnJMdb
	kHzifXP3z7m+fMu+WSAxCUO/FlCBdlDlrKa9X7J/9gT5PYbRBJB464aZk3Qw63tT
	3cpCGUFvB7K+oJdwtA56LP6kfE9YnI6M4KtKSSeWpMzBbxfXY73wrr5eg/9PPaW0
	73urQa51dxyqp6KcOOzMcDOtJJ83vWcy10Yb0S70YEiVxUCKa2eqk5Rnjd1EdnCA
	DF4sjjUBCwj09LzWpwqjEgG/WWasosQlL7yPSK9pGoteJtSKSSCePHS70kUK45K6
	shM8VoMeJlYuSf2MKzdD2SFcZd38iTXH8uO/Ni0j3G5f7EVpSX8hEaGT7f/Mfcxv
	jgFwMAGPs2xhek/Va5bPsbs1oV1/d+M=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 22 Jul 2026 13:20:22 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id BB22760A02;
	Wed, 22 Jul 2026 13:20:22 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66MAFiV8036339;
	Wed, 22 Jul 2026 13:15:44 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 66MAFieZ036338;
	Wed, 22 Jul 2026 13:15:44 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf v3 1/3] ipvs: fix the checksum validations
Date: Wed, 22 Jul 2026 13:15:15 +0300
Message-ID: <20260722101517.36313-2-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260722101517.36313-1-ja@ssi.bg>
References: <20260722101517.36313-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

ip_vs_in_icmp_v6() is missing checksum validation for ICMPv6
packets from clients. In fact, as for TCP/UDP we should
validate the checksum for ICMP packets only when we
mangle the packets on MASQ or on reply for tunnel.

Also, Sashiko points out that handle_response_icmp() being
common for IPv4 and IPv6 is missing the pseudo-header
calculation while validating ICMPv6 messages from real
servers which is a problem if checksum is not validated
by the hardware.

Fix the problems by creating ip_vs_checksum_common_check()
helper and use it for TCP/UDP/ICMP both for IPv4 and IPv6.
Rely on the nf_checksum() for validating the ICMP messages
but use it also for TCP and UDP.

Use correct IP offset for IP_VS_DBG_RL_PKT for TCP/UDP/SCTP.

IPVS packets (TCP/UDP/SCTP/ICMP) do not need checksum
validation on LOCAL_OUT (local clients or local real
servers) and on FORWARD (traffic from servers on LAN).
Do it only on LOCAL_IN, in case nf_checksum() is not
called on PRE_ROUTING.

Also, ip_vs_checksum_complete() can be marked static.

Fixes: 2a3b791e6e11 ("IPVS: Add/adjust Netfilter hook functions and helpers for v6")
Link: https://sashiko.dev/#/patchset/20260708180315.77413-1-ja%40ssi.bg
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h                   | 34 ++++++++++++++++--
 net/netfilter/ipvs/ip_vs_core.c       | 20 +++++++++--
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 15 ++++----
 net/netfilter/ipvs/ip_vs_proto_tcp.c  | 44 +++++------------------
 net/netfilter/ipvs/ip_vs_proto_udp.c  | 50 ++++++---------------------
 5 files changed, 77 insertions(+), 86 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 3fc864a320fb..bf85ad6b1b42 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -25,7 +25,9 @@
 #include <linux/netfilter.h>		/* for union nf_inet_addr */
 #include <linux/ip.h>
 #include <linux/ipv6.h>			/* for struct ipv6hdr */
+#include <net/route.h>
 #include <net/ipv6.h>
+#include <net/ip6_fib.h>
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 #include <net/netfilter/nf_conntrack.h>
 #endif
@@ -2068,8 +2070,6 @@ void ip_vs_nat_icmp_v6(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		       struct ip_vs_conn *cp, int dir);
 #endif
 
-__sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset);
-
 static inline __wsum ip_vs_check_diff4(__be32 old, __be32 new, __wsum oldsum)
 {
 	__be32 diff[2] = { ~old, new };
@@ -2095,6 +2095,36 @@ static inline __wsum ip_vs_check_diff2(__be16 old, __be16 new, __wsum oldsum)
 	return csum_partial(diff, sizeof(diff), oldsum);
 }
 
+static inline bool ip_vs_checksum_needed(struct sk_buff *skb, int af)
+{
+	/* Checksum unnecessary or already validated? */
+	if (skb_csum_unnecessary(skb))
+		return false;
+	/* LOCAL_OUT ? */
+	if (!skb->dev || skb->dev->flags & IFF_LOOPBACK)
+		return false;
+	/* !LOCAL_IN (FORWARD) ? */
+	if (af == AF_INET6) {
+		if (!(dst_rt6_info(skb_dst(skb))->rt6i_flags & RTF_LOCAL))
+			return false;
+	} else {
+		if (!(skb_rtable(skb)->rt_flags & RTCF_LOCAL))
+			return false;
+	}
+	return true;
+}
+
+/**
+ * ip_vs_checksum_common_check - validate checksum for TCP/UDP/ICMP
+ */
+static inline bool ip_vs_checksum_common_check(struct sk_buff *skb,
+					       int offset, int proto, int af)
+{
+	if (!ip_vs_checksum_needed(skb, af))
+		return true;
+	return !nf_checksum(skb, NF_INET_LOCAL_IN, offset, proto, af);
+}
+
 /* Forget current conntrack (unconfirmed) and attach notrack entry */
 static inline void ip_vs_notrack(struct sk_buff *skb)
 {
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index bafab93451d0..c8b512725e6e 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -867,7 +867,7 @@ static int sysctl_nat_icmp_send(struct netns_ipvs *ipvs) { return 0; }
 
 #endif
 
-__sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset)
+static __sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset)
 {
 	return csum_fold(skb_checksum(skb, offset, skb->len - offset, 0));
 }
@@ -1038,13 +1038,14 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 				unsigned int offset, unsigned int ihl,
 				unsigned int hooknum)
 {
+	int iproto = af == AF_INET6 ? IPPROTO_ICMPV6 : IPPROTO_ICMP;
 	unsigned int verdict = NF_DROP;
 
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
 		goto after_nat;
 
 	/* Ensure the checksum is correct */
-	if (!skb_csum_unnecessary(skb) && ip_vs_checksum_complete(skb, ihl)) {
+	if (!ip_vs_checksum_common_check(skb, ihl, iproto, af)) {
 		/* Failed checksum! */
 		IP_VS_DBG_BUF(1, "Forward ICMP: failed checksum from %s!\n",
 			      IP_VS_DBG_ADDR(af, snet));
@@ -1898,7 +1899,8 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 	verdict = NF_DROP;
 
 	/* Ensure the checksum is correct */
-	if (!skb_csum_unnecessary(skb) && ip_vs_checksum_complete(skb, ihl)) {
+	if ((IP_VS_FWD_METHOD(cp) == IP_VS_CONN_F_MASQ || tunnel) &&
+	    !ip_vs_checksum_common_check(skb, ihl, IPPROTO_ICMP, AF_INET)) {
 		/* Failed checksum! */
 		IP_VS_DBG(1, "Incoming ICMP: failed checksum from %pI4!\n",
 			  &iph->saddr);
@@ -2064,6 +2066,18 @@ static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
 		goto out;
 	}
 
+	verdict = NF_DROP;
+
+	/* Ensure the checksum is correct */
+	if (IP_VS_FWD_METHOD(cp) == IP_VS_CONN_F_MASQ &&
+	    !ip_vs_checksum_common_check(skb, iph->len, IPPROTO_ICMPV6,
+					 AF_INET6)) {
+		/* Failed checksum! */
+		IP_VS_DBG(1, "Incoming ICMPv6: failed checksum from %pI6c!\n",
+			  &iph->saddr);
+		goto out;
+	}
+
 	/* do the statistics and put it back */
 	ip_vs_in_stats(cp, skb);
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index c67317be17df..f6f732b7dfa8 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -11,7 +11,7 @@
 
 static int
 sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
-		unsigned int sctphoff);
+		struct ip_vs_iphdr *iph);
 
 static int
 sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
@@ -109,7 +109,7 @@ sctp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		int ret;
 
 		/* Some checks before mangling */
-		if (!sctp_csum_check(cp->af, skb, pp, sctphoff))
+		if (!sctp_csum_check(cp->af, skb, pp, iph))
 			return 0;
 
 		/* Call application helper if needed */
@@ -157,7 +157,7 @@ sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		int ret;
 
 		/* Some checks before mangling */
-		if (!sctp_csum_check(cp->af, skb, pp, sctphoff))
+		if (!sctp_csum_check(cp->af, skb, pp, iph))
 			return 0;
 
 		/* Call application helper if needed */
@@ -187,19 +187,22 @@ sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 static int
 sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
-		unsigned int sctphoff)
+		struct ip_vs_iphdr *iph)
 {
+	unsigned int sctphoff = iph->len;
 	struct sctphdr *sh;
 	__le32 cmp, val;
 
+	if (!ip_vs_checksum_needed(skb, af))
+		return 1;
 	sh = (struct sctphdr *)(skb->data + sctphoff);
 	cmp = sh->checksum;
 	val = sctp_compute_cksum(skb, sctphoff);
 
 	if (val != cmp) {
 		/* CRC failure, dump it. */
-		IP_VS_DBG_RL_PKT(0, af, pp, skb, 0,
-				"Failed checksum for");
+		IP_VS_DBG_RL_PKT(0, af, pp, skb, iph->off,
+				 "Failed checksum for");
 		return 0;
 	}
 	return 1;
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index f86b763efcc4..533fce3e5e4e 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -29,7 +29,7 @@
 
 static int
 tcp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
-	       unsigned int tcphoff);
+	       struct ip_vs_iphdr *iph);
 
 static int
 tcp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
@@ -166,7 +166,7 @@ tcp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		int ret;
 
 		/* Some checks before mangling */
-		if (!tcp_csum_check(cp->af, skb, pp, tcphoff))
+		if (!tcp_csum_check(cp->af, skb, pp, iph))
 			return 0;
 
 		/* Call application helper if needed */
@@ -244,7 +244,7 @@ tcp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		int ret;
 
 		/* Some checks before mangling */
-		if (!tcp_csum_check(cp->af, skb, pp, tcphoff))
+		if (!tcp_csum_check(cp->af, skb, pp, iph))
 			return 0;
 
 		/*
@@ -302,41 +302,13 @@ tcp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 static int
 tcp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
-	       unsigned int tcphoff)
+	       struct ip_vs_iphdr *iph)
 {
-	switch (skb->ip_summed) {
-	case CHECKSUM_NONE:
-		skb->csum = skb_checksum(skb, tcphoff, skb->len - tcphoff, 0);
-		fallthrough;
-	case CHECKSUM_COMPLETE:
-#ifdef CONFIG_IP_VS_IPV6
-		if (af == AF_INET6) {
-			if (csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-					    &ipv6_hdr(skb)->daddr,
-					    skb->len - tcphoff,
-					    IPPROTO_TCP,
-					    skb->csum)) {
-				IP_VS_DBG_RL_PKT(0, af, pp, skb, 0,
-						 "Failed checksum for");
-				return 0;
-			}
-		} else
-#endif
-			if (csum_tcpudp_magic(ip_hdr(skb)->saddr,
-					      ip_hdr(skb)->daddr,
-					      skb->len - tcphoff,
-					      ip_hdr(skb)->protocol,
-					      skb->csum)) {
-				IP_VS_DBG_RL_PKT(0, af, pp, skb, 0,
-						 "Failed checksum for");
-				return 0;
-			}
-		break;
-	default:
-		/* No need to checksum. */
-		break;
+	if (!ip_vs_checksum_common_check(skb, iph->len, IPPROTO_TCP, af)) {
+		IP_VS_DBG_RL_PKT(0, af, pp, skb, iph->off,
+				 "Failed checksum for");
+		return 0;
 	}
-
 	return 1;
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 58f9e255927e..de3597347542 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -25,7 +25,7 @@
 
 static int
 udp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
-	       unsigned int udphoff);
+	       struct ip_vs_iphdr *iph);
 
 static int
 udp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
@@ -155,7 +155,7 @@ udp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		int ret;
 
 		/* Some checks before mangling */
-		if (!udp_csum_check(cp->af, skb, pp, udphoff))
+		if (!udp_csum_check(cp->af, skb, pp, iph))
 			return 0;
 
 		/*
@@ -238,7 +238,7 @@ udp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		int ret;
 
 		/* Some checks before mangling */
-		if (!udp_csum_check(cp->af, skb, pp, udphoff))
+		if (!udp_csum_check(cp->af, skb, pp, iph))
 			return 0;
 
 		/*
@@ -298,48 +298,20 @@ udp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 static int
 udp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
-	       unsigned int udphoff)
+	       struct ip_vs_iphdr *iph)
 {
 	struct udphdr _udph, *uh;
 
-	uh = skb_header_pointer(skb, udphoff, sizeof(_udph), &_udph);
+	uh = skb_header_pointer(skb, iph->len, sizeof(_udph), &_udph);
 	if (uh == NULL)
 		return 0;
 
-	if (uh->check != 0) {
-		switch (skb->ip_summed) {
-		case CHECKSUM_NONE:
-			skb->csum = skb_checksum(skb, udphoff,
-						 skb->len - udphoff, 0);
-			fallthrough;
-		case CHECKSUM_COMPLETE:
-#ifdef CONFIG_IP_VS_IPV6
-			if (af == AF_INET6) {
-				if (csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-						    &ipv6_hdr(skb)->daddr,
-						    skb->len - udphoff,
-						    IPPROTO_UDP,
-						    skb->csum)) {
-					IP_VS_DBG_RL_PKT(0, af, pp, skb, 0,
-							 "Failed checksum for");
-					return 0;
-				}
-			} else
-#endif
-				if (csum_tcpudp_magic(ip_hdr(skb)->saddr,
-						      ip_hdr(skb)->daddr,
-						      skb->len - udphoff,
-						      ip_hdr(skb)->protocol,
-						      skb->csum)) {
-					IP_VS_DBG_RL_PKT(0, af, pp, skb, 0,
-							 "Failed checksum for");
-					return 0;
-				}
-			break;
-		default:
-			/* No need to checksum. */
-			break;
-		}
+	if (!uh->check)
+		return 1;
+	if (!ip_vs_checksum_common_check(skb, iph->len, IPPROTO_UDP, af)) {
+		IP_VS_DBG_RL_PKT(0, af, pp, skb, iph->off,
+				 "Failed checksum for");
+		return 0;
 	}
 	return 1;
 }
-- 
2.55.0


