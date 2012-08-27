From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH 2/2] ipvs: Extend MTU check to account for IPv6 NAT defrag
	changes
Date: Mon, 27 Aug 2012 16:42:27 +0200
Message-ID: <20120827144059.5754.55303.stgit@dragon>
References: <20120827144024.5754.23872.stgit@dragon>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120827144024.5754.23872.stgit@dragon>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Hans Schillstrom <hans@schillstrom.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org

This patch is necessary, to make IPVS work, after Patrick McHardys
IPv6 NAT defragmentation changes.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

I would appriciate, if someone (e.g. Julian) double check the tunnel mode code.
--Jesper

 net/netfilter/ipvs/ip_vs_xmit.c |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index e56f0df..20763de 100644
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
@@ -956,8 +963,11 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
 
 	/* MTU checking: Special for tunnel mode */
-	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr) &&
-	    !skb_is_gso(skb)) {
+	if ((!IP6CB(skb)->frag_max_size &&
+	     (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr) &&
+	      !skb_is_gso(skb)))
+	    || IP6CB(skb)->frag_max_size + sizeof(struct ipv6hdr) > mtu) {
+
 		if (!skb->dev) {
 			struct net *net = dev_net(skb_dst(skb)->dev);
 

