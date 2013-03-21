From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCHv3 net-next 11/15] ipvs: remove rs_lock by using RCU
Date: Thu, 21 Mar 2013 11:58:08 +0200
Message-ID: <1363859892-9058-12-git-send-email-ja@ssi.bg>
References: <1363859892-9058-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1363859892-9058-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	rs_lock was used to protect rs_table (hash table)
from updaters (under global mutex) and readers (packet handlers).
We can remove rs_lock by using RCU lock for readers. Reclaiming
dest only with kfree_rcu is enough because the readers access
only fields from the ip_vs_dest structure.

	Use hlist for rs_table.

	As we are now using hlist_del_rcu, introduce in_rs_table
flag as replacement for the list_empty checks which do not
work with RCU. It is needed because only NAT dests are in
the rs_table.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |   14 ++++---
 net/netfilter/ipvs/ip_vs_core.c |    5 +-
 net/netfilter/ipvs/ip_vs_ctl.c  |   88 ++++++++++++++-------------------------
 3 files changed, 41 insertions(+), 66 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 564b30d..6873d2d 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -738,7 +738,7 @@ struct ip_vs_dest_dst {
  */
 struct ip_vs_dest {
 	struct list_head	n_list;   /* for the dests in the service */
-	struct list_head	d_list;   /* for table with all the dests */
+	struct hlist_node	d_list;   /* for table with all the dests */
 
 	u16			af;		/* address family */
 	__be16			port;		/* port number of the server */
@@ -767,6 +767,9 @@ struct ip_vs_dest {
 	__be16			vport;		/* virtual port number */
 	union nf_inet_addr	vaddr;		/* virtual IP address */
 	__u32			vfwmark;	/* firewall mark of service */
+
+	struct rcu_head		rcu_head;
+	unsigned int		in_rs_table:1;	/* we are in rs_table */
 };
 
 
@@ -897,7 +900,7 @@ struct netns_ipvs {
 	#define IP_VS_RTAB_SIZE (1 << IP_VS_RTAB_BITS)
 	#define IP_VS_RTAB_MASK (IP_VS_RTAB_SIZE - 1)
 
-	struct list_head	rs_table[IP_VS_RTAB_SIZE];
+	struct hlist_head	rs_table[IP_VS_RTAB_SIZE];
 	/* ip_vs_app */
 	struct list_head	app_list;
 	/* ip_vs_proto */
@@ -933,7 +936,6 @@ struct netns_ipvs {
 
 	int			num_services;    /* no of virtual services */
 
-	rwlock_t		rs_lock;         /* real services table */
 	/* Trash for destinations */
 	struct list_head	dest_trash;
 	/* Service counters */
@@ -1376,9 +1378,9 @@ static inline void ip_vs_service_put(struct ip_vs_service *svc)
 	atomic_dec(&svc->usecnt);
 }
 
-extern struct ip_vs_dest *
-ip_vs_lookup_real_service(struct net *net, int af, __u16 protocol,
-			  const union nf_inet_addr *daddr, __be16 dport);
+extern bool
+ip_vs_has_real_service(struct net *net, int af, __u16 protocol,
+		       const union nf_inet_addr *daddr, __be16 dport);
 
 extern int ip_vs_use_count_inc(void);
 extern void ip_vs_use_count_dec(void);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index b97d0c7..207c3b9 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1164,9 +1164,8 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 					 sizeof(_ports), _ports, &iph);
 		if (pptr == NULL)
 			return NF_ACCEPT;	/* Not for me */
-		if (ip_vs_lookup_real_service(net, af, iph.protocol,
-					      &iph.saddr,
-					      pptr[0])) {
+		if (ip_vs_has_real_service(net, af, iph.protocol, &iph.saddr,
+					   pptr[0])) {
 			/*
 			 * Notify the real server: there is no
 			 * existing entry if it is not RST
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 811cba2..a66b1c7 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -506,17 +506,13 @@ static inline unsigned int ip_vs_rs_hashkey(int af,
 		& IP_VS_RTAB_MASK;
 }
 
-/*
- *	Hashes ip_vs_dest in rs_table by <proto,addr,port>.
- *	should be called with locked tables.
- */
-static int ip_vs_rs_hash(struct netns_ipvs *ipvs, struct ip_vs_dest *dest)
+/* Hash ip_vs_dest in rs_table by <proto,addr,port>. */
+static void ip_vs_rs_hash(struct netns_ipvs *ipvs, struct ip_vs_dest *dest)
 {
 	unsigned int hash;
 
-	if (!list_empty(&dest->d_list)) {
-		return 0;
-	}
+	if (dest->in_rs_table)
+		return;
 
 	/*
 	 *	Hash by proto,addr,port,
@@ -524,60 +520,47 @@ static int ip_vs_rs_hash(struct netns_ipvs *ipvs, struct ip_vs_dest *dest)
 	 */
 	hash = ip_vs_rs_hashkey(dest->af, &dest->addr, dest->port);
 
-	list_add(&dest->d_list, &ipvs->rs_table[hash]);
-
-	return 1;
+	hlist_add_head_rcu(&dest->d_list, &ipvs->rs_table[hash]);
+	dest->in_rs_table = 1;
 }
 
-/*
- *	UNhashes ip_vs_dest from rs_table.
- *	should be called with locked tables.
- */
-static int ip_vs_rs_unhash(struct ip_vs_dest *dest)
+/* Unhash ip_vs_dest from rs_table. */
+static void ip_vs_rs_unhash(struct ip_vs_dest *dest)
 {
 	/*
 	 * Remove it from the rs_table table.
 	 */
-	if (!list_empty(&dest->d_list)) {
-		list_del_init(&dest->d_list);
+	if (dest->in_rs_table) {
+		hlist_del_rcu(&dest->d_list);
+		dest->in_rs_table = 0;
 	}
-
-	return 1;
 }
 
-/*
- *	Lookup real service by <proto,addr,port> in the real service table.
- */
-struct ip_vs_dest *
-ip_vs_lookup_real_service(struct net *net, int af, __u16 protocol,
-			  const union nf_inet_addr *daddr,
-			  __be16 dport)
+/* Check if real service by <proto,addr,port> is present */
+bool ip_vs_has_real_service(struct net *net, int af, __u16 protocol,
+			    const union nf_inet_addr *daddr, __be16 dport)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	unsigned int hash;
 	struct ip_vs_dest *dest;
 
-	/*
-	 *	Check for "full" addressed entries
-	 *	Return the first found entry
-	 */
+	/* Check for "full" addressed entries */
 	hash = ip_vs_rs_hashkey(af, daddr, dport);
 
-	read_lock(&ipvs->rs_lock);
-	list_for_each_entry(dest, &ipvs->rs_table[hash], d_list) {
-		if ((dest->af == af)
-		    && ip_vs_addr_equal(af, &dest->addr, daddr)
-		    && (dest->port == dport)
-		    && ((dest->protocol == protocol) ||
-			dest->vfwmark)) {
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(dest, &ipvs->rs_table[hash], d_list) {
+		if (dest->port == dport &&
+		    dest->af == af &&
+		    ip_vs_addr_equal(af, &dest->addr, daddr) &&
+		    (dest->protocol == protocol || dest->vfwmark)) {
 			/* HIT */
-			read_unlock(&ipvs->rs_lock);
-			return dest;
+			rcu_read_unlock();
+			return true;
 		}
 	}
-	read_unlock(&ipvs->rs_lock);
+	rcu_read_unlock();
 
-	return NULL;
+	return false;
 }
 
 /*
@@ -610,9 +593,6 @@ ip_vs_lookup_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
  * the backup synchronization daemon. It finds the
  * destination to be bound to the received connection
  * on the backup.
- *
- * ip_vs_lookup_real_service() looked promissing, but
- * seems not working as expected.
  */
 struct ip_vs_dest *ip_vs_find_dest(struct net  *net, int af,
 				   const union nf_inet_addr *daddr,
@@ -713,7 +693,7 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
 			__ip_vs_dst_cache_reset(dest);
 			__ip_vs_unbind_svc(dest);
 			free_percpu(dest->stats.cpustats);
-			kfree(dest);
+			kfree_rcu(dest, rcu_head);
 		}
 	}
 
@@ -740,7 +720,7 @@ static void ip_vs_trash_cleanup(struct net *net)
 		__ip_vs_dst_cache_reset(dest);
 		__ip_vs_unbind_svc(dest);
 		free_percpu(dest->stats.cpustats);
-		kfree(dest);
+		kfree_rcu(dest, rcu_head);
 	}
 }
 
@@ -805,9 +785,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 		 *    Put the real service in rs_table if not present.
 		 *    For now only for NAT!
 		 */
-		write_lock_bh(&ipvs->rs_lock);
 		ip_vs_rs_hash(ipvs, dest);
-		write_unlock_bh(&ipvs->rs_lock);
 	}
 	atomic_set(&dest->conn_flags, conn_flags);
 
@@ -903,7 +881,7 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 	atomic_set(&dest->persistconns, 0);
 	atomic_set(&dest->refcnt, 1);
 
-	INIT_LIST_HEAD(&dest->d_list);
+	INIT_HLIST_NODE(&dest->d_list);
 	spin_lock_init(&dest->dst_lock);
 	spin_lock_init(&dest->stats.lock);
 	__ip_vs_update_dest(svc, dest, udest, 1);
@@ -1043,9 +1021,7 @@ static void __ip_vs_del_dest(struct net *net, struct ip_vs_dest *dest)
 	/*
 	 *  Remove it from the d-linked list with the real services.
 	 */
-	write_lock_bh(&ipvs->rs_lock);
 	ip_vs_rs_unhash(dest);
-	write_unlock_bh(&ipvs->rs_lock);
 
 	/*
 	 *  Decrease the refcnt of the dest, and free the dest
@@ -1065,7 +1041,7 @@ static void __ip_vs_del_dest(struct net *net, struct ip_vs_dest *dest)
 		   time, so the operation here is OK */
 		atomic_dec(&dest->svc->refcnt);
 		free_percpu(dest->stats.cpustats);
-		kfree(dest);
+		kfree_rcu(dest, rcu_head);
 	} else {
 		IP_VS_DBG_BUF(3, "Moving dest %s:%u into trash, "
 			      "dest->refcnt=%d\n",
@@ -3809,11 +3785,9 @@ int __net_init ip_vs_control_net_init(struct net *net)
 	int idx;
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	rwlock_init(&ipvs->rs_lock);
