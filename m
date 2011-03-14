From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 03/20] ipvs: properly zero stats and rates
Date: Mon, 14 Mar 2011 12:45:29 +0900
Message-ID: <1300074346-13799-4-git-send-email-horms@verge.net.au>
References: <1300074346-13799-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1300074346-13799-1-git-send-email-horms@verge.net.au>
Sender: netfilter-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

 	Currently, the new percpu counters are not zeroed and
the zero commands do not work as expected, we still show the old
sum of percpu values. OTOH, we can not reset the percpu counters
from user context without causing the incrementing to use old
and bogus values.

 	So, as Eric Dumazet suggested fix that by moving all overhead
to stats reading in user context. Do not introduce overhead in
timer context (estimator) and incrementing (packet handling in
softirqs).

 	The new ustats0 field holds the zero point for all
counter values, the rates always use 0 as base value as before.
When showing the values to user space just give the difference
between counters and the base values. The only drawback is that
percpu stats are not zeroed, they are accessible only from /proc
and are new interface, so it should not be a compatibility problem
as long as the sum stats are correct after zeroing.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h            |    1 +
 net/netfilter/ipvs/ip_vs_ctl.c |   96 +++++++++++++++++++++++++---------------
 net/netfilter/ipvs/ip_vs_est.c |   15 +++---
 3 files changed, 69 insertions(+), 43 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 9db750d..06f5af4 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -374,6 +374,7 @@ struct ip_vs_stats {
 	struct ip_vs_estimator	est;		/* estimator */
 	struct ip_vs_cpu_stats	*cpustats;	/* per cpu counters */
 	spinlock_t		lock;		/* spin lock */
+	struct ip_vs_stats_user	ustats0;	/* reset values */
 };
 
 /*
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index a2a67ad..804fee7 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -711,13 +711,51 @@ static void ip_vs_trash_cleanup(struct net *net)
 	}
 }
 
+static void
+ip_vs_copy_stats(struct ip_vs_stats_user *dst, struct ip_vs_stats *src)
+{
+#define IP_VS_SHOW_STATS_COUNTER(c) dst->c = src->ustats.c - src->ustats0.c
+#define IP_VS_SHOW_STATS_RATE(r) dst->r = src->ustats.r
+
+	spin_lock_bh(&src->lock);
+
+	IP_VS_SHOW_STATS_COUNTER(conns);
+	IP_VS_SHOW_STATS_COUNTER(inpkts);
+	IP_VS_SHOW_STATS_COUNTER(outpkts);
+	IP_VS_SHOW_STATS_COUNTER(inbytes);
+	IP_VS_SHOW_STATS_COUNTER(outbytes);
+
+	IP_VS_SHOW_STATS_RATE(cps);
+	IP_VS_SHOW_STATS_RATE(inpps);
+	IP_VS_SHOW_STATS_RATE(outpps);
+	IP_VS_SHOW_STATS_RATE(inbps);
+	IP_VS_SHOW_STATS_RATE(outbps);
+
+	spin_unlock_bh(&src->lock);
+}
 
 static void
 ip_vs_zero_stats(struct ip_vs_stats *stats)
 {
 	spin_lock_bh(&stats->lock);
 
-	memset(&stats->ustats, 0, sizeof(stats->ustats));
+	/* get current counters as zero point, rates are zeroed */
+
+#define IP_VS_ZERO_STATS_COUNTER(c) stats->ustats0.c = stats->ustats.c
+#define IP_VS_ZERO_STATS_RATE(r) stats->ustats.r = 0
+
+	IP_VS_ZERO_STATS_COUNTER(conns);
+	IP_VS_ZERO_STATS_COUNTER(inpkts);
+	IP_VS_ZERO_STATS_COUNTER(outpkts);
+	IP_VS_ZERO_STATS_COUNTER(inbytes);
+	IP_VS_ZERO_STATS_COUNTER(outbytes);
+
+	IP_VS_ZERO_STATS_RATE(cps);
+	IP_VS_ZERO_STATS_RATE(inpps);
+	IP_VS_ZERO_STATS_RATE(outpps);
+	IP_VS_ZERO_STATS_RATE(inbps);
+	IP_VS_ZERO_STATS_RATE(outbps);
+
 	ip_vs_zero_estimator(stats);
 
 	spin_unlock_bh(&stats->lock);
