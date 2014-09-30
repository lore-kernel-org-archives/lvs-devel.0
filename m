From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] ipvs: Clean up comment style in ip_vs.h
Date: Tue, 30 Sep 2014 10:50:06 +0900
Message-ID: <1412041806-9480-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Miller <davem@davemloft.net>, Pablo Neira Ayuso <pablo@netfilter.org>, Simon Horman <horms@verge.net.au>

* Consistently use the multi-line comment style for networking code:

  /* This
   * That
   * The other thing
   */

* Use single-line comment style for comments with only one line of text.

* In general follow the leading '*' of each line of a comment with a
  single space and then text.

Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h | 183 ++++++++++++++++++----------------------------------
 1 file changed, 61 insertions(+), 122 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 576d7f0..af69086 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1,6 +1,5 @@
-/*
- *      IP Virtual Server
- *      data structure and functionality definitions
+/* IP Virtual Server
+ * data structure and functionality definitions
  */
 
 #ifndef _NET_IP_VS_H
@@ -30,15 +29,12 @@
 #endif
 #include <net/net_namespace.h>		/* Netw namespace */
 
-/*
- * Generic access of ipvs struct
- */
+/* Generic access of ipvs struct */
 static inline struct netns_ipvs *net_ipvs(struct net* net)
 {
 	return net->ipvs;
 }
-/*
- * Get net ptr from skb in traffic cases
+/* Get net ptr from skb in traffic cases
  * use skb_sknet when call is from userland (ioctl or netlink)
  */
 static inline struct net *skb_net(const struct sk_buff *skb)
@@ -90,8 +86,7 @@ static inline struct net *skb_sknet(const struct sk_buff *skb)
 	return &init_net;
 #endif
 }
-/*
- * This one needed for single_open_net since net is stored directly in
+/* This one needed for single_open_net since net is stored directly in
  * private not as a struct i.e. seq_file_net can't be used.
  */
 static inline struct net *seq_file_single_net(struct seq_file *seq)
