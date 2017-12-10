From: Inju Song <inju.song@navercorp.com>
Subject: [PATCH 1/3] netfilter: ipvs: handle memory allocation fail in mh
 scheduler.
Date: Sun, 10 Dec 2017 16:33:48 +0900
Message-ID: <e4318639ffcff4fdb506fe138d752f9ad1162c1d.1512888407.git.inju.song@navercorp.com>
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

  1) change svc->num_dests to fixed size when allocate memory.

  2) return -ENOMEM if memory allocation is faild(non-failing methods)

Signed-off-by: Inju Song <inju.song@navercorp.com>
---
 net/netfilter/ipvs/ip_vs_mh.c | 101 +++++++++++++++++++++++++++---------------
 1 file changed, 65 insertions(+), 36 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_mh.c b/net/netfilter/ipvs/ip_vs_mh.c
index 534a9f5..b3fa8c4 100644
--- a/net/netfilter/ipvs/ip_vs_mh.c
+++ b/net/netfilter/ipvs/ip_vs_mh.c
@@ -19,11 +19,17 @@ struct ip_vs_mh_lookup {
 };
 
 /* for IPVS MH entry hash table */
-#define IP_VS_MH_LOOKUP_SIZE	65537 /* Must be prime number */
+#ifndef CONFIG_IP_VS_MH_TAB_BITS
+#define CONFIG_IP_VS_MH_TAB_BITS        8
+#endif
+#define IP_VS_MH_TAB_BITS               CONFIG_IP_VS_MH_TAB_BITS
+#define IP_VS_MH_TAB_SIZE               BIT(IP_VS_MH_TAB_BITS)
+#define IP_VS_MH_LOOKUP_SIZE		65537 /* Must be prime number */
 
 struct ip_vs_mh_state {
 	struct rcu_head		rcu_head;
 	struct ip_vs_mh_lookup  lookup[IP_VS_MH_LOOKUP_SIZE];
+	unsigned int		**permutation;
 	hsiphash_key_t		hash1, hash2;
 };
 
@@ -61,25 +67,21 @@ static inline bool is_unavailable(struct ip_vs_dest *dest)
 	return hsiphash(&v, sizeof(v), key);
 }
 
