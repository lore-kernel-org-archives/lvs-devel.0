From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [RFC PATCH 5/9] ipvs network name space aware
Date: Fri, 8 Oct 2010 13:17:02 +0200
Message-ID: <201010081317.04167.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr

This patch just contains ip_vs_ctl

Signed-off-by:Hans Schillstrom <hans.schillstrom@ericsson.com>

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index ca8ec8c..7e99cbc 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -38,6 +38,7 @@
 #include <linux/mutex.h>

 #include <net/net_namespace.h>
+#include <linux/nsproxy.h>
 #include <net/ip.h>
 #ifdef CONFIG_IP_VS_IPV6
 #include <net/ipv6.h>
@@ -77,20 +78,8 @@ static atomic_t ip_vs_dropentry = ATOMIC_INIT(0);
 /* number of virtual services */
 static int ip_vs_num_services = 0;

-/* sysctl variables */
-static int sysctl_ip_vs_drop_entry = 0;
-static int sysctl_ip_vs_drop_packet = 0;
-static int sysctl_ip_vs_secure_tcp = 0;
-static int sysctl_ip_vs_amemthresh = 1024;
-static int sysctl_ip_vs_am_droprate = 10;
-int sysctl_ip_vs_cache_bypass = 0;
-int sysctl_ip_vs_expire_nodest_conn = 0;
-int sysctl_ip_vs_expire_quiescent_template = 0;
-int sysctl_ip_vs_sync_threshold[2] = { 3, 50 };
-int sysctl_ip_vs_nat_icmp_send = 0;
-
-
 #ifdef CONFIG_IP_VS_DEBUG
+/* sysctl variables, Not per netns level */
 static int sysctl_ip_vs_debug_level = 0;

 int ip_vs_get_debug_level(void)
@@ -101,7 +90,7 @@ int ip_vs_get_debug_level(void)

 #ifdef CONFIG_IP_VS_IPV6
 /* Taken from rt6_fill_node() in net/ipv6/route.c, is there a better way? */
-static int __ip_vs_addr_is_local_v6(const struct in6_addr *addr)
+static int __ip_vs_addr_is_local_v6(struct net *net, const struct in6_addr *addr)
 {
 	struct rt6_info *rt;
 	struct flowi fl = {
@@ -112,7 +101,7 @@ static int __ip_vs_addr_is_local_v6(const struct in6_addr *addr)
 				.saddr = { .s6_addr32 = {0, 0, 0, 0} }, } },
 	};

-	rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl);
+	rt = (struct rt6_info *)ip6_route_output(net, NULL, &fl);
 	if (rt && rt->rt6i_dev && (rt->rt6i_dev->flags & IFF_LOOPBACK))
 			return 1;

@@ -123,8 +112,9 @@ static int __ip_vs_addr_is_local_v6(const struct in6_addr *addr)
  *	update_defense_level is called from keventd and from sysctl,
  *	so it needs to protect itself from softirqs
  */
