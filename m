From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 6/6] ipvs: rename estimator functions
Date: Mon, 14 Mar 2011 01:44:28 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103140141580.28562@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org


 	Rename ip_vs_new_estimator to ip_vs_start_estimator
and ip_vs_kill_estimator to ip_vs_stop_estimator to better
match their logic.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp lvs-test-2.6-8a80c79/linux/include/net/ip_vs.h linux/include/net/ip_vs.h
--- lvs-test-2.6-8a80c79/linux/include/net/ip_vs.h	2011-03-14 00:47:24.256249853 +0200
+++ linux/include/net/ip_vs.h	2011-03-14 00:46:58.128250398 +0200
@@ -1176,8 +1176,8 @@ extern void ip_vs_sync_cleanup(void);
   */
  extern int ip_vs_estimator_init(void);
  extern void ip_vs_estimator_cleanup(void);
-extern void ip_vs_new_estimator(struct net *net, struct ip_vs_stats *stats);
-extern void ip_vs_kill_estimator(struct net *net, struct ip_vs_stats *stats);
+extern void ip_vs_start_estimator(struct net *net, struct ip_vs_stats *stats);
+extern void ip_vs_stop_estimator(struct net *net, struct ip_vs_stats *stats);
  extern void ip_vs_zero_estimator(struct ip_vs_stats *stats);
  extern void ip_vs_read_estimator(struct ip_vs_stats_user *dst,
  				 struct ip_vs_stats *stats);
diff -urp lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_ctl.c linux/net/netfilter/ipvs/ip_vs_ctl.c
--- lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_ctl.c	2011-03-14 00:47:24.259247572 +0200
+++ linux/net/netfilter/ipvs/ip_vs_ctl.c	2011-03-14 00:46:58.131247939 +0200
@@ -800,7 +800,7 @@ __ip_vs_update_dest(struct ip_vs_service
  	spin_unlock(&dest->dst_lock);

  	if (add)
-		ip_vs_new_estimator(svc->net, &dest->stats);
+		ip_vs_start_estimator(svc->net, &dest->stats);

  	write_lock_bh(&__ip_vs_svc_lock);

@@ -1006,7 +1006,7 @@ static void __ip_vs_del_dest(struct net
  {
  	struct netns_ipvs *ipvs = net_ipvs(net);

-	ip_vs_kill_estimator(net, &dest->stats);
+	ip_vs_stop_estimator(net, &dest->stats);

  	/*
  	 *  Remove it from the d-linked list with the real services.
@@ -1199,7 +1199,7 @@ ip_vs_add_service(struct net *net, struc
  	else if (svc->port == 0)
  		atomic_inc(&ipvs->nullsvc_counter);

-	ip_vs_new_estimator(net, &svc->stats);
+	ip_vs_start_estimator(net, &svc->stats);

  	/* Count only IPv4 services for old get/setsockopt interface */
  	if (svc->af == AF_INET)
@@ -1351,7 +1351,7 @@ static void __ip_vs_del_service(struct i
  	if (svc->af == AF_INET)
  		ipvs->num_services--;

-	ip_vs_kill_estimator(svc->net, &svc->stats);
+	ip_vs_stop_estimator(svc->net, &svc->stats);

  	/* Unbind scheduler */
  	old_sched = svc->scheduler;
@@ -3583,7 +3583,7 @@ int __net_init __ip_vs_control_init(stru
  		goto err_dup;
  	}
  #endif
-	ip_vs_new_estimator(net, &ipvs->tot_stats);
+	ip_vs_start_estimator(net, &ipvs->tot_stats);
  	ipvs->sysctl_tbl = tbl;
  	/* Schedule defense work */
  	INIT_DELAYED_WORK(&ipvs->defense_work, defense_work_handler);
@@ -3601,7 +3601,7 @@ static void __net_exit __ip_vs_control_c
  	struct netns_ipvs *ipvs = net_ipvs(net);

  	ip_vs_trash_cleanup(net);
-	ip_vs_kill_estimator(net, &ipvs->tot_stats);
+	ip_vs_stop_estimator(net, &ipvs->tot_stats);
  	cancel_delayed_work_sync(&ipvs->defense_work);
  	cancel_work_sync(&ipvs->defense_work.work);
  #ifdef CONFIG_SYSCTL
diff -urp lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_est.c linux/net/netfilter/ipvs/ip_vs_est.c
--- lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_est.c	2011-03-14 00:47:24.260253578 +0200
+++ linux/net/netfilter/ipvs/ip_vs_est.c	2011-03-14 00:46:58.132249023 +0200
@@ -139,7 +139,7 @@ static void estimation_timer(unsigned lo
  	mod_timer(&ipvs->est_timer, jiffies + 2*HZ);
  }

-void ip_vs_new_estimator(struct net *net, struct ip_vs_stats *stats)
+void ip_vs_start_estimator(struct net *net, struct ip_vs_stats *stats)
  {
  	struct netns_ipvs *ipvs = net_ipvs(net);
  	struct ip_vs_estimator *est = &stats->est;
@@ -151,7 +151,7 @@ void ip_vs_new_estimator(struct net *net
  	spin_unlock_bh(&ipvs->est_lock);
  }

-void ip_vs_kill_estimator(struct net *net, struct ip_vs_stats *stats)
+void ip_vs_stop_estimator(struct net *net, struct ip_vs_stats *stats)
  {
  	struct netns_ipvs *ipvs = net_ipvs(net);
  	struct ip_vs_estimator *est = &stats->est;
