From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next v2 4/4] netfilter: ipvs: merge ipv4 + ipv6 icmp reply handlers
Date: Tue, 12 Oct 2021 19:29:59 +0200
Message-ID: <20211012172959.745-5-fw@strlen.de>
References: <20211012172959.745-1-fw@strlen.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20211012172959.745-1-fw@strlen.de>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: netfilter-devel@vger.kernel.org
Cc: lvs-devel@vger.kernel.org, ja@ssi.bg, horms@verge.net.au, Florian Westphal <fw@strlen.de>

Similar to earlier patches: allow ipv4 and ipv6 to use the
same handler.  ipv4 and ipv6 specific actions can be done by
checking state->pf.

v2: split the pf == NFPROTO_IPV4 check (Julian Anastasov)

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/netfilter/ipvs/ip_vs_core.c | 37 +++++++++++++--------------------
 1 file changed, 14 insertions(+), 23 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index ad5f5e50547f..e93c937a8bf0 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2106,40 +2106,31 @@ static unsigned int
 ip_vs_forward_icmp(void *priv, struct sk_buff *skb,
 		   const struct nf_hook_state *state)
 {
-	int r;
 	struct netns_ipvs *ipvs = net_ipvs(state->net);
-
-	if (ip_hdr(skb)->protocol != IPPROTO_ICMP)
-		return NF_ACCEPT;
+	int r;
 
 	/* ipvs enabled in this netns ? */
 	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
 		return NF_ACCEPT;
 
-	return ip_vs_in_icmp(ipvs, skb, &r, state->hook);
-}
-
+	if (state->pf == NFPROTO_IPV4) {
+		if (ip_hdr(skb)->protocol != IPPROTO_ICMP)
+			return NF_ACCEPT;
 #ifdef CONFIG_IP_VS_IPV6
-static unsigned int
-ip_vs_forward_icmp_v6(void *priv, struct sk_buff *skb,
-		      const struct nf_hook_state *state)
-{
-	int r;
-	struct netns_ipvs *ipvs = net_ipvs(state->net);
-	struct ip_vs_iphdr iphdr;
+	} else {
+		struct ip_vs_iphdr iphdr;
 
-	ip_vs_fill_iph_skb(AF_INET6, skb, false, &iphdr);
-	if (iphdr.protocol != IPPROTO_ICMPV6)
-		return NF_ACCEPT;
+		ip_vs_fill_iph_skb(AF_INET6, skb, false, &iphdr);
 
-	/* ipvs enabled in this netns ? */
-	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
-		return NF_ACCEPT;
+		if (iphdr.protocol != IPPROTO_ICMPV6)
+			return NF_ACCEPT;
 
-	return ip_vs_in_icmp_v6(ipvs, skb, &r, state->hook, &iphdr);
-}
+		return ip_vs_in_icmp_v6(ipvs, skb, &r, state->hook, &iphdr);
 #endif
+	}
 
+	return ip_vs_in_icmp(ipvs, skb, &r, state->hook);
+}
 
 static const struct nf_hook_ops ip_vs_ops4[] = {
 	/* After packet filtering, change source only for VS/NAT */
@@ -2224,7 +2215,7 @@ static const struct nf_hook_ops ip_vs_ops6[] = {
 	/* After packet filtering (but before ip_vs_out_icmp), catch icmp
 	 * destined for 0.0.0.0/0, which is for incoming IPVS connections */
 	{
-		.hook		= ip_vs_forward_icmp_v6,
+		.hook		= ip_vs_forward_icmp,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= 99,
-- 
2.32.0

