From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next] ipvs: use 64-bit rates in stats
Date: Tue, 10 Feb 2015 15:32:09 +0900
Message-ID: <1423549929-25064-2-git-send-email-horms@verge.net.au>
References: <1423549929-25064-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1423549929-25064-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Chris Caputo <ccaputo@alt.net>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

IPVS stats are limited to 2^(32-10) conns/s and packets/s,
2^(32-5) bytes/s. It is time to use 64 bits:

* Change all conn/packet kernel counters to 64-bit and update
them in u64_stats_update_{begin,end} section

* In kernel use struct ip_vs_kstats instead of the user-space
struct ip_vs_stats_user and use new func ip_vs_export_stats_user
to export it to sockopt users to preserve compatibility with
32-bit values

* Rename cpu counters "ustats" to "cnt"

* To netlink users provide additionally 64-bit stats:
IPVS_SVC_ATTR_STATS64 and IPVS_DEST_ATTR_STATS64. Old stats
remain for old binaries.

* We can use ip_vs_copy_stats in ip_vs_stats_percpu_show

Thanks to Chris Caputo for providing initial patch for ip_vs_est.c

Signed-off-by: Chris Caputo <ccaputo@alt.net>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |  50 ++++++++----
 include/uapi/linux/ip_vs.h      |   7 +-
 net/netfilter/ipvs/ip_vs_core.c |  36 +++++----
 net/netfilter/ipvs/ip_vs_ctl.c  | 174 ++++++++++++++++++++++++++--------------
 net/netfilter/ipvs/ip_vs_est.c  | 102 ++++++++++++-----------
 5 files changed, 226 insertions(+), 143 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 615b20b..a627fe6 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -365,15 +365,15 @@ struct ip_vs_seq {
 
 /* counters per cpu */
 struct ip_vs_counters {
-	__u32		conns;		/* connections scheduled */
-	__u32		inpkts;		/* incoming packets */
-	__u32		outpkts;	/* outgoing packets */
+	__u64		conns;		/* connections scheduled */
+	__u64		inpkts;		/* incoming packets */
+	__u64		outpkts;	/* outgoing packets */
 	__u64		inbytes;	/* incoming bytes */
 	__u64		outbytes;	/* outgoing bytes */
 };
 /* Stats per cpu */
 struct ip_vs_cpu_stats {
-	struct ip_vs_counters   ustats;
+	struct ip_vs_counters   cnt;
 	struct u64_stats_sync   syncp;
 };
 
@@ -383,23 +383,40 @@ struct ip_vs_estimator {
 
 	u64			last_inbytes;
 	u64			last_outbytes;
-	u32			last_conns;
-	u32			last_inpkts;
-	u32			last_outpkts;
-
-	u32			cps;
-	u32			inpps;
-	u32			outpps;
-	u32			inbps;
-	u32			outbps;
+	u64			last_conns;
+	u64			last_inpkts;
+	u64			last_outpkts;
+
+	u64			cps;
+	u64			inpps;
+	u64			outpps;
+	u64			inbps;
+	u64			outbps;
+};
+
+/*
+ * IPVS statistics object, 64-bit kernel version of struct ip_vs_stats_user
+ */
+struct ip_vs_kstats {
+	u64			conns;		/* connections scheduled */
+	u64			inpkts;		/* incoming packets */
+	u64			outpkts;	/* outgoing packets */
+	u64			inbytes;	/* incoming bytes */
+	u64			outbytes;	/* outgoing bytes */
+
+	u64			cps;		/* current connection rate */
+	u64			inpps;		/* current in packet rate */
+	u64			outpps;		/* current out packet rate */
+	u64			inbps;		/* current in byte rate */
+	u64			outbps;		/* current out byte rate */
 };
 
 struct ip_vs_stats {
-	struct ip_vs_stats_user	ustats;		/* statistics */
+	struct ip_vs_kstats	kstats;		/* kernel statistics */
 	struct ip_vs_estimator	est;		/* estimator */
 	struct ip_vs_cpu_stats __percpu	*cpustats;	/* per cpu counters */
 	spinlock_t		lock;		/* spin lock */
-	struct ip_vs_stats_user	ustats0;	/* reset values */
+	struct ip_vs_kstats	kstats0;	/* reset values */
 };
 
 struct dst_entry;
@@ -1388,8 +1405,7 @@ void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp, int pkts);
 void ip_vs_start_estimator(struct net *net, struct ip_vs_stats *stats);
 void ip_vs_stop_estimator(struct net *net, struct ip_vs_stats *stats);
 void ip_vs_zero_estimator(struct ip_vs_stats *stats);
