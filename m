From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 08/22] IPVS: netns preparation for proto_sctp
Date: Thu,  6 Jan 2011 15:16:04 +0900
Message-ID: <1294294578-8601-9-git-send-email-horms@verge.net.au>
References: <1294294578-8601-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1294294578-8601-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
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
 Removed unuset function set_state_timeout()

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/netns/ip_vs.h             |    9 +++
 net/netfilter/ipvs/ip_vs_proto.c      |    3 +
 net/netfilter/ipvs/ip_vs_proto_sctp.c |  121 ++++++++++++++++-----------------
 3 files changed, 70 insertions(+), 63 deletions(-)

diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
index 62b1448..58bd3fd 100644
--- a/include/net/netns/ip_vs.h
+++ b/include/net/netns/ip_vs.h
@@ -47,6 +47,15 @@ struct netns_ipvs {
 	struct list_head	udp_apps[UDP_APP_TAB_SIZE];
 	spinlock_t		udp_app_lock;
 #endif
+	/* ip_vs_proto_sctp */
+#ifdef CONFIG_IP_VS_PROTO_SCTP
+	#define SCTP_APP_TAB_BITS	4
+	#define SCTP_APP_TAB_SIZE	(1 << SCTP_APP_TAB_BITS)
+	#define SCTP_APP_TAB_MASK	(SCTP_APP_TAB_SIZE - 1)
+	/* Hash table for SCTP application incarnations	 */
+	struct list_head	sctp_apps[SCTP_APP_TAB_SIZE];
+	spinlock_t		sctp_app_lock;
+#endif
 
 	/* ip_vs_lblc */
 	int			sysctl_lblc_expiration;
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index cdc4142..001b2f8 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -313,6 +313,9 @@ static int __net_init __ip_vs_protocol_init(struct net *net)
 #ifdef CONFIG_IP_VS_PROTO_UDP
 	register_ip_vs_proto_netns(net, &ip_vs_protocol_udp);
 #endif
+#ifdef CONFIG_IP_VS_PROTO_SCTP
+	register_ip_vs_proto_netns(net, &ip_vs_protocol_sctp);
+#endif
 	return 0;
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 521b827..f826dd1 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -862,7 +862,7 @@ static struct ipvs_sctp_nextstate
 /*
  *      Timeout table[state]
  */
-static int sctp_timeouts[IP_VS_SCTP_S_LAST + 1] = {
+static const int sctp_timeouts[IP_VS_SCTP_S_LAST + 1] = {
 	[IP_VS_SCTP_S_NONE]         =     2 * HZ,
 	[IP_VS_SCTP_S_INIT_CLI]     =     1 * 60 * HZ,
 	[IP_VS_SCTP_S_INIT_SER]     =     1 * 60 * HZ,
@@ -906,18 +906,6 @@ static const char *sctp_state_name(int state)
 	return "?";
 }
 
-static void sctp_timeout_change(struct ip_vs_protocol *pp, int flags)
-{
-}
-
-static int
-sctp_set_state_timeout(struct ip_vs_protocol *pp, char *sname, int to)
-{
-
-return ip_vs_set_state_timeout(pp->timeout_table, IP_VS_SCTP_S_LAST,
-				sctp_state_name_table, sname, to);
-}
-
 static inline int
 set_sctp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 		int direction, const struct sk_buff *skb)
@@ -926,6 +914,7 @@ set_sctp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 	unsigned char chunk_type;
 	int event, next_state;
 	int ihl;
+	struct ip_vs_proto_data *pd;
 
 #ifdef CONFIG_IP_VS_IPV6
 	ihl = cp->af == AF_INET ? ip_hdrlen(skb) : sizeof(struct ipv6hdr);
@@ -1001,10 +990,13 @@ set_sctp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 			}
 		}
 	}
+	pd = ip_vs_proto_data_get(&init_net, pp->protocol); /* tmp fix */
+	if (likely(pd))
+		cp->timeout = pd->timeout_table[cp->state = next_state];
+	else	/* What to do ? */
+		cp->timeout = sctp_timeouts[cp->state = next_state];
 
-	 cp->timeout = pp->timeout_table[cp->state = next_state];
-
-	 return 1;
+	return 1;
 }
 
 static int
@@ -1020,16 +1012,6 @@ sctp_state_transition(struct ip_vs_conn *cp, int direction,
 	return ret;
 }
 
