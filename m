From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] ipvs: fix dst_lock locking on dest update
Date: Wed,  2 Mar 2011 07:59:35 +0900
Message-ID: <1299020375-11362-2-git-send-email-horms@verge.net.au>
References: <1299020375-11362-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1299020375-11362-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

	Fix dst_lock usage in __ip_vs_update_dest. We need
_bh locking because destination is updated in user context.
Can cause lockups on frequent destination updates.
Problem reported by Simon Kirby. Bug was introduced
in 2.6.37 from the "ipvs: changes for local real server"
change.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 22f7ad5..ba98e13 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -808,9 +808,9 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	dest->u_threshold = udest->u_threshold;
 	dest->l_threshold = udest->l_threshold;
 
-	spin_lock(&dest->dst_lock);
+	spin_lock_bh(&dest->dst_lock);
 	ip_vs_dst_reset(dest);
-	spin_unlock(&dest->dst_lock);
+	spin_unlock_bh(&dest->dst_lock);
 
 	if (add)
 		ip_vs_new_estimator(&dest->stats);
-- 
1.7.2.3

