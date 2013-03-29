From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 32/34] ipvs: convert dests to rcu
Date: Fri, 29 Mar 2013 13:11:49 +0900
Message-ID: <1364530311-11512-33-git-send-email-horms@verge.net.au>
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

In previous commits the schedulers started to access
svc->destinations with _rcu list traversal primitives
because the IP_VS_WAIT_WHILE macro still plays the role of
grace period. Now it is time to finish the updating part,
i.e. adding and deleting of dests with _rcu suffix before
removing the IP_VS_WAIT_WHILE in next commit.

We use the same rule for conns as for the
schedulers: dests can be searched in RCU read-side critical
section where ip_vs_dest_hold can be called by ip_vs_bind_dest.

Some things are not perfect, for example, calling
functions like ip_vs_lookup_dest from updating code under
RCU, just because we use some function both from reader
and from updater.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |    2 +-
 net/netfilter/ipvs/ip_vs_conn.c |    8 +++++---
 net/netfilter/ipvs/ip_vs_ctl.c  |   32 +++++++++++++++++---------------
 net/netfilter/ipvs/ip_vs_sync.c |   11 ++++-------
 4 files changed, 27 insertions(+), 26 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 4a7bc63..78a6634 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1434,7 +1434,7 @@ extern struct ip_vs_dest *
 ip_vs_find_dest(struct net *net, int af, const union nf_inet_addr *daddr,
 		__be16 dport, const union nf_inet_addr *vaddr, __be16 vport,
 		__u16 protocol, __u32 fwmark, __u32 flags);
-extern struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp);
+extern void ip_vs_try_bind_dest(struct ip_vs_conn *cp);
 
 static inline void ip_vs_dest_hold(struct ip_vs_dest *dest)
 {
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 1b29e4a..54de340 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -611,10 +611,11 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
  * Check if there is a destination for the connection, if so
  * bind the connection to the destination.
  */
-struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp)
+void ip_vs_try_bind_dest(struct ip_vs_conn *cp)
 {
 	struct ip_vs_dest *dest;
 
+	rcu_read_lock();
 	dest = ip_vs_find_dest(ip_vs_conn_net(cp), cp->af, &cp->daddr,
 			       cp->dport, &cp->vaddr, cp->vport,
 			       cp->protocol, cp->fwmark, cp->flags);
@@ -624,7 +625,8 @@ struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp)
 		spin_lock(&cp->lock);
 		if (cp->dest) {
 			spin_unlock(&cp->lock);
-			return dest;
+			rcu_read_unlock();
+			return;
 		}
 
 		/* Applications work depending on the forwarding method
@@ -648,7 +650,7 @@ struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp)
 		if (pd && atomic_read(&pd->appcnt))
 			ip_vs_bind_app(cp, pd->pp);
 	}
-	return dest;
+	rcu_read_unlock();
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 2bfd807..0763cc6 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -565,8 +565,8 @@ bool ip_vs_has_real_service(struct net *net, int af, __u16 protocol,
 	return false;
 }
 
-/*
- *	Lookup destination by {addr,port} in the given service
+/* Lookup destination by {addr,port} in the given service
+ * Called under RCU lock.
  */
 static struct ip_vs_dest *
 ip_vs_lookup_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
@@ -577,7 +577,7 @@ ip_vs_lookup_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
 	/*
 	 * Find the destination for the given service
 	 */
