From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 15/22] IPVS: netns, ip_vs_stats and its procfs
Date: Thu,  6 Jan 2011 15:16:11 +0900
Message-ID: <1294294578-8601-16-git-send-email-horms@verge.net.au>
References: <1294294578-8601-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1294294578-8601-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Patrick McHardy <kaber@trash.net>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

The statistic counter locks for every packet are now removed,
and that statistic is now per CPU, i.e. no locks needed.
However summing is made in ip_vs_est into ip_vs_stats struct
which is moved to ipvs struc.

procfs, ip_vs_stats now have a "per cpu" count and a grand total.
A new function seq_file_single_net() in ip_vs.h created for handling of
single_open_net() since it does not place net ptr in a struct, like others.

/var/lib/lxc # cat /proc/net/ip_vs_stats_percpu
       Total Incoming Outgoing         Incoming         Outgoing
CPU    Conns  Packets  Packets            Bytes            Bytes
  0        0        3        1               9D               34
  1        0        1        2               49               70
  2        0        1        2               34               76
  3        1        2        2               70               74
  ~        1        7        7              18A              18E

     Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s
           0        0        0                0                0

*v3
ip_vs_stats reamains as before, instead ip_vs_stats_percpu is added.
u64 seq lock added

*v4
Bug correction inbytes and outbytes as own vars..
per_cpu counter for all stats now as suggested by Julian.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/linux/ip_vs.h           |    4 +-
 include/net/ip_vs.h             |   51 ++++++++++++++-
 include/net/netns/ip_vs.h       |    4 +
 net/netfilter/ipvs/ip_vs_core.c |   89 +++++++++++++++-----------
 net/netfilter/ipvs/ip_vs_ctl.c  |  134 +++++++++++++++++++++++++++++++++------
 net/netfilter/ipvs/ip_vs_est.c  |   39 +++++++++++
 6 files changed, 258 insertions(+), 63 deletions(-)

diff --git a/include/linux/ip_vs.h b/include/linux/ip_vs.h
index 4deb383..47a83d4 100644
--- a/include/linux/ip_vs.h
+++ b/include/linux/ip_vs.h
@@ -180,10 +180,10 @@ struct ip_vs_getinfo {
 /* The argument to IP_VS_SO_GET_SERVICE */
 struct ip_vs_service_entry {
 	/* which service: user fills in these */
-	__u16		protocol;
+	__u16			protocol;
 	__be32			addr;		/* virtual address */
 	__be16			port;
-	__u32		fwmark;		/* firwall mark of service */
+	__u32			fwmark;		/* firwall mark of service */
 
 	/* service options */
 	char			sched_name[IP_VS_SCHEDNAME_MAXLEN];
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 4265b5e..605d5db 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -90,6 +90,18 @@ static inline struct net *skb_sknet(struct sk_buff *skb)
 	return &init_net;
 #endif
 }
+/*
+ * This one needed for single_open_net since net is stored directly in
+ * private not as a struct i.e. seq_file_net cant be used.
+ */
+static inline struct net *seq_file_single_net(struct seq_file *seq)
+{
+#ifdef CONFIG_NET_NS
+	return (struct net *)seq->private;
+#else
+	return &init_net;
+#endif
+}
 
 /* Connections' size value needed by ip_vs_ctl.c */
 extern int ip_vs_conn_tab_size;
@@ -320,6 +332,23 @@ struct ip_vs_seq {
 						   before last resized pkt */
 };
 
+/*
+ * counters per cpu
+ */
+struct ip_vs_counters {
+	__u32		conns;		/* connections scheduled */
+	__u32		inpkts;		/* incoming packets */
+	__u32		outpkts;	/* outgoing packets */
+	__u64		inbytes;	/* incoming bytes */
+	__u64		outbytes;	/* outgoing bytes */
+};
+/*
+ * Stats per cpu
+ */
+struct ip_vs_cpu_stats {
+	struct ip_vs_counters   ustats;
+	struct u64_stats_sync   syncp;
+};
 
 /*
  *	IPVS statistics objects
@@ -341,12 +370,28 @@ struct ip_vs_estimator {
 };
 
 struct ip_vs_stats {
-	struct ip_vs_stats_user	ustats;         /* statistics */
+	struct ip_vs_stats_user	ustats;		/* statistics */
 	struct ip_vs_estimator	est;		/* estimator */
-
-	spinlock_t              lock;           /* spin lock */
+	struct ip_vs_cpu_stats	*cpustats;	/* per cpu counters */
+	spinlock_t		lock;		/* spin lock */
 };
 
