From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 1/2] ipvs: add sync_maxlen parameter for the sync daemon
Date: Sun, 26 Jul 2015 15:03:27 +0300
Message-ID: <1437912208-29538-2-git-send-email-ja@ssi.bg>
References: <1437912208-29538-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1437912208-29538-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

Allow setups with large MTU to send large sync packets by
adding sync_maxlen parameter. The default value is now based
on MTU but no more than 1500 for compatibility reasons.

To avoid problems if MTU changes allow fragmentation by
sending packets with DF=0. Problem reported by Dan Carpenter.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |  19 +++---
 include/uapi/linux/ip_vs.h      |   1 +
 net/netfilter/ipvs/ip_vs_ctl.c  |  53 ++++++++++------
 net/netfilter/ipvs/ip_vs_sync.c | 137 ++++++++++++++++++----------------------
 4 files changed, 108 insertions(+), 102 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 4e3731e..2fdc13c 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -846,6 +846,13 @@ struct ipvs_master_sync_state {
 /* How much time to keep dests in trash */
 #define IP_VS_DEST_TRASH_PERIOD		(120 * HZ)
 
+struct ipvs_sync_daemon_cfg {
+	int			syncid;
+	u16			sync_maxlen;
+	/* multicast interface name */
+	char			mcast_ifn[IP_VS_IFNAME_MAXLEN];
+};
+
 /* IPVS in network namespace */
 struct netns_ipvs {
 	int			gen;		/* Generation */
@@ -961,15 +968,10 @@ struct netns_ipvs {
 	spinlock_t		sync_buff_lock;
 	struct task_struct	**backup_threads;
 	int			threads_mask;
-	int			send_mesg_maxlen;
-	int			recv_mesg_maxlen;
 	volatile int		sync_state;
-	volatile int		master_syncid;
-	volatile int		backup_syncid;
 	struct mutex		sync_mutex;
-	/* multicast interface name */
-	char			master_mcast_ifn[IP_VS_IFNAME_MAXLEN];
-	char			backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
+	struct ipvs_sync_daemon_cfg	mcfg;	/* Master Configuration */
+	struct ipvs_sync_daemon_cfg	bcfg;	/* Backup Configuration */
 	/* net name space ptr */
 	struct net		*net;            /* Needed by timer routines */
 	/* Number of heterogeneous destinations, needed becaus heterogeneous
@@ -1408,7 +1410,8 @@ static inline void ip_vs_dest_put_and_free(struct ip_vs_dest *dest)
 /* IPVS sync daemon data and function prototypes
  * (from ip_vs_sync.c)
  */
-int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid);
+int start_sync_thread(struct net *net, struct ipvs_sync_daemon_cfg *cfg,
+		      int state);
 int stop_sync_thread(struct net *net, int state);
 void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp, int pkts);
 
diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
index 3199243..68377d8 100644
--- a/include/uapi/linux/ip_vs.h
+++ b/include/uapi/linux/ip_vs.h
@@ -406,6 +406,7 @@ enum {
 	IPVS_DAEMON_ATTR_STATE,		/* sync daemon state (master/backup) */
 	IPVS_DAEMON_ATTR_MCAST_IFN,	/* multicast interface name */
 	IPVS_DAEMON_ATTR_SYNC_ID,	/* SyncID we belong to */
+	IPVS_DAEMON_ATTR_SYNC_MAXLEN,	/* UDP Payload Size */
 	__IPVS_DAEMON_ATTR_MAX,
 };
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 5fa121c..37b47aa 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2320,10 +2320,15 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		struct ip_vs_daemon_user *dm = (struct ip_vs_daemon_user *)arg;
 
 		if (cmd == IP_VS_SO_SET_STARTDAEMON) {
+			struct ipvs_sync_daemon_cfg cfg;
+
+			memset(&cfg, 0, sizeof(cfg));
+			strlcpy(cfg.mcast_ifn, dm->mcast_ifn,
+				sizeof(cfg.mcast_ifn));
+			cfg.syncid = dm->syncid;
 			rtnl_lock();
 			mutex_lock(&ipvs->sync_mutex);
-			ret = start_sync_thread(net, dm->state, dm->mcast_ifn,
-						dm->syncid);
+			ret = start_sync_thread(net, &cfg, dm->state);
 			mutex_unlock(&ipvs->sync_mutex);
 			rtnl_unlock();
 		} else {
@@ -2632,15 +2637,15 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 		mutex_lock(&ipvs->sync_mutex);
 		if (ipvs->sync_state & IP_VS_STATE_MASTER) {
 			d[0].state = IP_VS_STATE_MASTER;
-			strlcpy(d[0].mcast_ifn, ipvs->master_mcast_ifn,
+			strlcpy(d[0].mcast_ifn, ipvs->mcfg.mcast_ifn,
 				sizeof(d[0].mcast_ifn));
-			d[0].syncid = ipvs->master_syncid;
+			d[0].syncid = ipvs->mcfg.syncid;
 		}
 		if (ipvs->sync_state & IP_VS_STATE_BACKUP) {
 			d[1].state = IP_VS_STATE_BACKUP;
-			strlcpy(d[1].mcast_ifn, ipvs->backup_mcast_ifn,
+			strlcpy(d[1].mcast_ifn, ipvs->bcfg.mcast_ifn,
 				sizeof(d[1].mcast_ifn));
-			d[1].syncid = ipvs->backup_syncid;
+			d[1].syncid = ipvs->bcfg.syncid;
 		}
 		if (copy_to_user(user, &d, sizeof(d)) != 0)
 			ret = -EFAULT;
@@ -2795,6 +2800,7 @@ static const struct nla_policy ip_vs_daemon_policy[IPVS_DAEMON_ATTR_MAX + 1] = {
 	[IPVS_DAEMON_ATTR_MCAST_IFN]	= { .type = NLA_NUL_STRING,
 					    .len = IP_VS_IFNAME_MAXLEN },
 	[IPVS_DAEMON_ATTR_SYNC_ID]	= { .type = NLA_U32 },
+	[IPVS_DAEMON_ATTR_SYNC_MAXLEN]	= { .type = NLA_U16 },
 };
 
 /* Policy used for attributes in nested attribute IPVS_CMD_ATTR_SERVICE */
@@ -3251,7 +3257,7 @@ static int ip_vs_genl_parse_dest(struct ip_vs_dest_user_kern *udest,
 }
 
 static int ip_vs_genl_fill_daemon(struct sk_buff *skb, __u32 state,
-				  const char *mcast_ifn, __u32 syncid)
+				  struct ipvs_sync_daemon_cfg *c)
 {
 	struct nlattr *nl_daemon;
 
@@ -3260,8 +3266,9 @@ static int ip_vs_genl_fill_daemon(struct sk_buff *skb, __u32 state,
 		return -EMSGSIZE;
 
 	if (nla_put_u32(skb, IPVS_DAEMON_ATTR_STATE, state) ||
-	    nla_put_string(skb, IPVS_DAEMON_ATTR_MCAST_IFN, mcast_ifn) ||
-	    nla_put_u32(skb, IPVS_DAEMON_ATTR_SYNC_ID, syncid))
+	    nla_put_string(skb, IPVS_DAEMON_ATTR_MCAST_IFN, c->mcast_ifn) ||
+	    nla_put_u32(skb, IPVS_DAEMON_ATTR_SYNC_ID, c->syncid) ||
+	    nla_put_u16(skb, IPVS_DAEMON_ATTR_SYNC_MAXLEN, c->sync_maxlen))
 		goto nla_put_failure;
 	nla_nest_end(skb, nl_daemon);
 
@@ -3273,7 +3280,7 @@ nla_put_failure:
 }
 
 static int ip_vs_genl_dump_daemon(struct sk_buff *skb, __u32 state,
-				  const char *mcast_ifn, __u32 syncid,
+				  struct ipvs_sync_daemon_cfg *c,
 				  struct netlink_callback *cb)
 {
 	void *hdr;
@@ -3283,7 +3290,7 @@ static int ip_vs_genl_dump_daemon(struct sk_buff *skb, __u32 state,
 	if (!hdr)
 		return -EMSGSIZE;
 
-	if (ip_vs_genl_fill_daemon(skb, state, mcast_ifn, syncid))
+	if (ip_vs_genl_fill_daemon(skb, state, c))
 		goto nla_put_failure;
 
 	genlmsg_end(skb, hdr);
@@ -3303,8 +3310,7 @@ static int ip_vs_genl_dump_daemons(struct sk_buff *skb,
 	mutex_lock(&ipvs->sync_mutex);
 	if ((ipvs->sync_state & IP_VS_STATE_MASTER) && !cb->args[0]) {
 		if (ip_vs_genl_dump_daemon(skb, IP_VS_STATE_MASTER,
-					   ipvs->master_mcast_ifn,
-					   ipvs->master_syncid, cb) < 0)
+					   &ipvs->mcfg, cb) < 0)
 			goto nla_put_failure;
 
 		cb->args[0] = 1;
@@ -3312,8 +3318,7 @@ static int ip_vs_genl_dump_daemons(struct sk_buff *skb,
 
 	if ((ipvs->sync_state & IP_VS_STATE_BACKUP) && !cb->args[1]) {
 		if (ip_vs_genl_dump_daemon(skb, IP_VS_STATE_BACKUP,
-					   ipvs->backup_mcast_ifn,
-					   ipvs->backup_syncid, cb) < 0)
+					   &ipvs->bcfg, cb) < 0)
 			goto nla_put_failure;
 
 		cb->args[1] = 1;
@@ -3328,25 +3333,33 @@ nla_put_failure:
 static int ip_vs_genl_new_daemon(struct net *net, struct nlattr **attrs)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct ipvs_sync_daemon_cfg c;
+	struct nlattr *a;
 	int ret;
 
+	memset(&c, 0, sizeof(c));
 	if (!(attrs[IPVS_DAEMON_ATTR_STATE] &&
 	      attrs[IPVS_DAEMON_ATTR_MCAST_IFN] &&
 	      attrs[IPVS_DAEMON_ATTR_SYNC_ID]))
 		return -EINVAL;
+	strlcpy(c.mcast_ifn, nla_data(attrs[IPVS_DAEMON_ATTR_MCAST_IFN]),
+		sizeof(c.mcast_ifn));
+	c.syncid = nla_get_u32(attrs[IPVS_DAEMON_ATTR_SYNC_ID]);
+
+	a = attrs[IPVS_DAEMON_ATTR_SYNC_MAXLEN];
+	if (a)
+		c.sync_maxlen = nla_get_u16(a);
 
 	/* The synchronization protocol is incompatible with mixed family
 	 * services
 	 */
-	if (net_ipvs(net)->mixed_address_family_dests > 0)
+	if (ipvs->mixed_address_family_dests > 0)
 		return -EINVAL;
 
 	rtnl_lock();
 	mutex_lock(&ipvs->sync_mutex);
-	ret = start_sync_thread(net,
-				nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]),
-				nla_data(attrs[IPVS_DAEMON_ATTR_MCAST_IFN]),
-				nla_get_u32(attrs[IPVS_DAEMON_ATTR_SYNC_ID]));
+	ret = start_sync_thread(net, &c,
+				nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]));
 	mutex_unlock(&ipvs->sync_mutex);
 	rtnl_unlock();
 	return ret;
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index b2c7ee2..54ff340 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -320,26 +320,28 @@ sb_dequeue(struct netns_ipvs *ipvs, struct ipvs_master_sync_state *ms)
  * Create a new sync buffer for Version 1 proto.
  */
 static inline struct ip_vs_sync_buff *
-ip_vs_sync_buff_create(struct netns_ipvs *ipvs)
+ip_vs_sync_buff_create(struct netns_ipvs *ipvs, unsigned int len)
 {
 	struct ip_vs_sync_buff *sb;
 
 	if (!(sb=kmalloc(sizeof(struct ip_vs_sync_buff), GFP_ATOMIC)))
 		return NULL;
 
-	sb->mesg = kmalloc(ipvs->send_mesg_maxlen, GFP_ATOMIC);
+	len = max_t(unsigned int, len + sizeof(struct ip_vs_sync_mesg),
+		    ipvs->mcfg.sync_maxlen);
+	sb->mesg = kmalloc(len, GFP_ATOMIC);
 	if (!sb->mesg) {
 		kfree(sb);
 		return NULL;
 	}
 	sb->mesg->reserved = 0;  /* old nr_conns i.e. must be zero now */
 	sb->mesg->version = SYNC_PROTO_VER;
-	sb->mesg->syncid = ipvs->master_syncid;
+	sb->mesg->syncid = ipvs->mcfg.syncid;
 	sb->mesg->size = htons(sizeof(struct ip_vs_sync_mesg));
 	sb->mesg->nr_conns = 0;
 	sb->mesg->spare = 0;
 	sb->head = (unsigned char *)sb->mesg + sizeof(struct ip_vs_sync_mesg);
-	sb->end = (unsigned char *)sb->mesg + ipvs->send_mesg_maxlen;
+	sb->end = (unsigned char *)sb->mesg + len;
 
 	sb->firstuse = jiffies;
 	return sb;
@@ -402,7 +404,7 @@ select_master_thread_id(struct netns_ipvs *ipvs, struct ip_vs_conn *cp)
  * Create a new sync buffer for Version 0 proto.
  */
 static inline struct ip_vs_sync_buff *
-ip_vs_sync_buff_create_v0(struct netns_ipvs *ipvs)
+ip_vs_sync_buff_create_v0(struct netns_ipvs *ipvs, unsigned int len)
 {
 	struct ip_vs_sync_buff *sb;
 	struct ip_vs_sync_mesg_v0 *mesg;
@@ -410,17 +412,19 @@ ip_vs_sync_buff_create_v0(struct netns_ipvs *ipvs)
 	if (!(sb=kmalloc(sizeof(struct ip_vs_sync_buff), GFP_ATOMIC)))
 		return NULL;
 
-	sb->mesg = kmalloc(ipvs->send_mesg_maxlen, GFP_ATOMIC);
+	len = max_t(unsigned int, len + sizeof(struct ip_vs_sync_mesg_v0),
+		    ipvs->mcfg.sync_maxlen);
+	sb->mesg = kmalloc(len, GFP_ATOMIC);
 	if (!sb->mesg) {
 		kfree(sb);
 		return NULL;
 	}
 	mesg = (struct ip_vs_sync_mesg_v0 *)sb->mesg;
 	mesg->nr_conns = 0;
-	mesg->syncid = ipvs->master_syncid;
+	mesg->syncid = ipvs->mcfg.syncid;
 	mesg->size = htons(sizeof(struct ip_vs_sync_mesg_v0));
 	sb->head = (unsigned char *)mesg + sizeof(struct ip_vs_sync_mesg_v0);
-	sb->end = (unsigned char *)mesg + ipvs->send_mesg_maxlen;
+	sb->end = (unsigned char *)mesg + len;
 	sb->firstuse = jiffies;
 	return sb;
 }
@@ -533,7 +537,7 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
 	struct ip_vs_sync_buff *buff;
 	struct ipvs_master_sync_state *ms;
 	int id;
-	int len;
+	unsigned int len;
 
 	if (unlikely(cp->af != AF_INET))
 		return;
@@ -553,17 +557,19 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
 	id = select_master_thread_id(ipvs, cp);
 	ms = &ipvs->ms[id];
 	buff = ms->sync_buff;
+	len = (cp->flags & IP_VS_CONN_F_SEQ_MASK) ? FULL_CONN_SIZE :
+		SIMPLE_CONN_SIZE;
 	if (buff) {
 		m = (struct ip_vs_sync_mesg_v0 *) buff->mesg;
 		/* Send buffer if it is for v1 */
-		if (!m->nr_conns) {
+		if (buff->head + len > buff->end || !m->nr_conns) {
 			sb_queue_tail(ipvs, ms);
 			ms->sync_buff = NULL;
 			buff = NULL;
 		}
 	}
 	if (!buff) {
-		buff = ip_vs_sync_buff_create_v0(ipvs);
+		buff = ip_vs_sync_buff_create_v0(ipvs, len);
 		if (!buff) {
 			spin_unlock_bh(&ipvs->sync_buff_lock);
 			pr_err("ip_vs_sync_buff_create failed.\n");
@@ -572,8 +578,6 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
 		ms->sync_buff = buff;
 	}
 
-	len = (cp->flags & IP_VS_CONN_F_SEQ_MASK) ? FULL_CONN_SIZE :
-		SIMPLE_CONN_SIZE;
 	m = (struct ip_vs_sync_mesg_v0 *) buff->mesg;
 	s = (struct ip_vs_sync_conn_v0 *) buff->head;
 
@@ -597,12 +601,6 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
 	m->nr_conns++;
 	m->size = htons(ntohs(m->size) + len);
 	buff->head += len;
-
-	/* check if there is a space for next one */
-	if (buff->head + FULL_CONN_SIZE > buff->end) {
-		sb_queue_tail(ipvs, ms);
-		ms->sync_buff = NULL;
-	}
 	spin_unlock_bh(&ipvs->sync_buff_lock);
 
 	/* synchronize its controller if it has */
@@ -694,7 +692,7 @@ sloop:
 	}
 
 	if (!buff) {
-		buff = ip_vs_sync_buff_create(ipvs);
+		buff = ip_vs_sync_buff_create(ipvs, len);
 		if (!buff) {
 			spin_unlock_bh(&ipvs->sync_buff_lock);
 			pr_err("ip_vs_sync_buff_create failed.\n");
@@ -1219,7 +1217,7 @@ static void ip_vs_process_message(struct net *net, __u8 *buffer,
 		return;
 	}
 	/* SyncID sanity check */
-	if (ipvs->backup_syncid != 0 && m2->syncid != ipvs->backup_syncid) {
+	if (ipvs->bcfg.syncid != 0 && m2->syncid != ipvs->bcfg.syncid) {
 		IP_VS_DBG(7, "BACKUP, Ignoring syncid = %d\n", m2->syncid);
 		return;
 	}
@@ -1319,6 +1317,17 @@ static void set_mcast_ttl(struct sock *sk, u_char ttl)
 	release_sock(sk);
 }
 
+/* Control fragmentation of messages */
+static void set_mcast_pmtudisc(struct sock *sk, int val)
+{
+	struct inet_sock *inet = inet_sk(sk);
+
+	/* setsockopt(sock, SOL_IP, IP_MTU_DISCOVER, &val, sizeof(val)); */
+	lock_sock(sk);
+	inet->pmtudisc = val;
+	release_sock(sk);
+}
+
 /*
  *      Specifiy default interface for outgoing multicasts
  */
@@ -1345,43 +1354,6 @@ static int set_mcast_if(struct sock *sk, char *ifname)
 
 
 /*
- *	Set the maximum length of sync message according to the
- *	specified interface's MTU.
- */
-static int set_sync_mesg_maxlen(struct net *net, int sync_state)
-{
-	struct netns_ipvs *ipvs = net_ipvs(net);
-	struct net_device *dev;
-	int num;
-
-	if (sync_state == IP_VS_STATE_MASTER) {
-		dev = __dev_get_by_name(net, ipvs->master_mcast_ifn);
-		if (!dev)
-			return -ENODEV;
-
-		num = (dev->mtu - sizeof(struct iphdr) -
-		       sizeof(struct udphdr) -
-		       SYNC_MESG_HEADER_LEN - 20) / SIMPLE_CONN_SIZE;
-		ipvs->send_mesg_maxlen = SYNC_MESG_HEADER_LEN +
-			SIMPLE_CONN_SIZE * min(num, MAX_CONNS_PER_SYNCBUFF);
-		IP_VS_DBG(7, "setting the maximum length of sync sending "
-			  "message %d.\n", ipvs->send_mesg_maxlen);
-	} else if (sync_state == IP_VS_STATE_BACKUP) {
-		dev = __dev_get_by_name(net, ipvs->backup_mcast_ifn);
-		if (!dev)
-			return -ENODEV;
-
-		ipvs->recv_mesg_maxlen = dev->mtu -
-			sizeof(struct iphdr) - sizeof(struct udphdr);
-		IP_VS_DBG(7, "setting the maximum length of sync receiving "
-			  "message %d.\n", ipvs->recv_mesg_maxlen);
-	}
-
-	return 0;
-}
-
-
-/*
  *      Join a multicast group.
  *      the group is specified by a class D multicast address 224.0.0.0/8
  *      in the in_addr structure passed in as a parameter.
@@ -1461,7 +1433,7 @@ static struct socket *make_send_sock(struct net *net, int id)
 		pr_err("Error during creation of socket; terminating\n");
 		return ERR_PTR(result);
 	}
-	result = set_mcast_if(sock->sk, ipvs->master_mcast_ifn);
+	result = set_mcast_if(sock->sk, ipvs->mcfg.mcast_ifn);
 	if (result < 0) {
 		pr_err("Error setting outbound mcast interface\n");
 		goto error;
@@ -1469,11 +1441,13 @@ static struct socket *make_send_sock(struct net *net, int id)
 
 	set_mcast_loop(sock->sk, 0);
 	set_mcast_ttl(sock->sk, 1);
+	/* Allow fragmentation if MTU changes */
+	set_mcast_pmtudisc(sock->sk, IP_PMTUDISC_DONT);
 	result = sysctl_sync_sock_size(ipvs);
 	if (result > 0)
 		set_sock_size(sock->sk, 1, result);
 
-	result = bind_mcastif_addr(sock, ipvs->master_mcast_ifn);
+	result = bind_mcastif_addr(sock, ipvs->mcfg.mcast_ifn);
 	if (result < 0) {
 		pr_err("Error binding address of the mcast interface\n");
 		goto error;
@@ -1531,7 +1505,7 @@ static struct socket *make_receive_sock(struct net *net, int id)
 	/* join the multicast group */
 	result = join_mcast_group(sock->sk,
 			(struct in_addr *) &mcast_addr.sin_addr,
-			ipvs->backup_mcast_ifn);
+			ipvs->bcfg.mcast_ifn);
 	if (result < 0) {
 		pr_err("Error joining to the multicast group\n");
 		goto error;
@@ -1639,7 +1613,7 @@ static int sync_thread_master(void *data)
 
 	pr_info("sync thread started: state = MASTER, mcast_ifn = %s, "
 		"syncid = %d, id = %d\n",
-		ipvs->master_mcast_ifn, ipvs->master_syncid, tinfo->id);
+		ipvs->mcfg.mcast_ifn, ipvs->mcfg.syncid, tinfo->id);
 
 	for (;;) {
 		sb = next_sync_buff(ipvs, ms);
@@ -1693,7 +1667,7 @@ static int sync_thread_backup(void *data)
 
 	pr_info("sync thread started: state = BACKUP, mcast_ifn = %s, "
 		"syncid = %d, id = %d\n",
-		ipvs->backup_mcast_ifn, ipvs->backup_syncid, tinfo->id);
+		ipvs->bcfg.mcast_ifn, ipvs->bcfg.syncid, tinfo->id);
 
 	while (!kthread_should_stop()) {
 		wait_event_interruptible(*sk_sleep(tinfo->sock->sk),
@@ -1703,7 +1677,7 @@ static int sync_thread_backup(void *data)
 		/* do we have data now? */
 		while (!skb_queue_empty(&(tinfo->sock->sk->sk_receive_queue))) {
 			len = ip_vs_receive(tinfo->sock, tinfo->buf,
-					ipvs->recv_mesg_maxlen);
+					ipvs->bcfg.sync_maxlen);
 			if (len <= 0) {
 				if (len != -EAGAIN)
 					pr_err("receiving message error\n");
@@ -1723,16 +1697,19 @@ static int sync_thread_backup(void *data)
 }
 
 
-int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid)
+int start_sync_thread(struct net *net, struct ipvs_sync_daemon_cfg *c,
+		      int state)
 {
 	struct ip_vs_sync_thread_data *tinfo;
 	struct task_struct **array = NULL, *task;
 	struct socket *sock;
 	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct net_device *dev;
 	char *name;
 	int (*threadfn)(void *data);
-	int id, count;
+	int id, count, hlen;
 	int result = -ENOMEM;
+	u16 mtu, min_mtu;
 
 	IP_VS_DBG(7, "%s(): pid %d\n", __func__, task_pid_nr(current));
 	IP_VS_DBG(7, "Each ip_vs_sync_conn entry needs %Zd bytes\n",
@@ -1744,22 +1721,35 @@ int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid)
 	} else
 		count = ipvs->threads_mask + 1;
 
+	dev = __dev_get_by_name(net, c->mcast_ifn);
+	if (!dev) {
+		pr_err("Unknown mcast interface: %s\n", c->mcast_ifn);
+		return -ENODEV;
+	}
+	hlen = sizeof(struct iphdr) + sizeof(struct udphdr);
+	mtu = (state == IP_VS_STATE_BACKUP) ?
+		  clamp(dev->mtu, 1500U, 65535U) : 1500U;
+	min_mtu = (state == IP_VS_STATE_BACKUP) ? 1024 : 1;
+
+	if (c->sync_maxlen)
+		c->sync_maxlen = clamp_t(unsigned int,
+					 c->sync_maxlen, min_mtu,
+					 65535 - hlen);
+	else
+		c->sync_maxlen = mtu - hlen;
+
 	if (state == IP_VS_STATE_MASTER) {
 		if (ipvs->ms)
 			return -EEXIST;
 
-		strlcpy(ipvs->master_mcast_ifn, mcast_ifn,
-			sizeof(ipvs->master_mcast_ifn));
-		ipvs->master_syncid = syncid;
+		ipvs->mcfg = *c;
 		name = "ipvs-m:%d:%d";
 		threadfn = sync_thread_master;
 	} else if (state == IP_VS_STATE_BACKUP) {
 		if (ipvs->backup_threads)
 			return -EEXIST;
 
-		strlcpy(ipvs->backup_mcast_ifn, mcast_ifn,
-			sizeof(ipvs->backup_mcast_ifn));
-		ipvs->backup_syncid = syncid;
+		ipvs->bcfg = *c;
 		name = "ipvs-b:%d:%d";
 		threadfn = sync_thread_backup;
 	} else {
@@ -1787,7 +1777,6 @@ int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid)
 		if (!array)
 			goto out;
 	}
-	set_sync_mesg_maxlen(net, state);
 
 	tinfo = NULL;
 	for (id = 0; id < count; id++) {
@@ -1805,7 +1794,7 @@ int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid)
 		tinfo->net = net;
 		tinfo->sock = sock;
 		if (state == IP_VS_STATE_BACKUP) {
-			tinfo->buf = kmalloc(ipvs->recv_mesg_maxlen,
+			tinfo->buf = kmalloc(ipvs->bcfg.sync_maxlen,
 					     GFP_KERNEL);
 			if (!tinfo->buf)
 				goto outtinfo;
-- 
1.9.3

