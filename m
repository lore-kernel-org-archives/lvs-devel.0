From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 31/34] ipvs: convert sched_lock to spin lock
Date: Fri, 29 Mar 2013 13:11:48 +0900
Message-ID: <1364530311-11512-32-git-send-email-horms@verge.net.au>
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

As all read_locks are gone spin lock is preferred.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h              |    2 +-
 net/netfilter/ipvs/ip_vs_ctl.c   |    2 +-
 net/netfilter/ipvs/ip_vs_lblc.c  |   18 +++++++++---------
 net/netfilter/ipvs/ip_vs_lblcr.c |   26 +++++++++++++-------------
 net/netfilter/ipvs/ip_vs_rr.c    |   10 +++++-----
 net/netfilter/ipvs/ip_vs_wrr.c   |    8 ++++----
 6 files changed, 33 insertions(+), 33 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 4990de6..4a7bc63 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -734,7 +734,7 @@ struct ip_vs_service {
 
 	/* for scheduling */
 	struct ip_vs_scheduler	*scheduler;    /* bound scheduler object */
-	rwlock_t		sched_lock;    /* lock sched_data */
+	spinlock_t		sched_lock;    /* lock sched_data */
 	void			*sched_data;   /* scheduler application data */
 
 	/* alternate persistence engine */
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index d022726..2bfd807 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1219,7 +1219,7 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 	svc->net = net;
 
 	INIT_LIST_HEAD(&svc->destinations);
-	rwlock_init(&svc->sched_lock);
+	spin_lock_init(&svc->sched_lock);
 	spin_lock_init(&svc->stats.lock);
 
 	/* Bind the scheduler */
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index c7ff978..ffef8a1 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -194,7 +194,7 @@ ip_vs_lblc_get(int af, struct ip_vs_lblc_table *tbl,
 
 /*
  * Create or update an ip_vs_lblc_entry, which is a mapping of a destination IP
- * address to a server. Called under write lock.
+ * address to a server. Called under spin lock.
  */
 static inline struct ip_vs_lblc_entry *
 ip_vs_lblc_new(struct ip_vs_lblc_table *tbl, const union nf_inet_addr *daddr,
@@ -242,7 +242,7 @@ static void ip_vs_lblc_flush(struct ip_vs_service *svc)
 	struct hlist_node *next;
 	int i;
 
-	write_lock_bh(&svc->sched_lock);
+	spin_lock_bh(&svc->sched_lock);
 	tbl->dead = 1;
 	for (i=0; i<IP_VS_LBLC_TAB_SIZE; i++) {
 		hlist_for_each_entry_safe(en, next, &tbl->bucket[i], list) {
@@ -250,7 +250,7 @@ static void ip_vs_lblc_flush(struct ip_vs_service *svc)
 			atomic_dec(&tbl->entries);
 		}
 	}
-	write_unlock_bh(&svc->sched_lock);
+	spin_unlock_bh(&svc->sched_lock);
 }
 
 static int sysctl_lblc_expiration(struct ip_vs_service *svc)
@@ -274,7 +274,7 @@ static inline void ip_vs_lblc_full_check(struct ip_vs_service *svc)
 	for (i=0, j=tbl->rover; i<IP_VS_LBLC_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLC_TAB_MASK;
 
-		write_lock(&svc->sched_lock);
+		spin_lock(&svc->sched_lock);
 		hlist_for_each_entry_safe(en, next, &tbl->bucket[j], list) {
 			if (time_before(now,
 					en->lastuse +
@@ -284,7 +284,7 @@ static inline void ip_vs_lblc_full_check(struct ip_vs_service *svc)
 			ip_vs_lblc_free(en);
 			atomic_dec(&tbl->entries);
 		}
-		write_unlock(&svc->sched_lock);
+		spin_unlock(&svc->sched_lock);
 	}
 	tbl->rover = j;
 }
@@ -330,7 +330,7 @@ static void ip_vs_lblc_check_expire(unsigned long data)
 	for (i=0, j=tbl->rover; i<IP_VS_LBLC_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLC_TAB_MASK;
 
-		write_lock(&svc->sched_lock);
+		spin_lock(&svc->sched_lock);
 		hlist_for_each_entry_safe(en, next, &tbl->bucket[j], list) {
 			if (time_before(now, en->lastuse + ENTRY_TIMEOUT))
 				continue;
@@ -339,7 +339,7 @@ static void ip_vs_lblc_check_expire(unsigned long data)
 			atomic_dec(&tbl->entries);
 			goal--;
 		}
-		write_unlock(&svc->sched_lock);
+		spin_unlock(&svc->sched_lock);
 		if (goal <= 0)
 			break;
 	}
@@ -527,10 +527,10 @@ ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	}
 
 	/* If we fail to create a cache entry, we'll just use the valid dest */
-	write_lock(&svc->sched_lock);
+	spin_lock(&svc->sched_lock);
 	if (!tbl->dead)
 		ip_vs_lblc_new(tbl, &iph.daddr, dest);
-	write_unlock(&svc->sched_lock);
+	spin_unlock(&svc->sched_lock);
 
 out:
 	IP_VS_DBG_BUF(6, "LBLC: destination IP address %s --> server %s:%d\n",
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 6049b85..cdfe6a9 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -368,7 +368,7 @@ ip_vs_lblcr_get(int af, struct ip_vs_lblcr_table *tbl,
 
 /*
  * Create or update an ip_vs_lblcr_entry, which is a mapping of a destination
- * IP address to a server. Called under write lock.
+ * IP address to a server. Called under spin lock.
  */
 static inline struct ip_vs_lblcr_entry *
 ip_vs_lblcr_new(struct ip_vs_lblcr_table *tbl, const union nf_inet_addr *daddr,
@@ -412,14 +412,14 @@ static void ip_vs_lblcr_flush(struct ip_vs_service *svc)
 	struct ip_vs_lblcr_entry *en;
 	struct hlist_node *next;
 
-	write_lock_bh(&svc->sched_lock);
+	spin_lock_bh(&svc->sched_lock);
 	tbl->dead = 1;
 	for (i=0; i<IP_VS_LBLCR_TAB_SIZE; i++) {
 		hlist_for_each_entry_safe(en, next, &tbl->bucket[i], list) {
 			ip_vs_lblcr_free(en);
 		}
 	}
-	write_unlock_bh(&svc->sched_lock);
+	spin_unlock_bh(&svc->sched_lock);
 }
 
 static int sysctl_lblcr_expiration(struct ip_vs_service *svc)
@@ -443,7 +443,7 @@ static inline void ip_vs_lblcr_full_check(struct ip_vs_service *svc)
 	for (i=0, j=tbl->rover; i<IP_VS_LBLCR_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLCR_TAB_MASK;
 
-		write_lock(&svc->sched_lock);
+		spin_lock(&svc->sched_lock);
 		hlist_for_each_entry_safe(en, next, &tbl->bucket[j], list) {
 			if (time_after(en->lastuse +
 				       sysctl_lblcr_expiration(svc), now))
@@ -452,7 +452,7 @@ static inline void ip_vs_lblcr_full_check(struct ip_vs_service *svc)
 			ip_vs_lblcr_free(en);
 			atomic_dec(&tbl->entries);
 		}
-		write_unlock(&svc->sched_lock);
+		spin_unlock(&svc->sched_lock);
 	}
 	tbl->rover = j;
 }
@@ -498,7 +498,7 @@ static void ip_vs_lblcr_check_expire(unsigned long data)
 	for (i=0, j=tbl->rover; i<IP_VS_LBLCR_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLCR_TAB_MASK;
 
-		write_lock(&svc->sched_lock);
+		spin_lock(&svc->sched_lock);
 		hlist_for_each_entry_safe(en, next, &tbl->bucket[j], list) {
 			if (time_before(now, en->lastuse+ENTRY_TIMEOUT))
 				continue;
@@ -507,7 +507,7 @@ static void ip_vs_lblcr_check_expire(unsigned long data)
 			atomic_dec(&tbl->entries);
 			goal--;
 		}
-		write_unlock(&svc->sched_lock);
+		spin_unlock(&svc->sched_lock);
 		if (goal <= 0)
 			break;
 	}
@@ -678,7 +678,7 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		if (atomic_read(&en->set.size) > 1 &&
 		    time_after(jiffies, en->set.lastmod +
 				sysctl_lblcr_expiration(svc))) {
-			write_lock(&svc->sched_lock);
+			spin_lock(&svc->sched_lock);
 			if (atomic_read(&en->set.size) > 1) {
 				struct ip_vs_dest *m;
 
@@ -686,7 +686,7 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 				if (m)
 					ip_vs_dest_set_erase(&en->set, m);
 			}
-			write_unlock(&svc->sched_lock);
+			spin_unlock(&svc->sched_lock);
 		}
 
 		/* If the destination is not overloaded, use it */
@@ -701,10 +701,10 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		}
 
 		/* Update our cache entry */
-		write_lock(&svc->sched_lock);
+		spin_lock(&svc->sched_lock);
 		if (!tbl->dead)
 			ip_vs_dest_set_insert(&en->set, dest, true);
-		write_unlock(&svc->sched_lock);
+		spin_unlock(&svc->sched_lock);
 		goto out;
 	}
 
@@ -716,10 +716,10 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	}
 
 	/* If we fail to create a cache entry, we'll just use the valid dest */
