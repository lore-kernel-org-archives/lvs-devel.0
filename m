From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/4 nf-next] ipvs: call rtnl_lock early
Date: Fri, 21 Aug 2015 09:23:40 -0700
Message-ID: <1440174222-12695-3-git-send-email-horms@verge.net.au>
References: <1440174222-12695-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1440174222-12695-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

When the sync damon is started we need to hold rtnl
lock while calling ip_mc_join_group. Currently, we have
a wrong locking order because the correct one is
rtnl_lock->__ip_vs_mutex. It is implied from the usage
of __ip_vs_mutex in ip_vs_dst_event() which is called
under rtnl lock during NETDEV_* notifications.

Fix the problem by calling rtnl_lock early only for the
start_sync_thread call. As a bonus this fixes the usage
__dev_get_by_name which was not called under rtnl lock.

This patch actually extends and depends on commit 54ff9ef36bdf
("ipv4, ipv6: kill ip_mc_{join, leave}_group and
ipv6_sock_mc_{join, drop}").

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c  | 50 +++++++++++++++++++++++++++--------------
 net/netfilter/ipvs/ip_vs_sync.c |  2 --
 2 files changed, 33 insertions(+), 19 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 24c554201a76..af0b69e411b7 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2335,13 +2335,18 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 	    cmd == IP_VS_SO_SET_STOPDAEMON) {
 		struct ip_vs_daemon_user *dm = (struct ip_vs_daemon_user *)arg;
 
-		mutex_lock(&ipvs->sync_mutex);
-		if (cmd == IP_VS_SO_SET_STARTDAEMON)
+		if (cmd == IP_VS_SO_SET_STARTDAEMON) {
+			rtnl_lock();
+			mutex_lock(&ipvs->sync_mutex);
 			ret = start_sync_thread(net, dm->state, dm->mcast_ifn,
 						dm->syncid);
-		else
+			mutex_unlock(&ipvs->sync_mutex);
+			rtnl_unlock();
+		} else {
+			mutex_lock(&ipvs->sync_mutex);
 			ret = stop_sync_thread(net, dm->state);
-		mutex_unlock(&ipvs->sync_mutex);
+			mutex_unlock(&ipvs->sync_mutex);
+		}
 		goto out_dec;
 	}
 
@@ -3342,6 +3347,9 @@ nla_put_failure:
 
 static int ip_vs_genl_new_daemon(struct net *net, struct nlattr **attrs)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
+	int ret;
+
 	if (!(attrs[IPVS_DAEMON_ATTR_STATE] &&
 	      attrs[IPVS_DAEMON_ATTR_MCAST_IFN] &&
 	      attrs[IPVS_DAEMON_ATTR_SYNC_ID]))
@@ -3353,19 +3361,30 @@ static int ip_vs_genl_new_daemon(struct net *net, struct nlattr **attrs)
 	if (net_ipvs(net)->mixed_address_family_dests > 0)
 		return -EINVAL;
 
-	return start_sync_thread(net,
-				 nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]),
-				 nla_data(attrs[IPVS_DAEMON_ATTR_MCAST_IFN]),
-				 nla_get_u32(attrs[IPVS_DAEMON_ATTR_SYNC_ID]));
+	rtnl_lock();
+	mutex_lock(&ipvs->sync_mutex);
+	ret = start_sync_thread(net,
+				nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]),
+				nla_data(attrs[IPVS_DAEMON_ATTR_MCAST_IFN]),
+				nla_get_u32(attrs[IPVS_DAEMON_ATTR_SYNC_ID]));
+	mutex_unlock(&ipvs->sync_mutex);
+	rtnl_unlock();
+	return ret;
 }
 
 static int ip_vs_genl_del_daemon(struct net *net, struct nlattr **attrs)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
+	int ret;
+
 	if (!attrs[IPVS_DAEMON_ATTR_STATE])
 		return -EINVAL;
 
-	return stop_sync_thread(net,
-				nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]));
+	mutex_lock(&ipvs->sync_mutex);
+	ret = stop_sync_thread(net,
+			       nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]));
+	mutex_unlock(&ipvs->sync_mutex);
+	return ret;
 }
 
 static int ip_vs_genl_set_config(struct net *net, struct nlattr **attrs)
@@ -3389,7 +3408,7 @@ static int ip_vs_genl_set_config(struct net *net, struct nlattr **attrs)
 
 static int ip_vs_genl_set_daemon(struct sk_buff *skb, struct genl_info *info)
 {
-	int ret = 0, cmd;
+	int ret = -EINVAL, cmd;
 	struct net *net;
 	struct netns_ipvs *ipvs;
 
@@ -3400,22 +3419,19 @@ static int ip_vs_genl_set_daemon(struct sk_buff *skb, struct genl_info *info)
 	if (cmd == IPVS_CMD_NEW_DAEMON || cmd == IPVS_CMD_DEL_DAEMON) {
 		struct nlattr *daemon_attrs[IPVS_DAEMON_ATTR_MAX + 1];
 
-		mutex_lock(&ipvs->sync_mutex);
 		if (!info->attrs[IPVS_CMD_ATTR_DAEMON] ||
 		    nla_parse_nested(daemon_attrs, IPVS_DAEMON_ATTR_MAX,
 				     info->attrs[IPVS_CMD_ATTR_DAEMON],
-				     ip_vs_daemon_policy)) {
-			ret = -EINVAL;
+				     ip_vs_daemon_policy))
 			goto out;
-		}
 
 		if (cmd == IPVS_CMD_NEW_DAEMON)
 			ret = ip_vs_genl_new_daemon(net, daemon_attrs);
 		else
 			ret = ip_vs_genl_del_daemon(net, daemon_attrs);
-out:
-		mutex_unlock(&ipvs->sync_mutex);
 	}
+
+out:
 	return ret;
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index d99ad93eb855..6bc6dca9bca8 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1405,11 +1405,9 @@ join_mcast_group(struct sock *sk, struct in_addr *addr, char *ifname)
 
 	mreq.imr_ifindex = dev->ifindex;
 
-	rtnl_lock();
 	lock_sock(sk);
 	ret = ip_mc_join_group(sk, &mreq);
 	release_sock(sk);
-	rtnl_unlock();
 
 	return ret;
 }
-- 
2.1.4

