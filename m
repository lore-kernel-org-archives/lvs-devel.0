From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 01/18] ipvs: move struct netns_ipvs
Date: Sun,  6 Mar 2011 08:45:43 +0900
Message-ID: <1299368760-14271-2-git-send-email-horms@verge.net.au>
References: <1299368760-14271-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1299368760-14271-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

 	Remove include/net/netns/ip_vs.h because it depends on
structures from include/net/ip_vs.h. As ipvs is pointer in
struct net it is better to move struct netns_ipvs into
include/net/ip_vs.h, so that we can easily use other structures
in struct netns_ipvs.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h         |  122 ++++++++++++++++++++++++++++++++++++
 include/net/net_namespace.h |    2 +-
 include/net/netns/ip_vs.h   |  143 -------------------------------------------
 3 files changed, 123 insertions(+), 144 deletions(-)
 delete mode 100644 include/net/netns/ip_vs.h

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index e74da41e..7280661 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -803,6 +803,128 @@ struct ip_vs_app {
 	void (*timeout_change)(struct ip_vs_app *app, int flags);
 };
 
+/* IPVS in network namespace */
+struct netns_ipvs {
+	int			gen;		/* Generation */
+	/*
+	 *	Hash table: for real service lookups
+	 */
+	#define IP_VS_RTAB_BITS 4
+	#define IP_VS_RTAB_SIZE (1 << IP_VS_RTAB_BITS)
+	#define IP_VS_RTAB_MASK (IP_VS_RTAB_SIZE - 1)
+
+	struct list_head	rs_table[IP_VS_RTAB_SIZE];
+	/* ip_vs_app */
+	struct list_head	app_list;
+	struct mutex		app_mutex;
+	struct lock_class_key	app_key;	/* mutex debuging */
+
+	/* ip_vs_proto */
+	#define IP_VS_PROTO_TAB_SIZE	32	/* must be power of 2 */
+	struct ip_vs_proto_data *proto_data_table[IP_VS_PROTO_TAB_SIZE];
+	/* ip_vs_proto_tcp */
+#ifdef CONFIG_IP_VS_PROTO_TCP
+	#define	TCP_APP_TAB_BITS	4
+	#define	TCP_APP_TAB_SIZE	(1 << TCP_APP_TAB_BITS)
+	#define	TCP_APP_TAB_MASK	(TCP_APP_TAB_SIZE - 1)
+	struct list_head	tcp_apps[TCP_APP_TAB_SIZE];
+	spinlock_t		tcp_app_lock;
+#endif
+	/* ip_vs_proto_udp */
+#ifdef CONFIG_IP_VS_PROTO_UDP
+	#define	UDP_APP_TAB_BITS	4
+	#define	UDP_APP_TAB_SIZE	(1 << UDP_APP_TAB_BITS)
+	#define	UDP_APP_TAB_MASK	(UDP_APP_TAB_SIZE - 1)
+	struct list_head	udp_apps[UDP_APP_TAB_SIZE];
+	spinlock_t		udp_app_lock;
+#endif
+	/* ip_vs_proto_sctp */
+#ifdef CONFIG_IP_VS_PROTO_SCTP
+	#define SCTP_APP_TAB_BITS	4
+	#define SCTP_APP_TAB_SIZE	(1 << SCTP_APP_TAB_BITS)
+	#define SCTP_APP_TAB_MASK	(SCTP_APP_TAB_SIZE - 1)
+	/* Hash table for SCTP application incarnations	 */
+	struct list_head	sctp_apps[SCTP_APP_TAB_SIZE];
+	spinlock_t		sctp_app_lock;
+#endif
+	/* ip_vs_conn */
+	atomic_t		conn_count;      /*  connection counter */
+
+	/* ip_vs_ctl */
+	struct ip_vs_stats		*tot_stats;  /* Statistics & est. */
+	struct ip_vs_cpu_stats __percpu *cpustats;   /* Stats per cpu */
+	seqcount_t			*ustats_seq; /* u64 read retry */
+
+	int			num_services;    /* no of virtual services */
+	/* 1/rate drop and drop-entry variables */
+	struct delayed_work	defense_work;   /* Work handler */
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
+	/* Trash for destinations */
+	struct list_head	dest_trash;
+	/* Service counters */
+	atomic_t		ftpsvc_counter;
+	atomic_t		nullsvc_counter;
+
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
+	/* ip_vs_lblc */
+	int			sysctl_lblc_expiration;
+	struct ctl_table_header	*lblc_ctl_header;
+	struct ctl_table	*lblc_ctl_table;
+	/* ip_vs_lblcr */
+	int			sysctl_lblcr_expiration;
+	struct ctl_table_header	*lblcr_ctl_header;
+	struct ctl_table	*lblcr_ctl_table;
+	/* ip_vs_est */
+	struct list_head	est_list;	/* estimator list */
+	spinlock_t		est_lock;
+	struct timer_list	est_timer;	/* Estimation timer */
+	/* ip_vs_sync */
+	struct list_head	sync_queue;
+	spinlock_t		sync_lock;
+	struct ip_vs_sync_buff  *sync_buff;
+	spinlock_t		sync_buff_lock;
+	struct sockaddr_in	sync_mcast_addr;
+	struct task_struct	*master_thread;
+	struct task_struct	*backup_thread;
+	int			send_mesg_maxlen;
+	int			recv_mesg_maxlen;
+	volatile int		sync_state;
+	volatile int		master_syncid;
+	volatile int		backup_syncid;
+	/* multicast interface name */
+	char			master_mcast_ifn[IP_VS_IFNAME_MAXLEN];
+	char			backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
+	/* net name space ptr */
+	struct net		*net;            /* Needed by timer routines */
+};
 
 /*
  *      IPVS core functions
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index b3b4a34..3ae4919 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -20,7 +20,6 @@
 #include <net/netns/conntrack.h>
 #endif
 #include <net/netns/xfrm.h>
-#include <net/netns/ip_vs.h>
 
 struct proc_dir_entry;
 struct net_device;
@@ -28,6 +27,7 @@ struct sock;
 struct ctl_table_header;
 struct net_generic;
 struct sock;
+struct netns_ipvs;
 
 
 #define NETDEV_HASHBITS    8
diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
deleted file mode 100644
index 259ebac..0000000
--- a/include/net/netns/ip_vs.h
+++ /dev/null
@@ -1,143 +0,0 @@
-/*
- *  IP Virtual Server
- *  Data structure for network namspace
- *
- */
-
-#ifndef IP_VS_H_
-#define IP_VS_H_
-
-#include <linux/list.h>
-#include <linux/mutex.h>
-#include <linux/list_nulls.h>
-#include <linux/ip_vs.h>
-#include <asm/atomic.h>
-#include <linux/in.h>
-
-struct ip_vs_stats;
-struct ip_vs_sync_buff;
-struct ctl_table_header;
-
-struct netns_ipvs {
-	int			gen;		/* Generation */
-	/*
-	 *	Hash table: for real service lookups
-	 */
-	#define IP_VS_RTAB_BITS 4
-	#define IP_VS_RTAB_SIZE (1 << IP_VS_RTAB_BITS)
-	#define IP_VS_RTAB_MASK (IP_VS_RTAB_SIZE - 1)
-
-	struct list_head	rs_table[IP_VS_RTAB_SIZE];
-	/* ip_vs_app */
-	struct list_head	app_list;
-	struct mutex		app_mutex;
-	struct lock_class_key	app_key;	/* mutex debuging */
-
-	/* ip_vs_proto */
-	#define IP_VS_PROTO_TAB_SIZE	32	/* must be power of 2 */
-	struct ip_vs_proto_data *proto_data_table[IP_VS_PROTO_TAB_SIZE];
-	/* ip_vs_proto_tcp */
-#ifdef CONFIG_IP_VS_PROTO_TCP
-	#define	TCP_APP_TAB_BITS	4
-	#define	TCP_APP_TAB_SIZE	(1 << TCP_APP_TAB_BITS)
-	#define	TCP_APP_TAB_MASK	(TCP_APP_TAB_SIZE - 1)
-	struct list_head	tcp_apps[TCP_APP_TAB_SIZE];
-	spinlock_t		tcp_app_lock;
-#endif
-	/* ip_vs_proto_udp */
-#ifdef CONFIG_IP_VS_PROTO_UDP
-	#define	UDP_APP_TAB_BITS	4
-	#define	UDP_APP_TAB_SIZE	(1 << UDP_APP_TAB_BITS)
-	#define	UDP_APP_TAB_MASK	(UDP_APP_TAB_SIZE - 1)
-	struct list_head	udp_apps[UDP_APP_TAB_SIZE];
-	spinlock_t		udp_app_lock;
-#endif
-	/* ip_vs_proto_sctp */
-#ifdef CONFIG_IP_VS_PROTO_SCTP
-	#define SCTP_APP_TAB_BITS	4
-	#define SCTP_APP_TAB_SIZE	(1 << SCTP_APP_TAB_BITS)
-	#define SCTP_APP_TAB_MASK	(SCTP_APP_TAB_SIZE - 1)
-	/* Hash table for SCTP application incarnations	 */
-	struct list_head	sctp_apps[SCTP_APP_TAB_SIZE];
-	spinlock_t		sctp_app_lock;
-#endif
-	/* ip_vs_conn */
-	atomic_t		conn_count;      /*  connection counter */
-
-	/* ip_vs_ctl */
-	struct ip_vs_stats		*tot_stats;  /* Statistics & est. */
-	struct ip_vs_cpu_stats __percpu *cpustats;   /* Stats per cpu */
-	seqcount_t			*ustats_seq; /* u64 read retry */
-
-	int			num_services;    /* no of virtual services */
-	/* 1/rate drop and drop-entry variables */
-	struct delayed_work	defense_work;   /* Work handler */
-	int			drop_rate;
-	int			drop_counter;
-	atomic_t		dropentry;
-	/* locks in ctl.c */
-	spinlock_t		dropentry_lock;  /* drop entry handling */
-	spinlock_t		droppacket_lock; /* drop packet handling */
-	spinlock_t		securetcp_lock;  /* state and timeout tables */
-	rwlock_t		rs_lock;         /* real services table */
-	/* semaphore for IPVS sockopts. And, [gs]etsockopt may sleep. */
-	struct lock_class_key	ctl_key;	/* ctl_mutex debuging */
-	/* Trash for destinations */
-	struct list_head	dest_trash;
-	/* Service counters */
-	atomic_t		ftpsvc_counter;
-	atomic_t		nullsvc_counter;
-
-	/* sys-ctl struct */
-	struct ctl_table_header	*sysctl_hdr;
-	struct ctl_table	*sysctl_tbl;
-	/* sysctl variables */
-	int			sysctl_amemthresh;
-	int			sysctl_am_droprate;
-	int			sysctl_drop_entry;
-	int			sysctl_drop_packet;
-	int			sysctl_secure_tcp;
-#ifdef CONFIG_IP_VS_NFCT
-	int			sysctl_conntrack;
-#endif
-	int			sysctl_snat_reroute;
-	int			sysctl_sync_ver;
-	int			sysctl_cache_bypass;
-	int			sysctl_expire_nodest_conn;
-	int			sysctl_expire_quiescent_template;
-	int			sysctl_sync_threshold[2];
-	int			sysctl_nat_icmp_send;
-
-	/* ip_vs_lblc */
-	int			sysctl_lblc_expiration;
-	struct ctl_table_header	*lblc_ctl_header;
-	struct ctl_table	*lblc_ctl_table;
-	/* ip_vs_lblcr */
-	int			sysctl_lblcr_expiration;
-	struct ctl_table_header	*lblcr_ctl_header;
-	struct ctl_table	*lblcr_ctl_table;
-	/* ip_vs_est */
-	struct list_head	est_list;	/* estimator list */
-	spinlock_t		est_lock;
-	struct timer_list	est_timer;	/* Estimation timer */
-	/* ip_vs_sync */
-	struct list_head	sync_queue;
-	spinlock_t		sync_lock;
-	struct ip_vs_sync_buff  *sync_buff;
-	spinlock_t		sync_buff_lock;
-	struct sockaddr_in	sync_mcast_addr;
-	struct task_struct	*master_thread;
-	struct task_struct	*backup_thread;
-	int			send_mesg_maxlen;
-	int			recv_mesg_maxlen;
-	volatile int		sync_state;
-	volatile int		master_syncid;
-	volatile int		backup_syncid;
-	/* multicast interface name */
-	char			master_mcast_ifn[IP_VS_IFNAME_MAXLEN];
-	char			backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
-	/* net name space ptr */
-	struct net		*net;            /* Needed by timer routines */
-};
