From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v2 13/18] ipvs: use correct address family in LC logs
Date: Thu, 14 Aug 2014 20:23:36 -0700
Message-ID: <1408073021-24007-14-git-send-email-agartrell@fb.com>
References: <1408073021-24007-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=5v1lsTSSb9fqCc9NSPxGGrOYfx9ffskVWO1V4ZSpK+M=;
 b=ImjHYSH/0ZHow9qr7rO28zISj586zXcy1g3mRpHWj9CXOUjlfW2krhWdzDOUYskiaJ0l
 8QXulYy9zQmBAtK1LctEYmvuzEv/Kk8siLWBvXpTv+3HHsCQXcDnVyLF2AXhGNO1ls1g
 mF0hsvqGCtX0UFHoGzT4KDA2eJXpgbzSdzA= 
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

