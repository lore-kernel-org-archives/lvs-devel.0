From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 10/15] ipvs: convert app locks
Date: Thu, 28 Mar 2013 14:39:39 +0900
Message-ID: <1364449184-26672-11-git-send-email-horms@verge.net.au>
References: <1364449184-26672-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1364449184-26672-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

We use locks like tcp_app_lock, udp_app_lock,
sctp_app_lock to protect access to the protocol hash tables
from readers in packet context while the application
instances (inc) are [un]registered under global mutex.

As the hash tables are mostly read when conns are
created and bound to app, use RCU for readers and reclaim
app instance after grace period.

Simplify ip_vs_app_inc_get because we use usecnt
only for statistics and rely on module refcounting.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h                   |    4 +---
 net/netfilter/ipvs/ip_vs_app.c        |   27 +++++++++++++++++++--------
 net/netfilter/ipvs/ip_vs_ftp.c        |    2 ++
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   18 ++++++------------
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |   18 ++++++------------
 net/netfilter/ipvs/ip_vs_proto_udp.c  |   19 ++++++-------------
 6 files changed, 40 insertions(+), 48 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 1c8f39a..3c91b58 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -823,6 +823,7 @@ struct ip_vs_app {
 	struct ip_vs_app	*app;		/* its real application */
 	__be16			port;		/* port number in net order */
 	atomic_t		usecnt;		/* usage counter */
+	struct rcu_head		rcu_head;
 
 	/*
 	 * output hook: Process packet in inout direction, diff set for TCP.
@@ -908,7 +909,6 @@ struct netns_ipvs {
 	#define	TCP_APP_TAB_SIZE	(1 << TCP_APP_TAB_BITS)
 	#define	TCP_APP_TAB_MASK	(TCP_APP_TAB_SIZE - 1)
 	struct list_head	tcp_apps[TCP_APP_TAB_SIZE];
-	spinlock_t		tcp_app_lock;
 #endif
 	/* ip_vs_proto_udp */
 #ifdef CONFIG_IP_VS_PROTO_UDP
@@ -916,7 +916,6 @@ struct netns_ipvs {
 	#define	UDP_APP_TAB_SIZE	(1 << UDP_APP_TAB_BITS)
 	#define	UDP_APP_TAB_MASK	(UDP_APP_TAB_SIZE - 1)
 	struct list_head	udp_apps[UDP_APP_TAB_SIZE];
-	spinlock_t		udp_app_lock;
 #endif
 	/* ip_vs_proto_sctp */
 #ifdef CONFIG_IP_VS_PROTO_SCTP
@@ -925,7 +924,6 @@ struct netns_ipvs {
 	#define SCTP_APP_TAB_MASK	(SCTP_APP_TAB_SIZE - 1)
 	/* Hash table for SCTP application incarnations	 */
 	struct list_head	sctp_apps[SCTP_APP_TAB_SIZE];
-	spinlock_t		sctp_app_lock;
 #endif
 	/* ip_vs_conn */
 	atomic_t		conn_count;      /*  connection counter */
diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index 0b779d7..a956030 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -58,6 +58,18 @@ static inline void ip_vs_app_put(struct ip_vs_app *app)
 	module_put(app->module);
 }
 
+static void ip_vs_app_inc_destroy(struct ip_vs_app *inc)
+{
+	kfree(inc->timeout_table);
+	kfree(inc);
+}
+
+static void ip_vs_app_inc_rcu_free(struct rcu_head *head)
+{
+	struct ip_vs_app *inc = container_of(head, struct ip_vs_app, rcu_head);
+
+	ip_vs_app_inc_destroy(inc);
+}
 
 /*
  *	Allocate/initialize app incarnation and register it in proto apps.
@@ -106,8 +118,7 @@ ip_vs_app_inc_new(struct net *net, struct ip_vs_app *app, __u16 proto,
 	return 0;
 
   out:
-	kfree(inc->timeout_table);
-	kfree(inc);
+	ip_vs_app_inc_destroy(inc);
 	return ret;
 }
 
@@ -131,8 +142,7 @@ ip_vs_app_inc_release(struct net *net, struct ip_vs_app *inc)
 
 	list_del(&inc->a_list);
 
-	kfree(inc->timeout_table);
-	kfree(inc);
+	call_rcu(&inc->rcu_head, ip_vs_app_inc_rcu_free);
 }
 
 
@@ -144,9 +154,9 @@ int ip_vs_app_inc_get(struct ip_vs_app *inc)
 {
 	int result;
 
-	atomic_inc(&inc->usecnt);
-	if (unlikely((result = ip_vs_app_get(inc->app)) != 1))
-		atomic_dec(&inc->usecnt);
+	result = ip_vs_app_get(inc->app);
+	if (result)
+		atomic_inc(&inc->usecnt);
 	return result;
 }
 
@@ -156,8 +166,8 @@ int ip_vs_app_inc_get(struct ip_vs_app *inc)
  */
 void ip_vs_app_inc_put(struct ip_vs_app *inc)
 {
-	ip_vs_app_put(inc->app);
 	atomic_dec(&inc->usecnt);
+	ip_vs_app_put(inc->app);
 }
 
 
@@ -218,6 +228,7 @@ out_unlock:
 /*
  *	ip_vs_app unregistration routine
  *	We are sure there are no app incarnations attached to services
+ *	Caller should use synchronize_rcu() or rcu_barrier()
  */
 void unregister_ip_vs_app(struct net *net, struct ip_vs_app *app)
 {
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 4f53a5f..7f90825 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -480,6 +480,7 @@ static int __init ip_vs_ftp_init(void)
 	int rv;
 
 	rv = register_pernet_subsys(&ip_vs_ftp_ops);
+	/* rcu_barrier() is called by netns on error */
 	return rv;
 }
 
@@ -489,6 +490,7 @@ static int __init ip_vs_ftp_init(void)
 static void __exit ip_vs_ftp_exit(void)
 {
 	unregister_pernet_subsys(&ip_vs_ftp_ops);
+	/* rcu_barrier() is called by netns */
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index ae8ec6f..9302448 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -1014,30 +1014,25 @@ static int sctp_register_app(struct net *net, struct ip_vs_app *inc)
 
 	hash = sctp_app_hashkey(port);
 
-	spin_lock_bh(&ipvs->sctp_app_lock);
 	list_for_each_entry(i, &ipvs->sctp_apps[hash], p_list) {
 		if (i->port == port) {
 			ret = -EEXIST;
 			goto out;
 		}
 	}
-	list_add(&inc->p_list, &ipvs->sctp_apps[hash]);
+	list_add_rcu(&inc->p_list, &ipvs->sctp_apps[hash]);
 	atomic_inc(&pd->appcnt);
 out:
-	spin_unlock_bh(&ipvs->sctp_app_lock);
 
 	return ret;
 }
 
 static void sctp_unregister_app(struct net *net, struct ip_vs_app *inc)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_SCTP);
 
-	spin_lock_bh(&ipvs->sctp_app_lock);
 	atomic_dec(&pd->appcnt);
-	list_del(&inc->p_list);
-	spin_unlock_bh(&ipvs->sctp_app_lock);
+	list_del_rcu(&inc->p_list);
 }
 
 static int sctp_app_conn_bind(struct ip_vs_conn *cp)
