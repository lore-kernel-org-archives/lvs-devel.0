From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 29/84] ipvs: Pass ipvs not net to ip_vs_genl_parse_service
Date: Thu, 24 Sep 2015 09:52:14 +0900
Message-ID: <1443055989-1306-30-git-send-email-horms@verge.net.au>
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
 net/netfilter/ipvs/ip_vs_ctl.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index e509c27f7292..ea650ed62a50 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3034,12 +3034,11 @@ nla_put_failure:
 	return skb->len;
 }
 
-static int ip_vs_genl_parse_service(struct net *net,
+static int ip_vs_genl_parse_service(struct netns_ipvs *ipvs,
 				    struct ip_vs_service_user_kern *usvc,
 				    struct nlattr *nla, int full_entry,
 				    struct ip_vs_service **ret_svc)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct nlattr *attrs[IPVS_SVC_ATTR_MAX + 1];
 	struct nlattr *nla_af, *nla_port, *nla_fwmark, *nla_protocol, *nla_addr;
 	struct ip_vs_service *svc;
@@ -3123,11 +3122,12 @@ static int ip_vs_genl_parse_service(struct net *net,
 static struct ip_vs_service *ip_vs_genl_find_service(struct net *net,
 						     struct nlattr *nla)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_service_user_kern usvc;
 	struct ip_vs_service *svc;
 	int ret;
 
-	ret = ip_vs_genl_parse_service(net, &usvc, nla, 0, &svc);
+	ret = ip_vs_genl_parse_service(ipvs, &usvc, nla, 0, &svc);
 	return ret ? ERR_PTR(ret) : svc;
 }
 
@@ -3538,7 +3538,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 	if (cmd == IPVS_CMD_NEW_SERVICE || cmd == IPVS_CMD_SET_SERVICE)
 		need_full_svc = 1;
 
-	ret = ip_vs_genl_parse_service(net, &usvc,
+	ret = ip_vs_genl_parse_service(ipvs, &usvc,
 				       info->attrs[IPVS_CMD_ATTR_SERVICE],
 				       need_full_svc, &svc);
 	if (ret)
-- 
2.1.4
