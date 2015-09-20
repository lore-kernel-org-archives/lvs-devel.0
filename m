From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 57/84] ipvs: Pass ipvs not net into ip_vs_app_net_init and ip_vs_app_net_cleanup
Date: Sun, 20 Sep 2015 01:23:13 -0500
Message-ID: <1442730220-32458-57-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip_vs.h             | 4 ++--
 net/netfilter/ipvs/ip_vs_app.c  | 9 +++++----
 net/netfilter/ipvs/ip_vs_core.c | 6 +++---
 3 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 5caafed5af2e..728a670d69fd 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1326,11 +1326,11 @@ ip_vs_control_add(struct ip_vs_conn *cp, struct ip_vs_conn *ctl_cp)
 int ip_vs_estimator_net_init(struct netns_ipvs *ipvs);
 int ip_vs_control_net_init(struct netns_ipvs *ipvs);
 int ip_vs_protocol_net_init(struct net *net);
-int ip_vs_app_net_init(struct net *net);
+int ip_vs_app_net_init(struct netns_ipvs *ipvs);
 int ip_vs_conn_net_init(struct net *net);
 int ip_vs_sync_net_init(struct netns_ipvs *ipvs);
 void ip_vs_conn_net_cleanup(struct net *net);
-void ip_vs_app_net_cleanup(struct net *net);
+void ip_vs_app_net_cleanup(struct netns_ipvs *ipvs);
 void ip_vs_protocol_net_cleanup(struct net *net);
 void ip_vs_control_net_cleanup(struct netns_ipvs *ipvs);
 void ip_vs_estimator_net_cleanup(struct netns_ipvs *ipvs);
diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index cb1246912f0f..0328f7250693 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -603,18 +603,19 @@ static const struct file_operations ip_vs_app_fops = {
 };
 #endif
 
-int __net_init ip_vs_app_net_init(struct net *net)
+int __net_init ip_vs_app_net_init(struct netns_ipvs *ipvs)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct net *net = ipvs->net;
 
 	INIT_LIST_HEAD(&ipvs->app_list);
 	proc_create("ip_vs_app", 0, net->proc_net, &ip_vs_app_fops);
 	return 0;
 }
 
-void __net_exit ip_vs_app_net_cleanup(struct net *net)
+void __net_exit ip_vs_app_net_cleanup(struct netns_ipvs *ipvs)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct net *net = ipvs->net;
+
 	unregister_ip_vs_app(ipvs, NULL /* all */);
 	remove_proc_entry("ip_vs_app", net->proc_net);
 }
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index ec6f022fba6a..01398eb757fa 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2081,7 +2081,7 @@ static int __net_init __ip_vs_init(struct net *net)
 	if (ip_vs_protocol_net_init(net) < 0)
 		goto protocol_fail;
 
-	if (ip_vs_app_net_init(net) < 0)
+	if (ip_vs_app_net_init(ipvs) < 0)
 		goto app_fail;
 
 	if (ip_vs_conn_net_init(net) < 0)
@@ -2100,7 +2100,7 @@ static int __net_init __ip_vs_init(struct net *net)
 sync_fail:
 	ip_vs_conn_net_cleanup(net);
 conn_fail:
-	ip_vs_app_net_cleanup(net);
+	ip_vs_app_net_cleanup(ipvs);
 app_fail:
 	ip_vs_protocol_net_cleanup(net);
 protocol_fail:
@@ -2118,7 +2118,7 @@ static void __net_exit __ip_vs_cleanup(struct net *net)
 
 	ip_vs_service_net_cleanup(ipvs);	/* ip_vs_flush() with locks */
 	ip_vs_conn_net_cleanup(net);
-	ip_vs_app_net_cleanup(net);
+	ip_vs_app_net_cleanup(ipvs);
 	ip_vs_protocol_net_cleanup(net);
 	ip_vs_control_net_cleanup(ipvs);
 	ip_vs_estimator_net_cleanup(ipvs);
-- 
2.2.1

