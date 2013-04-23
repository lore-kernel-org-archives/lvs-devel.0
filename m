From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 6/9] ipvs: Avoid shadowing net variable in ip_vs_leave()
Date: Tue, 23 Apr 2013 12:03:57 +0900
Message-ID: <1366686240-23493-7-git-send-email-horms@verge.net.au>
References: <1366686240-23493-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1366686240-23493-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Dan Carpenter <dan.carpenter@oracle.com>, Simon Horman <horms@verge.net.au>

Flagged by sparse.
Compile and sparse tested only.

Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index a0d7bd3..085b588 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -584,9 +584,9 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 #ifdef CONFIG_IP_VS_IPV6
 	if (svc->af == AF_INET6) {
 		if (!skb->dev) {
-			struct net *net = dev_net(skb_dst(skb)->dev);
+			struct net *net_ = dev_net(skb_dst(skb)->dev);
 
-			skb->dev = net->loopback_dev;
+			skb->dev = net_->loopback_dev;
 		}
 		icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);
 	} else
-- 
1.8.2.1

