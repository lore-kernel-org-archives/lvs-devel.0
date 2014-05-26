From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf] ipvs: Fix panic due to non-linear skb
Date: Mon, 26 May 2014 10:37:15 +0900
Message-ID: <1401068235-6730-2-git-send-email-horms@verge.net.au>
References: <1401068235-6730-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1401068235-6730-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Peter Christensen <pch@ordbogen.com>, Simon Horman <horms@verge.net.au>

From: Peter Christensen <pch@ordbogen.com>

Receiving a ICMP response to an IPIP packet in a non-linear skb could
cause a kernel panic in __skb_pull.

The problem was introduced in
commit f2edb9f7706dcb2c0d9a362b2ba849efe3a97f5e ("ipvs: implement
passive PMTUD for IPIP packets").

Signed-off-by: Peter Christensen <pch@ordbogen.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 4f26ee4..3d2d2c8 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1392,15 +1392,19 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 
 	if (ipip) {
 		__be32 info = ic->un.gateway;
+		__u8 type = ic->type;
+		__u8 code = ic->code;
 
 		/* Update the MTU */
 		if (ic->type == ICMP_DEST_UNREACH &&
 		    ic->code == ICMP_FRAG_NEEDED) {
 			struct ip_vs_dest *dest = cp->dest;
 			u32 mtu = ntohs(ic->un.frag.mtu);
+			__be16 frag_off = cih->frag_off;
 
 			/* Strip outer IP and ICMP, go to IPIP header */
-			__skb_pull(skb, ihl + sizeof(_icmph));
+			if (pskb_pull(skb, ihl + sizeof(_icmph)) == NULL)
+				goto ignore_ipip;
 			offset2 -= ihl + sizeof(_icmph);
 			skb_reset_network_header(skb);
 			IP_VS_DBG(12, "ICMP for IPIP %pI4->%pI4: mtu=%u\n",
@@ -1408,7 +1412,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 			ipv4_update_pmtu(skb, dev_net(skb->dev),
 					 mtu, 0, 0, 0, 0);
 			/* Client uses PMTUD? */
-			if (!(cih->frag_off & htons(IP_DF)))
+			if (!(frag_off & htons(IP_DF)))
 				goto ignore_ipip;
 			/* Prefer the resulting PMTU */
 			if (dest) {
@@ -1427,12 +1431,13 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 		/* Strip outer IP, ICMP and IPIP, go to IP header of
 		 * original request.
 		 */
-		__skb_pull(skb, offset2);
+		if (pskb_pull(skb, offset2) == NULL)
+			goto ignore_ipip;
 		skb_reset_network_header(skb);
 		IP_VS_DBG(12, "Sending ICMP for %pI4->%pI4: t=%u, c=%u, i=%u\n",
 			&ip_hdr(skb)->saddr, &ip_hdr(skb)->daddr,
-			ic->type, ic->code, ntohl(info));
-		icmp_send(skb, ic->type, ic->code, info);
+			type, code, ntohl(info));
+		icmp_send(skb, type, code, info);
 		/* ICMP can be shorter but anyways, account it */
 		ip_vs_out_stats(cp, skb);
 
-- 
1.8.5.2

