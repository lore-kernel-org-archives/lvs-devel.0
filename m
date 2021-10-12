From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next v2 2/4] netfilter: ipvs: remove unneeded output wrappers
Date: Tue, 12 Oct 2021 19:29:57 +0200
Message-ID: <20211012172959.745-3-fw@strlen.de>
References: <20211012172959.745-1-fw@strlen.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20211012172959.745-1-fw@strlen.de>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: netfilter-devel@vger.kernel.org
Cc: lvs-devel@vger.kernel.org, ja@ssi.bg, horms@verge.net.au, Florian Westphal <fw@strlen.de>

After earlier patch we can use ip_vs_out_hook directly.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/netfilter/ipvs/ip_vs_core.c | 62 ++++-----------------------------
 1 file changed, 6 insertions(+), 56 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 5a5deee3425c..2db033455204 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1471,56 +1471,6 @@ ip_vs_out_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *stat
 	return NF_ACCEPT;
 }
 
-/*
- *	It is hooked at the NF_INET_FORWARD and NF_INET_LOCAL_IN chain,
- *	used only for VS/NAT.
- *	Check if packet is reply for established ip_vs_conn.
- */
-static unsigned int
-ip_vs_reply4(void *priv, struct sk_buff *skb,
-	     const struct nf_hook_state *state)
-{
-	return ip_vs_out_hook(priv, skb, state);
-}
-
-/*
- *	It is hooked at the NF_INET_LOCAL_OUT chain, used only for VS/NAT.
- *	Check if packet is reply for established ip_vs_conn.
- */
-static unsigned int
-ip_vs_local_reply4(void *priv, struct sk_buff *skb,
-		   const struct nf_hook_state *state)
-{
-	return ip_vs_out_hook(priv, skb, state);
-}
-
-#ifdef CONFIG_IP_VS_IPV6
-
-/*
- *	It is hooked at the NF_INET_FORWARD and NF_INET_LOCAL_IN chain,
- *	used only for VS/NAT.
- *	Check if packet is reply for established ip_vs_conn.
- */
-static unsigned int
-ip_vs_reply6(void *priv, struct sk_buff *skb,
-	     const struct nf_hook_state *state)
-{
-	return ip_vs_out_hook(priv, skb, state);
-}
-
-/*
- *	It is hooked at the NF_INET_LOCAL_OUT chain, used only for VS/NAT.
- *	Check if packet is reply for established ip_vs_conn.
- */
-static unsigned int
-ip_vs_local_reply6(void *priv, struct sk_buff *skb,
-		   const struct nf_hook_state *state)
-{
-	return ip_vs_out_hook(priv, skb, state);
-}
-
-#endif
-
 static unsigned int
 ip_vs_try_to_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		      struct ip_vs_proto_data *pd,
@@ -2243,7 +2193,7 @@ ip_vs_forward_icmp_v6(void *priv, struct sk_buff *skb,
 static const struct nf_hook_ops ip_vs_ops4[] = {
 	/* After packet filtering, change source only for VS/NAT */
 	{
-		.hook		= ip_vs_reply4,
+		.hook		= ip_vs_out_hook,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_NAT_SRC - 2,
@@ -2259,7 +2209,7 @@ static const struct nf_hook_ops ip_vs_ops4[] = {
 	},
 	/* Before ip_vs_in, change source only for VS/NAT */
 	{
-		.hook		= ip_vs_local_reply4,
+		.hook		= ip_vs_out_hook,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP_PRI_NAT_DST + 1,
@@ -2281,7 +2231,7 @@ static const struct nf_hook_ops ip_vs_ops4[] = {
 	},
 	/* After packet filtering, change source only for VS/NAT */
 	{
-		.hook		= ip_vs_reply4,
+		.hook		= ip_vs_out_hook,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= 100,
@@ -2292,7 +2242,7 @@ static const struct nf_hook_ops ip_vs_ops4[] = {
 static const struct nf_hook_ops ip_vs_ops6[] = {
 	/* After packet filtering, change source only for VS/NAT */
 	{
-		.hook		= ip_vs_reply6,
+		.hook		= ip_vs_out_hook,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_NAT_SRC - 2,
@@ -2308,7 +2258,7 @@ static const struct nf_hook_ops ip_vs_ops6[] = {
 	},
 	/* Before ip_vs_in, change source only for VS/NAT */
 	{
-		.hook		= ip_vs_local_reply6,
+		.hook		= ip_vs_out_hook,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_NAT_DST + 1,
@@ -2330,7 +2280,7 @@ static const struct nf_hook_ops ip_vs_ops6[] = {
 	},
 	/* After packet filtering, change source only for VS/NAT */
 	{
-		.hook		= ip_vs_reply6,
+		.hook		= ip_vs_out_hook,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= 100,
-- 
2.32.0

