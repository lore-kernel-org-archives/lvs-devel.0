From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 67/84] ipvs: Better derivation of ipvs in ip_vs_tunnel_xmit
Date: Sun, 20 Sep 2015 01:23:23 -0500
Message-ID: <1442730220-32458-67-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Don't use "net_ipvs(skb_net(skb))" as skb_net is a bad hack.  Instead
use cp->ipvs and ipvs->net for the net.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 5b5ec0b688de..ec10ebf246fd 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -971,8 +971,8 @@ int
 ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
-	struct net *net = skb_net(skb);
-	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct netns_ipvs *ipvs = cp->ipvs;
+	struct net *net = ipvs->net;
 	struct rtable *rt;			/* Route to the other host */
 	__be32 saddr;				/* Source for tunnel */
 	struct net_device *tdev;		/* Device to other host */
-- 
2.2.1
