From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/2] netfilter: ipvs: fix compiler warnings
Date: Sat, 22 Jan 2011 14:10:34 +1100
Message-ID: <1295665835-8708-2-git-send-email-horms@verge.net.au>
References: <1295665835-8708-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1295665835-8708-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Changli Gao <xiaosuo@gmail.com>, Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

From: Changli Gao <xiaosuo@gmail.com>

Fix compiler warnings when no transport protocol load balancing support
is configured.

[horms@verge.net.au: removed suprious __ip_vs_cleanup() clean-up hunk]
Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c   |    4 ++++
 net/netfilter/ipvs/ip_vs_proto.c |    4 ++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 09ca2ce..68b8033 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2062,7 +2062,9 @@ static const struct file_operations ip_vs_stats_percpu_fops = {
  */
 static int ip_vs_set_timeout(struct net *net, struct ip_vs_timeout_user *u)
 {
+#if defined(CONFIG_IP_VS_PROTO_TCP) || defined(CONFIG_IP_VS_PROTO_UDP)
 	struct ip_vs_proto_data *pd;
+#endif
 
 	IP_VS_DBG(2, "Setting timeout tcp:%d tcpfin:%d udp:%d\n",
 		  u->tcp_timeout,
@@ -2405,7 +2407,9 @@ __ip_vs_get_dest_entries(struct net *net, const struct ip_vs_get_dests *get,
 static inline void
 __ip_vs_get_timeouts(struct net *net, struct ip_vs_timeout_user *u)
 {
+#if defined(CONFIG_IP_VS_PROTO_TCP) || defined(CONFIG_IP_VS_PROTO_UDP)
 	struct ip_vs_proto_data *pd;
+#endif
 
 #ifdef CONFIG_IP_VS_PROTO_TCP
 	pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 6ac986c..17484a4 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -60,6 +60,9 @@ static int __used __init register_ip_vs_protocol(struct ip_vs_protocol *pp)
 	return 0;
 }
 
+#if defined(CONFIG_IP_VS_PROTO_TCP) || defined(CONFIG_IP_VS_PROTO_UDP) || \
+    defined(CONFIG_IP_VS_PROTO_SCTP) || defined(CONFIG_IP_VS_PROTO_AH) || \
+    defined(CONFIG_IP_VS_PROTO_ESP)
 /*
  *	register an ipvs protocols netns related data
  */
@@ -85,6 +88,7 @@ register_ip_vs_proto_netns(struct net *net, struct ip_vs_protocol *pp)
 
 	return 0;
 }
+#endif
 
 /*
  *	unregister an ipvs protocol
-- 
1.7.2.3

