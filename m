From: Hans Schillstrom <hans@schillstrom.com>
Subject: [v3 PATCH 4/6] IPVS: rename of netns init and cleanup functions.
Date: Fri, 29 Apr 2011 08:25:32 +0200
Message-ID: <1304058334-17594-5-git-send-email-hans@schillstrom.com>
References: <1304058334-17594-1-git-send-email-hans@schillstrom.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1304058334-17594-1-git-send-email-hans@schillstrom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ja@ssi.bg, horms@verge.net.au, ebiederm@xmission.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans.schillstrom@ericsson.com, Hans Schillstrom <hans@schillstrom.com>

Make it more clear what the functions does,
on request by Julian.

Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
---
 include/net/ip_vs.h              |   26 +++++++++++++-------------
 net/netfilter/ipvs/ip_vs_app.c   |    4 ++--
 net/netfilter/ipvs/ip_vs_conn.c  |    4 ++--
 net/netfilter/ipvs/ip_vs_core.c  |   36 ++++++++++++++++++------------------
 net/netfilter/ipvs/ip_vs_ctl.c   |   20 ++++++++++----------
 net/netfilter/ipvs/ip_vs_est.c   |    4 ++--
 net/netfilter/ipvs/ip_vs_proto.c |    4 ++--
 net/netfilter/ipvs/ip_vs_sync.c  |    4 ++--
 8 files changed, 51 insertions(+), 51 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 86aefed..da2aea9 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1093,19 +1093,19 @@ ip_vs_control_add(struct ip_vs_conn *cp, struct ip_vs_conn *ctl_cp)
 /*
  * IPVS netns init & cleanup functions
  */
-extern int __ip_vs_estimator_init(struct net *net);
-extern int __ip_vs_control_init(struct net *net);
-extern int __ip_vs_protocol_init(struct net *net);
-extern int __ip_vs_app_init(struct net *net);
-extern int __ip_vs_conn_init(struct net *net);
-extern int __ip_vs_sync_init(struct net *net);
-extern void __ip_vs_conn_cleanup(struct net *net);
-extern void __ip_vs_app_cleanup(struct net *net);
-extern void __ip_vs_protocol_cleanup(struct net *net);
-extern void __ip_vs_control_cleanup(struct net *net);
-extern void __ip_vs_estimator_cleanup(struct net *net);
-extern void __ip_vs_sync_cleanup(struct net *net);
-extern void __ip_vs_service_cleanup(struct net *net);
+extern int ip_vs_estimator_net_init(struct net *net);
+extern int ip_vs_control_net_init(struct net *net);
+extern int ip_vs_protocol_net_init(struct net *net);
+extern int ip_vs_app_net_init(struct net *net);
+extern int ip_vs_conn_net_init(struct net *net);
+extern int ip_vs_sync_net_init(struct net *net);
+extern void ip_vs_conn_net_cleanup(struct net *net);
+extern void ip_vs_app_net_cleanup(struct net *net);
+extern void ip_vs_protocol_net_cleanup(struct net *net);
+extern void ip_vs_control_net_cleanup(struct net *net);
+extern void ip_vs_estimator_net_cleanup(struct net *net);
+extern void ip_vs_sync_net_cleanup(struct net *net);
+extern void ip_vs_service_net_cleanup(struct net *net);
 
 /*
  *      IPVS application functions
diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index 51f3af7..81b299d 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -576,7 +576,7 @@ static const struct file_operations ip_vs_app_fops = {
 };
 #endif
 
-int __net_init __ip_vs_app_init(struct net *net)
+int __net_init ip_vs_app_net_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
@@ -585,7 +585,7 @@ int __net_init __ip_vs_app_init(struct net *net)
 	return 0;
 }
 
-void __net_exit __ip_vs_app_cleanup(struct net *net)
+void __net_exit ip_vs_app_net_cleanup(struct net *net)
 {
 	proc_net_remove(net, "ip_vs_app");
 }
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index d3fd91b..b1e7a0c 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1247,7 +1247,7 @@ flush_again:
 /*
  * per netns init and exit
  */
-int __net_init __ip_vs_conn_init(struct net *net)
+int __net_init ip_vs_conn_net_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
@@ -1258,7 +1258,7 @@ int __net_init __ip_vs_conn_init(struct net *net)
 	return 0;
 }
 
