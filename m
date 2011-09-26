From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 4/4] IPVS: Removed unused variables
Date: Mon, 26 Sep 2011 10:23:53 +0900
Message-ID: <1317000233-11169-5-git-send-email-horms@verge.net.au>
References: <1317000233-11169-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1317000233-11169-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

ipvs is not used in ip_vs_genl_set_cmd() or ip_vs_genl_get_cmd()

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 36f4495..f10a903 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3194,10 +3194,8 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 	int ret = 0, cmd;
 	int need_full_svc = 0, need_full_dest = 0;
 	struct net *net;
-	struct netns_ipvs *ipvs;
 
 	net = skb_sknet(skb);
-	ipvs = net_ipvs(net);
 	cmd = info->genlhdr->cmd;
 
 	mutex_lock(&__ip_vs_mutex);
@@ -3307,10 +3305,8 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	void *reply;
 	int ret, cmd, reply_cmd;
 	struct net *net;
-	struct netns_ipvs *ipvs;
 
 	net = skb_sknet(skb);
-	ipvs = net_ipvs(net);
 	cmd = info->genlhdr->cmd;
 
 	if (cmd == IPVS_CMD_GET_SERVICE)
-- 
1.7.5.4
