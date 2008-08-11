From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH 8/9] ipvs: Embed estimator object into stats object
Date: Mon, 11 Aug 2008 14:16:25 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0808111354480.12259@titan.stealer.net>
References: <1218366459-23971-1-git-send-email-sven.wegener@stealer.net> <1218366459-23971-9-git-send-email-sven.wegener@stealer.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1218366459-23971-9-git-send-email-sven.wegener@stealer.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

There's no reason for dynamically allocating an estimator object for every
stats object. Directly embed an estimator object into every stats object and
switch to using the kernel-provided list implementation. This makes the code
much simpler and faster, as we do not need to traverse the list of all
estimators to find the one belonging to a stats object. There's no need to use
an rwlock, as we only have one reader. Also reorder the members of the
estimator structure slightly to avoid padding overhead. This can't be done
with the stats object as the members are currently copied to our user space
object via memcpy() and changing it would break ABI.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
Acked-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h       |   28 ++++++++++-
 net/ipv4/ipvs/ip_vs_ctl.c |    2 +-
 net/ipv4/ipvs/ip_vs_est.c |  117 +++++++++++++++------------------------------
 3 files changed, 65 insertions(+), 82 deletions(-)

Changes since last post: Include a comment on the requirement that no 
member should precede the lock in ip_vs_stats. Reorder the member of 
ip_vs_estimator to avoid padding.

diff --git a/include/net/ip_vs.h 
b/include/net/ip_vs.h index c8ee9b8..7312c3d 100644
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
@@ -659,7 +683,7 @@ extern void ip_vs_sync_conn(struct ip_vs_conn *cp);
 /*
  *      IPVS rate estimator prototypes (from ip_vs_est.c)
  */
-extern int ip_vs_new_estimator(struct ip_vs_stats *stats);
+extern void ip_vs_new_estimator(struct ip_vs_stats *stats);
 extern void ip_vs_kill_estimator(struct ip_vs_stats *stats);
 extern void ip_vs_zero_estimator(struct ip_vs_stats *stats);
 
diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index 999d884..d651bce 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -684,8 +684,8 @@ ip_vs_zero_stats(struct ip_vs_stats *stats)
 {
 	spin_lock_bh(&stats->lock);
 	memset(stats, 0, (char *)&stats->lock - (char *)stats);
-	spin_unlock_bh(&stats->lock);
 	ip_vs_zero_estimator(stats);
+	spin_unlock_bh(&stats->lock);
 }
 
 /*
diff --git a/net/ipv4/ipvs/ip_vs_est.c b/net/ipv4/ipvs/ip_vs_est.c
index 1d6e58e..5a20f93 100644
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
+static void estimation_timer(unsigned long arg);
 
-
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
 
@@ -142,62 +123,40 @@ int ip_vs_new_estimator(struct ip_vs_stats *stats)
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
-	}
-	while (killed && !est_list && try_to_del_timer_sync(&est_timer) < 0) {
-		write_unlock_bh(&est_lock);
+	struct ip_vs_estimator *est = &stats->est;
+
+	spin_lock_bh(&est_lock);
+	list_del(&est->list);
+	while (list_empty(&est_list) && try_to_del_timer_sync(&est_timer) < 0) {
+		spin_unlock_bh(&est_lock);
 		cpu_relax();
-		write_lock_bh(&est_lock);
+		spin_lock_bh(&est_lock);
 	}
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
