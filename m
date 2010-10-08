From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [RFC PATCH 9/9] ipvs network name space aware
Date: Fri, 8 Oct 2010 13:17:13 +0200
Message-ID: <201010081317.15354.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr

This patch contains ip_vs_sync.c and ip_vs_xmit.c

There is one sync daemon per netns, and a number is prepended to its name.
(a kind of incarnation counter)

Part of the netns migration in ip_vs_xmit.c was done in the IPv6 tunnel patch,
so make sure that "[patch v4] ipvs: IPv6 tunnel mode" is applied

Signed-off-by:Hans Schillstrom <hans.schillstrom@ericsson.com>

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 7ba0693..98575da 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -74,6 +74,7 @@ struct ip_vs_sync_conn_options {
 struct ip_vs_sync_thread_data {
 	struct socket *sock;
 	char *buf;
+	struct net *net;
 };

 #define SIMPLE_CONN_SIZE  (sizeof(struct ip_vs_sync_conn))
@@ -113,9 +114,6 @@ struct ip_vs_sync_mesg {
 	/* ip_vs_sync_conn entries start here */
 };

-/* the maximum length of sync (sending/receiving) message */
-static int sync_send_mesg_maxlen;
-static int sync_recv_mesg_maxlen;

 struct ip_vs_sync_buff {
 	struct list_head        list;
@@ -127,70 +125,41 @@ struct ip_vs_sync_buff {
 	unsigned char           *end;
 };

-
-/* the sync_buff list head and the lock */
-static LIST_HEAD(ip_vs_sync_queue);
-static DEFINE_SPINLOCK(ip_vs_sync_lock);
-
-/* current sync_buff for accepting new conn entries */
-static struct ip_vs_sync_buff   *curr_sb = NULL;
-static DEFINE_SPINLOCK(curr_sb_lock);
-
-/* ipvs sync daemon state */
-volatile int ip_vs_sync_state = IP_VS_STATE_NONE;
-volatile int ip_vs_master_syncid = 0;
-volatile int ip_vs_backup_syncid = 0;
-
-/* multicast interface name */
-char ip_vs_master_mcast_ifn[IP_VS_IFNAME_MAXLEN];
-char ip_vs_backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
-
-/* sync daemon tasks */
-static struct task_struct *sync_master_thread;
-static struct task_struct *sync_backup_thread;
-
-/* multicast addr */
-static struct sockaddr_in mcast_addr = {
-	.sin_family		= AF_INET,
-	.sin_port		= cpu_to_be16(IP_VS_SYNC_PORT),
-	.sin_addr.s_addr	= cpu_to_be32(IP_VS_SYNC_GROUP),
-};
-
-
-static inline struct ip_vs_sync_buff *sb_dequeue(void)
+static inline struct ip_vs_sync_buff *sb_dequeue(struct net *net)
 {
 	struct ip_vs_sync_buff *sb;
+	struct netns_ipvs *ipvs = net->ipvs;

-	spin_lock_bh(&ip_vs_sync_lock);
-	if (list_empty(&ip_vs_sync_queue)) {
+	spin_lock_bh(&ipvs->sync_lock);
+	if (list_empty(&ipvs->sync_queue)) {
 		sb = NULL;
 	} else {
-		sb = list_entry(ip_vs_sync_queue.next,
+		sb = list_entry(ipvs->sync_queue.next,
 				struct ip_vs_sync_buff,
 				list);
 		list_del(&sb->list);
 	}
-	spin_unlock_bh(&ip_vs_sync_lock);
+	spin_unlock_bh(&ipvs->sync_lock);

 	return sb;
 }

-static inline struct ip_vs_sync_buff * ip_vs_sync_buff_create(void)
+static inline struct ip_vs_sync_buff * ip_vs_sync_buff_create(struct net *net)
 {
 	struct ip_vs_sync_buff *sb;

 	if (!(sb=kmalloc(sizeof(struct ip_vs_sync_buff), GFP_ATOMIC)))
 		return NULL;

-	if (!(sb->mesg=kmalloc(sync_send_mesg_maxlen, GFP_ATOMIC))) {
+	if (!(sb->mesg=kmalloc(net->ipvs->sync_send_mesg_maxlen, GFP_ATOMIC))) {
 		kfree(sb);
 		return NULL;
 	}
 	sb->mesg->nr_conns = 0;
-	sb->mesg->syncid = ip_vs_master_syncid;
+	sb->mesg->syncid = net->ipvs->master_syncid;
 	sb->mesg->size = 4;
 	sb->head = (unsigned char *)sb->mesg + 4;
-	sb->end = (unsigned char *)sb->mesg + sync_send_mesg_maxlen;
+	sb->end = (unsigned char *)sb->mesg + net->ipvs->sync_send_mesg_maxlen;
 	sb->firstuse = jiffies;
 	return sb;
 }
@@ -201,14 +170,16 @@ static inline void ip_vs_sync_buff_release(struct ip_vs_sync_buff *sb)
 	kfree(sb);
 }

-static inline void sb_queue_tail(struct ip_vs_sync_buff *sb)
+static inline void sb_queue_tail(struct net *net, struct ip_vs_sync_buff *sb)
 {
-	spin_lock(&ip_vs_sync_lock);
-	if (ip_vs_sync_state & IP_VS_STATE_MASTER)
-		list_add_tail(&sb->list, &ip_vs_sync_queue);
+	struct netns_ipvs *ipvs = net->ipvs;
+
+	spin_lock(&ipvs->sync_lock);
+	if (ipvs->sync_state & IP_VS_STATE_MASTER)
+		list_add_tail(&sb->list, &ipvs->sync_queue);
 	else
 		ip_vs_sync_buff_release(sb);
-	spin_unlock(&ip_vs_sync_lock);
+	spin_unlock(&ipvs->sync_lock);
 }

 /*
@@ -216,18 +187,19 @@ static inline void sb_queue_tail(struct ip_vs_sync_buff *sb)
  *	than the specified time or the specified time is zero.
  */
 static inline struct ip_vs_sync_buff *
-get_curr_sync_buff(unsigned long time)
+get_curr_sync_buff(struct net *net, unsigned long time)
 {
 	struct ip_vs_sync_buff *sb;
+	struct netns_ipvs *ipvs = net->ipvs;

-	spin_lock_bh(&curr_sb_lock);
-	if (curr_sb && (time == 0 ||
-			time_before(jiffies - curr_sb->firstuse, time))) {
-		sb = curr_sb;
-		curr_sb = NULL;
+	spin_lock_bh(&ipvs->sync_buff_lock);
+	if (ipvs->sync_buff && (time == 0 ||
+			time_before(jiffies - ipvs->sync_buff->firstuse, time))) {
+		sb = ipvs->sync_buff;
+		ipvs->sync_buff = NULL;
 	} else
 		sb = NULL;
-	spin_unlock_bh(&curr_sb_lock);
+	spin_unlock_bh(&ipvs->sync_buff_lock);
 	return sb;
 }

@@ -236,16 +208,17 @@ get_curr_sync_buff(unsigned long time)
  *      Add an ip_vs_conn information into the current sync_buff.
  *      Called by ip_vs_in.
  */
-void ip_vs_sync_conn(struct ip_vs_conn *cp)
+void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp)
 {
 	struct ip_vs_sync_mesg *m;
 	struct ip_vs_sync_conn *s;
 	int len;
+	struct netns_ipvs *ipvs = net->ipvs;

-	spin_lock(&curr_sb_lock);
-	if (!curr_sb) {
-		if (!(curr_sb=ip_vs_sync_buff_create())) {
-			spin_unlock(&curr_sb_lock);
+	spin_lock(&ipvs->sync_buff_lock);
+	if (!ipvs->sync_buff) {
+		if (!(ipvs->sync_buff=ip_vs_sync_buff_create(net))) {
+			spin_unlock(&ipvs->sync_buff_lock);
 			pr_err("ip_vs_sync_buff_create failed.\n");
 			return;
 		}
@@ -253,8 +226,8 @@ void ip_vs_sync_conn(struct ip_vs_conn *cp)

 	len = (cp->flags & IP_VS_CONN_F_SEQ_MASK) ? FULL_CONN_SIZE :
 		SIMPLE_CONN_SIZE;
-	m = curr_sb->mesg;
-	s = (struct ip_vs_sync_conn *)curr_sb->head;
+	m = ipvs->sync_buff->mesg;
+	s = (struct ip_vs_sync_conn *)ipvs->sync_buff->head;

 	/* copy members */
 	s->protocol = cp->protocol;
@@ -274,18 +247,18 @@ void ip_vs_sync_conn(struct ip_vs_conn *cp)

 	m->nr_conns++;
 	m->size += len;
-	curr_sb->head += len;
+	ipvs->sync_buff->head += len;

 	/* check if there is a space for next one */
-	if (curr_sb->head+FULL_CONN_SIZE > curr_sb->end) {
-		sb_queue_tail(curr_sb);
-		curr_sb = NULL;
+	if (ipvs->sync_buff->head+FULL_CONN_SIZE > ipvs->sync_buff->end) {
+		sb_queue_tail(net, ipvs->sync_buff);
+		ipvs->sync_buff = NULL;
 	}
-	spin_unlock(&curr_sb_lock);
+	spin_unlock(&ipvs->sync_buff_lock);

 	/* synchronize its controller if it has */
 	if (cp->control)
-		ip_vs_sync_conn(cp->control);
+		ip_vs_sync_conn(net, cp->control);
 }


@@ -293,13 +266,15 @@ void ip_vs_sync_conn(struct ip_vs_conn *cp)
  *      Process received multicast message and create the corresponding
  *      ip_vs_conn entries.
  */
-static void ip_vs_process_message(const char *buffer, const size_t buflen)
+static void
+ip_vs_process_message(struct net *net, const char *buffer, const size_t buflen)
 {
 	struct ip_vs_sync_mesg *m = (struct ip_vs_sync_mesg *)buffer;
 	struct ip_vs_sync_conn *s;
 	struct ip_vs_sync_conn_options *opt;
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
+	struct ip_vs_proto_data *pd;
 	struct ip_vs_dest *dest;
 	char *p;
 	int i;
@@ -318,7 +293,7 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 	}

 	/* SyncID sanity check */
-	if (ip_vs_backup_syncid != 0 && m->syncid != ip_vs_backup_syncid) {
+	if (net->ipvs->backup_syncid != 0 && m->syncid != net->ipvs->backup_syncid) {
 		IP_VS_DBG(7, "Ignoring incoming msg with syncid = %d\n",
 			  m->syncid);
 		return;
@@ -371,13 +346,13 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 		}

 		if (!(flags & IP_VS_CONN_F_TEMPLATE))
-			cp = ip_vs_conn_in_get(AF_INET, s->protocol,
+			cp = ip_vs_conn_in_get(net, AF_INET, s->protocol,
 					       (union nf_inet_addr *)&s->caddr,
 					       s->cport,
 					       (union nf_inet_addr *)&s->vaddr,
 					       s->vport);
 		else
-			cp = ip_vs_ct_in_get(AF_INET, s->protocol,
+			cp = ip_vs_ct_in_get(net, AF_INET, s->protocol,
 					     (union nf_inet_addr *)&s->caddr,
 					     s->cport,
 					     (union nf_inet_addr *)&s->vaddr,
@@ -388,7 +363,7 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 			 * If it is not found the connection will remain unbound
 			 * but still handled.
 			 */
-			dest = ip_vs_find_dest(AF_INET,
+			dest = ip_vs_find_dest(net, AF_INET,
 					       (union nf_inet_addr *)&s->daddr,
 					       s->dport,
 					       (union nf_inet_addr *)&s->vaddr,
@@ -406,7 +381,7 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 				else
 					flags &= ~IP_VS_CONN_F_INACTIVE;
 			}
-			cp = ip_vs_conn_new(AF_INET, s->protocol,
+			cp = ip_vs_conn_new(net, AF_INET, s->protocol,
 					    (union nf_inet_addr *)&s->caddr,
 					    s->cport,
 					    (union nf_inet_addr *)&s->vaddr,
@@ -421,7 +396,7 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 				return;
 			}
 		} else if (!cp->dest) {
-			dest = ip_vs_try_bind_dest(cp);
+			dest = ip_vs_try_bind_dest(net, cp);
 			if (dest)
 				atomic_dec(&dest->refcnt);
 		} else if ((cp->dest) && (cp->protocol == IPPROTO_TCP) &&
@@ -452,7 +427,7 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)

 		if (opt)
 			memcpy(&cp->in_seq, opt, sizeof(*opt));
-		atomic_set(&cp->in_pkts, sysctl_ip_vs_sync_threshold[0]);
+		atomic_set(&cp->in_pkts, net->ipvs->sysctl_sync_threshold[0]);
 		cp->state = state;
 		cp->old_state = cp->state;
 		/*
@@ -461,8 +436,9 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 		 * virtual service. If needed, we can do it for
 		 * non-fwmark persistent services.
 		 */
-		if (!(flags & IP_VS_CONN_F_TEMPLATE) && pp->timeout_table)
-			cp->timeout = pp->timeout_table[state];
+		pd = ip_vs_proto_data_get(net,cp->protocol);
+		if (!(flags & IP_VS_CONN_F_TEMPLATE) && pd && pd->timeout_table )
+			cp->timeout = pd->timeout_table[state];
 		else
 			cp->timeout = (3*60*HZ);
 		ip_vs_conn_put(cp);
@@ -503,8 +479,10 @@ static int set_mcast_if(struct sock *sk, char *ifname)
 {
 	struct net_device *dev;
 	struct inet_sock *inet = inet_sk(sk);
+	struct net *net = sock_net(sk);

-	if ((dev = __dev_get_by_name(&init_net, ifname)) == NULL)
+	BUG_ON(!net);
+	if ((dev = __dev_get_by_name(net, ifname)) == NULL)
 		return -ENODEV;

 	if (sk->sk_bound_dev_if && dev->ifindex != sk->sk_bound_dev_if)
@@ -523,30 +501,31 @@ static int set_mcast_if(struct sock *sk, char *ifname)
  *	Set the maximum length of sync message according to the
  *	specified interface's MTU.
  */
-static int set_sync_mesg_maxlen(int sync_state)
+static int set_sync_mesg_maxlen(struct net *net, int sync_state)
 {
 	struct net_device *dev;
 	int num;
+	struct netns_ipvs *ipvs = net->ipvs;

 	if (sync_state == IP_VS_STATE_MASTER) {
-		if ((dev = __dev_get_by_name(&init_net, ip_vs_master_mcast_ifn)) == NULL)
+		if ((dev = __dev_get_by_name(net, ipvs->master_mcast_ifn)) == NULL)
 			return -ENODEV;

 		num = (dev->mtu - sizeof(struct iphdr) -
 		       sizeof(struct udphdr) -
 		       SYNC_MESG_HEADER_LEN - 20) / SIMPLE_CONN_SIZE;
-		sync_send_mesg_maxlen = SYNC_MESG_HEADER_LEN +
+		ipvs->sync_send_mesg_maxlen = SYNC_MESG_HEADER_LEN +
 			SIMPLE_CONN_SIZE * min(num, MAX_CONNS_PER_SYNCBUFF);
 		IP_VS_DBG(7, "setting the maximum length of sync sending "
-			  "message %d.\n", sync_send_mesg_maxlen);
+			  "message %d.\n", ipvs->sync_send_mesg_maxlen);
 	} else if (sync_state == IP_VS_STATE_BACKUP) {
-		if ((dev = __dev_get_by_name(&init_net, ip_vs_backup_mcast_ifn)) == NULL)
+		if ((dev = __dev_get_by_name(net, ipvs->backup_mcast_ifn)) == NULL)
 			return -ENODEV;

-		sync_recv_mesg_maxlen = dev->mtu -
+		ipvs->sync_recv_mesg_maxlen = dev->mtu -
 			sizeof(struct iphdr) - sizeof(struct udphdr);
 		IP_VS_DBG(7, "setting the maximum length of sync receiving "
-			  "message %d.\n", sync_recv_mesg_maxlen);
+			  "message %d.\n", ipvs->sync_recv_mesg_maxlen);
 	}

 	return 0;
@@ -564,11 +543,13 @@ join_mcast_group(struct sock *sk, struct in_addr *addr, char *ifname)
 	struct ip_mreqn mreq;
 	struct net_device *dev;
 	int ret;
+	struct net *net = sock_net(sk);

+	BUG_ON(!net);
 	memset(&mreq, 0, sizeof(mreq));
 	memcpy(&mreq.imr_multiaddr, addr, sizeof(struct in_addr));

-	if ((dev = __dev_get_by_name(&init_net, ifname)) == NULL)
+	if ((dev = __dev_get_by_name(net, ifname)) == NULL)
 		return -ENODEV;
 	if (sk->sk_bound_dev_if && dev->ifindex != sk->sk_bound_dev_if)
 		return -EINVAL;
@@ -588,8 +569,10 @@ static int bind_mcastif_addr(struct socket *sock, char *ifname)
 	struct net_device *dev;
 	__be32 addr;
 	struct sockaddr_in sin;
+	struct net *net = sock_net(sock->sk);

-	if ((dev = __dev_get_by_name(&init_net, ifname)) == NULL)
+	BUG_ON(!net);
+	if ((dev = __dev_get_by_name(net, ifname)) == NULL)
 		return -ENODEV;

 	addr = inet_select_addr(dev, 0, RT_SCOPE_UNIVERSE);
@@ -611,19 +594,19 @@ static int bind_mcastif_addr(struct socket *sock, char *ifname)
 /*
  *      Set up sending multicast socket over UDP
  */
-static struct socket * make_send_sock(void)
+static struct socket * make_send_sock(struct net *net)
 {
 	struct socket *sock;
 	int result;

-	/* First create a socket */
-	result = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	/* First create a socket in current netns  */
+	result = sock_create(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
 	if (result < 0) {
 		pr_err("Error during creation of socket; terminating\n");
 		return ERR_PTR(result);
 	}

-	result = set_mcast_if(sock->sk, ip_vs_master_mcast_ifn);
+	result = set_mcast_if(sock->sk, net->ipvs->master_mcast_ifn);
 	if (result < 0) {
 		pr_err("Error setting outbound mcast interface\n");
 		goto error;
@@ -632,13 +615,14 @@ static struct socket * make_send_sock(void)
 	set_mcast_loop(sock->sk, 0);
 	set_mcast_ttl(sock->sk, 1);

-	result = bind_mcastif_addr(sock, ip_vs_master_mcast_ifn);
+	result = bind_mcastif_addr(sock, net->ipvs->master_mcast_ifn);
 	if (result < 0) {
 		pr_err("Error binding address of the mcast interface\n");
 		goto error;
 	}

-	result = sock->ops->connect(sock, (struct sockaddr *) &mcast_addr,
+	result = sock->ops->connect(sock,
+			(struct sockaddr *) &net->ipvs->sync_mcast_addr,
 			sizeof(struct sockaddr), 0);
 	if (result < 0) {
 		pr_err("Error connecting to the multicast addr\n");
@@ -656,13 +640,13 @@ static struct socket * make_send_sock(void)
 /*
  *      Set up receiving multicast socket over UDP
  */
-static struct socket * make_receive_sock(void)
+static struct socket * make_receive_sock(struct net *net)
 {
 	struct socket *sock;
 	int result;

-	/* First create a socket */
-	result = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	/* First create a socket in current netns */
+	result = sock_create(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
 	if (result < 0) {
 		pr_err("Error during creation of socket; terminating\n");
 		return ERR_PTR(result);
@@ -671,7 +655,8 @@ static struct socket * make_receive_sock(void)
 	/* it is equivalent to the REUSEADDR option in user-space */
 	sock->sk->sk_reuse = 1;

-	result = sock->ops->bind(sock, (struct sockaddr *) &mcast_addr,
+	result = sock->ops->bind(sock,
+			(struct sockaddr *) &net->ipvs->sync_mcast_addr,
 			sizeof(struct sockaddr));
 	if (result < 0) {
 		pr_err("Error binding to the multicast addr\n");
@@ -680,8 +665,8 @@ static struct socket * make_receive_sock(void)

 	/* join the multicast group */
 	result = join_mcast_group(sock->sk,
-			(struct in_addr *) &mcast_addr.sin_addr,
-			ip_vs_backup_mcast_ifn);
+			(struct in_addr *) &net->ipvs->sync_mcast_addr.sin_addr,
+			net->ipvs->backup_mcast_ifn);
 	if (result < 0) {
 		pr_err("Error joining to the multicast group\n");
 		goto error;
@@ -756,16 +741,17 @@ static int sync_thread_master(void *data)

 	pr_info("sync thread started: state = MASTER, mcast_ifn = %s, "
 		"syncid = %d\n",
-		ip_vs_master_mcast_ifn, ip_vs_master_syncid);
+		tinfo->net->ipvs->master_mcast_ifn,
+		tinfo->net->ipvs->master_syncid);

 	while (!kthread_should_stop()) {
-		while ((sb = sb_dequeue())) {
+		while ((sb = sb_dequeue(tinfo->net))) {
 			ip_vs_send_sync_msg(tinfo->sock, sb->mesg);
 			ip_vs_sync_buff_release(sb);
 		}

 		/* check if entries stay in curr_sb for 2 seconds */
-		sb = get_curr_sync_buff(2 * HZ);
+		sb = get_curr_sync_buff(tinfo->net, 2 * HZ);
 		if (sb) {
 			ip_vs_send_sync_msg(tinfo->sock, sb->mesg);
 			ip_vs_sync_buff_release(sb);
@@ -775,12 +761,12 @@ static int sync_thread_master(void *data)
 	}

 	/* clean up the sync_buff queue */
-	while ((sb=sb_dequeue())) {
+	while ((sb=sb_dequeue(tinfo->net))) {
 		ip_vs_sync_buff_release(sb);
 	}

 	/* clean up the current sync_buff */
-	if ((sb = get_curr_sync_buff(0))) {
+	if ((sb = get_curr_sync_buff(tinfo->net, 0))) {
 		ip_vs_sync_buff_release(sb);
 	}

@@ -796,10 +782,11 @@ static int sync_thread_backup(void *data)
 {
 	struct ip_vs_sync_thread_data *tinfo = data;
 	int len;
-
+
 	pr_info("sync thread started: state = BACKUP, mcast_ifn = %s, "
 		"syncid = %d\n",
-		ip_vs_backup_mcast_ifn, ip_vs_backup_syncid);
+		tinfo->net->ipvs->backup_mcast_ifn,
+		tinfo->net->ipvs->backup_syncid);

 	while (!kthread_should_stop()) {
 		wait_event_interruptible(*sk_sleep(tinfo->sock->sk),
@@ -809,16 +796,15 @@ static int sync_thread_backup(void *data)
 		/* do we have data now? */
 		while (!skb_queue_empty(&(tinfo->sock->sk->sk_receive_queue))) {
 			len = ip_vs_receive(tinfo->sock, tinfo->buf,
-					sync_recv_mesg_maxlen);
+					tinfo->net->ipvs->sync_recv_mesg_maxlen);
 			if (len <= 0) {
 				pr_err("receiving message error\n");
 				break;
 			}
-
-			/* disable bottom half, because it accesses the data
+			/* disable bottom half per netns, because it accesses the data
 			   shared by softirq while getting/creating conns */
 			local_bh_disable();
-			ip_vs_process_message(tinfo->buf, len);
+			ip_vs_process_message(tinfo->net, tinfo->buf, len);
 			local_bh_enable();
 		}
 	}
@@ -832,41 +818,43 @@ static int sync_thread_backup(void *data)
 }


-int start_sync_thread(int state, char *mcast_ifn, __u8 syncid)
+int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid)
 {
 	struct ip_vs_sync_thread_data *tinfo;
 	struct task_struct **realtask, *task;
 	struct socket *sock;
+	struct netns_ipvs *ipvs = net->ipvs;
 	char *name, *buf = NULL;
 	int (*threadfn)(void *data);
 	int result = -ENOMEM;

-	IP_VS_DBG(7, "%s(): pid %d\n", __func__, task_pid_nr(current));
+	IP_VS_DBG(7, "%s(): pid %d inc:%d\n", __func__, task_pid_nr(current),
+		                             ipvs->inc);
 	IP_VS_DBG(7, "Each ip_vs_sync_conn entry needs %Zd bytes\n",
 		  sizeof(struct ip_vs_sync_conn));

 	if (state == IP_VS_STATE_MASTER) {
-		if (sync_master_thread)
+		if (ipvs->sync_master_thread)
 			return -EEXIST;

-		strlcpy(ip_vs_master_mcast_ifn, mcast_ifn,
-			sizeof(ip_vs_master_mcast_ifn));
-		ip_vs_master_syncid = syncid;
-		realtask = &sync_master_thread;
-		name = "ipvs_syncmaster";
+		strlcpy(ipvs->master_mcast_ifn, mcast_ifn,
+			sizeof(ipvs->master_mcast_ifn));
+		ipvs->master_syncid = syncid;
+		realtask = &ipvs->sync_master_thread;
+		name = "ipvs_master:%d";
 		threadfn = sync_thread_master;
-		sock = make_send_sock();
+		sock = make_send_sock(net);
 	} else if (state == IP_VS_STATE_BACKUP) {
-		if (sync_backup_thread)
+		if (ipvs->sync_backup_thread)
 			return -EEXIST;

-		strlcpy(ip_vs_backup_mcast_ifn, mcast_ifn,
-			sizeof(ip_vs_backup_mcast_ifn));
-		ip_vs_backup_syncid = syncid;
-		realtask = &sync_backup_thread;
-		name = "ipvs_syncbackup";
+		strlcpy(ipvs->backup_mcast_ifn, mcast_ifn,
+			sizeof(ipvs->backup_mcast_ifn));
+		ipvs->backup_syncid = syncid;
+		realtask = &ipvs->sync_backup_thread;
+		name = "ipvs_backup:%d";
 		threadfn = sync_thread_backup;
-		sock = make_receive_sock();
+		sock = make_receive_sock(net);
 	} else {
 		return -EINVAL;
 	}
@@ -876,9 +864,9 @@ int start_sync_thread(int state, char *mcast_ifn, __u8 syncid)
 		goto out;
 	}

-	set_sync_mesg_maxlen(state);
+	set_sync_mesg_maxlen(net, state);
 	if (state == IP_VS_STATE_BACKUP) {
-		buf = kmalloc(sync_recv_mesg_maxlen, GFP_KERNEL);
+		buf = kmalloc(ipvs->sync_recv_mesg_maxlen, GFP_KERNEL);
 		if (!buf)
 			goto outsocket;
 	}
@@ -889,16 +877,17 @@ int start_sync_thread(int state, char *mcast_ifn, __u8 syncid)

 	tinfo->sock = sock;
 	tinfo->buf = buf;
+	tinfo->net = net;

-	task = kthread_run(threadfn, tinfo, name);
+	task = kthread_run(threadfn, tinfo, name, ipvs->inc);
 	if (IS_ERR(task)) {
 		result = PTR_ERR(task);
 		goto outtinfo;
 	}
-
+	IP_VS_DBG(1, "kthread %s started (%d)\n", name, task->pid);
 	/* mark as active */
 	*realtask = task;
-	ip_vs_sync_state |= state;
+	ipvs->sync_state |= state;

 	/* increase the module use count */
 	ip_vs_use_count_inc();
@@ -916,16 +905,19 @@ out:
 }


-int stop_sync_thread(int state)
+int stop_sync_thread(struct net *net, int state)
 {
+	struct netns_ipvs *ipvs = net->ipvs;
+
 	IP_VS_DBG(7, "%s(): pid %d\n", __func__, task_pid_nr(current));

 	if (state == IP_VS_STATE_MASTER) {
-		if (!sync_master_thread)
+		if (!ipvs->sync_master_thread)
 			return -ESRCH;

-		pr_info("stopping master sync thread %d ...\n",
-			task_pid_nr(sync_master_thread));
+		pr_info("stopping master sync thread %d  inc:%d...\n",
+			task_pid_nr(ipvs->sync_master_thread),
+			ipvs->inc);

 		/*
 		 * The lock synchronizes with sb_queue_tail(), so that we don't
@@ -933,21 +925,22 @@ int stop_sync_thread(int state)
 		 * progress of stopping the master sync daemon.
 		 */

-		spin_lock_bh(&ip_vs_sync_lock);
-		ip_vs_sync_state &= ~IP_VS_STATE_MASTER;
-		spin_unlock_bh(&ip_vs_sync_lock);
-		kthread_stop(sync_master_thread);
-		sync_master_thread = NULL;
+		spin_lock_bh(&ipvs->sync_lock);
+		ipvs->sync_state &= ~IP_VS_STATE_MASTER;
+		spin_unlock_bh(&ipvs->sync_lock);
+		kthread_stop(ipvs->sync_master_thread);
+		ipvs->sync_master_thread = NULL;
 	} else if (state == IP_VS_STATE_BACKUP) {
-		if (!sync_backup_thread)
+		if (!ipvs->sync_backup_thread)
 			return -ESRCH;

-		pr_info("stopping backup sync thread %d ...\n",
-			task_pid_nr(sync_backup_thread));
+		pr_info("stopping backup sync thread %d inc:%d...\n",
+			task_pid_nr(ipvs->sync_backup_thread),
+			ipvs->inc);

-		ip_vs_sync_state &= ~IP_VS_STATE_BACKUP;
-		kthread_stop(sync_backup_thread);
-		sync_backup_thread = NULL;
+		ipvs->sync_state &= ~IP_VS_STATE_BACKUP;
+		kthread_stop(ipvs->sync_backup_thread);
+		ipvs->sync_backup_thread = NULL;
 	} else {
 		return -EINVAL;
 	}
@@ -957,3 +950,41 @@ int stop_sync_thread(int state)

 	return 0;
 }
+
+/*
+ * Initialize data struct for each netns
+ */
+static int __net_init __ip_vs_sync_init(struct net *net)
+{
+	struct netns_ipvs *ipvs = net->ipvs;
+	INIT_LIST_HEAD(&ipvs->sync_queue);
+	spin_lock_init(&ipvs->sync_lock);
+	spin_lock_init(&ipvs->sync_buff_lock);
+
+	ipvs->sync_mcast_addr.sin_family = AF_INET;
+	ipvs->sync_mcast_addr.sin_port = cpu_to_be16(IP_VS_SYNC_PORT);
+	ipvs->sync_mcast_addr.sin_addr.s_addr = cpu_to_be32(IP_VS_SYNC_GROUP);
+	return 0;
+}
+
+static void __ip_vs_sync_cleanup(struct net *net)
+{
+	stop_sync_thread(net, net->ipvs->sync_state &
+			      (IP_VS_STATE_MASTER | IP_VS_STATE_BACKUP));
+	return;
+}
+static struct pernet_operations ipvs_sync_ops = {
+	.init = __ip_vs_sync_init,
+	.exit = __ip_vs_sync_cleanup,
+};
+
+
+int __init ip_vs_sync_init(void)
+{
+	return register_pernet_subsys(&ipvs_sync_ops);
+}
+
+void __exit ip_vs_sync_cleanup(void)
+{
+	unregister_pernet_subsys(&ipvs_sync_ops);
+}
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index a2e8497..d68178f 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -410,13 +410,15 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* check if it is a connection of no-client-port */
 	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT)) {
 		__be16 _pt, *p;
+		struct net *net;
 		p = skb_header_pointer(skb, iph->ihl*4, sizeof(_pt), &_pt);
 		if (p == NULL)
 			goto tx_error;
-		ip_vs_conn_fill_cport(cp, *p);
+		net = dev_net(skb->dev);
+		ip_vs_conn_fill_cport(net, cp, *p);
 		IP_VS_DBG(10, "filled cport=%d\n", ntohs(*p));
 	}
-
+	IP_VS_DBG(10, "%s() dst:%x\n", __func__, iph->daddr);
 	if (!(rt = __ip_vs_get_out_rt(skb, cp, RT_TOS(iph->tos))))
 		goto tx_error_icmp;

@@ -486,14 +488,16 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* check if it is a connection of no-client-port */
 	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT)) {
 		__be16 _pt, *p;
+		struct net *net;
 		p = skb_header_pointer(skb, sizeof(struct ipv6hdr),
 				       sizeof(_pt), &_pt);
 		if (p == NULL)
 			goto tx_error;
-		ip_vs_conn_fill_cport(cp, *p);
+		net = dev_net(skb->dev);
+		BUG_ON(!net);
+		ip_vs_conn_fill_cport(net, cp, *p);
 		IP_VS_DBG(10, "filled cport=%d\n", ntohs(*p));
 	}
-
 	rt = __ip_vs_get_out_rt_v6(skb, cp, NULL, 0);
 	if (!rt)
 		goto tx_error_icmp;

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