-	write_lock(&svc->sched_lock);
+	spin_lock(&svc->sched_lock);
 	if (!tbl->dead)
 		ip_vs_lblcr_new(tbl, &iph.daddr, dest);
-	write_unlock(&svc->sched_lock);
+	spin_unlock(&svc->sched_lock);
 
 out:
 	IP_VS_DBG_BUF(6, "LBLCR: destination IP address %s --> server %s:%d\n",
diff --git a/net/netfilter/ipvs/ip_vs_rr.c b/net/netfilter/ipvs/ip_vs_rr.c
index 3942890..aa4601f 100644
--- a/net/netfilter/ipvs/ip_vs_rr.c
+++ b/net/netfilter/ipvs/ip_vs_rr.c
@@ -39,14 +39,14 @@ static int ip_vs_rr_del_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest)
 {
 	struct list_head *p;
 
-	write_lock_bh(&svc->sched_lock);
+	spin_lock_bh(&svc->sched_lock);
 	p = (struct list_head *) svc->sched_data;
 	/* dest is already unlinked, so p->prev is not valid but
 	 * p->next is valid, use it to reach previous entry.
 	 */
 	if (p == &dest->n_list)
 		svc->sched_data = p->next->prev;
-	write_unlock_bh(&svc->sched_lock);
+	spin_unlock_bh(&svc->sched_lock);
 	return 0;
 }
 
