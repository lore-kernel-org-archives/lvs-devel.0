From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 5/9] ipvs: use adaptive pause in master thread
Date: Wed, 11 Apr 2012 23:02:39 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1204112221250.2000@ja.ssi.bg>
References: <1332320185-27157-1-git-send-email-horms@verge.net.au> <1332320185-27157-6-git-send-email-horms@verge.net.au> <20120402111145.GA15181@1984> <alpine.LFD.2.00.1204032258540.1995@ja.ssi.bg> <20120405150553.GA8144@1984> <alpine.LFD.2.00.1204082221440.6964@ja.ssi.bg>
 <20120409230803.GB27514@1984>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120409230803.GB27514@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>


	Hello,

On Tue, 10 Apr 2012, Pablo Neira Ayuso wrote:

> You can still use kthread_should_stop inside a wrapper function
> that calls kthread_stop and up() the semaphore.
> 
> sync_stop:
>         kthread_stop(k)
>         up(s)
> 
> kthread_routine:
>         while(1) {
>                 down(s)
>                 if (kthread_should_stop(k))
>                         break;
> 
>                 get sync msg
>                 send sync msg
>         }
> 
> BTW, each up() does not necessarily mean one wakeup event. up() will
> delivery only one wakeup event for one process that has been already
> awaken.

	OK, now I added up(). It will be called when
32 messages are queued after last sent by thread.

> > 	I'm still thinking if sndbuf value should be exported,
> > currently users have to modify the global default/max value.
> 
> I think it's a good idea.

	Done, used same value both for rcvbuf and sndbuf.

> > But in below version I'm trying to handle the sndbuf overflow
> > by blocking for write_space event. By this way we should work
> > with any sndbuf configuration.
> 
> You seem to be defering the overrun problem by using a longer
> intermediate queue than the socket buffer. Then, that queue can be
> tuned by the user via sysctl. It may happen under heavy stress that
> your intermediate queue gets full again, then you'll have to drop
> packets at some point.

	Yes, both values are for same thing, the problem is
that queue size is in messages while socket buffer is in bytes.
And as sndbuf config is optional, I'm not trying to derive
sync_qlen_max from sndbuf. May be we can do it after
socket is created but it will cause problem for systems
that do not configure sync_sock_size, they before now used
unlimited queue and may be default socket size, so using
some small default sndbuf as sync_qlen_max can cause message
drops. They will use reduced limits. So, now we provide
some large sync_qlen_max as default configuration
which probably exceeds the default socket buffer.

	Still, I think the down/up idea is not better.
We are adding two new vars: master_stopped and
master_sem.

	The problem is that kthread_stop() is a blocking
function. It waits thread to terminate. It can not wakeup
thread blocked in down(), so we add master_stopped flag
that will unblock the down() loop while kthread_stop() will also
unblock thread if waiting for write_space. I.e. up()+kthread_stop()
is racy without additional flag while kthread_stop()+up()
is not possible to work.

	I'm appending untested version with up+down but I think
we should use wake_up_process and schedule_timeout instead,
as in previous version.

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 2bdee51..8ed41eb 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -870,6 +870,8 @@ struct netns_ipvs {
 #endif
 	int			sysctl_snat_reroute;
 	int			sysctl_sync_ver;
+	int			sysctl_sync_qlen_max;
+	int			sysctl_sync_sock_size;
 	int			sysctl_cache_bypass;
 	int			sysctl_expire_nodest_conn;
 	int			sysctl_expire_quiescent_template;
@@ -890,6 +892,10 @@ struct netns_ipvs {
 	struct timer_list	est_timer;	/* Estimation timer */
 	/* ip_vs_sync */
 	struct list_head	sync_queue;
+	int			sync_queue_len;
+	unsigned int		sync_queue_delay;
+	int			master_stopped;
+	struct semaphore	master_sem;
 	spinlock_t		sync_lock;
 	struct ip_vs_sync_buff  *sync_buff;
 	spinlock_t		sync_buff_lock;
@@ -912,6 +918,8 @@ struct netns_ipvs {
 #define DEFAULT_SYNC_THRESHOLD	3
 #define DEFAULT_SYNC_PERIOD	50
 #define DEFAULT_SYNC_VER	1
+#define IPVS_SYNC_WAKEUP_RATE	32
+#define IPVS_SYNC_QLEN_MAX	(IPVS_SYNC_WAKEUP_RATE * 4)
 
 #ifdef CONFIG_SYSCTL
 
@@ -930,6 +938,16 @@ static inline int sysctl_sync_ver(struct netns_ipvs *ipvs)
 	return ipvs->sysctl_sync_ver;
 }
 
+static inline int sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_sync_qlen_max;
+}
+
+static inline int sysctl_sync_sock_size(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_sync_sock_size;
+}
+
 #else
 
 static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
@@ -947,6 +965,16 @@ static inline int sysctl_sync_ver(struct netns_ipvs *ipvs)
 	return DEFAULT_SYNC_VER;
 }
 
