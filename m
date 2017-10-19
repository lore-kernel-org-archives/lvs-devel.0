From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] netfilter: mark expected switch fall-throughs
Date: Thu, 19 Oct 2017 09:06:16 -0500
Message-ID: <20171019140616.GA15989@embeddedor.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, "Gustavo A. R. Silva" <garsilva@embeddedor.com>

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Notice that in some cases I placed the "fall through" comment on its own
line, which is what GCC is expecting to find.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
This code was tested by compilation only (GCC 7.2.0 was used).
Please, verify if the actual intention of the code is to fall through.

 net/netfilter/ipset/ip_set_core.c      | 3 ++-
 net/netfilter/ipvs/ip_vs_proto_tcp.c   | 1 +
 net/netfilter/ipvs/ip_vs_proto_udp.c   | 1 +
 net/netfilter/nf_conntrack_h323_asn1.c | 3 +++
 net/netfilter/nft_cmp.c                | 2 ++
 net/netfilter/x_tables.c               | 3 ++-
 6 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index cf84f7b..72f654a 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1386,7 +1386,8 @@ ip_set_dump_start(struct sk_buff *skb, struct netlink_callback *cb)
 				goto next_set;
 			if (set->variant->uref)
 				set->variant->uref(set, cb, true);
-			/* Fall through and add elements */
+			/* add elements */
+			/* fall through */
 		default:
 			rcu_read_lock_bh();
 			ret = set->variant->list(set, skb, cb);
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 1c6e101..569631d 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -315,6 +315,7 @@ tcp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
 	switch (skb->ip_summed) {
 	case CHECKSUM_NONE:
 		skb->csum = skb_checksum(skb, tcphoff, skb->len - tcphoff, 0);
+		/* fall through */
 	case CHECKSUM_COMPLETE:
 #ifdef CONFIG_IP_VS_IPV6
 		if (af == AF_INET6) {
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 30e11cd..c15ef7c 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -319,6 +319,7 @@ udp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
 		case CHECKSUM_NONE:
 			skb->csum = skb_checksum(skb, udphoff,
 						 skb->len - udphoff, 0);
+			/* fall through */
 		case CHECKSUM_COMPLETE:
 #ifdef CONFIG_IP_VS_IPV6
 			if (af == AF_INET6) {
diff --git a/net/netfilter/nf_conntrack_h323_asn1.c b/net/netfilter/nf_conntrack_h323_asn1.c
index 89b2e46..7336e5c 100644
--- a/net/netfilter/nf_conntrack_h323_asn1.c
+++ b/net/netfilter/nf_conntrack_h323_asn1.c
@@ -250,12 +250,15 @@ static unsigned int get_uint(bitstr_t *bs, int b)
 	case 4:
 		v |= *bs->cur++;
 		v <<= 8;
+		/* fall through */
 	case 3:
 		v |= *bs->cur++;
 		v <<= 8;
+		/* fall through */
 	case 2:
 		v |= *bs->cur++;
 		v <<= 8;
+		/* fall through */
 	case 1:
 		v |= *bs->cur++;
 		break;
diff --git a/net/netfilter/nft_cmp.c b/net/netfilter/nft_cmp.c
index c2945eb..fa90a84 100644
--- a/net/netfilter/nft_cmp.c
+++ b/net/netfilter/nft_cmp.c
@@ -44,6 +44,7 @@ static void nft_cmp_eval(const struct nft_expr *expr,
 	case NFT_CMP_LT:
 		if (d == 0)
 			goto mismatch;
+		/* fall through */
 	case NFT_CMP_LTE:
 		if (d > 0)
 			goto mismatch;
@@ -51,6 +52,7 @@ static void nft_cmp_eval(const struct nft_expr *expr,
 	case NFT_CMP_GT:
 		if (d == 0)
 			goto mismatch;
+		/* fall through */
 	case NFT_CMP_GTE:
 		if (d < 0)
 			goto mismatch;
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index d8571f4..fa5cdd0 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1382,7 +1382,8 @@ static void *xt_mttg_seq_next(struct seq_file *seq, void *v, loff_t *ppos,
 		trav->curr = trav->curr->next;
 		if (trav->curr != trav->head)
 			break;
-		/* fallthru, _stop will unlock */
+		/* _stop will unlock */
+		/* fall through */
 	default:
 		return NULL;
 	}
-- 
2.7.4

