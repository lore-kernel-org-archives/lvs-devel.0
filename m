From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 07/84] ipvs: Store ipvs not net in struct ip_vs_service
Date: Mon, 21 Sep 2015 13:01:44 -0500
Message-ID: <1442858581-15869-7-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>

In practice struct netns_ipvs is as meaningful as struct net and more
useful as it holds the ipvs specific data.  So store a pointer to
struct netns_ipvs.

Update the accesses of param->net to access param->ipvs->net instead.

In functions where we are searching for an svc and filtering by net
filter by ipvs instead.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip_vs.h              |  2 +-
 net/netfilter/ipvs/ip_vs_core.c  | 10 +++----
 net/netfilter/ipvs/ip_vs_ctl.c   | 64 ++++++++++++++++++++++------------------
 net/netfilter/ipvs/ip_vs_lblc.c  |  3 +-
 net/netfilter/ipvs/ip_vs_lblcr.c |  3 +-
 5 files changed, 43 insertions(+), 39 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 83e2aea63db2..2c22380b9ad7 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -678,7 +678,7 @@ struct ip_vs_service {
 	unsigned int		flags;	  /* service status flags */
 	unsigned int		timeout;  /* persistent timeout in ticks */
 	__be32			netmask;  /* grouping granularity, mask/plen */
-	struct net		*net;
+	struct netns_ipvs	*ipvs;
 
 	struct list_head	destinations;  /* real server d-linked list */
 	__u32			num_dests;     /* number of servers */
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index fd02aec0a11a..583199c2bcdc 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -179,7 +179,7 @@ ip_vs_out_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 static inline void
 ip_vs_conn_stats(struct ip_vs_conn *cp, struct ip_vs_service *svc)
 {
-	struct netns_ipvs *ipvs = net_ipvs(svc->net);
+	struct netns_ipvs *ipvs = svc->ipvs;
 	struct ip_vs_cpu_stats *s;
 
 	s = this_cpu_ptr(cp->dest->stats.cpustats);
@@ -215,7 +215,7 @@ ip_vs_conn_fill_param_persist(const struct ip_vs_service *svc,
 			      const union nf_inet_addr *vaddr, __be16 vport,
 			      struct ip_vs_conn_param *p)
 {
-	ip_vs_conn_fill_param(net_ipvs(svc->net), svc->af, protocol, caddr, cport, vaddr,
+	ip_vs_conn_fill_param(svc->ipvs, svc->af, protocol, caddr, cport, vaddr,
 			      vport, p);
 	p->pe = rcu_dereference(svc->pe);
 	if (p->pe && p->pe->fill_param)
@@ -376,7 +376,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	/*
 	 *    Create a new connection according to the template
 	 */
-	ip_vs_conn_fill_param(net_ipvs(svc->net), svc->af, iph->protocol, src_addr,
+	ip_vs_conn_fill_param(svc->ipvs, svc->af, iph->protocol, src_addr,
 			      src_port, dst_addr, dst_port, &param);
 
 	cp = ip_vs_conn_new(&param, dest->af, &dest->addr, dport, flags, dest,
@@ -524,7 +524,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	{
 		struct ip_vs_conn_param p;
 
-		ip_vs_conn_fill_param(net_ipvs(svc->net), svc->af, iph->protocol,
+		ip_vs_conn_fill_param(svc->ipvs, svc->af, iph->protocol,
 				      caddr, cport, vaddr, vport, &p);
 		cp = ip_vs_conn_new(&p, dest->af, &dest->addr,
 				    dest->port ? dest->port : vport,
@@ -600,7 +600,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		IP_VS_DBG(6, "%s(): create a cache_bypass entry\n", __func__);
 		{
 			struct ip_vs_conn_param p;
-			ip_vs_conn_fill_param(net_ipvs(svc->net), svc->af, iph->protocol,
+			ip_vs_conn_fill_param(svc->ipvs, svc->af, iph->protocol,
 					      &iph->saddr, pptr[0],
 					      &iph->daddr, pptr[1], &p);
 			cp = ip_vs_conn_new(&p, svc->af, &daddr, 0,
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 6162ae56e47a..7132e83617b6 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -309,14 +309,14 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
 		/*
 		 *  Hash it by <netns,protocol,addr,port> in ip_vs_svc_table
 		 */
-		hash = ip_vs_svc_hashkey(svc->net, svc->af, svc->protocol,
+		hash = ip_vs_svc_hashkey(svc->ipvs->net, svc->af, svc->protocol,
 					 &svc->addr, svc->port);
 		hlist_add_head_rcu(&svc->s_list, &ip_vs_svc_table[hash]);
 	} else {
 		/*
 		 *  Hash it by fwmark in svc_fwm_table
 		 */
-		hash = ip_vs_svc_fwm_hashkey(svc->net, svc->fwmark);
+		hash = ip_vs_svc_fwm_hashkey(svc->ipvs->net, svc->fwmark);
 		hlist_add_head_rcu(&svc->f_list, &ip_vs_svc_fwm_table[hash]);
 	}
 
@@ -360,6 +360,7 @@ static inline struct ip_vs_service *
 __ip_vs_service_find(struct net *net, int af, __u16 protocol,
 		     const union nf_inet_addr *vaddr, __be16 vport)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	unsigned int hash;
 	struct ip_vs_service *svc;
 
@@ -371,7 +372,7 @@ __ip_vs_service_find(struct net *net, int af, __u16 protocol,
 		    && ip_vs_addr_equal(af, &svc->addr, vaddr)
 		    && (svc->port == vport)
 		    && (svc->protocol == protocol)
-		    && net_eq(svc->net, net)) {
+		    && (svc->ipvs == ipvs)) {
 			/* HIT */
 			return svc;
 		}
@@ -387,6 +388,7 @@ __ip_vs_service_find(struct net *net, int af, __u16 protocol,
 static inline struct ip_vs_service *
 __ip_vs_svc_fwm_find(struct net *net, int af, __u32 fwmark)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	unsigned int hash;
 	struct ip_vs_service *svc;
 
@@ -395,7 +397,7 @@ __ip_vs_svc_fwm_find(struct net *net, int af, __u32 fwmark)
 
 	hlist_for_each_entry_rcu(svc, &ip_vs_svc_fwm_table[hash], f_list) {
 		if (svc->fwmark == fwmark && svc->af == af
-		    && net_eq(svc->net, net)) {
+		    && (svc->ipvs == ipvs)) {
 			/* HIT */
 			return svc;
 		}
@@ -660,7 +662,7 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, int dest_af,
 		     const union nf_inet_addr *daddr, __be16 dport)
 {
 	struct ip_vs_dest *dest;
-	struct netns_ipvs *ipvs = net_ipvs(svc->net);
+	struct netns_ipvs *ipvs = svc->ipvs;
 
 	/*
 	 * Find the destination in trash
@@ -788,7 +790,7 @@ static void
 __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 		    struct ip_vs_dest_user_kern *udest, int add)
 {
-	struct netns_ipvs *ipvs = net_ipvs(svc->net);
+	struct netns_ipvs *ipvs = svc->ipvs;
 	struct ip_vs_service *old_svc;
 	struct ip_vs_scheduler *sched;
 	int conn_flags;
@@ -843,7 +845,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	spin_unlock_bh(&dest->dst_lock);
 
 	if (add) {
-		ip_vs_start_estimator(svc->net, &dest->stats);
+		ip_vs_start_estimator(svc->ipvs->net, &dest->stats);
 		list_add_rcu(&dest->n_list, &svc->destinations);
 		svc->num_dests++;
 		sched = rcu_dereference_protected(svc->scheduler, 1);
@@ -874,12 +876,12 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 		atype = ipv6_addr_type(&udest->addr.in6);
 		if ((!(atype & IPV6_ADDR_UNICAST) ||
 			atype & IPV6_ADDR_LINKLOCAL) &&
-			!__ip_vs_addr_is_local_v6(svc->net, &udest->addr.in6))
+			!__ip_vs_addr_is_local_v6(svc->ipvs->net, &udest->addr.in6))
 			return -EINVAL;
 	} else
 #endif
 	{
-		atype = inet_addr_type(svc->net, udest->addr.ip);
+		atype = inet_addr_type(svc->ipvs->net, udest->addr.ip);
 		if (atype != RTN_LOCAL && atype != RTN_UNICAST)
 			return -EINVAL;
 	}
@@ -1079,7 +1081,7 @@ static void __ip_vs_unlink_dest(struct ip_vs_service *svc,
 	svc->num_dests--;
 
 	if (dest->af != svc->af)
-		net_ipvs(svc->net)->mixed_address_family_dests--;
+		svc->ipvs->mixed_address_family_dests--;
 
 	if (svcupd) {
 		struct ip_vs_scheduler *sched;
@@ -1120,7 +1122,7 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	/*
 	 *	Delete the destination
 	 */
-	__ip_vs_del_dest(svc->net, dest, false);
+	__ip_vs_del_dest(svc->ipvs->net, dest, false);
 
 	LeaveFunction(2);
 
@@ -1237,7 +1239,7 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 	svc->flags = u->flags;
 	svc->timeout = u->timeout * HZ;
 	svc->netmask = u->netmask;
-	svc->net = net;
+	svc->ipvs = ipvs;
 
 	INIT_LIST_HEAD(&svc->destinations);
 	spin_lock_init(&svc->sched_lock);
@@ -1381,7 +1383,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
 	struct ip_vs_dest *dest, *nxt;
 	struct ip_vs_scheduler *old_sched;
 	struct ip_vs_pe *old_pe;
-	struct netns_ipvs *ipvs = net_ipvs(svc->net);
+	struct netns_ipvs *ipvs = svc->ipvs;
 
 	pr_info("%s: enter\n", __func__);
 
@@ -1389,7 +1391,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
 	if (svc->af == AF_INET)
 		ipvs->num_services--;
 
-	ip_vs_stop_estimator(svc->net, &svc->stats);
+	ip_vs_stop_estimator(svc->ipvs->net, &svc->stats);
 
 	/* Unbind scheduler */
 	old_sched = rcu_dereference_protected(svc->scheduler, 1);
@@ -1405,7 +1407,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
 	 */
 	list_for_each_entry_safe(dest, nxt, &svc->destinations, n_list) {
 		__ip_vs_unlink_dest(svc, dest, 0);
-		__ip_vs_del_dest(svc->net, dest, cleanup);
+		__ip_vs_del_dest(svc->ipvs->net, dest, cleanup);
 	}
 
 	/*
@@ -1458,6 +1460,7 @@ static int ip_vs_del_service(struct ip_vs_service *svc)
  */
 static int ip_vs_flush(struct net *net, bool cleanup)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	int idx;
 	struct ip_vs_service *svc;
 	struct hlist_node *n;
@@ -1468,7 +1471,7 @@ static int ip_vs_flush(struct net *net, bool cleanup)
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		hlist_for_each_entry_safe(svc, n, &ip_vs_svc_table[idx],
 					  s_list) {
-			if (net_eq(svc->net, net))
+			if (svc->ipvs == ipvs)
 				ip_vs_unlink_service(svc, cleanup);
 		}
 	}
@@ -1479,7 +1482,7 @@ static int ip_vs_flush(struct net *net, bool cleanup)
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		hlist_for_each_entry_safe(svc, n, &ip_vs_svc_fwm_table[idx],
 					  f_list) {
-			if (net_eq(svc->net, net))
+			if (svc->ipvs == ipvs)
 				ip_vs_unlink_service(svc, cleanup);
 		}
 	}
@@ -1540,7 +1543,7 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 	mutex_lock(&__ip_vs_mutex);
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		hlist_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
-			if (net_eq(svc->net, net)) {
+			if (svc->ipvs == ipvs) {
 				list_for_each_entry(dest, &svc->destinations,
 						    n_list) {
 					ip_vs_forget_dev(dest, dev);
@@ -1549,7 +1552,7 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 		}
 
 		hlist_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
-			if (net_eq(svc->net, net)) {
+			if (svc->ipvs == ipvs) {
 				list_for_each_entry(dest, &svc->destinations,
 						    n_list) {
 					ip_vs_forget_dev(dest, dev);
@@ -1585,24 +1588,25 @@ static int ip_vs_zero_service(struct ip_vs_service *svc)
 
 static int ip_vs_zero_all(struct net *net)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	int idx;
 	struct ip_vs_service *svc;
 
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		hlist_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
-			if (net_eq(svc->net, net))
+			if (svc->ipvs == ipvs)
 				ip_vs_zero_service(svc);
 		}
 	}
 
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		hlist_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
-			if (net_eq(svc->net, net))
+			if (svc->ipvs == ipvs)
 				ip_vs_zero_service(svc);
 		}
 	}
 
-	ip_vs_zero_stats(&net_ipvs(net)->tot_stats);
+	ip_vs_zero_stats(&ipvs->tot_stats);
 	return 0;
 }
 
@@ -1901,6 +1905,7 @@ static inline const char *ip_vs_fwd_name(unsigned int flags)
 static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
 {
 	struct net *net = seq_file_net(seq);
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_iter *iter = seq->private;
 	int idx;
 	struct ip_vs_service *svc;
@@ -1908,7 +1913,7 @@ static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
 	/* look in hash by protocol */
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		hlist_for_each_entry_rcu(svc, &ip_vs_svc_table[idx], s_list) {
-			if (net_eq(svc->net, net) && pos-- == 0) {
+			if ((svc->ipvs == ipvs) && pos-- == 0) {
 				iter->table = ip_vs_svc_table;
 				iter->bucket = idx;
 				return svc;
@@ -1920,7 +1925,7 @@ static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		hlist_for_each_entry_rcu(svc, &ip_vs_svc_fwm_table[idx],
 					 f_list) {
-			if (net_eq(svc->net, net) && pos-- == 0) {
+			if ((svc->ipvs == ipvs) && pos-- == 0) {
 				iter->table = ip_vs_svc_fwm_table;
 				iter->bucket = idx;
 				return svc;
@@ -2487,6 +2492,7 @@ __ip_vs_get_service_entries(struct net *net,
 			    const struct ip_vs_get_services *get,
 			    struct ip_vs_get_services __user *uptr)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	int idx, count=0;
 	struct ip_vs_service *svc;
 	struct ip_vs_service_entry entry;
@@ -2495,7 +2501,7 @@ __ip_vs_get_service_entries(struct net *net,
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		hlist_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
 			/* Only expose IPv4 entries to old interface */
-			if (svc->af != AF_INET || !net_eq(svc->net, net))
+			if (svc->af != AF_INET || (svc->ipvs != ipvs))
 				continue;
 
 			if (count >= get->num_services)
@@ -2514,7 +2520,7 @@ __ip_vs_get_service_entries(struct net *net,
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		hlist_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
 			/* Only expose IPv4 entries to old interface */
-			if (svc->af != AF_INET || !net_eq(svc->net, net))
+			if (svc->af != AF_INET || (svc->ipvs != ipvs))
 				continue;
 
 			if (count >= get->num_services)
@@ -3008,12 +3014,12 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 	int idx = 0, i;
 	int start = cb->args[0];
 	struct ip_vs_service *svc;
-	struct net *net = skb_sknet(skb);
+	struct netns_ipvs *ipvs = net_ipvs(skb_sknet(skb));
 
 	mutex_lock(&__ip_vs_mutex);
 	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
 		hlist_for_each_entry(svc, &ip_vs_svc_table[i], s_list) {
-			if (++idx <= start || !net_eq(svc->net, net))
+			if (++idx <= start || (svc->ipvs != ipvs))
 				continue;
 			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
 				idx--;
@@ -3024,7 +3030,7 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 
 	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
 		hlist_for_each_entry(svc, &ip_vs_svc_fwm_table[i], f_list) {
-			if (++idx <= start || !net_eq(svc->net, net))
+			if (++idx <= start || (svc->ipvs != ipvs))
 				continue;
 			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
 				idx--;
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 127f14046c51..cccf4d637412 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -250,8 +250,7 @@ static void ip_vs_lblc_flush(struct ip_vs_service *svc)
 static int sysctl_lblc_expiration(struct ip_vs_service *svc)
 {
 #ifdef CONFIG_SYSCTL
-	struct netns_ipvs *ipvs = net_ipvs(svc->net);
-	return ipvs->sysctl_lblc_expiration;
+	return svc->ipvs->sysctl_lblc_expiration;
 #else
 	return DEFAULT_EXPIRATION;
 #endif
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 2229d2d8bbe0..796d70e47ddd 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -415,8 +415,7 @@ static void ip_vs_lblcr_flush(struct ip_vs_service *svc)
 static int sysctl_lblcr_expiration(struct ip_vs_service *svc)
 {
 #ifdef CONFIG_SYSCTL
-	struct netns_ipvs *ipvs = net_ipvs(svc->net);
-	return ipvs->sysctl_lblcr_expiration;
+	return svc->ipvs->sysctl_lblcr_expiration;
 #else
 	return DEFAULT_EXPIRATION;
 #endif
-- 
2.2.1
