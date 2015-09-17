From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 12/15] ipvs: support scheduling inverse and icmp TCP packets
Date: Thu, 17 Sep 2015 14:40:48 +0900
Message-ID: <1442468451-24012-13-git-send-email-horms@verge.net.au>
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
 net/netfilter/ipvs/ip_vs_proto_tcp.c | 39 ++++++++++++++++++++++++++----------
 1 file changed, 28 insertions(+), 11 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index dbc707514f29..8f43cf6044e9 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -40,26 +40,43 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	struct ip_vs_service *svc;
 	struct tcphdr _tcph, *th;
 	struct netns_ipvs *ipvs;
+	__be16 _ports[2], *ports = NULL;
 
-	if (ip_vs_iph_icmp(iph)) {
-		/* TEMPORARY - do not schedule icmp yet */
-		*verdict = NF_ACCEPT;
-		return 0;
+	net = skb_net(skb);
+	ipvs = net_ipvs(net);
+
+	/* In the event of icmp, we're only guaranteed to have the first 8
+	 * bytes of the transport header, so we only check the rest of the
+	 * TCP packet for non-ICMP packets
+	 */
+	if (likely(!ip_vs_iph_icmp(iph))) {
+		th = skb_header_pointer(skb, iph->len, sizeof(_tcph), &_tcph);
+		if (th) {
+			if (th->rst || !(sysctl_sloppy_tcp(ipvs) || th->syn))
+				return 1;
+			ports = &th->source;
+		}
+	} else {
+		ports = skb_header_pointer(
+			skb, iph->len, sizeof(_ports), &_ports);
 	}
 
-	th = skb_header_pointer(skb, iph->len, sizeof(_tcph), &_tcph);
-	if (th == NULL) {
+	if (!ports) {
 		*verdict = NF_DROP;
 		return 0;
 	}
-	net = skb_net(skb);
-	ipvs = net_ipvs(net);
 
 	/* No !th->ack check to allow scheduling on SYN+ACK for Active FTP */
 	rcu_read_lock();
-	if ((th->syn || sysctl_sloppy_tcp(ipvs)) && !th->rst &&
-	    (svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
-				      &iph->daddr, th->dest))) {
+
+	if (likely(!ip_vs_iph_inverse(iph)))
+		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+					 &iph->daddr, ports[1]);
+	else
+		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+					 &iph->saddr, ports[0]);
+
+	if (svc) {
 		int ignored;
 
 		if (ip_vs_todrop(ipvs)) {
-- 
2.1.4
