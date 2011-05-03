From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/2] IPVS: init and cleanup restructuring.
Date: Tue,  3 May 2011 16:05:16 +0900
Message-ID: <1304406316-15636-3-git-send-email-horms@verge.net.au>
References: <1304406316-15636-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1304406316-15636-1-git-send-email-horms@verge.net.au>
Sender: netfilter-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Hans Schillstrom <hans@schillstrom.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans@schillstrom.com>

This patch tries to restore the initial init and cleanup
sequences that was before namspace patch.

The number of calls to register_pernet_device have been
reduced to one for the ip_vs.ko
Schedulers still have their own calls.

This patch adds a function __ip_vs_service_cleanup()
and a throttle or actually on/off switch for
the netfilter hooks.

The nf hooks will be enabled when the first service is loaded
and disabled when the last service is removed or when a
namespace exit starts.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
[minor edits to description]
[removed whitespace only hunk in ip_vs_in_icmp()]
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h              |   17 +++++
 net/netfilter/ipvs/ip_vs_app.c   |   15 +----
 net/netfilter/ipvs/ip_vs_conn.c  |   12 +---
 net/netfilter/ipvs/ip_vs_core.c  |  100 ++++++++++++++++++++++++++++---
 net/netfilter/ipvs/ip_vs_ctl.c   |  123 ++++++++++++++++++++++++++++++++------
 net/netfilter/ipvs/ip_vs_est.c   |   14 +----
 net/netfilter/ipvs/ip_vs_proto.c |   11 +---
 net/netfilter/ipvs/ip_vs_sync.c  |   13 +---
 8 files changed, 225 insertions(+), 80 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 4d1b71a..02f6702 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -791,6 +791,7 @@ struct ip_vs_app {
 /* IPVS in network namespace */
 struct netns_ipvs {
 	int			gen;		/* Generation */
+	int			enable;		/* enable like nf_hooks do */
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
index 2dc6de1..51f3af7 100644
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
-	rv = register_pernet_subsys(&ip_vs_app_ops);
-	return rv;
+	return 0;
 }
 
 
 void ip_vs_app_cleanup(void)
 {
-	unregister_pernet_subsys(&ip_vs_app_ops);
 }
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index f289306..5092505 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1258,22 +1258,17 @@ int __net_init __ip_vs_conn_init(struct net *net)
 	return 0;
 }
 
-static void __net_exit __ip_vs_conn_cleanup(struct net *net)
+void __net_exit __ip_vs_conn_cleanup(struct net *net)
 {
 	/* flush all the connection entries first */
 	ip_vs_conn_flush(net);
 	proc_net_remove(net, "ip_vs_conn");
 	proc_net_remove(net, "ip_vs_conn_sync");
 }
-static struct pernet_operations ipvs_conn_ops = {
-	.init = __ip_vs_conn_init,
-	.exit = __ip_vs_conn_cleanup,
-};
 
 int __init ip_vs_conn_init(void)
 {
 	int idx;
-	int retc;
 
 	/* Compute size and mask */
 	ip_vs_conn_tab_size = 1 << ip_vs_conn_tab_bits;
@@ -1309,17 +1304,14 @@ int __init ip_vs_conn_init(void)
 		rwlock_init(&__ip_vs_conntbl_lock_array[idx].l);
 	}
 
-	retc = register_pernet_subsys(&ipvs_conn_ops);
-
 	/* calculate the random value for connection hash */
 	get_random_bytes(&ip_vs_conn_rnd, sizeof(ip_vs_conn_rnd));
 
-	return retc;
+	return 0;
 }
 
 void ip_vs_conn_cleanup(void)
 {
-	unregister_pernet_subsys(&ipvs_conn_ops);
 	/* Release the empty cache */
 	kmem_cache_destroy(ip_vs_conn_cachep);
 	vfree(ip_vs_conn_tab);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index a0791dc..36e650b 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1113,6 +1113,9 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 		return NF_ACCEPT;
 
 	net = skb_net(skb);
+	if (!net_ipvs(net)->enable)
+		return NF_ACCEPT;
+
 	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
@@ -1529,6 +1532,11 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 			      IP_VS_DBG_ADDR(af, &iph.daddr), hooknum);
 		return NF_ACCEPT;
 	}
+	/* ipvs enabled in this netns ? */
+	net = skb_net(skb);
+	if (!net_ipvs(net)->enable)
+		return NF_ACCEPT;
+
 	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 
 	/* Bad... Do not break raw sockets */
