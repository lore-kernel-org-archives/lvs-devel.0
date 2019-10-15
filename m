From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/6] ipvs: no need to update skb route entry for local destination packets.
Date: Tue, 15 Oct 2019 09:32:07 +0200
Message-ID: <20191015073212.19394-2-horms@verge.net.au>
References: <20191015073212.19394-1-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20191015073212.19394-1-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, zhang kai <zhangkaiheb@126.com>, Simon Horman <horms@verge.net.au>

From: zhang kai <zhangkaiheb@126.com>

In the end of function __ip_vs_get_out_rt/__ip_vs_get_out_rt_v6,the
'local' variable is always zero.

Signed-off-by: zhang kai <zhangkaiheb@126.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 888d3068a492..b1e300f8881b 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -407,12 +407,9 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 		goto err_put;
 
 	skb_dst_drop(skb);
-	if (noref) {
-		if (!local)
-			skb_dst_set_noref(skb, &rt->dst);
-		else
-			skb_dst_set(skb, dst_clone(&rt->dst));
-	} else
+	if (noref)
+		skb_dst_set_noref(skb, &rt->dst);
+	else
 		skb_dst_set(skb, &rt->dst);
 
 	return local;
@@ -574,12 +571,9 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 		goto err_put;
 
 	skb_dst_drop(skb);
-	if (noref) {
-		if (!local)
-			skb_dst_set_noref(skb, &rt->dst);
-		else
-			skb_dst_set(skb, dst_clone(&rt->dst));
-	} else
+	if (noref)
+		skb_dst_set_noref(skb, &rt->dst);
+	else
 		skb_dst_set(skb, &rt->dst);
 
 	return local;
-- 
2.11.0

