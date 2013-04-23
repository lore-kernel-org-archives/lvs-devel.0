From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 1/9] ipvs: properly dereference dest_dst in ip_vs_forget_dev
Date: Tue, 23 Apr 2013 12:03:52 +0900
Message-ID: <1366686240-23493-2-git-send-email-horms@verge.net.au>
References: <1366686240-23493-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1366686240-23493-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Dan Carpenter <dan.carpenter@oracle.com>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

Use rcu_dereference_protected to resolve
sparse warning, found by kbuild test robot:

net/netfilter/ipvs/ip_vs_ctl.c:1464:35: warning: dereference of
noderef expression

Problem from commit 026ace060dfe29
("ipvs: optimize dst usage for real server")

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

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
1.8.2.1