+/*
+ * Helper Macros for per cpu
+ * ipvs->tot_stats->ustats.count
+ */
+#define IPVS_STAT_INC(ipvs, count)	\
+	__this_cpu_inc((ipvs)->ustats->count)
+
+#define IPVS_STAT_ADD(ipvs, count, value) \
+	do {\
+		write_seqcount_begin(per_cpu_ptr((ipvs)->ustats_seq, \
+				     raw_smp_processor_id())); \
+		__this_cpu_add((ipvs)->ustats->count, value); \
+		write_seqcount_end(per_cpu_ptr((ipvs)->ustats_seq, \
+				   raw_smp_processor_id())); \
+	} while (0)
+
 struct dst_entry;
 struct iphdr;
 struct ip_vs_conn;
diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
index aba78f3..bd1dad8 100644
--- a/include/net/netns/ip_vs.h
+++ b/include/net/netns/ip_vs.h
@@ -61,6 +61,10 @@ struct netns_ipvs {
 	struct list_head	sctp_apps[SCTP_APP_TAB_SIZE];
 	spinlock_t		sctp_app_lock;
 #endif
+	/* ip_vs_ctl */
+	struct ip_vs_stats		*tot_stats;  /* Statistics & est. */
+	struct ip_vs_cpu_stats __percpu *cpustats;   /* Stats per cpu */
+	seqcount_t			*ustats_seq; /* u64 read retry */
 
 	/* ip_vs_lblc */
 	int			sysctl_lblc_expiration;
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 5531d56..7e6a2a0 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -115,21 +115,28 @@ static inline void
 ip_vs_in_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 {
 	struct ip_vs_dest *dest = cp->dest;
+	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
+
 	if (dest && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
-		spin_lock(&dest->stats.lock);
-		dest->stats.ustats.inpkts++;
-		dest->stats.ustats.inbytes += skb->len;
-		spin_unlock(&dest->stats.lock);
-
-		spin_lock(&dest->svc->stats.lock);
-		dest->svc->stats.ustats.inpkts++;
-		dest->svc->stats.ustats.inbytes += skb->len;
-		spin_unlock(&dest->svc->stats.lock);
-
-		spin_lock(&ip_vs_stats.lock);
-		ip_vs_stats.ustats.inpkts++;
-		ip_vs_stats.ustats.inbytes += skb->len;
-		spin_unlock(&ip_vs_stats.lock);
+		struct ip_vs_cpu_stats *s;
+
+		s = this_cpu_ptr(dest->stats.cpustats);
+		s->ustats.inpkts++;
+		u64_stats_update_begin(&s->syncp);
+		s->ustats.inbytes += skb->len;
+		u64_stats_update_end(&s->syncp);
+
+		s = this_cpu_ptr(dest->svc->stats.cpustats);
+		s->ustats.inpkts++;
+		u64_stats_update_begin(&s->syncp);
+		s->ustats.inbytes += skb->len;
+		u64_stats_update_end(&s->syncp);
+
+		s = this_cpu_ptr(ipvs->cpustats);
+		s->ustats.inpkts++;
+		u64_stats_update_begin(&s->syncp);
+		s->ustats.inbytes += skb->len;
+		u64_stats_update_end(&s->syncp);
 	}
 }
 
@@ -138,21 +145,28 @@ static inline void
 ip_vs_out_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 {
 	struct ip_vs_dest *dest = cp->dest;
+	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
+
 	if (dest && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
-		spin_lock(&dest->stats.lock);
-		dest->stats.ustats.outpkts++;
-		dest->stats.ustats.outbytes += skb->len;
-		spin_unlock(&dest->stats.lock);
-
-		spin_lock(&dest->svc->stats.lock);
-		dest->svc->stats.ustats.outpkts++;
-		dest->svc->stats.ustats.outbytes += skb->len;
-		spin_unlock(&dest->svc->stats.lock);
-
-		spin_lock(&ip_vs_stats.lock);
-		ip_vs_stats.ustats.outpkts++;
-		ip_vs_stats.ustats.outbytes += skb->len;
-		spin_unlock(&ip_vs_stats.lock);
+		struct ip_vs_cpu_stats *s;
+
+		s = this_cpu_ptr(dest->stats.cpustats);
+		s->ustats.outpkts++;
+		u64_stats_update_begin(&s->syncp);
+		s->ustats.outbytes += skb->len;
+		u64_stats_update_end(&s->syncp);
+
+		s = this_cpu_ptr(dest->svc->stats.cpustats);
+		s->ustats.outpkts++;
+		u64_stats_update_begin(&s->syncp);
+		s->ustats.outbytes += skb->len;
+		u64_stats_update_end(&s->syncp);
+
+		s = this_cpu_ptr(ipvs->cpustats);
+		s->ustats.outpkts++;
+		u64_stats_update_begin(&s->syncp);
+		s->ustats.outbytes += skb->len;
+		u64_stats_update_end(&s->syncp);
 	}
 }
 
@@ -160,17 +174,17 @@ ip_vs_out_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 static inline void
 ip_vs_conn_stats(struct ip_vs_conn *cp, struct ip_vs_service *svc)
 {
-	spin_lock(&cp->dest->stats.lock);
-	cp->dest->stats.ustats.conns++;
-	spin_unlock(&cp->dest->stats.lock);
+	struct netns_ipvs *ipvs = net_ipvs(svc->net);
+	struct ip_vs_cpu_stats *s;
 
-	spin_lock(&svc->stats.lock);
-	svc->stats.ustats.conns++;
-	spin_unlock(&svc->stats.lock);
+	s = this_cpu_ptr(cp->dest->stats.cpustats);
+	s->ustats.conns++;
 
-	spin_lock(&ip_vs_stats.lock);
-	ip_vs_stats.ustats.conns++;
-	spin_unlock(&ip_vs_stats.lock);
+	s = this_cpu_ptr(svc->stats.cpustats);
+	s->ustats.conns++;
+
+	s = this_cpu_ptr(ipvs->cpustats);
+	s->ustats.conns++;
 }
 
 
@@ -1841,7 +1855,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	},
 #endif
 };
