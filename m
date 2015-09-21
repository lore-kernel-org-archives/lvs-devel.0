From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 21/84] ipvs: Pass ipvs not net to ip_vs_service_net_cleanup
Date: Mon, 21 Sep 2015 13:01:58 -0500
Message-ID: <1442858581-15869-21-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
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
2.2.1

