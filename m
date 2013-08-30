From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf 2/5] ipvs: do not use dest after ip_vs_dest_put in LBLCR
Date: Fri, 30 Aug 2013 18:14:25 +0900
Message-ID: <1377854068-22340-3-git-send-email-horms@verge.net.au>
References: <1377854068-22340-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1377854068-22340-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

commit c5549571f975ab ("ipvs: convert lblcr scheduler to rcu")
allows RCU readers to use dest after calling ip_vs_dest_put().
In the corner case it can race with ip_vs_dest_trash_expire()
which can release the dest while it is being returned to the
RCU readers as scheduling result.

To fix the problem do not allow e->dest to be replaced and
defer the ip_vs_dest_put() call by using RCU callback. Now
e->dest does not need to be RCU pointer.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_lblcr.c | 50 ++++++++++++++++------------------------
 1 file changed, 20 insertions(+), 30 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 3cd85b2..64de585 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -89,7 +89,7 @@
  */
 struct ip_vs_dest_set_elem {
 	struct list_head	list;          /* list link */
-	struct ip_vs_dest __rcu *dest;         /* destination server */
+	struct ip_vs_dest	*dest;		/* destination server */
 	struct rcu_head		rcu_head;
 };
 
@@ -107,11 +107,7 @@ static void ip_vs_dest_set_insert(struct ip_vs_dest_set *set,
 
 	if (check) {
 		list_for_each_entry(e, &set->list, list) {
-			struct ip_vs_dest *d;
-
-			d = rcu_dereference_protected(e->dest, 1);
-			if (d == dest)
-				/* already existed */
+			if (e->dest == dest)
 				return;
 		}
 	}
@@ -121,7 +117,7 @@ static void ip_vs_dest_set_insert(struct ip_vs_dest_set *set,
 		return;
 
 	ip_vs_dest_hold(dest);
-	RCU_INIT_POINTER(e->dest, dest);
+	e->dest = dest;
 
 	list_add_rcu(&e->list, &set->list);
 	atomic_inc(&set->size);
@@ -129,22 +125,27 @@ static void ip_vs_dest_set_insert(struct ip_vs_dest_set *set,
 	set->lastmod = jiffies;
 }
 
+static void ip_vs_lblcr_elem_rcu_free(struct rcu_head *head)
+{
+	struct ip_vs_dest_set_elem *e;
+
+	e = container_of(head, struct ip_vs_dest_set_elem, rcu_head);
+	ip_vs_dest_put(e->dest);
+	kfree(e);
+}
+
 static void
 ip_vs_dest_set_erase(struct ip_vs_dest_set *set, struct ip_vs_dest *dest)
 {
 	struct ip_vs_dest_set_elem *e;
 
 	list_for_each_entry(e, &set->list, list) {
-		struct ip_vs_dest *d;
-
-		d = rcu_dereference_protected(e->dest, 1);
-		if (d == dest) {
+		if (e->dest == dest) {
 			/* HIT */
 			atomic_dec(&set->size);
 			set->lastmod = jiffies;
-			ip_vs_dest_put(dest);
 			list_del_rcu(&e->list);
-			kfree_rcu(e, rcu_head);
+			call_rcu(&e->rcu_head, ip_vs_lblcr_elem_rcu_free);
 			break;
 		}
 	}
@@ -155,16 +156,8 @@ static void ip_vs_dest_set_eraseall(struct ip_vs_dest_set *set)
 	struct ip_vs_dest_set_elem *e, *ep;
 
 	list_for_each_entry_safe(e, ep, &set->list, list) {
-		struct ip_vs_dest *d;
-
-		d = rcu_dereference_protected(e->dest, 1);
-		/*
-		 * We don't kfree dest because it is referred either
-		 * by its service or by the trash dest list.
-		 */
-		ip_vs_dest_put(d);
 		list_del_rcu(&e->list);
-		kfree_rcu(e, rcu_head);
+		call_rcu(&e->rcu_head, ip_vs_lblcr_elem_rcu_free);
 	}
 }
 
@@ -175,12 +168,9 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 	struct ip_vs_dest *dest, *least;
 	int loh, doh;
 
-	if (set == NULL)
-		return NULL;
-
 	/* select the first destination server, whose weight > 0 */
 	list_for_each_entry_rcu(e, &set->list, list) {
-		least = rcu_dereference(e->dest);
+		least = e->dest;
 		if (least->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 
@@ -195,7 +185,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 	/* find the destination with the weighted least load */
   nextstage:
 	list_for_each_entry_continue_rcu(e, &set->list, list) {
-		dest = rcu_dereference(e->dest);
+		dest = e->dest;
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 
@@ -232,7 +222,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_max(struct ip_vs_dest_set *set)
 
 	/* select the first destination server, whose weight > 0 */
 	list_for_each_entry(e, &set->list, list) {
-		most = rcu_dereference_protected(e->dest, 1);
+		most = e->dest;
 		if (atomic_read(&most->weight) > 0) {
 			moh = ip_vs_dest_conn_overhead(most);
 			goto nextstage;
@@ -243,7 +233,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_max(struct ip_vs_dest_set *set)
 	/* find the destination with the weighted most load */
   nextstage:
 	list_for_each_entry_continue(e, &set->list, list) {
-		dest = rcu_dereference_protected(e->dest, 1);
+		dest = e->dest;
 		doh = ip_vs_dest_conn_overhead(dest);
 		/* moh/mw < doh/dw ==> moh*dw < doh*mw, where mw,dw>0 */
 		if ((moh * atomic_read(&dest->weight) <
@@ -819,7 +809,7 @@ static void __exit ip_vs_lblcr_cleanup(void)
 {
 	unregister_ip_vs_scheduler(&ip_vs_lblcr_scheduler);
 	unregister_pernet_subsys(&ip_vs_lblcr_ops);
-	synchronize_rcu();
+	rcu_barrier();
 }
 
 
-- 
1.8.4
