From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 17/22] IPVS: netns, ip_vs_ctl local vars moved to ipvs struct.
Date: Thu, 13 Jan 2011 10:53:03 +0900
Message-ID: <1294883588-5683-18-git-send-email-horms@verge.net.au>
References: <1294883588-5683-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1294883588-5683-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

Moving global vars to ipvs struct, except for svc table lock.
Next patch for ctl will be drop-rate handling.

*v3
__ip_vs_mutex remains global
 ip_vs_conntrack_enabled(struct netns_ipvs *ipvs)

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h                   |   27 ++--
 include/net/netns/ip_vs.h             |   37 ++++-
 net/netfilter/ipvs/ip_vs_conn.c       |    7 +-
 net/netfilter/ipvs/ip_vs_core.c       |   34 +++--
 net/netfilter/ipvs/ip_vs_ctl.c        |  291 +++++++++++++++++----------------
 net/netfilter/ipvs/ip_vs_proto_sctp.c |    2 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |    2 +-
 net/netfilter/ipvs/ip_vs_proto_udp.c  |    2 +-
 net/netfilter/ipvs/ip_vs_sync.c       |    9 +-
 9 files changed, 230 insertions(+), 181 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index f82c0ff..af9acf4 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -41,7 +41,7 @@ static inline struct netns_ipvs *net_ipvs(struct net* net)
  * Get net ptr from skb in traffic cases
  * use skb_sknet when call is from userland (ioctl or netlink)
  */
-static inline struct net *skb_net(struct sk_buff *skb)
+static inline struct net *skb_net(const struct sk_buff *skb)
 {
 #ifdef CONFIG_NET_NS
 #ifdef CONFIG_IP_VS_DEBUG
@@ -69,7 +69,7 @@ static inline struct net *skb_net(struct sk_buff *skb)
 #endif
 }
 
