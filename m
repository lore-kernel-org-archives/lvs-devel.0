From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 34/84] ipvs: Pass ipvs not net to stop_sync_thread
Date: Sun, 20 Sep 2015 01:22:50 -0500
Message-ID: <1442730220-32458-34-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip_vs.h             | 2 +-
 net/netfilter/ipvs/ip_vs_ctl.c  | 4 ++--
 net/netfilter/ipvs/ip_vs_sync.c | 7 +++----
 3 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index dd7cd3a48fd4..71f4d338c208 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1451,7 +1451,7 @@ static inline void ip_vs_dest_put_and_free(struct ip_vs_dest *dest)
  */
 int start_sync_thread(struct netns_ipvs *ipvs, struct ipvs_sync_daemon_cfg *cfg,
 		      int state);
-int stop_sync_thread(struct net *net, int state);
+int stop_sync_thread(struct netns_ipvs *ipvs, int state);
 void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp, int pkts);
 
 /* IPVS rate estimator prototypes (from ip_vs_est.c) */
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 07106bfe2ac4..85a2f2699a18 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2355,7 +2355,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 			rtnl_unlock();
 		} else {
 			mutex_lock(&ipvs->sync_mutex);
-			ret = stop_sync_thread(net, dm->state);
+			ret = stop_sync_thread(ipvs, dm->state);
 			mutex_unlock(&ipvs->sync_mutex);
 		}
 		goto out_dec;
@@ -3447,7 +3447,7 @@ static int ip_vs_genl_del_daemon(struct netns_ipvs *ipvs, struct nlattr **attrs)
 		return -EINVAL;
 
 	mutex_lock(&ipvs->sync_mutex);
-	ret = stop_sync_thread(ipvs->net,
+	ret = stop_sync_thread(ipvs,
 			       nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]));
 	mutex_unlock(&ipvs->sync_mutex);
 	return ret;
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 90c455c0b42b..0b2e01aa764a 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1946,9 +1946,8 @@ out:
 }
 
 
-int stop_sync_thread(struct net *net, int state)
+int stop_sync_thread(struct netns_ipvs *ipvs, int state)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct task_struct **array;
 	int id;
 	int retc = -EINVAL;
@@ -2030,11 +2029,11 @@ void ip_vs_sync_net_cleanup(struct net *net)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	mutex_lock(&ipvs->sync_mutex);
-	retc = stop_sync_thread(net, IP_VS_STATE_MASTER);
+	retc = stop_sync_thread(ipvs, IP_VS_STATE_MASTER);
 	if (retc && retc != -ESRCH)
 		pr_err("Failed to stop Master Daemon\n");
 
-	retc = stop_sync_thread(net, IP_VS_STATE_BACKUP);
+	retc = stop_sync_thread(ipvs, IP_VS_STATE_BACKUP);
 	if (retc && retc != -ESRCH)
 		pr_err("Failed to stop Backup Daemon\n");
 	mutex_unlock(&ipvs->sync_mutex);
-- 
2.2.1

