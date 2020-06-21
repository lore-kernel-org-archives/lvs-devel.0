From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next] ipvs: register hooks only with services
Date: Sun, 21 Jun 2020 18:40:30 +0300
Message-ID: <20200621154030.10998-1-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, netfilter-devel@vger.kernel.org

Keep the IPVS hooks registered in Netfilter only
while there are configured virtual services. This
saves CPU cycles while IPVS is loaded but not used.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |  5 +++
 net/netfilter/ipvs/ip_vs_core.c | 80 ++++++++++++++++++++++++++-------
 net/netfilter/ipvs/ip_vs_ctl.c  | 23 +++++++++-
 3 files changed, 89 insertions(+), 19 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index fe96aa462d05..011f407b76fe 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -874,6 +874,7 @@ struct netns_ipvs {
 	struct ip_vs_stats		tot_stats;  /* Statistics & est. */
 
 	int			num_services;    /* no of virtual services */
+	int			num_services6;   /* IPv6 virtual services */
 
 	/* Trash for destinations */
 	struct list_head	dest_trash;
@@ -960,6 +961,7 @@ struct netns_ipvs {
 	 * are not supported when synchronization is enabled.
 	 */
 	unsigned int		mixed_address_family_dests;
+	unsigned int		hooks_afmask;	/* &1=AF_INET, &2=AF_INET6 */
 };
 
 #define DEFAULT_SYNC_THRESHOLD	3
@@ -1668,6 +1670,9 @@ static inline void ip_vs_unregister_conntrack(struct ip_vs_service *svc)
 #endif
 }
 
