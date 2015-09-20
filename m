From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 30/84] ipvs: Pass ipvs not net to ip_vs_genl_find_service
Date: Sun, 20 Sep 2015 01:22:46 -0500
Message-ID: <1442730220-32458-30-git-send-email-ebiederm@xmission.com>
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
 net/netfilter/ipvs/ip_vs_ctl.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 1e3fc8962627..9dab372ceedb 100644
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
2.2.1

