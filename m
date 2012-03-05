From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 7/8] ipvs: add support for sync threads
Date: Tue,  6 Mar 2012 00:00:07 +0200
Message-ID: <1330984808-2343-8-git-send-email-ja@ssi.bg>
References: <1330984808-2343-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1330984808-2343-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Aleksey Chudov <aleksey.chudov@gmail.com>

	Allow master and backup servers to use many threads
for sync traffic. Add sysctl var "sync_ports" to define the
number of threads. Every thread will use single UDP port,
thread 0 will use the default port 8848 while last thread
will use port 8848+sync_ports-1.

	The sync traffic for connections is scheduled to many
master threads based on the cp address but one connection is
always assigned to same thread to avoid reordering of the
sync messages.

	Remove ip_vs_sync_switch_mode because this check
for sync mode change is still risky. Instead, check for mode
change under sync_buff_lock.

	Make sure the backup socks do not block on reading.

Special thanks to Aleksey Chudov for helping in all tests.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Tested-by: Aleksey Chudov <aleksey.chudov@gmail.com>
---
 include/net/ip_vs.h             |   23 ++-
 net/netfilter/ipvs/ip_vs_conn.c |    7 +
 net/netfilter/ipvs/ip_vs_ctl.c  |   29 +++-
 net/netfilter/ipvs/ip_vs_sync.c |  349 ++++++++++++++++++++++++---------------
 4 files changed, 265 insertions(+), 143 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 8bee5d0..082e12d 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -870,6 +870,7 @@ struct netns_ipvs {
 #endif
 	int			sysctl_snat_reroute;
 	int			sysctl_sync_ver;
+	int			sysctl_sync_ports;
 	int			sysctl_cache_bypass;
 	int			sysctl_expire_nodest_conn;
 	int			sysctl_expire_quiescent_template;
@@ -891,13 +892,13 @@ struct netns_ipvs {
 	spinlock_t		est_lock;
 	struct timer_list	est_timer;	/* Estimation timer */
 	/* ip_vs_sync */
-	struct list_head	sync_queue;
+	struct list_head	*sync_queues;
 	spinlock_t		sync_lock;
-	struct ip_vs_sync_buff  *sync_buff;
+	struct ip_vs_sync_buff  **sync_buffs;
 	spinlock_t		sync_buff_lock;
-	struct sockaddr_in	sync_mcast_addr;
-	struct task_struct	*master_thread;
-	struct task_struct	*backup_thread;
+	struct task_struct	**master_threads;
+	struct task_struct	**backup_threads;
+	int			threads_mask;
 	int			send_mesg_maxlen;
 	int			recv_mesg_maxlen;
 	volatile int		sync_state;
@@ -917,6 +918,7 @@ struct netns_ipvs {
 #define DEFAULT_SYNC_RETRIES		0
 #define DEFAULT_SYNC_VER		1
 #define IPVS_SYNC_FLUSH_TIME		(HZ * 2)
+#define IPVS_SYNC_PORTS_MAX		(1 << 6)
 
 #ifdef CONFIG_SYSCTL
 
@@ -945,6 +947,11 @@ static inline int sysctl_sync_ver(struct netns_ipvs *ipvs)
 	return ipvs->sysctl_sync_ver;
 }
 
+static inline int sysctl_sync_ports(struct netns_ipvs *ipvs)
+{
+	return ACCESS_ONCE(ipvs->sysctl_sync_ports);
+}
+
 #else
 
 static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
@@ -972,6 +979,11 @@ static inline int sysctl_sync_ver(struct netns_ipvs *ipvs)
 	return DEFAULT_SYNC_VER;
 }
 
+static inline int sysctl_sync_ports(struct netns_ipvs *ipvs)
+{
+	return 1;
+}
+
 #endif
 
 /*
@@ -1212,7 +1224,6 @@ extern struct ip_vs_stats ip_vs_stats;
 extern const struct ctl_path net_vs_ctl_path[];
 extern int sysctl_ip_vs_sync_ver;
 
-extern void ip_vs_sync_switch_mode(struct net *net, int mode);
 extern struct ip_vs_service *
 ip_vs_service_get(struct net *net, int af, __u32 fwmark, __u16 protocol,
 		  const union nf_inet_addr *vaddr, __be16 vport);
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 126971c..7478b66 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -618,12 +618,19 @@ struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp)
 	if (dest) {
 		struct ip_vs_proto_data *pd;
 
+		spin_lock(&cp->lock);
+		if (cp->dest) {
+			spin_unlock(&cp->lock);
+			return dest;
+		}
+
 		/* Applications work depending on the forwarding method
 		 * but better to reassign them always when binding dest */
 		if (cp->app)
 			ip_vs_unbind_app(cp);
 
 		ip_vs_bind_dest(cp, dest);
+		spin_unlock(&cp->lock);
 
 		/* Update its packet transmitter */
 		cp->packet_xmit = NULL;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index da922c7..6c532d6 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1657,9 +1657,24 @@ proc_do_sync_mode(ctl_table *table, int write,
 		if ((*valp < 0) || (*valp > 1)) {
 			/* Restore the correct value */
 			*valp = val;
-		} else {
-			struct net *net = current->nsproxy->net_ns;
-			ip_vs_sync_switch_mode(net, val);
+		}
+	}
+	return rc;
+}
+
+static int
+proc_do_sync_ports(ctl_table *table, int write,
+		   void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int *valp = table->data;
+	int val = *valp;
+	int rc;
+
+	rc = proc_dointvec(table, write, buffer, lenp, ppos);
+	if (write && (*valp != val)) {
+		if (*valp < 1 || !is_power_of_2(*valp)) {
+			/* Restore the correct value */
+			*valp = val;
 		}
 	}
 	return rc;
@@ -1723,6 +1738,12 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_do_sync_mode,
 	},
 	{
+		.procname	= "sync_ports",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_do_sync_ports,
+	},
+	{
 		.procname	= "cache_bypass",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
@@ -3673,6 +3694,8 @@ int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	tbl[idx++].data = &ipvs->sysctl_snat_reroute;
 	ipvs->sysctl_sync_ver = 1;
 	tbl[idx++].data = &ipvs->sysctl_sync_ver;
+	ipvs->sysctl_sync_ports = 1;
+	tbl[idx++].data = &ipvs->sysctl_sync_ports;
 	tbl[idx++].data = &ipvs->sysctl_cache_bypass;
 	tbl[idx++].data = &ipvs->sysctl_expire_nodest_conn;
 	tbl[idx++].data = &ipvs->sysctl_expire_quiescent_template;
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 8ee8a57..33f4cf4 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -196,6 +196,7 @@ struct ip_vs_sync_thread_data {
 	struct net *net;
 	struct socket *sock;
 	char *buf;
+	int id;
 };
 
 /* Version 0 definition of packet sizes */
@@ -271,13 +272,6 @@ struct ip_vs_sync_buff {
 	unsigned char           *end;
 };
 
-/* multicast addr */
-static struct sockaddr_in mcast_addr = {
-	.sin_family		= AF_INET,
-	.sin_port		= cpu_to_be16(IP_VS_SYNC_PORT),
-	.sin_addr.s_addr	= cpu_to_be32(IP_VS_SYNC_GROUP),
-};
-
 /*
  * Copy of struct ip_vs_seq
  * From unaligned network order to aligned host order
@@ -300,15 +294,16 @@ static void hton_seq(struct ip_vs_seq *ho, struct ip_vs_seq *no)
 	put_unaligned_be32(ho->previous_delta, &no->previous_delta);
 }
 
-static inline struct ip_vs_sync_buff *sb_dequeue(struct netns_ipvs *ipvs)
+static inline struct ip_vs_sync_buff *sb_dequeue(struct netns_ipvs *ipvs,
+						 int id)
 {
 	struct ip_vs_sync_buff *sb;
 
 	spin_lock_bh(&ipvs->sync_lock);
-	if (list_empty(&ipvs->sync_queue)) {
+	if (list_empty(&ipvs->sync_queues[id])) {
 		sb = NULL;
 	} else {
-		sb = list_entry(ipvs->sync_queue.next,
+		sb = list_entry(ipvs->sync_queues[id].next,
 				struct ip_vs_sync_buff,
 				list);
 		list_del(&sb->list);
@@ -334,7 +329,7 @@ ip_vs_sync_buff_create(struct netns_ipvs *ipvs)
 		kfree(sb);
 		return NULL;
 	}
-	sb->mesg->reserved = 0;  /* old nr_conns i.e. must be zeo now */
+	sb->mesg->reserved = 0;  /* old nr_conns i.e. must be zero now */
 	sb->mesg->version = SYNC_PROTO_VER;
 	sb->mesg->syncid = ipvs->master_syncid;
 	sb->mesg->size = sizeof(struct ip_vs_sync_mesg);
@@ -353,13 +348,13 @@ static inline void ip_vs_sync_buff_release(struct ip_vs_sync_buff *sb)
 	kfree(sb);
 }
 
