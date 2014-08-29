From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v4 18/20] ipvs: use correct address family in WLC logs
Date: Fri, 29 Aug 2014 01:39:07 -0700
Message-ID: <1409301549-5284-19-git-send-email-agartrell@fb.com>
References: <1409301549-5284-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=iNtjgo5kwJA1j6vr+OuwzBwifEmTkU69BtDbAmkAFpI=;
 b=aRxt8G+lAdKAg85UecQeTWPkaplvX2WIqCmnCw+C3tP0GwAYITI4aSpcMKEr2v3PEHN+
 56l/u7Fx6KktwEIeqyX3FzGwXKxSffAJa1Ie1rC7By3LheRWsSwjyWU5xopXjusneNn1
 b9vzDs89CvjLW5+65Z3gJMRxb8I/JUUV7Tw= 
In-Reply-To: <1409301549-5284-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

From: Julian Anastasov <ja@ssi.bg>

Needed to support svc->af != dest->af.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_wlc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_wlc.c b/net/netfilter/ipvs/ip_vs_wlc.c
index b5b4650..6b366fd 100644
--- a/net/netfilter/ipvs/ip_vs_wlc.c
+++ b/net/netfilter/ipvs/ip_vs_wlc.c
@@ -80,7 +80,8 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 
 	IP_VS_DBG_BUF(6, "WLC: server %s:%u "
 		      "activeconns %d refcnt %d weight %d overhead %d\n",
-		      IP_VS_DBG_ADDR(svc->af, &least->addr), ntohs(least->port),
+		      IP_VS_DBG_ADDR(least->af, &least->addr),
+		      ntohs(least->port),
 		      atomic_read(&least->activeconns),
 		      atomic_read(&least->refcnt),
 		      atomic_read(&least->weight), loh);
-- 
1.8.1

