From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 13/14] IPVS: Add __ip_vs_control_{init,cleanup}_sysctl()
Date: Fri,  4 Feb 2011 18:46:21 +0900
Message-ID: <1296812782-14953-14-git-send-email-horms@verge.net.au>
References: <1296812782-14953-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1296812782-14953-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Simon Horman <horms@verge.net.au>

Break out the portions of __ip_vs_control_init() and
__ip_vs_control_cleanup() where aren't necessary when
CONFIG_SYSCTL is undefined.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |  110 +++++++++++++++++++++++++---------------
 1 files changed, 69 insertions(+), 41 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 60a3686..e06e2af 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -88,6 +88,8 @@ static int __ip_vs_addr_is_local_v6(struct net *net,
 	return 0;
 }
 #endif
+
+#ifdef CONFIG_SYSCTL
 /*
  *	update_defense_level is called from keventd and from sysctl,
  *	so it needs to protect itself from softirqs
@@ -229,6 +231,7 @@ static void defense_work_handler(struct work_struct *work)
 		ip_vs_random_dropentry(ipvs->net);
 	schedule_delayed_work(&ipvs->defense_work, DEFENSE_TIMER_PERIOD);
 }
+#endif
 
 int
 ip_vs_use_count_inc(void)
@@ -1483,7 +1486,7 @@ static int ip_vs_zero_all(struct net *net)
 	return 0;
 }
 
-
+#ifdef CONFIG_SYSCTL
 static int
 proc_do_defense_mode(ctl_table *table, int write,
 		     void __user *buffer, size_t *lenp, loff_t *ppos)
@@ -1505,7 +1508,6 @@ proc_do_defense_mode(ctl_table *table, int write,
 	return rc;
 }
 
-
 static int
 proc_do_sync_threshold(ctl_table *table, int write,
 		       void __user *buffer, size_t *lenp, loff_t *ppos)
@@ -1739,6 +1741,7 @@ const struct ctl_path net_vs_ctl_path[] = {
 	{ }
 };
 EXPORT_SYMBOL_GPL(net_vs_ctl_path);
+#endif
 
 #ifdef CONFIG_PROC_FS
 
@@ -3482,7 +3485,8 @@ static void ip_vs_genl_unregister(void)
 /*
  * per netns intit/exit func.
  */
