From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH] ipvs: Fix race conditions in lblcr scheduler
Date: Mon, 18 Aug 2008 00:53:05 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0808180052160.12259@titan.stealer.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg

We can't access the cache entry outside of our critical read-locked region,
because someone may free that entry. Also getting an entry under read lock,
then locking for write and trying to delete that entry looks fishy, but should
be no problem here, because we're only comparing a pointer. Also there is no
need for our own rwlock, there is already one in the service structure for use
in the schedulers.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv4/ipvs/ip_vs_lblcr.c |  229 +++++++++++++++++++++----------------------
 1 files changed, 114 insertions(+), 115 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_lblcr.c b/net/ipv4/ipvs/ip_vs_lblcr.c
index f1c8450..96bfdc2 100644
--- a/net/ipv4/ipvs/ip_vs_lblcr.c
+++ b/net/ipv4/ipvs/ip_vs_lblcr.c
@@ -106,7 +106,7 @@ ip_vs_dest_set_insert(struct ip_vs_dest_set *set, struct ip_vs_dest *dest)
 			return NULL;
 	}
 
-	e = kmalloc(sizeof(struct ip_vs_dest_list), GFP_ATOMIC);
+	e = kmalloc(sizeof(*e), GFP_ATOMIC);
 	if (e == NULL) {
 		IP_VS_ERR("ip_vs_dest_set_insert(): no memory\n");
 		return NULL;
@@ -116,11 +116,9 @@ ip_vs_dest_set_insert(struct ip_vs_dest_set *set, struct ip_vs_dest *dest)
 	e->dest = dest;
 
 	/* link it to the list */
-	write_lock(&set->lock);
 	e->next = set->list;
 	set->list = e;
 	atomic_inc(&set->size);
-	write_unlock(&set->lock);
 
 	set->lastmod = jiffies;
 	return e;
@@ -131,7 +129,6 @@ ip_vs_dest_set_erase(struct ip_vs_dest_set *set, struct ip_vs_dest *dest)
 {
 	struct ip_vs_dest_list *e, **ep;
 
-	write_lock(&set->lock);
 	for (ep=&set->list, e=*ep; e!=NULL; e=*ep) {
 		if (e->dest == dest) {
 			/* HIT */
@@ -144,7 +141,6 @@ ip_vs_dest_set_erase(struct ip_vs_dest_set *set, struct ip_vs_dest *dest)
 		}
 		ep = &e->next;
 	}
-	write_unlock(&set->lock);
 }
 
 static void ip_vs_dest_set_eraseall(struct ip_vs_dest_set *set)
@@ -174,7 +170,6 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 	if (set == NULL)
 		return NULL;
 
-	read_lock(&set->lock);
 	/* select the first destination server, whose weight > 0 */
 	for (e=set->list; e!=NULL; e=e->next) {
 		least = e->dest;
@@ -188,7 +183,6 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 			goto nextstage;
 		}
 	}
-	read_unlock(&set->lock);
 	return NULL;
 
 	/* find the destination with the weighted least load */
@@ -207,7 +201,6 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 			loh = doh;
 		}
 	}
-	read_unlock(&set->lock);
 
 	IP_VS_DBG(6, "ip_vs_dest_set_min: server %d.%d.%d.%d:%d "
 		  "activeconns %d refcnt %d weight %d overhead %d\n",
@@ -229,7 +222,6 @@ static inline struct ip_vs_dest *ip_vs_dest_set_max(struct ip_vs_dest_set *set)
 	if (set == NULL)
 		return NULL;
 
-	read_lock(&set->lock);
 	/* select the first destination server, whose weight > 0 */
 	for (e=set->list; e!=NULL; e=e->next) {
 		most = e->dest;
@@ -239,7 +231,6 @@ static inline struct ip_vs_dest *ip_vs_dest_set_max(struct ip_vs_dest_set *set)
 			goto nextstage;
 		}
 	}
