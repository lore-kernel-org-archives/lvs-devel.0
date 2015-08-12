From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next 12/12] ipvs: support scheduling inverse and icmp SCTP packets
Date: Wed, 12 Aug 2015 13:47:10 -0700
Message-ID: <1439412430-1702375-13-git-send-email-agartrell@fb.com>
References: <1439412430-1702375-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=9hikTNTKfLbI5BT2+yQ8KzXrmbKvRK0Jwey3xUjiySE=;
 b=d4rn8Lc6xZzk4T4Jl0iVaC29MCPgm4xd9PcaOvrcn7T4WQx5iMUmWUcSICtUsbje1FSU
 61iliInN90z8RvVgpRew/porauJMD9Py1ixdRvZQquMW7I6/thr53OZ/E61AnTqyNoF9
 tYwLKQ0CmvNT1vxO/NAmoybQ9dWkuAGsPOs= 
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
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 41 ++++++++++++++++++++---------------
 1 file changed, 23 insertions(+), 18 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index cd2984f..48e3471 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -18,22 +18,23 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	struct netns_ipvs *ipvs;
 	sctp_chunkhdr_t _schunkh, *sch;
 	sctp_sctphdr_t *sh, _sctph;
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
+	} else
+		ports = skb_header_pointer(
+			skb, iph->len, sizeof(_ports), &_ports);
 
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
-	}
-
-	sch = skb_header_pointer(skb, iph->len + sizeof(sctp_sctphdr_t),
-				 sizeof(_schunkh), &_schunkh);
-	if (sch == NULL) {
+	if (!ports) {
 		*verdict = NF_DROP;
 		return 0;
 	}
@@ -41,9 +42,13 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
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
Alex Gartrell <agartrell@fb.com>

