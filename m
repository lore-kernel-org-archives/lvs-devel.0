From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 14/21] ipvs: use correct address family in LC logs
Date: Tue, 16 Sep 2014 09:34:28 +0900
Message-ID: <1410827675-3637-15-git-send-email-horms@verge.net.au>
References: <1410827675-3637-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1410827675-3637-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Alex Gartrell <agartrell@fb.com>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

Needed to support svc->af != dest->af.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Alex Gartrell <agartrell@fb.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
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
2.0.1

