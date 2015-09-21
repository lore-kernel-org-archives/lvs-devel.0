From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 75/84] ipvs: Pass ipvs into ip_vs_out
Date: Mon, 21 Sep 2015 13:02:52 -0500
Message-ID: <1442858581-15869-75-git-send-email-ebiederm@xmission.com>
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

Derive ipvs from state->net in the callers of ip_vs_out and pass it
into ip_vs_out.  Removing the need to use the hack skb_net.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
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
2.2.1
