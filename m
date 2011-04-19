From: Hans Schillstrom <hans@schillstrom.com>
Subject: [PATCH 3/3] IPVS: init and cleanup restructuring.
Date: Tue, 19 Apr 2011 17:25:05 +0200
Message-ID: <1303226705-29178-3-git-send-email-hans@schillstrom.com>
References: <1303226705-29178-1-git-send-email-hans@schillstrom.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1303226705-29178-1-git-send-email-hans@schillstrom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, ebiederm@xmission.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans.schillstrom@ericsson.com, Hans Schillstrom <hans@schillstrom.com>

This patch tries to restore the initial init and cleanup
sequences that was before name space patch.

The number of calls to register_pernet_device have been
reduced to one for the ip_vs.ko
Schedulers still have their own calls.

This patch adds a function __ip_vs_service_cleanup()
and a throttle or actually on/off switch for
the netfilter hooks.

The nf hooks will be enabled when the first service is loaded
and disabled when the last service is removed or when a
name space exit starts.

Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
---
 include/net/ip_vs.h              |   17 +++++++
 net/netfilter/ipvs/ip_vs_app.c   |   15 +-----
 net/netfilter/ipvs/ip_vs_conn.c  |   20 ++++----
 net/netfilter/ipvs/ip_vs_core.c  |   86 ++++++++++++++++++++++++++++++++------
 net/netfilter/ipvs/ip_vs_ctl.c   |   66 ++++++++++++++++++++++-------
 net/netfilter/ipvs/ip_vs_est.c   |   14 +-----
 net/netfilter/ipvs/ip_vs_proto.c |   11 +----
 net/netfilter/ipvs/ip_vs_sync.c  |   13 +----
 8 files changed, 161 insertions(+), 81 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index d516f00..558e490 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -791,6 +791,7 @@ struct ip_vs_app {
 /* IPVS in network namespace */
 struct netns_ipvs {
 	int			gen;		/* Generation */
+	int			throttle;	/* Instead of nf unreg */
 	/*
 	 *	Hash table: for real service lookups
 	 */
@@ -1089,6 +1090,22 @@ ip_vs_control_add(struct ip_vs_conn *cp, struct ip_vs_conn *ctl_cp)
 	atomic_inc(&ctl_cp->n_control);
 }

+/*
+ * IPVS netns init & cleanup functions
+ */
+extern int __ip_vs_estimator_init(struct net *net);
+extern int __ip_vs_control_init(struct net *net);
+extern int __ip_vs_protocol_init(struct net *net);
+extern int __ip_vs_app_init(struct net *net);
+extern int __ip_vs_conn_init(struct net *net);
+extern int __ip_vs_sync_init(struct net *net);
+extern void __ip_vs_conn_cleanup(struct net *net);
+extern void __ip_vs_app_cleanup(struct net *net);
+extern void __ip_vs_protocol_cleanup(struct net *net);
+extern void __ip_vs_control_cleanup(struct net *net);
+extern void __ip_vs_estimator_cleanup(struct net *net);
+extern void __ip_vs_sync_cleanup(struct net *net);
+extern void __ip_vs_service_cleanup(struct net *net);

 /*
  *      IPVS application functions
diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index 7e8e769..51f3af7 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -576,7 +576,7 @@ static const struct file_operations ip_vs_app_fops = {
 };
 #endif

-static int __net_init __ip_vs_app_init(struct net *net)
+int __net_init __ip_vs_app_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);

@@ -585,26 +585,17 @@ static int __net_init __ip_vs_app_init(struct net *net)
 	return 0;
 }

-static void __net_exit __ip_vs_app_cleanup(struct net *net)
+void __net_exit __ip_vs_app_cleanup(struct net *net)
 {
 	proc_net_remove(net, "ip_vs_app");
 }

-static struct pernet_operations ip_vs_app_ops = {
-	.init = __ip_vs_app_init,
-	.exit = __ip_vs_app_cleanup,
-};
-
 int __init ip_vs_app_init(void)
 {
-	int rv;
-
-	rv = register_pernet_device(&ip_vs_app_ops);
-	return rv;
+	return 0;
 }


 void ip_vs_app_cleanup(void)
 {
-	unregister_pernet_device(&ip_vs_app_ops);
 }
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 36cd5ea..f8d6702 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1251,30 +1251,30 @@ int __net_init __ip_vs_conn_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);

+	EnterFunction(2);
 	atomic_set(&ipvs->conn_count, 0);

 	proc_net_fops_create(net, "ip_vs_conn", 0, &ip_vs_conn_fops);
 	proc_net_fops_create(net, "ip_vs_conn_sync", 0, &ip_vs_conn_sync_fops);
+	LeaveFunction(2);
 	return 0;
 }

-static void __net_exit __ip_vs_conn_cleanup(struct net *net)
+void __net_exit __ip_vs_conn_cleanup(struct net *net)
 {
+	EnterFunction(2);
 	/* flush all the connection entries first */
 	ip_vs_conn_flush(net);
 	proc_net_remove(net, "ip_vs_conn");
 	proc_net_remove(net, "ip_vs_conn_sync");
+	LeaveFunction(2);
 }
