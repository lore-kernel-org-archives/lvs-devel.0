From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 50/84] ipvs: Pass ipvs not net to estimation_timer
Date: Thu, 24 Sep 2015 09:52:35 +0900
Message-ID: <1443055989-1306-51-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_est.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 638a301f7ee4..c86dc456c8f4 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -102,10 +102,8 @@ static void estimation_timer(unsigned long arg)
 	struct ip_vs_estimator *e;
 	struct ip_vs_stats *s;
 	u64 rate;
-	struct net *net = (struct net *)arg;
-	struct netns_ipvs *ipvs;
+	struct netns_ipvs *ipvs = (struct netns_ipvs *)arg;
 
-	ipvs = net_ipvs(net);
 	spin_lock(&ipvs->est_lock);
 	list_for_each_entry(e, &ipvs->est_list, list) {
 		s = container_of(e, struct ip_vs_stats, est);
@@ -196,7 +194,7 @@ int __net_init ip_vs_estimator_net_init(struct net *net)
 
 	INIT_LIST_HEAD(&ipvs->est_list);
 	spin_lock_init(&ipvs->est_lock);
-	setup_timer(&ipvs->est_timer, estimation_timer, (unsigned long)net);
+	setup_timer(&ipvs->est_timer, estimation_timer, (unsigned long)ipvs);
 	mod_timer(&ipvs->est_timer, jiffies + 2 * HZ);
 	return 0;
 }
-- 
2.1.4
