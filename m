From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 21/34] ipvs: convert lblcr scheduler to rcu
Date: Fri, 29 Mar 2013 13:11:38 +0900
Message-ID: <1364530311-11512-22-git-send-email-horms@verge.net.au>
References: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

The schedule method now needs _rcu list-traversal
primitive for svc->destinations. The read_lock for sched_lock is
removed. The set.lock is removed because now it is used in
rare cases, mostly under sched_lock.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_lblcr.c |  171 ++++++++++++++++++++------------------
 1 file changed, 90 insertions(+), 81 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index c03b6a3..c22f173 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -89,40 +89,44 @@
  */
 struct ip_vs_dest_set_elem {
 	struct list_head	list;          /* list link */
-	struct ip_vs_dest       *dest;          /* destination server */
+	struct ip_vs_dest __rcu *dest;         /* destination server */
+	struct rcu_head		rcu_head;
 };
 
 struct ip_vs_dest_set {
 	atomic_t                size;           /* set size */
 	unsigned long           lastmod;        /* last modified time */
 	struct list_head	list;           /* destination list */
-	rwlock_t	        lock;           /* lock for this list */
 };
 
 
-static struct ip_vs_dest_set_elem *
-ip_vs_dest_set_insert(struct ip_vs_dest_set *set, struct ip_vs_dest *dest)
+static void ip_vs_dest_set_insert(struct ip_vs_dest_set *set,
+				  struct ip_vs_dest *dest, bool check)
 {
 	struct ip_vs_dest_set_elem *e;
 
-	list_for_each_entry(e, &set->list, list) {
-		if (e->dest == dest)
-			/* already existed */
-			return NULL;
+	if (check) {
+		list_for_each_entry(e, &set->list, list) {
+			struct ip_vs_dest *d;
+
+			d = rcu_dereference_protected(e->dest, 1);
+			if (d == dest)
+				/* already existed */
+				return;
+		}
 	}
 
 	e = kmalloc(sizeof(*e), GFP_ATOMIC);
 	if (e == NULL)
-		return NULL;
+		return;
 
-	atomic_inc(&dest->refcnt);
-	e->dest = dest;
+	ip_vs_dest_hold(dest);
+	RCU_INIT_POINTER(e->dest, dest);
 
-	list_add(&e->list, &set->list);
+	list_add_rcu(&e->list, &set->list);
 	atomic_inc(&set->size);
 
 	set->lastmod = jiffies;
-	return e;
 }
 
 static void
@@ -131,13 +135,16 @@ ip_vs_dest_set_erase(struct ip_vs_dest_set *set, struct ip_vs_dest *dest)
 	struct ip_vs_dest_set_elem *e;
 
 	list_for_each_entry(e, &set->list, list) {
-		if (e->dest == dest) {
+		struct ip_vs_dest *d;
+
+		d = rcu_dereference_protected(e->dest, 1);
+		if (d == dest) {
 			/* HIT */
 			atomic_dec(&set->size);
 			set->lastmod = jiffies;
-			atomic_dec(&e->dest->refcnt);
-			list_del(&e->list);
-			kfree(e);
+			ip_vs_dest_put(dest);
+			list_del_rcu(&e->list);
+			kfree_rcu(e, rcu_head);
 			break;
 		}
 	}
@@ -147,17 +154,18 @@ static void ip_vs_dest_set_eraseall(struct ip_vs_dest_set *set)
 {
 	struct ip_vs_dest_set_elem *e, *ep;
 
-	write_lock(&set->lock);
 	list_for_each_entry_safe(e, ep, &set->list, list) {
+		struct ip_vs_dest *d;
+
+		d = rcu_dereference_protected(e->dest, 1);
 		/*
 		 * We don't kfree dest because it is referred either
 		 * by its service or by the trash dest list.
 		 */
-		atomic_dec(&e->dest->refcnt);
-		list_del(&e->list);
-		kfree(e);
+		ip_vs_dest_put(d);
+		list_del_rcu(&e->list);
+		kfree_rcu(e, rcu_head);
 	}
-	write_unlock(&set->lock);
 }
 
 /* get weighted least-connection node in the destination set */
@@ -171,8 +179,8 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 		return NULL;
 
 	/* select the first destination server, whose weight > 0 */
-	list_for_each_entry(e, &set->list, list) {
-		least = e->dest;
+	list_for_each_entry_rcu(e, &set->list, list) {
+		least = rcu_dereference(e->dest);
 		if (least->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 
@@ -186,8 +194,8 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 
 	/* find the destination with the weighted least load */
   nextstage:
-	list_for_each_entry(e, &set->list, list) {
-		dest = e->dest;
+	list_for_each_entry_continue_rcu(e, &set->list, list) {
+		dest = rcu_dereference(e->dest);
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 
@@ -224,7 +232,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_max(struct ip_vs_dest_set *set)
 
 	/* select the first destination server, whose weight > 0 */
 	list_for_each_entry(e, &set->list, list) {
-		most = e->dest;
+		most = rcu_dereference_protected(e->dest, 1);
 		if (atomic_read(&most->weight) > 0) {
 			moh = ip_vs_dest_conn_overhead(most);
 			goto nextstage;
@@ -234,8 +242,8 @@ static inline struct ip_vs_dest *ip_vs_dest_set_max(struct ip_vs_dest_set *set)
 
 	/* find the destination with the weighted most load */
   nextstage:
-	list_for_each_entry(e, &set->list, list) {
-		dest = e->dest;
+	list_for_each_entry_continue(e, &set->list, list) {
+		dest = rcu_dereference_protected(e->dest, 1);
 		doh = ip_vs_dest_conn_overhead(dest);
 		/* moh/mw < doh/dw ==> moh*dw < doh*mw, where mw,dw>0 */
 		if ((moh * atomic_read(&dest->weight) <
@@ -262,11 +270,12 @@ static inline struct ip_vs_dest *ip_vs_dest_set_max(struct ip_vs_dest_set *set)
  *      IP address and its destination server set
  */
 struct ip_vs_lblcr_entry {
-	struct list_head        list;
+	struct hlist_node       list;
 	int			af;		/* address family */
 	union nf_inet_addr      addr;           /* destination IP address */
 	struct ip_vs_dest_set   set;            /* destination server set */
 	unsigned long           lastuse;        /* last used time */
+	struct rcu_head		rcu_head;
 };
 
 
@@ -274,12 +283,14 @@ struct ip_vs_lblcr_entry {
  *      IPVS lblcr hash table
  */
 struct ip_vs_lblcr_table {
-	struct list_head        bucket[IP_VS_LBLCR_TAB_SIZE];  /* hash bucket */
+	struct rcu_head		rcu_head;
+	struct hlist_head __rcu bucket[IP_VS_LBLCR_TAB_SIZE];  /* hash bucket */
 	atomic_t                entries;        /* number of entries */
 	int                     max_size;       /* maximum size of entries */
 	struct timer_list       periodic_timer; /* collect stale entries */
 	int                     rover;          /* rover for expire check */
 	int                     counter;        /* counter for no expire */
+	bool			dead;
 };
 
 
@@ -302,9 +313,9 @@ static ctl_table vs_vars_table[] = {
 
 static inline void ip_vs_lblcr_free(struct ip_vs_lblcr_entry *en)
 {
-	list_del(&en->list);
+	hlist_del_rcu(&en->list);
 	ip_vs_dest_set_eraseall(&en->set);
-	kfree(en);
+	kfree_rcu(en, rcu_head);
 }
 
 
@@ -334,15 +345,12 @@ ip_vs_lblcr_hash(struct ip_vs_lblcr_table *tbl, struct ip_vs_lblcr_entry *en)
 {
 	unsigned int hash = ip_vs_lblcr_hashkey(en->af, &en->addr);
 
-	list_add(&en->list, &tbl->bucket[hash]);
+	hlist_add_head_rcu(&en->list, &tbl->bucket[hash]);
 	atomic_inc(&tbl->entries);
 }
 
 
-/*
- *  Get ip_vs_lblcr_entry associated with supplied parameters. Called under
- *  read lock.
- */
+/* Get ip_vs_lblcr_entry associated with supplied parameters. */
 static inline struct ip_vs_lblcr_entry *
 ip_vs_lblcr_get(int af, struct ip_vs_lblcr_table *tbl,
 		const union nf_inet_addr *addr)
@@ -350,7 +358,7 @@ ip_vs_lblcr_get(int af, struct ip_vs_lblcr_table *tbl,
 	unsigned int hash = ip_vs_lblcr_hashkey(af, addr);
 	struct ip_vs_lblcr_entry *en;
 
-	list_for_each_entry(en, &tbl->bucket[hash], list)
+	hlist_for_each_entry_rcu(en, &tbl->bucket[hash], list)
 		if (ip_vs_addr_equal(af, &en->addr, addr))
 			return en;
 
@@ -381,14 +389,14 @@ ip_vs_lblcr_new(struct ip_vs_lblcr_table *tbl, const union nf_inet_addr *daddr,
 		/* initialize its dest set */
 		atomic_set(&(en->set.size), 0);
 		INIT_LIST_HEAD(&en->set.list);
-		rwlock_init(&en->set.lock);
+
+		ip_vs_dest_set_insert(&en->set, dest, false);
 
 		ip_vs_lblcr_hash(tbl, en);
+		return en;
 	}
 
-	write_lock(&en->set.lock);
-	ip_vs_dest_set_insert(&en->set, dest);
-	write_unlock(&en->set.lock);
+	ip_vs_dest_set_insert(&en->set, dest, true);
 
 	return en;
 }
@@ -397,17 +405,21 @@ ip_vs_lblcr_new(struct ip_vs_lblcr_table *tbl, const union nf_inet_addr *daddr,
 /*
  *      Flush all the entries of the specified table.
  */
-static void ip_vs_lblcr_flush(struct ip_vs_lblcr_table *tbl)
+static void ip_vs_lblcr_flush(struct ip_vs_service *svc)
 {
+	struct ip_vs_lblcr_table *tbl = svc->sched_data;
 	int i;
-	struct ip_vs_lblcr_entry *en, *nxt;
+	struct ip_vs_lblcr_entry *en;
+	struct hlist_node *next;
 
-	/* No locking required, only called during cleanup. */
+	write_lock_bh(&svc->sched_lock);
+	tbl->dead = 1;
 	for (i=0; i<IP_VS_LBLCR_TAB_SIZE; i++) {
-		list_for_each_entry_safe(en, nxt, &tbl->bucket[i], list) {
+		hlist_for_each_entry_safe(en, next, &tbl->bucket[i], list) {
 			ip_vs_lblcr_free(en);
 		}
 	}
+	write_unlock_bh(&svc->sched_lock);
 }
 
 static int sysctl_lblcr_expiration(struct ip_vs_service *svc)
@@ -425,13 +437,14 @@ static inline void ip_vs_lblcr_full_check(struct ip_vs_service *svc)
 	struct ip_vs_lblcr_table *tbl = svc->sched_data;
 	unsigned long now = jiffies;
 	int i, j;
-	struct ip_vs_lblcr_entry *en, *nxt;
+	struct ip_vs_lblcr_entry *en;
+	struct hlist_node *next;
 
 	for (i=0, j=tbl->rover; i<IP_VS_LBLCR_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLCR_TAB_MASK;
 
 		write_lock(&svc->sched_lock);
-		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
+		hlist_for_each_entry_safe(en, next, &tbl->bucket[j], list) {
 			if (time_after(en->lastuse +
 				       sysctl_lblcr_expiration(svc), now))
 				continue;
@@ -463,7 +476,8 @@ static void ip_vs_lblcr_check_expire(unsigned long data)
 	unsigned long now = jiffies;
 	int goal;
 	int i, j;
-	struct ip_vs_lblcr_entry *en, *nxt;
+	struct ip_vs_lblcr_entry *en;
+	struct hlist_node *next;
 
 	if ((tbl->counter % COUNT_FOR_FULL_EXPIRATION) == 0) {
 		/* do full expiration check */
@@ -485,7 +499,7 @@ static void ip_vs_lblcr_check_expire(unsigned long data)
 		j = (j + 1) & IP_VS_LBLCR_TAB_MASK;
 
 		write_lock(&svc->sched_lock);
-		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
+		hlist_for_each_entry_safe(en, next, &tbl->bucket[j], list) {
 			if (time_before(now, en->lastuse+ENTRY_TIMEOUT))
 				continue;
 
@@ -523,11 +537,12 @@ static int ip_vs_lblcr_init_svc(struct ip_vs_service *svc)
 	 *    Initialize the hash buckets
 	 */
 	for (i=0; i<IP_VS_LBLCR_TAB_SIZE; i++) {
-		INIT_LIST_HEAD(&tbl->bucket[i]);
+		INIT_HLIST_HEAD(&tbl->bucket[i]);
 	}
 	tbl->max_size = IP_VS_LBLCR_TAB_SIZE*16;
 	tbl->rover = 0;
 	tbl->counter = 1;
+	tbl->dead = 0;
 
 	/*
 	 *    Hook periodic timer for garbage collection
@@ -548,10 +563,10 @@ static int ip_vs_lblcr_done_svc(struct ip_vs_service *svc)
 	del_timer_sync(&tbl->periodic_timer);
 
 	/* got to clean up table entries here */
-	ip_vs_lblcr_flush(tbl);
+	ip_vs_lblcr_flush(svc);
 
 	/* release the table itself */
-	kfree(tbl);
+	kfree_rcu(tbl, rcu_head);
 	IP_VS_DBG(6, "LBLCR hash table (memory=%Zdbytes) released\n",
 		  sizeof(*tbl));
 
@@ -577,7 +592,7 @@ __ip_vs_lblcr_schedule(struct ip_vs_service *svc)
 	 * The server with weight=0 is quiesced and will not receive any
 	 * new connection.
 	 */
-	list_for_each_entry(dest, &svc->destinations, n_list) {
+	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 
@@ -593,7 +608,7 @@ __ip_vs_lblcr_schedule(struct ip_vs_service *svc)
 	 *    Find the destination with the least load.
 	 */
   nextstage:
-	list_for_each_entry_continue(dest, &svc->destinations, n_list) {
+	list_for_each_entry_continue_rcu(dest, &svc->destinations, n_list) {
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 
@@ -627,7 +642,7 @@ is_overloaded(struct ip_vs_dest *dest, struct ip_vs_service *svc)
 	if (atomic_read(&dest->activeconns) > atomic_read(&dest->weight)) {
 		struct ip_vs_dest *d;
 
-		list_for_each_entry(d, &svc->destinations, n_list) {
+		list_for_each_entry_rcu(d, &svc->destinations, n_list) {
 			if (atomic_read(&d->activeconns)*2
 			    < atomic_read(&d->weight)) {
 				return 1;
@@ -646,7 +661,7 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 {
 	struct ip_vs_lblcr_table *tbl = svc->sched_data;
 	struct ip_vs_iphdr iph;
-	struct ip_vs_dest *dest = NULL;
+	struct ip_vs_dest *dest;
 	struct ip_vs_lblcr_entry *en;
 
 	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
@@ -654,53 +669,46 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
 	/* First look in our cache */
-	read_lock(&svc->sched_lock);
 	en = ip_vs_lblcr_get(svc->af, tbl, &iph.daddr);
 	if (en) {
-		/* We only hold a read lock, but this is atomic */
 		en->lastuse = jiffies;
 
 		/* Get the least loaded destination */
-		read_lock(&en->set.lock);
 		dest = ip_vs_dest_set_min(&en->set);
-		read_unlock(&en->set.lock);
 
 		/* More than one destination + enough time passed by, cleanup */
 		if (atomic_read(&en->set.size) > 1 &&
-				time_after(jiffies, en->set.lastmod +
+		    time_after(jiffies, en->set.lastmod +
 				sysctl_lblcr_expiration(svc))) {
-			struct ip_vs_dest *m;
+			write_lock(&svc->sched_lock);
+			if (atomic_read(&en->set.size) > 1) {
+				struct ip_vs_dest *m;
 
-			write_lock(&en->set.lock);
-			m = ip_vs_dest_set_max(&en->set);
-			if (m)
-				ip_vs_dest_set_erase(&en->set, m);
-			write_unlock(&en->set.lock);
+				m = ip_vs_dest_set_max(&en->set);
+				if (m)
+					ip_vs_dest_set_erase(&en->set, m);
+			}
+			write_unlock(&svc->sched_lock);
 		}
 
 		/* If the destination is not overloaded, use it */
-		if (dest && !is_overloaded(dest, svc)) {
-			read_unlock(&svc->sched_lock);
+		if (dest && !is_overloaded(dest, svc))
 			goto out;
-		}
 
 		/* The cache entry is invalid, time to schedule */
 		dest = __ip_vs_lblcr_schedule(svc);
 		if (!dest) {
 			ip_vs_scheduler_err(svc, "no destination available");
-			read_unlock(&svc->sched_lock);
 			return NULL;
 		}
 
 		/* Update our cache entry */
-		write_lock(&en->set.lock);
-		ip_vs_dest_set_insert(&en->set, dest);
-		write_unlock(&en->set.lock);
-	}
-	read_unlock(&svc->sched_lock);
-
-	if (dest)
+		write_lock(&svc->sched_lock);
+		if (!tbl->dead)
+			ip_vs_dest_set_insert(&en->set, dest, true);
+		write_unlock(&svc->sched_lock);
 		goto out;
+	}
 
 	/* No cache entry, time to schedule */
 	dest = __ip_vs_lblcr_schedule(svc);
@@ -711,7 +719,8 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 
 	/* If we fail to create a cache entry, we'll just use the valid dest */
 	write_lock(&svc->sched_lock);
-	ip_vs_lblcr_new(tbl, &iph.daddr, dest);
+	if (!tbl->dead)
+		ip_vs_lblcr_new(tbl, &iph.daddr, dest);
 	write_unlock(&svc->sched_lock);
 
 out:
-- 
1.7.10.4