-static struct pernet_operations ipvs_conn_ops = {
-	.init = __ip_vs_conn_init,
-	.exit = __ip_vs_conn_cleanup,
-};

 int __init ip_vs_conn_init(void)
 {
 	int idx;
-	int retc;

+	EnterFunction(2);
 	/* Compute size and mask */
 	ip_vs_conn_tab_size = 1 << ip_vs_conn_tab_bits;
 	ip_vs_conn_tab_mask = ip_vs_conn_tab_size - 1;
@@ -1309,18 +1309,18 @@ int __init ip_vs_conn_init(void)
 		rwlock_init(&__ip_vs_conntbl_lock_array[idx].l);
 	}

-	retc = register_pernet_device(&ipvs_conn_ops);
-
 	/* calculate the random value for connection hash */
 	get_random_bytes(&ip_vs_conn_rnd, sizeof(ip_vs_conn_rnd));
+	LeaveFunction(2);

-	return retc;
+	return 0;
 }

 void ip_vs_conn_cleanup(void)
 {
-	unregister_pernet_device(&ipvs_conn_ops);
+	EnterFunction(2);
 	/* Release the empty cache */
 	kmem_cache_destroy(ip_vs_conn_cachep);
 	vfree(ip_vs_conn_tab);
+	LeaveFunction(2);
 }
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index a7bb81d..dc27fdf 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1343,6 +1343,10 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 		return NF_ACCEPT; /* The packet looks wrong, ignore */

 	net = skb_net(skb);
+	/* Name space in use ? */
+	if (net->ipvs->throttle)
+		return NF_ACCEPT;
+
 	pd = ip_vs_proto_data_get(net, cih->protocol);
 	if (!pd)
 		return NF_ACCEPT;
@@ -1563,6 +1567,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 		}

 	net = skb_net(skb);
+	if (net->ipvs->throttle)
+		return NF_ACCEPT;
 	/* Protocol supported? */
 	pd = ip_vs_proto_data_get(net, iph.protocol);
 	if (unlikely(!pd))
@@ -1588,7 +1594,6 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	}

 	IP_VS_DBG_PKT(11, af, pp, skb, 0, "Incoming packet");
