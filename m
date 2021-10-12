From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 3/4] netfilter: ipvs: remove unneeded input wrappers
Date: Tue, 12 Oct 2021 14:06:07 +0200
Message-ID: <20211012120608.21827-4-fw@strlen.de>
References: <20211012120608.21827-1-fw@strlen.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20211012120608.21827-1-fw@strlen.de>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: netfilter-devel@vger.kernel.org
Cc: lvs-devel@vger.kernel.org, ja@ssi.bg, horms@verge.net.au, Florian Westphal <fw@strlen.de>

After earlier patch ip_vs_hook_in can be used directly.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/netfilter/ipvs/ip_vs_core.c | 57 +++------------------------------
 1 file changed, 4 insertions(+), 53 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 2db033455204..ad5f5e50547f 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2093,55 +2093,6 @@ ip_vs_in_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *state
 	return ret;
 }
 
-/*
- *	AF_INET handler in NF_INET_LOCAL_IN chain
- *	Schedule and forward packets from remote clients
- */
-static unsigned int
-ip_vs_remote_request4(void *priv, struct sk_buff *skb,
-		      const struct nf_hook_state *state)
-{
-	return ip_vs_in_hook(priv, skb, state);
-}
-
-/*
- *	AF_INET handler in NF_INET_LOCAL_OUT chain
- *	Schedule and forward packets from local clients
- */
-static unsigned int
-ip_vs_local_request4(void *priv, struct sk_buff *skb,
-		     const struct nf_hook_state *state)
-{
-	return ip_vs_in_hook(priv, skb, state);
-}
-
-#ifdef CONFIG_IP_VS_IPV6
-
-/*
- *	AF_INET6 handler in NF_INET_LOCAL_IN chain
- *	Schedule and forward packets from remote clients
- */
-static unsigned int
-ip_vs_remote_request6(void *priv, struct sk_buff *skb,
-		      const struct nf_hook_state *state)
-{
-	return ip_vs_in_hook(priv, skb, state);
-}
-
-/*
- *	AF_INET6 handler in NF_INET_LOCAL_OUT chain
- *	Schedule and forward packets from local clients
- */
-static unsigned int
-ip_vs_local_request6(void *priv, struct sk_buff *skb,
-		     const struct nf_hook_state *state)
-{
-	return ip_vs_in_hook(priv, skb, state);
-}
-
-#endif
-
-
 /*
  *	It is hooked at the NF_INET_FORWARD chain, in order to catch ICMP
  *      related packets destined for 0.0.0.0/0.
@@ -2202,7 +2153,7 @@ static const struct nf_hook_ops ip_vs_ops4[] = {
 	 * or VS/NAT(change destination), so that filtering rules can be
 	 * applied to IPVS. */
 	{
-		.hook		= ip_vs_remote_request4,
+		.hook		= ip_vs_in_hook,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_NAT_SRC - 1,
@@ -2216,7 +2167,7 @@ static const struct nf_hook_ops ip_vs_ops4[] = {
 	},
 	/* After mangle, schedule and forward local requests */
 	{
-		.hook		= ip_vs_local_request4,
+		.hook		= ip_vs_in_hook,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP_PRI_NAT_DST + 2,
@@ -2251,7 +2202,7 @@ static const struct nf_hook_ops ip_vs_ops6[] = {
 	 * or VS/NAT(change destination), so that filtering rules can be
 	 * applied to IPVS. */
 	{
-		.hook		= ip_vs_remote_request6,
+		.hook		= ip_vs_in_hook,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_NAT_SRC - 1,
@@ -2265,7 +2216,7 @@ static const struct nf_hook_ops ip_vs_ops6[] = {
 	},
 	/* After mangle, schedule and forward local requests */
 	{
-		.hook		= ip_vs_local_request6,
+		.hook		= ip_vs_in_hook,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_NAT_DST + 2,
-- 
2.32.0

