From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [RFC PATCH 6/9] ipvs network name space aware
Date: Fri, 8 Oct 2010 13:17:06 +0200
Message-ID: <201010081317.07175.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr

This patch just contains ip_vs_est.c

There is one estimator i.e not one per netns
When est runs it loops all netns
  for_each_net(net) { ... }


Signed-off-by:Hans Schillstrom <hans.schillstrom@ericsson.com>

diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index ff28801..e8c185d 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -8,8 +8,13 @@
  *              as published by the Free Software Foundation; either version
  *              2 of the License, or (at your option) any later version.
  *
- * Changes:
+ * Changes:     Hans Schillstrom <hans.schillstrom@ericsson.com>
  *
+ *              Network name space (netns) aware.
+ *              Global data moved to netns i.e struct netns_ipvs
+ *		Affected data: est_list and est_lock.
+ *		estimation_timer() runs with a common timer, but
+ *		do update every netns on timeout.
  */

 #define KMSG_COMPONENT "IPVS"
@@ -45,13 +50,13 @@
     rate is ~2.15Gbits/s, average pps and cps are scaled by 2^10.

   * A lot code is taken from net/sched/estimator.c
+
+  * netns: estimation_timer runs every netns
  */


 static void estimation_timer(unsigned long arg);

-static LIST_HEAD(est_list);
-static DEFINE_SPINLOCK(est_lock);
 static DEFINE_TIMER(est_timer, estimation_timer, 0, 0);

 static void estimation_timer(unsigned long arg)
@@ -62,50 +67,55 @@ static void estimation_timer(unsigned long arg)
 	u32 n_inpkts, n_outpkts;
 	u64 n_inbytes, n_outbytes;
 	u32 rate;
-
-	spin_lock(&est_lock);
-	list_for_each_entry(e, &est_list, list) {
-		s = container_of(e, struct ip_vs_stats, est);
-
-		spin_lock(&s->lock);
-		n_conns = s->ustats.conns;
-		n_inpkts = s->ustats.inpkts;
-		n_outpkts = s->ustats.outpkts;
-		n_inbytes = s->ustats.inbytes;
-		n_outbytes = s->ustats.outbytes;
-
-		/* scaled by 2^10, but divided 2 seconds */
-		rate = (n_conns - e->last_conns)<<9;
-		e->last_conns = n_conns;
-		e->cps += ((long)rate - (long)e->cps)>>2;
-		s->ustats.cps = (e->cps+0x1FF)>>10;
-
-		rate = (n_inpkts - e->last_inpkts)<<9;
-		e->last_inpkts = n_inpkts;
-		e->inpps += ((long)rate - (long)e->inpps)>>2;
-		s->ustats.inpps = (e->inpps+0x1FF)>>10;
-
-		rate = (n_outpkts - e->last_outpkts)<<9;
-		e->last_outpkts = n_outpkts;
-		e->outpps += ((long)rate - (long)e->outpps)>>2;
-		s->ustats.outpps = (e->outpps+0x1FF)>>10;
-
-		rate = (n_inbytes - e->last_inbytes)<<4;
-		e->last_inbytes = n_inbytes;
-		e->inbps += ((long)rate - (long)e->inbps)>>2;
-		s->ustats.inbps = (e->inbps+0xF)>>5;
-
-		rate = (n_outbytes - e->last_outbytes)<<4;
-		e->last_outbytes = n_outbytes;
-		e->outbps += ((long)rate - (long)e->outbps)>>2;
-		s->ustats.outbps = (e->outbps+0xF)>>5;
-		spin_unlock(&s->lock);
+	struct net *net;
+	struct netns_ipvs *ipvs;
+
+	for_each_net(net) {
+		ipvs = net->ipvs;
+		spin_lock(&ipvs->est_lock);
+		list_for_each_entry(e, &ipvs->est_list, list) {
+			s = container_of(e, struct ip_vs_stats, est);
+
+			spin_lock(&s->lock);
+			n_conns = s->ustats.conns;
+			n_inpkts = s->ustats.inpkts;
+			n_outpkts = s->ustats.outpkts;
+			n_inbytes = s->ustats.inbytes;
+			n_outbytes = s->ustats.outbytes;
+
+			/* scaled by 2^10, but divided 2 seconds */
+			rate = (n_conns - e->last_conns)<<9;
+			e->last_conns = n_conns;
+			e->cps += ((long)rate - (long)e->cps)>>2;
+			s->ustats.cps = (e->cps+0x1FF)>>10;
+
+			rate = (n_inpkts - e->last_inpkts)<<9;
+			e->last_inpkts = n_inpkts;
+			e->inpps += ((long)rate - (long)e->inpps)>>2;
+			s->ustats.inpps = (e->inpps+0x1FF)>>10;
+
+			rate = (n_outpkts - e->last_outpkts)<<9;
+			e->last_outpkts = n_outpkts;
+			e->outpps += ((long)rate - (long)e->outpps)>>2;
+			s->ustats.outpps = (e->outpps+0x1FF)>>10;
+
+			rate = (n_inbytes - e->last_inbytes)<<4;
+			e->last_inbytes = n_inbytes;
+			e->inbps += ((long)rate - (long)e->inbps)>>2;
+			s->ustats.inbps = (e->inbps+0xF)>>5;
+
+			rate = (n_outbytes - e->last_outbytes)<<4;
+			e->last_outbytes = n_outbytes;
+			e->outbps += ((long)rate - (long)e->outbps)>>2;
+			s->ustats.outbps = (e->outbps+0xF)>>5;
+			spin_unlock(&s->lock);
+		}
+		spin_unlock(&ipvs->est_lock);
 	}
-	spin_unlock(&est_lock);
 	mod_timer(&est_timer, jiffies + 2*HZ);
 }

