From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 78/84] ipvs: Pass ipvs into ip_vs_out_icmp and ip_vs_out_icmp_v6
Date: Mon, 21 Sep 2015 13:02:55 -0500
Message-ID: <1442858581-15869-78-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>

This removes the need to compute ipvs with the hack "net_ipvs(skb_net(skb))"

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
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
2.2.1

