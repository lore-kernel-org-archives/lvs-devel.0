From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next,v3 03/14] ipvs: Handle inverse and icmp headers in ip_vs_leave
Date: Tue, 25 Aug 2015 20:49:18 -0700
Message-ID: <1440560969-3511889-3-git-send-email-agartrell@fb.com>
References: <1440560969-3511889-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=tSGtrIvR2jwcESTeKVKuJoRVv3iZNXfsdvbxLpzxOz0=;
 b=SVukD7G8FdQ6GyjKaqBmfD8tPZaVfthkcUTpztpOas/gaFYlY/9jDLl6u0EWuXfx9gCV
 lSjWtUVt8hOpzgxqaym9JXUOxiY2U5D0toqYbt1VYQ/si25LfyJAvlxAVWSTn9PeUCNv
 r/ow7EOQ9vvT0qZGadM9nDTaUV7k7KjYb+A= 
In-Reply-To: <1440560969-3511889-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: alexgartrell@gmail.com, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 30 ++++++++++++++++++------------
 1 file changed, 18 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 4f5d3d1..dfda8d6 100644
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
@@ -598,7 +604,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 	 * listed in the ipvs table), pass the packets, because it is
 	 * not ipvs job to decide to drop the packets.
 	 */
-	if ((svc->port == FTPPORT) && (pptr[1] != FTPPORT))
+	if (svc->port == FTPPORT && dport != FTPPORT)
 		return NF_ACCEPT;
 
 	/*
-- 
Alex Gartrell <agartrell@fb.com>

