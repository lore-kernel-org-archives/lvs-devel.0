From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 01/22] IPVS: netns, add basic init per netns.
Date: Thu, 13 Jan 2011 10:52:47 +0900
Message-ID: <1294883588-5683-2-git-send-email-horms@verge.net.au>
References: <1294883588-5683-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1294883588-5683-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

Preparation for network name-space init, in this stage
some empty functions exists.

In most files there is a check if it is root ns i.e. init_net
if (!net_eq(net, &init_net))
        return ...
this will be removed by the last patch, when enabling name-space.

*v3
 ip_vs_conn.c merge error corrected.
 net_ipvs #ifdef removed as sugested by Jan Engelhardt

[ horms@verge.net.au: Removed whitespace-change-only hunks ]
Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h              |   11 ++++++
 include/net/net_namespace.h      |    2 +
 include/net/netns/ip_vs.h        |   25 +++++++++++++++
 net/netfilter/ipvs/ip_vs_app.c   |   28 ++++++++++++++--
 net/netfilter/ipvs/ip_vs_conn.c  |   34 +++++++++++++++++---
 net/netfilter/ipvs/ip_vs_core.c  |   63 ++++++++++++++++++++++++++++++++++++-
 net/netfilter/ipvs/ip_vs_ctl.c   |   49 ++++++++++++++++++++++++-----
 net/netfilter/ipvs/ip_vs_est.c   |   20 +++++++++++-
 net/netfilter/ipvs/ip_vs_ftp.c   |   34 ++++++++++++++++++--
 net/netfilter/ipvs/ip_vs_lblc.c  |   37 ++++++++++++++++++++--
 net/netfilter/ipvs/ip_vs_lblcr.c |   38 ++++++++++++++++++++--
 net/netfilter/ipvs/ip_vs_proto.c |   19 +++++++++++
 net/netfilter/ipvs/ip_vs_sync.c  |   27 ++++++++++++++++
 13 files changed, 354 insertions(+), 33 deletions(-)
 create mode 100644 include/net/netns/ip_vs.h

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index d858264..c1c2ece 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -28,6 +28,15 @@
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 #include <net/netfilter/nf_conntrack.h>
 #endif
+#include <net/net_namespace.h>		/* Netw namespace */
+
+/*
+ * Generic access of ipvs struct
+ */
+static inline struct netns_ipvs *net_ipvs(struct net* net)
+{
+	return net->ipvs;
+}
 
 /* Connections' size value needed by ip_vs_ctl.c */
 extern int ip_vs_conn_tab_size;
@@ -922,6 +931,8 @@ extern char ip_vs_backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
 extern int start_sync_thread(int state, char *mcast_ifn, __u8 syncid);
 extern int stop_sync_thread(int state);
 extern void ip_vs_sync_conn(struct ip_vs_conn *cp);
+extern int ip_vs_sync_init(void);
+extern void ip_vs_sync_cleanup(void);
 
 
 /*
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 1bf812b..b3b4a34 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -20,6 +20,7 @@
 #include <net/netns/conntrack.h>
 #endif
 #include <net/netns/xfrm.h>
+#include <net/netns/ip_vs.h>
 
 struct proc_dir_entry;
 struct net_device;
@@ -94,6 +95,7 @@ struct net {
 #ifdef CONFIG_XFRM
 	struct netns_xfrm	xfrm;
 #endif
+	struct netns_ipvs	*ipvs;
 };
 
 
diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
new file mode 100644
index 0000000..12fe840
--- /dev/null
+++ b/include/net/netns/ip_vs.h
@@ -0,0 +1,25 @@
+/*
+ *  IP Virtual Server
+ *  Data structure for network namspace
+ *
+ */
+
+#ifndef IP_VS_H_
+#define IP_VS_H_
+
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/list_nulls.h>
+#include <linux/ip_vs.h>
+#include <asm/atomic.h>
+#include <linux/in.h>
+
+struct ip_vs_stats;
+struct ip_vs_sync_buff;
+struct ctl_table_header;
+
+struct netns_ipvs {
+	int			gen;		/* Generation */
+};
+
+#endif /* IP_VS_H_ */
diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index a475ede..40b09cc 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -569,15 +569,35 @@ static const struct file_operations ip_vs_app_fops = {
 };
 #endif
 