-static void update_defense_level(void)
+static void update_defense_level(struct net *net)
 {
+	struct netns_ipvs *ipvs = net->ipvs;
 	struct sysinfo i;
 	static int old_secure_tcp = 0;
 	int availmem;
@@ -139,20 +129,20 @@ static void update_defense_level(void)
 	/* si_swapinfo(&i); */
 	/* availmem = availmem - (i.totalswap - i.freeswap); */

-	nomem = (availmem < sysctl_ip_vs_amemthresh);
+	nomem = (availmem < ipvs->sysctl_amemthresh);

 	local_bh_disable();

 	/* drop_entry */
 	spin_lock(&__ip_vs_dropentry_lock);
-	switch (sysctl_ip_vs_drop_entry) {
+	switch (ipvs->sysctl_drop_entry) {
 	case 0:
 		atomic_set(&ip_vs_dropentry, 0);
 		break;
 	case 1:
 		if (nomem) {
 			atomic_set(&ip_vs_dropentry, 1);
-			sysctl_ip_vs_drop_entry = 2;
+			ipvs->sysctl_drop_entry = 2;
 		} else {
 			atomic_set(&ip_vs_dropentry, 0);
 		}
@@ -162,7 +152,7 @@ static void update_defense_level(void)
 			atomic_set(&ip_vs_dropentry, 1);
 		} else {
 			atomic_set(&ip_vs_dropentry, 0);
-			sysctl_ip_vs_drop_entry = 1;
+			ipvs->sysctl_drop_entry = 1;
 		};
 		break;
 	case 3:
@@ -173,16 +163,16 @@ static void update_defense_level(void)

 	/* drop_packet */
 	spin_lock(&__ip_vs_droppacket_lock);
-	switch (sysctl_ip_vs_drop_packet) {
+	switch (ipvs->sysctl_drop_packet) {
 	case 0:
 		ip_vs_drop_rate = 0;
 		break;
 	case 1:
 		if (nomem) {
 			ip_vs_drop_rate = ip_vs_drop_counter
-				= sysctl_ip_vs_amemthresh /
-				(sysctl_ip_vs_amemthresh-availmem);
-			sysctl_ip_vs_drop_packet = 2;
+				= ipvs->sysctl_amemthresh /
+				(ipvs->sysctl_amemthresh-availmem);
+			ipvs->sysctl_drop_packet = 2;
 		} else {
 			ip_vs_drop_rate = 0;
 		}
@@ -190,22 +180,22 @@ static void update_defense_level(void)
 	case 2:
 		if (nomem) {
 			ip_vs_drop_rate = ip_vs_drop_counter
-				= sysctl_ip_vs_amemthresh /
-				(sysctl_ip_vs_amemthresh-availmem);
+				= ipvs->sysctl_amemthresh /
+				(ipvs->sysctl_amemthresh-availmem);
 		} else {
 			ip_vs_drop_rate = 0;
-			sysctl_ip_vs_drop_packet = 1;
+			ipvs->sysctl_drop_packet = 1;
 		}
 		break;
 	case 3:
-		ip_vs_drop_rate = sysctl_ip_vs_am_droprate;
+		ip_vs_drop_rate = ipvs->sysctl_am_droprate;
 		break;
 	}
 	spin_unlock(&__ip_vs_droppacket_lock);

 	/* secure_tcp */
 	spin_lock(&ip_vs_securetcp_lock);
-	switch (sysctl_ip_vs_secure_tcp) {
+	switch (ipvs->sysctl_secure_tcp) {
 	case 0:
 		if (old_secure_tcp >= 2)
 			to_change = 0;
@@ -214,7 +204,7 @@ static void update_defense_level(void)
 		if (nomem) {
 			if (old_secure_tcp < 2)
 				to_change = 1;
-			sysctl_ip_vs_secure_tcp = 2;
+			ipvs->sysctl_secure_tcp = 2;
 		} else {
 			if (old_secure_tcp >= 2)
 				to_change = 0;
@@ -227,7 +217,7 @@ static void update_defense_level(void)
 		} else {
 			if (old_secure_tcp >= 2)
 				to_change = 0;
-			sysctl_ip_vs_secure_tcp = 1;
+			ipvs->sysctl_secure_tcp = 1;
 		}
 		break;
 	case 3:
@@ -235,9 +225,9 @@ static void update_defense_level(void)
 			to_change = 1;
 		break;
 	}
-	old_secure_tcp = sysctl_ip_vs_secure_tcp;
+	old_secure_tcp = ipvs->sysctl_secure_tcp;
 	if (to_change >= 0)
-		ip_vs_protocol_timeout_change(sysctl_ip_vs_secure_tcp>1);
+		ip_vs_protocol_timeout_change(ipvs->sysctl_secure_tcp>1);
 	spin_unlock(&ip_vs_securetcp_lock);

 	local_bh_enable();
@@ -253,9 +243,16 @@ static DECLARE_DELAYED_WORK(defense_work, defense_work_handler);

 static void defense_work_handler(struct work_struct *work)
 {
-	update_defense_level();
-	if (atomic_read(&ip_vs_dropentry))
-		ip_vs_random_dropentry();
+	struct net *net;
+
+	for_each_net(net)
+		update_defense_level(net);
+
+	if (atomic_read(&ip_vs_dropentry)) {
+		/* Should another sched period be used to reduce peak load ?*/
+		for_each_net(net)
+			ip_vs_random_dropentry(net);
+	}

 	schedule_delayed_work(&defense_work, DEFENSE_TIMER_PERIOD);
 }
@@ -272,40 +269,6 @@ ip_vs_use_count_dec(void)
 	module_put(THIS_MODULE);
 }

-
-/*
- *	Hash table: for virtual service lookups
- */
-#define IP_VS_SVC_TAB_BITS 8
-#define IP_VS_SVC_TAB_SIZE (1 << IP_VS_SVC_TAB_BITS)
-#define IP_VS_SVC_TAB_MASK (IP_VS_SVC_TAB_SIZE - 1)
-
-/* the service table hashed by <protocol, addr, port> */
-static struct list_head ip_vs_svc_table[IP_VS_SVC_TAB_SIZE];
-/* the service table hashed by fwmark */
-static struct list_head ip_vs_svc_fwm_table[IP_VS_SVC_TAB_SIZE];
-
-/*
- *	Hash table: for real service lookups
- */
-#define IP_VS_RTAB_BITS 4
-#define IP_VS_RTAB_SIZE (1 << IP_VS_RTAB_BITS)
-#define IP_VS_RTAB_MASK (IP_VS_RTAB_SIZE - 1)
-
-static struct list_head ip_vs_rtable[IP_VS_RTAB_SIZE];
-
-/*
- *	Trash for destinations
- */
-static LIST_HEAD(ip_vs_dest_trash);
-
-/*
- *	FTP & NULL virtual service counters
- */
-static atomic_t ip_vs_ftpsvc_counter = ATOMIC_INIT(0);
-static atomic_t ip_vs_nullsvc_counter = ATOMIC_INIT(0);
-
-
 /*
  *	Returns hash value for virtual service
  */
@@ -336,10 +299,10 @@ static __inline__ unsigned ip_vs_svc_fwm_hashkey(__u32 fwmark)

 /*
  *	Hashes a service in the ip_vs_svc_table by <proto,addr,port>
- *	or in the ip_vs_svc_fwm_table by fwmark.
+ *	or in the net->ipvs->ctl_fwm_table by fwmark.
  *	Should be called with locked tables.
  */
-static int ip_vs_svc_hash(struct ip_vs_service *svc)
+static int ip_vs_svc_hash(struct net *net, struct ip_vs_service *svc)
 {
 	unsigned hash;

@@ -355,13 +318,13 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
 		 */
 		hash = ip_vs_svc_hashkey(svc->af, svc->protocol, &svc->addr,
 					 svc->port);
-		list_add(&svc->s_list, &ip_vs_svc_table[hash]);
+		list_add(&svc->s_list, &net->ipvs->ctl_svc_table[hash]);
 	} else {
 		/*
-		 *  Hash it by fwmark in ip_vs_svc_fwm_table
+		 *  Hash it by fwmark in net->ipvs->ctl_fwm_table
 		 */
 		hash = ip_vs_svc_fwm_hashkey(svc->fwmark);
-		list_add(&svc->f_list, &ip_vs_svc_fwm_table[hash]);
+		list_add(&svc->f_list, &net->ipvs->ctl_fwm_table[hash]);
 	}

 	svc->flags |= IP_VS_SVC_F_HASHED;
@@ -372,7 +335,7 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)


 /*
- *	Unhashes a service from ip_vs_svc_table/ip_vs_svc_fwm_table.
+ *	Unhashes a service from net->ipvs->ctl_svc_table/net->ipvs->ctl_fwm_table.
  *	Should be called with locked tables.
  */
 static int ip_vs_svc_unhash(struct ip_vs_service *svc)
@@ -384,10 +347,10 @@ static int ip_vs_svc_unhash(struct ip_vs_service *svc)
 	}

 	if (svc->fwmark == 0) {
-		/* Remove it from the ip_vs_svc_table table */
+		/* Remove it from the net->ipvs->ctl_svc_table table */
 		list_del(&svc->s_list);
 	} else {
-		/* Remove it from the ip_vs_svc_fwm_table table */
+		/* Remove it from the net->ipvs->ctl_fwm_table table */
 		list_del(&svc->f_list);
 	}

@@ -401,16 +364,17 @@ static int ip_vs_svc_unhash(struct ip_vs_service *svc)
  *	Get service by {proto,addr,port} in the service table.
  */
 static inline struct ip_vs_service *
-__ip_vs_service_get(int af, __u16 protocol, const union nf_inet_addr *vaddr,
-		    __be16 vport)
+__ip_vs_service_get(struct net *net, int af, __u16 protocol,
+		    const union nf_inet_addr *vaddr,  __be16 vport)
 {
 	unsigned hash;
 	struct ip_vs_service *svc;
+	struct netns_ipvs *ipvs = net->ipvs;

 	/* Check for "full" addressed entries */
 	hash = ip_vs_svc_hashkey(af, protocol, vaddr, vport);

-	list_for_each_entry(svc, &ip_vs_svc_table[hash], s_list){
+	list_for_each_entry(svc, &ipvs->ctl_svc_table[hash], s_list){
 		if ((svc->af == af)
 		    && ip_vs_addr_equal(af, &svc->addr, vaddr)
 		    && (svc->port == vport)
@@ -429,15 +393,16 @@ __ip_vs_service_get(int af, __u16 protocol, const union nf_inet_addr *vaddr,
  *	Get service by {fwmark} in the service table.
  */
 static inline struct ip_vs_service *
-__ip_vs_svc_fwm_get(int af, __u32 fwmark)
+__ip_vs_svc_fwm_get(struct net *net, int af, __u32 fwmark)
 {
 	unsigned hash;
 	struct ip_vs_service *svc;
+	struct netns_ipvs *ipvs = net->ipvs;

 	/* Check for fwmark addressed entries */
 	hash = ip_vs_svc_fwm_hashkey(fwmark);

-	list_for_each_entry(svc, &ip_vs_svc_fwm_table[hash], f_list) {
+	list_for_each_entry(svc, &ipvs->ctl_fwm_table[hash], f_list) {
 		if (svc->fwmark == fwmark && svc->af == af) {
 			/* HIT */
 			atomic_inc(&svc->usecnt);
@@ -449,7 +414,7 @@ __ip_vs_svc_fwm_get(int af, __u32 fwmark)
 }

 struct ip_vs_service *
-ip_vs_service_get(int af, __u32 fwmark, __u16 protocol,
+ip_vs_service_get(struct net *net, int af, __u32 fwmark, __u16 protocol,
 		  const union nf_inet_addr *vaddr, __be16 vport)
 {
 	struct ip_vs_service *svc;
@@ -459,32 +424,32 @@ ip_vs_service_get(int af, __u32 fwmark, __u16 protocol,
 	/*
 	 *	Check the table hashed by fwmark first
 	 */
-	if (fwmark && (svc = __ip_vs_svc_fwm_get(af, fwmark)))
+	if (fwmark && (svc = __ip_vs_svc_fwm_get(net, af, fwmark)))
 		goto out;

 	/*
 	 *	Check the table hashed by <protocol,addr,port>
 	 *	for "full" addressed entries
 	 */
-	svc = __ip_vs_service_get(af, protocol, vaddr, vport);
+	svc = __ip_vs_service_get(net, af, protocol, vaddr, vport);

 	if (svc == NULL
 	    && protocol == IPPROTO_TCP
-	    && atomic_read(&ip_vs_ftpsvc_counter)
+	    && atomic_read(&net->ipvs->ctl_ftpsvc_counter)
 	    && (vport == FTPDATA || ntohs(vport) >= PROT_SOCK)) {
 		/*
 		 * Check if ftp service entry exists, the packet
 		 * might belong to FTP data connections.
 		 */
-		svc = __ip_vs_service_get(af, protocol, vaddr, FTPPORT);
+		svc = __ip_vs_service_get(net, af, protocol, vaddr, FTPPORT);
 	}

 	if (svc == NULL
-	    && atomic_read(&ip_vs_nullsvc_counter)) {
+	    && atomic_read(&net->ipvs->ctl_nullsvc_counter)) {
 		/*
 		 * Check if the catch-all port (port zero) exists
 		 */
-		svc = __ip_vs_service_get(af, protocol, vaddr, 0);
+		svc = __ip_vs_service_get(net, af, protocol, vaddr, 0);
 	}

   out:
@@ -538,10 +503,10 @@ static inline unsigned ip_vs_rs_hashkey(int af,
 }

 /*
- *	Hashes ip_vs_dest in ip_vs_rtable by <proto,addr,port>.
+ *	Hashes ip_vs_dest in net->ipvs->ctl_rtable by <proto,addr,port>.
  *	should be called with locked tables.
  */
-static int ip_vs_rs_hash(struct ip_vs_dest *dest)
+static int ip_vs_rs_hash(struct net *net, struct ip_vs_dest *dest)
 {
 	unsigned hash;

@@ -555,19 +520,19 @@ static int ip_vs_rs_hash(struct ip_vs_dest *dest)
 	 */
 	hash = ip_vs_rs_hashkey(dest->af, &dest->addr, dest->port);

-	list_add(&dest->d_list, &ip_vs_rtable[hash]);
+	list_add(&dest->d_list, &net->ipvs->ctl_rtable[hash]);

 	return 1;
 }

 /*
- *	UNhashes ip_vs_dest from ip_vs_rtable.
+ *	UNhashes ip_vs_dest from net->ipvs->ctl_rtable.
  *	should be called with locked tables.
  */
 static int ip_vs_rs_unhash(struct ip_vs_dest *dest)
 {
 	/*
-	 * Remove it from the ip_vs_rtable table.
+	 * Remove it from the net->ipvs->ctl_rtable table.
 	 */
 	if (!list_empty(&dest->d_list)) {
 		list_del(&dest->d_list);
@@ -581,12 +546,13 @@ static int ip_vs_rs_unhash(struct ip_vs_dest *dest)
  *	Lookup real service by <proto,addr,port> in the real service table.
  */
 struct ip_vs_dest *
-ip_vs_lookup_real_service(int af, __u16 protocol,
+ip_vs_lookup_real_service(struct net *net, int af, __u16 protocol,
 			  const union nf_inet_addr *daddr,
 			  __be16 dport)
 {
 	unsigned hash;
 	struct ip_vs_dest *dest;
+	struct netns_ipvs *ipvs = net->ipvs;

 	/*
 	 *	Check for "full" addressed entries
@@ -595,7 +561,7 @@ ip_vs_lookup_real_service(int af, __u16 protocol,
 	hash = ip_vs_rs_hashkey(af, daddr, dport);

 	read_lock(&__ip_vs_rs_lock);
-	list_for_each_entry(dest, &ip_vs_rtable[hash], d_list) {
+	list_for_each_entry(dest, &ipvs->ctl_rtable[hash], d_list) {
 		if ((dest->af == af)
 		    && ip_vs_addr_equal(af, &dest->addr, daddr)
 		    && (dest->port == dport)
@@ -645,15 +611,15 @@ ip_vs_lookup_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
  * ip_vs_lookup_real_service() looked promissing, but
  * seems not working as expected.
  */
-struct ip_vs_dest *ip_vs_find_dest(int af, const union nf_inet_addr *daddr,
-				   __be16 dport,
-				   const union nf_inet_addr *vaddr,
-				   __be16 vport, __u16 protocol)
+struct ip_vs_dest *
+ip_vs_find_dest(struct net *net, int af,
+		const union nf_inet_addr *daddr, __be16 dport,
+		const union nf_inet_addr *vaddr, __be16 vport, __u16 protocol)
 {
 	struct ip_vs_dest *dest;
 	struct ip_vs_service *svc;

-	svc = ip_vs_service_get(af, 0, protocol, vaddr, vport);
+	svc = ip_vs_service_get(net, af, 0, protocol, vaddr, vport);
 	if (!svc)
 		return NULL;
 	dest = ip_vs_lookup_dest(svc, daddr, dport);
@@ -674,15 +640,16 @@ struct ip_vs_dest *ip_vs_find_dest(int af, const union nf_inet_addr *daddr,
  *  scheduling.
  */
 static struct ip_vs_dest *
-ip_vs_trash_get_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
-		     __be16 dport)
+ip_vs_trash_get_dest(struct net *net, struct ip_vs_service *svc,
+		     const union nf_inet_addr *daddr, __be16 dport)
 {
 	struct ip_vs_dest *dest, *nxt;
+	struct netns_ipvs *ipvs = net->ipvs;

 	/*
 	 * Find the destination in trash
 	 */
-	list_for_each_entry_safe(dest, nxt, &ip_vs_dest_trash, n_list) {
+	list_for_each_entry_safe(dest, nxt, &ipvs->ctl_dest_trash, n_list) {
 		IP_VS_DBG_BUF(3, "Destination %u/%s:%u still in trash, "
 			      "dest->refcnt=%d\n",
 			      dest->vfwmark,
@@ -730,11 +697,12 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
  *  are expired, and the refcnt of each destination in the trash must
  *  be 1, so we simply release them here.
  */
-static void ip_vs_trash_cleanup(void)
+static void ip_vs_trash_cleanup(struct net *net)
 {
 	struct ip_vs_dest *dest, *nxt;
+	struct netns_ipvs *ipvs = net->ipvs;

-	list_for_each_entry_safe(dest, nxt, &ip_vs_dest_trash, n_list) {
+	list_for_each_entry_safe(dest, nxt, &ipvs->ctl_dest_trash, n_list) {
 		list_del(&dest->n_list);
 		ip_vs_dst_reset(dest);
 		__ip_vs_unbind_svc(dest);
@@ -743,8 +711,7 @@ static void ip_vs_trash_cleanup(void)
 }


-static void
-ip_vs_zero_stats(struct ip_vs_stats *stats)
+static void ip_vs_zero_stats(struct ip_vs_stats *stats)
 {
 	spin_lock_bh(&stats->lock);

@@ -758,7 +725,7 @@ ip_vs_zero_stats(struct ip_vs_stats *stats)
  *	Update a destination in the given service
  */
 static void
-__ip_vs_update_dest(struct ip_vs_service *svc,
+__ip_vs_update_dest(struct net *net, struct ip_vs_service *svc,
 		    struct ip_vs_dest *dest, struct ip_vs_dest_user_kern *udest)
 {
 	int conn_flags;
@@ -770,13 +737,13 @@ __ip_vs_update_dest(struct ip_vs_service *svc,
 	/* check if local node and update the flags */
 #ifdef CONFIG_IP_VS_IPV6
 	if (svc->af == AF_INET6) {
-		if (__ip_vs_addr_is_local_v6(&udest->addr.in6)) {
+		if (__ip_vs_addr_is_local_v6(net, &udest->addr.in6)) {
 			conn_flags = (conn_flags & ~IP_VS_CONN_F_FWD_MASK)
 				| IP_VS_CONN_F_LOCALNODE;
 		}
 	} else
 #endif
-		if (inet_addr_type(&init_net, udest->addr.ip) == RTN_LOCAL) {
+		if (inet_addr_type(net, udest->addr.ip) == RTN_LOCAL) {
 			conn_flags = (conn_flags & ~IP_VS_CONN_F_FWD_MASK)
 				| IP_VS_CONN_F_LOCALNODE;
 		}
@@ -786,11 +753,11 @@ __ip_vs_update_dest(struct ip_vs_service *svc,
 		conn_flags |= IP_VS_CONN_F_NOOUTPUT;
 	} else {
 		/*
-		 *    Put the real service in ip_vs_rtable if not present.
-		 *    For now only for NAT!
+		 * Put the real service in net->ipvs->ctl_rtable if not present.
+		 * For now only for NAT!
 		 */
 		write_lock_bh(&__ip_vs_rs_lock);
-		ip_vs_rs_hash(dest);
+		ip_vs_rs_hash(net, dest);
 		write_unlock_bh(&__ip_vs_rs_lock);
 	}
 	atomic_set(&dest->conn_flags, conn_flags);
@@ -820,8 +787,8 @@ __ip_vs_update_dest(struct ip_vs_service *svc,
  *	Create a destination for the given service
  */
 static int
-ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
-	       struct ip_vs_dest **dest_p)
+ip_vs_new_dest(struct net *net, struct ip_vs_service *svc,
+	       struct ip_vs_dest_user_kern *udest, struct ip_vs_dest **dest_p)
 {
 	struct ip_vs_dest *dest;
 	unsigned atype;
@@ -833,12 +800,12 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 		atype = ipv6_addr_type(&udest->addr.in6);
 		if ((!(atype & IPV6_ADDR_UNICAST) ||
 			atype & IPV6_ADDR_LINKLOCAL) &&
-			!__ip_vs_addr_is_local_v6(&udest->addr.in6))
+			!__ip_vs_addr_is_local_v6(net, &udest->addr.in6))
 			return -EINVAL;
 	} else
 #endif
 	{
-		atype = inet_addr_type(&init_net, udest->addr.ip);
+		atype = inet_addr_type(net, udest->addr.ip);
 		if (atype != RTN_LOCAL && atype != RTN_UNICAST)
 			return -EINVAL;
 	}
@@ -865,8 +832,8 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 	INIT_LIST_HEAD(&dest->d_list);
 	spin_lock_init(&dest->dst_lock);
 	spin_lock_init(&dest->stats.lock);
-	__ip_vs_update_dest(svc, dest, udest);
-	ip_vs_new_estimator(&dest->stats);
+	__ip_vs_update_dest(net, svc, dest, udest);
+	ip_vs_new_estimator(net, &dest->stats);

 	*dest_p = dest;

@@ -878,8 +845,8 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 /*
  *	Add a destination into an existing service
  */
-static int
-ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
+static int ip_vs_add_dest(struct net *net, struct ip_vs_service *svc,
+			  struct ip_vs_dest_user_kern *udest)
 {
 	struct ip_vs_dest *dest;
 	union nf_inet_addr daddr;
@@ -915,7 +882,7 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	 * Check if the dest already exists in the trash and
 	 * is from the same service
 	 */
-	dest = ip_vs_trash_get_dest(svc, &daddr, dport);
+	dest = ip_vs_trash_get_dest(net, svc, &daddr, dport);

 	if (dest != NULL) {
 		IP_VS_DBG_BUF(3, "Get destination %s:%u from trash, "
@@ -926,14 +893,14 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 			      IP_VS_DBG_ADDR(svc->af, &dest->vaddr),
 			      ntohs(dest->vport));

-		__ip_vs_update_dest(svc, dest, udest);
+		__ip_vs_update_dest(net, svc, dest, udest);

 		/*
 		 * Get the destination from the trash
 		 */
 		list_del(&dest->n_list);

-		ip_vs_new_estimator(&dest->stats);
+		ip_vs_new_estimator(net, &dest->stats);

 		write_lock_bh(&__ip_vs_svc_lock);

@@ -956,7 +923,7 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	/*
 	 * Allocate and initialize the dest structure
 	 */
-	ret = ip_vs_new_dest(svc, udest, &dest);
+	ret = ip_vs_new_dest(net, svc, udest, &dest);
 	if (ret) {
 		return ret;
 	}
@@ -991,8 +958,8 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 /*
  *	Edit a destination in the given service
  */
-static int
-ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
+static int ip_vs_edit_dest(struct net *net, struct ip_vs_service *svc,
+			   struct ip_vs_dest_user_kern *udest)
 {
 	struct ip_vs_dest *dest;
 	union nf_inet_addr daddr;
@@ -1023,7 +990,7 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 		return -ENOENT;
 	}

-	__ip_vs_update_dest(svc, dest, udest);
+	__ip_vs_update_dest(net, svc, dest, udest);

 	write_lock_bh(&__ip_vs_svc_lock);

@@ -1045,9 +1012,9 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 /*
  *	Delete a destination (must be already unlinked from the service)
  */
-static void __ip_vs_del_dest(struct ip_vs_dest *dest)
+static void __ip_vs_del_dest(struct net *net, struct ip_vs_dest *dest)
 {
-	ip_vs_kill_estimator(&dest->stats);
+	ip_vs_kill_estimator(net, &dest->stats);

 	/*
 	 *  Remove it from the d-linked list with the real services.
@@ -1076,7 +1043,7 @@ static void __ip_vs_del_dest(struct ip_vs_dest *dest)
 			      IP_VS_DBG_ADDR(dest->af, &dest->addr),
 			      ntohs(dest->port),
 			      atomic_read(&dest->refcnt));
-		list_add(&dest->n_list, &ip_vs_dest_trash);
+		list_add(&dest->n_list, &net->ipvs->ctl_dest_trash);
 		atomic_inc(&dest->refcnt);
 	}
 }
@@ -1108,8 +1075,8 @@ static void __ip_vs_unlink_dest(struct ip_vs_service *svc,
 /*
  *	Delete a destination server in the given service
  */
-static int
-ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
+static int ip_vs_del_dest(struct net *net, struct ip_vs_service *svc,
+			  struct ip_vs_dest_user_kern *udest)
 {
 	struct ip_vs_dest *dest;
 	__be16 dport = udest->port;
@@ -1140,7 +1107,7 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	/*
 	 *	Delete the destination
 	 */
-	__ip_vs_del_dest(dest);
+	__ip_vs_del_dest(net, dest);

 	LeaveFunction(2);

@@ -1152,7 +1119,7 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
  *	Add a service into the service hash table
  */
 static int
-ip_vs_add_service(struct ip_vs_service_user_kern *u,
+ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 		  struct ip_vs_service **svc_p)
 {
 	int ret = 0;
@@ -1209,11 +1176,11 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,

 	/* Update the virtual service counters */
 	if (svc->port == FTPPORT)
-		atomic_inc(&ip_vs_ftpsvc_counter);
+		atomic_inc(&net->ipvs->ctl_ftpsvc_counter);
 	else if (svc->port == 0)
-		atomic_inc(&ip_vs_nullsvc_counter);
+		atomic_inc(&net->ipvs->ctl_nullsvc_counter);

-	ip_vs_new_estimator(&svc->stats);
+	ip_vs_new_estimator(net, &svc->stats);

 	/* Count only IPv4 services for old get/setsockopt interface */
 	if (svc->af == AF_INET)
@@ -1221,7 +1188,7 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,

 	/* Hash the service into the service table */
 	write_lock_bh(&__ip_vs_svc_lock);
-	ip_vs_svc_hash(svc);
+	ip_vs_svc_hash(net, svc);
 	write_unlock_bh(&__ip_vs_svc_lock);

 	*svc_p = svc;
@@ -1336,7 +1303,7 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
  *	- The service must be unlinked, unlocked and not referenced!
  *	- We are called under _bh lock
  */
-static void __ip_vs_del_service(struct ip_vs_service *svc)
+static void __ip_vs_del_service(struct net *net, struct ip_vs_service *svc)
 {
 	struct ip_vs_dest *dest, *nxt;
 	struct ip_vs_scheduler *old_sched;
@@ -1345,7 +1312,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc)
 	if (svc->af == AF_INET)
 		ip_vs_num_services--;

-	ip_vs_kill_estimator(&svc->stats);
+	ip_vs_kill_estimator(net, &svc->stats);

 	/* Unbind scheduler */
 	old_sched = svc->scheduler;
@@ -1364,16 +1331,16 @@ static void __ip_vs_del_service(struct ip_vs_service *svc)
 	 */
 	list_for_each_entry_safe(dest, nxt, &svc->destinations, n_list) {
 		__ip_vs_unlink_dest(svc, dest, 0);
-		__ip_vs_del_dest(dest);
+		__ip_vs_del_dest(net, dest);
 	}

 	/*
 	 *    Update the virtual service counters
 	 */
 	if (svc->port == FTPPORT)
-		atomic_dec(&ip_vs_ftpsvc_counter);
+		atomic_dec(&net->ipvs->ctl_ftpsvc_counter);
 	else if (svc->port == 0)
-		atomic_dec(&ip_vs_nullsvc_counter);
+		atomic_dec(&net->ipvs->ctl_nullsvc_counter);

 	/*
 	 *    Free the service if nobody refers to it
@@ -1388,7 +1355,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc)
 /*
  *	Delete a service from the service list
  */
-static int ip_vs_del_service(struct ip_vs_service *svc)
+static int ip_vs_del_service(struct net *net, struct ip_vs_service *svc)
 {
 	if (svc == NULL)
 		return -EEXIST;
@@ -1405,7 +1372,7 @@ static int ip_vs_del_service(struct ip_vs_service *svc)
 	 */
 	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 1);

-	__ip_vs_del_service(svc);
+	__ip_vs_del_service(net, svc);

 	write_unlock_bh(&__ip_vs_svc_lock);

@@ -1416,23 +1383,26 @@ static int ip_vs_del_service(struct ip_vs_service *svc)
 /*
  *	Flush all the virtual services
  */
-static int ip_vs_flush(void)
+static int ip_vs_flush(struct net *net)
 {
 	int idx;
 	struct ip_vs_service *svc, *nxt;
+	struct netns_ipvs *ipvs = net->ipvs;

 	/*
 	 * Flush the service table hashed by <protocol,addr,port>
 	 */
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each_entry_safe(svc, nxt, &ip_vs_svc_table[idx], s_list) {
+		list_for_each_entry_safe(svc, nxt,
+				         &ipvs->ctl_svc_table[idx],
+				         s_list) {
 			write_lock_bh(&__ip_vs_svc_lock);
 			ip_vs_svc_unhash(svc);
 			/*
 			 * Wait until all the svc users go away.
 			 */
 			IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 0);
-			__ip_vs_del_service(svc);
+			__ip_vs_del_service(net, svc);
 			write_unlock_bh(&__ip_vs_svc_lock);
 		}
 	}
@@ -1442,14 +1412,14 @@ static int ip_vs_flush(void)
 	 */
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		list_for_each_entry_safe(svc, nxt,
-					 &ip_vs_svc_fwm_table[idx], f_list) {
+					 &ipvs->ctl_fwm_table[idx], f_list) {
 			write_lock_bh(&__ip_vs_svc_lock);
 			ip_vs_svc_unhash(svc);
 			/*
 			 * Wait until all the svc users go away.
 			 */
 			IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 0);
-			__ip_vs_del_service(svc);
+			__ip_vs_del_service(net, svc);
 			write_unlock_bh(&__ip_vs_svc_lock);
 		}
 	}
@@ -1474,24 +1444,25 @@ static int ip_vs_zero_service(struct ip_vs_service *svc)
 	return 0;
 }

-static int ip_vs_zero_all(void)
+static int ip_vs_zero_all(struct net *net)
 {
 	int idx;
 	struct ip_vs_service *svc;
+	struct netns_ipvs *ipvs = net->ipvs;

 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
+		list_for_each_entry(svc, &ipvs->ctl_svc_table[idx], s_list) {
 			ip_vs_zero_service(svc);
 		}
 	}

 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
+		list_for_each_entry(svc, &ipvs->ctl_fwm_table[idx], f_list) {
 			ip_vs_zero_service(svc);
 		}
 	}

-	ip_vs_zero_stats(&ip_vs_stats);
+	ip_vs_zero_stats(ipvs->ctl_stats);
 	return 0;
 }

@@ -1500,6 +1471,7 @@ static int
 proc_do_defense_mode(ctl_table *table, int write,
 		     void __user *buffer, size_t *lenp, loff_t *ppos)
 {
+	struct net *net = current->nsproxy->net_ns;
 	int *valp = table->data;
 	int val = *valp;
 	int rc;
@@ -1510,7 +1482,7 @@ proc_do_defense_mode(ctl_table *table, int write,
 			/* Restore the correct value */
 			*valp = val;
 		} else {
-			update_defense_level();
+			update_defense_level(net);
 		}
 	}
 	return rc;
@@ -1539,53 +1511,71 @@ proc_do_sync_threshold(ctl_table *table, int write,

 /*
  *	IPVS sysctl table (under the /proc/sys/net/ipv4/vs/)
+ *	Do not change order or insert new entries without
+ *	align with netns init in __ip_vs_control_init()
  */

 static struct ctl_table vs_vars[] = {
 	{
 		.procname	= "amemthresh",
-		.data		= &sysctl_ip_vs_amemthresh,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-#ifdef CONFIG_IP_VS_DEBUG
-	{
-		.procname	= "debug_level",
-		.data		= &sysctl_ip_vs_debug_level,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
-#endif
 	{
 		.procname	= "am_droprate",
-		.data		= &sysctl_ip_vs_am_droprate,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
 	{
 		.procname	= "drop_entry",
-		.data		= &sysctl_ip_vs_drop_entry,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_do_defense_mode,
 	},
 	{
 		.procname	= "drop_packet",
-		.data		= &sysctl_ip_vs_drop_packet,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_do_defense_mode,
 	},
 	{
 		.procname	= "secure_tcp",
-		.data		= &sysctl_ip_vs_secure_tcp,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_do_defense_mode,
 	},
+	{
+		.procname	= "cache_bypass",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "expire_nodest_conn",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "expire_quiescent_template",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "sync_threshold",
+		.maxlen		= sizeof(sysctl_ip_vs_sync_threshold),
+		.mode		= 0644,
+		.proc_handler	= proc_do_sync_threshold,
+	},
+	{
+		.procname	= "nat_icmp_send",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 #if 0
 	{
 		.procname	= "timeout_established",
@@ -1672,41 +1662,15 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 #endif
+#ifdef CONFIG_IP_VS_DEBUG
 	{
-		.procname	= "cache_bypass",
-		.data		= &sysctl_ip_vs_cache_bypass,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
-		.procname	= "expire_nodest_conn",
-		.data		= &sysctl_ip_vs_expire_nodest_conn,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
-		.procname	= "expire_quiescent_template",
-		.data		= &sysctl_ip_vs_expire_quiescent_template,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
-		.procname	= "sync_threshold",
-		.data		= &sysctl_ip_vs_sync_threshold,
-		.maxlen		= sizeof(sysctl_ip_vs_sync_threshold),
-		.mode		= 0644,
-		.proc_handler	= proc_do_sync_threshold,
-	},
-	{
-		.procname	= "nat_icmp_send",
-		.data		= &sysctl_ip_vs_nat_icmp_send,
+		.procname	= "debug_level",
+		.data		= &sysctl_ip_vs_debug_level,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+#endif
 	{ }
 };

@@ -1718,11 +1682,10 @@ const struct ctl_path net_vs_ctl_path[] = {
 };
 EXPORT_SYMBOL_GPL(net_vs_ctl_path);

-static struct ctl_table_header * sysctl_header;
-
 #ifdef CONFIG_PROC_FS

 struct ip_vs_iter {
+	struct seq_net_private p;  /* Do not move this, netns depends upon it*/
 	struct list_head *table;
 	int bucket;
 };
@@ -1752,12 +1715,15 @@ static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
 	struct ip_vs_iter *iter = seq->private;
 	int idx;
 	struct ip_vs_service *svc;
+	struct net *net = seq_file_net(seq);
+	struct netns_ipvs *ipvs = net->ipvs;

+	BUG_ON(!net);
 	/* look in hash by protocol */
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
+		list_for_each_entry(svc, &ipvs->ctl_svc_table[idx], s_list) {
 			if (pos-- == 0){
-				iter->table = ip_vs_svc_table;
+				iter->table = ipvs->ctl_svc_table;
 				iter->bucket = idx;
 				return svc;
 			}
@@ -1766,9 +1732,9 @@ static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)

 	/* keep looking in fwmark */
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
+		list_for_each_entry(svc, &ipvs->ctl_fwm_table[idx], f_list) {
 			if (pos-- == 0) {
-				iter->table = ip_vs_svc_fwm_table;
+				iter->table = ipvs->ctl_fwm_table;
 				iter->bucket = idx;
 				return svc;
 			}
@@ -1792,7 +1758,10 @@ static void *ip_vs_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	struct list_head *e;
 	struct ip_vs_iter *iter;
 	struct ip_vs_service *svc;
+	struct net *net = seq_file_net(seq);
+	struct netns_ipvs *ipvs = net->ipvs;

+	BUG_ON(!net);
 	++*pos;
 	if (v == SEQ_START_TOKEN)
 		return ip_vs_info_array(seq,0);
@@ -1800,31 +1769,31 @@ static void *ip_vs_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	svc = v;
 	iter = seq->private;

-	if (iter->table == ip_vs_svc_table) {
+	if (iter->table == ipvs->ctl_svc_table) {
 		/* next service in table hashed by protocol */
-		if ((e = svc->s_list.next) != &ip_vs_svc_table[iter->bucket])
+		if ((e = svc->s_list.next) != &ipvs->ctl_svc_table[iter->bucket])
 			return list_entry(e, struct ip_vs_service, s_list);


 		while (++iter->bucket < IP_VS_SVC_TAB_SIZE) {
-			list_for_each_entry(svc,&ip_vs_svc_table[iter->bucket],
+			list_for_each_entry(svc, &ipvs->ctl_svc_table[iter->bucket],
 					    s_list) {
 				return svc;
 			}
 		}

-		iter->table = ip_vs_svc_fwm_table;
+		iter->table = ipvs->ctl_fwm_table;
 		iter->bucket = -1;
 		goto scan_fwmark;
 	}

 	/* next service in hashed by fwmark */
-	if ((e = svc->f_list.next) != &ip_vs_svc_fwm_table[iter->bucket])
+	if ((e = svc->f_list.next) != &ipvs->ctl_fwm_table[iter->bucket])
 		return list_entry(e, struct ip_vs_service, f_list);

  scan_fwmark:
 	while (++iter->bucket < IP_VS_SVC_TAB_SIZE) {
-		list_for_each_entry(svc, &ip_vs_svc_fwm_table[iter->bucket],
+		list_for_each_entry(svc, &ipvs->ctl_fwm_table[iter->bucket],
 				    f_list)
 			return svc;
 	}
@@ -1853,8 +1822,10 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 		const struct ip_vs_service *svc = v;
 		const struct ip_vs_iter *iter = seq->private;
 		const struct ip_vs_dest *dest;
+		struct net *net = seq_file_net(seq);

-		if (iter->table == ip_vs_svc_table) {
+		BUG_ON(!net);
+		if (iter->table == net->ipvs->ctl_svc_table) {
 #ifdef CONFIG_IP_VS_IPV6
 			if (svc->af == AF_INET6)
 				seq_printf(seq, "%s  [%pI6]:%04X %s ",
@@ -1921,7 +1892,7 @@ static const struct seq_operations ip_vs_info_seq_ops = {

 static int ip_vs_info_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &ip_vs_info_seq_ops,
+	return seq_open_net(inode, file, &ip_vs_info_seq_ops,
 			sizeof(struct ip_vs_iter));
 }

@@ -1935,13 +1906,12 @@ static const struct file_operations ip_vs_info_fops = {

 #endif

-struct ip_vs_stats ip_vs_stats = {
-	.lock = __SPIN_LOCK_UNLOCKED(ip_vs_stats.lock),
-};
-
 #ifdef CONFIG_PROC_FS
 static int ip_vs_stats_show(struct seq_file *seq, void *v)
 {
+	/* single_open_net returns net in private */
+	struct net *net = (struct net *)seq->private;
+	struct ip_vs_stats *ctl_stats = net->ipvs->ctl_stats;

 /*               01234567 01234567 01234567 0123456701234567 0123456701234567 */
 	seq_puts(seq,
@@ -1949,29 +1919,29 @@ static int ip_vs_stats_show(struct seq_file *seq, void *v)
 	seq_printf(seq,
 		   "   Conns  Packets  Packets            Bytes            Bytes\n");

-	spin_lock_bh(&ip_vs_stats.lock);
-	seq_printf(seq, "%8X %8X %8X %16LX %16LX\n\n", ip_vs_stats.ustats.conns,
-		   ip_vs_stats.ustats.inpkts, ip_vs_stats.ustats.outpkts,
-		   (unsigned long long) ip_vs_stats.ustats.inbytes,
-		   (unsigned long long) ip_vs_stats.ustats.outbytes);
+	spin_lock_bh(&ctl_stats->lock);
+	seq_printf(seq, "%8X %8X %8X %16LX %16LX\n\n", ctl_stats->ustats.conns,
+		   ctl_stats->ustats.inpkts, ctl_stats->ustats.outpkts,
+		   (unsigned long long) ctl_stats->ustats.inbytes,
+		   (unsigned long long) ctl_stats->ustats.outbytes);

 /*                 01234567 01234567 01234567 0123456701234567 0123456701234567 */
 	seq_puts(seq,
 		   " Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s\n");
 	seq_printf(seq,"%8X %8X %8X %16X %16X\n",
-			ip_vs_stats.ustats.cps,
-			ip_vs_stats.ustats.inpps,
-			ip_vs_stats.ustats.outpps,
-			ip_vs_stats.ustats.inbps,
-			ip_vs_stats.ustats.outbps);
-	spin_unlock_bh(&ip_vs_stats.lock);
+			ctl_stats->ustats.cps,
+			ctl_stats->ustats.inpps,
+			ctl_stats->ustats.outpps,
+			ctl_stats->ustats.inbps,
+			ctl_stats->ustats.outbps);
+	spin_unlock_bh(&ctl_stats->lock);

 	return 0;
 }

 static int ip_vs_stats_seq_open(struct inode *inode, struct file *file)
 {
-	return single_open(file, ip_vs_stats_show, NULL);
+	return single_open_net(inode, file, ip_vs_stats_show);
 }

 static const struct file_operations ip_vs_stats_fops = {
@@ -1979,7 +1949,7 @@ static const struct file_operations ip_vs_stats_fops = {
 	.open = ip_vs_stats_seq_open,
 	.read = seq_read,
 	.llseek = seq_lseek,
-	.release = single_release,
+	.release = single_release_net,
 };

 #endif
@@ -1987,29 +1957,32 @@ static const struct file_operations ip_vs_stats_fops = {
 /*
  *	Set timeout values for tcp tcpfin udp in the timeout_table.
  */
-static int ip_vs_set_timeout(struct ip_vs_timeout_user *u)
+static int ip_vs_set_timeout(struct net *net, struct ip_vs_timeout_user *u)
 {
+	struct ip_vs_proto_data *pd;
 	IP_VS_DBG(2, "Setting timeout tcp:%d tcpfin:%d udp:%d\n",
 		  u->tcp_timeout,
 		  u->tcp_fin_timeout,
 		  u->udp_timeout);

 #ifdef CONFIG_IP_VS_PROTO_TCP
-	if (u->tcp_timeout) {
-		ip_vs_protocol_tcp.timeout_table[IP_VS_TCP_S_ESTABLISHED]
-			= u->tcp_timeout * HZ;
+	pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
+	if (u->tcp_timeout && pd) {
+		pd->timeout_table[IP_VS_TCP_S_ESTABLISHED]
+		        = u->tcp_timeout * HZ;
 	}

-	if (u->tcp_fin_timeout) {
-		ip_vs_protocol_tcp.timeout_table[IP_VS_TCP_S_FIN_WAIT]
+	if (u->tcp_fin_timeout && pd) {
+		pd->timeout_table[IP_VS_TCP_S_FIN_WAIT]
 			= u->tcp_fin_timeout * HZ;
 	}
 #endif

 #ifdef CONFIG_IP_VS_PROTO_UDP
 	if (u->udp_timeout) {
-		ip_vs_protocol_udp.timeout_table[IP_VS_UDP_S_NORMAL]
-			= u->udp_timeout * HZ;
+		if( (pd = ip_vs_proto_data_get(net, IPPROTO_UDP)) )
+			pd->timeout_table[IP_VS_UDP_S_NORMAL]
+			        = u->udp_timeout * HZ;
 	}
 #endif
 	return 0;
@@ -2076,7 +2049,9 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 	struct ip_vs_service *svc;
 	struct ip_vs_dest_user *udest_compat;
 	struct ip_vs_dest_user_kern udest;
+	struct net *net = sock_net(sk);

+	BUG_ON(!net);
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;

@@ -2103,19 +2078,19 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)

 	if (cmd == IP_VS_SO_SET_FLUSH) {
 		/* Flush the virtual service */
-		ret = ip_vs_flush();
+		ret = ip_vs_flush(net);
 		goto out_unlock;
 	} else if (cmd == IP_VS_SO_SET_TIMEOUT) {
 		/* Set timeout values for (tcp tcpfin udp) */
-		ret = ip_vs_set_timeout((struct ip_vs_timeout_user *)arg);
+		ret = ip_vs_set_timeout(net, (struct ip_vs_timeout_user *)arg);
 		goto out_unlock;
 	} else if (cmd == IP_VS_SO_SET_STARTDAEMON) {
 		struct ip_vs_daemon_user *dm = (struct ip_vs_daemon_user *)arg;
-		ret = start_sync_thread(dm->state, dm->mcast_ifn, dm->syncid);
+		ret = start_sync_thread(net, dm->state, dm->mcast_ifn, dm->syncid);
 		goto out_unlock;
 	} else if (cmd == IP_VS_SO_SET_STOPDAEMON) {
 		struct ip_vs_daemon_user *dm = (struct ip_vs_daemon_user *)arg;
-		ret = stop_sync_thread(dm->state);
+		ret = stop_sync_thread(net, dm->state);
 		goto out_unlock;
 	}

@@ -2130,7 +2105,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 	if (cmd == IP_VS_SO_SET_ZERO) {
 		/* if no service address is set, zero counters in all */
 		if (!usvc.fwmark && !usvc.addr.ip && !usvc.port) {
-			ret = ip_vs_zero_all();
+			ret = ip_vs_zero_all(net);
 			goto out_unlock;
 		}
 	}
@@ -2147,15 +2122,15 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)

 	/* Lookup the exact service by <protocol, addr, port> or fwmark */
 	if (usvc.fwmark == 0)
-		svc = __ip_vs_service_get(usvc.af, usvc.protocol,
+		svc = __ip_vs_service_get(net, usvc.af, usvc.protocol,
 					  &usvc.addr, usvc.port);
 	else
-		svc = __ip_vs_svc_fwm_get(usvc.af, usvc.fwmark);
+		svc = __ip_vs_svc_fwm_get(net, usvc.af, usvc.fwmark);

 	if (cmd != IP_VS_SO_SET_ADD
 	    && (svc == NULL || svc->protocol != usvc.protocol)) {
 		ret = -ESRCH;
-		goto out_drop_service;
+		goto out_unlock;
 	}

 	switch (cmd) {
@@ -2163,13 +2138,13 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		if (svc != NULL)
 			ret = -EEXIST;
 		else
-			ret = ip_vs_add_service(&usvc, &svc);
+			ret = ip_vs_add_service(net, &usvc, &svc);
 		break;
 	case IP_VS_SO_SET_EDIT:
 		ret = ip_vs_edit_service(svc, &usvc);
 		break;
 	case IP_VS_SO_SET_DEL:
-		ret = ip_vs_del_service(svc);
+		ret = ip_vs_del_service(net, svc);
 		if (!ret)
 			goto out_unlock;
 		break;
@@ -2177,19 +2152,18 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		ret = ip_vs_zero_service(svc);
 		break;
 	case IP_VS_SO_SET_ADDDEST:
-		ret = ip_vs_add_dest(svc, &udest);
+		ret = ip_vs_add_dest(net, svc, &udest);
 		break;
 	case IP_VS_SO_SET_EDITDEST:
-		ret = ip_vs_edit_dest(svc, &udest);
+		ret = ip_vs_edit_dest(net, svc, &udest);
 		break;
 	case IP_VS_SO_SET_DELDEST:
-		ret = ip_vs_del_dest(svc, &udest);
+		ret = ip_vs_del_dest(net, svc, &udest);
 		break;
 	default:
 		ret = -EINVAL;
 	}

-out_drop_service:
 	if (svc)
 		ip_vs_service_put(svc);

@@ -2207,7 +2181,7 @@ static void
 ip_vs_copy_stats(struct ip_vs_stats_user *dst, struct ip_vs_stats *src)
 {
 	spin_lock_bh(&src->lock);
-	memcpy(dst, &src->ustats, sizeof(*dst));
+	memcpy(dst, &src->ustats, sizeof(struct ip_vs_stats_user));
 	spin_unlock_bh(&src->lock);
 }

@@ -2227,16 +2201,17 @@ ip_vs_copy_service(struct ip_vs_service_entry *dst, struct ip_vs_service *src)
 }

 static inline int
-__ip_vs_get_service_entries(const struct ip_vs_get_services *get,
+__ip_vs_get_service_entries(struct net *net, const struct ip_vs_get_services *get,
 			    struct ip_vs_get_services __user *uptr)
 {
 	int idx, count=0;
 	struct ip_vs_service *svc;
 	struct ip_vs_service_entry entry;
+	struct netns_ipvs *ipvs = net->ipvs;
 	int ret = 0;

 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
+		list_for_each_entry(svc, &ipvs->ctl_svc_table[idx], s_list) {
 			/* Only expose IPv4 entries to old interface */
 			if (svc->af != AF_INET)
 				continue;
@@ -2255,7 +2230,7 @@ __ip_vs_get_service_entries(const struct ip_vs_get_services *get,
 	}

 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
+		list_for_each_entry(svc, &ipvs->ctl_fwm_table[idx], f_list) {
 			/* Only expose IPv4 entries to old interface */
 			if (svc->af != AF_INET)
 				continue;
@@ -2277,7 +2252,7 @@ __ip_vs_get_service_entries(const struct ip_vs_get_services *get,
 }

 static inline int
-__ip_vs_get_dest_entries(const struct ip_vs_get_dests *get,
+__ip_vs_get_dest_entries(struct net *net, const struct ip_vs_get_dests *get,
 			 struct ip_vs_get_dests __user *uptr)
 {
 	struct ip_vs_service *svc;
@@ -2285,9 +2260,9 @@ __ip_vs_get_dest_entries(const struct ip_vs_get_dests *get,
 	int ret = 0;

 	if (get->fwmark)
-		svc = __ip_vs_svc_fwm_get(AF_INET, get->fwmark);
+		svc = __ip_vs_svc_fwm_get(net, AF_INET, get->fwmark);
 	else
-		svc = __ip_vs_service_get(AF_INET, get->protocol, &addr,
+		svc = __ip_vs_service_get(net, AF_INET, get->protocol, &addr,
 					  get->port);

 	if (svc) {
@@ -2323,17 +2298,23 @@ __ip_vs_get_dest_entries(const struct ip_vs_get_dests *get,
 }

 static inline void
-__ip_vs_get_timeouts(struct ip_vs_timeout_user *u)
+__ip_vs_get_timeouts(struct net *net, struct ip_vs_timeout_user *u)
 {
+	struct ip_vs_proto_data *pd;
+
 #ifdef CONFIG_IP_VS_PROTO_TCP
-	u->tcp_timeout =
-		ip_vs_protocol_tcp.timeout_table[IP_VS_TCP_S_ESTABLISHED] / HZ;
-	u->tcp_fin_timeout =
-		ip_vs_protocol_tcp.timeout_table[IP_VS_TCP_S_FIN_WAIT] / HZ;
+	pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
+	if (pd) {
+		u->tcp_timeout=pd->timeout_table[IP_VS_TCP_S_ESTABLISHED] / HZ;
+		u->tcp_fin_timeout=pd->timeout_table[IP_VS_TCP_S_FIN_WAIT] / HZ;
+	} else {
+		u->tcp_timeout = 0;
+		u->tcp_fin_timeout = 0;
+	}
 #endif
 #ifdef CONFIG_IP_VS_PROTO_UDP
-	u->udp_timeout =
-		ip_vs_protocol_udp.timeout_table[IP_VS_UDP_S_NORMAL] / HZ;
+	pd = ip_vs_proto_data_get(net, IPPROTO_UDP);
+	u->udp_timeout = (pd ? pd->timeout_table[IP_VS_UDP_S_NORMAL] / HZ : 0);
 #endif
 }

@@ -2362,7 +2343,9 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	unsigned char arg[128];
 	int ret = 0;
 	unsigned int copylen;
+	struct net *net = sock_net(sk);

+	BUG_ON(!net);
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;

@@ -2424,7 +2407,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 			ret = -EINVAL;
 			goto out;
 		}
-		ret = __ip_vs_get_service_entries(get, user);
+		ret = __ip_vs_get_service_entries(net, get, user);
 	}
 	break;

@@ -2437,9 +2420,9 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 		entry = (struct ip_vs_service_entry *)arg;
 		addr.ip = entry->addr;
 		if (entry->fwmark)
-			svc = __ip_vs_svc_fwm_get(AF_INET, entry->fwmark);
+			svc = __ip_vs_svc_fwm_get(net, AF_INET, entry->fwmark);
 		else
-			svc = __ip_vs_service_get(AF_INET, entry->protocol,
+			svc = __ip_vs_service_get(net, AF_INET, entry->protocol,
 						  &addr, entry->port);
 		if (svc) {
 			ip_vs_copy_service(entry, svc);
@@ -2464,7 +2447,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 			ret = -EINVAL;
 			goto out;
 		}
-		ret = __ip_vs_get_dest_entries(get, user);
+		ret = __ip_vs_get_dest_entries(net, get, user);
 	}
 	break;

@@ -2472,7 +2455,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	{
 		struct ip_vs_timeout_user t;

-		__ip_vs_get_timeouts(&t);
+		__ip_vs_get_timeouts(net, &t);
 		if (copy_to_user(user, &t, sizeof(t)) != 0)
 			ret = -EFAULT;
 	}
@@ -2483,15 +2466,15 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 		struct ip_vs_daemon_user d[2];

 		memset(&d, 0, sizeof(d));
-		if (ip_vs_sync_state & IP_VS_STATE_MASTER) {
+		if (net->ipvs->sync_state & IP_VS_STATE_MASTER) {
 			d[0].state = IP_VS_STATE_MASTER;
-			strlcpy(d[0].mcast_ifn, ip_vs_master_mcast_ifn, sizeof(d[0].mcast_ifn));
-			d[0].syncid = ip_vs_master_syncid;
+			strlcpy(d[0].mcast_ifn, net->ipvs->master_mcast_ifn, sizeof(d[0].mcast_ifn));
+			d[0].syncid = net->ipvs->master_syncid;
 		}
-		if (ip_vs_sync_state & IP_VS_STATE_BACKUP) {
+		if (net->ipvs->sync_state & IP_VS_STATE_BACKUP) {
 			d[1].state = IP_VS_STATE_BACKUP;
-			strlcpy(d[1].mcast_ifn, ip_vs_backup_mcast_ifn, sizeof(d[1].mcast_ifn));
-			d[1].syncid = ip_vs_backup_syncid;
+			strlcpy(d[1].mcast_ifn, net->ipvs->backup_mcast_ifn, sizeof(d[1].mcast_ifn));
+			d[1].syncid = net->ipvs->backup_syncid;
 		}
 		if (copy_to_user(user, &d, sizeof(d)) != 0)
 			ret = -EFAULT;
@@ -2530,6 +2513,7 @@ static struct genl_family ip_vs_genl_family = {
 	.name		= IPVS_GENL_NAME,
 	.version	= IPVS_GENL_VERSION,
 	.maxattr	= IPVS_CMD_MAX,
+	.netnsok 	= true,		/* Make ipvsadm to work on netns */
 };

 /* Policy used for first-level command attributes */
@@ -2680,10 +2664,15 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 	int idx = 0, i;
 	int start = cb->args[0];
 	struct ip_vs_service *svc;
-
+	struct net *net = skb->sk->sk_net;
+	struct netns_ipvs *ipvs;
+	if (!net)
+		net = dev_net(skb->dev);
+	BUG_ON(!net);
+	ipvs = net->ipvs;
 	mutex_lock(&__ip_vs_mutex);
 	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
-		list_for_each_entry(svc, &ip_vs_svc_table[i], s_list) {
+		list_for_each_entry(svc, &ipvs->ctl_svc_table[i], s_list) {
 			if (++idx <= start)
 				continue;
 			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
@@ -2694,7 +2683,7 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 	}

 	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
-		list_for_each_entry(svc, &ip_vs_svc_fwm_table[i], f_list) {
+		list_for_each_entry(svc, &net->ipvs->ctl_fwm_table[i], f_list) {
 			if (++idx <= start)
 				continue;
 			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
@@ -2711,7 +2700,7 @@ nla_put_failure:
 	return skb->len;
 }

-static int ip_vs_genl_parse_service(struct ip_vs_service_user_kern *usvc,
+static int ip_vs_genl_parse_service(struct net *net, struct ip_vs_service_user_kern *usvc,
 				    struct nlattr *nla, int full_entry)
 {
 	struct nlattr *attrs[IPVS_SVC_ATTR_MAX + 1];
@@ -2770,9 +2759,9 @@ static int ip_vs_genl_parse_service(struct ip_vs_service_user_kern *usvc,

 		/* prefill flags from service if it already exists */
 		if (usvc->fwmark)
-			svc = __ip_vs_svc_fwm_get(usvc->af, usvc->fwmark);
+			svc = __ip_vs_svc_fwm_get(net, usvc->af, usvc->fwmark);
 		else
-			svc = __ip_vs_service_get(usvc->af, usvc->protocol,
+			svc = __ip_vs_service_get(net, usvc->af, usvc->protocol,
 						  &usvc->addr, usvc->port);
 		if (svc) {
 			usvc->flags = svc->flags;
@@ -2791,19 +2780,19 @@ static int ip_vs_genl_parse_service(struct ip_vs_service_user_kern *usvc,
 	return 0;
 }

-static struct ip_vs_service *ip_vs_genl_find_service(struct nlattr *nla)
+static struct ip_vs_service *ip_vs_genl_find_service(struct net *net, struct nlattr *nla)
 {
 	struct ip_vs_service_user_kern usvc;
 	int ret;

-	ret = ip_vs_genl_parse_service(&usvc, nla, 0);
+	ret = ip_vs_genl_parse_service(net, &usvc, nla, 0);
 	if (ret)
 		return ERR_PTR(ret);

 	if (usvc.fwmark)
-		return __ip_vs_svc_fwm_get(usvc.af, usvc.fwmark);
+		return __ip_vs_svc_fwm_get(net, usvc.af, usvc.fwmark);
 	else
-		return __ip_vs_service_get(usvc.af, usvc.protocol,
+		return __ip_vs_service_get(net, usvc.af, usvc.protocol,
 					   &usvc.addr, usvc.port);
 }

@@ -2871,7 +2860,11 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 	struct ip_vs_service *svc;
 	struct ip_vs_dest *dest;
 	struct nlattr *attrs[IPVS_CMD_ATTR_MAX + 1];
+	struct net *net = skb->sk->sk_net;

+	if (!net)
+		net = dev_net(skb->dev);
+	BUG_ON(!net);
 	mutex_lock(&__ip_vs_mutex);

 	/* Try to find the service for which to dump destinations */
@@ -2879,7 +2872,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 			IPVS_CMD_ATTR_MAX, ip_vs_cmd_policy))
 		goto out_err;

-	svc = ip_vs_genl_find_service(attrs[IPVS_CMD_ATTR_SERVICE]);
+	svc = ip_vs_genl_find_service(net, attrs[IPVS_CMD_ATTR_SERVICE]);
 	if (IS_ERR(svc) || svc == NULL)
 		goto out_err;

@@ -2994,20 +2987,23 @@ nla_put_failure:
 static int ip_vs_genl_dump_daemons(struct sk_buff *skb,
 				   struct netlink_callback *cb)
 {
+	struct net *net = sock_net(skb->sk);
+
+	BUG_ON(!net);
 	mutex_lock(&__ip_vs_mutex);
-	if ((ip_vs_sync_state & IP_VS_STATE_MASTER) && !cb->args[0]) {
+	if ((net->ipvs->sync_state & IP_VS_STATE_MASTER) && !cb->args[0]) {
 		if (ip_vs_genl_dump_daemon(skb, IP_VS_STATE_MASTER,
-					   ip_vs_master_mcast_ifn,
-					   ip_vs_master_syncid, cb) < 0)
+					   net->ipvs->master_mcast_ifn,
+					   net->ipvs->master_syncid, cb) < 0)
 			goto nla_put_failure;

 		cb->args[0] = 1;
 	}

-	if ((ip_vs_sync_state & IP_VS_STATE_BACKUP) && !cb->args[1]) {
+	if ((net->ipvs->sync_state & IP_VS_STATE_BACKUP) && !cb->args[1]) {
 		if (ip_vs_genl_dump_daemon(skb, IP_VS_STATE_BACKUP,
-					   ip_vs_backup_mcast_ifn,
-					   ip_vs_backup_syncid, cb) < 0)
+					   net->ipvs->backup_mcast_ifn,
+					   net->ipvs->backup_syncid, cb) < 0)
 			goto nla_put_failure;

 		cb->args[1] = 1;
@@ -3019,31 +3015,33 @@ nla_put_failure:
 	return skb->len;
 }

-static int ip_vs_genl_new_daemon(struct nlattr **attrs)
+static int ip_vs_genl_new_daemon(struct net *net, struct nlattr **attrs)
 {
 	if (!(attrs[IPVS_DAEMON_ATTR_STATE] &&
 	      attrs[IPVS_DAEMON_ATTR_MCAST_IFN] &&
 	      attrs[IPVS_DAEMON_ATTR_SYNC_ID]))
 		return -EINVAL;

-	return start_sync_thread(nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]),
+	return start_sync_thread(net,
+				 nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]),
 				 nla_data(attrs[IPVS_DAEMON_ATTR_MCAST_IFN]),
 				 nla_get_u32(attrs[IPVS_DAEMON_ATTR_SYNC_ID]));
 }

-static int ip_vs_genl_del_daemon(struct nlattr **attrs)
+static int ip_vs_genl_del_daemon(struct net *net, struct nlattr **attrs)
 {
 	if (!attrs[IPVS_DAEMON_ATTR_STATE])
 		return -EINVAL;

-	return stop_sync_thread(nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]));
+	return stop_sync_thread(net,
+				nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]));
 }

-static int ip_vs_genl_set_config(struct nlattr **attrs)
+static int ip_vs_genl_set_config(struct net *net, struct nlattr **attrs)
 {
 	struct ip_vs_timeout_user t;

-	__ip_vs_get_timeouts(&t);
+	__ip_vs_get_timeouts(net, &t);

 	if (attrs[IPVS_CMD_ATTR_TIMEOUT_TCP])
 		t.tcp_timeout = nla_get_u32(attrs[IPVS_CMD_ATTR_TIMEOUT_TCP]);
@@ -3055,7 +3053,7 @@ static int ip_vs_genl_set_config(struct nlattr **attrs)
 	if (attrs[IPVS_CMD_ATTR_TIMEOUT_UDP])
 		t.udp_timeout = nla_get_u32(attrs[IPVS_CMD_ATTR_TIMEOUT_UDP]);

-	return ip_vs_set_timeout(&t);
+	return ip_vs_set_timeout(net, &t);
 }

 static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
@@ -3065,16 +3063,20 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 	struct ip_vs_dest_user_kern udest;
 	int ret = 0, cmd;
 	int need_full_svc = 0, need_full_dest = 0;
+	struct net *net = skb->sk->sk_net;

+	if (!net)
+		net = dev_net(skb->dev);
+	BUG_ON(!net);
 	cmd = info->genlhdr->cmd;

 	mutex_lock(&__ip_vs_mutex);

 	if (cmd == IPVS_CMD_FLUSH) {
-		ret = ip_vs_flush();
+		ret = ip_vs_flush(net);
 		goto out;
 	} else if (cmd == IPVS_CMD_SET_CONFIG) {
-		ret = ip_vs_genl_set_config(info->attrs);
+		ret = ip_vs_genl_set_config(net, info->attrs);
 		goto out;
 	} else if (cmd == IPVS_CMD_NEW_DAEMON ||
 		   cmd == IPVS_CMD_DEL_DAEMON) {
@@ -3090,13 +3092,13 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 		}

 		if (cmd == IPVS_CMD_NEW_DAEMON)
-			ret = ip_vs_genl_new_daemon(daemon_attrs);
+			ret = ip_vs_genl_new_daemon(net, daemon_attrs);
 		else
-			ret = ip_vs_genl_del_daemon(daemon_attrs);
+			ret = ip_vs_genl_del_daemon(net, daemon_attrs);
 		goto out;
 	} else if (cmd == IPVS_CMD_ZERO &&
 		   !info->attrs[IPVS_CMD_ATTR_SERVICE]) {
-		ret = ip_vs_zero_all();
+		ret = ip_vs_zero_all(net);
 		goto out;
 	}

@@ -3106,7 +3108,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 	if (cmd == IPVS_CMD_NEW_SERVICE || cmd == IPVS_CMD_SET_SERVICE)
 		need_full_svc = 1;

-	ret = ip_vs_genl_parse_service(&usvc,
+	ret = ip_vs_genl_parse_service(net, &usvc,
 				       info->attrs[IPVS_CMD_ATTR_SERVICE],
 				       need_full_svc);
 	if (ret)
@@ -3114,10 +3116,10 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)

 	/* Lookup the exact service by <protocol, addr, port> or fwmark */
 	if (usvc.fwmark == 0)
-		svc = __ip_vs_service_get(usvc.af, usvc.protocol,
+		svc = __ip_vs_service_get(net, usvc.af, usvc.protocol,
 					  &usvc.addr, usvc.port);
 	else
-		svc = __ip_vs_svc_fwm_get(usvc.af, usvc.fwmark);
+		svc = __ip_vs_svc_fwm_get(net, usvc.af, usvc.fwmark);

 	/* Unless we're adding a new service, the service must already exist */
 	if ((cmd != IPVS_CMD_NEW_SERVICE) && (svc == NULL)) {
@@ -3143,7 +3145,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 	switch (cmd) {
 	case IPVS_CMD_NEW_SERVICE:
 		if (svc == NULL)
-			ret = ip_vs_add_service(&usvc, &svc);
+			ret = ip_vs_add_service(net, &usvc, &svc);
 		else
 			ret = -EEXIST;
 		break;
@@ -3151,16 +3153,16 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 		ret = ip_vs_edit_service(svc, &usvc);
 		break;
 	case IPVS_CMD_DEL_SERVICE:
-		ret = ip_vs_del_service(svc);
+		ret = ip_vs_del_service(net, svc);
 		break;
 	case IPVS_CMD_NEW_DEST:
-		ret = ip_vs_add_dest(svc, &udest);
+		ret = ip_vs_add_dest(net, svc, &udest);
 		break;
 	case IPVS_CMD_SET_DEST:
-		ret = ip_vs_edit_dest(svc, &udest);
+		ret = ip_vs_edit_dest(net, svc, &udest);
 		break;
 	case IPVS_CMD_DEL_DEST:
-		ret = ip_vs_del_dest(svc, &udest);
+		ret = ip_vs_del_dest(net, svc, &udest);
 		break;
 	case IPVS_CMD_ZERO:
 		ret = ip_vs_zero_service(svc);
@@ -3182,7 +3184,11 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	struct sk_buff *msg;
 	void *reply;
 	int ret, cmd, reply_cmd;
+	struct net *net = skb->sk->sk_net;

+	if (unlikely(!net))
+		net = dev_net(skb->dev);
+	BUG_ON(!net);
 	cmd = info->genlhdr->cmd;

 	if (cmd == IPVS_CMD_GET_SERVICE)
@@ -3211,7 +3217,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	{
 		struct ip_vs_service *svc;

-		svc = ip_vs_genl_find_service(info->attrs[IPVS_CMD_ATTR_SERVICE]);
+		svc = ip_vs_genl_find_service(net, info->attrs[IPVS_CMD_ATTR_SERVICE]);
 		if (IS_ERR(svc)) {
 			ret = PTR_ERR(svc);
 			goto out_err;
@@ -3232,7 +3238,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	{
 		struct ip_vs_timeout_user t;

-		__ip_vs_get_timeouts(&t);
+		__ip_vs_get_timeouts(net, &t);
 #ifdef CONFIG_IP_VS_PROTO_TCP
 		NLA_PUT_U32(msg, IPVS_CMD_ATTR_TIMEOUT_TCP, t.tcp_timeout);
 		NLA_PUT_U32(msg, IPVS_CMD_ATTR_TIMEOUT_TCP_FIN,
@@ -3377,62 +3383,131 @@ static void ip_vs_genl_unregister(void)
 }

 /* End of Generic Netlink interface definitions */
+/*
+ * per netns intit/exit func.
+ */
+int /*__net_init*/ __ip_vs_control_init(struct net *net)
+{
+	int idx;
+	struct netns_ipvs *ipvs = net->ipvs;
+	struct ctl_table *tbl;
+
+	ipvs->ctl_stats=kzalloc(sizeof(struct ip_vs_stats), GFP_KERNEL);
+	if (ipvs->ctl_stats == NULL) {
+		pr_err("%s(): no memory.\n", __func__);
+		return -ENOMEM;
+	}
+
+	proc_net_fops_create(net, "ip_vs", 0, &ip_vs_info_fops);
+	proc_net_fops_create(net, "ip_vs_stats",0, &ip_vs_stats_fops);
+	if (net != &init_net) {
+		tbl = kmemdup(vs_vars, sizeof(vs_vars), GFP_KERNEL);
+		if (tbl == NULL)
+			goto err_dup;
+	} else
+		tbl = vs_vars;
+	/* Initialize sysctl defaults */
+	idx = 0;
+	ipvs->sysctl_amemthresh = 1024;
+	tbl[idx++].data = &ipvs->sysctl_amemthresh;
+	ipvs->sysctl_am_droprate = 10;
+	tbl[idx++].data = &ipvs->sysctl_am_droprate;
+	ipvs->sysctl_drop_entry = 0;
+	tbl[idx++].data = &ipvs->sysctl_drop_entry;
+	ipvs->sysctl_drop_packet = 0;
+	tbl[idx++].data = &ipvs->sysctl_drop_packet;
+	ipvs->sysctl_secure_tcp = 0;
+	tbl[idx++].data = &ipvs->sysctl_secure_tcp;
+	ipvs->sysctl_cache_bypass = 0;
+	tbl[idx++].data = &ipvs->sysctl_cache_bypass;
+	ipvs->sysctl_expire_nodest_conn = 0;
+	tbl[idx++].data = &ipvs->sysctl_expire_nodest_conn;
+	ipvs->sysctl_expire_quiescent_template = 0;
+	tbl[idx++].data = &ipvs->sysctl_expire_quiescent_template;
+	ipvs->sysctl_sync_threshold[0] = 3;
+	ipvs->sysctl_sync_threshold[1] = 50;
+	tbl[idx].data = &ipvs->sysctl_sync_threshold;
+	tbl[idx++].maxlen = sizeof(ipvs->sysctl_sync_threshold);
+	ipvs->sysctl_nat_icmp_send = 0;
+	tbl[idx++].data = &ipvs->sysctl_nat_icmp_send;
+
+	ipvs->sysctl_hdr = register_net_sysctl_table(net, net_vs_ctl_path, tbl);
+	if (ipvs->sysctl_hdr == NULL)
+			goto err_reg;
+	ipvs->sysctl_tbl = tbl;
+	/* Initialize net->ipvs->ctl_svc_table, net->ipvs->ctl_fwm_table, net->ipvs->ctl_rtable */
+	spin_lock_init(&ipvs->ctl_stats->lock);
+
+	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++)  {
+		INIT_LIST_HEAD(&ipvs->ctl_svc_table[idx]);
+		INIT_LIST_HEAD(&ipvs->ctl_fwm_table[idx]);
+	}
+
+	for (idx = 0; idx < IP_VS_RTAB_SIZE; idx++)  {
+		INIT_LIST_HEAD(&ipvs->ctl_rtable[idx]);
+	}
+	INIT_LIST_HEAD(&ipvs->ctl_dest_trash);
+	atomic_set(&ipvs->ctl_ftpsvc_counter, 0);
+	atomic_set(&ipvs->ctl_nullsvc_counter, 0);
+	ip_vs_new_estimator(net, ipvs->ctl_stats);
+	return 0;
+
+err_reg:
+	if (net != &init_net)
+		kfree(tbl);
+err_dup:
+	kfree(ipvs->ctl_stats);
+	return -ENOMEM;
+}
+
+static void __net_exit __ip_vs_control_cleanup(struct net *net)
+{
+	ip_vs_kill_estimator(net, net->ipvs->ctl_stats);
+	unregister_sysctl_table(net->ipvs->sysctl_hdr);
+	proc_net_remove(net, "ip_vs_stats");
+	proc_net_remove(net, "ip_vs");
+	ip_vs_trash_cleanup(net);
+	cancel_rearming_delayed_work(&defense_work);
+	cancel_work_sync(&defense_work.work);
+	kfree(net->ipvs->ctl_stats);
+	if ( net != &init_net )
+		kfree(net->ipvs->sysctl_tbl);
+}
+
+static struct pernet_operations ipvs_control_ops = {
+	.init = __ip_vs_control_init,
+	.exit = __ip_vs_control_cleanup,
+};


 int __init ip_vs_control_init(void)
 {
 	int ret;
-	int idx;

 	EnterFunction(2);
-
 	ret = nf_register_sockopt(&ip_vs_sockopts);
 	if (ret) {
 		pr_err("cannot register sockopt.\n");
 		return ret;
 	}
-
 	ret = ip_vs_genl_register();
 	if (ret) {
 		pr_err("cannot register Generic Netlink interface.\n");
 		nf_unregister_sockopt(&ip_vs_sockopts);
 		return ret;
 	}
-
-	proc_net_fops_create(&init_net, "ip_vs", 0, &ip_vs_info_fops);
-	proc_net_fops_create(&init_net, "ip_vs_stats",0, &ip_vs_stats_fops);
-
-	sysctl_header = register_sysctl_paths(net_vs_ctl_path, vs_vars);
-
-	/* Initialize ip_vs_svc_table, ip_vs_svc_fwm_table, ip_vs_rtable */
-	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++)  {
-		INIT_LIST_HEAD(&ip_vs_svc_table[idx]);
-		INIT_LIST_HEAD(&ip_vs_svc_fwm_table[idx]);
-	}
-	for(idx = 0; idx < IP_VS_RTAB_SIZE; idx++)  {
-		INIT_LIST_HEAD(&ip_vs_rtable[idx]);
-	}
-
-	ip_vs_new_estimator(&ip_vs_stats);
-
+	ret = register_pernet_subsys(&ipvs_control_ops);
 	/* Hook the defense timer */
 	schedule_delayed_work(&defense_work, DEFENSE_TIMER_PERIOD);
