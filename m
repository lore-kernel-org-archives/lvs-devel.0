From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 04/19] ipvs: convert dh scheduler to rcu
Date: Fri, 22 Mar 2013 11:46:39 +0200
Message-ID: <1363945614-11752-5-git-send-email-ja@ssi.bg>
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

	Use the new add_dest and del_dest methods
to reassign dests.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_dh.c |   81 +++++++++++++++++++++++------------------
 1 files changed, 45 insertions(+), 36 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index 7f3b0cc..ebe80f4 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -51,7 +51,7 @@
  *      IPVS DH bucket
  */
 struct ip_vs_dh_bucket {
-	struct ip_vs_dest       *dest;          /* real server (cache) */
+	struct ip_vs_dest __rcu	*dest;	/* real server (cache) */
 };
 
 /*
@@ -64,6 +64,10 @@ struct ip_vs_dh_bucket {
 #define IP_VS_DH_TAB_SIZE               (1 << IP_VS_DH_TAB_BITS)
 #define IP_VS_DH_TAB_MASK               (IP_VS_DH_TAB_SIZE - 1)
 
+struct ip_vs_dh_state {
+	struct ip_vs_dh_bucket		buckets[IP_VS_DH_TAB_SIZE];
+	struct rcu_head			rcu_head;
+};
 
 /*
  *	Returns hash value for IPVS DH entry
@@ -85,10 +89,9 @@ static inline unsigned int ip_vs_dh_hashkey(int af, const union nf_inet_addr *ad
  *      Get ip_vs_dest associated with supplied parameters.
  */
 static inline struct ip_vs_dest *
-ip_vs_dh_get(int af, struct ip_vs_dh_bucket *tbl,
-	     const union nf_inet_addr *addr)
+ip_vs_dh_get(int af, struct ip_vs_dh_state *s, const union nf_inet_addr *addr)
 {
-	return (tbl[ip_vs_dh_hashkey(af, addr)]).dest;
+	return rcu_dereference(s->buckets[ip_vs_dh_hashkey(af, addr)].dest);
 }
 
 
