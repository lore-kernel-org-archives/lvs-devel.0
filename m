From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/8] ipvs: provide iph to schedulers
Date: Wed, 26 Jun 2013 18:11:23 +0900
Message-ID: <1372237890-28211-2-git-send-email-horms@verge.net.au>
References: <1372237890-28211-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1372237890-28211-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

Before now the schedulers needed access only to IP
addresses and it was easy to get them from skb by
using ip_vs_fill_iph_addr_only.

New changes for the SH scheduler will need the protocol
and ports which is difficult to get from skb for the
IPv6 case. As we have all the data in the iph structure,
to avoid the same slow lookups provide the iph to schedulers.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Acked-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h              | 28 ++--------------------------
 net/netfilter/ipvs/ip_vs_core.c  |  4 ++--
 net/netfilter/ipvs/ip_vs_dh.c    | 10 ++++------
 net/netfilter/ipvs/ip_vs_lblc.c  | 12 +++++-------
 net/netfilter/ipvs/ip_vs_lblcr.c | 12 +++++-------
 net/netfilter/ipvs/ip_vs_lc.c    |  3 ++-
 net/netfilter/ipvs/ip_vs_nq.c    |  3 ++-
 net/netfilter/ipvs/ip_vs_rr.c    |  3 ++-
 net/netfilter/ipvs/ip_vs_sed.c   |  3 ++-
 net/netfilter/ipvs/ip_vs_sh.c    | 10 ++++------
 net/netfilter/ipvs/ip_vs_wlc.c   |  3 ++-
 net/netfilter/ipvs/ip_vs_wrr.c   |  3 ++-
 12 files changed, 34 insertions(+), 60 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 4405886..f5faf85 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -197,31 +197,6 @@ ip_vs_fill_iph_skb(int af, const struct sk_buff *skb, struct ip_vs_iphdr *iphdr)
 	}
 }
 
-/* This function is a faster version of ip_vs_fill_iph_skb().
- * Where we only populate {s,d}addr (and avoid calling ipv6_find_hdr()).
- * This is used by the some of the ip_vs_*_schedule() functions.
- * (Mostly done to avoid ABI breakage of external schedulers)
- */
-static inline void
-ip_vs_fill_iph_addr_only(int af, const struct sk_buff *skb,
-			 struct ip_vs_iphdr *iphdr)
-{
-#ifdef CONFIG_IP_VS_IPV6
-	if (af == AF_INET6) {
-		const struct ipv6hdr *iph =
-			(struct ipv6hdr *)skb_network_header(skb);
-		iphdr->saddr.in6 = iph->saddr;
-		iphdr->daddr.in6 = iph->daddr;
-	} else
-#endif
-	{
-		const struct iphdr *iph =
-			(struct iphdr *)skb_network_header(skb);
-		iphdr->saddr.ip = iph->saddr;
-		iphdr->daddr.ip = iph->daddr;
-	}
-}
-
 static inline void ip_vs_addr_copy(int af, union nf_inet_addr *dst,
 				   const union nf_inet_addr *src)
 {
@@ -814,7 +789,8 @@ struct ip_vs_scheduler {
 
 	/* selecting a server from the given service */
 	struct ip_vs_dest* (*schedule)(struct ip_vs_service *svc,
-				       const struct sk_buff *skb);
+				       const struct sk_buff *skb,
+				       struct ip_vs_iphdr *iph);
 };
 
 /* The persistence engine object */
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 05565d2..e9b0330 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -305,7 +305,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 		 * return *ignored=0 i.e. ICMP and NF_DROP
 		 */
 		sched = rcu_dereference(svc->scheduler);
-		dest = sched->schedule(svc, skb);
+		dest = sched->schedule(svc, skb, iph);
 		if (!dest) {
 			IP_VS_DBG(1, "p-schedule: no dest found.\n");
 			kfree(param.pe_data);
@@ -452,7 +452,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	}
 
 	sched = rcu_dereference(svc->scheduler);
