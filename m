From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH V4 1/7] ipvs: Trivial changes,
	use compressed IPv6 address in output
Date: Wed, 26 Sep 2012 14:05:53 +0200
Message-ID: <20120926120546.24804.22455.stgit@dragon>
References: <20120926120534.24804.78415.stgit@dragon>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20120926120534.24804.78415.stgit@dragon>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Hans Schillstrom <hans@schillstrom.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

Have not converted the proc file output to compressed IPv6 addresses.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 include/net/ip_vs.h              |    2 +-
 net/netfilter/ipvs/ip_vs_core.c  |    2 +-
 net/netfilter/ipvs/ip_vs_proto.c |    6 +++---
 net/netfilter/ipvs/ip_vs_sched.c |    2 +-
 net/netfilter/ipvs/ip_vs_xmit.c  |   10 +++++-----
 5 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index ee75ccd..aba0bb2 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -165,7 +165,7 @@ static inline const char *ip_vs_dbg_addr(int af, char *buf, size_t buf_len,
 	int len;
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6)
-		len = snprintf(&buf[*idx], buf_len - *idx, "[%pI6]",
+		len = snprintf(&buf[*idx], buf_len - *idx, "[%pI6c]",
 			       &addr->in6) + 1;
 	else
 #endif
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 58918e2..4edb654 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1487,7 +1487,7 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 	if (ic == NULL)
 		return NF_DROP;
 
-	IP_VS_DBG(12, "Incoming ICMPv6 (%d,%d) %pI6->%pI6\n",
+	IP_VS_DBG(12, "Incoming ICMPv6 (%d,%d) %pI6c->%pI6c\n",
 		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
 		  &iph->saddr, &iph->daddr);
 
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 50d8218..939f7fb 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -280,17 +280,17 @@ ip_vs_tcpudp_debug_packet_v6(struct ip_vs_protocol *pp,
 	if (ih == NULL)
 		sprintf(buf, "TRUNCATED");
 	else if (ih->nexthdr == IPPROTO_FRAGMENT)
-		sprintf(buf, "%pI6->%pI6 frag",	&ih->saddr, &ih->daddr);
+		sprintf(buf, "%pI6c->%pI6c frag", &ih->saddr, &ih->daddr);
 	else {
 		__be16 _ports[2], *pptr;
 
 		pptr = skb_header_pointer(skb, offset + sizeof(struct ipv6hdr),
 					  sizeof(_ports), _ports);
 		if (pptr == NULL)
-			sprintf(buf, "TRUNCATED %pI6->%pI6",
+			sprintf(buf, "TRUNCATED %pI6c->%pI6c",
 				&ih->saddr, &ih->daddr);
 		else
-			sprintf(buf, "%pI6:%u->%pI6:%u",
+			sprintf(buf, "%pI6c:%u->%pI6c:%u",
 				&ih->saddr, ntohs(pptr[0]),
 				&ih->daddr, ntohs(pptr[1]));
 	}
diff --git a/net/netfilter/ipvs/ip_vs_sched.c b/net/netfilter/ipvs/ip_vs_sched.c
index 08dbdd5..d6bf20d 100644
--- a/net/netfilter/ipvs/ip_vs_sched.c
+++ b/net/netfilter/ipvs/ip_vs_sched.c
@@ -159,7 +159,7 @@ void ip_vs_scheduler_err(struct ip_vs_service *svc, const char *msg)
 			     svc->fwmark, msg);
 #ifdef CONFIG_IP_VS_IPV6
 	} else if (svc->af == AF_INET6) {
-		IP_VS_ERR_RL("%s: %s [%pI6]:%d - %s\n",
+		IP_VS_ERR_RL("%s: %s [%pI6c]:%d - %s\n",
 			     svc->scheduler->name,
 			     ip_vs_proto_name(svc->protocol),
 			     &svc->addr.in6, ntohs(svc->port), msg);
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 56f6d5d..1060bd5 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -335,7 +335,7 @@ __ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
 	local = __ip_vs_is_local_route6(rt);
 	if (!((local ? IP_VS_RT_MODE_LOCAL : IP_VS_RT_MODE_NON_LOCAL) &
 	      rt_mode)) {
-		IP_VS_DBG_RL("Stopping traffic to %s address, dest: %pI6\n",
+		IP_VS_DBG_RL("Stopping traffic to %s address, dest: %pI6c\n",
 			     local ? "local":"non-local", daddr);
 		dst_release(&rt->dst);
 		return NULL;
@@ -343,8 +343,8 @@ __ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
 	if (local && !(rt_mode & IP_VS_RT_MODE_RDR) &&
 	    !((ort = (struct rt6_info *) skb_dst(skb)) &&
 	      __ip_vs_is_local_route6(ort))) {
-		IP_VS_DBG_RL("Redirect from non-local address %pI6 to local "
-			     "requires NAT method, dest: %pI6\n",
+		IP_VS_DBG_RL("Redirect from non-local address %pI6c to local "
+			     "requires NAT method, dest: %pI6c\n",
 			     &ipv6_hdr(skb)->daddr, daddr);
 		dst_release(&rt->dst);
 		return NULL;
@@ -352,8 +352,8 @@ __ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
 	if (unlikely(!local && (!skb->dev || skb->dev->flags & IFF_LOOPBACK) &&
 		     ipv6_addr_type(&ipv6_hdr(skb)->saddr) &
 				    IPV6_ADDR_LOOPBACK)) {
-		IP_VS_DBG_RL("Stopping traffic from loopback address %pI6 "
-			     "to non-local address, dest: %pI6\n",
+		IP_VS_DBG_RL("Stopping traffic from loopback address %pI6c "
+			     "to non-local address, dest: %pI6c\n",
 			     &ipv6_hdr(skb)->saddr, daddr);
 		dst_release(&rt->dst);
 		return NULL;

