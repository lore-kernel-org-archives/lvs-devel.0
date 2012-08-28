From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH V2 2/2] ipvs: Extend MTU check to account for IPv6 NAT defrag
	changes
Date: Tue, 28 Aug 2012 16:23:33 +0200
Message-ID: <20120828142248.11475.15917.stgit@dragon>
References: <20120828142051.11475.63775.stgit@dragon>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20120828142051.11475.63775.stgit@dragon>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Hans Schillstrom <hans@schillstrom.com>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org

This patch is necessary, to make IPVS work, after Patrick McHardys
IPv6 NAT defragmentation changes.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
In V2: the tunnel mode is no longer a special case.

 net/netfilter/ipvs/ip_vs_xmit.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 67a3978..56f6d5d 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -88,7 +88,14 @@ __ip_vs_dst_check(struct ip_vs_dest *dest, u32 rtos)
 static inline bool
 __mtu_check_toobig_v6(const struct sk_buff *skb, u32 mtu)
 {
-	if (skb->len > mtu && !skb_is_gso(skb)) {
+	if (IP6CB(skb)->frag_max_size) {
+		/* frag_max_size tell us that, this packet have been
+		 * defragmented by netfilter IPv6 conntrack module.
+		 */
+		if (IP6CB(skb)->frag_max_size > mtu)
+			return true; /* largest fragment violate MTU */
+	}
+	else if (skb->len > mtu && !skb_is_gso(skb)) {
 		return true; /* Packet size violate MTU size */
 	}
 	return false;

