From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 84/84] ipvs: Pass ipvs into ip_vs_gather_frags
Date: Thu, 24 Sep 2015 09:53:09 +0900
Message-ID: <1443055989-1306-85-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: "Eric W. Biederman" <ebiederm@xmission.com>

This will be needed later when the network namespace guessing is
removed from ip_defrag.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index ab85ae0f531f..fb6b6c87d841 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -688,7 +688,8 @@ static inline enum ip_defrag_users ip_vs_defrag_user(unsigned int hooknum)
 	return IP_DEFRAG_VS_OUT;
 }
 
-static inline int ip_vs_gather_frags(struct sk_buff *skb, u_int32_t user)
+static inline int ip_vs_gather_frags(struct netns_ipvs *ipvs,
+				     struct sk_buff *skb, u_int32_t user)
 {
 	int err;
 
@@ -912,7 +913,7 @@ static int ip_vs_out_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb,
 
 	/* reassemble IP fragments */
 	if (ip_is_fragment(ip_hdr(skb))) {
-		if (ip_vs_gather_frags(skb, ip_vs_defrag_user(hooknum)))
+		if (ip_vs_gather_frags(ipvs, skb, ip_vs_defrag_user(hooknum)))
 			return NF_STOLEN;
 	}
 
@@ -1232,7 +1233,7 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
 	if (af == AF_INET)
 #endif
 		if (unlikely(ip_is_fragment(ip_hdr(skb)) && !pp->dont_defrag)) {
-			if (ip_vs_gather_frags(skb,
+			if (ip_vs_gather_frags(ipvs, skb,
 					       ip_vs_defrag_user(hooknum)))
 				return NF_STOLEN;
 
@@ -1403,7 +1404,7 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 
 	/* reassemble IP fragments */
 	if (ip_is_fragment(ip_hdr(skb))) {
-		if (ip_vs_gather_frags(skb, ip_vs_defrag_user(hooknum)))
+		if (ip_vs_gather_frags(ipvs, skb, ip_vs_defrag_user(hooknum)))
 			return NF_STOLEN;
 	}
 
-- 
2.1.4