-	dest = sched->schedule(svc, skb);
+	dest = sched->schedule(svc, skb, iph);
 	if (dest == NULL) {
 		IP_VS_DBG(1, "Schedule: no dest found.\n");
 		return NULL;
diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index ccab120..c3b8454 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -214,18 +214,16 @@ static inline int is_overloaded(struct ip_vs_dest *dest)
  *      Destination hashing scheduling
  */
 static struct ip_vs_dest *
-ip_vs_dh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
+ip_vs_dh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		  struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_dest *dest;
 	struct ip_vs_dh_state *s;
-	struct ip_vs_iphdr iph;
-
-	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
 
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
 	s = (struct ip_vs_dh_state *) svc->sched_data;
-	dest = ip_vs_dh_get(svc->af, s, &iph.daddr);
+	dest = ip_vs_dh_get(svc->af, s, &iph->daddr);
 	if (!dest
 	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
 	    || atomic_read(&dest->weight) <= 0
@@ -235,7 +233,7 @@ ip_vs_dh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	}
 
 	IP_VS_DBG_BUF(6, "DH: destination IP address %s --> server %s:%d\n",
-		      IP_VS_DBG_ADDR(svc->af, &iph.daddr),
+		      IP_VS_DBG_ADDR(svc->af, &iph->daddr),
 		      IP_VS_DBG_ADDR(svc->af, &dest->addr),
 		      ntohs(dest->port));
 
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 44595b8..1383b0e 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -487,19 +487,17 @@ is_overloaded(struct ip_vs_dest *dest, struct ip_vs_service *svc)
  *    Locality-Based (weighted) Least-Connection scheduling
  */
 static struct ip_vs_dest *
-ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
+ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		    struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_lblc_table *tbl = svc->sched_data;
-	struct ip_vs_iphdr iph;
 	struct ip_vs_dest *dest = NULL;
 	struct ip_vs_lblc_entry *en;
 
-	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
-
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
 	/* First look in our cache */
-	en = ip_vs_lblc_get(svc->af, tbl, &iph.daddr);
+	en = ip_vs_lblc_get(svc->af, tbl, &iph->daddr);
 	if (en) {
 		/* We only hold a read lock, but this is atomic */
 		en->lastuse = jiffies;
@@ -529,12 +527,12 @@ ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	/* If we fail to create a cache entry, we'll just use the valid dest */
 	spin_lock_bh(&svc->sched_lock);
 	if (!tbl->dead)
-		ip_vs_lblc_new(tbl, &iph.daddr, dest);
+		ip_vs_lblc_new(tbl, &iph->daddr, dest);
 	spin_unlock_bh(&svc->sched_lock);
 
 out:
 	IP_VS_DBG_BUF(6, "LBLC: destination IP address %s --> server %s:%d\n",
-		      IP_VS_DBG_ADDR(svc->af, &iph.daddr),
+		      IP_VS_DBG_ADDR(svc->af, &iph->daddr),
 		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port));
 
 	return dest;
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 876937d..3cd85b2 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -655,19 +655,17 @@ is_overloaded(struct ip_vs_dest *dest, struct ip_vs_service *svc)
  *    Locality-Based (weighted) Least-Connection scheduling
  */
 static struct ip_vs_dest *
-ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
+ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		     struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_lblcr_table *tbl = svc->sched_data;
-	struct ip_vs_iphdr iph;
 	struct ip_vs_dest *dest;
 	struct ip_vs_lblcr_entry *en;
 
-	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
-
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
 	/* First look in our cache */
-	en = ip_vs_lblcr_get(svc->af, tbl, &iph.daddr);
+	en = ip_vs_lblcr_get(svc->af, tbl, &iph->daddr);
 	if (en) {
 		en->lastuse = jiffies;
 
@@ -718,12 +716,12 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	/* If we fail to create a cache entry, we'll just use the valid dest */
 	spin_lock_bh(&svc->sched_lock);
 	if (!tbl->dead)
-		ip_vs_lblcr_new(tbl, &iph.daddr, dest);
+		ip_vs_lblcr_new(tbl, &iph->daddr, dest);
 	spin_unlock_bh(&svc->sched_lock);
 
 out:
 	IP_VS_DBG_BUF(6, "LBLCR: destination IP address %s --> server %s:%d\n",
-		      IP_VS_DBG_ADDR(svc->af, &iph.daddr),
+		      IP_VS_DBG_ADDR(svc->af, &iph->daddr),
 		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port));
 
 	return dest;
diff --git a/net/netfilter/ipvs/ip_vs_lc.c b/net/netfilter/ipvs/ip_vs_lc.c
index 5128e33..2bdcb1c 100644
--- a/net/netfilter/ipvs/ip_vs_lc.c
+++ b/net/netfilter/ipvs/ip_vs_lc.c
@@ -26,7 +26,8 @@
  *	Least Connection scheduling
  */
 static struct ip_vs_dest *
-ip_vs_lc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
+ip_vs_lc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		  struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_dest *dest, *least = NULL;
 	unsigned int loh = 0, doh;
diff --git a/net/netfilter/ipvs/ip_vs_nq.c b/net/netfilter/ipvs/ip_vs_nq.c
index 646cfd4..d8d9860 100644
--- a/net/netfilter/ipvs/ip_vs_nq.c
+++ b/net/netfilter/ipvs/ip_vs_nq.c
@@ -55,7 +55,8 @@ ip_vs_nq_dest_overhead(struct ip_vs_dest *dest)
  *	Weighted Least Connection scheduling
  */
 static struct ip_vs_dest *
-ip_vs_nq_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
+ip_vs_nq_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		  struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_dest *dest, *least = NULL;
 	unsigned int loh = 0, doh;
diff --git a/net/netfilter/ipvs/ip_vs_rr.c b/net/netfilter/ipvs/ip_vs_rr.c
index c35986c..176b87c 100644
--- a/net/netfilter/ipvs/ip_vs_rr.c
+++ b/net/netfilter/ipvs/ip_vs_rr.c
@@ -55,7 +55,8 @@ static int ip_vs_rr_del_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest)
  * Round-Robin Scheduling
  */
 static struct ip_vs_dest *
