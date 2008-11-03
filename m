From: Julius Volz <julius.volz@gmail.com>
Subject: [PATCH] IPVS: Add IPv6 support to LBLC/LBLCR schedulers
Date: Tue, 4 Nov 2008 00:17:12 +0100
Message-ID: <20081103231712.GA7807@cydonia.lan>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:date:from:to:cc:subject
         :message-id:mime-version:content-type:content-disposition:user-agent;
        bh=B1m6JreIvXjZ9IUBdqDAlNa7XW/hQTn90Qk6tNLNygE=;
        b=AqBFftMuGPxY4Dh4nh0J63ZL83umHkPB/UG27+ZLZ1ofLeEtms8FX3QDfL5jZsbexw
         HC0wEgwOT03bEebd3V5NELF/24c/oOqiBmtbzUl8YsI/cSbw9fchOTyCK/sHfaoBaw8z
         DRL12bQXdMFBcdMSenYXzW0BykkGT545vqqbw=
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: horms@verge.net.au

Add IPv6 support to LBLC and LBLCR schedulers. These were the last
schedulers without IPv6 support, but we might want to keep the
supports_ipv6 flag in the case of future schedulers without IPv6
support.

Signed-off-by: Julius Volz <julius.volz@gmail.com>
---
 net/netfilter/ipvs/ip_vs_lblc.c  |   63 ++++++++++++++++----------
 net/netfilter/ipvs/ip_vs_lblcr.c |   90 ++++++++++++++++++++++---------------
 2 files changed, 92 insertions(+), 61 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 035d4c3..135a594 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -86,7 +86,8 @@ static int sysctl_ip_vs_lblc_expiration = 24*60*60*HZ;
  */
 struct ip_vs_lblc_entry {
 	struct list_head        list;
-	__be32                  addr;           /* destination IP address */
+	int			af;		/* address family */
+	union nf_inet_addr      addr;           /* destination IP address */
 	struct ip_vs_dest       *dest;          /* real server (cache) */
 	unsigned long           lastuse;        /* last used time */
 };
@@ -137,9 +138,17 @@ static inline void ip_vs_lblc_free(struct ip_vs_lblc_entry *en)
 /*
  *	Returns hash value for IPVS LBLC entry
  */
-static inline unsigned ip_vs_lblc_hashkey(__be32 addr)
+static inline unsigned
+ip_vs_lblc_hashkey(int af, const union nf_inet_addr *addr)
 {
-	return (ntohl(addr)*2654435761UL) & IP_VS_LBLC_TAB_MASK;
+	__be32 addr_fold = addr->ip;
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		addr_fold = addr->ip6[0]^addr->ip6[1]^
+			    addr->ip6[2]^addr->ip6[3];
+#endif
+	return (ntohl(addr_fold)*2654435761UL) & IP_VS_LBLC_TAB_MASK;
 }
 
 
