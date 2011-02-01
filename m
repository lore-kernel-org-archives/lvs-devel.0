From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 4/4] IPVS: Allow compilation with CONFIG_SYSCTL disabled
Date: Tue,  1 Feb 2011 11:14:15 +1100
Message-ID: <1296519255-10602-5-git-send-email-horms@verge.net.au>
References: <1296519255-10602-1-git-send-email-horms@verge.net.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1296519255-10602-1-git-send-email-horms@verge.net.au>
Sender: linux-next-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Randy Dunlap <randy.dunlap@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Hans Schillstrom <hans@schillstrom.com>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

This is a rather naieve approach to allowing PVS to compile with
CONFIG_SYSCTL disabled.  I am working on a more comprehensive patch which
will remove compilation of all sysctl-related IPVS code when CONFIG_SYSCTL
is disabled.

Cc: Hans Schillstrom <hans@schillstrom.com>
Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c   |   14 +++++++++-----
 net/netfilter/ipvs/ip_vs_lblc.c  |   20 ++++++++++----------
 net/netfilter/ipvs/ip_vs_lblcr.c |   20 ++++++++++----------
 3 files changed, 29 insertions(+), 25 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index d7c2fa8..c73b0c8 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3552,10 +3552,15 @@ int __net_init __ip_vs_control_init(struct net *net)
 	tbl[idx++].data = &ipvs->sysctl_nat_icmp_send;
 
 
+#ifdef CONFIG_SYSCTL
 	ipvs->sysctl_hdr = register_net_sysctl_table(net, net_vs_ctl_path,
 						     tbl);
-	if (ipvs->sysctl_hdr == NULL)
-		goto err_reg;
+	if (ipvs->sysctl_hdr == NULL) {
+		if (!net_eq(net, &init_net))
+			kfree(tbl);
+		goto err_dup;
+	}
+#endif
 	ip_vs_new_estimator(net, ipvs->tot_stats);
 	ipvs->sysctl_tbl = tbl;
 	/* Schedule defense work */
@@ -3563,9 +3568,6 @@ int __net_init __ip_vs_control_init(struct net *net)
 	schedule_delayed_work(&ipvs->defense_work, DEFENSE_TIMER_PERIOD);
 	return 0;
 
-err_reg:
-	if (!net_eq(net, &init_net))
-		kfree(tbl);
 err_dup:
 	free_percpu(ipvs->cpustats);
 err_alloc:
@@ -3581,7 +3583,9 @@ static void __net_exit __ip_vs_control_cleanup(struct net *net)
 	ip_vs_kill_estimator(net, ipvs->tot_stats);
 	cancel_delayed_work_sync(&ipvs->defense_work);
 	cancel_work_sync(&ipvs->defense_work.work);
+#ifdef CONFIG_SYSCTL
 	unregister_net_sysctl_table(ipvs->sysctl_hdr);
+#endif
 	proc_net_remove(net, "ip_vs_stats_percpu");
 	proc_net_remove(net, "ip_vs_stats");
 	proc_net_remove(net, "ip_vs");
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index d5bec33..00b5ffa 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -554,33 +554,33 @@ static int __net_init __ip_vs_lblc_init(struct net *net)
 						sizeof(vs_vars_table),
 						GFP_KERNEL);
 		if (ipvs->lblc_ctl_table == NULL)
-			goto err_dup;
+			return -ENOMEM;
 	} else
 		ipvs->lblc_ctl_table = vs_vars_table;
 	ipvs->sysctl_lblc_expiration = 24*60*60*HZ;
 	ipvs->lblc_ctl_table[0].data = &ipvs->sysctl_lblc_expiration;
 
+#ifdef CONFIG_SYSCTL
 	ipvs->lblc_ctl_header =
 		register_net_sysctl_table(net, net_vs_ctl_path,
 					  ipvs->lblc_ctl_table);
-	if (!ipvs->lblc_ctl_header)
-		goto err_reg;
+	if (!ipvs->lblc_ctl_header) {
+		if (!net_eq(net, &init_net))
+			kfree(ipvs->lblc_ctl_table);
+		return -ENOMEM;
+	}
+#endif
 
 	return 0;
-
-err_reg:
-	if (!net_eq(net, &init_net))
-		kfree(ipvs->lblc_ctl_table);
-
-err_dup:
-	return -ENOMEM;
 }
 
 static void __net_exit __ip_vs_lblc_exit(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
+#ifdef CONFIG_SYSCTL
 	unregister_net_sysctl_table(ipvs->lblc_ctl_header);
+#endif
 
 	if (!net_eq(net, &init_net))
 		kfree(ipvs->lblc_ctl_table);
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 61ae8cf..bfa25f1 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -754,33 +754,33 @@ static int __net_init __ip_vs_lblcr_init(struct net *net)
 						sizeof(vs_vars_table),
 						GFP_KERNEL);
 		if (ipvs->lblcr_ctl_table == NULL)
-			goto err_dup;
+			return -ENOMEM;
 	} else
 		ipvs->lblcr_ctl_table = vs_vars_table;
 	ipvs->sysctl_lblcr_expiration = 24*60*60*HZ;
 	ipvs->lblcr_ctl_table[0].data = &ipvs->sysctl_lblcr_expiration;
 
+#ifdef CONFIG_SYSCTL
 	ipvs->lblcr_ctl_header =
 		register_net_sysctl_table(net, net_vs_ctl_path,
 					  ipvs->lblcr_ctl_table);
-	if (!ipvs->lblcr_ctl_header)
-		goto err_reg;
+	if (!ipvs->lblcr_ctl_header) {
+		if (!net_eq(net, &init_net))
+			kfree(ipvs->lblcr_ctl_table);
+		return -ENOMEM;
+	}
+#endif
 
 	return 0;
-
-err_reg:
-	if (!net_eq(net, &init_net))
-		kfree(ipvs->lblcr_ctl_table);
-
-err_dup:
-	return -ENOMEM;
 }
 
 static void __net_exit __ip_vs_lblcr_exit(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
+#ifdef CONFIG_SYSCTL
 	unregister_net_sysctl_table(ipvs->lblcr_ctl_header);
+#endif
 
 	if (!net_eq(net, &init_net))
 		kfree(ipvs->lblcr_ctl_table);
-- 
1.7.2.3
