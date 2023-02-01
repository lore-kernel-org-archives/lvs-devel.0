From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next] ipvs: avoid kfree_rcu without 2nd arg
Date: Wed,  1 Feb 2023 19:56:53 +0200
Message-ID: <20230201175653.114334-1-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Uladzislau Rezki <urezki@gmail.com>

Avoid possible synchronize_rcu() as part from the
kfree_rcu() call when 2nd arg is not provided.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h            | 1 +
 net/netfilter/ipvs/ip_vs_est.c | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index c6c61100d244..6d71a5ff52df 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -461,6 +461,7 @@ void ip_vs_stats_free(struct ip_vs_stats *stats);
 
 /* Multiple chains processed in same tick */
 struct ip_vs_est_tick_data {
+	struct rcu_head		rcu_head;
 	struct hlist_head	chains[IPVS_EST_TICK_CHAINS];
 	DECLARE_BITMAP(present, IPVS_EST_TICK_CHAINS);
 	DECLARE_BITMAP(full, IPVS_EST_TICK_CHAINS);
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index df56073bb282..25c7118d9348 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -549,7 +549,7 @@ void ip_vs_stop_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
 	__set_bit(row, kd->avail);
 	if (!kd->tick_len[row]) {
 		RCU_INIT_POINTER(kd->ticks[row], NULL);
-		kfree_rcu(td);
+		kfree_rcu(td, rcu_head);
 	}
 	kd->est_count--;
 	if (kd->est_count) {
-- 
2.39.1


