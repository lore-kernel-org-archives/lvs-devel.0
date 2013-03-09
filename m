From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCHv2 net-next 13/15] ipvs: convert connection locking
Date: Sat,  9 Mar 2013 23:16:53 +0200
Message-ID: <1362863815-5898-14-git-send-email-ja@ssi.bg>
References: <1362863815-5898-1-git-send-email-ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1362863815-5898-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

	Convert __ip_vs_conntbl_lock_array as follows:

- readers that do not modify conn lists will use RCU lock
- updaters that modify lists will use spinlock_t

	Now for conn lookups we will use RCU read-side
critical section. Without using __ip_vs_conn_get such
places have access to connection fields and can
dereference some pointers like pe and pe_data plus
the ability to update timer expiration. If full access
is required we contend for reference.

	We add barrier in __ip_vs_conn_put, so that
other CPUs see the refcnt operation after other writes.

	With the introduction of ip_vs_conn_unlink()
we try to reorganize ip_vs_conn_expire(), so that
unhashing of connections that should stay more time is
avoided, even if it is for very short time.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |   12 ++
 net/netfilter/ipvs/ip_vs_conn.c |  230 +++++++++++++++++++++------------------
 2 files changed, 134 insertions(+), 108 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index b2657c1..9059360 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -620,6 +620,8 @@ struct ip_vs_conn {
 	const struct ip_vs_pe	*pe;
 	char			*pe_data;
 	__u8			pe_data_len;
+
+	struct rcu_head		rcu_head;
 };
 
 /*
@@ -1173,9 +1175,19 @@ struct ip_vs_conn * ip_vs_conn_out_get_proto(int af, const struct sk_buff *skb,
 					     const struct ip_vs_iphdr *iph,
 					     int inverse);
 
+/* Get reference to gain full access to conn.
+ * By default, RCU read-side critical sections have access only to
+ * conn fields and its PE data, see ip_vs_conn_rcu_free() for reference.
+ */
+static inline bool __ip_vs_conn_get(struct ip_vs_conn *cp)
+{
+	return atomic_inc_not_zero(&cp->refcnt);
+}
+
 /* put back the conn without restarting its timer */
 static inline void __ip_vs_conn_put(struct ip_vs_conn *cp)
 {
+	smp_mb__before_atomic_dec();
 	atomic_dec(&cp->refcnt);
 }
 extern void ip_vs_conn_put(struct ip_vs_conn *cp);
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 704e514..b0cd2be 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -79,51 +79,21 @@ static unsigned int ip_vs_conn_rnd __read_mostly;
 
 struct ip_vs_aligned_lock
 {
-	rwlock_t	l;
+	spinlock_t	l;
 } __attribute__((__aligned__(SMP_CACHE_BYTES)));
 
 /* lock array for conn table */
 static struct ip_vs_aligned_lock
 __ip_vs_conntbl_lock_array[CT_LOCKARRAY_SIZE] __cacheline_aligned;
 
