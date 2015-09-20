From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 71/84] ipvs: Better derivation of ipvs in ip_vs_in_stats and ip_vs_out_stats
Date: Sun, 20 Sep 2015 01:23:27 -0500
Message-ID: <1442730220-32458-71-git-send-email-ebiederm@xmission.com>
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

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 514596b7a324..1c9c52349b7c 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -112,7 +112,7 @@ static inline void
 ip_vs_in_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 {
 	struct ip_vs_dest *dest = cp->dest;
-	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
+	struct netns_ipvs *ipvs = cp->ipvs;
 
 	if (dest && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
 		struct ip_vs_cpu_stats *s;
@@ -146,7 +146,7 @@ static inline void
 ip_vs_out_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 {
 	struct ip_vs_dest *dest = cp->dest;
-	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
+	struct netns_ipvs *ipvs = cp->ipvs;
 
 	if (dest && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
 		struct ip_vs_cpu_stats *s;
-- 
2.2.1

