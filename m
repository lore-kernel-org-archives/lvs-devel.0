From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 5/5] ipvs: fix some sparse warnings
Date: Sat,  9 Mar 2013 23:25:08 +0200
Message-ID: <1362864308-8259-6-git-send-email-ja@ssi.bg>
References: <1362864308-8259-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1362864308-8259-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	Add missing __percpu annotations and make
ip_vs_net_id static.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |    2 +-
 net/netfilter/ipvs/ip_vs_core.c |    8 +-------
 net/netfilter/ipvs/ip_vs_est.c  |    2 +-
 3 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 5ed8939..43886bb 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -474,7 +474,7 @@ struct ip_vs_estimator {
 struct ip_vs_stats {
 	struct ip_vs_stats_user	ustats;		/* statistics */
 	struct ip_vs_estimator	est;		/* estimator */
-	struct ip_vs_cpu_stats	*cpustats;	/* per cpu counters */
+	struct ip_vs_cpu_stats __percpu	*cpustats;	/* per cpu counters */
 	spinlock_t		lock;		/* spin lock */
 	struct ip_vs_stats_user	ustats0;	/* reset values */
 };
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 207c3b9..4fc749c 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -69,10 +69,7 @@ EXPORT_SYMBOL(ip_vs_conn_put);
 EXPORT_SYMBOL(ip_vs_get_debug_level);
 #endif
 
-int ip_vs_net_id __read_mostly;
-#ifdef IP_VS_GENERIC_NETNS
-EXPORT_SYMBOL(ip_vs_net_id);
-#endif
+static int ip_vs_net_id __read_mostly;
 /* netns cnt used for uniqueness */
 static atomic_t ipvs_netns_cnt = ATOMIC_INIT(0);
 
@@ -1180,9 +1177,6 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 						iph.len)))) {
 #ifdef CONFIG_IP_VS_IPV6
 				if (af == AF_INET6) {
-					struct net *net =
-						dev_net(skb_dst(skb)->dev);