+static inline int sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
+{
+	return IPVS_SYNC_QLEN_MAX;
+}
+
+static inline int sysctl_sync_sock_size(struct netns_ipvs *ipvs)
+{
+	return 0;
+}
+
 #endif
 
 /*
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 964d426..2172fcc 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1718,6 +1718,18 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_do_sync_mode,
 	},
 	{
+		.procname	= "sync_qlen_max",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "sync_sock_size",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "cache_bypass",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
@@ -3662,6 +3674,10 @@ int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	tbl[idx++].data = &ipvs->sysctl_snat_reroute;
 	ipvs->sysctl_sync_ver = 1;
 	tbl[idx++].data = &ipvs->sysctl_sync_ver;
+	ipvs->sysctl_sync_qlen_max = nr_free_buffer_pages() / 32;
+	tbl[idx++].data = &ipvs->sysctl_sync_qlen_max;
+	ipvs->sysctl_sync_sock_size = 0;
+	tbl[idx++].data = &ipvs->sysctl_sync_sock_size;
 	tbl[idx++].data = &ipvs->sysctl_cache_bypass;
 	tbl[idx++].data = &ipvs->sysctl_expire_nodest_conn;
 	tbl[idx++].data = &ipvs->sysctl_expire_quiescent_template;
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 0e36679..0bd473c 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -312,6 +312,9 @@ static inline struct ip_vs_sync_buff *sb_dequeue(struct netns_ipvs *ipvs)
 				struct ip_vs_sync_buff,
 				list);
 		list_del(&sb->list);
+		ipvs->sync_queue_len--;
+		if (!ipvs->sync_queue_len)
+			ipvs->sync_queue_delay = 0;
 	}
 	spin_unlock_bh(&ipvs->sync_lock);
 
@@ -358,9 +361,13 @@ static inline void sb_queue_tail(struct netns_ipvs *ipvs)
 	struct ip_vs_sync_buff *sb = ipvs->sync_buff;
 
 	spin_lock(&ipvs->sync_lock);
-	if (ipvs->sync_state & IP_VS_STATE_MASTER)
+	if (ipvs->sync_state & IP_VS_STATE_MASTER &&
+	    ipvs->sync_queue_len < sysctl_sync_qlen_max(ipvs)) {
 		list_add_tail(&sb->list, &ipvs->sync_queue);
-	else
+		ipvs->sync_queue_len++;
+		if ((++ipvs->sync_queue_delay) == IPVS_SYNC_WAKEUP_RATE)
+			up(&ipvs->master_sem);
+	} else
 		ip_vs_sync_buff_release(sb);
 	spin_unlock(&ipvs->sync_lock);
 }
@@ -405,10 +412,11 @@ void ip_vs_sync_switch_mode(struct net *net, int mode)
 		ipvs->sync_buff = NULL;
 	} else {
 		spin_lock_bh(&ipvs->sync_lock);
-		if (ipvs->sync_state & IP_VS_STATE_MASTER)
+		if (ipvs->sync_state & IP_VS_STATE_MASTER) {
 			list_add_tail(&ipvs->sync_buff->list,
 				      &ipvs->sync_queue);
-		else
+			ipvs->sync_queue_len++;
+		} else
 			ip_vs_sync_buff_release(ipvs->sync_buff);
 		spin_unlock_bh(&ipvs->sync_lock);
 	}
@@ -1130,6 +1138,28 @@ static void ip_vs_process_message(struct net *net, __u8 *buffer,
 
 
 /*
+ *      Setup sndbuf (mode=1) or rcvbuf (mode=0)
+ */
+static void set_sock_size(struct sock *sk, int mode, int val)
+{
+	/* setsockopt(sock, SOL_SOCKET, SO_SNDBUF, &val, sizeof(val)); */
+	/* setsockopt(sock, SOL_SOCKET, SO_RCVBUF, &val, sizeof(val)); */
+	lock_sock(sk);
+	if (mode) {
+		val = clamp_t(int, val, (SOCK_MIN_SNDBUF + 1) / 2,
+			      sysctl_wmem_max);
+		sk->sk_sndbuf = val * 2;
+		sk->sk_userlocks |= SOCK_SNDBUF_LOCK;
+	} else {
+		val = clamp_t(int, val, (SOCK_MIN_RCVBUF + 1) / 2,
+			      sysctl_rmem_max);
+		sk->sk_rcvbuf = val * 2;
+		sk->sk_userlocks |= SOCK_RCVBUF_LOCK;
+	}
+	release_sock(sk);
+}
+
+/*
  *      Setup loopback of outgoing multicasts on a sending socket
  */
 static void set_mcast_loop(struct sock *sk, u_char loop)
@@ -1305,6 +1335,9 @@ static struct socket *make_send_sock(struct net *net)
 
 	set_mcast_loop(sock->sk, 0);
 	set_mcast_ttl(sock->sk, 1);