-int __net_init __ip_vs_control_init(struct net *net)
+#ifdef CONFIG_SYSCTL
+int __net_init __ip_vs_control_init_sysctl(struct net *net)
 {
 	int idx;
 	struct netns_ipvs *ipvs = net_ipvs(net);
@@ -3492,38 +3496,11 @@ int __net_init __ip_vs_control_init(struct net *net)
 	spin_lock_init(&ipvs->dropentry_lock);
 	spin_lock_init(&ipvs->droppacket_lock);
 	spin_lock_init(&ipvs->securetcp_lock);
-	ipvs->rs_lock = __RW_LOCK_UNLOCKED(ipvs->rs_lock);
-
-	/* Initialize rs_table */
-	for (idx = 0; idx < IP_VS_RTAB_SIZE; idx++)
-		INIT_LIST_HEAD(&ipvs->rs_table[idx]);
-
-	INIT_LIST_HEAD(&ipvs->dest_trash);
-	atomic_set(&ipvs->ftpsvc_counter, 0);
-	atomic_set(&ipvs->nullsvc_counter, 0);
-
-	/* procfs stats */
-	ipvs->tot_stats = kzalloc(sizeof(struct ip_vs_stats), GFP_KERNEL);
-	if (ipvs->tot_stats == NULL) {
-		pr_err("%s(): no memory.\n", __func__);
-		return -ENOMEM;
-	}
-	ipvs->cpustats = alloc_percpu(struct ip_vs_cpu_stats);
-	if (!ipvs->cpustats) {
-		pr_err("%s() alloc_percpu failed\n", __func__);
-		goto err_alloc;
-	}
-	spin_lock_init(&ipvs->tot_stats->lock);
-
-	proc_net_fops_create(net, "ip_vs", 0, &ip_vs_info_fops);
-	proc_net_fops_create(net, "ip_vs_stats", 0, &ip_vs_stats_fops);
-	proc_net_fops_create(net, "ip_vs_stats_percpu", 0,
-			     &ip_vs_stats_percpu_fops);
 
 	if (!net_eq(net, &init_net)) {
 		tbl = kmemdup(vs_vars, sizeof(vs_vars), GFP_KERNEL);
 		if (tbl == NULL)
-			goto err_dup;
+			return -ENOMEM;
 	} else
 		tbl = vs_vars;
 	/* Initialize sysctl defaults */
@@ -3552,24 +3529,79 @@ int __net_init __ip_vs_control_init(struct net *net)
 	tbl[idx++].data = &ipvs->sysctl_nat_icmp_send;
 
 
-#ifdef CONFIG_SYSCTL
 	ipvs->sysctl_hdr = register_net_sysctl_table(net, net_vs_ctl_path,
 						     tbl);
 	if (ipvs->sysctl_hdr == NULL) {
 		if (!net_eq(net, &init_net))
 			kfree(tbl);
-		goto err_dup;
+		return -ENOMEM;
 	}
-#endif
 	ip_vs_new_estimator(net, ipvs->tot_stats);
 	ipvs->sysctl_tbl = tbl;
 	/* Schedule defense work */
 	INIT_DELAYED_WORK(&ipvs->defense_work, defense_work_handler);
 	schedule_delayed_work(&ipvs->defense_work, DEFENSE_TIMER_PERIOD);
+
+	return 0;
+}
+
+void __net_init __ip_vs_control_cleanup_sysctl(struct net *net)
+{
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
+	cancel_delayed_work_sync(&ipvs->defense_work);
+	cancel_work_sync(&ipvs->defense_work.work);
+	unregister_net_sysctl_table(ipvs->sysctl_hdr);
+}
+
+#else
+
+int __net_init __ip_vs_control_init_sysctl(struct net *net) { return 0; }
+void __net_init __ip_vs_control_cleanup_sysctl(struct net *net) { }
+
+#endif
+
+int __net_init __ip_vs_control_init(struct net *net)
+{
+	int idx;
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
+	if (__ip_vs_control_init_sysctl(net))
+		return -ENOMEM;
+
+	ipvs->rs_lock = __RW_LOCK_UNLOCKED(ipvs->rs_lock);
+
+	/* Initialize rs_table */
+	for (idx = 0; idx < IP_VS_RTAB_SIZE; idx++)
+		INIT_LIST_HEAD(&ipvs->rs_table[idx]);
+
+	INIT_LIST_HEAD(&ipvs->dest_trash);
+	atomic_set(&ipvs->ftpsvc_counter, 0);
+	atomic_set(&ipvs->nullsvc_counter, 0);
+
+	/* procfs stats */
+	ipvs->tot_stats = kzalloc(sizeof(struct ip_vs_stats), GFP_KERNEL);
+	if (ipvs->tot_stats == NULL) {
+		pr_err("%s(): no memory.\n", __func__);
+		return -ENOMEM;
+	}
+	ipvs->cpustats = alloc_percpu(struct ip_vs_cpu_stats);
+	if (!ipvs->cpustats) {
+		pr_err("%s() alloc_percpu failed\n", __func__);
+		goto err_alloc;
+	}
+	spin_lock_init(&ipvs->tot_stats->lock);
+
+	for (idx = 0; idx < IP_VS_RTAB_SIZE; idx++)
+		INIT_LIST_HEAD(&ipvs->rs_table[idx]);
+
+	proc_net_fops_create(net, "ip_vs", 0, &ip_vs_info_fops);
+	proc_net_fops_create(net, "ip_vs_stats", 0, &ip_vs_stats_fops);
+	proc_net_fops_create(net, "ip_vs_stats_percpu", 0,
+			     &ip_vs_stats_percpu_fops);
+
 	return 0;
 
-err_dup:
-	free_percpu(ipvs->cpustats);
 err_alloc:
 	kfree(ipvs->tot_stats);
 	return -ENOMEM;
@@ -3581,11 +3613,7 @@ static void __net_exit __ip_vs_control_cleanup(struct net *net)
 
 	ip_vs_trash_cleanup(net);
 	ip_vs_kill_estimator(net, ipvs->tot_stats);
-	cancel_delayed_work_sync(&ipvs->defense_work);
-	cancel_work_sync(&ipvs->defense_work.work);
-#ifdef CONFIG_SYSCTL
-	unregister_net_sysctl_table(ipvs->sysctl_hdr);
-#endif
+	__ip_vs_control_cleanup_sysctl(net);
 	proc_net_remove(net, "ip_vs_stats_percpu");
 	proc_net_remove(net, "ip_vs_stats");
 	proc_net_remove(net, "ip_vs");
-- 
1.7.2.3

