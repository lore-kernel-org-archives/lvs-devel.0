From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 04/15] ipvs: pull out ip_vs_try_to_schedule function
Date: Thu, 17 Sep 2015 14:40:40 +0900
Message-ID: <1442468451-24012-5-git-send-email-horms@verge.net.au>
References: <1442468451-24012-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1442468451-24012-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Alex Gartrell <agartrell@fb.com>, Simon Horman <horms@verge.net.au>

From: Alex Gartrell <agartrell@fb.com>

This is necessary as we'll be trying to schedule icmp later and we'll want
to share this code.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c | 60 ++++++++++++++++++++++++++---------------
 1 file changed, 39 insertions(+), 21 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index bb998d432ce7..2c44e34314c2 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1327,6 +1327,42 @@ ip_vs_local_reply6(const struct nf_hook_ops *ops, struct sk_buff *skb,
 
 #endif
 
+static unsigned int
+ip_vs_try_to_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
+		      int *verdict, struct ip_vs_conn **cpp,
+		      struct ip_vs_iphdr *iph)
+{
+	struct ip_vs_protocol *pp = pd->pp;
+
+	if (!iph->fragoffs) {
+		/* No (second) fragments need to enter here, as nf_defrag_ipv6
+		 * replayed fragment zero will already have created the cp
+		 */
+
+		/* Schedule and create new connection entry into cpp */
+		if (!pp->conn_schedule(af, skb, pd, verdict, cpp, iph))
+			return 0;
+	}
+
+	if (unlikely(!*cpp)) {
+		/* sorry, all this trouble for a no-hit :) */
+		IP_VS_DBG_PKT(12, af, pp, skb, iph->off,
+			      "ip_vs_in: packet continues traversal as normal");
+		if (iph->fragoffs) {
+			/* Fragment that couldn't be mapped to a conn entry
+			 * is missing module nf_defrag_ipv6
+			 */
+			IP_VS_DBG_RL("Unhandled frag, load nf_defrag_ipv6\n");
+			IP_VS_DBG_PKT(7, af, pp, skb, iph->off,
+				      "unhandled fragment");
+		}
+		*verdict = NF_ACCEPT;
+		return 0;
+	}
+
+	return 1;
+}
+
 /*
  *	Handle ICMP messages in the outside-to-inside direction (incoming).
  *	Find any that might be relevant, check against existing connections,
@@ -1690,33 +1726,15 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 		cp = NULL;
 	}
 
-	if (unlikely(!cp) && !iph.fragoffs) {
-		/* No (second) fragments need to enter here, as nf_defrag_ipv6
-		 * replayed fragment zero will already have created the cp
-		 */
+	if (unlikely(!cp)) {
 		int v;
 
-		/* Schedule and create new connection entry into &cp */
-		if (!pp->conn_schedule(af, skb, pd, &v, &cp, &iph))
+		if (!ip_vs_try_to_schedule(af, skb, pd, &v, &cp, &iph))
 			return v;
 	}
 
-	if (unlikely(!cp)) {
-		/* sorry, all this trouble for a no-hit :) */
-		IP_VS_DBG_PKT(12, af, pp, skb, 0,
-			      "ip_vs_in: packet continues traversal as normal");
-		if (iph.fragoffs) {
-			/* Fragment that couldn't be mapped to a conn entry
-			 * is missing module nf_defrag_ipv6
-			 */
-			IP_VS_DBG_RL("Unhandled frag, load nf_defrag_ipv6\n");
-			IP_VS_DBG_PKT(7, af, pp, skb, iph.off,
-				      "unhandled fragment");
-		}
-		return NF_ACCEPT;
-	}
