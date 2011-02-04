From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 04/14] IPVS: Add {sysctl_sync_threshold,period}()
Date: Fri,  4 Feb 2011 18:46:12 +0900
Message-ID: <1296812782-14953-5-git-send-email-horms@verge.net.au>
References: <1296812782-14953-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1296812782-14953-1-git-send-email-horms@verge.net.au>
Sender: netfilter-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Simon Horman <horms@verge.net.au>

In preparation for not including sysctl_sync_threshold in
struct netns_ipvs when CONFIG_SYCTL is not defined.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/netns/ip_vs.h       |   29 +++++++++++++++++++++++++++++
 net/netfilter/ipvs/ip_vs_core.c |   10 +++++-----
 net/netfilter/ipvs/ip_vs_ctl.c  |    4 ++--
 net/netfilter/ipvs/ip_vs_sync.c |    4 ++--
 4 files changed, 38 insertions(+), 9 deletions(-)

diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
index 259ebac..e205767 100644
--- a/include/net/netns/ip_vs.h
+++ b/include/net/netns/ip_vs.h
@@ -140,4 +140,33 @@ struct netns_ipvs {
 	struct net		*net;            /* Needed by timer routines */
 };
 
+#define DEFAULT_SYNC_THRESHOLD	3
+#define DEFAULT_SYNC_PERIOD	50
+
+#ifdef CONFIG_SYSCTL
+
+static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_sync_threshold[0];
+}
+
+static inline int sysctl_sync_period(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_sync_threshold[1];
+}
+
+#else
+
+static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
+{
+	return DEFAULT_SYNC_THRESHOLD;
+}
+
+static inline int sysctl_sync_period(struct netns_ipvs *ipvs)
+{
+	return DEFAULT_SYNC_PERIOD;
+}
+
+#endif
+
 #endif /* IP_VS_H_ */
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 66bb68b..d7a7fcb 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1635,15 +1635,15 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	 */
 
 	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
-		pkts = ipvs->sysctl_sync_threshold[0];
+		pkts = sysctl_sync_threshold(ipvs);
 	else
 		pkts = atomic_add_return(1, &cp->in_pkts);
 
 	if ((ipvs->sync_state & IP_VS_STATE_MASTER) &&
 	    cp->protocol == IPPROTO_SCTP) {
 		if ((cp->state == IP_VS_SCTP_S_ESTABLISHED &&
-			(pkts % ipvs->sysctl_sync_threshold[1]
-			 == ipvs->sysctl_sync_threshold[0])) ||
+			(pkts % sysctl_sync_period(ipvs)
+			 == sysctl_sync_threshold(ipvs))) ||
 				(cp->old_state != cp->state &&
 				 ((cp->state == IP_VS_SCTP_S_CLOSED) ||
 				  (cp->state == IP_VS_SCTP_S_SHUT_ACK_CLI) ||
@@ -1657,8 +1657,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	else if ((ipvs->sync_state & IP_VS_STATE_MASTER) &&
 	    (((cp->protocol != IPPROTO_TCP ||
 	       cp->state == IP_VS_TCP_S_ESTABLISHED) &&
-	      (pkts % ipvs->sysctl_sync_threshold[1]
-	       == ipvs->sysctl_sync_threshold[0])) ||
+	      (pkts % sysctl_sync_period(ipvs)
+	       == sysctl_sync_threshold(ipvs))) ||
 	     ((cp->protocol == IPPROTO_TCP) && (cp->old_state != cp->state) &&
 	      ((cp->state == IP_VS_TCP_S_FIN_WAIT) ||
 	       (cp->state == IP_VS_TCP_S_CLOSE) ||
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c73b0c8..60a3686 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3545,8 +3545,8 @@ int __net_init __ip_vs_control_init(struct net *net)
 	tbl[idx++].data = &ipvs->sysctl_cache_bypass;
 	tbl[idx++].data = &ipvs->sysctl_expire_nodest_conn;
 	tbl[idx++].data = &ipvs->sysctl_expire_quiescent_template;
-	ipvs->sysctl_sync_threshold[0] = 3;
-	ipvs->sysctl_sync_threshold[1] = 50;
+	ipvs->sysctl_sync_threshold[0] = DEFAULT_SYNC_THRESHOLD;
+	ipvs->sysctl_sync_threshold[1] = DEFAULT_SYNC_PERIOD;
 	tbl[idx].data = &ipvs->sysctl_sync_threshold;
 	tbl[idx++].maxlen = sizeof(ipvs->sysctl_sync_threshold);
 	tbl[idx++].data = &ipvs->sysctl_nat_icmp_send;
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 2a2a836..7f8998e 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -650,7 +650,7 @@ control:
 	if (cp->flags & IP_VS_CONN_F_TEMPLATE) {
 		int pkts = atomic_add_return(1, &cp->in_pkts);
 
-		if (pkts % ipvs->sysctl_sync_threshold[1] != 1)
+		if (pkts % sysctl_sync_period(ipvs) != 1)
 			return;
 	}
 	goto sloop;
@@ -795,7 +795,7 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 
 	if (opt)
 		memcpy(&cp->in_seq, opt, sizeof(*opt));
-	atomic_set(&cp->in_pkts, ipvs->sysctl_sync_threshold[0]);
+	atomic_set(&cp->in_pkts, sysctl_sync_threshold(ipvs));
 	cp->state = state;
 	cp->old_state = cp->state;
 	/*
-- 
1.7.2.3

