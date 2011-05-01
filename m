From: Hans Schillstrom <hans@schillstrom.com>
Subject: [v4 PATCH 1/6] IPVS: Change of socket usage to enable name space exit.
Date: Sun,  1 May 2011 18:50:13 +0200
Message-ID: <1304268618-18103-2-git-send-email-hans@schillstrom.com>
References: <1304268618-18103-1-git-send-email-hans@schillstrom.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1304268618-18103-1-git-send-email-hans@schillstrom.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ja@ssi.bg, horms@verge.net.au, ebiederm@xmission.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans.schillstrom@ericsson.com, Hans Schillstrom <hans@schillstrom.com>

To work this patch also needs the other patches in this series.

VERSION: 4

DESCRIPTION

If the sync daemons run in a name space while it crashes
or get killed, there is no way to stop them except for a reboot.
When all patches are there, ip_vs_core will handle register_pernet_(),
i.e. ip_vs_sync_init() and ip_vs_sync_cleanup() will be removed.

Kernel threads should not increment the use count of a socket.
By calling sk_change_net() after creating a socket this is avoided.
sock_release cant be used intead sk_release_kernel() should be used.

Thanks Eric W Biederman for your advices.

This patch is based on net-next-2.6  ver 2.6.39-rc2

CHANGES
 Rev 2
   sock_create_kern() used instead of __sock_create()
   return codes of kthread_stop() used.
 Rev 3
   -
 Rev 4
   Check of return code changed to -ESRCH in __ip_vs_sync_cleanup()

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
---
 net/netfilter/ipvs/ip_vs_core.c |    2 +-
 net/netfilter/ipvs/ip_vs_sync.c |   58 +++++++++++++++++++++++++--------------
 2 files changed, 38 insertions(+), 22 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 07accf6..a0791dc 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1896,7 +1896,7 @@ static int __net_init __ip_vs_init(struct net *net)
 
 static void __net_exit __ip_vs_cleanup(struct net *net)
 {
-	IP_VS_DBG(10, "ipvs netns %d released\n", net_ipvs(net)->gen);
+	IP_VS_DBG(2, "ipvs netns %d released\n", net_ipvs(net)->gen);
 }
 
 static struct pernet_operations ipvs_core_ops = {
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 3e7961e..0cce953 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1303,13 +1303,18 @@ static struct socket *make_send_sock(struct net *net)
 	struct socket *sock;
 	int result;
 
-	/* First create a socket */
-	result = __sock_create(net, PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock, 1);
+	/* First create a socket move it to right name space later */
+	result = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
 	if (result < 0) {
 		pr_err("Error during creation of socket; terminating\n");
 		return ERR_PTR(result);
 	}
-
+	/*
+	 * Kernel sockets that are a part of a namespace, should not
+	 * hold a reference to a namespace in order to allow to stop it.
+	 * After sk_change_net should be released using sk_release_kernel.
+	 */
+	sk_change_net(sock->sk, net);
 	result = set_mcast_if(sock->sk, ipvs->master_mcast_ifn);
 	if (result < 0) {
 		pr_err("Error setting outbound mcast interface\n");
@@ -1334,8 +1339,8 @@ static struct socket *make_send_sock(struct net *net)
 
 	return sock;
 
-  error:
-	sock_release(sock);
+error:
+	sk_release_kernel(sock->sk);
 	return ERR_PTR(result);
 }
 
@@ -1350,12 +1355,17 @@ static struct socket *make_receive_sock(struct net *net)
 	int result;
 
 	/* First create a socket */
-	result = __sock_create(net, PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock, 1);
+	result = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
 	if (result < 0) {
 		pr_err("Error during creation of socket; terminating\n");
 		return ERR_PTR(result);
 	}
-
+	/*
+	 * Kernel sockets that are a part of a namespace, should not
+	 * hold a reference to a namespace in order to allow to stop it.
+	 * After sk_change_net should be released using sk_release_kernel.
+	 */
+	sk_change_net(sock->sk, net);
 	/* it is equivalent to the REUSEADDR option in user-space */
 	sock->sk->sk_reuse = 1;
 
@@ -1377,8 +1387,8 @@ static struct socket *make_receive_sock(struct net *net)
 
 	return sock;
 
-  error:
-	sock_release(sock);
+error:
+	sk_release_kernel(sock->sk);
 	return ERR_PTR(result);
 }
 
