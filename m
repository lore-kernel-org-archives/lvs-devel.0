From: hans@schillstrom.com
Subject: [*v3 PATCH 15/22] IPVS: netns, ip_vs_stats and its procfs
Date: Thu, 30 Dec 2010 11:50:59 +0100
Message-ID: <1293706266-27152-16-git-send-email-hans@schillstrom.com>
References: <1293706266-27152-1-git-send-email-hans@schillstrom.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1293706266-27152-1-git-send-email-hans@schillstrom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>

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

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/ip_vs.h             |   25 +++++++++
 include/net/netns/ip_vs.h       |    5 ++
 net/netfilter/ipvs/ip_vs_core.c |   26 ++++-----
 net/netfilter/ipvs/ip_vs_ctl.c  |  110 ++++++++++++++++++++++++++++++++-------
 net/netfilter/ipvs/ip_vs_est.c  |   34 ++++++++++++
 5 files changed, 166 insertions(+), 34 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index d7b1dcd..1076cfb 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -88,6 +88,18 @@ static inline struct net *skb_sknet(const struct sk_buff *skb) {
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
@@ -344,6 +356,19 @@ struct ip_vs_stats {
 
 	spinlock_t              lock;           /* spin lock */
 };
+/*
+ * Helper Macros for per cpu
+ * ipvs->ctl_stats->ustats.count
+ */
+#define IPVS_STAT_INC(ipvs, count)	\
+	__this_cpu_inc((ipvs)->ustats->count)
+
+#define IPVS_STAT_ADD(ipvs, count, value)	\
+	write_seqcount_begin(per_cpu_ptr((ipvs)->ustats_seq, \
+		             raw_smp_processor_id())); \
+	__this_cpu_add((ipvs)->ustats->count, value); \
+	write_seqcount_end(per_cpu_ptr((ipvs)->ustats_seq, \
+			   raw_smp_processor_id()))
 
 struct dst_entry;
 struct iphdr;
diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
index f6a6114..3b173b4 100644
--- a/include/net/netns/ip_vs.h
+++ b/include/net/netns/ip_vs.h
@@ -62,6 +62,11 @@ struct netns_ipvs {
 	struct list_head 	sctp_apps[SCTP_APP_TAB_SIZE];
 	spinlock_t		sctp_app_lock;
 #endif
+	/* ip_vs_ctl */
+	struct ip_vs_stats 		*ctl_stats;  /* Statistics & estimator */
+	struct ip_vs_stats_user __percpu *ustats;    /* Statistics */
+	seqcount_t			*ustats_seq; /* u64 read retry */
+
 	/* ip_vs_lblc */
 	int 			sysctl_lblc_expiration;
 	struct ctl_table_header	*lblc_ctl_header;
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 5d6e250..5e278e5 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -115,6 +115,8 @@ static inline void
 ip_vs_in_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 {
 	struct ip_vs_dest *dest = cp->dest;
+	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
+
 	if (dest && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
 		spin_lock(&dest->stats.lock);
 		dest->stats.ustats.inpkts++;
@@ -126,10 +128,8 @@ ip_vs_in_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 		dest->svc->stats.ustats.inbytes += skb->len;
 		spin_unlock(&dest->svc->stats.lock);
 
-		spin_lock(&ip_vs_stats.lock);
-		ip_vs_stats.ustats.inpkts++;
-		ip_vs_stats.ustats.inbytes += skb->len;
-		spin_unlock(&ip_vs_stats.lock);
+		IPVS_STAT_INC(ipvs, inpkts);
+		IPVS_STAT_ADD(ipvs, inbytes, skb->len);
 	}
 }
 
@@ -138,6 +138,8 @@ static inline void
 ip_vs_out_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 {
 	struct ip_vs_dest *dest = cp->dest;
+	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
+
 	if (dest && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
 		spin_lock(&dest->stats.lock);
 		dest->stats.ustats.outpkts++;
@@ -149,10 +151,8 @@ ip_vs_out_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 		dest->svc->stats.ustats.outbytes += skb->len;
 		spin_unlock(&dest->svc->stats.lock);
 
-		spin_lock(&ip_vs_stats.lock);
-		ip_vs_stats.ustats.outpkts++;
-		ip_vs_stats.ustats.outbytes += skb->len;
-		spin_unlock(&ip_vs_stats.lock);
+		IPVS_STAT_INC(ipvs, outpkts);
+		IPVS_STAT_ADD(ipvs, outbytes, skb->len);
 	}
 }
 
@@ -160,6 +160,8 @@ ip_vs_out_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 static inline void
 ip_vs_conn_stats(struct ip_vs_conn *cp, struct ip_vs_service *svc)
 {
+	struct netns_ipvs *ipvs = net_ipvs(svc->net);
+
 	spin_lock(&cp->dest->stats.lock);
 	cp->dest->stats.ustats.conns++;
 	spin_unlock(&cp->dest->stats.lock);
@@ -168,9 +170,7 @@ ip_vs_conn_stats(struct ip_vs_conn *cp, struct ip_vs_service *svc)
 	svc->stats.ustats.conns++;
 	spin_unlock(&svc->stats.lock);
 
-	spin_lock(&ip_vs_stats.lock);
-	ip_vs_stats.ustats.conns++;
-	spin_unlock(&ip_vs_stats.lock);
+	IPVS_STAT_INC(ipvs, conns);
 }
 
 
@@ -1471,13 +1471,12 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 static unsigned int
 ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 {
-	struct net *net = NULL;
+	struct net *net;
 	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
 	struct ip_vs_conn *cp;
 	int ret, restart, pkts;
-	struct net *net;
 	struct netns_ipvs *ipvs;
 
 	/* Already marked as IPVS request or reply? */
@@ -1842,7 +1841,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	},
 #endif
 };
-
 /*
  *	Initialize IP Virtual Server netns mem.
  */
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 105c05f..173fadc 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -258,8 +258,7 @@ static DECLARE_DELAYED_WORK(defense_work, defense_work_handler);
 
 static void defense_work_handler(struct work_struct *work)
 {
-	struct net *net = &init_net;
-	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct netns_ipvs *ipvs = net_ipvs(&init_net);
 
 	update_defense_level(ipvs);
 	if (atomic_read(&ip_vs_dropentry))
@@ -1499,7 +1498,7 @@ static int ip_vs_zero_all(struct net *net)
 		}
 	}
 
