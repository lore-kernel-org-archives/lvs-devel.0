From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [RFC PATCH 2/9] ipvs network name space aware
Date: Fri, 8 Oct 2010 13:16:53 +0200
Message-ID: <201010081316.54676.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr

This part contains the include files
where include/net/netns/ip_vs.h is new and contains all moved vars.

SUMMARY

 include/net/ip_vs.h                     |  136 ++++---
 include/net/net_namespace.h             |    2 +
 include/net/netns/ip_vs.h               |  112 +++++

Signed-off-by:Hans Schillstrom <hans.schillstrom@ericsson.com>
---

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index b17f863..b40a0fb 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -288,6 +288,7 @@ struct iphdr;
 struct ip_vs_conn;
 struct ip_vs_app;
 struct sk_buff;
+struct ip_vs_proto_data;

 struct ip_vs_protocol {
 	struct ip_vs_protocol	*next;
@@ -302,6 +303,10 @@ struct ip_vs_protocol {

 	void (*exit)(struct ip_vs_protocol *pp);

+	void (*init_netns)(struct net *net, struct ip_vs_proto_data *pd);
+
+	void (*exit_netns)(struct net *net, struct ip_vs_proto_data *pd);
+
 	int (*conn_schedule)(int af, struct sk_buff *skb,
 			     struct ip_vs_protocol *pp,
 			     int *verdict, struct ip_vs_conn **cpp);
@@ -337,11 +342,11 @@ struct ip_vs_protocol {
 				const struct sk_buff *skb,
 				struct ip_vs_protocol *pp);

-	int (*register_app)(struct ip_vs_app *inc);
+	int (*register_app)(struct net *net, struct ip_vs_app *inc);

-	void (*unregister_app)(struct ip_vs_app *inc);
+	void (*unregister_app)(struct net *net, struct ip_vs_app *inc);

-	int (*app_conn_bind)(struct ip_vs_conn *cp);
+	int (*app_conn_bind)(struct net *net, struct ip_vs_conn *cp);

 	void (*debug_packet)(struct ip_vs_protocol *pp,
 			     const struct sk_buff *skb,
@@ -350,10 +355,24 @@ struct ip_vs_protocol {

 	void (*timeout_change)(struct ip_vs_protocol *pp, int flags);

-	int (*set_state_timeout)(struct ip_vs_protocol *pp, char *sname, int to);
+	/*
+	 int (*set_state_timeout)(struct ip_vs_protocol *pp,
+	                          char *sname,
+	                          int to);    Not used  -Hans S */
+};
+/*
+ * protocol data per netns
+ */
+struct ip_vs_proto_data {
+	struct ip_vs_proto_data	*next;
+	struct ip_vs_protocol   *pp;
+	int			*timeout_table;	/* protocol timeout table */
+	atomic_t		appcnt;		/* counter of proto app incs. */
 };

-extern struct ip_vs_protocol * ip_vs_proto_get(unsigned short proto);
+extern struct ip_vs_protocol   * ip_vs_proto_get(unsigned short proto);
+extern struct ip_vs_proto_data * ip_vs_proto_data_get(struct net *net,
+						      unsigned short proto);

 /*
  *	IP_VS structure allocated for each dynamically scheduled connection
@@ -398,6 +417,8 @@ struct ip_vs_conn {
 	int (*packet_xmit)(struct sk_buff *skb, struct ip_vs_conn *cp,
 			   struct ip_vs_protocol *pp);

+	struct net		*net;		/* netns ptr needed in timer */
+
 	/* Note: we can group the following members into a structure,
 	   in order to save more space, and the following members are
 	   only used in VS/NAT anyway */
@@ -628,29 +649,32 @@ enum {
 	IP_VS_DIR_LAST,
 };

-extern struct ip_vs_conn *ip_vs_conn_in_get
-(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
- const union nf_inet_addr *d_addr, __be16 d_port);
+extern struct ip_vs_conn *
+ip_vs_conn_in_get(struct net *net, int af, int protocol,
+		  const union nf_inet_addr *s_addr, __be16 s_port,
+		  const union nf_inet_addr *d_addr, __be16 d_port);

-extern struct ip_vs_conn *ip_vs_ct_in_get
-(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
- const union nf_inet_addr *d_addr, __be16 d_port);
+extern struct ip_vs_conn *
+ip_vs_ct_in_get(struct net *net, int af, int protocol,
+		const union nf_inet_addr *s_addr, __be16 s_port,
+		const union nf_inet_addr *d_addr, __be16 d_port);

-struct ip_vs_conn * ip_vs_conn_in_get_proto(int af, const struct sk_buff *skb,
-					    struct ip_vs_protocol *pp,
-					    const struct ip_vs_iphdr *iph,
-					    unsigned int proto_off,
-					    int inverse);
+struct ip_vs_conn *
+ip_vs_conn_in_get_proto(int af, const struct sk_buff *skb,
+			struct ip_vs_protocol *pp,
+			const struct ip_vs_iphdr *iph,
+			unsigned int proto_off, int inverse);

-extern struct ip_vs_conn *ip_vs_conn_out_get
-(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
- const union nf_inet_addr *d_addr, __be16 d_port);
+extern struct ip_vs_conn *
+ip_vs_conn_out_get(struct net *net,int af, int protocol,
+		   const union nf_inet_addr *s_addr, __be16 s_port,
+		   const union nf_inet_addr *d_addr, __be16 d_port);

-struct ip_vs_conn * ip_vs_conn_out_get_proto(int af, const struct sk_buff *skb,
-					     struct ip_vs_protocol *pp,
-					     const struct ip_vs_iphdr *iph,
-					     unsigned int proto_off,
-					     int inverse);
+struct ip_vs_conn *
+ip_vs_conn_out_get_proto(int af, const struct sk_buff *skb,
+			 struct ip_vs_protocol *pp,
+			 const struct ip_vs_iphdr *iph,
+			 unsigned int proto_off, int inverse);

 /* put back the conn without restarting its timer */
 static inline void __ip_vs_conn_put(struct ip_vs_conn *cp)
@@ -658,20 +682,22 @@ static inline void __ip_vs_conn_put(struct ip_vs_conn *cp)
 	atomic_dec(&cp->refcnt);
 }
 extern void ip_vs_conn_put(struct ip_vs_conn *cp);
-extern void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport);
+extern void
+ip_vs_conn_fill_cport(struct net *net, struct ip_vs_conn *cp, __be16 cport);

 extern struct ip_vs_conn *
-ip_vs_conn_new(int af, int proto, const union nf_inet_addr *caddr, __be16 cport,
+ip_vs_conn_new(struct net *net, int af, int proto,
+	       const union nf_inet_addr *caddr, __be16 cport,
 	       const union nf_inet_addr *vaddr, __be16 vport,
-	       const union nf_inet_addr *daddr, __be16 dport, unsigned flags,
-	       struct ip_vs_dest *dest);
+	       const union nf_inet_addr *daddr, __be16 dport,
+	       unsigned flags, struct ip_vs_dest *dest);
 extern void ip_vs_conn_expire_now(struct ip_vs_conn *cp);

 extern const char * ip_vs_state_name(__u16 proto, int state);

-extern void ip_vs_tcp_conn_listen(struct ip_vs_conn *cp);
-extern int ip_vs_check_template(struct ip_vs_conn *ct);
-extern void ip_vs_random_dropentry(void);
+extern void ip_vs_tcp_conn_listen(struct net *net, struct ip_vs_conn *cp);
+extern int ip_vs_check_template(struct net *net, struct ip_vs_conn *ct);
+extern void ip_vs_random_dropentry(struct net *net);
 extern int ip_vs_conn_init(void);
 extern void ip_vs_conn_cleanup(void);

@@ -741,12 +767,15 @@ ip_vs_control_add(struct ip_vs_conn *cp, struct ip_vs_conn *ctl_cp)
  *      (from ip_vs_app.c)
  */
 #define IP_VS_APP_MAX_PORTS  8
-extern int register_ip_vs_app(struct ip_vs_app *app);
-extern void unregister_ip_vs_app(struct ip_vs_app *app);
-extern int ip_vs_bind_app(struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
+extern int register_ip_vs_app(struct net *net, struct ip_vs_app *app);
+extern void unregister_ip_vs_app(struct net *net, struct ip_vs_app *app);
+extern int ip_vs_bind_app(struct net *net, struct ip_vs_conn *cp,
+		          struct ip_vs_protocol *pp);
 extern void ip_vs_unbind_app(struct ip_vs_conn *cp);
-extern int
-register_ip_vs_app_inc(struct ip_vs_app *app, __u16 proto, __u16 port);
+extern int register_ip_vs_app_inc(struct net *net,
+				  struct ip_vs_app *app,
+				  __u16 proto,
+				  __u16 port);
 extern int ip_vs_app_inc_get(struct ip_vs_app *inc);
 extern void ip_vs_app_inc_put(struct ip_vs_app *inc);

@@ -762,7 +791,7 @@ extern void ip_vs_app_cleanup(void);
 extern int ip_vs_protocol_init(void);
 extern void ip_vs_protocol_cleanup(void);
 extern void ip_vs_protocol_timeout_change(int flags);
-extern int *ip_vs_create_timeout_table(int *table, int size);
+extern int *ip_vs_create_timeout_table(const int *table, int size);
 extern int
 ip_vs_set_state_timeout(int *table, int num, const char *const *names,
 			const char *name, int to);
@@ -806,7 +835,7 @@ extern struct ip_vs_stats ip_vs_stats;
 extern const struct ctl_path net_vs_ctl_path[];

 extern struct ip_vs_service *
-ip_vs_service_get(int af, __u32 fwmark, __u16 protocol,
+ip_vs_service_get(struct net *net, int af, __u32 fwmark, __u16 protocol,
 		  const union nf_inet_addr *vaddr, __be16 vport);

 static inline void ip_vs_service_put(struct ip_vs_service *svc)
@@ -815,7 +844,7 @@ static inline void ip_vs_service_put(struct ip_vs_service *svc)
 }

 extern struct ip_vs_dest *
-ip_vs_lookup_real_service(int af, __u16 protocol,
+ip_vs_lookup_real_service(struct net *net, int af, __u16 protocol,
 			  const union nf_inet_addr *daddr, __be16 dport);

 extern int ip_vs_use_count_inc(void);
@@ -823,23 +852,22 @@ extern void ip_vs_use_count_dec(void);
 extern int ip_vs_control_init(void);
 extern void ip_vs_control_cleanup(void);
 extern struct ip_vs_dest *
-ip_vs_find_dest(int af, const union nf_inet_addr *daddr, __be16 dport,
+ip_vs_find_dest(struct net *net, int af,
+		const union nf_inet_addr *daddr, __be16 dport,
 		const union nf_inet_addr *vaddr, __be16 vport, __u16 protocol);
-extern struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp);
-
+extern struct ip_vs_dest *ip_vs_try_bind_dest(struct net *net,
+		                              struct ip_vs_conn *cp);

 /*
  *      IPVS sync daemon data and function prototypes
  *      (from ip_vs_sync.c)
  */
-extern volatile int ip_vs_sync_state;
-extern volatile int ip_vs_master_syncid;
-extern volatile int ip_vs_backup_syncid;
-extern char ip_vs_master_mcast_ifn[IP_VS_IFNAME_MAXLEN];
-extern char ip_vs_backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
-extern int start_sync_thread(int state, char *mcast_ifn, __u8 syncid);
-extern int stop_sync_thread(int state);
-extern void ip_vs_sync_conn(struct ip_vs_conn *cp);
+extern int start_sync_thread(struct net *net, int state, char *mcast_ifn,
+		             __u8 syncid);
+extern int stop_sync_thread(struct net *net, int state);
+extern void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp);
+extern int ip_vs_sync_init(void);
+extern void ip_vs_sync_cleanup(void);


 /*
@@ -847,8 +875,8 @@ extern void ip_vs_sync_conn(struct ip_vs_conn *cp);
  */
 extern int ip_vs_estimator_init(void);
 extern void ip_vs_estimator_cleanup(void);
-extern void ip_vs_new_estimator(struct ip_vs_stats *stats);
-extern void ip_vs_kill_estimator(struct ip_vs_stats *stats);
+extern void ip_vs_new_estimator(struct net *net, struct ip_vs_stats *stats);
+extern void ip_vs_kill_estimator(struct net *net, struct ip_vs_stats *stats);
 extern void ip_vs_zero_estimator(struct ip_vs_stats *stats);

 /*
@@ -864,8 +892,8 @@ extern int ip_vs_tunnel_xmit
 (struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
 extern int ip_vs_dr_xmit
 (struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
-extern int ip_vs_icmp_xmit
-(struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp, int offset);
+extern int ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
+		           struct ip_vs_protocol *pp, int offset);
 extern void ip_vs_dst_reset(struct ip_vs_dest *dest);

 #ifdef CONFIG_IP_VS_IPV6
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index bd10a79..b59cdc5 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -15,6 +15,7 @@
 #include <net/netns/ipv4.h>
 #include <net/netns/ipv6.h>
 #include <net/netns/dccp.h>
+#include <net/netns/ip_vs.h>
 #include <net/netns/x_tables.h>
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 #include <net/netns/conntrack.h>
@@ -91,6 +92,7 @@ struct net {
 	struct sk_buff_head	wext_nlevents;
 #endif
 	struct net_generic	*gen;
+	struct netns_ipvs       *ipvs;
 };


diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
new file mode 100644
index 0000000..540ac90
--- /dev/null
+++ b/include/net/netns/ip_vs.h
@@ -0,0 +1,112 @@
+#ifndef __NETNS_IP_VS_H_
+#define __NETNS_IP_VS_H_
+
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/list_nulls.h>
+#include <linux/ip_vs.h>
+#include <asm/atomic.h>
+#include <linux/in.h>
+
+struct ip_vs_stats;
+struct ip_vs_sync_buff;
+struct ctl_table_header;
+
+struct netns_ipvs {
+	int			inc;		/* incarnation */
+	/* ip_vs_app */
+	struct list_head 	app_list;
+	struct mutex		app_mutex;
+	struct lock_class_key 	app_key;	/* Grrr, for mutex debuging */
+	/* ip_vs_conn */
+	unsigned char           conn_cname[20];	/* Connection hash name */
+	struct list_head 	*conn_tab;	/* Connection hash: for in and output packets */
+	struct kmem_cache 	*conn_cachep;	/* SLAB cache for IPVS connections */
+	atomic_t 		conn_count;	/* counter for current IPVS connections */
+	atomic_t 		conn_no_cport_cnt; /* counter for no client port connections */
+	unsigned int 		conn_rnd;	/* random value for IPVS connection hash */
+	/* ip_vs_ctl */
+	struct ip_vs_stats 	*ctl_stats;	/* Statistics & estimator */
+	/*	Hash table: for virtual service lookups */
+	#define IP_VS_SVC_TAB_BITS 8
+	#define IP_VS_SVC_TAB_SIZE (1 << IP_VS_SVC_TAB_BITS)
+	#define IP_VS_SVC_TAB_MASK (IP_VS_SVC_TAB_SIZE - 1)
+	/* the service table hashed by <protocol, addr, port> */
+	struct list_head 	ctl_svc_table[IP_VS_SVC_TAB_SIZE];
+	/* the service table hashed by fwmark */
+	struct list_head 	ctl_fwm_table[IP_VS_SVC_TAB_SIZE];
+	/* Hash table: for real service lookups */
+	#define IP_VS_RTAB_BITS 4
+	#define IP_VS_RTAB_SIZE (1 << IP_VS_RTAB_BITS)
+	#define IP_VS_RTAB_MASK (IP_VS_RTAB_SIZE - 1)
+	struct list_head 	ctl_rtable[IP_VS_RTAB_SIZE]; /* Hash table: for real service  */
+	struct list_head	ctl_dest_trash;	    /* Trash for destinations */
+	atomic_t 		ctl_ftpsvc_counter;
+	atomic_t 		ctl_nullsvc_counter;
+	/* sys-ctl struct */
+	struct ctl_table_header	*sysctl_hdr;
+	struct ctl_table	*sysctl_tbl;
+	/* sysctl variables */
+	int 			sysctl_amemthresh;
+	int 			sysctl_am_droprate;
+	int 			sysctl_drop_entry;
+	int 			sysctl_drop_packet;
+	int 			sysctl_secure_tcp;
+	int 			sysctl_cache_bypass;
+	int 			sysctl_expire_nodest_conn;
+	int 			sysctl_expire_quiescent_template;
+	int 			sysctl_sync_threshold[2];
+	int 			sysctl_nat_icmp_send;
+	/* ip_vs_proto */
+	#define IP_VS_PROTO_TAB_SIZE		32	/* must be power of 2 */
+	struct ip_vs_proto_data *proto_data_table[IP_VS_PROTO_TAB_SIZE];
+	/* ip_vs_proto_tcp */
+#ifdef CONFIG_IP_VS_PROTO_TCP
+	#define	TCP_APP_TAB_BITS	4
+	#define	TCP_APP_TAB_SIZE	(1 << TCP_APP_TAB_BITS)
+	#define	TCP_APP_TAB_MASK	(TCP_APP_TAB_SIZE - 1)
+	struct list_head 	tcp_apps[TCP_APP_TAB_SIZE];
+	spinlock_t		tcp_app_lock;
+#endif
+	/* ip_vs_proto_udp */
+#ifdef CONFIG_IP_VS_PROTO_UDP
+	#define	UDP_APP_TAB_BITS	4
+	#define	UDP_APP_TAB_SIZE	(1 << UDP_APP_TAB_BITS)
+	#define	UDP_APP_TAB_MASK	(UDP_APP_TAB_SIZE - 1)
+	struct list_head 	udp_apps[UDP_APP_TAB_SIZE];
+	spinlock_t		udp_app_lock;
+#endif
+	/* ip_vs_proto_sctp */
+	#define SCTP_APP_TAB_BITS        4
+	#define SCTP_APP_TAB_SIZE        (1 << SCTP_APP_TAB_BITS)
+	#define SCTP_APP_TAB_MASK        (SCTP_APP_TAB_SIZE - 1)
+	/* Hash table for SCTP application incarnations	 */
+	struct list_head 	sctp_apps[SCTP_APP_TAB_SIZE];
+	spinlock_t		sctp_app_lock;
+
+	/* ip_vs_est */
+	struct list_head 	est_list;	/* estimator list */
+	spinlock_t		est_lock;
+	/* ip_vs_sync */
+	struct list_head	sync_queue;
+	spinlock_t		sync_lock;
+	struct ip_vs_sync_buff  *sync_buff;
+	spinlock_t		sync_buff_lock;
+	struct sockaddr_in 	sync_mcast_addr;
+	/* sync daemon tasks */
+	struct task_struct 	*sync_master_thread;
+	struct task_struct 	*sync_backup_thread;
+	/* the maximum length of sync (sending/receiving) message */
+	int 			sync_send_mesg_maxlen;
+	int 			sync_recv_mesg_maxlen;
+
+	volatile int 		sync_state;
+	volatile int 		master_syncid;
+	volatile int 		backup_syncid;
+	/* multicast interface name */
+	char 			master_mcast_ifn[IP_VS_IFNAME_MAXLEN];
+	char 			backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
+
+};
+
+#endif /*__NETNS_IP_VS_H_*/

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