-void ip_vs_read_estimator(struct ip_vs_stats_user *dst,
-			  struct ip_vs_stats *stats);
+void ip_vs_read_estimator(struct ip_vs_kstats *dst, struct ip_vs_stats *stats);
 
 /* Various IPVS packet transmitters (from ip_vs_xmit.c) */
 int ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
index cabe95d..3199243 100644
--- a/include/uapi/linux/ip_vs.h
+++ b/include/uapi/linux/ip_vs.h
@@ -358,6 +358,8 @@ enum {
 
 	IPVS_SVC_ATTR_PE_NAME,		/* name of ct retriever */
 
+	IPVS_SVC_ATTR_STATS64,		/* nested attribute for service stats */
+
 	__IPVS_SVC_ATTR_MAX,
 };
 
@@ -387,6 +389,8 @@ enum {
 
 	IPVS_DEST_ATTR_ADDR_FAMILY,	/* Address family of address */
 
+	IPVS_DEST_ATTR_STATS64,		/* nested attribute for dest stats */
+
 	__IPVS_DEST_ATTR_MAX,
 };
 
@@ -410,7 +414,8 @@ enum {
 /*
  * Attributes used to describe service or destination entry statistics
  *
- * Used inside nested attributes IPVS_SVC_ATTR_STATS and IPVS_DEST_ATTR_STATS
+ * Used inside nested attributes IPVS_SVC_ATTR_STATS, IPVS_DEST_ATTR_STATS,
+ * IPVS_SVC_ATTR_STATS64 and IPVS_DEST_ATTR_STATS64.
  */
 enum {
 	IPVS_STATS_ATTR_UNSPEC = 0,
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 990decb..c9470c8 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -119,24 +119,24 @@ ip_vs_in_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 		struct ip_vs_service *svc;
 
 		s = this_cpu_ptr(dest->stats.cpustats);
-		s->ustats.inpkts++;
 		u64_stats_update_begin(&s->syncp);
-		s->ustats.inbytes += skb->len;
+		s->cnt.inpkts++;
+		s->cnt.inbytes += skb->len;
 		u64_stats_update_end(&s->syncp);
 
 		rcu_read_lock();
 		svc = rcu_dereference(dest->svc);
 		s = this_cpu_ptr(svc->stats.cpustats);
-		s->ustats.inpkts++;
 		u64_stats_update_begin(&s->syncp);
-		s->ustats.inbytes += skb->len;
+		s->cnt.inpkts++;
+		s->cnt.inbytes += skb->len;
 		u64_stats_update_end(&s->syncp);
 		rcu_read_unlock();
 
 		s = this_cpu_ptr(ipvs->tot_stats.cpustats);
-		s->ustats.inpkts++;
 		u64_stats_update_begin(&s->syncp);
-		s->ustats.inbytes += skb->len;
+		s->cnt.inpkts++;
+		s->cnt.inbytes += skb->len;
 		u64_stats_update_end(&s->syncp);
 	}
 }
@@ -153,24 +153,24 @@ ip_vs_out_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 		struct ip_vs_service *svc;
 
 		s = this_cpu_ptr(dest->stats.cpustats);
-		s->ustats.outpkts++;
 		u64_stats_update_begin(&s->syncp);
-		s->ustats.outbytes += skb->len;
+		s->cnt.outpkts++;
+		s->cnt.outbytes += skb->len;
 		u64_stats_update_end(&s->syncp);
 
 		rcu_read_lock();
 		svc = rcu_dereference(dest->svc);
 		s = this_cpu_ptr(svc->stats.cpustats);
-		s->ustats.outpkts++;
 		u64_stats_update_begin(&s->syncp);
-		s->ustats.outbytes += skb->len;
+		s->cnt.outpkts++;
+		s->cnt.outbytes += skb->len;
 		u64_stats_update_end(&s->syncp);
 		rcu_read_unlock();
 
 		s = this_cpu_ptr(ipvs->tot_stats.cpustats);
-		s->ustats.outpkts++;
 		u64_stats_update_begin(&s->syncp);