@@ -150,7 +159,7 @@ static inline unsigned ip_vs_lblc_hashkey(__be32 addr)
 static void
 ip_vs_lblc_hash(struct ip_vs_lblc_table *tbl, struct ip_vs_lblc_entry *en)
 {
-	unsigned hash = ip_vs_lblc_hashkey(en->addr);
+	unsigned hash = ip_vs_lblc_hashkey(en->af, &en->addr);
 
 	list_add(&en->list, &tbl->bucket[hash]);
 	atomic_inc(&tbl->entries);
@@ -162,13 +171,14 @@ ip_vs_lblc_hash(struct ip_vs_lblc_table *tbl, struct ip_vs_lblc_entry *en)
  *  lock
  */
 static inline struct ip_vs_lblc_entry *
-ip_vs_lblc_get(struct ip_vs_lblc_table *tbl, __be32 addr)
+ip_vs_lblc_get(int af, struct ip_vs_lblc_table *tbl,
+	       const union nf_inet_addr *addr)
 {
-	unsigned hash = ip_vs_lblc_hashkey(addr);
+	unsigned hash = ip_vs_lblc_hashkey(af, addr);
 	struct ip_vs_lblc_entry *en;
 
 	list_for_each_entry(en, &tbl->bucket[hash], list)
-		if (en->addr == addr)
+		if (ip_vs_addr_equal(af, &en->addr, addr))
 			return en;
 
 	return NULL;
@@ -180,12 +190,12 @@ ip_vs_lblc_get(struct ip_vs_lblc_table *tbl, __be32 addr)
  * address to a server. Called under write lock.
  */
 static inline struct ip_vs_lblc_entry *
-ip_vs_lblc_new(struct ip_vs_lblc_table *tbl, __be32 daddr,
+ip_vs_lblc_new(struct ip_vs_lblc_table *tbl, const union nf_inet_addr *daddr,
 	       struct ip_vs_dest *dest)
 {
 	struct ip_vs_lblc_entry *en;
 
-	en = ip_vs_lblc_get(tbl, daddr);
+	en = ip_vs_lblc_get(dest->af, tbl, daddr);
 	if (!en) {
 		en = kmalloc(sizeof(*en), GFP_ATOMIC);
 		if (!en) {
@@ -193,7 +203,8 @@ ip_vs_lblc_new(struct ip_vs_lblc_table *tbl, __be32 daddr,
 			return NULL;
 		}
 
-		en->addr = daddr;
+		en->af = dest->af;
+		ip_vs_addr_copy(dest->af, &en->addr, daddr);
 		en->lastuse = jiffies;
 
 		atomic_inc(&dest->refcnt);
@@ -369,7 +380,7 @@ static int ip_vs_lblc_done_svc(struct ip_vs_service *svc)
 
 
 static inline struct ip_vs_dest *
-__ip_vs_lblc_schedule(struct ip_vs_service *svc, struct iphdr *iph)
+__ip_vs_lblc_schedule(struct ip_vs_service *svc)
 {
 	struct ip_vs_dest *dest, *least;
 	int loh, doh;
@@ -420,12 +431,13 @@ __ip_vs_lblc_schedule(struct ip_vs_service *svc, struct iphdr *iph)
 		}
 	}
 
-	IP_VS_DBG(6, "LBLC: server %pI4:%d "
-		  "activeconns %d refcnt %d weight %d overhead %d\n",
-		  &least->addr.ip, ntohs(least->port),
-		  atomic_read(&least->activeconns),
-		  atomic_read(&least->refcnt),
-		  atomic_read(&least->weight), loh);
+	IP_VS_DBG_BUF(6, "LBLC: server %s:%d "
+		      "activeconns %d refcnt %d weight %d overhead %d\n",
+		      IP_VS_DBG_ADDR(least->af, &least->addr),
+		      ntohs(least->port),
+		      atomic_read(&least->activeconns),
+		      atomic_read(&least->refcnt),
+		      atomic_read(&least->weight), loh);
 
 	return least;
 }
@@ -459,15 +471,17 @@ static struct ip_vs_dest *
 ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 {
 	struct ip_vs_lblc_table *tbl = svc->sched_data;
-	struct iphdr *iph = ip_hdr(skb);
+	struct ip_vs_iphdr iph;
 	struct ip_vs_dest *dest = NULL;
 	struct ip_vs_lblc_entry *en;
 
+	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
+
 	IP_VS_DBG(6, "ip_vs_lblc_schedule(): Scheduling...\n");
 
 	/* First look in our cache */
 	read_lock(&svc->sched_lock);
-	en = ip_vs_lblc_get(tbl, iph->daddr);
+	en = ip_vs_lblc_get(svc->af, tbl, &iph.daddr);
 	if (en) {
 		/* We only hold a read lock, but this is atomic */
 		en->lastuse = jiffies;
@@ -491,7 +505,7 @@ ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		goto out;
 
 	/* No cache entry or it is invalid, time to schedule */
-	dest = __ip_vs_lblc_schedule(svc, iph);
+	dest = __ip_vs_lblc_schedule(svc);
 	if (!dest) {
 		IP_VS_DBG(1, "no destination available\n");
 		return NULL;
@@ -499,12 +513,13 @@ ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 
 	/* If we fail to create a cache entry, we'll just use the valid dest */
 	write_lock(&svc->sched_lock);
-	ip_vs_lblc_new(tbl, iph->daddr, dest);
+	ip_vs_lblc_new(tbl, &iph.daddr, dest);
 	write_unlock(&svc->sched_lock);
 
 out:
-	IP_VS_DBG(6, "LBLC: destination IP address %pI4 --> server %pI4:%d\n",
-		  &iph->daddr, &dest->addr.ip, ntohs(dest->port));
+	IP_VS_DBG_BUF(6, "LBLC: destination IP address %s --> server %s:%d\n",
+		      IP_VS_DBG_ADDR(svc->af, &iph.daddr),
+		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port));
 
 	return dest;
 }
@@ -520,7 +535,7 @@ static struct ip_vs_scheduler ip_vs_lblc_scheduler =
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_lblc_scheduler.n_list),
 #ifdef CONFIG_IP_VS_IPV6
-	.supports_ipv6 =	0,
+	.supports_ipv6 =	1,
 #endif
 	.init_service =		ip_vs_lblc_init_svc,
 	.done_service =		ip_vs_lblc_done_svc,
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index cceeff6..4d6534a 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -202,12 +202,13 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 		}
 	}
 
-	IP_VS_DBG(6, "ip_vs_dest_set_min: server %pI4:%d "
-		  "activeconns %d refcnt %d weight %d overhead %d\n",
-		  &least->addr.ip, ntohs(least->port),
-		  atomic_read(&least->activeconns),
-		  atomic_read(&least->refcnt),
-		  atomic_read(&least->weight), loh);
+	IP_VS_DBG_BUF(6, "ip_vs_dest_set_min: server %s:%d "
+		      "activeconns %d refcnt %d weight %d overhead %d\n",
+		      IP_VS_DBG_ADDR(least->af, &least->addr),
+		      ntohs(least->port),
+		      atomic_read(&least->activeconns),
+		      atomic_read(&least->refcnt),
+		      atomic_read(&least->weight), loh);
 	return least;
 }
 
@@ -248,12 +249,12 @@ static inline struct ip_vs_dest *ip_vs_dest_set_max(struct ip_vs_dest_set *set)
 		}
 	}
 