-static inline void ct_read_lock(unsigned int key)
-{
-	read_lock(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
-}
-
-static inline void ct_read_unlock(unsigned int key)
-{
-	read_unlock(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
-}
-
 static inline void ct_write_lock(unsigned int key)
 {
-	write_lock(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
+	spin_lock(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
 }
 
 static inline void ct_write_unlock(unsigned int key)
 {
-	write_unlock(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
-}
-
-static inline void ct_read_lock_bh(unsigned int key)
-{
-	read_lock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
-}
-
-static inline void ct_read_unlock_bh(unsigned int key)
-{
-	read_unlock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
-}
-
-static inline void ct_write_lock_bh(unsigned int key)
-{
-	write_lock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
-}
-
-static inline void ct_write_unlock_bh(unsigned int key)
-{
-	write_unlock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
+	spin_unlock(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
 }
 
 
@@ -201,9 +171,9 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
 	spin_lock(&cp->lock);
 
 	if (!(cp->flags & IP_VS_CONN_F_HASHED)) {
-		hlist_add_head(&cp->c_list, &ip_vs_conn_tab[hash]);
 		cp->flags |= IP_VS_CONN_F_HASHED;
 		atomic_inc(&cp->refcnt);
+		hlist_add_head_rcu(&cp->c_list, &ip_vs_conn_tab[hash]);
 		ret = 1;
 	} else {
 		pr_err("%s(): request for already hashed, called from %pF\n",
@@ -220,7 +190,7 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
 
 /*
  *	UNhashes ip_vs_conn from ip_vs_conn_tab.
- *	returns bool success.
+ *	returns bool success. Caller should hold conn reference.
  */
 static inline int ip_vs_conn_unhash(struct ip_vs_conn *cp)
 {
@@ -234,7 +204,7 @@ static inline int ip_vs_conn_unhash(struct ip_vs_conn *cp)
 	spin_lock(&cp->lock);
 
 	if (cp->flags & IP_VS_CONN_F_HASHED) {
-		hlist_del(&cp->c_list);
+		hlist_del_rcu(&cp->c_list);
 		cp->flags &= ~IP_VS_CONN_F_HASHED;
 		atomic_dec(&cp->refcnt);
 		ret = 1;
@@ -247,6 +217,36 @@ static inline int ip_vs_conn_unhash(struct ip_vs_conn *cp)
 	return ret;
 }
 
+/* Try to unlink ip_vs_conn from ip_vs_conn_tab.
+ * returns bool success.
+ */
+static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
+{
+	unsigned int hash;
+	bool ret;
+
+	hash = ip_vs_conn_hashkey_conn(cp);
+
+	ct_write_lock(hash);
+	spin_lock(&cp->lock);
+
+	if (cp->flags & IP_VS_CONN_F_HASHED) {
+		ret = false;
+		/* Decrease refcnt and unlink conn only if we are last user */
+		if (atomic_cmpxchg(&cp->refcnt, 1, 0) == 1) {
+			hlist_del_rcu(&cp->c_list);
+			cp->flags &= ~IP_VS_CONN_F_HASHED;
+			ret = true;
+		}
+	} else
+		ret = atomic_read(&cp->refcnt) ? false : true;
+
+	spin_unlock(&cp->lock);
+	ct_write_unlock(hash);
+
+	return ret;
+}
+
 
 /*
  *  Gets ip_vs_conn associated with supplied parameters in the ip_vs_conn_tab.
@@ -262,9 +262,9 @@ __ip_vs_conn_in_get(const struct ip_vs_conn_param *p)
 
 	hash = ip_vs_conn_hashkey_param(p, false);
 
-	ct_read_lock(hash);
+	rcu_read_lock();
 
-	hlist_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
+	hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
 		if (cp->af == p->af &&
 		    p->cport == cp->cport && p->vport == cp->vport &&
 		    ip_vs_addr_equal(p->af, p->caddr, &cp->caddr) &&
@@ -272,14 +272,15 @@ __ip_vs_conn_in_get(const struct ip_vs_conn_param *p)
 		    ((!p->cport) ^ (!(cp->flags & IP_VS_CONN_F_NO_CPORT))) &&
 		    p->protocol == cp->protocol &&
 		    ip_vs_conn_net_eq(cp, p->net)) {
+			if (!__ip_vs_conn_get(cp))
+				continue;
 			/* HIT */
-			atomic_inc(&cp->refcnt);
-			ct_read_unlock(hash);
+			rcu_read_unlock();
 			return cp;
 		}
 	}
 
-	ct_read_unlock(hash);
+	rcu_read_unlock();
 
 	return NULL;
 }
@@ -346,14 +347,16 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
 
 	hash = ip_vs_conn_hashkey_param(p, false);
 
-	ct_read_lock(hash);
+	rcu_read_lock();
 
-	hlist_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
+	hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
 		if (!ip_vs_conn_net_eq(cp, p->net))
 			continue;
 		if (p->pe_data && p->pe->ct_match) {
-			if (p->pe == cp->pe && p->pe->ct_match(p, cp))
-				goto out;
+			if (p->pe == cp->pe && p->pe->ct_match(p, cp)) {
+				if (__ip_vs_conn_get(cp))
+					goto out;
+			}
 			continue;
 		}
 
@@ -365,15 +368,15 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
 				     p->af, p->vaddr, &cp->vaddr) &&
 		    p->cport == cp->cport && p->vport == cp->vport &&
 		    cp->flags & IP_VS_CONN_F_TEMPLATE &&
-		    p->protocol == cp->protocol)
-			goto out;
+		    p->protocol == cp->protocol) {
+			if (__ip_vs_conn_get(cp))
+				goto out;
+		}
 	}
 	cp = NULL;
 
   out:
-	if (cp)
-		atomic_inc(&cp->refcnt);
-	ct_read_unlock(hash);
+	rcu_read_unlock();
 
 	IP_VS_DBG_BUF(9, "template lookup/in %s %s:%d->%s:%d %s\n",
 		      ip_vs_proto_name(p->protocol),
@@ -398,23 +401,24 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
 	 */
 	hash = ip_vs_conn_hashkey_param(p, true);
 
-	ct_read_lock(hash);
+	rcu_read_lock();
 
-	hlist_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
+	hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
 		if (cp->af == p->af &&
 		    p->vport == cp->cport && p->cport == cp->dport &&
 		    ip_vs_addr_equal(p->af, p->vaddr, &cp->caddr) &&
 		    ip_vs_addr_equal(p->af, p->caddr, &cp->daddr) &&
 		    p->protocol == cp->protocol &&
 		    ip_vs_conn_net_eq(cp, p->net)) {
+			if (!__ip_vs_conn_get(cp))
+				continue;
 			/* HIT */
-			atomic_inc(&cp->refcnt);
 			ret = cp;
 			break;
 		}
 	}
 
-	ct_read_unlock(hash);
+	rcu_read_unlock();
 
 	IP_VS_DBG_BUF(9, "lookup/out %s %s:%d->%s:%d %s\n",
 		      ip_vs_proto_name(p->protocol),
@@ -757,41 +761,36 @@ int ip_vs_check_template(struct ip_vs_conn *ct)
 		 * Simply decrease the refcnt of the template,
 		 * don't restart its timer.
 		 */
-		atomic_dec(&ct->refcnt);
+		__ip_vs_conn_put(ct);
 		return 0;
 	}
 	return 1;
 }
 
+static void ip_vs_conn_rcu_free(struct rcu_head *head)
+{
+	struct ip_vs_conn *cp = container_of(head, struct ip_vs_conn,
+					     rcu_head);
+
+	ip_vs_pe_put(cp->pe);
+	kfree(cp->pe_data);
+	kmem_cache_free(ip_vs_conn_cachep, cp);
+}
+
 static void ip_vs_conn_expire(unsigned long data)
 {
 	struct ip_vs_conn *cp = (struct ip_vs_conn *)data;
 	struct net *net = ip_vs_conn_net(cp);
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	cp->timeout = 60*HZ;
-
-	/*
-	 *	hey, I'm using it
-	 */
-	atomic_inc(&cp->refcnt);
-
 	/*
 	 *	do I control anybody?
 	 */
 	if (atomic_read(&cp->n_control))
 		goto expire_later;
 
-	/*
-	 *	unhash it if it is hashed in the conn table
-	 */
-	if (!ip_vs_conn_unhash(cp) && !(cp->flags & IP_VS_CONN_F_ONE_PACKET))
-		goto expire_later;
-
-	/*
-	 *	refcnt==1 implies I'm the only one referrer
-	 */
-	if (likely(atomic_read(&cp->refcnt) == 1)) {
+	/* Unlink conn if not referenced anymore */
+	if (likely(ip_vs_conn_unlink(cp))) {
 		/* delete the timer if it is activated by other users */
 		del_timer(&cp->timer);
 
@@ -810,38 +809,41 @@ static void ip_vs_conn_expire(unsigned long data)
 				ip_vs_conn_drop_conntrack(cp);
 		}
 
-		ip_vs_pe_put(cp->pe);
-		kfree(cp->pe_data);
 		if (unlikely(cp->app != NULL))
 			ip_vs_unbind_app(cp);
 		ip_vs_unbind_dest(cp);
 		if (cp->flags & IP_VS_CONN_F_NO_CPORT)
 			atomic_dec(&ip_vs_conn_no_cport_cnt);
+		call_rcu(&cp->rcu_head, ip_vs_conn_rcu_free);
 		atomic_dec(&ipvs->conn_count);
-
-		kmem_cache_free(ip_vs_conn_cachep, cp);
 		return;
 	}
 
-	/* hash it back to the table */
-	ip_vs_conn_hash(cp);
-
   expire_later:
-	IP_VS_DBG(7, "delayed: conn->refcnt-1=%d conn->n_control=%d\n",
-		  atomic_read(&cp->refcnt)-1,
+	IP_VS_DBG(7, "delayed: conn->refcnt=%d conn->n_control=%d\n",
+		  atomic_read(&cp->refcnt),
 		  atomic_read(&cp->n_control));
 
+	atomic_inc(&cp->refcnt);
+	cp->timeout = 60*HZ;
+
 	if (ipvs->sync_state & IP_VS_STATE_MASTER)
 		ip_vs_sync_conn(net, cp, sysctl_sync_threshold(ipvs));
 
 	ip_vs_conn_put(cp);
 }
 
-
+/* Modify timer, so that it expires as soon as possible.
+ * Can be called without reference only if under RCU lock.
+ */
 void ip_vs_conn_expire_now(struct ip_vs_conn *cp)
 {
-	if (del_timer(&cp->timer))
-		mod_timer(&cp->timer, jiffies);
+	/* Using mod_timer_pending will ensure the timer is not
+	 * modified after the final del_timer in ip_vs_conn_expire.
+	 */
+	if (timer_pending(&cp->timer) &&
+	    time_after(cp->timer.expires, jiffies))
+		mod_timer_pending(&cp->timer, jiffies);
 }
 
 
@@ -952,14 +954,17 @@ static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
 	struct ip_vs_iter_state *iter = seq->private;
 
 	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
-		ct_read_lock_bh(idx);
-		hlist_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
+			/* __ip_vs_conn_get() is not needed by
+			 * ip_vs_conn_seq_show and ip_vs_conn_sync_seq_show
+			 */
 			if (pos-- == 0) {
 				iter->l = &ip_vs_conn_tab[idx];
 				return cp;
 			}
 		}
-		ct_read_unlock_bh(idx);
+		rcu_read_unlock();
 	}
 
 	return NULL;
