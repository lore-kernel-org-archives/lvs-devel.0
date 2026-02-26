Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 50D75320CCC;
	Thu, 26 Feb 2026 19:55:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772135735; cv=none; b=GVXix0OdhkYtD4blKgBV2VRx+NA5mTx3JonmmXmXR3tDURDxtCD7sCpo9fj9mOgBWHTnBR8xMafVfRaJXkaGOvU8NvFnRpgXuu5uuuKpVy7Xhpn5nn3z3wSFPBvaEjC6elyjYiA7Yy3Vjg69qSHHv9+9ojFEQIvp6+JczV2p+YQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772135735; c=relaxed/simple;
	bh=48D7SAi1plpSPk4a9OPwAzeITAE+4Ef/mJK6v5jHVQc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=UUGFFvIsYlrCnOdAmw5qr0Lwi4eyVCVPm2/bQ5oN/urR8/1qloSR3h+fT1y1XFCpWOPtjgH9mHjai2UNd/cxwBDc9KfdfRENaNdcAj7xlKXrr0Trv9vmY5m6Wk6/HY6L66EWtxMUIy3HCULzNFx7Tb7iyUvhr3jItWGzn4SLafI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=kW/sGJ3Y; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="kW/sGJ3Y"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 3F2E921D56;
	Thu, 26 Feb 2026 21:55:13 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=Q8e96fu9tEBVzPjMsu+qEDY1jTd3dzeZeNkaxpLEs7Q=; b=kW/sGJ3YCWiN
	UgsfGP725MwEiYpQ65efU6z55iVwDPNJZNxcDyfJKbPwg5HDtSr0QBQToKtvDxg/
	DCvzwH7KC5WELflD7EZ+XRXOunH5lBq7dODf/kDMsagEnZfIw+KUpLDdJ1PLLkdS
	CyU+79O9i56emqv0zgZr0+XMLqB7ruP+nkN/kvs/621wfnkkYX3Lykmm2+lLHufi
	JKzKuLonaO60XgFw+rBynkfVVka0m8A0Z2xjBh03HYiS7JW6lRjTzTvbZ6Hzrnok
	t2B3buPDb1p23g8MSssGgD47OFsPGzuPSJ8A3fVVD0BS4w1g83OEnEXnwdZE7VZe
	YNTAz0JLlQ3L1r8OgA7dQqk1FutVJ+LAskX8a2KLtK7NYhmuaZNdScDI7jDrHlur
	tCvIVjIp9VdLPdIBq9isRIywpxNl2apFPYwTiTuBtgkGXfe9hoB6ic7j51lSMzpE
	H8HO1ZRkB+6dX/Uik7UMd2o6oblAqsN9jz5exsxCDhpXJf/3UHeJG/JZB5JTEu/k
	gZNzvfEXqqFZue1fzg1pWtNGfWLkyfeDzGDR5qQQdBNQw+4gupdqy9oN3MPjzQ8H
	TzgjfEQVC0Z+Q/lx3eHpcxrdpbdcynxyUZpz0KeKP7neCSZTbREVAiYlZ5NuKN3r
	zP0SMBWYlYcX5g3NkcnDPMsG74AaizA=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 26 Feb 2026 21:55:07 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 8EDDB62A0E;
	Thu, 26 Feb 2026 21:55:06 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 61QJphbL064986;
	Thu, 26 Feb 2026 21:51:43 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 61QJphIN064985;
	Thu, 26 Feb 2026 21:51:43 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: [PATCH nf-next 3/5] ipvs: use resizable hash table for services
Date: Thu, 26 Feb 2026 21:50:19 +0200
Message-ID: <20260226195021.64943-4-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260226195021.64943-1-ja@ssi.bg>
References: <20260226195021.64943-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Make the hash table for services resizable in the bit range of 4-20.
Table is attached only while services are present. Resizing is done
by delayed work based on load (the number of hashed services).
Table grows when load increases 2+ times (above 12.5% with lfactor=-3)
and shrinks 8+ times when load decreases 16+ times (below 0.78%).

Switch to jhash hashing to reduce the collisions for multiple
services.

Add a hash_key field into the service to store the table ID in
the highest bit and the entry's hash value in the lowest bits. The
lowest part of the hash value is used as bucket ID, the remaining
part is used to filter the entries in the bucket before matching
the keys and as result, helps the lookup operation to access only
one cache line. By knowing the table ID and bucket ID for entry,
we can unlink it without calculating the hash value and doing
lookup by keys. We need only to validate the saved hash_key under
lock.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h            |  49 ++-
 net/netfilter/ipvs/ip_vs_ctl.c | 673 +++++++++++++++++++++++++++------
 2 files changed, 593 insertions(+), 129 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 8f3c8b0f766c..48e35a24e229 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -35,12 +35,10 @@
 
 #define IP_VS_HDR_INVERSE	1
 #define IP_VS_HDR_ICMP		2
-/*
- *	Hash table: for virtual service lookups
- */
-#define IP_VS_SVC_TAB_BITS 8
-#define IP_VS_SVC_TAB_SIZE BIT(IP_VS_SVC_TAB_BITS)
-#define IP_VS_SVC_TAB_MASK (IP_VS_SVC_TAB_SIZE - 1)
+
+/* svc_table limits */
+#define IP_VS_SVC_TAB_MIN_BITS	4
+#define IP_VS_SVC_TAB_MAX_BITS	20
 
 /* Generic access of ipvs struct */
 static inline struct netns_ipvs *net_ipvs(struct net* net)
@@ -51,8 +49,6 @@ static inline struct netns_ipvs *net_ipvs(struct net* net)
 /* Connections' size value needed by ip_vs_ctl.c */
 extern int ip_vs_conn_tab_size;
 
-extern struct mutex __ip_vs_mutex;
-
 struct ip_vs_iphdr {
 	int hdr_flags;	/* ipvs flags */
 	__u32 off;	/* Where IP or IPv4 header starts */
@@ -289,6 +285,12 @@ static inline int ip_vs_af_index(int af)
 	return af == AF_INET6 ? IP_VS_AF_INET6 : IP_VS_AF_INET;
 }
 
