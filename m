From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 11/24] IPVS: Add ip_vs_route_me_harder()
Date: Tue, 15 Mar 2011 14:27:19 +0900
Message-ID: <1300166852-725-12-git-send-email-horms@verge.net.au>
References: <1300166852-725-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1300166852-725-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

Add ip_vs_route_me_harder() to avoid repeating the same code twice.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |   48 +++++++++++++++++---------------------
 1 files changed, 22 insertions(+), 26 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 6f4940e..299c7f3 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -631,6 +631,24 @@ static inline int ip_vs_gather_frags_v6(struct sk_buff *skb, u_int32_t user)
 }
 #endif
 
+static int ip_vs_route_me_harder(int af, struct sk_buff *skb)
+{
+	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6) {
+		if (ipvs->sysctl_snat_reroute && ip6_route_me_harder(skb) != 0)
+			return 1;
+	} else
+#endif
+		if ((ipvs->sysctl_snat_reroute ||
+		     skb_rtable(skb)->rt_flags & RTCF_LOCAL) &&
+		    ip_route_me_harder(skb, RTN_LOCAL) != 0)
+			return 1;
+
+	return 0;
+}
+
 /*
  * Packet has been made sufficiently writable in caller
  * - inout: 1=in->out, 0=out->in
@@ -737,7 +755,6 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 				struct ip_vs_protocol *pp,
 				unsigned int offset, unsigned int ihl)
 {
-	struct netns_ipvs *ipvs;
 	unsigned int verdict = NF_DROP;
 
 	if (IP_VS_FWD_METHOD(cp) != 0) {
@@ -759,8 +776,6 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 	if (!skb_make_writable(skb, offset))
 		goto out;
 
-	ipvs = net_ipvs(skb_net(skb));
-
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6)
 		ip_vs_nat_icmp_v6(skb, pp, cp, 1);
@@ -768,16 +783,8 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 #endif
 		ip_vs_nat_icmp(skb, pp, cp, 1);
 
-#ifdef CONFIG_IP_VS_IPV6
-	if (af == AF_INET6) {
-		if (ipvs->sysctl_snat_reroute && ip6_route_me_harder(skb) != 0)
-			goto out;
-	} else
-#endif
-		if ((ipvs->sysctl_snat_reroute ||
-		     skb_rtable(skb)->rt_flags & RTCF_LOCAL) &&
-		    ip_route_me_harder(skb, RTN_LOCAL) != 0)
-			goto out;
+	if (ip_vs_route_me_harder(af, skb))
+		goto out;
 
 	/* do the statistics and put it back */
 	ip_vs_out_stats(cp, skb);
@@ -985,7 +992,6 @@ handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		struct ip_vs_conn *cp, int ihl)
 {
 	struct ip_vs_protocol *pp = pd->pp;
-	struct netns_ipvs *ipvs;
 
 	IP_VS_DBG_PKT(11, af, pp, skb, 0, "Outgoing packet");
 
@@ -1021,18 +1027,8 @@ handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	 * if it came from this machine itself.  So re-compute
 	 * the routing information.
 	 */
-	ipvs = net_ipvs(skb_net(skb));
