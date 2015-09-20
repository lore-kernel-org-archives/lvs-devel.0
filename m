From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 40/84] ipvs: Pass ipvs not net to ip_vs_sync_conn
Date: Sun, 20 Sep 2015 01:22:56 -0500
Message-ID: <1442730220-32458-40-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
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
index f54e9afdf4dd..5d001f410fc5 100644
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
2.2.1

