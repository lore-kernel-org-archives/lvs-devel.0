From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v2 16/18] ipvs: use correct address family in SED logs
Date: Thu, 14 Aug 2014 20:23:39 -0700
Message-ID: <1408073021-24007-17-git-send-email-agartrell@fb.com>
References: <1408073021-24007-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=1mnIlqXcr6TZNyLu5MYKLd9/AOGPK4oQiZHF4PJBTQ4=;
 b=IXhoXmpAd8RrsOkgHeuJ7HBCMl8Mxh5mmvNQ7oTkxmuLKF8dmAzkdj3W9iuBYQZJ/T2E
 TUoXt+pfMVTk9bymbNXTdB0k6eHdrtXqGbxChvORyR/EYqSac7Ev6vkexmVkOXQZ72cf
 vcR/+pvjpxYl6ufnlDXWqD/tzDuB2LkqsjA= 
In-Reply-To: <1408073021-24007-1-git-send-email-agartrell@fb.com>
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
 net/netfilter/ipvs/ip_vs_sed.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_sed.c b/net/netfilter/ipvs/ip_vs_sed.c
index e446b9f..f8e2d00 100644
--- a/net/netfilter/ipvs/ip_vs_sed.c
+++ b/net/netfilter/ipvs/ip_vs_sed.c
@@ -108,7 +108,8 @@ ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 
 	IP_VS_DBG_BUF(6, "SED: server %s:%u "
 		      "activeconns %d refcnt %d weight %d overhead %d\n",
-		      IP_VS_DBG_ADDR(svc->af, &least->addr), ntohs(least->port),
+		      IP_VS_DBG_ADDR(least->af, &least->addr),
+		      ntohs(least->port),
 		      atomic_read(&least->activeconns),
 		      atomic_read(&least->refcnt),
 		      atomic_read(&least->weight), loh);
-- 
1.8.1