@@ -1562,7 +1570,6 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 		}
 
-	net = skb_net(skb);
 	/* Protocol supported? */
 	pd = ip_vs_proto_data_get(net, iph.protocol);
 	if (unlikely(!pd))
@@ -1588,7 +1595,6 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	}
 
 	IP_VS_DBG_PKT(11, af, pp, skb, 0, "Incoming packet");
-	net = skb_net(skb);
 	ipvs = net_ipvs(net);
 	/* Check the server status */
 	if (cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
@@ -1743,10 +1749,16 @@ ip_vs_forward_icmp(unsigned int hooknum, struct sk_buff *skb,
 		   int (*okfn)(struct sk_buff *))
 {
 	int r;
+	struct net *net;
 
 	if (ip_hdr(skb)->protocol != IPPROTO_ICMP)
 		return NF_ACCEPT;
 
+	/* ipvs enabled in this netns ? */
+	net = skb_net(skb);
+	if (!net_ipvs(net)->enable)
+		return NF_ACCEPT;
+
 	return ip_vs_in_icmp(skb, &r, hooknum);
 }
 
@@ -1757,10 +1769,16 @@ ip_vs_forward_icmp_v6(unsigned int hooknum, struct sk_buff *skb,
 		      int (*okfn)(struct sk_buff *))
 {
 	int r;
+	struct net *net;
 
 	if (ipv6_hdr(skb)->nexthdr != IPPROTO_ICMPV6)
 		return NF_ACCEPT;
 
+	/* ipvs enabled in this netns ? */
+	net = skb_net(skb);
+	if (!net_ipvs(net)->enable)
+		return NF_ACCEPT;
+
 	return ip_vs_in_icmp_v6(skb, &r, hooknum);
 }
 #endif
@@ -1884,21 +1902,72 @@ static int __net_init __ip_vs_init(struct net *net)
 		pr_err("%s(): no memory.\n", __func__);
 		return -ENOMEM;
 	}
+	/* Hold the beast until a service is registerd */
+	ipvs->enable = 0;
 	ipvs->net = net;
 	/* Counters used for creating unique names */
 	ipvs->gen = atomic_read(&ipvs_netns_cnt);
 	atomic_inc(&ipvs_netns_cnt);
 	net->ipvs = ipvs;
+
+	if (__ip_vs_estimator_init(net) < 0)
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
+	__ip_vs_service_cleanup(net);	/* ip_vs_flush() with locks */
+	__ip_vs_conn_cleanup(net);
+	__ip_vs_app_cleanup(net);
+	__ip_vs_protocol_cleanup(net);
+	__ip_vs_control_cleanup(net);
+	__ip_vs_estimator_cleanup(net);
 	IP_VS_DBG(2, "ipvs netns %d released\n", net_ipvs(net)->gen);
 }
 