-void __net_exit __ip_vs_conn_cleanup(struct net *net)
+void __net_exit ip_vs_conn_net_cleanup(struct net *net)
 {
 	/* flush all the connection entries first */
 	ip_vs_conn_flush(net);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index b9debc9..4582716 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1911,22 +1911,22 @@ static int __net_init __ip_vs_init(struct net *net)
 	atomic_inc(&ipvs_netns_cnt);
 	net->ipvs = ipvs;
 
-	if (__ip_vs_estimator_init(net) < 0)
+	if (ip_vs_estimator_net_init(net) < 0)
 		goto estimator_fail;
 
-	if (__ip_vs_control_init(net) < 0)
+	if (ip_vs_control_net_init(net) < 0)
 		goto control_fail;
 
-	if (__ip_vs_protocol_init(net) < 0)
+	if (ip_vs_protocol_net_init(net) < 0)
 		goto protocol_fail;
 
-	if (__ip_vs_app_init(net) < 0)
+	if (ip_vs_app_net_init(net) < 0)
 		goto app_fail;
 
-	if (__ip_vs_conn_init(net) < 0)
+	if (ip_vs_conn_net_init(net) < 0)
 		goto conn_fail;
 
-	if (__ip_vs_sync_init(net) < 0)
+	if (ip_vs_sync_net_init(net) < 0)
 		goto sync_fail;
 
 	printk(KERN_INFO "IPVS: Creating netns size=%zu id=%d\n",
@@ -1937,27 +1937,27 @@ static int __net_init __ip_vs_init(struct net *net)
  */
 
 sync_fail:
-	__ip_vs_conn_cleanup(net);
+	ip_vs_conn_net_cleanup(net);
 conn_fail:
-	__ip_vs_app_cleanup(net);
+	ip_vs_app_net_cleanup(net);
 app_fail:
-	__ip_vs_protocol_cleanup(net);
+	ip_vs_protocol_net_cleanup(net);
 protocol_fail:
-	__ip_vs_control_cleanup(net);
+	ip_vs_control_net_cleanup(net);
 control_fail:
-	__ip_vs_estimator_cleanup(net);
+	ip_vs_estimator_net_cleanup(net);
 estimator_fail:
 	return -ENOMEM;
 }
 
 static void __net_exit __ip_vs_cleanup(struct net *net)
 {
-	__ip_vs_service_cleanup(net);	/* ip_vs_flush() with locks */
-	__ip_vs_conn_cleanup(net);
-	__ip_vs_app_cleanup(net);
-	__ip_vs_protocol_cleanup(net);
-	__ip_vs_control_cleanup(net);
-	__ip_vs_estimator_cleanup(net);
+	ip_vs_service_net_cleanup(net);	/* ip_vs_flush() with locks */
+	ip_vs_conn_net_cleanup(net);
+	ip_vs_app_net_cleanup(net);
+	ip_vs_protocol_net_cleanup(net);
+	ip_vs_control_net_cleanup(net);
+	ip_vs_estimator_net_cleanup(net);
 	IP_VS_DBG(2, "ipvs netns %d released\n", net_ipvs(net)->gen);
 }
 
@@ -1965,7 +1965,7 @@ static void __net_exit __ip_vs_dev_cleanup(struct net *net)
 {
 	EnterFunction(2);
 	net_ipvs(net)->enable = 0;	/* Disable packet reception */
-	__ip_vs_sync_cleanup(net);
+	ip_vs_sync_net_cleanup(net);
 	LeaveFunction(2);
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index e63b395..64df5bf 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1494,7 +1494,7 @@ static int ip_vs_flush(struct net *net)
  *	Delete service by {netns} in the service table.
  *	Called by __ip_vs_cleanup()
  */
-void __ip_vs_service_cleanup(struct net *net)
+void ip_vs_service_net_cleanup(struct net *net)
 {
 	EnterFunction(2);
 	/* Check for "full" addressed entries */
@@ -1673,7 +1673,7 @@ proc_do_sync_mode(ctl_table *table, int write,
 /*
  *	IPVS sysctl table (under the /proc/sys/net/ipv4/vs/)
  *	Do not change order or insert new entries without
- *	align with netns init in __ip_vs_control_init()
+ *	align with netns init in ip_vs_control_net_init()
  */
 
 static struct ctl_table vs_vars[] = {
@@ -3609,7 +3609,7 @@ static void ip_vs_genl_unregister(void)
  * per netns intit/exit func.
  */
 #ifdef CONFIG_SYSCTL
-int __net_init __ip_vs_control_init_sysctl(struct net *net)
+int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 {
 	int idx;
 	struct netns_ipvs *ipvs = net_ipvs(net);
@@ -3668,7 +3668,7 @@ int __net_init __ip_vs_control_init_sysctl(struct net *net)
 	return 0;
 }
 
-void __net_init __ip_vs_control_cleanup_sysctl(struct net *net)
+void __net_init ip_vs_control_net_cleanup_sysctl(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
@@ -3679,8 +3679,8 @@ void __net_init __ip_vs_control_cleanup_sysctl(struct net *net)
 
 #else
 
-int __net_init __ip_vs_control_init_sysctl(struct net *net) { return 0; }
-void __net_init __ip_vs_control_cleanup_sysctl(struct net *net) { }
+int __net_init ip_vs_control_net_init_sysctl(struct net *net) { return 0; }
+void __net_init ip_vs_control_net_cleanup_sysctl(struct net *net) { }
 
 #endif
 
@@ -3688,7 +3688,7 @@ static struct notifier_block ip_vs_dst_notifier = {
 	.notifier_call = ip_vs_dst_event,
 };
 
-int __net_init __ip_vs_control_init(struct net *net)
+int __net_init ip_vs_control_net_init(struct net *net)
 {
 	int idx;
 	struct netns_ipvs *ipvs = net_ipvs(net);
@@ -3716,7 +3716,7 @@ int __net_init __ip_vs_control_init(struct net *net)
 	proc_net_fops_create(net, "ip_vs_stats_percpu", 0,
 			     &ip_vs_stats_percpu_fops);
 
-	if (__ip_vs_control_init_sysctl(net))
+	if (ip_vs_control_net_init_sysctl(net))
 		goto err;
 
 	return 0;
@@ -3726,13 +3726,13 @@ err:
 	return -ENOMEM;
 }
 
-void __net_exit __ip_vs_control_cleanup(struct net *net)
+void __net_exit ip_vs_control_net_cleanup(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	ip_vs_trash_cleanup(net);
 	ip_vs_stop_estimator(net, &ipvs->tot_stats);
-	__ip_vs_control_cleanup_sysctl(net);
+	ip_vs_control_net_cleanup_sysctl(net);
 	proc_net_remove(net, "ip_vs_stats_percpu");
 	proc_net_remove(net, "ip_vs_stats");
 	proc_net_remove(net, "ip_vs");
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 508cce9..f5d2a01 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -192,7 +192,7 @@ void ip_vs_read_estimator(struct ip_vs_stats_user *dst,
 	dst->outbps = (e->outbps + 0xF) >> 5;
 }
 
-int __net_init __ip_vs_estimator_init(struct net *net)
+int __net_init ip_vs_estimator_net_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
@@ -203,7 +203,7 @@ int __net_init __ip_vs_estimator_init(struct net *net)
 	return 0;
 }
 
-void __net_exit __ip_vs_estimator_cleanup(struct net *net)
+void __net_exit ip_vs_estimator_net_cleanup(struct net *net)
 {
 	del_timer_sync(&net_ipvs(net)->est_timer);
 }
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index eb86028..52d073c 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -316,7 +316,7 @@ ip_vs_tcpudp_debug_packet(int af, struct ip_vs_protocol *pp,
 /*
  * per network name-space init
  */
-int __net_init __ip_vs_protocol_init(struct net *net)
+int __net_init ip_vs_protocol_net_init(struct net *net)
 {
 #ifdef CONFIG_IP_VS_PROTO_TCP
 	register_ip_vs_proto_netns(net, &ip_vs_protocol_tcp);
@@ -336,7 +336,7 @@ int __net_init __ip_vs_protocol_init(struct net *net)
 	return 0;
 }
 
-void __net_exit __ip_vs_protocol_cleanup(struct net *net)
+void __net_exit ip_vs_protocol_net_cleanup(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_proto_data *pd;
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index f31ef18..1036b34 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1663,7 +1663,7 @@ int stop_sync_thread(struct net *net, int state)
 /*
  * Initialize data struct for each netns
  */
-int __net_init __ip_vs_sync_init(struct net *net)
+int __net_init ip_vs_sync_net_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
@@ -1677,7 +1677,7 @@ int __net_init __ip_vs_sync_init(struct net *net)
 	return 0;
 }
 
-void __ip_vs_sync_cleanup(struct net *net)
+void ip_vs_sync_net_cleanup(struct net *net)
 {
 	int retc;
 
-- 
1.7.4