-	list_for_each_entry(dest, &svc->destinations, n_list) {
+	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
 		if ((dest->af == svc->af)
 		    && ip_vs_addr_equal(svc->af, &dest->addr, daddr)
 		    && (dest->port == dport)) {
@@ -591,10 +591,11 @@ ip_vs_lookup_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
 
 /*
  * Find destination by {daddr,dport,vaddr,protocol}
- * Cretaed to be used in ip_vs_process_message() in
+ * Created to be used in ip_vs_process_message() in
  * the backup synchronization daemon. It finds the
  * destination to be bound to the received connection
  * on the backup.
+ * Called under RCU lock, no refcnt is returned.
  */
 struct ip_vs_dest *ip_vs_find_dest(struct net  *net, int af,
 				   const union nf_inet_addr *daddr,
@@ -615,8 +616,6 @@ struct ip_vs_dest *ip_vs_find_dest(struct net  *net, int af,
 	dest = ip_vs_lookup_dest(svc, daddr, port);
 	if (!dest)
 		dest = ip_vs_lookup_dest(svc, daddr, port ^ dport);
-	if (dest)
-		ip_vs_dest_hold(dest);
 	ip_vs_service_put(svc);
 	return dest;
 }
@@ -826,7 +825,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 0);
 
 	if (add) {
-		list_add(&dest->n_list, &svc->destinations);
+		list_add_rcu(&dest->n_list, &svc->destinations);
 		svc->num_dests++;
 		if (svc->scheduler->add_dest)
 			svc->scheduler->add_dest(svc, dest);
@@ -933,10 +932,10 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 
 	ip_vs_addr_copy(svc->af, &daddr, &udest->addr);
 
-	/*
-	 * Check if the dest already exists in the list
-	 */
+	/* We use function that requires RCU lock */
+	rcu_read_lock();
 	dest = ip_vs_lookup_dest(svc, &daddr, dport);
+	rcu_read_unlock();
 
 	if (dest != NULL) {
 		IP_VS_DBG(1, "%s(): dest already exists\n", __func__);
@@ -997,10 +996,10 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 
 	ip_vs_addr_copy(svc->af, &daddr, &udest->addr);
 
-	/*
-	 *  Lookup the destination list
-	 */
+	/* We use function that requires RCU lock */
+	rcu_read_lock();
 	dest = ip_vs_lookup_dest(svc, &daddr, dport);
+	rcu_read_unlock();
 
 	if (dest == NULL) {
 		IP_VS_DBG(1, "%s(): dest doesn't exist\n", __func__);
@@ -1069,7 +1068,7 @@ static void __ip_vs_unlink_dest(struct ip_vs_service *svc,
 	/*
 	 *  Remove it from the d-linked destination list.
 	 */
-	list_del(&dest->n_list);
+	list_del_rcu(&dest->n_list);
 	svc->num_dests--;
 
 	if (svcupd && svc->scheduler->del_dest)
@@ -1094,7 +1093,10 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 
 	EnterFunction(2);
 
+	/* We use function that requires RCU lock */
+	rcu_read_lock();
 	dest = ip_vs_lookup_dest(svc, &udest->addr, dport);
+	rcu_read_unlock();
 
 	if (dest == NULL) {
 		IP_VS_DBG(1, "%s(): destination not found!\n", __func__);
@@ -2104,7 +2106,7 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 		else
 			seq_putc(seq, '\n');
 
-		list_for_each_entry(dest, &svc->destinations, n_list) {
+		list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
 #ifdef CONFIG_IP_VS_IPV6
 			if (dest->af == AF_INET6)
 				seq_printf(seq,
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 6cc3e52..9724174 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -858,23 +858,20 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 		flags |= cp->flags & ~IP_VS_CONN_F_BACKUP_UPD_MASK;
 		cp->flags = flags;
 		spin_unlock(&cp->lock);
-		if (!dest) {
-			dest = ip_vs_try_bind_dest(cp);
-			if (dest)
-				ip_vs_dest_put(dest);
-		}
+		if (!dest)
+			ip_vs_try_bind_dest(cp);
 	} else {
 		/*
 		 * Find the appropriate destination for the connection.
 		 * If it is not found the connection will remain unbound
 		 * but still handled.
 		 */
+		rcu_read_lock();
 		dest = ip_vs_find_dest(net, type, daddr, dport, param->vaddr,
 				       param->vport, protocol, fwmark, flags);
 
 		cp = ip_vs_conn_new(param, daddr, dport, flags, dest, fwmark);
-		if (dest)
-			ip_vs_dest_put(dest);
+		rcu_read_unlock();
 		if (!cp) {
 			if (param->pe_data)
 				kfree(param->pe_data);
-- 
1.7.10.4
