From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 33/84] ipvs: Pass ipvs not net to start_sync_thread
Date: Thu, 24 Sep 2015 09:52:18 +0900
Message-ID: <1443055989-1306-34-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |  2 +-
 net/netfilter/ipvs/ip_vs_ctl.c  |  4 ++--
 net/netfilter/ipvs/ip_vs_sync.c | 11 +++++------
 3 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 3c077e8a038c..dd7cd3a48fd4 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1449,7 +1449,7 @@ static inline void ip_vs_dest_put_and_free(struct ip_vs_dest *dest)
 /* IPVS sync daemon data and function prototypes
  * (from ip_vs_sync.c)
  */
-int start_sync_thread(struct net *net, struct ipvs_sync_daemon_cfg *cfg,
+int start_sync_thread(struct netns_ipvs *ipvs, struct ipvs_sync_daemon_cfg *cfg,
 		      int state);
 int stop_sync_thread(struct net *net, int state);
 void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp, int pkts);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 08d772c289d7..b63b4c186040 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2350,7 +2350,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 			cfg.syncid = dm->syncid;
 			rtnl_lock();
 			mutex_lock(&ipvs->sync_mutex);
-			ret = start_sync_thread(net, &cfg, dm->state);
+			ret = start_sync_thread(ipvs, &cfg, dm->state);
 			mutex_unlock(&ipvs->sync_mutex);
 			rtnl_unlock();
 		} else {
@@ -3432,7 +3432,7 @@ static int ip_vs_genl_new_daemon(struct netns_ipvs *ipvs, struct nlattr **attrs)
 
 	rtnl_lock();
 	mutex_lock(&ipvs->sync_mutex);
-	ret = start_sync_thread(ipvs->net, &c,
+	ret = start_sync_thread(ipvs, &c,
 				nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]));
 	mutex_unlock(&ipvs->sync_mutex);
 	rtnl_unlock();
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index d158e0713ab9..90c455c0b42b 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1778,13 +1778,12 @@ static int sync_thread_backup(void *data)
 }
 
 
-int start_sync_thread(struct net *net, struct ipvs_sync_daemon_cfg *c,
+int start_sync_thread(struct netns_ipvs *ipvs, struct ipvs_sync_daemon_cfg *c,
 		      int state)
 {
 	struct ip_vs_sync_thread_data *tinfo;
 	struct task_struct **array = NULL, *task;
 	struct socket *sock;
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct net_device *dev;
 	char *name;
 	int (*threadfn)(void *data);
@@ -1811,7 +1810,7 @@ int start_sync_thread(struct net *net, struct ipvs_sync_daemon_cfg *c,
 	if (!c->mcast_ttl)
 		c->mcast_ttl = 1;
 
-	dev = __dev_get_by_name(net, c->mcast_ifn);
+	dev = __dev_get_by_name(ipvs->net, c->mcast_ifn);
 	if (!dev) {
 		pr_err("Unknown mcast interface: %s\n", c->mcast_ifn);
 		return -ENODEV;
@@ -1873,9 +1872,9 @@ int start_sync_thread(struct net *net, struct ipvs_sync_daemon_cfg *c,
 	tinfo = NULL;
 	for (id = 0; id < count; id++) {
 		if (state == IP_VS_STATE_MASTER)
-			sock = make_send_sock(net, id);
+			sock = make_send_sock(ipvs->net, id);
 		else
-			sock = make_receive_sock(net, id);
+			sock = make_receive_sock(ipvs->net, id);
 		if (IS_ERR(sock)) {
 			result = PTR_ERR(sock);
 			goto outtinfo;
@@ -1883,7 +1882,7 @@ int start_sync_thread(struct net *net, struct ipvs_sync_daemon_cfg *c,
 		tinfo = kmalloc(sizeof(*tinfo), GFP_KERNEL);
 		if (!tinfo)
 			goto outsocket;
-		tinfo->net = net;
+		tinfo->net = ipvs->net;
 		tinfo->sock = sock;
 		if (state == IP_VS_STATE_BACKUP) {
 			tinfo->buf = kmalloc(ipvs->bcfg.sync_maxlen,
-- 
2.1.4
