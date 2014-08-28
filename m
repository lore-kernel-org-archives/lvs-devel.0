From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v3 14/20] ipvs: use correct address family in LC logs
Date: Wed, 27 Aug 2014 22:43:48 -0700
Message-ID: <1409204634-1123-15-git-send-email-agartrell@fb.com>
References: <1409204634-1123-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=5v1lsTSSb9fqCc9NSPxGGrOYfx9ffskVWO1V4ZSpK+M=;
 b=Af0aq2EeCsoQ1NsSGST143aPKtWzQDNFzRKUborCMZydK4dHuJ5QCOGwp2+k+l545HM8
 rmuj6+AYZ1luKwhYLwOazd7/obKuAh/oeooatMHjC7nS0F+vsPDeI2nSvW2F+wZHsAsp
 aGxl3NXFxgTe0wMPLd8vVdHLug9/5LF6doA= 
In-Reply-To: <1409204634-1123-1-git-send-email-agartrell@fb.com>
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
 net/netfilter/ipvs/ip_vs_lc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_lc.c b/net/netfilter/ipvs/ip_vs_lc.c
index 2bdcb1c..19a0769 100644
--- a/net/netfilter/ipvs/ip_vs_lc.c
+++ b/net/netfilter/ipvs/ip_vs_lc.c
@@ -59,7 +59,7 @@ ip_vs_lc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	else
 		IP_VS_DBG_BUF(6, "LC: server %s:%u activeconns %d "
 			      "inactconns %d\n",
-			      IP_VS_DBG_ADDR(svc->af, &least->addr),
+			      IP_VS_DBG_ADDR(least->af, &least->addr),
 			      ntohs(least->port),
 			      atomic_read(&least->activeconns),
 			      atomic_read(&least->inactconns));
-- 
1.8.1