-/*
- *      Hash table for SCTP application incarnations
- */
-#define SCTP_APP_TAB_BITS        4
-#define SCTP_APP_TAB_SIZE        (1 << SCTP_APP_TAB_BITS)
-#define SCTP_APP_TAB_MASK        (SCTP_APP_TAB_SIZE - 1)
-
-static struct list_head sctp_apps[SCTP_APP_TAB_SIZE];
-static DEFINE_SPINLOCK(sctp_app_lock);
-
 static inline __u16 sctp_app_hashkey(__be16 port)
 {
 	return (((__force u16)port >> SCTP_APP_TAB_BITS) ^ (__force u16)port)
@@ -1042,34 +1024,40 @@ static int sctp_register_app(struct ip_vs_app *inc)
 	__u16 hash;
 	__be16 port = inc->port;
 	int ret = 0;
+	struct netns_ipvs *ipvs = net_ipvs(&init_net);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(&init_net, IPPROTO_SCTP);
 
 	hash = sctp_app_hashkey(port);
 
-	spin_lock_bh(&sctp_app_lock);
-	list_for_each_entry(i, &sctp_apps[hash], p_list) {
+	spin_lock_bh(&ipvs->sctp_app_lock);
+	list_for_each_entry(i, &ipvs->sctp_apps[hash], p_list) {
 		if (i->port == port) {
 			ret = -EEXIST;
 			goto out;
 		}
 	}
-	list_add(&inc->p_list, &sctp_apps[hash]);
-	atomic_inc(&ip_vs_protocol_sctp.appcnt);
+	list_add(&inc->p_list, &ipvs->sctp_apps[hash]);
+	atomic_inc(&pd->pp->appcnt);
 out:
-	spin_unlock_bh(&sctp_app_lock);
+	spin_unlock_bh(&ipvs->sctp_app_lock);
 
 	return ret;
 }
 
 static void sctp_unregister_app(struct ip_vs_app *inc)
 {
-	spin_lock_bh(&sctp_app_lock);
-	atomic_dec(&ip_vs_protocol_sctp.appcnt);
+	struct netns_ipvs *ipvs = net_ipvs(&init_net);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(&init_net, IPPROTO_SCTP);
+
+	spin_lock_bh(&ipvs->sctp_app_lock);
+	atomic_dec(&pd->pp->appcnt);
 	list_del(&inc->p_list);
-	spin_unlock_bh(&sctp_app_lock);
+	spin_unlock_bh(&ipvs->sctp_app_lock);
 }
 
 static int sctp_app_conn_bind(struct ip_vs_conn *cp)
 {
+	struct netns_ipvs *ipvs = net_ipvs(&init_net);
 	int hash;
 	struct ip_vs_app *inc;
 	int result = 0;
@@ -1080,12 +1068,12 @@ static int sctp_app_conn_bind(struct ip_vs_conn *cp)
 	/* Lookup application incarnations and bind the right one */
 	hash = sctp_app_hashkey(cp->vport);
 
-	spin_lock(&sctp_app_lock);
-	list_for_each_entry(inc, &sctp_apps[hash], p_list) {
+	spin_lock(&ipvs->sctp_app_lock);
+	list_for_each_entry(inc, &ipvs->sctp_apps[hash], p_list) {
 		if (inc->port == cp->vport) {
 			if (unlikely(!ip_vs_app_inc_get(inc)))
 				break;
-			spin_unlock(&sctp_app_lock);
+			spin_unlock(&ipvs->sctp_app_lock);
 
 			IP_VS_DBG_BUF(9, "%s: Binding conn %s:%u->"
 					"%s:%u to app %s on port %u\n",
@@ -1101,43 +1089,50 @@ static int sctp_app_conn_bind(struct ip_vs_conn *cp)
 			goto out;
 		}
 	}
-	spin_unlock(&sctp_app_lock);
+	spin_unlock(&ipvs->sctp_app_lock);
 out:
 	return result;
 }
 
-static void ip_vs_sctp_init(struct ip_vs_protocol *pp)
+/* ---------------------------------------------
+ *   timeouts is netns related now.
+ * ---------------------------------------------
+ */
+static void __ip_vs_sctp_init(struct net *net, struct ip_vs_proto_data *pd)
 {
-	IP_VS_INIT_HASH_TABLE(sctp_apps);
-	pp->timeout_table = sctp_timeouts;
-}
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
+	ip_vs_init_hash_table(ipvs->sctp_apps, SCTP_APP_TAB_SIZE);
+	spin_lock_init(&ipvs->tcp_app_lock);
+	pd->timeout_table = ip_vs_create_timeout_table((int *)sctp_timeouts,
+							sizeof(sctp_timeouts));
+}
 
-static void ip_vs_sctp_exit(struct ip_vs_protocol *pp)
+static void __ip_vs_sctp_exit(struct net *net, struct ip_vs_proto_data *pd)
 {
-
+	kfree(pd->timeout_table);
 }
 
 struct ip_vs_protocol ip_vs_protocol_sctp = {
-	.name = "SCTP",
-	.protocol = IPPROTO_SCTP,
-	.num_states = IP_VS_SCTP_S_LAST,
-	.dont_defrag = 0,
-	.appcnt = ATOMIC_INIT(0),
-	.init = ip_vs_sctp_init,
-	.exit = ip_vs_sctp_exit,
-	.register_app = sctp_register_app,
+	.name		= "SCTP",
+	.protocol	= IPPROTO_SCTP,
+	.num_states	= IP_VS_SCTP_S_LAST,
+	.dont_defrag	= 0,
+	.init		= NULL,
+	.exit		= NULL,
+	.init_netns	= __ip_vs_sctp_init,
+	.exit_netns	= __ip_vs_sctp_exit,
+	.register_app	= sctp_register_app,
 	.unregister_app = sctp_unregister_app,
-	.conn_schedule = sctp_conn_schedule,
-	.conn_in_get = ip_vs_conn_in_get_proto,
-	.conn_out_get = ip_vs_conn_out_get_proto,
-	.snat_handler = sctp_snat_handler,
-	.dnat_handler = sctp_dnat_handler,
-	.csum_check = sctp_csum_check,
-	.state_name = sctp_state_name,
+	.conn_schedule	= sctp_conn_schedule,
+	.conn_in_get	= ip_vs_conn_in_get_proto,
+	.conn_out_get	= ip_vs_conn_out_get_proto,
+	.snat_handler	= sctp_snat_handler,
+	.dnat_handler	= sctp_dnat_handler,
+	.csum_check	= sctp_csum_check,
+	.state_name	= sctp_state_name,
 	.state_transition = sctp_state_transition,
-	.app_conn_bind = sctp_app_conn_bind,
-	.debug_packet = ip_vs_tcpudp_debug_packet,
-	.timeout_change = sctp_timeout_change,
-	.set_state_timeout = sctp_set_state_timeout,
+	.app_conn_bind	= sctp_app_conn_bind,
+	.debug_packet	= ip_vs_tcpudp_debug_packet,
+	.timeout_change	= NULL,
 };
-- 
1.7.2.3

