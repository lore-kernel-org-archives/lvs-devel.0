From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH v4 7/8] ipvs: add support for sync threads
Date: Tue, 24 Apr 2012 23:46:41 +0300
Message-ID: <1335300402-8076-8-git-send-email-ja@ssi.bg>
References: <1335300402-8076-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1335300402-8076-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

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
 include/net/ip_vs.h             |   34 +++-
 net/netfilter/ipvs/ip_vs_conn.c |    7 +
 net/netfilter/ipvs/ip_vs_ctl.c  |   29 +++-
 net/netfilter/ipvs/ip_vs_sync.c |  401 ++++++++++++++++++++++++---------------
 4 files changed, 305 insertions(+), 166 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 37398e3..27b89fb 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -784,6 +784,16 @@ struct ip_vs_app {
 	void (*timeout_change)(struct ip_vs_app *app, int flags);
 };
 
+struct ipvs_master_sync_state {
+	struct list_head	sync_queue;
+	struct ip_vs_sync_buff	*sync_buff;
+	int			sync_queue_len;
+	unsigned int		sync_queue_delay;
+	struct task_struct	*master_thread;
+	struct delayed_work	master_wakeup_work;
+	struct netns_ipvs	*ipvs;
+};
+
 /* IPVS in network namespace */
 struct netns_ipvs {
 	int			gen;		/* Generation */
@@ -870,6 +880,7 @@ struct netns_ipvs {
 #endif
 	int			sysctl_snat_reroute;
 	int			sysctl_sync_ver;
+	int			sysctl_sync_ports;
 	int			sysctl_sync_qlen_max;
 	int			sysctl_sync_sock_size;
 	int			sysctl_cache_bypass;
@@ -893,16 +904,11 @@ struct netns_ipvs {
 	spinlock_t		est_lock;
 	struct timer_list	est_timer;	/* Estimation timer */
 	/* ip_vs_sync */
-	struct list_head	sync_queue;
-	int			sync_queue_len;
-	unsigned int		sync_queue_delay;
-	struct delayed_work	master_wakeup_work;
 	spinlock_t		sync_lock;
-	struct ip_vs_sync_buff  *sync_buff;
+	struct ipvs_master_sync_state *ms;
 	spinlock_t		sync_buff_lock;
-	struct sockaddr_in	sync_mcast_addr;
-	struct task_struct	*master_thread;
-	struct task_struct	*backup_thread;
+	struct task_struct	**backup_threads;
+	int			threads_mask;
 	int			send_mesg_maxlen;
 	int			recv_mesg_maxlen;
 	volatile int		sync_state;
@@ -926,6 +932,7 @@ struct netns_ipvs {
 #define IPVS_SYNC_SEND_DELAY	(HZ / 50)
 #define IPVS_SYNC_CHECK_PERIOD	HZ
 #define IPVS_SYNC_FLUSH_TIME	(HZ * 2)
+#define IPVS_SYNC_PORTS_MAX	(1 << 6)
 
 #ifdef CONFIG_SYSCTL
 
@@ -954,6 +961,11 @@ static inline int sysctl_sync_ver(struct netns_ipvs *ipvs)
 	return ipvs->sysctl_sync_ver;
 }
 
+static inline int sysctl_sync_ports(struct netns_ipvs *ipvs)
+{
+	return ACCESS_ONCE(ipvs->sysctl_sync_ports);
+}
+
 static inline int sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
 {
 	return ipvs->sysctl_sync_qlen_max;
@@ -991,6 +1003,11 @@ static inline int sysctl_sync_ver(struct netns_ipvs *ipvs)
 	return DEFAULT_SYNC_VER;
 }
 
+static inline int sysctl_sync_ports(struct netns_ipvs *ipvs)
+{
+	return 1;
+}
+
 static inline int sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
 {
 	return IPVS_SYNC_QLEN_MAX;
@@ -1240,7 +1257,6 @@ extern void ip_vs_scheduler_err(struct ip_vs_service *svc, const char *msg);
 extern struct ip_vs_stats ip_vs_stats;
 extern int sysctl_ip_vs_sync_ver;
 
-extern void ip_vs_sync_switch_mode(struct net *net, int mode);
 extern struct ip_vs_service *
 ip_vs_service_get(struct net *net, int af, __u32 fwmark, __u16 protocol,
 		  const union nf_inet_addr *vaddr, __be16 vport);
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 46260fb..6a43c93 100644
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
index 3cbd1e2..221cc51 100644
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
 		.procname	= "sync_qlen_max",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
@@ -3686,6 +3707,8 @@ int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	tbl[idx++].data = &ipvs->sysctl_snat_reroute;
 	ipvs->sysctl_sync_ver = 1;
 	tbl[idx++].data = &ipvs->sysctl_sync_ver;
+	ipvs->sysctl_sync_ports = 1;
+	tbl[idx++].data = &ipvs->sysctl_sync_ports;
 	ipvs->sysctl_sync_qlen_max = nr_free_buffer_pages() / 32;
 	tbl[idx++].data = &ipvs->sysctl_sync_qlen_max;
 	ipvs->sysctl_sync_sock_size = 0;
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 8d6a421..effa10c 100644
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
@@ -300,22 +294,22 @@ static void hton_seq(struct ip_vs_seq *ho, struct ip_vs_seq *no)
 	put_unaligned_be32(ho->previous_delta, &no->previous_delta);
 }
 
-static inline struct ip_vs_sync_buff *sb_dequeue(struct netns_ipvs *ipvs)
+static inline struct ip_vs_sync_buff *
+sb_dequeue(struct netns_ipvs *ipvs, struct ipvs_master_sync_state *ms)
 {
 	struct ip_vs_sync_buff *sb;
 
 	spin_lock_bh(&ipvs->sync_lock);
-	if (list_empty(&ipvs->sync_queue)) {
+	if (list_empty(&ms->sync_queue)) {
 		sb = NULL;
 		__set_current_state(TASK_INTERRUPTIBLE);
 	} else {
-		sb = list_entry(ipvs->sync_queue.next,
-				struct ip_vs_sync_buff,
+		sb = list_entry(ms->sync_queue.next, struct ip_vs_sync_buff,
 				list);
 		list_del(&sb->list);
-		ipvs->sync_queue_len--;
-		if (!ipvs->sync_queue_len)
-			ipvs->sync_queue_delay = 0;
+		ms->sync_queue_len--;
+		if (!ms->sync_queue_len)
+			ms->sync_queue_delay = 0;
 	}
 	spin_unlock_bh(&ipvs->sync_lock);
 
@@ -338,7 +332,7 @@ ip_vs_sync_buff_create(struct netns_ipvs *ipvs)
 		kfree(sb);
 		return NULL;
 	}
-	sb->mesg->reserved = 0;  /* old nr_conns i.e. must be zeo now */
+	sb->mesg->reserved = 0;  /* old nr_conns i.e. must be zero now */
 	sb->mesg->version = SYNC_PROTO_VER;
 	sb->mesg->syncid = ipvs->master_syncid;
 	sb->mesg->size = sizeof(struct ip_vs_sync_mesg);
@@ -357,20 +351,21 @@ static inline void ip_vs_sync_buff_release(struct ip_vs_sync_buff *sb)
 	kfree(sb);
 }
 
-static inline void sb_queue_tail(struct netns_ipvs *ipvs)
+static inline void sb_queue_tail(struct netns_ipvs *ipvs,
+				 struct ipvs_master_sync_state *ms)
 {
-	struct ip_vs_sync_buff *sb = ipvs->sync_buff;
+	struct ip_vs_sync_buff *sb = ms->sync_buff;
 
 	spin_lock(&ipvs->sync_lock);
 	if (ipvs->sync_state & IP_VS_STATE_MASTER &&
-	    ipvs->sync_queue_len < sysctl_sync_qlen_max(ipvs)) {
-		if (!ipvs->sync_queue_len)
-			schedule_delayed_work(&ipvs->master_wakeup_work,
+	    ms->sync_queue_len < sysctl_sync_qlen_max(ipvs)) {
+		if (!ms->sync_queue_len)
+			schedule_delayed_work(&ms->master_wakeup_work,
 					      max(IPVS_SYNC_SEND_DELAY, 1));
-		ipvs->sync_queue_len++;
-		list_add_tail(&sb->list, &ipvs->sync_queue);
-		if ((++ipvs->sync_queue_delay) == IPVS_SYNC_WAKEUP_RATE)
-			wake_up_process(ipvs->master_thread);
+		ms->sync_queue_len++;
+		list_add_tail(&sb->list, &ms->sync_queue);
+		if ((++ms->sync_queue_delay) == IPVS_SYNC_WAKEUP_RATE)
+			wake_up_process(ms->master_thread);
 	} else
 		ip_vs_sync_buff_release(sb);
 	spin_unlock(&ipvs->sync_lock);
@@ -381,15 +376,15 @@ static inline void sb_queue_tail(struct netns_ipvs *ipvs)
  *	than the specified time or the specified time is zero.
  */
 static inline struct ip_vs_sync_buff *
-get_curr_sync_buff(struct netns_ipvs *ipvs, unsigned long time)
+get_curr_sync_buff(struct netns_ipvs *ipvs, struct ipvs_master_sync_state *ms,
+		   unsigned long time)
 {
 	struct ip_vs_sync_buff *sb;
 
 	spin_lock_bh(&ipvs->sync_buff_lock);
-	if (ipvs->sync_buff &&
-	    time_after_eq(jiffies - ipvs->sync_buff->firstuse, time)) {
-		sb = ipvs->sync_buff;
-		ipvs->sync_buff = NULL;
+	sb = ms->sync_buff;
+	if (sb && time_after_eq(jiffies - sb->firstuse, time)) {
+		ms->sync_buff = NULL;
 		__set_current_state(TASK_RUNNING);
 	} else
 		sb = NULL;
@@ -397,31 +392,10 @@ get_curr_sync_buff(struct netns_ipvs *ipvs, unsigned long time)
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
-	struct ip_vs_sync_buff *sb;
-
-	spin_lock_bh(&ipvs->sync_buff_lock);
-	if (!(ipvs->sync_state & IP_VS_STATE_MASTER))
-		goto unlock;
-	sb = ipvs->sync_buff;
-	if (mode == sysctl_sync_ver(ipvs) || !sb)
-		goto unlock;
-
-	/* Buffer empty ? then let buf_create do the job  */
-	if (sb->mesg->size <= sizeof(struct ip_vs_sync_mesg)) {
-		ip_vs_sync_buff_release(sb);
-		ipvs->sync_buff = NULL;
-	} else
-		sb_queue_tail(ipvs);
-
-unlock:
-	spin_unlock_bh(&ipvs->sync_buff_lock);
+	return ((long) cp >> (1 + ilog2(sizeof(*cp)))) & ipvs->threads_mask;
 }
 
 /*
@@ -543,6 +517,9 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_sync_mesg_v0 *m;
 	struct ip_vs_sync_conn_v0 *s;
+	struct ip_vs_sync_buff *buff;
+	struct ipvs_master_sync_state *ms;
+	int id;
 	int len;
 
 	if (unlikely(cp->af != AF_INET))
@@ -555,20 +532,37 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
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
+	ms = &ipvs->ms[id];
+	buff = ms->sync_buff;
+	if (buff) {
+		m = (struct ip_vs_sync_mesg_v0 *) buff->mesg;
+		/* Send buffer if it is for v1 */
+		if (!m->nr_conns) {
+			sb_queue_tail(ipvs, ms);
+			ms->sync_buff = NULL;
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
+		ms->sync_buff = buff;
 	}
 
 	len = (cp->flags & IP_VS_CONN_F_SEQ_MASK) ? FULL_CONN_SIZE :
 		SIMPLE_CONN_SIZE;
-	m = (struct ip_vs_sync_mesg_v0 *)ipvs->sync_buff->mesg;
-	s = (struct ip_vs_sync_conn_v0 *)ipvs->sync_buff->head;
+	m = (struct ip_vs_sync_mesg_v0 *) buff->mesg;
+	s = (struct ip_vs_sync_conn_v0 *) buff->head;
 
 	/* copy members */
 	s->reserved = 0;
@@ -589,12 +583,12 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
 
 	m->nr_conns++;
 	m->size += len;
-	ipvs->sync_buff->head += len;
+	buff->head += len;
 
 	/* check if there is a space for next one */
-	if (ipvs->sync_buff->head + FULL_CONN_SIZE > ipvs->sync_buff->end) {
-		sb_queue_tail(ipvs);
-		ipvs->sync_buff = NULL;
+	if (buff->head + FULL_CONN_SIZE > buff->end) {
+		sb_queue_tail(ipvs, ms);
+		ms->sync_buff = NULL;
 	}
 	spin_unlock(&ipvs->sync_buff_lock);
 
@@ -619,6 +613,9 @@ void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp, int pkts)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_sync_mesg *m;
 	union ip_vs_sync_conn *s;
+	struct ip_vs_sync_buff *buff;
+	struct ipvs_master_sync_state *ms;
+	int id;
 	__u8 *p;
 	unsigned int len, pe_name_len, pad;
 
@@ -645,6 +642,13 @@ sloop:
 	}
 
 	spin_lock(&ipvs->sync_buff_lock);
+	if (!(ipvs->sync_state & IP_VS_STATE_MASTER)) {
+		spin_unlock(&ipvs->sync_buff_lock);
+		return;
+	}
+
+	id = select_master_thread_id(ipvs, cp);
+	ms = &ipvs->ms[id];
 
 #ifdef CONFIG_IP_VS_IPV6
 	if (cp->af == AF_INET6)
@@ -663,27 +667,32 @@ sloop:
 
 	/* check if there is a space for this one  */
 	pad = 0;
-	if (ipvs->sync_buff) {
-		pad = (4 - (size_t)ipvs->sync_buff->head) & 3;
-		if (ipvs->sync_buff->head + len + pad > ipvs->sync_buff->end) {
-			sb_queue_tail(ipvs);
-			ipvs->sync_buff = NULL;
+	buff = ms->sync_buff;
+	if (buff) {
+		m = buff->mesg;
+		pad = (4 - (size_t) buff->head) & 3;
+		/* Send buffer if it is for v0 */
+		if (buff->head + len + pad > buff->end || m->reserved) {
+			sb_queue_tail(ipvs, ms);
+			ms->sync_buff = NULL;
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
+		ms->sync_buff = buff;
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
@@ -834,6 +843,7 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 		kfree(param->pe_data);
 
 		dest = cp->dest;
+		spin_lock(&cp->lock);
 		if ((cp->flags ^ flags) & IP_VS_CONN_F_INACTIVE &&
 		    !(flags & IP_VS_CONN_F_TEMPLATE) && dest) {
 			if (flags & IP_VS_CONN_F_INACTIVE) {
@@ -847,6 +857,7 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 		flags &= IP_VS_CONN_F_BACKUP_UPD_MASK;
 		flags |= cp->flags & ~IP_VS_CONN_F_BACKUP_UPD_MASK;
 		cp->flags = flags;
+		spin_unlock(&cp->lock);
 		if (!dest) {
 			dest = ip_vs_try_bind_dest(cp);
 			if (dest)
@@ -1399,9 +1410,15 @@ static int bind_mcastif_addr(struct socket *sock, char *ifname)
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
 
@@ -1453,9 +1470,15 @@ error:
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
 
@@ -1549,10 +1572,10 @@ ip_vs_receive(struct socket *sock, char *buffer, const size_t buflen)
 	iov.iov_base     = buffer;
 	iov.iov_len      = (size_t)buflen;
 
-	len = kernel_recvmsg(sock, &msg, &iov, 1, buflen, 0);
+	len = kernel_recvmsg(sock, &msg, &iov, 1, buflen, MSG_DONTWAIT);
 
 	if (len < 0)
-		return -1;
+		return len;
 
 	LeaveFunction(7);
 	return len;
@@ -1561,44 +1584,47 @@ ip_vs_receive(struct socket *sock, char *buffer, const size_t buflen)
 /* Wakeup the master thread for sending */
 static void master_wakeup_work_handler(struct work_struct *work)
 {
-	struct netns_ipvs *ipvs = container_of(work, struct netns_ipvs,
-					       master_wakeup_work.work);
+	struct ipvs_master_sync_state *ms =
+		container_of(work, struct ipvs_master_sync_state,
+			     master_wakeup_work.work);
+	struct netns_ipvs *ipvs = ms->ipvs;
 
 	spin_lock_bh(&ipvs->sync_lock);
-	if (ipvs->sync_queue_len &&
-	    ipvs->sync_queue_delay < IPVS_SYNC_WAKEUP_RATE) {
-		ipvs->sync_queue_delay = IPVS_SYNC_WAKEUP_RATE;
-		wake_up_process(ipvs->master_thread);
+	if (ms->sync_queue_len &&
+	    ms->sync_queue_delay < IPVS_SYNC_WAKEUP_RATE) {
+		ms->sync_queue_delay = IPVS_SYNC_WAKEUP_RATE;
+		wake_up_process(ms->master_thread);
 	}
 	spin_unlock_bh(&ipvs->sync_lock);
 }
 
 /* Get next buffer to send */
 static inline struct ip_vs_sync_buff *
-next_sync_buff(struct netns_ipvs *ipvs)
+next_sync_buff(struct netns_ipvs *ipvs, struct ipvs_master_sync_state *ms)
 {
 	struct ip_vs_sync_buff *sb;
 
-	sb = sb_dequeue(ipvs);
+	sb = sb_dequeue(ipvs, ms);
 	if (sb)
 		return sb;
 	/* Do not delay entries in buffer for more than 2 seconds */
-	return get_curr_sync_buff(ipvs, IPVS_SYNC_FLUSH_TIME);
+	return get_curr_sync_buff(ipvs, ms, IPVS_SYNC_FLUSH_TIME);
 }
 
 static int sync_thread_master(void *data)
 {
 	struct ip_vs_sync_thread_data *tinfo = data;
 	struct netns_ipvs *ipvs = net_ipvs(tinfo->net);
+	struct ipvs_master_sync_state *ms = &ipvs->ms[tinfo->id];
 	struct sock *sk = tinfo->sock->sk;
 	struct ip_vs_sync_buff *sb;
 
 	pr_info("sync thread started: state = MASTER, mcast_ifn = %s, "
-		"syncid = %d\n",
-		ipvs->master_mcast_ifn, ipvs->master_syncid);
+		"syncid = %d, id = %d\n",
+		ipvs->master_mcast_ifn, ipvs->master_syncid, tinfo->id);
 
 	for (;;) {
-		sb = next_sync_buff(ipvs);
+		sb = next_sync_buff(ipvs, ms);
 		if (unlikely(kthread_should_stop()))
 			break;
 		if (!sb) {
@@ -1624,12 +1650,12 @@ done:
 		ip_vs_sync_buff_release(sb);
 
 	/* clean up the sync_buff queue */
-	while ((sb = sb_dequeue(ipvs)))
+	while ((sb = sb_dequeue(ipvs, ms)))
 		ip_vs_sync_buff_release(sb);
 	__set_current_state(TASK_RUNNING);
 
 	/* clean up the current sync_buff */
-	sb = get_curr_sync_buff(ipvs, 0);
+	sb = get_curr_sync_buff(ipvs, ms, 0);
 	if (sb)
 		ip_vs_sync_buff_release(sb);
 
@@ -1648,8 +1674,8 @@ static int sync_thread_backup(void *data)
 	int len;
 
 	pr_info("sync thread started: state = BACKUP, mcast_ifn = %s, "
-		"syncid = %d\n",
-		ipvs->backup_mcast_ifn, ipvs->backup_syncid);
+		"syncid = %d, id = %d\n",
+		ipvs->backup_mcast_ifn, ipvs->backup_syncid, tinfo->id);
 
 	while (!kthread_should_stop()) {
 		wait_event_interruptible(*sk_sleep(tinfo->sock->sk),
@@ -1661,7 +1687,8 @@ static int sync_thread_backup(void *data)
 			len = ip_vs_receive(tinfo->sock, tinfo->buf,
 					ipvs->recv_mesg_maxlen);
 			if (len <= 0) {
-				pr_err("receiving message error\n");
+				if (len != -EAGAIN)
+					pr_err("receiving message error\n");
 				break;
 			}
 
@@ -1685,90 +1712,140 @@ static int sync_thread_backup(void *data)
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
+		if (ipvs->ms)
 			return -EEXIST;
 
 		strlcpy(ipvs->master_mcast_ifn, mcast_ifn,
 			sizeof(ipvs->master_mcast_ifn));
 		ipvs->master_syncid = syncid;
-		realtask = &ipvs->master_thread;
-		name = "ipvs_master:%d";
+		name = "ipvs-m:%d:%d";
 		threadfn = sync_thread_master;
-		ipvs->sync_queue_len = 0;
-		ipvs->sync_queue_delay = 0;
-		INIT_DELAYED_WORK(&ipvs->master_wakeup_work,
-				  master_wakeup_work_handler);
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
-	}
+	if (state == IP_VS_STATE_MASTER) {
+		struct ipvs_master_sync_state *ms;
 
-	set_sync_mesg_maxlen(net, state);
-	if (state == IP_VS_STATE_BACKUP) {
-		buf = kmalloc(ipvs->recv_mesg_maxlen, GFP_KERNEL);
-		if (!buf)
-			goto outsocket;
+		ipvs->ms = kzalloc(count * sizeof(ipvs->ms[0]), GFP_KERNEL);
+		if (!ipvs->ms)
+			goto out;
+		ms = ipvs->ms;
+		for (id = 0; id < count; id++, ms++) {
+			INIT_LIST_HEAD(&ms->sync_queue);
+			ms->sync_queue_len = 0;
+			ms->sync_queue_delay = 0;
+			INIT_DELAYED_WORK(&ms->master_wakeup_work,
+					  master_wakeup_work_handler);
+			ms->ipvs = ipvs;
+		}
+	} else {
+		array = kzalloc(count * sizeof(struct task_struct *),
+				GFP_KERNEL);
+		if (!array)
+			goto out;
 	}
+	set_sync_mesg_maxlen(net, state);
 
-	tinfo = kmalloc(sizeof(*tinfo), GFP_KERNEL);
-	if (!tinfo)
-		goto outbuf;
-
-	tinfo->net = net;
-	tinfo->sock = sock;
-	tinfo->buf = buf;
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
+		if (state == IP_VS_STATE_MASTER)
+			ipvs->ms[id].master_thread = task;
+		else
+			array[id] = task;
 	}
 
 	/* mark as active */
-	*realtask = task;
+
+	if (state == IP_VS_STATE_BACKUP)
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
+	while (count-- > 0) {
+		if (state == IP_VS_STATE_MASTER)
+			kthread_stop(ipvs->ms[count].master_thread);
+		else
+			kthread_stop(array[count]);
+	}
+	kfree(array);
+
 out:
+	if (!(ipvs->sync_state & IP_VS_STATE_MASTER)) {
+		kfree(ipvs->ms);
+		ipvs->ms = NULL;
+	}
 	return result;
 }
 
@@ -1776,39 +1853,60 @@ out:
 int stop_sync_thread(struct net *net, int state)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct task_struct **array;
+	int id;
 	int retc = -EINVAL;
 
 	IP_VS_DBG(7, "%s(): pid %d\n", __func__, task_pid_nr(current));
 
 	if (state == IP_VS_STATE_MASTER) {
-		if (!ipvs->master_thread)
+		if (!ipvs->ms)
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
-		cancel_delayed_work_sync(&ipvs->master_wakeup_work);
-		retc = kthread_stop(ipvs->master_thread);
-		ipvs->master_thread = NULL;
+		spin_unlock(&ipvs->sync_lock);
+		spin_unlock_bh(&ipvs->sync_buff_lock);
+
+		retc = 0;
+		for (id = ipvs->threads_mask; id >= 0; id--) {
+			struct ipvs_master_sync_state *ms = &ipvs->ms[id];
+			int ret;
+
+			pr_info("stopping master sync thread %d ...\n",
+				task_pid_nr(ms->master_thread));
+			cancel_delayed_work_sync(&ms->master_wakeup_work);
+			ret = kthread_stop(ms->master_thread);
+			if (retc >= 0)
+				retc = ret;
+		}
+		kfree(ipvs->ms);
+		ipvs->ms = NULL;
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
@@ -1825,13 +1923,8 @@ int __net_init ip_vs_sync_net_init(struct net *net)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	__mutex_init(&ipvs->sync_mutex, "ipvs->sync_mutex", &__ipvs_sync_key);
-	INIT_LIST_HEAD(&ipvs->sync_queue);
 	spin_lock_init(&ipvs->sync_lock);
 	spin_lock_init(&ipvs->sync_buff_lock);
