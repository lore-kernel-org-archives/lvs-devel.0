From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next 11/12] ipvs: support scheduling inverse and icmp UDP packets
Date: Wed, 12 Aug 2015 13:47:09 -0700
Message-ID: <1439412430-1702375-12-git-send-email-agartrell@fb.com>
References: <1439412430-1702375-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=w9sr8wCFuWVF+bTMlxNiWWXEdMtZPHTgw+wM8IJT7c4=;
 b=L0n5y21tP5bvfEkdTxiKBOdzzFcT7+gb2zGy3QI+K6hMGODdPaUZ4m/s4XjQnSFmF/qg
 aNtNJ+/TZF8q2mZJU0/YKR6jZlHKduLhZe+Ac03u328vMnT6SslrWXOZe35iyeZifraj
 7pF017kLG7PtbLkv8Du6cO/bqiU8D8KQ4Gc= 
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
 net/netfilter/ipvs/ip_vs_proto_udp.c | 32 ++++++++++++++++++++------------
 1 file changed, 20 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 1403be2..235c942 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -36,23 +36,31 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	struct net *net;
 	struct ip_vs_service *svc;
 	struct udphdr _udph, *uh;
-
-	if (ip_vs_iph_icmp(iph)) {
-		/* TEMPORARY - do not schedule icmp yet */
-		*verdict = NF_ACCEPT;
-		return 0;
-	}
-
-	/* IPv6 fragments, only first fragment will hit this */
-	uh = skb_header_pointer(skb, iph->len, sizeof(_udph), &_udph);
-	if (uh == NULL) {
+	__be16 _ports[2], *ports = NULL;
+
+	if (likely(!ip_vs_iph_icmp(iph))) {
+		/* IPv6 fragments, only first fragment will hit this */
+		uh = skb_header_pointer(skb, iph->len, sizeof(_udph), &_udph);
+		if (uh)
+			ports = &uh->source;
+	} else
+		ports = skb_header_pointer(
+			skb, iph->len, sizeof(_ports), &_ports);
+
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
Alex Gartrell <agartrell@fb.com>

