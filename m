From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next,v3 12/14] ipvs: support scheduling inverse and icmp TCP packets
Date: Tue, 25 Aug 2015 20:49:27 -0700
Message-ID: <1440560969-3511889-12-git-send-email-agartrell@fb.com>
References: <1440560969-3511889-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=/EytTalq4oWN8bKdZ35yjbVVCEBTH7WrHNOZNjnMUC0=;
 b=ZLEnyURkUH4FA8rTpUzx3OiLAvQxGtnRcDoh2+e12YWiWO4wrA/Vey/5279exHlEKeMd
 Cvaq+R2wvT9DjPMB+IgA/oDzJICpaFGrIIxxdYvEWNpU+rs/pBTfMYw/6e4y/vyOB93t
 JnWYX+2NRCWxNZp6Bzt5N59fp1QWjvgUvb4= 
In-Reply-To: <1440560969-3511889-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: alexgartrell@gmail.com, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

In the event of an icmp packet, take only the ports instead of trying to
grab the full header.

In the event of an inverse packet, use the source address and port.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_proto_tcp.c | 39 ++++++++++++++++++++++++++----------
 1 file changed, 28 insertions(+), 11 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index dbc7075..8f43cf6 100644
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
Alex Gartrell <agartrell@fb.com>

