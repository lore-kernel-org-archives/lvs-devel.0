From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 50/84] ipvs: Pass ipvs not net to estimation_timer
Date: Sun, 20 Sep 2015 01:23:06 -0500
Message-ID: <1442730220-32458-50-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
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
2.2.1