@@ -977,6 +982,7 @@ static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct ip_vs_conn *cp = v;
 	struct ip_vs_iter_state *iter = seq->private;
+	struct hlist_node *e;
 	struct hlist_head *l = iter->l;
 	int idx;
 
@@ -985,19 +991,19 @@ static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 		return ip_vs_conn_array(seq, 0);
 
 	/* more on same hash chain? */
-	if (cp->c_list.next)
-		return hlist_entry(cp->c_list.next, struct ip_vs_conn, c_list);
+	e = rcu_dereference(hlist_next_rcu(&cp->c_list));
+	if (e)
+		return hlist_entry(e, struct ip_vs_conn, c_list);
+	rcu_read_unlock();
 
 	idx = l - ip_vs_conn_tab;
-	ct_read_unlock_bh(idx);
-
 	while (++idx < ip_vs_conn_tab_size) {
-		ct_read_lock_bh(idx);
-		hlist_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
 			iter->l = &ip_vs_conn_tab[idx];
 			return cp;
 		}
-		ct_read_unlock_bh(idx);
+		rcu_read_unlock();
 	}
 	iter->l = NULL;
 	return NULL;
@@ -1009,7 +1015,7 @@ static void ip_vs_conn_seq_stop(struct seq_file *seq, void *v)
 	struct hlist_head *l = iter->l;
 
 	if (l)
