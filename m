From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] IPVS Bug, Null ptr in ip_vs_ctl.c ip_vs_genl_dump_daemons().
Date: Thu, 31 Mar 2011 10:32:15 +0900
Message-ID: <1301535135-4288-2-git-send-email-horms@verge.net.au>
References: <1301535135-4288-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1301535135-4288-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>, Hans Schillstrom <hans.schillstrom@ericsson.com>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

ipvsadm -ln --daemon will trigger a Null pointer exception because
ip_vs_genl_dump_daemons() uses skb_net() instead of skb_sknet().

To prevent others from NULL ptr a check is made in ip_vs.h skb_net().

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h            |    2 +-
 net/netfilter/ipvs/ip_vs_ctl.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 30b49ed..4d1b71a 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -52,7 +52,7 @@ static inline struct net *skb_net(const struct sk_buff *skb)
 	 */
 	if (likely(skb->dev && skb->dev->nd_net))
 		return dev_net(skb->dev);
-	if (skb_dst(skb)->dev)
+	if (skb_dst(skb) && skb_dst(skb)->dev)
 		return dev_net(skb_dst(skb)->dev);
 	WARN(skb->sk, "Maybe skb_sknet should be used in %s() at line:%d\n",
 		      __func__, __LINE__);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 33733c8..ae47090 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3120,7 +3120,7 @@ nla_put_failure:
 static int ip_vs_genl_dump_daemons(struct sk_buff *skb,
 				   struct netlink_callback *cb)
 {
-	struct net *net = skb_net(skb);
+	struct net *net = skb_sknet(skb);
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	mutex_lock(&__ip_vs_mutex);
-- 
1.7.4.1

