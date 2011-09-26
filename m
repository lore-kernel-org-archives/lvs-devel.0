From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 3/5] IPVS: Remove unused parameter from ip_vs_confirm_conntrack()
Date: Mon, 26 Sep 2011 18:05:36 +0900
Message-ID: <1317027938-22053-4-git-send-email-horms@verge.net.au>
References: <1317027938-22053-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1317027938-22053-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>, "David S. Miller" <davem@davemloft.net>, Simon Horman <horms@verge.net.au>

Acked-by: Julian Anastasov <ja@ssi.bg>
Acked-by Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |    5 ++---
 net/netfilter/ipvs/ip_vs_nfct.c |    2 +-
 net/netfilter/ipvs/ip_vs_xmit.c |    2 +-
 3 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 1aaf915..a5f0f6b 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1377,7 +1377,7 @@ static inline int ip_vs_conntrack_enabled(struct netns_ipvs *ipvs)
 
 extern void ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp,
 				   int outin);
-extern int ip_vs_confirm_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp);
+extern int ip_vs_confirm_conntrack(struct sk_buff *skb);
 extern void ip_vs_nfct_expect_related(struct sk_buff *skb, struct nf_conn *ct,
 				      struct ip_vs_conn *cp, u_int8_t proto,
 				      const __be16 port, int from_rs);
@@ -1395,8 +1395,7 @@ static inline void ip_vs_update_conntrack(struct sk_buff *skb,
 {
 }
 
-static inline int ip_vs_confirm_conntrack(struct sk_buff *skb,
-					  struct ip_vs_conn *cp)
+static inline int ip_vs_confirm_conntrack(struct sk_buff *skb);
 {
 	return NF_ACCEPT;
 }
diff --git a/net/netfilter/ipvs/ip_vs_nfct.c b/net/netfilter/ipvs/ip_vs_nfct.c
index f454c80..022e77e 100644
--- a/net/netfilter/ipvs/ip_vs_nfct.c
+++ b/net/netfilter/ipvs/ip_vs_nfct.c
@@ -127,7 +127,7 @@ ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp, int outin)
 	nf_conntrack_alter_reply(ct, &new_tuple);
 }
 
-int ip_vs_confirm_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp)
+int ip_vs_confirm_conntrack(struct sk_buff *skb)
 {
 	return nf_conntrack_confirm(skb);
 }
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index ee319a4..aa2d720 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -339,7 +339,7 @@ ip_vs_dst_reset(struct ip_vs_dest *dest)
 								\
 	(skb)->ipvs_property = 1;				\
 	if (unlikely((cp)->flags & IP_VS_CONN_F_NFCT))		\
-		__ret = ip_vs_confirm_conntrack(skb, cp);	\
+		__ret = ip_vs_confirm_conntrack(skb);		\
 	if (__ret == NF_ACCEPT) {				\
 		nf_reset(skb);					\
 		skb_forward_csum(skb);				\
-- 
1.7.5.4
