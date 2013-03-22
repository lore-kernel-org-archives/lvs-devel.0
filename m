From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 13/19] ipvs: convert wrr scheduler to rcu
Date: Fri, 22 Mar 2013 11:46:48 +0200
Message-ID: <1363945614-11752-14-git-send-email-ja@ssi.bg>
References: <1363945614-11752-1-git-send-email-ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1363945614-11752-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

	The schedule method now needs _rcu list-traversal
primitive for svc->destinations. As the weight for some
dest can be reduced during dest selection, change the
algorithm to check weights by using minimum weights in the
1 .. max_weight-(di-1) range, with the same step (di). By this
way we ensure that there will be always a weight >= 1 check
before claiming that all destinations are overloaded.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_wrr.c |  167 ++++++++++++++++++++++++---------------
 1 files changed, 103 insertions(+), 64 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index 231be7d..98cb05e 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -29,14 +29,45 @@
 
 #include <net/ip_vs.h>
 
+/* The WRR algorithm depends on some caclulations:
+ * - mw: maximum weight
+ * - di: weight step, greatest common divisor from all weights
+ * - cw: current required weight
+ * As result, all weights are in the [di..mw] range with a step=di.
+ *
+ * First, we start with cw = mw and select dests with weight >= cw.
+ * Then cw is reduced with di and all dests are checked again.
+ * Last pass should be with cw = di. We have mw/di passes in total:
+ *
+ * pass 1: cw = max weight
+ * pass 2: cw = max weight - di
+ * pass 3: cw = max weight - 2 * di
+ * ...
+ * last pass: cw = di
+ *
+ * Weights are supposed to be >= di but we run in parallel with
+ * weight changes, it is possible some dest weight to be reduced
+ * below di, bad if it is the only available dest.
+ *
+ * So, we modify how mw is calculated, now it is reduced with (di - 1),
+ * so that last cw is 1 to catch such dests with weight below di:
+ * pass 1: cw = max weight - (di - 1)
+ * pass 2: cw = max weight - di - (di - 1)
+ * pass 3: cw = max weight - 2 * di - (di - 1)
+ * ...
+ * last pass: cw = 1
+ *
+ */
+
 /*
  * current destination pointer for weighted round-robin scheduling
  */
 struct ip_vs_wrr_mark {
-	struct list_head *cl;	/* current list head */
+	struct ip_vs_dest *cl;	/* current dest or head */
 	int cw;			/* current weight */
 	int mw;			/* maximum weight */
 	int di;			/* decreasing interval */
+	struct rcu_head		rcu_head;
 };
 
 
@@ -88,10 +119,10 @@ static int ip_vs_wrr_init_svc(struct ip_vs_service *svc)
 	if (mark == NULL)
 		return -ENOMEM;
 
-	mark->cl = &svc->destinations;
-	mark->cw = 0;
-	mark->mw = ip_vs_wrr_max_weight(svc);
+	mark->cl = list_entry(&svc->destinations, struct ip_vs_dest, n_list);
 	mark->di = ip_vs_wrr_gcd_weight(svc);
+	mark->mw = ip_vs_wrr_max_weight(svc) - (mark->di - 1);
+	mark->cw = mark->mw;
 	svc->sched_data = mark;
 
 	return 0;
@@ -100,24 +131,31 @@ static int ip_vs_wrr_init_svc(struct ip_vs_service *svc)
 
 static int ip_vs_wrr_done_svc(struct ip_vs_service *svc)
 {
+	struct ip_vs_wrr_mark *mark = svc->sched_data;
+
 	/*
 	 *    Release the mark variable
 	 */
-	kfree(svc->sched_data);
+	kfree_rcu(mark, rcu_head);
 
 	return 0;
 }
 
 
-static int ip_vs_wrr_update_svc(struct ip_vs_service *svc)
+static int ip_vs_wrr_dest_changed(struct ip_vs_service *svc,
+				  struct ip_vs_dest *dest)
 {
 	struct ip_vs_wrr_mark *mark = svc->sched_data;
 
-	mark->cl = &svc->destinations;
-	mark->mw = ip_vs_wrr_max_weight(svc);
+	write_lock_bh(&svc->sched_lock);
+	mark->cl = list_entry(&svc->destinations, struct ip_vs_dest, n_list);
 	mark->di = ip_vs_wrr_gcd_weight(svc);
-	if (mark->cw > mark->mw)
-		mark->cw = 0;
+	mark->mw = ip_vs_wrr_max_weight(svc) - (mark->di - 1);
+	if (mark->cw > mark->mw || !mark->cw)
+		mark->cw = mark->mw;
+	else if (mark->di > 1)
+		mark->cw = (mark->cw / mark->di) * mark->di + 1;
+	write_unlock_bh(&svc->sched_lock);
 	return 0;
 }
 
