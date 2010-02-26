From: Simon Horman <horms@verge.net.au>
Subject: [RFC] IPVS: Convert connection table lock over to RCU
Date: Fri, 26 Feb 2010 14:00:54 +1100
Message-ID: <20100226030054.GA6111@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>

Signed-off-by: Simon Horman <horms@verge.net.au>

--- 

This seems to be a fairly clean conversion to me. But its my journey
into the world of RCU, so I would appreciate a careful review.

I have deliberately introduced some noise into this patch
in the form of changing the name of some global variables and functions.
This is in order to clearly highlight changes at the call-sites.

The table of 16 locks (4 bits) used for the connection table seems
to be somewhat arbitrary to me, this patch intentionally leaves
that as is.

Index: net-next-2.6/net/netfilter/ipvs/ip_vs_conn.c
===================================================================
--- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c	2010-02-26 10:42:16.000000000 +1100
+++ net-next-2.6/net/netfilter/ipvs/ip_vs_conn.c	2010-02-26 10:52:32.000000000 +1100
@@ -35,6 +35,8 @@
 #include <linux/seq_file.h>
 #include <linux/jhash.h>
 #include <linux/random.h>
+#include <linux/spinlock.h>
+#include <linux/rculist.h>
 
 #include <net/net_namespace.h>
 #include <net/ip_vs.h>
@@ -75,57 +77,37 @@ static unsigned int ip_vs_conn_rnd;
 /*
  *  Fine locking granularity for big connection hash table
  */
-#define CT_LOCKARRAY_BITS  4
-#define CT_LOCKARRAY_SIZE  (1<<CT_LOCKARRAY_BITS)
-#define CT_LOCKARRAY_MASK  (CT_LOCKARRAY_SIZE-1)
+#define CT_MUTEX_BITS  4
+#define CT_MUTEX_SIZE  (1<<CT_MUTEX_BITS)
+#define CT_MUTEX_MASK  (CT_MUTEX_SIZE-1)
 
-struct ip_vs_aligned_lock
+struct ip_vs_aligned_spinlock
 {
-	rwlock_t	l;
+	spinlock_t	l;
 } __attribute__((__aligned__(SMP_CACHE_BYTES)));
 
-/* lock array for conn table */
-static struct ip_vs_aligned_lock
-__ip_vs_conntbl_lock_array[CT_LOCKARRAY_SIZE] __cacheline_aligned;
+/* mutex array for connection table */
+static struct ip_vs_aligned_spinlock
+__ip_vs_conntbl_mutex[CT_MUTEX_SIZE] __cacheline_aligned;
 