+/* work_flags */
+enum {
+	IP_VS_WORK_SVC_RESIZE,		/* Schedule svc_resize_work */
+	IP_VS_WORK_SVC_NORESIZE,	/* Stopping svc_resize_work */
+};
+
 /* The port number of FTP service (in network order). */
 #define FTPPORT  cpu_to_be16(21)
 #define FTPDATA  cpu_to_be16(20)
@@ -888,14 +890,15 @@ struct ip_vs_dest_user_kern {
  * forwarding entries.
  */
 struct ip_vs_service {
-	struct hlist_node	s_list;   /* node in service table */
-	atomic_t		refcnt;   /* reference counter */
-
+	struct hlist_bl_node	s_list;   /* node in service table */
+	u32			hash_key; /* Key for the hash table */
 	u16			af;       /* address family */
 	__u16			protocol; /* which protocol (TCP/UDP) */
+
 	union nf_inet_addr	addr;	  /* IP address for virtual service */
-	__be16			port;	  /* port number for the service */
 	__u32                   fwmark;   /* firewall mark of the service */
+	atomic_t		refcnt;   /* reference counter */
+	__be16			port;	  /* port number for the service */
 	unsigned int		flags;	  /* service status flags */
 	unsigned int		timeout;  /* persistent timeout in ticks */
 	__be32			netmask;  /* grouping granularity, mask/plen */
@@ -1154,6 +1157,10 @@ struct netns_ipvs {
 	struct list_head	dest_trash;
 	spinlock_t		dest_trash_lock;
 	struct timer_list	dest_trash_timer; /* expiration timer */
+	struct mutex		service_mutex;    /* service reconfig */
+	struct rw_semaphore	svc_resize_sem;   /* svc_table resizing */
+	struct delayed_work	svc_resize_work;  /* resize svc_table */
+	atomic_t		svc_table_changes;/* ++ on new table */
 	/* Service counters */
 	atomic_t		num_services[IP_VS_AF_MAX];   /* Services */
 	atomic_t		fwm_services[IP_VS_AF_MAX];   /* Services */
@@ -1218,6 +1225,7 @@ struct netns_ipvs {
 	int			sysctl_est_nice;	/* kthread nice */
 	int			est_stopped;		/* stop tasks */
 #endif
+	int			sysctl_svc_lfactor;
 
 	/* ip_vs_lblc */
 	int			sysctl_lblc_expiration;
@@ -1227,6 +1235,7 @@ struct netns_ipvs {
 	int			sysctl_lblcr_expiration;
 	struct ctl_table_header	*lblcr_ctl_header;
 	struct ctl_table	*lblcr_ctl_table;
+	unsigned long		work_flags;	/* IP_VS_WORK_* flags */
 	/* ip_vs_est */
 	struct delayed_work	est_reload_work;/* Reload kthread tasks */
 	struct mutex		est_mutex;	/* protect kthread tasks */
@@ -1258,9 +1267,7 @@ struct netns_ipvs {
 	unsigned int		mixed_address_family_dests;
 	unsigned int		hooks_afmask;	/* &1=AF_INET, &2=AF_INET6 */
 
-	/* the service mutex that protect svc_table and svc_fwm_table */
-	struct mutex service_mutex;
-	struct hlist_head svc_table[IP_VS_SVC_TAB_SIZE];	/* Services */
+	struct ip_vs_rht __rcu	*svc_table;	/* Services */
 };
 
 #define DEFAULT_SYNC_THRESHOLD	3
@@ -1510,6 +1517,18 @@ static inline int sysctl_est_nice(struct netns_ipvs *ipvs)
 
 #endif
 
+/* Get load factor to map num_services/u_thresh to t->size
+ * Smaller value decreases u_thresh to reduce collisions but increases
+ * the table size
+ * Returns factor where:
+ * - <0: u_thresh = size >> -factor, eg. lfactor -2 = 25% load
+ * - >=0: u_thresh = size << factor, eg. lfactor 1 = 200% load
+ */
+static inline int sysctl_svc_lfactor(struct netns_ipvs *ipvs)
+{
+	return READ_ONCE(ipvs->sysctl_svc_lfactor);
+}
+
 /* IPVS core functions
  * (from ip_vs_core.c)
  */
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 564e09f0f90a..3f1c5af9c0de 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -29,6 +29,7 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/mutex.h>
+#include <linux/rcupdate_wait.h>
 
 #include <net/net_namespace.h>
 #include <linux/nsproxy.h>
@@ -293,47 +294,59 @@ ip_vs_use_count_dec(void)
 }
 
 
-
+/* Service hashing:
+ * Operation			Locking order
+ * ---------------------------------------------------------------------------
+ * add table			service_mutex, svc_resize_sem(W)
+ * del table			service_mutex
+ * move between tables		svc_resize_sem(W), seqcount_t(W), bit lock
+ * add/del service		service_mutex, bit lock
+ * find service			RCU, seqcount_t(R)
+ * walk services(blocking)	service_mutex, svc_resize_sem(R)
+ * walk services(non-blocking)	RCU, seqcount_t(R)
+ *
+ * - new tables are linked/unlinked under service_mutex and svc_resize_sem
+ * - new table is linked on resizing and all operations can run in parallel
+ * in 2 tables until the new table is registered as current one
+ * - two contexts can modify buckets: config and table resize, both in
+ * process context
+ * - only table resizer can move entries, so we do not protect t->seqc[]
+ * items with t->lock[]
+ * - lookups occur under RCU lock and seqcount reader lock to detect if
+ * services are moved to new table
+ * - move operations may disturb readers: find operation will not miss entries
+ * but walkers may see same entry twice if they are forced to retry chains
+ * - walkers using cond_resched_rcu() on !PREEMPT_RCU may need to hold
+ * service_mutex to disallow new tables to be installed or to check
+ * svc_table_changes and repeat the RCU read section if new table is installed
+ */
 
 /*
  *	Returns hash value for virtual service
  */
-static inline unsigned int
-ip_vs_svc_hashkey(struct netns_ipvs *ipvs, int af, unsigned int proto,
+static inline u32
+ip_vs_svc_hashval(struct ip_vs_rht *t, int af, unsigned int proto,
 		  const union nf_inet_addr *addr, __be16 port)
 {
-	unsigned int porth = ntohs(port);
-	__be32 addr_fold = addr->ip;
-	__u32 ahash;
-
-#ifdef CONFIG_IP_VS_IPV6
-	if (af == AF_INET6)
-		addr_fold = addr->ip6[0]^addr->ip6[1]^
-			    addr->ip6[2]^addr->ip6[3];
-#endif
-	ahash = ntohl(addr_fold);
-	ahash ^= ((size_t) ipvs >> 8);
-
-	return (proto ^ ahash ^ (porth >> IP_VS_SVC_TAB_BITS) ^ porth) &
-	       IP_VS_SVC_TAB_MASK;
+	return ip_vs_rht_hash_linfo(t, af, addr, ntohs(port), proto);
 }
 
 /*
  *	Returns hash value of fwmark for virtual service lookup
  */
-static inline unsigned int ip_vs_svc_fwm_hashkey(struct netns_ipvs *ipvs, __u32 fwmark)
+static inline u32 ip_vs_svc_fwm_hashval(struct ip_vs_rht *t, int af,
+					__u32 fwmark)
 {
-	return (((size_t)ipvs>>8) ^ fwmark) & IP_VS_SVC_TAB_MASK;
+	return jhash_2words(fwmark, af, (u32)t->hash_key.key[0]);
 }
 
-/*
- *	Hashes a service in the svc_table by <netns,proto,addr,port>
- *	or by fwmark.
- *	Should be called with locked tables.
- */
+/* Hashes a service in the svc_table by <proto,addr,port> or by fwmark */
 static int ip_vs_svc_hash(struct ip_vs_service *svc)
 {
-	unsigned int hash;
+	struct netns_ipvs *ipvs = svc->ipvs;
+	struct hlist_bl_head *head;
+	struct ip_vs_rht *t;
+	u32 hash;
 
 	if (svc->flags & IP_VS_SVC_F_HASHED) {
 		pr_err("%s(): request for already hashed, called from %pS\n",
@@ -341,23 +354,32 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
 		return 0;
 	}
 
+	/* increase its refcnt because it is referenced by the svc table */
+	atomic_inc(&svc->refcnt);
+
+	/* New entries go into recent table */
+	t = rcu_dereference_protected(ipvs->svc_table, 1);
+	t = rcu_dereference_protected(t->new_tbl, 1);
+
 	if (svc->fwmark == 0) {
 		/*
-		 *  Hash it by <netns,protocol,addr,port>
+		 *  Hash it by <protocol,addr,port>
 		 */
-		hash = ip_vs_svc_hashkey(svc->ipvs, svc->af, svc->protocol,
+		hash = ip_vs_svc_hashval(t, svc->af, svc->protocol,
 					 &svc->addr, svc->port);
 	} else {
 		/*
 		 *  Hash it by fwmark
 		 */
-		hash = ip_vs_svc_fwm_hashkey(svc->ipvs, svc->fwmark);
+		hash = ip_vs_svc_fwm_hashval(t, svc->af, svc->fwmark);
 	}
-	hlist_add_head_rcu(&svc->s_list, &svc->ipvs->svc_table[hash]);
-
+	head = t->buckets + (hash & t->mask);
+	hlist_bl_lock(head);
+	WRITE_ONCE(svc->hash_key, ip_vs_rht_build_hash_key(t, hash));
 	svc->flags |= IP_VS_SVC_F_HASHED;
-	/* increase its refcnt because it is referenced by the svc table */
-	atomic_inc(&svc->refcnt);
+	hlist_bl_add_head_rcu(&svc->s_list, head);
+	hlist_bl_unlock(head);
+
 	return 1;
 }
 
@@ -368,17 +390,45 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
  */
 static int ip_vs_svc_unhash(struct ip_vs_service *svc)
 {
+	struct netns_ipvs *ipvs = svc->ipvs;
+	struct hlist_bl_head *head;
+	struct ip_vs_rht *t;
+	u32 hash_key2;
+	u32 hash_key;
+
 	if (!(svc->flags & IP_VS_SVC_F_HASHED)) {
 		pr_err("%s(): request for unhash flagged, called from %pS\n",
 		       __func__, __builtin_return_address(0));
 		return 0;
 	}
 
+	t = rcu_dereference_protected(ipvs->svc_table, 1);
+	hash_key = READ_ONCE(svc->hash_key);
+	/* We need to lock the bucket in the right table */
+	if (ip_vs_rht_same_table(t, hash_key)) {
+		head = t->buckets + (hash_key & t->mask);
+		hlist_bl_lock(head);
+		/* Ensure hash_key is read under lock */
+		hash_key2 = READ_ONCE(svc->hash_key);
+		/* Moved to new table ? */
+		if (hash_key != hash_key2) {
+			hlist_bl_unlock(head);
+			t = rcu_dereference_protected(t->new_tbl, 1);
+			head = t->buckets + (hash_key2 & t->mask);
+			hlist_bl_lock(head);
+		}
+	} else {
+		/* It is already moved to new table */
+		t = rcu_dereference_protected(t->new_tbl, 1);
+		head = t->buckets + (hash_key & t->mask);
+		hlist_bl_lock(head);
+	}
 	/* Remove it from svc_table */
-	hlist_del_rcu(&svc->s_list);
+	hlist_bl_del_rcu(&svc->s_list);
 
 	svc->flags &= ~IP_VS_SVC_F_HASHED;
 	atomic_dec(&svc->refcnt);
+	hlist_bl_unlock(head);
 	return 1;
 }
 
@@ -390,18 +440,29 @@ static inline struct ip_vs_service *
 __ip_vs_service_find(struct netns_ipvs *ipvs, int af, __u16 protocol,
 		     const union nf_inet_addr *vaddr, __be16 vport)
 {
-	unsigned int hash;
+	DECLARE_IP_VS_RHT_WALK_BUCKET_RCU();
+	struct hlist_bl_head *head;
 	struct ip_vs_service *svc;
-
-	/* Check for "full" addressed entries */
-	hash = ip_vs_svc_hashkey(ipvs, af, protocol, vaddr, vport);
-
-	hlist_for_each_entry_rcu(svc, &ipvs->svc_table[hash], s_list) {
-		if (svc->af == af && ip_vs_addr_equal(af, &svc->addr, vaddr) &&
-		    svc->port == vport && svc->protocol == protocol &&
-		    !svc->fwmark) {
-			/* HIT */
-			return svc;
+	struct ip_vs_rht *t, *p;
+	struct hlist_bl_node *e;
+	u32 hash, hash_key;
+
+	ip_vs_rht_for_each_table_rcu(ipvs->svc_table, t, p) {
+		/* Check for "full" addressed entries */
+		hash = ip_vs_svc_hashval(t, af, protocol, vaddr, vport);
+
+		hash_key = ip_vs_rht_build_hash_key(t, hash);
+		ip_vs_rht_walk_bucket_rcu(t, hash_key, head) {
+			hlist_bl_for_each_entry_rcu(svc, e, head, s_list) {
+				if (READ_ONCE(svc->hash_key) == hash_key &&
+				    svc->af == af &&
+				    ip_vs_addr_equal(af, &svc->addr, vaddr) &&
+				    svc->port == vport &&
+				    svc->protocol == protocol && !svc->fwmark) {
+					/* HIT */
+					return svc;
+				}
+			}
 		}
 	}
 
@@ -415,16 +476,26 @@ __ip_vs_service_find(struct netns_ipvs *ipvs, int af, __u16 protocol,
 static inline struct ip_vs_service *
 __ip_vs_svc_fwm_find(struct netns_ipvs *ipvs, int af, __u32 fwmark)
 {
-	unsigned int hash;
+	DECLARE_IP_VS_RHT_WALK_BUCKET_RCU();
+	struct hlist_bl_head *head;
 	struct ip_vs_service *svc;
-
-	/* Check for fwmark addressed entries */
-	hash = ip_vs_svc_fwm_hashkey(ipvs, fwmark);
-
-	hlist_for_each_entry_rcu(svc, &ipvs->svc_table[hash], s_list) {
-		if (svc->fwmark == fwmark && svc->af == af) {
-			/* HIT */
-			return svc;
+	struct ip_vs_rht *t, *p;
+	struct hlist_bl_node *e;
+	u32 hash, hash_key;
+
+	ip_vs_rht_for_each_table_rcu(ipvs->svc_table, t, p) {
+		/* Check for fwmark addressed entries */
+		hash = ip_vs_svc_fwm_hashval(t, af, fwmark);
+
+		hash_key = ip_vs_rht_build_hash_key(t, hash);
+		ip_vs_rht_walk_bucket_rcu(t, hash_key, head) {
+			hlist_bl_for_each_entry_rcu(svc, e, head, s_list) {
+				if (READ_ONCE(svc->hash_key) == hash_key &&
+				    svc->fwmark == fwmark && svc->af == af) {
+					/* HIT */
+					return svc;
+				}
+			}
 		}
 	}
 
@@ -487,6 +558,220 @@ ip_vs_service_find(struct netns_ipvs *ipvs, int af, __u32 fwmark, __u16 protocol
 	return svc;
 }
 
+/* Return the number of registered services */
+static int ip_vs_get_num_services(struct netns_ipvs *ipvs)
+{
+	int ns = 0, ni = IP_VS_AF_MAX;
+
+	while (--ni >= 0)
+		ns += atomic_read(&ipvs->num_services[ni]);
+	return ns;
+}
+
+/* Get default load factor to map num_services/u_thresh to t->size */
+static int ip_vs_svc_default_load_factor(struct netns_ipvs *ipvs)
+{
+	int factor;
+
+	if (net_eq(ipvs->net, &init_net))
+		factor = -3;	/* grow if load is above 12.5% */
+	else
+		factor = -2;	/* grow if load is above 25% */
+	return factor;
+}
+
+/* Get the desired svc_table size */
+static int ip_vs_svc_desired_size(struct netns_ipvs *ipvs, struct ip_vs_rht *t,
+				  int lfactor)
+{
+	return ip_vs_rht_desired_size(ipvs, t, ip_vs_get_num_services(ipvs),
+				      lfactor, IP_VS_SVC_TAB_MIN_BITS,
+				      IP_VS_SVC_TAB_MAX_BITS);
+}
+
+/* Allocate svc_table */
+static struct ip_vs_rht *ip_vs_svc_table_alloc(struct netns_ipvs *ipvs,
+					       int buckets, int lfactor)
+{
+	struct ip_vs_rht *t;
+	int scounts, locks;
+
+	/* No frequent lookups to race with resizing, so use max of 64
+	 * seqcounts. Only resizer moves entries, so use 0 locks.
+	 */
+	scounts = clamp(buckets >> 4, 1, 64);
+	locks = 0;
+
+	t = ip_vs_rht_alloc(buckets, scounts, locks);
+	if (!t)
+		return NULL;
+	t->lfactor = lfactor;
+	ip_vs_rht_set_thresholds(t, t->size, lfactor, IP_VS_SVC_TAB_MIN_BITS,
+				 IP_VS_SVC_TAB_MAX_BITS);
+	return t;
+}
+
+/* svc_table resizer work */
+static void svc_resize_work_handler(struct work_struct *work)
+{
+	struct hlist_bl_head *head, *head2;
+	struct ip_vs_rht *t_free = NULL;
+	unsigned int resched_score = 0;
+	struct hlist_bl_node *cn, *nn;
+	struct ip_vs_rht *t, *t_new;
+	struct ip_vs_service *svc;
+	struct netns_ipvs *ipvs;
+	bool more_work = true;
+	seqcount_t *sc;
+	int limit = 0;
+	int new_size;
+	int lfactor;
+	u32 bucket;
+
+	ipvs = container_of(work, struct netns_ipvs, svc_resize_work.work);
+
+	if (!down_write_trylock(&ipvs->svc_resize_sem))
+		goto out;
+	if (!mutex_trylock(&ipvs->service_mutex))
+		goto unlock_sem;
+	more_work = false;
+	clear_bit(IP_VS_WORK_SVC_RESIZE, &ipvs->work_flags);
+	if (!READ_ONCE(ipvs->enable) ||
+	    test_bit(IP_VS_WORK_SVC_NORESIZE, &ipvs->work_flags))
+		goto unlock_m;
+	t = rcu_dereference_protected(ipvs->svc_table, 1);
+	/* Do nothing if table is removed */
+	if (!t)
+		goto unlock_m;
+	/* New table needs to be registered? BUG! */
+	if (t != rcu_dereference_protected(t->new_tbl, 1))
+		goto unlock_m;
+
+	lfactor = sysctl_svc_lfactor(ipvs);
+	/* Should we resize ? */
+	new_size = ip_vs_svc_desired_size(ipvs, t, lfactor);
+	if (new_size == t->size && lfactor == t->lfactor)
+		goto unlock_m;
+
+	t_new = ip_vs_svc_table_alloc(ipvs, new_size, lfactor);
+	if (!t_new) {
+		more_work = true;
+		goto unlock_m;
+	}
+	/* Flip the table_id */
+	t_new->table_id = t->table_id ^ IP_VS_RHT_TABLE_ID_MASK;
+
+	rcu_assign_pointer(t->new_tbl, t_new);
+	/* Allow add/del to new_tbl while moving from old table */
+	mutex_unlock(&ipvs->service_mutex);
+
+	ip_vs_rht_for_each_bucket(t, bucket, head) {
+same_bucket:
+		if (++limit >= 16) {
+			if (!READ_ONCE(ipvs->enable) ||
+			    test_bit(IP_VS_WORK_SVC_NORESIZE,
+				     &ipvs->work_flags))
+				goto unlock_sem;
+			if (resched_score >= 100) {
+				resched_score = 0;
+				cond_resched();
+			}
+			limit = 0;
+		}
+		if (hlist_bl_empty(head)) {
+			resched_score++;
+			continue;
+		}
+		/* Preemption calls ahead... */
+		resched_score = 0;
+
+		sc = &t->seqc[bucket & t->seqc_mask];
+		/* seqcount_t usage considering PREEMPT_RT rules:
+		 * - we are the only writer => preemption can be allowed
+		 * - readers (SoftIRQ) => disable BHs
+		 * - readers (processes) => preemption should be disabled
+		 */
+		local_bh_disable();
+		preempt_disable_nested();
+		write_seqcount_begin(sc);
+		hlist_bl_lock(head);
+
+		hlist_bl_for_each_entry_safe(svc, cn, nn, head, s_list) {
+			u32 hash;
+
+			/* New hash for the new table */
+			if (svc->fwmark == 0) {
+				/*  Hash it by <protocol,addr,port> */
+				hash = ip_vs_svc_hashval(t_new, svc->af,
+							 svc->protocol,
+							 &svc->addr, svc->port);
+			} else {
+				/* Hash it by fwmark */
+				hash = ip_vs_svc_fwm_hashval(t_new, svc->af,
+							     svc->fwmark);
+			}
+			hlist_bl_del_rcu(&svc->s_list);
+			head2 = t_new->buckets + (hash & t_new->mask);
+
+			hlist_bl_lock(head2);
+			WRITE_ONCE(svc->hash_key,
+				   ip_vs_rht_build_hash_key(t_new, hash));
+			/* t_new->seqc are not used at this stage, we race
+			 * only with add/del, so only lock the bucket.
+			 */
+			hlist_bl_add_head_rcu(&svc->s_list, head2);
+			hlist_bl_unlock(head2);
+			/* Too long chain? Do it in steps */
+			if (++limit >= 64)
+				break;
+		}
+
+		hlist_bl_unlock(head);
+		write_seqcount_end(sc);
+		preempt_enable_nested();
+		local_bh_enable();
+		if (limit >= 64)
+			goto same_bucket;
+	}
+
+	/* Tables can be switched only under service_mutex */
+	while (!mutex_trylock(&ipvs->service_mutex)) {
+		cond_resched();
+		if (!READ_ONCE(ipvs->enable) ||
+		    test_bit(IP_VS_WORK_SVC_NORESIZE, &ipvs->work_flags))
+			goto unlock_sem;
+	}
+	if (!READ_ONCE(ipvs->enable) ||
+	    test_bit(IP_VS_WORK_SVC_NORESIZE, &ipvs->work_flags))
+		goto unlock_m;
+
+	rcu_assign_pointer(ipvs->svc_table, t_new);
+	/* Inform readers that new table is installed */
+	smp_mb__before_atomic();
+	atomic_inc(&ipvs->svc_table_changes);
+	t_free = t;
+
+unlock_m:
+	mutex_unlock(&ipvs->service_mutex);
+
+unlock_sem:
+	up_write(&ipvs->svc_resize_sem);
+
+	if (t_free) {
+		/* RCU readers should not see more than two tables in chain.
+		 * To prevent new table to be attached wait here instead of
+		 * freeing the old table in RCU callback.
+		 */
+		synchronize_rcu();
+		ip_vs_rht_free(t_free);
+	}
+
+out:
+	if (!READ_ONCE(ipvs->enable) || !more_work ||
+	    test_bit(IP_VS_WORK_SVC_NORESIZE, &ipvs->work_flags))
+		return;
+	queue_delayed_work(system_unbound_wq, &ipvs->svc_resize_work, 1);
+}
 
 static inline void
 __ip_vs_bind_svc(struct ip_vs_dest *dest, struct ip_vs_service *svc)
@@ -1357,12 +1642,13 @@ static int
 ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 		  struct ip_vs_service **svc_p)
 {
-	int ret = 0;
 	struct ip_vs_scheduler *sched = NULL;
+	struct ip_vs_rht *t, *t_new = NULL;
 	int af_id = ip_vs_af_index(u->af);
-	struct ip_vs_pe *pe = NULL;
 	struct ip_vs_service *svc = NULL;
+	struct ip_vs_pe *pe = NULL;
 	int ret_hooks = -1;
+	int ret = 0;
 
 	/* increase the module use count */
 	if (!ip_vs_use_count_inc())
@@ -1404,6 +1690,18 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 	}
 #endif
 
+	t = rcu_dereference_protected(ipvs->svc_table, 1);
+	if (!t) {
+		int lfactor = sysctl_svc_lfactor(ipvs);
+		int new_size = ip_vs_svc_desired_size(ipvs, NULL, lfactor);
+
+		t_new = ip_vs_svc_table_alloc(ipvs, new_size, lfactor);
+		if (!t_new) {
+			ret = -ENOMEM;
+			goto out_err;
+		}
+	}
+
 	if (!atomic_read(&ipvs->num_services[af_id])) {
 		ret = ip_vs_register_hooks(ipvs, u->af);
 		if (ret < 0)
@@ -1449,6 +1747,12 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 	if (ret < 0)
 		goto out_err;
 
+	if (t_new) {
+		clear_bit(IP_VS_WORK_SVC_NORESIZE, &ipvs->work_flags);
+		rcu_assign_pointer(ipvs->svc_table, t_new);
+		t_new = NULL;
+	}
+
 	/* Update the virtual service counters */
 	if (svc->port == FTPPORT)
 		atomic_inc(&ipvs->ftpsvc_counter[af_id]);
@@ -1470,6 +1774,12 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 	/* Hash the service into the service table */
 	ip_vs_svc_hash(svc);
 
+	/* Schedule resize work */
+	if (t && ip_vs_get_num_services(ipvs) > t->u_thresh &&
+	    !test_and_set_bit(IP_VS_WORK_SVC_RESIZE, &ipvs->work_flags))
+		queue_delayed_work(system_unbound_wq, &ipvs->svc_resize_work,
+				   1);
+
 	*svc_p = svc;
 
 	if (!READ_ONCE(ipvs->enable)) {
@@ -1484,6 +1794,8 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 
 
  out_err:
+	if (t_new)
+		ip_vs_rht_free(t_new);
 	if (ret_hooks >= 0)
 		ip_vs_unregister_hooks(ipvs, u->af);
 	if (svc != NULL) {
@@ -1671,10 +1983,38 @@ static void ip_vs_unlink_service(struct ip_vs_service *svc, bool cleanup)
  */
 static int ip_vs_del_service(struct ip_vs_service *svc)
 {
+	struct netns_ipvs *ipvs;
+	struct ip_vs_rht *t, *p;
+	int ns;
+
 	if (svc == NULL)
 		return -EEXIST;
+	ipvs = svc->ipvs;
 	ip_vs_unlink_service(svc, false);
-
+	t = rcu_dereference_protected(ipvs->svc_table, 1);
+
+	/* Drop the table if no more services */
+	ns = ip_vs_get_num_services(ipvs);
+	if (!ns) {
+		/* Stop the resizer and drop the tables */
+		set_bit(IP_VS_WORK_SVC_NORESIZE, &ipvs->work_flags);
+		cancel_delayed_work_sync(&ipvs->svc_resize_work);
+		if (t) {
+			rcu_assign_pointer(ipvs->svc_table, NULL);
+			while (1) {
+				p = rcu_dereference_protected(t->new_tbl, 1);
+				call_rcu(&t->rcu_head, ip_vs_rht_rcu_free);
+				if (p == t)
+					break;
+				t = p;
+			}
+		}
+	} else if (ns <= t->l_thresh &&
+		   !test_and_set_bit(IP_VS_WORK_SVC_RESIZE,
+				     &ipvs->work_flags)) {
+		queue_delayed_work(system_unbound_wq, &ipvs->svc_resize_work,
+				   1);
+	}
 	return 0;
 }
 
@@ -1684,14 +2024,36 @@ static int ip_vs_del_service(struct ip_vs_service *svc)
  */
 static int ip_vs_flush(struct netns_ipvs *ipvs, bool cleanup)
 {
-	int idx;
+	DECLARE_IP_VS_RHT_WALK_BUCKETS();
+	struct hlist_bl_head *head;
 	struct ip_vs_service *svc;
-	struct hlist_node *n;
+	struct hlist_bl_node *ne;
+	struct hlist_bl_node *e;
+	struct ip_vs_rht *t, *p;
+
+	/* Stop the resizer and drop the tables */
+	if (!test_and_set_bit(IP_VS_WORK_SVC_NORESIZE, &ipvs->work_flags))
+		cancel_delayed_work_sync(&ipvs->svc_resize_work);
+	/* No resizer, so now we have exclusive write access */
+
+	if (ip_vs_get_num_services(ipvs)) {
+		ip_vs_rht_walk_buckets(ipvs->svc_table, head) {
+			hlist_bl_for_each_entry_safe(svc, e, ne, head, s_list)
+				ip_vs_unlink_service(svc, cleanup);
+		}
+	}
 
-	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		hlist_for_each_entry_safe(svc, n, &ipvs->svc_table[idx],
-					  s_list)
-			ip_vs_unlink_service(svc, cleanup);
+	/* Unregister the hash table and release it after RCU grace period */
+	t = rcu_dereference_protected(ipvs->svc_table, 1);
+	if (t) {
+		rcu_assign_pointer(ipvs->svc_table, NULL);
+		while (1) {
+			p = rcu_dereference_protected(t->new_tbl, 1);
+			call_rcu(&t->rcu_head, ip_vs_rht_rcu_free);
+			if (p == t)
+				break;
+			t = p;
+		}
 	}
 	return 0;
 }
@@ -1742,19 +2104,44 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 	struct net *net = dev_net(dev);
 	struct netns_ipvs *ipvs = net_ipvs(net);
+	DECLARE_IP_VS_RHT_WALK_BUCKETS_RCU();
+	unsigned int resched_score = 0;
+	struct hlist_bl_head *head;
 	struct ip_vs_service *svc;
+	struct hlist_bl_node *e;
 	struct ip_vs_dest *dest;
-	unsigned int idx;
+	int old_gen, new_gen;
 
 	if (event != NETDEV_DOWN || !ipvs)
 		return NOTIFY_DONE;
 	IP_VS_DBG(3, "%s() dev=%s\n", __func__, dev->name);
+
+	old_gen = atomic_read(&ipvs->svc_table_changes);
+
 	rcu_read_lock();
-	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		hlist_for_each_entry_rcu(svc, &ipvs->svc_table[idx], s_list)
+
+repeat:
+	smp_rmb(); /* ipvs->svc_table and svc_table_changes */
+	ip_vs_rht_walk_buckets_rcu(ipvs->svc_table, head) {
+		hlist_bl_for_each_entry_rcu(svc, e, head, s_list) {
 			list_for_each_entry_rcu(dest, &svc->destinations,
-						n_list)
+						n_list) {
 				ip_vs_forget_dev(dest, dev);
+				resched_score += 10;
+			}
+			resched_score++;
+		}
+		resched_score++;
+		if (resched_score >= 100) {
+			resched_score = 0;
+			cond_resched_rcu();
+			new_gen = atomic_read(&ipvs->svc_table_changes);
+			/* New table installed ? */
+			if (old_gen != new_gen) {
+				old_gen = new_gen;
+				goto repeat;
+			}
+		}
 	}
 	rcu_read_unlock();
 
@@ -1777,14 +2164,28 @@ static int ip_vs_zero_service(struct ip_vs_service *svc)
 
 static int ip_vs_zero_all(struct netns_ipvs *ipvs)
 {
-	int idx;
+	DECLARE_IP_VS_RHT_WALK_BUCKETS_RCU();
+	unsigned int resched_score = 0;
+	struct hlist_bl_head *head;
 	struct ip_vs_service *svc;
+	struct hlist_bl_node *e;
 
-	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		hlist_for_each_entry(svc, &ipvs->svc_table[idx], s_list)
+	rcu_read_lock();
+
+	ip_vs_rht_walk_buckets_rcu(ipvs->svc_table, head) {
+		hlist_bl_for_each_entry_rcu(svc, e, head, s_list) {
 			ip_vs_zero_service(svc);
+			resched_score += 10;
+		}
+		resched_score++;
+		if (resched_score >= 100) {
+			resched_score = 0;
+			cond_resched_rcu();
+		}
 	}
 
+	rcu_read_unlock();
+
 	ip_vs_zero_stats(&ipvs->tot_stats->s);
 	return 0;
 }
@@ -2218,7 +2619,8 @@ static struct ctl_table vs_vars[] = {
 
 struct ip_vs_iter {
 	struct seq_net_private p;  /* Do not move this, netns depends upon it*/
-	int bucket;
+	struct ip_vs_rht *t;
+	u32 bucket;
 };
 
 /*
@@ -2239,17 +2641,23 @@ static inline const char *ip_vs_fwd_name(unsigned int flags)
 	}
 }
 
-
+/* Do not expect consistent view during add, del and move(table resize).
+ * We may miss entries and even show duplicates.
+ */
 static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
 {
-	struct net *net = seq_file_net(seq);
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_iter *iter = seq->private;
-	int idx;
+	struct ip_vs_rht *t = iter->t;
 	struct ip_vs_service *svc;
+	struct hlist_bl_node *e;
+	int idx;
 
-	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		hlist_for_each_entry_rcu(svc, &ipvs->svc_table[idx], s_list) {
+	if (!t)
+		return NULL;
+	for (idx = 0; idx < t->size; idx++) {
+		hlist_bl_for_each_entry_rcu(svc, e, &t->buckets[idx], s_list) {
+			if (!ip_vs_rht_same_table(t, READ_ONCE(svc->hash_key)))
+				break;
 			if (pos-- == 0) {
 				iter->bucket = idx;
 				return svc;
@@ -2262,18 +2670,22 @@ static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
 static void *ip_vs_info_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(RCU)
 {
+	struct ip_vs_iter *iter = seq->private;
+	struct net *net = seq_file_net(seq);
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
 	rcu_read_lock();
+	iter->t = rcu_dereference(ipvs->svc_table);
 	return *pos ? ip_vs_info_array(seq, *pos - 1) : SEQ_START_TOKEN;
 }
 
 
 static void *ip_vs_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct hlist_node *e;
-	struct ip_vs_iter *iter;
 	struct ip_vs_service *svc;
-	struct net *net = seq_file_net(seq);
-	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct ip_vs_iter *iter;
+	struct hlist_bl_node *e;
+	struct ip_vs_rht *t;
 
 	++*pos;
 	if (v == SEQ_START_TOKEN)
@@ -2281,15 +2693,22 @@ static void *ip_vs_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 	svc = v;
 	iter = seq->private;
+	t = iter->t;
+	if (!t)
+		return NULL;
 
-	e = rcu_dereference(hlist_next_rcu(&svc->s_list));
-	if (e)
-		return hlist_entry(e, struct ip_vs_service, s_list);
+	hlist_bl_for_each_entry_continue_rcu(svc, e, s_list) {
+		/* Our cursor was moved to new table ? */
+		if (!ip_vs_rht_same_table(t, READ_ONCE(svc->hash_key)))
+			break;
+		return svc;
+	}
 
-	while (++iter->bucket < IP_VS_SVC_TAB_SIZE) {
-		hlist_for_each_entry_rcu(svc,
-					 &ipvs->svc_table[iter->bucket],
-					 s_list) {
+	while (++iter->bucket < t->size) {
+		hlist_bl_for_each_entry_rcu(svc, e, &t->buckets[iter->bucket],
+					    s_list) {
+			if (!ip_vs_rht_same_table(t, READ_ONCE(svc->hash_key)))
+				break;
 			return svc;
 		}
 	}
@@ -2770,13 +3189,18 @@ __ip_vs_get_service_entries(struct netns_ipvs *ipvs,
 			    const struct ip_vs_get_services *get,
 			    struct ip_vs_get_services __user *uptr)
 {
-	int idx, count=0;
-	struct ip_vs_service *svc;
 	struct ip_vs_service_entry entry;
+	DECLARE_IP_VS_RHT_WALK_BUCKETS();
+	struct hlist_bl_head *head;
+	struct ip_vs_service *svc;
+	struct hlist_bl_node *e;
+	int count = 0;
 	int ret = 0;
 
-	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		hlist_for_each_entry(svc, &ipvs->svc_table[idx], s_list) {
+	lockdep_assert_held(&ipvs->svc_resize_sem);
+	/* All service modifications are disabled, go ahead */
+	ip_vs_rht_walk_buckets(ipvs->svc_table, head) {
+		hlist_bl_for_each_entry(svc, e, head, s_list) {
 			/* Only expose IPv4 entries to old interface */
 			if (svc->af != AF_INET)
 				continue;
@@ -2948,6 +3372,35 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 		return ret;
 	}
 
+	if (cmd == IP_VS_SO_GET_SERVICES) {
+		struct ip_vs_get_services *get;
+		size_t size;
+
+		get = (struct ip_vs_get_services *)arg;
+		size = struct_size(get, entrytable, get->num_services);
+		if (*len != size) {
+			pr_err("length: %u != %zu\n", *len, size);
+			return -EINVAL;
+		}
+		/* Protect against table resizer moving the entries.
+		 * Try reverse locking, so that we do not hold the mutex
+		 * while waiting for semaphore.
+		 */
+		while (1) {
+			ret = down_read_killable(&ipvs->svc_resize_sem);
+			if (ret < 0)
+				return ret;
+			if (mutex_trylock(&ipvs->service_mutex))
+				break;
+			up_read(&ipvs->svc_resize_sem);
+			cond_resched();
+		}
+		ret = __ip_vs_get_service_entries(ipvs, get, user);
+		up_read(&ipvs->svc_resize_sem);
+		mutex_unlock(&ipvs->service_mutex);
+		return ret;
+	}
+
 	mutex_lock(&ipvs->service_mutex);
 	switch (cmd) {
 	case IP_VS_SO_GET_VERSION:
@@ -2976,22 +3429,6 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	}
 	break;
 
-	case IP_VS_SO_GET_SERVICES:
-	{
-		struct ip_vs_get_services *get;
-		size_t size;
-
-		get = (struct ip_vs_get_services *)arg;
-		size = struct_size(get, entrytable, get->num_services);
-		if (*len != size) {
-			pr_err("length: %u != %zu\n", *len, size);
-			ret = -EINVAL;
-			goto out;
-		}
-		ret = __ip_vs_get_service_entries(ipvs, get, user);
-	}
-	break;
-
 	case IP_VS_SO_GET_SERVICE:
 	{
 		struct ip_vs_service_entry *entry;
@@ -3277,15 +3714,19 @@ static int ip_vs_genl_dump_service(struct sk_buff *skb,
 static int ip_vs_genl_dump_services(struct sk_buff *skb,
 				    struct netlink_callback *cb)
 {
-	int idx = 0, i;
-	int start = cb->args[0];
-	struct ip_vs_service *svc;
+	DECLARE_IP_VS_RHT_WALK_BUCKETS_SAFE_RCU();
 	struct net *net = sock_net(skb->sk);
 	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct hlist_bl_head *head;
+	struct ip_vs_service *svc;
+	struct hlist_bl_node *e;
+	int start = cb->args[0];
+	int idx = 0;
 
+	down_read(&ipvs->svc_resize_sem);
 	rcu_read_lock();
-	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
-		hlist_for_each_entry_rcu(svc, &ipvs->svc_table[i], s_list) {
+	ip_vs_rht_walk_buckets_safe_rcu(ipvs->svc_table, head) {
+		hlist_bl_for_each_entry_rcu(svc, e, head, s_list) {
 			if (++idx <= start)
 				continue;
 			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
@@ -3297,6 +3738,7 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 
 nla_put_failure:
 	rcu_read_unlock();
+	up_read(&ipvs->svc_resize_sem);
 	cb->args[0] = idx;
 
 	return skb->len;
@@ -4306,8 +4748,10 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 
 	/* Initialize service_mutex, svc_table per netns */
 	__mutex_init(&ipvs->service_mutex, "ipvs->service_mutex", &__ipvs_service_key);
-	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++)
-		INIT_HLIST_HEAD(&ipvs->svc_table[idx]);
+	init_rwsem(&ipvs->svc_resize_sem);
+	INIT_DELAYED_WORK(&ipvs->svc_resize_work, svc_resize_work_handler);
+	atomic_set(&ipvs->svc_table_changes, 0);
+	RCU_INIT_POINTER(ipvs->svc_table, NULL);
 
 	/* Initialize rs_table */
 	for (idx = 0; idx < IP_VS_RTAB_SIZE; idx++)
@@ -4326,6 +4770,7 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 	}
 
 	INIT_DELAYED_WORK(&ipvs->est_reload_work, est_reload_work_handler);
+	ipvs->sysctl_svc_lfactor = ip_vs_svc_default_load_factor(ipvs);
 
 	/* procfs stats */
 	ipvs->tot_stats = kzalloc(sizeof(*ipvs->tot_stats), GFP_KERNEL);
-- 
2.53.0


