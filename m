From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 32/84] ipvs: Pass ipvs not net to ip_vs_genl_del_daemon
Date: Mon, 21 Sep 2015 13:02:09 -0500
Message-ID: <1442858581-15869-32-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 847ea2fd44db..08d772c289d7 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3439,16 +3439,15 @@ static int ip_vs_genl_new_daemon(struct netns_ipvs *ipvs, struct nlattr **attrs)
 	return ret;
 }
 
-static int ip_vs_genl_del_daemon(struct net *net, struct nlattr **attrs)
+static int ip_vs_genl_del_daemon(struct netns_ipvs *ipvs, struct nlattr **attrs)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	int ret;
 
 	if (!attrs[IPVS_DAEMON_ATTR_STATE])
 		return -EINVAL;
 
 	mutex_lock(&ipvs->sync_mutex);
-	ret = stop_sync_thread(net,
+	ret = stop_sync_thread(ipvs->net,
 			       nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]));
 	mutex_unlock(&ipvs->sync_mutex);
 	return ret;
@@ -3496,7 +3495,7 @@ static int ip_vs_genl_set_daemon(struct sk_buff *skb, struct genl_info *info)
 		if (cmd == IPVS_CMD_NEW_DAEMON)
 			ret = ip_vs_genl_new_daemon(ipvs, daemon_attrs);
 		else
-			ret = ip_vs_genl_del_daemon(net, daemon_attrs);
+			ret = ip_vs_genl_del_daemon(ipvs, daemon_attrs);
 	}
 
 out:
-- 
2.2.1
