From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 13/15] ipvs: support scheduling inverse and icmp UDP packets
Date: Thu, 17 Sep 2015 14:40:49 +0900
Message-ID: <1442468451-24012-14-git-send-email-horms@verge.net.au>
References: <1442468451-24012-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1442468451-24012-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
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
 net/netfilter/ipvs/ip_vs_proto_udp.c | 27 ++++++++++++++++++---------
 1 file changed, 18 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 1403be250988..f3aa821efb89 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -36,23 +36,32 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	struct net *net;
 	struct ip_vs_service *svc;
 	struct udphdr _udph, *uh;
+	__be16 _ports[2], *ports = NULL;
 
-	if (ip_vs_iph_icmp(iph)) {
-		/* TEMPORARY - do not schedule icmp yet */
-		*verdict = NF_ACCEPT;
-		return 0;
+	if (likely(!ip_vs_iph_icmp(iph))) {
+		/* IPv6 fragments, only first fragment will hit this */
+		uh = skb_header_pointer(skb, iph->len, sizeof(_udph), &_udph);
+		if (uh)
+			ports = &uh->source;
+	} else {
+		ports = skb_header_pointer(
+			skb, iph->len, sizeof(_ports), &_ports);
 	}
 
-	/* IPv6 fragments, only first fragment will hit this */
-	uh = skb_header_pointer(skb, iph->len, sizeof(_udph), &_udph);
-	if (uh == NULL) {
+	if (!ports) {
 		*verdict = NF_DROP;
 		return 0;
 	}
+
 	net = skb_net(skb);
 	rcu_read_lock();
-	svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
-				 &iph->daddr, uh->dest);
+	if (likely(!ip_vs_iph_inverse(iph)))
+		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+					 &iph->daddr, ports[1]);
+	else
+		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+					 &iph->saddr, ports[0]);
+
 	if (svc) {
 		int ignored;
 
-- 
2.1.4