-	net = skb_net(skb);
 	ipvs = net_ipvs(net);
 	/* Check the server status */
 	if (cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
@@ -1879,24 +1884,73 @@ static int __net_init __ip_vs_init(struct net *net)
 {
 	struct netns_ipvs *ipvs;

+	EnterFunction(2);
 	ipvs = net_generic(net, ip_vs_net_id);
 	if (ipvs == NULL) {
 		pr_err("%s(): no memory.\n", __func__);
 		return -ENOMEM;
 	}
+	/* Hold the beast until a service is registerd */
+	ipvs->throttle = -1;
 	ipvs->net = net;
 	/* Counters used for creating unique names */
 	ipvs->gen = atomic_read(&ipvs_netns_cnt);
 	atomic_inc(&ipvs_netns_cnt);
 	net->ipvs = ipvs;
+
+	if ( __ip_vs_estimator_init(net) < 0)
+		goto estimator_fail;
+
+	if (__ip_vs_control_init(net) < 0)
+		goto control_fail;
+
+	if (__ip_vs_protocol_init(net) < 0)
+		goto protocol_fail;
+
+	if (__ip_vs_app_init(net) < 0)
+		goto app_fail;
+
+	if (__ip_vs_conn_init(net) < 0)
+		goto conn_fail;
+
+	if (__ip_vs_sync_init(net) < 0)
+		goto sync_fail;
+
+	LeaveFunction(2);
 	printk(KERN_INFO "IPVS: Creating netns size=%zu id=%d\n",
 			 sizeof(struct netns_ipvs), ipvs->gen);
 	return 0;
+/*
+ * Error handling
+ */
+
+sync_fail:
+	__ip_vs_conn_cleanup(net);
+conn_fail:
+	__ip_vs_app_cleanup(net);
+app_fail:
+	__ip_vs_protocol_cleanup(net);
+protocol_fail:
+	__ip_vs_control_cleanup(net);
+control_fail:
+	__ip_vs_estimator_cleanup(net);
+estimator_fail:
+	return -ENOMEM;
 }

 static void __net_exit __ip_vs_cleanup(struct net *net)
 {
-	IP_VS_DBG(10, "ipvs netns %d released\n", net_ipvs(net)->gen);
+	net->ipvs->throttle = -1;
+	EnterFunction(2);
+	__ip_vs_sync_cleanup(net);
+	__ip_vs_service_cleanup(net);	/* ip_vs_flush() with locks */
+	__ip_vs_conn_cleanup(net);
+	__ip_vs_app_cleanup(net);
+	__ip_vs_protocol_cleanup(net);
+	__ip_vs_control_cleanup(net);
+	__ip_vs_estimator_cleanup(net);
+	LeaveFunction(2);
+	IP_VS_DBG(2, "ipvs netns %d released\n", net_ipvs(net)->gen);
 }

 static struct pernet_operations ipvs_core_ops = {
@@ -1913,10 +1967,7 @@ static int __init ip_vs_init(void)
 {
 	int ret;

-	ret = register_pernet_device(&ipvs_core_ops);	/* Alloc ip_vs struct */
-	if (ret < 0)
-		return ret;
-
+	EnterFunction(2);
 	ip_vs_estimator_init();
 	ret = ip_vs_control_init();
 	if (ret < 0) {
@@ -1944,41 +1995,50 @@ static int __init ip_vs_init(void)
 		goto cleanup_conn;
 	}

+	ret = register_pernet_device(&ipvs_core_ops);	/* Alloc ip_vs struct */
+	if (ret < 0)
+		goto cleanup_sync;
+
 	ret = nf_register_hooks(ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
 	if (ret < 0) {
 		pr_err("can't register hooks.\n");
-		goto cleanup_sync;
+		goto cleanup_net;
 	}

 	pr_info("ipvs loaded.\n");
+	LeaveFunction(2);
+
 	return ret;

+cleanup_net:
+	unregister_pernet_device(&ipvs_core_ops);       /* free ip_vs struct */
 cleanup_sync:
 	ip_vs_sync_cleanup();
-  cleanup_conn:
+cleanup_conn:
 	ip_vs_conn_cleanup();
-  cleanup_app:
+cleanup_app:
 	ip_vs_app_cleanup();
-  cleanup_protocol:
+cleanup_protocol:
 	ip_vs_protocol_cleanup();
 	ip_vs_control_cleanup();
-  cleanup_estimator:
+cleanup_estimator:
 	ip_vs_estimator_cleanup();
-	unregister_pernet_device(&ipvs_core_ops);	/* free ip_vs struct */
 	return ret;
 }

 static void __exit ip_vs_cleanup(void)
 {
+	EnterFunction(2);
 	nf_unregister_hooks(ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
+	unregister_pernet_device(&ipvs_core_ops);	/* free ip_vs struct */
 	ip_vs_sync_cleanup();
 	ip_vs_conn_cleanup();
 	ip_vs_app_cleanup();
 	ip_vs_protocol_cleanup();
 	ip_vs_control_cleanup();
 	ip_vs_estimator_cleanup();
-	unregister_pernet_device(&ipvs_core_ops);	/* free ip_vs struct */
 	pr_info("ipvs unloaded.\n");
+	LeaveFunction(2);
 }

 module_init(ip_vs_init);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 08715d8..6534ca3 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -69,6 +69,11 @@ int ip_vs_get_debug_level(void)
 }
 #endif

+
+/*  Protos */
+static void __ip_vs_del_service(struct ip_vs_service *svc);
+
+
 #ifdef CONFIG_IP_VS_IPV6
 /* Taken from rt6_fill_node() in net/ipv6/route.c, is there a better way? */
 static int __ip_vs_addr_is_local_v6(struct net *net,
@@ -345,6 +350,9 @@ static int ip_vs_svc_unhash(struct ip_vs_service *svc)

 	svc->flags &= ~IP_VS_SVC_F_HASHED;
 	atomic_dec(&svc->refcnt);
+	/* No more services then no need for input */
+	if (atomic_read(&svc->refcnt) == 0)
+		svc->net->ipvs->throttle = -1;
 	return 1;
 }

@@ -480,7 +488,6 @@ __ip_vs_unbind_svc(struct ip_vs_dest *dest)
 	}
 }

-
 /*
  *	Returns hash value for real service
  */
@@ -1214,6 +1221,8 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 	write_unlock_bh(&__ip_vs_svc_lock);

 	*svc_p = svc;
+	/* Now whe have a service - full throttle */
+	ipvs->throttle = 0;
 	return 0;


@@ -1472,6 +1481,41 @@ static int ip_vs_flush(struct net *net)
 	return 0;
 }