@@ -108,7 +103,7 @@ extern int ip_vs_conn_tab_size;
 
 struct ip_vs_iphdr {
 	__u32 len;	/* IPv4 simply where L4 starts
-			   IPv6 where L4 Transport Header starts */
+			 * IPv6 where L4 Transport Header starts */
 	__u16 fragoffs; /* IPv6 fragment offset, 0 if first frag (or not frag)*/
 	__s16 protocol;
 	__s32 flags;
@@ -305,15 +300,11 @@ static inline const char *ip_vs_dbg_addr(int af, char *buf, size_t buf_len,
 #endif
 
 
-/*
- *      The port number of FTP service (in network order).
- */
+/* The port number of FTP service (in network order). */
 #define FTPPORT  cpu_to_be16(21)
 #define FTPDATA  cpu_to_be16(20)
 
-/*
- *      TCP State Values
- */
+/* TCP State Values */
 enum {
 	IP_VS_TCP_S_NONE = 0,
 	IP_VS_TCP_S_ESTABLISHED,
@@ -329,25 +320,19 @@ enum {
 	IP_VS_TCP_S_LAST
 };
 
-/*
- *	UDP State Values
- */
+/* UDP State Values */
 enum {
 	IP_VS_UDP_S_NORMAL,
 	IP_VS_UDP_S_LAST,
 };
 
-/*
- *	ICMP State Values
- */
+/* ICMP State Values */
 enum {
 	IP_VS_ICMP_S_NORMAL,
 	IP_VS_ICMP_S_LAST,
 };
 
-/*
- *	SCTP State Values
- */
+/* SCTP State Values */
 enum ip_vs_sctp_states {
 	IP_VS_SCTP_S_NONE,
 	IP_VS_SCTP_S_INIT1,
@@ -366,10 +351,9 @@ enum ip_vs_sctp_states {
 	IP_VS_SCTP_S_LAST
 };
 
-/*
- *	Delta sequence info structure
- *	Each ip_vs_conn has 2 (output AND input seq. changes).
- *      Only used in the VS/NAT.
+/* Delta sequence info structure
+ * Each ip_vs_conn has 2 (output AND input seq. changes).
+ * Only used in the VS/NAT.
  */
 struct ip_vs_seq {
 	__u32			init_seq;	/* Add delta from this seq */
@@ -378,9 +362,7 @@ struct ip_vs_seq {
 						   before last resized pkt */
 };
 
-/*
- * counters per cpu
- */
+/* counters per cpu */
 struct ip_vs_counters {
 	__u32		conns;		/* connections scheduled */
 	__u32		inpkts;		/* incoming packets */
@@ -388,17 +370,13 @@ struct ip_vs_counters {
 	__u64		inbytes;	/* incoming bytes */
 	__u64		outbytes;	/* outgoing bytes */
 };
-/*
- * Stats per cpu
- */
+/* Stats per cpu */
 struct ip_vs_cpu_stats {
 	struct ip_vs_counters   ustats;
 	struct u64_stats_sync   syncp;
 };
 
-/*
- *	IPVS statistics objects
- */
+/* IPVS statistics objects */
 struct ip_vs_estimator {
 	struct list_head	list;
 
@@ -491,9 +469,7 @@ struct ip_vs_protocol {
 	void (*timeout_change)(struct ip_vs_proto_data *pd, int flags);
 };
 
-/*
- * protocol data per netns
- */
+/* protocol data per netns */
 struct ip_vs_proto_data {
 	struct ip_vs_proto_data	*next;
 	struct ip_vs_protocol	*pp;
@@ -520,9 +496,7 @@ struct ip_vs_conn_param {
 	__u8				pe_data_len;
 };
 
-/*
- *	IP_VS structure allocated for each dynamically scheduled connection
- */
+/* IP_VS structure allocated for each dynamically scheduled connection */
 struct ip_vs_conn {
 	struct hlist_node	c_list;         /* hashed list heads */
 	/* Protocol, addresses and port numbers */
@@ -570,8 +544,9 @@ struct ip_vs_conn {
 			   struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
 
 	/* Note: we can group the following members into a structure,
-	   in order to save more space, and the following members are
-	   only used in VS/NAT anyway */
+	 * in order to save more space, and the following members are
+	 * only used in VS/NAT anyway
+	 */
 	struct ip_vs_app        *app;           /* bound ip_vs_app object */
 	void                    *app_data;      /* Application private data */
 	struct ip_vs_seq        in_seq;         /* incoming seq. struct */
@@ -584,9 +559,7 @@ struct ip_vs_conn {
 	struct rcu_head		rcu_head;
 };
 
-/*
- *  To save some memory in conn table when name space is disabled.
- */
+/* To save some memory in conn table when name space is disabled. */
 static inline struct net *ip_vs_conn_net(const struct ip_vs_conn *cp)
 {
 #ifdef CONFIG_NET_NS
@@ -612,13 +585,12 @@ static inline int ip_vs_conn_net_eq(const struct ip_vs_conn *cp,
 #endif
 }
 
-/*
- *	Extended internal versions of struct ip_vs_service_user and
- *	ip_vs_dest_user for IPv6 support.
+/* Extended internal versions of struct ip_vs_service_user and
+ * ip_vs_dest_user for IPv6 support.
  *
- *	We need these to conveniently pass around service and destination
- *	options, but unfortunately, we also need to keep the old definitions to
- *	maintain userspace backwards compatibility for the setsockopt interface.
+ * We need these to conveniently pass around service and destination
+ * options, but unfortunately, we also need to keep the old definitions to
+ * maintain userspace backwards compatibility for the setsockopt interface.
  */
 struct ip_vs_service_user_kern {
 	/* virtual service addresses */
@@ -697,9 +669,8 @@ struct ip_vs_dest_dst {
 	struct rcu_head		rcu_head;
 };
 
-/*
- *	The real server destination forwarding entry
- *	with ip address, port number, and so on.
+/* The real server destination forwarding entry
+ * with ip address, port number, and so on.
  */
 struct ip_vs_dest {
 	struct list_head	n_list;   /* for the dests in the service */
@@ -739,9 +710,7 @@ struct ip_vs_dest {
 };
 
 
-/*
- *	The scheduler object
- */
+/* The scheduler object */
 struct ip_vs_scheduler {
 	struct list_head	n_list;		/* d-linked list head */
 	char			*name;		/* scheduler name */
@@ -781,9 +750,7 @@ struct ip_vs_pe {
 	int (*show_pe_data)(const struct ip_vs_conn *cp, char *buf);
 };
 
-/*
- *	The application module object (a.k.a. app incarnation)
- */
+/* The application module object (a.k.a. app incarnation) */
 struct ip_vs_app {
 	struct list_head	a_list;		/* member in app list */
 	int			type;		/* IP_VS_APP_TYPE_xxx */
@@ -799,16 +766,14 @@ struct ip_vs_app {
 	atomic_t		usecnt;		/* usage counter */
 	struct rcu_head		rcu_head;
 
-	/*
-	 * output hook: Process packet in inout direction, diff set for TCP.
+	/* output hook: Process packet in inout direction, diff set for TCP.
 	 * Return: 0=Error, 1=Payload Not Mangled/Mangled but checksum is ok,
 	 *	   2=Mangled but checksum was not updated
 	 */
 	int (*pkt_out)(struct ip_vs_app *, struct ip_vs_conn *,
 		       struct sk_buff *, int *diff);
 
-	/*
-	 * input hook: Process packet in outin direction, diff set for TCP.
+	/* input hook: Process packet in outin direction, diff set for TCP.
 	 * Return: 0=Error, 1=Payload Not Mangled/Mangled but checksum is ok,
 	 *	   2=Mangled but checksum was not updated
 	 */
@@ -867,9 +832,7 @@ struct ipvs_master_sync_state {
 struct netns_ipvs {
 	int			gen;		/* Generation */
 	int			enable;		/* enable like nf_hooks do */
-	/*
-	 *	Hash table: for real service lookups
-	 */
+	/* Hash table: for real service lookups */
 	#define IP_VS_RTAB_BITS 4
 	#define IP_VS_RTAB_SIZE (1 << IP_VS_RTAB_BITS)
 	#define IP_VS_RTAB_MASK (IP_VS_RTAB_SIZE - 1)
@@ -903,7 +866,7 @@ struct netns_ipvs {
 	struct list_head	sctp_apps[SCTP_APP_TAB_SIZE];
 #endif
 	/* ip_vs_conn */
-	atomic_t		conn_count;      /*  connection counter */
+	atomic_t		conn_count;      /* connection counter */
 
 	/* ip_vs_ctl */
 	struct ip_vs_stats		tot_stats;  /* Statistics & est. */
@@ -992,7 +955,8 @@ struct netns_ipvs {
 	struct net		*net;            /* Needed by timer routines */
 	/* Number of heterogeneous destinations, needed because
 	 * heterogeneous are not supported when synchronization is
-	 * enabled */
+	 * enabled
+	 */
 	unsigned int		mixed_address_family_dests;
 };
 
@@ -1147,9 +1111,8 @@ static inline int sysctl_backup_only(struct netns_ipvs *ipvs)
 
 #endif
 
-/*
- *      IPVS core functions
- *      (from ip_vs_core.c)
+/* IPVS core functions
+ * (from ip_vs_core.c)
  */
 const char *ip_vs_proto_name(unsigned int proto);
 void ip_vs_init_hash_table(struct list_head *table, int rows);
@@ -1157,11 +1120,9 @@ void ip_vs_init_hash_table(struct list_head *table, int rows);
 
 #define IP_VS_APP_TYPE_FTP	1
 
-/*
- *     ip_vs_conn handling functions
- *     (from ip_vs_conn.c)
+/* ip_vs_conn handling functions
+ * (from ip_vs_conn.c)
  */
-
 enum {
 	IP_VS_DIR_INPUT = 0,
 	IP_VS_DIR_OUTPUT,
@@ -1292,9 +1253,7 @@ ip_vs_control_add(struct ip_vs_conn *cp, struct ip_vs_conn *ctl_cp)
 	atomic_inc(&ctl_cp->n_control);
 }
 
-/*
- * IPVS netns init & cleanup functions
- */
+/* IPVS netns init & cleanup functions */
 int ip_vs_estimator_net_init(struct net *net);
 int ip_vs_control_net_init(struct net *net);
 int ip_vs_protocol_net_init(struct net *net);
@@ -1309,9 +1268,8 @@ void ip_vs_estimator_net_cleanup(struct net *net);
 void ip_vs_sync_net_cleanup(struct net *net);
 void ip_vs_service_net_cleanup(struct net *net);
 
-/*
- *      IPVS application functions
- *      (from ip_vs_app.c)
+/* IPVS application functions
+ * (from ip_vs_app.c)
  */
 #define IP_VS_APP_MAX_PORTS  8
 struct ip_vs_app *register_ip_vs_app(struct net *net, struct ip_vs_app *app);
@@ -1331,9 +1289,7 @@ int unregister_ip_vs_pe(struct ip_vs_pe *pe);
 struct ip_vs_pe *ip_vs_pe_getbyname(const char *name);
 struct ip_vs_pe *__ip_vs_pe_getbyname(const char *pe_name);
 
-/*
- * Use a #define to avoid all of module.h just for these trivial ops
- */
+/* Use a #define to avoid all of module.h just for these trivial ops */
 #define ip_vs_pe_get(pe)			\
 	if (pe && pe->module)			\
 		__module_get(pe->module);
@@ -1342,9 +1298,7 @@ struct ip_vs_pe *__ip_vs_pe_getbyname(const char *pe_name);
 	if (pe && pe->module)			\
 		module_put(pe->module);
 
-/*
- *	IPVS protocol functions (from ip_vs_proto.c)
- */
+/* IPVS protocol functions (from ip_vs_proto.c) */
 int ip_vs_protocol_init(void);
 void ip_vs_protocol_cleanup(void);
 void ip_vs_protocol_timeout_change(struct netns_ipvs *ipvs, int flags);
@@ -1362,9 +1316,8 @@ extern struct ip_vs_protocol ip_vs_protocol_esp;
 extern struct ip_vs_protocol ip_vs_protocol_ah;
 extern struct ip_vs_protocol ip_vs_protocol_sctp;
 
-/*
- *      Registering/unregistering scheduler functions
- *      (from ip_vs_sched.c)
+/* Registering/unregistering scheduler functions
+ * (from ip_vs_sched.c)
  */
 int register_ip_vs_scheduler(struct ip_vs_scheduler *scheduler);
 int unregister_ip_vs_scheduler(struct ip_vs_scheduler *scheduler);
@@ -1384,9 +1337,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 void ip_vs_scheduler_err(struct ip_vs_service *svc, const char *msg);
 
 
-/*
- *      IPVS control data and functions (from ip_vs_ctl.c)
- */
+/* IPVS control data and functions (from ip_vs_ctl.c) */
 extern struct ip_vs_stats ip_vs_stats;
 extern int sysctl_ip_vs_sync_ver;
 
@@ -1427,26 +1378,21 @@ static inline void ip_vs_dest_put_and_free(struct ip_vs_dest *dest)
 		kfree(dest);
 }
 
-/*
- *      IPVS sync daemon data and function prototypes
- *      (from ip_vs_sync.c)
+/* IPVS sync daemon data and function prototypes
+ * (from ip_vs_sync.c)
  */
 int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid);
 int stop_sync_thread(struct net *net, int state);
 void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp, int pkts);
 
-/*
- *      IPVS rate estimator prototypes (from ip_vs_est.c)
- */
+/* IPVS rate estimator prototypes (from ip_vs_est.c) */
 void ip_vs_start_estimator(struct net *net, struct ip_vs_stats *stats);
 void ip_vs_stop_estimator(struct net *net, struct ip_vs_stats *stats);
 void ip_vs_zero_estimator(struct ip_vs_stats *stats);
 void ip_vs_read_estimator(struct ip_vs_stats_user *dst,
 			  struct ip_vs_stats *stats);
 
-/*
- *	Various IPVS packet transmitters (from ip_vs_xmit.c)
- */
+/* Various IPVS packet transmitters (from ip_vs_xmit.c) */
 int ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		    struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
 int ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
@@ -1477,10 +1423,9 @@ int ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 #endif
 
 #ifdef CONFIG_SYSCTL
-/*
- *	This is a simple mechanism to ignore packets when
- *	we are loaded. Just set ip_vs_drop_rate to 'n' and
- *	we start to drop 1/rate of the packets
+/* This is a simple mechanism to ignore packets when
+ * we are loaded. Just set ip_vs_drop_rate to 'n' and
+ * we start to drop 1/rate of the packets
  */
 
 static inline int ip_vs_todrop(struct netns_ipvs *ipvs)
@@ -1496,9 +1441,7 @@ static inline int ip_vs_todrop(struct netns_ipvs *ipvs)
 static inline int ip_vs_todrop(struct netns_ipvs *ipvs) { return 0; }
 #endif
 
-/*
- *      ip_vs_fwd_tag returns the forwarding tag of the connection
- */
+/* ip_vs_fwd_tag returns the forwarding tag of the connection */
 #define IP_VS_FWD_METHOD(cp)  (cp->flags & IP_VS_CONN_F_FWD_MASK)
 
 static inline char ip_vs_fwd_tag(struct ip_vs_conn *cp)
@@ -1557,9 +1500,7 @@ static inline __wsum ip_vs_check_diff2(__be16 old, __be16 new, __wsum oldsum)
 	return csum_partial(diff, sizeof(diff), oldsum);
 }
 
-/*
- * Forget current conntrack (unconfirmed) and attach notrack entry
- */
+/* Forget current conntrack (unconfirmed) and attach notrack entry */
 static inline void ip_vs_notrack(struct sk_buff *skb)
 {
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
@@ -1576,8 +1517,7 @@ static inline void ip_vs_notrack(struct sk_buff *skb)
 }
 
 #ifdef CONFIG_IP_VS_NFCT
-/*
- *      Netfilter connection tracking
+/*      Netfilter connection tracking
  *      (from ip_vs_nfct.c)
  */
 static inline int ip_vs_conntrack_enabled(struct netns_ipvs *ipvs)
@@ -1623,8 +1563,7 @@ static inline void ip_vs_conn_drop_conntrack(struct ip_vs_conn *cp)
 static inline int
 ip_vs_dest_conn_overhead(struct ip_vs_dest *dest)
 {
-	/*
-	 * We think the overhead of processing active connections is 256
+	/* We think the overhead of processing active connections is 256
 	 * times higher than that of inactive connections in average. (This
 	 * 256 times might not be accurate, we will change it later) We
 	 * use the following formula to estimate the overhead now:
-- 
2.1.0

