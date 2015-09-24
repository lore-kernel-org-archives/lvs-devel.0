From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 75/84] ipvs: Pass ipvs into ip_vs_out
Date: Thu, 24 Sep 2015 09:53:00 +0900
Message-ID: <1443055989-1306-76-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Derive ipvs from state->net in the callers of ip_vs_out and pass it
into ip_vs_out.  Removing the need to use the hack skb_net.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index b25fb3309472..07a4ddca650d 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1173,10 +1173,9 @@ drop:
  *	Check if outgoing packet belongs to the established ip_vs_conn.
  */
 static unsigned int
-ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
+ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int af)
 {
-	struct net *net = NULL;
-	struct netns_ipvs *ipvs;
+	struct net *net = ipvs->net;
 	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
@@ -1201,8 +1200,6 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (unlikely(!skb_dst(skb)))
 		return NF_ACCEPT;
 
-	net = skb_net(skb);
-	ipvs = net_ipvs(net);
 	if (!ipvs->enable)
 		return NF_ACCEPT;
 
@@ -1306,7 +1303,7 @@ static unsigned int
 ip_vs_reply4(void *priv, struct sk_buff *skb,
 	     const struct nf_hook_state *state)
 {
-	return ip_vs_out(state->hook, skb, AF_INET);
+	return ip_vs_out(net_ipvs(state->net), state->hook, skb, AF_INET);
 }
 
 /*
@@ -1317,7 +1314,7 @@ static unsigned int
 ip_vs_local_reply4(void *priv, struct sk_buff *skb,
 		   const struct nf_hook_state *state)
 {
-	return ip_vs_out(state->hook, skb, AF_INET);
+	return ip_vs_out(net_ipvs(state->net), state->hook, skb, AF_INET);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1331,7 +1328,7 @@ static unsigned int
 ip_vs_reply6(void *priv, struct sk_buff *skb,
 	     const struct nf_hook_state *state)
 {
-	return ip_vs_out(state->hook, skb, AF_INET6);
+	return ip_vs_out(net_ipvs(state->net), state->hook, skb, AF_INET6);
 }
 
 /*
@@ -1342,7 +1339,7 @@ static unsigned int
 ip_vs_local_reply6(void *priv, struct sk_buff *skb,
 		   const struct nf_hook_state *state)
 {
-	return ip_vs_out(state->hook, skb, AF_INET6);
+	return ip_vs_out(net_ipvs(state->net), state->hook, skb, AF_INET6);
 }
 
 #endif
-- 
2.1.4

