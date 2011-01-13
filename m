From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 02/22] IPVS: netns to services part 1
Date: Thu, 13 Jan 2011 10:52:48 +0900
Message-ID: <1294883588-5683-3-git-send-email-horms@verge.net.au>
References: <1294883588-5683-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1294883588-5683-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

Services hash tables got netns ptr a hash arg,
While Real Servers (rs) has been moved to ipvs struct.
Two new inline functions added to get net ptr from skb.

Since ip_vs is called from different contexts there is two
places to dig for the net ptr skb->dev or skb->sk
this is handled in skb_net() and skb_sknet()

Global functions, ip_vs_service_get() ip_vs_lookup_real_service()
etc have got  struct net *net as first param.
If possible get net ptr skb etc,
 - if not &init_net is used at this early stage of patching.

ip_vs_ctl.c  procfs not ready for netns yet.

*v3
 Comments by Julian
- __ip_vs_service_find and __ip_vs_svc_fwm_find are fast path,
  net_eq(svc->net, net) so the check is at the end now.
- net = skb_net(skb) in ip_vs_out moved after check for skb_dst.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h                   |   64 +++++++++-
 include/net/netns/ip_vs.h             |    8 +
 net/netfilter/ipvs/ip_vs_conn.c       |    2 +-
 net/netfilter/ipvs/ip_vs_core.c       |    4 +-
 net/netfilter/ipvs/ip_vs_ctl.c        |  232 +++++++++++++++++++--------------
 net/netfilter/ipvs/ip_vs_proto_sctp.c |    5 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |    7 +-
 net/netfilter/ipvs/ip_vs_proto_udp.c  |    5 +-
 net/netfilter/ipvs/ip_vs_sync.c       |    2 +-
 9 files changed, 214 insertions(+), 115 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index c1c2ece..d551e0d 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -37,6 +37,59 @@ static inline struct netns_ipvs *net_ipvs(struct net* net)
 {
 	return net->ipvs;
 }
+/*
+ * Get net ptr from skb in traffic cases
+ * use skb_sknet when call is from userland (ioctl or netlink)
+ */
+static inline struct net *skb_net(struct sk_buff *skb)
+{
+#ifdef CONFIG_NET_NS
+#ifdef CONFIG_IP_VS_DEBUG
+	/*
+	 * This is used for debug only.
+	 * Start with the most likely hit
+	 * End with BUG
+	 */
+	if (likely(skb->dev && skb->dev->nd_net))
+		return dev_net(skb->dev);
+	if (skb_dst(skb)->dev)
+		return dev_net(skb_dst(skb)->dev);
+	WARN(skb->sk, "Maybe skb_sknet should be used in %s() at line:%d\n",
+		      __func__, __LINE__);
+	if (likely(skb->sk && skb->sk->sk_net))
+		return sock_net(skb->sk);
+	pr_err("There is no net ptr to find in the skb in %s() line:%d\n",
+		__func__, __LINE__);
+	BUG();
+#else
+	return dev_net(skb->dev ? : skb_dst(skb)->dev);
+#endif
+#else
+	return &init_net;
+#endif
+}
+
+static inline struct net *skb_sknet(struct sk_buff *skb)
+{
+#ifdef CONFIG_NET_NS
+#ifdef CONFIG_IP_VS_DEBUG
+	/* Start with the most likely hit */
+	if (likely(skb->sk && skb->sk->sk_net))
+		return sock_net(skb->sk);
+	WARN(skb->dev, "Maybe skb_net should be used instead in %s() line:%d\n",
+		       __func__, __LINE__);
+	if (likely(skb->dev && skb->dev->nd_net))
+		return dev_net(skb->dev);
+	pr_err("There is no net ptr to find in the skb in %s() line:%d\n",
+		__func__, __LINE__);
+	BUG();
+#else
+	return sock_net(skb->sk);
+#endif
+#else
+	return &init_net;
+#endif
+}
 
 /* Connections' size value needed by ip_vs_ctl.c */
 extern int ip_vs_conn_tab_size;