+	result = sysctl_sync_sock_size(ipvs);
+	if (result > 0)
+		set_sock_size(sock->sk, 1, result);
 
 	result = bind_mcastif_addr(sock, ipvs->master_mcast_ifn);
 	if (result < 0) {
@@ -1350,6 +1383,9 @@ static struct socket *make_receive_sock(struct net *net)
 	sk_change_net(sock->sk, net);
 	/* it is equivalent to the REUSEADDR option in user-space */
 	sock->sk->sk_reuse = 1;
+	result = sysctl_sync_sock_size(ipvs);
+	if (result > 0)
+		set_sock_size(sock->sk, 0, result);
 
 	result = sock->ops->bind(sock, (struct sockaddr *) &mcast_addr,
 			sizeof(struct sockaddr));
@@ -1392,18 +1428,22 @@ ip_vs_send_async(struct socket *sock, const char *buffer, const size_t length)
 	return len;
 }
 
-static void
+static int
 ip_vs_send_sync_msg(struct socket *sock, struct ip_vs_sync_mesg *msg)
 {
 	int msize;
+	int ret;
 
 	msize = msg->size;
 
 	/* Put size in network byte order */
 	msg->size = htons(msg->size);
 
-	if (ip_vs_send_async(sock, (char *)msg, msize) != msize)
-		pr_err("ip_vs_send_async error\n");
+	ret = ip_vs_send_async(sock, (char *)msg, msize);
+	if (ret >= 0 || ret == -EAGAIN)
+		return ret;
+	pr_err("ip_vs_send_async error %d\n", ret);
+	return 0;
 }
 
 static int
@@ -1428,33 +1468,57 @@ ip_vs_receive(struct socket *sock, char *buffer, const size_t buflen)
 	return len;
 }
 
+/* Get next buffer to send */
+static inline struct ip_vs_sync_buff *
+next_sync_buff(struct netns_ipvs *ipvs)
+{
+	struct ip_vs_sync_buff *sb;
+
+	sb = sb_dequeue(ipvs);
+	if (sb)
+		return sb;
+	/* Do not delay entries in buffer for more than 2 seconds */
+	return get_curr_sync_buff(ipvs, 2 * HZ);
+}
 
 static int sync_thread_master(void *data)
 {
 	struct ip_vs_sync_thread_data *tinfo = data;
 	struct netns_ipvs *ipvs = net_ipvs(tinfo->net);
+	struct sock *sk = tinfo->sock->sk;
 	struct ip_vs_sync_buff *sb;
 
 	pr_info("sync thread started: state = MASTER, mcast_ifn = %s, "
 		"syncid = %d\n",
 		ipvs->master_mcast_ifn, ipvs->master_syncid);
 
-	while (!kthread_should_stop()) {
-		while ((sb = sb_dequeue(ipvs))) {
-			ip_vs_send_sync_msg(tinfo->sock, sb->mesg);
-			ip_vs_sync_buff_release(sb);
+	for (;;) {
+		sb = next_sync_buff(ipvs);
+		if (!sb) {
+			down_timeout(&ipvs->master_sem, HZ / 5);
+			if (ipvs->master_stopped)
+				break;
+			continue;
 		}
 
-		/* check if entries stay in ipvs->sync_buff for 2 seconds */
-		sb = get_curr_sync_buff(ipvs, 2 * HZ);
-		if (sb) {
-			ip_vs_send_sync_msg(tinfo->sock, sb->mesg);
-			ip_vs_sync_buff_release(sb);
+retry:
+		if (unlikely(ipvs->master_stopped))
+			break;
+		if (ip_vs_send_sync_msg(tinfo->sock, sb->mesg) < 0) {
+			int ret = 0;
+
+			__wait_event_interruptible(*sk_sleep(sk),
+						   sock_writeable(sk) ||
+						   kthread_should_stop(),
+						   ret);
+			goto retry;
 		}
-
-		schedule_timeout_interruptible(HZ);
+		ip_vs_sync_buff_release(sb);
 	}
 
+	if (sb)
+		ip_vs_sync_buff_release(sb);
+
 	/* clean up the sync_buff queue */
 	while ((sb = sb_dequeue(ipvs)))
 		ip_vs_sync_buff_release(sb);
@@ -1538,6 +1602,10 @@ int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid)
 		realtask = &ipvs->master_thread;
 		name = "ipvs_master:%d";
 		threadfn = sync_thread_master;
+		ipvs->sync_queue_len = 0;
+		ipvs->sync_queue_delay = 0;
+		ipvs->master_stopped = 0;
+		sema_init(&ipvs->master_sem, 0);
 		sock = make_send_sock(net);
 	} else if (state == IP_VS_STATE_BACKUP) {
 		if (ipvs->backup_thread)
@@ -1623,6 +1691,8 @@ int stop_sync_thread(struct net *net, int state)
 		spin_lock_bh(&ipvs->sync_lock);
 		ipvs->sync_state &= ~IP_VS_STATE_MASTER;
 		spin_unlock_bh(&ipvs->sync_lock);
+		ipvs->master_stopped = 1;
+		up(&ipvs->master_sem);
 		retc = kthread_stop(ipvs->master_thread);
 		ipvs->master_thread = NULL;
 	} else if (state == IP_VS_STATE_BACKUP) {