-		s->ustats.outbytes += skb->len;
+		s->cnt.outpkts++;
+		s->cnt.outbytes += skb->len;
 		u64_stats_update_end(&s->syncp);
 	}
 }
@@ -183,13 +183,19 @@ ip_vs_conn_stats(struct ip_vs_conn *cp, struct ip_vs_service *svc)
 	struct ip_vs_cpu_stats *s;
 
 	s = this_cpu_ptr(cp->dest->stats.cpustats);
-	s->ustats.conns++;
+	u64_stats_update_begin(&s->syncp);
+	s->cnt.conns++;
+	u64_stats_update_end(&s->syncp);
 
 	s = this_cpu_ptr(svc->stats.cpustats);
-	s->ustats.conns++;
+	u64_stats_update_begin(&s->syncp);
+	s->cnt.conns++;
+	u64_stats_update_end(&s->syncp);
 
 	s = this_cpu_ptr(ipvs->tot_stats.cpustats);
-	s->ustats.conns++;
+	u64_stats_update_begin(&s->syncp);
+	s->cnt.conns++;
+	u64_stats_update_end(&s->syncp);
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index e557590..6fd6005 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -729,9 +729,9 @@ static void ip_vs_trash_cleanup(struct net *net)
 }
 
 static void
-ip_vs_copy_stats(struct ip_vs_stats_user *dst, struct ip_vs_stats *src)
+ip_vs_copy_stats(struct ip_vs_kstats *dst, struct ip_vs_stats *src)
 {
-#define IP_VS_SHOW_STATS_COUNTER(c) dst->c = src->ustats.c - src->ustats0.c
+#define IP_VS_SHOW_STATS_COUNTER(c) dst->c = src->kstats.c - src->kstats0.c
 
 	spin_lock_bh(&src->lock);
 
@@ -747,13 +747,28 @@ ip_vs_copy_stats(struct ip_vs_stats_user *dst, struct ip_vs_stats *src)
 }
 
 static void
