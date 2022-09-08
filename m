From: Julian Anastasov <ja@ssi.bg>
Subject: [RFC PATCHv2 1/4] ipvs: add rcu protection to stats
Date: Fri,  9 Sep 2022 01:21:06 +0300
Message-ID: <20220908222109.147452-2-ja@ssi.bg>
References: <20220908222109.147452-1-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20220908222109.147452-1-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jiri Wiesner <jwiesner@suse.de>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

In preparation to using RCU locking for the list
with estimators, make sure the struct ip_vs_stats
are released after RCU grace period by using RCU
callbacks. This affects ipvs->tot_stats where we
can not use RCU callbacks for ipvs, so we use
allocated struct ip_vs_stats_rcu. For services
and dests we force RCU callbacks for all cases.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |  8 ++++-
 net/netfilter/ipvs/ip_vs_core.c | 10 ++++--
 net/netfilter/ipvs/ip_vs_ctl.c  | 64 ++++++++++++++++++++++-----------
 3 files changed, 57 insertions(+), 25 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index ff1804a0c469..bd8ae137e43b 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -405,6 +405,11 @@ struct ip_vs_stats {
 	struct ip_vs_kstats	kstats0;	/* reset values */
 };
 
+struct ip_vs_stats_rcu {
+	struct ip_vs_stats	s;
+	struct rcu_head		rcu_head;
+};
+
 struct dst_entry;
 struct iphdr;
 struct ip_vs_conn;
@@ -688,6 +693,7 @@ struct ip_vs_dest {
 	union nf_inet_addr	vaddr;		/* virtual IP address */
 	__u32			vfwmark;	/* firewall mark of service */
 
+	struct rcu_head		rcu_head;
 	struct list_head	t_list;		/* in dest_trash */
 	unsigned int		in_rs_table:1;	/* we are in rs_table */
 };
@@ -869,7 +875,7 @@ struct netns_ipvs {
 	atomic_t		conn_count;      /* connection counter */
 
 	/* ip_vs_ctl */
-	struct ip_vs_stats		tot_stats;  /* Statistics & est. */
+	struct ip_vs_stats_rcu	*tot_stats;      /* Statistics & est. */
 
 	int			num_services;    /* no of virtual services */
 	int			num_services6;   /* IPv6 virtual services */
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 51ad557a525b..fcdaef1fcccf 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -143,7 +143,7 @@ ip_vs_in_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 		s->cnt.inbytes += skb->len;
 		u64_stats_update_end(&s->syncp);
 
-		s = this_cpu_ptr(ipvs->tot_stats.cpustats);
+		s = this_cpu_ptr(ipvs->tot_stats->s.cpustats);
 		u64_stats_update_begin(&s->syncp);
 		s->cnt.inpkts++;
 		s->cnt.inbytes += skb->len;
@@ -179,7 +179,7 @@ ip_vs_out_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 		s->cnt.outbytes += skb->len;
 		u64_stats_update_end(&s->syncp);
 
-		s = this_cpu_ptr(ipvs->tot_stats.cpustats);
+		s = this_cpu_ptr(ipvs->tot_stats->s.cpustats);
 		u64_stats_update_begin(&s->syncp);
 		s->cnt.outpkts++;
 		s->cnt.outbytes += skb->len;
@@ -208,7 +208,7 @@ ip_vs_conn_stats(struct ip_vs_conn *cp, struct ip_vs_service *svc)
 	s->cnt.conns++;
 	u64_stats_update_end(&s->syncp);
 
-	s = this_cpu_ptr(ipvs->tot_stats.cpustats);
+	s = this_cpu_ptr(ipvs->tot_stats->s.cpustats);
 	u64_stats_update_begin(&s->syncp);
 	s->cnt.conns++;
 	u64_stats_update_end(&s->syncp);
@@ -2448,6 +2448,10 @@ static void __exit ip_vs_cleanup(void)
 	ip_vs_conn_cleanup();
 	ip_vs_protocol_cleanup();
 	ip_vs_control_cleanup();
+	/* common rcu_barrier() used by:
+	 * - ip_vs_control_cleanup()
+	 */
+	rcu_barrier();
 	pr_info("ipvs unloaded.\n");
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index efab2b06d373..44c79fd1779c 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -483,17 +483,14 @@ static void ip_vs_service_rcu_free(struct rcu_head *head)
 	ip_vs_service_free(svc);
 }
 
