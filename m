From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 03/15] ipvs: Handle inverse and icmp headers in ip_vs_leave
Date: Thu, 17 Sep 2015 14:40:39 +0900
Message-ID: <1442468451-24012-4-git-send-email-horms@verge.net.au>
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

Signed-off-by: Alex Gartrell <agartrell@fb.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c | 33 +++++++++++++++++++++------------
 1 file changed, 21 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 4f5d3d174517..bb998d432ce7 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -519,6 +519,17 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	return cp;
 }
 
+#ifdef CONFIG_SYSCTL
+static inline int ip_vs_addr_is_unicast(struct net *net, int af,
+					union nf_inet_addr *addr)
+{
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		return ipv6_addr_type(&addr->in6) & IPV6_ADDR_UNICAST;
+#endif
+	return (inet_addr_type(net, addr->ip) == RTN_UNICAST);
+}
+#endif
 
 /*
  *  Pass or drop the packet.
@@ -528,33 +539,28 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		struct ip_vs_proto_data *pd, struct ip_vs_iphdr *iph)
 {
-	__be16 _ports[2], *pptr;
+	__be16 _ports[2], *pptr, dport;
 #ifdef CONFIG_SYSCTL
 	struct net *net;
 	struct netns_ipvs *ipvs;
-	int unicast;
 #endif
 
 	pptr = frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports, iph);
-	if (pptr == NULL) {
+	if (!pptr)
 		return NF_DROP;
-	}
+	dport = likely(!ip_vs_iph_inverse(iph)) ? pptr[1] : pptr[0];
 
 #ifdef CONFIG_SYSCTL
 	net = skb_net(skb);
 
-#ifdef CONFIG_IP_VS_IPV6
-	if (svc->af == AF_INET6)
-		unicast = ipv6_addr_type(&iph->daddr.in6) & IPV6_ADDR_UNICAST;
-	else
-#endif
-		unicast = (inet_addr_type(net, iph->daddr.ip) == RTN_UNICAST);
 
 	/* if it is fwmark-based service, the cache_bypass sysctl is up
 	   and the destination is a non-local unicast, then create
 	   a cache_bypass connection entry */
 	ipvs = net_ipvs(net);
-	if (ipvs->sysctl_cache_bypass && svc->fwmark && unicast) {
+	if (ipvs->sysctl_cache_bypass && svc->fwmark &&
+	    !(iph->hdr_flags & (IP_VS_HDR_INVERSE | IP_VS_HDR_ICMP)) &&
+	    ip_vs_addr_is_unicast(net, svc->af, &iph->daddr)) {
 		int ret;
 		struct ip_vs_conn *cp;
 		unsigned int flags = (svc->flags & IP_VS_SVC_F_ONEPACKET &&
@@ -598,9 +604,12 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 	 * listed in the ipvs table), pass the packets, because it is
 	 * not ipvs job to decide to drop the packets.
 	 */
-	if ((svc->port == FTPPORT) && (pptr[1] != FTPPORT))
+	if (svc->port == FTPPORT && dport != FTPPORT)
 		return NF_ACCEPT;
 
+	if (unlikely(ip_vs_iph_icmp(iph)))
+		return NF_DROP;
+
 	/*
 	 * Notify the client that the destination is unreachable, and
 	 * release the socket buffer.
-- 
2.1.4