-static inline void sb_queue_tail(struct netns_ipvs *ipvs)
+static inline void sb_queue_tail(struct netns_ipvs *ipvs, int id)
 {
-	struct ip_vs_sync_buff *sb = ipvs->sync_buff;
+	struct ip_vs_sync_buff *sb = ipvs->sync_buffs[id];
 
 	spin_lock(&ipvs->sync_lock);
 	if (ipvs->sync_state & IP_VS_STATE_MASTER)
-		list_add_tail(&sb->list, &ipvs->sync_queue);
+		list_add_tail(&sb->list, &ipvs->sync_queues[id]);
 	else
 		ip_vs_sync_buff_release(sb);
 	spin_unlock(&ipvs->sync_lock);
@@ -370,49 +365,25 @@ static inline void sb_queue_tail(struct netns_ipvs *ipvs)
  *	than the specified time or the specified time is zero.
  */
 static inline struct ip_vs_sync_buff *
-get_curr_sync_buff(struct netns_ipvs *ipvs, unsigned long time)
+get_curr_sync_buff(struct netns_ipvs *ipvs, int id, unsigned long time)
 {
 	struct ip_vs_sync_buff *sb;
 
 	spin_lock_bh(&ipvs->sync_buff_lock);
-	if (ipvs->sync_buff &&
-	    time_after_eq(jiffies - ipvs->sync_buff->firstuse, time)) {
-		sb = ipvs->sync_buff;
-		ipvs->sync_buff = NULL;
+	if (ipvs->sync_buffs[id] &&
+	    time_after_eq(jiffies - ipvs->sync_buffs[id]->firstuse, time)) {
+		sb = ipvs->sync_buffs[id];
+		ipvs->sync_buffs[id] = NULL;
 	} else
 		sb = NULL;
 	spin_unlock_bh(&ipvs->sync_buff_lock);
 	return sb;
 }
 
-/*
- * Switch mode from sending version 0 or 1
- *  - must handle sync_buf
- */
-void ip_vs_sync_switch_mode(struct net *net, int mode)
+static inline int
+select_master_thread_id(struct netns_ipvs *ipvs, struct ip_vs_conn *cp)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
-
-	if (!(ipvs->sync_state & IP_VS_STATE_MASTER))
-		return;
-	if (mode == sysctl_sync_ver(ipvs) || !ipvs->sync_buff)
-		return;
-
-	spin_lock_bh(&ipvs->sync_buff_lock);
-	/* Buffer empty ? then let buf_create do the job  */
-	if (ipvs->sync_buff->mesg->size <=  sizeof(struct ip_vs_sync_mesg)) {
-		kfree(ipvs->sync_buff);
-		ipvs->sync_buff = NULL;
-	} else {
-		spin_lock_bh(&ipvs->sync_lock);
-		if (ipvs->sync_state & IP_VS_STATE_MASTER)
-			list_add_tail(&ipvs->sync_buff->list,
-				      &ipvs->sync_queue);
-		else
-			ip_vs_sync_buff_release(ipvs->sync_buff);
-		spin_unlock_bh(&ipvs->sync_lock);
-	}
-	spin_unlock_bh(&ipvs->sync_buff_lock);
+	return ((int) cp >> (1 + ilog2(sizeof(*cp)))) & ipvs->threads_mask;
 }
 
 /*
@@ -532,8 +503,10 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
 			       int pkts)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct ip_vs_sync_buff *buff;
 	struct ip_vs_sync_mesg_v0 *m;
 	struct ip_vs_sync_conn_v0 *s;
+	int id;
 	int len;
 
 	if (unlikely(cp->af != AF_INET))
@@ -546,20 +519,36 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
 		return;
 
 	spin_lock(&ipvs->sync_buff_lock);
-	if (!ipvs->sync_buff) {
-		ipvs->sync_buff =
-			ip_vs_sync_buff_create_v0(ipvs);
-		if (!ipvs->sync_buff) {
+	if (!(ipvs->sync_state & IP_VS_STATE_MASTER)) {
+		spin_unlock(&ipvs->sync_buff_lock);
+		return;
+	}
+
+	id = select_master_thread_id(ipvs, cp);
+	buff = ipvs->sync_buffs[id];
+	if (buff) {
+		m = (struct ip_vs_sync_mesg_v0 *) buff->mesg;
+		/* Send buffer if it is for v1 */
+		if (!m->nr_conns) {
+			sb_queue_tail(ipvs, id);
+			ipvs->sync_buffs[id] = NULL;
+			buff = NULL;
+		}
+	}
+	if (!buff) {
+		buff = ip_vs_sync_buff_create_v0(ipvs);
+		if (!buff) {
 			spin_unlock(&ipvs->sync_buff_lock);
 			pr_err("ip_vs_sync_buff_create failed.\n");
 			return;
 		}
+		ipvs->sync_buffs[id] = buff;
 	}
 
 	len = (cp->flags & IP_VS_CONN_F_SEQ_MASK) ? FULL_CONN_SIZE :
 		SIMPLE_CONN_SIZE;