-
 /*
  *	Initialize IP Virtual Server netns mem.
  */
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 92436eb..5d0ad24 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -259,8 +259,7 @@ static DECLARE_DELAYED_WORK(defense_work, defense_work_handler);
 
 static void defense_work_handler(struct work_struct *work)
 {
-	struct net *net = &init_net;
-	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct netns_ipvs *ipvs = net_ipvs(&init_net);
 
 	update_defense_level(ipvs);
 	if (atomic_read(&ip_vs_dropentry))
@@ -521,6 +520,7 @@ __ip_vs_unbind_svc(struct ip_vs_dest *dest)
 			      svc->fwmark,
 			      IP_VS_DBG_ADDR(svc->af, &svc->addr),
 			      ntohs(svc->port), atomic_read(&svc->usecnt));
+		free_percpu(svc->stats.cpustats);
 		kfree(svc);
 	}
 }
@@ -724,6 +724,7 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
 			list_del(&dest->n_list);
 			ip_vs_dst_reset(dest);
 			__ip_vs_unbind_svc(dest);
+			free_percpu(dest->stats.cpustats);
 			kfree(dest);
 		}
 	}
@@ -749,6 +750,7 @@ static void ip_vs_trash_cleanup(void)
 		list_del(&dest->n_list);
 		ip_vs_dst_reset(dest);
 		__ip_vs_unbind_svc(dest);
+		free_percpu(dest->stats.cpustats);
 		kfree(dest);
 	}
 }
@@ -870,6 +872,11 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 		pr_err("%s(): no memory.\n", __func__);
 		return -ENOMEM;
 	}