@@ -1053,12 +1048,12 @@ static int sctp_app_conn_bind(struct ip_vs_conn *cp)
 	/* Lookup application incarnations and bind the right one */
 	hash = sctp_app_hashkey(cp->vport);
 
-	spin_lock(&ipvs->sctp_app_lock);
-	list_for_each_entry(inc, &ipvs->sctp_apps[hash], p_list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(inc, &ipvs->sctp_apps[hash], p_list) {
 		if (inc->port == cp->vport) {
 			if (unlikely(!ip_vs_app_inc_get(inc)))
 				break;
-			spin_unlock(&ipvs->sctp_app_lock);
+			rcu_read_unlock();
 
 			IP_VS_DBG_BUF(9, "%s: Binding conn %s:%u->"
 					"%s:%u to app %s on port %u\n",
@@ -1074,7 +1069,7 @@ static int sctp_app_conn_bind(struct ip_vs_conn *cp)
 			goto out;
 		}
 	}
-	spin_unlock(&ipvs->sctp_app_lock);
+	rcu_read_unlock();
 out:
 	return result;
 }
@@ -1088,7 +1083,6 @@ static int __ip_vs_sctp_init(struct net *net, struct ip_vs_proto_data *pd)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	ip_vs_init_hash_table(ipvs->sctp_apps, SCTP_APP_TAB_SIZE);
-	spin_lock_init(&ipvs->sctp_app_lock);
 	pd->timeout_table = ip_vs_create_timeout_table((int *)sctp_timeouts,
 							sizeof(sctp_timeouts));
 	if (!pd->timeout_table)
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 9af653a..0bbc3fe 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -580,18 +580,16 @@ static int tcp_register_app(struct net *net, struct ip_vs_app *inc)
 
 	hash = tcp_app_hashkey(port);
 
-	spin_lock_bh(&ipvs->tcp_app_lock);
 	list_for_each_entry(i, &ipvs->tcp_apps[hash], p_list) {
 		if (i->port == port) {
 			ret = -EEXIST;
 			goto out;
 		}
 	}
-	list_add(&inc->p_list, &ipvs->tcp_apps[hash]);
+	list_add_rcu(&inc->p_list, &ipvs->tcp_apps[hash]);
 	atomic_inc(&pd->appcnt);
 
   out:
-	spin_unlock_bh(&ipvs->tcp_app_lock);
 	return ret;
 }
 