-	m = (struct ip_vs_sync_mesg_v0 *)ipvs->sync_buff->mesg;
-	s = (struct ip_vs_sync_conn_v0 *)ipvs->sync_buff->head;
+	m = (struct ip_vs_sync_mesg_v0 *) buff->mesg;
+	s = (struct ip_vs_sync_conn_v0 *) buff->head;
 
 	/* copy members */
 	s->reserved = 0;
@@ -580,12 +569,12 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
 
 	m->nr_conns++;
 	m->size += len;
-	ipvs->sync_buff->head += len;
+	buff->head += len;
 
 	/* check if there is a space for next one */
-	if (ipvs->sync_buff->head + FULL_CONN_SIZE > ipvs->sync_buff->end) {
-		sb_queue_tail(ipvs);
-		ipvs->sync_buff = NULL;
+	if (buff->head + FULL_CONN_SIZE > buff->end) {
+		sb_queue_tail(ipvs, id);
+		ipvs->sync_buffs[id] = NULL;
 	}
 	spin_unlock(&ipvs->sync_buff_lock);
 
@@ -608,10 +597,12 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
 void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp, int pkts)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct ip_vs_sync_buff *buff;
 	struct ip_vs_sync_mesg *m;
 	union ip_vs_sync_conn *s;
 	__u8 *p;
 	unsigned int len, pe_name_len, pad;