@@ -1473,7 +1483,7 @@ static int sync_thread_master(void *data)
 		ip_vs_sync_buff_release(sb);
 
 	/* release the sending multicast socket */
-	sock_release(tinfo->sock);
+	sk_release_kernel(tinfo->sock->sk);
 	kfree(tinfo);
 
 	return 0;
@@ -1513,7 +1523,7 @@ static int sync_thread_backup(void *data)
 	}
 
 	/* release the sending multicast socket */
-	sock_release(tinfo->sock);
+	sk_release_kernel(tinfo->sock->sk);
 	kfree(tinfo->buf);
 	kfree(tinfo);
 
@@ -1601,7 +1611,7 @@ outtinfo:
 outbuf:
 	kfree(buf);
 outsocket:
-	sock_release(sock);
+	sk_release_kernel(sock->sk);
 out:
 	return result;
 }
@@ -1610,6 +1620,7 @@ out:
 int stop_sync_thread(struct net *net, int state)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
+	int retc = -EINVAL;
 
 	IP_VS_DBG(7, "%s(): pid %d\n", __func__, task_pid_nr(current));
 
@@ -1629,7 +1640,7 @@ int stop_sync_thread(struct net *net, int state)
 		spin_lock_bh(&ipvs->sync_lock);
 		ipvs->sync_state &= ~IP_VS_STATE_MASTER;
 		spin_unlock_bh(&ipvs->sync_lock);
-		kthread_stop(ipvs->master_thread);
+		retc = kthread_stop(ipvs->master_thread);
 		ipvs->master_thread = NULL;
 	} else if (state == IP_VS_STATE_BACKUP) {
 		if (!ipvs->backup_thread)
@@ -1639,16 +1650,14 @@ int stop_sync_thread(struct net *net, int state)
 			task_pid_nr(ipvs->backup_thread));
 
 		ipvs->sync_state &= ~IP_VS_STATE_BACKUP;
-		kthread_stop(ipvs->backup_thread);
+		retc = kthread_stop(ipvs->backup_thread);
 		ipvs->backup_thread = NULL;
-	} else {
-		return -EINVAL;
 	}
 
 	/* decrease the module use count */
 	ip_vs_use_count_dec();
 
-	return 0;
+	return retc;
 }
 
 /*
@@ -1670,8 +1679,15 @@ static int __net_init __ip_vs_sync_init(struct net *net)
 
 static void __ip_vs_sync_cleanup(struct net *net)
 {
-	stop_sync_thread(net, IP_VS_STATE_MASTER);
-	stop_sync_thread(net, IP_VS_STATE_BACKUP);
+	int retc;
+
+	retc = stop_sync_thread(net, IP_VS_STATE_MASTER);
+	if (retc && retc != -ESRCH)
+		pr_err("Failed to stop Master Daemon\n");
+
+	retc = stop_sync_thread(net, IP_VS_STATE_BACKUP);
+	if (retc && retc != -ESRCH)
+		pr_err("Failed to stop Backup Daemon\n");
 }
 
 static struct pernet_operations ipvs_sync_ops = {
@@ -1682,10 +1698,10 @@ static struct pernet_operations ipvs_sync_ops = {
 
 int __init ip_vs_sync_init(void)
 {
-	return register_pernet_subsys(&ipvs_sync_ops);
+	return register_pernet_device(&ipvs_sync_ops);
 }
 
 void ip_vs_sync_cleanup(void)
 {
-	unregister_pernet_subsys(&ipvs_sync_ops);
+	unregister_pernet_device(&ipvs_sync_ops);
 }
-- 
1.7.2.3

