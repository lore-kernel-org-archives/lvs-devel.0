From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 09/15] ipvs: sh: support scheduling icmp/inverse packets consistently
Date: Thu, 17 Sep 2015 14:40:45 +0900
Message-ID: <1442468451-24012-10-git-send-email-horms@verge.net.au>
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

"source_hash" the dest fields if it's an inverse packet.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sh.c | 45 ++++++++++++++++++++-----------------------
 1 file changed, 21 insertions(+), 24 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 98a13433b68c..1e373a5e44e3 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -280,35 +280,29 @@ static int ip_vs_sh_dest_changed(struct ip_vs_service *svc,
 static inline __be16
 ip_vs_sh_get_port(const struct sk_buff *skb, struct ip_vs_iphdr *iph)
 {
-	__be16 port;
-	struct tcphdr _tcph, *th;
-	struct udphdr _udph, *uh;
-	sctp_sctphdr_t _sctph, *sh;
+	__be16 _ports[2], *ports;
 
+	/* At this point we know that we have a valid packet of some kind.
+	 * Because ICMP packets are only guaranteed to have the first 8
+	 * bytes, let's just grab the ports.  Fortunately they're in the
+	 * same position for all three of the protocols we care about.
+	 */
 	switch (iph->protocol) {
 	case IPPROTO_TCP:
-		th = skb_header_pointer(skb, iph->len, sizeof(_tcph), &_tcph);
-		if (unlikely(th == NULL))
-			return 0;
-		port = th->source;
-		break;
 	case IPPROTO_UDP:
-		uh = skb_header_pointer(skb, iph->len, sizeof(_udph), &_udph);
-		if (unlikely(uh == NULL))
-			return 0;
-		port = uh->source;
-		break;
 	case IPPROTO_SCTP:
-		sh = skb_header_pointer(skb, iph->len, sizeof(_sctph), &_sctph);
-		if (unlikely(sh == NULL))
+		ports = skb_header_pointer(skb, iph->len, sizeof(_ports),
+					   &_ports);
+		if (unlikely(!ports))
 			return 0;
-		port = sh->source;
-		break;
+
+		if (likely(!ip_vs_iph_inverse(iph)))
+			return ports[0];
+		else
+			return ports[1];
 	default:
-		port = 0;
+		return 0;
 	}
-
-	return port;
 }
 
 
@@ -322,6 +316,9 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	struct ip_vs_dest *dest;
 	struct ip_vs_sh_state *s;
 	__be16 port = 0;
+	const union nf_inet_addr *hash_addr;
+
+	hash_addr = ip_vs_iph_inverse(iph) ? &iph->daddr : &iph->saddr;
 
 	IP_VS_DBG(6, "ip_vs_sh_schedule(): Scheduling...\n");
 
@@ -331,9 +328,9 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	s = (struct ip_vs_sh_state *) svc->sched_data;
 
 	if (svc->flags & IP_VS_SVC_F_SCHED_SH_FALLBACK)
-		dest = ip_vs_sh_get_fallback(svc, s, &iph->saddr, port);
+		dest = ip_vs_sh_get_fallback(svc, s, hash_addr, port);
 	else
-		dest = ip_vs_sh_get(svc, s, &iph->saddr, port);
+		dest = ip_vs_sh_get(svc, s, hash_addr, port);
 
 	if (!dest) {
 		ip_vs_scheduler_err(svc, "no destination available");
@@ -341,7 +338,7 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	}
 
 	IP_VS_DBG_BUF(6, "SH: source IP address %s --> server %s:%d\n",
-		      IP_VS_DBG_ADDR(svc->af, &iph->saddr),
+		      IP_VS_DBG_ADDR(svc->af, hash_addr),
 		      IP_VS_DBG_ADDR(dest->af, &dest->addr),
 		      ntohs(dest->port));
 
-- 
2.1.4