+	dest->stats.cpustats = alloc_percpu(struct ip_vs_cpu_stats);
+	if (!dest->stats.cpustats) {
+		pr_err("%s() alloc_percpu failed\n", __func__);
+		goto err_alloc;
+	}
 
 	dest->af = svc->af;
 	dest->protocol = svc->protocol;
@@ -893,6 +900,10 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 
 	LeaveFunction(2);
 	return 0;
+
+err_alloc:
+	kfree(dest);
+	return -ENOMEM;
 }
 
 
@@ -1039,6 +1050,7 @@ static void __ip_vs_del_dest(struct net *net, struct ip_vs_dest *dest)
 		   and only one user context can update virtual service at a
 		   time, so the operation here is OK */
 		atomic_dec(&dest->svc->refcnt);
+		free_percpu(dest->stats.cpustats);
 		kfree(dest);
 	} else {
 		IP_VS_DBG_BUF(3, "Moving dest %s:%u into trash, "
@@ -1165,6 +1177,11 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 		ret = -ENOMEM;
 		goto out_err;
 	}
+	svc->stats.cpustats = alloc_percpu(struct ip_vs_cpu_stats);
+	if (!svc->stats.cpustats) {
+		pr_err("%s() alloc_percpu failed\n", __func__);
+		goto out_err;
+	}
 
 	/* I'm the first user of the service */
 	atomic_set(&svc->usecnt, 0);
@@ -1214,6 +1231,7 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 	*svc_p = svc;
 	return 0;
 
+
  out_err:
 	if (svc != NULL) {
 		ip_vs_unbind_scheduler(svc);
@@ -1222,6 +1240,8 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 			ip_vs_app_inc_put(svc->inc);
 			local_bh_enable();
 		}
+		if (svc->stats.cpustats)
+			free_percpu(svc->stats.cpustats);
 		kfree(svc);
 	}
 	ip_vs_scheduler_put(sched);
@@ -1390,6 +1410,7 @@ static void __ip_vs_del_service(struct ip_vs_service *svc)
 			      svc->fwmark,
 			      IP_VS_DBG_ADDR(svc->af, &svc->addr),
 			      ntohs(svc->port), atomic_read(&svc->usecnt));
+		free_percpu(svc->stats.cpustats);
 		kfree(svc);
 	}
 
@@ -1501,7 +1522,7 @@ static int ip_vs_zero_all(struct net *net)
 		}
 	}
 
-	ip_vs_zero_stats(&ip_vs_stats);
+	ip_vs_zero_stats(net_ipvs(net)->tot_stats);
 	return 0;
 }
 
