From: Inju Song <inju.song@navercorp.com>
Subject: [PATCH 2/3] netfilter: ipvs: release refcnt and improve
 ip_vs_mh_reassign()
Date: Sun, 10 Dec 2017 16:34:31 +0900
Message-ID: <0934e976a52b20b559d9bac618af460a7cfa0c31.1512888407.git.inju.song@navercorp.com>
References: <cover.1512888407.git.inju.song@navercorp.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1512888407.git.inju.song@navercorp.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>

  1) release refcnt of old dests in lookup entry

  2) handle exception about svc->num_dests == 0
     - skip permutate and populate if dest list is empty

  3) change allocation method
     - in case of allocating permutate array, use vmalloc()
       instead of kalloc()

Signed-off-by: Inju Song <inju.song@navercorp.com>
---
 net/netfilter/ipvs/ip_vs_mh.c | 58 +++++++++++++++++++++++++++++--------------
 1 file changed, 39 insertions(+), 19 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_mh.c b/net/netfilter/ipvs/ip_vs_mh.c
index b3fa8c4..bb20b96 100644
--- a/net/netfilter/ipvs/ip_vs_mh.c
+++ b/net/netfilter/ipvs/ip_vs_mh.c
@@ -5,6 +5,7 @@
 #include <linux/slab.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
+#include <linux/vmalloc.h>
 #include <linux/skbuff.h>
 
 #include <net/ip_vs.h>
@@ -74,6 +75,12 @@ static inline int ip_vs_mh_permutate(struct ip_vs_mh_state *s,
 	struct list_head *p;
 	struct ip_vs_dest *dest;
 	unsigned int offset, skip;
+	bool empty;
+
+	p = &svc->destinations;
+	empty = list_empty(p);
+	if (empty)
+		return 0;
 
 	/* extending permutation table to 2d arrays */
 	for (i = 1; i < svc->num_dests; i++)
@@ -81,7 +88,6 @@ static inline int ip_vs_mh_permutate(struct ip_vs_mh_state *s,
 				    IP_VS_MH_LOOKUP_SIZE;
 
 	i = 0;
-	p = &svc->destinations;
 	while ((p = p->next) != &svc->destinations) {
 		dest = list_entry(p, struct ip_vs_dest, n_list);
 		offset = ip_vs_mh_hashkey(svc->af, &dest->addr,	dest->port,
@@ -110,6 +116,7 @@ static inline int ip_vs_mh_permutate(struct ip_vs_mh_state *s,
 	struct list_head *p;
 	struct ip_vs_dest *dest;
 	unsigned int n, c;
+	bool empty;
 
 	ret = 0;
 	next = kcalloc(IP_VS_MH_TAB_SIZE, sizeof(unsigned int),
@@ -128,11 +135,17 @@ static inline int ip_vs_mh_permutate(struct ip_vs_mh_state *s,
 		RCU_INIT_POINTER(entry[i].dest, NULL);
 
 	n = 0;
+	p = &svc->destinations;
+	empty = list_empty(p);
+	if (empty)
+		goto out;
+
 	pmt = s->permutation;
 	while (n < IP_VS_MH_LOOKUP_SIZE) {
-		p = &svc->destinations;
 		for (i = 0; i < svc->num_dests; i++) {
-			p = p->next;
+			if (p == &svc->destinations)
+				p = p->next;
+
 			c = pmt[i][next[i]];
 
 			while (entry[c].dest) {
@@ -147,20 +160,29 @@ static inline int ip_vs_mh_permutate(struct ip_vs_mh_state *s,
 			n++;
 			if (n == IP_VS_MH_LOOKUP_SIZE)
 				break;
+
+			p = p->next;
 		}
 	}
 
+out:
 	l = &s->lookup[0];
 	for (i = 0; i < IP_VS_MH_LOOKUP_SIZE; i++) {
 		dest = rcu_dereference_protected(entry[i].dest, 1);
-		ip_vs_dest_hold(dest);
-		RCU_INIT_POINTER(l->dest, dest);
+		if (dest)
+			ip_vs_dest_put(dest);
+		if (empty) {
+			RCU_INIT_POINTER(l->dest, NULL);
+		} else {
+			ip_vs_dest_hold(dest);
+			RCU_INIT_POINTER(l->dest, dest);
 
-		IP_VS_DBG_BUF(6, "assigned i: %d dest: %s weight: %d\n",
-			      i, IP_VS_DBG_ADDR(dest->af, &dest->addr),
-			      atomic_read(&dest->weight));
+			IP_VS_DBG_BUF(6, "assigned i: %d dest: %s weight: %d\n",
+				      i, IP_VS_DBG_ADDR(dest->af, &dest->addr),
+				      atomic_read(&dest->weight));
 
-		RCU_INIT_POINTER(entry[i].dest, NULL);
+			RCU_INIT_POINTER(entry[i].dest, NULL);
+		}
 		l++;
 	}
 
@@ -250,19 +272,15 @@ static void ip_vs_mh_flush(struct ip_vs_mh_state *s)
 {
 	int ret;
 
-	/* flush all the hash entry before assigning mh entry */
-	ip_vs_mh_flush(s);
-
 	/* ip_vs_mh_reassign is responsible for assigning
 	 * and releasing s->permutation table
 	 */
-	s->permutation = kcalloc(IP_VS_MH_TAB_SIZE, sizeof(unsigned int *),
-				 GFP_KERNEL);
+	s->permutation = vzalloc(IP_VS_MH_TAB_SIZE * sizeof(unsigned int *));
 	if (!s->permutation)
 		return -ENOMEM;
 
-	s->permutation[0] = kcalloc(IP_VS_MH_TAB_SIZE * IP_VS_MH_LOOKUP_SIZE,
-				    sizeof(unsigned int), GFP_KERNEL);
+	s->permutation[0] = vzalloc(IP_VS_MH_TAB_SIZE * IP_VS_MH_LOOKUP_SIZE *
+				    sizeof(unsigned int));
 	if (!s->permutation[0]) {
 		ret = -ENOMEM;
 		goto err_alloc;
@@ -276,12 +294,14 @@ static void ip_vs_mh_flush(struct ip_vs_mh_state *s)
 	if (ret < 0)
 		goto err_out;
 
-	return 0;
+	IP_VS_DBG_BUF(6, "MH: reassign lookup table of %s:%d\n",
+		      IP_VS_DBG_ADDR(svc->af, &svc->addr),
+		      ntohs(svc->port));
 
 err_out:
-	kfree(s->permutation[0]);
+	vfree(s->permutation[0]);
 err_alloc:
-	kfree(s->permutation);
+	vfree(s->permutation);
 	return ret;
 }
 
-- 
1.8.3.1


-- 
Inju Song
NAVER Corporation