@@ -599,13 +597,10 @@ static int tcp_register_app(struct net *net, struct ip_vs_app *inc)
 static void
 tcp_unregister_app(struct net *net, struct ip_vs_app *inc)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
 
-	spin_lock_bh(&ipvs->tcp_app_lock);
 	atomic_dec(&pd->appcnt);
-	list_del(&inc->p_list);
-	spin_unlock_bh(&ipvs->tcp_app_lock);
+	list_del_rcu(&inc->p_list);
 }
 
 
@@ -624,12 +619,12 @@ tcp_app_conn_bind(struct ip_vs_conn *cp)
 	/* Lookup application incarnations and bind the right one */
 	hash = tcp_app_hashkey(cp->vport);
 
-	spin_lock(&ipvs->tcp_app_lock);
-	list_for_each_entry(inc, &ipvs->tcp_apps[hash], p_list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(inc, &ipvs->tcp_apps[hash], p_list) {
 		if (inc->port == cp->vport) {
 			if (unlikely(!ip_vs_app_inc_get(inc)))
 				break;
-			spin_unlock(&ipvs->tcp_app_lock);
+			rcu_read_unlock();
 
 			IP_VS_DBG_BUF(9, "%s(): Binding conn %s:%u->"
 				      "%s:%u to app %s on port %u\n",
@@ -646,7 +641,7 @@ tcp_app_conn_bind(struct ip_vs_conn *cp)
 			goto out;
 		}
 	}
-	spin_unlock(&ipvs->tcp_app_lock);
+	rcu_read_unlock();
 
   out:
 	return result;
@@ -676,7 +671,6 @@ static int __ip_vs_tcp_init(struct net *net, struct ip_vs_proto_data *pd)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	ip_vs_init_hash_table(ipvs->tcp_apps, TCP_APP_TAB_SIZE);
-	spin_lock_init(&ipvs->tcp_app_lock);
 	pd->timeout_table = ip_vs_create_timeout_table((int *)tcp_timeouts,
 							sizeof(tcp_timeouts));
 	if (!pd->timeout_table)
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 503a842..1a03e2d 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -359,19 +359,16 @@ static int udp_register_app(struct net *net, struct ip_vs_app *inc)
 
 	hash = udp_app_hashkey(port);
 
-
-	spin_lock_bh(&ipvs->udp_app_lock);
 	list_for_each_entry(i, &ipvs->udp_apps[hash], p_list) {
 		if (i->port == port) {
 			ret = -EEXIST;
 			goto out;
 		}
 	}
-	list_add(&inc->p_list, &ipvs->udp_apps[hash]);
+	list_add_rcu(&inc->p_list, &ipvs->udp_apps[hash]);
 	atomic_inc(&pd->appcnt);
 
   out:
-	spin_unlock_bh(&ipvs->udp_app_lock);
 	return ret;
 }
 
@@ -380,12 +377,9 @@ static void
 udp_unregister_app(struct net *net, struct ip_vs_app *inc)
 {
 	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_UDP);
-	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	spin_lock_bh(&ipvs->udp_app_lock);
 	atomic_dec(&pd->appcnt);
-	list_del(&inc->p_list);
-	spin_unlock_bh(&ipvs->udp_app_lock);
+	list_del_rcu(&inc->p_list);
 }
 
 
@@ -403,12 +397,12 @@ static int udp_app_conn_bind(struct ip_vs_conn *cp)
 	/* Lookup application incarnations and bind the right one */
 	hash = udp_app_hashkey(cp->vport);
 
-	spin_lock(&ipvs->udp_app_lock);
-	list_for_each_entry(inc, &ipvs->udp_apps[hash], p_list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(inc, &ipvs->udp_apps[hash], p_list) {
 		if (inc->port == cp->vport) {
 			if (unlikely(!ip_vs_app_inc_get(inc)))
 				break;
-			spin_unlock(&ipvs->udp_app_lock);
+			rcu_read_unlock();
 
 			IP_VS_DBG_BUF(9, "%s(): Binding conn %s:%u->"
 				      "%s:%u to app %s on port %u\n",
@@ -425,7 +419,7 @@ static int udp_app_conn_bind(struct ip_vs_conn *cp)
 			goto out;
 		}
 	}
-	spin_unlock(&ipvs->udp_app_lock);
+	rcu_read_unlock();
 
   out:
 	return result;
@@ -467,7 +461,6 @@ static int __udp_init(struct net *net, struct ip_vs_proto_data *pd)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	ip_vs_init_hash_table(ipvs->udp_apps, UDP_APP_TAB_SIZE);
-	spin_lock_init(&ipvs->udp_app_lock);
 	pd->timeout_table = ip_vs_create_timeout_table((int *)udp_timeouts,
 							sizeof(udp_timeouts));
 	if (!pd->timeout_table)
-- 
1.7.10.4