-static void __ip_vs_svc_put(struct ip_vs_service *svc, bool do_delay)
+static void __ip_vs_svc_put(struct ip_vs_service *svc)
 {
 	if (atomic_dec_and_test(&svc->refcnt)) {
 		IP_VS_DBG_BUF(3, "Removing service %u/%s:%u\n",
 			      svc->fwmark,
 			      IP_VS_DBG_ADDR(svc->af, &svc->addr),
 			      ntohs(svc->port));
-		if (do_delay)
-			call_rcu(&svc->rcu_head, ip_vs_service_rcu_free);
-		else
-			ip_vs_service_free(svc);
+		call_rcu(&svc->rcu_head, ip_vs_service_rcu_free);
 	}
 }
 
@@ -780,14 +777,22 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, int dest_af,
 	return dest;
 }
 
+static void ip_vs_dest_rcu_free(struct rcu_head *head)
+{
+	struct ip_vs_dest *dest;
+
+	dest = container_of(head, struct ip_vs_dest, rcu_head);
+	free_percpu(dest->stats.cpustats);
+	ip_vs_dest_put_and_free(dest);
+}
+
 static void ip_vs_dest_free(struct ip_vs_dest *dest)
 {
 	struct ip_vs_service *svc = rcu_dereference_protected(dest->svc, 1);
 
 	__ip_vs_dst_cache_reset(dest);
-	__ip_vs_svc_put(svc, false);
-	free_percpu(dest->stats.cpustats);
-	ip_vs_dest_put_and_free(dest);
+	__ip_vs_svc_put(svc);
+	call_rcu(&dest->rcu_head, ip_vs_dest_rcu_free);
 }
 
 /*
@@ -811,6 +816,16 @@ static void ip_vs_trash_cleanup(struct netns_ipvs *ipvs)
 	}
 }
 
+static void ip_vs_stats_rcu_free(struct rcu_head *head)
+{
+	struct ip_vs_stats_rcu *rs = container_of(head,
+						  struct ip_vs_stats_rcu,
+						  rcu_head);
+
+	free_percpu(rs->s.cpustats);
+	kfree(rs);
+}
+
 static void
 ip_vs_copy_stats(struct ip_vs_kstats *dst, struct ip_vs_stats *src)
 {
@@ -923,7 +938,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 		if (old_svc != svc) {
 			ip_vs_zero_stats(&dest->stats);
 			__ip_vs_bind_svc(dest, svc);
-			__ip_vs_svc_put(old_svc, true);
+			__ip_vs_svc_put(old_svc);
 		}
 	}
 
@@ -1571,7 +1586,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
 	/*
 	 *    Free the service if nobody refers to it
 	 */
-	__ip_vs_svc_put(svc, true);
+	__ip_vs_svc_put(svc);
 
 	/* decrease the module use count */
 	ip_vs_use_count_dec();
@@ -1761,7 +1776,7 @@ static int ip_vs_zero_all(struct netns_ipvs *ipvs)
 		}
 	}
 
-	ip_vs_zero_stats(&ipvs->tot_stats);
+	ip_vs_zero_stats(&ipvs->tot_stats->s);
 	return 0;
 }
 
@@ -2255,7 +2270,7 @@ static int ip_vs_stats_show(struct seq_file *seq, void *v)
 	seq_puts(seq,
 		 "   Conns  Packets  Packets            Bytes            Bytes\n");
 
