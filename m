From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/4] ipvs: remove _bh from percpu stats reading
Date: Mon, 14 Mar 2011 07:44:19 +0900
Message-ID: <1300056261-14709-3-git-send-email-horms@verge.net.au>
References: <1300056261-14709-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300056261-14709-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Patrick McHardy <kaber@trash.net>, Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

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

