From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 65/84] ipvs: Pass ipvs not net into ip_vs_conn_net_init and ip_vs_conn_net_cleanup
Date: Thu, 24 Sep 2015 09:52:50 +0900
Message-ID: <1443055989-1306-66-git-send-email-horms@verge.net.au>
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
 net/netfilter/ipvs/ip_vs_conn.c | 8 ++++----
 net/netfilter/ipvs/ip_vs_core.c | 6 +++---
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 0ca436ef7dad..5ad04be64895 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1331,9 +1331,9 @@ int ip_vs_estimator_net_init(struct netns_ipvs *ipvs);
 int ip_vs_control_net_init(struct netns_ipvs *ipvs);
 int ip_vs_protocol_net_init(struct net *net);
 int ip_vs_app_net_init(struct netns_ipvs *ipvs);
-int ip_vs_conn_net_init(struct net *net);
+int ip_vs_conn_net_init(struct netns_ipvs *ipvs);
 int ip_vs_sync_net_init(struct netns_ipvs *ipvs);
-void ip_vs_conn_net_cleanup(struct net *net);
+void ip_vs_conn_net_cleanup(struct netns_ipvs *ipvs);
 void ip_vs_app_net_cleanup(struct netns_ipvs *ipvs);
 void ip_vs_protocol_net_cleanup(struct net *net);
 void ip_vs_control_net_cleanup(struct netns_ipvs *ipvs);
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 4bb1b7d1286d..d1d168c7fc68 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1345,9 +1345,9 @@ flush_again:
 /*
  * per netns init and exit
  */
-int __net_init ip_vs_conn_net_init(struct net *net)
+int __net_init ip_vs_conn_net_init(struct netns_ipvs *ipvs)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct net *net = ipvs->net;
 
 	atomic_set(&ipvs->conn_count, 0);
 
@@ -1356,9 +1356,9 @@ int __net_init ip_vs_conn_net_init(struct net *net)
 	return 0;
 }
 
-void __net_exit ip_vs_conn_net_cleanup(struct net *net)
+void __net_exit ip_vs_conn_net_cleanup(struct netns_ipvs *ipvs)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct net *net = ipvs->net;
 
 	/* flush all the connection entries first */
 	ip_vs_conn_flush(ipvs);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index f0369e7602a0..9b37fe30dcac 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2086,7 +2086,7 @@ static int __net_init __ip_vs_init(struct net *net)
 	if (ip_vs_app_net_init(ipvs) < 0)
 		goto app_fail;
 
-	if (ip_vs_conn_net_init(net) < 0)
+	if (ip_vs_conn_net_init(ipvs) < 0)
 		goto conn_fail;
 
 	if (ip_vs_sync_net_init(ipvs) < 0)
@@ -2100,7 +2100,7 @@ static int __net_init __ip_vs_init(struct net *net)
  */
 
 sync_fail:
-	ip_vs_conn_net_cleanup(net);
+	ip_vs_conn_net_cleanup(ipvs);
 conn_fail:
 	ip_vs_app_net_cleanup(ipvs);
 app_fail:
@@ -2119,7 +2119,7 @@ static void __net_exit __ip_vs_cleanup(struct net *net)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	ip_vs_service_net_cleanup(ipvs);	/* ip_vs_flush() with locks */
-	ip_vs_conn_net_cleanup(net);
+	ip_vs_conn_net_cleanup(ipvs);
 	ip_vs_app_net_cleanup(ipvs);
 	ip_vs_protocol_net_cleanup(net);
 	ip_vs_control_net_cleanup(ipvs);
-- 
2.1.4

