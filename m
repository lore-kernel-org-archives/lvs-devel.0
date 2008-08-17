From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH] ipvs: Fix race conditions in lblc scheduler
Date: Mon, 18 Aug 2008 00:52:08 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0808180050440.12259@titan.stealer.net>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg

We can't access the cache entry outside of our critical read-locked region,
because someone may free that entry. And we also need to check in the critical
region wether the destination is still available, i.e. it's not in the trash.
If we drop our reference counter, the destination can be purged from the trash
at any time. Our caller only guarantees that no destination is moved to the
trash, while we are scheduling. Also there is no need for our own rwlock,
there is already one in the service structure for use in the schedulers.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv4/ipvs/ip_vs_lblc.c |  204 +++++++++++++++++++++-----------------------
 1 files changed, 96 insertions(+), 108 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_lblc.c b/net/ipv4/ipvs/ip_vs_lblc.c
index b9b334c..d2a43aa 100644
--- a/net/ipv4/ipvs/ip_vs_lblc.c
+++ b/net/ipv4/ipvs/ip_vs_lblc.c
@@ -96,7 +96,6 @@ struct ip_vs_lblc_entry {
  *      IPVS lblc hash table
  */
 struct ip_vs_lblc_table {
-	rwlock_t	        lock;           /* lock for this table */
 	struct list_head        bucket[IP_VS_LBLC_TAB_SIZE];  /* hash bucket */
 	atomic_t                entries;        /* number of entries */
 	int                     max_size;       /* maximum size of entries */
@@ -123,31 +122,6 @@ static ctl_table vs_vars_table[] = {
 
 static struct ctl_table_header * sysctl_header;
 
-/*
- *      new/free a ip_vs_lblc_entry, which is a mapping of a destionation
- *      IP address to a server.
- */
-static inline struct ip_vs_lblc_entry *
-ip_vs_lblc_new(__be32 daddr, struct ip_vs_dest *dest)
-{
-	struct ip_vs_lblc_entry *en;
-
-	en = kmalloc(sizeof(struct ip_vs_lblc_entry), GFP_ATOMIC);
-	if (en == NULL) {
-		IP_VS_ERR("ip_vs_lblc_new(): no memory\n");
-		return NULL;
-	}
-
-	INIT_LIST_HEAD(&en->list);
-	en->addr = daddr;
-
-	atomic_inc(&dest->refcnt);
-	en->dest = dest;
-
-	return en;
-}
-
-
 static inline void ip_vs_lblc_free(struct ip_vs_lblc_entry *en)
 {
 	list_del(&en->list);
@@ -173,55 +147,66 @@ static inline unsigned ip_vs_lblc_hashkey(__be32 addr)
  *	Hash an entry in the ip_vs_lblc_table.
  *	returns bool success.
  */
-static int
+static void
 ip_vs_lblc_hash(struct ip_vs_lblc_table *tbl, struct ip_vs_lblc_entry *en)
 {
-	unsigned hash;
-
-	if (!list_empty(&en->list)) {
-		IP_VS_ERR("ip_vs_lblc_hash(): request for already hashed, "
-			  "called from %p\n", __builtin_return_address(0));
-		return 0;
-	}
+	unsigned hash = ip_vs_lblc_hashkey(en->addr);
 
-	/*
-	 *	Hash by destination IP address
-	 */
-	hash = ip_vs_lblc_hashkey(en->addr);
-
-	write_lock(&tbl->lock);
 	list_add(&en->list, &tbl->bucket[hash]);
 	atomic_inc(&tbl->entries);
-	write_unlock(&tbl->lock);
-
-	return 1;
 }
 
 
 /*
- *  Get ip_vs_lblc_entry associated with supplied parameters.
+ *  Get ip_vs_lblc_entry associated with supplied parameters. Called under read
+ *  lock
  */
 static inline struct ip_vs_lblc_entry *
 ip_vs_lblc_get(struct ip_vs_lblc_table *tbl, __be32 addr)
 {
-	unsigned hash;
+	unsigned hash = ip_vs_lblc_hashkey(addr);
 	struct ip_vs_lblc_entry *en;
 
-	hash = ip_vs_lblc_hashkey(addr);
+	list_for_each_entry(en, &tbl->bucket[hash], list)
+		if (en->addr == addr)
+			return en;
 
-	read_lock(&tbl->lock);
+	return NULL;
+}
 
-	list_for_each_entry(en, &tbl->bucket[hash], list) {
-		if (en->addr == addr) {
-			/* HIT */
-			read_unlock(&tbl->lock);
-			return en;
+
+/*
+ * Create or update an ip_vs_lblc_entry, which is a mapping of a destination IP
+ * address to a server. Called under write lock.
+ */
+static inline struct ip_vs_lblc_entry *
+ip_vs_lblc_new(struct ip_vs_lblc_table *tbl, __be32 daddr,
+	       struct ip_vs_dest *dest)
+{
+	struct ip_vs_lblc_entry *en;
+
+	en = ip_vs_lblc_get(tbl, daddr);
+	if (!en) {
+		en = kmalloc(sizeof(*en), GFP_ATOMIC);
+		if (!en) {
+			IP_VS_ERR("ip_vs_lblc_new(): no memory\n");
+			return NULL;
 		}
-	}
 
-	read_unlock(&tbl->lock);
+		en->addr = daddr;
+		en->lastuse = jiffies;
 
-	return NULL;
+		atomic_inc(&dest->refcnt);
+		en->dest = dest;
+
+		ip_vs_lblc_hash(tbl, en);
+	} else if (en->dest != dest) {
+		atomic_dec(&en->dest->refcnt);
+		atomic_inc(&dest->refcnt);
+		en->dest = dest;
+	}
+
+	return en;
 }
 
 
@@ -230,30 +215,29 @@ ip_vs_lblc_get(struct ip_vs_lblc_table *tbl, __be32 addr)
  */
 static void ip_vs_lblc_flush(struct ip_vs_lblc_table *tbl)
 {
-	int i;
 	struct ip_vs_lblc_entry *en, *nxt;
+	int i;
 
 	for (i=0; i<IP_VS_LBLC_TAB_SIZE; i++) {
-		write_lock(&tbl->lock);
 		list_for_each_entry_safe(en, nxt, &tbl->bucket[i], list) {
 			ip_vs_lblc_free(en);
 			atomic_dec(&tbl->entries);
 		}
-		write_unlock(&tbl->lock);
 	}
 }
 
 
-static inline void ip_vs_lblc_full_check(struct ip_vs_lblc_table *tbl)
+static inline void ip_vs_lblc_full_check(struct ip_vs_service *svc)
 {
+	struct ip_vs_lblc_table *tbl = svc->sched_data;
+	struct ip_vs_lblc_entry *en, *nxt;
 	unsigned long now = jiffies;
 	int i, j;
-	struct ip_vs_lblc_entry *en, *nxt;
 
 	for (i=0, j=tbl->rover; i<IP_VS_LBLC_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLC_TAB_MASK;
 
-		write_lock(&tbl->lock);
+		write_lock(&svc->sched_lock);
 		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
 			if (time_before(now,
 					en->lastuse + sysctl_ip_vs_lblc_expiration))
@@ -262,7 +246,7 @@ static inline void ip_vs_lblc_full_check(struct ip_vs_lblc_table *tbl)
 			ip_vs_lblc_free(en);
 			atomic_dec(&tbl->entries);
 		}
-		write_unlock(&tbl->lock);
+		write_unlock(&svc->sched_lock);
 	}
 	tbl->rover = j;
 }
@@ -281,17 +265,16 @@ static inline void ip_vs_lblc_full_check(struct ip_vs_lblc_table *tbl)
  */
 static void ip_vs_lblc_check_expire(unsigned long data)
 {
-	struct ip_vs_lblc_table *tbl;
+	struct ip_vs_service *svc = (struct ip_vs_service *) data;
+	struct ip_vs_lblc_table *tbl = svc->sched_data;
 	unsigned long now = jiffies;
 	int goal;
 	int i, j;
 	struct ip_vs_lblc_entry *en, *nxt;
 
-	tbl = (struct ip_vs_lblc_table *)data;
-
 	if ((tbl->counter % COUNT_FOR_FULL_EXPIRATION) == 0) {
 		/* do full expiration check */
-		ip_vs_lblc_full_check(tbl);
+		ip_vs_lblc_full_check(svc);
 		tbl->counter = 1;
 		goto out;
 	}
@@ -308,7 +291,7 @@ static void ip_vs_lblc_check_expire(unsigned long data)
 	for (i=0, j=tbl->rover; i<IP_VS_LBLC_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLC_TAB_MASK;
 
-		write_lock(&tbl->lock);
+		write_lock(&svc->sched_lock);
 		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
 			if (time_before(now, en->lastuse + ENTRY_TIMEOUT))
 				continue;
@@ -317,7 +300,7 @@ static void ip_vs_lblc_check_expire(unsigned long data)
 			atomic_dec(&tbl->entries);
 			goal--;
 		}
-		write_unlock(&tbl->lock);
+		write_unlock(&svc->sched_lock);
 		if (goal <= 0)
 			break;
 	}
@@ -336,15 +319,14 @@ static int ip_vs_lblc_init_svc(struct ip_vs_service *svc)
 	/*
 	 *    Allocate the ip_vs_lblc_table for this service
 	 */
-	tbl = kmalloc(sizeof(struct ip_vs_lblc_table), GFP_ATOMIC);
+	tbl = kmalloc(sizeof(*tbl), GFP_ATOMIC);
 	if (tbl == NULL) {
 		IP_VS_ERR("ip_vs_lblc_init_svc(): no memory\n");
 		return -ENOMEM;
 	}
 	svc->sched_data = tbl;
 	IP_VS_DBG(6, "LBLC hash table (memory=%Zdbytes) allocated for "
-		  "current service\n",
-		  sizeof(struct ip_vs_lblc_table));
+		  "current service\n", sizeof(*tbl));
 
 	/*
 	 *    Initialize the hash buckets
@@ -352,7 +334,6 @@ static int ip_vs_lblc_init_svc(struct ip_vs_service *svc)
 	for (i=0; i<IP_VS_LBLC_TAB_SIZE; i++) {
 		INIT_LIST_HEAD(&tbl->bucket[i]);
 	}
-	rwlock_init(&tbl->lock);
 	tbl->max_size = IP_VS_LBLC_TAB_SIZE*16;
 	tbl->rover = 0;
 	tbl->counter = 1;
@@ -361,9 +342,8 @@ static int ip_vs_lblc_init_svc(struct ip_vs_service *svc)
 	 *    Hook periodic timer for garbage collection
 	 */
 	setup_timer(&tbl->periodic_timer, ip_vs_lblc_check_expire,
-			(unsigned long)tbl);
-	tbl->periodic_timer.expires = jiffies+CHECK_EXPIRE_INTERVAL;
-	add_timer(&tbl->periodic_timer);
+			(unsigned long)svc);
+	mod_timer(&tbl->periodic_timer, jiffies + CHECK_EXPIRE_INTERVAL);
 
 	return 0;
 }
@@ -380,9 +360,9 @@ static int ip_vs_lblc_done_svc(struct ip_vs_service *svc)
 	ip_vs_lblc_flush(tbl);
 
 	/* release the table itself */
-	kfree(svc->sched_data);
+	kfree(tbl);
 	IP_VS_DBG(6, "LBLC hash table (memory=%Zdbytes) released\n",
-		  sizeof(struct ip_vs_lblc_table));
+		  sizeof(*tbl));
 
 	return 0;
 }
