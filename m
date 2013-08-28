From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net 3/4] ipvs: make the service replacement more robust
Date: Wed, 28 Aug 2013 19:29:35 +0300
Message-ID: <1377707376-4362-4-git-send-email-ja@ssi.bg>
References: <1377707376-4362-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1377707376-4362-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

commit 578bc3ef1e473a ("ipvs: reorganize dest trash") added
IP_VS_DEST_STATE_REMOVING flag and RCU callback named
ip_vs_dest_wait_readers() to keep dests and services after
removal for at least a RCU grace period. But we have the
following corner cases:

- we can not reuse the same dest if its service is removed
while IP_VS_DEST_STATE_REMOVING is still set because another dest
removal in the first grace period can not extend this period.
It can happen when ipvsadm -C && ipvsadm -R is used.

- dest->svc can be replaced but ip_vs_in_stats() and
ip_vs_out_stats() have no explicit read memory barriers
when accessing dest->svc. It can happen that dest->svc
was just freed (replaced) while we use it to update
the stats.

We solve the problems as follows:

- IP_VS_DEST_STATE_REMOVING is removed and we ensure a fixed
idle period for the dest (IP_VS_DEST_TRASH_PERIOD). idle_start
will remember when for first time after deletion we noticed
dest->refcnt=0. Later, the connections can grab a reference
while in RCU grace period but if refcnt becomes 0 we can
safely free the dest and its svc.

- dest->svc becomes RCU pointer. As result, we add explicit
RCU locking in ip_vs_in_stats() and ip_vs_out_stats().

- __ip_vs_unbind_svc is renamed to __ip_vs_svc_put(), it
now can free the service immediately or after a RCU grace
period. dest->svc is not set to NULL anymore.

	As result, unlinked dests and their services are
freed always after IP_VS_DEST_TRASH_PERIOD period, unused
services are freed after a RCU grace period.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |    6 +--
 net/netfilter/ipvs/ip_vs_core.c |   12 ++++-
 net/netfilter/ipvs/ip_vs_ctl.c  |   90 +++++++++++++++------------------------
 3 files changed, 47 insertions(+), 61 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index f0d70f0..ce3e942 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -723,8 +723,6 @@ struct ip_vs_dest_dst {
 	struct rcu_head		rcu_head;
 };
 
-/* In grace period after removing */
-#define IP_VS_DEST_STATE_REMOVING	0x01
 /*
  *	The real server destination forwarding entry
  *	with ip address, port number, and so on.
@@ -742,7 +740,7 @@ struct ip_vs_dest {
 
 	atomic_t		refcnt;		/* reference counter */
 	struct ip_vs_stats      stats;          /* statistics */
-	unsigned long		state;		/* state flags */
+	unsigned long		idle_start;	/* start time, jiffies */
 
 	/* connection counters and thresholds */
 	atomic_t		activeconns;	/* active connections */
