Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B8C772C326C;
	Thu, 30 Jul 2026 18:36:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785436584; cv=none; b=pwnuC9Df1COYMqLtZYTt7CfcWHMFGWoOEZJsX4kVNq4x57tIQhuqtX8g+hawCMBz109yGmjGmaTEoRQOxYINkD553NIHDtF7gj8VC5eBQ354sNiQPjGmdBh/Tj9XHo1JjoxnW4+e2GgGCEg10G/WYdAMrE8MAH+OV5u1ZitPvso=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785436584; c=relaxed/simple;
	bh=Hf9pzuvpmc7gXrWqsgfBmHoXLetzOnMmMEfIj6MPKSU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=pJyj/iZ0+IGixYK70KPXQ7h1Oz1dOzhq5EMHDq1E12ems0IxhkhVZfIg/CU1KCcrORkYW/rcf/ZmlwRcBvfh2SRUwRh6uJqpDEjhFVPeN+AnC3bpjr2r/u1YCztRnPxq9FdqSmOAO7XrIoqp+1ECAv9Ny4xcXp9cmSzZ1AF6dVU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=TMRoceNA; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="TMRoceNA"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id D4A35216C4;
	Thu, 30 Jul 2026 21:36:14 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=BW+o5Ydbi/DoKtns7zCPnuADgSeOss/8HnYIqdz1Cfs=; b=TMRoceNALbSj
	IE8OBb7wLNSnw7MOquIY23VSzhsIuoMyoVrxNNBpxmyDU71r+DO0NRXTXLkvz0Kf
	251n97kz0e87GCxmJ25ITezr3CrdPSTxH1cl/cuQ9HF++Ofu15TK9TXrw7MUM4xc
	XbN6HgZDCfrQDtnoFUpwqmKyBfKHnCIEVg93av9V1bnk9sJ8G7M57l0Ea8jpu5h3
	24EbgnH3TNB92ZIS1I8bZBHfGDMws5PJEMCyAEjOLSU4zuV1F4qq18AqxTStCMcz
	uOOK3U09RvujiOwU4AsaKDY3g5iENv5KpOH1TDK5iDFQlmMC8NKfW+wJkHzJ5Mv3
	qxSSvmMRBk37FF/e/cyZDzP9OqgQOHUT1f8PDTWGWEdjePxxxQiP2tmUvcHXjDuV
	V6JIB1PUo38LqcIfIk/w7XSd5ZBoALU7LM6vXpucmJzWKzjeDhb1ZJU0Bg8Pfxru
	vyyU5gJvk1QUWxBgzulZ7UlV4szo95Ml7tdtcvrCrZW2zYdgIemtEzPFgHkl367s
	4CBGNDP8rrZMdYIvEeIijn541XDfe6LQD8pAXGNw/95nAwJjXHtDcNhzSqZgTpUv
	IKfXte+dquleXYQtJvV0Wl0Qnlm9Hw9Eki0msriUBYwW/qfmTQZTzf4ZJdeloeoU
	Bp5LkfuCmQk5t2UesSx/Z1tH00eLCWs=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 30 Jul 2026 21:36:14 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id B833B61BEF;
	Thu, 30 Jul 2026 21:36:15 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66UIaDon087551;
	Thu, 30 Jul 2026 21:36:13 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 66UIaD6Y087550;
	Thu, 30 Jul 2026 21:36:13 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf v3 2/2] ipvs: return the csum validation for forward hook
Date: Thu, 30 Jul 2026 21:35:06 +0300
Message-ID: <20260730183506.87473-3-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260730183506.87473-1-ja@ssi.bg>
References: <20260730183506.87473-1-ja@ssi.bg>
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
Link: https://sashiko.dev/#/patchset/20260728202520.59179-1-ja%40ssi.bg
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h                   | 19 +++++--------------
 net/netfilter/ipvs/ip_vs_proto_sctp.c |  2 +-
 2 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 1235f1934e94..d2813eb795be 100644
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
@@ -2095,30 +2093,23 @@ static inline __wsum ip_vs_check_diff2(__be16 old, __be16 new, __wsum oldsum)
 	return csum_partial(diff, sizeof(diff), oldsum);
 }
 
-static inline bool ip_vs_checksum_needed(struct sk_buff *skb, int af)
+static inline bool ip_vs_checksum_needed(struct sk_buff *skb)
 {
 	/* Checksum unnecessary or already validated? */
 	if (skb_csum_unnecessary(skb))
 		return false;
-	/* LOCAL_OUT ? */
-	if (!skb->dev || skb->dev->flags & IFF_LOOPBACK)
+	/* Locally generated ? */
+	if (!skb->dev)
 		return false;
-	/* !LOCAL_IN (FORWARD) ? */
-	if (af == AF_INET6) {
-		if (!(dst_rt6_info(skb_dst(skb))->rt6i_flags & RTF_LOCAL))
-			return false;
-	} else {
-		if (!(skb_rtable(skb)->rt_flags & RTCF_LOCAL))
-			return false;
-	}
 	return true;
 }
 
 static inline bool ip_vs_checksum_common_check(struct sk_buff *skb,
 					       int offset, int proto, int af)
 {
-	if (!ip_vs_checksum_needed(skb, af))
+	if (!ip_vs_checksum_needed(skb))
 		return true;
+	/* Validate csum even for FORWARD */
 	return !nf_checksum(skb, NF_INET_LOCAL_IN, offset, proto, af);
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 3dbd3096e163..c80567c73469 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -193,7 +193,7 @@ sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 	struct sctphdr *sh;
 	__le32 cmp, val;
 
-	if (!ip_vs_checksum_needed(skb, af))
+	if (!ip_vs_checksum_needed(skb))
 		return 1;
 	sh = (struct sctphdr *)(skb->data + sctphoff);
 	cmp = sh->checksum;
-- 
2.55.0


