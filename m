From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] ipvs: sctp: fix checksumming by adding hardware offload support
Date: Mon,  4 Feb 2013 18:27:54 +0100
Message-ID: <916047bfad2e27385c15954a71e9462bb2f828f2.1359997089.git.dborkman@redhat.com>
References: <cover.1359997089.git.dborkman@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <cover.1359997089.git.dborkman@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: mohanreddykv@gmail.com, pablo@netfilter.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-sctp@vger.kernel.org, root Daniel Borkmann <dborkman@redhat.com>

From: root Daniel Borkmann <dborkman@redhat.com>

In our test lab, we have a simple SCTP client connecting to a SCTP
server via an IPVS load balancer. On some machines, load balancing
works, but on others the initial handshake just fails, thus no
SCTP connection whatsoever can be established.

We observed that the SCTP INIT-ACK handshake reply from the IPVS
machine to the client had a correct IP checksum, but corrupt SCTP
checksum when forwarded, thus on the client-side the packet was
dropped and an intial handshake retriggered until all attempts
run into the void.

This patch fixes the problem by taking hardware offload features
of the NIC into account (which was just ignored here), similar as
done in the SCTP checksumming code itself. Also, while at it,
the checksum is in little-endian format (as fixed in commit 458f04c:
sctp: Clean up sctp checksumming code). Tested by myself.

Cc: Venkata Mohan Reddy <mohanreddykv@gmail.com>
Cc: Simon Horman <horms@verge.net.au>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 41 ++++++++++++++++++++---------------
 1 file changed, 23 insertions(+), 18 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 746048b..dc41622 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -61,14 +61,33 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	return 1;
 }
 
+static void sctp_nat_csum(struct sk_buff *skb, sctp_sctphdr_t *sctph,
+			  unsigned int sctphoff)
+{
+	struct sk_buff *iter;
+
+	/* Calculate the checksum */
+	if (!(skb->dev->features & NETIF_F_SCTP_CSUM)) {
+		__u32 crc32 = sctp_start_cksum((__u8 *)sctph,
+					       skb_headlen(skb) - sctphoff);
+		skb_walk_frags(skb, iter)
+			crc32 = sctp_update_cksum((u8 *) iter->data,
+						  skb_headlen(iter), crc32);
+		sctph->checksum = sctp_end_cksum(crc32);
+	} else {
+		/* no need to seed pseudo checksum for SCTP */
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		skb->csum_start = (skb_transport_header(skb) - skb->head);
+		skb->csum_offset = offsetof(struct sctphdr, checksum);
+	}
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
@@ -92,13 +111,7 @@ sctp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
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
@@ -109,8 +122,6 @@ sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
 {
 	sctp_sctphdr_t *sctph;
 	unsigned int sctphoff = iph->len;
-	struct sk_buff *iter;
-	__be32 crc32;
 
 #ifdef CONFIG_IP_VS_IPV6
 	if (cp->af == AF_INET6 && iph->fragoffs)
@@ -134,13 +145,7 @@ sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
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
1.7.11.7

