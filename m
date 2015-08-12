From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next 10/12] ipvs: support scheduling inverse and icmp TCP packets
Date: Wed, 12 Aug 2015 13:47:08 -0700
Message-ID: <1439412430-1702375-11-git-send-email-agartrell@fb.com>
References: <1439412430-1702375-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=ELYurYLWI5FA2YTA09899stgdI1U2jyPFwORCz29rUA=;
 b=NqCkBy1/rQ/fHjg9WKjTAUS+TJ2iIEdX1XeJInmE202eLnOjnxNJqz6wNbQbGuCdBLb/
 mZoS5BY44YANcRO0ygeqNJNU9XtdDZ5Q2ZwIEOLkza1IF9Tln4BCLFNNwkeiOgKAXBc+
 cbyXT2z7LV0RlaOtVWr+3Wu19pLTdMpBqdk= 
In-Reply-To: <1439412430-1702375-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ja@ssi.bg, horms@verge.net.au, lvs-devel@vger.kernel.org
Cc: kernel-team@fb.com, alexgartrell@gmail.com, Alex Gartrell <agartrell@fb.com>

In the event of an icmp packet, take only the ports instead of trying to
grab the full header.

In the event of an inverse packet, use the source address and port.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_proto_tcp.c | 40 +++++++++++++++++++++++++-----------
 1 file changed, 28 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index dbc7075..36e2324 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -40,26 +40,42 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	struct ip_vs_service *svc;
 	struct tcphdr _tcph, *th;
 	struct netns_ipvs *ipvs;
+	__be16 _ports[2], *ports = NULL;
 
-	if (ip_vs_iph_icmp(iph)) {
-		/* TEMPORARY - do not schedule icmp yet */
-		*verdict = NF_ACCEPT;
-		return 0;
-	}
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
+	} else
+		ports = skb_header_pointer(
+			skb, iph->len, sizeof(_ports), &_ports);
 
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

