From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [RFC PATCH 1/1] IPVS netns shutdown/startup dead-lock
Date: Mon, 13 Jun 2011 11:32:10 +0200
Message-ID: <1307957530-12732-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

ip_vs_mutext is used by both netns shutdown code and startup
and both implicit uses sk_lock-AF_INET mutex.

cleanup CPU-1         startup CPU-2
ip_vs_dst_event()     ip_vs_genl_set_cmd()
 sk_lock-AF_INET     __ip_vs_mutex
                     sk_lock-AF_INET
__ip_vs_mutex
* DEAD LOCK *

This can be solved by have the ip_vs_mutex per netns
or avid locking when starting/stoping sync-threads.
i.e. just add a starting/stoping flag.

ip_vs_mutex per name-space seems to be a more future proof solution.

Which one should be used ?

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/ip_vs.h             |    2 ++
 net/netfilter/ipvs/ip_vs_ctl.c  |   15 ++++++++++-----
 net/netfilter/ipvs/ip_vs_sync.c |   30 +++++++++++++++++++++++++-----
 3 files changed, 37 insertions(+), 10 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 34a6fa8..e82fa8d 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -895,6 +895,8 @@ struct netns_ipvs {
 	struct sockaddr_in	sync_mcast_addr;
 	struct task_struct	*master_thread;
 	struct task_struct	*backup_thread;
+	atomic_t		master_flg;	/* Start-up flag*/
+	atomic_t		backup_flg;
 	int			send_mesg_maxlen;
 	int			recv_mesg_maxlen;
 	volatile int		sync_state;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 699c79a..21c541f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2318,13 +2318,17 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		goto out_unlock;
 	} else if (cmd == IP_VS_SO_SET_STARTDAEMON) {
 		struct ip_vs_daemon_user *dm = (struct ip_vs_daemon_user *)arg;
+		/* Unlock since a global socket lock will be taken later */
+		mutex_unlock(&__ip_vs_mutex);
 		ret = start_sync_thread(net, dm->state, dm->mcast_ifn,
 					dm->syncid);
-		goto out_unlock;
+		goto out_dec;
 	} else if (cmd == IP_VS_SO_SET_STOPDAEMON) {
 		struct ip_vs_daemon_user *dm = (struct ip_vs_daemon_user *)arg;
+		/* Unlock since a global socket lock will be taken later */
+		mutex_unlock(&__ip_vs_mutex);
 		ret = stop_sync_thread(net, dm->state);
-		goto out_unlock;
+		goto out_dec;
 	}
 
 	usvc_compat = (struct ip_vs_service_user *)arg;
@@ -3305,12 +3309,13 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 			ret = -EINVAL;
 			goto out;
 		}
-
+		/* Unlock since a global socket lock will be taken later */
+		mutex_unlock(&__ip_vs_mutex);
 		if (cmd == IPVS_CMD_NEW_DAEMON)
 			ret = ip_vs_genl_new_daemon(net, daemon_attrs);
 		else
 			ret = ip_vs_genl_del_daemon(net, daemon_attrs);
-		goto out;
+		goto out_nounlock;
 	} else if (cmd == IPVS_CMD_ZERO &&
 		   !info->attrs[IPVS_CMD_ATTR_SERVICE]) {
 		ret = ip_vs_zero_all(net);
@@ -3382,7 +3387,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 
 out:
 	mutex_unlock(&__ip_vs_mutex);
-
+out_nounlock:
 	return ret;
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index e292e5b..7a996dc 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1540,30 +1540,37 @@ int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid)
 	char *name, *buf = NULL;
 	int (*threadfn)(void *data);
 	int result = -ENOMEM;
+	atomic_t *run_flg;
 
 	IP_VS_DBG(7, "%s(): pid %d\n", __func__, task_pid_nr(current));
 	IP_VS_DBG(7, "Each ip_vs_sync_conn entry needs %Zd bytes\n",
 		  sizeof(struct ip_vs_sync_conn_v0));
 