-	IP_VS_DBG(6, "ip_vs_dest_set_max: server %pI4:%d "
-		  "activeconns %d refcnt %d weight %d overhead %d\n",
-		  &most->addr.ip, ntohs(most->port),
-		  atomic_read(&most->activeconns),
-		  atomic_read(&most->refcnt),
-		  atomic_read(&most->weight), moh);
+	IP_VS_DBG_BUF(6, "ip_vs_dest_set_max: server %s:%d "
+		      "activeconns %d refcnt %d weight %d overhead %d\n",
+		      IP_VS_DBG_ADDR(most->af, &most->addr), ntohs(most->port),
+		      atomic_read(&most->activeconns),
+		      atomic_read(&most->refcnt),
+		      atomic_read(&most->weight), moh);
 	return most;
 }
 
@@ -264,7 +265,8 @@ static inline struct ip_vs_dest *ip_vs_dest_set_max(struct ip_vs_dest_set *set)
  */
 struct ip_vs_lblcr_entry {
 	struct list_head        list;
-	__be32                   addr;           /* destination IP address */
+	int			af;		/* address family */
+	union nf_inet_addr      addr;           /* destination IP address */
 	struct ip_vs_dest_set   set;            /* destination server set */
 	unsigned long           lastuse;        /* last used time */
 };
