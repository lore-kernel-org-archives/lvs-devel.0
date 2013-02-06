From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] ipvs: sctp: fix checksumming on snat and dnat handlers
Date: Wed,  6 Feb 2013 10:24:38 +0900
Message-ID: <1360113878-31051-2-git-send-email-horms@verge.net.au>
References: <1360113878-31051-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1360113878-31051-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Daniel Borkmann <dborkman@redhat.com>, Simon Horman <horms@verge.net.au>

From: Daniel Borkmann <dborkman@redhat.com>

In our test lab, we have a simple SCTP client connecting to a SCTP
server via an IPVS load balancer. On some machines, load balancing
works, but on others the initial handshake just fails, thus no
SCTP connection whatsoever can be established!

We observed that the SCTP INIT-ACK handshake reply from the IPVS
machine to the client had a correct IP checksum, but corrupt SCTP
checksum when forwarded, thus on the client-side the packet was
dropped and an intial handshake retriggered until all attempts
run into the void.

To fix this issue, this patch i) adds a missing CHECKSUM_UNNECESSARY
after the full checksum (re-)calculation (as done in IPVS TCP and UDP
code as well), ii) calculates the checksum in little-endian format
(as fixed with the SCTP code in commit 4458f04c: sctp: Clean up sctp
checksumming code) and iii) refactors duplicate checksum code into a
common function. Tested by myself.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   35 ++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 18 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 746048b..ae8ec6f 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -61,14 +61,27 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	return 1;
 }
 
+static void sctp_nat_csum(struct sk_buff *skb, sctp_sctphdr_t *sctph,
+			  unsigned int sctphoff)
+{
+	__u32 crc32;
+	struct sk_buff *iter;
+
+	crc32 = sctp_start_cksum((__u8 *)sctph, skb_headlen(skb) - sctphoff);
+	skb_walk_frags(skb, iter)
+		crc32 = sctp_update_cksum((u8 *) iter->data,
+					  skb_headlen(iter), crc32);
+	sctph->checksum = sctp_end_cksum(crc32);
+
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+}
+
 static int
 sctp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		  struct ip_vs_conn *cp, struct ip_vs_iphdr *iph)
 {
 	sctp_sctphdr_t *sctph;
 	unsigned int sctphoff = iph->len;
-	struct sk_buff *iter;
-	__be32 crc32;
 
 #ifdef CONFIG_IP_VS_IPV6
 	if (cp->af == AF_INET6 && iph->fragoffs)
@@ -92,13 +105,7 @@ sctp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 	sctph = (void *) skb_network_header(skb) + sctphoff;
 	sctph->source = cp->vport;
 
-	/* Calculate the checksum */
-	crc32 = sctp_start_cksum((u8 *) sctph, skb_headlen(skb) - sctphoff);
-	skb_walk_frags(skb, iter)
-		crc32 = sctp_update_cksum((u8 *) iter->data, skb_headlen(iter),
-				          crc32);
-	crc32 = sctp_end_cksum(crc32);
-	sctph->checksum = crc32;
+	sctp_nat_csum(skb, sctph, sctphoff);
 
 	return 1;
 }
@@ -109,8 +116,6 @@ sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 {
 	sctp_sctphdr_t *sctph;
 	unsigned int sctphoff = iph->len;
-	struct sk_buff *iter;
-	__be32 crc32;
 
 #ifdef CONFIG_IP_VS_IPV6
 	if (cp->af == AF_INET6 && iph->fragoffs)
@@ -134,13 +139,7 @@ sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 	sctph = (void *) skb_network_header(skb) + sctphoff;
 	sctph->dest = cp->dport;
 
-	/* Calculate the checksum */
-	crc32 = sctp_start_cksum((u8 *) sctph, skb_headlen(skb) - sctphoff);
-	skb_walk_frags(skb, iter)
-		crc32 = sctp_update_cksum((u8 *) iter->data, skb_headlen(iter),
-					  crc32);
-	crc32 = sctp_end_cksum(crc32);
-	sctph->checksum = crc32;
+	sctp_nat_csum(skb, sctph, sctphoff);
 
 	return 1;
 }
-- 
1.7.10.4