+	int id;
 
 	/* Handle old version of the protocol */
 	if (sysctl_sync_ver(ipvs) == 0) {
@@ -636,6 +627,12 @@ sloop:
 	}
 
 	spin_lock(&ipvs->sync_buff_lock);
+	if (!(ipvs->sync_state & IP_VS_STATE_MASTER)) {
+		spin_unlock(&ipvs->sync_buff_lock);
+		return;
+	}
+
+	id = select_master_thread_id(ipvs, cp);
 
 #ifdef CONFIG_IP_VS_IPV6
 	if (cp->af == AF_INET6)
@@ -654,27 +651,32 @@ sloop:
 
 	/* check if there is a space for this one  */
 	pad = 0;
-	if (ipvs->sync_buff) {
-		pad = (4 - (size_t)ipvs->sync_buff->head) & 3;
-		if (ipvs->sync_buff->head + len + pad > ipvs->sync_buff->end) {
-			sb_queue_tail(ipvs);
-			ipvs->sync_buff = NULL;
+	buff = ipvs->sync_buffs[id];
+	if (buff) {
+		m = buff->mesg;
+		pad = (4 - (size_t) buff->head) & 3;
+		/* Send buffer if it is for v0 */
+		if (buff->head + len + pad > buff->end || m->reserved) {
+			sb_queue_tail(ipvs, id);
+			ipvs->sync_buffs[id] = NULL;
+			buff = NULL;
 			pad = 0;
 		}
 	}
 
-	if (!ipvs->sync_buff) {
-		ipvs->sync_buff = ip_vs_sync_buff_create(ipvs);
-		if (!ipvs->sync_buff) {
+	if (!buff) {
+		buff = ip_vs_sync_buff_create(ipvs);
+		if (!buff) {
 			spin_unlock(&ipvs->sync_buff_lock);
 			pr_err("ip_vs_sync_buff_create failed.\n");
 			return;
 		}
+		ipvs->sync_buffs[id] = buff;
+		m = buff->mesg;
 	}
 
-	m = ipvs->sync_buff->mesg;
-	p = ipvs->sync_buff->head;
-	ipvs->sync_buff->head += pad + len;
+	p = buff->head;
+	buff->head += pad + len;
 	m->size += pad + len;
 	/* Add ev. padding from prev. sync_conn */
 	while (pad--)
@@ -825,6 +827,7 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 		kfree(param->pe_data);
 
 		dest = cp->dest;
+		spin_lock(&cp->lock);
 		if ((cp->flags ^ flags) & IP_VS_CONN_F_INACTIVE &&
 		    !(flags & IP_VS_CONN_F_TEMPLATE) && dest) {
 			if (flags & IP_VS_CONN_F_INACTIVE) {
@@ -838,6 +841,7 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 		flags &= IP_VS_CONN_F_BACKUP_UPD_MASK;
 		flags |= cp->flags & ~IP_VS_CONN_F_BACKUP_UPD_MASK;
 		cp->flags = flags;
+		spin_unlock(&cp->lock);
 		if (!dest) {
 			dest = ip_vs_try_bind_dest(cp);
 			if (dest)
@@ -1368,9 +1372,15 @@ static int bind_mcastif_addr(struct socket *sock, char *ifname)
 /*
  *      Set up sending multicast socket over UDP
  */
-static struct socket *make_send_sock(struct net *net)
+static struct socket *make_send_sock(struct net *net, int id)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
+	/* multicast addr */
+	struct sockaddr_in mcast_addr = {
+		.sin_family		= AF_INET,
+		.sin_port		= cpu_to_be16(IP_VS_SYNC_PORT + id),
+		.sin_addr.s_addr	= cpu_to_be32(IP_VS_SYNC_GROUP),
+	};
 	struct socket *sock;
 	int result;
 
@@ -1419,9 +1429,15 @@ error:
 /*
  *      Set up receiving multicast socket over UDP
  */
-static struct socket *make_receive_sock(struct net *net)
+static struct socket *make_receive_sock(struct net *net, int id)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
+	/* multicast addr */
+	struct sockaddr_in mcast_addr = {
+		.sin_family		= AF_INET,
+		.sin_port		= cpu_to_be16(IP_VS_SYNC_PORT + id),
+		.sin_addr.s_addr	= cpu_to_be32(IP_VS_SYNC_GROUP),
+	};
 	struct socket *sock;
 	int result;
 
@@ -1512,10 +1528,10 @@ ip_vs_receive(struct socket *sock, char *buffer, const size_t buflen)
 	iov.iov_base     = buffer;
 	iov.iov_len      = (size_t)buflen;
 
-	len = kernel_recvmsg(sock, &msg, &iov, 1, buflen, 0);
+	len = kernel_recvmsg(sock, &msg, &iov, 1, buflen, MSG_DONTWAIT);
 
 	if (len < 0)
-		return -1;
+		return len;
 
 	LeaveFunction(7);
 	return len;
@@ -1523,15 +1539,15 @@ ip_vs_receive(struct socket *sock, char *buffer, const size_t buflen)
 
 /* Get next buffer to send */
 static inline struct ip_vs_sync_buff *
-next_sync_buff(struct netns_ipvs *ipvs)
+next_sync_buff(struct netns_ipvs *ipvs, int id)
 {
 	struct ip_vs_sync_buff *sb;
 
-	sb = sb_dequeue(ipvs);
+	sb = sb_dequeue(ipvs, id);
 	if (sb)
 		return sb;
 	/* Do not delay entries in buffer for more than 2 seconds */
-	return get_curr_sync_buff(ipvs, IPVS_SYNC_FLUSH_TIME);
+	return get_curr_sync_buff(ipvs, id, IPVS_SYNC_FLUSH_TIME);
 }
 
 static int sync_thread_master(void *data)
@@ -1542,15 +1558,15 @@ static int sync_thread_master(void *data)
 	int pause = HZ / 10;
 
 	pr_info("sync thread started: state = MASTER, mcast_ifn = %s, "
-		"syncid = %d\n",
-		ipvs->master_mcast_ifn, ipvs->master_syncid);
+		"syncid = %d, id = %d\n",
+		ipvs->master_mcast_ifn, ipvs->master_syncid, tinfo->id);
 
 	while (!kthread_should_stop()) {
 		int count = 0;
 
 		for (;;) {
 			if (!sb) {
-				sb = next_sync_buff(ipvs);
+				sb = next_sync_buff(ipvs, tinfo->id);
 				if (!sb)
 					break;
 			}
@@ -1577,11 +1593,11 @@ static int sync_thread_master(void *data)
 		ip_vs_sync_buff_release(sb);
 
 	/* clean up the sync_buff queue */
-	while ((sb = sb_dequeue(ipvs)))
+	while ((sb = sb_dequeue(ipvs, tinfo->id)))
 		ip_vs_sync_buff_release(sb);
 
 	/* clean up the current sync_buff */
-	sb = get_curr_sync_buff(ipvs, 0);
+	sb = get_curr_sync_buff(ipvs, tinfo->id, 0);
 	if (sb)
 		ip_vs_sync_buff_release(sb);
 
@@ -1600,8 +1616,8 @@ static int sync_thread_backup(void *data)
 	int len;
 
 	pr_info("sync thread started: state = BACKUP, mcast_ifn = %s, "
-		"syncid = %d\n",
-		ipvs->backup_mcast_ifn, ipvs->backup_syncid);
+		"syncid = %d, id = %d\n",
+		ipvs->backup_mcast_ifn, ipvs->backup_syncid, tinfo->id);
 
 	while (!kthread_should_stop()) {
 		wait_event_interruptible(*sk_sleep(tinfo->sock->sk),
@@ -1613,7 +1629,8 @@ static int sync_thread_backup(void *data)
 			len = ip_vs_receive(tinfo->sock, tinfo->buf,
 					ipvs->recv_mesg_maxlen);
 			if (len <= 0) {
-				pr_err("receiving message error\n");
+				if (len != -EAGAIN)
+					pr_err("receiving message error\n");
 				break;
 			}
 
@@ -1637,86 +1654,135 @@ static int sync_thread_backup(void *data)
 int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid)
 {
 	struct ip_vs_sync_thread_data *tinfo;
-	struct task_struct **realtask, *task;
+	struct task_struct **array = NULL, *task;
 	struct socket *sock;
 	struct netns_ipvs *ipvs = net_ipvs(net);
-	char *name, *buf = NULL;
+	char *name;
 	int (*threadfn)(void *data);
+	int id, count;
 	int result = -ENOMEM;
 
 	IP_VS_DBG(7, "%s(): pid %d\n", __func__, task_pid_nr(current));
 	IP_VS_DBG(7, "Each ip_vs_sync_conn entry needs %Zd bytes\n",
 		  sizeof(struct ip_vs_sync_conn_v0));
 
+	if (!ipvs->sync_state) {
+		count = clamp(sysctl_sync_ports(ipvs), 1, IPVS_SYNC_PORTS_MAX);
+		ipvs->threads_mask = count - 1;
+	} else
+		count = ipvs->threads_mask + 1;
 
 	if (state == IP_VS_STATE_MASTER) {
-		if (ipvs->master_thread)
+		if (ipvs->master_threads)
 			return -EEXIST;
 
 		strlcpy(ipvs->master_mcast_ifn, mcast_ifn,
 			sizeof(ipvs->master_mcast_ifn));
 		ipvs->master_syncid = syncid;
-		realtask = &ipvs->master_thread;
-		name = "ipvs_master:%d";
+		name = "ipvs-m:%d:%d";
 		threadfn = sync_thread_master;
-		sock = make_send_sock(net);
 	} else if (state == IP_VS_STATE_BACKUP) {
-		if (ipvs->backup_thread)
+		if (ipvs->backup_threads)
 			return -EEXIST;
 
 		strlcpy(ipvs->backup_mcast_ifn, mcast_ifn,
 			sizeof(ipvs->backup_mcast_ifn));
 		ipvs->backup_syncid = syncid;
-		realtask = &ipvs->backup_thread;
-		name = "ipvs_backup:%d";
+		name = "ipvs-b:%d:%d";
 		threadfn = sync_thread_backup;
-		sock = make_receive_sock(net);
 	} else {
 		return -EINVAL;
 	}
 
-	if (IS_ERR(sock)) {
-		result = PTR_ERR(sock);
-		goto out;
+	if (state == IP_VS_STATE_MASTER) {
+		ipvs->sync_queues = kmalloc(count * sizeof(struct list_head),
+					    GFP_KERNEL);
+		if (!ipvs->sync_queues)
+			goto out;
+		for (id = 0; id < count; id++)
+			INIT_LIST_HEAD(&ipvs->sync_queues[id]);
+		ipvs->sync_buffs = kzalloc(count *
+					   sizeof(struct ip_vs_sync_buff *),
+					   GFP_KERNEL);
+		if (!ipvs->sync_buffs)
+			goto out;
 	}
 
+	array = kzalloc(count * sizeof(struct task_struct *), GFP_KERNEL);
+	if (!array)
+		goto out;
+
 	set_sync_mesg_maxlen(net, state);
-	if (state == IP_VS_STATE_BACKUP) {
-		buf = kmalloc(ipvs->recv_mesg_maxlen, GFP_KERNEL);
-		if (!buf)
-			goto outsocket;
-	}
 
-	tinfo = kmalloc(sizeof(*tinfo), GFP_KERNEL);
-	if (!tinfo)
-		goto outbuf;
+	tinfo = NULL;
+	for (id = 0; id < count; id++) {
+		if (state == IP_VS_STATE_MASTER)
+			sock = make_send_sock(net, id);
+		else
+			sock = make_receive_sock(net, id);
+		if (IS_ERR(sock)) {
+			result = PTR_ERR(sock);
+			goto outtinfo;
+		}
 
-	tinfo->net = net;
-	tinfo->sock = sock;
-	tinfo->buf = buf;
+		tinfo = kmalloc(sizeof(*tinfo), GFP_KERNEL);
+		if (!tinfo)
+			goto outsocket;
+		tinfo->net = net;
+		tinfo->sock = sock;
+		if (state == IP_VS_STATE_BACKUP) {
+			tinfo->buf = kmalloc(ipvs->recv_mesg_maxlen,
+					     GFP_KERNEL);
+			if (!tinfo->buf)
+				goto outtinfo;
+		}
+		tinfo->id = id;
 
-	task = kthread_run(threadfn, tinfo, name, ipvs->gen);
-	if (IS_ERR(task)) {
-		result = PTR_ERR(task);
-		goto outtinfo;
+		task = kthread_run(threadfn, tinfo, name, ipvs->gen, id);
+		if (IS_ERR(task)) {
+			result = PTR_ERR(task);
+			goto outtinfo;
+		}
+		tinfo = NULL;
+		array[id] = task;
 	}
 
 	/* mark as active */
-	*realtask = task;
+
+	if (state == IP_VS_STATE_MASTER)
+		ipvs->master_threads = array;
+	else
+		ipvs->backup_threads = array;
+	spin_lock_bh(&ipvs->sync_buff_lock);
 	ipvs->sync_state |= state;
+	spin_unlock_bh(&ipvs->sync_buff_lock);
 
 	/* increase the module use count */
 	ip_vs_use_count_inc();
 
 	return 0;
 
-outtinfo:
-	kfree(tinfo);
-outbuf:
-	kfree(buf);
 outsocket:
 	sk_release_kernel(sock->sk);
+
+outtinfo:
+	if (tinfo) {
+		sk_release_kernel(tinfo->sock->sk);
+		kfree(tinfo->buf);
+		kfree(tinfo);
+	}
+	count = id;
+	while (count-- > 0)
+		kthread_stop(array[count]);
+	kfree(array);
+
 out:
+	if (!(ipvs->sync_state & IP_VS_STATE_MASTER)) {
+		kfree(ipvs->sync_queues);
+		ipvs->sync_queues = NULL;
+		kfree(ipvs->sync_buffs);
+		ipvs->sync_buffs = NULL;
+	}
 	return result;
 }
 
@@ -1724,38 +1790,58 @@ out:
 int stop_sync_thread(struct net *net, int state)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct task_struct **array;
+	int id;
 	int retc = -EINVAL;
 
 	IP_VS_DBG(7, "%s(): pid %d\n", __func__, task_pid_nr(current));
 
 	if (state == IP_VS_STATE_MASTER) {
-		if (!ipvs->master_thread)
+		if (!ipvs->master_threads)
 			return -ESRCH;
 
-		pr_info("stopping master sync thread %d ...\n",
-			task_pid_nr(ipvs->master_thread));
-
 		/*
 		 * The lock synchronizes with sb_queue_tail(), so that we don't
 		 * add sync buffers to the queue, when we are already in
 		 * progress of stopping the master sync daemon.
 		 */
 
-		spin_lock_bh(&ipvs->sync_lock);
+		spin_lock_bh(&ipvs->sync_buff_lock);
+		spin_lock(&ipvs->sync_lock);
 		ipvs->sync_state &= ~IP_VS_STATE_MASTER;
-		spin_unlock_bh(&ipvs->sync_lock);
-		retc = kthread_stop(ipvs->master_thread);
-		ipvs->master_thread = NULL;
+		spin_unlock(&ipvs->sync_lock);
+		spin_unlock_bh(&ipvs->sync_buff_lock);
+		array = ipvs->master_threads;
+		retc = 0;
+		for (id = ipvs->threads_mask; id >= 0; id--) {
+			int ret;
+
+			pr_info("stopping master sync thread %d ...\n",
+				task_pid_nr(array[id]));
+			ret = kthread_stop(array[id]);
+			if (retc >= 0)
+				retc = ret;
+		}
+		kfree(array);
+		ipvs->master_threads = NULL;
 	} else if (state == IP_VS_STATE_BACKUP) {
-		if (!ipvs->backup_thread)
+		if (!ipvs->backup_threads)
 			return -ESRCH;
 
-		pr_info("stopping backup sync thread %d ...\n",
-			task_pid_nr(ipvs->backup_thread));
-
 		ipvs->sync_state &= ~IP_VS_STATE_BACKUP;
-		retc = kthread_stop(ipvs->backup_thread);
-		ipvs->backup_thread = NULL;
+		array = ipvs->backup_threads;
+		retc = 0;
+		for (id = ipvs->threads_mask; id >= 0; id--) {
+			int ret;
+
+			pr_info("stopping backup sync thread %d ...\n",
+				task_pid_nr(array[id]));
+			ret = kthread_stop(array[id]);
+			if (retc >= 0)
+				retc = ret;
+		}
+		kfree(array);
+		ipvs->backup_threads = NULL;
 	}
 
 	/* decrease the module use count */
@@ -1772,13 +1858,8 @@ int __net_init ip_vs_sync_net_init(struct net *net)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	__mutex_init(&ipvs->sync_mutex, "ipvs->sync_mutex", &__ipvs_sync_key);
-	INIT_LIST_HEAD(&ipvs->sync_queue);
 	spin_lock_init(&ipvs->sync_lock);
 	spin_lock_init(&ipvs->sync_buff_lock);