-int __init ip_vs_app_init(void)
+static int __net_init __ip_vs_app_init(struct net *net)
 {
-	/* we will replace it with proc_net_ipvs_create() soon */
-	proc_net_fops_create(&init_net, "ip_vs_app", 0, &ip_vs_app_fops);
+	if (!net_eq(net, &init_net))	/* netns not enabled yet */
+		return -EPERM;
+
+	proc_net_fops_create(net, "ip_vs_app", 0, &ip_vs_app_fops);
 	return 0;
 }
 
+static void __net_exit __ip_vs_app_cleanup(struct net *net)
+{
+	proc_net_remove(net, "ip_vs_app");
+}
+
+static struct pernet_operations ip_vs_app_ops = {
+	.init = __ip_vs_app_init,
+	.exit = __ip_vs_app_cleanup,
+};
+
+int __init ip_vs_app_init(void)
+{
+	int rv;
+
+	rv = register_pernet_subsys(&ip_vs_app_ops);
+	return rv;
+}
+
 
 void ip_vs_app_cleanup(void)
 {
-	proc_net_remove(&init_net, "ip_vs_app");
+	unregister_pernet_subsys(&ip_vs_app_ops);
 }
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 66e4662..7c1b502 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1201,11 +1201,36 @@ static void ip_vs_conn_flush(void)
 		goto flush_again;
 	}
 }
+/*
+ * per netns init and exit
+ */
+int __net_init __ip_vs_conn_init(struct net *net)
+{
+	if (!net_eq(net, &init_net))	/* netns not enabled yet */
+		return -EPERM;
 
+	proc_net_fops_create(net, "ip_vs_conn", 0, &ip_vs_conn_fops);
+	proc_net_fops_create(net, "ip_vs_conn_sync", 0, &ip_vs_conn_sync_fops);
+	return 0;
+}
+
+static void __net_exit __ip_vs_conn_cleanup(struct net *net)
+{
+	if (!net_eq(net, &init_net))	/* netns not enabled yet */
+		return;
+
+	proc_net_remove(net, "ip_vs_conn");
+	proc_net_remove(net, "ip_vs_conn_sync");
+}
+static struct pernet_operations ipvs_conn_ops = {
+	.init = __ip_vs_conn_init,
+	.exit = __ip_vs_conn_cleanup,
+};
 
 int __init ip_vs_conn_init(void)
 {
 	int idx;
+	int retc;
 
 	/* Compute size and mask */
 	ip_vs_conn_tab_size = 1 << ip_vs_conn_tab_bits;
@@ -1243,24 +1268,21 @@ int __init ip_vs_conn_init(void)
 		rwlock_init(&__ip_vs_conntbl_lock_array[idx].l);
 	}
 
-	proc_net_fops_create(&init_net, "ip_vs_conn", 0, &ip_vs_conn_fops);
-	proc_net_fops_create(&init_net, "ip_vs_conn_sync", 0, &ip_vs_conn_sync_fops);
+	retc = register_pernet_subsys(&ipvs_conn_ops);
 
 	/* calculate the random value for connection hash */
 	get_random_bytes(&ip_vs_conn_rnd, sizeof(ip_vs_conn_rnd));
 
-	return 0;
+	return retc;
 }
 
-
 void ip_vs_conn_cleanup(void)
 {
+	unregister_pernet_subsys(&ipvs_conn_ops);
 	/* flush all the connection entries first */
 	ip_vs_conn_flush();
 
 	/* Release the empty cache */
 	kmem_cache_destroy(ip_vs_conn_cachep);
-	proc_net_remove(&init_net, "ip_vs_conn");
-	proc_net_remove(&init_net, "ip_vs_conn_sync");
 	vfree(ip_vs_conn_tab);
 }
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 5287771..206f40c 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -41,6 +41,7 @@
 #include <net/icmp.h>                   /* for icmp_send */
 #include <net/route.h>
 #include <net/ip6_checksum.h>
