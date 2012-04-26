From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [v2 PATCH 1/1] ipvs: kernel oops - do_ip_vs_get_ctl
Date: Thu, 26 Apr 2012 07:47:44 +0200
Message-ID: <1335419264-1225-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, brouer@redhat.com, rohara@redhat.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

Change order of init so netns init is ready
when register ioctl and netlink.

Ver2 
	Whitespace fixes and __init added.

Reported-by: "Ryan O'Hara" <rohara@redhat.com>
Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/ip_vs.h             |    2 +
 net/netfilter/ipvs/ip_vs_core.c |    9 ++++++
 net/netfilter/ipvs/ip_vs_ctl.c  |   52 ++++++++++++++++++++++----------------
 3 files changed, 41 insertions(+), 22 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index f967395..93b81aa 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1201,6 +1201,8 @@ ip_vs_lookup_real_service(struct net *net, int af, __u16 protocol,
 
 extern int ip_vs_use_count_inc(void);
 extern void ip_vs_use_count_dec(void);
+extern int ip_vs_register_nl_ioctl(void);
+extern void ip_vs_unregister_nl_ioctl(void);
 extern int ip_vs_control_init(void);
 extern void ip_vs_control_cleanup(void);
 extern struct ip_vs_dest *
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index d8b1d30..c8f36b9 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1995,10 +1995,18 @@ static int __init ip_vs_init(void)
 		goto cleanup_dev;
 	}
 
+	ret = ip_vs_register_nl_ioctl();
+	if (ret < 0) {
+		pr_err("can't register netlink/ioctl.\n");
+		goto cleanup_hooks;
+	}
+
 	pr_info("ipvs loaded.\n");
 
 	return ret;
 
+cleanup_hooks:
+	nf_unregister_hooks(ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
 cleanup_dev:
 	unregister_pernet_device(&ipvs_core_dev_ops);
 cleanup_sub:
@@ -2014,6 +2022,7 @@ exit:
 
 static void __exit ip_vs_cleanup(void)
 {
+	ip_vs_unregister_nl_ioctl();
 	nf_unregister_hooks(ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
 	unregister_pernet_device(&ipvs_core_dev_ops);
 	unregister_pernet_subsys(&ipvs_core_ops);	/* free ip_vs struct */
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 7131417..efaf484 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3750,21 +3750,10 @@ void __net_exit ip_vs_control_net_cleanup(struct net *net)
 	free_percpu(ipvs->tot_stats.cpustats);
 }
 
-int __init ip_vs_control_init(void)
+int __init ip_vs_register_nl_ioctl(void)
 {
-	int idx;
 	int ret;
 
-	EnterFunction(2);
-
-	/* Initialize svc_table, ip_vs_svc_fwm_table, rs_table */
-	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++)  {
-		INIT_LIST_HEAD(&ip_vs_svc_table[idx]);
-		INIT_LIST_HEAD(&ip_vs_svc_fwm_table[idx]);
-	}
-
-	smp_wmb();	/* Do we really need it now ? */
-
 	ret = nf_register_sockopt(&ip_vs_sockopts);
 	if (ret) {
 		pr_err("cannot register sockopt.\n");
@@ -3776,28 +3765,47 @@ int __init ip_vs_control_init(void)
 		pr_err("cannot register Generic Netlink interface.\n");
 		goto err_genl;
 	}
-
-	ret = register_netdevice_notifier(&ip_vs_dst_notifier);
-	if (ret < 0)
-		goto err_notf;
-
-	LeaveFunction(2);
 	return 0;
 
-err_notf:
-	ip_vs_genl_unregister();
 err_genl:
 	nf_unregister_sockopt(&ip_vs_sockopts);
 err_sock:
 	return ret;
 }
 
+void ip_vs_unregister_nl_ioctl(void)
+{
+	ip_vs_genl_unregister();
+	nf_unregister_sockopt(&ip_vs_sockopts);
+}
+
+int __init ip_vs_control_init(void)
+{
+	int idx;
+	int ret;
+
+	EnterFunction(2);
+
+	/* Initialize svc_table, ip_vs_svc_fwm_table, rs_table */
+	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
+		INIT_LIST_HEAD(&ip_vs_svc_table[idx]);
+		INIT_LIST_HEAD(&ip_vs_svc_fwm_table[idx]);
+	}
+
+	smp_wmb();	/* Do we really need it now ? */
+
+	ret = register_netdevice_notifier(&ip_vs_dst_notifier);
+	if (ret < 0)
+		return ret;
+
+	LeaveFunction(2);
+	return 0;
+}
+
 
 void ip_vs_control_cleanup(void)
 {
 	EnterFunction(2);
 	unregister_netdevice_notifier(&ip_vs_dst_notifier);
-	ip_vs_genl_unregister();
-	nf_unregister_sockopt(&ip_vs_sockopts);
 	LeaveFunction(2);
 }
-- 
1.7.2.3

