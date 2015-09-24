From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 21/84] ipvs: Pass ipvs not net to ip_vs_service_net_cleanup
Date: Thu, 24 Sep 2015 09:52:06 +0900
Message-ID: <1443055989-1306-22-git-send-email-horms@verge.net.au>
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
 include/net/ip_vs.h             | 2 +-
 net/netfilter/ipvs/ip_vs_core.c | 6 ++++--
 net/netfilter/ipvs/ip_vs_ctl.c  | 3 +--
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index b54a19eaa630..3c7040a313b5 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1335,7 +1335,7 @@ void ip_vs_protocol_net_cleanup(struct net *net);
 void ip_vs_control_net_cleanup(struct net *net);
 void ip_vs_estimator_net_cleanup(struct net *net);
 void ip_vs_sync_net_cleanup(struct net *net);
-void ip_vs_service_net_cleanup(struct net *net);
+void ip_vs_service_net_cleanup(struct netns_ipvs *ipvs);
 
 /* IPVS application functions
  * (from ip_vs_app.c)
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index c22e0692e22d..787d561e200b 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2110,13 +2110,15 @@ estimator_fail:
 
 static void __net_exit __ip_vs_cleanup(struct net *net)
 {
-	ip_vs_service_net_cleanup(net);	/* ip_vs_flush() with locks */
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
+	ip_vs_service_net_cleanup(ipvs);	/* ip_vs_flush() with locks */
 	ip_vs_conn_net_cleanup(net);
 	ip_vs_app_net_cleanup(net);
 	ip_vs_protocol_net_cleanup(net);
 	ip_vs_control_net_cleanup(net);
 	ip_vs_estimator_net_cleanup(net);
-	IP_VS_DBG(2, "ipvs netns %d released\n", net_ipvs(net)->gen);
+	IP_VS_DBG(2, "ipvs netns %d released\n", ipvs->gen);
 	net->ipvs = NULL;
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index d9ff59a4bc6e..a281961a1840 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1484,9 +1484,8 @@ static int ip_vs_flush(struct netns_ipvs *ipvs, bool cleanup)
  *	Delete service by {netns} in the service table.
  *	Called by __ip_vs_cleanup()
  */
-void ip_vs_service_net_cleanup(struct net *net)
+void ip_vs_service_net_cleanup(struct netns_ipvs *ipvs)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	EnterFunction(2);
 	/* Check for "full" addressed entries */
 	mutex_lock(&__ip_vs_mutex);
-- 
2.1.4
