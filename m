From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 45/84] ipvs: Pass ipvs not net to ip_vs_genl_set_config
Date: Thu, 24 Sep 2015 09:52:30 +0900
Message-ID: <1443055989-1306-46-git-send-email-horms@verge.net.au>
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
 net/netfilter/ipvs/ip_vs_ctl.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index dba75ec2ed53..4042a6f449cb 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3453,9 +3453,8 @@ static int ip_vs_genl_del_daemon(struct netns_ipvs *ipvs, struct nlattr **attrs)
 	return ret;
 }
 
-static int ip_vs_genl_set_config(struct net *net, struct nlattr **attrs)
+static int ip_vs_genl_set_config(struct netns_ipvs *ipvs, struct nlattr **attrs)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_timeout_user t;
 
 	__ip_vs_get_timeouts(ipvs, &t);
@@ -3522,7 +3521,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 		ret = ip_vs_flush(ipvs, false);
 		goto out;
 	} else if (cmd == IPVS_CMD_SET_CONFIG) {
-		ret = ip_vs_genl_set_config(net, info->attrs);
+		ret = ip_vs_genl_set_config(ipvs, info->attrs);
 		goto out;
 	} else if (cmd == IPVS_CMD_ZERO &&
 		   !info->attrs[IPVS_CMD_ATTR_SERVICE]) {
-- 
2.1.4