@@ -756,7 +754,7 @@ struct ip_vs_dest {
 	struct ip_vs_dest_dst __rcu *dest_dst;	/* cached dst info */
 
 	/* for virtual service */
-	struct ip_vs_service	*svc;		/* service it belongs to */
+	struct ip_vs_service __rcu *svc;	/* service it belongs to */
 	__u16			protocol;	/* which protocol (TCP/UDP) */
 	__be16			vport;		/* virtual port number */
 	union nf_inet_addr	vaddr;		/* virtual IP address */
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 4f69e83..74fd00c 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -116,6 +116,7 @@ ip_vs_in_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 
 	if (dest && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
 		struct ip_vs_cpu_stats *s;
+		struct ip_vs_service *svc;
 
 		s = this_cpu_ptr(dest->stats.cpustats);
 		s->ustats.inpkts++;
@@ -123,11 +124,14 @@ ip_vs_in_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 		s->ustats.inbytes += skb->len;
 		u64_stats_update_end(&s->syncp);
 
-		s = this_cpu_ptr(dest->svc->stats.cpustats);
+		rcu_read_lock();
+		svc = rcu_dereference(dest->svc);
+		s = this_cpu_ptr(svc->stats.cpustats);
 		s->ustats.inpkts++;
 		u64_stats_update_begin(&s->syncp);
 		s->ustats.inbytes += skb->len;
 		u64_stats_update_end(&s->syncp);
+		rcu_read_unlock();
 
 		s = this_cpu_ptr(ipvs->tot_stats.cpustats);
 		s->ustats.inpkts++;
@@ -146,6 +150,7 @@ ip_vs_out_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 
 	if (dest && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
 		struct ip_vs_cpu_stats *s;
+		struct ip_vs_service *svc;
 
 		s = this_cpu_ptr(dest->stats.cpustats);
 		s->ustats.outpkts++;
@@ -153,11 +158,14 @@ ip_vs_out_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 		s->ustats.outbytes += skb->len;
 		u64_stats_update_end(&s->syncp);
 
-		s = this_cpu_ptr(dest->svc->stats.cpustats);
+		rcu_read_lock();
+		svc = rcu_dereference(dest->svc);
+		s = this_cpu_ptr(svc->stats.cpustats);
 		s->ustats.outpkts++;
 		u64_stats_update_begin(&s->syncp);
 		s->ustats.outbytes += skb->len;
 		u64_stats_update_end(&s->syncp);
+		rcu_read_unlock();
 
 		s = this_cpu_ptr(ipvs->tot_stats.cpustats);
 		s->ustats.outpkts++;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c8148e4..98ad387 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -460,7 +460,7 @@ static inline void
 __ip_vs_bind_svc(struct ip_vs_dest *dest, struct ip_vs_service *svc)
 {
 	atomic_inc(&svc->refcnt);
-	dest->svc = svc;
+	rcu_assign_pointer(dest->svc, svc);
 }
 
 static void ip_vs_service_free(struct ip_vs_service *svc)
@@ -470,18 +470,25 @@ static void ip_vs_service_free(struct ip_vs_service *svc)
 	kfree(svc);
 }
 
-static void
-__ip_vs_unbind_svc(struct ip_vs_dest *dest)
+static void ip_vs_service_rcu_free(struct rcu_head *head)
 {
-	struct ip_vs_service *svc = dest->svc;
+	struct ip_vs_service *svc;
 
-	dest->svc = NULL;
+	svc = container_of(head, struct ip_vs_service, rcu_head);
+	ip_vs_service_free(svc);
+}
+
+static void __ip_vs_svc_put(struct ip_vs_service *svc, bool do_delay)
+{
 	if (atomic_dec_and_test(&svc->refcnt)) {
 		IP_VS_DBG_BUF(3, "Removing service %u/%s:%u\n",
 			      svc->fwmark,
 			      IP_VS_DBG_ADDR(svc->af, &svc->addr),
 			      ntohs(svc->port));
-		ip_vs_service_free(svc);
+		if (do_delay)
+			call_rcu(&svc->rcu_head, ip_vs_service_rcu_free);
+		else
+			ip_vs_service_free(svc);
 	}
 }
 
@@ -667,11 +674,6 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
 			      IP_VS_DBG_ADDR(svc->af, &dest->addr),
 			      ntohs(dest->port),
 			      atomic_read(&dest->refcnt));
-		/* We can not reuse dest while in grace period
-		 * because conns still can use dest->svc
-		 */
-		if (test_bit(IP_VS_DEST_STATE_REMOVING, &dest->state))
-			continue;
 		if (dest->af == svc->af &&
 		    ip_vs_addr_equal(svc->af, &dest->addr, daddr) &&
 		    dest->port == dport &&
@@ -697,8 +699,10 @@ out:
 
 static void ip_vs_dest_free(struct ip_vs_dest *dest)
 {
+	struct ip_vs_service *svc = rcu_dereference_protected(dest->svc, 1);
+
 	__ip_vs_dst_cache_reset(dest);
-	__ip_vs_unbind_svc(dest);
+	__ip_vs_svc_put(svc, false);
 	free_percpu(dest->stats.cpustats);
 	kfree(dest);
 }
@@ -771,6 +775,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 		    struct ip_vs_dest_user_kern *udest, int add)
 {
 	struct netns_ipvs *ipvs = net_ipvs(svc->net);
+	struct ip_vs_service *old_svc;
 	struct ip_vs_scheduler *sched;
 	int conn_flags;
 
@@ -792,13 +797,14 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	atomic_set(&dest->conn_flags, conn_flags);
 
 	/* bind the service */
-	if (!dest->svc) {
+	old_svc = rcu_dereference_protected(dest->svc, 1);
+	if (!old_svc) {
 		__ip_vs_bind_svc(dest, svc);
 	} else {
-		if (dest->svc != svc) {
-			__ip_vs_unbind_svc(dest);
+		if (old_svc != svc) {
 			ip_vs_zero_stats(&dest->stats);
 			__ip_vs_bind_svc(dest, svc);
+			__ip_vs_svc_put(old_svc, true);
 		}
 	}
 
@@ -998,16 +1004,6 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	return 0;
 }
 
-static void ip_vs_dest_wait_readers(struct rcu_head *head)
-{
-	struct ip_vs_dest *dest = container_of(head, struct ip_vs_dest,
-					       rcu_head);
-
-	/* End of grace period after unlinking */
-	clear_bit(IP_VS_DEST_STATE_REMOVING, &dest->state);
-}
-
-
 /*
  *	Delete a destination (must be already unlinked from the service)
  */
@@ -1023,20 +1019,16 @@ static void __ip_vs_del_dest(struct net *net, struct ip_vs_dest *dest,
 	 */
 	ip_vs_rs_unhash(dest);
 
-	if (!cleanup) {
-		set_bit(IP_VS_DEST_STATE_REMOVING, &dest->state);
-		call_rcu(&dest->rcu_head, ip_vs_dest_wait_readers);
-	}
-
 	spin_lock_bh(&ipvs->dest_trash_lock);
 	IP_VS_DBG_BUF(3, "Moving dest %s:%u into trash, dest->refcnt=%d\n",
 		      IP_VS_DBG_ADDR(dest->af, &dest->addr), ntohs(dest->port),
 		      atomic_read(&dest->refcnt));
 	if (list_empty(&ipvs->dest_trash) && !cleanup)
 		mod_timer(&ipvs->dest_trash_timer,
-			  jiffies + IP_VS_DEST_TRASH_PERIOD);
+			  jiffies + (IP_VS_DEST_TRASH_PERIOD >> 1));
 	/* dest lives in trash without reference */
 	list_add(&dest->t_list, &ipvs->dest_trash);
+	dest->idle_start = 0;
 	spin_unlock_bh(&ipvs->dest_trash_lock);
 	ip_vs_dest_put(dest);
 }
@@ -1108,24 +1100,30 @@ static void ip_vs_dest_trash_expire(unsigned long data)
 	struct net *net = (struct net *) data;
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_dest *dest, *next;
+	unsigned long now = jiffies;
 
 	spin_lock(&ipvs->dest_trash_lock);
 	list_for_each_entry_safe(dest, next, &ipvs->dest_trash, t_list) {
-		/* Skip if dest is in grace period */
-		if (test_bit(IP_VS_DEST_STATE_REMOVING, &dest->state))
-			continue;
 		if (atomic_read(&dest->refcnt) > 0)
 			continue;
+		if (dest->idle_start) {
+			if (time_before(now, dest->idle_start +
+					     IP_VS_DEST_TRASH_PERIOD))
+				continue;
+		} else {
+			dest->idle_start = max(1UL, now);
+			continue;
+		}
 		IP_VS_DBG_BUF(3, "Removing destination %u/%s:%u from trash\n",
 			      dest->vfwmark,
-			      IP_VS_DBG_ADDR(dest->svc->af, &dest->addr),
+			      IP_VS_DBG_ADDR(dest->af, &dest->addr),
 			      ntohs(dest->port));
 		list_del(&dest->t_list);
 		ip_vs_dest_free(dest);
 	}
 	if (!list_empty(&ipvs->dest_trash))
 		mod_timer(&ipvs->dest_trash_timer,
-			  jiffies + IP_VS_DEST_TRASH_PERIOD);
+			  jiffies + (IP_VS_DEST_TRASH_PERIOD >> 1));
 	spin_unlock(&ipvs->dest_trash_lock);
 }
 
