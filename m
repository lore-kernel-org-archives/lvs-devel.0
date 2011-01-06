From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 07/22] IPVS: netns preparation for proto_udp
Date: Thu,  6 Jan 2011 15:16:03 +0900
Message-ID: <1294294578-8601-8-git-send-email-horms@verge.net.au>
References: <1294294578-8601-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1294294578-8601-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Patrick McHardy <kaber@trash.net>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

In this phase (one), all local vars will be moved to ipvs struct.

Remaining work, add param struct net *net to a couple of
functions that is common for all protos and use ip_vs_proto_data

*v3
Removed unused function set_state_timeout()

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/netns/ip_vs.h            |    8 +++
 net/netfilter/ipvs/ip_vs_proto.c     |    3 +
 net/netfilter/ipvs/ip_vs_proto_udp.c |   86 +++++++++++++++++-----------------
 3 files changed, 54 insertions(+), 43 deletions(-)

diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
index ac77363..62b1448 100644
--- a/include/net/netns/ip_vs.h
+++ b/include/net/netns/ip_vs.h
@@ -39,6 +39,14 @@ struct netns_ipvs {
 	struct list_head	tcp_apps[TCP_APP_TAB_SIZE];
 	spinlock_t		tcp_app_lock;
 #endif
+	/* ip_vs_proto_udp */
+#ifdef CONFIG_IP_VS_PROTO_UDP
+	#define	UDP_APP_TAB_BITS	4
+	#define	UDP_APP_TAB_SIZE	(1 << UDP_APP_TAB_BITS)
+	#define	UDP_APP_TAB_MASK	(UDP_APP_TAB_SIZE - 1)
+	struct list_head	udp_apps[UDP_APP_TAB_SIZE];
+	spinlock_t		udp_app_lock;
+#endif
 
 	/* ip_vs_lblc */
 	int			sysctl_lblc_expiration;
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 320c6a6..cdc4142 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -310,6 +310,9 @@ static int __net_init __ip_vs_protocol_init(struct net *net)
 #ifdef CONFIG_IP_VS_PROTO_TCP
 	register_ip_vs_proto_netns(net, &ip_vs_protocol_tcp);
 #endif
+#ifdef CONFIG_IP_VS_PROTO_UDP
+	register_ip_vs_proto_netns(net, &ip_vs_protocol_udp);
+#endif
 	return 0;
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 5ab54f6..71a4721 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -9,7 +9,8 @@
  *              as published by the Free Software Foundation; either version
  *              2 of the License, or (at your option) any later version.
  *
- * Changes:
+ * Changes:     Hans Schillstrom <hans.schillstrom@ericsson.com>
+ *              Network name space (netns) aware.
  *
  */
 
@@ -345,19 +346,6 @@ udp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
 	return 1;
 }
 
