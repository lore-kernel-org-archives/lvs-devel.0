From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 26/34] ipvs: convert sh scheduler to rcu
Date: Fri, 29 Mar 2013 13:11:43 +0900
Message-ID: <1364530311-11512-27-git-send-email-horms@verge.net.au>
References: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

Use the 3 new methods to reassign dests.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sh.c |   81 +++++++++++++++++++++++------------------
 1 file changed, 45 insertions(+), 36 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index e331269..55e76d8 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -53,7 +53,7 @@
  *      IPVS SH bucket
  */
 struct ip_vs_sh_bucket {
-	struct ip_vs_dest       *dest;          /* real server (cache) */
+	struct ip_vs_dest __rcu	*dest;	/* real server (cache) */
 };
 
 /*
@@ -66,6 +66,10 @@ struct ip_vs_sh_bucket {
 #define IP_VS_SH_TAB_SIZE               (1 << IP_VS_SH_TAB_BITS)
 #define IP_VS_SH_TAB_MASK               (IP_VS_SH_TAB_SIZE - 1)
 
+struct ip_vs_sh_state {
+	struct ip_vs_sh_bucket		buckets[IP_VS_SH_TAB_SIZE];
+	struct rcu_head			rcu_head;
+};
 
 /*
  *	Returns hash value for IPVS SH entry
@@ -87,10 +91,9 @@ static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *ad
  *      Get ip_vs_dest associated with supplied parameters.
  */
 static inline struct ip_vs_dest *
-ip_vs_sh_get(int af, struct ip_vs_sh_bucket *tbl,
-	     const union nf_inet_addr *addr)
+ip_vs_sh_get(int af, struct ip_vs_sh_state *s, const union nf_inet_addr *addr)
 {
-	return (tbl[ip_vs_sh_hashkey(af, addr)]).dest;
+	return rcu_dereference(s->buckets[ip_vs_sh_hashkey(af, addr)].dest);
 }
 
 
