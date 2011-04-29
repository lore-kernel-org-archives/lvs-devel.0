From: Hans Schillstrom <hans@schillstrom.com>
Subject: [v3 PATCH 6/6] IPVS: add debug functions
Date: Fri, 29 Apr 2011 08:25:34 +0200
Message-ID: <1304058334-17594-7-git-send-email-hans@schillstrom.com>
References: <1304058334-17594-1-git-send-email-hans@schillstrom.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1304058334-17594-1-git-send-email-hans@schillstrom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ja@ssi.bg, horms@verge.net.au, ebiederm@xmission.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans.schillstrom@ericsson.com, Hans Schillstrom <hans@schillstrom.com>

Optional patch, but it is nice to have.

Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 64df5bf..aaa5dd4 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -351,8 +351,11 @@ static int ip_vs_svc_unhash(struct ip_vs_service *svc)
 	svc->flags &= ~IP_VS_SVC_F_HASHED;
 	atomic_dec(&svc->refcnt);
 	/* No more services, no need for input */
-	if (atomic_read(&svc->refcnt) == 0)
+	if (atomic_read(&svc->refcnt) == 0) {
 		net_ipvs(svc->net)->enable = 0;
+		IP_VS_DBG(2, "Last service removed in net(%d) input disabled\n",
+			     net_ipvs(svc->net)->gen);
+	}
 	return 1;
 }
 
@@ -1222,6 +1225,10 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 	write_unlock_bh(&__ip_vs_svc_lock);
 
 	*svc_p = svc;
+	if (!ipvs->enable)
+		pr_info("netns(%d) enabled first service added\n",
+			 ipvs->gen);
+
 	/* Now there is a service - full throttle */
 	ipvs->enable = 1;
 	return 0;
@@ -3693,6 +3700,7 @@ int __net_init ip_vs_control_net_init(struct net *net)
 	int idx;
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
+	EnterFunction(2);
 	ipvs->rs_lock = __RW_LOCK_UNLOCKED(ipvs->rs_lock);
 
 	/* Initialize rs_table */
@@ -3719,6 +3727,7 @@ int __net_init ip_vs_control_net_init(struct net *net)
 	if (ip_vs_control_net_init_sysctl(net))
 		goto err;
 
+	LeaveFunction(2);
 	return 0;
 
 err:
@@ -3730,6 +3739,7 @@ void __net_exit ip_vs_control_net_cleanup(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
+	EnterFunction(2);
 	ip_vs_trash_cleanup(net);
 	ip_vs_stop_estimator(net, &ipvs->tot_stats);
 	ip_vs_control_net_cleanup_sysctl(net);
@@ -3737,6 +3747,7 @@ void __net_exit ip_vs_control_net_cleanup(struct net *net)
 	proc_net_remove(net, "ip_vs_stats");
 	proc_net_remove(net, "ip_vs");
 	free_percpu(ipvs->tot_stats.cpustats);
+	LeaveFunction(2);
 }
 
 int __init ip_vs_control_init(void)
-- 
1.7.4

