From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH v2] netfilter: mark expected switch fall-throughs
Date: Tue, 7 Nov 2017 08:19:29 -0600
Message-ID: <20171107141929.GA24483@embeddedor.com>
References: <20171107073045.Horde.fHvUlYL1jmnkY_bpuXRFqCR@gator4166.hostgator.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171107073045.Horde.fHvUlYL1jmnkY_bpuXRFqCR@gator4166.hostgator.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, "Gustavo A. R. Silva" <garsilva@embeddedor.com>

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Addresses-Coverity-ID: 1128839
Addresses-Coverity-ID: 1128840
Addresses-Coverity-ID: 115120
Addresses-Coverity-ID: 115121
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
Changes in v2:
 Replace code comments with "fall through" as suggested by Pablo Neira Ayuso.
 Add Coverity IDs to the changelog.

 net/netfilter/ipset/ip_set_core.c      | 2 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c   | 1 +
 net/netfilter/ipvs/ip_vs_proto_udp.c   | 1 +
 net/netfilter/nf_conntrack_h323_asn1.c | 3 +++
 net/netfilter/nft_cmp.c                | 2 ++
 net/netfilter/x_tables.c               | 2 +-
 6 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index cf84f7b..d5a43ca 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1386,7 +1386,7 @@ ip_set_dump_start(struct sk_buff *skb, struct netlink_callback *cb)
 				goto next_set;
 			if (set->variant->uref)
 				set->variant->uref(set, cb, true);
-			/* Fall through and add elements */
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
index cf1bf26..c957fcf 100644
--- a/net/netfilter/nf_conntrack_h323_asn1.c
+++ b/net/netfilter/nf_conntrack_h323_asn1.c
@@ -250,12 +250,15 @@ static unsigned int get_uint(struct bitstr *bs, int b)
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
index a77dd51..7c1414e 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1397,7 +1397,7 @@ static void *xt_mttg_seq_next(struct seq_file *seq, void *v, loff_t *ppos,
 		trav->curr = trav->curr->next;
 		if (trav->curr != trav->head)
 			break;
-		/* fallthru, _stop will unlock */
+		/* fall through */
 	default:
 		return NULL;
 	}
-- 
2.7.4

