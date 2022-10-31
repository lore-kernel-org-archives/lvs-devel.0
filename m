From: Julian Anastasov <ja@ssi.bg>
Subject: [RFC PATCHv6 3/7] ipvs: use u64_stats_t for the per-cpu counters
Date: Mon, 31 Oct 2022 16:56:43 +0200
Message-ID: <20221031145647.156930-4-ja@ssi.bg>
References: <20221031145647.156930-1-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20221031145647.156930-1-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jiri Wiesner <jwiesner@suse.de>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

Use the provided u64_stats_t type to avoid
load/store tearing.

Fixes: 316580b69d0a ("u64_stats: provide u64_stats_t type")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             | 10 +++++-----
 net/netfilter/ipvs/ip_vs_core.c | 30 +++++++++++++++---------------
 net/netfilter/ipvs/ip_vs_ctl.c  | 10 +++++-----
 net/netfilter/ipvs/ip_vs_est.c  | 20 ++++++++++----------
 4 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index e5582c01a4a3..a4d44138c2a8 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -351,11 +351,11 @@ struct ip_vs_seq {
 
 /* counters per cpu */
 struct ip_vs_counters {
-	__u64		conns;		/* connections scheduled */
-	__u64		inpkts;		/* incoming packets */
-	__u64		outpkts;	/* outgoing packets */
-	__u64		inbytes;	/* incoming bytes */
-	__u64		outbytes;	/* outgoing bytes */
+	u64_stats_t	conns;		/* connections scheduled */
+	u64_stats_t	inpkts;		/* incoming packets */
+	u64_stats_t	outpkts;	/* outgoing packets */
+	u64_stats_t	inbytes;	/* incoming bytes */
+	u64_stats_t	outbytes;	/* outgoing bytes */
 };
 /* Stats per cpu */
 struct ip_vs_cpu_stats {
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index fcdaef1fcccf..2fcc26507d69 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -132,21 +132,21 @@ ip_vs_in_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 
 		s = this_cpu_ptr(dest->stats.cpustats);
 		u64_stats_update_begin(&s->syncp);
-		s->cnt.inpkts++;
-		s->cnt.inbytes += skb->len;
+		u64_stats_inc(&s->cnt.inpkts);
+		u64_stats_add(&s->cnt.inbytes, skb->len);
 		u64_stats_update_end(&s->syncp);
 
 		svc = rcu_dereference(dest->svc);
 		s = this_cpu_ptr(svc->stats.cpustats);
 		u64_stats_update_begin(&s->syncp);
-		s->cnt.inpkts++;
-		s->cnt.inbytes += skb->len;
+		u64_stats_inc(&s->cnt.inpkts);
+		u64_stats_add(&s->cnt.inbytes, skb->len);
 		u64_stats_update_end(&s->syncp);
 
 		s = this_cpu_ptr(ipvs->tot_stats->s.cpustats);
 		u64_stats_update_begin(&s->syncp);
-		s->cnt.inpkts++;
-		s->cnt.inbytes += skb->len;
+		u64_stats_inc(&s->cnt.inpkts);
+		u64_stats_add(&s->cnt.inbytes, skb->len);
 		u64_stats_update_end(&s->syncp);
 
 		local_bh_enable();
@@ -168,21 +168,21 @@ ip_vs_out_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 
 		s = this_cpu_ptr(dest->stats.cpustats);
 		u64_stats_update_begin(&s->syncp);
-		s->cnt.outpkts++;
-		s->cnt.outbytes += skb->len;
+		u64_stats_inc(&s->cnt.outpkts);
+		u64_stats_add(&s->cnt.outbytes, skb->len);
 		u64_stats_update_end(&s->syncp);
 
 		svc = rcu_dereference(dest->svc);
 		s = this_cpu_ptr(svc->stats.cpustats);
 		u64_stats_update_begin(&s->syncp);
-		s->cnt.outpkts++;
-		s->cnt.outbytes += skb->len;
+		u64_stats_inc(&s->cnt.outpkts);
+		u64_stats_add(&s->cnt.outbytes, skb->len);
 		u64_stats_update_end(&s->syncp);
 
 		s = this_cpu_ptr(ipvs->tot_stats->s.cpustats);
 		u64_stats_update_begin(&s->syncp);
-		s->cnt.outpkts++;
-		s->cnt.outbytes += skb->len;
+		u64_stats_inc(&s->cnt.outpkts);
+		u64_stats_add(&s->cnt.outbytes, skb->len);
 		u64_stats_update_end(&s->syncp);
 
 		local_bh_enable();
@@ -200,17 +200,17 @@ ip_vs_conn_stats(struct ip_vs_conn *cp, struct ip_vs_service *svc)
 
 	s = this_cpu_ptr(cp->dest->stats.cpustats);
 	u64_stats_update_begin(&s->syncp);
-	s->cnt.conns++;
+	u64_stats_inc(&s->cnt.conns);
 	u64_stats_update_end(&s->syncp);
 
 	s = this_cpu_ptr(svc->stats.cpustats);
 	u64_stats_update_begin(&s->syncp);
-	s->cnt.conns++;
+	u64_stats_inc(&s->cnt.conns);
 	u64_stats_update_end(&s->syncp);
 
 	s = this_cpu_ptr(ipvs->tot_stats->s.cpustats);
 	u64_stats_update_begin(&s->syncp);
-	s->cnt.conns++;
+	u64_stats_inc(&s->cnt.conns);
 	u64_stats_update_end(&s->syncp);
 
 	local_bh_enable();
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index ec6db864ac36..5f9cc2e7ba71 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2335,11 +2335,11 @@ static int ip_vs_stats_percpu_show(struct seq_file *seq, void *v)
 
 		do {
 			start = u64_stats_fetch_begin(&u->syncp);
-			conns = u->cnt.conns;
-			inpkts = u->cnt.inpkts;
-			outpkts = u->cnt.outpkts;
-			inbytes = u->cnt.inbytes;
-			outbytes = u->cnt.outbytes;
+			conns = u64_stats_read(&u->cnt.conns);
+			inpkts = u64_stats_read(&u->cnt.inpkts);
+			outpkts = u64_stats_read(&u->cnt.outpkts);
+			inbytes = u64_stats_read(&u->cnt.inbytes);
+			outbytes = u64_stats_read(&u->cnt.outbytes);
 		} while (u64_stats_fetch_retry(&u->syncp, start));
 
 		seq_printf(seq, "%3X %8LX %8LX %8LX %16LX %16LX\n",
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 9a1a7af6a186..f53150d82a92 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -67,11 +67,11 @@ static void ip_vs_read_cpu_stats(struct ip_vs_kstats *sum,
 		if (add) {
 			do {
 				start = u64_stats_fetch_begin(&s->syncp);
-				conns = s->cnt.conns;
-				inpkts = s->cnt.inpkts;
-				outpkts = s->cnt.outpkts;
-				inbytes = s->cnt.inbytes;
-				outbytes = s->cnt.outbytes;
+				conns = u64_stats_read(&s->cnt.conns);
+				inpkts = u64_stats_read(&s->cnt.inpkts);
+				outpkts = u64_stats_read(&s->cnt.outpkts);
+				inbytes = u64_stats_read(&s->cnt.inbytes);
+				outbytes = u64_stats_read(&s->cnt.outbytes);
 			} while (u64_stats_fetch_retry(&s->syncp, start));
 			sum->conns += conns;
 			sum->inpkts += inpkts;
@@ -82,11 +82,11 @@ static void ip_vs_read_cpu_stats(struct ip_vs_kstats *sum,
 			add = true;
 			do {
 				start = u64_stats_fetch_begin(&s->syncp);
-				sum->conns = s->cnt.conns;
-				sum->inpkts = s->cnt.inpkts;
-				sum->outpkts = s->cnt.outpkts;
-				sum->inbytes = s->cnt.inbytes;
-				sum->outbytes = s->cnt.outbytes;
+				sum->conns = u64_stats_read(&s->cnt.conns);
+				sum->inpkts = u64_stats_read(&s->cnt.inpkts);
+				sum->outpkts = u64_stats_read(&s->cnt.outpkts);
+				sum->inbytes = u64_stats_read(&s->cnt.inbytes);
+				sum->outbytes = u64_stats_read(&s->cnt.outbytes);
 			} while (u64_stats_fetch_retry(&s->syncp, start));
 		}
 	}
-- 
2.38.1


