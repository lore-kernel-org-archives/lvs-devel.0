From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next,v2 12/13] ipvs: support scheduling inverse and icmp UDP packets
Date: Mon, 24 Aug 2015 16:44:44 -0700
Message-ID: <1440459885-1103938-12-git-send-email-agartrell@fb.com>
References: <1440459885-1103938-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=2Gpevps/SnMj9WF9va81vF2pj6S+j5OUkeGToHPXQXE=;
 b=OZj4sFlGrbWiJ/Dk33ywOnsca+llp2GAX1Z4Ai3/Ru88SzVyrgNg90BAfpRFCoKDDxCI
 PQPitZ/EEAUpZnYFW1YwttA7lUCTAy0ROoHDZDGUAfesvlXqEWkwAmNIhRZPxJwI+bYc
 s3s/faBknQ8rLZ3bZx0De1HlnFz4CtL7L6g= 
In-Reply-To: <1440459885-1103938-1-git-send-email-agartrell@fb.com>
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
 net/netfilter/ipvs/ip_vs_proto_udp.c | 27 ++++++++++++++++++---------
 1 file changed, 18 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 1403be2..f3aa821 100644
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
Alex Gartrell <agartrell@fb.com>

