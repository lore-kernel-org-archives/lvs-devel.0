From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 78/84] ipvs: Pass ipvs into ip_vs_out_icmp and ip_vs_out_icmp_v6
Date: Thu, 24 Sep 2015 09:53:03 +0900
Message-ID: <1443055989-1306-79-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: "Eric W. Biederman" <ebiederm@xmission.com>

This removes the need to compute ipvs with the hack "net_ipvs(skb_net(skb))"

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 0304c7cbb786..9967c9fac7f7 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -897,10 +897,9 @@ out:
  *	Find any that might be relevant, check against existing connections.
  *	Currently handles error types - unreachable, quench, ttl exceeded.
  */
-static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
-			  unsigned int hooknum)
+static int ip_vs_out_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb,
+			  int *related, unsigned int hooknum)
 {
-	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
 	struct iphdr *iph;
 	struct icmphdr	_icmph, *ic;
 	struct iphdr	_ciph, *cih;	/* The ip header contained within the ICMP */
@@ -973,10 +972,10 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
 }
 
 #ifdef CONFIG_IP_VS_IPV6
-static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
-			     unsigned int hooknum, struct ip_vs_iphdr *ipvsh)
+static int ip_vs_out_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
+			     int *related,  unsigned int hooknum,
+			     struct ip_vs_iphdr *ipvsh)
 {
-	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
 	struct icmp6hdr	_icmph, *ic;
 	struct ip_vs_iphdr ciph = {.flags = 0, .fragoffs = 0};/*Contained IP */
 	struct ip_vs_conn *cp;
@@ -1208,7 +1207,7 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
 	if (af == AF_INET6) {
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
 			int related;
-			int verdict = ip_vs_out_icmp_v6(skb, &related,
+			int verdict = ip_vs_out_icmp_v6(ipvs, skb, &related,
 							hooknum, &iph);
 
 			if (related)
@@ -1218,7 +1217,7 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
 #endif
 		if (unlikely(iph.protocol == IPPROTO_ICMP)) {
 			int related;
-			int verdict = ip_vs_out_icmp(skb, &related, hooknum);
+			int verdict = ip_vs_out_icmp(ipvs, skb, &related, hooknum);
 
 			if (related)
 				return verdict;
-- 
2.1.4
