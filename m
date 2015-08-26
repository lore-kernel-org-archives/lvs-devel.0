From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next,v4 03/14] ipvs: Handle inverse and icmp headers in ip_vs_leave
Date: Wed, 26 Aug 2015 09:40:30 -0700
Message-ID: <1440607241-355987-3-git-send-email-agartrell@fb.com>
References: <1440607241-355987-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=q0bmVGBQKfV4GyspR7WEBxbhKemINk00Rrlg9Hs2S38=;
 b=oK1W048Ndn5tsvO9NsKyLA109Mf7zIGlA7lcL9Cn/b0axIReQswwXgr+IMBwAamEML1o
 1cGtgRhJgQ5TgsSQqGqaPTWEZASytZnBcYCAt8ZYEw3slbJbH7dvwmUGerEcQ/SVMgqT
 LD8Bj6LCEWE9Cje/viQNHglSw5EAdgB+rs4= 
In-Reply-To: <1440607241-355987-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: alexgartrell@gmail.com, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 33 +++++++++++++++++++++------------
 1 file changed, 21 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 4f5d3d1..bb998d4 100644
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
Alex Gartrell <agartrell@fb.com>

