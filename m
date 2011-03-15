From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 12/24] IPVS: Add sysctl_snat_reroute()
Date: Tue, 15 Mar 2011 14:27:20 +0900
Message-ID: <1300166852-725-13-git-send-email-horms@verge.net.au>
References: <1300166852-725-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300166852-725-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

In preparation for not including sysctl_snat_reroute in
struct netns_ipvs when CONFIG_SYCTL is not defined.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |   20 ++++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 299c7f3..1d8a2a2 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -599,6 +599,20 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 	return NF_DROP;
 }
 
+#ifdef CONFIG_SYSCTL
+
+static int sysctl_snat_reroute(struct sk_buff *skb)
+{
+	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
+	return ipvs->sysctl_snat_reroute;
+}
+
+#else
+
+static int sysctl_snat_reroute(struct sk_buff *skb) { return 0; }
+
+#endif
+
 __sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset)
 {
 	return csum_fold(skb_checksum(skb, offset, skb->len - offset, 0));
@@ -633,15 +647,13 @@ static inline int ip_vs_gather_frags_v6(struct sk_buff *skb, u_int32_t user)
 
 static int ip_vs_route_me_harder(int af, struct sk_buff *skb)
 {
-	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
-
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
-		if (ipvs->sysctl_snat_reroute && ip6_route_me_harder(skb) != 0)
+		if (sysctl_snat_reroute(skb) && ip6_route_me_harder(skb) != 0)
 			return 1;
 	} else
 #endif
-		if ((ipvs->sysctl_snat_reroute ||
+		if ((sysctl_snat_reroute(skb) ||
 		     skb_rtable(skb)->rt_flags & RTCF_LOCAL) &&
 		    ip_route_me_harder(skb, RTN_LOCAL) != 0)
 			return 1;
-- 
1.7.2.3

