From: Julian Anastasov <ja@ssi.bg>
Subject: [RFC PATCHv6 7/7] ipvs: debug the tick time
Date: Mon, 31 Oct 2022 16:56:47 +0200
Message-ID: <20221031145647.156930-8-ja@ssi.bg>
References: <20221031145647.156930-1-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20221031145647.156930-1-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jiri Wiesner <jwiesner@suse.de>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

Just for testing print the tick time every minute

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_est.c | 28 ++++++++++++++++++++++++++--
 1 file changed, 26 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 526100976d59..4489a3dbad1e 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -147,7 +147,14 @@ static void ip_vs_tick_estimation(struct ip_vs_est_kt_data *kd, int row)
 {
 	struct ip_vs_est_tick_data *td;
 	int cid;
-
+	u64 ns = 0;
+	static int used_row = -1;
+	static int pass;
+
+	if (used_row < 0)
+		used_row = row;
+	if (row == used_row && !kd->id && !(pass & 31))
+		ns = ktime_get_ns();
 	rcu_read_lock();
 	td = rcu_dereference(kd->ticks[row]);
 	if (!td)
@@ -164,6 +171,16 @@ static void ip_vs_tick_estimation(struct ip_vs_est_kt_data *kd, int row)
 
 out:
 	rcu_read_unlock();
+	if (row == used_row && !kd->id && !(pass++ & 31)) {
+		static int ncpu;
+
+		ns = ktime_get_ns() - ns;
+		if (!ncpu)
+			ncpu = num_possible_cpus();
+		pr_info("tick time: %lluns for %d CPUs, %d ests, %d chains, chain_max=%d\n",
+			(unsigned long long)ns, ncpu, kd->tick_len[row],
+			IPVS_EST_TICK_CHAINS, kd->chain_max);
+	}
 }
 
 static int ip_vs_estimation_kthread(void *data)
@@ -637,7 +654,7 @@ static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max)
 	int i, loops, ntest;
 	s32 min_est = 0;
 	ktime_t t1, t2;
-	s64 diff, val;
+	s64 diff = 0, val;
 	int max = 8;
 	int ret = 1;
 
@@ -702,6 +719,8 @@ static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max)
 	}
 
 out:
+	pr_info("calc: chain_max=%d, single est=%dns, diff=%d, loops=%d, ntest=%d\n",
+		max, min_est, (int)diff, loops, ntest);
 	if (s)
 		hlist_del_init(&s->est.list);
 	*chain_max = max;
@@ -737,6 +756,7 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
 	int id, row, cid, delay;
 	bool last, last_td;
 	int chain_max;
+	u64 ns = 0;
 	int step;
 
 	if (!ip_vs_est_calc_limits(ipvs, &chain_max))
@@ -770,6 +790,8 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
 	 */
 	delay = IPVS_EST_NTICKS;
 
+	ns = ktime_get_ns();
+
 next_delay:
 	delay--;
 	if (delay < 0)
@@ -856,6 +878,8 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
 	goto walk_chain;
 
 end_dequeue:
+	ns = ktime_get_ns() - ns;
+	pr_info("dequeue: %lluns\n", (unsigned long long)ns);
 	/* All estimators removed while calculating ? */
 	if (!ipvs->est_kt_count)
 		goto unlock;
-- 
2.38.1


