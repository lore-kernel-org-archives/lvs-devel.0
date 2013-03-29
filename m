From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 20/34] ipvs: convert lblc scheduler to rcu
Date: Fri, 29 Mar 2013 13:11:37 +0900
Message-ID: <1364530311-11512-21-git-send-email-horms@verge.net.au>
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
removed. Use a dead flag to prevent new entries to be created
while scheduler is reclaimed. Use hlist for the hash table.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_lblc.c |   96 ++++++++++++++++++++++-----------------
 1 file changed, 55 insertions(+), 41 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index fdd89b9..b873e17 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -90,11 +90,12 @@
  *      IP address and its destination server
  */
 struct ip_vs_lblc_entry {
-	struct list_head        list;
+	struct hlist_node	list;
 	int			af;		/* address family */
 	union nf_inet_addr      addr;           /* destination IP address */
-	struct ip_vs_dest       *dest;          /* real server (cache) */
+	struct ip_vs_dest __rcu	*dest;          /* real server (cache) */
 	unsigned long           lastuse;        /* last used time */
+	struct rcu_head		rcu_head;
 };
 
 
@@ -102,12 +103,14 @@ struct ip_vs_lblc_entry {
  *      IPVS lblc hash table
  */
 struct ip_vs_lblc_table {
-	struct list_head        bucket[IP_VS_LBLC_TAB_SIZE];  /* hash bucket */
+	struct rcu_head		rcu_head;
+	struct hlist_head __rcu bucket[IP_VS_LBLC_TAB_SIZE];  /* hash bucket */
+	struct timer_list       periodic_timer; /* collect stale entries */
 	atomic_t                entries;        /* number of entries */
 	int                     max_size;       /* maximum size of entries */
-	struct timer_list       periodic_timer; /* collect stale entries */
 	int                     rover;          /* rover for expire check */
 	int                     counter;        /* counter for no expire */
+	bool			dead;
 };
 
 
@@ -129,13 +132,16 @@ static ctl_table vs_vars_table[] = {
 
 static inline void ip_vs_lblc_free(struct ip_vs_lblc_entry *en)
 {
-	list_del(&en->list);
+	struct ip_vs_dest *dest;
+
+	hlist_del_rcu(&en->list);
 	/*
 	 * We don't kfree dest because it is referred either by its service
 	 * or the trash dest list.
 	 */
-	atomic_dec(&en->dest->refcnt);
-	kfree(en);
+	dest = rcu_dereference_protected(en->dest, 1);
+	ip_vs_dest_put(dest);
+	kfree_rcu(en, rcu_head);
 }
 
 
@@ -165,15 +171,12 @@ ip_vs_lblc_hash(struct ip_vs_lblc_table *tbl, struct ip_vs_lblc_entry *en)
 {
 	unsigned int hash = ip_vs_lblc_hashkey(en->af, &en->addr);
 
-	list_add(&en->list, &tbl->bucket[hash]);
+	hlist_add_head_rcu(&en->list, &tbl->bucket[hash]);
 	atomic_inc(&tbl->entries);
 }
 
 
-/*
- *  Get ip_vs_lblc_entry associated with supplied parameters. Called under read
- *  lock
- */
+/* Get ip_vs_lblc_entry associated with supplied parameters. */
 static inline struct ip_vs_lblc_entry *
 ip_vs_lblc_get(int af, struct ip_vs_lblc_table *tbl,
 	       const union nf_inet_addr *addr)
@@ -181,7 +184,7 @@ ip_vs_lblc_get(int af, struct ip_vs_lblc_table *tbl,
 	unsigned int hash = ip_vs_lblc_hashkey(af, addr);
 	struct ip_vs_lblc_entry *en;
 
-	list_for_each_entry(en, &tbl->bucket[hash], list)
+	hlist_for_each_entry_rcu(en, &tbl->bucket[hash], list)
 		if (ip_vs_addr_equal(af, &en->addr, addr))
 			return en;
 
@@ -209,14 +212,20 @@ ip_vs_lblc_new(struct ip_vs_lblc_table *tbl, const union nf_inet_addr *daddr,
 		ip_vs_addr_copy(dest->af, &en->addr, daddr);
 		en->lastuse = jiffies;
 
-		atomic_inc(&dest->refcnt);
-		en->dest = dest;
+		ip_vs_dest_hold(dest);
+		RCU_INIT_POINTER(en->dest, dest);
 
 		ip_vs_lblc_hash(tbl, en);
-	} else if (en->dest != dest) {
-		atomic_dec(&en->dest->refcnt);
-		atomic_inc(&dest->refcnt);
-		en->dest = dest;
+	} else {
+		struct ip_vs_dest *old_dest;
+
+		old_dest = rcu_dereference_protected(en->dest, 1);
+		if (old_dest != dest) {
+			ip_vs_dest_put(old_dest);
+			ip_vs_dest_hold(dest);
+			/* No ordering constraints for refcnt */
+			RCU_INIT_POINTER(en->dest, dest);
+		}
 	}
 
 	return en;
@@ -226,17 +235,22 @@ ip_vs_lblc_new(struct ip_vs_lblc_table *tbl, const union nf_inet_addr *daddr,
 /*
  *      Flush all the entries of the specified table.
  */
-static void ip_vs_lblc_flush(struct ip_vs_lblc_table *tbl)
+static void ip_vs_lblc_flush(struct ip_vs_service *svc)
 {
-	struct ip_vs_lblc_entry *en, *nxt;
+	struct ip_vs_lblc_table *tbl = svc->sched_data;
+	struct ip_vs_lblc_entry *en;
+	struct hlist_node *next;
 	int i;
 
+	write_lock_bh(&svc->sched_lock);
+	tbl->dead = 1;
 	for (i=0; i<IP_VS_LBLC_TAB_SIZE; i++) {
-		list_for_each_entry_safe(en, nxt, &tbl->bucket[i], list) {
+		hlist_for_each_entry_safe(en, next, &tbl->bucket[i], list) {
 			ip_vs_lblc_free(en);
 			atomic_dec(&tbl->entries);
 		}
 	}
+	write_unlock_bh(&svc->sched_lock);
 }
 
 static int sysctl_lblc_expiration(struct ip_vs_service *svc)
@@ -252,7 +266,8 @@ static int sysctl_lblc_expiration(struct ip_vs_service *svc)
 static inline void ip_vs_lblc_full_check(struct ip_vs_service *svc)
 {
 	struct ip_vs_lblc_table *tbl = svc->sched_data;
-	struct ip_vs_lblc_entry *en, *nxt;
+	struct ip_vs_lblc_entry *en;
+	struct hlist_node *next;
 	unsigned long now = jiffies;
 	int i, j;
 
@@ -260,7 +275,7 @@ static inline void ip_vs_lblc_full_check(struct ip_vs_service *svc)
 		j = (j + 1) & IP_VS_LBLC_TAB_MASK;
 
 		write_lock(&svc->sched_lock);
-		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
+		hlist_for_each_entry_safe(en, next, &tbl->bucket[j], list) {
 			if (time_before(now,
 					en->lastuse +
 					sysctl_lblc_expiration(svc)))
@@ -293,7 +308,8 @@ static void ip_vs_lblc_check_expire(unsigned long data)
 	unsigned long now = jiffies;
 	int goal;
 	int i, j;
-	struct ip_vs_lblc_entry *en, *nxt;
+	struct ip_vs_lblc_entry *en;
+	struct hlist_node *next;
 
 	if ((tbl->counter % COUNT_FOR_FULL_EXPIRATION) == 0) {
 		/* do full expiration check */
@@ -315,7 +331,7 @@ static void ip_vs_lblc_check_expire(unsigned long data)
 		j = (j + 1) & IP_VS_LBLC_TAB_MASK;
 
 		write_lock(&svc->sched_lock);
-		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
+		hlist_for_each_entry_safe(en, next, &tbl->bucket[j], list) {
 			if (time_before(now, en->lastuse + ENTRY_TIMEOUT))
 				continue;
 
@@ -354,11 +370,12 @@ static int ip_vs_lblc_init_svc(struct ip_vs_service *svc)
 	 *    Initialize the hash buckets
 	 */
 	for (i=0; i<IP_VS_LBLC_TAB_SIZE; i++) {
-		INIT_LIST_HEAD(&tbl->bucket[i]);
+		INIT_HLIST_HEAD(&tbl->bucket[i]);
 	}
 	tbl->max_size = IP_VS_LBLC_TAB_SIZE*16;
 	tbl->rover = 0;
 	tbl->counter = 1;
+	tbl->dead = 0;
 
 	/*
 	 *    Hook periodic timer for garbage collection
@@ -379,10 +396,10 @@ static int ip_vs_lblc_done_svc(struct ip_vs_service *svc)
 	del_timer_sync(&tbl->periodic_timer);
 
 	/* got to clean up table entries here */
-	ip_vs_lblc_flush(tbl);
+	ip_vs_lblc_flush(svc);
 
 	/* release the table itself */
-	kfree(tbl);
+	kfree_rcu(tbl, rcu_head);
 	IP_VS_DBG(6, "LBLC hash table (memory=%Zdbytes) released\n",
 		  sizeof(*tbl));
 
@@ -408,7 +425,7 @@ __ip_vs_lblc_schedule(struct ip_vs_service *svc)
 	 * The server with weight=0 is quiesced and will not receive any
 	 * new connection.
 	 */
-	list_for_each_entry(dest, &svc->destinations, n_list) {
+	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 		if (atomic_read(&dest->weight) > 0) {
@@ -423,7 +440,7 @@ __ip_vs_lblc_schedule(struct ip_vs_service *svc)
 	 *    Find the destination with the least load.
 	 */
   nextstage:
-	list_for_each_entry_continue(dest, &svc->destinations, n_list) {
+	list_for_each_entry_continue_rcu(dest, &svc->destinations, n_list) {
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 
@@ -457,7 +474,7 @@ is_overloaded(struct ip_vs_dest *dest, struct ip_vs_service *svc)
 	if (atomic_read(&dest->activeconns) > atomic_read(&dest->weight)) {
 		struct ip_vs_dest *d;
 
-		list_for_each_entry(d, &svc->destinations, n_list) {
+		list_for_each_entry_rcu(d, &svc->destinations, n_list) {
 			if (atomic_read(&d->activeconns)*2
 			    < atomic_read(&d->weight)) {
 				return 1;
@@ -484,7 +501,6 @@ ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
 	/* First look in our cache */
-	read_lock(&svc->sched_lock);
 	en = ip_vs_lblc_get(svc->af, tbl, &iph.daddr);
 	if (en) {
 		/* We only hold a read lock, but this is atomic */
@@ -499,14 +515,11 @@ ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		 * free up entries from the trash at any time.
 		 */
 
-		if (en->dest->flags & IP_VS_DEST_F_AVAILABLE)
-			dest = en->dest;
+		dest = rcu_dereference(en->dest);
+		if ((dest->flags & IP_VS_DEST_F_AVAILABLE) &&
+		    atomic_read(&dest->weight) > 0 && !is_overloaded(dest, svc))
+			goto out;
 	}
-	read_unlock(&svc->sched_lock);
-
-	/* If the destination has a weight and is not overloaded, use it */
-	if (dest && atomic_read(&dest->weight) > 0 && !is_overloaded(dest, svc))
-		goto out;
 
 	/* No cache entry or it is invalid, time to schedule */
 	dest = __ip_vs_lblc_schedule(svc);
@@ -517,7 +530,8 @@ ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 
 	/* If we fail to create a cache entry, we'll just use the valid dest */
 	write_lock(&svc->sched_lock);
-	ip_vs_lblc_new(tbl, &iph.daddr, dest);
+	if (!tbl->dead)
+		ip_vs_lblc_new(tbl, &iph.daddr, dest);
 	write_unlock(&svc->sched_lock);
 
 out:
-- 
1.7.10.4

