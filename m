From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [*v2 PATCH 22/22] IPVS: netns, final patch enabling network name space.
Date: Mon, 13 Dec 2010 14:38:30 +0100
Message-ID: <1292247510-753-23-git-send-email-hans.schillstrom@ericsson.com>
References: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

all init_net removed, (except for some alloc related
that needs to be there)

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 net/netfilter/ipvs/ip_vs_app.c  |    3 ---
 net/netfilter/ipvs/ip_vs_conn.c |    5 -----
 net/netfilter/ipvs/ip_vs_core.c |    4 ----
 net/netfilter/ipvs/ip_vs_ctl.c  |    7 +------
 net/netfilter/ipvs/ip_vs_est.c  |    3 ---
 net/netfilter/ipvs/ip_vs_ftp.c  |    6 ------
 net/netfilter/ipvs/ip_vs_sync.c |    5 -----
 7 files changed, 1 insertions(+), 32 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index af2cd83..f10901b 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -581,9 +581,6 @@ static int __net_init __ip_vs_app_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return -EPERM;
-
 	INIT_LIST_HEAD(&ipvs->app_list);
 	__mutex_init(&ipvs->app_mutex,"ipvs->app_mutex", &ipvs->app_key);
 	proc_net_fops_create(net, "ip_vs_app", 0, &ip_vs_app_fops);
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 0200d97..24a17c8 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1232,8 +1232,6 @@ int __net_init __ip_vs_conn_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return -EPERM;
 	atomic_set(&ipvs->conn_count, 0);
 
 	proc_net_fops_create(net, "ip_vs_conn", 0, &ip_vs_conn_fops);
@@ -1244,9 +1242,6 @@ int __net_init __ip_vs_conn_init(struct net *net)
 /* Cleanup and release all netns related ... */
 static void __net_exit __ip_vs_conn_cleanup(struct net *net)
 {
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return;
-
 	/* flush all the connection entries first */
 	ip_vs_conn_flush(net);
 	proc_net_remove(net, "ip_vs_conn");
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 7441dcd..bc3fca5 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1852,10 +1852,6 @@ static int __net_init  __ip_vs_init(struct net *net)
 {
 	struct netns_ipvs *ipvs;
 
-	if (!net_eq(net, &init_net)) {
-		pr_err("The final patch for enabling netns is missing\n");
-		return -EPERM;
-	}
 	ipvs = (struct netns_ipvs *)net_generic(net, ip_vs_net_id);
 	if (ipvs == NULL) {
 		pr_err("%s(): no memory.\n", __func__);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 3883ec6..f1a1ad8 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2544,6 +2544,7 @@ static struct genl_family ip_vs_genl_family = {
 	.name		= IPVS_GENL_NAME,
 	.version	= IPVS_GENL_VERSION,
 	.maxattr	= IPVS_CMD_MAX,
+	.netnsok        = true,         /* Make ipvsadm to work on netns */
 };
 
 /* Policy used for first-level command attributes */
@@ -3413,9 +3414,6 @@ int __net_init __ip_vs_control_init(struct net *net)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ctl_table *tbl;
 
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return -EPERM;
-
 	atomic_set(&ipvs->dropentry, 0);
 	spin_lock_init(&ipvs->dropentry_lock);
 	spin_lock_init(&ipvs->droppacket_lock);
@@ -3507,9 +3505,6 @@ static void __net_exit __ip_vs_control_cleanup(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return;
-
 	ip_vs_trash_cleanup(net);
 	ip_vs_kill_estimator(net, ipvs->ctl_stats);
 	cancel_rearming_delayed_work(&ipvs->defense_work);
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 576de09..cf8a0f5 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -195,9 +195,6 @@ static int __net_init __ip_vs_estimator_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return -EPERM;
-
 	INIT_LIST_HEAD(&ipvs->est_list);
 	spin_lock_init(&ipvs->est_lock);
 	return 0;
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 78d5980..596b39c 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -412,9 +412,6 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
 	int i, ret;
 	struct ip_vs_app *app = &ip_vs_ftp;
 
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return -EPERM;
-
 	ret = register_ip_vs_app(net, app);
 	if (ret)
 		return ret;
@@ -441,9 +438,6 @@ static void __ip_vs_ftp_exit(struct net *net)
 {
 	struct ip_vs_app *app = &ip_vs_ftp;
 
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return;
-
 	unregister_ip_vs_app(net, app);
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 25b4729..f0e020b 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1653,9 +1653,6 @@ static int __net_init __ip_vs_sync_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return -EPERM;
-
 	INIT_LIST_HEAD(&ipvs->sync_queue);
 	spin_lock_init(&ipvs->sync_lock);
 	spin_lock_init(&ipvs->sync_buff_lock);
@@ -1668,8 +1665,6 @@ static int __net_init __ip_vs_sync_init(struct net *net)
 
 static void __ip_vs_sync_cleanup(struct net *net)
 {
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return;
 	stop_sync_thread(net, IP_VS_STATE_MASTER);
 	stop_sync_thread(net, IP_VS_STATE_BACKUP);
 	return;
-- 
1.7.2.3

