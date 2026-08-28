Received: from mx.swemel.ru (mx.swemel.ru [95.143.211.150])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 241523F1042;
	Fri, 28 Aug 2026 09:05:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=95.143.211.150
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787907908; cv=none; b=JNWxxJrTrA4nFJT4VAYwOFFC7Ybb2/rWzYMeZvJonUHGomKE4gsxyC0rxtwv9BxdRRzXJSAFr22jVVEisIx5p9wsULTusOAj8wdifx+hLuYyB7XHRlNqR0dSR2dUnMktLgXnUzILd0MOGwQmt8zhyFYevxNfoSSKQKTmucQl6iY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787907908; c=relaxed/simple;
	bh=Ejf70St9xv35smMJRlt75iZRTrv+MkSeYJX80TfDbYI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=BNaPej0k+w288fuV89mXVIPtKATwFzi1kyBi/2rhNFSomx5rv7td4tO5aUbIQWrgtMLfjLy7MXpK6M+VJ814puOzgoBHY3EI7jd5ebgxwHaO69WwYSwYwQQW3hNjYMNKCo8FYB7i+raezWVzDJ57SwVrIsFOrDyhKwMSA9XVkjA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=swemel.ru; spf=pass smtp.mailfrom=swemel.ru; dkim=pass (1024-bit key) header.d=swemel.ru header.i=@swemel.ru header.b=iw1e0k7T; arc=none smtp.client-ip=95.143.211.150
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=swemel.ru
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=swemel.ru
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=swemel.ru header.i=@swemel.ru header.b="iw1e0k7T"
From: Denis Arefev <arefev@swemel.ru>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=swemel.ru; s=mail;
	t=1787907322;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=kDm083ubOGPoeNyTcgkSzWZYrZQ4GupNUIX+4IAgrbM=;
	b=iw1e0k7T//K0LXM0/oS2ZLYjls91dFlNFynVCHITC+zWpWiIYyy0tCj0TovmOQPmZXF0r2
	p9t+jQyryEqERsGoENfCiG93kmI5+0mUVDcMYytuq1x17t90UVwn6hdUqWNEe1CTaaGmTb
	i1O9MOZobUc4sZnD5u5CHykIOiVtSGM=
To: stable@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Jakub Kicinski <kuba@kernel.org>,
	Dwip Banerjee <dwip@linux.vnet.ibm.com>,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 5.10/6.1] ipvs: reload ip header after head reallocation
Date: Fri, 28 Aug 2026 11:55:21 +0300
Message-ID: <20260828085522.31015-1-arefev@swemel.ru>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Florian Westphal <fw@strlen.de>

commit a2f57827bf7c695b8c72dc4511cae8e86582369d upstream.

__ip_vs_get_out_rt() calls skb_ensure_writable() which may
reallocate skb->head.

Fixes: 8d8e20e2d7bb ("ipvs: Decrement ttl")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-sonnet-4-6
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Florian Westphal <fw@strlen.de>
[Denis Arefev: adapted for 5.10/6.1: keep EnterFunction/LeaveFunction
instrumentation]
Signed-off-by: Denis Arefev <arefev@swemel.ru>
---
Backport fix for CVE-2026-68476 
Link: https://nvd.nist.gov/vuln/detail/CVE-2026-68476 
---
 net/netfilter/ipvs/ip_vs_xmit.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 9e199f00eea7..29ca141e3795 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -718,15 +718,13 @@ int
 ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
-	struct iphdr  *iph = ip_hdr(skb);
-
 	EnterFunction(10);
 
-	if (__ip_vs_get_out_rt(cp->ipvs, cp->af, skb, NULL, iph->daddr,
-			       IP_VS_RT_MODE_NON_LOCAL, NULL, ipvsh) < 0)
+	if (__ip_vs_get_out_rt(cp->ipvs, cp->af, skb, NULL, ip_hdr(skb)->daddr,
+			       IP_VS_RT_MODE_NON_LOCAL, NULL, ipvsh) < 0)
 		goto tx_error;
 
-	ip_send_check(iph);
+	ip_send_check(ip_hdr(skb));
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->ignore_df = 1;
-- 
2.43.0

