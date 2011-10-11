From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] IPVS netns shutdown/startup dead-lock
Date: Tue, 11 Oct 2011 10:54:35 +0900
Message-ID: <1318298075-23501-2-git-send-email-horms@verge.net.au>
References: <1318298075-23501-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1318298075-23501-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>, Hans Schillstrom <hans@schillstrom.com>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans@schillstrom.com>

ip_vs_mutext is used by both netns shutdown code and startup
and both implicit uses sk_lock-AF_INET mutex.

cleanup CPU-1         startup CPU-2
ip_vs_dst_event()     ip_vs_genl_set_cmd()
 sk_lock-AF_INET     __ip_vs_mutex
                     sk_lock-AF_INET
__ip_vs_mutex
* DEAD LOCK *

A new mutex placed in ip_vs netns struct called sync_mutex is added.

Comments from Julian and Simon added.
This patch has been running for more than 3 month now and it seems to work.

Ver. 3
    IP_VS_SO_GET_DAEMON in do_ip_vs_get_ctl protected by sync_mutex
    instead of __ip_vs_mutex as sugested by Julian.

Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |    1 +
 net/netfilter/ipvs/ip_vs_ctl.c  |  131 ++++++++++++++++++++++++---------------
 net/netfilter/ipvs/ip_vs_sync.c |    6 ++
 3 files changed, 87 insertions(+), 51 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 1aaf915..8fa4430 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -900,6 +900,7 @@ struct netns_ipvs {
 	volatile int		sync_state;
 	volatile int		master_syncid;
 	volatile int		backup_syncid;
+	struct mutex		sync_mutex;
 	/* multicast interface name */
 	char			master_mcast_ifn[IP_VS_IFNAME_MAXLEN];
 	char			backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 5290ac3..e3be48b 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2283,6 +2283,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 	struct ip_vs_service *svc;
 	struct ip_vs_dest_user *udest_compat;
 	struct ip_vs_dest_user_kern udest;
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -2303,6 +2304,24 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 	/* increase the module use count */
 	ip_vs_use_count_inc();
 
+	/* Handle daemons since they have another lock */
+	if (cmd == IP_VS_SO_SET_STARTDAEMON ||
+	    cmd == IP_VS_SO_SET_STOPDAEMON) {
+		struct ip_vs_daemon_user *dm = (struct ip_vs_daemon_user *)arg;
+
+		if (mutex_lock_interruptible(&ipvs->sync_mutex)) {
+			ret = -ERESTARTSYS;
+			goto out_dec;
+		}
+		if (cmd == IP_VS_SO_SET_STARTDAEMON)
+			ret = start_sync_thread(net, dm->state, dm->mcast_ifn,
+						dm->syncid);
+		else
+			ret = stop_sync_thread(net, dm->state);
+		mutex_unlock(&ipvs->sync_mutex);
+		goto out_dec;
+	}
+
 	if (mutex_lock_interruptible(&__ip_vs_mutex)) {
 		ret = -ERESTARTSYS;
 		goto out_dec;
@@ -2316,15 +2335,6 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		/* Set timeout values for (tcp tcpfin udp) */
 		ret = ip_vs_set_timeout(net, (struct ip_vs_timeout_user *)arg);
 		goto out_unlock;
-	} else if (cmd == IP_VS_SO_SET_STARTDAEMON) {
-		struct ip_vs_daemon_user *dm = (struct ip_vs_daemon_user *)arg;
-		ret = start_sync_thread(net, dm->state, dm->mcast_ifn,
-					dm->syncid);
-		goto out_unlock;
-	} else if (cmd == IP_VS_SO_SET_STOPDAEMON) {
-		struct ip_vs_daemon_user *dm = (struct ip_vs_daemon_user *)arg;
-		ret = stop_sync_thread(net, dm->state);
-		goto out_unlock;
 	}
 
 	usvc_compat = (struct ip_vs_service_user *)arg;
@@ -2584,6 +2594,33 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 
 	if (copy_from_user(arg, user, copylen) != 0)
 		return -EFAULT;
+	/*
+	 * Handle daemons first since it has its own locking
+	 */
+	if (cmd == IP_VS_SO_GET_DAEMON) {
+		struct ip_vs_daemon_user d[2];
+
+		memset(&d, 0, sizeof(d));
+		if (mutex_lock_interruptible(&ipvs->sync_mutex))
+			return -ERESTARTSYS;
+
+		if (ipvs->sync_state & IP_VS_STATE_MASTER) {
+			d[0].state = IP_VS_STATE_MASTER;
+			strlcpy(d[0].mcast_ifn, ipvs->master_mcast_ifn,
+				sizeof(d[0].mcast_ifn));
+			d[0].syncid = ipvs->master_syncid;
+		}
+		if (ipvs->sync_state & IP_VS_STATE_BACKUP) {
+			d[1].state = IP_VS_STATE_BACKUP;
+			strlcpy(d[1].mcast_ifn, ipvs->backup_mcast_ifn,
+				sizeof(d[1].mcast_ifn));
+			d[1].syncid = ipvs->backup_syncid;
+		}
+		if (copy_to_user(user, &d, sizeof(d)) != 0)
+			ret = -EFAULT;
+		mutex_unlock(&ipvs->sync_mutex);
+		return ret;
+	}
 
 	if (mutex_lock_interruptible(&__ip_vs_mutex))
 		return -ERESTARTSYS;
@@ -2681,28 +2718,6 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	}
 	break;
 
