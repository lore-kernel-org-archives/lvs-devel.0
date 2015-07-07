From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net RFC] ipvs: add more mcast parameters for the sync daemon
Date: Tue,  7 Jul 2015 22:14:12 +0300
Message-ID: <1436296452-5632-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Phillip Moore <pdm@pobox.com>, lvs-users@linuxvirtualserver.org

Add new sync parameters for sync daemon, used on start:

- sync_maxlen: for setups with large MTU to send
large sync packets and to avoid problems with MTU
changes. The default value is now based on MTU but
no more than 1500 for compatibility reasons.

- mcast_group: configure the multicast address, now IPv6
is supported too

- mcast_port: configure the multicast port

- mcast_ttl: configure the multicast TTL/HOP_LIMIT

Now the sync messages do not use DF flag to allow
fragmentation on MTU changes.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |  23 ++-
 include/uapi/linux/ip_vs.h      |   5 +
 net/netfilter/ipvs/ip_vs_ctl.c  | 104 ++++++++++---
 net/netfilter/ipvs/ip_vs_sync.c | 316 +++++++++++++++++++++++++++-------------
 4 files changed, 316 insertions(+), 132 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 4e3731e..9b9ca87 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -846,6 +846,17 @@ struct ipvs_master_sync_state {
 /* How much time to keep dests in trash */
 #define IP_VS_DEST_TRASH_PERIOD		(120 * HZ)
 
+struct ipvs_sync_daemon_cfg {
+	union nf_inet_addr	mcast_group;
+	int			syncid;
+	u16			sync_maxlen;
+	u16			mcast_port;
+	u8			mcast_af;
+	u8			mcast_ttl;
+	/* multicast interface name */
+	char			mcast_ifn[IP_VS_IFNAME_MAXLEN];
+};
+
 /* IPVS in network namespace */
 struct netns_ipvs {
 	int			gen;		/* Generation */
@@ -961,15 +972,10 @@ struct netns_ipvs {
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
@@ -1408,7 +1414,8 @@ static inline void ip_vs_dest_put_and_free(struct ip_vs_dest *dest)
 /* IPVS sync daemon data and function prototypes
  * (from ip_vs_sync.c)
  */
-int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid);
+int start_sync_thread(struct net *net, struct ipvs_sync_daemon_cfg *cfg,
+		      int state);
 int stop_sync_thread(struct net *net, int state);
 void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp, int pkts);
 
diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
index 3199243..391395c 100644
--- a/include/uapi/linux/ip_vs.h
+++ b/include/uapi/linux/ip_vs.h
@@ -406,6 +406,11 @@ enum {
 	IPVS_DAEMON_ATTR_STATE,		/* sync daemon state (master/backup) */
 	IPVS_DAEMON_ATTR_MCAST_IFN,	/* multicast interface name */
 	IPVS_DAEMON_ATTR_SYNC_ID,	/* SyncID we belong to */
+	IPVS_DAEMON_ATTR_SYNC_MAXLEN,	/* UDP Payload Size */
+	IPVS_DAEMON_ATTR_MCAST_GROUP,	/* IPv4 Multicast Address */
+	IPVS_DAEMON_ATTR_MCAST_GROUP6,	/* IPv6 Multicast Address */
+	IPVS_DAEMON_ATTR_MCAST_PORT,	/* Multicast Port (base) */
+	IPVS_DAEMON_ATTR_MCAST_TTL,	/* Multicast TTL */
 	__IPVS_DAEMON_ATTR_MAX,
 };
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 285eae3..ede2be0 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2320,11 +2320,17 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		struct ip_vs_daemon_user *dm = (struct ip_vs_daemon_user *)arg;
 
 		mutex_lock(&ipvs->sync_mutex);
-		if (cmd == IP_VS_SO_SET_STARTDAEMON)
-			ret = start_sync_thread(net, dm->state, dm->mcast_ifn,
-						dm->syncid);
-		else
+		if (cmd == IP_VS_SO_SET_STARTDAEMON) {
+			struct ipvs_sync_daemon_cfg cfg;
+
+			memset(&cfg, 0, sizeof(cfg));
+			strlcpy(cfg.mcast_ifn, dm->mcast_ifn,
+				sizeof(cfg.mcast_ifn));
+			cfg.syncid = dm->syncid;
+			ret = start_sync_thread(net, &cfg, dm->state);
+		} else {
 			ret = stop_sync_thread(net, dm->state);
+		}
 		mutex_unlock(&ipvs->sync_mutex);
 		goto out_dec;
 	}
