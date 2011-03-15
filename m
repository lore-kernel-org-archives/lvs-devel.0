From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 02/24] ipvs: remove _bh from percpu stats reading
Date: Tue, 15 Mar 2011 14:27:10 +0900
Message-ID: <1300166852-725-3-git-send-email-horms@verge.net.au>
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

 	ip_vs_read_cpu_stats is called only from timer, so
no need for _bh locks.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_est.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index f560a05..88bd716 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -69,10 +69,10 @@ static void ip_vs_read_cpu_stats(struct ip_vs_stats_user *sum,
 			sum->inpkts += s->ustats.inpkts;
 			sum->outpkts += s->ustats.outpkts;
 			do {
-				start = u64_stats_fetch_begin_bh(&s->syncp);
+				start = u64_stats_fetch_begin(&s->syncp);
 				inbytes = s->ustats.inbytes;
 				outbytes = s->ustats.outbytes;
-			} while (u64_stats_fetch_retry_bh(&s->syncp, start));
+			} while (u64_stats_fetch_retry(&s->syncp, start));
 			sum->inbytes += inbytes;
 			sum->outbytes += outbytes;
 		} else {
@@ -80,10 +80,10 @@ static void ip_vs_read_cpu_stats(struct ip_vs_stats_user *sum,
 			sum->inpkts = s->ustats.inpkts;
 			sum->outpkts = s->ustats.outpkts;
 			do {
-				start = u64_stats_fetch_begin_bh(&s->syncp);
+				start = u64_stats_fetch_begin(&s->syncp);
 				sum->inbytes = s->ustats.inbytes;
 				sum->outbytes = s->ustats.outbytes;
-			} while (u64_stats_fetch_retry_bh(&s->syncp, start));
+			} while (u64_stats_fetch_retry(&s->syncp, start));
 		}
 	}
 }
-- 
1.7.2.3

