From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 2/4] ipvs: reorganize tot_stats
Date: Fri, 4 Mar 2011 12:20:35 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103041218080.1452@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, =?UTF-8?Q?Hans_Schillstr=C3=B6m?= <hans.schillstrom@ericsson.com>


 	The global tot_stats contains cpustats field just like the
stats for dest and svc, so better use it to simplify the usage
in estimation_timer. As tot_stats is registered as estimator
we can remove the special ip_vs_read_cpu_stats call for
tot_stats. Fix ip_vs_read_cpu_stats to be called under
stats lock because it is still used as synchronization between
estimation timer and user context (the stats readers).

 	Also, make sure ip_vs_stats_percpu_show reads properly
the u64 stats from user context.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp lvs-test-2.6-8a80c79/linux/include/net/ip_vs.h linux/include/net/ip_vs.h
--- lvs-test-2.6-8a80c79/linux/include/net/ip_vs.h	2011-03-03 22:51:05.000000000 +0200
+++ linux/include/net/ip_vs.h	2011-03-03 22:56:57.780378777 +0200
@@ -851,8 +851,7 @@ struct netns_ipvs {
  	atomic_t		conn_count;      /*  connection counter */

  	/* ip_vs_ctl */
-	struct ip_vs_stats		*tot_stats;  /* Statistics & est. */
-	struct ip_vs_cpu_stats __percpu *cpustats;   /* Stats per cpu */
+	struct ip_vs_stats		tot_stats;  /* Statistics & est. */
  	seqcount_t			*ustats_seq; /* u64 read retry */

  	int			num_services;    /* no of virtual services */
diff -urp lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_core.c linux/net/netfilter/ipvs/ip_vs_core.c
--- lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_core.c	2011-03-03 22:47:47.000000000 +0200
+++ linux/net/netfilter/ipvs/ip_vs_core.c	2011-03-03 22:56:57.782378981 +0200
@@ -132,7 +132,7 @@ ip_vs_in_stats(struct ip_vs_conn *cp, st
  		s->ustats.inbytes += skb->len;
  		u64_stats_update_end(&s->syncp);

-		s = this_cpu_ptr(ipvs->cpustats);
+		s = this_cpu_ptr(ipvs->tot_stats.cpustats);
  		s->ustats.inpkts++;
  		u64_stats_update_begin(&s->syncp);
  		s->ustats.inbytes += skb->len;
@@ -162,7 +162,7 @@ ip_vs_out_stats(struct ip_vs_conn *cp, s
  		s->ustats.outbytes += skb->len;
  		u64_stats_update_end(&s->syncp);

-		s = this_cpu_ptr(ipvs->cpustats);
+		s = this_cpu_ptr(ipvs->tot_stats.cpustats);
  		s->ustats.outpkts++;
  		u64_stats_update_begin(&s->syncp);
  		s->ustats.outbytes += skb->len;
@@ -183,7 +183,7 @@ ip_vs_conn_stats(struct ip_vs_conn *cp,
  	s = this_cpu_ptr(svc->stats.cpustats);
  	s->ustats.conns++;

-	s = this_cpu_ptr(ipvs->cpustats);
+	s = this_cpu_ptr(ipvs->tot_stats.cpustats);
  	s->ustats.conns++;
  }

diff -urp lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_ctl.c linux/net/netfilter/ipvs/ip_vs_ctl.c
--- lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_ctl.c	2011-03-03 22:47:47.000000000 +0200
+++ linux/net/netfilter/ipvs/ip_vs_ctl.c	2011-03-03 23:04:33.089379951 +0200
@@ -1479,7 +1479,7 @@ static int ip_vs_zero_all(struct net *ne
  		}
  	}

-	ip_vs_zero_stats(net_ipvs(net)->tot_stats);
+	ip_vs_zero_stats(&net_ipvs(net)->tot_stats);
  	return 0;
  }

@@ -1961,7 +1961,7 @@ static const struct file_operations ip_v
  static int ip_vs_stats_show(struct seq_file *seq, void *v)
  {
  	struct net *net = seq_file_single_net(seq);
-	struct ip_vs_stats *tot_stats = net_ipvs(net)->tot_stats;
+	struct ip_vs_stats *tot_stats = &net_ipvs(net)->tot_stats;

  /*               01234567 01234567 01234567 0123456701234567 0123456701234567 */
  	seq_puts(seq,
@@ -2005,7 +2005,8 @@ static const struct file_operations ip_v
  static int ip_vs_stats_percpu_show(struct seq_file *seq, void *v)
  {
  	struct net *net = seq_file_single_net(seq);
-	struct ip_vs_stats *tot_stats = net_ipvs(net)->tot_stats;
+	struct ip_vs_stats *tot_stats = &net_ipvs(net)->tot_stats;
+	struct ip_vs_cpu_stats *cpustats = tot_stats->cpustats;
  	int i;

  /*               01234567 01234567 01234567 0123456701234567 0123456701234567 */
@@ -2015,11 +2016,20 @@ static int ip_vs_stats_percpu_show(struc
  		   "CPU    Conns  Packets  Packets            Bytes            Bytes\n");

  	for_each_possible_cpu(i) {
-		struct ip_vs_cpu_stats *u = per_cpu_ptr(net->ipvs->cpustats, i);
+		struct ip_vs_cpu_stats *u = per_cpu_ptr(cpustats, i);
+		unsigned int start;
+		__u64 inbytes, outbytes;
+
+		do {
+			start = u64_stats_fetch_begin_bh(&u->syncp);
+			inbytes = u->ustats.inbytes;
+			outbytes = u->ustats.outbytes;
+		} while (u64_stats_fetch_retry_bh(&u->syncp, start));
+
  		seq_printf(seq, "%3X %8X %8X %8X %16LX %16LX\n",
-			    i, u->ustats.conns, u->ustats.inpkts,
-			    u->ustats.outpkts, (__u64)u->ustats.inbytes,
-			    (__u64)u->ustats.outbytes);
+			   i, u->ustats.conns, u->ustats.inpkts,
+			   u->ustats.outpkts, (__u64)inbytes,
+			   (__u64)outbytes);
  	}

  	spin_lock_bh(&tot_stats->lock);
@@ -3503,17 +3513,12 @@ int __net_init __ip_vs_control_init(stru
  	atomic_set(&ipvs->nullsvc_counter, 0);

  	/* procfs stats */
-	ipvs->tot_stats = kzalloc(sizeof(struct ip_vs_stats), GFP_KERNEL);
-	if (ipvs->tot_stats == NULL) {
-		pr_err("%s(): no memory.\n", __func__);
-		return -ENOMEM;
-	}
-	ipvs->cpustats = alloc_percpu(struct ip_vs_cpu_stats);
-	if (!ipvs->cpustats) {
+	ipvs->tot_stats.cpustats = alloc_percpu(struct ip_vs_cpu_stats);
+	if (!ipvs->tot_stats.cpustats) {
  		pr_err("%s() alloc_percpu failed\n", __func__);
  		goto err_alloc;
  	}
-	spin_lock_init(&ipvs->tot_stats->lock);
+	spin_lock_init(&ipvs->tot_stats.lock);

  	proc_net_fops_create(net, "ip_vs", 0, &ip_vs_info_fops);
  	proc_net_fops_create(net, "ip_vs_stats", 0, &ip_vs_stats_fops);
@@ -3561,7 +3566,7 @@ int __net_init __ip_vs_control_init(stru
  		goto err_dup;
  	}
  #endif
-	ip_vs_new_estimator(net, ipvs->tot_stats);
+	ip_vs_new_estimator(net, &ipvs->tot_stats);
  	ipvs->sysctl_tbl = tbl;
  	/* Schedule defense work */
  	INIT_DELAYED_WORK(&ipvs->defense_work, defense_work_handler);
@@ -3569,9 +3574,8 @@ int __net_init __ip_vs_control_init(stru
  	return 0;

  err_dup:
-	free_percpu(ipvs->cpustats);
+	free_percpu(ipvs->tot_stats.cpustats);
  err_alloc:
-	kfree(ipvs->tot_stats);
  	return -ENOMEM;
  }

@@ -3580,7 +3584,7 @@ static void __net_exit __ip_vs_control_c
  	struct netns_ipvs *ipvs = net_ipvs(net);

  	ip_vs_trash_cleanup(net);
-	ip_vs_kill_estimator(net, ipvs->tot_stats);
+	ip_vs_kill_estimator(net, &ipvs->tot_stats);
  	cancel_delayed_work_sync(&ipvs->defense_work);
  	cancel_work_sync(&ipvs->defense_work.work);
  #ifdef CONFIG_SYSCTL
@@ -3589,8 +3593,7 @@ static void __net_exit __ip_vs_control_c
  	proc_net_remove(net, "ip_vs_stats_percpu");
  	proc_net_remove(net, "ip_vs_stats");
  	proc_net_remove(net, "ip_vs");
-	free_percpu(ipvs->cpustats);
-	kfree(ipvs->tot_stats);
+	free_percpu(ipvs->tot_stats.cpustats);
  }

  static struct pernet_operations ipvs_control_ops = {
diff -urp lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_est.c linux/net/netfilter/ipvs/ip_vs_est.c
--- lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_est.c	2011-03-03 22:47:47.000000000 +0200
+++ linux/net/netfilter/ipvs/ip_vs_est.c	2011-03-03 22:56:57.786378448 +0200
@@ -101,13 +101,12 @@ static void estimation_timer(unsigned lo
  	struct netns_ipvs *ipvs;

  	ipvs = net_ipvs(net);
-	ip_vs_read_cpu_stats(&ipvs->tot_stats->ustats, ipvs->cpustats);
  	spin_lock(&ipvs->est_lock);
  	list_for_each_entry(e, &ipvs->est_list, list) {
  		s = container_of(e, struct ip_vs_stats, est);

-		ip_vs_read_cpu_stats(&s->ustats, s->cpustats);
  		spin_lock(&s->lock);
+		ip_vs_read_cpu_stats(&s->ustats, s->cpustats);
  		n_conns = s->ustats.conns;
  		n_inpkts = s->ustats.inpkts;
  		n_outpkts = s->ustats.outpkts;
