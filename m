From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 77/84] ipvs: Pass ipvs into ip_vs_in_icmp and ip_vs_in_icmp_v6
Date: Sun, 20 Sep 2015 01:23:33 -0500
Message-ID: <1442730220-32458-77-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

With ipvs passed into ip_vs_in_icmp and ip_vs_in_icmp_v6
they no longer need to call the hack that is skb_net.

Additionally ipvs_in_icmp no longer needs to call dev_net(skb->dev)
and can use the ipvs->net instead.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 36 ++++++++++++++----------------------
 1 file changed, 14 insertions(+), 22 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 3ab96bdc66fd..0304c7cbb786 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1388,10 +1388,9 @@ ip_vs_try_to_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
  *	Currently handles error types - unreachable, quench, ttl exceeded.
  */
 static int
-ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
+ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
+	      unsigned int hooknum)
 {
-	struct net *net = NULL;
-	struct netns_ipvs *ipvs;
 	struct iphdr *iph;
 	struct icmphdr	_icmph, *ic;
 	struct iphdr	_ciph, *cih;	/* The ip header contained within the ICMP */
@@ -1440,9 +1439,6 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	if (cih == NULL)
 		return NF_ACCEPT; /* The packet looks wrong, ignore */
 
-	net = skb_net(skb);
-	ipvs = net_ipvs(net);
-
 	/* Special case for errors for IPIP packets */
 	ipip = false;
 	if (cih->protocol == IPPROTO_IPIP) {
@@ -1520,7 +1516,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 			skb_reset_network_header(skb);
 			IP_VS_DBG(12, "ICMP for IPIP %pI4->%pI4: mtu=%u\n",
 				&ip_hdr(skb)->saddr, &ip_hdr(skb)->daddr, mtu);
-			ipv4_update_pmtu(skb, dev_net(skb->dev),
+			ipv4_update_pmtu(skb, ipvs->net,
 					 mtu, 0, 0, 0, 0);
 			/* Client uses PMTUD? */
 			if (!(frag_off & htons(IP_DF)))
@@ -1575,11 +1571,10 @@ out:
 }
 
 #ifdef CONFIG_IP_VS_IPV6
-static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
-			    unsigned int hooknum, struct ip_vs_iphdr *iph)
+static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
+			    int *related, unsigned int hooknum,
+			    struct ip_vs_iphdr *iph)
 {
-	struct net *net = NULL;
-	struct netns_ipvs *ipvs;
 	struct icmp6hdr	_icmph, *ic;
 	struct ip_vs_iphdr ciph = {.flags = 0, .fragoffs = 0};/*Contained IP */
 	struct ip_vs_conn *cp;
@@ -1619,8 +1614,6 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 	if (!ip_vs_fill_iph_skb_icmp(AF_INET6, skb, offset, true, &ciph))
 		return NF_ACCEPT;
 
-	net = skb_net(skb);
-	ipvs = net_ipvs(net);
 	pd = ip_vs_proto_data_get(ipvs, ciph.protocol);
 	if (!pd)
 		return NF_ACCEPT;
@@ -1732,8 +1725,8 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
 	if (af == AF_INET6) {
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
 			int related;
-			int verdict = ip_vs_in_icmp_v6(skb, &related, hooknum,
-						       &iph);
+			int verdict = ip_vs_in_icmp_v6(ipvs, skb, &related,
+						       hooknum, &iph);
 
 			if (related)
 				return verdict;
@@ -1742,7 +1735,8 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
 #endif
 		if (unlikely(iph.protocol == IPPROTO_ICMP)) {
 			int related;
-			int verdict = ip_vs_in_icmp(skb, &related, hooknum);
+			int verdict = ip_vs_in_icmp(ipvs, skb, &related,
+						    hooknum);
 
 			if (related)
 				return verdict;
@@ -1895,17 +1889,16 @@ ip_vs_forward_icmp(void *priv, struct sk_buff *skb,
 		   const struct nf_hook_state *state)
 {
 	int r;
-	struct netns_ipvs *ipvs;
+	struct netns_ipvs *ipvs = net_ipvs(state->net);
 
 	if (ip_hdr(skb)->protocol != IPPROTO_ICMP)
 		return NF_ACCEPT;
 
 	/* ipvs enabled in this netns ? */
-	ipvs = net_ipvs(state->net);
 	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
 		return NF_ACCEPT;
 
-	return ip_vs_in_icmp(skb, &r, state->hook);
+	return ip_vs_in_icmp(ipvs, skb, &r, state->hook);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1914,7 +1907,7 @@ ip_vs_forward_icmp_v6(void *priv, struct sk_buff *skb,
 		      const struct nf_hook_state *state)
 {
 	int r;
-	struct netns_ipvs *ipvs;
+	struct netns_ipvs *ipvs = net_ipvs(state->net);
 	struct ip_vs_iphdr iphdr;
 
 	ip_vs_fill_iph_skb(AF_INET6, skb, false, &iphdr);
@@ -1922,11 +1915,10 @@ ip_vs_forward_icmp_v6(void *priv, struct sk_buff *skb,
 		return NF_ACCEPT;
 
 	/* ipvs enabled in this netns ? */
-	ipvs = net_ipvs(state->net);
 	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
 		return NF_ACCEPT;
 
-	return ip_vs_in_icmp_v6(skb, &r, state->hook, &iphdr);
+	return ip_vs_in_icmp_v6(ipvs, skb, &r, state->hook, &iphdr);
 }
 #endif
 
-- 
2.2.1