-		ct_read_unlock_bh(l - ip_vs_conn_tab);
+		rcu_read_unlock();
 }
 
 static int ip_vs_conn_seq_show(struct seq_file *seq, void *v)
@@ -1188,7 +1194,7 @@ static inline int todrop_entry(struct ip_vs_conn *cp)
 void ip_vs_random_dropentry(struct net *net)
 {
 	int idx;
-	struct ip_vs_conn *cp;
+	struct ip_vs_conn *cp, *cp_c;
 
 	/*
 	 * Randomly scan 1/32 of the whole table every second
@@ -1199,9 +1205,9 @@ void ip_vs_random_dropentry(struct net *net)
 		/*
 		 *  Lock is actually needed in this loop.
 		 */
-		ct_write_lock_bh(hash);
+		rcu_read_lock();
 
-		hlist_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
+		hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
 			if (cp->flags & IP_VS_CONN_F_TEMPLATE)
 				/* connection template */
 				continue;
@@ -1228,12 +1234,15 @@ void ip_vs_random_dropentry(struct net *net)
 
 			IP_VS_DBG(4, "del connection\n");
 			ip_vs_conn_expire_now(cp);
-			if (cp->control) {
+			cp_c = cp->control;
+			/* cp->control is valid only with reference to cp */
+			if (cp_c && __ip_vs_conn_get(cp)) {
 				IP_VS_DBG(4, "del conn template\n");
-				ip_vs_conn_expire_now(cp->control);
+				ip_vs_conn_expire_now(cp_c);
+				__ip_vs_conn_put(cp);
 			}
 		}
-		ct_write_unlock_bh(hash);
+		rcu_read_unlock();
 	}
 }
 
