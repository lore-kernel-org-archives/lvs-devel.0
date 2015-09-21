From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 79/84] ipvs: Pass ipvs through ip_vs_route_me_harder into sysctl_snat_reroute
Date: Mon, 21 Sep 2015 13:02:56 -0500
Message-ID: <1442858581-15869-79-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>

This removes the need to use the hack skb_net.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
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
2.2.1
