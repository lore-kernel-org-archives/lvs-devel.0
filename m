From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 5/5] ipvs: stats should not depend on CPU 0
Date: Wed, 18 Sep 2013 14:45:42 -0500
Message-ID: <1379533542-9891-6-git-send-email-horms@verge.net.au>
References: <1379533542-9891-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1379533542-9891-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

When reading percpu stats we need to properly reset
the sum when CPU 0 is not present in the possible mask.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_est.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

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
1.8.4

