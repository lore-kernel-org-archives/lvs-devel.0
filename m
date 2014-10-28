From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf] ipvs: Avoid null-pointer deref in debug code
Date: Tue, 28 Oct 2014 10:05:34 +0900
Message-ID: <1414458334-22479-2-git-send-email-horms@verge.net.au>
References: <1414458334-22479-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1414458334-22479-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Alex Gartrell <agartrell@fb.com>, Simon Horman <horms@verge.net.au>

From: Alex Gartrell <agartrell@fb.com>

Use daddr instead of reaching into dest.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Alex Gartrell <agartrell@fb.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 91f17c1..437a366 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -316,7 +316,7 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 	if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
 						  local))) {
 		IP_VS_DBG_RL("We are crossing local and non-local addresses"
-			     " daddr=%pI4\n", &dest->addr.ip);
+			     " daddr=%pI4\n", &daddr);
 		goto err_put;
 	}
 
@@ -458,7 +458,7 @@ __ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 	if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
 						  local))) {
 		IP_VS_DBG_RL("We are crossing local and non-local addresses"
-			     " daddr=%pI6\n", &dest->addr.in6);
+			     " daddr=%pI6\n", daddr);
 		goto err_put;
 	}
 
-- 
2.1.1