+ip_vs_export_stats_user(struct ip_vs_stats_user *dst, struct ip_vs_kstats *src)
+{
+	dst->conns = (u32)src->conns;
+	dst->inpkts = (u32)src->inpkts;
+	dst->outpkts = (u32)src->outpkts;
+	dst->inbytes = src->inbytes;
+	dst->outbytes = src->outbytes;
+	dst->cps = (u32)src->cps;
+	dst->inpps = (u32)src->inpps;
+	dst->outpps = (u32)src->outpps;
+	dst->inbps = (u32)src->inbps;
+	dst->outbps = (u32)src->outbps;
+}
+
+static void
 ip_vs_zero_stats(struct ip_vs_stats *stats)
 {
 	spin_lock_bh(&stats->lock);
 
 	/* get current counters as zero point, rates are zeroed */
 
-#define IP_VS_ZERO_STATS_COUNTER(c) stats->ustats0.c = stats->ustats.c
+#define IP_VS_ZERO_STATS_COUNTER(c) stats->kstats0.c = stats->kstats.c
 
 	IP_VS_ZERO_STATS_COUNTER(conns);
 	IP_VS_ZERO_STATS_COUNTER(inpkts);
@@ -2044,7 +2059,7 @@ static const struct file_operations ip_vs_info_fops = {
 static int ip_vs_stats_show(struct seq_file *seq, void *v)
 {
 	struct net *net = seq_file_single_net(seq);
-	struct ip_vs_stats_user show;
+	struct ip_vs_kstats show;
 
 /*               01234567 01234567 01234567 0123456701234567 0123456701234567 */
 	seq_puts(seq,
@@ -2053,17 +2068,22 @@ static int ip_vs_stats_show(struct seq_file *seq, void *v)
 		   "   Conns  Packets  Packets            Bytes            Bytes\n");
 
 	ip_vs_copy_stats(&show, &net_ipvs(net)->tot_stats);
-	seq_printf(seq, "%8X %8X %8X %16LX %16LX\n\n", show.conns,
-		   show.inpkts, show.outpkts,
-		   (unsigned long long) show.inbytes,
-		   (unsigned long long) show.outbytes);
-
-/*                 01234567 01234567 01234567 0123456701234567 0123456701234567 */
+	seq_printf(seq, "%8LX %8LX %8LX %16LX %16LX\n\n",
+		   (unsigned long long)show.conns,
+		   (unsigned long long)show.inpkts,
+		   (unsigned long long)show.outpkts,
+		   (unsigned long long)show.inbytes,
+		   (unsigned long long)show.outbytes);
+
+/*                01234567 01234567 01234567 0123456701234567 0123456701234567*/
 	seq_puts(seq,
-		   " Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s\n");
-	seq_printf(seq, "%8X %8X %8X %16X %16X\n",
-			show.cps, show.inpps, show.outpps,
-			show.inbps, show.outbps);
+		 " Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s\n");
+	seq_printf(seq, "%8LX %8LX %8LX %16LX %16LX\n",
+		   (unsigned long long)show.cps,
+		   (unsigned long long)show.inpps,
+		   (unsigned long long)show.outpps,
+		   (unsigned long long)show.inbps,
+		   (unsigned long long)show.outbps);
 
 	return 0;
 }
@@ -2086,7 +2106,7 @@ static int ip_vs_stats_percpu_show(struct seq_file *seq, void *v)
 	struct net *net = seq_file_single_net(seq);
 	struct ip_vs_stats *tot_stats = &net_ipvs(net)->tot_stats;
 	struct ip_vs_cpu_stats __percpu *cpustats = tot_stats->cpustats;
-	struct ip_vs_stats_user rates;
+	struct ip_vs_kstats kstats;
 	int i;
 
 /*               01234567 01234567 01234567 0123456701234567 0123456701234567 */
@@ -2098,41 +2118,41 @@ static int ip_vs_stats_percpu_show(struct seq_file *seq, void *v)
 	for_each_possible_cpu(i) {
 		struct ip_vs_cpu_stats *u = per_cpu_ptr(cpustats, i);
 		unsigned int start;
-		__u64 inbytes, outbytes;
+		u64 conns, inpkts, outpkts, inbytes, outbytes;
 
 		do {
 			start = u64_stats_fetch_begin_irq(&u->syncp);
-			inbytes = u->ustats.inbytes;
-			outbytes = u->ustats.outbytes;
+			conns = u->cnt.conns;
+			inpkts = u->cnt.inpkts;
+			outpkts = u->cnt.outpkts;
+			inbytes = u->cnt.inbytes;
+			outbytes = u->cnt.outbytes;
 		} while (u64_stats_fetch_retry_irq(&u->syncp, start));
 
-		seq_printf(seq, "%3X %8X %8X %8X %16LX %16LX\n",
-			   i, u->ustats.conns, u->ustats.inpkts,
-			   u->ustats.outpkts, (__u64)inbytes,
-			   (__u64)outbytes);
+		seq_printf(seq, "%3X %8LX %8LX %8LX %16LX %16LX\n",
+			   i, (u64)conns, (u64)inpkts,
+			   (u64)outpkts, (u64)inbytes,
+			   (u64)outbytes);
 	}
 
-	spin_lock_bh(&tot_stats->lock);
-
-	seq_printf(seq, "  ~ %8X %8X %8X %16LX %16LX\n\n",
-		   tot_stats->ustats.conns, tot_stats->ustats.inpkts,
-		   tot_stats->ustats.outpkts,
-		   (unsigned long long) tot_stats->ustats.inbytes,
-		   (unsigned long long) tot_stats->ustats.outbytes);
-
-	ip_vs_read_estimator(&rates, tot_stats);
+	ip_vs_copy_stats(&kstats, tot_stats);
 
-	spin_unlock_bh(&tot_stats->lock);
+	seq_printf(seq, "  ~ %8LX %8LX %8LX %16LX %16LX\n\n",
+		   (unsigned long long)kstats.conns,
+		   (unsigned long long)kstats.inpkts,
+		   (unsigned long long)kstats.outpkts,
+		   (unsigned long long)kstats.inbytes,
+		   (unsigned long long)kstats.outbytes);
 
-/*                 01234567 01234567 01234567 0123456701234567 0123456701234567 */
+/*                ... 01234567 01234567 01234567 0123456701234567 0123456701234567 */
 	seq_puts(seq,
-		   "     Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s\n");
-	seq_printf(seq, "    %8X %8X %8X %16X %16X\n",
-			rates.cps,
-			rates.inpps,
-			rates.outpps,
-			rates.inbps,
-			rates.outbps);
+		 "     Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s\n");
+	seq_printf(seq, "    %8LX %8LX %8LX %16LX %16LX\n",
+		   kstats.cps,
+		   kstats.inpps,
+		   kstats.outpps,
+		   kstats.inbps,
+		   kstats.outbps);
 
 	return 0;
 }
