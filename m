From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 23/84] ipvs: Cache ipvs in ip_vs_in_icmp and ip_vs_in_icmp_v6
Date: Mon, 21 Sep 2015 13:02:00 -0500
Message-ID: <1442858581-15869-23-git-send-email-ebiederm@xmission.com>
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

Storte the value of net_ipvs in a variable named ipvs so that when
there are more users struct netns_ipvs in ip_vs_in_cmp and
ip_vs_in_icmp_v6 they won't need to compute the value again.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 787d561e200b..77dcd3ed27de 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1403,6 +1403,7 @@ static int
 ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 {
 	struct net *net = NULL;
+	struct netns_ipvs *ipvs;
 	struct iphdr *iph;
 	struct icmphdr	_icmph, *ic;
 	struct iphdr	_ciph, *cih;	/* The ip header contained within the ICMP */
@@ -1452,6 +1453,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 		return NF_ACCEPT; /* The packet looks wrong, ignore */
 
 	net = skb_net(skb);
+	ipvs = net_ipvs(net);
 
 	/* Special case for errors for IPIP packets */
 	ipip = false;
@@ -1493,7 +1495,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	if (!cp) {
 		int v;
 
-		if (!sysctl_schedule_icmp(net_ipvs(net)))
+		if (!sysctl_schedule_icmp(ipvs))
 			return NF_ACCEPT;
 
 		if (!ip_vs_try_to_schedule(AF_INET, skb, pd, &v, &cp, &ciph))
@@ -1589,6 +1591,7 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 			    unsigned int hooknum, struct ip_vs_iphdr *iph)
 {
 	struct net *net = NULL;
+	struct netns_ipvs *ipvs;
 	struct icmp6hdr	_icmph, *ic;
 	struct ip_vs_iphdr ciph = {.flags = 0, .fragoffs = 0};/*Contained IP */
 	struct ip_vs_conn *cp;
@@ -1629,6 +1632,7 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 		return NF_ACCEPT;
 
 	net = skb_net(skb);
+	ipvs = net_ipvs(net);
 	pd = ip_vs_proto_data_get(net, ciph.protocol);
 	if (!pd)
 		return NF_ACCEPT;
@@ -1649,7 +1653,7 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 	if (!cp) {
 		int v;
 
-		if (!sysctl_schedule_icmp(net_ipvs(net)))
+		if (!sysctl_schedule_icmp(ipvs))
 			return NF_ACCEPT;
 
 		if (!ip_vs_try_to_schedule(AF_INET6, skb, pd, &v, &cp, &ciph))
-- 
2.2.1
