From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 48/84] ipvs: Pass ipvs not net to ip_vs_control_net_(init|cleanup)_sysctl
Date: Thu, 24 Sep 2015 09:52:33 +0900
Message-ID: <1443055989-1306-49-git-send-email-horms@verge.net.au>
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
 net/netfilter/ipvs/ip_vs_ctl.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 93b7bd39bcb9..f0d72d6375e7 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3841,10 +3841,10 @@ static void ip_vs_genl_unregister(void)
  * per netns intit/exit func.
  */
 #ifdef CONFIG_SYSCTL
-static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
+static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 {
+	struct net *net = ipvs->net;
 	int idx;
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ctl_table *tbl;
 
 	atomic_set(&ipvs->dropentry, 0);
@@ -3926,9 +3926,9 @@ static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	return 0;
 }
 
-static void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
+static void __net_exit ip_vs_control_net_cleanup_sysctl(struct netns_ipvs *ipvs)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct net *net = ipvs->net;
 
 	cancel_delayed_work_sync(&ipvs->defense_work);
 	cancel_work_sync(&ipvs->defense_work.work);
@@ -3941,8 +3941,8 @@ static void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
 
 #else
 
-static int __net_init ip_vs_control_net_init_sysctl(struct net *net) { return 0; }
-static void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net) { }
+static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs) { return 0; }
+static void __net_exit ip_vs_control_net_cleanup_sysctl(struct netns_ipvs *ipvs) { }
 
 #endif
 
@@ -3984,7 +3984,7 @@ int __net_init ip_vs_control_net_init(struct net *net)
 	proc_create("ip_vs_stats_percpu", 0, net->proc_net,
 		    &ip_vs_stats_percpu_fops);
 
-	if (ip_vs_control_net_init_sysctl(net))
+	if (ip_vs_control_net_init_sysctl(ipvs))
 		goto err;
 
 	return 0;
@@ -3999,7 +3999,7 @@ void __net_exit ip_vs_control_net_cleanup(struct net *net)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	ip_vs_trash_cleanup(ipvs);
-	ip_vs_control_net_cleanup_sysctl(net);
+	ip_vs_control_net_cleanup_sysctl(ipvs);
 	remove_proc_entry("ip_vs_stats_percpu", net->proc_net);
 	remove_proc_entry("ip_vs_stats", net->proc_net);
 	remove_proc_entry("ip_vs", net->proc_net);
-- 
2.1.4