-	ip_vs_zero_stats(&ip_vs_stats);
+	ip_vs_zero_stats(net_ipvs(net)->ctl_stats);
 	return 0;
 }
 
@@ -1989,13 +1988,11 @@ static const struct file_operations ip_vs_info_fops = {
 
 #endif
 
-struct ip_vs_stats ip_vs_stats = {
-	.lock = __SPIN_LOCK_UNLOCKED(ip_vs_stats.lock),
-};
-
 #ifdef CONFIG_PROC_FS
 static int ip_vs_stats_show(struct seq_file *seq, void *v)
 {
+	struct net *net = seq_file_single_net(seq);
+	struct ip_vs_stats *ctl_stats = net_ipvs(net)->ctl_stats;
 
 /*               01234567 01234567 01234567 0123456701234567 0123456701234567 */
 	seq_puts(seq,
@@ -2003,22 +2000,22 @@ static int ip_vs_stats_show(struct seq_file *seq, void *v)
 	seq_printf(seq,
 		   "   Conns  Packets  Packets            Bytes            Bytes\n");
 
-	spin_lock_bh(&ip_vs_stats.lock);
-	seq_printf(seq, "%8X %8X %8X %16LX %16LX\n\n", ip_vs_stats.ustats.conns,
-		   ip_vs_stats.ustats.inpkts, ip_vs_stats.ustats.outpkts,
-		   (unsigned long long) ip_vs_stats.ustats.inbytes,
-		   (unsigned long long) ip_vs_stats.ustats.outbytes);
+	spin_lock_bh(&ctl_stats->lock);
+	seq_printf(seq, "%8X %8X %8X %16LX %16LX\n\n", ctl_stats->ustats.conns,
+		   ctl_stats->ustats.inpkts, ctl_stats->ustats.outpkts,
+		   (unsigned long long) ctl_stats->ustats.inbytes,
+		   (unsigned long long) ctl_stats->ustats.outbytes);
 
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
+			ctl_stats->ustats.cps,
+			ctl_stats->ustats.inpps,
+			ctl_stats->ustats.outpps,
+			ctl_stats->ustats.inbps,
+			ctl_stats->ustats.outbps);
+	spin_unlock_bh(&ctl_stats->lock);
 
 	return 0;
 }
@@ -2036,6 +2033,57 @@ static const struct file_operations ip_vs_stats_fops = {
 	.release = single_release,
 };
 
+static int ip_vs_stats_percpu_show(struct seq_file *seq, void *v)
+{
+	struct net *net = seq_file_single_net(seq);
+	struct ip_vs_stats *ctl_stats = net_ipvs(net)->ctl_stats;
+	int i;
+
+/*               01234567 01234567 01234567 0123456701234567 0123456701234567 */
+	seq_puts(seq,
+		 "       Total Incoming Outgoing         Incoming         Outgoing\n");
+	seq_printf(seq,
+		   "CPU    Conns  Packets  Packets            Bytes            Bytes\n");
+
+	for_each_possible_cpu(i) {
+		struct ip_vs_stats_user *u = per_cpu_ptr(net->ipvs->ustats, i);
+		seq_printf(seq, "%3X %8X %8X %8X %16LX %16LX\n",
+			    i, u->conns, u->inpkts, u->outpkts,
+			    (__u64) u->inbytes, (__u64) u->outbytes);
+	}
+
+	spin_lock_bh(&ctl_stats->lock);
+	seq_printf(seq, "  ~ %8X %8X %8X %16LX %16LX\n\n", ctl_stats->ustats.conns,
+		   ctl_stats->ustats.inpkts, ctl_stats->ustats.outpkts,
+		   (unsigned long long) ctl_stats->ustats.inbytes,
+		   (unsigned long long) ctl_stats->ustats.outbytes);
+
+/*                 01234567 01234567 01234567 0123456701234567 0123456701234567 */
+	seq_puts(seq,
+		   "     Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s\n");
+	seq_printf(seq,"    %8X %8X %8X %16X %16X\n",
+			ctl_stats->ustats.cps,
+			ctl_stats->ustats.inpps,
+			ctl_stats->ustats.outpps,
+			ctl_stats->ustats.inbps,
+			ctl_stats->ustats.outbps);
+	spin_unlock_bh(&ctl_stats->lock);
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
@@ -3460,6 +3508,18 @@ int __net_init __ip_vs_control_init(struct net *net)
 
 	if (!net_eq(net, &init_net))	/* netns not enabled yet */
 		return -EPERM;
+	/* procfs stats */
+	ipvs->ctl_stats = kzalloc(sizeof(struct ip_vs_stats), GFP_KERNEL);
+	if (ipvs->ctl_stats == NULL) {
+		pr_err("%s(): no memory.\n", __func__);
+		return -ENOMEM;
+	}
+	ipvs->ustats = alloc_percpu(struct ip_vs_stats_user);
+	if (!ipvs->ustats) {
+		pr_err("%s() alloc_percpu failed\n",__func__);
+		goto err_alloc;
+	}
+	spin_lock_init(&ipvs->ctl_stats->lock);
 
 	for(idx = 0; idx < IP_VS_RTAB_SIZE; idx++) {
 		INIT_LIST_HEAD(&ipvs->rs_table[idx]);
@@ -3467,25 +3527,35 @@ int __net_init __ip_vs_control_init(struct net *net)
 
 	proc_net_fops_create(net, "ip_vs", 0, &ip_vs_info_fops);
 	proc_net_fops_create(net, "ip_vs_stats", 0, &ip_vs_stats_fops);
+	proc_net_fops_create(net, "ip_vs_stats_percpu", 0,
+			     &ip_vs_stats_percpu_fops);
 	sysctl_header = register_net_sysctl_table(net, net_vs_ctl_path, vs_vars);
 	if (sysctl_header == NULL)
 		goto err_reg;
-	ip_vs_new_estimator(net, &ip_vs_stats);
+	ip_vs_new_estimator(net, ipvs->ctl_stats);
 	return 0;
 
 err_reg:
+	free_percpu(ipvs->ustats);
+err_alloc:
+	kfree(ipvs->ctl_stats);
 	return -ENOMEM;
 }
 
 static void __net_exit __ip_vs_control_cleanup(struct net *net)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
 	if (!net_eq(net, &init_net))	/* netns not enabled yet */
 		return;
 
-	ip_vs_kill_estimator(net, &ip_vs_stats);
+	ip_vs_kill_estimator(net, ipvs->ctl_stats);
 	unregister_net_sysctl_table(sysctl_header);
+	proc_net_remove(net, "ip_vs_stats_percpu");
 	proc_net_remove(net, "ip_vs_stats");
 	proc_net_remove(net, "ip_vs");
+	free_percpu(ipvs->ustats);
+	kfree(ipvs->ctl_stats);
 }
 
 static struct pernet_operations ipvs_control_ops = {
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 4a82a8b..6d3d06c 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -52,6 +52,39 @@
  */
 
 
+/*
+ * Make a summary from each cpu
+ */
+static inline void get_stats(struct netns_ipvs *ipvs)
+{
+	int i;
+
+	for_each_possible_cpu(i) {
+		struct ip_vs_stats_user *u = per_cpu_ptr(ipvs->ustats, i);
+		seqcount_t  *seq_count = per_cpu_ptr(ipvs->ustats_seq, i);
+		unsigned int start;
+		if (i) {
+			ipvs->ctl_stats->ustats.conns += u->conns;
+			ipvs->ctl_stats->ustats.inpkts += u->inpkts;
+			ipvs->ctl_stats->ustats.outpkts += u->outpkts;
+			do {
+				start = read_seqcount_begin(seq_count);
+				ipvs->ctl_stats->ustats.inbytes += u->inbytes;
+				ipvs->ctl_stats->ustats.outbytes += u->outbytes;
+			} while (read_seqcount_retry(seq_count, start));
+		} else {
+			ipvs->ctl_stats->ustats.conns = u->conns;
+			ipvs->ctl_stats->ustats.inpkts = u->inpkts;
+			ipvs->ctl_stats->ustats.outpkts = u->outpkts;
+			do {
+				start = read_seqcount_begin(seq_count);
+				ipvs->ctl_stats->ustats.inbytes = u->inbytes;
+				ipvs->ctl_stats->ustats.outbytes = u->outbytes;
+			} while (read_seqcount_retry(seq_count, start));
+		}
+	}
+}
+
 static void estimation_timer(unsigned long arg)
 {
 	struct ip_vs_estimator *e;
@@ -64,6 +97,7 @@ static void estimation_timer(unsigned long arg)
 	struct netns_ipvs *ipvs;
 
 	ipvs = net_ipvs(net);
+	get_stats(ipvs);
 	spin_lock(&ipvs->est_lock);
 	list_for_each_entry(e, &ipvs->est_list, list) {
 		s = container_of(e, struct ip_vs_stats, est);
-- 
1.7.2.3

