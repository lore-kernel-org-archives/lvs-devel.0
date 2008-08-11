From: Sven Wegener <sven.wegener@stealer.net>
Subject: [GIT] Please pull updates for IPVS
Date: Mon, 11 Aug 2008 23:46:50 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0808112318510.12259@titan.stealer.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, horms@verge.net.au

Hi Dave,

I have a couple of updates for IPVS pending. The patches have been
posted to the mailing-list and acked by Simon Horman, so I thought it's
ok to send you a pull request for them, if that's ok with you.

Mostly trivial cleanups. Two potential deadlock fixes, one introduced by
my last sync daemon changes and one in the estimator code, which is
going back for years. The other estimator change is the biggest one. If
you have an issue with something, just holler and I'll get on it. I'll
append an overall diff as it's not that big.

Thanks!

The following changes since commit 8123b421e8ed944671d7241323ed3198cccb4041:
  David S. Miller (1):
        pkt_sched: Fix ingress deletion and filter attachment.

are available in the git repository at:

  git://git.stealer.net/linux-2.6.git stealer/ipvs/for-davem

Simon Horman (1):
      ipvs: Explictly clear ip_vs_stats members

Sven Wegener (9):
      ipvs: Fix possible deadlock in sync code
      ipvs: Fix possible deadlock in estimator code
      ipvs: Use ARRAY_SIZE()
      ipvs: Use list_empty() instead of open-coding the same functionality
      ipvs: Initialize schedulers' struct list_head at compile time
      ipvs: Annotate init functions with __init
      ipvs: Mark net_vs_ctl_path const
      ipvs: Embed estimator object into stats object
      ipvs: No need to zero out ip_vs_stats during initialization

 include/net/ip_vs.h         |   32 ++++++++++--
 net/ipv4/ipvs/ip_vs_app.c   |    2 +-
 net/ipv4/ipvs/ip_vs_conn.c  |    2 +-
 net/ipv4/ipvs/ip_vs_ctl.c   |   27 +++++++---
 net/ipv4/ipvs/ip_vs_dh.c    |    2 +-
 net/ipv4/ipvs/ip_vs_est.c   |  116 ++++++++++++++----------------------------
 net/ipv4/ipvs/ip_vs_lblc.c  |    2 +-
 net/ipv4/ipvs/ip_vs_lblcr.c |    2 +-
 net/ipv4/ipvs/ip_vs_lc.c    |    2 +-
 net/ipv4/ipvs/ip_vs_nq.c    |    2 +-
 net/ipv4/ipvs/ip_vs_proto.c |    4 +-
 net/ipv4/ipvs/ip_vs_rr.c    |    2 +-
 net/ipv4/ipvs/ip_vs_sched.c |    4 +-
 net/ipv4/ipvs/ip_vs_sed.c   |    2 +-
 net/ipv4/ipvs/ip_vs_sh.c    |    2 +-
 net/ipv4/ipvs/ip_vs_sync.c  |    4 +-
 net/ipv4/ipvs/ip_vs_wlc.c   |    2 +-
 net/ipv4/ipvs/ip_vs_wrr.c   |    2 +-
 18 files changed, 105 insertions(+), 106 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index cbb59eb..7312c3d 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -140,8 +140,24 @@ struct ip_vs_seq {
 
 
 /*
- *	IPVS statistics object
+ *	IPVS statistics objects
  */
+struct ip_vs_estimator {
+	struct list_head	list;
+
+	u64			last_inbytes;
+	u64			last_outbytes;
+	u32			last_conns;
+	u32			last_inpkts;
+	u32			last_outpkts;
+
+	u32			cps;
+	u32			inpps;
+	u32			outpps;
+	u32			inbps;
+	u32			outbps;
+};
+
 struct ip_vs_stats
 {
 	__u32                   conns;          /* connections scheduled */
@@ -156,7 +172,15 @@ struct ip_vs_stats
 	__u32			inbps;		/* current in byte rate */
 	__u32			outbps;		/* current out byte rate */
 
+	/*
+	 * Don't add anything before the lock, because we use memcpy() to copy
+	 * the members before the lock to struct ip_vs_stats_user in
+	 * ip_vs_ctl.c.
+	 */
+
 	spinlock_t              lock;           /* spin lock */
+
+	struct ip_vs_estimator	est;		/* estimator */
 };
 
 struct dst_entry;
@@ -440,7 +464,7 @@ struct ip_vs_app
  */
 extern const char *ip_vs_proto_name(unsigned proto);
 extern void ip_vs_init_hash_table(struct list_head *table, int rows);
-#define IP_VS_INIT_HASH_TABLE(t) ip_vs_init_hash_table(t, sizeof(t)/sizeof(t[0]))
+#define IP_VS_INIT_HASH_TABLE(t) ip_vs_init_hash_table((t), ARRAY_SIZE((t)))
 
 #define IP_VS_APP_TYPE_FTP	1
 
@@ -620,7 +644,7 @@ extern int sysctl_ip_vs_expire_quiescent_template;
 extern int sysctl_ip_vs_sync_threshold[2];
 extern int sysctl_ip_vs_nat_icmp_send;
 extern struct ip_vs_stats ip_vs_stats;
-extern struct ctl_path net_vs_ctl_path[];
+extern const struct ctl_path net_vs_ctl_path[];
 
 extern struct ip_vs_service *
 ip_vs_service_get(__u32 fwmark, __u16 protocol, __be32 vaddr, __be16 vport);
@@ -659,7 +683,7 @@ extern void ip_vs_sync_conn(struct ip_vs_conn *cp);
 /*
  *      IPVS rate estimator prototypes (from ip_vs_est.c)
  */
-extern int ip_vs_new_estimator(struct ip_vs_stats *stats);
+extern void ip_vs_new_estimator(struct ip_vs_stats *stats);
 extern void ip_vs_kill_estimator(struct ip_vs_stats *stats);
 extern void ip_vs_zero_estimator(struct ip_vs_stats *stats);
 
diff --git a/net/ipv4/ipvs/ip_vs_app.c b/net/ipv4/ipvs/ip_vs_app.c
index 1f1897a..201b8ea 100644
--- a/net/ipv4/ipvs/ip_vs_app.c
+++ b/net/ipv4/ipvs/ip_vs_app.c
@@ -608,7 +608,7 @@ int ip_vs_skb_replace(struct sk_buff *skb, gfp_t pri,
 }
 
 
-int ip_vs_app_init(void)
+int __init ip_vs_app_init(void)
 {
 	/* we will replace it with proc_net_ipvs_create() soon */
 	proc_net_fops_create(&init_net, "ip_vs_app", 0, &ip_vs_app_fops);
diff --git a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
index f8bdae4..44a6872 100644
--- a/net/ipv4/ipvs/ip_vs_conn.c
+++ b/net/ipv4/ipvs/ip_vs_conn.c
@@ -965,7 +965,7 @@ static void ip_vs_conn_flush(void)
 }
 
 
-int ip_vs_conn_init(void)
+int __init ip_vs_conn_init(void)
 {
 	int idx;
 
diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index 9a5ace0..6379705 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -683,9 +683,22 @@ static void
 ip_vs_zero_stats(struct ip_vs_stats *stats)
 {
 	spin_lock_bh(&stats->lock);
-	memset(stats, 0, (char *)&stats->lock - (char *)stats);
-	spin_unlock_bh(&stats->lock);
+
+	stats->conns = 0;
+	stats->inpkts = 0;
+	stats->outpkts = 0;
+	stats->inbytes = 0;
+	stats->outbytes = 0;
+
+	stats->cps = 0;
+	stats->inpps = 0;
+	stats->outpps = 0;
+	stats->inbps = 0;
+	stats->outbps = 0;
+
 	ip_vs_zero_estimator(stats);
+
+	spin_unlock_bh(&stats->lock);
 }
 
 /*
@@ -1589,7 +1602,7 @@ static struct ctl_table vs_vars[] = {
 	{ .ctl_name = 0 }
 };
 
-struct ctl_path net_vs_ctl_path[] = {
+const struct ctl_path net_vs_ctl_path[] = {
 	{ .procname = "net", .ctl_name = CTL_NET, },
 	{ .procname = "ipv4", .ctl_name = NET_IPV4, },
 	{ .procname = "vs", },
@@ -1784,7 +1797,9 @@ static const struct file_operations ip_vs_info_fops = {
 
 #endif
 
-struct ip_vs_stats ip_vs_stats;
+struct ip_vs_stats ip_vs_stats = {
+	.lock = __SPIN_LOCK_UNLOCKED(ip_vs_stats.lock),
+};
 
 #ifdef CONFIG_PROC_FS
 static int ip_vs_stats_show(struct seq_file *seq, void *v)
@@ -2306,7 +2321,7 @@ static struct nf_sockopt_ops ip_vs_sockopts = {
 };
 
 
-int ip_vs_control_init(void)
+int __init ip_vs_control_init(void)
 {
 	int ret;
 	int idx;
@@ -2333,8 +2348,6 @@ int ip_vs_control_init(void)
 		INIT_LIST_HEAD(&ip_vs_rtable[idx]);
 	}
 
-	memset(&ip_vs_stats, 0, sizeof(ip_vs_stats));
-	spin_lock_init(&ip_vs_stats.lock);
 	ip_vs_new_estimator(&ip_vs_stats);
 
 	/* Hook the defense timer */
diff --git a/net/ipv4/ipvs/ip_vs_dh.c b/net/ipv4/ipvs/ip_vs_dh.c
index 8afc150..fa66824 100644
--- a/net/ipv4/ipvs/ip_vs_dh.c
+++ b/net/ipv4/ipvs/ip_vs_dh.c
@@ -233,6 +233,7 @@ static struct ip_vs_scheduler ip_vs_dh_scheduler =
 	.name =			"dh",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+	.n_list =		LIST_HEAD_INIT(ip_vs_dh_scheduler.n_list),
 	.init_service =		ip_vs_dh_init_svc,
 	.done_service =		ip_vs_dh_done_svc,
 	.update_service =	ip_vs_dh_update_svc,
@@ -242,7 +243,6 @@ static struct ip_vs_scheduler ip_vs_dh_scheduler =
 
 static int __init ip_vs_dh_init(void)
 {
-	INIT_LIST_HEAD(&ip_vs_dh_scheduler.n_list);
 	return register_ip_vs_scheduler(&ip_vs_dh_scheduler);
 }
 
diff --git a/net/ipv4/ipvs/ip_vs_est.c b/net/ipv4/ipvs/ip_vs_est.c
index bc04eed..5a20f93 100644
--- a/net/ipv4/ipvs/ip_vs_est.c
+++ b/net/ipv4/ipvs/ip_vs_est.c
@@ -17,6 +17,7 @@
 #include <linux/types.h>
 #include <linux/interrupt.h>
 #include <linux/sysctl.h>
+#include <linux/list.h>
 
 #include <net/ip_vs.h>
 
@@ -44,28 +45,11 @@
  */
 
 
-struct ip_vs_estimator
-{
-	struct ip_vs_estimator	*next;
-	struct ip_vs_stats	*stats;
-
-	u32			last_conns;
-	u32			last_inpkts;
-	u32			last_outpkts;
-	u64			last_inbytes;
-	u64			last_outbytes;
-
-	u32			cps;
-	u32			inpps;
-	u32			outpps;
-	u32			inbps;
-	u32			outbps;
-};
-
+static void estimation_timer(unsigned long arg);
 
-static struct ip_vs_estimator *est_list = NULL;
-static DEFINE_RWLOCK(est_lock);
-static struct timer_list est_timer;
+static LIST_HEAD(est_list);
+static DEFINE_SPINLOCK(est_lock);
+static DEFINE_TIMER(est_timer, estimation_timer, 0, 0);
 
 static void estimation_timer(unsigned long arg)
 {
@@ -76,9 +60,9 @@ static void estimation_timer(unsigned long arg)
 	u64 n_inbytes, n_outbytes;
 	u32 rate;
 
-	read_lock(&est_lock);
-	for (e = est_list; e; e = e->next) {
-		s = e->stats;
+	spin_lock(&est_lock);
+	list_for_each_entry(e, &est_list, list) {
+		s = container_of(e, struct ip_vs_stats, est);
 
 		spin_lock(&s->lock);
 		n_conns = s->conns;
@@ -114,19 +98,16 @@ static void estimation_timer(unsigned long arg)
 		s->outbps = (e->outbps+0xF)>>5;
 		spin_unlock(&s->lock);
 	}
-	read_unlock(&est_lock);
+	spin_unlock(&est_lock);
 	mod_timer(&est_timer, jiffies + 2*HZ);
 }
 
-int ip_vs_new_estimator(struct ip_vs_stats *stats)
+void ip_vs_new_estimator(struct ip_vs_stats *stats)
 {
-	struct ip_vs_estimator *est;
+	struct ip_vs_estimator *est = &stats->est;
 
-	est = kzalloc(sizeof(*est), GFP_KERNEL);
-	if (est == NULL)
-		return -ENOMEM;
+	INIT_LIST_HEAD(&est->list);
 
-	est->stats = stats;
 	est->last_conns = stats->conns;
 	est->cps = stats->cps<<10;
 
@@ -142,59 +123,40 @@ int ip_vs_new_estimator(struct ip_vs_stats *stats)
 	est->last_outbytes = stats->outbytes;
 	est->outbps = stats->outbps<<5;
 
-	write_lock_bh(&est_lock);
-	est->next = est_list;
-	if (est->next == NULL) {
-		setup_timer(&est_timer, estimation_timer, 0);
-		est_timer.expires = jiffies + 2*HZ;
-		add_timer(&est_timer);
-	}
-	est_list = est;
-	write_unlock_bh(&est_lock);
-	return 0;
+	spin_lock_bh(&est_lock);
+	if (list_empty(&est_list))
+		mod_timer(&est_timer, jiffies + 2 * HZ);
+	list_add(&est->list, &est_list);
+	spin_unlock_bh(&est_lock);
 }
 
 void ip_vs_kill_estimator(struct ip_vs_stats *stats)
 {
-	struct ip_vs_estimator *est, **pest;
-	int killed = 0;
-
-	write_lock_bh(&est_lock);
-	pest = &est_list;
-	while ((est=*pest) != NULL) {
-		if (est->stats != stats) {
-			pest = &est->next;
-			continue;
-		}
-		*pest = est->next;
-		kfree(est);
-		killed++;
+	struct ip_vs_estimator *est = &stats->est;
+
+	spin_lock_bh(&est_lock);
+	list_del(&est->list);
+	while (list_empty(&est_list) && try_to_del_timer_sync(&est_timer) < 0) {
+		spin_unlock_bh(&est_lock);
+		cpu_relax();
+		spin_lock_bh(&est_lock);
 	}
-	if (killed && est_list == NULL)
-		del_timer_sync(&est_timer);
-	write_unlock_bh(&est_lock);
+	spin_unlock_bh(&est_lock);
 }
 
 void ip_vs_zero_estimator(struct ip_vs_stats *stats)
 {
-	struct ip_vs_estimator *e;
-
-	write_lock_bh(&est_lock);
-	for (e = est_list; e; e = e->next) {
-		if (e->stats != stats)
-			continue;
-
-		/* set counters zero */
-		e->last_conns = 0;
-		e->last_inpkts = 0;
-		e->last_outpkts = 0;
-		e->last_inbytes = 0;
-		e->last_outbytes = 0;
-		e->cps = 0;
-		e->inpps = 0;
-		e->outpps = 0;
-		e->inbps = 0;
-		e->outbps = 0;
-	}
-	write_unlock_bh(&est_lock);
+	struct ip_vs_estimator *est = &stats->est;
+
+	/* set counters zero, caller must hold the stats->lock lock */
+	est->last_inbytes = 0;
+	est->last_outbytes = 0;
+	est->last_conns = 0;
+	est->last_inpkts = 0;
+	est->last_outpkts = 0;
+	est->cps = 0;
+	est->inpps = 0;
+	est->outpps = 0;
+	est->inbps = 0;
+	est->outbps = 0;
 }
diff --git a/net/ipv4/ipvs/ip_vs_lblc.c b/net/ipv4/ipvs/ip_vs_lblc.c
index 0efa3db..7a6a319 100644
--- a/net/ipv4/ipvs/ip_vs_lblc.c
+++ b/net/ipv4/ipvs/ip_vs_lblc.c
@@ -539,6 +539,7 @@ static struct ip_vs_scheduler ip_vs_lblc_scheduler =
 	.name =			"lblc",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+	.n_list =		LIST_HEAD_INIT(ip_vs_lblc_scheduler.n_list),
 	.init_service =		ip_vs_lblc_init_svc,
 	.done_service =		ip_vs_lblc_done_svc,
 	.update_service =	ip_vs_lblc_update_svc,
@@ -550,7 +551,6 @@ static int __init ip_vs_lblc_init(void)
 {
 	int ret;
 
-	INIT_LIST_HEAD(&ip_vs_lblc_scheduler.n_list);
 	sysctl_header = register_sysctl_paths(net_vs_ctl_path, vs_vars_table);
 	ret = register_ip_vs_scheduler(&ip_vs_lblc_scheduler);
 	if (ret)
diff --git a/net/ipv4/ipvs/ip_vs_lblcr.c b/net/ipv4/ipvs/ip_vs_lblcr.c
index 8e3bbeb..c234e73 100644
--- a/net/ipv4/ipvs/ip_vs_lblcr.c
+++ b/net/ipv4/ipvs/ip_vs_lblcr.c
@@ -728,6 +728,7 @@ static struct ip_vs_scheduler ip_vs_lblcr_scheduler =
 	.name =			"lblcr",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+	.n_list =		LIST_HEAD_INIT(ip_vs_lblcr_scheduler.n_list),
 	.init_service =		ip_vs_lblcr_init_svc,
 	.done_service =		ip_vs_lblcr_done_svc,
 	.update_service =	ip_vs_lblcr_update_svc,
@@ -739,7 +740,6 @@ static int __init ip_vs_lblcr_init(void)
 {
 	int ret;
 
-	INIT_LIST_HEAD(&ip_vs_lblcr_scheduler.n_list);
 	sysctl_header = register_sysctl_paths(net_vs_ctl_path, vs_vars_table);
 	ret = register_ip_vs_scheduler(&ip_vs_lblcr_scheduler);
 	if (ret)
diff --git a/net/ipv4/ipvs/ip_vs_lc.c b/net/ipv4/ipvs/ip_vs_lc.c
index ac9f08e..ebcdbf7 100644
--- a/net/ipv4/ipvs/ip_vs_lc.c
+++ b/net/ipv4/ipvs/ip_vs_lc.c
@@ -98,6 +98,7 @@ static struct ip_vs_scheduler ip_vs_lc_scheduler = {
 	.name =			"lc",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+	.n_list =		LIST_HEAD_INIT(ip_vs_lc_scheduler.n_list),
 	.init_service =		ip_vs_lc_init_svc,
 	.done_service =		ip_vs_lc_done_svc,
 	.update_service =	ip_vs_lc_update_svc,
@@ -107,7 +108,6 @@ static struct ip_vs_scheduler ip_vs_lc_scheduler = {
 
 static int __init ip_vs_lc_init(void)
 {
-	INIT_LIST_HEAD(&ip_vs_lc_scheduler.n_list);
 	return register_ip_vs_scheduler(&ip_vs_lc_scheduler) ;
 }
 
diff --git a/net/ipv4/ipvs/ip_vs_nq.c b/net/ipv4/ipvs/ip_vs_nq.c
index a46bf25..92f3a67 100644
--- a/net/ipv4/ipvs/ip_vs_nq.c
+++ b/net/ipv4/ipvs/ip_vs_nq.c
@@ -136,6 +136,7 @@ static struct ip_vs_scheduler ip_vs_nq_scheduler =
 	.name =			"nq",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+	.n_list =		LIST_HEAD_INIT(ip_vs_nq_scheduler.n_list),
 	.init_service =		ip_vs_nq_init_svc,
 	.done_service =		ip_vs_nq_done_svc,
 	.update_service =	ip_vs_nq_update_svc,
@@ -145,7 +146,6 @@ static struct ip_vs_scheduler ip_vs_nq_scheduler =
 
 static int __init ip_vs_nq_init(void)
 {
-	INIT_LIST_HEAD(&ip_vs_nq_scheduler.n_list);
 	return register_ip_vs_scheduler(&ip_vs_nq_scheduler);
 }
 
diff --git a/net/ipv4/ipvs/ip_vs_proto.c b/net/ipv4/ipvs/ip_vs_proto.c
index 876714f..6099a88 100644
--- a/net/ipv4/ipvs/ip_vs_proto.c
+++ b/net/ipv4/ipvs/ip_vs_proto.c
@@ -43,7 +43,7 @@ static struct ip_vs_protocol *ip_vs_proto_table[IP_VS_PROTO_TAB_SIZE];
 /*
  *	register an ipvs protocol
  */
-static int __used register_ip_vs_protocol(struct ip_vs_protocol *pp)
+static int __used __init register_ip_vs_protocol(struct ip_vs_protocol *pp)
 {
 	unsigned hash = IP_VS_PROTO_HASH(pp->protocol);
 
@@ -190,7 +190,7 @@ ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp,
 }
 
 
-int ip_vs_protocol_init(void)
+int __init ip_vs_protocol_init(void)
 {
 	char protocols[64];
 #define REGISTER_PROTOCOL(p)			\
diff --git a/net/ipv4/ipvs/ip_vs_rr.c b/net/ipv4/ipvs/ip_vs_rr.c
index c8db12d..358110d 100644
--- a/net/ipv4/ipvs/ip_vs_rr.c
+++ b/net/ipv4/ipvs/ip_vs_rr.c
@@ -94,6 +94,7 @@ static struct ip_vs_scheduler ip_vs_rr_scheduler = {
 	.name =			"rr",			/* name */
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+	.n_list =		LIST_HEAD_INIT(ip_vs_rr_scheduler.n_list),
 	.init_service =		ip_vs_rr_init_svc,
 	.done_service =		ip_vs_rr_done_svc,
 	.update_service =	ip_vs_rr_update_svc,
@@ -102,7 +103,6 @@ static struct ip_vs_scheduler ip_vs_rr_scheduler = {
 
 static int __init ip_vs_rr_init(void)
 {
-	INIT_LIST_HEAD(&ip_vs_rr_scheduler.n_list);
 	return register_ip_vs_scheduler(&ip_vs_rr_scheduler);
 }
 
diff --git a/net/ipv4/ipvs/ip_vs_sched.c b/net/ipv4/ipvs/ip_vs_sched.c
index b647673..a46ad9e 100644
--- a/net/ipv4/ipvs/ip_vs_sched.c
+++ b/net/ipv4/ipvs/ip_vs_sched.c
@@ -184,7 +184,7 @@ int register_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
 
 	write_lock_bh(&__ip_vs_sched_lock);
 
-	if (scheduler->n_list.next != &scheduler->n_list) {
+	if (!list_empty(&scheduler->n_list)) {
 		write_unlock_bh(&__ip_vs_sched_lock);
 		ip_vs_use_count_dec();
 		IP_VS_ERR("register_ip_vs_scheduler(): [%s] scheduler "
@@ -229,7 +229,7 @@ int unregister_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
 	}
 
 	write_lock_bh(&__ip_vs_sched_lock);
-	if (scheduler->n_list.next == &scheduler->n_list) {
+	if (list_empty(&scheduler->n_list)) {
 		write_unlock_bh(&__ip_vs_sched_lock);
 		IP_VS_ERR("unregister_ip_vs_scheduler(): [%s] scheduler "
 			  "is not in the list. failed\n", scheduler->name);
diff --git a/net/ipv4/ipvs/ip_vs_sed.c b/net/ipv4/ipvs/ip_vs_sed.c
index 2a7d313..77663d8 100644
--- a/net/ipv4/ipvs/ip_vs_sed.c
+++ b/net/ipv4/ipvs/ip_vs_sed.c
@@ -138,6 +138,7 @@ static struct ip_vs_scheduler ip_vs_sed_scheduler =
 	.name =			"sed",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+	.n_list =		LIST_HEAD_INIT(ip_vs_sed_scheduler.n_list),
 	.init_service =		ip_vs_sed_init_svc,
 	.done_service =		ip_vs_sed_done_svc,
 	.update_service =	ip_vs_sed_update_svc,
@@ -147,7 +148,6 @@ static struct ip_vs_scheduler ip_vs_sed_scheduler =
 
 static int __init ip_vs_sed_init(void)
 {
-	INIT_LIST_HEAD(&ip_vs_sed_scheduler.n_list);
 	return register_ip_vs_scheduler(&ip_vs_sed_scheduler);
 }
 
diff --git a/net/ipv4/ipvs/ip_vs_sh.c b/net/ipv4/ipvs/ip_vs_sh.c
index b8fdfac..7b979e2 100644
--- a/net/ipv4/ipvs/ip_vs_sh.c
+++ b/net/ipv4/ipvs/ip_vs_sh.c
@@ -230,6 +230,7 @@ static struct ip_vs_scheduler ip_vs_sh_scheduler =
 	.name =			"sh",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+	.n_list	 =		LIST_HEAD_INIT(ip_vs_sh_scheduler.n_list),
 	.init_service =		ip_vs_sh_init_svc,
 	.done_service =		ip_vs_sh_done_svc,
 	.update_service =	ip_vs_sh_update_svc,
@@ -239,7 +240,6 @@ static struct ip_vs_scheduler ip_vs_sh_scheduler =
 
 static int __init ip_vs_sh_init(void)
 {
-	INIT_LIST_HEAD(&ip_vs_sh_scheduler.n_list);
 	return register_ip_vs_scheduler(&ip_vs_sh_scheduler);
 }
 
diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
index 45e9bd9..a652da2 100644
--- a/net/ipv4/ipvs/ip_vs_sync.c
+++ b/net/ipv4/ipvs/ip_vs_sync.c
@@ -904,9 +904,9 @@ int stop_sync_thread(int state)
 		 * progress of stopping the master sync daemon.
 		 */
 
-		spin_lock(&ip_vs_sync_lock);
+		spin_lock_bh(&ip_vs_sync_lock);
 		ip_vs_sync_state &= ~IP_VS_STATE_MASTER;
-		spin_unlock(&ip_vs_sync_lock);
+		spin_unlock_bh(&ip_vs_sync_lock);
 		kthread_stop(sync_master_thread);
 		sync_master_thread = NULL;
 	} else if (state == IP_VS_STATE_BACKUP) {
diff --git a/net/ipv4/ipvs/ip_vs_wlc.c b/net/ipv4/ipvs/ip_vs_wlc.c
index 772c3cb..9b0ef86 100644
--- a/net/ipv4/ipvs/ip_vs_wlc.c
+++ b/net/ipv4/ipvs/ip_vs_wlc.c
@@ -126,6 +126,7 @@ static struct ip_vs_scheduler ip_vs_wlc_scheduler =
 	.name =			"wlc",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+	.n_list =		LIST_HEAD_INIT(ip_vs_wlc_scheduler.n_list),
 	.init_service =		ip_vs_wlc_init_svc,
 	.done_service =		ip_vs_wlc_done_svc,
 	.update_service =	ip_vs_wlc_update_svc,
@@ -135,7 +136,6 @@ static struct ip_vs_scheduler ip_vs_wlc_scheduler =
 
 static int __init ip_vs_wlc_init(void)
 {
-	INIT_LIST_HEAD(&ip_vs_wlc_scheduler.n_list);
 	return register_ip_vs_scheduler(&ip_vs_wlc_scheduler);
 }
 
diff --git a/net/ipv4/ipvs/ip_vs_wrr.c b/net/ipv4/ipvs/ip_vs_wrr.c
index 1d6932d..0d86a79 100644
--- a/net/ipv4/ipvs/ip_vs_wrr.c
+++ b/net/ipv4/ipvs/ip_vs_wrr.c
@@ -212,6 +212,7 @@ static struct ip_vs_scheduler ip_vs_wrr_scheduler = {
 	.name =			"wrr",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+	.n_list =		LIST_HEAD_INIT(ip_vs_wrr_scheduler.n_list),
 	.init_service =		ip_vs_wrr_init_svc,
 	.done_service =		ip_vs_wrr_done_svc,
 	.update_service =	ip_vs_wrr_update_svc,
@@ -220,7 +221,6 @@ static struct ip_vs_scheduler ip_vs_wrr_scheduler = {
 
 static int __init ip_vs_wrr_init(void)
 {
-	INIT_LIST_HEAD(&ip_vs_wrr_scheduler.n_list);
 	return register_ip_vs_scheduler(&ip_vs_wrr_scheduler) ;
 }
 