@@ -1244,7 +1253,7 @@ void ip_vs_random_dropentry(struct net *net)
 static void ip_vs_conn_flush(struct net *net)
 {
 	int idx;
-	struct ip_vs_conn *cp;
+	struct ip_vs_conn *cp, *cp_c;
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 flush_again:
@@ -1252,19 +1261,22 @@ flush_again:
 		/*
 		 *  Lock is actually needed in this loop.
 		 */
-		ct_write_lock_bh(idx);
+		rcu_read_lock();
 
-		hlist_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
+		hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
 			if (!ip_vs_conn_net_eq(cp, net))
 				continue;
 			IP_VS_DBG(4, "del connection\n");
 			ip_vs_conn_expire_now(cp);
-			if (cp->control) {
+			cp_c = cp->control;
+			/* cp->control is valid only with reference to cp */
+			if (cp_c && __ip_vs_conn_get(cp)) {
 				IP_VS_DBG(4, "del conn template\n");
-				ip_vs_conn_expire_now(cp->control);
+				ip_vs_conn_expire_now(cp_c);
+				__ip_vs_conn_put(cp);
 			}
 		}
-		ct_write_unlock_bh(idx);
+		rcu_read_unlock();
 	}
 
 	/* the counter may be not NULL, because maybe some conn entries
@@ -1331,7 +1343,7 @@ int __init ip_vs_conn_init(void)
 		INIT_HLIST_HEAD(&ip_vs_conn_tab[idx]);
 
 	for (idx = 0; idx < CT_LOCKARRAY_SIZE; idx++)  {
-		rwlock_init(&__ip_vs_conntbl_lock_array[idx].l);
+		spin_lock_init(&__ip_vs_conntbl_lock_array[idx].l);
 	}
 
 	/* calculate the random value for connection hash */
@@ -1342,6 +1354,8 @@ int __init ip_vs_conn_init(void)
 
 void ip_vs_conn_cleanup(void)
 {
+	/* Wait all ip_vs_conn_rcu_free() callbacks to complete */
+	rcu_barrier();
 	/* Release the empty cache */
 	kmem_cache_destroy(ip_vs_conn_cachep);
 	vfree(ip_vs_conn_tab);
-- 
1.7.3.4