+int ip_vs_register_hooks(struct netns_ipvs *ipvs, unsigned int af);
+void ip_vs_unregister_hooks(struct netns_ipvs *ipvs, unsigned int af);
+
 static inline int
 ip_vs_dest_conn_overhead(struct ip_vs_dest *dest)
 {
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 517f6a2ac15a..b4a6b7662f3f 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2258,7 +2258,7 @@ ip_vs_forward_icmp_v6(void *priv, struct sk_buff *skb,
 #endif
 
 
-static const struct nf_hook_ops ip_vs_ops[] = {
+static const struct nf_hook_ops ip_vs_ops4[] = {
 	/* After packet filtering, change source only for VS/NAT */
 	{
 		.hook		= ip_vs_reply4,
@@ -2304,7 +2304,10 @@ static const struct nf_hook_ops ip_vs_ops[] = {
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= 100,
 	},
+};
+
 #ifdef CONFIG_IP_VS_IPV6
+static const struct nf_hook_ops ip_vs_ops6[] = {
 	/* After packet filtering, change source only for VS/NAT */
 	{
 		.hook		= ip_vs_reply6,
@@ -2350,8 +2353,64 @@ static const struct nf_hook_ops ip_vs_ops[] = {
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= 100,
 	},
-#endif
 };
+#endif
+
+int ip_vs_register_hooks(struct netns_ipvs *ipvs, unsigned int af)
+{
+	const struct nf_hook_ops *ops;
+	unsigned int count;
+	unsigned int afmask;
+	int ret = 0;
+
+	if (af == AF_INET6) {
+#ifdef CONFIG_IP_VS_IPV6
+		ops = ip_vs_ops6;
+		count = ARRAY_SIZE(ip_vs_ops6);
+		afmask = 2;
+#else
+		return -EINVAL;
+#endif
+	} else {
+		ops = ip_vs_ops4;
+		count = ARRAY_SIZE(ip_vs_ops4);
+		afmask = 1;
+	}
+
+	if (!(ipvs->hooks_afmask & afmask)) {
+		ret = nf_register_net_hooks(ipvs->net, ops, count);
+		if (ret >= 0)
+			ipvs->hooks_afmask |= afmask;
+	}
+	return ret;
+}
+
+void ip_vs_unregister_hooks(struct netns_ipvs *ipvs, unsigned int af)
+{
+	const struct nf_hook_ops *ops;
+	unsigned int count;
+	unsigned int afmask;
+
+	if (af == AF_INET6) {
+#ifdef CONFIG_IP_VS_IPV6
+		ops = ip_vs_ops6;
+		count = ARRAY_SIZE(ip_vs_ops6);
+		afmask = 2;
+#else
+		return;
+#endif
+	} else {
+		ops = ip_vs_ops4;
+		count = ARRAY_SIZE(ip_vs_ops4);
+		afmask = 1;
+	}
+
+	if (ipvs->hooks_afmask & afmask) {
+		nf_unregister_net_hooks(ipvs->net, ops, count);
+		ipvs->hooks_afmask &= ~afmask;
+	}
+}
+
 /*
  *	Initialize IP Virtual Server netns mem.
  */
@@ -2427,19 +2486,6 @@ static void __net_exit __ip_vs_cleanup_batch(struct list_head *net_list)
 	}
 }
 
-static int __net_init __ip_vs_dev_init(struct net *net)
-{
-	int ret;
-
-	ret = nf_register_net_hooks(net, ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
-	if (ret < 0)
-		goto hook_fail;
-	return 0;
-
-hook_fail:
-	return ret;
-}
-
 static void __net_exit __ip_vs_dev_cleanup_batch(struct list_head *net_list)
 {
 	struct netns_ipvs *ipvs;
@@ -2448,7 +2494,8 @@ static void __net_exit __ip_vs_dev_cleanup_batch(struct list_head *net_list)
 	EnterFunction(2);
 	list_for_each_entry(net, net_list, exit_list) {
 		ipvs = net_ipvs(net);
-		nf_unregister_net_hooks(net, ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
+		ip_vs_unregister_hooks(ipvs, AF_INET);
+		ip_vs_unregister_hooks(ipvs, AF_INET6);
 		ipvs->enable = 0;	/* Disable packet reception */
 		smp_wmb();
 		ip_vs_sync_net_cleanup(ipvs);
@@ -2464,7 +2511,6 @@ static struct pernet_operations ipvs_core_ops = {
 };
 
 static struct pernet_operations ipvs_core_dev_ops = {
-	.init = __ip_vs_dev_init,
 	.exit_batch = __ip_vs_dev_cleanup_batch,
 };
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 412656c34f20..0eed388c960b 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1272,6 +1272,7 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 	struct ip_vs_scheduler *sched = NULL;
 	struct ip_vs_pe *pe = NULL;
 	struct ip_vs_service *svc = NULL;
+	int ret_hooks = -1;
 
 	/* increase the module use count */
 	if (!ip_vs_use_count_inc())
@@ -1313,6 +1314,14 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 	}
 #endif
 
+	if ((u->af == AF_INET && !ipvs->num_services) ||
+	    (u->af == AF_INET6 && !ipvs->num_services6)) {
+		ret = ip_vs_register_hooks(ipvs, u->af);
+		if (ret < 0)
+			goto out_err;
+		ret_hooks = ret;
+	}
+
 	svc = kzalloc(sizeof(struct ip_vs_service), GFP_KERNEL);
 	if (svc == NULL) {
 		IP_VS_DBG(1, "%s(): no memory\n", __func__);
@@ -1374,6 +1383,8 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 	/* Count only IPv4 services for old get/setsockopt interface */
 	if (svc->af == AF_INET)
 		ipvs->num_services++;
+	else if (svc->af == AF_INET6)
+		ipvs->num_services6++;
 
 	/* Hash the service into the service table */
 	ip_vs_svc_hash(svc);
@@ -1385,6 +1396,8 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 
 
  out_err:
+	if (ret_hooks >= 0)
+		ip_vs_unregister_hooks(ipvs, u->af);
 	if (svc != NULL) {
 		ip_vs_unbind_scheduler(svc, sched);
 		ip_vs_service_free(svc);
@@ -1500,9 +1513,15 @@ static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
 	struct ip_vs_pe *old_pe;
 	struct netns_ipvs *ipvs = svc->ipvs;
 
-	/* Count only IPv4 services for old get/setsockopt interface */
-	if (svc->af == AF_INET)
+	if (svc->af == AF_INET) {
 		ipvs->num_services--;
+		if (!ipvs->num_services)
+			ip_vs_unregister_hooks(ipvs, svc->af);
+	} else if (svc->af == AF_INET6) {
+		ipvs->num_services6--;
+		if (!ipvs->num_services6)
+			ip_vs_unregister_hooks(ipvs, svc->af);
+	}
 
 	ip_vs_stop_estimator(svc->ipvs, &svc->stats);
 
-- 
2.26.2