-ip_vs_rr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
+ip_vs_rr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		  struct ip_vs_iphdr *iph)
 {
 	struct list_head *p;
 	struct ip_vs_dest *dest, *last;
diff --git a/net/netfilter/ipvs/ip_vs_sed.c b/net/netfilter/ipvs/ip_vs_sed.c
index f320592..a5284cc 100644
--- a/net/netfilter/ipvs/ip_vs_sed.c
+++ b/net/netfilter/ipvs/ip_vs_sed.c
@@ -59,7 +59,8 @@ ip_vs_sed_dest_overhead(struct ip_vs_dest *dest)
  *	Weighted Least Connection scheduling
  */
 static struct ip_vs_dest *
-ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
+ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		   struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_dest *dest, *least;
 	unsigned int loh, doh;
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index a65edfe4..e0d5d16 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -227,18 +227,16 @@ static inline int is_overloaded(struct ip_vs_dest *dest)
  *      Source Hashing scheduling
  */
 static struct ip_vs_dest *
-ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
+ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		  struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_dest *dest;
 	struct ip_vs_sh_state *s;
-	struct ip_vs_iphdr iph;
-
-	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
 
 	IP_VS_DBG(6, "ip_vs_sh_schedule(): Scheduling...\n");
 
 	s = (struct ip_vs_sh_state *) svc->sched_data;
-	dest = ip_vs_sh_get(svc->af, s, &iph.saddr);
+	dest = ip_vs_sh_get(svc->af, s, &iph->saddr);
 	if (!dest
 	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
 	    || atomic_read(&dest->weight) <= 0
@@ -248,7 +246,7 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	}
 
 	IP_VS_DBG_BUF(6, "SH: source IP address %s --> server %s:%d\n",
-		      IP_VS_DBG_ADDR(svc->af, &iph.saddr),
+		      IP_VS_DBG_ADDR(svc->af, &iph->saddr),
 		      IP_VS_DBG_ADDR(svc->af, &dest->addr),
 		      ntohs(dest->port));
 
diff --git a/net/netfilter/ipvs/ip_vs_wlc.c b/net/netfilter/ipvs/ip_vs_wlc.c
index c60a81c..6dc1fa1 100644
--- a/net/netfilter/ipvs/ip_vs_wlc.c
+++ b/net/netfilter/ipvs/ip_vs_wlc.c
@@ -31,7 +31,8 @@
  *	Weighted Least Connection scheduling
  */
 static struct ip_vs_dest *
-ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
+ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		   struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_dest *dest, *least;
 	unsigned int loh, doh;
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index 0e68555..0546cd5 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -162,7 +162,8 @@ static int ip_vs_wrr_dest_changed(struct ip_vs_service *svc,
  *    Weighted Round-Robin Scheduling
  */
 static struct ip_vs_dest *
-ip_vs_wrr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
+ip_vs_wrr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		   struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_dest *dest, *last, *stop = NULL;
 	struct ip_vs_wrr_mark *mark = svc->sched_data;
-- 
1.8.2.1
