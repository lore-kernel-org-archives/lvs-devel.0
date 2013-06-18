From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 1/3] ipvs: SCTP ports should be writable in ICMP packets
Date: Tue, 18 Jun 2013 10:08:06 +0300
Message-ID: <1371539288-5036-2-git-send-email-ja@ssi.bg>
References: <1371539288-5036-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1371539288-5036-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

Make sure that SCTP ports are writable when embedded in ICMP
from client, so that ip_vs_nat_icmp can translate them safely.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_core.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index e9b0330..4f69e83 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1442,7 +1442,8 @@ ignore_ipip:
 
 	/* do the statistics and put it back */
 	ip_vs_in_stats(cp, skb);
-	if (IPPROTO_TCP == cih->protocol || IPPROTO_UDP == cih->protocol)
+	if (IPPROTO_TCP == cih->protocol || IPPROTO_UDP == cih->protocol ||
+	    IPPROTO_SCTP == cih->protocol)
 		offset += 2 * sizeof(__u16);
 	verdict = ip_vs_icmp_xmit(skb, cp, pp, offset, hooknum, &ciph);
 
-- 
1.7.3.4