+static void __net_exit __ip_vs_dev_cleanup(struct net *net)
+{
+	EnterFunction(2);
+	net_ipvs(net)->enable = 0;	/* Disable packet reception */
+	__ip_vs_sync_cleanup(net);
+	LeaveFunction(2);
+}
+
 static struct pernet_operations ipvs_core_ops = {
 	.init = __ip_vs_init,
 	.exit = __ip_vs_cleanup,
@@ -1906,6 +1975,10 @@ static struct pernet_operations ipvs_core_ops = {
 	.size = sizeof(struct netns_ipvs),
 };
 
+static struct pernet_operations ipvs_core_dev_ops = {
+	.exit = __ip_vs_dev_cleanup,
+};
+
 /*
  *	Initialize IP Virtual Server
  */
@@ -1913,10 +1986,6 @@ static int __init ip_vs_init(void)
 {
 	int ret;
 
-	ret = register_pernet_subsys(&ipvs_core_ops);	/* Alloc ip_vs struct */
-	if (ret < 0)
-		return ret;
-
 	ip_vs_estimator_init();
 	ret = ip_vs_control_init();
 	if (ret < 0) {
@@ -1944,15 +2013,28 @@ static int __init ip_vs_init(void)
 		goto cleanup_conn;
 	}
 
+	ret = register_pernet_subsys(&ipvs_core_ops);	/* Alloc ip_vs struct */
+	if (ret < 0)
+		goto cleanup_sync;
+
+	ret = register_pernet_device(&ipvs_core_dev_ops);
+	if (ret < 0)
+		goto cleanup_sub;
+
 	ret = nf_register_hooks(ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
 	if (ret < 0) {
 		pr_err("can't register hooks.\n");
-		goto cleanup_sync;
+		goto cleanup_dev;
 	}
 
 	pr_info("ipvs loaded.\n");
+
 	return ret;
 
+cleanup_dev:
+	unregister_pernet_device(&ipvs_core_dev_ops);
+cleanup_sub:
+	unregister_pernet_subsys(&ipvs_core_ops);
 cleanup_sync:
 	ip_vs_sync_cleanup();
   cleanup_conn:
@@ -1964,20 +2046,20 @@ cleanup_sync:
 	ip_vs_control_cleanup();
   cleanup_estimator:
 	ip_vs_estimator_cleanup();
-	unregister_pernet_subsys(&ipvs_core_ops);	/* free ip_vs struct */
 	return ret;
 }
 
 static void __exit ip_vs_cleanup(void)
 {
 	nf_unregister_hooks(ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
+	unregister_pernet_device(&ipvs_core_dev_ops);
+	unregister_pernet_subsys(&ipvs_core_ops);	/* free ip_vs struct */
 	ip_vs_sync_cleanup();
 	ip_vs_conn_cleanup();
 	ip_vs_app_cleanup();
 	ip_vs_protocol_cleanup();
 	ip_vs_control_cleanup();
 	ip_vs_estimator_cleanup();
-	unregister_pernet_subsys(&ipvs_core_ops);	/* free ip_vs struct */
 	pr_info("ipvs unloaded.\n");
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index ae47090..e699a94 100644
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
+	/* No more services, no need for input */
+	if (atomic_read(&svc->refcnt) == 0)
+		net_ipvs(svc->net)->enable = 0;
 	return 1;
 }
 
@@ -1214,6 +1222,8 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 	write_unlock_bh(&__ip_vs_svc_lock);
 
 	*svc_p = svc;
+	/* Now there is a service - full throttle */
+	ipvs->enable = 1;
 	return 0;
 
 
@@ -1472,6 +1482,84 @@ static int ip_vs_flush(struct net *net)
 	return 0;
 }
 
+/*
+ *	Delete service by {netns} in the service table.
+ *	Called by __ip_vs_cleanup()
+ */
+void __ip_vs_service_cleanup(struct net *net)
+{
+	EnterFunction(2);
+	/* Check for "full" addressed entries */
+	mutex_lock(&__ip_vs_mutex);
+	ip_vs_flush(net);
+	mutex_unlock(&__ip_vs_mutex);
+	LeaveFunction(2);
+}
+/*
+ * Release dst hold by dst_cache
+ */
+static inline void
+__ip_vs_dev_reset(struct ip_vs_dest *dest, struct net_device *dev)
+{
+	spin_lock_bh(&dest->dst_lock);
+	if (dest->dst_cache && dest->dst_cache->dev == dev) {
+		IP_VS_DBG_BUF(3, "Reset dev:%s dest %s:%u ,dest->refcnt=%d\n",
+			      dev->name,
+			      IP_VS_DBG_ADDR(dest->af, &dest->addr),
+			      ntohs(dest->port),
+			      atomic_read(&dest->refcnt));
+		ip_vs_dst_reset(dest);
+	}
+	spin_unlock_bh(&dest->dst_lock);
+
+}
+/*
+ * Netdev event receiver
+ * Currently only NETDEV_UNREGISTER is handled, i.e. if we hold a reference to
+ * a device that is "unregister" it must be released.
+ */
+static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
+			    void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct net *net = dev_net(dev);
+	struct ip_vs_service *svc;
+	struct ip_vs_dest *dest;
+	unsigned int idx;
+
+	if (event != NETDEV_UNREGISTER)
+		return NOTIFY_DONE;
+	IP_VS_DBG(3, "%s() dev=%s\n", __func__, dev->name);
+	EnterFunction(2);
+	mutex_lock(&__ip_vs_mutex);
+	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
+		list_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
+			if (net_eq(svc->net, net)) {
+				list_for_each_entry(dest, &svc->destinations,
+						    n_list) {
+					__ip_vs_dev_reset(dest, dev);
+				}
+			}
+		}
+
+		list_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
+			if (net_eq(svc->net, net)) {
+				list_for_each_entry(dest, &svc->destinations,
+						    n_list) {
+					__ip_vs_dev_reset(dest, dev);
+				}
+			}
+
+		}
+	}
+
+	list_for_each_entry(dest, &net_ipvs(net)->dest_trash, n_list) {
+		__ip_vs_dev_reset(dest, dev);
+	}
+	mutex_unlock(&__ip_vs_mutex);
+	LeaveFunction(2);
+	return NOTIFY_DONE;
+}
 
 /*
  *	Zero counters in a service or all services
@@ -3588,6 +3676,10 @@ void __net_init __ip_vs_control_cleanup_sysctl(struct net *net) { }
 
 #endif
 
+static struct notifier_block ip_vs_dst_notifier = {
+	.notifier_call = ip_vs_dst_event,
+};
+
 int __net_init __ip_vs_control_init(struct net *net)
 {
 	int idx;
@@ -3626,7 +3718,7 @@ err:
 	return -ENOMEM;
 }
 
-static void __net_exit __ip_vs_control_cleanup(struct net *net)
+void __net_exit __ip_vs_control_cleanup(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
@@ -3639,11 +3731,6 @@ static void __net_exit __ip_vs_control_cleanup(struct net *net)
 	free_percpu(ipvs->tot_stats.cpustats);
 }
 
-static struct pernet_operations ipvs_control_ops = {
-	.init = __ip_vs_control_init,
-	.exit = __ip_vs_control_cleanup,
-};
-
 int __init ip_vs_control_init(void)
 {
 	int idx;
@@ -3657,33 +3744,32 @@ int __init ip_vs_control_init(void)
 		INIT_LIST_HEAD(&ip_vs_svc_fwm_table[idx]);
 	}
 
-	ret = register_pernet_subsys(&ipvs_control_ops);
-	if (ret) {
-		pr_err("cannot register namespace.\n");
-		goto err;
-	}
-
 	smp_wmb();	/* Do we really need it now ? */
 
 	ret = nf_register_sockopt(&ip_vs_sockopts);
 	if (ret) {
 		pr_err("cannot register sockopt.\n");
-		goto err_net;
+		goto err_sock;
 	}
 
 	ret = ip_vs_genl_register();
 	if (ret) {
 		pr_err("cannot register Generic Netlink interface.\n");
-		nf_unregister_sockopt(&ip_vs_sockopts);
-		goto err_net;
+		goto err_genl;
 	}
 
