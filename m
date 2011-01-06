From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 22/22] IPVS: netns, final patch enabling network name space.
Date: Thu,  6 Jan 2011 15:16:18 +0900
Message-ID: <1294294578-8601-23-git-send-email-horms@verge.net.au>
References: <1294294578-8601-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1294294578-8601-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Patrick McHardy <kaber@trash.net>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

all init_net removed, (except for some alloc related
that needs to be there)

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
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
index 53ac696..39d2a30 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -582,9 +582,6 @@ static int __net_init __ip_vs_app_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return -EPERM;
-
 	INIT_LIST_HEAD(&ipvs->app_list);
 	__mutex_init(&ipvs->app_mutex, "ipvs->app_mutex", &ipvs->app_key);
 	proc_net_fops_create(net, "ip_vs_app", 0, &ip_vs_app_fops);
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 28bdaf7..83233fe 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1234,8 +1234,6 @@ int __net_init __ip_vs_conn_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return -EPERM;
 	atomic_set(&ipvs->conn_count, 0);
 
 	proc_net_fops_create(net, "ip_vs_conn", 0, &ip_vs_conn_fops);
@@ -1245,9 +1243,6 @@ int __net_init __ip_vs_conn_init(struct net *net)
 
 static void __net_exit __ip_vs_conn_cleanup(struct net *net)
 {
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return;
-
 	/* flush all the connection entries first */
 	ip_vs_conn_flush(net);
 	proc_net_remove(net, "ip_vs_conn");
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 9e10c7a..f36a84f 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1877,10 +1877,6 @@ static int __net_init __ip_vs_init(struct net *net)
 {
 	struct netns_ipvs *ipvs;
 
-	if (!net_eq(net, &init_net)) {
-		pr_err("The final patch for enabling netns is missing\n");
-		return -EPERM;
-	}
 	ipvs = net_generic(net, ip_vs_net_id);
 	if (ipvs == NULL) {
 		pr_err("%s(): no memory.\n", __func__);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index d37a6d8..4aa8da7 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2619,6 +2619,7 @@ static struct genl_family ip_vs_genl_family = {
 	.name		= IPVS_GENL_NAME,
 	.version	= IPVS_GENL_VERSION,
 	.maxattr	= IPVS_CMD_MAX,
+	.netnsok        = true,         /* Make ipvsadm to work on netns */
 };
 
 /* Policy used for first-level command attributes */
@@ -3485,9 +3486,6 @@ int __net_init __ip_vs_control_init(struct net *net)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ctl_table *tbl;
 
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return -EPERM;
-
 	atomic_set(&ipvs->dropentry, 0);
 	spin_lock_init(&ipvs->dropentry_lock);
 	spin_lock_init(&ipvs->droppacket_lock);
@@ -3580,9 +3578,6 @@ static void __net_exit __ip_vs_control_cleanup(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return;
-
 	ip_vs_trash_cleanup(net);
 	ip_vs_kill_estimator(net, ipvs->tot_stats);
 	cancel_rearming_delayed_work(&ipvs->defense_work);
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index d13616b..f560a05 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -203,9 +203,6 @@ static int __net_init __ip_vs_estimator_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return -EPERM;
-
 	INIT_LIST_HEAD(&ipvs->est_list);
 	spin_lock_init(&ipvs->est_lock);
 	setup_timer(&ipvs->est_timer, estimation_timer, (unsigned long)net);
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 6a04f9a..6b5dd6d 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -413,9 +413,6 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
 	int i, ret;
 	struct ip_vs_app *app = &ip_vs_ftp;
 
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return -EPERM;
-
 	ret = register_ip_vs_app(net, app);
 	if (ret)
 		return ret;
@@ -442,9 +439,6 @@ static void __ip_vs_ftp_exit(struct net *net)
 {
 	struct ip_vs_app *app = &ip_vs_ftp;
 
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return;
-
 	unregister_ip_vs_app(net, app);
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index a333831..0a768c4 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1659,9 +1659,6 @@ static int __net_init __ip_vs_sync_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return -EPERM;
-
 	INIT_LIST_HEAD(&ipvs->sync_queue);
 	spin_lock_init(&ipvs->sync_lock);
 	spin_lock_init(&ipvs->sync_buff_lock);
@@ -1674,8 +1671,6 @@ static int __net_init __ip_vs_sync_init(struct net *net)
 
 static void __ip_vs_sync_cleanup(struct net *net)
 {
-	if (!net_eq(net, &init_net))	/* netns not enabled yet */
-		return;
 	stop_sync_thread(net, IP_VS_STATE_MASTER);
 	stop_sync_thread(net, IP_VS_STATE_BACKUP);
 }
-- 
1.7.2.3

