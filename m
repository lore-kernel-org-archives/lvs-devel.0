From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 1/6] ipvs: properly dereference dest_dst in ip_vs_forget_dev
Date: Wed, 17 Apr 2013 23:50:45 +0300
Message-ID: <1366231850-22188-2-git-send-email-ja@ssi.bg>
References: <1366231850-22188-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1366231850-22188-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>

	Use rcu_dereference_protected to resolve
sparse warning, found by kbuild test robot:

net/netfilter/ipvs/ip_vs_ctl.c:1464:35: warning: dereference of
noderef expression

	Problem from commit 026ace060dfe29
("ipvs: optimize dst usage for real server")

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 9e4074c..5a65444 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1460,8 +1460,11 @@ void ip_vs_service_net_cleanup(struct net *net)
 static inline void
 ip_vs_forget_dev(struct ip_vs_dest *dest, struct net_device *dev)
 {
+	struct ip_vs_dest_dst *dest_dst;
+
 	spin_lock_bh(&dest->dst_lock);
-	if (dest->dest_dst && dest->dest_dst->dst_cache->dev == dev) {
+	dest_dst = rcu_dereference_protected(dest->dest_dst, 1);
+	if (dest_dst && dest_dst->dst_cache->dev == dev) {
 		IP_VS_DBG_BUF(3, "Reset dev:%s dest %s:%u ,dest->refcnt=%d\n",
 			      dev->name,
 			      IP_VS_DBG_ADDR(dest->af, &dest->addr),
-- 
1.7.3.4

