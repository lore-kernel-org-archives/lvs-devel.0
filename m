From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 30/84] ipvs: Pass ipvs not net to ip_vs_genl_find_service
Date: Thu, 24 Sep 2015 09:52:15 +0900
Message-ID: <1443055989-1306-31-git-send-email-horms@verge.net.au>
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
index ea650ed62a50..01c3a1a75d16 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3119,10 +3119,9 @@ static int ip_vs_genl_parse_service(struct netns_ipvs *ipvs,
 	return 0;
 }
 
-static struct ip_vs_service *ip_vs_genl_find_service(struct net *net,
+static struct ip_vs_service *ip_vs_genl_find_service(struct netns_ipvs *ipvs,
 						     struct nlattr *nla)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_service_user_kern usvc;
 	struct ip_vs_service *svc;
 	int ret;
@@ -3203,6 +3202,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 	struct ip_vs_dest *dest;
 	struct nlattr *attrs[IPVS_CMD_ATTR_MAX + 1];
 	struct net *net = skb_sknet(skb);
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	mutex_lock(&__ip_vs_mutex);
 
@@ -3212,7 +3212,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 		goto out_err;
 
 
-	svc = ip_vs_genl_find_service(net, attrs[IPVS_CMD_ATTR_SERVICE]);
+	svc = ip_vs_genl_find_service(ipvs, attrs[IPVS_CMD_ATTR_SERVICE]);
 	if (IS_ERR(svc) || svc == NULL)
 		goto out_err;
 
@@ -3668,7 +3668,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	{
 		struct ip_vs_service *svc;
 
-		svc = ip_vs_genl_find_service(net,
+		svc = ip_vs_genl_find_service(ipvs,
 					      info->attrs[IPVS_CMD_ATTR_SERVICE]);
 		if (IS_ERR(svc)) {
 			ret = PTR_ERR(svc);
-- 
2.1.4