-	ip_vs_copy_stats(&show, &net_ipvs(net)->tot_stats);
+	ip_vs_copy_stats(&show, &net_ipvs(net)->tot_stats->s);
 	seq_printf(seq, "%8LX %8LX %8LX %16LX %16LX\n\n",
 		   (unsigned long long)show.conns,
 		   (unsigned long long)show.inpkts,
@@ -2279,7 +2294,7 @@ static int ip_vs_stats_show(struct seq_file *seq, void *v)
 static int ip_vs_stats_percpu_show(struct seq_file *seq, void *v)
 {
 	struct net *net = seq_file_single_net(seq);
-	struct ip_vs_stats *tot_stats = &net_ipvs(net)->tot_stats;
+	struct ip_vs_stats *tot_stats = &net_ipvs(net)->tot_stats->s;
 	struct ip_vs_cpu_stats __percpu *cpustats = tot_stats->cpustats;
 	struct ip_vs_kstats kstats;
 	int i;
@@ -4106,7 +4121,6 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 			kfree(tbl);
 		return -ENOMEM;
 	}
-	ip_vs_start_estimator(ipvs, &ipvs->tot_stats);
 	ipvs->sysctl_tbl = tbl;
 	/* Schedule defense work */
 	INIT_DELAYED_WORK(&ipvs->defense_work, defense_work_handler);
@@ -4117,6 +4131,7 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 	INIT_DELAYED_WORK(&ipvs->expire_nodest_conn_work,
 			  expire_nodest_conn_handler);
 
+	ip_vs_start_estimator(ipvs, &ipvs->tot_stats->s);
 	return 0;
 }
 
@@ -4128,7 +4143,7 @@ static void __net_exit ip_vs_control_net_cleanup_sysctl(struct netns_ipvs *ipvs)
 	cancel_delayed_work_sync(&ipvs->defense_work);
 	cancel_work_sync(&ipvs->defense_work.work);
 	unregister_net_sysctl_table(ipvs->sysctl_hdr);
-	ip_vs_stop_estimator(ipvs, &ipvs->tot_stats);
+	ip_vs_stop_estimator(ipvs, &ipvs->tot_stats->s);
 
 	if (!net_eq(net, &init_net))
 		kfree(ipvs->sysctl_tbl);
@@ -4164,17 +4179,20 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 	atomic_set(&ipvs->conn_out_counter, 0);
 
 	/* procfs stats */
-	ipvs->tot_stats.cpustats = alloc_percpu(struct ip_vs_cpu_stats);
-	if (!ipvs->tot_stats.cpustats)
+	ipvs->tot_stats = kzalloc(sizeof(*ipvs->tot_stats), GFP_KERNEL);
+	if (!ipvs->tot_stats)
 		return -ENOMEM;
+	ipvs->tot_stats->s.cpustats = alloc_percpu(struct ip_vs_cpu_stats);
+	if (!ipvs->tot_stats->s.cpustats)
+		goto err_tot_stats;
 
 	for_each_possible_cpu(i) {
 		struct ip_vs_cpu_stats *ipvs_tot_stats;
-		ipvs_tot_stats = per_cpu_ptr(ipvs->tot_stats.cpustats, i);
+		ipvs_tot_stats = per_cpu_ptr(ipvs->tot_stats->s.cpustats, i);
 		u64_stats_init(&ipvs_tot_stats->syncp);
 	}
 
-	spin_lock_init(&ipvs->tot_stats.lock);
+	spin_lock_init(&ipvs->tot_stats->s.lock);
 
 #ifdef CONFIG_PROC_FS
 	if (!proc_create_net("ip_vs", 0, ipvs->net->proc_net,
@@ -4206,7 +4224,10 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 
 err_vs:
 #endif
-	free_percpu(ipvs->tot_stats.cpustats);
+	free_percpu(ipvs->tot_stats->s.cpustats);
+
+err_tot_stats:
+	kfree(ipvs->tot_stats);
 	return -ENOMEM;
 }
 
@@ -4219,7 +4240,7 @@ void __net_exit ip_vs_control_net_cleanup(struct netns_ipvs *ipvs)
 	remove_proc_entry("ip_vs_stats", ipvs->net->proc_net);
 	remove_proc_entry("ip_vs", ipvs->net->proc_net);
 #endif
-	free_percpu(ipvs->tot_stats.cpustats);
+	call_rcu(&ipvs->tot_stats->rcu_head, ip_vs_stats_rcu_free);
 }
 
 int __init ip_vs_register_nl_ioctl(void)
@@ -4279,5 +4300,6 @@ void ip_vs_control_cleanup(void)
 {
 	EnterFunction(2);
 	unregister_netdevice_notifier(&ip_vs_dst_notifier);
+	/* relying on common rcu_barrier() in ip_vs_cleanup() */
 	LeaveFunction(2);
 }
-- 
2.37.3


