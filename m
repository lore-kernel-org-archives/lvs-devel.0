From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 14/19] ipvs: reorganize dest trash
Date: Fri, 22 Mar 2013 11:46:49 +0200
Message-ID: <1363945614-11752-15-git-send-email-ja@ssi.bg>
References: <1363945614-11752-1-git-send-email-ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1363945614-11752-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

	All dests will go to trash, no exceptions.
But we have to use new list node t_list for this, due
to RCU changes in following patches. Dests will wait there
initial grace period and later all conns and schedulers to
put their reference. The dests don't get reference for
staying in dest trash as before.

	As result, we do not load ip_vs_dest_put with
extra checks for last refcnt and the schedulers do not
need to play games with atomic_inc_not_zero while
selecting best destination.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h            |    9 ++
 net/netfilter/ipvs/ip_vs_ctl.c |  178 +++++++++++++++++++++++-----------------
 2 files changed, 113 insertions(+), 74 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 2752c86..76747d9 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -749,6 +749,8 @@ struct ip_vs_dest_dst {
 	struct rcu_head		rcu_head;
 };
 
+/* In grace period after removing */
+#define IP_VS_DEST_STATE_REMOVING	0x01
 /*
  *	The real server destination forwarding entry
  *	with ip address, port number, and so on.
@@ -766,6 +768,7 @@ struct ip_vs_dest {
 
 	atomic_t		refcnt;		/* reference counter */
 	struct ip_vs_stats      stats;          /* statistics */
+	unsigned long		state;		/* state flags */
 
 	/* connection counters and thresholds */
 	atomic_t		activeconns;	/* active connections */
@@ -785,6 +788,7 @@ struct ip_vs_dest {
 	union nf_inet_addr	vaddr;		/* virtual IP address */
 	__u32			vfwmark;	/* firewall mark of service */
 
+	struct list_head	t_list;		/* in dest_trash */
 	struct rcu_head		rcu_head;
 	unsigned int		in_rs_table:1;	/* we are in rs_table */
 };
@@ -912,6 +916,9 @@ struct ipvs_master_sync_state {
 	struct netns_ipvs	*ipvs;
 };
 
+/* How much time to keep dests in trash */
+#define IP_VS_DEST_TRASH_PERIOD		(120 * HZ)
+
 /* IPVS in network namespace */
 struct netns_ipvs {
 	int			gen;		/* Generation */
@@ -961,6 +968,8 @@ struct netns_ipvs {
 
 	/* Trash for destinations */
 	struct list_head	dest_trash;
+	spinlock_t		dest_trash_lock;
+	struct timer_list	dest_trash_timer; /* expiration timer */
 	/* Service counters */
 	atomic_t		ftpsvc_counter;
 	atomic_t		nullsvc_counter;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 36d9cd8..a6c206f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -71,7 +71,7 @@ int ip_vs_get_debug_level(void)
 
 
 /*  Protos */
-static void __ip_vs_del_service(struct ip_vs_service *svc);
+static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup);
 
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -655,19 +655,25 @@ static struct ip_vs_dest *
 ip_vs_trash_get_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
 		     __be16 dport)
 {
-	struct ip_vs_dest *dest, *nxt;
+	struct ip_vs_dest *dest;
 	struct netns_ipvs *ipvs = net_ipvs(svc->net);
 
 	/*
 	 * Find the destination in trash
 	 */
-	list_for_each_entry_safe(dest, nxt, &ipvs->dest_trash, n_list) {
+	spin_lock_bh(&ipvs->dest_trash_lock);
+	list_for_each_entry(dest, &ipvs->dest_trash, t_list) {
 		IP_VS_DBG_BUF(3, "Destination %u/%s:%u still in trash, "
 			      "dest->refcnt=%d\n",
 			      dest->vfwmark,
 			      IP_VS_DBG_ADDR(svc->af, &dest->addr),
 			      ntohs(dest->port),
 			      atomic_read(&dest->refcnt));
+		/* We can not reuse dest while in grace period
+		 * because conns still can use dest->svc
+		 */
+		if (test_bit(IP_VS_DEST_STATE_REMOVING, &dest->state))
+			continue;
 		if (dest->af == svc->af &&
 		    ip_vs_addr_equal(svc->af, &dest->addr, daddr) &&
 		    dest->port == dport &&
@@ -677,29 +683,27 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
 		     (ip_vs_addr_equal(svc->af, &dest->vaddr, &svc->addr) &&
 		      dest->vport == svc->port))) {
 			/* HIT */
-			return dest;
-		}
-
-		/*
-		 * Try to purge the destination from trash if not referenced
-		 */
-		if (atomic_read(&dest->refcnt) == 1) {
-			IP_VS_DBG_BUF(3, "Removing destination %u/%s:%u "
-				      "from trash\n",
-				      dest->vfwmark,
-				      IP_VS_DBG_ADDR(svc->af, &dest->addr),
-				      ntohs(dest->port));
-			list_del(&dest->n_list);
-			__ip_vs_dst_cache_reset(dest);
-			__ip_vs_unbind_svc(dest);
-			free_percpu(dest->stats.cpustats);
-			kfree_rcu(dest, rcu_head);
+			list_del(&dest->t_list);
+			ip_vs_dest_hold(dest);
+			goto out;
 		}
 	}
 
-	return NULL;
+	dest = NULL;
+
+out:
+	spin_unlock_bh(&ipvs->dest_trash_lock);
+
+	return dest;
 }
 