@@ -1991,13 +2012,11 @@ static const struct file_operations ip_vs_info_fops = {
 
 #endif
 
-struct ip_vs_stats ip_vs_stats = {
-	.lock = __SPIN_LOCK_UNLOCKED(ip_vs_stats.lock),
-};
-
 #ifdef CONFIG_PROC_FS
 static int ip_vs_stats_show(struct seq_file *seq, void *v)
 {
+	struct net *net = seq_file_single_net(seq);
+	struct ip_vs_stats *tot_stats = net_ipvs(net)->tot_stats;
 
 /*               01234567 01234567 01234567 0123456701234567 0123456701234567 */
 	seq_puts(seq,
@@ -2005,22 +2024,22 @@ static int ip_vs_stats_show(struct seq_file *seq, void *v)
 	seq_printf(seq,
 		   "   Conns  Packets  Packets            Bytes            Bytes\n");
 
-	spin_lock_bh(&ip_vs_stats.lock);
-	seq_printf(seq, "%8X %8X %8X %16LX %16LX\n\n", ip_vs_stats.ustats.conns,
-		   ip_vs_stats.ustats.inpkts, ip_vs_stats.ustats.outpkts,
-		   (unsigned long long) ip_vs_stats.ustats.inbytes,
-		   (unsigned long long) ip_vs_stats.ustats.outbytes);
+	spin_lock_bh(&tot_stats->lock);
+	seq_printf(seq, "%8X %8X %8X %16LX %16LX\n\n", tot_stats->ustats.conns,
+		   tot_stats->ustats.inpkts, tot_stats->ustats.outpkts,
+		   (unsigned long long) tot_stats->ustats.inbytes,
+		   (unsigned long long) tot_stats->ustats.outbytes);
 
 /*                 01234567 01234567 01234567 0123456701234567 0123456701234567 */
 	seq_puts(seq,
 		   " Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s\n");
 	seq_printf(seq,"%8X %8X %8X %16X %16X\n",
-			ip_vs_stats.ustats.cps,
-			ip_vs_stats.ustats.inpps,
-			ip_vs_stats.ustats.outpps,
-			ip_vs_stats.ustats.inbps,
-			ip_vs_stats.ustats.outbps);
-	spin_unlock_bh(&ip_vs_stats.lock);
+			tot_stats->ustats.cps,
+			tot_stats->ustats.inpps,
+			tot_stats->ustats.outpps,
+			tot_stats->ustats.inbps,
+			tot_stats->ustats.outbps);
+	spin_unlock_bh(&tot_stats->lock);
 
 	return 0;
 }
@@ -2038,6 +2057,59 @@ static const struct file_operations ip_vs_stats_fops = {
 	.release = single_release,
 };
 
+static int ip_vs_stats_percpu_show(struct seq_file *seq, void *v)
+{
+	struct net *net = seq_file_single_net(seq);
+	struct ip_vs_stats *tot_stats = net_ipvs(net)->tot_stats;
+	int i;
+
+/*               01234567 01234567 01234567 0123456701234567 0123456701234567 */
+	seq_puts(seq,
+		 "       Total Incoming Outgoing         Incoming         Outgoing\n");
+	seq_printf(seq,
+		   "CPU    Conns  Packets  Packets            Bytes            Bytes\n");
+
+	for_each_possible_cpu(i) {
+		struct ip_vs_cpu_stats *u = per_cpu_ptr(net->ipvs->cpustats, i);
+		seq_printf(seq, "%3X %8X %8X %8X %16LX %16LX\n",
+			    i, u->ustats.conns, u->ustats.inpkts,
+			    u->ustats.outpkts, (__u64)u->ustats.inbytes,
+			    (__u64)u->ustats.outbytes);
+	}
+
+	spin_lock_bh(&tot_stats->lock);
+	seq_printf(seq, "  ~ %8X %8X %8X %16LX %16LX\n\n",
+		   tot_stats->ustats.conns, tot_stats->ustats.inpkts,
+		   tot_stats->ustats.outpkts,
+		   (unsigned long long) tot_stats->ustats.inbytes,
+		   (unsigned long long) tot_stats->ustats.outbytes);
+
+/*                 01234567 01234567 01234567 0123456701234567 0123456701234567 */
+	seq_puts(seq,
+		   "     Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s\n");
+	seq_printf(seq, "    %8X %8X %8X %16X %16X\n",
+			tot_stats->ustats.cps,
+			tot_stats->ustats.inpps,
+			tot_stats->ustats.outpps,
+			tot_stats->ustats.inbps,
+			tot_stats->ustats.outbps);
+	spin_unlock_bh(&tot_stats->lock);
+
+	return 0;
+}
+
+static int ip_vs_stats_percpu_seq_open(struct inode *inode, struct file *file)
+{
+	return single_open_net(inode, file, ip_vs_stats_percpu_show);
+}
+
+static const struct file_operations ip_vs_stats_percpu_fops = {
+	.owner = THIS_MODULE,
+	.open = ip_vs_stats_percpu_seq_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
 #endif
 
 /*
@@ -3463,32 +3535,54 @@ int __net_init __ip_vs_control_init(struct net *net)
 
 	if (!net_eq(net, &init_net))	/* netns not enabled yet */
 		return -EPERM;
+	/* procfs stats */
+	ipvs->tot_stats = kzalloc(sizeof(struct ip_vs_stats), GFP_KERNEL);
+	if (ipvs->tot_stats == NULL) {
+		pr_err("%s(): no memory.\n", __func__);
+		return -ENOMEM;
+	}
+	ipvs->cpustats = alloc_percpu(struct ip_vs_cpu_stats);
+	if (!ipvs->cpustats) {
+		pr_err("%s() alloc_percpu failed\n", __func__);
+		goto err_alloc;
+	}
+	spin_lock_init(&ipvs->tot_stats->lock);
 
 	for (idx = 0; idx < IP_VS_RTAB_SIZE; idx++)
 		INIT_LIST_HEAD(&ipvs->rs_table[idx]);
 
 	proc_net_fops_create(net, "ip_vs", 0, &ip_vs_info_fops);
 	proc_net_fops_create(net, "ip_vs_stats", 0, &ip_vs_stats_fops);
+	proc_net_fops_create(net, "ip_vs_stats_percpu", 0,
+			     &ip_vs_stats_percpu_fops);
 	sysctl_header = register_net_sysctl_table(net, net_vs_ctl_path,
 						  vs_vars);
 	if (sysctl_header == NULL)
 		goto err_reg;
-	ip_vs_new_estimator(net, &ip_vs_stats);
+	ip_vs_new_estimator(net, ipvs->tot_stats);
 	return 0;
 
 err_reg:
+	free_percpu(ipvs->cpustats);
+err_alloc:
+	kfree(ipvs->tot_stats);
 	return -ENOMEM;
 }
 
 static void __net_exit __ip_vs_control_cleanup(struct net *net)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
 	if (!net_eq(net, &init_net))	/* netns not enabled yet */
 		return;
 
-	ip_vs_kill_estimator(net, &ip_vs_stats);
+	ip_vs_kill_estimator(net, ipvs->tot_stats);
 	unregister_net_sysctl_table(sysctl_header);
+	proc_net_remove(net, "ip_vs_stats_percpu");
 	proc_net_remove(net, "ip_vs_stats");
 	proc_net_remove(net, "ip_vs");
+	free_percpu(ipvs->cpustats);
+	kfree(ipvs->tot_stats);
 }
 
 static struct pernet_operations ipvs_control_ops = {
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 07d839b..d13616b 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -52,6 +52,43 @@
  */
 
 
+/*
+ * Make a summary from each cpu
+ */
+static void ip_vs_read_cpu_stats(struct ip_vs_stats_user *sum,
+				 struct ip_vs_cpu_stats *stats)
+{
+	int i;
+
+	for_each_possible_cpu(i) {
+		struct ip_vs_cpu_stats *s = per_cpu_ptr(stats, i);
+		unsigned int start;
+		__u64 inbytes, outbytes;
+		if (i) {
+			sum->conns += s->ustats.conns;
+			sum->inpkts += s->ustats.inpkts;
+			sum->outpkts += s->ustats.outpkts;
+			do {
+				start = u64_stats_fetch_begin_bh(&s->syncp);
+				inbytes = s->ustats.inbytes;
+				outbytes = s->ustats.outbytes;
+			} while (u64_stats_fetch_retry_bh(&s->syncp, start));
+			sum->inbytes += inbytes;
+			sum->outbytes += outbytes;
+		} else {
+			sum->conns = s->ustats.conns;
+			sum->inpkts = s->ustats.inpkts;
+			sum->outpkts = s->ustats.outpkts;
+			do {
+				start = u64_stats_fetch_begin_bh(&s->syncp);
+				sum->inbytes = s->ustats.inbytes;
+				sum->outbytes = s->ustats.outbytes;
+			} while (u64_stats_fetch_retry_bh(&s->syncp, start));
+		}
+	}
+}
+
+
 static void estimation_timer(unsigned long arg)
 {
 	struct ip_vs_estimator *e;
@@ -64,10 +101,12 @@ static void estimation_timer(unsigned long arg)
 	struct netns_ipvs *ipvs;
 
 	ipvs = net_ipvs(net);
+	ip_vs_read_cpu_stats(&ipvs->tot_stats->ustats, ipvs->cpustats);
 	spin_lock(&ipvs->est_lock);
 	list_for_each_entry(e, &ipvs->est_list, list) {
 		s = container_of(e, struct ip_vs_stats, est);
 
+		ip_vs_read_cpu_stats(&s->ustats, s->cpustats);
 		spin_lock(&s->lock);
 		n_conns = s->ustats.conns;
 		n_inpkts = s->ustats.inpkts;
-- 
1.7.2.3