-static inline void ct_read_lock(unsigned key)
+static inline void ct_mutex_lock(unsigned key)
 {
-	read_lock(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
+	spin_lock(&__ip_vs_conntbl_mutex[key&CT_MUTEX_MASK].l);
 }
 
-static inline void ct_read_unlock(unsigned key)
+static inline void ct_mutex_unlock(unsigned key)
 {
-	read_unlock(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
+	spin_unlock(&__ip_vs_conntbl_mutex[key&CT_MUTEX_MASK].l);
 }
 
-static inline void ct_write_lock(unsigned key)
+static inline void ct_mutex_lock_bh(unsigned key)
 {
-	write_lock(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
+	spin_lock_bh(&__ip_vs_conntbl_mutex[key&CT_MUTEX_MASK].l);
 }
 
-static inline void ct_write_unlock(unsigned key)
+static inline void ct_mutex_unlock_bh(unsigned key)
 {
-	write_unlock(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
-}
-
-static inline void ct_read_lock_bh(unsigned key)
-{
-	read_lock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
-}
-
-static inline void ct_read_unlock_bh(unsigned key)
-{
-	read_unlock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
-}
-
-static inline void ct_write_lock_bh(unsigned key)
-{
-	write_lock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
-}
-
-static inline void ct_write_unlock_bh(unsigned key)
-{
-	write_unlock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
+	spin_unlock_bh(&__ip_vs_conntbl_mutex[key&CT_MUTEX_MASK].l);
 }
 
 
@@ -155,27 +137,27 @@ static unsigned int ip_vs_conn_hashkey(i
 static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
 {
 	unsigned hash;
-	int ret;
 
 	/* Hash by protocol, client address and port */
 	hash = ip_vs_conn_hashkey(cp->af, cp->protocol, &cp->caddr, cp->cport);
 
-	ct_write_lock(hash);
+	ct_mutex_lock(hash);
 
 	if (!(cp->flags & IP_VS_CONN_F_HASHED)) {
-		list_add(&cp->c_list, &ip_vs_conn_tab[hash]);
+		list_add_rcu(&cp->c_list, &ip_vs_conn_tab[hash]);
 		cp->flags |= IP_VS_CONN_F_HASHED;
 		atomic_inc(&cp->refcnt);
-		ret = 1;
-	} else {
-		pr_err("%s(): request for already hashed, called from %pF\n",
-		       __func__, __builtin_return_address(0));
-		ret = 0;
+		ct_mutex_unlock(hash);
+		synchronize_rcu();
+		return 1;
 	}
 
-	ct_write_unlock(hash);
+	ct_mutex_unlock(hash);
 
-	return ret;
+	pr_err("%s(): request for already hashed, called from %pF\n",
+	       __func__, __builtin_return_address(0));
+
+	return 0;
 }
 
 
@@ -186,24 +168,24 @@ static inline int ip_vs_conn_hash(struct
 static inline int ip_vs_conn_unhash(struct ip_vs_conn *cp)
 {
 	unsigned hash;
-	int ret;
 
 	/* unhash it and decrease its reference counter */
 	hash = ip_vs_conn_hashkey(cp->af, cp->protocol, &cp->caddr, cp->cport);
 
-	ct_write_lock(hash);
+	ct_mutex_lock(hash);
 
 	if (cp->flags & IP_VS_CONN_F_HASHED) {
-		list_del(&cp->c_list);
+		list_del_rcu(&cp->c_list);
 		cp->flags &= ~IP_VS_CONN_F_HASHED;
 		atomic_dec(&cp->refcnt);
-		ret = 1;
-	} else
-		ret = 0;
+		ct_mutex_unlock(hash);
+		synchronize_rcu();
+		return 1;
+	}
 
-	ct_write_unlock(hash);
+	ct_mutex_unlock(hash);
 
-	return ret;
+	return 0;
 }
 
 
@@ -222,9 +204,9 @@ static inline struct ip_vs_conn *__ip_vs
 
 	hash = ip_vs_conn_hashkey(af, protocol, s_addr, s_port);
 
-	ct_read_lock(hash);
+	rcu_read_lock();
 
-	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
+	list_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
 		if (cp->af == af &&
 		    ip_vs_addr_equal(af, s_addr, &cp->caddr) &&
 		    ip_vs_addr_equal(af, d_addr, &cp->vaddr) &&
@@ -233,12 +215,12 @@ static inline struct ip_vs_conn *__ip_vs
 		    protocol == cp->protocol) {
 			/* HIT */
 			atomic_inc(&cp->refcnt);
-			ct_read_unlock(hash);
+			rcu_read_unlock();
 			return cp;
 		}
 	}
 
-	ct_read_unlock(hash);
+	rcu_read_unlock();
 
 	return NULL;
 }
@@ -273,9 +255,9 @@ struct ip_vs_conn *ip_vs_ct_in_get
 
 	hash = ip_vs_conn_hashkey(af, protocol, s_addr, s_port);
 
-	ct_read_lock(hash);
+	rcu_read_lock();
 
-	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
+	list_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
 		if (cp->af == af &&
 		    ip_vs_addr_equal(af, s_addr, &cp->caddr) &&
 		    /* protocol should only be IPPROTO_IP if
@@ -293,7 +275,7 @@ struct ip_vs_conn *ip_vs_ct_in_get
 	cp = NULL;
 
   out:
-	ct_read_unlock(hash);
+	rcu_read_unlock();
 
 	IP_VS_DBG_BUF(9, "template lookup/in %s %s:%d->%s:%d %s\n",
 		      ip_vs_proto_name(protocol),
@@ -322,9 +304,9 @@ struct ip_vs_conn *ip_vs_conn_out_get
 	 */
 	hash = ip_vs_conn_hashkey(af, protocol, d_addr, d_port);
 
-	ct_read_lock(hash);
+	rcu_read_lock();
 
-	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
+	list_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
 		if (cp->af == af &&
 		    ip_vs_addr_equal(af, d_addr, &cp->caddr) &&
 		    ip_vs_addr_equal(af, s_addr, &cp->daddr) &&
@@ -337,7 +319,7 @@ struct ip_vs_conn *ip_vs_conn_out_get
 		}
 	}
 
-	ct_read_unlock(hash);
+	rcu_read_unlock();
 
 	IP_VS_DBG_BUF(9, "lookup/out %s %s:%d->%s:%d %s\n",
 		      ip_vs_proto_name(protocol),
@@ -776,14 +758,16 @@ static void *ip_vs_conn_array(struct seq
 	struct ip_vs_conn *cp;
 
 	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
-		ct_read_lock_bh(idx);
-		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
+		rcu_read_lock_bh();
+		list_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
 			if (pos-- == 0) {
 				seq->private = &ip_vs_conn_tab[idx];
+				/* N.B: no rcu_read_unlock_bh() here
+				 *      Seems really horrible :-( */
 				return cp;
 			}
 		}
-		ct_read_unlock_bh(idx);
+		rcu_read_unlock_bh();
 	}
 
 	return NULL;
@@ -807,19 +791,22 @@ static void *ip_vs_conn_seq_next(struct
 
 	/* more on same hash chain? */
 	if ((e = cp->c_list.next) != l)
-		return list_entry(e, struct ip_vs_conn, c_list);
+		return list_entry_rcu(e, struct ip_vs_conn, c_list);
 
 	idx = l - ip_vs_conn_tab;
-	ct_read_unlock_bh(idx);
+	rcu_read_unlock_bh();
 
 	while (++idx < ip_vs_conn_tab_size) {
-		ct_read_lock_bh(idx);
-		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
+		rcu_read_lock_bh();
+		list_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
 			seq->private = &ip_vs_conn_tab[idx];
+			/* N.B: no rcu_read_unlock_bh() here
+			 *      Seems really horrible :-( */
 			return cp;
 		}
-		ct_read_unlock_bh(idx);
+		rcu_read_unlock_bh();
 	}
+
 	seq->private = NULL;
 	return NULL;
 }
@@ -829,7 +816,7 @@ static void ip_vs_conn_seq_stop(struct s
 	struct list_head *l = seq->private;
 
 	if (l)
-		ct_read_unlock_bh(l - ip_vs_conn_tab);
+		rcu_read_unlock_bh();
 }
 
 static int ip_vs_conn_seq_show(struct seq_file *seq, void *v)
@@ -997,8 +984,7 @@ void ip_vs_random_dropentry(void)
 		/*
 		 *  Lock is actually needed in this loop.
 		 */
-		ct_write_lock_bh(hash);
-
+		ct_mutex_lock_bh(hash);
 		list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
 			if (cp->flags & IP_VS_CONN_F_TEMPLATE)
 				/* connection template */
@@ -1030,7 +1016,7 @@ void ip_vs_random_dropentry(void)
 				ip_vs_conn_expire_now(cp->control);
 			}
 		}
