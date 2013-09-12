From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCHv2 net 2/4] ipvs: do not use dest after ip_vs_dest_put in LBLC
Date: Thu, 12 Sep 2013 11:21:08 +0300
Message-ID: <1378974070-9372-3-git-send-email-ja@ssi.bg>
References: <1378974070-9372-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1378974070-9372-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

commit c2a4ffb70eef39 ("ipvs: convert lblc scheduler to rcu")
allows RCU readers to use dest after calling ip_vs_dest_put().
In the corner case it can race with ip_vs_dest_trash_expire()
which can release the dest while it is being returned to the
RCU readers as scheduling result.

To fix the problem do not allow en->dest to be replaced and
defer the ip_vs_dest_put() call by using RCU callback. Now
en->dest does not need to be RCU pointer.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_lblc.c |   68 ++++++++++++++++++---------------------
 1 files changed, 31 insertions(+), 37 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 1383b0e..b39b0e9 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -93,7 +93,7 @@ struct ip_vs_lblc_entry {
 	struct hlist_node	list;
 	int			af;		/* address family */
 	union nf_inet_addr      addr;           /* destination IP address */
-	struct ip_vs_dest __rcu	*dest;          /* real server (cache) */
+	struct ip_vs_dest	*dest;          /* real server (cache) */
 	unsigned long           lastuse;        /* last used time */
 	struct rcu_head		rcu_head;
 };
@@ -130,20 +130,21 @@ static struct ctl_table vs_vars_table[] = {
 };
 #endif
 
-static inline void ip_vs_lblc_free(struct ip_vs_lblc_entry *en)
+static void ip_vs_lblc_rcu_free(struct rcu_head *head)
 {
-	struct ip_vs_dest *dest;
+	struct ip_vs_lblc_entry *en = container_of(head,
+						   struct ip_vs_lblc_entry,
+						   rcu_head);
 
-	hlist_del_rcu(&en->list);
-	/*
-	 * We don't kfree dest because it is referred either by its service
-	 * or the trash dest list.
-	 */
-	dest = rcu_dereference_protected(en->dest, 1);
-	ip_vs_dest_put(dest);
-	kfree_rcu(en, rcu_head);
+	ip_vs_dest_put(en->dest);
+	kfree(en);
 }
 
+static inline void ip_vs_lblc_del(struct ip_vs_lblc_entry *en)
+{
+	hlist_del_rcu(&en->list);
+	call_rcu(&en->rcu_head, ip_vs_lblc_rcu_free);
+}
 
 /*
  *	Returns hash value for IPVS LBLC entry
@@ -203,30 +204,23 @@ ip_vs_lblc_new(struct ip_vs_lblc_table *tbl, const union nf_inet_addr *daddr,
 	struct ip_vs_lblc_entry *en;
 
 	en = ip_vs_lblc_get(dest->af, tbl, daddr);
-	if (!en) {
-		en = kmalloc(sizeof(*en), GFP_ATOMIC);
-		if (!en)
-			return NULL;
-
-		en->af = dest->af;
-		ip_vs_addr_copy(dest->af, &en->addr, daddr);
-		en->lastuse = jiffies;
+	if (en) {
+		if (en->dest == dest)
+			return en;
+		ip_vs_lblc_del(en);
+	}
+	en = kmalloc(sizeof(*en), GFP_ATOMIC);
+	if (!en)
+		return NULL;
 
-		ip_vs_dest_hold(dest);
-		RCU_INIT_POINTER(en->dest, dest);
+	en->af = dest->af;
+	ip_vs_addr_copy(dest->af, &en->addr, daddr);
+	en->lastuse = jiffies;
 
-		ip_vs_lblc_hash(tbl, en);
-	} else {
-		struct ip_vs_dest *old_dest;
+	ip_vs_dest_hold(dest);
+	en->dest = dest;
 
-		old_dest = rcu_dereference_protected(en->dest, 1);
-		if (old_dest != dest) {
-			ip_vs_dest_put(old_dest);
-			ip_vs_dest_hold(dest);
-			/* No ordering constraints for refcnt */
-			RCU_INIT_POINTER(en->dest, dest);
-		}
-	}
+	ip_vs_lblc_hash(tbl, en);
 
 	return en;
 }
@@ -246,7 +240,7 @@ static void ip_vs_lblc_flush(struct ip_vs_service *svc)
 	tbl->dead = 1;
 	for (i=0; i<IP_VS_LBLC_TAB_SIZE; i++) {
 		hlist_for_each_entry_safe(en, next, &tbl->bucket[i], list) {
-			ip_vs_lblc_free(en);
+			ip_vs_lblc_del(en);
 			atomic_dec(&tbl->entries);
 		}
 	}
@@ -281,7 +275,7 @@ static inline void ip_vs_lblc_full_check(struct ip_vs_service *svc)
 					sysctl_lblc_expiration(svc)))
 				continue;
 
-			ip_vs_lblc_free(en);
+			ip_vs_lblc_del(en);
 			atomic_dec(&tbl->entries);
 		}
 		spin_unlock(&svc->sched_lock);
@@ -335,7 +329,7 @@ static void ip_vs_lblc_check_expire(unsigned long data)
 			if (time_before(now, en->lastuse + ENTRY_TIMEOUT))
 				continue;
 
-			ip_vs_lblc_free(en);
+			ip_vs_lblc_del(en);
 			atomic_dec(&tbl->entries);
 			goal--;
 		}
@@ -511,7 +505,7 @@ ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 		 * free up entries from the trash at any time.
 		 */
 
-		dest = rcu_dereference(en->dest);
+		dest = en->dest;
 		if ((dest->flags & IP_VS_DEST_F_AVAILABLE) &&
 		    atomic_read(&dest->weight) > 0 && !is_overloaded(dest, svc))
 			goto out;
@@ -631,7 +625,7 @@ static void __exit ip_vs_lblc_cleanup(void)
 {
 	unregister_ip_vs_scheduler(&ip_vs_lblc_scheduler);
 	unregister_pernet_subsys(&ip_vs_lblc_ops);
-	synchronize_rcu();
+	rcu_barrier();
 }
 
 
-- 
1.7.3.4

