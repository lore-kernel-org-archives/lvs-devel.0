From: Julian Anastasov <ja@ssi.bg>
Subject: [RFC PATCHv3 5/5] ipvs: debug the tick time
Date: Mon, 12 Sep 2022 13:18:38 +0300
Message-ID: <20220912101838.12522-6-ja@ssi.bg>
References: <20220912101838.12522-1-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20220912101838.12522-1-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jiri Wiesner <jwiesner@suse.de>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

Just for testing print the tick time every 2 seconds

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_est.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 5f5ee29fdcb5..a765ec2b0594 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -141,7 +141,13 @@ static void ip_vs_tick_estimation(struct ip_vs_est_kt_data *kd, int row)
 {
 	struct ip_vs_est_tick_data *td;
 	int cid;
+	u64 ns = 0;
+	static int used_row = -1;
 
+	if (used_row < 0)
+		used_row = row;
+	if (row == used_row && !kd->id)
+		ns = ktime_get_ns();
 	rcu_read_lock();
 	td = rcu_dereference(kd->ticks[row]);
 	if (!td)
@@ -158,6 +164,16 @@ static void ip_vs_tick_estimation(struct ip_vs_est_kt_data *kd, int row)
 
 out:
 	rcu_read_unlock();
+	if (row == used_row && !kd->id) {
+		static int ncpu;
+
+		ns = ktime_sub(ktime_get_ns(), ns);
+		if (!ncpu)
+			ncpu = num_possible_cpus();
+		pr_info("tick time: %lluns for %d CPUs, %d ests, %d chains, max depth %d\n",
+			(unsigned long long) ns, ncpu, kd->tick_len[row],
+			IPVS_EST_TICK_CHAINS, kd->chain_max_len);
+	}
 }
 
 static int ip_vs_estimation_kthread(void *data)
-- 
2.37.3


