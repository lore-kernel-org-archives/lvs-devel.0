From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 09/22] IPVS: netns preparation for proto_ah_esp
Date: Thu,  6 Jan 2011 15:16:05 +0900
Message-ID: <1294294578-8601-10-git-send-email-horms@verge.net.au>
References: <1294294578-8601-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1294294578-8601-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Patrick McHardy <kaber@trash.net>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

In this phase (one), all local vars will be moved to ipvs struct.

Remaining work, add param struct net *net to a couple of
functions that common for all protos.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_proto.c        |    6 ++++++
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |   20 ++++----------------
 2 files changed, 10 insertions(+), 16 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 001b2f8..9f609d4 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -316,6 +316,12 @@ static int __net_init __ip_vs_protocol_init(struct net *net)
 #ifdef CONFIG_IP_VS_PROTO_SCTP
 	register_ip_vs_proto_netns(net, &ip_vs_protocol_sctp);
 #endif
+#ifdef CONFIG_IP_VS_PROTO_AH
+	register_ip_vs_proto_netns(net, &ip_vs_protocol_ah);
+#endif
+#ifdef CONFIG_IP_VS_PROTO_ESP
+	register_ip_vs_proto_netns(net, &ip_vs_protocol_esp);
+#endif
 	return 0;
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index 3a04611..b8b37fa 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -117,26 +117,14 @@ ah_esp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 	return 0;
 }
 
-static void ah_esp_init(struct ip_vs_protocol *pp)
-{
-	/* nothing to do now */
-}
-
-
-static void ah_esp_exit(struct ip_vs_protocol *pp)
-{
-	/* nothing to do now */
-}
-
-
 #ifdef CONFIG_IP_VS_PROTO_AH
 struct ip_vs_protocol ip_vs_protocol_ah = {
 	.name =			"AH",
 	.protocol =		IPPROTO_AH,
 	.num_states =		1,
 	.dont_defrag =		1,
-	.init =			ah_esp_init,
-	.exit =			ah_esp_exit,
+	.init =			NULL,
+	.exit =			NULL,
 	.conn_schedule =	ah_esp_conn_schedule,
 	.conn_in_get =		ah_esp_conn_in_get,
 	.conn_out_get =		ah_esp_conn_out_get,
@@ -159,8 +147,8 @@ struct ip_vs_protocol ip_vs_protocol_esp = {
 	.protocol =		IPPROTO_ESP,
 	.num_states =		1,
 	.dont_defrag =		1,
-	.init =			ah_esp_init,
-	.exit =			ah_esp_exit,
+	.init =			NULL,
+	.exit =			NULL,
 	.conn_schedule =	ah_esp_conn_schedule,
 	.conn_in_get =		ah_esp_conn_in_get,
 	.conn_out_get =		ah_esp_conn_out_get,
-- 
1.7.2.3

