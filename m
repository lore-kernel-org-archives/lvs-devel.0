From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 83/84] ipvs: Remove skb_sknet
Date: Sun, 20 Sep 2015 01:23:39 -0500
Message-ID: <1442730220-32458-83-git-send-email-ebiederm@xmission.com>
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

This function adds no real value and it obscures what the code is doing.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip_vs.h            | 22 ----------------------
 net/netfilter/ipvs/ip_vs_ctl.c | 25 ++++++++++---------------
 2 files changed, 10 insertions(+), 37 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index d621330d423c..0816c872b689 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -38,28 +38,6 @@ static inline struct netns_ipvs *net_ipvs(struct net* net)
 	return net->ipvs;
 }
 
-static inline struct net *skb_sknet(const struct sk_buff *skb)
-{
-#ifdef CONFIG_NET_NS
-#ifdef CONFIG_IP_VS_DEBUG
-	/* Start with the most likely hit */
-	if (likely(skb->sk && sock_net(skb->sk)))
-		return sock_net(skb->sk);
-	WARN(skb->dev, "Maybe skb_net should be used instead in %s() line:%d\n",
-		       __func__, __LINE__);
-	if (likely(skb->dev && dev_net(skb->dev)))
-		return dev_net(skb->dev);
-	pr_err("There is no net ptr to find in the skb in %s() line:%d\n",
-		__func__, __LINE__);
-	BUG();
-#else
-	return sock_net(skb->sk);
-#endif
-#else
-	return &init_net;
-#endif
-}
-
 /* This one needed for single_open_net since net is stored directly in
  * private not as a struct i.e. seq_file_net can't be used.
  */
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c71c4cbbf3b6..f7386d5b231c 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3002,7 +3002,8 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 	int idx = 0, i;
 	int start = cb->args[0];
 	struct ip_vs_service *svc;
-	struct netns_ipvs *ipvs = net_ipvs(skb_sknet(skb));
+	struct net *net = sock_net(skb->sk);
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	mutex_lock(&__ip_vs_mutex);
 	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
@@ -3201,7 +3202,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 	struct ip_vs_service *svc;
 	struct ip_vs_dest *dest;
 	struct nlattr *attrs[IPVS_CMD_ATTR_MAX + 1];
-	struct net *net = skb_sknet(skb);
+	struct net *net = sock_net(skb->sk);
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	mutex_lock(&__ip_vs_mutex);
@@ -3348,7 +3349,7 @@ nla_put_failure:
 static int ip_vs_genl_dump_daemons(struct sk_buff *skb,
 				   struct netlink_callback *cb)
 {
-	struct net *net = skb_sknet(skb);
+	struct net *net = sock_net(skb->sk);
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	mutex_lock(&ipvs->sync_mutex);
@@ -3475,11 +3476,9 @@ static int ip_vs_genl_set_config(struct netns_ipvs *ipvs, struct nlattr **attrs)
 static int ip_vs_genl_set_daemon(struct sk_buff *skb, struct genl_info *info)
 {
 	int ret = -EINVAL, cmd;
-	struct net *net;
-	struct netns_ipvs *ipvs;
+	struct net *net = sock_net(skb->sk);
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	net = skb_sknet(skb);
-	ipvs = net_ipvs(net);
 	cmd = info->genlhdr->cmd;
 
 	if (cmd == IPVS_CMD_NEW_DAEMON || cmd == IPVS_CMD_DEL_DAEMON) {
@@ -3508,11 +3507,9 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 	struct ip_vs_dest_user_kern udest;
 	int ret = 0, cmd;
 	int need_full_svc = 0, need_full_dest = 0;
-	struct net *net;
-	struct netns_ipvs *ipvs;
+	struct net *net = sock_net(skb->sk);
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	net = skb_sknet(skb);
-	ipvs = net_ipvs(net);
 	cmd = info->genlhdr->cmd;
 
 	mutex_lock(&__ip_vs_mutex);
@@ -3632,11 +3629,9 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	struct sk_buff *msg;
 	void *reply;
 	int ret, cmd, reply_cmd;
-	struct net *net;
-	struct netns_ipvs *ipvs;
+	struct net *net = sock_net(skb->sk);
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	net = skb_sknet(skb);
-	ipvs = net_ipvs(net);
 	cmd = info->genlhdr->cmd;
 
 	if (cmd == IPVS_CMD_GET_SERVICE)
-- 
2.2.1