@@ -2400,6 +2420,7 @@ static void
 ip_vs_copy_service(struct ip_vs_service_entry *dst, struct ip_vs_service *src)
 {
 	struct ip_vs_scheduler *sched;
+	struct ip_vs_kstats kstats;
 
 	sched = rcu_dereference_protected(src->scheduler, 1);
 	dst->protocol = src->protocol;
@@ -2411,7 +2432,8 @@ ip_vs_copy_service(struct ip_vs_service_entry *dst, struct ip_vs_service *src)
 	dst->timeout = src->timeout / HZ;
 	dst->netmask = src->netmask;
 	dst->num_dests = src->num_dests;
-	ip_vs_copy_stats(&dst->stats, &src->stats);
+	ip_vs_copy_stats(&kstats, &src->stats);
+	ip_vs_export_stats_user(&dst->stats, &kstats);
 }
 
 static inline int
@@ -2485,6 +2507,7 @@ __ip_vs_get_dest_entries(struct net *net, const struct ip_vs_get_dests *get,
 		int count = 0;
 		struct ip_vs_dest *dest;
 		struct ip_vs_dest_entry entry;
+		struct ip_vs_kstats kstats;
 
 		memset(&entry, 0, sizeof(entry));
 		list_for_each_entry(dest, &svc->destinations, n_list) {
@@ -2506,7 +2529,8 @@ __ip_vs_get_dest_entries(struct net *net, const struct ip_vs_get_dests *get,
 			entry.activeconns = atomic_read(&dest->activeconns);
 			entry.inactconns = atomic_read(&dest->inactconns);
 			entry.persistconns = atomic_read(&dest->persistconns);
-			ip_vs_copy_stats(&entry.stats, &dest->stats);
+			ip_vs_copy_stats(&kstats, &dest->stats);
+			ip_vs_export_stats_user(&entry.stats, &kstats);
 			if (copy_to_user(&uptr->entrytable[count],
 					 &entry, sizeof(entry))) {
 				ret = -EFAULT;
@@ -2798,25 +2822,51 @@ static const struct nla_policy ip_vs_dest_policy[IPVS_DEST_ATTR_MAX + 1] = {
 };
 
 static int ip_vs_genl_fill_stats(struct sk_buff *skb, int container_type,
-				 struct ip_vs_stats *stats)
+				 struct ip_vs_kstats *kstats)
+{
+	struct nlattr *nl_stats = nla_nest_start(skb, container_type);
+
+	if (!nl_stats)
+		return -EMSGSIZE;
+
+	if (nla_put_u32(skb, IPVS_STATS_ATTR_CONNS, (u32)kstats->conns) ||
+	    nla_put_u32(skb, IPVS_STATS_ATTR_INPKTS, (u32)kstats->inpkts) ||
+	    nla_put_u32(skb, IPVS_STATS_ATTR_OUTPKTS, (u32)kstats->outpkts) ||
+	    nla_put_u64(skb, IPVS_STATS_ATTR_INBYTES, kstats->inbytes) ||
+	    nla_put_u64(skb, IPVS_STATS_ATTR_OUTBYTES, kstats->outbytes) ||
+	    nla_put_u32(skb, IPVS_STATS_ATTR_CPS, (u32)kstats->cps) ||
+	    nla_put_u32(skb, IPVS_STATS_ATTR_INPPS, (u32)kstats->inpps) ||
+	    nla_put_u32(skb, IPVS_STATS_ATTR_OUTPPS, (u32)kstats->outpps) ||
+	    nla_put_u32(skb, IPVS_STATS_ATTR_INBPS, (u32)kstats->inbps) ||
+	    nla_put_u32(skb, IPVS_STATS_ATTR_OUTBPS, (u32)kstats->outbps))
+		goto nla_put_failure;
+	nla_nest_end(skb, nl_stats);
+
+	return 0;
+
+nla_put_failure:
+	nla_nest_cancel(skb, nl_stats);
+	return -EMSGSIZE;
+}
+
+static int ip_vs_genl_fill_stats64(struct sk_buff *skb, int container_type,
+				   struct ip_vs_kstats *kstats)
 {
-	struct ip_vs_stats_user ustats;
 	struct nlattr *nl_stats = nla_nest_start(skb, container_type);
+
 	if (!nl_stats)
 		return -EMSGSIZE;
 
-	ip_vs_copy_stats(&ustats, stats);
-
-	if (nla_put_u32(skb, IPVS_STATS_ATTR_CONNS, ustats.conns) ||
-	    nla_put_u32(skb, IPVS_STATS_ATTR_INPKTS, ustats.inpkts) ||
-	    nla_put_u32(skb, IPVS_STATS_ATTR_OUTPKTS, ustats.outpkts) ||
-	    nla_put_u64(skb, IPVS_STATS_ATTR_INBYTES, ustats.inbytes) ||
-	    nla_put_u64(skb, IPVS_STATS_ATTR_OUTBYTES, ustats.outbytes) ||
-	    nla_put_u32(skb, IPVS_STATS_ATTR_CPS, ustats.cps) ||
-	    nla_put_u32(skb, IPVS_STATS_ATTR_INPPS, ustats.inpps) ||
-	    nla_put_u32(skb, IPVS_STATS_ATTR_OUTPPS, ustats.outpps) ||
-	    nla_put_u32(skb, IPVS_STATS_ATTR_INBPS, ustats.inbps) ||
-	    nla_put_u32(skb, IPVS_STATS_ATTR_OUTBPS, ustats.outbps))
+	if (nla_put_u64(skb, IPVS_STATS_ATTR_CONNS, kstats->conns) ||
+	    nla_put_u64(skb, IPVS_STATS_ATTR_INPKTS, kstats->inpkts) ||
+	    nla_put_u64(skb, IPVS_STATS_ATTR_OUTPKTS, kstats->outpkts) ||
+	    nla_put_u64(skb, IPVS_STATS_ATTR_INBYTES, kstats->inbytes) ||
+	    nla_put_u64(skb, IPVS_STATS_ATTR_OUTBYTES, kstats->outbytes) ||
+	    nla_put_u64(skb, IPVS_STATS_ATTR_CPS, kstats->cps) ||
+	    nla_put_u64(skb, IPVS_STATS_ATTR_INPPS, kstats->inpps) ||
+	    nla_put_u64(skb, IPVS_STATS_ATTR_OUTPPS, kstats->outpps) ||
+	    nla_put_u64(skb, IPVS_STATS_ATTR_INBPS, kstats->inbps) ||
+	    nla_put_u64(skb, IPVS_STATS_ATTR_OUTBPS, kstats->outbps))
 		goto nla_put_failure;
 	nla_nest_end(skb, nl_stats);
 
@@ -2835,6 +2885,7 @@ static int ip_vs_genl_fill_service(struct sk_buff *skb,
 	struct nlattr *nl_service;
 	struct ip_vs_flags flags = { .flags = svc->flags,
 				     .mask = ~0 };
+	struct ip_vs_kstats kstats;
 
 	nl_service = nla_nest_start(skb, IPVS_CMD_ATTR_SERVICE);
 	if (!nl_service)
@@ -2860,7 +2911,10 @@ static int ip_vs_genl_fill_service(struct sk_buff *skb,
 	    nla_put_u32(skb, IPVS_SVC_ATTR_TIMEOUT, svc->timeout / HZ) ||
 	    nla_put_be32(skb, IPVS_SVC_ATTR_NETMASK, svc->netmask))
 		goto nla_put_failure;
-	if (ip_vs_genl_fill_stats(skb, IPVS_SVC_ATTR_STATS, &svc->stats))
+	ip_vs_copy_stats(&kstats, &svc->stats);
+	if (ip_vs_genl_fill_stats(skb, IPVS_SVC_ATTR_STATS, &kstats))
+		goto nla_put_failure;
+	if (ip_vs_genl_fill_stats64(skb, IPVS_SVC_ATTR_STATS64, &kstats))
 		goto nla_put_failure;
 
 	nla_nest_end(skb, nl_service);
@@ -3032,6 +3086,7 @@ static struct ip_vs_service *ip_vs_genl_find_service(struct net *net,
 static int ip_vs_genl_fill_dest(struct sk_buff *skb, struct ip_vs_dest *dest)
 {
 	struct nlattr *nl_dest;
+	struct ip_vs_kstats kstats;
 
 	nl_dest = nla_nest_start(skb, IPVS_CMD_ATTR_DEST);
 	if (!nl_dest)
@@ -3054,7 +3109,10 @@ static int ip_vs_genl_fill_dest(struct sk_buff *skb, struct ip_vs_dest *dest)
 			atomic_read(&dest->persistconns)) ||
 	    nla_put_u16(skb, IPVS_DEST_ATTR_ADDR_FAMILY, dest->af))
 		goto nla_put_failure;
-	if (ip_vs_genl_fill_stats(skb, IPVS_DEST_ATTR_STATS, &dest->stats))
+	ip_vs_copy_stats(&kstats, &dest->stats);
+	if (ip_vs_genl_fill_stats(skb, IPVS_DEST_ATTR_STATS, &kstats))
+		goto nla_put_failure;
+	if (ip_vs_genl_fill_stats64(skb, IPVS_DEST_ATTR_STATS64, &kstats))
 		goto nla_put_failure;
 
 	nla_nest_end(skb, nl_dest);
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 1425e9a..ef0eb0a 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -45,17 +45,19 @@
 
   NOTES.
 
-  * The stored value for average bps is scaled by 2^5, so that maximal
-    rate is ~2.15Gbits/s, average pps and cps are scaled by 2^10.
+  * Average bps is scaled by 2^5, while average pps and cps are scaled by 2^10.
 
-  * A lot code is taken from net/sched/estimator.c
+  * Netlink users can see 64-bit values but sockopt users are restricted
+    to 32-bit values for conns, packets, bps, cps and pps.
+
+  * A lot of code is taken from net/core/gen_estimator.c
  */
 
 
 /*
  * Make a summary from each cpu
  */
-static void ip_vs_read_cpu_stats(struct ip_vs_stats_user *sum,
+static void ip_vs_read_cpu_stats(struct ip_vs_kstats *sum,
 				 struct ip_vs_cpu_stats __percpu *stats)
 {
 	int i;
@@ -64,27 +66,31 @@ static void ip_vs_read_cpu_stats(struct ip_vs_stats_user *sum,
 	for_each_possible_cpu(i) {
 		struct ip_vs_cpu_stats *s = per_cpu_ptr(stats, i);
 		unsigned int start;
-		__u64 inbytes, outbytes;
+		u64 conns, inpkts, outpkts, inbytes, outbytes;
+
 		if (add) {
-			sum->conns += s->ustats.conns;
-			sum->inpkts += s->ustats.inpkts;
-			sum->outpkts += s->ustats.outpkts;
 			do {
 				start = u64_stats_fetch_begin(&s->syncp);
-				inbytes = s->ustats.inbytes;
-				outbytes = s->ustats.outbytes;
+				conns = s->cnt.conns;
+				inpkts = s->cnt.inpkts;
+				outpkts = s->cnt.outpkts;
+				inbytes = s->cnt.inbytes;
+				outbytes = s->cnt.outbytes;
 			} while (u64_stats_fetch_retry(&s->syncp, start));
+			sum->conns += conns;
+			sum->inpkts += inpkts;
+			sum->outpkts += outpkts;
 			sum->inbytes += inbytes;
 			sum->outbytes += outbytes;
 		} else {
 			add = true;
-			sum->conns = s->ustats.conns;
-			sum->inpkts = s->ustats.inpkts;
-			sum->outpkts = s->ustats.outpkts;
 			do {
 				start = u64_stats_fetch_begin(&s->syncp);
-				sum->inbytes = s->ustats.inbytes;
-				sum->outbytes = s->ustats.outbytes;
+				sum->conns = s->cnt.conns;
+				sum->inpkts = s->cnt.inpkts;
+				sum->outpkts = s->cnt.outpkts;
+				sum->inbytes = s->cnt.inbytes;
+				sum->outbytes = s->cnt.outbytes;
 			} while (u64_stats_fetch_retry(&s->syncp, start));
 		}
 	}
@@ -95,10 +101,7 @@ static void estimation_timer(unsigned long arg)
 {
 	struct ip_vs_estimator *e;
 	struct ip_vs_stats *s;
-	u32 n_conns;
-	u32 n_inpkts, n_outpkts;
-	u64 n_inbytes, n_outbytes;
-	u32 rate;
+	u64 rate;
 	struct net *net = (struct net *)arg;
 	struct netns_ipvs *ipvs;
 
@@ -108,33 +111,29 @@ static void estimation_timer(unsigned long arg)
 		s = container_of(e, struct ip_vs_stats, est);
 
 		spin_lock(&s->lock);
-		ip_vs_read_cpu_stats(&s->ustats, s->cpustats);
-		n_conns = s->ustats.conns;
-		n_inpkts = s->ustats.inpkts;
-		n_outpkts = s->ustats.outpkts;
-		n_inbytes = s->ustats.inbytes;
-		n_outbytes = s->ustats.outbytes;
+		ip_vs_read_cpu_stats(&s->kstats, s->cpustats);
 
 		/* scaled by 2^10, but divided 2 seconds */
-		rate = (n_conns - e->last_conns) << 9;
-		e->last_conns = n_conns;
-		e->cps += ((long)rate - (long)e->cps) >> 2;
-
-		rate = (n_inpkts - e->last_inpkts) << 9;
-		e->last_inpkts = n_inpkts;
-		e->inpps += ((long)rate - (long)e->inpps) >> 2;
-
-		rate = (n_outpkts - e->last_outpkts) << 9;
-		e->last_outpkts = n_outpkts;
-		e->outpps += ((long)rate - (long)e->outpps) >> 2;
-
-		rate = (n_inbytes - e->last_inbytes) << 4;
-		e->last_inbytes = n_inbytes;
-		e->inbps += ((long)rate - (long)e->inbps) >> 2;
-
-		rate = (n_outbytes - e->last_outbytes) << 4;
-		e->last_outbytes = n_outbytes;
-		e->outbps += ((long)rate - (long)e->outbps) >> 2;
+		rate = (s->kstats.conns - e->last_conns) << 9;
+		e->last_conns = s->kstats.conns;
+		e->cps += ((s64)rate - (s64)e->cps) >> 2;
+
+		rate = (s->kstats.inpkts - e->last_inpkts) << 9;
+		e->last_inpkts = s->kstats.inpkts;
+		e->inpps += ((s64)rate - (s64)e->inpps) >> 2;
+
+		rate = (s->kstats.outpkts - e->last_outpkts) << 9;
+		e->last_outpkts = s->kstats.outpkts;
+		e->outpps += ((s64)rate - (s64)e->outpps) >> 2;
+
+		/* scaled by 2^5, but divided 2 seconds */
+		rate = (s->kstats.inbytes - e->last_inbytes) << 4;
+		e->last_inbytes = s->kstats.inbytes;
+		e->inbps += ((s64)rate - (s64)e->inbps) >> 2;
+
+		rate = (s->kstats.outbytes - e->last_outbytes) << 4;
+		e->last_outbytes = s->kstats.outbytes;
+		e->outbps += ((s64)rate - (s64)e->outbps) >> 2;
 		spin_unlock(&s->lock);
 	}
 	spin_unlock(&ipvs->est_lock);
@@ -166,14 +165,14 @@ void ip_vs_stop_estimator(struct net *net, struct ip_vs_stats *stats)
 void ip_vs_zero_estimator(struct ip_vs_stats *stats)
 {
 	struct ip_vs_estimator *est = &stats->est;
-	struct ip_vs_stats_user *u = &stats->ustats;
+	struct ip_vs_kstats *k = &stats->kstats;
 
 	/* reset counters, caller must hold the stats->lock lock */
-	est->last_inbytes = u->inbytes;
-	est->last_outbytes = u->outbytes;
-	est->last_conns = u->conns;
-	est->last_inpkts = u->inpkts;
-	est->last_outpkts = u->outpkts;
+	est->last_inbytes = k->inbytes;
+	est->last_outbytes = k->outbytes;
+	est->last_conns = k->conns;
+	est->last_inpkts = k->inpkts;
+	est->last_outpkts = k->outpkts;
 	est->cps = 0;
 	est->inpps = 0;
 	est->outpps = 0;
@@ -182,8 +181,7 @@ void ip_vs_zero_estimator(struct ip_vs_stats *stats)
 }
 
 /* Get decoded rates */
-void ip_vs_read_estimator(struct ip_vs_stats_user *dst,
-			  struct ip_vs_stats *stats)
+void ip_vs_read_estimator(struct ip_vs_kstats *dst, struct ip_vs_stats *stats)
 {
 	struct ip_vs_estimator *e = &stats->est;
 
-- 
2.1.4