+static void ip_vs_dest_free(struct ip_vs_dest *dest)
+{
+	__ip_vs_dst_cache_reset(dest);
+	__ip_vs_unbind_svc(dest);
+	free_percpu(dest->stats.cpustats);
+	kfree(dest);
+}
 
 /*
  *  Clean up all the destinations in the trash
@@ -708,19 +712,18 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
  *  When the ip_vs_control_clearup is activated by ipvs module exit,
  *  the service tables must have been flushed and all the connections
  *  are expired, and the refcnt of each destination in the trash must
- *  be 1, so we simply release them here.
+ *  be 0, so we simply release them here.
  */
 static void ip_vs_trash_cleanup(struct net *net)
 {
 	struct ip_vs_dest *dest, *nxt;
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	list_for_each_entry_safe(dest, nxt, &ipvs->dest_trash, n_list) {
-		list_del(&dest->n_list);
-		__ip_vs_dst_cache_reset(dest);
-		__ip_vs_unbind_svc(dest);
-		free_percpu(dest->stats.cpustats);
-		kfree_rcu(dest, rcu_head);
+	del_timer_sync(&ipvs->dest_trash_timer);
+	/* No need to use dest_trash_lock */
+	list_for_each_entry_safe(dest, nxt, &ipvs->dest_trash, t_list) {
+		list_del(&dest->t_list);
+		ip_vs_dest_free(dest);
 	}
 }
 
@@ -953,11 +956,6 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 			      IP_VS_DBG_ADDR(svc->af, &dest->vaddr),
 			      ntohs(dest->vport));
 
-		/*
-		 * Get the destination from the trash
-		 */
-		list_del(&dest->n_list);
-
 		__ip_vs_update_dest(svc, dest, udest, 1);
 		ret = 0;
 	} else {
@@ -1013,11 +1011,21 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	return 0;
 }
 
+static void ip_vs_dest_wait_readers(struct rcu_head *head)
+{
+	struct ip_vs_dest *dest = container_of(head, struct ip_vs_dest,
+					       rcu_head);
+
+	/* End of grace period after unlinking */
+	clear_bit(IP_VS_DEST_STATE_REMOVING, &dest->state);
+}
+
 
 /*
  *	Delete a destination (must be already unlinked from the service)
  */
-static void __ip_vs_del_dest(struct net *net, struct ip_vs_dest *dest)
+static void __ip_vs_del_dest(struct net *net, struct ip_vs_dest *dest,
+			     bool cleanup)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
@@ -1028,34 +1036,22 @@ static void __ip_vs_del_dest(struct net *net, struct ip_vs_dest *dest)
 	 */
 	ip_vs_rs_unhash(dest);
 
