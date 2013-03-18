From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 5/5] ipvs: fix some sparse warnings
Date: Mon, 18 Mar 2013 22:15:43 +0900
Message-ID: <1363612543-9787-6-git-send-email-horms@verge.net.au>
References: <1363612543-9787-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1363612543-9787-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

	Add missing __percpu annotations and make
ip_vs_net_id static.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |    2 +-
 net/netfilter/ipvs/ip_vs_core.c |    8 +-------
 net/netfilter/ipvs/ip_vs_est.c  |    2 +-
 3 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index fce8e6b..bee87ba 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -459,7 +459,7 @@ struct ip_vs_estimator {
 struct ip_vs_stats {
 	struct ip_vs_stats_user	ustats;		/* statistics */
 	struct ip_vs_estimator	est;		/* estimator */
-	struct ip_vs_cpu_stats	*cpustats;	/* per cpu counters */
+	struct ip_vs_cpu_stats __percpu	*cpustats;	/* per cpu counters */
 	spinlock_t		lock;		/* spin lock */
 	struct ip_vs_stats_user	ustats0;	/* reset values */
 };
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 61f49d2..2aef23e 100644
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
 
@@ -1181,9 +1178,6 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 						iph.len)))) {
 #ifdef CONFIG_IP_VS_IPV6
 				if (af == AF_INET6) {
-					struct net *net =
-						dev_net(skb_dst(skb)->dev);
-
 					if (!skb->dev)
 						skb->dev = net->loopback_dev;
 					icmpv6_send(skb,
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 0fac601..6bee6d0 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -56,7 +56,7 @@
  * Make a summary from each cpu
  */
 static void ip_vs_read_cpu_stats(struct ip_vs_stats_user *sum,
-				 struct ip_vs_cpu_stats *stats)
+				 struct ip_vs_cpu_stats __percpu *stats)
 {
 	int i;
 
-- 
1.7.10.4
