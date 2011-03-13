From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 03/18] ipvs: zero percpu stats
Date: Mon, 14 Mar 2011 01:29:56 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103140120210.25062@ja.ssi.bg>
References: <1299368760-14271-1-git-send-email-horms@verge.net.au>  <1299368760-14271-4-git-send-email-horms@verge.net.au>  <1299402367.2758.87.camel@edumazet-laptop>  <alpine.LFD.2.00.1103061218470.1879@ja.ssi.bg>
 <1300013852.2761.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-733841543-1300058998=:25062"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1300013852.2761.14.camel@edumazet-laptop>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org, Hans Schillstrom <hans@schillstrom.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-733841543-1300058998=:25062
Content-Type: TEXT/PLAIN; charset="utf-8"; format="flowed"
Content-Transfer-Encoding: 8bit


 	Hello,

On Sun, 13 Mar 2011, Eric Dumazet wrote:

> Le dimanche 06 mars 2011 à 14:18 +0200, Julian Anastasov a écrit :
>>  	Packet processing can damage the counters while we
>> do memset, so we need at least u64_stats_fetch_* to sync
>> with incrementing.
>>
>
> OK I now understand what you wanted to do.
>
> Problem is you do synchronize your memset() with a concurrent writer but
> one way only. (You detect a writer did some changes on the counters
> while you memset() them), but a writer has no way to detect your writes
> (could be partially committed to main memory) : It could read a
> corrupted value.

 	You mean such worst case is possible: incrementing
remembers old values and uses them for next packet incrementing.

> I feel memory barriers are wrong and not really fixable without slowing
> down the hot path.
>
> As implied in include/linux/u64_stats_sync.h file, a "writer" should be
> alone :)
>
> One other way to handle that (and let hot path packet processing without
> extra locking) would be to never memset() this data, but use a separate
> "summed" value as a relative point, and substract this sum to the
> current one (all this in slow path, so not a problem)

 	Good idea. Thanks! Here is a new version that
does not reset percpu counters but maintains proper
values after zeroing for the other stats and rates
as before. For now I decided not to show zeroed values
for percpu values.

===========================================================

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
as long as the sum stats and rates are correct after zeroing.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp lvs-test-2.6-8a80c79/linux/include/net/ip_vs.h linux/include/net/ip_vs.h
--- lvs-test-2.6-8a80c79/linux/include/net/ip_vs.h	2011-03-14 00:27:47.000000000 +0200
+++ linux/include/net/ip_vs.h	2011-03-14 00:28:59.645249612 +0200
@@ -374,6 +374,7 @@ struct ip_vs_stats {
  	struct ip_vs_estimator	est;		/* estimator */
  	struct ip_vs_cpu_stats	*cpustats;	/* per cpu counters */
  	spinlock_t		lock;		/* spin lock */
+	struct ip_vs_stats_user	ustats0;	/* reset values */
  };

  /*
diff -urp lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_ctl.c linux/net/netfilter/ipvs/ip_vs_ctl.c
--- lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_ctl.c	2011-03-14 00:27:47.000000000 +0200
+++ linux/net/netfilter/ipvs/ip_vs_ctl.c	2011-03-14 00:32:05.799251081 +0200
@@ -709,13 +709,51 @@ static void ip_vs_trash_cleanup(struct n
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
@@ -1961,7 +1999,7 @@ static const struct file_operations ip_v
  static int ip_vs_stats_show(struct seq_file *seq, void *v)
  {
  	struct net *net = seq_file_single_net(seq);
-	struct ip_vs_stats *tot_stats = &net_ipvs(net)->tot_stats;
+	struct ip_vs_stats_user show;

  /*               01234567 01234567 01234567 0123456701234567 0123456701234567 */
  	seq_puts(seq,
@@ -1969,22 +2007,18 @@ static int ip_vs_stats_show(struct seq_f
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
@@ -2296,14 +2330,6 @@ do_ip_vs_set_ctl(struct sock *sk, int cm


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
@@ -2689,31 +2715,29 @@ static const struct nla_policy ip_vs_des
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
diff -urp lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_est.c linux/net/netfilter/ipvs/ip_vs_est.c
--- lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_est.c	2011-03-14 00:27:47.000000000 +0200
+++ linux/net/netfilter/ipvs/ip_vs_est.c	2011-03-14 00:28:59.648248944 +0200
@@ -184,13 +184,14 @@ void ip_vs_kill_estimator(struct net *ne
  void ip_vs_zero_estimator(struct ip_vs_stats *stats)
  {
  	struct ip_vs_estimator *est = &stats->est;
+	struct ip_vs_stats_user *u = &stats->ustats;

-	/* set counters zero, caller must hold the stats->lock lock */
-	est->last_inbytes = 0;
-	est->last_outbytes = 0;
-	est->last_conns = 0;
-	est->last_inpkts = 0;
-	est->last_outpkts = 0;
+	/* reset counters, caller must hold the stats->lock lock */
+	est->last_inbytes = u->inbytes;
+	est->last_outbytes = u->outbytes;
+	est->last_conns = u->conns;
+	est->last_inpkts = u->inpkts;
+	est->last_outpkts = u->outpkts;
  	est->cps = 0;
  	est->inpps = 0;
  	est->outpps = 0;
---1463811672-733841543-1300058998=:25062--