@@ -311,9 +313,17 @@ static inline void ip_vs_lblcr_free(struct ip_vs_lblcr_entry *en)
 /*
  *	Returns hash value for IPVS LBLCR entry
  */
-static inline unsigned ip_vs_lblcr_hashkey(__be32 addr)
+static inline unsigned
+ip_vs_lblcr_hashkey(int af, const union nf_inet_addr *addr)
 {
-	return (ntohl(addr)*2654435761UL) & IP_VS_LBLCR_TAB_MASK;
+	__be32 addr_fold = addr->ip;
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		addr_fold = addr->ip6[0]^addr->ip6[1]^
+			    addr->ip6[2]^addr->ip6[3];
+#endif
+	return (ntohl(addr_fold)*2654435761UL) & IP_VS_LBLCR_TAB_MASK;
 }
 
 
@@ -324,7 +334,7 @@ static inline unsigned ip_vs_lblcr_hashkey(__be32 addr)
 static void
 ip_vs_lblcr_hash(struct ip_vs_lblcr_table *tbl, struct ip_vs_lblcr_entry *en)
 {
-	unsigned hash = ip_vs_lblcr_hashkey(en->addr);
+	unsigned hash = ip_vs_lblcr_hashkey(en->af, &en->addr);
 
 	list_add(&en->list, &tbl->bucket[hash]);
 	atomic_inc(&tbl->entries);
@@ -336,13 +346,14 @@ ip_vs_lblcr_hash(struct ip_vs_lblcr_table *tbl, struct ip_vs_lblcr_entry *en)
  *  read lock.
  */
 static inline struct ip_vs_lblcr_entry *
-ip_vs_lblcr_get(struct ip_vs_lblcr_table *tbl, __be32 addr)
+ip_vs_lblcr_get(int af, struct ip_vs_lblcr_table *tbl,
+		const union nf_inet_addr *addr)
 {
-	unsigned hash = ip_vs_lblcr_hashkey(addr);
+	unsigned hash = ip_vs_lblcr_hashkey(af, addr);
 	struct ip_vs_lblcr_entry *en;
 
 	list_for_each_entry(en, &tbl->bucket[hash], list)
-		if (en->addr == addr)
+		if (ip_vs_addr_equal(af, &en->addr, addr))
 			return en;
 
 	return NULL;
@@ -354,12 +365,12 @@ ip_vs_lblcr_get(struct ip_vs_lblcr_table *tbl, __be32 addr)
  * IP address to a server. Called under write lock.
  */
 static inline struct ip_vs_lblcr_entry *
-ip_vs_lblcr_new(struct ip_vs_lblcr_table *tbl,  __be32 daddr,
+ip_vs_lblcr_new(struct ip_vs_lblcr_table *tbl, const union nf_inet_addr *daddr,
 		struct ip_vs_dest *dest)
 {
 	struct ip_vs_lblcr_entry *en;
 
-	en = ip_vs_lblcr_get(tbl, daddr);
+	en = ip_vs_lblcr_get(dest->af, tbl, daddr);
 	if (!en) {
 		en = kmalloc(sizeof(*en), GFP_ATOMIC);
 		if (!en) {
@@ -367,7 +378,8 @@ ip_vs_lblcr_new(struct ip_vs_lblcr_table *tbl,  __be32 daddr,
 			return NULL;
 		}
 
-		en->addr = daddr;
+		en->af = dest->af;
+		ip_vs_addr_copy(dest->af, &en->addr, daddr);
 		en->lastuse = jiffies;
 
 		/* initilize its dest set */
@@ -544,7 +556,7 @@ static int ip_vs_lblcr_done_svc(struct ip_vs_service *svc)
 
 
 static inline struct ip_vs_dest *
-__ip_vs_lblcr_schedule(struct ip_vs_service *svc, struct iphdr *iph)
+__ip_vs_lblcr_schedule(struct ip_vs_service *svc)
 {
 	struct ip_vs_dest *dest, *least;
 	int loh, doh;
@@ -596,12 +608,13 @@ __ip_vs_lblcr_schedule(struct ip_vs_service *svc, struct iphdr *iph)
 		}
 	}
 
-	IP_VS_DBG(6, "LBLCR: server %pI4:%d "
-		  "activeconns %d refcnt %d weight %d overhead %d\n",
-		  &least->addr.ip, ntohs(least->port),
-		  atomic_read(&least->activeconns),
-		  atomic_read(&least->refcnt),
-		  atomic_read(&least->weight), loh);
+	IP_VS_DBG_BUF(6, "LBLCR: server %s:%d "
+		      "activeconns %d refcnt %d weight %d overhead %d\n",
+		      IP_VS_DBG_ADDR(least->af, &least->addr),
+		      ntohs(least->port),
+		      atomic_read(&least->activeconns),
+		      atomic_read(&least->refcnt),
+		      atomic_read(&least->weight), loh);
 
 	return least;
 }
@@ -635,15 +648,17 @@ static struct ip_vs_dest *
 ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 {
 	struct ip_vs_lblcr_table *tbl = svc->sched_data;
-	struct iphdr *iph = ip_hdr(skb);
+	struct ip_vs_iphdr iph;
 	struct ip_vs_dest *dest = NULL;
 	struct ip_vs_lblcr_entry *en;
 
+	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
+
 	IP_VS_DBG(6, "ip_vs_lblcr_schedule(): Scheduling...\n");
 
 	/* First look in our cache */
 	read_lock(&svc->sched_lock);
-	en = ip_vs_lblcr_get(tbl, iph->daddr);
+	en = ip_vs_lblcr_get(svc->af, tbl, &iph.daddr);
 	if (en) {
 		/* We only hold a read lock, but this is atomic */
 		en->lastuse = jiffies;
@@ -673,7 +688,7 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		}
 
 		/* The cache entry is invalid, time to schedule */
-		dest = __ip_vs_lblcr_schedule(svc, iph);
+		dest = __ip_vs_lblcr_schedule(svc);
 		if (!dest) {
 			IP_VS_DBG(1, "no destination available\n");
 			read_unlock(&svc->sched_lock);
@@ -691,7 +706,7 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		goto out;
 
 	/* No cache entry, time to schedule */
-	dest = __ip_vs_lblcr_schedule(svc, iph);
+	dest = __ip_vs_lblcr_schedule(svc);
 	if (!dest) {
 		IP_VS_DBG(1, "no destination available\n");
 		return NULL;
@@ -699,12 +714,13 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 
 	/* If we fail to create a cache entry, we'll just use the valid dest */
 	write_lock(&svc->sched_lock);
-	ip_vs_lblcr_new(tbl, iph->daddr, dest);
+	ip_vs_lblcr_new(tbl, &iph.daddr, dest);
 	write_unlock(&svc->sched_lock);
 
 out:
-	IP_VS_DBG(6, "LBLCR: destination IP address %pI4 --> server %pI4:%d\n",
-		  &iph->daddr, &dest->addr.ip, ntohs(dest->port));
+	IP_VS_DBG_BUF(6, "LBLCR: destination IP address %s --> server %s:%d\n",
+		      IP_VS_DBG_ADDR(svc->af, &iph.daddr),
+		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port));
 
 	return dest;
 }
@@ -720,7 +736,7 @@ static struct ip_vs_scheduler ip_vs_lblcr_scheduler =
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_lblcr_scheduler.n_list),
 #ifdef CONFIG_IP_VS_IPV6
-	.supports_ipv6 =	0,
+	.supports_ipv6 =	1,
 #endif
 	.init_service =		ip_vs_lblcr_init_svc,
 	.done_service =		ip_vs_lblcr_done_svc,
-- 
1.5.3.7