@@ -128,80 +166,79 @@ static int ip_vs_wrr_update_svc(struct ip_vs_service *svc)
 static struct ip_vs_dest *
 ip_vs_wrr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 {
-	struct ip_vs_dest *dest;
+	struct ip_vs_dest *dest, *last, *stop = NULL;
 	struct ip_vs_wrr_mark *mark = svc->sched_data;
-	struct list_head *p;
+	bool last_pass = false, restarted = false;
 
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
-	/*
-	 * This loop will always terminate, because mark->cw in (0, max_weight]
-	 * and at least one server has its weight equal to max_weight.
-	 */
 	write_lock(&svc->sched_lock);
-	p = mark->cl;
+	dest = mark->cl;
+	/* No available dests? */
+	if (mark->mw == 0)
+		goto err_noavail;
+	last = dest;
+	/* Stop only after all dests were checked for weight >= 1 (last pass) */
 	while (1) {
-		if (mark->cl == &svc->destinations) {
-			/* it is at the head of the destination list */
-
-			if (mark->cl == mark->cl->next) {
-				/* no dest entry */
-				ip_vs_scheduler_err(svc,
-					"no destination available: "
-					"no destinations present");
-				dest = NULL;
-				goto out;
-			}
-
-			mark->cl = svc->destinations.next;
-			mark->cw -= mark->di;
-			if (mark->cw <= 0) {
-				mark->cw = mark->mw;
-				/*
-				 * Still zero, which means no available servers.
-				 */
-				if (mark->cw == 0) {
-					mark->cl = &svc->destinations;
-					ip_vs_scheduler_err(svc,
-						"no destination available");
-					dest = NULL;
-					goto out;
-				}
-			}
-		} else
-			mark->cl = mark->cl->next;
-
-		if (mark->cl != &svc->destinations) {
-			/* not at the head of the list */
-			dest = list_entry(mark->cl, struct ip_vs_dest, n_list);
+		list_for_each_entry_continue_rcu(dest,
+						 &svc->destinations,
+						 n_list) {
 			if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
-			    atomic_read(&dest->weight) >= mark->cw) {
-				/* got it */
-				break;
-			}
+			    atomic_read(&dest->weight) >= mark->cw)
+				goto found;
+			if (dest == stop)
+				goto err_over;
 		}
-
-		if (mark->cl == p && mark->cw == mark->di) {
-			/* back to the start, and no dest is found.
-			   It is only possible when all dests are OVERLOADED */
-			dest = NULL;
-			ip_vs_scheduler_err(svc,
-				"no destination available: "
-				"all destinations are overloaded");
-			goto out;
+		mark->cw -= mark->di;
+		if (mark->cw <= 0) {
+			mark->cw = mark->mw;
+			/* Stop if we tried last pass from first dest:
+			 * 1. last_pass: we started checks when cw > di but
+			 *	then all dests were checked for w >= 1
+			 * 2. last was head: the first and only traversal
+			 *	was for weight >= 1, for all dests.
+			 */
+			if (last_pass ||
+			    &last->n_list == &svc->destinations)
+				goto err_over;
+			restarted = true;
+		}
+		last_pass = mark->cw <= mark->di;
+		if (last_pass && restarted &&
+		    &last->n_list != &svc->destinations) {
+			/* First traversal was for w >= 1 but only
+			 * for dests after 'last', now do the same
+			 * for all dests up to 'last'.
+			 */
+			stop = last;
 		}
 	}
 
+found:
 	IP_VS_DBG_BUF(6, "WRR: server %s:%u "
 		      "activeconns %d refcnt %d weight %d\n",
 		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port),
 		      atomic_read(&dest->activeconns),
 		      atomic_read(&dest->refcnt),
 		      atomic_read(&dest->weight));
+	mark->cl = dest;
 
   out:
 	write_unlock(&svc->sched_lock);
 	return dest;
+
+err_noavail:
+	mark->cl = dest;
+	dest = NULL;
+	ip_vs_scheduler_err(svc, "no destination available");
+	goto out;
+
+err_over:
+	mark->cl = dest;
+	dest = NULL;
+	ip_vs_scheduler_err(svc, "no destination available: "
+			    "all destinations are overloaded");
+	goto out;
 }
 
 
@@ -212,7 +249,9 @@ static struct ip_vs_scheduler ip_vs_wrr_scheduler = {
 	.n_list =		LIST_HEAD_INIT(ip_vs_wrr_scheduler.n_list),
 	.init_service =		ip_vs_wrr_init_svc,
 	.done_service =		ip_vs_wrr_done_svc,
-	.update_service =	ip_vs_wrr_update_svc,
+	.add_dest =		ip_vs_wrr_dest_changed,
+	.del_dest =		ip_vs_wrr_dest_changed,
+	.upd_dest =		ip_vs_wrr_dest_changed,
 	.schedule =		ip_vs_wrr_schedule,
 };
 
-- 
1.7.3.4