-	read_unlock(&set->lock);
 	return NULL;
 
 	/* find the destination with the weighted most load */
@@ -256,7 +247,6 @@ static inline struct ip_vs_dest *ip_vs_dest_set_max(struct ip_vs_dest_set *set)
 			moh = doh;
 		}
 	}
-	read_unlock(&set->lock);
 
 	IP_VS_DBG(6, "ip_vs_dest_set_max: server %d.%d.%d.%d:%d "
 		  "activeconns %d refcnt %d weight %d overhead %d\n",
@@ -284,7 +274,6 @@ struct ip_vs_lblcr_entry {
  *      IPVS lblcr hash table
  */
 struct ip_vs_lblcr_table {
-	rwlock_t	        lock;           /* lock for this table */
 	struct list_head        bucket[IP_VS_LBLCR_TAB_SIZE];  /* hash bucket */
 	atomic_t                entries;        /* number of entries */
 	int                     max_size;       /* maximum size of entries */
@@ -311,32 +300,6 @@ static ctl_table vs_vars_table[] = {
 
 static struct ctl_table_header * sysctl_header;
 
-/*
- *      new/free a ip_vs_lblcr_entry, which is a mapping of a destination
- *      IP address to a server.
- */
-static inline struct ip_vs_lblcr_entry *ip_vs_lblcr_new(__be32 daddr)
-{
-	struct ip_vs_lblcr_entry *en;
-
-	en = kmalloc(sizeof(struct ip_vs_lblcr_entry), GFP_ATOMIC);
-	if (en == NULL) {
-		IP_VS_ERR("ip_vs_lblcr_new(): no memory\n");
-		return NULL;
-	}
-
-	INIT_LIST_HEAD(&en->list);
-	en->addr = daddr;
-
-	/* initilize its dest set */
-	atomic_set(&(en->set.size), 0);
-	en->set.list = NULL;
-	rwlock_init(&en->set.lock);
-
-	return en;
-}
-
-
 static inline void ip_vs_lblcr_free(struct ip_vs_lblcr_entry *en)
 {
 	list_del(&en->list);
@@ -358,55 +321,68 @@ static inline unsigned ip_vs_lblcr_hashkey(__be32 addr)
  *	Hash an entry in the ip_vs_lblcr_table.
  *	returns bool success.
  */
-static int
+static void
 ip_vs_lblcr_hash(struct ip_vs_lblcr_table *tbl, struct ip_vs_lblcr_entry *en)
 {
-	unsigned hash;
-
-	if (!list_empty(&en->list)) {
-		IP_VS_ERR("ip_vs_lblcr_hash(): request for already hashed, "
-			  "called from %p\n", __builtin_return_address(0));
-		return 0;
-	}
+	unsigned hash = ip_vs_lblcr_hashkey(en->addr);
 
-	/*
-	 *	Hash by destination IP address
-	 */
-	hash = ip_vs_lblcr_hashkey(en->addr);
-
-	write_lock(&tbl->lock);
 	list_add(&en->list, &tbl->bucket[hash]);
 	atomic_inc(&tbl->entries);
-	write_unlock(&tbl->lock);
-
-	return 1;
 }
 
 
 /*
- *  Get ip_vs_lblcr_entry associated with supplied parameters.
+ *  Get ip_vs_lblcr_entry associated with supplied parameters. Called under
+ *  read lock.
  */
 static inline struct ip_vs_lblcr_entry *
 ip_vs_lblcr_get(struct ip_vs_lblcr_table *tbl, __be32 addr)
 {
-	unsigned hash;
+	unsigned hash = ip_vs_lblcr_hashkey(addr);
 	struct ip_vs_lblcr_entry *en;
 
-	hash = ip_vs_lblcr_hashkey(addr);
+	list_for_each_entry(en, &tbl->bucket[hash], list)
+		if (en->addr == addr)
+			return en;
+
+	return NULL;
+}
 
-	read_lock(&tbl->lock);
 
-	list_for_each_entry(en, &tbl->bucket[hash], list) {
-		if (en->addr == addr) {
-			/* HIT */
-			read_unlock(&tbl->lock);
-			return en;
+/*
+ * Create or update an ip_vs_lblcr_entry, which is a mapping of a destination
+ * IP address to a server. Called under write lock.
+ */
+static inline struct ip_vs_lblcr_entry *
+ip_vs_lblcr_new(struct ip_vs_lblcr_table *tbl,  __be32 daddr,
+		struct ip_vs_dest *dest)
+{
+	struct ip_vs_lblcr_entry *en;
+
+	en = ip_vs_lblcr_get(tbl, daddr);
+	if (!en) {
+		en = kmalloc(sizeof(*en), GFP_ATOMIC);
+		if (!en) {
+			IP_VS_ERR("ip_vs_lblcr_new(): no memory\n");
+			return NULL;
 		}
+
+		en->addr = daddr;
+		en->lastuse = jiffies;
+
+		/* initilize its dest set */
+		atomic_set(&(en->set.size), 0);
+		en->set.list = NULL;
+		rwlock_init(&en->set.lock);
+
+		ip_vs_lblcr_hash(tbl, en);
 	}
 
-	read_unlock(&tbl->lock);
+	write_lock(&en->set.lock);
+	ip_vs_dest_set_insert(&en->set, dest);
+	write_unlock(&en->set.lock);
 
-	return NULL;
+	return en;
 }
 
 
@@ -418,19 +394,18 @@ static void ip_vs_lblcr_flush(struct ip_vs_lblcr_table *tbl)
 	int i;
 	struct ip_vs_lblcr_entry *en, *nxt;
 
+	/* No locking required, only called during cleanup. */
 	for (i=0; i<IP_VS_LBLCR_TAB_SIZE; i++) {
-		write_lock(&tbl->lock);
 		list_for_each_entry_safe(en, nxt, &tbl->bucket[i], list) {
 			ip_vs_lblcr_free(en);
-			atomic_dec(&tbl->entries);
 		}
-		write_unlock(&tbl->lock);
 	}
 }
 
 
-static inline void ip_vs_lblcr_full_check(struct ip_vs_lblcr_table *tbl)
+static inline void ip_vs_lblcr_full_check(struct ip_vs_service *svc)
 {
+	struct ip_vs_lblcr_table *tbl = svc->sched_data;
 	unsigned long now = jiffies;
 	int i, j;
 	struct ip_vs_lblcr_entry *en, *nxt;
@@ -438,7 +413,7 @@ static inline void ip_vs_lblcr_full_check(struct ip_vs_lblcr_table *tbl)
 	for (i=0, j=tbl->rover; i<IP_VS_LBLCR_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLCR_TAB_MASK;
 
-		write_lock(&tbl->lock);
+		write_lock(&svc->sched_lock);
 		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
 			if (time_after(en->lastuse+sysctl_ip_vs_lblcr_expiration,
 				       now))
@@ -447,7 +422,7 @@ static inline void ip_vs_lblcr_full_check(struct ip_vs_lblcr_table *tbl)
 			ip_vs_lblcr_free(en);
 			atomic_dec(&tbl->entries);
 		}
-		write_unlock(&tbl->lock);
+		write_unlock(&svc->sched_lock);
 	}
 	tbl->rover = j;
 }
@@ -466,17 +441,16 @@ static inline void ip_vs_lblcr_full_check(struct ip_vs_lblcr_table *tbl)
  */
 static void ip_vs_lblcr_check_expire(unsigned long data)
 {
-	struct ip_vs_lblcr_table *tbl;
+	struct ip_vs_service *svc = (struct ip_vs_service *) data;
+	struct ip_vs_lblcr_table *tbl = svc->sched_data;
 	unsigned long now = jiffies;
 	int goal;
 	int i, j;
 	struct ip_vs_lblcr_entry *en, *nxt;
 
-	tbl = (struct ip_vs_lblcr_table *)data;
-
 	if ((tbl->counter % COUNT_FOR_FULL_EXPIRATION) == 0) {
 		/* do full expiration check */
-		ip_vs_lblcr_full_check(tbl);
+		ip_vs_lblcr_full_check(svc);
 		tbl->counter = 1;
 		goto out;
 	}
@@ -493,7 +467,7 @@ static void ip_vs_lblcr_check_expire(unsigned long data)
 	for (i=0, j=tbl->rover; i<IP_VS_LBLCR_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLCR_TAB_MASK;
 
-		write_lock(&tbl->lock);
+		write_lock(&svc->sched_lock);
 		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
 			if (time_before(now, en->lastuse+ENTRY_TIMEOUT))
 				continue;
@@ -502,7 +476,7 @@ static void ip_vs_lblcr_check_expire(unsigned long data)
 			atomic_dec(&tbl->entries);
 			goal--;
 		}
-		write_unlock(&tbl->lock);
+		write_unlock(&svc->sched_lock);
 		if (goal <= 0)
 			break;
 	}
@@ -520,15 +494,14 @@ static int ip_vs_lblcr_init_svc(struct ip_vs_service *svc)
 	/*
 	 *    Allocate the ip_vs_lblcr_table for this service
 	 */
-	tbl = kmalloc(sizeof(struct ip_vs_lblcr_table), GFP_ATOMIC);
+	tbl = kmalloc(sizeof(*tbl), GFP_ATOMIC);
 	if (tbl == NULL) {
 		IP_VS_ERR("ip_vs_lblcr_init_svc(): no memory\n");
 		return -ENOMEM;
 	}
 	svc->sched_data = tbl;
 	IP_VS_DBG(6, "LBLCR hash table (memory=%Zdbytes) allocated for "
-		  "current service\n",
-		  sizeof(struct ip_vs_lblcr_table));
+		  "current service\n", sizeof(*tbl));
 
 	/*
 	 *    Initialize the hash buckets
@@ -536,7 +509,6 @@ static int ip_vs_lblcr_init_svc(struct ip_vs_service *svc)
 	for (i=0; i<IP_VS_LBLCR_TAB_SIZE; i++) {
 		INIT_LIST_HEAD(&tbl->bucket[i]);
 	}
-	rwlock_init(&tbl->lock);
 	tbl->max_size = IP_VS_LBLCR_TAB_SIZE*16;
 	tbl->rover = 0;
 	tbl->counter = 1;
@@ -545,9 +517,8 @@ static int ip_vs_lblcr_init_svc(struct ip_vs_service *svc)
 	 *    Hook periodic timer for garbage collection
 	 */
 	setup_timer(&tbl->periodic_timer, ip_vs_lblcr_check_expire,
-			(unsigned long)tbl);
-	tbl->periodic_timer.expires = jiffies+CHECK_EXPIRE_INTERVAL;
-	add_timer(&tbl->periodic_timer);
+			(unsigned long)svc);
+	mod_timer(&tbl->periodic_timer, jiffies + CHECK_EXPIRE_INTERVAL);
 
 	return 0;
 }
@@ -564,9 +535,9 @@ static int ip_vs_lblcr_done_svc(struct ip_vs_service *svc)
 	ip_vs_lblcr_flush(tbl);
 
 	/* release the table itself */
-	kfree(svc->sched_data);
+	kfree(tbl);
 	IP_VS_DBG(6, "LBLCR hash table (memory=%Zdbytes) released\n",
-		  sizeof(struct ip_vs_lblcr_table));
+		  sizeof(*tbl));
 
 	return 0;
 }
