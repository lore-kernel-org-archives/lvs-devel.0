From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 14/22] IPVS: netns awareness to ip_vs_sync
Date: Thu,  6 Jan 2011 15:16:10 +0900
Message-ID: <1294294578-8601-15-git-send-email-horms@verge.net.au>
References: <1294294578-8601-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1294294578-8601-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Patrick McHardy <kaber@trash.net>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

All global variables moved to struct ipvs,
most external changes fixed (i.e. init_net removed)
in sync_buf create  + 4 replaced by sizeof(struct..)

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |   14 +-
 include/net/netns/ip_vs.h       |   16 ++
 net/netfilter/ipvs/ip_vs_core.c |   15 +-
 net/netfilter/ipvs/ip_vs_ctl.c  |   52 ++++---
 net/netfilter/ipvs/ip_vs_sync.c |  334 +++++++++++++++++++++------------------
 5 files changed, 240 insertions(+), 191 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index c08927b..4265b5e 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -958,7 +958,7 @@ extern struct ip_vs_stats ip_vs_stats;
 extern const struct ctl_path net_vs_ctl_path[];
 extern int sysctl_ip_vs_sync_ver;
 
-extern void ip_vs_sync_switch_mode(int mode);
+extern void ip_vs_sync_switch_mode(struct net *net, int mode);
 extern struct ip_vs_service *
 ip_vs_service_get(struct net *net, int af, __u32 fwmark, __u16 protocol,
 		  const union nf_inet_addr *vaddr, __be16 vport);
@@ -987,14 +987,10 @@ extern struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp);
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
+			     __u8 syncid);
+extern int stop_sync_thread(struct net *net, int state);
+extern void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp);
 extern int ip_vs_sync_init(void);
 extern void ip_vs_sync_cleanup(void);
 
diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
index db02401..aba78f3 100644
--- a/include/net/netns/ip_vs.h
+++ b/include/net/netns/ip_vs.h
@@ -74,6 +74,22 @@ struct netns_ipvs {
 	struct list_head	est_list;	/* estimator list */
 	spinlock_t		est_lock;
 	struct timer_list	est_timer;	/* Estimation timer */
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
 };
 
 #endif /* IP_VS_H_ */
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 9317aff..5531d56 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1471,12 +1471,13 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 static unsigned int
 ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 {
-	struct net *net = NULL;
+	struct net *net;
 	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
 	struct ip_vs_conn *cp;
 	int ret, restart, pkts;
+	struct netns_ipvs *ipvs;
 
 	/* Already marked as IPVS request or reply? */
 	if (skb->ipvs_property)
@@ -1556,7 +1557,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	}
 
 	IP_VS_DBG_PKT(11, af, pp, skb, 0, "Incoming packet");