+/*
+ *	Delete service by {netns} in the service table.
+ *	Called by __ip_vs_cleanup()
+ */
+void __ip_vs_service_cleanup(struct net *net)
+{
+	unsigned hash;
+	struct ip_vs_service *svc, *tmp;
+
+	EnterFunction(2);
+	/* Check for "full" addressed entries */
+	for (hash = 0; hash<IP_VS_SVC_TAB_SIZE; hash++) {
+		write_lock_bh(&__ip_vs_svc_lock);
+		list_for_each_entry_safe(svc, tmp, &ip_vs_svc_table[hash],
+					 s_list) {
+			if (net_eq(svc->net, net)) {
+				ip_vs_svc_unhash(svc);
+				/*  Wait until all the svc users go away. */
+				IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 0);
+				__ip_vs_del_service(svc);
+			}
+		}
+		list_for_each_entry_safe(svc, tmp, &ip_vs_svc_fwm_table[hash],
+					 f_list) {
+			if (net_eq(svc->net, net)) {
+				ip_vs_svc_unhash(svc);
+				/*  Wait until all the svc users go away. */
+				IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 0);
+				__ip_vs_del_service(svc);
+			}
+		}
+		write_unlock_bh(&__ip_vs_svc_lock);
+	}
+	LeaveFunction(2);
+}

 /*
  *	Zero counters in a service or all services
@@ -3593,6 +3637,7 @@ int __net_init __ip_vs_control_init(struct net *net)
 	int idx;
 	struct netns_ipvs *ipvs = net_ipvs(net);

+	EnterFunction(2);
 	ipvs->rs_lock = __RW_LOCK_UNLOCKED(ipvs->rs_lock);

 	/* Initialize rs_table */
@@ -3619,6 +3664,7 @@ int __net_init __ip_vs_control_init(struct net *net)
 	if (__ip_vs_control_init_sysctl(net))
 		goto err;

+	LeaveFunction(2);
 	return 0;

 err:
@@ -3626,10 +3672,11 @@ err:
 	return -ENOMEM;
 }

-static void __net_exit __ip_vs_control_cleanup(struct net *net)
+void __net_exit __ip_vs_control_cleanup(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);

+	EnterFunction(2);
 	ip_vs_trash_cleanup(net);
 	ip_vs_stop_estimator(net, &ipvs->tot_stats);
 	__ip_vs_control_cleanup_sysctl(net);
@@ -3637,13 +3684,9 @@ static void __net_exit __ip_vs_control_cleanup(struct net *net)
 	proc_net_remove(net, "ip_vs_stats");
 	proc_net_remove(net, "ip_vs");
 	free_percpu(ipvs->tot_stats.cpustats);
+	LeaveFunction(2);
 }

-static struct pernet_operations ipvs_control_ops = {
-	.init = __ip_vs_control_init,
-	.exit = __ip_vs_control_cleanup,
-};
-
 int __init ip_vs_control_init(void)
 {
 	int idx;
@@ -3657,12 +3700,6 @@ int __init ip_vs_control_init(void)
 		INIT_LIST_HEAD(&ip_vs_svc_fwm_table[idx]);
 	}

-	ret = register_pernet_device(&ipvs_control_ops);
-	if (ret) {
-		pr_err("cannot register namespace.\n");
-		goto err;
-	}
-
 	smp_wmb();	/* Do we really need it now ? */

 	ret = nf_register_sockopt(&ip_vs_sockopts);
@@ -3682,8 +3719,6 @@ int __init ip_vs_control_init(void)
 	return 0;

 err_net:
-	unregister_pernet_device(&ipvs_control_ops);
-err:
 	return ret;
 }