-		ct_write_unlock_bh(hash);
+		ct_mutex_unlock_bh(hash);
 	}
 }
 
@@ -1048,8 +1034,7 @@ static void ip_vs_conn_flush(void)
 		/*
 		 *  Lock is actually needed in this loop.
 		 */
-		ct_write_lock_bh(idx);
-
+		ct_mutex_lock_bh(idx);
 		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
 
 			IP_VS_DBG(4, "del connection\n");
@@ -1059,7 +1044,7 @@ static void ip_vs_conn_flush(void)
 				ip_vs_conn_expire_now(cp->control);
 			}
 		}
-		ct_write_unlock_bh(idx);
+		ct_mutex_unlock_bh(idx);
 	}
 
 	/* the counter may be not NULL, because maybe some conn entries
@@ -1107,9 +1092,8 @@ int __init ip_vs_conn_init(void)
 		INIT_LIST_HEAD(&ip_vs_conn_tab[idx]);
 	}
 
-	for (idx = 0; idx < CT_LOCKARRAY_SIZE; idx++)  {
-		rwlock_init(&__ip_vs_conntbl_lock_array[idx].l);
-	}
+	for (idx = 0; idx < CT_MUTEX_SIZE; idx++)
+		spin_lock_init(&__ip_vs_conntbl_mutex[idx].l);
 
 	proc_net_fops_create(&init_net, "ip_vs_conn", 0, &ip_vs_conn_fops);
 	proc_net_fops_create(&init_net, "ip_vs_conn_sync", 0, &ip_vs_conn_sync_fops);
