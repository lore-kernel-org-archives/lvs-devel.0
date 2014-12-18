From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net] ipvs: rerouting to local clients is not needed anymore
Date: Thu, 18 Dec 2014 22:41:23 +0200
Message-ID: <1418935283-5315-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Smart Weblications GmbH - Florian Wiessner <f.wiessner@smart-weblications.de>

commit f5a41847acc5 ("ipvs: move ip_route_me_harder for ICMP")
from 2.6.37 introduced ip_route_me_harder() call for responses to
local clients, so that we can provide valid rt_src after SNAT.
It was used by TCP to provide valid daddr for ip_send_reply().
After commit 0a5ebb8000c5 ("ipv4: Pass explicit daddr arg to
ip_send_reply()." from 3.0 this rerouting is not needed anymore
and should be avoided, especially in LOCAL_IN.

Fixes 3.12.33 crash in xfrm reported by Florian Wiessner:
"3.12.33 - BUG xfrm_selector_match+0x25/0x2f6"

Reported-by: Smart Weblications GmbH - Florian Wiessner <f.wiessner@smart-weblications.de>
Tested-by: Smart Weblications GmbH - Florian Wiessner <f.wiessner@smart-weblications.de>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

	Patch tested on net tree (Dec 7), 3.14.25, 3.12.33, 3.10.61.
3.4.104 needs a modified fix that resolves rejects, it applies
with little fuzz on 3.2.64. Let me know if I should post
separately 3.2 and 3.4 patches.

 net/netfilter/ipvs/ip_vs_core.c | 33 ++++++++++++++++++++++-----------
 1 file changed, 22 insertions(+), 11 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 990decb..b87ca32 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -659,16 +659,24 @@ static inline int ip_vs_gather_frags(struct sk_buff *skb, u_int32_t user)
 	return err;
 }
 
-static int ip_vs_route_me_harder(int af, struct sk_buff *skb)
+static int ip_vs_route_me_harder(int af, struct sk_buff *skb,
+				 unsigned int hooknum)
 {
+	if (!sysctl_snat_reroute(skb))
+		return 0;
+	/* Reroute replies only to remote clients (FORWARD and LOCAL_OUT) */
+	if (NF_INET_LOCAL_IN == hooknum)
+		return 0;
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
-		if (sysctl_snat_reroute(skb) && ip6_route_me_harder(skb) != 0)
+		struct dst_entry *dst = skb_dst(skb);
+
+		if (dst->dev && !(dst->dev->flags & IFF_LOOPBACK) &&
+		    ip6_route_me_harder(skb) != 0)
 			return 1;
 	} else
 #endif
-		if ((sysctl_snat_reroute(skb) ||
-		     skb_rtable(skb)->rt_flags & RTCF_LOCAL) &&
+		if (!(skb_rtable(skb)->rt_flags & RTCF_LOCAL) &&
 		    ip_route_me_harder(skb, RTN_LOCAL) != 0)
 			return 1;
 
@@ -791,7 +799,8 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 				union nf_inet_addr *snet,
 				__u8 protocol, struct ip_vs_conn *cp,
 				struct ip_vs_protocol *pp,
-				unsigned int offset, unsigned int ihl)
+				unsigned int offset, unsigned int ihl,
+				unsigned int hooknum)
 {
 	unsigned int verdict = NF_DROP;
 
@@ -821,7 +830,7 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 #endif
 		ip_vs_nat_icmp(skb, pp, cp, 1);
 
-	if (ip_vs_route_me_harder(af, skb))
+	if (ip_vs_route_me_harder(af, skb, hooknum))
 		goto out;
 
 	/* do the statistics and put it back */
@@ -916,7 +925,7 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
 
 	snet.ip = iph->saddr;
 	return handle_response_icmp(AF_INET, skb, &snet, cih->protocol, cp,
-				    pp, ciph.len, ihl);
+				    pp, ciph.len, ihl, hooknum);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -981,7 +990,8 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 	snet.in6 = ciph.saddr.in6;
 	writable = ciph.len;
 	return handle_response_icmp(AF_INET6, skb, &snet, ciph.protocol, cp,
-				    pp, writable, sizeof(struct ipv6hdr));
+				    pp, writable, sizeof(struct ipv6hdr),
+				    hooknum);
 }
 #endif
 
@@ -1040,7 +1050,8 @@ static inline bool is_new_conn(const struct sk_buff *skb,
  */
 static unsigned int
 handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
-		struct ip_vs_conn *cp, struct ip_vs_iphdr *iph)
+		struct ip_vs_conn *cp, struct ip_vs_iphdr *iph,
+		unsigned int hooknum)
 {
 	struct ip_vs_protocol *pp = pd->pp;
 
@@ -1078,7 +1089,7 @@ handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	 * if it came from this machine itself.  So re-compute
 	 * the routing information.
 	 */
-	if (ip_vs_route_me_harder(af, skb))
+	if (ip_vs_route_me_harder(af, skb, hooknum))
 		goto drop;
 
 	IP_VS_DBG_PKT(10, af, pp, skb, 0, "After SNAT");
@@ -1181,7 +1192,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	cp = pp->conn_out_get(af, skb, &iph, 0);
 
 	if (likely(cp))
-		return handle_response(af, skb, pd, cp, &iph);
+		return handle_response(af, skb, pd, cp, &iph, hooknum);
 	if (sysctl_nat_icmp_send(net) &&
 	    (pp->protocol == IPPROTO_TCP ||
 	     pp->protocol == IPPROTO_UDP ||
-- 
1.9.3

