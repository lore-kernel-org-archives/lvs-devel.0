From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 70/84] ipvs: Pass ipvs into ensure_mtu_is adequate
Date: Thu, 24 Sep 2015 09:52:55 +0900
Message-ID: <1443055989-1306-71-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: "Eric W. Biederman" <ebiederm@xmission.com>

This allows two different ways for computing/guessing net to be
removed from ensure_mtu_is_adequate.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 13a678a63ed5..77182b9750cd 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -212,13 +212,14 @@ static inline void maybe_update_pmtu(int skb_af, struct sk_buff *skb, int mtu)
 		ort->dst.ops->update_pmtu(&ort->dst, sk, NULL, mtu);
 }
 
-static inline bool ensure_mtu_is_adequate(int skb_af, int rt_mode,
+static inline bool ensure_mtu_is_adequate(struct netns_ipvs *ipvs, int skb_af,
+					  int rt_mode,
 					  struct ip_vs_iphdr *ipvsh,
 					  struct sk_buff *skb, int mtu)
 {
 #ifdef CONFIG_IP_VS_IPV6
 	if (skb_af == AF_INET6) {
-		struct net *net = dev_net(skb_dst(skb)->dev);
+		struct net *net = ipvs->net;
 
 		if (unlikely(__mtu_check_toobig_v6(skb, mtu))) {
 			if (!skb->dev)
@@ -233,8 +234,6 @@ static inline bool ensure_mtu_is_adequate(int skb_af, int rt_mode,
 	} else
 #endif
 	{
-		struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
-
 		/* If we're going to tunnel the packet and pmtu discovery
 		 * is disabled, we'll just fragment it anyway
 		 */
@@ -338,7 +337,7 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 		maybe_update_pmtu(skb_af, skb, mtu);
 	}
 
-	if (!ensure_mtu_is_adequate(skb_af, rt_mode, ipvsh, skb, mtu))
+	if (!ensure_mtu_is_adequate(ipvs, skb_af, rt_mode, ipvsh, skb, mtu))
 		goto err_put;
 
 	skb_dst_drop(skb);
@@ -487,7 +486,7 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 		maybe_update_pmtu(skb_af, skb, mtu);
 	}
 
-	if (!ensure_mtu_is_adequate(skb_af, rt_mode, ipvsh, skb, mtu))
+	if (!ensure_mtu_is_adequate(ipvs, skb_af, rt_mode, ipvsh, skb, mtu))
 		goto err_put;
 
 	skb_dst_drop(skb);
-- 
2.1.4
