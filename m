Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 47C24348C52;
	Mon, 27 Jul 2026 18:52:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785178376; cv=none; b=Qlh9YG6xRs1/mzkOYwc1hOC9AbFM1eEBDALJUYaAKHMaxsmehlQU7Kwc/FMTDIk1xZd9Mmv3+bPNapY07EBUxurq0oWJNtUUn7SvItj2TGih6SzSJNz23pbteOLUO61WYrZPeWNf/NrNed7ySQxepcBMDonAlGG6wgBcsNflogg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785178376; c=relaxed/simple;
	bh=9+PgpeQ5ox3Z39IaM1F/epWykBrtThRH1V7Y2kquPcQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=RwfDhxdv8GNKQ9pgX3vmWpT4rt5WTwgNIErADjT/d0XB7tlbAHqtWlcStt4jkSQgj2N1+7q6FksI5n1va6b+a3GzVEj1A7/Nvx/kAD5sp3mk8/q+jmEppZ4cCMLx+2EPJZSOcwKdOei7OQMAUOWx8MqDPcxGs7ENe0Ez18twGio=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=bOnWGCm9; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="bOnWGCm9"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id A02D521B1E;
	Mon, 27 Jul 2026 21:52:49 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=Dy44LEX1lm02o+FBHHAPvYM/pJ5uaIyUAee7qteRkPQ=; b=bOnWGCm9xsNJ
	u02a15CmdtN3TQeAIM8w4HKk0sihSQqXVnLSRqNbRXzVhPB/7vpDAh4oEz2unFST
	+pikEzujcY8pRtOt1ZZYA+gj1fL3TF6k6syDh0ZRNsAzMvu2M/wnsCp4kW8+7As4
	KTxPPdmVgSgz6eqieTpcmILMzO9gXHpG18ynimzoyFTHycjzZUAhR9stKpr4tC83
	tg1Boeb9wrmkHuSyCnwLT5okz5ZUBvbhFDUtsu3a1lODM0CjjPStFQldTeu/x+Wk
	7nsp6f2nKOK1wqrU/VlmMeehL8cLj+SpaHGSrdPVtwVSgPzNCsdS22EN/kWeF0db
	S2HgHSRhBBE6zIBUzgXp+o99l1x/o4NjbLdhz+QdgEesg5NimBEj3YG0yHTl7K6d
	OF9XI5TXDq1VDv1HZEfIs1amOeBQS9W7ucv0eL+dZXfL4Po/zTAHNK8wOnvkraCq
	NRq7hOvH29NGY7GRUXHkfIQ/bWbRCVFaz8XferotCeaWRJ/PqBFLTpkY+E8Glkj0
	LoYVDnbDaRNp9ZSMBlK42Whabe4Jj6tlErcUXc9IXU6sBhtYkRcqb4bqrfvP1ANz
	PXWhGfGzDjfAlvB0HfikfAaWlEXLwLavk+hRUYCMm/RyPEL48TJs9isJiAC28OxV
	+WIvgznDFhgyB4AP2yIzLoU72tB6p1Q=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 27 Jul 2026 21:52:49 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 6951F60A18;
	Mon, 27 Jul 2026 21:52:50 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66RIopT4067561;
	Mon, 27 Jul 2026 21:50:51 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 66RIopoe067560;
	Mon, 27 Jul 2026 21:50:51 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf 2/2] ipvs: return the per-proto csum validations
Date: Mon, 27 Jul 2026 21:50:24 +0300
Message-ID: <20260727185024.67534-3-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260727185024.67534-1-ja@ssi.bg>
References: <20260727185024.67534-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Sashiko notes that playing games with the skb dst and rt
flags instead of providing hooknum is not a good idea
when validating the checksums.

Also, skipping checksum validation for FORWARD packets
risk silent data corruption, even if the only user is
the FTP-CMD packets coming from the real server.

So, return the per-proto checksum validations, do not
use any hooknum-specific checks and convert the common
helper to be ICMP-only (ip_vs_checksum_icmp_check).

Fixes: e876b75b9020 ("ipvs: fix the checksum validations")
Link: https://sashiko.dev/#/patchset/20260722211420.153933-1-pablo%40netfilter.org
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h                   | 29 -----------------
 net/netfilter/ipvs/ip_vs_core.c       | 35 +++++++++++++++++---
 net/netfilter/ipvs/ip_vs_proto_sctp.c |  2 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c  | 40 ++++++++++++++++++++---
 net/netfilter/ipvs/ip_vs_proto_udp.c  | 47 +++++++++++++++++++++++----
 5 files changed, 107 insertions(+), 46 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index d80785485b92..b49c75929d03 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -25,9 +25,7 @@
 #include <linux/netfilter.h>		/* for union nf_inet_addr */
 #include <linux/ip.h>
 #include <linux/ipv6.h>			/* for struct ipv6hdr */
