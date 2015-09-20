From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 70/84] ipvs: Pass ipvs into ensure_mtu_is adequate
Date: Sun, 20 Sep 2015 01:23:26 -0500
Message-ID: <1442730220-32458-70-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

This allows two different ways for computing/guessing net to be
removed from ensure_mtu_is_adequate.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
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
