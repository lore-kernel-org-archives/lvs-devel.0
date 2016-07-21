From: fgao@ikuai8.com
Subject: [PATCH 1/1] lvs: Use IS_ERR_OR_NULL(svc) instead of IS_ERR(svc) || svc == NULL
Date: Fri, 22 Jul 2016 07:55:41 +0800
Message-ID: <1469145341-15488-1-git-send-email-fgao@ikuai8.com>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>

From: Gao Feng <fgao@ikuai8.com>

This minor refactoring does not change the logic of function
ip_vs_genl_dump_dests.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v1: Initial patch

 net/netfilter/ipvs/ip_vs_ctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c3c809b..6dc86cc 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3267,7 +3267,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 
 
 	svc = ip_vs_genl_find_service(ipvs, attrs[IPVS_CMD_ATTR_SERVICE]);
-	if (IS_ERR(svc) || svc == NULL)
+	if (IS_ERR_OR_NULL(svc))
 		goto out_err;
 
 	/* Dump the destinations */
-- 
1.9.1