@@ -96,25 +99,30 @@ ip_vs_dh_get(int af, struct ip_vs_dh_bucket *tbl,
  *      Assign all the hash buckets of the specified table with the service.
  */
 static int
-ip_vs_dh_assign(struct ip_vs_dh_bucket *tbl, struct ip_vs_service *svc)
+ip_vs_dh_reassign(struct ip_vs_dh_state *s, struct ip_vs_service *svc)
 {
 	int i;
 	struct ip_vs_dh_bucket *b;
 	struct list_head *p;
 	struct ip_vs_dest *dest;
+	bool empty;
 
-	b = tbl;
+	b = &s->buckets[0];
 	p = &svc->destinations;
+	empty = list_empty(p);
 	for (i=0; i<IP_VS_DH_TAB_SIZE; i++) {
-		if (list_empty(p)) {
-			b->dest = NULL;
-		} else {
+		dest = rcu_dereference_protected(b->dest, 1);
+		if (dest)
+			ip_vs_dest_put(dest);
+		if (empty)
+			RCU_INIT_POINTER(b->dest, NULL);
+		else {
 			if (p == &svc->destinations)
 				p = p->next;
 
 			dest = list_entry(p, struct ip_vs_dest, n_list);
-			atomic_inc(&dest->refcnt);
-			b->dest = dest;
+			ip_vs_dest_hold(dest);
+			RCU_INIT_POINTER(b->dest, dest);
 
 			p = p->next;
 		}
@@ -127,16 +135,18 @@ ip_vs_dh_assign(struct ip_vs_dh_bucket *tbl, struct ip_vs_service *svc)
 /*
  *      Flush all the hash buckets of the specified table.
  */
-static void ip_vs_dh_flush(struct ip_vs_dh_bucket *tbl)
+static void ip_vs_dh_flush(struct ip_vs_dh_state *s)
 {
 	int i;
 	struct ip_vs_dh_bucket *b;
+	struct ip_vs_dest *dest;
 
-	b = tbl;
+	b = &s->buckets[0];
 	for (i=0; i<IP_VS_DH_TAB_SIZE; i++) {
-		if (b->dest) {
-			atomic_dec(&b->dest->refcnt);
-			b->dest = NULL;
+		dest = rcu_dereference_protected(b->dest, 1);
+		if (dest) {
+			ip_vs_dest_put(dest);
+			RCU_INIT_POINTER(b->dest, NULL);
 		}
 		b++;
 	}
@@ -145,21 +155,20 @@ static void ip_vs_dh_flush(struct ip_vs_dh_bucket *tbl)
 
 static int ip_vs_dh_init_svc(struct ip_vs_service *svc)
 {
-	struct ip_vs_dh_bucket *tbl;
+	struct ip_vs_dh_state *s;
 
 	/* allocate the DH table for this service */
-	tbl = kmalloc(sizeof(struct ip_vs_dh_bucket)*IP_VS_DH_TAB_SIZE,
-		      GFP_KERNEL);
-	if (tbl == NULL)
+	s = kzalloc(sizeof(struct ip_vs_dh_state), GFP_KERNEL);
+	if (s == NULL)
 		return -ENOMEM;
 
-	svc->sched_data = tbl;
+	svc->sched_data = s;
 	IP_VS_DBG(6, "DH hash table (memory=%Zdbytes) allocated for "
 		  "current service\n",
 		  sizeof(struct ip_vs_dh_bucket)*IP_VS_DH_TAB_SIZE);
 
-	/* assign the hash buckets with the updated service */
-	ip_vs_dh_assign(tbl, svc);
+	/* assign the hash buckets with current dests */
+	ip_vs_dh_reassign(s, svc);
 
 	return 0;
 }
@@ -167,13 +176,13 @@ static int ip_vs_dh_init_svc(struct ip_vs_service *svc)
 
 static int ip_vs_dh_done_svc(struct ip_vs_service *svc)
 {
-	struct ip_vs_dh_bucket *tbl = svc->sched_data;
+	struct ip_vs_dh_state *s = svc->sched_data;
 
 	/* got to clean up hash buckets here */
-	ip_vs_dh_flush(tbl);
+	ip_vs_dh_flush(s);
 
 	/* release the table itself */
-	kfree(svc->sched_data);
+	kfree_rcu(s, rcu_head);
 	IP_VS_DBG(6, "DH hash table (memory=%Zdbytes) released\n",
 		  sizeof(struct ip_vs_dh_bucket)*IP_VS_DH_TAB_SIZE);
 
@@ -181,15 +190,13 @@ static int ip_vs_dh_done_svc(struct ip_vs_service *svc)
 }
 
 
-static int ip_vs_dh_update_svc(struct ip_vs_service *svc)
+static int ip_vs_dh_dest_changed(struct ip_vs_service *svc,
+				 struct ip_vs_dest *dest)
 {
-	struct ip_vs_dh_bucket *tbl = svc->sched_data;
-
-	/* got to clean up hash buckets here */
-	ip_vs_dh_flush(tbl);
+	struct ip_vs_dh_state *s = svc->sched_data;
 
 	/* assign the hash buckets with the updated service */
-	ip_vs_dh_assign(tbl, svc);
+	ip_vs_dh_reassign(s, svc);
 
 	return 0;
 }
@@ -212,19 +219,20 @@ static struct ip_vs_dest *
 ip_vs_dh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 {
 	struct ip_vs_dest *dest;
-	struct ip_vs_dh_bucket *tbl;
+	struct ip_vs_dh_state *s;
 	struct ip_vs_iphdr iph;
 
 	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
 
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
-	tbl = (struct ip_vs_dh_bucket *)svc->sched_data;
-	dest = ip_vs_dh_get(svc->af, tbl, &iph.daddr);
+	s = (struct ip_vs_dh_state *) svc->sched_data;
+	dest = ip_vs_dh_get(svc->af, s, &iph.daddr);
 	if (!dest
 	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
 	    || atomic_read(&dest->weight) <= 0
 	    || is_overloaded(dest)) {
+		ip_vs_scheduler_err(svc, "no destination available");
 		return NULL;
 	}
 
@@ -248,7 +256,8 @@ static struct ip_vs_scheduler ip_vs_dh_scheduler =
 	.n_list =		LIST_HEAD_INIT(ip_vs_dh_scheduler.n_list),
 	.init_service =		ip_vs_dh_init_svc,
 	.done_service =		ip_vs_dh_done_svc,
-	.update_service =	ip_vs_dh_update_svc,
+	.add_dest =		ip_vs_dh_dest_changed,
+	.del_dest =		ip_vs_dh_dest_changed,
 	.schedule =		ip_vs_dh_schedule,
 };
 
-- 
1.7.3.4