@@ -63,7 +63,7 @@ ip_vs_rr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
-	write_lock(&svc->sched_lock);
+	spin_lock(&svc->sched_lock);
 	p = (struct list_head *) svc->sched_data;
 	last = dest = list_entry(p, struct ip_vs_dest, n_list);
 
@@ -85,13 +85,13 @@ ip_vs_rr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	} while (pass < 2 && p != &svc->destinations);
 
 stop:
-	write_unlock(&svc->sched_lock);
+	spin_unlock(&svc->sched_lock);
 	ip_vs_scheduler_err(svc, "no destination available");
 	return NULL;
 
   out:
 	svc->sched_data = &dest->n_list;
-	write_unlock(&svc->sched_lock);
+	spin_unlock(&svc->sched_lock);
 	IP_VS_DBG_BUF(6, "RR: server %s:%u "
 		      "activeconns %d refcnt %d weight %d\n",
 		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port),
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index a74fd9b..b173ef9 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -145,7 +145,7 @@ static int ip_vs_wrr_dest_changed(struct ip_vs_service *svc,
 {
 	struct ip_vs_wrr_mark *mark = svc->sched_data;
 
-	write_lock_bh(&svc->sched_lock);
+	spin_lock_bh(&svc->sched_lock);
 	mark->cl = list_entry(&svc->destinations, struct ip_vs_dest, n_list);
 	mark->di = ip_vs_wrr_gcd_weight(svc);
 	mark->mw = ip_vs_wrr_max_weight(svc) - (mark->di - 1);
@@ -153,7 +153,7 @@ static int ip_vs_wrr_dest_changed(struct ip_vs_service *svc,
 		mark->cw = mark->mw;
 	else if (mark->di > 1)
 		mark->cw = (mark->cw / mark->di) * mark->di + 1;
-	write_unlock_bh(&svc->sched_lock);
+	spin_unlock_bh(&svc->sched_lock);
 	return 0;
 }
 
@@ -170,7 +170,7 @@ ip_vs_wrr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
-	write_lock(&svc->sched_lock);
+	spin_lock(&svc->sched_lock);
 	dest = mark->cl;
 	/* No available dests? */
 	if (mark->mw == 0)
@@ -222,7 +222,7 @@ found:
 	mark->cl = dest;
 
   out:
-	write_unlock(&svc->sched_lock);
+	spin_unlock(&svc->sched_lock);
 	return dest;
 
 err_noavail:
-- 
1.7.10.4