-static inline unsigned int **
-ip_vs_mh_permutate(struct ip_vs_mh_state *s, struct ip_vs_service *svc)
+static inline int ip_vs_mh_permutate(struct ip_vs_mh_state *s,
+				     struct ip_vs_service *svc)
 {
 	int i, j;
-	unsigned int **permutation;
 	struct list_head *p;
 	struct ip_vs_dest *dest;
 	unsigned int offset, skip;
-	int dcnt;
 
-	dcnt = svc->num_dests;
-	permutation = kcalloc(dcnt, sizeof(unsigned int *), GFP_KERNEL);
-	permutation[0] = kcalloc(dcnt * IP_VS_MH_LOOKUP_SIZE,
-				 sizeof(unsigned int), GFP_KERNEL);
-	for (i = 1; i < dcnt; i++)
-		permutation[i] = permutation[i - 1] + IP_VS_MH_LOOKUP_SIZE;
+	/* extending permutation table to 2d arrays */
+	for (i = 1; i < svc->num_dests; i++)
+		s->permutation[i] = s->permutation[i - 1] +
+				    IP_VS_MH_LOOKUP_SIZE;
 
-	p = &svc->destinations;
 	i = 0;
+	p = &svc->destinations;
 	while ((p = p->next) != &svc->destinations) {
 		dest = list_entry(p, struct ip_vs_dest, n_list);
 		offset = ip_vs_mh_hashkey(svc->af, &dest->addr,	dest->port,
@@ -89,44 +91,53 @@ static inline bool is_unavailable(struct ip_vs_dest *dest)
 					(IP_VS_MH_LOOKUP_SIZE - 1) + 1;
 
 		for (j = 0; j < IP_VS_MH_LOOKUP_SIZE; j++) {
-			permutation[i][j] = (offset + (j * skip)) %
+			s->permutation[i][j] = (offset + (j * skip)) %
 						IP_VS_MH_LOOKUP_SIZE;
 		}
 		i++;
 	}
 
-	return permutation;
+	return 0;
 }
 
 static inline int
-ip_vs_mh_populate(struct ip_vs_mh_state *s, struct ip_vs_service *svc,
-		  unsigned int **permutation)
+ip_vs_mh_populate(struct ip_vs_mh_state *s, struct ip_vs_service *svc)
 {
-	int i;
+	int i, ret;
 	unsigned int *next;
+	unsigned int **pmt;
 	struct ip_vs_mh_lookup *entry, *l;
 	struct list_head *p;
 	struct ip_vs_dest *dest;
-	int dcnt;
 	unsigned int n, c;
 
-	dcnt = svc->num_dests;
-	next = kcalloc(dcnt, sizeof(unsigned int), GFP_KERNEL);
+	ret = 0;
+	next = kcalloc(IP_VS_MH_TAB_SIZE, sizeof(unsigned int),
+		       GFP_KERNEL);
+	if (!next)
+		return -ENOMEM;
+
 	entry = kcalloc(IP_VS_MH_LOOKUP_SIZE, sizeof(*entry),
 			GFP_KERNEL);
+	if (!entry) {
+		ret = -ENOMEM;
+		goto err_alloc;
+	}
+
 	for (i = 0; i < IP_VS_MH_LOOKUP_SIZE; i++)
 		RCU_INIT_POINTER(entry[i].dest, NULL);
 
 	n = 0;
+	pmt = s->permutation;
 	while (n < IP_VS_MH_LOOKUP_SIZE) {
 		p = &svc->destinations;
-		for (i = 0; i < dcnt; i++) {
+		for (i = 0; i < svc->num_dests; i++) {
 			p = p->next;
-			c = permutation[i][next[i]];
+			c = pmt[i][next[i]];
 
 			while (entry[c].dest) {
 				next[i] = next[i] + 1;
-				c = permutation[i][next[i]];
+				c = pmt[i][next[i]];
 			}
 
 			dest = list_entry(p, struct ip_vs_dest, n_list);
@@ -152,10 +163,11 @@ static inline bool is_unavailable(struct ip_vs_dest *dest)
 		RCU_INIT_POINTER(entry[i].dest, NULL);
 		l++;
 	}
-	kfree(next);
-	kfree(entry);
 
-	return 0;
+	kfree(entry);
+err_alloc:
+	kfree(next);
+	return ret;
 }
 
 /* Get ip_vs_dest associated with supplied parameters. */
@@ -236,24 +248,41 @@ static void ip_vs_mh_flush(struct ip_vs_mh_state *s)
 static int
 ip_vs_mh_reassign(struct ip_vs_mh_state *s, struct ip_vs_service *svc)
 {
-	int dcnt;
-	unsigned int **permutation;
+	int ret;
 
 	/* flush all the hash entry before assigning mh entry */
 	ip_vs_mh_flush(s);
 
-	/* if destination number is zero, skip mh assign */
-	dcnt = svc->num_dests;
-	if (dcnt <= 0)
-		return 0;
+	/* ip_vs_mh_reassign is responsible for assigning
+	 * and releasing s->permutation table
+	 */
+	s->permutation = kcalloc(IP_VS_MH_TAB_SIZE, sizeof(unsigned int *),
+				 GFP_KERNEL);
+	if (!s->permutation)
+		return -ENOMEM;
 
-	permutation = ip_vs_mh_permutate(s, svc);
-	ip_vs_mh_populate(s, svc, permutation);
+	s->permutation[0] = kcalloc(IP_VS_MH_TAB_SIZE * IP_VS_MH_LOOKUP_SIZE,
+				    sizeof(unsigned int), GFP_KERNEL);
+	if (!s->permutation[0]) {
+		ret = -ENOMEM;
+		goto err_alloc;
+	}
 
-	kfree(permutation[0]);
-	kfree(permutation);
+	ret = ip_vs_mh_permutate(s, svc);
+	if (ret < 0)
+		goto err_out;
+
+	ret = ip_vs_mh_populate(s, svc);
+	if (ret < 0)
+		goto err_out;
 
 	return 0;
+
+err_out:
+	kfree(s->permutation[0]);
+err_alloc:
+	kfree(s->permutation);
+	return ret;
 }
 
 static int ip_vs_mh_init_svc(struct ip_vs_service *svc)
-- 
1.8.3.1


-- 
Inju Song
NAVER Corporation

