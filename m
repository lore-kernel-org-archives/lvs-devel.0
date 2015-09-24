From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 31/84] ipvs: Pass ipvs not net to ip_vs_genl_new_daemon
Date: Thu, 24 Sep 2015 09:52:16 +0900
Message-ID: <1443055989-1306-32-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
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
 net/netfilter/ipvs/ip_vs_ctl.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 01c3a1a75d16..847ea2fd44db 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3374,9 +3374,8 @@ nla_put_failure:
 	return skb->len;
 }
 
-static int ip_vs_genl_new_daemon(struct net *net, struct nlattr **attrs)
+static int ip_vs_genl_new_daemon(struct netns_ipvs *ipvs, struct nlattr **attrs)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ipvs_sync_daemon_cfg c;
 	struct nlattr *a;
 	int ret;
@@ -3433,7 +3432,7 @@ static int ip_vs_genl_new_daemon(struct net *net, struct nlattr **attrs)
 
 	rtnl_lock();
 	mutex_lock(&ipvs->sync_mutex);
-	ret = start_sync_thread(net, &c,
+	ret = start_sync_thread(ipvs->net, &c,
 				nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]));
 	mutex_unlock(&ipvs->sync_mutex);
 	rtnl_unlock();
@@ -3495,7 +3494,7 @@ static int ip_vs_genl_set_daemon(struct sk_buff *skb, struct genl_info *info)
 			goto out;
 
 		if (cmd == IPVS_CMD_NEW_DAEMON)
-			ret = ip_vs_genl_new_daemon(net, daemon_attrs);
+			ret = ip_vs_genl_new_daemon(ipvs, daemon_attrs);
 		else
 			ret = ip_vs_genl_del_daemon(net, daemon_attrs);
 	}
-- 
2.1.4

