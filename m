Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4514B3C585B;
	Thu,  6 Aug 2026 10:52:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786013565; cv=none; b=mkjhEInZr4M3WL1XzdrbchUzTdWkymuD5CJzthlwH4c3pkzmWdOh+BEa0SWLxA42+/YAuU5Vo078YPn2L8ZwA4rgnlovz6eTbEvemMEd60TGGTwr8Byq/xmwvMgtL01xdPJ47eOY4PmFRPBypPyf5yxNumf+gAmGxK0mS8Sg1+k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786013565; c=relaxed/simple;
	bh=lTlT2Yck3ZMSIrpvZH6FezaAJF3yU2DijFQbI0dRJQA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=QUTNgXN73a3WltflwQIdN+NuHSpi/CKhiP3Vk2/j5wYCdZK7hQO8jDn5FsVGASn9OVYZH61lhoUoBjFPJy8fzQ7EzNSpA123tmgYUuW9MU5C4KntZ2Z0ZJ3wK6mQYkDh6f44KlO7UuOUGk9zKy3wzak53SUytKd0ELlTuzUejoA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=WEW54dQc; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="WEW54dQc"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 34E7721CD4;
	Thu, 06 Aug 2026 13:52:29 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=HKMqzPTr
	AmLDH7yG4j41bLRLsuahuF+lj0/OYWBhNhM=; b=WEW54dQcbfYiPGeTyV7gtmjR
	rXyddQQdzdw44BqxVoApySviKPVt/2qt4LnjR29iC1urRByq+izar4rr2SNrGGAQ
	J8npIkrp0uHX5am+53eJYk4rsL4314ZUzvPRW1NYl3M6Vnlrl3YS7RFWlzAqgKOa
	vobU77FwwvmZZ45mTCi3p4Z1IeWAqmgQ3dFqRIgQAWCHhyEoL4wNIvfDpd4eHrH0
	btAnnnqO8HKBaviTofXHem+ZNzspsAHMFOVZ5W19IxeP1BTo58VZqIhAPtwFG1r1
	RyuxO7zIto8pcmeO6TElTRK6VCJq0Q0DkNSn9n3X60v5aAhzfLe3CJfliPOmwV10
	8JOHbIFVadALBkUweLhD7yQrmz/zHck20ZlaG3UJcEMd7A4PLsYzvCFlC2bdenB+
	pztlgrWTYE/HXF5UXphdXMcWZ81NKAT/l7D3iEHA+N0VtOaO5ISVZ/fej1DuwK1m
	KrR4YhQIoqURwZbvdEmn9HtRd0H/dOC7jiUX7okmJ9X6SUfbhBxhnX1TnBktb2mw
	WmoRidVI8XOdb9NvUzD/mDPuFjElBb22hFGHTT73aKVw+Ydj/hpGTHhO/+YaUeLZ
	YDI6bFEEzOyE+Hul5tpv7WywLl/v9EXYTIwViiQv3g3L2asSmqDoNValIIhnf68I
	EnQ+CxZyz+Augp17Rh8=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 06 Aug 2026 13:52:29 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id D82F060585;
	Thu,  6 Aug 2026 13:52:29 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 676AqMbg034636;
	Thu, 6 Aug 2026 13:52:22 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 676AqJIP034634;
	Thu, 6 Aug 2026 13:52:19 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf] ipvs: revalidate ihl to prevent out-of-bounds access
Date: Thu,  6 Aug 2026 13:52:11 +0300
Message-ID: <20260806105211.34622-1-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

While the outer IP header is already pulled into the skb head,
we must be careful and revalidate the embedded headers after
reading them from the skb frags to prevent out-of-bounds
access.

One such place reported by Sashiko is ip_vs_nat_icmp() where
local process can change the ihl field and after
skb_ensure_writable() we can see larger value which is a
problem for the ip_send_check(cih) calls.

Add check to drop the packet if the ihl field is changed.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Link: https://sashiko.dev/#/patchset/20260730183506.87473-1-ja%40ssi.bg
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |  2 +-
 net/netfilter/ipvs/ip_vs_core.c | 11 +++++++++--
 net/netfilter/ipvs/ip_vs_xmit.c |  3 ++-
 3 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index fc2ef5ef31a6..be3a6617adf4 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -2068,7 +2068,7 @@ static inline bool ip_vs_conn_use_hash2(struct ip_vs_conn *cp)
 	       !(cp->flags & IP_VS_CONN_F_TEMPLATE);
 }
 
-void ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
+bool ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		    struct ip_vs_conn *cp, int dir, unsigned int toff,
 		    bool has_ports, struct ip_vs_iphdr *ciph);
 
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 95af77b68851..1a0661d19d9f 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -923,7 +923,7 @@ static int ip_vs_route_me_harder(struct netns_ipvs *ipvs, int af,
  * Packet has been made sufficiently writable in caller
  * - inout: 1=in->out, 0=out->in
  */
-void ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
+bool ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		    struct ip_vs_conn *cp, int inout, unsigned int toff,
 		    bool has_ports, struct ip_vs_iphdr *ciph)
 {
@@ -931,6 +931,11 @@ void ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
 	struct icmphdr *icmph	 = (struct icmphdr *)(skb->data + toff);
 	struct iphdr *cih	 = (struct iphdr *)(icmph + 1);
 
+	/* Before now we may used ihl from skb frag, revalidate it after
+	 * copying it into skb head to prevent out-of-bounds access
+	 */
+	if (cih->ihl * 4 != ciph->len - ciph->off)
+		return false;
 	if (inout) {
 		iph->saddr = cp->vaddr.ip;
 		ip_send_check(iph);
@@ -964,6 +969,7 @@ void ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
 	else
 		IP_VS_DBG_PKT(11, AF_INET, pp, skb, ciph->off,
 			      "Forwarding altered incoming ICMP");
+	return true;
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1055,7 +1061,8 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 		ip_vs_nat_icmp_v6(skb, pp, cp, 1, toff, has_ports, ciph);
 	else
 #endif
-		ip_vs_nat_icmp(skb, pp, cp, 1, toff, has_ports, ciph);
+		if (!ip_vs_nat_icmp(skb, pp, cp, 1, toff, has_ports, ciph))
+			goto out;
 
 	if (ip_vs_route_me_harder(cp->ipvs, af, skb, hooknum))
 		goto out;
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 3d3c72c9dda4..f5f72a2135e1 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -1582,7 +1582,8 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (skb_cow(skb, rt->dst.dev->hard_header_len))
 		goto tx_error;
 
-	ip_vs_nat_icmp(skb, pp, cp, 0, toff, has_ports, ciph);
+	if (!ip_vs_nat_icmp(skb, pp, cp, 0, toff, has_ports, ciph))
+		goto tx_error;
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->ignore_df = 1;
-- 
2.55.0