+	/* master/backup_flag is used to protect for multiple starts
+	 * the ip_vs_mutex can't be used here due to deadlock problems.*/
 	if (state == IP_VS_STATE_MASTER) {
-		if (ipvs->master_thread)
+		if (ipvs->master_thread ||
+		    !atomic_dec_and_test(&ipvs->master_flg))
 			return -EEXIST;
 
 		strlcpy(ipvs->master_mcast_ifn, mcast_ifn,
 			sizeof(ipvs->master_mcast_ifn));
 		ipvs->master_syncid = syncid;
 		realtask = &ipvs->master_thread;
+		run_flg = &ipvs->master_flg;
 		name = "ipvs_master:%d";
 		threadfn = sync_thread_master;
 		sock = make_send_sock(net);
 	} else if (state == IP_VS_STATE_BACKUP) {
-		if (ipvs->backup_thread)
+		if (ipvs->backup_thread ||
+		    !atomic_dec_and_test(&ipvs->backup_flg))
 			return -EEXIST;
 
 		strlcpy(ipvs->backup_mcast_ifn, mcast_ifn,
 			sizeof(ipvs->backup_mcast_ifn));
 		ipvs->backup_syncid = syncid;
 		realtask = &ipvs->backup_thread;
+		run_flg = &ipvs->backup_flg;
 		name = "ipvs_backup:%d";
 		threadfn = sync_thread_backup;
 		sock = make_receive_sock(net);
@@ -1600,7 +1607,8 @@ int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid)
 	/* mark as active */
 	*realtask = task;
 	ipvs->sync_state |= state;
-
+	/* Free to use again */
+	atomic_set(run_flg, 1);
 	/* increase the module use count */
 	ip_vs_use_count_inc();
 
@@ -1613,6 +1621,7 @@ outbuf:
 outsocket:
 	sk_release_kernel(sock->sk);
 out:
+	atomic_set(run_flg, -1);
 	return result;
 }
 
@@ -1621,11 +1630,15 @@ int stop_sync_thread(struct net *net, int state)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	int retc = -EINVAL;
+	atomic_t *run_flg;
 
 	IP_VS_DBG(7, "%s(): pid %d\n", __func__, task_pid_nr(current));
 
+	/* master/backup_flag is used to protect for multiple shutdowns
+	 * the ip_vs_mutex can't be used here due to deadlock problems.*/
 	if (state == IP_VS_STATE_MASTER) {
-		if (!ipvs->master_thread)
+		if (!ipvs->master_thread ||
+		    !atomic_dec_and_test(&ipvs->master_flg))
 			return -ESRCH;
 
 		pr_info("stopping master sync thread %d ...\n",
@@ -1642,8 +1655,11 @@ int stop_sync_thread(struct net *net, int state)
 		spin_unlock_bh(&ipvs->sync_lock);
 		retc = kthread_stop(ipvs->master_thread);
 		ipvs->master_thread = NULL;
+		/* Free to use again */
+		atomic_set(&ipvs->master_flg, 1);
 	} else if (state == IP_VS_STATE_BACKUP) {
-		if (!ipvs->backup_thread)
+		if (!ipvs->backup_thread ||
+		    !atomic_dec_and_test(&ipvs->backup_flg))
 			return -ESRCH;
 
 		pr_info("stopping backup sync thread %d ...\n",
@@ -1652,6 +1668,8 @@ int stop_sync_thread(struct net *net, int state)
 		ipvs->sync_state &= ~IP_VS_STATE_BACKUP;
 		retc = kthread_stop(ipvs->backup_thread);
 		ipvs->backup_thread = NULL;
+		/* Free to use again */
+		atomic_set(&ipvs->backup_flg, 1);
 	}
 
 	/* decrease the module use count */
@@ -1674,6 +1692,8 @@ int __net_init __ip_vs_sync_init(struct net *net)
 	ipvs->sync_mcast_addr.sin_family = AF_INET;
 	ipvs->sync_mcast_addr.sin_port = cpu_to_be16(IP_VS_SYNC_PORT);
 	ipvs->sync_mcast_addr.sin_addr.s_addr = cpu_to_be32(IP_VS_SYNC_GROUP);
+	atomic_set(&ipvs->master_flg, 1);
+	atomic_set(&ipvs->backup_flg, 1);
 	return 0;
 }
 
-- 
1.7.2.3