-
-/*
- *	Note: the caller guarantees that only one of register_app,
- *	unregister_app or app_conn_bind is called each time.
- */
-
-#define	UDP_APP_TAB_BITS	4
-#define	UDP_APP_TAB_SIZE	(1 << UDP_APP_TAB_BITS)
-#define	UDP_APP_TAB_MASK	(UDP_APP_TAB_SIZE - 1)
-
-static struct list_head udp_apps[UDP_APP_TAB_SIZE];
-static DEFINE_SPINLOCK(udp_app_lock);
-
 static inline __u16 udp_app_hashkey(__be16 port)
 {
 	return (((__force u16)port >> UDP_APP_TAB_BITS) ^ (__force u16)port)
@@ -371,22 +359,24 @@ static int udp_register_app(struct ip_vs_app *inc)
 	__u16 hash;
 	__be16 port = inc->port;
 	int ret = 0;
+	struct netns_ipvs *ipvs = net_ipvs(&init_net);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(&init_net, IPPROTO_UDP);
 
 	hash = udp_app_hashkey(port);
 
 
-	spin_lock_bh(&udp_app_lock);
-	list_for_each_entry(i, &udp_apps[hash], p_list) {
+	spin_lock_bh(&ipvs->udp_app_lock);
+	list_for_each_entry(i, &ipvs->udp_apps[hash], p_list) {
 		if (i->port == port) {
 			ret = -EEXIST;
 			goto out;
 		}
 	}
-	list_add(&inc->p_list, &udp_apps[hash]);
-	atomic_inc(&ip_vs_protocol_udp.appcnt);
+	list_add(&inc->p_list, &ipvs->udp_apps[hash]);
+	atomic_inc(&pd->pp->appcnt);
 
   out:
-	spin_unlock_bh(&udp_app_lock);
+	spin_unlock_bh(&ipvs->udp_app_lock);
 	return ret;
 }
 
@@ -394,15 +384,19 @@ static int udp_register_app(struct ip_vs_app *inc)
 static void
 udp_unregister_app(struct ip_vs_app *inc)
 {
-	spin_lock_bh(&udp_app_lock);
-	atomic_dec(&ip_vs_protocol_udp.appcnt);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(&init_net, IPPROTO_UDP);
+	struct netns_ipvs *ipvs = net_ipvs(&init_net);
+
+	spin_lock_bh(&ipvs->udp_app_lock);
+	atomic_dec(&pd->pp->appcnt);
 	list_del(&inc->p_list);
-	spin_unlock_bh(&udp_app_lock);
+	spin_unlock_bh(&ipvs->udp_app_lock);
 }
 
 
 static int udp_app_conn_bind(struct ip_vs_conn *cp)
 {
+	struct netns_ipvs *ipvs = net_ipvs(&init_net);
 	int hash;
 	struct ip_vs_app *inc;
 	int result = 0;
@@ -414,12 +408,12 @@ static int udp_app_conn_bind(struct ip_vs_conn *cp)
 	/* Lookup application incarnations and bind the right one */
 	hash = udp_app_hashkey(cp->vport);
 
-	spin_lock(&udp_app_lock);
-	list_for_each_entry(inc, &udp_apps[hash], p_list) {
+	spin_lock(&ipvs->udp_app_lock);
+	list_for_each_entry(inc, &ipvs->udp_apps[hash], p_list) {
 		if (inc->port == cp->vport) {
 			if (unlikely(!ip_vs_app_inc_get(inc)))
 				break;
-			spin_unlock(&udp_app_lock);
+			spin_unlock(&ipvs->udp_app_lock);
 
 			IP_VS_DBG_BUF(9, "%s(): Binding conn %s:%u->"
 				      "%s:%u to app %s on port %u\n",
@@ -436,14 +430,14 @@ static int udp_app_conn_bind(struct ip_vs_conn *cp)
 			goto out;
 		}
 	}
-	spin_unlock(&udp_app_lock);
+	spin_unlock(&ipvs->udp_app_lock);
 
   out:
 	return result;
 }
 
 
-static int udp_timeouts[IP_VS_UDP_S_LAST+1] = {
+static const int udp_timeouts[IP_VS_UDP_S_LAST+1] = {
 	[IP_VS_UDP_S_NORMAL]		=	5*60*HZ,
 	[IP_VS_UDP_S_LAST]		=	2*HZ,
 };
@@ -453,14 +447,6 @@ static const char *const udp_state_name_table[IP_VS_UDP_S_LAST+1] = {
 	[IP_VS_UDP_S_LAST]		=	"BUG!",
 };
 
-
-static int
-udp_set_state_timeout(struct ip_vs_protocol *pp, char *sname, int to)
-{
-	return ip_vs_set_state_timeout(pp->timeout_table, IP_VS_UDP_S_LAST,
-				       udp_state_name_table, sname, to);
-}
-
 static const char * udp_state_name(int state)
 {
 	if (state >= IP_VS_UDP_S_LAST)
@@ -473,18 +459,31 @@ udp_state_transition(struct ip_vs_conn *cp, int direction,
 		     const struct sk_buff *skb,
 		     struct ip_vs_protocol *pp)
 {
-	cp->timeout = pp->timeout_table[IP_VS_UDP_S_NORMAL];
+	struct ip_vs_proto_data *pd;   /* Temp fix, pp will be replaced by pd */
+
+	pd = ip_vs_proto_data_get(&init_net, IPPROTO_UDP);
+	if (unlikely(!pd)) {
+		pr_err("UDP no ns data\n");
+		return 0;
+	}
+
+	cp->timeout = pd->timeout_table[IP_VS_UDP_S_NORMAL];
 	return 1;
 }
 
-static void udp_init(struct ip_vs_protocol *pp)
+static void __udp_init(struct net *net, struct ip_vs_proto_data *pd)
 {
-	IP_VS_INIT_HASH_TABLE(udp_apps);
-	pp->timeout_table = udp_timeouts;
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
+	ip_vs_init_hash_table(ipvs->udp_apps, UDP_APP_TAB_SIZE);
+	spin_lock_init(&ipvs->udp_app_lock);
+	pd->timeout_table = ip_vs_create_timeout_table((int *)udp_timeouts,
+							sizeof(udp_timeouts));
 }
 
-static void udp_exit(struct ip_vs_protocol *pp)
+static void __udp_exit(struct net *net, struct ip_vs_proto_data *pd)
 {
+	kfree(pd->timeout_table);
 }
 
 
@@ -493,8 +492,10 @@ struct ip_vs_protocol ip_vs_protocol_udp = {
 	.protocol =		IPPROTO_UDP,
 	.num_states =		IP_VS_UDP_S_LAST,
 	.dont_defrag =		0,
-	.init =			udp_init,
-	.exit =			udp_exit,
+	.init =			NULL,
+	.exit =			NULL,
+	.init_netns =		__udp_init,
+	.exit_netns =		__udp_exit,
 	.conn_schedule =	udp_conn_schedule,
 	.conn_in_get =		ip_vs_conn_in_get_proto,
 	.conn_out_get =		ip_vs_conn_out_get_proto,
@@ -508,5 +509,4 @@ struct ip_vs_protocol ip_vs_protocol_udp = {
 	.app_conn_bind =	udp_app_conn_bind,
 	.debug_packet =		ip_vs_tcpudp_debug_packet,
 	.timeout_change =	NULL,
-	.set_state_timeout =	udp_set_state_timeout,
 };
-- 
1.7.2.3

