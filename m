From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [*v2 PATCH 15/22] IPVS: netns, ip_vs_stats and its procfs
Date: Mon, 13 Dec 2010 14:38:23 +0100
Message-ID: <1292247510-753-16-git-send-email-hans.schillstrom@ericsson.com>
References: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

The statistic counter locks for every packet are now removed,
and that statistic is now per CPU, i.e. no locks needed.
However summing is made in ip_vs_est into ip_vs_stats struct
which is moved to ipvs struc.

procfs, ip_vs_stats now have a "per cpu" count and a grand total.
A new function seq_file_single_net() in ip_vs.h created for handling of
single_open_net() since it does not place net ptr in a struct, like others.


/var/lib/lxc # cat /proc/net/ip_vs_stats
       Total Incoming Outgoing         Incoming         Outgoing
CPU    Conns  Packets  Packets            Bytes            Bytes
  0        0        3        1               9D               34
  1        0        1        2               49               70
  2        0        1        2               34               76
  3        1        2        2               70               74
  ~        1        7        7              18A              18E

     Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s
           0        0        0                0                0

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/ip_vs.h             |   22 ++++++++++++
 include/net/netns/ip_vs.h       |    4 ++
 net/netfilter/ipvs/ip_vs_core.c |   23 ++++++------
 net/netfilter/ipvs/ip_vs_ctl.c  |   72 ++++++++++++++++++++++++++-------------
 net/netfilter/ipvs/ip_vs_est.c  |   26 ++++++++++++++
 5 files changed, 111 insertions(+), 36 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 21ba325..848fcda 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -92,6 +92,19 @@ static inline struct net *skb_sknet(const struct sk_buff *skb) {
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
+
 
 /* Connections' size value needed by ip_vs_ctl.c */
 extern int ip_vs_conn_tab_size;
@@ -348,6 +361,15 @@ struct ip_vs_stats {
 
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
+	__this_cpu_add((ipvs)->ustats->count, value)
 
 struct dst_entry;
 struct iphdr;
diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
index 1f00447..b6642f0 100644
--- a/include/net/netns/ip_vs.h
+++ b/include/net/netns/ip_vs.h
@@ -62,6 +62,10 @@ struct netns_ipvs {
 	struct list_head 	sctp_apps[SCTP_APP_TAB_SIZE];
 	spinlock_t		sctp_app_lock;
 #endif
+	/* ip_vs_ctl */
+	struct ip_vs_stats 		*ctl_stats; /* Statistics & estimator */
+	struct ip_vs_stats_user __percpu *ustats;   /* Statistics */
+
 	/* ip_vs_lblc */
 	int 			sysctl_lblc_expiration;
 	struct ctl_table_header	*lblc_ctl_header;
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index e77ebcb..679eb16 100644
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
 
 
@@ -1827,7 +1827,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	},
 #endif
 };
-
 /*
  *	Initialize IP Virtual Server netns mem.
  */
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 86195c2..ca7bf30 100644
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
@@ -1498,7 +1497,7 @@ static int ip_vs_zero_all(struct net *net)
 		}
 	}
 
-	ip_vs_zero_stats(&ip_vs_stats);
+	ip_vs_zero_stats(net_ipvs(net)->ctl_stats);
 	return 0;
 }
 
@@ -1988,36 +1987,42 @@ static const struct file_operations ip_vs_info_fops = {
 
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
+	int i;
 
 /*               01234567 01234567 01234567 0123456701234567 0123456701234567 */
 	seq_puts(seq,
-		 "   Total Incoming Outgoing         Incoming         Outgoing\n");
+		 "       Total Incoming Outgoing         Incoming         Outgoing\n");
 	seq_printf(seq,
-		   "   Conns  Packets  Packets            Bytes            Bytes\n");
+		   "CPU    Conns  Packets  Packets            Bytes            Bytes\n");
 
-	spin_lock_bh(&ip_vs_stats.lock);
-	seq_printf(seq, "%8X %8X %8X %16LX %16LX\n\n", ip_vs_stats.ustats.conns,
-		   ip_vs_stats.ustats.inpkts, ip_vs_stats.ustats.outpkts,
-		   (unsigned long long) ip_vs_stats.ustats.inbytes,
-		   (unsigned long long) ip_vs_stats.ustats.outbytes);
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
 
 /*                 01234567 01234567 01234567 0123456701234567 0123456701234567 */
 	seq_puts(seq,
-		   " Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s\n");
-	seq_printf(seq,"%8X %8X %8X %16X %16X\n",
-			ip_vs_stats.ustats.cps,
-			ip_vs_stats.ustats.inpps,
-			ip_vs_stats.ustats.outpps,
-			ip_vs_stats.ustats.inbps,
-			ip_vs_stats.ustats.outbps);
-	spin_unlock_bh(&ip_vs_stats.lock);
+		   "     Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s\n");
+	seq_printf(seq,"    %8X %8X %8X %16X %16X\n",
+			ctl_stats->ustats.cps,
+			ctl_stats->ustats.inpps,
+			ctl_stats->ustats.outpps,
+			ctl_stats->ustats.inbps,
+			ctl_stats->ustats.outbps);
+	spin_unlock_bh(&ctl_stats->lock);
 
 	return 0;
 }
@@ -3459,6 +3464,18 @@ int __net_init __ip_vs_control_init(struct net *net)
 
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
@@ -3469,22 +3486,29 @@ int __net_init __ip_vs_control_init(struct net *net)
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
 	proc_net_remove(net, "ip_vs_stats");
 	proc_net_remove(net, "ip_vs");
+	free_percpu(ipvs->ustats);
+	kfree(ipvs->ctl_stats);
 }
 
 static struct pernet_operations ipvs_control_ops = {
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 6bcabed..576de09 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -55,6 +55,31 @@
 static void estimation_timer(unsigned long arg);
 static DEFINE_TIMER(est_timer, estimation_timer, 0, 0);
 
+/*
+ * Make a summary from each cpu
+ */
+static inline void get_stats(struct netns_ipvs *ipvs)
+{
+	int i;
+
+	for_each_possible_cpu(i) {
+		struct ip_vs_stats_user *u = per_cpu_ptr(ipvs->ustats, i);
+		if (i) {
+			ipvs->ctl_stats->ustats.conns += u->conns;
+			ipvs->ctl_stats->ustats.inpkts += u->inpkts;
+			ipvs->ctl_stats->ustats.inbytes += u->inbytes;
+			ipvs->ctl_stats->ustats.outpkts += u->outpkts;
+			ipvs->ctl_stats->ustats.outbytes += u->outbytes;
+		} else {
+			ipvs->ctl_stats->ustats.conns = u->conns;
+			ipvs->ctl_stats->ustats.inpkts = u->inpkts;
+			ipvs->ctl_stats->ustats.inbytes = u->inbytes;
+			ipvs->ctl_stats->ustats.outpkts = u->outpkts;
+			ipvs->ctl_stats->ustats.outbytes = u->outbytes;
+		}
+	}
+}
+
 static void estimation_timer(unsigned long arg)
 {
 	struct ip_vs_estimator *e;
@@ -68,6 +93,7 @@ static void estimation_timer(unsigned long arg)
 
 	for_each_net(net) {
 		ipvs = net_ipvs(net);
+		get_stats(ipvs);
 		spin_lock(&ipvs->est_lock);
 		list_for_each_entry(e, &ipvs->est_list, list) {
 			s = container_of(e, struct ip_vs_stats, est);
-- 
1.7.2.3

