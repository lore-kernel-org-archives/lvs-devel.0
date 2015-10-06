From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] ipvs: Remove possibly unused net variable from ip_vs_out
Date: Tue,  6 Oct 2015 17:15:24 +0900
Message-ID: <1444119324-5653-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

Since 6f2bcea9917d ("ipvs: Pass ipvs into ip_vs_in_icmp and
ip_vs_in_icmp_v6") the net variable in ip_vs_out() appears to be unused
unless CONFIG_IP_VS_IPV6 is set. To resolve this remove the net variable
and dereference net asneeded.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index d08df435c2aa..3773154d9b71 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1172,7 +1172,6 @@ drop:
 static unsigned int
 ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int af)
 {
-	struct net *net = ipvs->net;
 	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
@@ -1272,7 +1271,7 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
 #ifdef CONFIG_IP_VS_IPV6
 				if (af == AF_INET6) {
 					if (!skb->dev)
-						skb->dev = net->loopback_dev;
+						skb->dev = ipvs->net->loopback_dev;
 					icmpv6_send(skb,
 						    ICMPV6_DEST_UNREACH,
 						    ICMPV6_PORT_UNREACH,
-- 
2.1.4

