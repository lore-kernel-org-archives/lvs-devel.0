From: Hans Schillstrom <hans@schillstrom.com>
Subject: [PATCH 1/3] IPVS: Change of socket usage to enable name space exit.
Date: Tue, 19 Apr 2011 17:25:03 +0200
Message-ID: <1303226705-29178-1-git-send-email-hans@schillstrom.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, ebiederm@xmission.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans.schillstrom@ericsson.com, Hans Schillstrom <hans@schillstrom.com>

This is the first patch in a series of three.
The cleanup doesn't work when not exit in a clean way by using ipvsadm.
Killing of a namespace causes a hanging ipvs, this series will cure that.

If the sync daemons run in a namespace while it crashes
or get killed, there is no way to stop them except for a reboot.

Kernel threads should not increment the use count of a socket.
By calling sk_change_net() after creating a socket this is avoided.
sock_release cant be used, instead sk_release_kernel() should be used.

Thanks to Eric W Biederman.

This patch is based on net-next-2.6  ver 2.6.39-rc2

Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
---
 net/netfilter/ipvs/ip_vs_sync.c |   28 +++++++++++++++++++---------
 1 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 3e7961e..3f87555 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1309,7 +1309,12 @@ static struct socket *make_send_sock(struct net *net)
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

@@ -1355,7 +1360,12 @@ static struct socket *make_receive_sock(struct net *net)
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
--
1.7.2.3

