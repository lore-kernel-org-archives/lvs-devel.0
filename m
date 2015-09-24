From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 40/84] ipvs: Pass ipvs not net to ip_vs_sync_conn
Date: Thu, 24 Sep 2015 09:52:25 +0900
Message-ID: <1443055989-1306-41-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
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
 include/net/ip_vs.h             | 2 +-
 net/netfilter/ipvs/ip_vs_conn.c | 3 +--
 net/netfilter/ipvs/ip_vs_core.c | 2 +-
 net/netfilter/ipvs/ip_vs_sync.c | 5 ++---
 4 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 71f4d338c208..b10b337ce974 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1452,7 +1452,7 @@ static inline void ip_vs_dest_put_and_free(struct ip_vs_dest *dest)
 int start_sync_thread(struct netns_ipvs *ipvs, struct ipvs_sync_daemon_cfg *cfg,
 		      int state);
 int stop_sync_thread(struct netns_ipvs *ipvs, int state);
-void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp, int pkts);
+void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts);
 
 /* IPVS rate estimator prototypes (from ip_vs_est.c) */
 void ip_vs_start_estimator(struct net *net, struct ip_vs_stats *stats);
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index d0d57f14bc76..06809db5eef6 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -801,7 +801,6 @@ static void ip_vs_conn_expire(unsigned long data)
 {
 	struct ip_vs_conn *cp = (struct ip_vs_conn *)data;
 	struct netns_ipvs *ipvs = cp->ipvs;
-	struct net *net = ipvs->net;
 
 	/*
 	 *	do I control anybody?
@@ -847,7 +846,7 @@ static void ip_vs_conn_expire(unsigned long data)
 	cp->timeout = 60*HZ;
 
 	if (ipvs->sync_state & IP_VS_STATE_MASTER)
-		ip_vs_sync_conn(net, cp, sysctl_sync_threshold(ipvs));
+		ip_vs_sync_conn(ipvs, cp, sysctl_sync_threshold(ipvs));
 
 	ip_vs_conn_put(cp);
 }
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 2e96500c6f3f..a8128b06f73b 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1842,7 +1842,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 		pkts = atomic_add_return(1, &cp->in_pkts);
 
 	if (ipvs->sync_state & IP_VS_STATE_MASTER)
-		ip_vs_sync_conn(net, cp, pkts);
+		ip_vs_sync_conn(ipvs, cp, pkts);
 
 	ip_vs_conn_put(cp);
 	return ret;
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 58ec7850ab06..a0808f230cd6 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -614,7 +614,7 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
 			pkts = atomic_add_return(1, &cp->in_pkts);
 		else
 			pkts = sysctl_sync_threshold(ipvs);
-		ip_vs_sync_conn(ipvs->net, cp, pkts);
+		ip_vs_sync_conn(ipvs, cp, pkts);
 	}
 }
 
@@ -623,9 +623,8 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
  *      Called by ip_vs_in.
  *      Sending Version 1 messages
  */
-void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp, int pkts)
+void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_sync_mesg *m;
 	union ip_vs_sync_conn *s;
 	struct ip_vs_sync_buff *buff;
-- 
2.1.4

