From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 46/84] ipvs: Pass ipvs not net to ip_vs_start_estimator aned ip_vs_stop_estimator
Date: Mon, 21 Sep 2015 13:02:23 -0500
Message-ID: <1442858581-15869-46-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip_vs.h            |  4 ++--
 net/netfilter/ipvs/ip_vs_ctl.c | 12 ++++++------
 net/netfilter/ipvs/ip_vs_est.c |  6 ++----
 3 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index f3ddf7696d68..2d49357b328c 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1455,8 +1455,8 @@ int stop_sync_thread(struct netns_ipvs *ipvs, int state);
 void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts);
 
 /* IPVS rate estimator prototypes (from ip_vs_est.c) */
-void ip_vs_start_estimator(struct net *net, struct ip_vs_stats *stats);
-void ip_vs_stop_estimator(struct net *net, struct ip_vs_stats *stats);
+void ip_vs_start_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats);
+void ip_vs_stop_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats);
 void ip_vs_zero_estimator(struct ip_vs_stats *stats);
 void ip_vs_read_estimator(struct ip_vs_kstats *dst, struct ip_vs_stats *stats);
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 4042a6f449cb..f43b894f3ef6 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -840,7 +840,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	spin_unlock_bh(&dest->dst_lock);
 
 	if (add) {
-		ip_vs_start_estimator(svc->ipvs->net, &dest->stats);
+		ip_vs_start_estimator(svc->ipvs, &dest->stats);
 		list_add_rcu(&dest->n_list, &svc->destinations);
 		svc->num_dests++;
 		sched = rcu_dereference_protected(svc->scheduler, 1);
@@ -1036,7 +1036,7 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 static void __ip_vs_del_dest(struct netns_ipvs *ipvs, struct ip_vs_dest *dest,
 			     bool cleanup)
 {
-	ip_vs_stop_estimator(ipvs->net, &dest->stats);
+	ip_vs_stop_estimator(ipvs, &dest->stats);
 
 	/*
 	 *  Remove it from the d-linked list with the real services.
@@ -1254,7 +1254,7 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 	else if (svc->port == 0)
 		atomic_inc(&ipvs->nullsvc_counter);
 
-	ip_vs_start_estimator(ipvs->net, &svc->stats);
+	ip_vs_start_estimator(ipvs, &svc->stats);
 
 	/* Count only IPv4 services for old get/setsockopt interface */
 	if (svc->af == AF_INET)
@@ -1382,7 +1382,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
 	if (svc->af == AF_INET)
 		ipvs->num_services--;
 
-	ip_vs_stop_estimator(svc->ipvs->net, &svc->stats);
+	ip_vs_stop_estimator(svc->ipvs, &svc->stats);
 
 	/* Unbind scheduler */
 	old_sched = rcu_dereference_protected(svc->scheduler, 1);
@@ -3917,7 +3917,7 @@ static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 			kfree(tbl);
 		return -ENOMEM;
 	}
-	ip_vs_start_estimator(net, &ipvs->tot_stats);
+	ip_vs_start_estimator(ipvs, &ipvs->tot_stats);
 	ipvs->sysctl_tbl = tbl;
 	/* Schedule defense work */
 	INIT_DELAYED_WORK(&ipvs->defense_work, defense_work_handler);
@@ -3933,7 +3933,7 @@ static void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
 	cancel_delayed_work_sync(&ipvs->defense_work);
 	cancel_work_sync(&ipvs->defense_work.work);
 	unregister_net_sysctl_table(ipvs->sysctl_hdr);
-	ip_vs_stop_estimator(net, &ipvs->tot_stats);
+	ip_vs_stop_estimator(ipvs, &ipvs->tot_stats);
 
 	if (!net_eq(net, &init_net))
 		kfree(ipvs->sysctl_tbl);
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index ef0eb0a8d552..638a301f7ee4 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -140,9 +140,8 @@ static void estimation_timer(unsigned long arg)
 	mod_timer(&ipvs->est_timer, jiffies + 2*HZ);
 }
 
-void ip_vs_start_estimator(struct net *net, struct ip_vs_stats *stats)
+void ip_vs_start_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_estimator *est = &stats->est;
 
 	INIT_LIST_HEAD(&est->list);
@@ -152,9 +151,8 @@ void ip_vs_start_estimator(struct net *net, struct ip_vs_stats *stats)
 	spin_unlock_bh(&ipvs->est_lock);
 }
 
-void ip_vs_stop_estimator(struct net *net, struct ip_vs_stats *stats)
+void ip_vs_stop_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_estimator *est = &stats->est;
 
 	spin_lock_bh(&ipvs->est_lock);
-- 
2.2.1

