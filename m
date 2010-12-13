From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [*v2 PATCH 09/22] IPVS: netns preparation for proto_ah_esp
Date: Mon, 13 Dec 2010 14:38:17 +0100
Message-ID: <1292247510-753-10-git-send-email-hans.schillstrom@ericsson.com>
References: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

In this phase (one), all local vars will be moved to ipvs struct.

Remaining work, add param struct net *net to a couple of
functions that common for all protos.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 net/netfilter/ipvs/ip_vs_proto.c        |    6 ++++++
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |   20 ++++----------------
 2 files changed, 10 insertions(+), 16 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index fd3a7a8..1089248 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -316,6 +316,12 @@ static int  __net_init  __ip_vs_protocol_init(struct net *net)
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

