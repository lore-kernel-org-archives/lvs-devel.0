From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 3.2.66] ipvs: rerouting to local clients is not needed anymore
Date: Fri,  6 Feb 2015 10:55:25 +0200
Message-ID: <1423212925-24810-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org

commit f5a41847acc5 ("ipvs: move ip_route_me_harder for ICMP")
from 2.6.37 introduced ip_route_me_harder() call for responses to
local clients, so that we can provide valid rt_src after SNAT.
It was used by TCP to provide valid daddr for ip_send_reply().
After commit 0a5ebb8000c5 ("ipv4: Pass explicit daddr arg to
ip_send_reply()." from 3.0 this rerouting is not needed anymore
and should be avoided, especially in LOCAL_IN.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

Pablo, this patch is a 3.2.66 version (same subject).

 net/netfilter/ipvs/ip_vs_core.c | 32 +++++++++++++++++++++-----------
 1 file changed, 21 insertions(+), 11 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 6dc7d7d..d864aaf 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -662,16 +662,24 @@ static inline int ip_vs_gather_frags_v6(struct sk_buff *skb, u_int32_t user)
 }
 #endif
 
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
 
@@ -782,7 +790,8 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 				union nf_inet_addr *snet,
 				__u8 protocol, struct ip_vs_conn *cp,
 				struct ip_vs_protocol *pp,
-				unsigned int offset, unsigned int ihl)
+				unsigned int offset, unsigned int ihl,
+				unsigned int hooknum)
 {
 	unsigned int verdict = NF_DROP;
 
@@ -812,7 +821,7 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 #endif
 		ip_vs_nat_icmp(skb, pp, cp, 1);
 
-	if (ip_vs_route_me_harder(af, skb))
+	if (ip_vs_route_me_harder(af, skb, hooknum))
 		goto out;
 
 	/* do the statistics and put it back */
@@ -908,7 +917,7 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
 
 	snet.ip = iph->saddr;
 	return handle_response_icmp(AF_INET, skb, &snet, cih->protocol, cp,
-				    pp, offset, ihl);
+				    pp, offset, ihl, hooknum);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -985,7 +994,8 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 
 	ipv6_addr_copy(&snet.in6, &iph->saddr);
 	return handle_response_icmp(AF_INET6, skb, &snet, cih->nexthdr, cp,
-				    pp, offset, sizeof(struct ipv6hdr));
+				    pp, offset, sizeof(struct ipv6hdr),
+				    hooknum);
 }
 #endif
 
@@ -1018,7 +1028,7 @@ static inline int is_tcp_reset(const struct sk_buff *skb, int nh_len)
  */
 static unsigned int
 handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
-		struct ip_vs_conn *cp, int ihl)
+		struct ip_vs_conn *cp, int ihl, unsigned int hooknum)
 {
 	struct ip_vs_protocol *pp = pd->pp;
 
@@ -1056,7 +1066,7 @@ handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	 * if it came from this machine itself.  So re-compute
 	 * the routing information.
 	 */
-	if (ip_vs_route_me_harder(af, skb))
+	if (ip_vs_route_me_harder(af, skb, hooknum))
 		goto drop;
 
 	IP_VS_DBG_PKT(10, af, pp, skb, 0, "After SNAT");
@@ -1169,7 +1179,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	cp = pp->conn_out_get(af, skb, &iph, iph.len, 0);
 
 	if (likely(cp))
-		return handle_response(af, skb, pd, cp, iph.len);
+		return handle_response(af, skb, pd, cp, iph.len, hooknum);
 	if (sysctl_nat_icmp_send(net) &&
 	    (pp->protocol == IPPROTO_TCP ||
 	     pp->protocol == IPPROTO_UDP ||
-- 
1.9.3