@@ -663,50 +634,78 @@ is_overloaded(struct ip_vs_dest *dest, struct ip_vs_service *svc)
 static struct ip_vs_dest *
 ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 {
-	struct ip_vs_dest *dest;
-	struct ip_vs_lblcr_table *tbl;
-	struct ip_vs_lblcr_entry *en;
+	struct ip_vs_lblcr_table *tbl = svc->sched_data;
 	struct iphdr *iph = ip_hdr(skb);
+	struct ip_vs_dest *dest = NULL;
+	struct ip_vs_lblcr_entry *en;
 
 	IP_VS_DBG(6, "ip_vs_lblcr_schedule(): Scheduling...\n");
 
-	tbl = (struct ip_vs_lblcr_table *)svc->sched_data;
+	/* First look in our cache */
+	read_lock(&svc->sched_lock);
 	en = ip_vs_lblcr_get(tbl, iph->daddr);
-	if (en == NULL) {
-		dest = __ip_vs_lblcr_schedule(svc, iph);
-		if (dest == NULL) {
-			IP_VS_DBG(1, "no destination available\n");
-			return NULL;
-		}
-		en = ip_vs_lblcr_new(iph->daddr);
-		if (en == NULL) {
-			return NULL;
-		}
-		ip_vs_dest_set_insert(&en->set, dest);
-		ip_vs_lblcr_hash(tbl, en);
-	} else {
+	if (en) {
+		/* We only hold a read lock, but this is atomic */
+		en->lastuse = jiffies;
+
+		/* Get the least loaded destination */
+		read_lock(&en->set.lock);
 		dest = ip_vs_dest_set_min(&en->set);
-		if (!dest || is_overloaded(dest, svc)) {
-			dest = __ip_vs_lblcr_schedule(svc, iph);
-			if (dest == NULL) {
-				IP_VS_DBG(1, "no destination available\n");
-				return NULL;
-			}
-			ip_vs_dest_set_insert(&en->set, dest);
-		}
+		read_unlock(&en->set.lock);
+
+		/* More than one destination + enough time passed by, cleanup */
 		if (atomic_read(&en->set.size) > 1 &&
-		    jiffies-en->set.lastmod > sysctl_ip_vs_lblcr_expiration) {
+				time_after(jiffies, en->set.lastmod +
+				sysctl_ip_vs_lblcr_expiration)) {
 			struct ip_vs_dest *m;
+
+			write_lock(&en->set.lock);
 			m = ip_vs_dest_set_max(&en->set);
 			if (m)
 				ip_vs_dest_set_erase(&en->set, m);
+			write_unlock(&en->set.lock);
+		}
+
+		/* If the destination is not overloaded, use it */
+		if (dest && !is_overloaded(dest, svc)) {
+			read_unlock(&svc->sched_lock);
+			goto out;
+		}
+
+		/* The cache entry is invalid, time to schedule */
+		dest = __ip_vs_lblcr_schedule(svc, iph);
+		if (!dest) {
+			IP_VS_DBG(1, "no destination available\n");
+			read_unlock(&svc->sched_lock);
+			return NULL;
 		}
+
+		/* Update our cache entry */
+		write_lock(&en->set.lock);
+		ip_vs_dest_set_insert(&en->set, dest);
+		write_unlock(&en->set.lock);
+	}
+	read_unlock(&svc->sched_lock);
+
+	if (dest)
+		goto out;
+
+	/* No cache entry, time to schedule */
+	dest = __ip_vs_lblcr_schedule(svc, iph);
+	if (!dest) {
+		IP_VS_DBG(1, "no destination available\n");
+		return NULL;
 	}
-	en->lastuse = jiffies;
 
+	/* If we fail to create a cache entry, we'll just use the valid dest */
+	write_lock(&svc->sched_lock);
+	ip_vs_lblcr_new(tbl, iph->daddr, dest);
+	write_unlock(&svc->sched_lock);
+
+out:
 	IP_VS_DBG(6, "LBLCR: destination IP address %u.%u.%u.%u "
 		  "--> server %u.%u.%u.%u:%d\n",
-		  NIPQUAD(en->addr),
+		  NIPQUAD(iph->addr),
 		  NIPQUAD(dest->addr),
 		  ntohs(dest->port));
 
