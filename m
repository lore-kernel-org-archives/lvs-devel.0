From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 22/84] ipvs: Pass ipvs not net to ip_vs_zero_all
Date: Thu, 24 Sep 2015 09:52:07 +0900
Message-ID: <1443055989-1306-23-git-send-email-horms@verge.net.au>
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
 net/netfilter/ipvs/ip_vs_ctl.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index a281961a1840..0b7749ae1e8d 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1576,9 +1576,8 @@ static int ip_vs_zero_service(struct ip_vs_service *svc)
 	return 0;
 }
 
-static int ip_vs_zero_all(struct net *net)
+static int ip_vs_zero_all(struct netns_ipvs *ipvs)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	int idx;
 	struct ip_vs_service *svc;
 
@@ -2384,7 +2383,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 	if (cmd == IP_VS_SO_SET_ZERO) {
 		/* if no service address is set, zero counters in all */
 		if (!usvc.fwmark && !usvc.addr.ip && !usvc.port) {
-			ret = ip_vs_zero_all(net);
+			ret = ip_vs_zero_all(ipvs);
 			goto out_unlock;
 		}
 	}
@@ -3530,7 +3529,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 		goto out;
 	} else if (cmd == IPVS_CMD_ZERO &&
 		   !info->attrs[IPVS_CMD_ATTR_SERVICE]) {
-		ret = ip_vs_zero_all(net);
+		ret = ip_vs_zero_all(ipvs);
 		goto out;
 	}
 
-- 
2.1.4

