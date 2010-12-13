From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [*v2 PATCH 18/22] IPVS: netns, defense work timer.
Date: Mon, 13 Dec 2010 14:38:26 +0100
Message-ID: <1292247510-753-19-git-send-email-hans.schillstrom@ericsson.com>
References: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

This patch makes defense work timer per name-space,
A net ptr had to be added to the ipvs struct,
since it's needed by defense_work_handler.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/ip_vs.h             |    2 +-
 include/net/netns/ip_vs.h       |    4 +++-
 net/netfilter/ipvs/ip_vs_conn.c |    5 +++--
 net/netfilter/ipvs/ip_vs_core.c |    1 +
 net/netfilter/ipvs/ip_vs_ctl.c  |   20 +++++++++-----------
 5 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 9b3fd8f..057c954 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -861,7 +861,7 @@ extern const char * ip_vs_state_name(__u16 proto, int state);
 
 extern void ip_vs_tcp_conn_listen(struct net *net, struct ip_vs_conn *cp);
 extern int ip_vs_check_template(struct ip_vs_conn *ct);
-extern void ip_vs_random_dropentry(void);
+extern void ip_vs_random_dropentry(struct net *net);
 extern int ip_vs_conn_init(void);
 extern void ip_vs_conn_cleanup(void);
 
diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
index b4a40bc..eeb1dd1 100644
--- a/include/net/netns/ip_vs.h
+++ b/include/net/netns/ip_vs.h
@@ -68,9 +68,9 @@ struct netns_ipvs {
 	/* ip_vs_ctl */
 	struct ip_vs_stats 		 *ctl_stats; /* Statistics & estimator */
 	struct ip_vs_stats_user __percpu *ustats;    /* Statistics */
-
 	int 			num_services;    /* no of virtual services */
 	/* 1/rate drop and drop-entry variables */
+	struct delayed_work	defense_work;   /* Work handler */
 	int 			drop_rate;
 	int			drop_counter;
 	atomic_t 		dropentry;
@@ -130,6 +130,8 @@ struct netns_ipvs {
 	/* multicast interface name */
 	char 			master_mcast_ifn[IP_VS_IFNAME_MAXLEN];
 	char 			backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
+	/* net name space ptr */
+	struct net 		*net;            /* Needed by timer routines */
 };
 
 #endif /* IP_VS_H_ */
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 3ccc33a..0200d97 100644
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
index 3a4dad2..34e4f71 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1858,6 +1858,7 @@ static int __net_init  __ip_vs_init(struct net *net)
 		pr_err("%s(): no memory.\n", __func__);
 		return -ENOMEM;
 	}
+	ipvs->net = net;
 	/* Incarnation counters used for creating unique names */
 	ipvs->inc = atomic_read(&ipvs_netns_cnt);
 	atomic_inc(&ipvs_netns_cnt);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 6982298..747bc96 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -215,18 +215,16 @@ static void update_defense_level(struct netns_ipvs *ipvs)
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
@@ -3495,6 +3493,9 @@ int __net_init __ip_vs_control_init(struct net *net)
 		goto err_reg;
 	ip_vs_new_estimator(net, ipvs->ctl_stats);
 	ipvs->sysctl_tbl = tbl;
+	/* Schedule defense work */
+	INIT_DELAYED_WORK(&ipvs->defense_work, defense_work_handler);
+	schedule_delayed_work(&ipvs->defense_work, DEFENSE_TIMER_PERIOD);
 	return 0;
 
 err_reg:
@@ -3518,6 +3519,8 @@ static void __net_exit __ip_vs_control_cleanup(struct net *net)
 	unregister_net_sysctl_table(ipvs->sysctl_hdr);
 	proc_net_remove(net, "ip_vs_stats");
 	proc_net_remove(net, "ip_vs");
+	cancel_rearming_delayed_work(&ipvs->defense_work);
+	cancel_work_sync(&ipvs->defense_work.work);
 	free_percpu(ipvs->ustats);
 	kfree(ipvs->ctl_stats);
 }
@@ -3561,9 +3564,6 @@ int __init ip_vs_control_init(void)
 		goto err_net;
 	}
 
-	/* Hook the defense timer */
-	schedule_delayed_work(&defense_work, DEFENSE_TIMER_PERIOD);
-
 	LeaveFunction(2);
 	return 0;
 
@@ -3578,8 +3578,6 @@ void ip_vs_control_cleanup(void)
 {
 	EnterFunction(2);
 	ip_vs_trash_cleanup();
-	cancel_rearming_delayed_work(&defense_work);
-	cancel_work_sync(&defense_work.work);
 	unregister_pernet_subsys(&ipvs_control_ops);
 	ip_vs_genl_unregister();
 	nf_unregister_sockopt(&ip_vs_sockopts);
-- 
1.7.2.3