-void ip_vs_new_estimator(struct ip_vs_stats *stats)
+void ip_vs_new_estimator(struct net *net, struct ip_vs_stats *stats)
 {
 	struct ip_vs_estimator *est = &stats->est;

@@ -126,18 +136,18 @@ void ip_vs_new_estimator(struct ip_vs_stats *stats)
 	est->last_outbytes = stats->ustats.outbytes;
 	est->outbps = stats->ustats.outbps<<5;

-	spin_lock_bh(&est_lock);
-	list_add(&est->list, &est_list);
-	spin_unlock_bh(&est_lock);
+	spin_lock_bh(&net->ipvs->est_lock);
+	list_add(&est->list, &net->ipvs->est_list);
+	spin_unlock_bh(&net->ipvs->est_lock);
 }

-void ip_vs_kill_estimator(struct ip_vs_stats *stats)
+void ip_vs_kill_estimator(struct net *net, struct ip_vs_stats *stats)
 {
 	struct ip_vs_estimator *est = &stats->est;

-	spin_lock_bh(&est_lock);
+	spin_lock_bh(&net->ipvs->est_lock);
 	list_del(&est->list);
-	spin_unlock_bh(&est_lock);
+	spin_unlock_bh(&net->ipvs->est_lock);
 }

 void ip_vs_zero_estimator(struct ip_vs_stats *stats)
@@ -156,14 +166,31 @@ void ip_vs_zero_estimator(struct ip_vs_stats *stats)
 	est->inbps = 0;
 	est->outbps = 0;
 }
+static int __net_init __ip_vs_estimator_init(struct net *net)
+{
+	INIT_LIST_HEAD(&net->ipvs->est_list);
+	spin_lock_init(&net->ipvs->est_lock);
+	return 0;
+}
+
+static struct pernet_operations ip_vs_app_ops = {
+	.init = __ip_vs_estimator_init,
+//	.exit = __ip_vs_estimator_cleanup,
+};

 int __init ip_vs_estimator_init(void)
 {
+	int rv;
+
+	rv = register_pernet_subsys(&ip_vs_app_ops);
+	if(rv < 0)
+		return rv;
 	mod_timer(&est_timer, jiffies + 2 * HZ);
-	return 0;
+	return rv;
 }

 void ip_vs_estimator_cleanup(void)
 {
 	del_timer_sync(&est_timer);
+	unregister_pernet_subsys(&ip_vs_app_ops);
 }

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
