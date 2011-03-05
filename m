From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 17/18] IPVS: Add __ip_vs_control_{init,cleanup}_sysctl()
Date: Sun,  6 Mar 2011 08:45:59 +0900
Message-ID: <1299368760-14271-18-git-send-email-horms@verge.net.au>
References: <1299368760-14271-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1299368760-14271-1-git-send-email-horms@verge.net.au>
Sender: netfilter-owner@vger.kernel.org
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
 net/netfilter/ipvs/ip_vs_ctl.c |   98 +++++++++++++++++++++++++---------------
 1 files changed, 62 insertions(+), 36 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 8cdbf91..4ddae3d 100644
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
@@ -1502,7 +1505,7 @@ static int ip_vs_zero_all(struct net *net)
 	return 0;
 }
 
-
+#ifdef CONFIG_SYSCTL
 static int
 proc_do_defense_mode(ctl_table *table, int write,
 		     void __user *buffer, size_t *lenp, loff_t *ppos)
@@ -1524,7 +1527,6 @@ proc_do_defense_mode(ctl_table *table, int write,
 	return rc;
 }
 
-
 static int
 proc_do_sync_threshold(ctl_table *table, int write,
 		       void __user *buffer, size_t *lenp, loff_t *ppos)
@@ -1758,6 +1760,7 @@ const struct ctl_path net_vs_ctl_path[] = {
 	{ }
 };
 EXPORT_SYMBOL_GPL(net_vs_ctl_path);
+#endif
 
 #ifdef CONFIG_PROC_FS
 
@@ -3511,7 +3514,8 @@ static void ip_vs_genl_unregister(void)
 /*
  * per netns intit/exit func.
  */
-int __net_init __ip_vs_control_init(struct net *net)
+#ifdef CONFIG_SYSCTL
+int __net_init __ip_vs_control_init_sysctl(struct net *net)
 {
 	int idx;
 	struct netns_ipvs *ipvs = net_ipvs(net);
@@ -3521,33 +3525,11 @@ int __net_init __ip_vs_control_init(struct net *net)
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
-	ipvs->tot_stats.cpustats = alloc_percpu(struct ip_vs_cpu_stats);
-	if (!ipvs->tot_stats.cpustats) {
-		pr_err("%s() alloc_percpu failed\n", __func__);
-		goto err_alloc;
-	}
-	spin_lock_init(&ipvs->tot_stats.lock);
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
@@ -3576,25 +3558,73 @@ int __net_init __ip_vs_control_init(struct net *net)
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
 	ip_vs_new_estimator(net, &ipvs->tot_stats);
 	ipvs->sysctl_tbl = tbl;
 	/* Schedule defense work */
 	INIT_DELAYED_WORK(&ipvs->defense_work, defense_work_handler);
 	schedule_delayed_work(&ipvs->defense_work, DEFENSE_TIMER_PERIOD);
+
 	return 0;
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
 
-err_dup:
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
+	ipvs->tot_stats.cpustats = alloc_percpu(struct ip_vs_cpu_stats);
+	if (ipvs->tot_stats.cpustats) {
+		pr_err("%s(): alloc_percpu.\n", __func__);
+		return -ENOMEM;
+	}
+	spin_lock_init(&ipvs->tot_stats.lock);
+
+	proc_net_fops_create(net, "ip_vs", 0, &ip_vs_info_fops);
+	proc_net_fops_create(net, "ip_vs_stats", 0, &ip_vs_stats_fops);
+	proc_net_fops_create(net, "ip_vs_stats_percpu", 0,
+			     &ip_vs_stats_percpu_fops);
+
+	if (__ip_vs_control_init_sysctl(net))
+		goto err;
+
+	return 0;
+
+err:
 	free_percpu(ipvs->tot_stats.cpustats);
-err_alloc:
 	return -ENOMEM;
 }
 
@@ -3604,11 +3634,7 @@ static void __net_exit __ip_vs_control_cleanup(struct net *net)
 
 	ip_vs_trash_cleanup(net);
 	ip_vs_kill_estimator(net, &ipvs->tot_stats);
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

