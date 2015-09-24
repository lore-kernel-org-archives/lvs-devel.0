From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 79/84] ipvs: Pass ipvs through ip_vs_route_me_harder into sysctl_snat_reroute
Date: Thu, 24 Sep 2015 09:53:04 +0900
Message-ID: <1443055989-1306-80-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: "Eric W. Biederman" <ebiederm@xmission.com>

This removes the need to use the hack skb_net.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 9967c9fac7f7..22eae0231cbb 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -651,9 +651,8 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 
 #ifdef CONFIG_SYSCTL
 
-static int sysctl_snat_reroute(struct sk_buff *skb)
+static int sysctl_snat_reroute(struct netns_ipvs *ipvs)
 {
-	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
 	return ipvs->sysctl_snat_reroute;
 }
 
@@ -669,7 +668,7 @@ static int sysctl_expire_nodest_conn(struct netns_ipvs *ipvs)
 
 #else
 
-static int sysctl_snat_reroute(struct sk_buff *skb) { return 0; }
+static int sysctl_snat_reroute(struct netns_ipvs *ipvs) { return 0; }
 static int sysctl_nat_icmp_send(struct netns_ipvs *ipvs) { return 0; }
 static int sysctl_expire_nodest_conn(struct netns_ipvs *ipvs) { return 0; }
 
@@ -702,10 +701,10 @@ static inline int ip_vs_gather_frags(struct sk_buff *skb, u_int32_t user)
 	return err;
 }
 
-static int ip_vs_route_me_harder(int af, struct sk_buff *skb,
-				 unsigned int hooknum)
+static int ip_vs_route_me_harder(struct netns_ipvs *ipvs, int af,
+				 struct sk_buff *skb, unsigned int hooknum)
 {
-	if (!sysctl_snat_reroute(skb))
+	if (!sysctl_snat_reroute(ipvs))
 		return 0;
 	/* Reroute replies only to remote clients (FORWARD and LOCAL_OUT) */
 	if (NF_INET_LOCAL_IN == hooknum)
@@ -873,7 +872,7 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 #endif
 		ip_vs_nat_icmp(skb, pp, cp, 1);
 
-	if (ip_vs_route_me_harder(af, skb, hooknum))
+	if (ip_vs_route_me_harder(cp->ipvs, af, skb, hooknum))
 		goto out;
 
 	/* do the statistics and put it back */
@@ -1144,7 +1143,7 @@ handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	 * if it came from this machine itself.  So re-compute
 	 * the routing information.
 	 */
-	if (ip_vs_route_me_harder(af, skb, hooknum))
+	if (ip_vs_route_me_harder(cp->ipvs, af, skb, hooknum))
 		goto drop;
 
 	IP_VS_DBG_PKT(10, af, pp, skb, iph->off, "After SNAT");
-- 
2.1.4