+	ret = register_netdevice_notifier(&ip_vs_dst_notifier);
+	if (ret < 0)
+		goto err_notf;
+
 	LeaveFunction(2);
 	return 0;
 
-err_net:
-	unregister_pernet_subsys(&ipvs_control_ops);
-err:
+err_notf:
+	ip_vs_genl_unregister();
+err_genl:
+	nf_unregister_sockopt(&ip_vs_sockopts);
+err_sock:
 	return ret;
 }
 
@@ -3691,7 +3777,6 @@ err:
 void ip_vs_control_cleanup(void)
 {
 	EnterFunction(2);
-	unregister_pernet_subsys(&ipvs_control_ops);
 	ip_vs_genl_unregister();
 	nf_unregister_sockopt(&ip_vs_sockopts);
 	LeaveFunction(2);
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 8c8766c..508cce9 100644
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
-	rv = register_pernet_subsys(&ip_vs_app_ops);
-	return rv;
+	return 0;
 }
 
 void ip_vs_estimator_cleanup(void)
 {
-	unregister_pernet_subsys(&ip_vs_app_ops);
 }
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 17484a4..eb86028 100644
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
-	return register_pernet_subsys(&ipvs_proto_ops);
 
 	return 0;
 }
@@ -393,7 +387,6 @@ void ip_vs_protocol_cleanup(void)
 	struct ip_vs_protocol *pp;
 	int i;
 
-	unregister_pernet_subsys(&ipvs_proto_ops);
 	/* unregister all the ipvs protocols */
 	for (i = 0; i < IP_VS_PROTO_TAB_SIZE; i++) {
 		while ((pp = ip_vs_proto_table[i]) != NULL)
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 0cce953..e292e5b 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1663,7 +1663,7 @@ int stop_sync_thread(struct net *net, int state)
 /*
  * Initialize data struct for each netns
  */
-static int __net_init __ip_vs_sync_init(struct net *net)
+int __net_init __ip_vs_sync_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
@@ -1677,7 +1677,7 @@ static int __net_init __ip_vs_sync_init(struct net *net)
 	return 0;
 }
 
-static void __ip_vs_sync_cleanup(struct net *net)
+void __ip_vs_sync_cleanup(struct net *net)
 {
 	int retc;
 
@@ -1690,18 +1690,11 @@ static void __ip_vs_sync_cleanup(struct net *net)
 		pr_err("Failed to stop Backup Daemon\n");
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
1.7.4.1

