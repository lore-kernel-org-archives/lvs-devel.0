From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH V4 2/7] ipvs: IPv6 extend ICMPv6 handling for future types
Date: Wed, 26 Sep 2012 14:06:11 +0200
Message-ID: <20120926120558.24804.98621.stgit@dragon>
References: <20120926120534.24804.78415.stgit@dragon>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20120926120534.24804.78415.stgit@dragon>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Hans Schillstrom <hans@schillstrom.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

Extend handling of ICMPv6, to all none Informational Messages
(via ICMPV6_INFOMSG_MASK).  This actually only extend our handling to
type ICMPV6_PARAMPROB (Parameter Problem), and future types.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
This change have been pulled out the frag handling patch
as it was not related to IPv6 frag handling.

 net/netfilter/ipvs/ip_vs_core.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

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

