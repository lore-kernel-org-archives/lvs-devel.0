From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] ipvs: stop tot_stats estimator only under CONFIG_SYSCTL
Date: Fri, 13 Jun 2014 16:37:09 +0900
Message-ID: <1402645029-21756-2-git-send-email-horms@verge.net.au>
References: <1402645029-21756-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1402645029-21756-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

The tot_stats estimator is started only when CONFIG_SYSCTL
is defined. But it is stopped without checking CONFIG_SYSCTL.
Fix the crash by moving ip_vs_stop_estimator into
ip_vs_control_net_cleanup_sysctl.

The change is needed after commit 14e405461e664b
("IPVS: Add __ip_vs_control_{init,cleanup}_sysctl()") from 2.6.39.

Reported-by: Jet Chen <jet.chen@intel.com>
Tested-by: Jet Chen <jet.chen@intel.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c42e83d..581a658 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3778,6 +3778,7 @@ static void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
 	cancel_delayed_work_sync(&ipvs->defense_work);
 	cancel_work_sync(&ipvs->defense_work.work);
 	unregister_net_sysctl_table(ipvs->sysctl_hdr);
+	ip_vs_stop_estimator(net, &ipvs->tot_stats);
 }
 
 #else
@@ -3840,7 +3841,6 @@ void __net_exit ip_vs_control_net_cleanup(struct net *net)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	ip_vs_trash_cleanup(net);
-	ip_vs_stop_estimator(net, &ipvs->tot_stats);
 	ip_vs_control_net_cleanup_sysctl(net);
 	remove_proc_entry("ip_vs_stats_percpu", net->proc_net);
 	remove_proc_entry("ip_vs_stats", net->proc_net);
-- 
2.0.0.rc2