@@ -478,46 +458,54 @@ is_overloaded(struct ip_vs_dest *dest, struct ip_vs_service *svc)
 static struct ip_vs_dest *
 ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 {
-	struct ip_vs_dest *dest;
-	struct ip_vs_lblc_table *tbl;
-	struct ip_vs_lblc_entry *en;
+	struct ip_vs_lblc_table *tbl = svc->sched_data;
 	struct iphdr *iph = ip_hdr(skb);
+	struct ip_vs_dest *dest = NULL;
+	struct ip_vs_lblc_entry *en;
 
 	IP_VS_DBG(6, "ip_vs_lblc_schedule(): Scheduling...\n");
 
-	tbl = (struct ip_vs_lblc_table *)svc->sched_data;
+	/* First look in our cache */
+	read_lock(&svc->sched_lock);
 	en = ip_vs_lblc_get(tbl, iph->daddr);
-	if (en == NULL) {
-		dest = __ip_vs_lblc_schedule(svc, iph);
-		if (dest == NULL) {
-			IP_VS_DBG(1, "no destination available\n");
-			return NULL;
-		}
-		en = ip_vs_lblc_new(iph->daddr, dest);
-		if (en == NULL) {
-			return NULL;
-		}
-		ip_vs_lblc_hash(tbl, en);
-	} else {
-		dest = en->dest;
-		if (!(dest->flags & IP_VS_DEST_F_AVAILABLE)
-		    || atomic_read(&dest->weight) <= 0
-		    || is_overloaded(dest, svc)) {
-			dest = __ip_vs_lblc_schedule(svc, iph);
-			if (dest == NULL) {
-				IP_VS_DBG(1, "no destination available\n");
-				return NULL;
-			}
-			atomic_dec(&en->dest->refcnt);
-			atomic_inc(&dest->refcnt);
-			en->dest = dest;
-		}
+	if (en) {
+		/* We only hold a read lock, but this is atomic */
+		en->lastuse = jiffies;
+
+		/*
+		 * If the destination is not available, i.e. it's in the trash,
+		 * we must ignore it, as it may be removed from under our feet,
+		 * if someone drops our reference count. Our caller only makes
+		 * sure that destinations, that are not in the trash, are not
+		 * moved to the trash, while we are scheduling. But anyone can
+		 * free up entries from the trash at any time.
+		 */
+
+		if (en->dest->flags & IP_VS_DEST_F_AVAILABLE)
+			dest = en->dest;
+	}
+	read_unlock(&svc->sched_lock);
+
+	/* If the destination has a weight and is not overloaded, use it */
+	if (dest && atomic_read(&dest->weight) > 0 && !is_overloaded(dest, svc))
+		goto out;
+
+	/* No cache entry or it is invalid, time to schedule */
+	dest = __ip_vs_lblc_schedule(svc, iph);
+	if (!dest) {
+		IP_VS_DBG(1, "no destination available\n");
+		return NULL;
 	}
-	en->lastuse = jiffies;
 
+	/* If we fail to create a cache entry, we'll just use the valid dest */
+	write_lock(&svc->sched_lock);
+	ip_vs_lblc_new(tbl, iph->daddr, dest);
+	write_unlock(&svc->sched_lock);
+
+out:
 	IP_VS_DBG(6, "LBLC: destination IP address %u.%u.%u.%u "
 		  "--> server %u.%u.%u.%u:%d\n",
-		  NIPQUAD(en->addr),
+		  NIPQUAD(iph->daddr),
 		  NIPQUAD(dest->addr),
 		  ntohs(dest->port));
 