@@ -1963,7 +2001,7 @@ static const struct file_operations ip_vs_info_fops = {
 static int ip_vs_stats_show(struct seq_file *seq, void *v)
 {
 	struct net *net = seq_file_single_net(seq);
-	struct ip_vs_stats *tot_stats = &net_ipvs(net)->tot_stats;
+	struct ip_vs_stats_user show;
 
 /*               01234567 01234567 01234567 0123456701234567 0123456701234567 */
 	seq_puts(seq,
@@ -1971,22 +2009,18 @@ static int ip_vs_stats_show(struct seq_file *seq, void *v)
 	seq_printf(seq,
 		   "   Conns  Packets  Packets            Bytes            Bytes\n");
 
-	spin_lock_bh(&tot_stats->lock);
-	seq_printf(seq, "%8X %8X %8X %16LX %16LX\n\n", tot_stats->ustats.conns,
-		   tot_stats->ustats.inpkts, tot_stats->ustats.outpkts,
-		   (unsigned long long) tot_stats->ustats.inbytes,
-		   (unsigned long long) tot_stats->ustats.outbytes);
+	ip_vs_copy_stats(&show, &net_ipvs(net)->tot_stats);
+	seq_printf(seq, "%8X %8X %8X %16LX %16LX\n\n", show.conns,
+		   show.inpkts, show.outpkts,
+		   (unsigned long long) show.inbytes,
+		   (unsigned long long) show.outbytes);
 
 /*                 01234567 01234567 01234567 0123456701234567 0123456701234567 */
 	seq_puts(seq,
 		   " Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s\n");
-	seq_printf(seq,"%8X %8X %8X %16X %16X\n",
-			tot_stats->ustats.cps,
-			tot_stats->ustats.inpps,
-			tot_stats->ustats.outpps,
-			tot_stats->ustats.inbps,
-			tot_stats->ustats.outbps);
-	spin_unlock_bh(&tot_stats->lock);
+	seq_printf(seq, "%8X %8X %8X %16X %16X\n",
+			show.cps, show.inpps, show.outpps,
+			show.inbps, show.outbps);
 
 	return 0;
 }
@@ -2298,14 +2332,6 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 
 
 static void
-ip_vs_copy_stats(struct ip_vs_stats_user *dst, struct ip_vs_stats *src)
-{
-	spin_lock_bh(&src->lock);
-	memcpy(dst, &src->ustats, sizeof(*dst));
-	spin_unlock_bh(&src->lock);
-}
-
-static void
 ip_vs_copy_service(struct ip_vs_service_entry *dst, struct ip_vs_service *src)
 {
 	dst->protocol = src->protocol;
@@ -2691,31 +2717,29 @@ static const struct nla_policy ip_vs_dest_policy[IPVS_DEST_ATTR_MAX + 1] = {
 static int ip_vs_genl_fill_stats(struct sk_buff *skb, int container_type,
 				 struct ip_vs_stats *stats)
 {
+	struct ip_vs_stats_user ustats;
 	struct nlattr *nl_stats = nla_nest_start(skb, container_type);
 	if (!nl_stats)
 		return -EMSGSIZE;
 
-	spin_lock_bh(&stats->lock);
-
-	NLA_PUT_U32(skb, IPVS_STATS_ATTR_CONNS, stats->ustats.conns);
-	NLA_PUT_U32(skb, IPVS_STATS_ATTR_INPKTS, stats->ustats.inpkts);
-	NLA_PUT_U32(skb, IPVS_STATS_ATTR_OUTPKTS, stats->ustats.outpkts);
-	NLA_PUT_U64(skb, IPVS_STATS_ATTR_INBYTES, stats->ustats.inbytes);
-	NLA_PUT_U64(skb, IPVS_STATS_ATTR_OUTBYTES, stats->ustats.outbytes);
-	NLA_PUT_U32(skb, IPVS_STATS_ATTR_CPS, stats->ustats.cps);
-	NLA_PUT_U32(skb, IPVS_STATS_ATTR_INPPS, stats->ustats.inpps);
-	NLA_PUT_U32(skb, IPVS_STATS_ATTR_OUTPPS, stats->ustats.outpps);
-	NLA_PUT_U32(skb, IPVS_STATS_ATTR_INBPS, stats->ustats.inbps);
-	NLA_PUT_U32(skb, IPVS_STATS_ATTR_OUTBPS, stats->ustats.outbps);
+	ip_vs_copy_stats(&ustats, stats);
 
-	spin_unlock_bh(&stats->lock);
+	NLA_PUT_U32(skb, IPVS_STATS_ATTR_CONNS, ustats.conns);
+	NLA_PUT_U32(skb, IPVS_STATS_ATTR_INPKTS, ustats.inpkts);
+	NLA_PUT_U32(skb, IPVS_STATS_ATTR_OUTPKTS, ustats.outpkts);
+	NLA_PUT_U64(skb, IPVS_STATS_ATTR_INBYTES, ustats.inbytes);
+	NLA_PUT_U64(skb, IPVS_STATS_ATTR_OUTBYTES, ustats.outbytes);
+	NLA_PUT_U32(skb, IPVS_STATS_ATTR_CPS, ustats.cps);
+	NLA_PUT_U32(skb, IPVS_STATS_ATTR_INPPS, ustats.inpps);
+	NLA_PUT_U32(skb, IPVS_STATS_ATTR_OUTPPS, ustats.outpps);
+	NLA_PUT_U32(skb, IPVS_STATS_ATTR_INBPS, ustats.inbps);
+	NLA_PUT_U32(skb, IPVS_STATS_ATTR_OUTBPS, ustats.outbps);
 
 	nla_nest_end(skb, nl_stats);
 
 	return 0;
 
 nla_put_failure:
-	spin_unlock_bh(&stats->lock);
 	nla_nest_cancel(skb, nl_stats);
 	return -EMSGSIZE;
 }
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index b3751cf..a850087 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -184,13 +184,14 @@ void ip_vs_kill_estimator(struct net *net, struct ip_vs_stats *stats)
 void ip_vs_zero_estimator(struct ip_vs_stats *stats)
 {
 	struct ip_vs_estimator *est = &stats->est;
-
-	/* set counters zero, caller must hold the stats->lock lock */
-	est->last_inbytes = 0;
-	est->last_outbytes = 0;
-	est->last_conns = 0;
-	est->last_inpkts = 0;
-	est->last_outpkts = 0;
+	struct ip_vs_stats_user *u = &stats->ustats;
+
+	/* reset counters, caller must hold the stats->lock lock */
+	est->last_inbytes = u->inbytes;
+	est->last_outbytes = u->outbytes;
+	est->last_conns = u->conns;
+	est->last_inpkts = u->inpkts;
+	est->last_outpkts = u->outpkts;
 	est->cps = 0;
 	est->inpps = 0;
 	est->outpps = 0;
-- 
1.7.2.3

