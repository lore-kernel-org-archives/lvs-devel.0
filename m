From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net 4/4] ipvs: stats should not depend on CPU 0
Date: Wed, 28 Aug 2013 19:29:36 +0300
Message-ID: <1377707376-4362-5-git-send-email-ja@ssi.bg>
References: <1377707376-4362-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1377707376-4362-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

When reading percpu stats we need to properly reset
the sum when CPU 0 is not present in the possible mask.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_est.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 6bee6d0..1425e9a 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -59,12 +59,13 @@ static void ip_vs_read_cpu_stats(struct ip_vs_stats_user *sum,
 				 struct ip_vs_cpu_stats __percpu *stats)
 {
 	int i;
+	bool add = false;
 
 	for_each_possible_cpu(i) {
 		struct ip_vs_cpu_stats *s = per_cpu_ptr(stats, i);
 		unsigned int start;
 		__u64 inbytes, outbytes;
-		if (i) {
+		if (add) {
 			sum->conns += s->ustats.conns;
 			sum->inpkts += s->ustats.inpkts;
 			sum->outpkts += s->ustats.outpkts;
@@ -76,6 +77,7 @@ static void ip_vs_read_cpu_stats(struct ip_vs_stats_user *sum,
 			sum->inbytes += inbytes;
 			sum->outbytes += outbytes;
 		} else {
+			add = true;
 			sum->conns = s->ustats.conns;
 			sum->inpkts = s->ustats.inpkts;
 			sum->outpkts = s->ustats.outpkts;
-- 
1.7.3.4

