From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 03/84] ipvs: Use state->net in the ipvs forward functions
Date: Thu, 24 Sep 2015 09:51:48 +0900
Message-ID: <1443055989-1306-4-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
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
2.1.4