-	case IP_VS_SO_GET_DAEMON:
-	{
-		struct ip_vs_daemon_user d[2];
-
-		memset(&d, 0, sizeof(d));
-		if (ipvs->sync_state & IP_VS_STATE_MASTER) {
-			d[0].state = IP_VS_STATE_MASTER;
-			strlcpy(d[0].mcast_ifn, ipvs->master_mcast_ifn,
-				sizeof(d[0].mcast_ifn));
-			d[0].syncid = ipvs->master_syncid;
-		}
-		if (ipvs->sync_state & IP_VS_STATE_BACKUP) {
-			d[1].state = IP_VS_STATE_BACKUP;
-			strlcpy(d[1].mcast_ifn, ipvs->backup_mcast_ifn,
-				sizeof(d[1].mcast_ifn));
-			d[1].syncid = ipvs->backup_syncid;
-		}
-		if (copy_to_user(user, &d, sizeof(d)) != 0)
-			ret = -EFAULT;
-	}
-	break;
-
 	default:
 		ret = -EINVAL;
 	}
@@ -3205,7 +3220,7 @@ static int ip_vs_genl_dump_daemons(struct sk_buff *skb,
 	struct net *net = skb_sknet(skb);
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	mutex_lock(&__ip_vs_mutex);
+	mutex_lock(&ipvs->sync_mutex);
 	if ((ipvs->sync_state & IP_VS_STATE_MASTER) && !cb->args[0]) {
 		if (ip_vs_genl_dump_daemon(skb, IP_VS_STATE_MASTER,
 					   ipvs->master_mcast_ifn,
@@ -3225,7 +3240,7 @@ static int ip_vs_genl_dump_daemons(struct sk_buff *skb,
 	}
 
 nla_put_failure:
-	mutex_unlock(&__ip_vs_mutex);
+	mutex_unlock(&ipvs->sync_mutex);
 
 	return skb->len;
 }
@@ -3271,13 +3286,9 @@ static int ip_vs_genl_set_config(struct net *net, struct nlattr **attrs)
 	return ip_vs_set_timeout(net, &t);
 }
 
-static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
+static int ip_vs_genl_set_daemon(struct sk_buff *skb, struct genl_info *info)
 {
-	struct ip_vs_service *svc = NULL;
-	struct ip_vs_service_user_kern usvc;
-	struct ip_vs_dest_user_kern udest;
 	int ret = 0, cmd;
-	int need_full_svc = 0, need_full_dest = 0;
 	struct net *net;
 	struct netns_ipvs *ipvs;
 
@@ -3285,19 +3296,10 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 	ipvs = net_ipvs(net);
 	cmd = info->genlhdr->cmd;
 
-	mutex_lock(&__ip_vs_mutex);
-
-	if (cmd == IPVS_CMD_FLUSH) {
-		ret = ip_vs_flush(net);
-		goto out;
-	} else if (cmd == IPVS_CMD_SET_CONFIG) {
-		ret = ip_vs_genl_set_config(net, info->attrs);
-		goto out;
-	} else if (cmd == IPVS_CMD_NEW_DAEMON ||
-		   cmd == IPVS_CMD_DEL_DAEMON) {
-
+	if (cmd == IPVS_CMD_NEW_DAEMON || cmd == IPVS_CMD_DEL_DAEMON) {
 		struct nlattr *daemon_attrs[IPVS_DAEMON_ATTR_MAX + 1];
 
+		mutex_lock(&ipvs->sync_mutex);
 		if (!info->attrs[IPVS_CMD_ATTR_DAEMON] ||
 		    nla_parse_nested(daemon_attrs, IPVS_DAEMON_ATTR_MAX,
 				     info->attrs[IPVS_CMD_ATTR_DAEMON],
@@ -3310,6 +3312,33 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 			ret = ip_vs_genl_new_daemon(net, daemon_attrs);
 		else
 			ret = ip_vs_genl_del_daemon(net, daemon_attrs);
+out:
+		mutex_unlock(&ipvs->sync_mutex);
+	}
+	return ret;
+}
+
+static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
+{
+	struct ip_vs_service *svc = NULL;
+	struct ip_vs_service_user_kern usvc;
+	struct ip_vs_dest_user_kern udest;
+	int ret = 0, cmd;
+	int need_full_svc = 0, need_full_dest = 0;
+	struct net *net;
+	struct netns_ipvs *ipvs;
+
+	net = skb_sknet(skb);
+	ipvs = net_ipvs(net);
+	cmd = info->genlhdr->cmd;
+
+	mutex_lock(&__ip_vs_mutex);
+
+	if (cmd == IPVS_CMD_FLUSH) {
+		ret = ip_vs_flush(net);
+		goto out;
+	} else if (cmd == IPVS_CMD_SET_CONFIG) {
+		ret = ip_vs_genl_set_config(net, info->attrs);
 		goto out;
 	} else if (cmd == IPVS_CMD_ZERO &&
 		   !info->attrs[IPVS_CMD_ATTR_SERVICE]) {
@@ -3536,13 +3565,13 @@ static struct genl_ops ip_vs_genl_ops[] __read_mostly = {
 		.cmd	= IPVS_CMD_NEW_DAEMON,
 		.flags	= GENL_ADMIN_PERM,
 		.policy	= ip_vs_cmd_policy,
-		.doit	= ip_vs_genl_set_cmd,
+		.doit	= ip_vs_genl_set_daemon,
 	},
 	{
 		.cmd	= IPVS_CMD_DEL_DAEMON,
 		.flags	= GENL_ADMIN_PERM,
 		.policy	= ip_vs_cmd_policy,
-		.doit	= ip_vs_genl_set_cmd,
+		.doit	= ip_vs_genl_set_daemon,
 	},
 	{
 		.cmd	= IPVS_CMD_GET_DAEMON,
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 7ee7215..3cdd479 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -61,6 +61,7 @@
 
 #define SYNC_PROTO_VER  1		/* Protocol version in header */
 
+static struct lock_class_key __ipvs_sync_key;
 /*
  *	IPVS sync connection entry
  *	Version 0, i.e. original version.
@@ -1545,6 +1546,7 @@ int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid)
 	IP_VS_DBG(7, "Each ip_vs_sync_conn entry needs %Zd bytes\n",
 		  sizeof(struct ip_vs_sync_conn_v0));
 
+
 	if (state == IP_VS_STATE_MASTER) {
 		if (ipvs->master_thread)
 			return -EEXIST;
@@ -1667,6 +1669,7 @@ int __net_init ip_vs_sync_net_init(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
+	__mutex_init(&ipvs->sync_mutex, "ipvs->sync_mutex", &__ipvs_sync_key);
 	INIT_LIST_HEAD(&ipvs->sync_queue);
 	spin_lock_init(&ipvs->sync_lock);
 	spin_lock_init(&ipvs->sync_buff_lock);
@@ -1680,7 +1683,9 @@ int __net_init ip_vs_sync_net_init(struct net *net)
 void ip_vs_sync_net_cleanup(struct net *net)
 {
 	int retc;
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
+	mutex_lock(&ipvs->sync_mutex);
 	retc = stop_sync_thread(net, IP_VS_STATE_MASTER);
 	if (retc && retc != -ESRCH)
 		pr_err("Failed to stop Master Daemon\n");
@@ -1688,4 +1693,5 @@ void ip_vs_sync_net_cleanup(struct net *net)
 	retc = stop_sync_thread(net, IP_VS_STATE_BACKUP);
 	if (retc && retc != -ESRCH)
 		pr_err("Failed to stop Backup Daemon\n");
+	mutex_unlock(&ipvs->sync_mutex);
 }
-- 
1.7.6.3
