From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 81/84] ipvs: Pass ipvs not net to ip_vs_protocol_net_(init|cleanup)
Date: Thu, 24 Sep 2015 09:53:06 +0900
Message-ID: <1443055989-1306-82-git-send-email-horms@verge.net.au>
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
 include/net/ip_vs.h              | 4 ++--
 net/netfilter/ipvs/ip_vs_core.c  | 6 +++---
 net/netfilter/ipvs/ip_vs_proto.c | 8 +++-----
 3 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index f0a39ce3bf0e..00318d63a565 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1340,13 +1340,13 @@ ip_vs_control_add(struct ip_vs_conn *cp, struct ip_vs_conn *ctl_cp)
 /* IPVS netns init & cleanup functions */
 int ip_vs_estimator_net_init(struct netns_ipvs *ipvs);
 int ip_vs_control_net_init(struct netns_ipvs *ipvs);
-int ip_vs_protocol_net_init(struct net *net);
+int ip_vs_protocol_net_init(struct netns_ipvs *ipvs);
 int ip_vs_app_net_init(struct netns_ipvs *ipvs);
 int ip_vs_conn_net_init(struct netns_ipvs *ipvs);
 int ip_vs_sync_net_init(struct netns_ipvs *ipvs);
 void ip_vs_conn_net_cleanup(struct netns_ipvs *ipvs);
 void ip_vs_app_net_cleanup(struct netns_ipvs *ipvs);
-void ip_vs_protocol_net_cleanup(struct net *net);
+void ip_vs_protocol_net_cleanup(struct netns_ipvs *ipvs);
 void ip_vs_control_net_cleanup(struct netns_ipvs *ipvs);
 void ip_vs_estimator_net_cleanup(struct netns_ipvs *ipvs);
 void ip_vs_sync_net_cleanup(struct netns_ipvs *ipvs);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 22eae0231cbb..ab85ae0f531f 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2052,7 +2052,7 @@ static int __net_init __ip_vs_init(struct net *net)
 	if (ip_vs_control_net_init(ipvs) < 0)
 		goto control_fail;
 
-	if (ip_vs_protocol_net_init(net) < 0)
+	if (ip_vs_protocol_net_init(ipvs) < 0)
 		goto protocol_fail;
 
 	if (ip_vs_app_net_init(ipvs) < 0)
@@ -2076,7 +2076,7 @@ sync_fail:
 conn_fail:
 	ip_vs_app_net_cleanup(ipvs);
 app_fail:
-	ip_vs_protocol_net_cleanup(net);
+	ip_vs_protocol_net_cleanup(ipvs);
 protocol_fail:
 	ip_vs_control_net_cleanup(ipvs);
 control_fail:
@@ -2093,7 +2093,7 @@ static void __net_exit __ip_vs_cleanup(struct net *net)
 	ip_vs_service_net_cleanup(ipvs);	/* ip_vs_flush() with locks */
 	ip_vs_conn_net_cleanup(ipvs);
 	ip_vs_app_net_cleanup(ipvs);
-	ip_vs_protocol_net_cleanup(net);
+	ip_vs_protocol_net_cleanup(ipvs);
 	ip_vs_control_net_cleanup(ipvs);
 	ip_vs_estimator_net_cleanup(ipvs);
 	IP_VS_DBG(2, "ipvs netns %d released\n", ipvs->gen);
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index f05ee668a1d1..8ae480715cea 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -307,7 +307,7 @@ ip_vs_tcpudp_debug_packet(int af, struct ip_vs_protocol *pp,
 /*
  * per network name-space init
  */
-int __net_init ip_vs_protocol_net_init(struct net *net)
+int __net_init ip_vs_protocol_net_init(struct netns_ipvs *ipvs)
 {
 	int i, ret;
 	static struct ip_vs_protocol *protos[] = {
@@ -327,7 +327,6 @@ int __net_init ip_vs_protocol_net_init(struct net *net)
 	&ip_vs_protocol_esp,
 #endif
 	};
-	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	for (i = 0; i < ARRAY_SIZE(protos); i++) {
 		ret = register_ip_vs_proto_netns(ipvs, protos[i]);
@@ -337,13 +336,12 @@ int __net_init ip_vs_protocol_net_init(struct net *net)
 	return 0;
 
 cleanup:
-	ip_vs_protocol_net_cleanup(net);
+	ip_vs_protocol_net_cleanup(ipvs);
 	return ret;
 }
 
-void __net_exit ip_vs_protocol_net_cleanup(struct net *net)
+void __net_exit ip_vs_protocol_net_cleanup(struct netns_ipvs *ipvs)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_proto_data *pd;
 	int i;
 
-- 
2.1.4
