From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 51/84] ipvs: Pass ipvs not net to ip_vs_estimator_net_init and ip_vs_estimator_cleanup
Date: Sun, 20 Sep 2015 01:23:07 -0500
Message-ID: <1442730220-32458-51-git-send-email-ebiederm@xmission.com>
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

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip_vs.h             | 4 ++--
 net/netfilter/ipvs/ip_vs_core.c | 6 +++---
 net/netfilter/ipvs/ip_vs_est.c  | 8 +++-----
 3 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 38c1fca0c1a7..02734eaae679 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1323,7 +1323,7 @@ ip_vs_control_add(struct ip_vs_conn *cp, struct ip_vs_conn *ctl_cp)
 }
 
 /* IPVS netns init & cleanup functions */
-int ip_vs_estimator_net_init(struct net *net);
+int ip_vs_estimator_net_init(struct netns_ipvs *ipvs);
 int ip_vs_control_net_init(struct netns_ipvs *ipvs);
 int ip_vs_protocol_net_init(struct net *net);
 int ip_vs_app_net_init(struct net *net);
@@ -1333,7 +1333,7 @@ void ip_vs_conn_net_cleanup(struct net *net);
 void ip_vs_app_net_cleanup(struct net *net);
 void ip_vs_protocol_net_cleanup(struct net *net);
 void ip_vs_control_net_cleanup(struct netns_ipvs *ipvs);
-void ip_vs_estimator_net_cleanup(struct net *net);
+void ip_vs_estimator_net_cleanup(struct netns_ipvs *ipvs);
 void ip_vs_sync_net_cleanup(struct netns_ipvs *ipvs);
 void ip_vs_service_net_cleanup(struct netns_ipvs *ipvs);
 
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index b5f451f20f52..ec6f022fba6a 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2072,7 +2072,7 @@ static int __net_init __ip_vs_init(struct net *net)
 	atomic_inc(&ipvs_netns_cnt);
 	net->ipvs = ipvs;
 
-	if (ip_vs_estimator_net_init(net) < 0)
+	if (ip_vs_estimator_net_init(ipvs) < 0)
 		goto estimator_fail;
 
 	if (ip_vs_control_net_init(ipvs) < 0)
@@ -2106,7 +2106,7 @@ app_fail:
 protocol_fail:
 	ip_vs_control_net_cleanup(ipvs);
 control_fail:
-	ip_vs_estimator_net_cleanup(net);
+	ip_vs_estimator_net_cleanup(ipvs);
 estimator_fail:
 	net->ipvs = NULL;
 	return -ENOMEM;
@@ -2121,7 +2121,7 @@ static void __net_exit __ip_vs_cleanup(struct net *net)
 	ip_vs_app_net_cleanup(net);
 	ip_vs_protocol_net_cleanup(net);
 	ip_vs_control_net_cleanup(ipvs);
-	ip_vs_estimator_net_cleanup(net);
+	ip_vs_estimator_net_cleanup(ipvs);
 	IP_VS_DBG(2, "ipvs netns %d released\n", ipvs->gen);
 	net->ipvs = NULL;
 }
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index c86dc456c8f4..457c6c193e13 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -188,10 +188,8 @@ void ip_vs_read_estimator(struct ip_vs_kstats *dst, struct ip_vs_stats *stats)
 	dst->outbps = (e->outbps + 0xF) >> 5;
 }
 
-int __net_init ip_vs_estimator_net_init(struct net *net)
+int __net_init ip_vs_estimator_net_init(struct netns_ipvs *ipvs)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
-
 	INIT_LIST_HEAD(&ipvs->est_list);
 	spin_lock_init(&ipvs->est_lock);
 	setup_timer(&ipvs->est_timer, estimation_timer, (unsigned long)ipvs);
@@ -199,7 +197,7 @@ int __net_init ip_vs_estimator_net_init(struct net *net)
 	return 0;
 }
 
-void __net_exit ip_vs_estimator_net_cleanup(struct net *net)
+void __net_exit ip_vs_estimator_net_cleanup(struct netns_ipvs *ipvs)
 {
-	del_timer_sync(&net_ipvs(net)->est_timer);
+	del_timer_sync(&ipvs->est_timer);
 }
-- 
2.2.1