-static inline struct net *skb_sknet(struct sk_buff *skb)
+static inline struct net *skb_sknet(const struct sk_buff *skb)
 {
 #ifdef CONFIG_NET_NS
 #ifdef CONFIG_IP_VS_DEBUG
@@ -1023,13 +1023,6 @@ extern int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 /*
  *      IPVS control data and functions (from ip_vs_ctl.c)
  */
-extern int sysctl_ip_vs_cache_bypass;
-extern int sysctl_ip_vs_expire_nodest_conn;
-extern int sysctl_ip_vs_expire_quiescent_template;
-extern int sysctl_ip_vs_sync_threshold[2];
-extern int sysctl_ip_vs_nat_icmp_send;
-extern int sysctl_ip_vs_conntrack;
-extern int sysctl_ip_vs_snat_reroute;
 extern struct ip_vs_stats ip_vs_stats;
 extern const struct ctl_path net_vs_ctl_path[];
 extern int sysctl_ip_vs_sync_ver;
@@ -1119,11 +1112,13 @@ extern int ip_vs_icmp_xmit_v6
 extern int ip_vs_drop_rate;
 extern int ip_vs_drop_counter;
 
-static __inline__ int ip_vs_todrop(void)
+static inline int ip_vs_todrop(struct netns_ipvs *ipvs)
 {
-	if (!ip_vs_drop_rate) return 0;
-	if (--ip_vs_drop_counter > 0) return 0;
-	ip_vs_drop_counter = ip_vs_drop_rate;
+	if (!ipvs->drop_rate)
+		return 0;
+	if (--ipvs->drop_counter > 0)
+		return 0;
+	ipvs->drop_counter = ipvs->drop_rate;
 	return 1;
 }
 
@@ -1211,9 +1206,9 @@ static inline void ip_vs_notrack(struct sk_buff *skb)
  *      Netfilter connection tracking
  *      (from ip_vs_nfct.c)
  */
-static inline int ip_vs_conntrack_enabled(void)
+static inline int ip_vs_conntrack_enabled(struct netns_ipvs *ipvs)
 {
-	return sysctl_ip_vs_conntrack;
+	return ipvs->sysctl_conntrack;
 }
 
 extern void ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp,
@@ -1226,7 +1221,7 @@ extern void ip_vs_conn_drop_conntrack(struct ip_vs_conn *cp);
 
 #else
 
-static inline int ip_vs_conntrack_enabled(void)
+static inline int ip_vs_conntrack_enabled(struct netns_ipvs *ipvs)
 {
 	return 0;
 }
diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
index 1acfb33..c4b1abf 100644
--- a/include/net/netns/ip_vs.h
+++ b/include/net/netns/ip_vs.h
@@ -61,13 +61,46 @@ struct netns_ipvs {
 	struct list_head	sctp_apps[SCTP_APP_TAB_SIZE];
 	spinlock_t		sctp_app_lock;
 #endif
+	/* ip_vs_conn */
+	atomic_t		conn_count;      /*  connection counter */
+
 	/* ip_vs_ctl */
 	struct ip_vs_stats		*tot_stats;  /* Statistics & est. */
 	struct ip_vs_cpu_stats __percpu *cpustats;   /* Stats per cpu */
 	seqcount_t			*ustats_seq; /* u64 read retry */
 
-	/* ip_vs_conn */
-	atomic_t		conn_count;         /*  connection counter */
+	int			num_services;    /* no of virtual services */
+	/* 1/rate drop and drop-entry variables */
+	int			drop_rate;
+	int			drop_counter;
+	atomic_t		dropentry;
+	/* locks in ctl.c */
+	spinlock_t		dropentry_lock;  /* drop entry handling */
+	spinlock_t		droppacket_lock; /* drop packet handling */
+	spinlock_t		securetcp_lock;  /* state and timeout tables */
+	rwlock_t		rs_lock;         /* real services table */
+	/* semaphore for IPVS sockopts. And, [gs]etsockopt may sleep. */
+	struct lock_class_key	ctl_key;	/* ctl_mutex debuging */
+	/* sys-ctl struct */
+	struct ctl_table_header	*sysctl_hdr;
+	struct ctl_table	*sysctl_tbl;
+	/* sysctl variables */
+	int			sysctl_amemthresh;
+	int			sysctl_am_droprate;
+	int			sysctl_drop_entry;
+	int			sysctl_drop_packet;
+	int			sysctl_secure_tcp;
+#ifdef CONFIG_IP_VS_NFCT
+	int			sysctl_conntrack;
+#endif
+	int			sysctl_snat_reroute;
+	int			sysctl_sync_ver;
+	int			sysctl_cache_bypass;
+	int			sysctl_expire_nodest_conn;
+	int			sysctl_expire_quiescent_template;
+	int			sysctl_sync_threshold[2];
+	int			sysctl_nat_icmp_send;
+
 	/* ip_vs_lblc */
 	int			sysctl_lblc_expiration;
 	struct ctl_table_header	*lblc_ctl_header;
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 0d5e4fe..5ba205a 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -686,13 +686,14 @@ static inline void ip_vs_unbind_dest(struct ip_vs_conn *cp)
 int ip_vs_check_template(struct ip_vs_conn *ct)
 {
 	struct ip_vs_dest *dest = ct->dest;
+	struct netns_ipvs *ipvs = net_ipvs(ip_vs_conn_net(ct));
 
 	/*
 	 * Checking the dest server status.
 	 */
 	if ((dest == NULL) ||
 	    !(dest->flags & IP_VS_DEST_F_AVAILABLE) ||
-	    (sysctl_ip_vs_expire_quiescent_template &&
+	    (ipvs->sysctl_expire_quiescent_template &&
 	     (atomic_read(&dest->weight) == 0))) {
 		IP_VS_DBG_BUF(9, "check_template: dest not available for "
 			      "protocol %s s:%s:%d v:%s:%d "
@@ -879,7 +880,7 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
 	 * IP_VS_CONN_F_ONE_PACKET too.
 	 */
 
-	if (ip_vs_conntrack_enabled())
+	if (ip_vs_conntrack_enabled(ipvs))
 		cp->flags |= IP_VS_CONN_F_NFCT;
 
 	/* Hash it in the ip_vs_conn_tab finally */
@@ -1198,7 +1199,7 @@ static void ip_vs_conn_flush(struct net *net)
 	struct ip_vs_conn *cp;
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-  flush_again:
+flush_again:
 	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
 		/*
 		 *  Lock is actually needed in this loop.
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 7205b49..a7c59a7 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -499,6 +499,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		struct ip_vs_proto_data *pd)
 {
+	struct netns_ipvs *ipvs;
 	__be16 _ports[2], *pptr;
 	struct ip_vs_iphdr iph;
 	int unicast;
@@ -521,7 +522,8 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 	/* if it is fwmark-based service, the cache_bypass sysctl is up
 	   and the destination is a non-local unicast, then create
 	   a cache_bypass connection entry */
-	if (sysctl_ip_vs_cache_bypass && svc->fwmark && unicast) {
+	ipvs = net_ipvs(skb_net(skb));
+	if (ipvs->sysctl_cache_bypass && svc->fwmark && unicast) {
 		int ret, cs;
 		struct ip_vs_conn *cp;
 		unsigned int flags = (svc->flags & IP_VS_SVC_F_ONEPACKET &&
@@ -733,6 +735,7 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 				struct ip_vs_protocol *pp,
 				unsigned int offset, unsigned int ihl)
 {
+	struct netns_ipvs *ipvs;
 	unsigned int verdict = NF_DROP;
 
 	if (IP_VS_FWD_METHOD(cp) != 0) {
@@ -754,6 +757,8 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 	if (!skb_make_writable(skb, offset))
 		goto out;
 
+	ipvs = net_ipvs(skb_net(skb));
+
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6)
 		ip_vs_nat_icmp_v6(skb, pp, cp, 1);
@@ -763,11 +768,11 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
-		if (sysctl_ip_vs_snat_reroute && ip6_route_me_harder(skb) != 0)
+		if (ipvs->sysctl_snat_reroute && ip6_route_me_harder(skb) != 0)
 			goto out;
 	} else
 #endif
-		if ((sysctl_ip_vs_snat_reroute ||
+		if ((ipvs->sysctl_snat_reroute ||
 		     skb_rtable(skb)->rt_flags & RTCF_LOCAL) &&
 		    ip_route_me_harder(skb, RTN_LOCAL) != 0)
 			goto out;
@@ -979,6 +984,7 @@ handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		struct ip_vs_conn *cp, int ihl)
 {
 	struct ip_vs_protocol *pp = pd->pp;
+	struct netns_ipvs *ipvs;
 
 	IP_VS_DBG_PKT(11, af, pp, skb, 0, "Outgoing packet");
 
@@ -1014,13 +1020,15 @@ handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	 * if it came from this machine itself.  So re-compute
 	 * the routing information.
 	 */
+	ipvs = net_ipvs(skb_net(skb));
+
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
-		if (sysctl_ip_vs_snat_reroute && ip6_route_me_harder(skb) != 0)
+		if (ipvs->sysctl_snat_reroute && ip6_route_me_harder(skb) != 0)
 			goto drop;
 	} else
 #endif
-		if ((sysctl_ip_vs_snat_reroute ||
+		if ((ipvs->sysctl_snat_reroute ||
 		     skb_rtable(skb)->rt_flags & RTCF_LOCAL) &&
 		    ip_route_me_harder(skb, RTN_LOCAL) != 0)
 			goto drop;
@@ -1057,6 +1065,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
 	struct ip_vs_conn *cp;
+	struct netns_ipvs *ipvs;
 
 	EnterFunction(11);
 
@@ -1131,10 +1140,11 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	 * Check if the packet belongs to an existing entry
 	 */
 	cp = pp->conn_out_get(af, skb, &iph, iph.len, 0);
+	ipvs = net_ipvs(net);
 
 	if (likely(cp))
 		return handle_response(af, skb, pd, cp, iph.len);
-	if (sysctl_ip_vs_nat_icmp_send &&
+	if (ipvs->sysctl_nat_icmp_send &&
 	    (pp->protocol == IPPROTO_TCP ||
 	     pp->protocol == IPPROTO_UDP ||
 	     pp->protocol == IPPROTO_SCTP)) {
@@ -1580,7 +1590,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
 		/* the destination server is not available */
 
-		if (sysctl_ip_vs_expire_nodest_conn) {
+		if (ipvs->sysctl_expire_nodest_conn) {
 			/* try to expire the connection immediately */
 			ip_vs_conn_expire_now(cp);
 		}
@@ -1610,15 +1620,15 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	 */
 
 	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
-		pkts = sysctl_ip_vs_sync_threshold[0];
+		pkts = ipvs->sysctl_sync_threshold[0];
 	else
 		pkts = atomic_add_return(1, &cp->in_pkts);
 
 	if ((ipvs->sync_state & IP_VS_STATE_MASTER) &&
 	    cp->protocol == IPPROTO_SCTP) {
 		if ((cp->state == IP_VS_SCTP_S_ESTABLISHED &&
-			(pkts % sysctl_ip_vs_sync_threshold[1]
-			 == sysctl_ip_vs_sync_threshold[0])) ||
+			(pkts % ipvs->sysctl_sync_threshold[1]
+			 == ipvs->sysctl_sync_threshold[0])) ||
 				(cp->old_state != cp->state &&
 				 ((cp->state == IP_VS_SCTP_S_CLOSED) ||
 				  (cp->state == IP_VS_SCTP_S_SHUT_ACK_CLI) ||
@@ -1632,8 +1642,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	else if ((ipvs->sync_state & IP_VS_STATE_MASTER) &&
 	    (((cp->protocol != IPPROTO_TCP ||
 	       cp->state == IP_VS_TCP_S_ESTABLISHED) &&
-	      (pkts % sysctl_ip_vs_sync_threshold[1]
-	       == sysctl_ip_vs_sync_threshold[0])) ||
+	      (pkts % ipvs->sysctl_sync_threshold[1]
+	       == ipvs->sysctl_sync_threshold[0])) ||
 	     ((cp->protocol == IPPROTO_TCP) && (cp->old_state != cp->state) &&
 	      ((cp->state == IP_VS_TCP_S_FIN_WAIT) ||
 	       (cp->state == IP_VS_TCP_S_CLOSE) ||
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index cbd58c6..183ac18 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -58,42 +58,7 @@ static DEFINE_MUTEX(__ip_vs_mutex);
 /* lock for service table */
 static DEFINE_RWLOCK(__ip_vs_svc_lock);
 
-/* lock for table with the real services */
-static DEFINE_RWLOCK(__ip_vs_rs_lock);
-
-/* lock for state and timeout tables */
-static DEFINE_SPINLOCK(ip_vs_securetcp_lock);
-
-/* lock for drop entry handling */
-static DEFINE_SPINLOCK(__ip_vs_dropentry_lock);
-
-/* lock for drop packet handling */
-static DEFINE_SPINLOCK(__ip_vs_droppacket_lock);
-
-/* 1/rate drop and drop-entry variables */
-int ip_vs_drop_rate = 0;
-int ip_vs_drop_counter = 0;
-static atomic_t ip_vs_dropentry = ATOMIC_INIT(0);
-
-/* number of virtual services */
-static int ip_vs_num_services = 0;
-
 /* sysctl variables */
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
-#ifdef CONFIG_IP_VS_NFCT
-int sysctl_ip_vs_conntrack;
-#endif
-int sysctl_ip_vs_snat_reroute = 1;
-int sysctl_ip_vs_sync_ver = 1;		/* Default version of sync proto */
 
 #ifdef CONFIG_IP_VS_DEBUG
 static int sysctl_ip_vs_debug_level = 0;
@@ -142,73 +107,73 @@ static void update_defense_level(struct netns_ipvs *ipvs)
 	/* si_swapinfo(&i); */
 	/* availmem = availmem - (i.totalswap - i.freeswap); */
 
-	nomem = (availmem < sysctl_ip_vs_amemthresh);
+	nomem = (availmem < ipvs->sysctl_amemthresh);
 
 	local_bh_disable();
 
 	/* drop_entry */
-	spin_lock(&__ip_vs_dropentry_lock);
-	switch (sysctl_ip_vs_drop_entry) {
+	spin_lock(&ipvs->dropentry_lock);
+	switch (ipvs->sysctl_drop_entry) {
 	case 0:
-		atomic_set(&ip_vs_dropentry, 0);
+		atomic_set(&ipvs->dropentry, 0);
 		break;
 	case 1:
 		if (nomem) {
-			atomic_set(&ip_vs_dropentry, 1);
-			sysctl_ip_vs_drop_entry = 2;
+			atomic_set(&ipvs->dropentry, 1);
+			ipvs->sysctl_drop_entry = 2;
 		} else {
-			atomic_set(&ip_vs_dropentry, 0);
+			atomic_set(&ipvs->dropentry, 0);
 		}
 		break;
 	case 2:
 		if (nomem) {
-			atomic_set(&ip_vs_dropentry, 1);
+			atomic_set(&ipvs->dropentry, 1);
 		} else {
-			atomic_set(&ip_vs_dropentry, 0);
-			sysctl_ip_vs_drop_entry = 1;
+			atomic_set(&ipvs->dropentry, 0);
+			ipvs->sysctl_drop_entry = 1;
 		};
 		break;
 	case 3:
-		atomic_set(&ip_vs_dropentry, 1);
+		atomic_set(&ipvs->dropentry, 1);
 		break;
 	}
-	spin_unlock(&__ip_vs_dropentry_lock);
+	spin_unlock(&ipvs->dropentry_lock);
 
 	/* drop_packet */
-	spin_lock(&__ip_vs_droppacket_lock);
-	switch (sysctl_ip_vs_drop_packet) {
+	spin_lock(&ipvs->droppacket_lock);
+	switch (ipvs->sysctl_drop_packet) {
 	case 0:
-		ip_vs_drop_rate = 0;
+		ipvs->drop_rate = 0;
 		break;
 	case 1:
 		if (nomem) {
-			ip_vs_drop_rate = ip_vs_drop_counter
-				= sysctl_ip_vs_amemthresh /
-				(sysctl_ip_vs_amemthresh-availmem);
-			sysctl_ip_vs_drop_packet = 2;
+			ipvs->drop_rate = ipvs->drop_counter
+				= ipvs->sysctl_amemthresh /
+				(ipvs->sysctl_amemthresh-availmem);
+			ipvs->sysctl_drop_packet = 2;
 		} else {
-			ip_vs_drop_rate = 0;
+			ipvs->drop_rate = 0;
 		}
 		break;
 	case 2:
 		if (nomem) {
-			ip_vs_drop_rate = ip_vs_drop_counter
-				= sysctl_ip_vs_amemthresh /
-				(sysctl_ip_vs_amemthresh-availmem);
+			ipvs->drop_rate = ipvs->drop_counter
+				= ipvs->sysctl_amemthresh /
+				(ipvs->sysctl_amemthresh-availmem);
 		} else {
-			ip_vs_drop_rate = 0;
-			sysctl_ip_vs_drop_packet = 1;
+			ipvs->drop_rate = 0;
+			ipvs->sysctl_drop_packet = 1;
 		}
 		break;
 	case 3:
-		ip_vs_drop_rate = sysctl_ip_vs_am_droprate;
+		ipvs->drop_rate = ipvs->sysctl_am_droprate;
 		break;
 	}
-	spin_unlock(&__ip_vs_droppacket_lock);
+	spin_unlock(&ipvs->droppacket_lock);
 
 	/* secure_tcp */
-	spin_lock(&ip_vs_securetcp_lock);
-	switch (sysctl_ip_vs_secure_tcp) {
+	spin_lock(&ipvs->securetcp_lock);
+	switch (ipvs->sysctl_secure_tcp) {
 	case 0:
 		if (old_secure_tcp >= 2)
 			to_change = 0;
@@ -217,7 +182,7 @@ static void update_defense_level(struct netns_ipvs *ipvs)
 		if (nomem) {
 			if (old_secure_tcp < 2)
 				to_change = 1;
-			sysctl_ip_vs_secure_tcp = 2;
+			ipvs->sysctl_secure_tcp = 2;
 		} else {
 			if (old_secure_tcp >= 2)
 				to_change = 0;
@@ -230,7 +195,7 @@ static void update_defense_level(struct netns_ipvs *ipvs)
 		} else {
 			if (old_secure_tcp >= 2)
 				to_change = 0;
-			sysctl_ip_vs_secure_tcp = 1;
+			ipvs->sysctl_secure_tcp = 1;
 		}
 		break;
 	case 3:
@@ -238,11 +203,11 @@ static void update_defense_level(struct netns_ipvs *ipvs)
 			to_change = 1;
 		break;
 	}
-	old_secure_tcp = sysctl_ip_vs_secure_tcp;
+	old_secure_tcp = ipvs->sysctl_secure_tcp;
 	if (to_change >= 0)
 		ip_vs_protocol_timeout_change(ipvs,
-					     sysctl_ip_vs_secure_tcp > 1);
-	spin_unlock(&ip_vs_securetcp_lock);
+					      ipvs->sysctl_secure_tcp > 1);
+	spin_unlock(&ipvs->securetcp_lock);
 
 	local_bh_enable();
 }
@@ -260,7 +225,7 @@ static void defense_work_handler(struct work_struct *work)
 	struct netns_ipvs *ipvs = net_ipvs(&init_net);
 
 	update_defense_level(ipvs);
-	if (atomic_read(&ip_vs_dropentry))
+	if (atomic_read(&ipvs->dropentry))
 		ip_vs_random_dropentry();
 
 	schedule_delayed_work(&defense_work, DEFENSE_TIMER_PERIOD);
@@ -602,7 +567,7 @@ ip_vs_lookup_real_service(struct net *net, int af, __u16 protocol,
 	 */
 	hash = ip_vs_rs_hashkey(af, daddr, dport);
 
-	read_lock(&__ip_vs_rs_lock);
+	read_lock(&ipvs->rs_lock);
 	list_for_each_entry(dest, &ipvs->rs_table[hash], d_list) {
 		if ((dest->af == af)
 		    && ip_vs_addr_equal(af, &dest->addr, daddr)
@@ -610,11 +575,11 @@ ip_vs_lookup_real_service(struct net *net, int af, __u16 protocol,
 		    && ((dest->protocol == protocol) ||
 			dest->vfwmark)) {
 			/* HIT */
-			read_unlock(&__ip_vs_rs_lock);
+			read_unlock(&ipvs->rs_lock);
 			return dest;
 		}
 	}
-	read_unlock(&__ip_vs_rs_lock);
+	read_unlock(&ipvs->rs_lock);
 
 	return NULL;
 }
@@ -788,9 +753,9 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 		 *    Put the real service in rs_table if not present.
 		 *    For now only for NAT!
 		 */
-		write_lock_bh(&__ip_vs_rs_lock);
+		write_lock_bh(&ipvs->rs_lock);
 		ip_vs_rs_hash(ipvs, dest);
-		write_unlock_bh(&__ip_vs_rs_lock);
+		write_unlock_bh(&ipvs->rs_lock);
 	}
 	atomic_set(&dest->conn_flags, conn_flags);
 
@@ -1022,14 +987,16 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
  */
 static void __ip_vs_del_dest(struct net *net, struct ip_vs_dest *dest)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
 	ip_vs_kill_estimator(net, &dest->stats);
 
 	/*
 	 *  Remove it from the d-linked list with the real services.
 	 */
-	write_lock_bh(&__ip_vs_rs_lock);
+	write_lock_bh(&ipvs->rs_lock);
 	ip_vs_rs_unhash(dest);
-	write_unlock_bh(&__ip_vs_rs_lock);
+	write_unlock_bh(&ipvs->rs_lock);
 
 	/*
 	 *  Decrease the refcnt of the dest, and free the dest
@@ -1092,7 +1059,6 @@ static int
 ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 {
 	struct ip_vs_dest *dest;
-	struct net *net = svc->net;
 	__be16 dport = udest->port;
 
 	EnterFunction(2);
@@ -1121,7 +1087,7 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	/*
 	 *	Delete the destination
 	 */
-	__ip_vs_del_dest(net, dest);
+	__ip_vs_del_dest(svc->net, dest);
 
 	LeaveFunction(2);
 
@@ -1140,6 +1106,7 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 	struct ip_vs_scheduler *sched = NULL;
 	struct ip_vs_pe *pe = NULL;
 	struct ip_vs_service *svc = NULL;
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	/* increase the module use count */
 	ip_vs_use_count_inc();
@@ -1219,7 +1186,7 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 
 	/* Count only IPv4 services for old get/setsockopt interface */
 	if (svc->af == AF_INET)
-		ip_vs_num_services++;
+		ipvs->num_services++;
 
 	/* Hash the service into the service table */
 	write_lock_bh(&__ip_vs_svc_lock);
@@ -1359,12 +1326,13 @@ static void __ip_vs_del_service(struct ip_vs_service *svc)
 	struct ip_vs_dest *dest, *nxt;
 	struct ip_vs_scheduler *old_sched;
 	struct ip_vs_pe *old_pe;
+	struct netns_ipvs *ipvs = net_ipvs(svc->net);
 
 	pr_info("%s: enter\n", __func__);
 
 	/* Count only IPv4 services for old get/setsockopt interface */
 	if (svc->af == AF_INET)
-		ip_vs_num_services--;
+		ipvs->num_services--;
 
 	ip_vs_kill_estimator(svc->net, &svc->stats);
 
@@ -1589,42 +1557,31 @@ proc_do_sync_mode(ctl_table *table, int write,
 
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
@@ -1632,7 +1589,6 @@ static struct ctl_table vs_vars[] = {
 #ifdef CONFIG_IP_VS_NFCT
 	{
 		.procname	= "conntrack",
-		.data		= &sysctl_ip_vs_conntrack,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
@@ -1640,25 +1596,62 @@ static struct ctl_table vs_vars[] = {
 #endif
 	{
 		.procname	= "secure_tcp",
-		.data		= &sysctl_ip_vs_secure_tcp,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_do_defense_mode,
 	},
 	{
 		.procname	= "snat_reroute",
-		.data		= &sysctl_ip_vs_snat_reroute,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
 	{
 		.procname	= "sync_version",
-		.data		= &sysctl_ip_vs_sync_ver,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_do_sync_mode,
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
+		.maxlen		=
+			sizeof(((struct netns_ipvs *)0)->sysctl_sync_threshold),
+		.mode		= 0644,
+		.proc_handler	= proc_do_sync_threshold,
+	},
+	{
+		.procname	= "nat_icmp_send",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+#ifdef CONFIG_IP_VS_DEBUG
+	{
+		.procname	= "debug_level",
+		.data		= &sysctl_ip_vs_debug_level,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+#endif
 #if 0
 	{
 		.procname	= "timeout_established",
@@ -1745,41 +1738,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 #endif
-	{
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
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
 	{ }
 };
 
@@ -1791,8 +1749,6 @@ const struct ctl_path net_vs_ctl_path[] = {
 };
 EXPORT_SYMBOL_GPL(net_vs_ctl_path);
 
-static struct ctl_table_header * sysctl_header;
-
 #ifdef CONFIG_PROC_FS
 
 struct ip_vs_iter {
@@ -2543,7 +2499,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 		struct ip_vs_getinfo info;
 		info.version = IP_VS_VERSION_CODE;
 		info.size = ip_vs_conn_tab_size;
-		info.num_services = ip_vs_num_services;
+		info.num_services = ipvs->num_services;
 		if (copy_to_user(user, &info, sizeof(info)) != 0)
 			ret = -EFAULT;
 	}
@@ -3014,7 +2970,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 	struct ip_vs_service *svc;
 	struct ip_vs_dest *dest;
 	struct nlattr *attrs[IPVS_CMD_ATTR_MAX + 1];
-	struct net *net;
+	struct net *net = skb_sknet(skb);
 
 	mutex_lock(&__ip_vs_mutex);
 
@@ -3023,7 +2979,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 			IPVS_CMD_ATTR_MAX, ip_vs_cmd_policy))
 		goto out_err;
 
-	net = skb_sknet(skb);
+
 	svc = ip_vs_genl_find_service(net, attrs[IPVS_CMD_ATTR_SERVICE]);
 	if (IS_ERR(svc) || svc == NULL)
 		goto out_err;
@@ -3215,8 +3171,10 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 	int ret = 0, cmd;
 	int need_full_svc = 0, need_full_dest = 0;
 	struct net *net;
+	struct netns_ipvs *ipvs;
 
 	net = skb_sknet(skb);
+	ipvs = net_ipvs(net);
 	cmd = info->genlhdr->cmd;
 
 	mutex_lock(&__ip_vs_mutex);
@@ -3326,8 +3284,10 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	void *reply;
 	int ret, cmd, reply_cmd;
 	struct net *net;
+	struct netns_ipvs *ipvs;
 
 	net = skb_sknet(skb);
+	ipvs = net_ipvs(net);
 	cmd = info->genlhdr->cmd;
 
 	if (cmd == IPVS_CMD_GET_SERVICE)
@@ -3530,9 +3490,21 @@ int __net_init __ip_vs_control_init(struct net *net)
 {
 	int idx;
 	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct ctl_table *tbl;
 
 	if (!net_eq(net, &init_net))	/* netns not enabled yet */
 		return -EPERM;
+
+	atomic_set(&ipvs->dropentry, 0);
+	spin_lock_init(&ipvs->dropentry_lock);
+	spin_lock_init(&ipvs->droppacket_lock);
+	spin_lock_init(&ipvs->securetcp_lock);
+	ipvs->rs_lock = __RW_LOCK_UNLOCKED(ipvs->rs_lock);
+
+	/* Initialize rs_table */
+	for (idx = 0; idx < IP_VS_RTAB_SIZE; idx++)
+		INIT_LIST_HEAD(&ipvs->rs_table[idx]);
+
 	/* procfs stats */
 	ipvs->tot_stats = kzalloc(sizeof(struct ip_vs_stats), GFP_KERNEL);
 	if (ipvs->tot_stats == NULL) {
@@ -3553,14 +3525,51 @@ int __net_init __ip_vs_control_init(struct net *net)
 	proc_net_fops_create(net, "ip_vs_stats", 0, &ip_vs_stats_fops);
 	proc_net_fops_create(net, "ip_vs_stats_percpu", 0,
 			     &ip_vs_stats_percpu_fops);
-	sysctl_header = register_net_sysctl_table(net, net_vs_ctl_path,
+
+	if (!net_eq(net, &init_net)) {
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
+	tbl[idx++].data = &ipvs->sysctl_drop_entry;
+	tbl[idx++].data = &ipvs->sysctl_drop_packet;
+#ifdef CONFIG_IP_VS_NFCT
+	tbl[idx++].data = &ipvs->sysctl_conntrack;
+#endif
+	tbl[idx++].data = &ipvs->sysctl_secure_tcp;
+	ipvs->sysctl_snat_reroute = 1;
+	tbl[idx++].data = &ipvs->sysctl_snat_reroute;
+	ipvs->sysctl_sync_ver = 1;
+	tbl[idx++].data = &ipvs->sysctl_sync_ver;
+	tbl[idx++].data = &ipvs->sysctl_cache_bypass;
+	tbl[idx++].data = &ipvs->sysctl_expire_nodest_conn;
+	tbl[idx++].data = &ipvs->sysctl_expire_quiescent_template;
+	ipvs->sysctl_sync_threshold[0] = 3;
+	ipvs->sysctl_sync_threshold[1] = 50;
+	tbl[idx].data = &ipvs->sysctl_sync_threshold;
+	tbl[idx++].maxlen = sizeof(ipvs->sysctl_sync_threshold);
+	tbl[idx++].data = &ipvs->sysctl_nat_icmp_send;
+
+
+	ipvs->sysctl_hdr = register_net_sysctl_table(net, net_vs_ctl_path,
 						  vs_vars);
-	if (sysctl_header == NULL)
+	if (ipvs->sysctl_hdr == NULL)
 		goto err_reg;
 	ip_vs_new_estimator(net, ipvs->tot_stats);
+	ipvs->sysctl_tbl = tbl;
 	return 0;
 
 err_reg:
+	if (!net_eq(net, &init_net))
+		kfree(tbl);
+err_dup:
 	free_percpu(ipvs->cpustats);
 err_alloc:
 	kfree(ipvs->tot_stats);
@@ -3575,7 +3584,7 @@ static void __net_exit __ip_vs_control_cleanup(struct net *net)
 		return;
 
 	ip_vs_kill_estimator(net, ipvs->tot_stats);
-	unregister_net_sysctl_table(sysctl_header);
+	unregister_net_sysctl_table(ipvs->sysctl_hdr);
 	proc_net_remove(net, "ip_vs_stats_percpu");
 	proc_net_remove(net, "ip_vs_stats");
 	proc_net_remove(net, "ip_vs");
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 550365a..fb2d04a 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -34,7 +34,7 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 				     &iph.daddr, sh->dest))) {
 		int ignored;
 
-		if (ip_vs_todrop()) {
+		if (ip_vs_todrop(net_ipvs(net))) {
 			/*
 			 * It seems that we are very loaded.
 			 * We have to drop this packet :(
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index d8b3f9f..c0cc341 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -54,7 +54,7 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 				     &iph.daddr, th->dest))) {
 		int ignored;
 
-		if (ip_vs_todrop()) {
+		if (ip_vs_todrop(net_ipvs(net))) {
 			/*
 			 * It seems that we are very loaded.
 			 * We have to drop this packet :(
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 581157b..f1282cb 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -50,7 +50,7 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	if (svc) {
 		int ignored;
 
-		if (ip_vs_todrop()) {
+		if (ip_vs_todrop(net_ipvs(net))) {
 			/*
 			 * It seems that we are very loaded.
 			 * We have to drop this packet :(
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index f85e47d..b178056 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -394,7 +394,7 @@ void ip_vs_sync_switch_mode(struct net *net, int mode)
 
 	if (!ipvs->sync_state & IP_VS_STATE_MASTER)
 		return;
-	if (mode == sysctl_ip_vs_sync_ver || !ipvs->sync_buff)
+	if (mode == ipvs->sysctl_sync_ver || !ipvs->sync_buff)
 		return;
 
 	spin_lock_bh(&ipvs->sync_buff_lock);
@@ -521,7 +521,7 @@ void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp)
 	unsigned int len, pe_name_len, pad;
 
 	/* Handle old version of the protocol */
-	if (sysctl_ip_vs_sync_ver == 0) {
+	if (ipvs->sysctl_sync_ver == 0) {
 		ip_vs_sync_conn_v0(net, cp);
 		return;
 	}
@@ -650,7 +650,7 @@ control:
 	if (cp->flags & IP_VS_CONN_F_TEMPLATE) {
 		int pkts = atomic_add_return(1, &cp->in_pkts);
 
-		if (pkts % sysctl_ip_vs_sync_threshold[1] != 1)
+		if (pkts % ipvs->sysctl_sync_threshold[1] != 1)
 			return;
 	}
 	goto sloop;
@@ -724,6 +724,7 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 {
 	struct ip_vs_dest *dest;
 	struct ip_vs_conn *cp;
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	if (!(flags & IP_VS_CONN_F_TEMPLATE))
 		cp = ip_vs_conn_in_get(param);
@@ -794,7 +795,7 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 
 	if (opt)
 		memcpy(&cp->in_seq, opt, sizeof(*opt));
-	atomic_set(&cp->in_pkts, sysctl_ip_vs_sync_threshold[0]);
+	atomic_set(&cp->in_pkts, ipvs->sysctl_sync_threshold[0]);
 	cp->state = state;
 	cp->old_state = cp->state;
 	/*
-- 
1.7.2.3

