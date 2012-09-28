From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/7] ipvs: IPv6 extend ICMPv6 handling for future types
Date: Fri, 28 Sep 2012 11:54:59 +0900
Message-ID: <1348800904-23902-3-git-send-email-horms@verge.net.au>
References: <1348800904-23902-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1348800904-23902-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Hans Schillstrom <hans@schillstrom.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Simon Horman <horms@verge.net.au>

From: Jesper Dangaard Brouer <brouer@redhat.com>

Extend handling of ICMPv6, to all none Informational Messages
(via ICMPV6_INFOMSG_MASK).  This actually only extend our handling to
type ICMPV6_PARAMPROB (Parameter Problem), and future types.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 4edb654..ebd105c 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -950,9 +950,7 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 	 * this means that some packets will manage to get a long way
 	 * down this stack and then be rejected, but that's life.
 	 */
-	if ((ic->icmp6_type != ICMPV6_DEST_UNREACH) &&
-	    (ic->icmp6_type != ICMPV6_PKT_TOOBIG) &&
-	    (ic->icmp6_type != ICMPV6_TIME_EXCEED)) {
+	if (ic->icmp6_type & ICMPV6_INFOMSG_MASK) {
 		*related = 0;
 		return NF_ACCEPT;
 	}
@@ -1498,9 +1496,7 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 	 * this means that some packets will manage to get a long way
 	 * down this stack and then be rejected, but that's life.
 	 */
-	if ((ic->icmp6_type != ICMPV6_DEST_UNREACH) &&
-	    (ic->icmp6_type != ICMPV6_PKT_TOOBIG) &&
-	    (ic->icmp6_type != ICMPV6_TIME_EXCEED)) {
+	if (ic->icmp6_type & ICMPV6_INFOMSG_MASK) {
 		*related = 0;
 		return NF_ACCEPT;
 	}
-- 
1.7.10.4

