From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 76/84] ipvs: Pass ipvs into ip_vs_in
Date: Mon, 21 Sep 2015 13:02:53 -0500
Message-ID: <1442858581-15869-76-git-send-email-ebiederm@xmission.com>
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

Derive ipvs from state->net in the callers of ip_vs_in and pass it
into ip_vs_out.  Removing the need to use the hack skb_net.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 07a4ddca650d..3ab96bdc66fd 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1684,15 +1684,13 @@ out:
  *	and send it on its way...
  */
 static unsigned int
-ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
+ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int af)
 {
-	struct net *net;
 	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
 	struct ip_vs_conn *cp;
 	int ret, pkts;
-	struct netns_ipvs *ipvs;
 	int conn_reuse_mode;
 
 	/* Already marked as IPVS request or reply? */
@@ -1715,8 +1713,6 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 		return NF_ACCEPT;
 	}
 	/* ipvs enabled in this netns ? */
-	net = skb_net(skb);
-	ipvs = net_ipvs(net);
 	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
 		return NF_ACCEPT;
 
@@ -1844,7 +1840,7 @@ static unsigned int
 ip_vs_remote_request4(void *priv, struct sk_buff *skb,
 		      const struct nf_hook_state *state)
 {
-	return ip_vs_in(state->hook, skb, AF_INET);
+	return ip_vs_in(net_ipvs(state->net), state->hook, skb, AF_INET);
 }
 
 /*
@@ -1855,7 +1851,7 @@ static unsigned int
 ip_vs_local_request4(void *priv, struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
-	return ip_vs_in(state->hook, skb, AF_INET);
+	return ip_vs_in(net_ipvs(state->net), state->hook, skb, AF_INET);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1868,7 +1864,7 @@ static unsigned int
 ip_vs_remote_request6(void *priv, struct sk_buff *skb,
 		      const struct nf_hook_state *state)
 {
-	return ip_vs_in(state->hook, skb, AF_INET6);
+	return ip_vs_in(net_ipvs(state->net), state->hook, skb, AF_INET6);
 }
 
 /*
@@ -1879,7 +1875,7 @@ static unsigned int
 ip_vs_local_request6(void *priv, struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
-	return ip_vs_in(state->hook, skb, AF_INET6);
+	return ip_vs_in(net_ipvs(state->net), state->hook, skb, AF_INET6);
 }
 
 #endif
-- 
2.2.1