-#include <net/route.h>
 #include <net/ipv6.h>
-#include <net/ip6_fib.h>
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 #include <net/netfilter/nf_conntrack.h>
 #endif
@@ -2097,33 +2095,6 @@ static inline __wsum ip_vs_check_diff2(__be16 old, __be16 new, __wsum oldsum)
 	return csum_partial(diff, sizeof(diff), oldsum);
 }
 
-static inline bool ip_vs_checksum_needed(struct sk_buff *skb, int af)
-{
-	/* Checksum unnecessary or already validated? */
-	if (skb_csum_unnecessary(skb))
-		return false;
-	/* LOCAL_OUT ? */
-	if (!skb->dev || skb->dev->flags & IFF_LOOPBACK)
-		return false;
-	/* !LOCAL_IN (FORWARD) ? */
-	if (af == AF_INET6) {
-		if (!(dst_rt6_info(skb_dst(skb))->rt6i_flags & RTF_LOCAL))
-			return false;
-	} else {
-		if (!(skb_rtable(skb)->rt_flags & RTCF_LOCAL))
-			return false;
-	}
-	return true;
-}
-
-static inline bool ip_vs_checksum_common_check(struct sk_buff *skb,
-					       int offset, int proto, int af)
-{
-	if (!ip_vs_checksum_needed(skb, af))
-		return true;
-	return !nf_checksum(skb, NF_INET_LOCAL_IN, offset, proto, af);
-}
-
 /* Forget current conntrack (unconfirmed) and attach notrack entry */
 static inline void ip_vs_notrack(struct sk_buff *skb)
 {
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 0bdaeb4ed61e..ec4a56205e98 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -872,6 +872,33 @@ static __sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset)
 	return csum_fold(skb_checksum(skb, offset, skb->len - offset, 0));
 }
 
