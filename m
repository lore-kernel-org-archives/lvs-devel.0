From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 14/15] ipvs: support scheduling inverse and icmp SCTP packets
Date: Thu, 17 Sep 2015 14:40:50 +0900
Message-ID: <1442468451-24012-15-git-send-email-horms@verge.net.au>
References: <1442468451-24012-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1442468451-24012-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Alex Gartrell <agartrell@fb.com>, Simon Horman <horms@verge.net.au>

From: Alex Gartrell <agartrell@fb.com>

In the event of an icmp packet, take only the ports instead of trying to
grab the full header.

In the event of an inverse packet, use the source address and port.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 40 ++++++++++++++++++++---------------
 1 file changed, 23 insertions(+), 17 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index cd2984f3dad7..2026fca7e1c3 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -18,22 +18,24 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	struct netns_ipvs *ipvs;
 	sctp_chunkhdr_t _schunkh, *sch;
 	sctp_sctphdr_t *sh, _sctph;
-
-	if (ip_vs_iph_icmp(iph)) {
-		/* TEMPORARY - do not schedule icmp yet */
-		*verdict = NF_ACCEPT;
-		return 0;
-	}
-
-	sh = skb_header_pointer(skb, iph->len, sizeof(_sctph), &_sctph);
-	if (sh == NULL) {
-		*verdict = NF_DROP;
-		return 0;
+	__be16 _ports[2], *ports = NULL;
+
+	if (likely(!ip_vs_iph_icmp(iph))) {
+		sh = skb_header_pointer(skb, iph->len, sizeof(_sctph), &_sctph);
+		if (sh) {
+			sch = skb_header_pointer(
+				skb, iph->len + sizeof(sctp_sctphdr_t),
+				sizeof(_schunkh), &_schunkh);
+			if (sch && (sch->type == SCTP_CID_INIT ||
+				    sysctl_sloppy_sctp(ipvs)))
+				ports = &sh->source;
+		}
+	} else {
+		ports = skb_header_pointer(
+			skb, iph->len, sizeof(_ports), &_ports);
 	}
 
-	sch = skb_header_pointer(skb, iph->len + sizeof(sctp_sctphdr_t),
-				 sizeof(_schunkh), &_schunkh);
-	if (sch == NULL) {
+	if (!ports) {
 		*verdict = NF_DROP;
 		return 0;
 	}
@@ -41,9 +43,13 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	net = skb_net(skb);
 	ipvs = net_ipvs(net);
 	rcu_read_lock();
-	if ((sch->type == SCTP_CID_INIT || sysctl_sloppy_sctp(ipvs)) &&
-	    (svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
-				      &iph->daddr, sh->dest))) {
+	if (likely(!ip_vs_iph_inverse(iph)))
+		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+					 &iph->daddr, ports[1]);
+	else
+		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+					 &iph->saddr, ports[0]);
+	if (svc) {
 		int ignored;
 
 		if (ip_vs_todrop(ipvs)) {
-- 
2.1.4

