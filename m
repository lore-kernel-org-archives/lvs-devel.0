From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 04/18] ipvs: remove unused seqcount stats
Date: Sun,  6 Mar 2011 08:45:46 +0900
Message-ID: <1299368760-14271-5-git-send-email-horms@verge.net.au>
References: <1299368760-14271-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1299368760-14271-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

 	Remove ustats_seq, IPVS_STAT_INC and IPVS_STAT_ADD
because they are not used. They were replaced with u64_stats.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h |   17 -----------------
 1 files changed, 0 insertions(+), 17 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index f17841d..efd68dc 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
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
-
 struct dst_entry;
 struct iphdr;
 struct ip_vs_conn;
@@ -852,7 +836,6 @@ struct netns_ipvs {
 
 	/* ip_vs_ctl */
 	struct ip_vs_stats		tot_stats;  /* Statistics & est. */
-	seqcount_t			*ustats_seq; /* u64 read retry */
 
 	int			num_services;    /* no of virtual services */
 	/* 1/rate drop and drop-entry variables */
-- 
1.7.2.3

