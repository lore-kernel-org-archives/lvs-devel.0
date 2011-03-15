From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 08/24] ipvs: remove unused seqcount stats
Date: Tue, 15 Mar 2011 14:27:16 +0900
Message-ID: <1300166852-725-9-git-send-email-horms@verge.net.au>
References: <1300166852-725-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1300166852-725-1-git-send-email-horms@verge.net.au>
Sender: netfilter-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

 	Remove ustats_seq, IPVS_STAT_INC and IPVS_STAT_ADD
because they are not used. They were replaced with u64_stats.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h |   17 -----------------
 1 files changed, 0 insertions(+), 17 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 06f5af4..cf014ab 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -377,22 +377,6 @@ struct ip_vs_stats {
 	struct ip_vs_stats_user	ustats0;	/* reset values */
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
@@ -853,7 +837,6 @@ struct netns_ipvs {
 
 	/* ip_vs_ctl */
 	struct ip_vs_stats		tot_stats;  /* Statistics & est. */
-	seqcount_t			*ustats_seq; /* u64 read retry */
 
 	int			num_services;    /* no of virtual services */
 	/* 1/rate drop and drop-entry variables */
-- 
1.7.2.3