@@ -496,6 +549,7 @@ struct ip_vs_service {
 	unsigned		flags;	  /* service status flags */
 	unsigned		timeout;  /* persistent timeout in ticks */
 	__be32			netmask;  /* grouping granularity */
+	struct net		*net;
 
 	struct list_head	destinations;  /* real server d-linked list */
 	__u32			num_dests;     /* number of servers */
@@ -896,7 +950,7 @@ extern int sysctl_ip_vs_sync_ver;
 
 extern void ip_vs_sync_switch_mode(int mode);
 extern struct ip_vs_service *
-ip_vs_service_get(int af, __u32 fwmark, __u16 protocol,
+ip_vs_service_get(struct net *net, int af, __u32 fwmark, __u16 protocol,
 		  const union nf_inet_addr *vaddr, __be16 vport);
 
 static inline void ip_vs_service_put(struct ip_vs_service *svc)
@@ -905,7 +959,7 @@ static inline void ip_vs_service_put(struct ip_vs_service *svc)
 }
 
 extern struct ip_vs_dest *
-ip_vs_lookup_real_service(int af, __u16 protocol,
+ip_vs_lookup_real_service(struct net *net, int af, __u16 protocol,
 			  const union nf_inet_addr *daddr, __be16 dport);
 
 extern int ip_vs_use_count_inc(void);
@@ -913,9 +967,9 @@ extern void ip_vs_use_count_dec(void);
 extern int ip_vs_control_init(void);
 extern void ip_vs_control_cleanup(void);
 extern struct ip_vs_dest *
-ip_vs_find_dest(int af, const union nf_inet_addr *daddr, __be16 dport,
-		const union nf_inet_addr *vaddr, __be16 vport, __u16 protocol,
-		__u32 fwmark);
+ip_vs_find_dest(struct net *net, int af, const union nf_inet_addr *daddr,
+		__be16 dport, const union nf_inet_addr *vaddr, __be16 vport,
+		__u16 protocol, __u32 fwmark);
 extern struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp);
 
 
diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
index 12fe840..5b87d22 100644
--- a/include/net/netns/ip_vs.h
+++ b/include/net/netns/ip_vs.h
@@ -20,6 +20,14 @@ struct ctl_table_header;
 
 struct netns_ipvs {
 	int			gen;		/* Generation */
+	/*
+	 *	Hash table: for real service lookups
+	 */
+	#define IP_VS_RTAB_BITS 4
+	#define IP_VS_RTAB_SIZE (1 << IP_VS_RTAB_BITS)
+	#define IP_VS_RTAB_MASK (IP_VS_RTAB_SIZE - 1)
+
+	struct list_head	rs_table[IP_VS_RTAB_SIZE];
 };
 
 #endif /* IP_VS_H_ */
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 7c1b502..7a0e79e 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -611,7 +611,7 @@ struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp)
 	struct ip_vs_dest *dest;
 
 	if ((cp) && (!cp->dest)) {
-		dest = ip_vs_find_dest(cp->af, &cp->daddr, cp->dport,
+		dest = ip_vs_find_dest(&init_net, cp->af, &cp->daddr, cp->dport,
 				       &cp->vaddr, cp->vport,
 				       cp->protocol, cp->fwmark);
 		ip_vs_bind_dest(cp, dest);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 206f40c..d0616ea 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1031,6 +1031,7 @@ drop:
 static unsigned int
 ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 {
+	struct net *net = NULL;
 	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_conn *cp;
@@ -1054,6 +1055,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (unlikely(!skb_dst(skb)))
 		return NF_ACCEPT;
 
+	net = skb_net(skb);
 	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
@@ -1119,7 +1121,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 					  sizeof(_ports), _ports);
 		if (pptr == NULL)
 			return NF_ACCEPT;	/* Not for me */
-		if (ip_vs_lookup_real_service(af, iph.protocol,
+		if (ip_vs_lookup_real_service(net, af, iph.protocol,
 					      &iph.saddr,
 					      pptr[0])) {
 			/*
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index ceeef43..2d7c96b 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -288,15 +288,6 @@ static struct list_head ip_vs_svc_table[IP_VS_SVC_TAB_SIZE];
 static struct list_head ip_vs_svc_fwm_table[IP_VS_SVC_TAB_SIZE];
 
 /*
- *	Hash table: for real service lookups
- */
-#define IP_VS_RTAB_BITS 4
-#define IP_VS_RTAB_SIZE (1 << IP_VS_RTAB_BITS)
-#define IP_VS_RTAB_MASK (IP_VS_RTAB_SIZE - 1)
-
-static struct list_head ip_vs_rtable[IP_VS_RTAB_SIZE];
-
-/*
  *	Trash for destinations
  */
 static LIST_HEAD(ip_vs_dest_trash);
@@ -311,9 +302,9 @@ static atomic_t ip_vs_nullsvc_counter = ATOMIC_INIT(0);
 /*
  *	Returns hash value for virtual service
  */
-static __inline__ unsigned
-ip_vs_svc_hashkey(int af, unsigned proto, const union nf_inet_addr *addr,
-		  __be16 port)
+static inline unsigned
+ip_vs_svc_hashkey(struct net *net, int af, unsigned proto,
+		  const union nf_inet_addr *addr, __be16 port)
 {
 	register unsigned porth = ntohs(port);
 	__be32 addr_fold = addr->ip;
@@ -323,6 +314,7 @@ ip_vs_svc_hashkey(int af, unsigned proto, const union nf_inet_addr *addr,
 		addr_fold = addr->ip6[0]^addr->ip6[1]^
 			    addr->ip6[2]^addr->ip6[3];
 #endif
+	addr_fold ^= ((size_t)net>>8);
 
 	return (proto^ntohl(addr_fold)^(porth>>IP_VS_SVC_TAB_BITS)^porth)
 		& IP_VS_SVC_TAB_MASK;
@@ -331,13 +323,13 @@ ip_vs_svc_hashkey(int af, unsigned proto, const union nf_inet_addr *addr,
 /*
  *	Returns hash value of fwmark for virtual service lookup
  */
-static __inline__ unsigned ip_vs_svc_fwm_hashkey(__u32 fwmark)
+static inline unsigned ip_vs_svc_fwm_hashkey(struct net *net, __u32 fwmark)
 {
-	return fwmark & IP_VS_SVC_TAB_MASK;
+	return (((size_t)net>>8) ^ fwmark) & IP_VS_SVC_TAB_MASK;
 }
 
 /*
- *	Hashes a service in the ip_vs_svc_table by <proto,addr,port>
+ *	Hashes a service in the ip_vs_svc_table by <netns,proto,addr,port>
  *	or in the ip_vs_svc_fwm_table by fwmark.
  *	Should be called with locked tables.
  */
@@ -353,16 +345,16 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
 
 	if (svc->fwmark == 0) {
 		/*
-		 *  Hash it by <protocol,addr,port> in ip_vs_svc_table
+		 *  Hash it by <netns,protocol,addr,port> in ip_vs_svc_table
 		 */
-		hash = ip_vs_svc_hashkey(svc->af, svc->protocol, &svc->addr,
-					 svc->port);
+		hash = ip_vs_svc_hashkey(svc->net, svc->af, svc->protocol,
+					 &svc->addr, svc->port);
 		list_add(&svc->s_list, &ip_vs_svc_table[hash]);
 	} else {
 		/*
-		 *  Hash it by fwmark in ip_vs_svc_fwm_table
+		 *  Hash it by fwmark in svc_fwm_table
 		 */
-		hash = ip_vs_svc_fwm_hashkey(svc->fwmark);
+		hash = ip_vs_svc_fwm_hashkey(svc->net, svc->fwmark);
 		list_add(&svc->f_list, &ip_vs_svc_fwm_table[hash]);
 	}
 
@@ -374,7 +366,7 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
 
 
 /*
- *	Unhashes a service from ip_vs_svc_table/ip_vs_svc_fwm_table.
+ *	Unhashes a service from svc_table / svc_fwm_table.
  *	Should be called with locked tables.
  */
 static int ip_vs_svc_unhash(struct ip_vs_service *svc)
@@ -386,10 +378,10 @@ static int ip_vs_svc_unhash(struct ip_vs_service *svc)
 	}
 
 	if (svc->fwmark == 0) {
-		/* Remove it from the ip_vs_svc_table table */
+		/* Remove it from the svc_table table */
 		list_del(&svc->s_list);
 	} else {
-		/* Remove it from the ip_vs_svc_fwm_table table */
+		/* Remove it from the svc_fwm_table table */
 		list_del(&svc->f_list);
 	}
 
@@ -400,23 +392,24 @@ static int ip_vs_svc_unhash(struct ip_vs_service *svc)
 
 
 /*
- *	Get service by {proto,addr,port} in the service table.
+ *	Get service by {netns, proto,addr,port} in the service table.
  */
 static inline struct ip_vs_service *
-__ip_vs_service_find(int af, __u16 protocol, const union nf_inet_addr *vaddr,
-		    __be16 vport)
+__ip_vs_service_find(struct net *net, int af, __u16 protocol,
+		     const union nf_inet_addr *vaddr, __be16 vport)
 {
 	unsigned hash;
 	struct ip_vs_service *svc;
 
 	/* Check for "full" addressed entries */
-	hash = ip_vs_svc_hashkey(af, protocol, vaddr, vport);
+	hash = ip_vs_svc_hashkey(net, af, protocol, vaddr, vport);
 
 	list_for_each_entry(svc, &ip_vs_svc_table[hash], s_list){
 		if ((svc->af == af)
 		    && ip_vs_addr_equal(af, &svc->addr, vaddr)
 		    && (svc->port == vport)
-		    && (svc->protocol == protocol)) {
+		    && (svc->protocol == protocol)
+		    && net_eq(svc->net, net)) {
 			/* HIT */
 			return svc;
 		}
@@ -430,16 +423,17 @@ __ip_vs_service_find(int af, __u16 protocol, const union nf_inet_addr *vaddr,
  *	Get service by {fwmark} in the service table.
  */
 static inline struct ip_vs_service *
-__ip_vs_svc_fwm_find(int af, __u32 fwmark)
+__ip_vs_svc_fwm_find(struct net *net, int af, __u32 fwmark)
 {
 	unsigned hash;
 	struct ip_vs_service *svc;
 
 	/* Check for fwmark addressed entries */
-	hash = ip_vs_svc_fwm_hashkey(fwmark);
+	hash = ip_vs_svc_fwm_hashkey(net, fwmark);
 
 	list_for_each_entry(svc, &ip_vs_svc_fwm_table[hash], f_list) {
-		if (svc->fwmark == fwmark && svc->af == af) {
+		if (svc->fwmark == fwmark && svc->af == af
+		    && net_eq(svc->net, net)) {
 			/* HIT */
 			return svc;
 		}
@@ -449,7 +443,7 @@ __ip_vs_svc_fwm_find(int af, __u32 fwmark)
 }
 
 struct ip_vs_service *
-ip_vs_service_get(int af, __u32 fwmark, __u16 protocol,
+ip_vs_service_get(struct net *net, int af, __u32 fwmark, __u16 protocol,
 		  const union nf_inet_addr *vaddr, __be16 vport)
 {
 	struct ip_vs_service *svc;
@@ -459,14 +453,15 @@ ip_vs_service_get(int af, __u32 fwmark, __u16 protocol,
 	/*
 	 *	Check the table hashed by fwmark first
 	 */
-	if (fwmark && (svc = __ip_vs_svc_fwm_find(af, fwmark)))
+	svc = __ip_vs_svc_fwm_find(net, af, fwmark);
+	if (fwmark && svc)
 		goto out;
 
 	/*
 	 *	Check the table hashed by <protocol,addr,port>
 	 *	for "full" addressed entries
 	 */
-	svc = __ip_vs_service_find(af, protocol, vaddr, vport);
+	svc = __ip_vs_service_find(net, af, protocol, vaddr, vport);
 
 	if (svc == NULL
 	    && protocol == IPPROTO_TCP
@@ -476,7 +471,7 @@ ip_vs_service_get(int af, __u32 fwmark, __u16 protocol,
 		 * Check if ftp service entry exists, the packet
 		 * might belong to FTP data connections.
 		 */
-		svc = __ip_vs_service_find(af, protocol, vaddr, FTPPORT);
+		svc = __ip_vs_service_find(net, af, protocol, vaddr, FTPPORT);
 	}
 
 	if (svc == NULL
@@ -484,7 +479,7 @@ ip_vs_service_get(int af, __u32 fwmark, __u16 protocol,
 		/*
 		 * Check if the catch-all port (port zero) exists
 		 */
-		svc = __ip_vs_service_find(af, protocol, vaddr, 0);
+		svc = __ip_vs_service_find(net, af, protocol, vaddr, 0);
 	}
 
   out:
@@ -545,10 +540,10 @@ static inline unsigned ip_vs_rs_hashkey(int af,
 }
 
 /*
- *	Hashes ip_vs_dest in ip_vs_rtable by <proto,addr,port>.
+ *	Hashes ip_vs_dest in rs_table by <proto,addr,port>.
  *	should be called with locked tables.
  */
-static int ip_vs_rs_hash(struct ip_vs_dest *dest)
+static int ip_vs_rs_hash(struct netns_ipvs *ipvs, struct ip_vs_dest *dest)
 {
 	unsigned hash;
 
@@ -562,19 +557,19 @@ static int ip_vs_rs_hash(struct ip_vs_dest *dest)
 	 */
 	hash = ip_vs_rs_hashkey(dest->af, &dest->addr, dest->port);
 
-	list_add(&dest->d_list, &ip_vs_rtable[hash]);
+	list_add(&dest->d_list, &ipvs->rs_table[hash]);
 
 	return 1;
 }
 
 /*
- *	UNhashes ip_vs_dest from ip_vs_rtable.
+ *	UNhashes ip_vs_dest from rs_table.
  *	should be called with locked tables.
  */
 static int ip_vs_rs_unhash(struct ip_vs_dest *dest)
 {
 	/*
-	 * Remove it from the ip_vs_rtable table.
+	 * Remove it from the rs_table table.
 	 */
 	if (!list_empty(&dest->d_list)) {
 		list_del(&dest->d_list);
@@ -588,10 +583,11 @@ static int ip_vs_rs_unhash(struct ip_vs_dest *dest)
  *	Lookup real service by <proto,addr,port> in the real service table.
  */
 struct ip_vs_dest *
-ip_vs_lookup_real_service(int af, __u16 protocol,
+ip_vs_lookup_real_service(struct net *net, int af, __u16 protocol,
 			  const union nf_inet_addr *daddr,
 			  __be16 dport)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	unsigned hash;
 	struct ip_vs_dest *dest;
 
@@ -602,7 +598,7 @@ ip_vs_lookup_real_service(int af, __u16 protocol,
 	hash = ip_vs_rs_hashkey(af, daddr, dport);
 
 	read_lock(&__ip_vs_rs_lock);
-	list_for_each_entry(dest, &ip_vs_rtable[hash], d_list) {
+	list_for_each_entry(dest, &ipvs->rs_table[hash], d_list) {
 		if ((dest->af == af)
 		    && ip_vs_addr_equal(af, &dest->addr, daddr)
 		    && (dest->port == dport)
@@ -652,7 +648,8 @@ ip_vs_lookup_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
  * ip_vs_lookup_real_service() looked promissing, but
  * seems not working as expected.
  */
-struct ip_vs_dest *ip_vs_find_dest(int af, const union nf_inet_addr *daddr,
+struct ip_vs_dest *ip_vs_find_dest(struct net  *net, int af,
+				   const union nf_inet_addr *daddr,
 				   __be16 dport,
 				   const union nf_inet_addr *vaddr,
 				   __be16 vport, __u16 protocol, __u32 fwmark)
@@ -660,7 +657,7 @@ struct ip_vs_dest *ip_vs_find_dest(int af, const union nf_inet_addr *daddr,
 	struct ip_vs_dest *dest;
 	struct ip_vs_service *svc;
 
-	svc = ip_vs_service_get(af, fwmark, protocol, vaddr, vport);
+	svc = ip_vs_service_get(net, af, fwmark, protocol, vaddr, vport);
 	if (!svc)
 		return NULL;
 	dest = ip_vs_lookup_dest(svc, daddr, dport);
@@ -768,6 +765,7 @@ static void
 __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 		    struct ip_vs_dest_user_kern *udest, int add)
 {
+	struct netns_ipvs *ipvs = net_ipvs(svc->net);
 	int conn_flags;
 
 	/* set the weight and the flags */
@@ -780,11 +778,11 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 		conn_flags |= IP_VS_CONN_F_NOOUTPUT;
 	} else {
 		/*
-		 *    Put the real service in ip_vs_rtable if not present.
+		 *    Put the real service in rs_table if not present.
 		 *    For now only for NAT!
 		 */
 		write_lock_bh(&__ip_vs_rs_lock);
-		ip_vs_rs_hash(dest);
+		ip_vs_rs_hash(ipvs, dest);
 		write_unlock_bh(&__ip_vs_rs_lock);
 	}
 	atomic_set(&dest->conn_flags, conn_flags);
@@ -1117,7 +1115,7 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
  *	Add a service into the service hash table
  */
 static int
-ip_vs_add_service(struct ip_vs_service_user_kern *u,
+ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 		  struct ip_vs_service **svc_p)
 {
 	int ret = 0;
@@ -1172,6 +1170,7 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 	svc->flags = u->flags;
 	svc->timeout = u->timeout * HZ;
 	svc->netmask = u->netmask;
+	svc->net = net;
 
 	INIT_LIST_HEAD(&svc->destinations);
 	rwlock_init(&svc->sched_lock);
@@ -1428,17 +1427,19 @@ static int ip_vs_del_service(struct ip_vs_service *svc)
 /*
  *	Flush all the virtual services
  */
-static int ip_vs_flush(void)
+static int ip_vs_flush(struct net *net)
 {
 	int idx;
 	struct ip_vs_service *svc, *nxt;
 
 	/*
-	 * Flush the service table hashed by <protocol,addr,port>
+	 * Flush the service table hashed by <netns,protocol,addr,port>
 	 */
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each_entry_safe(svc, nxt, &ip_vs_svc_table[idx], s_list) {
-			ip_vs_unlink_service(svc);
+		list_for_each_entry_safe(svc, nxt, &ip_vs_svc_table[idx],
+					 s_list) {
+			if (net_eq(svc->net, net))
+				ip_vs_unlink_service(svc);
 		}
 	}
 
@@ -1448,7 +1449,8 @@ static int ip_vs_flush(void)
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		list_for_each_entry_safe(svc, nxt,
 					 &ip_vs_svc_fwm_table[idx], f_list) {
-			ip_vs_unlink_service(svc);
+			if (net_eq(svc->net, net))
+				ip_vs_unlink_service(svc);
 		}
 	}
 
@@ -1472,20 +1474,22 @@ static int ip_vs_zero_service(struct ip_vs_service *svc)
 	return 0;
 }
 
-static int ip_vs_zero_all(void)
+static int ip_vs_zero_all(struct net *net)
 {
 	int idx;
 	struct ip_vs_service *svc;
 
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		list_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
-			ip_vs_zero_service(svc);
+			if (net_eq(svc->net, net))
+				ip_vs_zero_service(svc);
 		}
 	}
 
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		list_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
-			ip_vs_zero_service(svc);
+			if (net_eq(svc->net, net))
+				ip_vs_zero_service(svc);
 		}
 	}
 
@@ -1763,6 +1767,7 @@ static struct ctl_table_header * sysctl_header;
 #ifdef CONFIG_PROC_FS
 
 struct ip_vs_iter {
+	struct seq_net_private p;  /* Do not move this, netns depends upon it*/
 	struct list_head *table;
 	int bucket;
 };
@@ -1789,6 +1794,7 @@ static inline const char *ip_vs_fwd_name(unsigned flags)
 /* Get the Nth entry in the two lists */
 static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
 {
+	struct net *net = seq_file_net(seq);
 	struct ip_vs_iter *iter = seq->private;
 	int idx;
 	struct ip_vs_service *svc;
@@ -1796,7 +1802,7 @@ static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
 	/* look in hash by protocol */
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		list_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
-			if (pos-- == 0){
+			if (net_eq(svc->net, net) && pos-- == 0) {
 				iter->table = ip_vs_svc_table;
 				iter->bucket = idx;
 				return svc;
@@ -1807,7 +1813,7 @@ static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
 	/* keep looking in fwmark */
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		list_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
-			if (pos-- == 0) {
+			if (net_eq(svc->net, net) && pos-- == 0) {
 				iter->table = ip_vs_svc_fwm_table;
 				iter->bucket = idx;
 				return svc;
@@ -1961,7 +1967,7 @@ static const struct seq_operations ip_vs_info_seq_ops = {
 
 static int ip_vs_info_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &ip_vs_info_seq_ops,
+	return seq_open_net(inode, file, &ip_vs_info_seq_ops,
 			sizeof(struct ip_vs_iter));
 }
 
@@ -2011,7 +2017,7 @@ static int ip_vs_stats_show(struct seq_file *seq, void *v)
 
 static int ip_vs_stats_seq_open(struct inode *inode, struct file *file)
 {
-	return single_open(file, ip_vs_stats_show, NULL);
+	return single_open_net(inode, file, ip_vs_stats_show);
 }
 
 static const struct file_operations ip_vs_stats_fops = {
@@ -2113,6 +2119,7 @@ static void ip_vs_copy_udest_compat(struct ip_vs_dest_user_kern *udest,
 static int
 do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 {
+	struct net *net = sock_net(sk);
 	int ret;
 	unsigned char arg[MAX_ARG_LEN];
 	struct ip_vs_service_user *usvc_compat;
@@ -2147,7 +2154,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 
 	if (cmd == IP_VS_SO_SET_FLUSH) {
 		/* Flush the virtual service */
-		ret = ip_vs_flush();
+		ret = ip_vs_flush(net);
 		goto out_unlock;
 	} else if (cmd == IP_VS_SO_SET_TIMEOUT) {
 		/* Set timeout values for (tcp tcpfin udp) */
@@ -2174,7 +2181,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 	if (cmd == IP_VS_SO_SET_ZERO) {
 		/* if no service address is set, zero counters in all */
 		if (!usvc.fwmark && !usvc.addr.ip && !usvc.port) {
-			ret = ip_vs_zero_all();
+			ret = ip_vs_zero_all(net);
 			goto out_unlock;
 		}
 	}
@@ -2191,10 +2198,10 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 
 	/* Lookup the exact service by <protocol, addr, port> or fwmark */
 	if (usvc.fwmark == 0)
-		svc = __ip_vs_service_find(usvc.af, usvc.protocol,
+		svc = __ip_vs_service_find(net, usvc.af, usvc.protocol,
 					   &usvc.addr, usvc.port);
 	else
-		svc = __ip_vs_svc_fwm_find(usvc.af, usvc.fwmark);
+		svc = __ip_vs_svc_fwm_find(net, usvc.af, usvc.fwmark);
 
 	if (cmd != IP_VS_SO_SET_ADD
 	    && (svc == NULL || svc->protocol != usvc.protocol)) {
@@ -2207,7 +2214,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		if (svc != NULL)
 			ret = -EEXIST;
 		else
-			ret = ip_vs_add_service(&usvc, &svc);
+			ret = ip_vs_add_service(net, &usvc, &svc);
 		break;
 	case IP_VS_SO_SET_EDIT:
 		ret = ip_vs_edit_service(svc, &usvc);
@@ -2267,7 +2274,8 @@ ip_vs_copy_service(struct ip_vs_service_entry *dst, struct ip_vs_service *src)
 }
 
 static inline int
-__ip_vs_get_service_entries(const struct ip_vs_get_services *get,
+__ip_vs_get_service_entries(struct net *net,
+			    const struct ip_vs_get_services *get,
 			    struct ip_vs_get_services __user *uptr)
 {
 	int idx, count=0;
@@ -2278,7 +2286,7 @@ __ip_vs_get_service_entries(const struct ip_vs_get_services *get,
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		list_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
 			/* Only expose IPv4 entries to old interface */
-			if (svc->af != AF_INET)
+			if (svc->af != AF_INET || !net_eq(svc->net, net))
 				continue;
 
 			if (count >= get->num_services)
@@ -2297,7 +2305,7 @@ __ip_vs_get_service_entries(const struct ip_vs_get_services *get,
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		list_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
 			/* Only expose IPv4 entries to old interface */
-			if (svc->af != AF_INET)
+			if (svc->af != AF_INET || !net_eq(svc->net, net))
 				continue;
 
 			if (count >= get->num_services)
@@ -2317,7 +2325,7 @@ __ip_vs_get_service_entries(const struct ip_vs_get_services *get,
 }
 
 static inline int
-__ip_vs_get_dest_entries(const struct ip_vs_get_dests *get,
+__ip_vs_get_dest_entries(struct net *net, const struct ip_vs_get_dests *get,
 			 struct ip_vs_get_dests __user *uptr)
 {
 	struct ip_vs_service *svc;
@@ -2325,9 +2333,9 @@ __ip_vs_get_dest_entries(const struct ip_vs_get_dests *get,
 	int ret = 0;
 
 	if (get->fwmark)
-		svc = __ip_vs_svc_fwm_find(AF_INET, get->fwmark);
+		svc = __ip_vs_svc_fwm_find(net, AF_INET, get->fwmark);
 	else
-		svc = __ip_vs_service_find(AF_INET, get->protocol, &addr,
+		svc = __ip_vs_service_find(net, AF_INET, get->protocol, &addr,
 					   get->port);
 
 	if (svc) {
@@ -2401,7 +2409,9 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	unsigned char arg[128];
 	int ret = 0;
 	unsigned int copylen;
+	struct net *net = sock_net(sk);
 
+	BUG_ON(!net);
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
@@ -2463,7 +2473,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 			ret = -EINVAL;
 			goto out;
 		}
-		ret = __ip_vs_get_service_entries(get, user);
+		ret = __ip_vs_get_service_entries(net, get, user);
 	}
 	break;
 
@@ -2476,10 +2486,11 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 		entry = (struct ip_vs_service_entry *)arg;
 		addr.ip = entry->addr;
 		if (entry->fwmark)
-			svc = __ip_vs_svc_fwm_find(AF_INET, entry->fwmark);
+			svc = __ip_vs_svc_fwm_find(net, AF_INET, entry->fwmark);
 		else
-			svc = __ip_vs_service_find(AF_INET, entry->protocol,
-						   &addr, entry->port);
+			svc = __ip_vs_service_find(net, AF_INET,
+						   entry->protocol, &addr,
+						   entry->port);
 		if (svc) {
 			ip_vs_copy_service(entry, svc);
 			if (copy_to_user(user, entry, sizeof(*entry)) != 0)
@@ -2502,7 +2513,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 			ret = -EINVAL;
 			goto out;
 		}
-		ret = __ip_vs_get_dest_entries(get, user);
+		ret = __ip_vs_get_dest_entries(net, get, user);
 	}
 	break;
 
@@ -2722,11 +2733,12 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 	int idx = 0, i;
 	int start = cb->args[0];
 	struct ip_vs_service *svc;
+	struct net *net = skb_sknet(skb);
 
 	mutex_lock(&__ip_vs_mutex);
 	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
 		list_for_each_entry(svc, &ip_vs_svc_table[i], s_list) {
-			if (++idx <= start)
+			if (++idx <= start || !net_eq(svc->net, net))
 				continue;
 			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
 				idx--;
@@ -2737,7 +2749,7 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 
 	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
 		list_for_each_entry(svc, &ip_vs_svc_fwm_table[i], f_list) {
-			if (++idx <= start)
+			if (++idx <= start || !net_eq(svc->net, net))
 				continue;
 			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
 				idx--;
@@ -2753,7 +2765,8 @@ nla_put_failure:
 	return skb->len;
 }
 
-static int ip_vs_genl_parse_service(struct ip_vs_service_user_kern *usvc,
+static int ip_vs_genl_parse_service(struct net *net,
+				    struct ip_vs_service_user_kern *usvc,
 				    struct nlattr *nla, int full_entry,
 				    struct ip_vs_service **ret_svc)
 {
@@ -2796,9 +2809,9 @@ static int ip_vs_genl_parse_service(struct ip_vs_service_user_kern *usvc,
 	}
 
 	if (usvc->fwmark)
-		svc = __ip_vs_svc_fwm_find(usvc->af, usvc->fwmark);
+		svc = __ip_vs_svc_fwm_find(net, usvc->af, usvc->fwmark);
 	else
-		svc = __ip_vs_service_find(usvc->af, usvc->protocol,
+		svc = __ip_vs_service_find(net, usvc->af, usvc->protocol,
 					   &usvc->addr, usvc->port);
 	*ret_svc = svc;
 
@@ -2835,13 +2848,14 @@ static int ip_vs_genl_parse_service(struct ip_vs_service_user_kern *usvc,
 	return 0;
 }
 
-static struct ip_vs_service *ip_vs_genl_find_service(struct nlattr *nla)
+static struct ip_vs_service *ip_vs_genl_find_service(struct net *net,
+						     struct nlattr *nla)
 {
 	struct ip_vs_service_user_kern usvc;
 	struct ip_vs_service *svc;
 	int ret;
 
-	ret = ip_vs_genl_parse_service(&usvc, nla, 0, &svc);
+	ret = ip_vs_genl_parse_service(net, &usvc, nla, 0, &svc);
 	return ret ? ERR_PTR(ret) : svc;
 }
 
@@ -2909,6 +2923,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 	struct ip_vs_service *svc;
 	struct ip_vs_dest *dest;
 	struct nlattr *attrs[IPVS_CMD_ATTR_MAX + 1];
+	struct net *net;
 
 	mutex_lock(&__ip_vs_mutex);
 
@@ -2917,7 +2932,8 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 			IPVS_CMD_ATTR_MAX, ip_vs_cmd_policy))
 		goto out_err;
 
-	svc = ip_vs_genl_find_service(attrs[IPVS_CMD_ATTR_SERVICE]);
+	net = skb_sknet(skb);
+	svc = ip_vs_genl_find_service(net, attrs[IPVS_CMD_ATTR_SERVICE]);
 	if (IS_ERR(svc) || svc == NULL)
 		goto out_err;
 
@@ -3102,13 +3118,15 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 	struct ip_vs_dest_user_kern udest;
 	int ret = 0, cmd;
 	int need_full_svc = 0, need_full_dest = 0;
+	struct net *net;
 
+	net = skb_sknet(skb);
 	cmd = info->genlhdr->cmd;
 
 	mutex_lock(&__ip_vs_mutex);
 
 	if (cmd == IPVS_CMD_FLUSH) {
-		ret = ip_vs_flush();
+		ret = ip_vs_flush(net);
 		goto out;
 	} else if (cmd == IPVS_CMD_SET_CONFIG) {
 		ret = ip_vs_genl_set_config(info->attrs);
@@ -3133,7 +3151,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 		goto out;
 	} else if (cmd == IPVS_CMD_ZERO &&
 		   !info->attrs[IPVS_CMD_ATTR_SERVICE]) {
-		ret = ip_vs_zero_all();
+		ret = ip_vs_zero_all(net);
 		goto out;
 	}
 
@@ -3143,7 +3161,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 	if (cmd == IPVS_CMD_NEW_SERVICE || cmd == IPVS_CMD_SET_SERVICE)
 		need_full_svc = 1;
 
-	ret = ip_vs_genl_parse_service(&usvc,
+	ret = ip_vs_genl_parse_service(net, &usvc,
 				       info->attrs[IPVS_CMD_ATTR_SERVICE],
 				       need_full_svc, &svc);
 	if (ret)
@@ -3173,7 +3191,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 	switch (cmd) {
 	case IPVS_CMD_NEW_SERVICE:
 		if (svc == NULL)
-			ret = ip_vs_add_service(&usvc, &svc);
+			ret = ip_vs_add_service(net, &usvc, &svc);
 		else
 			ret = -EEXIST;
 		break;
@@ -3211,7 +3229,9 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	struct sk_buff *msg;
 	void *reply;
 	int ret, cmd, reply_cmd;
+	struct net *net;
 
+	net = skb_sknet(skb);
 	cmd = info->genlhdr->cmd;
 
 	if (cmd == IPVS_CMD_GET_SERVICE)
@@ -3240,7 +3260,8 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	{
 		struct ip_vs_service *svc;
 
-		svc = ip_vs_genl_find_service(info->attrs[IPVS_CMD_ATTR_SERVICE]);
+		svc = ip_vs_genl_find_service(net,
+					      info->attrs[IPVS_CMD_ATTR_SERVICE]);
 		if (IS_ERR(svc)) {
 			ret = PTR_ERR(svc);
 			goto out_err;
@@ -3411,9 +3432,15 @@ static void ip_vs_genl_unregister(void)
  */
 int __net_init __ip_vs_control_init(struct net *net)
 {
+	int idx;
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
 	if (!net_eq(net, &init_net))	/* netns not enabled yet */
 		return -EPERM;
 
+	for (idx = 0; idx < IP_VS_RTAB_SIZE; idx++)
+		INIT_LIST_HEAD(&ipvs->rs_table[idx]);
+
 	proc_net_fops_create(net, "ip_vs", 0, &ip_vs_info_fops);
 	proc_net_fops_create(net, "ip_vs_stats", 0, &ip_vs_stats_fops);
 	sysctl_header = register_net_sysctl_table(net, net_vs_ctl_path,
@@ -3445,43 +3472,48 @@ static struct pernet_operations ipvs_control_ops = {
 
 int __init ip_vs_control_init(void)
 {
-	int ret;
 	int idx;
+	int ret;
 
 	EnterFunction(2);
 
-	/* Initialize ip_vs_svc_table, ip_vs_svc_fwm_table, ip_vs_rtable */
+	/* Initialize svc_table, ip_vs_svc_fwm_table, rs_table */
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++)  {
 		INIT_LIST_HEAD(&ip_vs_svc_table[idx]);
 		INIT_LIST_HEAD(&ip_vs_svc_fwm_table[idx]);
 	}
-	for(idx = 0; idx < IP_VS_RTAB_SIZE; idx++)  {
-		INIT_LIST_HEAD(&ip_vs_rtable[idx]);
+
+	ret = register_pernet_subsys(&ipvs_control_ops);
+	if (ret) {
+		pr_err("cannot register namespace.\n");
+		goto err;
 	}
-	smp_wmb();
+
+	smp_wmb();	/* Do we really need it now ? */
 
 	ret = nf_register_sockopt(&ip_vs_sockopts);
 	if (ret) {
 		pr_err("cannot register sockopt.\n");
-		return ret;
+		goto err_net;
 	}
 
 	ret = ip_vs_genl_register();
 	if (ret) {
 		pr_err("cannot register Generic Netlink interface.\n");
 		nf_unregister_sockopt(&ip_vs_sockopts);
-		return ret;
+		goto err_net;
 	}
 
-	ret = register_pernet_subsys(&ipvs_control_ops);
-	if (ret)
-		return ret;
-
 	/* Hook the defense timer */
 	schedule_delayed_work(&defense_work, DEFENSE_TIMER_PERIOD);
 
 	LeaveFunction(2);
 	return 0;
+
+err_net:
+	unregister_pernet_subsys(&ipvs_control_ops);
+err:
+	return ret;
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index a315159..521b827 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -12,6 +12,7 @@ static int
 sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		   int *verdict, struct ip_vs_conn **cpp)
 {
+	struct net *net;
 	struct ip_vs_service *svc;
 	sctp_chunkhdr_t _schunkh, *sch;
 	sctp_sctphdr_t *sh, _sctph;
@@ -27,9 +28,9 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 				 sizeof(_schunkh), &_schunkh);
 	if (sch == NULL)
 		return 0;
-
+	net = skb_net(skb);
 	if ((sch->type == SCTP_CID_INIT) &&
-	    (svc = ip_vs_service_get(af, skb->mark, iph.protocol,
+	    (svc = ip_vs_service_get(net, af, skb->mark, iph.protocol,
 				     &iph.daddr, sh->dest))) {
 		int ignored;
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 1cdab12..c175d31 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -31,6 +31,7 @@ static int
 tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		  int *verdict, struct ip_vs_conn **cpp)
 {
+	struct net *net;
 	struct ip_vs_service *svc;
 	struct tcphdr _tcph, *th;
 	struct ip_vs_iphdr iph;
@@ -42,11 +43,11 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		*verdict = NF_DROP;
 		return 0;
 	}
-
+	net = skb_net(skb);
 	/* No !th->ack check to allow scheduling on SYN+ACK for Active FTP */
 	if (th->syn &&
-	    (svc = ip_vs_service_get(af, skb->mark, iph.protocol, &iph.daddr,
-				     th->dest))) {
+	    (svc = ip_vs_service_get(net, af, skb->mark, iph.protocol,
+				     &iph.daddr, th->dest))) {
 		int ignored;
 
 		if (ip_vs_todrop()) {
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index cd398de..5ab54f6 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -31,6 +31,7 @@ static int
 udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		  int *verdict, struct ip_vs_conn **cpp)
 {
+	struct net *net;
 	struct ip_vs_service *svc;
 	struct udphdr _udph, *uh;
 	struct ip_vs_iphdr iph;
@@ -42,8 +43,8 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		*verdict = NF_DROP;
 		return 0;
 	}
