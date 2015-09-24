From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 71/84] ipvs: Better derivation of ipvs in ip_vs_in_stats and ip_vs_out_stats
Date: Thu, 24 Sep 2015 09:52:56 +0900
Message-ID: <1443055989-1306-72-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
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
2.1.4