@@ -98,27 +101,32 @@ ip_vs_sh_get(int af, struct ip_vs_sh_bucket *tbl,
  *      Assign all the hash buckets of the specified table with the service.
  */
 static int
-ip_vs_sh_assign(struct ip_vs_sh_bucket *tbl, struct ip_vs_service *svc)
+ip_vs_sh_reassign(struct ip_vs_sh_state *s, struct ip_vs_service *svc)
 {
 	int i;
 	struct ip_vs_sh_bucket *b;
 	struct list_head *p;
 	struct ip_vs_dest *dest;
 	int d_count;
+	bool empty;
 
-	b = tbl;
+	b = &s->buckets[0];
 	p = &svc->destinations;
+	empty = list_empty(p);
 	d_count = 0;
 	for (i=0; i<IP_VS_SH_TAB_SIZE; i++) {
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
 
 			IP_VS_DBG_BUF(6, "assigned i: %d dest: %s weight: %d\n",
 				      i, IP_VS_DBG_ADDR(svc->af, &dest->addr),
@@ -140,16 +148,18 @@ ip_vs_sh_assign(struct ip_vs_sh_bucket *tbl, struct ip_vs_service *svc)
 /*
  *      Flush all the hash buckets of the specified table.
  */
-static void ip_vs_sh_flush(struct ip_vs_sh_bucket *tbl)
+static void ip_vs_sh_flush(struct ip_vs_sh_state *s)
 {
 	int i;
 	struct ip_vs_sh_bucket *b;
+	struct ip_vs_dest *dest;
 
-	b = tbl;
+	b = &s->buckets[0];
 	for (i=0; i<IP_VS_SH_TAB_SIZE; i++) {
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
@@ -158,21 +168,20 @@ static void ip_vs_sh_flush(struct ip_vs_sh_bucket *tbl)
 
 static int ip_vs_sh_init_svc(struct ip_vs_service *svc)
 {
-	struct ip_vs_sh_bucket *tbl;
+	struct ip_vs_sh_state *s;
 
 	/* allocate the SH table for this service */
-	tbl = kmalloc(sizeof(struct ip_vs_sh_bucket)*IP_VS_SH_TAB_SIZE,
-		      GFP_KERNEL);
-	if (tbl == NULL)
+	s = kzalloc(sizeof(struct ip_vs_sh_state), GFP_KERNEL);
+	if (s == NULL)
 		return -ENOMEM;
 
-	svc->sched_data = tbl;
+	svc->sched_data = s;
 	IP_VS_DBG(6, "SH hash table (memory=%Zdbytes) allocated for "
 		  "current service\n",
 		  sizeof(struct ip_vs_sh_bucket)*IP_VS_SH_TAB_SIZE);
 
-	/* assign the hash buckets with the updated service */
-	ip_vs_sh_assign(tbl, svc);
+	/* assign the hash buckets with current dests */
+	ip_vs_sh_reassign(s, svc);
 
 	return 0;
 }
@@ -180,13 +189,13 @@ static int ip_vs_sh_init_svc(struct ip_vs_service *svc)
 
 static int ip_vs_sh_done_svc(struct ip_vs_service *svc)
 {
-	struct ip_vs_sh_bucket *tbl = svc->sched_data;
+	struct ip_vs_sh_state *s = svc->sched_data;
 
 	/* got to clean up hash buckets here */
-	ip_vs_sh_flush(tbl);
+	ip_vs_sh_flush(s);
 
 	/* release the table itself */
-	kfree(svc->sched_data);
+	kfree_rcu(s, rcu_head);
 	IP_VS_DBG(6, "SH hash table (memory=%Zdbytes) released\n",
 		  sizeof(struct ip_vs_sh_bucket)*IP_VS_SH_TAB_SIZE);
 
@@ -194,15 +203,13 @@ static int ip_vs_sh_done_svc(struct ip_vs_service *svc)
 }
 
 
-static int ip_vs_sh_update_svc(struct ip_vs_service *svc)
+static int ip_vs_sh_dest_changed(struct ip_vs_service *svc,
+				 struct ip_vs_dest *dest)
 {
-	struct ip_vs_sh_bucket *tbl = svc->sched_data;
-
-	/* got to clean up hash buckets here */
-	ip_vs_sh_flush(tbl);
+	struct ip_vs_sh_state *s = svc->sched_data;
 
 	/* assign the hash buckets with the updated service */
-	ip_vs_sh_assign(tbl, svc);
+	ip_vs_sh_reassign(s, svc);
 
 	return 0;
 }
@@ -225,15 +232,15 @@ static struct ip_vs_dest *
 ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 {
 	struct ip_vs_dest *dest;
-	struct ip_vs_sh_bucket *tbl;
+	struct ip_vs_sh_state *s;
 	struct ip_vs_iphdr iph;
 
 	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
 
 	IP_VS_DBG(6, "ip_vs_sh_schedule(): Scheduling...\n");
 
-	tbl = (struct ip_vs_sh_bucket *)svc->sched_data;
-	dest = ip_vs_sh_get(svc->af, tbl, &iph.saddr);
+	s = (struct ip_vs_sh_state *) svc->sched_data;
+	dest = ip_vs_sh_get(svc->af, s, &iph.saddr);
 	if (!dest
 	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
 	    || atomic_read(&dest->weight) <= 0
@@ -262,7 +269,9 @@ static struct ip_vs_scheduler ip_vs_sh_scheduler =
 	.n_list	 =		LIST_HEAD_INIT(ip_vs_sh_scheduler.n_list),
 	.init_service =		ip_vs_sh_init_svc,
 	.done_service =		ip_vs_sh_done_svc,
-	.update_service =	ip_vs_sh_update_svc,
+	.add_dest =		ip_vs_sh_dest_changed,
+	.del_dest =		ip_vs_sh_dest_changed,
+	.upd_dest =		ip_vs_sh_dest_changed,
 	.schedule =		ip_vs_sh_schedule,
 };
 
-- 
1.7.10.4
