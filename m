From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 18/22] IPVS: netns, defense work timer.
Date: Thu, 13 Jan 2011 10:53:04 +0900
Message-ID: <1294883588-5683-19-git-send-email-horms@verge.net.au>
References: <1294883588-5683-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1294883588-5683-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

This patch makes defense work timer per name-space,
A net ptr had to be added to the ipvs struct,
since it's needed by defense_work_handler.

[ horms@verge.net.au: Use cancel_delayed_work_sync() instead of
	              cancel_rearming_delayed_work(). Found during
		      merge conflict resoliution ]
Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |    2 +-
 include/net/netns/ip_vs.h       |    3 +++
 net/netfilter/ipvs/ip_vs_conn.c |    5 +++--
 net/netfilter/ipvs/ip_vs_core.c |    1 +
 net/netfilter/ipvs/ip_vs_ctl.c  |   20 +++++++++-----------
 5 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index af9acf4..fbe660f 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -877,7 +877,7 @@ extern const char * ip_vs_state_name(__u16 proto, int state);
 
 extern void ip_vs_tcp_conn_listen(struct net *net, struct ip_vs_conn *cp);
 extern int ip_vs_check_template(struct ip_vs_conn *ct);
-extern void ip_vs_random_dropentry(void);
+extern void ip_vs_random_dropentry(struct net *net);
 extern int ip_vs_conn_init(void);
 extern void ip_vs_conn_cleanup(void);
 
diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
index c4b1abf..4133261 100644
--- a/include/net/netns/ip_vs.h
+++ b/include/net/netns/ip_vs.h
@@ -71,6 +71,7 @@ struct netns_ipvs {
 
 	int			num_services;    /* no of virtual services */
 	/* 1/rate drop and drop-entry variables */
+	struct delayed_work	defense_work;   /* Work handler */
 	int			drop_rate;
 	int			drop_counter;
 	atomic_t		dropentry;
@@ -129,6 +130,8 @@ struct netns_ipvs {
 	/* multicast interface name */
 	char			master_mcast_ifn[IP_VS_IFNAME_MAXLEN];
 	char			backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
+	/* net name space ptr */
+	struct net		*net;            /* Needed by timer routines */
 };
 
 #endif /* IP_VS_H_ */
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 5ba205a..28bdaf7 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1138,7 +1138,7 @@ static inline int todrop_entry(struct ip_vs_conn *cp)
 }
 
 /* Called from keventd and must protect itself from softirqs */
-void ip_vs_random_dropentry(void)
+void ip_vs_random_dropentry(struct net *net)
 {
 	int idx;
 	struct ip_vs_conn *cp;
@@ -1158,7 +1158,8 @@ void ip_vs_random_dropentry(void)
 			if (cp->flags & IP_VS_CONN_F_TEMPLATE)
 				/* connection template */
 				continue;
-
+			if (!ip_vs_conn_net_eq(cp, net))
+				continue;
 			if (cp->protocol == IPPROTO_TCP) {
 				switch(cp->state) {
 				case IP_VS_TCP_S_SYN_RECV:
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index a7c59a7..bdda346 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1884,6 +1884,7 @@ static int __net_init __ip_vs_init(struct net *net)
 		pr_err("%s(): no memory.\n", __func__);
 		return -ENOMEM;
 	}
+	ipvs->net = net;
 	/* Counters used for creating unique names */
 	ipvs->gen = atomic_read(&ipvs_netns_cnt);
 	atomic_inc(&ipvs_netns_cnt);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 183ac18..6a963d4 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -217,18 +217,16 @@ static void update_defense_level(struct netns_ipvs *ipvs)
  *	Timer for checking the defense
  */
 #define DEFENSE_TIMER_PERIOD	1*HZ
-static void defense_work_handler(struct work_struct *work);
-static DECLARE_DELAYED_WORK(defense_work, defense_work_handler);
 
 static void defense_work_handler(struct work_struct *work)
 {
-	struct netns_ipvs *ipvs = net_ipvs(&init_net);
+	struct netns_ipvs *ipvs =
+		container_of(work, struct netns_ipvs, defense_work.work);
 
 	update_defense_level(ipvs);
 	if (atomic_read(&ipvs->dropentry))
-		ip_vs_random_dropentry();
-
-	schedule_delayed_work(&defense_work, DEFENSE_TIMER_PERIOD);
+		ip_vs_random_dropentry(ipvs->net);
+	schedule_delayed_work(&ipvs->defense_work, DEFENSE_TIMER_PERIOD);
 }
 
 int
@@ -3564,6 +3562,9 @@ int __net_init __ip_vs_control_init(struct net *net)
 		goto err_reg;
 	ip_vs_new_estimator(net, ipvs->tot_stats);
 	ipvs->sysctl_tbl = tbl;
+	/* Schedule defense work */
+	INIT_DELAYED_WORK(&ipvs->defense_work, defense_work_handler);
+	schedule_delayed_work(&ipvs->defense_work, DEFENSE_TIMER_PERIOD);
 	return 0;
 
 err_reg:
@@ -3588,6 +3589,8 @@ static void __net_exit __ip_vs_control_cleanup(struct net *net)
 	proc_net_remove(net, "ip_vs_stats_percpu");
 	proc_net_remove(net, "ip_vs_stats");
 	proc_net_remove(net, "ip_vs");
+	cancel_delayed_work_sync(&ipvs->defense_work);
+	cancel_work_sync(&ipvs->defense_work.work);
 	free_percpu(ipvs->cpustats);
 	kfree(ipvs->tot_stats);
 }
@@ -3631,9 +3634,6 @@ int __init ip_vs_control_init(void)
 		goto err_net;
 	}
 
-	/* Hook the defense timer */
-	schedule_delayed_work(&defense_work, DEFENSE_TIMER_PERIOD);
