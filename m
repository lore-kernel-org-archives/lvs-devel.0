From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 22/84] ipvs: Pass ipvs not net to ip_vs_zero_all
Date: Sun, 20 Sep 2015 01:22:38 -0500
Message-ID: <1442730220-32458-22-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index d3407ad866bb..591f528e4ed6 100644
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
2.2.1