@@ -2627,15 +2633,15 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
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
@@ -2790,6 +2796,11 @@ static const struct nla_policy ip_vs_daemon_policy[IPVS_DAEMON_ATTR_MAX + 1] = {
 	[IPVS_DAEMON_ATTR_MCAST_IFN]	= { .type = NLA_NUL_STRING,
 					    .len = IP_VS_IFNAME_MAXLEN },
 	[IPVS_DAEMON_ATTR_SYNC_ID]	= { .type = NLA_U32 },
+	[IPVS_DAEMON_ATTR_SYNC_MAXLEN]	= { .type = NLA_U16 },
+	[IPVS_DAEMON_ATTR_MCAST_GROUP]	= { .type = NLA_U32 },
+	[IPVS_DAEMON_ATTR_MCAST_GROUP6]	= { .len = sizeof(struct in6_addr) },
+	[IPVS_DAEMON_ATTR_MCAST_PORT]	= { .type = NLA_U16 },
+	[IPVS_DAEMON_ATTR_MCAST_TTL]	= { .type = NLA_U8 },
 };
 
 /* Policy used for attributes in nested attribute IPVS_CMD_ATTR_SERVICE */
@@ -3246,7 +3257,7 @@ static int ip_vs_genl_parse_dest(struct ip_vs_dest_user_kern *udest,
 }
 
 static int ip_vs_genl_fill_daemon(struct sk_buff *skb, __u32 state,
-				  const char *mcast_ifn, __u32 syncid)
+				  struct ipvs_sync_daemon_cfg *c)
 {
 	struct nlattr *nl_daemon;
 
@@ -3255,9 +3266,22 @@ static int ip_vs_genl_fill_daemon(struct sk_buff *skb, __u32 state,
 		return -EMSGSIZE;
 
 	if (nla_put_u32(skb, IPVS_DAEMON_ATTR_STATE, state) ||
-	    nla_put_string(skb, IPVS_DAEMON_ATTR_MCAST_IFN, mcast_ifn) ||
-	    nla_put_u32(skb, IPVS_DAEMON_ATTR_SYNC_ID, syncid))
+	    nla_put_string(skb, IPVS_DAEMON_ATTR_MCAST_IFN, c->mcast_ifn) ||
+	    nla_put_u32(skb, IPVS_DAEMON_ATTR_SYNC_ID, c->syncid) ||
+	    nla_put_u16(skb, IPVS_DAEMON_ATTR_SYNC_MAXLEN, c->sync_maxlen) ||
+	    nla_put_u16(skb, IPVS_DAEMON_ATTR_MCAST_PORT, c->mcast_port) ||
+	    nla_put_u8(skb, IPVS_DAEMON_ATTR_MCAST_TTL, c->mcast_ttl))
 		goto nla_put_failure;
+#ifdef CONFIG_IP_VS_IPV6
+	if (c->mcast_af == AF_INET6) {
+		if (nla_put_in6_addr(skb, IPVS_DAEMON_ATTR_MCAST_GROUP6,
+				     &c->mcast_group.in6))
+			goto nla_put_failure;
+	} else
+#endif
+		if (nla_put_in_addr(skb, IPVS_DAEMON_ATTR_MCAST_GROUP,
+				    c->mcast_group.ip))
+			goto nla_put_failure;
 	nla_nest_end(skb, nl_daemon);
 
 	return 0;
@@ -3268,7 +3292,7 @@ nla_put_failure:
 }
 
 static int ip_vs_genl_dump_daemon(struct sk_buff *skb, __u32 state,
-				  const char *mcast_ifn, __u32 syncid,
+				  struct ipvs_sync_daemon_cfg *c,
 				  struct netlink_callback *cb)
 {
 	void *hdr;
@@ -3278,7 +3302,7 @@ static int ip_vs_genl_dump_daemon(struct sk_buff *skb, __u32 state,
 	if (!hdr)
 		return -EMSGSIZE;
 
-	if (ip_vs_genl_fill_daemon(skb, state, mcast_ifn, syncid))
+	if (ip_vs_genl_fill_daemon(skb, state, c))
 		goto nla_put_failure;
 
 	genlmsg_end(skb, hdr);
@@ -3298,8 +3322,7 @@ static int ip_vs_genl_dump_daemons(struct sk_buff *skb,
 	mutex_lock(&ipvs->sync_mutex);
 	if ((ipvs->sync_state & IP_VS_STATE_MASTER) && !cb->args[0]) {
 		if (ip_vs_genl_dump_daemon(skb, IP_VS_STATE_MASTER,
-					   ipvs->master_mcast_ifn,
-					   ipvs->master_syncid, cb) < 0)
+					   &ipvs->mcfg, cb) < 0)
 			goto nla_put_failure;
 
 		cb->args[0] = 1;
@@ -3307,8 +3330,7 @@ static int ip_vs_genl_dump_daemons(struct sk_buff *skb,
 
 	if ((ipvs->sync_state & IP_VS_STATE_BACKUP) && !cb->args[1]) {
 		if (ip_vs_genl_dump_daemon(skb, IP_VS_STATE_BACKUP,
-					   ipvs->backup_mcast_ifn,
-					   ipvs->backup_syncid, cb) < 0)
+					   &ipvs->bcfg, cb) < 0)
 			goto nla_put_failure;
 
 		cb->args[1] = 1;
@@ -3322,10 +3344,52 @@ nla_put_failure:
 
 static int ip_vs_genl_new_daemon(struct net *net, struct nlattr **attrs)
 {
+	struct ipvs_sync_daemon_cfg c;
+	struct nlattr *a;
+
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
+
+	a = attrs[IPVS_DAEMON_ATTR_MCAST_GROUP];
+	if (a) {
+		c.mcast_af = AF_INET;
+		c.mcast_group.ip = nla_get_in_addr(a);
+		if (!ipv4_is_multicast(c.mcast_group.ip))
+			return -EINVAL;
+	} else {
+		a = attrs[IPVS_DAEMON_ATTR_MCAST_GROUP6];
+		if (a) {
+#ifdef CONFIG_IP_VS_IPV6
+			int addr_type;
+
+			c.mcast_af = AF_INET6;
+			c.mcast_group.in6 = nla_get_in6_addr(a);
+			addr_type = ipv6_addr_type(&c.mcast_group.in6);
+			if (!(addr_type & IPV6_ADDR_MULTICAST))
+				return -EINVAL;
+#else
+			return -EAFNOSUPPORT;
+#endif
+		}
+	}
+
+	a = attrs[IPVS_DAEMON_ATTR_MCAST_PORT];
+	if (a)
+		c.mcast_port = nla_get_u16(a);
+
+	a = attrs[IPVS_DAEMON_ATTR_MCAST_TTL];
+	if (a)
+		c.mcast_ttl = nla_get_u8(a);
 
 	/* The synchronization protocol is incompatible with mixed family
 	 * services
@@ -3333,10 +3397,8 @@ static int ip_vs_genl_new_daemon(struct net *net, struct nlattr **attrs)
 	if (net_ipvs(net)->mixed_address_family_dests > 0)
 		return -EINVAL;
 
-	return start_sync_thread(net,
-				 nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]),
-				 nla_data(attrs[IPVS_DAEMON_ATTR_MCAST_IFN]),
-				 nla_get_u32(attrs[IPVS_DAEMON_ATTR_SYNC_ID]));
+	return start_sync_thread(net, &c,
+				 nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]));
 }
 
 static int ip_vs_genl_del_daemon(struct net *net, struct nlattr **attrs)
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 19b9cce..12cf2e8 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -262,6 +262,11 @@ struct ip_vs_sync_mesg {
 	/* ip_vs_sync_conn entries start here */
 };
 
+union ipvs_sockaddr {
+	struct sockaddr_in	in;
+	struct sockaddr_in6	in6;
+};
+
 struct ip_vs_sync_buff {
 	struct list_head        list;
 	unsigned long           firstuse;
@@ -320,26 +325,28 @@ sb_dequeue(struct netns_ipvs *ipvs, struct ipvs_master_sync_state *ms)
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
@@ -402,7 +409,7 @@ select_master_thread_id(struct netns_ipvs *ipvs, struct ip_vs_conn *cp)
  * Create a new sync buffer for Version 0 proto.
  */
 static inline struct ip_vs_sync_buff *
-ip_vs_sync_buff_create_v0(struct netns_ipvs *ipvs)
+ip_vs_sync_buff_create_v0(struct netns_ipvs *ipvs, unsigned int len)
 {
 	struct ip_vs_sync_buff *sb;
 	struct ip_vs_sync_mesg_v0 *mesg;
@@ -410,17 +417,19 @@ ip_vs_sync_buff_create_v0(struct netns_ipvs *ipvs)
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
@@ -533,7 +542,7 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
 	struct ip_vs_sync_buff *buff;
 	struct ipvs_master_sync_state *ms;
 	int id;
-	int len;
+	unsigned int len;
 
 	if (unlikely(cp->af != AF_INET))
 		return;
@@ -553,17 +562,19 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
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
@@ -572,8 +583,6 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
 		ms->sync_buff = buff;
 	}
 
-	len = (cp->flags & IP_VS_CONN_F_SEQ_MASK) ? FULL_CONN_SIZE :
-		SIMPLE_CONN_SIZE;
 	m = (struct ip_vs_sync_mesg_v0 *) buff->mesg;
 	s = (struct ip_vs_sync_conn_v0 *) buff->head;
 
@@ -597,12 +606,6 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
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
@@ -694,7 +697,7 @@ sloop:
 	}
 
 	if (!buff) {
-		buff = ip_vs_sync_buff_create(ipvs);
+		buff = ip_vs_sync_buff_create(ipvs, len);
 		if (!buff) {
 			spin_unlock_bh(&ipvs->sync_buff_lock);
 			pr_err("ip_vs_sync_buff_create failed.\n");
@@ -1219,7 +1222,7 @@ static void ip_vs_process_message(struct net *net, __u8 *buffer,
 		return;
 	}
 	/* SyncID sanity check */
-	if (ipvs->backup_syncid != 0 && m2->syncid != ipvs->backup_syncid) {
+	if (ipvs->bcfg.syncid != 0 && m2->syncid != ipvs->bcfg.syncid) {
 		IP_VS_DBG(7, "BACKUP, Ignoring syncid = %d\n", m2->syncid);
 		return;
 	}
@@ -1303,6 +1306,14 @@ static void set_mcast_loop(struct sock *sk, u_char loop)
 	/* setsockopt(sock, SOL_IP, IP_MULTICAST_LOOP, &loop, sizeof(loop)); */
 	lock_sock(sk);
 	inet->mc_loop = loop ? 1 : 0;
+#ifdef CONFIG_IP_VS_IPV6
+	if (sk->sk_family == AF_INET6) {
+		struct ipv6_pinfo *np = inet6_sk(sk);
+
+		/* IPV6_MULTICAST_LOOP */
+		np->mc_loop = loop ? 1 : 0;
+	}
+#endif
 	release_sock(sk);
 }
 
@@ -1316,6 +1327,33 @@ static void set_mcast_ttl(struct sock *sk, u_char ttl)
 	/* setsockopt(sock, SOL_IP, IP_MULTICAST_TTL, &ttl, sizeof(ttl)); */
 	lock_sock(sk);
 	inet->mc_ttl = ttl;
+#ifdef CONFIG_IP_VS_IPV6
+	if (sk->sk_family == AF_INET6) {
+		struct ipv6_pinfo *np = inet6_sk(sk);
+
+		/* IPV6_MULTICAST_HOPS */
+		np->mcast_hops = ttl;
+	}
+#endif
+	release_sock(sk);
+}
+
+/* Control fragmentation of messages */
+static void set_mcast_pmtudisc(struct sock *sk, int val)
+{
+	struct inet_sock *inet = inet_sk(sk);
+
+	/* setsockopt(sock, SOL_IP, IP_MTU_DISCOVER, &val, sizeof(val)); */
+	lock_sock(sk);
+	inet->pmtudisc = val;
+#ifdef CONFIG_IP_VS_IPV6
+	if (sk->sk_family == AF_INET6) {
+		struct ipv6_pinfo *np = inet6_sk(sk);
+
+		/* IPV6_MTU_DISCOVER */
+		np->pmtudisc = val;
+	}
+#endif
 	release_sock(sk);
 }
 
@@ -1327,57 +1365,35 @@ static int set_mcast_if(struct sock *sk, char *ifname)
 	struct net_device *dev;
 	struct inet_sock *inet = inet_sk(sk);
 	struct net *net = sock_net(sk);
+	int ret;
 
-	dev = __dev_get_by_name(net, ifname);
+	dev = dev_get_by_name(net, ifname);
+	ret = -ENODEV;
 	if (!dev)
-		return -ENODEV;
+		goto out;
 
+	ret = -EINVAL;
 	if (sk->sk_bound_dev_if && dev->ifindex != sk->sk_bound_dev_if)
-		return -EINVAL;
+		goto out;
 
 	lock_sock(sk);
 	inet->mc_index = dev->ifindex;
 	/*  inet->mc_addr  = 0; */
-	release_sock(sk);
-
-	return 0;
-}
-
+#ifdef CONFIG_IP_VS_IPV6
+	if (sk->sk_family == AF_INET6) {
+		struct ipv6_pinfo *np = inet6_sk(sk);
 
-/*
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
+		/* IPV6_MULTICAST_IF */
+		np->mcast_oif = dev->ifindex;
 	}
+#endif
+	release_sock(sk);
+	ret = 0;
 
-	return 0;
+out:
+	if (dev)
+		dev_put(dev);
+	return ret;
 }
 
 
@@ -1397,36 +1413,74 @@ join_mcast_group(struct sock *sk, struct in_addr *addr, char *ifname)
 	memset(&mreq, 0, sizeof(mreq));
 	memcpy(&mreq.imr_multiaddr, addr, sizeof(struct in_addr));
 
+	/* Order is rtnl -> __ip_vs_mutex */
+	if (!rtnl_trylock())
+		return restart_syscall();
 	dev = __dev_get_by_name(net, ifname);
+	ret = -ENODEV;
 	if (!dev)
-		return -ENODEV;
+		goto unlock;
+	ret = -EINVAL;
 	if (sk->sk_bound_dev_if && dev->ifindex != sk->sk_bound_dev_if)
-		return -EINVAL;
+		goto unlock;
 
 	mreq.imr_ifindex = dev->ifindex;
 
-	rtnl_lock();
 	lock_sock(sk);
 	ret = ip_mc_join_group(sk, &mreq);
 	release_sock(sk);
+
+unlock:
 	rtnl_unlock();
 
 	return ret;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static int
+join_mcast_group6(struct sock *sk, struct in6_addr *addr, char *ifname)
+{
+	struct net *net = sock_net(sk);
+	struct net_device *dev;
+	int ret;
+
+	/* Order is rtnl -> __ip_vs_mutex */
+	if (!rtnl_trylock())
+		return restart_syscall();
+	dev = __dev_get_by_name(net, ifname);
+	ret = -ENODEV;
+	if (!dev)
+		goto unlock;
+	ret = -EINVAL;
+	if (sk->sk_bound_dev_if && dev->ifindex != sk->sk_bound_dev_if)
+		goto unlock;
+
+	lock_sock(sk);
+	ret = ipv6_sock_mc_join(sk, dev->ifindex, addr);
+	release_sock(sk);
+
+unlock:
+	rtnl_unlock();
+
+	return ret;
+}
+#endif
 
 static int bind_mcastif_addr(struct socket *sock, char *ifname)
 {
 	struct net *net = sock_net(sock->sk);
 	struct net_device *dev;
-	__be32 addr;
+	__be32 addr = 0;
 	struct sockaddr_in sin;
 
-	dev = __dev_get_by_name(net, ifname);
+	rcu_read_lock();
+	dev = dev_get_by_name_rcu(net, ifname);
+	if (dev)
+		addr = inet_select_addr(dev, 0, RT_SCOPE_UNIVERSE);
+	rcu_read_unlock();
 	if (!dev)
 		return -ENODEV;
 
-	addr = inet_select_addr(dev, 0, RT_SCOPE_UNIVERSE);
 	if (!addr)
 		pr_err("You probably need to specify IP address on "
 		       "multicast interface.\n");
@@ -1442,6 +1496,26 @@ static int bind_mcastif_addr(struct socket *sock, char *ifname)
 	return sock->ops->bind(sock, (struct sockaddr*)&sin, sizeof(sin));
 }
 
+static void get_mcast_sockaddr(union ipvs_sockaddr *sa, int *salen,
+			       struct ipvs_sync_daemon_cfg *c, int id)
+{
+	if (AF_INET6 == c->mcast_af) {
+		sa->in6 = (struct sockaddr_in6) {
+			.sin6_family = AF_INET6,
+			.sin6_port = htons(c->mcast_port + id),
+		};
+		sa->in6.sin6_addr = c->mcast_group.in6;
+		*salen = sizeof(sa->in6);
+	} else {
+		sa->in = (struct sockaddr_in) {
+			.sin_family = AF_INET,
+			.sin_port = htons(c->mcast_port + id),
+		};
+		sa->in.sin_addr = c->mcast_group.in;
+		*salen = sizeof(sa->in);
+	}
+}
+
 /*
  *      Set up sending multicast socket over UDP
  */
@@ -1449,16 +1523,13 @@ static struct socket *make_send_sock(struct net *net, int id)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	/* multicast addr */
-	struct sockaddr_in mcast_addr = {
-		.sin_family		= AF_INET,
-		.sin_port		= cpu_to_be16(IP_VS_SYNC_PORT + id),
-		.sin_addr.s_addr	= cpu_to_be32(IP_VS_SYNC_GROUP),
-	};
+	union ipvs_sockaddr mcast_addr;
 	struct socket *sock;
-	int result;
+	int result, salen;
 
 	/* First create a socket move it to right name space later */
-	result = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	result = sock_create_kern(ipvs->mcfg.mcast_af, SOCK_DGRAM, IPPROTO_UDP,
+				  &sock);
 	if (result < 0) {
 		pr_err("Error during creation of socket; terminating\n");
 		return ERR_PTR(result);
@@ -1469,26 +1540,32 @@ static struct socket *make_send_sock(struct net *net, int id)
 	 * After sk_change_net should be released using sk_release_kernel.
 	 */
 	sk_change_net(sock->sk, net);
-	result = set_mcast_if(sock->sk, ipvs->master_mcast_ifn);
+	result = set_mcast_if(sock->sk, ipvs->mcfg.mcast_ifn);
 	if (result < 0) {
 		pr_err("Error setting outbound mcast interface\n");
 		goto error;
 	}
 
 	set_mcast_loop(sock->sk, 0);
-	set_mcast_ttl(sock->sk, 1);
+	set_mcast_ttl(sock->sk, ipvs->mcfg.mcast_ttl);
+	/* Allow fragmentation if MTU changes */
+	set_mcast_pmtudisc(sock->sk, IP_PMTUDISC_DONT);
 	result = sysctl_sync_sock_size(ipvs);
 	if (result > 0)
 		set_sock_size(sock->sk, 1, result);
 
-	result = bind_mcastif_addr(sock, ipvs->master_mcast_ifn);
+	if (AF_INET == ipvs->mcfg.mcast_af)
+		result = bind_mcastif_addr(sock, ipvs->mcfg.mcast_ifn);
+	else
+		result = 0;
 	if (result < 0) {
 		pr_err("Error binding address of the mcast interface\n");
 		goto error;
 	}
 
+	get_mcast_sockaddr(&mcast_addr, &salen, &ipvs->mcfg, id);
 	result = sock->ops->connect(sock, (struct sockaddr *) &mcast_addr,
-			sizeof(struct sockaddr), 0);
+				    salen, 0);
 	if (result < 0) {
 		pr_err("Error connecting to the multicast addr\n");
 		goto error;
@@ -1509,16 +1586,13 @@ static struct socket *make_receive_sock(struct net *net, int id)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	/* multicast addr */
-	struct sockaddr_in mcast_addr = {
-		.sin_family		= AF_INET,
-		.sin_port		= cpu_to_be16(IP_VS_SYNC_PORT + id),
-		.sin_addr.s_addr	= cpu_to_be32(IP_VS_SYNC_GROUP),
-	};
+	union ipvs_sockaddr mcast_addr;
 	struct socket *sock;
-	int result;
+	int result, salen;
 
 	/* First create a socket */
-	result = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	result = sock_create_kern(ipvs->bcfg.mcast_af, SOCK_DGRAM, IPPROTO_UDP,
+				  &sock);
 	if (result < 0) {
 		pr_err("Error during creation of socket; terminating\n");
 		return ERR_PTR(result);
@@ -1535,17 +1609,22 @@ static struct socket *make_receive_sock(struct net *net, int id)
 	if (result > 0)
 		set_sock_size(sock->sk, 0, result);
 
-	result = sock->ops->bind(sock, (struct sockaddr *) &mcast_addr,
-			sizeof(struct sockaddr));
+	get_mcast_sockaddr(&mcast_addr, &salen, &ipvs->bcfg, id);
+	result = sock->ops->bind(sock, (struct sockaddr *)&mcast_addr, salen);
 	if (result < 0) {
 		pr_err("Error binding to the multicast addr\n");
 		goto error;
 	}
 
 	/* join the multicast group */
-	result = join_mcast_group(sock->sk,
-			(struct in_addr *) &mcast_addr.sin_addr,
-			ipvs->backup_mcast_ifn);
+#ifdef CONFIG_IP_VS_IPV6
+	if (ipvs->bcfg.mcast_af == AF_INET6)
+		result = join_mcast_group6(sock->sk, &mcast_addr.in6.sin6_addr,
+					   ipvs->bcfg.mcast_ifn);
+	else
+#endif
+		result = join_mcast_group(sock->sk, &mcast_addr.in.sin_addr,
+					  ipvs->bcfg.mcast_ifn);
 	if (result < 0) {
 		pr_err("Error joining to the multicast group\n");
 		goto error;
@@ -1653,7 +1732,7 @@ static int sync_thread_master(void *data)
 
 	pr_info("sync thread started: state = MASTER, mcast_ifn = %s, "
 		"syncid = %d, id = %d\n",
-		ipvs->master_mcast_ifn, ipvs->master_syncid, tinfo->id);
+		ipvs->mcfg.mcast_ifn, ipvs->mcfg.syncid, tinfo->id);
 
 	for (;;) {
 		sb = next_sync_buff(ipvs, ms);
@@ -1707,7 +1786,7 @@ static int sync_thread_backup(void *data)
 
 	pr_info("sync thread started: state = BACKUP, mcast_ifn = %s, "
 		"syncid = %d, id = %d\n",
-		ipvs->backup_mcast_ifn, ipvs->backup_syncid, tinfo->id);
+		ipvs->bcfg.mcast_ifn, ipvs->bcfg.syncid, tinfo->id);
 
 	while (!kthread_should_stop()) {
 		wait_event_interruptible(*sk_sleep(tinfo->sock->sk),
@@ -1717,7 +1796,7 @@ static int sync_thread_backup(void *data)
 		/* do we have data now? */
 		while (!skb_queue_empty(&(tinfo->sock->sk->sk_receive_queue))) {
 			len = ip_vs_receive(tinfo->sock, tinfo->buf,
-					ipvs->recv_mesg_maxlen);
+					ipvs->bcfg.sync_maxlen);
 			if (len <= 0) {
 				if (len != -EAGAIN)
 					pr_err("receiving message error\n");
@@ -1737,7 +1816,8 @@ static int sync_thread_backup(void *data)
 }
 
 
-int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid)
+int start_sync_thread(struct net *net, struct ipvs_sync_daemon_cfg *c,
+		      int state)
 {
 	struct ip_vs_sync_thread_data *tinfo;
 	struct task_struct **array = NULL, *task;
@@ -1746,7 +1826,8 @@ int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid)
 	char *name;
 	int (*threadfn)(void *data);
 	int id, count;
-	int result = -ENOMEM;
+	int err, result = -ENOMEM;
+	struct net_device *dev;
 
 	IP_VS_DBG(7, "%s(): pid %d\n", __func__, task_pid_nr(current));
 	IP_VS_DBG(7, "Each ip_vs_sync_conn entry needs %Zd bytes\n",
@@ -1758,22 +1839,52 @@ int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid)
 	} else
 		count = ipvs->threads_mask + 1;
 
+	if (c->mcast_af == AF_UNSPEC) {
+		c->mcast_af = AF_INET;
+		c->mcast_group.ip = cpu_to_be32(IP_VS_SYNC_GROUP);
+	}
+
+	if (!c->mcast_port)
+		c->mcast_port = IP_VS_SYNC_PORT;
+	if (!c->mcast_ttl)
+		c->mcast_ttl = 1;
+	err = 0;
+	rcu_read_lock();
+	dev = dev_get_by_name_rcu(net, c->mcast_ifn);
+	if (!dev) {
+		pr_err("Unknown mcast interface: %s\n", c->mcast_ifn);
+		err = -ENODEV;
+	} else {
+		int hlen = (AF_INET6 == c->mcast_af) ?
+			   sizeof(struct ipv6hdr) + sizeof(struct udphdr) :
+			   sizeof(struct iphdr) + sizeof(struct udphdr);
+		u16 mtu = (state == IP_VS_STATE_BACKUP) ?
+			  clamp(dev->mtu, 1500U, 65535U) : 1500U;
+		u16 min_mtu = (state == IP_VS_STATE_BACKUP) ? 1024 : 1;
+
+		if (c->sync_maxlen)
+			c->sync_maxlen = clamp_t(unsigned int,
+						 c->sync_maxlen, min_mtu,
+						 65535 - hlen);
+		else
+			c->sync_maxlen = mtu - hlen;
+	}
+	rcu_read_unlock();
+	if (err)
+		return err;
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
@@ -1801,7 +1912,6 @@ int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid)
 		if (!array)
 			goto out;
 	}
-	set_sync_mesg_maxlen(net, state);
 
 	tinfo = NULL;
 	for (id = 0; id < count; id++) {
@@ -1819,7 +1929,7 @@ int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid)
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

