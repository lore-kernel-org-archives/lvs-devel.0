From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 03/84] ipvs: Use state->net in the ipvs forward functions
Date: Mon, 21 Sep 2015 13:01:40 -0500
Message-ID: <1442858581-15869-3-git-send-email-ebiederm@xmission.com>
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

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 1fa12edccbcc..3f33a076aaec 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1905,15 +1905,13 @@ ip_vs_forward_icmp(void *priv, struct sk_buff *skb,
 		   const struct nf_hook_state *state)
 {
 	int r;
-	struct net *net;
 	struct netns_ipvs *ipvs;
 
 	if (ip_hdr(skb)->protocol != IPPROTO_ICMP)
 		return NF_ACCEPT;
 
 	/* ipvs enabled in this netns ? */
-	net = skb_net(skb);
-	ipvs = net_ipvs(net);
+	ipvs = net_ipvs(state->net);
 	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
 		return NF_ACCEPT;
 
@@ -1926,7 +1924,6 @@ ip_vs_forward_icmp_v6(void *priv, struct sk_buff *skb,
 		      const struct nf_hook_state *state)
 {
 	int r;
-	struct net *net;
 	struct netns_ipvs *ipvs;
 	struct ip_vs_iphdr iphdr;
 
@@ -1935,8 +1932,7 @@ ip_vs_forward_icmp_v6(void *priv, struct sk_buff *skb,
 		return NF_ACCEPT;
 
 	/* ipvs enabled in this netns ? */
-	net = skb_net(skb);
-	ipvs = net_ipvs(net);
+	ipvs = net_ipvs(state->net);
 	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
 		return NF_ACCEPT;
 
-- 
2.2.1