-
+	net = skb_net(skb);
+	ipvs = net_ipvs(net);
 	/* Check the server status */
 	if (cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
 		/* the destination server is not available */
@@ -1589,12 +1591,13 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	 *
 	 * For ONE_PKT let ip_vs_sync_conn() do the filter work.
 	 */
+
 	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
 		pkts = sysctl_ip_vs_sync_threshold[0];
 	else
 		pkts = atomic_add_return(1, &cp->in_pkts);
 
-	if ((ip_vs_sync_state & IP_VS_STATE_MASTER) &&
+	if ((ipvs->sync_state & IP_VS_STATE_MASTER) &&
 	    cp->protocol == IPPROTO_SCTP) {
 		if ((cp->state == IP_VS_SCTP_S_ESTABLISHED &&
 			(pkts % sysctl_ip_vs_sync_threshold[1]
@@ -1603,13 +1606,13 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 				 ((cp->state == IP_VS_SCTP_S_CLOSED) ||
 				  (cp->state == IP_VS_SCTP_S_SHUT_ACK_CLI) ||
 				  (cp->state == IP_VS_SCTP_S_SHUT_ACK_SER)))) {
-			ip_vs_sync_conn(cp);
+			ip_vs_sync_conn(net, cp);
 			goto out;
 		}
 	}
 
 	/* Keep this block last: TCP and others with pp->num_states <= 1 */
-	else if ((ip_vs_sync_state & IP_VS_STATE_MASTER) &&
+	else if ((ipvs->sync_state & IP_VS_STATE_MASTER) &&
 	    (((cp->protocol != IPPROTO_TCP ||
 	       cp->state == IP_VS_TCP_S_ESTABLISHED) &&
 	      (pkts % sysctl_ip_vs_sync_threshold[1]
@@ -1619,7 +1622,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	       (cp->state == IP_VS_TCP_S_CLOSE) ||
 	       (cp->state == IP_VS_TCP_S_CLOSE_WAIT) ||
 	       (cp->state == IP_VS_TCP_S_TIME_WAIT)))))
-		ip_vs_sync_conn(cp);
+		ip_vs_sync_conn(net, cp);
 out:
 	cp->old_state = cp->state;
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index e569f7f..92436eb 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1561,7 +1561,8 @@ proc_do_sync_mode(ctl_table *table, int write,
 			/* Restore the correct value */
 			*valp = val;
 		} else {
-			ip_vs_sync_switch_mode(val);
+			struct net *net = current->nsproxy->net_ns;
+			ip_vs_sync_switch_mode(net, val);
 		}
 	}
 	return rc;
@@ -2176,11 +2177,12 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		goto out_unlock;
 	} else if (cmd == IP_VS_SO_SET_STARTDAEMON) {
 		struct ip_vs_daemon_user *dm = (struct ip_vs_daemon_user *)arg;
-		ret = start_sync_thread(dm->state, dm->mcast_ifn, dm->syncid);
+		ret = start_sync_thread(net, dm->state, dm->mcast_ifn,
+					dm->syncid);
 		goto out_unlock;
 	} else if (cmd == IP_VS_SO_SET_STOPDAEMON) {
 		struct ip_vs_daemon_user *dm = (struct ip_vs_daemon_user *)arg;
-		ret = stop_sync_thread(dm->state);
+		ret = stop_sync_thread(net, dm->state);
 		goto out_unlock;
 	}
 
@@ -2426,6 +2428,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	int ret = 0;
 	unsigned int copylen;
 	struct net *net = sock_net(sk);
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	BUG_ON(!net);
 	if (!capable(CAP_NET_ADMIN))
@@ -2548,15 +2551,17 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 		struct ip_vs_daemon_user d[2];
 
 		memset(&d, 0, sizeof(d));
-		if (ip_vs_sync_state & IP_VS_STATE_MASTER) {
+		if (ipvs->sync_state & IP_VS_STATE_MASTER) {
 			d[0].state = IP_VS_STATE_MASTER;
-			strlcpy(d[0].mcast_ifn, ip_vs_master_mcast_ifn, sizeof(d[0].mcast_ifn));
-			d[0].syncid = ip_vs_master_syncid;
+			strlcpy(d[0].mcast_ifn, ipvs->master_mcast_ifn,
+				sizeof(d[0].mcast_ifn));
+			d[0].syncid = ipvs->master_syncid;
 		}
-		if (ip_vs_sync_state & IP_VS_STATE_BACKUP) {
+		if (ipvs->sync_state & IP_VS_STATE_BACKUP) {
 			d[1].state = IP_VS_STATE_BACKUP;
-			strlcpy(d[1].mcast_ifn, ip_vs_backup_mcast_ifn, sizeof(d[1].mcast_ifn));
-			d[1].syncid = ip_vs_backup_syncid;
+			strlcpy(d[1].mcast_ifn, ipvs->backup_mcast_ifn,
+				sizeof(d[1].mcast_ifn));
+			d[1].syncid = ipvs->backup_syncid;
 		}
 		if (copy_to_user(user, &d, sizeof(d)) != 0)
 			ret = -EFAULT;
@@ -3063,20 +3068,23 @@ nla_put_failure:
 static int ip_vs_genl_dump_daemons(struct sk_buff *skb,
 				   struct netlink_callback *cb)
 {
+	struct net *net = skb_net(skb);
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
 	mutex_lock(&__ip_vs_mutex);
-	if ((ip_vs_sync_state & IP_VS_STATE_MASTER) && !cb->args[0]) {
+	if ((ipvs->sync_state & IP_VS_STATE_MASTER) && !cb->args[0]) {
 		if (ip_vs_genl_dump_daemon(skb, IP_VS_STATE_MASTER,
-					   ip_vs_master_mcast_ifn,
-					   ip_vs_master_syncid, cb) < 0)
+					   ipvs->master_mcast_ifn,
+					   ipvs->master_syncid, cb) < 0)
 			goto nla_put_failure;
 
 		cb->args[0] = 1;
 	}
 
-	if ((ip_vs_sync_state & IP_VS_STATE_BACKUP) && !cb->args[1]) {
+	if ((ipvs->sync_state & IP_VS_STATE_BACKUP) && !cb->args[1]) {
 		if (ip_vs_genl_dump_daemon(skb, IP_VS_STATE_BACKUP,
-					   ip_vs_backup_mcast_ifn,
-					   ip_vs_backup_syncid, cb) < 0)
+					   ipvs->backup_mcast_ifn,
+					   ipvs->backup_syncid, cb) < 0)
 			goto nla_put_failure;
 
 		cb->args[1] = 1;
@@ -3088,24 +3096,26 @@ nla_put_failure:
 	return skb->len;
 }
 
-static int ip_vs_genl_new_daemon(struct nlattr **attrs)
+static int ip_vs_genl_new_daemon(struct net *net, struct nlattr **attrs)
 {
 	if (!(attrs[IPVS_DAEMON_ATTR_STATE] &&
 	      attrs[IPVS_DAEMON_ATTR_MCAST_IFN] &&
 	      attrs[IPVS_DAEMON_ATTR_SYNC_ID]))
 		return -EINVAL;
 
-	return start_sync_thread(nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]),
+	return start_sync_thread(net,
+				 nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]),
 				 nla_data(attrs[IPVS_DAEMON_ATTR_MCAST_IFN]),
 				 nla_get_u32(attrs[IPVS_DAEMON_ATTR_SYNC_ID]));
 }
 
-static int ip_vs_genl_del_daemon(struct nlattr **attrs)
+static int ip_vs_genl_del_daemon(struct net *net, struct nlattr **attrs)
 {
 	if (!attrs[IPVS_DAEMON_ATTR_STATE])
 		return -EINVAL;
 
-	return stop_sync_thread(nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]));
+	return stop_sync_thread(net,
+				nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]));
 }
 
 static int ip_vs_genl_set_config(struct net *net, struct nlattr **attrs)
@@ -3161,9 +3171,9 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 		}
 
 		if (cmd == IPVS_CMD_NEW_DAEMON)
-			ret = ip_vs_genl_new_daemon(daemon_attrs);
+			ret = ip_vs_genl_new_daemon(net, daemon_attrs);
 		else
