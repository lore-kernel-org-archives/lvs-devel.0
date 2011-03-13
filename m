From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 5/6] ipvs: optimize rates reading
Date: Mon, 14 Mar 2011 01:41:54 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103140139200.28562@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org


 	Move the estimator reading from estimation_timer to user
context. ip_vs_read_estimator() will be used to decode the rate
values. As the decoded rates are not set by estimation timer
there is no need to reset them in ip_vs_zero_stats.

 	There is no need ip_vs_new_estimator() to encode stats
to rates, if the destination is in trash both the stats and the
rates are inactive.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp lvs-test-2.6-8a80c79/linux/include/net/ip_vs.h linux/include/net/ip_vs.h
--- lvs-test-2.6-8a80c79/linux/include/net/ip_vs.h	2011-03-14 00:34:35.000000000 +0200
+++ linux/include/net/ip_vs.h	2011-03-14 00:41:08.550248330 +0200
@@ -1179,6 +1179,8 @@ extern void ip_vs_estimator_cleanup(void
  extern void ip_vs_new_estimator(struct net *net, struct ip_vs_stats *stats);
  extern void ip_vs_kill_estimator(struct net *net, struct ip_vs_stats *stats);
  extern void ip_vs_zero_estimator(struct ip_vs_stats *stats);
+extern void ip_vs_read_estimator(struct ip_vs_stats_user *dst,
+				 struct ip_vs_stats *stats);

  /*
   *	Various IPVS packet transmitters (from ip_vs_xmit.c)
diff -urp lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_ctl.c linux/net/netfilter/ipvs/ip_vs_ctl.c
--- lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_ctl.c	2011-03-14 00:33:57.000000000 +0200
+++ linux/net/netfilter/ipvs/ip_vs_ctl.c	2011-03-14 00:39:44.682248271 +0200
@@ -713,7 +713,6 @@ static void
  ip_vs_copy_stats(struct ip_vs_stats_user *dst, struct ip_vs_stats *src)
  {
  #define IP_VS_SHOW_STATS_COUNTER(c) dst->c = src->ustats.c - src->ustats0.c
-#define IP_VS_SHOW_STATS_RATE(r) dst->r = src->ustats.r

  	spin_lock_bh(&src->lock);

@@ -723,11 +722,7 @@ ip_vs_copy_stats(struct ip_vs_stats_user
  	IP_VS_SHOW_STATS_COUNTER(inbytes);
  	IP_VS_SHOW_STATS_COUNTER(outbytes);

-	IP_VS_SHOW_STATS_RATE(cps);
-	IP_VS_SHOW_STATS_RATE(inpps);
-	IP_VS_SHOW_STATS_RATE(outpps);
-	IP_VS_SHOW_STATS_RATE(inbps);
-	IP_VS_SHOW_STATS_RATE(outbps);
+	ip_vs_read_estimator(dst, src);

  	spin_unlock_bh(&src->lock);
  }
@@ -740,7 +735,6 @@ ip_vs_zero_stats(struct ip_vs_stats *sta
  	/* get current counters as zero point, rates are zeroed */

  #define IP_VS_ZERO_STATS_COUNTER(c) stats->ustats0.c = stats->ustats.c
-#define IP_VS_ZERO_STATS_RATE(r) stats->ustats.r = 0

  	IP_VS_ZERO_STATS_COUNTER(conns);
  	IP_VS_ZERO_STATS_COUNTER(inpkts);
@@ -748,12 +742,6 @@ ip_vs_zero_stats(struct ip_vs_stats *sta
  	IP_VS_ZERO_STATS_COUNTER(inbytes);
  	IP_VS_ZERO_STATS_COUNTER(outbytes);

-	IP_VS_ZERO_STATS_RATE(cps);
-	IP_VS_ZERO_STATS_RATE(inpps);
-	IP_VS_ZERO_STATS_RATE(outpps);
-	IP_VS_ZERO_STATS_RATE(inbps);
-	IP_VS_ZERO_STATS_RATE(outbps);
-
  	ip_vs_zero_estimator(stats);

  	spin_unlock_bh(&stats->lock);
@@ -2041,6 +2029,7 @@ static int ip_vs_stats_percpu_show(struc
  	struct net *net = seq_file_single_net(seq);
  	struct ip_vs_stats *tot_stats = &net_ipvs(net)->tot_stats;
  	struct ip_vs_cpu_stats *cpustats = tot_stats->cpustats;
+	struct ip_vs_stats_user rates;
  	int i;

  /*               01234567 01234567 01234567 0123456701234567 0123456701234567 */
@@ -2067,22 +2056,26 @@ static int ip_vs_stats_percpu_show(struc
  	}

  	spin_lock_bh(&tot_stats->lock);
+
  	seq_printf(seq, "  ~ %8X %8X %8X %16LX %16LX\n\n",
  		   tot_stats->ustats.conns, tot_stats->ustats.inpkts,
  		   tot_stats->ustats.outpkts,
  		   (unsigned long long) tot_stats->ustats.inbytes,
  		   (unsigned long long) tot_stats->ustats.outbytes);

+	ip_vs_read_estimator(&rates, tot_stats);
+
+	spin_unlock_bh(&tot_stats->lock);
+
  /*                 01234567 01234567 01234567 0123456701234567 0123456701234567 */
  	seq_puts(seq,
  		   "     Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s\n");
  	seq_printf(seq, "    %8X %8X %8X %16X %16X\n",
-			tot_stats->ustats.cps,
-			tot_stats->ustats.inpps,
-			tot_stats->ustats.outpps,
-			tot_stats->ustats.inbps,
-			tot_stats->ustats.outbps);
-	spin_unlock_bh(&tot_stats->lock);
+			rates.cps,
+			rates.inpps,
+			rates.outpps,
+			rates.inbps,
+			rates.outbps);

  	return 0;
  }
diff -urp lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_est.c linux/net/netfilter/ipvs/ip_vs_est.c
--- lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_est.c	2011-03-14 00:33:57.000000000 +0200
+++ linux/net/netfilter/ipvs/ip_vs_est.c	2011-03-14 00:40:10.991250030 +0200
@@ -117,27 +117,22 @@ static void estimation_timer(unsigned lo
  		rate = (n_conns - e->last_conns) << 9;
  		e->last_conns = n_conns;
  		e->cps += ((long)rate - (long)e->cps) >> 2;
-		s->ustats.cps = (e->cps + 0x1FF) >> 10;

  		rate = (n_inpkts - e->last_inpkts) << 9;
  		e->last_inpkts = n_inpkts;
  		e->inpps += ((long)rate - (long)e->inpps) >> 2;
-		s->ustats.inpps = (e->inpps + 0x1FF) >> 10;

  		rate = (n_outpkts - e->last_outpkts) << 9;
  		e->last_outpkts = n_outpkts;
  		e->outpps += ((long)rate - (long)e->outpps) >> 2;
-		s->ustats.outpps = (e->outpps + 0x1FF) >> 10;

  		rate = (n_inbytes - e->last_inbytes) << 4;
  		e->last_inbytes = n_inbytes;
  		e->inbps += ((long)rate - (long)e->inbps) >> 2;
-		s->ustats.inbps = (e->inbps + 0xF) >> 5;

  		rate = (n_outbytes - e->last_outbytes) << 4;
  		e->last_outbytes = n_outbytes;
  		e->outbps += ((long)rate - (long)e->outbps) >> 2;
-		s->ustats.outbps = (e->outbps + 0xF) >> 5;
  		spin_unlock(&s->lock);
  	}
  	spin_unlock(&ipvs->est_lock);
@@ -151,21 +146,6 @@ void ip_vs_new_estimator(struct net *net

  	INIT_LIST_HEAD(&est->list);

-	est->last_conns = stats->ustats.conns;
-	est->cps = stats->ustats.cps<<10;
-
-	est->last_inpkts = stats->ustats.inpkts;
-	est->inpps = stats->ustats.inpps<<10;
-
-	est->last_outpkts = stats->ustats.outpkts;
-	est->outpps = stats->ustats.outpps<<10;
-
-	est->last_inbytes = stats->ustats.inbytes;
-	est->inbps = stats->ustats.inbps<<5;
-
-	est->last_outbytes = stats->ustats.outbytes;
-	est->outbps = stats->ustats.outbps<<5;
