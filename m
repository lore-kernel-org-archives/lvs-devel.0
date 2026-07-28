Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A7D55473C75;
	Tue, 28 Jul 2026 20:29:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785270585; cv=none; b=jjjW9GVOHUwNhefQjUETWiy0Ta9HhPdMpEePlKWz4GhnP11r/jKdZjnFDyn05Hy3KrDDixgPEXTUZDOx7FZRGiWv9uV6VP8N05acekrz7v9pFBcis00PkXoiX4cHOHp6LaJi0tvV75hi6CHReaget+C5B6OpbKP7gp+xj0OkrAg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785270585; c=relaxed/simple;
	bh=F5GzT7w9tYOQ9z5ak2CO+bH/kq132UujT5u+iJwzI0w=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=qpL+3D7tUbqbkJzxX3G3iLyB1Q3FmTG8xtSUW0yi60PJRaFB6ypa7/mpz/v2zquo8W8BFCsW9tTekOaT+bXSRVs46oxhk4xQiKT5Oh5n+MlSYxVf/InxhKlbGzQ65Xp+vOeIC99/J1/LtxXVG/9GnX2Qdf6oyEK8JPAFJBStHFI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=mHzN/DWS; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="mHzN/DWS"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id D7C3521315;
	Tue, 28 Jul 2026 23:29:37 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=34evffACt8r62JfqID5b4F7ZghdOH0epBgnuj18P/5g=; b=mHzN/DWSl6OK
	CuADXR2MK2xtIbNPEDOmSrM98zrHNv0ZRA9LZCRLe7cEdOSPBMOxeNkIeNjZdMUN
	S/o99vEwQyUDd5kVlOnyYaxhmiO4XlLq0k8ZEz1z2Yjy6sudPygKuWXTGrT0aNLQ
	TkMe0nWYrzz9SnTDLKya7abwC4kB6jfEhFZdN6U+3jpbjXXhz1ROX5z5atWSwlyH
	1pNBQZfv7a5DkLS/1rUCM05cmBF/d6cobswTvFUFl/GzuMfgDPjgHtPxzVQ/bf4L
	+I1WHWwRE+Nw133VGs3CjZF9Mrk4cv4hjsZk1lABPTeWnhDczUf5S/KzX6rm4vyv
	biHTHPaBQXttRFB9qmq8RKoGwRgO4nGzRIWW5ET+yCiAubfBfb5vmilpZ9VhwazT
	FgZ5g+E5Ra3uoW27+98vEUtaoD/MHQfy8ddC84RP80TSdqQuug3/OMlFyC+8du0E
	hXHUbeEUmDmjdo8SQF1KQG+R/6cNxZUUm6OxtvuingcxYvvXrq8ta476nZxsSdwl
	EUptSEosk0h2lFnnIw6qcpLtxBFmfKYJeeVwa5ZASgQXHOltF0cId8SZBcwBB42v
	dvluOMNAAo+PWah1UeZ1taxdBcCcxUW7+bimlSYGcEE43llotm+4iggD09trVJL9
	VKD1Z3sKjTssj7ji1A4rEqW2ccg1654=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 28 Jul 2026 23:29:37 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id A523860B6E;
	Tue, 28 Jul 2026 23:29:38 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66SKPWKG059211;
	Tue, 28 Jul 2026 23:25:32 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 66SKPWil059210;
	Tue, 28 Jul 2026 23:25:32 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf v2 2/2] ipvs: return the csum validation for forward hook
Date: Tue, 28 Jul 2026 23:25:20 +0300
Message-ID: <20260728202520.59179-3-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260728202520.59179-1-ja@ssi.bg>
References: <20260728202520.59179-1-ja@ssi.bg>
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

Sashiko also noticed that by using common checksum
helper in the previous commit we actually fixed old bug
where the TCP/UDP checksum for IPv6 on CHECKSUM_COMPLETE
was not validated correctly.

Fixes: e876b75b9020 ("ipvs: fix the checksum validations")
Link: https://sashiko.dev/#/patchset/20260722211420.153933-1-pablo%40netfilter.org
Link: https://sashiko.dev/#/patchset/20260727185024.67534-1-ja%40ssi.bg
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h                   | 30 ++-------------------------
 net/netfilter/ipvs/ip_vs_core.c       | 27 ++++++++++++++++++++++++
 net/netfilter/ipvs/ip_vs_proto_sctp.c |  2 +-
 3 files changed, 30 insertions(+), 29 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 1235f1934e94..10f5ce76a0ae 100644
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
@@ -2095,32 +2093,8 @@ static inline __wsum ip_vs_check_diff2(__be16 old, __be16 new, __wsum oldsum)
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
+bool ip_vs_checksum_common_check(struct sk_buff *skb, int offset, int proto,
+				 int af);
 
 /* Forget current conntrack (unconfirmed) and attach notrack entry */
 static inline void ip_vs_notrack(struct sk_buff *skb)
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 0bdaeb4ed61e..a51418a449cc 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -872,6 +872,33 @@ static __sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset)
 	return csum_fold(skb_checksum(skb, offset, skb->len - offset, 0));
 }
 
+bool ip_vs_checksum_common_check(struct sk_buff *skb, int offset, int proto,
+				 int af)
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
+	if (af == AF_INET6)
+		return !csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+					&ipv6_hdr(skb)->daddr,
+					skb->len - offset,
+					proto, csum);
+#endif
+	if (proto == IPPROTO_ICMP)
+		return !csum_fold(csum);
+	return !csum_tcpudp_magic(ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
+				  skb->len - offset, proto, csum);
+}
+
 static inline enum ip_defrag_users ip_vs_defrag_user(unsigned int hooknum)
 {
 	if (NF_INET_LOCAL_IN == hooknum)
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
-- 
2.55.0


