From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next] net-ipvs: Delete an unnecessary check before the function call "module_put"
Date: Fri, 10 Jul 2015 15:42:49 +0900
Message-ID: <1436510569-10752-2-git-send-email-horms@verge.net.au>
References: <1436510569-10752-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1436510569-10752-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Markus Elfring <elfring@users.sourceforge.net>, Simon Horman <horms@verge.net.au>

From: Markus Elfring <elfring@users.sourceforge.net>

The module_put() function tests whether its argument is NULL and then
returns immediately. Thus the test around the call is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sched.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_sched.c b/net/netfilter/ipvs/ip_vs_sched.c
index 199760c71f39..e50221b9d95f 100644
--- a/net/netfilter/ipvs/ip_vs_sched.c
+++ b/net/netfilter/ipvs/ip_vs_sched.c
@@ -137,7 +137,7 @@ struct ip_vs_scheduler *ip_vs_scheduler_get(const char *sched_name)
 
 void ip_vs_scheduler_put(struct ip_vs_scheduler *scheduler)
 {
-	if (scheduler && scheduler->module)
+	if (scheduler)
 		module_put(scheduler->module);
 }
 
-- 
2.1.4