-	/*
-	 *  Decrease the refcnt of the dest, and free the dest
-	 *  if nobody refers to it (refcnt=0). Otherwise, throw
-	 *  the destination into the trash.
-	 */
-	if (atomic_dec_and_test(&dest->refcnt)) {
-		IP_VS_DBG_BUF(3, "Removing destination %u/%s:%u\n",
-			      dest->vfwmark,
-			      IP_VS_DBG_ADDR(dest->af, &dest->addr),
-			      ntohs(dest->port));
-		__ip_vs_dst_cache_reset(dest);
-		/* simply decrease svc->refcnt here, let the caller check
-		   and release the service if nobody refers to it.
-		   Only user context can release destination and service,
-		   and only one user context can update virtual service at a
-		   time, so the operation here is OK */
-		atomic_dec(&dest->svc->refcnt);
-		free_percpu(dest->stats.cpustats);
-		kfree_rcu(dest, rcu_head);
-	} else {
-		IP_VS_DBG_BUF(3, "Moving dest %s:%u into trash, "
-			      "dest->refcnt=%d\n",
-			      IP_VS_DBG_ADDR(dest->af, &dest->addr),
-			      ntohs(dest->port),
-			      atomic_read(&dest->refcnt));
-		list_add(&dest->n_list, &ipvs->dest_trash);
-		ip_vs_dest_hold(dest);
+	if (!cleanup) {
+		set_bit(IP_VS_DEST_STATE_REMOVING, &dest->state);
+		call_rcu(&dest->rcu_head, ip_vs_dest_wait_readers);
 	}
+
+	spin_lock_bh(&ipvs->dest_trash_lock);
+	IP_VS_DBG_BUF(3, "Moving dest %s:%u into trash, dest->refcnt=%d\n",
+		      IP_VS_DBG_ADDR(dest->af, &dest->addr), ntohs(dest->port),
+		      atomic_read(&dest->refcnt));
+	if (list_empty(&ipvs->dest_trash) && !cleanup)
+		mod_timer(&ipvs->dest_trash_timer,
+			  jiffies + IP_VS_DEST_TRASH_PERIOD);
+	/* dest lives in trash without reference */
+	list_add(&dest->t_list, &ipvs->dest_trash);
+	spin_unlock_bh(&ipvs->dest_trash_lock);
+	ip_vs_dest_put(dest);
 }
 
 
@@ -1120,13 +1116,38 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	/*
 	 *	Delete the destination
 	 */
-	__ip_vs_del_dest(svc->net, dest);
+	__ip_vs_del_dest(svc->net, dest, false);
 
 	LeaveFunction(2);
 
 	return 0;
 }
 
+static void ip_vs_dest_trash_expire(unsigned long data)
+{
+	struct net *net = (struct net *) data;
+	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct ip_vs_dest *dest, *next;
+
+	spin_lock(&ipvs->dest_trash_lock);
+	list_for_each_entry_safe(dest, next, &ipvs->dest_trash, t_list) {
+		/* Skip if dest is in grace period */
+		if (test_bit(IP_VS_DEST_STATE_REMOVING, &dest->state))
+			continue;
+		if (atomic_read(&dest->refcnt) > 0)
+			continue;
+		IP_VS_DBG_BUF(3, "Removing destination %u/%s:%u from trash\n",
+			      dest->vfwmark,
+			      IP_VS_DBG_ADDR(dest->svc->af, &dest->addr),
+			      ntohs(dest->port));
+		list_del(&dest->t_list);
+		ip_vs_dest_free(dest);
+	}
+	if (!list_empty(&ipvs->dest_trash))
+		mod_timer(&ipvs->dest_trash_timer,
+			  jiffies + IP_VS_DEST_TRASH_PERIOD);
+	spin_unlock(&ipvs->dest_trash_lock);
+}
 
 /*
  *	Add a service into the service hash table
@@ -1356,7 +1377,7 @@ out:
  *	- The service must be unlinked, unlocked and not referenced!
  *	- We are called under _bh lock
  */
-static void __ip_vs_del_service(struct ip_vs_service *svc)
+static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
 {
 	struct ip_vs_dest *dest, *nxt;
 	struct ip_vs_scheduler *old_sched;
@@ -1392,7 +1413,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc)
 	 */
 	list_for_each_entry_safe(dest, nxt, &svc->destinations, n_list) {
 		__ip_vs_unlink_dest(svc, dest, 0);
-		__ip_vs_del_dest(svc->net, dest);
+		__ip_vs_del_dest(svc->net, dest, cleanup);
 	}
 
 	/*
@@ -1422,7 +1443,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc)
 /*
  * Unlink a service from list and try to delete it if its refcnt reached 0
  */
-static void ip_vs_unlink_service(struct ip_vs_service *svc)
+static void ip_vs_unlink_service(struct ip_vs_service *svc, bool cleanup)
 {
 	/*
 	 * Unhash it from the service table
@@ -1436,7 +1457,7 @@ static void ip_vs_unlink_service(struct ip_vs_service *svc)
 	 */
 	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 0);
 
