From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 49/84] ipvs: Pass ipvs not net into ip_vs_control_net_(init|cleanup)
Date: Thu, 24 Sep 2015 09:52:34 +0900
Message-ID: <1443055989-1306-50-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
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
 include/net/ip_vs.h             | 4 ++--
 net/netfilter/ipvs/ip_vs_core.c | 6 +++---
 net/netfilter/ipvs/ip_vs_ctl.c  | 8 ++++----
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index c88a3bf85f98..38c1fca0c1a7 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1324,7 +1324,7 @@ ip_vs_control_add(struct ip_vs_conn *cp, struct ip_vs_conn *ctl_cp)
 
 /* IPVS netns init & cleanup functions */
 int ip_vs_estimator_net_init(struct net *net);
-int ip_vs_control_net_init(struct net *net);
+int ip_vs_control_net_init(struct netns_ipvs *ipvs);
 int ip_vs_protocol_net_init(struct net *net);
 int ip_vs_app_net_init(struct net *net);
 int ip_vs_conn_net_init(struct net *net);
@@ -1332,7 +1332,7 @@ int ip_vs_sync_net_init(struct netns_ipvs *ipvs);
 void ip_vs_conn_net_cleanup(struct net *net);
 void ip_vs_app_net_cleanup(struct net *net);
 void ip_vs_protocol_net_cleanup(struct net *net);
-void ip_vs_control_net_cleanup(struct net *net);
+void ip_vs_control_net_cleanup(struct netns_ipvs *ipvs);
 void ip_vs_estimator_net_cleanup(struct net *net);
 void ip_vs_sync_net_cleanup(struct netns_ipvs *ipvs);
 void ip_vs_service_net_cleanup(struct netns_ipvs *ipvs);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index cae395fc6523..b5f451f20f52 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2075,7 +2075,7 @@ static int __net_init __ip_vs_init(struct net *net)
 	if (ip_vs_estimator_net_init(net) < 0)
 		goto estimator_fail;
 
-	if (ip_vs_control_net_init(net) < 0)
+	if (ip_vs_control_net_init(ipvs) < 0)
 		goto control_fail;
 
 	if (ip_vs_protocol_net_init(net) < 0)
@@ -2104,7 +2104,7 @@ conn_fail:
 app_fail:
 	ip_vs_protocol_net_cleanup(net);
 protocol_fail:
-	ip_vs_control_net_cleanup(net);
+	ip_vs_control_net_cleanup(ipvs);
 control_fail:
 	ip_vs_estimator_net_cleanup(net);
 estimator_fail:
@@ -2120,7 +2120,7 @@ static void __net_exit __ip_vs_cleanup(struct net *net)
 	ip_vs_conn_net_cleanup(net);
 	ip_vs_app_net_cleanup(net);
 	ip_vs_protocol_net_cleanup(net);
-	ip_vs_control_net_cleanup(net);
+	ip_vs_control_net_cleanup(ipvs);
 	ip_vs_estimator_net_cleanup(net);
 	IP_VS_DBG(2, "ipvs netns %d released\n", ipvs->gen);
 	net->ipvs = NULL;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index f0d72d6375e7..b7a0bd274085 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3950,10 +3950,10 @@ static struct notifier_block ip_vs_dst_notifier = {
 	.notifier_call = ip_vs_dst_event,
 };
 
-int __net_init ip_vs_control_net_init(struct net *net)
+int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 {
+	struct net *net = ipvs->net;
 	int i, idx;
-	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	/* Initialize rs_table */
 	for (idx = 0; idx < IP_VS_RTAB_SIZE; idx++)
@@ -3994,9 +3994,9 @@ err:
 	return -ENOMEM;
 }
 
-void __net_exit ip_vs_control_net_cleanup(struct net *net)
+void __net_exit ip_vs_control_net_cleanup(struct netns_ipvs *ipvs)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct net *net = ipvs->net;
 
 	ip_vs_trash_cleanup(ipvs);
 	ip_vs_control_net_cleanup_sysctl(ipvs);
-- 
2.1.4

