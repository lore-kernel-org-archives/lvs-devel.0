From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [net-next 2/2] ipvs: batch __ip_vs_dev_cleanup
Date: Sat, 13 Jul 2019 23:19:46 +0800
Message-ID: <1563031186-2101-3-git-send-email-yanhaishuang@cmss.chinamobile.com>
References: <1563031186-2101-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1563031186-2101-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, Pablo Neira Ayuso <pablo@netfilter.org>, Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

It's better to batch __ip_vs_cleanup to speedup ipvs
devices dismantle.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index b4d79b7..58af24a 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2434,14 +2434,20 @@ static int __net_init __ip_vs_dev_init(struct net *net)
 	return ret;
 }
 
-static void __net_exit __ip_vs_dev_cleanup(struct net *net)
+static void __net_exit __ip_vs_dev_cleanup_batch(struct list_head *net_list)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct netns_ipvs *ipvs;
+	struct net *net;
+	LIST_HEAD(list);
+
 	EnterFunction(2);
-	nf_unregister_net_hooks(net, ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
-	ipvs->enable = 0;	/* Disable packet reception */
-	smp_wmb();
-	ip_vs_sync_net_cleanup(ipvs);
+	list_for_each_entry(net, net_list, exit_list) {
+		ipvs = net_ipvs(net);
+		nf_unregister_net_hooks(net, ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
+		ipvs->enable = 0;	/* Disable packet reception */
+		smp_wmb();
+		ip_vs_sync_net_cleanup(ipvs);
+	}
 	LeaveFunction(2);
 }
 
@@ -2454,7 +2460,7 @@ static void __net_exit __ip_vs_dev_cleanup(struct net *net)
 
 static struct pernet_operations ipvs_core_dev_ops = {
 	.init = __ip_vs_dev_init,
-	.exit = __ip_vs_dev_cleanup,
+	.exit_batch = __ip_vs_dev_cleanup_batch,
 };
 
 /*
-- 
1.8.3.1