-			ret = ip_vs_genl_del_daemon(daemon_attrs);
+			ret = ip_vs_genl_del_daemon(net, daemon_attrs);
 		goto out;
 	} else if (cmd == IPVS_CMD_ZERO &&
 		   !info->attrs[IPVS_CMD_ATTR_SERVICE]) {
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 67b2b09..9cbc1a8 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -192,6 +192,7 @@ union ip_vs_sync_conn {
 #define IPVS_OPT_F_PARAM	(1 << (IPVS_OPT_PARAM-1))
 
 struct ip_vs_sync_thread_data {
+	struct net *net;
 	struct socket *sock;
 	char *buf;
 };
@@ -259,10 +260,6 @@ struct ip_vs_sync_mesg {
 	/* ip_vs_sync_conn entries start here */
 };
 
-/* the maximum length of sync (sending/receiving) message */
-static int sync_send_mesg_maxlen;
-static int sync_recv_mesg_maxlen;
-
 struct ip_vs_sync_buff {
 	struct list_head        list;
 	unsigned long           firstuse;
@@ -273,28 +270,6 @@ struct ip_vs_sync_buff {
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
 /* multicast addr */
 static struct sockaddr_in mcast_addr = {
 	.sin_family		= AF_INET,
@@ -324,20 +299,20 @@ static void hton_seq(struct ip_vs_seq *ho, struct ip_vs_seq *no)
 	put_unaligned_be32(ho->previous_delta, &no->previous_delta);
 }
 
-static inline struct ip_vs_sync_buff *sb_dequeue(void)
+static inline struct ip_vs_sync_buff *sb_dequeue(struct netns_ipvs *ipvs)
 {
 	struct ip_vs_sync_buff *sb;
 
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
@@ -345,25 +320,27 @@ static inline struct ip_vs_sync_buff *sb_dequeue(void)
 /*
  * Create a new sync buffer for Version 1 proto.
  */
-static inline struct ip_vs_sync_buff * ip_vs_sync_buff_create(void)
+static inline struct ip_vs_sync_buff *
+ip_vs_sync_buff_create(struct netns_ipvs *ipvs)
 {
 	struct ip_vs_sync_buff *sb;
 
 	if (!(sb=kmalloc(sizeof(struct ip_vs_sync_buff), GFP_ATOMIC)))
 		return NULL;
 
-	if (!(sb->mesg=kmalloc(sync_send_mesg_maxlen, GFP_ATOMIC))) {
+	sb->mesg = kmalloc(ipvs->send_mesg_maxlen, GFP_ATOMIC);
+	if (!sb->mesg) {
 		kfree(sb);
 		return NULL;
 	}
 	sb->mesg->reserved = 0;  /* old nr_conns i.e. must be zeo now */
 	sb->mesg->version = SYNC_PROTO_VER;
-	sb->mesg->syncid = ip_vs_master_syncid;
+	sb->mesg->syncid = ipvs->master_syncid;
 	sb->mesg->size = sizeof(struct ip_vs_sync_mesg);
 	sb->mesg->nr_conns = 0;
 	sb->mesg->spare = 0;
 	sb->head = (unsigned char *)sb->mesg + sizeof(struct ip_vs_sync_mesg);
-	sb->end = (unsigned char *)sb->mesg + sync_send_mesg_maxlen;
+	sb->end = (unsigned char *)sb->mesg + ipvs->send_mesg_maxlen;
 
 	sb->firstuse = jiffies;
 	return sb;
@@ -375,14 +352,16 @@ static inline void ip_vs_sync_buff_release(struct ip_vs_sync_buff *sb)
 	kfree(sb);
 }
 
-static inline void sb_queue_tail(struct ip_vs_sync_buff *sb)
+static inline void sb_queue_tail(struct netns_ipvs *ipvs)
 {
-	spin_lock(&ip_vs_sync_lock);
-	if (ip_vs_sync_state & IP_VS_STATE_MASTER)
-		list_add_tail(&sb->list, &ip_vs_sync_queue);
+	struct ip_vs_sync_buff *sb = ipvs->sync_buff;
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
@@ -390,18 +369,18 @@ static inline void sb_queue_tail(struct ip_vs_sync_buff *sb)
  *	than the specified time or the specified time is zero.
  */
 static inline struct ip_vs_sync_buff *
-get_curr_sync_buff(unsigned long time)
+get_curr_sync_buff(struct netns_ipvs *ipvs, unsigned long time)
 {
 	struct ip_vs_sync_buff *sb;
 
-	spin_lock_bh(&curr_sb_lock);
-	if (curr_sb && (time == 0 ||
-			time_before(jiffies - curr_sb->firstuse, time))) {
-		sb = curr_sb;
-		curr_sb = NULL;
+	spin_lock_bh(&ipvs->sync_buff_lock);
+	if (ipvs->sync_buff && (time == 0 ||
+	    time_before(jiffies - ipvs->sync_buff->firstuse, time))) {
+		sb = ipvs->sync_buff;
+		ipvs->sync_buff = NULL;
 	} else
 		sb = NULL;
-	spin_unlock_bh(&curr_sb_lock);
+	spin_unlock_bh(&ipvs->sync_buff_lock);
 	return sb;
 }
 
@@ -409,33 +388,37 @@ get_curr_sync_buff(unsigned long time)
  * Switch mode from sending version 0 or 1
  *  - must handle sync_buf
  */
-void ip_vs_sync_switch_mode(int mode) {
+void ip_vs_sync_switch_mode(struct net *net, int mode)
+{
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	if (!ip_vs_sync_state & IP_VS_STATE_MASTER)
+	if (!ipvs->sync_state & IP_VS_STATE_MASTER)
 		return;
-	if (mode == sysctl_ip_vs_sync_ver || !curr_sb)
+	if (mode == sysctl_ip_vs_sync_ver || !ipvs->sync_buff)
 		return;
 
-	spin_lock_bh(&curr_sb_lock);
+	spin_lock_bh(&ipvs->sync_buff_lock);
 	/* Buffer empty ? then let buf_create do the job  */
-	if ( curr_sb->mesg->size <=  sizeof(struct ip_vs_sync_mesg)) {
-		kfree(curr_sb);
-		curr_sb = NULL;
+	if (ipvs->sync_buff->mesg->size <=  sizeof(struct ip_vs_sync_mesg)) {
+		kfree(ipvs->sync_buff);
+		ipvs->sync_buff = NULL;
 	} else {
-		spin_lock_bh(&ip_vs_sync_lock);
-		if (ip_vs_sync_state & IP_VS_STATE_MASTER)
-			list_add_tail(&curr_sb->list, &ip_vs_sync_queue);
+		spin_lock_bh(&ipvs->sync_lock);
+		if (ipvs->sync_state & IP_VS_STATE_MASTER)
+			list_add_tail(&ipvs->sync_buff->list,
+				      &ipvs->sync_queue);
 		else
-			ip_vs_sync_buff_release(curr_sb);
-		spin_unlock_bh(&ip_vs_sync_lock);
+			ip_vs_sync_buff_release(ipvs->sync_buff);
+		spin_unlock_bh(&ipvs->sync_lock);
 	}
-	spin_unlock_bh(&curr_sb_lock);
+	spin_unlock_bh(&ipvs->sync_buff_lock);
 }
 
 /*
  * Create a new sync buffer for Version 0 proto.
  */
-static inline struct ip_vs_sync_buff * ip_vs_sync_buff_create_v0(void)
+static inline struct ip_vs_sync_buff *
+ip_vs_sync_buff_create_v0(struct netns_ipvs *ipvs)
 {
 	struct ip_vs_sync_buff *sb;
 	struct ip_vs_sync_mesg_v0 *mesg;
@@ -443,16 +426,17 @@ static inline struct ip_vs_sync_buff * ip_vs_sync_buff_create_v0(void)
 	if (!(sb=kmalloc(sizeof(struct ip_vs_sync_buff), GFP_ATOMIC)))
 		return NULL;
 
-	if (!(sb->mesg=kmalloc(sync_send_mesg_maxlen, GFP_ATOMIC))) {
+	sb->mesg = kmalloc(ipvs->send_mesg_maxlen, GFP_ATOMIC);
+	if (!sb->mesg) {
 		kfree(sb);
 		return NULL;
 	}
 	mesg = (struct ip_vs_sync_mesg_v0 *)sb->mesg;
 	mesg->nr_conns = 0;
-	mesg->syncid = ip_vs_master_syncid;
-	mesg->size = 4;
-	sb->head = (unsigned char *)mesg + 4;
-	sb->end = (unsigned char *)mesg + sync_send_mesg_maxlen;
+	mesg->syncid = ipvs->master_syncid;
+	mesg->size = sizeof(struct ip_vs_sync_mesg_v0);
+	sb->head = (unsigned char *)mesg + sizeof(struct ip_vs_sync_mesg_v0);
+	sb->end = (unsigned char *)mesg + ipvs->send_mesg_maxlen;
 	sb->firstuse = jiffies;
 	return sb;
 }
@@ -461,8 +445,9 @@ static inline struct ip_vs_sync_buff * ip_vs_sync_buff_create_v0(void)
  *      Version 0 , could be switched in by sys_ctl.
  *      Add an ip_vs_conn information into the current sync_buff.
  */
-void ip_vs_sync_conn_v0(struct ip_vs_conn *cp)
+void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_sync_mesg_v0 *m;
 	struct ip_vs_sync_conn_v0 *s;
 	int len;
@@ -473,10 +458,12 @@ void ip_vs_sync_conn_v0(struct ip_vs_conn *cp)
 	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
 		return;
 
-	spin_lock(&curr_sb_lock);
-	if (!curr_sb) {
-		if (!(curr_sb=ip_vs_sync_buff_create_v0())) {
-			spin_unlock(&curr_sb_lock);
+	spin_lock(&ipvs->sync_buff_lock);
+	if (!ipvs->sync_buff) {
+		ipvs->sync_buff =
+			ip_vs_sync_buff_create_v0(ipvs);
+		if (!ipvs->sync_buff) {
+			spin_unlock(&ipvs->sync_buff_lock);
 			pr_err("ip_vs_sync_buff_create failed.\n");
 			return;
 		}
@@ -484,8 +471,8 @@ void ip_vs_sync_conn_v0(struct ip_vs_conn *cp)
 
 	len = (cp->flags & IP_VS_CONN_F_SEQ_MASK) ? FULL_CONN_SIZE :
 		SIMPLE_CONN_SIZE;
-	m = (struct ip_vs_sync_mesg_v0 *)curr_sb->mesg;
-	s = (struct ip_vs_sync_conn_v0 *)curr_sb->head;
+	m = (struct ip_vs_sync_mesg_v0 *)ipvs->sync_buff->mesg;
+	s = (struct ip_vs_sync_conn_v0 *)ipvs->sync_buff->head;
 
 	/* copy members */
 	s->reserved = 0;
@@ -506,18 +493,18 @@ void ip_vs_sync_conn_v0(struct ip_vs_conn *cp)
 
 	m->nr_conns++;
 	m->size += len;
-	curr_sb->head += len;
+	ipvs->sync_buff->head += len;
 
 	/* check if there is a space for next one */
-	if (curr_sb->head + FULL_CONN_SIZE > curr_sb->end) {
-		sb_queue_tail(curr_sb);
-		curr_sb = NULL;
+	if (ipvs->sync_buff->head + FULL_CONN_SIZE > ipvs->sync_buff->end) {
+		sb_queue_tail(ipvs);
+		ipvs->sync_buff = NULL;
 	}
-	spin_unlock(&curr_sb_lock);
+	spin_unlock(&ipvs->sync_buff_lock);
 
 	/* synchronize its controller if it has */
 	if (cp->control)
-		ip_vs_sync_conn(cp->control);
+		ip_vs_sync_conn(net, cp->control);
 }
 
 /*
@@ -525,8 +512,9 @@ void ip_vs_sync_conn_v0(struct ip_vs_conn *cp)
  *      Called by ip_vs_in.
  *      Sending Version 1 messages
  */
-void ip_vs_sync_conn(struct ip_vs_conn *cp)
+void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_sync_mesg *m;
 	union ip_vs_sync_conn *s;
 	__u8 *p;
@@ -534,7 +522,7 @@ void ip_vs_sync_conn(struct ip_vs_conn *cp)
 
 	/* Handle old version of the protocol */
 	if (sysctl_ip_vs_sync_ver == 0) {
-		ip_vs_sync_conn_v0(cp);
+		ip_vs_sync_conn_v0(net, cp);
 		return;
 	}
 	/* Do not sync ONE PACKET */
@@ -551,7 +539,7 @@ sloop:
 		pe_name_len = strnlen(cp->pe->name, IP_VS_PENAME_MAXLEN);
 	}
 
-	spin_lock(&curr_sb_lock);
+	spin_lock(&ipvs->sync_buff_lock);
 
 #ifdef CONFIG_IP_VS_IPV6
 	if (cp->af == AF_INET6)
@@ -570,26 +558,27 @@ sloop:
 
 	/* check if there is a space for this one  */
 	pad = 0;
-	if (curr_sb) {
-		pad = (4 - (size_t)curr_sb->head) & 3;
-		if (curr_sb->head + len + pad > curr_sb->end) {
-			sb_queue_tail(curr_sb);
-			curr_sb = NULL;
+	if (ipvs->sync_buff) {
+		pad = (4 - (size_t)ipvs->sync_buff->head) & 3;
+		if (ipvs->sync_buff->head + len + pad > ipvs->sync_buff->end) {
+			sb_queue_tail(ipvs);
+			ipvs->sync_buff = NULL;
 			pad = 0;
 		}
 	}
 
-	if (!curr_sb) {
-		if (!(curr_sb=ip_vs_sync_buff_create())) {
-			spin_unlock(&curr_sb_lock);
+	if (!ipvs->sync_buff) {
+		ipvs->sync_buff = ip_vs_sync_buff_create(ipvs);
+		if (!ipvs->sync_buff) {
+			spin_unlock(&ipvs->sync_buff_lock);
 			pr_err("ip_vs_sync_buff_create failed.\n");
 			return;
 		}
 	}
 
-	m = curr_sb->mesg;
-	p = curr_sb->head;
-	curr_sb->head += pad + len;
+	m = ipvs->sync_buff->mesg;
+	p = ipvs->sync_buff->head;
+	ipvs->sync_buff->head += pad + len;
 	m->size += pad + len;
 	/* Add ev. padding from prev. sync_conn */
 	while (pad--)
@@ -647,7 +636,7 @@ sloop:
 		}
 	}
 
-	spin_unlock(&curr_sb_lock);
+	spin_unlock(&ipvs->sync_buff_lock);
 
 control:
 	/* synchronize its controller if it has */
@@ -699,7 +688,8 @@ ip_vs_conn_fill_param_sync(int af, union ip_vs_sync_conn *sc,
 			buff[pe_name_len]=0;
 			p->pe = __ip_vs_pe_getbyname(buff);
 			if (!p->pe) {
-				IP_VS_DBG(3, "BACKUP, no %s engine found/loaded\n", buff);
+				IP_VS_DBG(3, "BACKUP, no %s engine found/loaded\n",
+					     buff);
 				return 1;
 			}
 		} else {
@@ -748,7 +738,7 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 		 * If it is not found the connection will remain unbound
 		 * but still handled.
 		 */
-		dest = ip_vs_find_dest(&init_net, type, daddr, dport, param->vaddr,
+		dest = ip_vs_find_dest(net, type, daddr, dport, param->vaddr,
 				       param->vport, protocol, fwmark);
 
 		/*  Set the approprite ativity flag */
@@ -1089,6 +1079,7 @@ out:
 static void ip_vs_process_message(struct net *net, __u8 *buffer,
 				  const size_t buflen)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_sync_mesg *m2 = (struct ip_vs_sync_mesg *)buffer;
 	__u8 *p, *msg_end;
 	int i, nr_conns;
@@ -1105,7 +1096,7 @@ static void ip_vs_process_message(struct net *net, __u8 *buffer,
 		return;
 	}
 	/* SyncID sanity check */
-	if (ip_vs_backup_syncid != 0 && m2->syncid != ip_vs_backup_syncid) {
+	if (ipvs->backup_syncid != 0 && m2->syncid != ipvs->backup_syncid) {
 		IP_VS_DBG(7, "BACKUP, Ignoring syncid = %d\n", m2->syncid);
 		return;
 	}
@@ -1190,8 +1181,10 @@ static int set_mcast_if(struct sock *sk, char *ifname)
 {
 	struct net_device *dev;
 	struct inet_sock *inet = inet_sk(sk);
+	struct net *net = sock_net(sk);
 
-	if ((dev = __dev_get_by_name(&init_net, ifname)) == NULL)
+	dev = __dev_get_by_name(net, ifname);
+	if (!dev)
 		return -ENODEV;
 
 	if (sk->sk_bound_dev_if && dev->ifindex != sk->sk_bound_dev_if)
@@ -1210,30 +1203,33 @@ static int set_mcast_if(struct sock *sk, char *ifname)
  *	Set the maximum length of sync message according to the
  *	specified interface's MTU.
  */
-static int set_sync_mesg_maxlen(int sync_state)
+static int set_sync_mesg_maxlen(struct net *net, int sync_state)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct net_device *dev;
 	int num;
 
 	if (sync_state == IP_VS_STATE_MASTER) {
-		if ((dev = __dev_get_by_name(&init_net, ip_vs_master_mcast_ifn)) == NULL)
+		dev = __dev_get_by_name(net, ipvs->master_mcast_ifn);
+		if (!dev)
 			return -ENODEV;
 
 		num = (dev->mtu - sizeof(struct iphdr) -
 		       sizeof(struct udphdr) -
 		       SYNC_MESG_HEADER_LEN - 20) / SIMPLE_CONN_SIZE;
-		sync_send_mesg_maxlen = SYNC_MESG_HEADER_LEN +
+		ipvs->send_mesg_maxlen = SYNC_MESG_HEADER_LEN +
 			SIMPLE_CONN_SIZE * min(num, MAX_CONNS_PER_SYNCBUFF);
 		IP_VS_DBG(7, "setting the maximum length of sync sending "
-			  "message %d.\n", sync_send_mesg_maxlen);
+			  "message %d.\n", ipvs->send_mesg_maxlen);
 	} else if (sync_state == IP_VS_STATE_BACKUP) {
-		if ((dev = __dev_get_by_name(&init_net, ip_vs_backup_mcast_ifn)) == NULL)
+		dev = __dev_get_by_name(net, ipvs->backup_mcast_ifn);
+		if (!dev)
 			return -ENODEV;
 
-		sync_recv_mesg_maxlen = dev->mtu -
+		ipvs->recv_mesg_maxlen = dev->mtu -
 			sizeof(struct iphdr) - sizeof(struct udphdr);
 		IP_VS_DBG(7, "setting the maximum length of sync receiving "
-			  "message %d.\n", sync_recv_mesg_maxlen);
+			  "message %d.\n", ipvs->recv_mesg_maxlen);
 	}
 
 	return 0;
@@ -1248,6 +1244,7 @@ static int set_sync_mesg_maxlen(int sync_state)
 static int
 join_mcast_group(struct sock *sk, struct in_addr *addr, char *ifname)
 {
+	struct net *net = sock_net(sk);
 	struct ip_mreqn mreq;
 	struct net_device *dev;
 	int ret;
@@ -1255,7 +1252,8 @@ join_mcast_group(struct sock *sk, struct in_addr *addr, char *ifname)
 	memset(&mreq, 0, sizeof(mreq));
 	memcpy(&mreq.imr_multiaddr, addr, sizeof(struct in_addr));
 
-	if ((dev = __dev_get_by_name(&init_net, ifname)) == NULL)
+	dev = __dev_get_by_name(net, ifname);
+	if (!dev)
 		return -ENODEV;
 	if (sk->sk_bound_dev_if && dev->ifindex != sk->sk_bound_dev_if)
 		return -EINVAL;
@@ -1272,11 +1270,13 @@ join_mcast_group(struct sock *sk, struct in_addr *addr, char *ifname)
 
 static int bind_mcastif_addr(struct socket *sock, char *ifname)
 {
+	struct net *net = sock_net(sock->sk);
 	struct net_device *dev;
 	__be32 addr;
 	struct sockaddr_in sin;
 
-	if ((dev = __dev_get_by_name(&init_net, ifname)) == NULL)
+	dev = __dev_get_by_name(net, ifname);
+	if (!dev)
 		return -ENODEV;
 
 	addr = inet_select_addr(dev, 0, RT_SCOPE_UNIVERSE);
@@ -1298,8 +1298,9 @@ static int bind_mcastif_addr(struct socket *sock, char *ifname)
 /*
  *      Set up sending multicast socket over UDP
  */
-static struct socket * make_send_sock(void)
+static struct socket *make_send_sock(struct net *net)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct socket *sock;
 	int result;
 
@@ -1310,7 +1311,7 @@ static struct socket * make_send_sock(void)
 		return ERR_PTR(result);
 	}
 
-	result = set_mcast_if(sock->sk, ip_vs_master_mcast_ifn);
+	result = set_mcast_if(sock->sk, ipvs->master_mcast_ifn);
 	if (result < 0) {
 		pr_err("Error setting outbound mcast interface\n");
 		goto error;
@@ -1319,7 +1320,7 @@ static struct socket * make_send_sock(void)
 	set_mcast_loop(sock->sk, 0);
 	set_mcast_ttl(sock->sk, 1);
 
-	result = bind_mcastif_addr(sock, ip_vs_master_mcast_ifn);
+	result = bind_mcastif_addr(sock, ipvs->master_mcast_ifn);
 	if (result < 0) {
 		pr_err("Error binding address of the mcast interface\n");
 		goto error;
@@ -1343,8 +1344,9 @@ static struct socket * make_send_sock(void)
 /*
  *      Set up receiving multicast socket over UDP
  */
-static struct socket * make_receive_sock(void)
+static struct socket *make_receive_sock(struct net *net)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct socket *sock;
 	int result;
 
@@ -1368,7 +1370,7 @@ static struct socket * make_receive_sock(void)
 	/* join the multicast group */
 	result = join_mcast_group(sock->sk,
 			(struct in_addr *) &mcast_addr.sin_addr,
-			ip_vs_backup_mcast_ifn);
+			ipvs->backup_mcast_ifn);
 	if (result < 0) {
 		pr_err("Error joining to the multicast group\n");
 		goto error;
@@ -1439,20 +1441,21 @@ ip_vs_receive(struct socket *sock, char *buffer, const size_t buflen)
 static int sync_thread_master(void *data)
 {
 	struct ip_vs_sync_thread_data *tinfo = data;
+	struct netns_ipvs *ipvs = net_ipvs(tinfo->net);
 	struct ip_vs_sync_buff *sb;
 
 	pr_info("sync thread started: state = MASTER, mcast_ifn = %s, "
 		"syncid = %d\n",
-		ip_vs_master_mcast_ifn, ip_vs_master_syncid);
+		ipvs->master_mcast_ifn, ipvs->master_syncid);
 
 	while (!kthread_should_stop()) {
-		while ((sb = sb_dequeue())) {
+		while ((sb = sb_dequeue(ipvs))) {
 			ip_vs_send_sync_msg(tinfo->sock, sb->mesg);
 			ip_vs_sync_buff_release(sb);
 		}
 
-		/* check if entries stay in curr_sb for 2 seconds */
-		sb = get_curr_sync_buff(2 * HZ);
+		/* check if entries stay in ipvs->sync_buff for 2 seconds */
+		sb = get_curr_sync_buff(ipvs, 2 * HZ);
 		if (sb) {
 			ip_vs_send_sync_msg(tinfo->sock, sb->mesg);
 			ip_vs_sync_buff_release(sb);
@@ -1462,14 +1465,13 @@ static int sync_thread_master(void *data)
 	}
 
 	/* clean up the sync_buff queue */
-	while ((sb=sb_dequeue())) {
+	while ((sb = sb_dequeue(ipvs)))
 		ip_vs_sync_buff_release(sb);
-	}
 
 	/* clean up the current sync_buff */
-	if ((sb = get_curr_sync_buff(0))) {
+	sb = get_curr_sync_buff(ipvs, 0);
+	if (sb)
 		ip_vs_sync_buff_release(sb);
-	}
 
 	/* release the sending multicast socket */
 	sock_release(tinfo->sock);
@@ -1482,11 +1484,12 @@ static int sync_thread_master(void *data)
 static int sync_thread_backup(void *data)
 {
 	struct ip_vs_sync_thread_data *tinfo = data;
+	struct netns_ipvs *ipvs = net_ipvs(tinfo->net);
 	int len;
 
 	pr_info("sync thread started: state = BACKUP, mcast_ifn = %s, "
 		"syncid = %d\n",
-		ip_vs_backup_mcast_ifn, ip_vs_backup_syncid);
+		ipvs->backup_mcast_ifn, ipvs->backup_syncid);
 
 	while (!kthread_should_stop()) {
 		wait_event_interruptible(*sk_sleep(tinfo->sock->sk),
@@ -1496,7 +1499,7 @@ static int sync_thread_backup(void *data)
 		/* do we have data now? */
 		while (!skb_queue_empty(&(tinfo->sock->sk->sk_receive_queue))) {
 			len = ip_vs_receive(tinfo->sock, tinfo->buf,
-					sync_recv_mesg_maxlen);
+					ipvs->recv_mesg_maxlen);
 			if (len <= 0) {
 				pr_err("receiving message error\n");
 				break;
@@ -1505,7 +1508,7 @@ static int sync_thread_backup(void *data)
 			/* disable bottom half, because it accesses the data
 			   shared by softirq while getting/creating conns */
 			local_bh_disable();
-			ip_vs_process_message(&init_net, tinfo->buf, len);
+			ip_vs_process_message(tinfo->net, tinfo->buf, len);
 			local_bh_enable();
 		}
 	}
@@ -1519,11 +1522,12 @@ static int sync_thread_backup(void *data)
 }
 
 
-int start_sync_thread(int state, char *mcast_ifn, __u8 syncid)
+int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid)
 {
 	struct ip_vs_sync_thread_data *tinfo;
 	struct task_struct **realtask, *task;
 	struct socket *sock;
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	char *name, *buf = NULL;
 	int (*threadfn)(void *data);
 	int result = -ENOMEM;
@@ -1533,27 +1537,27 @@ int start_sync_thread(int state, char *mcast_ifn, __u8 syncid)
 		  sizeof(struct ip_vs_sync_conn_v0));
 
 	if (state == IP_VS_STATE_MASTER) {
-		if (sync_master_thread)
+		if (ipvs->master_thread)
 			return -EEXIST;
 
-		strlcpy(ip_vs_master_mcast_ifn, mcast_ifn,
-			sizeof(ip_vs_master_mcast_ifn));
-		ip_vs_master_syncid = syncid;
-		realtask = &sync_master_thread;
-		name = "ipvs_syncmaster";
+		strlcpy(ipvs->master_mcast_ifn, mcast_ifn,
+			sizeof(ipvs->master_mcast_ifn));
+		ipvs->master_syncid = syncid;
+		realtask = &ipvs->master_thread;
+		name = "ipvs_master:%d";
 		threadfn = sync_thread_master;
-		sock = make_send_sock();
+		sock = make_send_sock(net);
 	} else if (state == IP_VS_STATE_BACKUP) {
-		if (sync_backup_thread)
+		if (ipvs->backup_thread)
 			return -EEXIST;
 
-		strlcpy(ip_vs_backup_mcast_ifn, mcast_ifn,
-			sizeof(ip_vs_backup_mcast_ifn));
-		ip_vs_backup_syncid = syncid;
-		realtask = &sync_backup_thread;
-		name = "ipvs_syncbackup";
+		strlcpy(ipvs->backup_mcast_ifn, mcast_ifn,
+			sizeof(ipvs->backup_mcast_ifn));
+		ipvs->backup_syncid = syncid;
+		realtask = &ipvs->backup_thread;
+		name = "ipvs_backup:%d";
 		threadfn = sync_thread_backup;
-		sock = make_receive_sock();
+		sock = make_receive_sock(net);
 	} else {
 		return -EINVAL;
 	}
@@ -1563,9 +1567,9 @@ int start_sync_thread(int state, char *mcast_ifn, __u8 syncid)
 		goto out;
 	}
 
-	set_sync_mesg_maxlen(state);
+	set_sync_mesg_maxlen(net, state);
 	if (state == IP_VS_STATE_BACKUP) {
-		buf = kmalloc(sync_recv_mesg_maxlen, GFP_KERNEL);
+		buf = kmalloc(ipvs->recv_mesg_maxlen, GFP_KERNEL);
 		if (!buf)
 			goto outsocket;
 	}
@@ -1574,10 +1578,11 @@ int start_sync_thread(int state, char *mcast_ifn, __u8 syncid)
 	if (!tinfo)
 		goto outbuf;
 
+	tinfo->net = net;
 	tinfo->sock = sock;
 	tinfo->buf = buf;
 
-	task = kthread_run(threadfn, tinfo, name);
+	task = kthread_run(threadfn, tinfo, name, ipvs->gen);
 	if (IS_ERR(task)) {
 		result = PTR_ERR(task);
 		goto outtinfo;
@@ -1585,7 +1590,7 @@ int start_sync_thread(int state, char *mcast_ifn, __u8 syncid)
 
 	/* mark as active */
 	*realtask = task;
-	ip_vs_sync_state |= state;
+	ipvs->sync_state |= state;
 
 	/* increase the module use count */
 	ip_vs_use_count_inc();
@@ -1603,16 +1608,18 @@ out:
 }
 
 
-int stop_sync_thread(int state)
+int stop_sync_thread(struct net *net, int state)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
 	IP_VS_DBG(7, "%s(): pid %d\n", __func__, task_pid_nr(current));
 
 	if (state == IP_VS_STATE_MASTER) {
-		if (!sync_master_thread)
+		if (!ipvs->master_thread)
 			return -ESRCH;
 
 		pr_info("stopping master sync thread %d ...\n",
-			task_pid_nr(sync_master_thread));
+			task_pid_nr(ipvs->master_thread));
 
 		/*
 		 * The lock synchronizes with sb_queue_tail(), so that we don't
@@ -1620,21 +1627,21 @@ int stop_sync_thread(int state)
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
+		kthread_stop(ipvs->master_thread);
+		ipvs->master_thread = NULL;
 	} else if (state == IP_VS_STATE_BACKUP) {
-		if (!sync_backup_thread)
+		if (!ipvs->backup_thread)
 			return -ESRCH;
 
 		pr_info("stopping backup sync thread %d ...\n",
-			task_pid_nr(sync_backup_thread));
+			task_pid_nr(ipvs->backup_thread));
 
-		ip_vs_sync_state &= ~IP_VS_STATE_BACKUP;
-		kthread_stop(sync_backup_thread);
-		sync_backup_thread = NULL;
+		ipvs->sync_state &= ~IP_VS_STATE_BACKUP;
+		kthread_stop(ipvs->backup_thread);
+		ipvs->backup_thread = NULL;
 	} else {
 		return -EINVAL;
 	}
@@ -1650,12 +1657,29 @@ int stop_sync_thread(int state)
  */
 static int __net_init __ip_vs_sync_init(struct net *net)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
+	if (!net_eq(net, &init_net))	/* netns not enabled yet */
+		return -EPERM;
+
+	INIT_LIST_HEAD(&ipvs->sync_queue);
+	spin_lock_init(&ipvs->sync_lock);
+	spin_lock_init(&ipvs->sync_buff_lock);
+
+	ipvs->sync_mcast_addr.sin_family = AF_INET;
+	ipvs->sync_mcast_addr.sin_port = cpu_to_be16(IP_VS_SYNC_PORT);
+	ipvs->sync_mcast_addr.sin_addr.s_addr = cpu_to_be32(IP_VS_SYNC_GROUP);
 	return 0;
 }
 
 static void __ip_vs_sync_cleanup(struct net *net)
 {
+	if (!net_eq(net, &init_net))	/* netns not enabled yet */
+		return;
+	stop_sync_thread(net, IP_VS_STATE_MASTER);
+	stop_sync_thread(net, IP_VS_STATE_BACKUP);
 }
+
 static struct pernet_operations ipvs_sync_ops = {
 	.init = __ip_vs_sync_init,
 	.exit = __ip_vs_sync_cleanup,
-- 
1.7.2.3