@@ -3691,7 +3726,6 @@ err:
 void ip_vs_control_cleanup(void)
 {
 	EnterFunction(2);
-	unregister_pernet_device(&ipvs_control_ops);
 	ip_vs_genl_unregister();
 	nf_unregister_sockopt(&ip_vs_sockopts);
 	LeaveFunction(2);
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 759163e..508cce9 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -192,7 +192,7 @@ void ip_vs_read_estimator(struct ip_vs_stats_user *dst,
 	dst->outbps = (e->outbps + 0xF) >> 5;
 }

-static int __net_init __ip_vs_estimator_init(struct net *net)
+int __net_init __ip_vs_estimator_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);

@@ -203,24 +203,16 @@ static int __net_init __ip_vs_estimator_init(struct net *net)
 	return 0;
 }

-static void __net_exit __ip_vs_estimator_exit(struct net *net)
+void __net_exit __ip_vs_estimator_cleanup(struct net *net)
 {
 	del_timer_sync(&net_ipvs(net)->est_timer);
 }
-static struct pernet_operations ip_vs_app_ops = {
-	.init = __ip_vs_estimator_init,
-	.exit = __ip_vs_estimator_exit,
-};

 int __init ip_vs_estimator_init(void)
 {
-	int rv;
-
-	rv = register_pernet_device(&ip_vs_app_ops);
-	return rv;
+	return 0;
 }

 void ip_vs_estimator_cleanup(void)
 {
-	unregister_pernet_device(&ip_vs_app_ops);
 }
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index f7021fc..eb86028 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -316,7 +316,7 @@ ip_vs_tcpudp_debug_packet(int af, struct ip_vs_protocol *pp,
 /*
  * per network name-space init
  */
-static int __net_init __ip_vs_protocol_init(struct net *net)
+int __net_init __ip_vs_protocol_init(struct net *net)
 {
 #ifdef CONFIG_IP_VS_PROTO_TCP
 	register_ip_vs_proto_netns(net, &ip_vs_protocol_tcp);
@@ -336,7 +336,7 @@ static int __net_init __ip_vs_protocol_init(struct net *net)
 	return 0;
 }

-static void __net_exit __ip_vs_protocol_cleanup(struct net *net)
+void __net_exit __ip_vs_protocol_cleanup(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_proto_data *pd;
@@ -349,11 +349,6 @@ static void __net_exit __ip_vs_protocol_cleanup(struct net *net)
 	}
 }

-static struct pernet_operations ipvs_proto_ops = {
-	.init = __ip_vs_protocol_init,
-	.exit = __ip_vs_protocol_cleanup,
-};
-
 int __init ip_vs_protocol_init(void)
 {
 	char protocols[64];
@@ -382,7 +377,6 @@ int __init ip_vs_protocol_init(void)
 	REGISTER_PROTOCOL(&ip_vs_protocol_esp);
 #endif
 	pr_info("Registered protocols (%s)\n", &protocols[2]);
-	return register_pernet_device(&ipvs_proto_ops);

 	return 0;
 }
@@ -393,7 +387,6 @@ void ip_vs_protocol_cleanup(void)
 	struct ip_vs_protocol *pp;
 	int i;

-	unregister_pernet_device(&ipvs_proto_ops);
 	/* unregister all the ipvs protocols */
 	for (i = 0; i < IP_VS_PROTO_TAB_SIZE; i++) {
 		while ((pp = ip_vs_proto_table[i]) != NULL)
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 1aeca1d..e911f03 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1664,7 +1664,7 @@ int stop_sync_thread(struct net *net, int state)
 /*
  * Initialize data struct for each netns
  */
-static int __net_init __ip_vs_sync_init(struct net *net)
+int __net_init __ip_vs_sync_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);

@@ -1678,24 +1678,17 @@ static int __net_init __ip_vs_sync_init(struct net *net)
 	return 0;
 }

-static void __ip_vs_sync_cleanup(struct net *net)
+void __ip_vs_sync_cleanup(struct net *net)
 {
 	stop_sync_thread(net, IP_VS_STATE_MASTER);
 	stop_sync_thread(net, IP_VS_STATE_BACKUP);
 }

-static struct pernet_operations ipvs_sync_ops = {
-	.init = __ip_vs_sync_init,
-	.exit = __ip_vs_sync_cleanup,
-};
-
-
 int __init ip_vs_sync_init(void)
 {
-	return register_pernet_device(&ipvs_sync_ops);
+	return 0;
 }

 void ip_vs_sync_cleanup(void)
 {
-	unregister_pernet_device(&ipvs_sync_ops);
 }
--
1.7.2.3