-	__ip_vs_del_service(svc);
+	__ip_vs_del_service(svc, cleanup);
 
 	write_unlock_bh(&__ip_vs_svc_lock);
 }
@@ -1448,7 +1469,7 @@ static int ip_vs_del_service(struct ip_vs_service *svc)
 {
 	if (svc == NULL)
 		return -EEXIST;
-	ip_vs_unlink_service(svc);
+	ip_vs_unlink_service(svc, false);
 
 	return 0;
 }
@@ -1457,7 +1478,7 @@ static int ip_vs_del_service(struct ip_vs_service *svc)
 /*
  *	Flush all the virtual services
  */
-static int ip_vs_flush(struct net *net)
+static int ip_vs_flush(struct net *net, bool cleanup)
 {
 	int idx;
 	struct ip_vs_service *svc, *nxt;
@@ -1469,7 +1490,7 @@ static int ip_vs_flush(struct net *net)
 		list_for_each_entry_safe(svc, nxt, &ip_vs_svc_table[idx],
 					 s_list) {
 			if (net_eq(svc->net, net))
-				ip_vs_unlink_service(svc);
+				ip_vs_unlink_service(svc, cleanup);
 		}
 	}
 
@@ -1480,7 +1501,7 @@ static int ip_vs_flush(struct net *net)
 		list_for_each_entry_safe(svc, nxt,
 					 &ip_vs_svc_fwm_table[idx], f_list) {
 			if (net_eq(svc->net, net))
-				ip_vs_unlink_service(svc);
+				ip_vs_unlink_service(svc, cleanup);
 		}
 	}
 
@@ -1496,7 +1517,7 @@ void ip_vs_service_net_cleanup(struct net *net)
 	EnterFunction(2);
 	/* Check for "full" addressed entries */
 	mutex_lock(&__ip_vs_mutex);
-	ip_vs_flush(net);
+	ip_vs_flush(net, true);
 	mutex_unlock(&__ip_vs_mutex);
 	LeaveFunction(2);
 }
@@ -1556,9 +1577,11 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 		}
 	}
 
-	list_for_each_entry(dest, &ipvs->dest_trash, n_list) {
+	spin_lock_bh(&ipvs->dest_trash_lock);
+	list_for_each_entry(dest, &ipvs->dest_trash, t_list) {
 		ip_vs_forget_dev(dest, dev);
 	}
+	spin_unlock_bh(&ipvs->dest_trash_lock);
 	mutex_unlock(&__ip_vs_mutex);
 	LeaveFunction(2);
 	return NOTIFY_DONE;
@@ -2392,7 +2415,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 
 	if (cmd == IP_VS_SO_SET_FLUSH) {
 		/* Flush the virtual service */
-		ret = ip_vs_flush(net);
+		ret = ip_vs_flush(net, false);
 		goto out_unlock;
 	} else if (cmd == IP_VS_SO_SET_TIMEOUT) {
 		/* Set timeout values for (tcp tcpfin udp) */
@@ -3401,7 +3424,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 	mutex_lock(&__ip_vs_mutex);
 
 	if (cmd == IPVS_CMD_FLUSH) {
-		ret = ip_vs_flush(net);
+		ret = ip_vs_flush(net, false);
 		goto out;
 	} else if (cmd == IPVS_CMD_SET_CONFIG) {
 		ret = ip_vs_genl_set_config(net, info->attrs);
@@ -3798,6 +3821,9 @@ int __net_init ip_vs_control_net_init(struct net *net)
 		INIT_HLIST_HEAD(&ipvs->rs_table[idx]);
 
 	INIT_LIST_HEAD(&ipvs->dest_trash);
+	spin_lock_init(&ipvs->dest_trash_lock);
+	setup_timer(&ipvs->dest_trash_timer, ip_vs_dest_trash_expire,
+		    (unsigned long) net);
 	atomic_set(&ipvs->ftpsvc_counter, 0);
 	atomic_set(&ipvs->nullsvc_counter, 0);
 
@@ -3827,6 +3853,10 @@ void __net_exit ip_vs_control_net_cleanup(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
+	/* Some dest can be in grace period even before cleanup, we have to
+	 * defer ip_vs_trash_cleanup until ip_vs_dest_wait_readers is called.
+	 */
+	rcu_barrier();
 	ip_vs_trash_cleanup(net);
 	ip_vs_stop_estimator(net, &ipvs->tot_stats);
 	ip_vs_control_net_cleanup_sysctl(net);
-- 
1.7.3.4
