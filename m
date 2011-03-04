From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 3/4] ipvs: zero percpu stats
Date: Fri, 4 Mar 2011 12:22:08 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103041220370.1452@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, =?UTF-8?Q?Hans_Schillstr=C3=B6m?= <hans.schillstrom@ericsson.com>


 	Zero the new percpu stats because we copy from there.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_ctl.c linux/net/netfilter/ipvs/ip_vs_ctl.c
--- lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_ctl.c	2011-03-03 23:10:42.000000000 +0200
+++ linux/net/netfilter/ipvs/ip_vs_ctl.c	2011-03-04 00:19:51.078379585 +0200
@@ -713,8 +713,25 @@ static void ip_vs_trash_cleanup(struct n
  static void
  ip_vs_zero_stats(struct ip_vs_stats *stats)
  {
+	struct ip_vs_cpu_stats *cpustats = stats->cpustats;
+	int i;
+
  	spin_lock_bh(&stats->lock);

+	for_each_possible_cpu(i) {
+		struct ip_vs_cpu_stats *u = per_cpu_ptr(cpustats, i);
+		unsigned int start;
+
+		/* Do not pretend to be writer, it is enough to
+		 * sync with writers that modify the u64 counters
+		 * because under stats->lock we are the only reader.
+		 */
+		do {
+			start = u64_stats_fetch_begin(&u->syncp);
+			memset(&u->ustats, 0, sizeof(u->ustats));
+		} while (u64_stats_fetch_retry(&u->syncp, start));
+	}
+
  	memset(&stats->ustats, 0, sizeof(stats->ustats));
  	ip_vs_zero_estimator(stats);

