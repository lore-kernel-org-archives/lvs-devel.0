From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 18/19] ipvs: convert services to rcu
Date: Fri, 22 Mar 2013 11:46:53 +0200
Message-ID: <1363945614-11752-19-git-send-email-ja@ssi.bg>
References: <1363945614-11752-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1363945614-11752-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

	This is the final step in RCU conversion.

	Things that are removed:

- svc->usecnt: now svc is accessed under RCU read lock
- svc->inc: and some unused code
- ip_vs_bind_pe and ip_vs_unbind_pe: no ability to replace PE
- __ip_vs_svc_lock: replaced with RCU
- IP_VS_WAIT_WHILE: now readers lookup svcs and dests under
	RCU and work in parallel with configuration

	Other changes:

- before now, a RCU read-side critical section included the
calling of the schedule method, now it is extended to include
service lookup
- ip_vs_svc_table and ip_vs_svc_fwm_table are now using hlist
- svc->pe and svc->scheduler remain to the end (of grace period),
	the schedulers are prepared for such RCU readers
	even after done_service is called but they need
	to use synchronize_rcu because last ip_vs_scheduler_put
	can happen while RCU read-side critical sections
	use an outdated svc->scheduler pointer
- as planned, update_service is removed
- empty services can be freed immediately after grace period.
	If dests were present, the services are freed from
	the dest trash code

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h                   |   28 +--
 net/netfilter/ipvs/ip_vs_core.c       |   26 +--
 net/netfilter/ipvs/ip_vs_ctl.c        |  299 ++++++++++++++-------------------
 net/netfilter/ipvs/ip_vs_dh.c         |    1 +
 net/netfilter/ipvs/ip_vs_lblc.c       |    1 +
 net/netfilter/ipvs/ip_vs_lblcr.c      |    1 +
 net/netfilter/ipvs/ip_vs_lc.c         |    1 +
 net/netfilter/ipvs/ip_vs_nq.c         |    1 +
 net/netfilter/ipvs/ip_vs_pe.c         |   12 --
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   14 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |   14 +-
 net/netfilter/ipvs/ip_vs_proto_udp.c  |   14 +-
 net/netfilter/ipvs/ip_vs_rr.c         |    1 +
 net/netfilter/ipvs/ip_vs_sched.c      |   28 ++--
 net/netfilter/ipvs/ip_vs_sed.c        |    1 +
 net/netfilter/ipvs/ip_vs_sh.c         |    1 +
 net/netfilter/ipvs/ip_vs_wlc.c        |    1 +
 net/netfilter/ipvs/ip_vs_wrr.c        |    1 +
 18 files changed, 186 insertions(+), 259 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 40bb2a6..3ee1f9e 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -359,8 +359,6 @@ static inline const char *ip_vs_dbg_addr(int af, char *buf, size_t buf_len,
 #define LeaveFunction(level)   do {} while (0)
 #endif
 
-#define	IP_VS_WAIT_WHILE(expr)	while (expr) { cpu_relax(); }
-
 
 /*
  *      The port number of FTP service (in network order).
@@ -712,10 +710,9 @@ struct ip_vs_dest_user_kern {
  *	and the forwarding entries
  */
 struct ip_vs_service {
-	struct list_head	s_list;   /* for normal service table */
-	struct list_head	f_list;   /* for fwmark-based service table */
+	struct hlist_node	s_list;   /* for normal service table */
+	struct hlist_node	f_list;   /* for fwmark-based service table */
 	atomic_t		refcnt;   /* reference counter */
-	atomic_t		usecnt;   /* use counter */
 
 	u16			af;       /* address family */
 	__u16			protocol; /* which protocol (TCP/UDP) */
@@ -730,15 +727,16 @@ struct ip_vs_service {
 	struct list_head	destinations;  /* real server d-linked list */
 	__u32			num_dests;     /* number of servers */
 	struct ip_vs_stats      stats;         /* statistics for the service */
-	struct ip_vs_app	*inc;	  /* bind conns to this app inc */
 
 	/* for scheduling */
-	struct ip_vs_scheduler	*scheduler;    /* bound scheduler object */
+	struct ip_vs_scheduler __rcu *scheduler; /* bound scheduler object */
 	spinlock_t		sched_lock;    /* lock sched_data */
 	void			*sched_data;   /* scheduler application data */
 
 	/* alternate persistence engine */
-	struct ip_vs_pe		*pe;
+	struct ip_vs_pe __rcu	*pe;
+
+	struct rcu_head		rcu_head;
 };
 
 /* Information for cached dst */
@@ -807,8 +805,6 @@ struct ip_vs_scheduler {
 	int (*init_service)(struct ip_vs_service *svc);
 	/* scheduling service finish */
 	void (*done_service)(struct ip_vs_service *svc);
-	/* scheduler updating service */
-	int (*update_service)(struct ip_vs_service *svc);
 	/* dest is linked */
 	int (*add_dest)(struct ip_vs_service *svc, struct ip_vs_dest *dest);
 	/* dest is unlinked */
@@ -1344,8 +1340,6 @@ extern void ip_vs_app_inc_put(struct ip_vs_app *inc);
 extern int ip_vs_app_pkt_out(struct ip_vs_conn *, struct sk_buff *skb);
 extern int ip_vs_app_pkt_in(struct ip_vs_conn *, struct sk_buff *skb);
 
-void ip_vs_bind_pe(struct ip_vs_service *svc, struct ip_vs_pe *pe);
-void ip_vs_unbind_pe(struct ip_vs_service *svc);
 int register_ip_vs_pe(struct ip_vs_pe *pe);
 int unregister_ip_vs_pe(struct ip_vs_pe *pe);
 struct ip_vs_pe *ip_vs_pe_getbyname(const char *name);
@@ -1392,7 +1386,8 @@ extern int register_ip_vs_scheduler(struct ip_vs_scheduler *scheduler);
 extern int unregister_ip_vs_scheduler(struct ip_vs_scheduler *scheduler);
 extern int ip_vs_bind_scheduler(struct ip_vs_service *svc,
 				struct ip_vs_scheduler *scheduler);
-extern void ip_vs_unbind_scheduler(struct ip_vs_service *svc);
+extern void ip_vs_unbind_scheduler(struct ip_vs_service *svc,
+				   struct ip_vs_scheduler *sched);
 extern struct ip_vs_scheduler *ip_vs_scheduler_get(const char *sched_name);
 extern void ip_vs_scheduler_put(struct ip_vs_scheduler *scheduler);
 extern struct ip_vs_conn *
@@ -1412,14 +1407,9 @@ extern struct ip_vs_stats ip_vs_stats;
 extern int sysctl_ip_vs_sync_ver;
 
 extern struct ip_vs_service *
-ip_vs_service_get(struct net *net, int af, __u32 fwmark, __u16 protocol,
+ip_vs_service_find(struct net *net, int af, __u32 fwmark, __u16 protocol,
 		  const union nf_inet_addr *vaddr, __be16 vport);
 
-static inline void ip_vs_service_put(struct ip_vs_service *svc)
-{
-	atomic_dec(&svc->usecnt);
-}
-
 extern bool
 ip_vs_has_real_service(struct net *net, int af, __u16 protocol,
 		       const union nf_inet_addr *daddr, __be16 dport);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 7bf62d0..8814f02 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -206,7 +206,7 @@ ip_vs_conn_fill_param_persist(const struct ip_vs_service *svc,
 {
 	ip_vs_conn_fill_param(svc->net, svc->af, protocol, caddr, cport, vaddr,
 			      vport, p);
-	p->pe = svc->pe;
+	p->pe = rcu_dereference(svc->pe);
 	if (p->pe && p->pe->fill_param)
 		return p->pe->fill_param(p, skb);
 
@@ -299,15 +299,16 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	/* Check if a template already exists */
 	ct = ip_vs_ct_in_get(&param);
 	if (!ct || !ip_vs_check_template(ct)) {
+		struct ip_vs_scheduler *sched;
+
 		/*
 		 * No template found or the dest of the connection
 		 * template is not available.
 		 * return *ignored=0 i.e. ICMP and NF_DROP
 		 */
-		rcu_read_lock();
-		dest = svc->scheduler->schedule(svc, skb);
+		sched = rcu_dereference(svc->scheduler);
+		dest = sched->schedule(svc, skb);
 		if (!dest) {
-			rcu_read_unlock();
 			IP_VS_DBG(1, "p-schedule: no dest found.\n");
 			kfree(param.pe_data);
 			*ignored = 0;
@@ -323,7 +324,6 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 		 * when the template expires */
 		ct = ip_vs_conn_new(&param, &dest->addr, dport,
 				    IP_VS_CONN_F_TEMPLATE, dest, skb->mark);
-		rcu_read_unlock();
 		if (ct == NULL) {
 			kfree(param.pe_data);
 			*ignored = -1;
@@ -397,6 +397,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 {
 	struct ip_vs_protocol *pp = pd->pp;
 	struct ip_vs_conn *cp = NULL;
+	struct ip_vs_scheduler *sched;
 	struct ip_vs_dest *dest;
 	__be16 _ports[2], *pptr;
 	unsigned int flags;
@@ -452,10 +453,9 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 		return NULL;
 	}
 
-	rcu_read_lock();
-	dest = svc->scheduler->schedule(svc, skb);
+	sched = rcu_dereference(svc->scheduler);
+	dest = sched->schedule(svc, skb);
 	if (dest == NULL) {
-		rcu_read_unlock();
 		IP_VS_DBG(1, "Schedule: no dest found.\n");
 		return NULL;
 	}
@@ -476,7 +476,6 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 		cp = ip_vs_conn_new(&p, &dest->addr,
 				    dest->port ? dest->port : pptr[1],
 				    flags, dest, skb->mark);
-		rcu_read_unlock();
 		if (!cp) {
 			*ignored = -1;
 			return NULL;
@@ -513,7 +512,6 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 
 	pptr = frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports, iph);
 	if (pptr == NULL) {
-		ip_vs_service_put(svc);
 		return NF_DROP;
 	}
 
@@ -539,8 +537,6 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 				      IP_VS_CONN_F_ONE_PACKET : 0;
 		union nf_inet_addr daddr =  { .all = { 0, 0, 0, 0 } };
 
-		ip_vs_service_put(svc);
-
 		/* create a new connection entry */
 		IP_VS_DBG(6, "%s(): create a cache_bypass entry\n", __func__);
 		{
@@ -577,12 +573,8 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 	 * listed in the ipvs table), pass the packets, because it is
 	 * not ipvs job to decide to drop the packets.
 	 */
-	if ((svc->port == FTPPORT) && (pptr[1] != FTPPORT)) {
-		ip_vs_service_put(svc);
+	if ((svc->port == FTPPORT) && (pptr[1] != FTPPORT))
 		return NF_ACCEPT;
-	}
-
-	ip_vs_service_put(svc);
 
 	/*
 	 * Notify the client that the destination is unreachable, and
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 8778927..26c87a5 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -55,9 +55,6 @@
 /* semaphore for IPVS sockopts. And, [gs]etsockopt may sleep. */
 static DEFINE_MUTEX(__ip_vs_mutex);
 
-/* lock for service table */
-static DEFINE_RWLOCK(__ip_vs_svc_lock);
-
 /* sysctl variables */
 
 #ifdef CONFIG_IP_VS_DEBUG
@@ -257,9 +254,9 @@ ip_vs_use_count_dec(void)
 #define IP_VS_SVC_TAB_MASK (IP_VS_SVC_TAB_SIZE - 1)
 
 /* the service table hashed by <protocol, addr, port> */
-static struct list_head ip_vs_svc_table[IP_VS_SVC_TAB_SIZE];
+static struct hlist_head ip_vs_svc_table[IP_VS_SVC_TAB_SIZE];
 /* the service table hashed by fwmark */
-static struct list_head ip_vs_svc_fwm_table[IP_VS_SVC_TAB_SIZE];
+static struct hlist_head ip_vs_svc_fwm_table[IP_VS_SVC_TAB_SIZE];
 
 
 /*
@@ -312,13 +309,13 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
 		 */
 		hash = ip_vs_svc_hashkey(svc->net, svc->af, svc->protocol,
 					 &svc->addr, svc->port);
-		list_add(&svc->s_list, &ip_vs_svc_table[hash]);
+		hlist_add_head_rcu(&svc->s_list, &ip_vs_svc_table[hash]);
 	} else {
 		/*
 		 *  Hash it by fwmark in svc_fwm_table
 		 */
 		hash = ip_vs_svc_fwm_hashkey(svc->net, svc->fwmark);
-		list_add(&svc->f_list, &ip_vs_svc_fwm_table[hash]);
+		hlist_add_head_rcu(&svc->f_list, &ip_vs_svc_fwm_table[hash]);
 	}
 
 	svc->flags |= IP_VS_SVC_F_HASHED;
@@ -342,10 +339,10 @@ static int ip_vs_svc_unhash(struct ip_vs_service *svc)
 
 	if (svc->fwmark == 0) {
 		/* Remove it from the svc_table table */
-		list_del(&svc->s_list);
+		hlist_del_rcu(&svc->s_list);
 	} else {
 		/* Remove it from the svc_fwm_table table */
-		list_del(&svc->f_list);
+		hlist_del_rcu(&svc->f_list);
 	}
 
 	svc->flags &= ~IP_VS_SVC_F_HASHED;
@@ -367,7 +364,7 @@ __ip_vs_service_find(struct net *net, int af, __u16 protocol,
 	/* Check for "full" addressed entries */
 	hash = ip_vs_svc_hashkey(net, af, protocol, vaddr, vport);
 
-	list_for_each_entry(svc, &ip_vs_svc_table[hash], s_list){
+	hlist_for_each_entry_rcu(svc, &ip_vs_svc_table[hash], s_list) {
 		if ((svc->af == af)
 		    && ip_vs_addr_equal(af, &svc->addr, vaddr)
 		    && (svc->port == vport)
@@ -394,7 +391,7 @@ __ip_vs_svc_fwm_find(struct net *net, int af, __u32 fwmark)
 	/* Check for fwmark addressed entries */
 	hash = ip_vs_svc_fwm_hashkey(net, fwmark);
 
-	list_for_each_entry(svc, &ip_vs_svc_fwm_table[hash], f_list) {
+	hlist_for_each_entry_rcu(svc, &ip_vs_svc_fwm_table[hash], f_list) {
 		if (svc->fwmark == fwmark && svc->af == af
 		    && net_eq(svc->net, net)) {
 			/* HIT */
@@ -405,15 +402,14 @@ __ip_vs_svc_fwm_find(struct net *net, int af, __u32 fwmark)
 	return NULL;
 }
 
+/* Find service, called under RCU lock */
 struct ip_vs_service *
-ip_vs_service_get(struct net *net, int af, __u32 fwmark, __u16 protocol,
-		  const union nf_inet_addr *vaddr, __be16 vport)
+ip_vs_service_find(struct net *net, int af, __u32 fwmark, __u16 protocol,
+		   const union nf_inet_addr *vaddr, __be16 vport)
 {
 	struct ip_vs_service *svc;
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	read_lock(&__ip_vs_svc_lock);
-
 	/*
 	 *	Check the table hashed by fwmark first
 	 */
@@ -449,10 +445,6 @@ ip_vs_service_get(struct net *net, int af, __u32 fwmark, __u16 protocol,
 	}
 
   out:
-	if (svc)
-		atomic_inc(&svc->usecnt);
-	read_unlock(&__ip_vs_svc_lock);
-
 	IP_VS_DBG_BUF(9, "lookup service: fwm %u %s %s:%u %s\n",
 		      fwmark, ip_vs_proto_name(protocol),
 		      IP_VS_DBG_ADDR(af, vaddr), ntohs(vport),
@@ -469,6 +461,13 @@ __ip_vs_bind_svc(struct ip_vs_dest *dest, struct ip_vs_service *svc)
 	dest->svc = svc;
 }
 
+static void ip_vs_service_free(struct ip_vs_service *svc)
+{
+	if (svc->stats.cpustats)
+		free_percpu(svc->stats.cpustats);
+	kfree(svc);
+}
+
 static void
 __ip_vs_unbind_svc(struct ip_vs_dest *dest)
 {
@@ -476,12 +475,11 @@ __ip_vs_unbind_svc(struct ip_vs_dest *dest)
 
 	dest->svc = NULL;
 	if (atomic_dec_and_test(&svc->refcnt)) {
-		IP_VS_DBG_BUF(3, "Removing service %u/%s:%u usecnt=%d\n",
+		IP_VS_DBG_BUF(3, "Removing service %u/%s:%u\n",
 			      svc->fwmark,
 			      IP_VS_DBG_ADDR(svc->af, &svc->addr),
-			      ntohs(svc->port), atomic_read(&svc->usecnt));
-		free_percpu(svc->stats.cpustats);
-		kfree(svc);
+			      ntohs(svc->port));
+		ip_vs_service_free(svc);
 	}
 }
 
@@ -606,7 +604,7 @@ struct ip_vs_dest *ip_vs_find_dest(struct net  *net, int af,
 	struct ip_vs_service *svc;
 	__be16 port = dport;
 
-	svc = ip_vs_service_get(net, af, fwmark, protocol, vaddr, vport);
+	svc = ip_vs_service_find(net, af, fwmark, protocol, vaddr, vport);
 	if (!svc)
 		return NULL;
 	if (fwmark && (flags & IP_VS_CONN_F_FWD_MASK) != IP_VS_CONN_F_MASQ)
@@ -614,7 +612,6 @@ struct ip_vs_dest *ip_vs_find_dest(struct net  *net, int af,
 	dest = ip_vs_lookup_dest(svc, daddr, port);
 	if (!dest)
 		dest = ip_vs_lookup_dest(svc, daddr, port ^ dport);
-	ip_vs_service_put(svc);
 	return dest;
 }
 
@@ -772,6 +769,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 		    struct ip_vs_dest_user_kern *udest, int add)
 {
 	struct netns_ipvs *ipvs = net_ipvs(svc->net);
+	struct ip_vs_scheduler *sched;
 	int conn_flags;
 
 	/* set the weight and the flags */
@@ -814,29 +812,17 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	__ip_vs_dst_cache_reset(dest);
 	spin_unlock_bh(&dest->dst_lock);
 
-	if (add)
-		ip_vs_start_estimator(svc->net, &dest->stats);
-
-	write_lock_bh(&__ip_vs_svc_lock);
-
-	/* Wait until all other svc users go away */
-	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 0);
-
+	sched = rcu_dereference_protected(svc->scheduler, 1);
 	if (add) {
+		ip_vs_start_estimator(svc->net, &dest->stats);
 		list_add_rcu(&dest->n_list, &svc->destinations);
 		svc->num_dests++;
-		if (svc->scheduler->add_dest)
-			svc->scheduler->add_dest(svc, dest);
+		if (sched->add_dest)
+			sched->add_dest(svc, dest);
 	} else {
-		if (svc->scheduler->upd_dest)
-			svc->scheduler->upd_dest(svc, dest);
+		if (sched->upd_dest)
+			sched->upd_dest(svc, dest);
 	}
-
-	/* call the update_service, because server weight may be changed */
-	if (svc->scheduler->update_service)
-		svc->scheduler->update_service(svc);
-
-	write_unlock_bh(&__ip_vs_svc_lock);
 }
 
 
@@ -1069,14 +1055,13 @@ static void __ip_vs_unlink_dest(struct ip_vs_service *svc,
 	list_del_rcu(&dest->n_list);
 	svc->num_dests--;
 
-	if (svcupd && svc->scheduler->del_dest)
-		svc->scheduler->del_dest(svc, dest);
+	if (svcupd) {
+		struct ip_vs_scheduler *sched;
 
-	/*
-	 *  Call the update_service function of its scheduler
-	 */
-	if (svcupd && svc->scheduler->update_service)
-			svc->scheduler->update_service(svc);
+		sched = rcu_dereference_protected(svc->scheduler, 1);
+		if (sched->del_dest)
+			sched->del_dest(svc, dest);
+	}
 }
 
 
@@ -1101,20 +1086,11 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 		return -ENOENT;
 	}
 
-	write_lock_bh(&__ip_vs_svc_lock);
-
-	/*
-	 *	Wait until all other svc users go away.
-	 */
-	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 0);
-
 	/*
 	 *	Unlink dest from the service
 	 */
 	__ip_vs_unlink_dest(svc, dest, 1);
 
-	write_unlock_bh(&__ip_vs_svc_lock);
-
 	/*
 	 *	Delete the destination
 	 */
@@ -1205,7 +1181,6 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 	}
 
 	/* I'm the first user of the service */
-	atomic_set(&svc->usecnt, 0);
 	atomic_set(&svc->refcnt, 0);
 
 	svc->af = u->af;
@@ -1229,7 +1204,7 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 	sched = NULL;
 
 	/* Bind the ct retriever */
-	ip_vs_bind_pe(svc, pe);
+	RCU_INIT_POINTER(svc->pe, pe);
 	pe = NULL;
 
 	/* Update the virtual service counters */
@@ -1245,9 +1220,7 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 		ipvs->num_services++;
 
 	/* Hash the service into the service table */
-	write_lock_bh(&__ip_vs_svc_lock);
 	ip_vs_svc_hash(svc);
-	write_unlock_bh(&__ip_vs_svc_lock);
 
 	*svc_p = svc;
 	/* Now there is a service - full throttle */
@@ -1257,15 +1230,8 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 
  out_err:
 	if (svc != NULL) {
-		ip_vs_unbind_scheduler(svc);
-		if (svc->inc) {
-			local_bh_disable();
-			ip_vs_app_inc_put(svc->inc);
-			local_bh_enable();
-		}
-		if (svc->stats.cpustats)
-			free_percpu(svc->stats.cpustats);
-		kfree(svc);
+		ip_vs_unbind_scheduler(svc, sched);
+		ip_vs_service_free(svc);
 	}
 	ip_vs_scheduler_put(sched);
 	ip_vs_pe_put(pe);
@@ -1315,12 +1281,17 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 	}
 #endif
 
-	write_lock_bh(&__ip_vs_svc_lock);
-
-	/*
-	 * Wait until all other svc users go away.
-	 */
-	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 0);
+	old_sched = rcu_dereference_protected(svc->scheduler, 1);
+	if (sched != old_sched) {
+		/* Bind the new scheduler */
+		ret = ip_vs_bind_scheduler(svc, sched);
+		if (ret) {
+			old_sched = sched;
+			goto out;
+		}
+		/* Unbind the old scheduler on success */
+		ip_vs_unbind_scheduler(svc, old_sched);
+	}
 
 	/*
 	 * Set the flags and timeout value
@@ -1329,47 +1300,23 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 	svc->timeout = u->timeout * HZ;
 	svc->netmask = u->netmask;
 
-	old_sched = svc->scheduler;
-	if (sched != old_sched) {
-		/*
-		 * Unbind the old scheduler
-		 */
-		ip_vs_unbind_scheduler(svc);
+	old_pe = rcu_dereference_protected(svc->pe, 1);
+	if (pe != old_pe)
+		rcu_assign_pointer(svc->pe, pe);
 
-		/*
-		 * Bind the new scheduler
-		 */
-		if ((ret = ip_vs_bind_scheduler(svc, sched))) {
-			/*
-			 * If ip_vs_bind_scheduler fails, restore the old
-			 * scheduler.
-			 * The main reason of failure is out of memory.
-			 *
-			 * The question is if the old scheduler can be
-			 * restored all the time. TODO: if it cannot be
-			 * restored some time, we must delete the service,
-			 * otherwise the system may crash.
-			 */
-			ip_vs_bind_scheduler(svc, old_sched);
-			old_sched = sched;
-			goto out_unlock;
-		}
-	}
-
-	old_pe = svc->pe;
-	if (pe != old_pe) {
-		ip_vs_unbind_pe(svc);
-		ip_vs_bind_pe(svc, pe);
-	}
-
-out_unlock:
-	write_unlock_bh(&__ip_vs_svc_lock);
 out:
 	ip_vs_scheduler_put(old_sched);
 	ip_vs_pe_put(old_pe);
 	return ret;
 }
 
+static void ip_vs_service_rcu_free(struct rcu_head *head)
+{
+	struct ip_vs_service *svc;
+
+	svc = container_of(head, struct ip_vs_service, rcu_head);
+	ip_vs_service_free(svc);
+}
 
 /*
  *	Delete a service from the service list
@@ -1392,21 +1339,14 @@ static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
 	ip_vs_stop_estimator(svc->net, &svc->stats);
 
 	/* Unbind scheduler */
-	old_sched = svc->scheduler;
-	ip_vs_unbind_scheduler(svc);
+	old_sched = rcu_dereference_protected(svc->scheduler, 1);
+	ip_vs_unbind_scheduler(svc, old_sched);
 	ip_vs_scheduler_put(old_sched);
 
-	/* Unbind persistence engine */
-	old_pe = svc->pe;
-	ip_vs_unbind_pe(svc);
+	/* Unbind persistence engine, keep svc->pe */
+	old_pe = rcu_dereference_protected(svc->pe, 1);
 	ip_vs_pe_put(old_pe);
 
-	/* Unbind app inc */
-	if (svc->inc) {
-		ip_vs_app_inc_put(svc->inc);
-		svc->inc = NULL;
-	}
-
 	/*
 	 *    Unlink the whole destination list
 	 */
@@ -1426,13 +1366,12 @@ static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
 	/*
 	 *    Free the service if nobody refers to it
 	 */
-	if (atomic_read(&svc->refcnt) == 0) {
-		IP_VS_DBG_BUF(3, "Removing service %u/%s:%u usecnt=%d\n",
+	if (atomic_dec_and_test(&svc->refcnt)) {
+		IP_VS_DBG_BUF(3, "Removing service %u/%s:%u\n",
 			      svc->fwmark,
 			      IP_VS_DBG_ADDR(svc->af, &svc->addr),
-			      ntohs(svc->port), atomic_read(&svc->usecnt));
-		free_percpu(svc->stats.cpustats);
-		kfree(svc);
+			      ntohs(svc->port));
+		call_rcu(&svc->rcu_head, ip_vs_service_rcu_free);
 	}
 
 	/* decrease the module use count */
@@ -1444,21 +1383,14 @@ static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
  */
 static void ip_vs_unlink_service(struct ip_vs_service *svc, bool cleanup)
 {
+	/* Hold svc to avoid double release from dest_trash */
+	atomic_inc(&svc->refcnt);
 	/*
 	 * Unhash it from the service table
 	 */
-	write_lock_bh(&__ip_vs_svc_lock);
-
 	ip_vs_svc_unhash(svc);
 
-	/*
-	 * Wait until all the svc users go away.
-	 */
-	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 0);
-
 	__ip_vs_del_service(svc, cleanup);
-
-	write_unlock_bh(&__ip_vs_svc_lock);
 }
 
 /*
@@ -1480,14 +1412,15 @@ static int ip_vs_del_service(struct ip_vs_service *svc)
 static int ip_vs_flush(struct net *net, bool cleanup)
 {
 	int idx;
-	struct ip_vs_service *svc, *nxt;
+	struct ip_vs_service *svc;
+	struct hlist_node *n;
 
 	/*
 	 * Flush the service table hashed by <netns,protocol,addr,port>
 	 */
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each_entry_safe(svc, nxt, &ip_vs_svc_table[idx],
-					 s_list) {
+		hlist_for_each_entry_safe(svc, n, &ip_vs_svc_table[idx],
+					  s_list) {
 			if (net_eq(svc->net, net))
 				ip_vs_unlink_service(svc, cleanup);
 		}
@@ -1497,8 +1430,8 @@ static int ip_vs_flush(struct net *net, bool cleanup)
 	 * Flush the service table hashed by fwmark
 	 */
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each_entry_safe(svc, nxt,
-					 &ip_vs_svc_fwm_table[idx], f_list) {
+		hlist_for_each_entry_safe(svc, n, &ip_vs_svc_fwm_table[idx],
+					  f_list) {
 			if (net_eq(svc->net, net))
 				ip_vs_unlink_service(svc, cleanup);
 		}
@@ -1556,7 +1489,7 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 	EnterFunction(2);
 	mutex_lock(&__ip_vs_mutex);
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
+		hlist_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
 			if (net_eq(svc->net, net)) {
 				list_for_each_entry(dest, &svc->destinations,
 						    n_list) {
@@ -1565,7 +1498,7 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 			}
 		}
 
-		list_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
+		hlist_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
 			if (net_eq(svc->net, net)) {
 				list_for_each_entry(dest, &svc->destinations,
 						    n_list) {
@@ -1593,12 +1526,10 @@ static int ip_vs_zero_service(struct ip_vs_service *svc)
 {
 	struct ip_vs_dest *dest;
 
-	write_lock_bh(&__ip_vs_svc_lock);
 	list_for_each_entry(dest, &svc->destinations, n_list) {
 		ip_vs_zero_stats(&dest->stats);
 	}
 	ip_vs_zero_stats(&svc->stats);
-	write_unlock_bh(&__ip_vs_svc_lock);
 	return 0;
 }
 
@@ -1608,14 +1539,14 @@ static int ip_vs_zero_all(struct net *net)
 	struct ip_vs_service *svc;
 
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
+		hlist_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
 			if (net_eq(svc->net, net))
 				ip_vs_zero_service(svc);
 		}
 	}
 
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
+		hlist_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
 			if (net_eq(svc->net, net))
 				ip_vs_zero_service(svc);
 		}
@@ -1943,7 +1874,7 @@ static struct ctl_table vs_vars[] = {
 
 struct ip_vs_iter {
 	struct seq_net_private p;  /* Do not move this, netns depends upon it*/
-	struct list_head *table;
+	struct hlist_head *table;
 	int bucket;
 };
 
@@ -1976,7 +1907,7 @@ static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
 
 	/* look in hash by protocol */
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
+		hlist_for_each_entry_rcu(svc, &ip_vs_svc_table[idx], s_list) {
 			if (net_eq(svc->net, net) && pos-- == 0) {
 				iter->table = ip_vs_svc_table;
 				iter->bucket = idx;
@@ -1987,7 +1918,8 @@ static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
 
 	/* keep looking in fwmark */
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
+		hlist_for_each_entry_rcu(svc, &ip_vs_svc_fwm_table[idx],
+					 f_list) {
 			if (net_eq(svc->net, net) && pos-- == 0) {
 				iter->table = ip_vs_svc_fwm_table;
 				iter->bucket = idx;
@@ -2000,17 +1932,16 @@ static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
 }
 
 static void *ip_vs_info_seq_start(struct seq_file *seq, loff_t *pos)
-__acquires(__ip_vs_svc_lock)
 {
 
-	read_lock_bh(&__ip_vs_svc_lock);
+	rcu_read_lock();
 	return *pos ? ip_vs_info_array(seq, *pos - 1) : SEQ_START_TOKEN;
 }
 
 
 static void *ip_vs_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct list_head *e;
+	struct hlist_node *e;
 	struct ip_vs_iter *iter;
 	struct ip_vs_service *svc;
 
@@ -2023,13 +1954,14 @@ static void *ip_vs_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 	if (iter->table == ip_vs_svc_table) {
 		/* next service in table hashed by protocol */
-		if ((e = svc->s_list.next) != &ip_vs_svc_table[iter->bucket])
-			return list_entry(e, struct ip_vs_service, s_list);
-
+		e = rcu_dereference(hlist_next_rcu(&svc->s_list));
+		if (e)
+			return hlist_entry(e, struct ip_vs_service, s_list);
 
 		while (++iter->bucket < IP_VS_SVC_TAB_SIZE) {
-			list_for_each_entry(svc,&ip_vs_svc_table[iter->bucket],
-					    s_list) {
+			hlist_for_each_entry_rcu(svc,
+						 &ip_vs_svc_table[iter->bucket],
+						 s_list) {
 				return svc;
 			}
 		}
@@ -2040,13 +1972,15 @@ static void *ip_vs_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	}
 
 	/* next service in hashed by fwmark */
-	if ((e = svc->f_list.next) != &ip_vs_svc_fwm_table[iter->bucket])
-		return list_entry(e, struct ip_vs_service, f_list);
+	e = rcu_dereference(hlist_next_rcu(&svc->f_list));
+	if (e)
+		return hlist_entry(e, struct ip_vs_service, f_list);
 
  scan_fwmark:
 	while (++iter->bucket < IP_VS_SVC_TAB_SIZE) {
-		list_for_each_entry(svc, &ip_vs_svc_fwm_table[iter->bucket],
-				    f_list)
+		hlist_for_each_entry_rcu(svc,
+					 &ip_vs_svc_fwm_table[iter->bucket],
+					 f_list)
 			return svc;
 	}
 
@@ -2054,9 +1988,8 @@ static void *ip_vs_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void ip_vs_info_seq_stop(struct seq_file *seq, void *v)
-__releases(__ip_vs_svc_lock)
 {
-	read_unlock_bh(&__ip_vs_svc_lock);
+	rcu_read_unlock();
 }
 
 
@@ -2074,6 +2007,7 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 		const struct ip_vs_service *svc = v;
 		const struct ip_vs_iter *iter = seq->private;
 		const struct ip_vs_dest *dest;
+		struct ip_vs_scheduler *sched = rcu_dereference(svc->scheduler);
 
 		if (iter->table == ip_vs_svc_table) {
 #ifdef CONFIG_IP_VS_IPV6
@@ -2082,18 +2016,18 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 					   ip_vs_proto_name(svc->protocol),
 					   &svc->addr.in6,
 					   ntohs(svc->port),
-					   svc->scheduler->name);
+					   sched->name);
 			else
 #endif
 				seq_printf(seq, "%s  %08X:%04X %s %s ",
 					   ip_vs_proto_name(svc->protocol),
 					   ntohl(svc->addr.ip),
 					   ntohs(svc->port),
-					   svc->scheduler->name,
+					   sched->name,
 					   (svc->flags & IP_VS_SVC_F_ONEPACKET)?"ops ":"");
 		} else {
 			seq_printf(seq, "FWM  %08X %s %s",
-				   svc->fwmark, svc->scheduler->name,
+				   svc->fwmark, sched->name,
 				   (svc->flags & IP_VS_SVC_F_ONEPACKET)?"ops ":"");
 		}
 
@@ -2449,11 +2383,13 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 	}
 
 	/* Lookup the exact service by <protocol, addr, port> or fwmark */
+	rcu_read_lock();
 	if (usvc.fwmark == 0)
 		svc = __ip_vs_service_find(net, usvc.af, usvc.protocol,
 					   &usvc.addr, usvc.port);
 	else
 		svc = __ip_vs_svc_fwm_find(net, usvc.af, usvc.fwmark);
+	rcu_read_unlock();
 
 	if (cmd != IP_VS_SO_SET_ADD
 	    && (svc == NULL || svc->protocol != usvc.protocol)) {
@@ -2505,11 +2441,14 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 static void
 ip_vs_copy_service(struct ip_vs_service_entry *dst, struct ip_vs_service *src)
 {
+	struct ip_vs_scheduler *sched;
+
+	sched = rcu_dereference_protected(src->scheduler, 1);
 	dst->protocol = src->protocol;
 	dst->addr = src->addr.ip;
 	dst->port = src->port;
 	dst->fwmark = src->fwmark;
-	strlcpy(dst->sched_name, src->scheduler->name, sizeof(dst->sched_name));
+	strlcpy(dst->sched_name, sched->name, sizeof(dst->sched_name));
 	dst->flags = src->flags;
 	dst->timeout = src->timeout / HZ;
 	dst->netmask = src->netmask;
@@ -2528,7 +2467,7 @@ __ip_vs_get_service_entries(struct net *net,
 	int ret = 0;
 
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
+		hlist_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
 			/* Only expose IPv4 entries to old interface */
 			if (svc->af != AF_INET || !net_eq(svc->net, net))
 				continue;
@@ -2547,7 +2486,7 @@ __ip_vs_get_service_entries(struct net *net,
 	}
 
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
+		hlist_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
 			/* Only expose IPv4 entries to old interface */
 			if (svc->af != AF_INET || !net_eq(svc->net, net))
 				continue;
@@ -2576,11 +2515,13 @@ __ip_vs_get_dest_entries(struct net *net, const struct ip_vs_get_dests *get,
 	union nf_inet_addr addr = { .ip = get->addr };
 	int ret = 0;
 
+	rcu_read_lock();
 	if (get->fwmark)
 		svc = __ip_vs_svc_fwm_find(net, AF_INET, get->fwmark);
 	else
 		svc = __ip_vs_service_find(net, AF_INET, get->protocol, &addr,
 					   get->port);
+	rcu_read_unlock();
 
 	if (svc) {
 		int count = 0;
@@ -2763,12 +2704,14 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 
 		entry = (struct ip_vs_service_entry *)arg;
 		addr.ip = entry->addr;
+		rcu_read_lock();
 		if (entry->fwmark)
 			svc = __ip_vs_svc_fwm_find(net, AF_INET, entry->fwmark);
 		else
 			svc = __ip_vs_service_find(net, AF_INET,
 						   entry->protocol, &addr,
 						   entry->port);
+		rcu_read_unlock();
 		if (svc) {
 			ip_vs_copy_service(entry, svc);
 			if (copy_to_user(user, entry, sizeof(*entry)) != 0)
@@ -2925,6 +2868,7 @@ nla_put_failure:
 static int ip_vs_genl_fill_service(struct sk_buff *skb,
 				   struct ip_vs_service *svc)
 {
+	struct ip_vs_scheduler *sched;
 	struct nlattr *nl_service;
 	struct ip_vs_flags flags = { .flags = svc->flags,
 				     .mask = ~0 };
@@ -2945,7 +2889,8 @@ static int ip_vs_genl_fill_service(struct sk_buff *skb,
 			goto nla_put_failure;
 	}
 
-	if (nla_put_string(skb, IPVS_SVC_ATTR_SCHED_NAME, svc->scheduler->name) ||
+	sched = rcu_dereference_protected(svc->scheduler, 1);
+	if (nla_put_string(skb, IPVS_SVC_ATTR_SCHED_NAME, sched->name) ||
 	    (svc->pe &&
 	     nla_put_string(skb, IPVS_SVC_ATTR_PE_NAME, svc->pe->name)) ||
 	    nla_put(skb, IPVS_SVC_ATTR_FLAGS, sizeof(flags), &flags) ||
@@ -2996,7 +2941,7 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 
 	mutex_lock(&__ip_vs_mutex);
 	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
-		list_for_each_entry(svc, &ip_vs_svc_table[i], s_list) {
+		hlist_for_each_entry(svc, &ip_vs_svc_table[i], s_list) {
 			if (++idx <= start || !net_eq(svc->net, net))
 				continue;
 			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
@@ -3007,7 +2952,7 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 	}
 
 	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
-		list_for_each_entry(svc, &ip_vs_svc_fwm_table[i], f_list) {
+		hlist_for_each_entry(svc, &ip_vs_svc_fwm_table[i], f_list) {
 			if (++idx <= start || !net_eq(svc->net, net))
 				continue;
 			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
@@ -3067,11 +3012,13 @@ static int ip_vs_genl_parse_service(struct net *net,
 		usvc->fwmark = 0;
 	}
 
+	rcu_read_lock();
 	if (usvc->fwmark)
 		svc = __ip_vs_svc_fwm_find(net, usvc->af, usvc->fwmark);
 	else
 		svc = __ip_vs_service_find(net, usvc->af, usvc->protocol,
 					   &usvc->addr, usvc->port);
+	rcu_read_unlock();
 	*ret_svc = svc;
 
 	/* If a full entry was requested, check for the additional fields */
@@ -3903,8 +3850,8 @@ int __init ip_vs_control_init(void)
 
 	/* Initialize svc_table, ip_vs_svc_fwm_table */
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		INIT_LIST_HEAD(&ip_vs_svc_table[idx]);
-		INIT_LIST_HEAD(&ip_vs_svc_fwm_table[idx]);
+		INIT_HLIST_HEAD(&ip_vs_svc_table[idx]);
+		INIT_HLIST_HEAD(&ip_vs_svc_fwm_table[idx]);
 	}
 
 	smp_wmb();	/* Do we really need it now ? */
diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index 89c2723..ccab120 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -269,6 +269,7 @@ static int __init ip_vs_dh_init(void)
 static void __exit ip_vs_dh_cleanup(void)
 {
 	unregister_ip_vs_scheduler(&ip_vs_dh_scheduler);
+	synchronize_rcu();
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index ffef8a1..d8e5238 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -633,6 +633,7 @@ static void __exit ip_vs_lblc_cleanup(void)
 {
 	unregister_ip_vs_scheduler(&ip_vs_lblc_scheduler);
 	unregister_pernet_subsys(&ip_vs_lblc_ops);
+	synchronize_rcu();
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index cdfe6a9..041b7cc 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -821,6 +821,7 @@ static void __exit ip_vs_lblcr_cleanup(void)
 {
 	unregister_ip_vs_scheduler(&ip_vs_lblcr_scheduler);
 	unregister_pernet_subsys(&ip_vs_lblcr_ops);
+	synchronize_rcu();
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_lc.c b/net/netfilter/ipvs/ip_vs_lc.c
index 0cabf78..5128e33 100644
--- a/net/netfilter/ipvs/ip_vs_lc.c
+++ b/net/netfilter/ipvs/ip_vs_lc.c
@@ -84,6 +84,7 @@ static int __init ip_vs_lc_init(void)
 static void __exit ip_vs_lc_cleanup(void)
 {
 	unregister_ip_vs_scheduler(&ip_vs_lc_scheduler);
+	synchronize_rcu();
 }
 
 module_init(ip_vs_lc_init);
diff --git a/net/netfilter/ipvs/ip_vs_nq.c b/net/netfilter/ipvs/ip_vs_nq.c
index 51dc0cf..646cfd4 100644
--- a/net/netfilter/ipvs/ip_vs_nq.c
+++ b/net/netfilter/ipvs/ip_vs_nq.c
@@ -133,6 +133,7 @@ static int __init ip_vs_nq_init(void)
 static void __exit ip_vs_nq_cleanup(void)
 {
 	unregister_ip_vs_scheduler(&ip_vs_nq_scheduler);
+	synchronize_rcu();
 }
 
 module_init(ip_vs_nq_init);
diff --git a/net/netfilter/ipvs/ip_vs_pe.c b/net/netfilter/ipvs/ip_vs_pe.c
index 5d9774c..1a82b29 100644
--- a/net/netfilter/ipvs/ip_vs_pe.c
+++ b/net/netfilter/ipvs/ip_vs_pe.c
@@ -16,18 +16,6 @@ static LIST_HEAD(ip_vs_pe);
 /* semaphore for IPVS PEs. */
 static DEFINE_MUTEX(ip_vs_pe_mutex);
 
-/* Bind a service with a pe */
-void ip_vs_bind_pe(struct ip_vs_service *svc, struct ip_vs_pe *pe)
-{
-	svc->pe = pe;
-}
-
-/* Unbind a service from its pe */
-void ip_vs_unbind_pe(struct ip_vs_service *svc)
-{
-	svc->pe = NULL;
-}
-
 /* Get pe in the pe list by name */
 struct ip_vs_pe *__ip_vs_pe_getbyname(const char *pe_name)
 {
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index f7190cd..4de5176 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -27,9 +27,10 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	if (sch == NULL)
 		return 0;
 	net = skb_net(skb);
+	rcu_read_lock();
 	if ((sch->type == SCTP_CID_INIT) &&
-	    (svc = ip_vs_service_get(net, af, skb->mark, iph->protocol,
-				     &iph->daddr, sh->dest))) {
+	    (svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+				      &iph->daddr, sh->dest))) {
 		int ignored;
 
 		if (ip_vs_todrop(net_ipvs(net))) {
@@ -37,7 +38,7 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 			 * It seems that we are very loaded.
 			 * We have to drop this packet :(
 			 */
-			ip_vs_service_put(svc);
+			rcu_read_unlock();
 			*verdict = NF_DROP;
 			return 0;
 		}
@@ -49,14 +50,13 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		if (!*cpp && ignored <= 0) {
 			if (!ignored)
 				*verdict = ip_vs_leave(svc, skb, pd, iph);
-			else {
-				ip_vs_service_put(svc);
+			else
 				*verdict = NF_DROP;
-			}
+			rcu_read_unlock();
 			return 0;
 		}
-		ip_vs_service_put(svc);
 	}
+	rcu_read_unlock();
 	/* NF_ACCEPT */
 	return 1;
 }
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 0bbc3fe..7de3342 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -47,9 +47,10 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	}
 	net = skb_net(skb);
 	/* No !th->ack check to allow scheduling on SYN+ACK for Active FTP */
+	rcu_read_lock();
 	if (th->syn &&
-	    (svc = ip_vs_service_get(net, af, skb->mark, iph->protocol,
-				     &iph->daddr, th->dest))) {
+	    (svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+				      &iph->daddr, th->dest))) {
 		int ignored;
 
 		if (ip_vs_todrop(net_ipvs(net))) {
@@ -57,7 +58,7 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 			 * It seems that we are very loaded.
 			 * We have to drop this packet :(
 			 */
-			ip_vs_service_put(svc);
+			rcu_read_unlock();
 			*verdict = NF_DROP;
 			return 0;
 		}
@@ -70,14 +71,13 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		if (!*cpp && ignored <= 0) {
 			if (!ignored)
 				*verdict = ip_vs_leave(svc, skb, pd, iph);
-			else {
-				ip_vs_service_put(svc);
+			else
 				*verdict = NF_DROP;
-			}
+			rcu_read_unlock();
 			return 0;
 		}
-		ip_vs_service_put(svc);
 	}
+	rcu_read_unlock();
 	/* NF_ACCEPT */
 	return 1;
 }
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 1a03e2d..b62a3c0 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -44,8 +44,9 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		return 0;
 	}
 	net = skb_net(skb);
-	svc = ip_vs_service_get(net, af, skb->mark, iph->protocol,
-				&iph->daddr, uh->dest);
+	rcu_read_lock();
+	svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+				 &iph->daddr, uh->dest);
 	if (svc) {
 		int ignored;
 
@@ -54,7 +55,7 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 			 * It seems that we are very loaded.
 			 * We have to drop this packet :(
 			 */
-			ip_vs_service_put(svc);
+			rcu_read_unlock();
 			*verdict = NF_DROP;
 			return 0;
 		}
@@ -67,14 +68,13 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		if (!*cpp && ignored <= 0) {
 			if (!ignored)
 				*verdict = ip_vs_leave(svc, skb, pd, iph);
-			else {
-				ip_vs_service_put(svc);
+			else
 				*verdict = NF_DROP;
-			}
+			rcu_read_unlock();
 			return 0;
 		}
-		ip_vs_service_put(svc);
 	}
+	rcu_read_unlock();
 	/* NF_ACCEPT */
 	return 1;
 }
diff --git a/net/netfilter/ipvs/ip_vs_rr.c b/net/netfilter/ipvs/ip_vs_rr.c
index aa4601f..749c98a 100644
--- a/net/netfilter/ipvs/ip_vs_rr.c
+++ b/net/netfilter/ipvs/ip_vs_rr.c
@@ -121,6 +121,7 @@ static int __init ip_vs_rr_init(void)
 static void __exit ip_vs_rr_cleanup(void)
 {
 	unregister_ip_vs_scheduler(&ip_vs_rr_scheduler);
+	synchronize_rcu();
 }
 
 module_init(ip_vs_rr_init);
diff --git a/net/netfilter/ipvs/ip_vs_sched.c b/net/netfilter/ipvs/ip_vs_sched.c
index 1b715d0..4dbcda6 100644
--- a/net/netfilter/ipvs/ip_vs_sched.c
+++ b/net/netfilter/ipvs/ip_vs_sched.c
@@ -47,8 +47,6 @@ int ip_vs_bind_scheduler(struct ip_vs_service *svc,
 {
 	int ret;
 
-	svc->scheduler = scheduler;
-
 	if (scheduler->init_service) {
 		ret = scheduler->init_service(svc);
 		if (ret) {
@@ -56,7 +54,7 @@ int ip_vs_bind_scheduler(struct ip_vs_service *svc,
 			return ret;
 		}
 	}
-
+	rcu_assign_pointer(svc->scheduler, scheduler);
 	return 0;
 }
 
@@ -64,17 +62,19 @@ int ip_vs_bind_scheduler(struct ip_vs_service *svc,
 /*
  *  Unbind a service with its scheduler
  */
-void ip_vs_unbind_scheduler(struct ip_vs_service *svc)
+void ip_vs_unbind_scheduler(struct ip_vs_service *svc,
+			    struct ip_vs_scheduler *sched)
 {
-	struct ip_vs_scheduler *sched = svc->scheduler;
+	struct ip_vs_scheduler *cur_sched;
 
-	if (!sched)
+	cur_sched = rcu_dereference_protected(svc->scheduler, 1);
+	/* This check proves that old 'sched' was installed */
+	if (!cur_sched)
 		return;
 
 	if (sched->done_service)
 		sched->done_service(svc);
-
-	svc->scheduler = NULL;
+	/* svc->scheduler can not be set to NULL */
 }
 
 
@@ -148,21 +148,21 @@ void ip_vs_scheduler_put(struct ip_vs_scheduler *scheduler)
 
 void ip_vs_scheduler_err(struct ip_vs_service *svc, const char *msg)
 {
+	struct ip_vs_scheduler *sched;
+
+	sched = rcu_dereference(svc->scheduler);
 	if (svc->fwmark) {
 		IP_VS_ERR_RL("%s: FWM %u 0x%08X - %s\n",
-			     svc->scheduler->name, svc->fwmark,
-			     svc->fwmark, msg);
+			     sched->name, svc->fwmark, svc->fwmark, msg);
 #ifdef CONFIG_IP_VS_IPV6
 	} else if (svc->af == AF_INET6) {
 		IP_VS_ERR_RL("%s: %s [%pI6c]:%d - %s\n",
-			     svc->scheduler->name,
-			     ip_vs_proto_name(svc->protocol),
+			     sched->name, ip_vs_proto_name(svc->protocol),
 			     &svc->addr.in6, ntohs(svc->port), msg);
 #endif
 	} else {
 		IP_VS_ERR_RL("%s: %s %pI4:%d - %s\n",
-			     svc->scheduler->name,
-			     ip_vs_proto_name(svc->protocol),
+			     sched->name, ip_vs_proto_name(svc->protocol),
 			     &svc->addr.ip, ntohs(svc->port), msg);
 	}
 }
diff --git a/net/netfilter/ipvs/ip_vs_sed.c b/net/netfilter/ipvs/ip_vs_sed.c
index d011870..f320592 100644
--- a/net/netfilter/ipvs/ip_vs_sed.c
+++ b/net/netfilter/ipvs/ip_vs_sed.c
@@ -134,6 +134,7 @@ static int __init ip_vs_sed_init(void)
 static void __exit ip_vs_sed_cleanup(void)
 {
 	unregister_ip_vs_scheduler(&ip_vs_sed_scheduler);
+	synchronize_rcu();
 }
 
 module_init(ip_vs_sed_init);
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 81c1a10..0df269d 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -283,6 +283,7 @@ static int __init ip_vs_sh_init(void)
 static void __exit ip_vs_sh_cleanup(void)
 {
 	unregister_ip_vs_scheduler(&ip_vs_sh_scheduler);
+	synchronize_rcu();
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_wlc.c b/net/netfilter/ipvs/ip_vs_wlc.c
index dafae88..c60a81c 100644
--- a/net/netfilter/ipvs/ip_vs_wlc.c
+++ b/net/netfilter/ipvs/ip_vs_wlc.c
@@ -106,6 +106,7 @@ static int __init ip_vs_wlc_init(void)
 static void __exit ip_vs_wlc_cleanup(void)
 {
 	unregister_ip_vs_scheduler(&ip_vs_wlc_scheduler);
+	synchronize_rcu();
 }
 
 module_init(ip_vs_wlc_init);
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index b173ef9..32c646e 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -261,6 +261,7 @@ static int __init ip_vs_wrr_init(void)
 static void __exit ip_vs_wrr_cleanup(void)
 {
 	unregister_ip_vs_scheduler(&ip_vs_wrr_scheduler);
+	synchronize_rcu();
 }
 
 module_init(ip_vs_wrr_init);
-- 
1.7.3.4