+static bool ip_vs_checksum_icmp_check(struct sk_buff *skb, int offset, int af)
+{
+	__wsum csum;
+
+	if (skb_csum_unnecessary(skb))
+		return true;
+	if (skb->ip_summed == CHECKSUM_NONE)
+		csum = skb_checksum(skb, offset, skb->len - offset, 0);
+	else if (skb->ip_summed == CHECKSUM_COMPLETE)
+		csum = csum_sub(skb->csum, skb_checksum(skb, 0, offset, 0));
+	else
+		return true;
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6) {
+		if (csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+				    &ipv6_hdr(skb)->daddr,
+				    skb->len - offset,
+				    IPPROTO_ICMPV6, csum))
+			return false;
+	} else
+#endif
+		if (csum_fold(csum))
+			return false;
+	return true;
+}
+
 static inline enum ip_defrag_users ip_vs_defrag_user(unsigned int hooknum)
 {
 	if (NF_INET_LOCAL_IN == hooknum)
@@ -1026,7 +1053,6 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 				struct ip_vs_iphdr *ciph,
 				unsigned int toff, unsigned int hooknum)
 {
-	int iproto = af == AF_INET6 ? IPPROTO_ICMPV6 : IPPROTO_ICMP;
 	unsigned int verdict = NF_DROP;
 	unsigned int ctoff = ciph->len;
 	bool has_ports = false;
@@ -1035,7 +1061,7 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 		goto after_nat;
 
 	/* Ensure the checksum is correct */
-	if (!ip_vs_checksum_common_check(skb, toff, iproto, af)) {
+	if (!ip_vs_checksum_icmp_check(skb, toff, af)) {
 		/* Failed checksum! */
 		IP_VS_DBG_BUF(1, "Forward ICMP: failed checksum from %s!\n",
 			      IP_VS_DBG_ADDR(af, snet));
@@ -1896,7 +1922,7 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 
 	/* Ensure the checksum is correct */
 	if ((IP_VS_FWD_METHOD(cp) == IP_VS_CONN_F_MASQ || tunnel) &&
-	    !ip_vs_checksum_common_check(skb, ihl, IPPROTO_ICMP, AF_INET)) {
+	    !ip_vs_checksum_icmp_check(skb, ihl, AF_INET)) {
 		/* Failed checksum! */
 		IP_VS_DBG(1, "Incoming ICMP: failed checksum from %pI4!\n",
 			  &iph->saddr.ip);
@@ -2057,8 +2083,7 @@ static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
 
 	/* Ensure the checksum is correct */
 	if (IP_VS_FWD_METHOD(cp) == IP_VS_CONN_F_MASQ &&
-	    !ip_vs_checksum_common_check(skb, iph->len, IPPROTO_ICMPV6,
-					 AF_INET6)) {
+	    !ip_vs_checksum_icmp_check(skb, iph->len, AF_INET6)) {
 		/* Failed checksum! */
 		IP_VS_DBG(1, "Incoming ICMPv6: failed checksum from %pI6c!\n",
 			  &iph->saddr);
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 3dbd3096e163..dd54a37dee29 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -193,7 +193,7 @@ sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 	struct sctphdr *sh;
 	__le32 cmp, val;
 
-	if (!ip_vs_checksum_needed(skb, af))
+	if (skb_csum_unnecessary(skb))
 		return 1;
 	sh = (struct sctphdr *)(skb->data + sctphoff);
 	cmp = sh->checksum;
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 99a286fdc90c..5ac25a27569d 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -304,11 +304,43 @@ static int
 tcp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 	       struct ip_vs_iphdr *iph)
 {
-	if (!ip_vs_checksum_common_check(skb, iph->len, IPPROTO_TCP, af)) {
-		IP_VS_DBG_RL_PKT(0, af, pp, skb, iph->off,
-				 "Failed checksum for");
-		return 0;
+	unsigned int tcphoff = iph->len;
+
+	if (skb_csum_unnecessary(skb))
+		return 1;
+	switch (skb->ip_summed) {
+	case CHECKSUM_NONE:
+		skb->csum = skb_checksum(skb, tcphoff, skb->len - tcphoff, 0);
+		fallthrough;
+	case CHECKSUM_COMPLETE:
+#ifdef CONFIG_IP_VS_IPV6
+		if (af == AF_INET6) {
+			if (csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+					    &ipv6_hdr(skb)->daddr,
+					    skb->len - tcphoff,
+					    IPPROTO_TCP,
+					    skb->csum)) {
+				IP_VS_DBG_RL_PKT(0, af, pp, skb, iph->off,
+						 "Failed checksum for");
+				return 0;
+			}
+		} else
+#endif
+			if (csum_tcpudp_magic(ip_hdr(skb)->saddr,
+					      ip_hdr(skb)->daddr,
+					      skb->len - tcphoff,
+					      ip_hdr(skb)->protocol,
+					      skb->csum)) {
+				IP_VS_DBG_RL_PKT(0, af, pp, skb, iph->off,
+						 "Failed checksum for");
+				return 0;
+			}
+		break;
+	default:
+		/* No need to checksum. */
+		break;
 	}
+
 	return 1;
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index f32785682402..e86cfa85ad59 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -300,18 +300,51 @@ static int
 udp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 	       struct ip_vs_iphdr *iph)
 {
+	unsigned int udphoff = iph->len;
 	struct udphdr _udph, *uh;
 
-	uh = skb_header_pointer(skb, iph->len, sizeof(_udph), &_udph);
+	uh = skb_header_pointer(skb, udphoff, sizeof(_udph), &_udph);
 	if (uh == NULL)
 		return 0;
 
-	if (!uh->check)
-		return 1;
-	if (!ip_vs_checksum_common_check(skb, iph->len, IPPROTO_UDP, af)) {
-		IP_VS_DBG_RL_PKT(0, af, pp, skb, iph->off,
-				 "Failed checksum for");
-		return 0;
+	if (uh->check != 0) {
+		if (skb_csum_unnecessary(skb))
+			return 1;
+		switch (skb->ip_summed) {
+		case CHECKSUM_NONE:
+			skb->csum = skb_checksum(skb, udphoff,
+						 skb->len - udphoff, 0);
+			fallthrough;
+		case CHECKSUM_COMPLETE:
+#ifdef CONFIG_IP_VS_IPV6
+			if (af == AF_INET6) {
+				if (csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+						    &ipv6_hdr(skb)->daddr,
+						    skb->len - udphoff,
+						    IPPROTO_UDP,
+						    skb->csum)) {
+					IP_VS_DBG_RL_PKT(0, af, pp, skb,
+							 iph->off,
+							 "Failed checksum for");
+					return 0;
+				}
+			} else
+#endif
+				if (csum_tcpudp_magic(ip_hdr(skb)->saddr,
+						      ip_hdr(skb)->daddr,
+						      skb->len - udphoff,
+						      ip_hdr(skb)->protocol,
+						      skb->csum)) {
+					IP_VS_DBG_RL_PKT(0, af, pp, skb,
+							 iph->off,
+							 "Failed checksum for");
+					return 0;
+				}
+			break;
+		default:
+			/* No need to checksum. */
+			break;
+		}
 	}
 	return 1;
 }
-- 
2.55.0