@@ -1320,14 +1318,6 @@ out:
 	return ret;
 }
 
-static void ip_vs_service_rcu_free(struct rcu_head *head)
-{
-	struct ip_vs_service *svc;
-
-	svc = container_of(head, struct ip_vs_service, rcu_head);
-	ip_vs_service_free(svc);
-}
-
 /*
  *	Delete a service from the service list
  *	- The service must be unlinked, unlocked and not referenced!
@@ -1376,13 +1366,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
 	/*
 	 *    Free the service if nobody refers to it
 	 */
-	if (atomic_dec_and_test(&svc->refcnt)) {
-		IP_VS_DBG_BUF(3, "Removing service %u/%s:%u\n",
-			      svc->fwmark,
-			      IP_VS_DBG_ADDR(svc->af, &svc->addr),
-			      ntohs(svc->port));
-		call_rcu(&svc->rcu_head, ip_vs_service_rcu_free);
-	}
+	__ip_vs_svc_put(svc, true);
 
 	/* decrease the module use count */
 	ip_vs_use_count_dec();
@@ -3836,10 +3820,6 @@ void __net_exit ip_vs_control_net_cleanup(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	/* Some dest can be in grace period even before cleanup, we have to
-	 * defer ip_vs_trash_cleanup until ip_vs_dest_wait_readers is called.
-	 */
-	rcu_barrier();
 	ip_vs_trash_cleanup(net);
 	ip_vs_stop_estimator(net, &ipvs->tot_stats);
 	ip_vs_control_net_cleanup_sysctl(net);
-- 
1.7.3.4

