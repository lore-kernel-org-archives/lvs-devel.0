From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 25/84] ipvs: Pass ipvs not net to ip_vs_set_timeout
Date: Thu, 24 Sep 2015 09:52:10 +0900
Message-ID: <1443055989-1306-26-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
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
2.1.4

