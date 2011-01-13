From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 21/22] IPVS: netns, misc init_net removal in core.
Date: Thu, 13 Jan 2011 10:53:07 +0900
Message-ID: <1294883588-5683-22-git-send-email-horms@verge.net.au>
References: <1294883588-5683-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1294883588-5683-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

init_net removed in __ip_vs_addr_is_local_v6, and got net as param.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |    6 ++++--
 net/netfilter/ipvs/ip_vs_ctl.c  |    9 +++++----
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index bdda346..9e10c7a 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -499,6 +499,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		struct ip_vs_proto_data *pd)
 {
+	struct net *net;
 	struct netns_ipvs *ipvs;
 	__be16 _ports[2], *pptr;
 	struct ip_vs_iphdr iph;
@@ -511,18 +512,19 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		ip_vs_service_put(svc);
 		return NF_DROP;
 	}
+	net = skb_net(skb);
 
 #ifdef CONFIG_IP_VS_IPV6
 	if (svc->af == AF_INET6)
 		unicast = ipv6_addr_type(&iph.daddr.in6) & IPV6_ADDR_UNICAST;
 	else
 #endif
-		unicast = (inet_addr_type(&init_net, iph.daddr.ip) == RTN_UNICAST);
+		unicast = (inet_addr_type(net, iph.daddr.ip) == RTN_UNICAST);
 
 	/* if it is fwmark-based service, the cache_bypass sysctl is up
 	   and the destination is a non-local unicast, then create
 	   a cache_bypass connection entry */
-	ipvs = net_ipvs(skb_net(skb));
+	ipvs = net_ipvs(net);
 	if (ipvs->sysctl_cache_bypass && svc->fwmark && unicast) {
 		int ret, cs;
 		struct ip_vs_conn *cp;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 65f5de4..edf2b6d 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -71,7 +71,8 @@ int ip_vs_get_debug_level(void)
 
 #ifdef CONFIG_IP_VS_IPV6
 /* Taken from rt6_fill_node() in net/ipv6/route.c, is there a better way? */
-static int __ip_vs_addr_is_local_v6(const struct in6_addr *addr)
+static int __ip_vs_addr_is_local_v6(struct net *net,
+				    const struct in6_addr *addr)
 {
 	struct rt6_info *rt;
 	struct flowi fl = {
@@ -80,7 +81,7 @@ static int __ip_vs_addr_is_local_v6(const struct in6_addr *addr)
 		.fl6_src = { .s6_addr32 = {0, 0, 0, 0} },
 	};
 
-	rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl);
+	rt = (struct rt6_info *)ip6_route_output(net, NULL, &fl);
 	if (rt && rt->rt6i_dev && (rt->rt6i_dev->flags & IFF_LOOPBACK))
 			return 1;
 
@@ -810,12 +811,12 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 		atype = ipv6_addr_type(&udest->addr.in6);
 		if ((!(atype & IPV6_ADDR_UNICAST) ||
 			atype & IPV6_ADDR_LINKLOCAL) &&
-			!__ip_vs_addr_is_local_v6(&udest->addr.in6))
+			!__ip_vs_addr_is_local_v6(svc->net, &udest->addr.in6))
 			return -EINVAL;
 	} else
 #endif
 	{
-		atype = inet_addr_type(&init_net, udest->addr.ip);
+		atype = inet_addr_type(svc->net, udest->addr.ip);
 		if (atype != RTN_LOCAL && atype != RTN_UNICAST)
 			return -EINVAL;
 	}
-- 
1.7.2.3