+#include <net/netns/generic.h>		/* net_generic() */
 
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
@@ -68,6 +69,12 @@ EXPORT_SYMBOL(ip_vs_conn_put);
 EXPORT_SYMBOL(ip_vs_get_debug_level);
 #endif
 
+int ip_vs_net_id __read_mostly;
+#ifdef IP_VS_GENERIC_NETNS
+EXPORT_SYMBOL(ip_vs_net_id);
+#endif
+/* netns cnt used for uniqueness */
+static atomic_t ipvs_netns_cnt = ATOMIC_INIT(0);
 
 /* ID used in ICMP lookups */
 #define icmp_id(icmph)          (((icmph)->un).echo.id)
@@ -1813,6 +1820,44 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 #endif
 };
 
+/*
+ *	Initialize IP Virtual Server netns mem.
+ */
+static int __net_init __ip_vs_init(struct net *net)
+{
+	struct netns_ipvs *ipvs;
+
+	if (!net_eq(net, &init_net)) {
+		pr_err("The final patch for enabling netns is missing\n");
+		return -EPERM;
+	}
+	ipvs = net_generic(net, ip_vs_net_id);
+	if (ipvs == NULL) {
+		pr_err("%s(): no memory.\n", __func__);
+		return -ENOMEM;
+	}
+	/* Counters used for creating unique names */
+	ipvs->gen = atomic_read(&ipvs_netns_cnt);
+	atomic_inc(&ipvs_netns_cnt);
+	net->ipvs = ipvs;
+	printk(KERN_INFO "IPVS: Creating netns size=%lu id=%d\n",
+			 sizeof(struct netns_ipvs), ipvs->gen);
+	return 0;
+}
+
+static void __net_exit __ip_vs_cleanup(struct net *net)
+{
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
+	IP_VS_DBG(10, "ipvs netns %d released\n", ipvs->gen);
+}
+
+static struct pernet_operations ipvs_core_ops = {
+	.init = __ip_vs_init,
+	.exit = __ip_vs_cleanup,
+	.id   = &ip_vs_net_id,
+	.size = sizeof(struct netns_ipvs),
+};
 
 /*
  *	Initialize IP Virtual Server
@@ -1821,8 +1866,11 @@ static int __init ip_vs_init(void)
 {
 	int ret;
 
-	ip_vs_estimator_init();
+	ret = register_pernet_subsys(&ipvs_core_ops);	/* Alloc ip_vs struct */
+	if (ret < 0)
+		return ret;
 
+	ip_vs_estimator_init();
 	ret = ip_vs_control_init();
 	if (ret < 0) {
 		pr_err("can't setup control.\n");
@@ -1843,15 +1891,23 @@ static int __init ip_vs_init(void)
 		goto cleanup_app;
 	}
 
