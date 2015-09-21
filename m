From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 25/84] ipvs: Pass ipvs not net to ip_vs_set_timeout
Date: Mon, 21 Sep 2015 13:02:02 -0500
Message-ID: <1442858581-15869-25-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index eb3911c69037..7aba55c875cb 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2202,10 +2202,9 @@ static const struct file_operations ip_vs_stats_percpu_fops = {
 /*
  *	Set timeout values for tcp tcpfin udp in the timeout_table.
  */
-static int ip_vs_set_timeout(struct net *net, struct ip_vs_timeout_user *u)
+static int ip_vs_set_timeout(struct netns_ipvs *ipvs, struct ip_vs_timeout_user *u)
 {
 #if defined(CONFIG_IP_VS_PROTO_TCP) || defined(CONFIG_IP_VS_PROTO_UDP)
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_proto_data *pd;
 #endif
 
@@ -2369,7 +2368,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		goto out_unlock;
 	} else if (cmd == IP_VS_SO_SET_TIMEOUT) {
 		/* Set timeout values for (tcp tcpfin udp) */
-		ret = ip_vs_set_timeout(net, (struct ip_vs_timeout_user *)arg);
+		ret = ip_vs_set_timeout(ipvs, (struct ip_vs_timeout_user *)arg);
 		goto out_unlock;
 	}
 
@@ -3461,6 +3460,7 @@ static int ip_vs_genl_del_daemon(struct net *net, struct nlattr **attrs)
 
 static int ip_vs_genl_set_config(struct net *net, struct nlattr **attrs)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_timeout_user t;
 
 	__ip_vs_get_timeouts(net, &t);
@@ -3475,7 +3475,7 @@ static int ip_vs_genl_set_config(struct net *net, struct nlattr **attrs)
 	if (attrs[IPVS_CMD_ATTR_TIMEOUT_UDP])
 		t.udp_timeout = nla_get_u32(attrs[IPVS_CMD_ATTR_TIMEOUT_UDP]);
 
-	return ip_vs_set_timeout(net, &t);
+	return ip_vs_set_timeout(ipvs, &t);
 }
 
 static int ip_vs_genl_set_daemon(struct sk_buff *skb, struct genl_info *info)
-- 
2.2.1

