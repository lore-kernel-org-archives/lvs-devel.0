From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next] ipvs: remove unnecessary assignment in __ip_vs_get_out_rt
Date: Tue, 28 Oct 2014 09:59:20 +0900
Message-ID: <1414457960-20864-2-git-send-email-horms@verge.net.au>
References: <1414457960-20864-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1414457960-20864-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Alex Gartrell <agartrell@fb.com>, Simon Horman <horms@verge.net.au>

From: Alex Gartrell <agartrell@fb.com>

It is a precondition of the function that daddr be equal to dest->addr.ip
if dest is non-NULL, so this additional assignment is just confusing for
stupid engineers like me.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 91f17c1..5efa597 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -293,7 +293,6 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 				  &dest->addr.ip, &dest_dst->dst_saddr.ip,
 				  atomic_read(&rt->dst.__refcnt));
 		}
-		daddr = dest->addr.ip;
 		if (ret_saddr)
 			*ret_saddr = dest_dst->dst_saddr.ip;
 	} else {
-- 
2.1.1