+	ret = ip_vs_sync_init();
+	if (ret < 0) {
+		pr_err("can't setup sync data.\n");
+		goto cleanup_conn;
+	}
+
 	ret = nf_register_hooks(ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
 	if (ret < 0) {
 		pr_err("can't register hooks.\n");
-		goto cleanup_conn;
+		goto cleanup_sync;
 	}
 
 	pr_info("ipvs loaded.\n");
 	return ret;
 
+cleanup_sync:
+	ip_vs_sync_cleanup();
   cleanup_conn:
 	ip_vs_conn_cleanup();
   cleanup_app:
@@ -1861,17 +1917,20 @@ static int __init ip_vs_init(void)
 	ip_vs_control_cleanup();
   cleanup_estimator:
 	ip_vs_estimator_cleanup();
+	unregister_pernet_subsys(&ipvs_core_ops);	/* free ip_vs struct */
 	return ret;
 }
 
 static void __exit ip_vs_cleanup(void)
 {
 	nf_unregister_hooks(ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
+	ip_vs_sync_cleanup();
 	ip_vs_conn_cleanup();
 	ip_vs_app_cleanup();
 	ip_vs_protocol_cleanup();
 	ip_vs_control_cleanup();
 	ip_vs_estimator_cleanup();
+	unregister_pernet_subsys(&ipvs_core_ops);	/* free ip_vs struct */
 	pr_info("ipvs unloaded.\n");
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index ca49e92..ceeef43 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3406,6 +3406,42 @@ static void ip_vs_genl_unregister(void)
 
 /* End of Generic Netlink interface definitions */
 
+/*
+ * per netns intit/exit func.
+ */
+int __net_init __ip_vs_control_init(struct net *net)
+{
+	if (!net_eq(net, &init_net))	/* netns not enabled yet */
+		return -EPERM;
+
+	proc_net_fops_create(net, "ip_vs", 0, &ip_vs_info_fops);
+	proc_net_fops_create(net, "ip_vs_stats", 0, &ip_vs_stats_fops);
+	sysctl_header = register_net_sysctl_table(net, net_vs_ctl_path,
+						  vs_vars);
+	if (sysctl_header == NULL)
+		goto err_reg;
+	ip_vs_new_estimator(&ip_vs_stats);
+	return 0;
+
+err_reg:
+	return -ENOMEM;
+}
+
+static void __net_exit __ip_vs_control_cleanup(struct net *net)
+{
+	if (!net_eq(net, &init_net))	/* netns not enabled yet */
+		return;
+
+	ip_vs_kill_estimator(&ip_vs_stats);
+	unregister_net_sysctl_table(sysctl_header);
+	proc_net_remove(net, "ip_vs_stats");
+	proc_net_remove(net, "ip_vs");
+}
+
+static struct pernet_operations ipvs_control_ops = {
+	.init = __ip_vs_control_init,
+	.exit = __ip_vs_control_cleanup,
+};
 
 int __init ip_vs_control_init(void)
 {
@@ -3437,12 +3473,9 @@ int __init ip_vs_control_init(void)
 		return ret;
 	}
 
-	proc_net_fops_create(&init_net, "ip_vs", 0, &ip_vs_info_fops);
-	proc_net_fops_create(&init_net, "ip_vs_stats",0, &ip_vs_stats_fops);
-
-	sysctl_header = register_sysctl_paths(net_vs_ctl_path, vs_vars);
-
-	ip_vs_new_estimator(&ip_vs_stats);
+	ret = register_pernet_subsys(&ipvs_control_ops);
+	if (ret)
+		return ret;
 
 	/* Hook the defense timer */
 	schedule_delayed_work(&defense_work, DEFENSE_TIMER_PERIOD);
@@ -3459,9 +3492,7 @@ void ip_vs_control_cleanup(void)
 	cancel_delayed_work_sync(&defense_work);
 	cancel_work_sync(&defense_work.work);
 	ip_vs_kill_estimator(&ip_vs_stats);
-	unregister_sysctl_table(sysctl_header);
-	proc_net_remove(&init_net, "ip_vs_stats");
-	proc_net_remove(&init_net, "ip_vs");
+	unregister_pernet_subsys(&ipvs_control_ops);
 	ip_vs_genl_unregister();
 	nf_unregister_sockopt(&ip_vs_sockopts);
 	LeaveFunction(2);
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index ff28801..7417a0c 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -157,13 +157,31 @@ void ip_vs_zero_estimator(struct ip_vs_stats *stats)
 	est->outbps = 0;
 }
 
+static int __net_init __ip_vs_estimator_init(struct net *net)
+{
+	if (!net_eq(net, &init_net))	/* netns not enabled yet */
+		return -EPERM;
+
+	return 0;
+}
+
+static struct pernet_operations ip_vs_app_ops = {
+	.init = __ip_vs_estimator_init,
+};
+
 int __init ip_vs_estimator_init(void)
 {
+	int rv;
+
+	rv = register_pernet_subsys(&ip_vs_app_ops);
+	if (rv < 0)
+		return rv;
 	mod_timer(&est_timer, jiffies + 2 * HZ);
-	return 0;
+	return rv;
 }
 
 void ip_vs_estimator_cleanup(void)
 {
 	del_timer_sync(&est_timer);
+	unregister_pernet_subsys(&ip_vs_app_ops);
 }
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 84aef65..0e762f3 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -399,15 +399,17 @@ static struct ip_vs_app ip_vs_ftp = {
 	.pkt_in =	ip_vs_ftp_in,
 };
 
-
 /*
- *	ip_vs_ftp initialization
+ *	per netns ip_vs_ftp initialization
  */
-static int __init ip_vs_ftp_init(void)
+static int __net_init __ip_vs_ftp_init(struct net *net)
 {
 	int i, ret;
 	struct ip_vs_app *app = &ip_vs_ftp;
 
+	if (!net_eq(net, &init_net))	/* netns not enabled yet */
+		return -EPERM;
+
 	ret = register_ip_vs_app(app);
 	if (ret)
 		return ret;
@@ -427,14 +429,38 @@ static int __init ip_vs_ftp_init(void)
 
 	return ret;
 }
+/*
+ *	netns exit
+ */
+static void __ip_vs_ftp_exit(struct net *net)
+{
+	struct ip_vs_app *app = &ip_vs_ftp;
+
+	if (!net_eq(net, &init_net))	/* netns not enabled yet */
+		return;
+
+	unregister_ip_vs_app(app);
+}
+
+static struct pernet_operations ip_vs_ftp_ops = {
+	.init = __ip_vs_ftp_init,
+	.exit = __ip_vs_ftp_exit,
+};
 
+int __init ip_vs_ftp_init(void)
+{
+	int rv;
+
+	rv = register_pernet_subsys(&ip_vs_ftp_ops);
+	return rv;
+}
 
 /*
  *	ip_vs_ftp finish.
  */
 static void __exit ip_vs_ftp_exit(void)
 {
-	unregister_ip_vs_app(&ip_vs_ftp);
+	unregister_pernet_subsys(&ip_vs_ftp_ops);
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 9323f89..84278fb 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -543,23 +543,54 @@ static struct ip_vs_scheduler ip_vs_lblc_scheduler =
 	.schedule =		ip_vs_lblc_schedule,
 };
 
+/*
+ *  per netns init.
+ */
+static int __net_init __ip_vs_lblc_init(struct net *net)
+{
+	if (!net_eq(net, &init_net))	/* netns not enabled yet */
+		return -EPERM;
+
+	sysctl_header = register_net_sysctl_table(net, net_vs_ctl_path,
+						  vs_vars_table);
+	if (!sysctl_header)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void __net_exit __ip_vs_lblc_exit(struct net *net)
+{
+	if (!net_eq(net, &init_net))	/* netns not enabled yet */
+		return;
+
+	unregister_net_sysctl_table(sysctl_header);
+}
+
+static struct pernet_operations ip_vs_lblc_ops = {
+	.init = __ip_vs_lblc_init,
+	.exit = __ip_vs_lblc_exit,
+};
 
 static int __init ip_vs_lblc_init(void)
 {
 	int ret;
 
-	sysctl_header = register_sysctl_paths(net_vs_ctl_path, vs_vars_table);
+	ret = register_pernet_subsys(&ip_vs_lblc_ops);
+	if (ret)
+		return ret;
+
 	ret = register_ip_vs_scheduler(&ip_vs_lblc_scheduler);
 	if (ret)
-		unregister_sysctl_table(sysctl_header);
+		unregister_pernet_subsys(&ip_vs_lblc_ops);
 	return ret;
 }
 
 
 static void __exit ip_vs_lblc_cleanup(void)
 {
-	unregister_sysctl_table(sysctl_header);
 	unregister_ip_vs_scheduler(&ip_vs_lblc_scheduler);
+	unregister_pernet_subsys(&ip_vs_lblc_ops);
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index dbeed8e..7c7396a 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -744,23 +744,53 @@ static struct ip_vs_scheduler ip_vs_lblcr_scheduler =
 	.schedule =		ip_vs_lblcr_schedule,
 };
 
+/*
+ *  per netns init.
+ */
+static int __net_init __ip_vs_lblcr_init(struct net *net)
+{
+	if (!net_eq(net, &init_net))	/* netns not enabled yet */
+		return -EPERM;
+
+	sysctl_header = register_net_sysctl_table(net, net_vs_ctl_path,
+						  vs_vars_table);
+	if (!sysctl_header)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void __net_exit __ip_vs_lblcr_exit(struct net *net)
+{
+	if (!net_eq(net, &init_net))	/* netns not enabled yet */
+		return;
+
+	unregister_net_sysctl_table(sysctl_header);
+}
+
+static struct pernet_operations ip_vs_lblcr_ops = {
+	.init = __ip_vs_lblcr_init,
+	.exit = __ip_vs_lblcr_exit,
+};
 
 static int __init ip_vs_lblcr_init(void)
 {
 	int ret;
 
-	sysctl_header = register_sysctl_paths(net_vs_ctl_path, vs_vars_table);
+	ret = register_pernet_subsys(&ip_vs_lblcr_ops);
+	if (ret)
+		return ret;
+
 	ret = register_ip_vs_scheduler(&ip_vs_lblcr_scheduler);
 	if (ret)
-		unregister_sysctl_table(sysctl_header);
+		unregister_pernet_subsys(&ip_vs_lblcr_ops);
 	return ret;
 }
 
-
 static void __exit ip_vs_lblcr_cleanup(void)
 {
-	unregister_sysctl_table(sysctl_header);
 	unregister_ip_vs_scheduler(&ip_vs_lblcr_scheduler);
+	unregister_pernet_subsys(&ip_vs_lblcr_ops);
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index c539983..4539294 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -236,6 +236,23 @@ ip_vs_tcpudp_debug_packet(int af, struct ip_vs_protocol *pp,
 		ip_vs_tcpudp_debug_packet_v4(pp, skb, offset, msg);
 }
 
+/*
+ * per network name-space init
+ */
+static int __net_init __ip_vs_protocol_init(struct net *net)
+{
+	return 0;
+}
+
+static void __net_exit __ip_vs_protocol_cleanup(struct net *net)
+{
+	/* empty */
+}
+
+static struct pernet_operations ipvs_proto_ops = {
+	.init = __ip_vs_protocol_init,
+	.exit = __ip_vs_protocol_cleanup,
+};
 
 int __init ip_vs_protocol_init(void)
 {
@@ -265,6 +282,7 @@ int __init ip_vs_protocol_init(void)
 	REGISTER_PROTOCOL(&ip_vs_protocol_esp);
 #endif
 	pr_info("Registered protocols (%s)\n", &protocols[2]);
+	return register_pernet_subsys(&ipvs_proto_ops);
 
 	return 0;
 }
@@ -275,6 +293,7 @@ void ip_vs_protocol_cleanup(void)
 	struct ip_vs_protocol *pp;
 	int i;
 
+	unregister_pernet_subsys(&ipvs_proto_ops);
 	/* unregister all the ipvs protocols */
 	for (i = 0; i < IP_VS_PROTO_TAB_SIZE; i++) {
 		while ((pp = ip_vs_proto_table[i]) != NULL)
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index c1c167a..3668739 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1639,3 +1639,30 @@ int stop_sync_thread(int state)
 
 	return 0;
 }
+
+/*
+ * Initialize data struct for each netns
+ */
+static int __net_init __ip_vs_sync_init(struct net *net)
+{
+	return 0;
+}
+
+static void __ip_vs_sync_cleanup(struct net *net)
+{
+}
+static struct pernet_operations ipvs_sync_ops = {
+	.init = __ip_vs_sync_init,
+	.exit = __ip_vs_sync_cleanup,
+};
+
+
+int __init ip_vs_sync_init(void)
+{
+	return register_pernet_subsys(&ipvs_sync_ops);
+}
+
+void __exit ip_vs_sync_cleanup(void)
+{
+	unregister_pernet_subsys(&ipvs_sync_ops);
+}
-- 
1.7.2.3

