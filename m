From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 4/4] ipvs: remove unused seqcount stats
Date: Fri, 4 Mar 2011 12:23:59 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103041222100.1452@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, =?UTF-8?Q?Hans_Schillstr=C3=B6m?= <hans.schillstrom@ericsson.com>


 	Remove ustats_seq, IPVS_STAT_INC and IPVS_STAT_ADD
because they are not used. They were replaced with u64_stats.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp lvs-test-2.6-8a80c79/linux/include/net/ip_vs.h linux/include/net/ip_vs.h
--- lvs-test-2.6-8a80c79/linux/include/net/ip_vs.h	2011-03-03 23:10:42.000000000 +0200
+++ linux/include/net/ip_vs.h	2011-03-03 23:15:22.520378136 +0200
@@ -376,22 +376,6 @@ struct ip_vs_stats {
  	spinlock_t		lock;		/* spin lock */
  };

-/*
- * Helper Macros for per cpu
- * ipvs->tot_stats->ustats.count
- */
-#define IPVS_STAT_INC(ipvs, count)	\
-	__this_cpu_inc((ipvs)->ustats->count)
-
-#define IPVS_STAT_ADD(ipvs, count, value) \
-	do {\
-		write_seqcount_begin(per_cpu_ptr((ipvs)->ustats_seq, \
-				     raw_smp_processor_id())); \
-		__this_cpu_add((ipvs)->ustats->count, value); \
-		write_seqcount_end(per_cpu_ptr((ipvs)->ustats_seq, \
-				   raw_smp_processor_id())); \
-	} while (0)
