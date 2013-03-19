From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/3] ipvs: fix sctp chunk length order
Date: Tue, 19 Mar 2013 10:39:56 +0900
Message-ID: <1363657198-5333-2-git-send-email-horms@verge.net.au>
References: <1363657198-5333-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1363657198-5333-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

Fix wrong but non-fatal access to chunk length.
sch->length should be in network order, next chunk should
be aligned to 4 bytes. Problem noticed in sparse output.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index ae8ec6f..cd1d729 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -906,7 +906,7 @@ set_sctp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 	sctp_chunkhdr_t _sctpch, *sch;
 	unsigned char chunk_type;
 	int event, next_state;
-	int ihl;
+	int ihl, cofs;
 
 #ifdef CONFIG_IP_VS_IPV6
 	ihl = cp->af == AF_INET ? ip_hdrlen(skb) : sizeof(struct ipv6hdr);
@@ -914,8 +914,8 @@ set_sctp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 	ihl = ip_hdrlen(skb);
 #endif
 
-	sch = skb_header_pointer(skb, ihl + sizeof(sctp_sctphdr_t),
-				sizeof(_sctpch), &_sctpch);
+	cofs = ihl + sizeof(sctp_sctphdr_t);
+	sch = skb_header_pointer(skb, cofs, sizeof(_sctpch), &_sctpch);
 	if (sch == NULL)
 		return;
 
@@ -933,10 +933,12 @@ set_sctp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 	 */
 	if ((sch->type == SCTP_CID_COOKIE_ECHO) ||
 	    (sch->type == SCTP_CID_COOKIE_ACK)) {
-		sch = skb_header_pointer(skb, (ihl + sizeof(sctp_sctphdr_t) +
-				sch->length), sizeof(_sctpch), &_sctpch);
-		if (sch) {
-			if (sch->type == SCTP_CID_ABORT)
+		int clen = ntohs(sch->length);
+
+		if (clen >= sizeof(sctp_chunkhdr_t)) {
+			sch = skb_header_pointer(skb, cofs + ALIGN(clen, 4),
+						 sizeof(_sctpch), &_sctpch);
+			if (sch && sch->type == SCTP_CID_ABORT)
 				chunk_type = sch->type;
 		}
 	}
-- 
1.7.10.4
