From: simran singhal <singhalsimran0@gmail.com>
Subject: [PATCH] net: netfilter: Use seq_puts()/seq_putc() where possible
Date: Wed, 29 Mar 2017 03:25:17 +0530
Message-ID: <20170328215517.GA18237@singhal-Inspiron-5558>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=x+0dBuMKXOMaVqJ7jfNyAQb+XmtsW1GzCxEd2S9iPuY=;
        b=GRA7dwSG/DOyLENJiZUD8nimSBX7CbY+ItmTVb0jmE/VEqhyvlQzC8cWPnGoM3GF1u
         sS1Y9zAK/UURpe9ANvQ01beIqsSp8CeaFmYKvum/cFGn1Anka5bbZWYYlKrH5UzBZmIN
         j0k7BFpwuedu7Vinvn9QzQZp+f/qEd0ideneM2OQ9Nxk9KMi6kory4iHW0eOkIk/UjlD
         dONwZQJb919xJBiWezwCm80ztDTpPesxiBlQSUJn5QVh7PwgbgdmdoVMPlF66PEyuodT
         hJTkgIoT4BQfhBUe/1+kYfhwRnosHi1MwXttQK6SGQmPhB4+9VwOut1hVbhRxsc7jxVo
         us0Q==
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, outreachy-kernel@googlegroups.com

For string without format specifiers, use seq_puts(). For
seq_printf("\n"), use seq_putc('\n').

Signed-off-by: simran singhal <singhalsimran0@gmail.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c          | 8 ++++----
 net/netfilter/nf_conntrack_expect.c     | 4 ++--
 net/netfilter/nf_conntrack_standalone.c | 6 +++---
 net/netfilter/nf_log.c                  | 4 ++--
 net/netfilter/nf_synproxy_core.c        | 6 +++---
 net/netfilter/xt_recent.c               | 2 +-
 6 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index efe348a..c3423e3 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2130,8 +2130,8 @@ static int ip_vs_stats_show(struct seq_file *seq, void *v)
 /*               01234567 01234567 01234567 0123456701234567 0123456701234567 */
 	seq_puts(seq,
 		 "   Total Incoming Outgoing         Incoming         Outgoing\n");
-	seq_printf(seq,
-		   "   Conns  Packets  Packets            Bytes            Bytes\n");
+	seq_puts(seq,
+		 "   Conns  Packets  Packets            Bytes            Bytes\n");
 
 	ip_vs_copy_stats(&show, &net_ipvs(net)->tot_stats);
 	seq_printf(seq, "%8LX %8LX %8LX %16LX %16LX\n\n",
@@ -2178,8 +2178,8 @@ static int ip_vs_stats_percpu_show(struct seq_file *seq, void *v)
 /*               01234567 01234567 01234567 0123456701234567 0123456701234567 */
 	seq_puts(seq,
 		 "       Total Incoming Outgoing         Incoming         Outgoing\n");
-	seq_printf(seq,
-		   "CPU    Conns  Packets  Packets            Bytes            Bytes\n");
+	seq_puts(seq,
+		 "CPU    Conns  Packets  Packets            Bytes            Bytes\n");
 
 	for_each_possible_cpu(i) {
 		struct ip_vs_cpu_stats *u = per_cpu_ptr(cpustats, i);
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 4b2e1fb..74c384e 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -549,7 +549,7 @@ static int exp_seq_show(struct seq_file *s, void *v)
 		seq_printf(s, "%ld ", timer_pending(&expect->timeout)
 			   ? (long)(expect->timeout.expires - jiffies)/HZ : 0);
 	else
-		seq_printf(s, "- ");
+		seq_puts(s, "- ");
 	seq_printf(s, "l3proto = %u proto=%u ",
 		   expect->tuple.src.l3num,
 		   expect->tuple.dst.protonum);
@@ -559,7 +559,7 @@ static int exp_seq_show(struct seq_file *s, void *v)
 				       expect->tuple.dst.protonum));
 
 	if (expect->flags & NF_CT_EXPECT_PERMANENT) {
-		seq_printf(s, "PERMANENT");
+		seq_puts(s, "PERMANENT");
 		delim = ",";
 	}
 	if (expect->flags & NF_CT_EXPECT_INACTIVE) {
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 2256147..ccb5cb9 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -250,7 +250,7 @@ static int ct_seq_show(struct seq_file *s, void *v)
 		goto release;
 
 	if (!(test_bit(IPS_SEEN_REPLY_BIT, &ct->status)))
-		seq_printf(s, "[UNREPLIED] ");
+		seq_puts(s, "[UNREPLIED] ");
 
 	print_tuple(s, &ct->tuplehash[IP_CT_DIR_REPLY].tuple,
 		    l3proto, l4proto);
@@ -261,7 +261,7 @@ static int ct_seq_show(struct seq_file *s, void *v)
 		goto release;
 
 	if (test_bit(IPS_ASSURED_BIT, &ct->status))
-		seq_printf(s, "[ASSURED] ");
+		seq_puts(s, "[ASSURED] ");
 
 	if (seq_has_overflowed(s))
 		goto release;
@@ -350,7 +350,7 @@ static int ct_cpu_seq_show(struct seq_file *seq, void *v)
 	const struct ip_conntrack_stat *st = v;
 
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "entries  searched found new invalid ignore delete delete_list insert insert_failed drop early_drop icmp_error  expect_new expect_create expect_delete search_restart\n");
+		seq_puts(seq, "entries  searched found new invalid ignore delete delete_list insert insert_failed drop early_drop icmp_error  expect_new expect_create expect_delete search_restart\n");
 		return 0;
 	}
 
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 8d85a05..cc32727 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -376,13 +376,13 @@ static int seq_show(struct seq_file *s, void *v)
 		logger = nft_log_dereference(loggers[*pos][i]);
 		seq_printf(s, "%s", logger->name);
 		if (i == 0 && loggers[*pos][i + 1] != NULL)
-			seq_printf(s, ",");
+			seq_puts(s, ",");
 
 		if (seq_has_overflowed(s))
 			return -ENOSPC;
 	}
 
-	seq_printf(s, ")\n");
+	seq_puts(s, ")\n");
 
 	if (seq_has_overflowed(s))
 		return -ENOSPC;
diff --git a/net/netfilter/nf_synproxy_core.c b/net/netfilter/nf_synproxy_core.c
index 7c6d1fb..abe03e8 100644
--- a/net/netfilter/nf_synproxy_core.c
+++ b/net/netfilter/nf_synproxy_core.c
@@ -287,9 +287,9 @@ static int synproxy_cpu_seq_show(struct seq_file *seq, void *v)
 	struct synproxy_stats *stats = v;
 
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "entries\t\tsyn_received\t"
-				"cookie_invalid\tcookie_valid\t"
-				"cookie_retrans\tconn_reopened\n");
+		seq_puts(seq, "entries\t\tsyn_received\t"
+			      "cookie_invalid\tcookie_valid\t"
+			      "cookie_retrans\tconn_reopened\n");
 		return 0;
 	}
 
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 1d89a4e..37d581a 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -532,7 +532,7 @@ static int recent_seq_show(struct seq_file *seq, void *v)
 			   &e->addr.in6, e->ttl, e->stamps[i], e->index);
 	for (i = 0; i < e->nstamps; i++)
 		seq_printf(seq, "%s %lu", i ? "," : "", e->stamps[i]);
-	seq_printf(seq, "\n");
+	seq_putc(seq, '\n');
 	return 0;
 }
 
-- 
2.7.4

