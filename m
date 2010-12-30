From: hans@schillstrom.com
Subject: [*v3 PATCH 06/22]  IPVS: netns preparation for proto_tcp
Date: Thu, 30 Dec 2010 11:50:50 +0100
Message-ID: <1293706266-27152-7-git-send-email-hans@schillstrom.com>
References: <1293706266-27152-1-git-send-email-hans@schillstrom.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1293706266-27152-1-git-send-email-hans@schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

In this phase (one), all local vars will be moved to ipvs struct.

Remaining work, add param struct net *net to a couple of
functions that is common for all protos and use all
ip_vs_proto_data

*v3
Removed unused function as sugested by Simon

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/ip_vs.h                  |    6 +-
 include/net/netns/ip_vs.h            |    8 +++
 net/netfilter/ipvs/ip_vs_ftp.c       |    8 ++-
 net/netfilter/ipvs/ip_vs_proto.c     |   13 ++++-
 net/netfilter/ipvs/ip_vs_proto_tcp.c |  101 ++++++++++++++++++----------------
 5 files changed, 83 insertions(+), 53 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 4fc61bc..8e544be 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -41,7 +41,7 @@ static inline struct netns_ipvs * net_ipvs(struct net* net)
  * Get net ptr from skb in traffic cases
  * use skb_sknet when call is from userland (ioctl or netlink)
  */
-static inline struct net *skb_net(struct sk_buff *skb) {
+static inline struct net *skb_net(const struct sk_buff *skb) {
 #ifdef CONFIG_NET_NS
 #ifdef CONFIG_IP_VS_DEBUG
 	/*
@@ -68,7 +68,7 @@ static inline struct net *skb_net(struct sk_buff *skb) {
 #endif
 }
 
-static inline struct net *skb_sknet(struct sk_buff *skb) {
+static inline struct net *skb_sknet(const struct sk_buff *skb) {
 #ifdef CONFIG_NET_NS
 #ifdef CONFIG_IP_VS_DEBUG
 	/* Start with the most likely hit */
@@ -805,7 +805,7 @@ extern void ip_vs_conn_expire_now(struct ip_vs_conn *cp);
 
 extern const char * ip_vs_state_name(__u16 proto, int state);
 
-extern void ip_vs_tcp_conn_listen(struct ip_vs_conn *cp);
+extern void ip_vs_tcp_conn_listen(struct net *net, struct ip_vs_conn *cp);
 extern int ip_vs_check_template(struct ip_vs_conn *ct);
 extern void ip_vs_random_dropentry(void);
 extern int ip_vs_conn_init(void);
diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
index b7d7815..512cdd0 100644
--- a/include/net/netns/ip_vs.h
+++ b/include/net/netns/ip_vs.h
@@ -32,6 +32,14 @@ struct netns_ipvs {
 	/* ip_vs_proto */
 	#define IP_VS_PROTO_TAB_SIZE	32	/* must be power of 2 */
 	struct ip_vs_proto_data *proto_data_table[IP_VS_PROTO_TAB_SIZE];
+	/* ip_vs_proto_tcp */
+#ifdef CONFIG_IP_VS_PROTO_TCP
+	#define	TCP_APP_TAB_BITS	4
+	#define	TCP_APP_TAB_SIZE	(1 << TCP_APP_TAB_BITS)
+	#define	TCP_APP_TAB_MASK	(TCP_APP_TAB_SIZE - 1)
+	struct list_head 	tcp_apps[TCP_APP_TAB_SIZE];
+	spinlock_t		tcp_app_lock;
+#endif
 
 	/* ip_vs_lblc */
 	int 			sysctl_lblc_expiration;
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 0e762f3..b38ae94 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -157,6 +157,7 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	int ret = 0;
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct;
+	struct net *net;
 
 #ifdef CONFIG_IP_VS_IPV6
 	/* This application helper doesn't work with IPv6 yet,
@@ -257,8 +258,9 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		 * would be adjusted twice.
 		 */
 
+		net = skb_net(skb);
 		cp->app_data = NULL;
-		ip_vs_tcp_conn_listen(n_cp);
+		ip_vs_tcp_conn_listen(net, n_cp);
 		ip_vs_conn_put(n_cp);
 		return ret;
 	}
@@ -287,6 +289,7 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	union nf_inet_addr to;
 	__be16 port;
 	struct ip_vs_conn *n_cp;
+	struct net *net;
 
 #ifdef CONFIG_IP_VS_IPV6
 	/* This application helper doesn't work with IPv6 yet,
@@ -378,7 +381,8 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	/*
 	 *	Move tunnel to listen state
 	 */
-	ip_vs_tcp_conn_listen(n_cp);
+	net = skb_net(skb);
+	ip_vs_tcp_conn_listen(net, n_cp);
 	ip_vs_conn_put(n_cp);
 
 	return 1;
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 8caaf3e..90d69c5 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -307,12 +307,23 @@ ip_vs_tcpudp_debug_packet(int af, struct ip_vs_protocol *pp,
  */
 static int  __net_init  __ip_vs_protocol_init(struct net *net)
 {
+#ifdef CONFIG_IP_VS_PROTO_TCP
+	register_ip_vs_proto_netns(net, &ip_vs_protocol_tcp);
+#endif
 	return 0;
 }
 
 static void __net_exit __ip_vs_protocol_cleanup(struct net *net)
 {
-	/* empty */
+	struct netns_ipvs *ipvs = net_ipvs(net);
+	struct ip_vs_proto_data *pd;
+	int i;
+
+	/* unregister all the ipvs proto data for this netns */
+	for (i = 0; i < IP_VS_PROTO_TAB_SIZE; i++) {
+		while ((pd = ipvs->proto_data_table[i]) != NULL)
+			unregister_ip_vs_proto_netns(net, pd);
+	}
 }
 
 static struct pernet_operations ipvs_proto_ops = {
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 5e4da60..88f3a22 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -9,8 +9,12 @@
  *              as published by the Free Software Foundation; either version
  *              2 of the License, or (at your option) any later version.
  *
- * Changes:
+ * Changes:     Hans Schillstrom <hans.schillstrom@ericsson.com>
  *
+ *              Network name space (netns) aware.
+ *              Global data moved to netns i.e struct netns_ipvs
+ *              tcp_timeouts table has copy per netns in a hash table per
+ *              protocol ip_vs_proto_data and is handled by netns
  */
 
 #define KMSG_COMPONENT "IPVS"
@@ -46,8 +50,8 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 	net = skb_net(skb);
 	/* No !th->ack check to allow scheduling on SYN+ACK for Active FTP */
 	if (th->syn &&
-	    (svc = ip_vs_service_get(net, af, skb->mark, iph.protocol, &iph.daddr,
-				     th->dest))) {
+	    (svc = ip_vs_service_get(net, af, skb->mark, iph.protocol,
+				     &iph.daddr, th->dest))) {
 		int ignored;
 
 		if (ip_vs_todrop()) {
@@ -345,7 +349,7 @@ static const int tcp_state_off[IP_VS_DIR_LAST] = {
 /*
  *	Timeout table[state]
  */
-static int tcp_timeouts[IP_VS_TCP_S_LAST+1] = {
+static const int tcp_timeouts[IP_VS_TCP_S_LAST+1] = {
 	[IP_VS_TCP_S_NONE]		=	2*HZ,
 	[IP_VS_TCP_S_ESTABLISHED]	=	15*60*HZ,
 	[IP_VS_TCP_S_SYN_SENT]		=	2*60*HZ,
@@ -460,13 +464,6 @@ static void tcp_timeout_change(struct ip_vs_protocol *pp, int flags)
 	tcp_state_table = (on? tcp_states_dos : tcp_states);
 }
 
-static int
-tcp_set_state_timeout(struct ip_vs_protocol *pp, char *sname, int to)
-{
-	return ip_vs_set_state_timeout(pp->timeout_table, IP_VS_TCP_S_LAST,
-				       tcp_state_name_table, sname, to);
-}
-
 static inline int tcp_state_idx(struct tcphdr *th)
 {
 	if (th->rst)
@@ -487,6 +484,7 @@ set_tcp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 	int state_idx;
 	int new_state = IP_VS_TCP_S_CLOSE;
 	int state_off = tcp_state_off[direction];
+	struct ip_vs_proto_data *pd;  /* Temp fix */
 
 	/*
 	 *    Update state offset to INPUT_ONLY if necessary
@@ -542,10 +540,13 @@ set_tcp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 		}
 	}
 
-	cp->timeout = pp->timeout_table[cp->state = new_state];
+	pd = ip_vs_proto_data_get(&init_net, pp->protocol);
+	if (likely(pd))
+		cp->timeout = pd->timeout_table[cp->state = new_state];
+	else	/* What to do ? */
+		cp->timeout = tcp_timeouts[cp->state = new_state];
 }
 
-
 /*
  *	Handle state transitions
  */
@@ -573,17 +574,6 @@ tcp_state_transition(struct ip_vs_conn *cp, int direction,
 	return 1;
 }
 
-
-/*
- *	Hash table for TCP application incarnations
- */
-#define	TCP_APP_TAB_BITS	4
-#define	TCP_APP_TAB_SIZE	(1 << TCP_APP_TAB_BITS)
-#define	TCP_APP_TAB_MASK	(TCP_APP_TAB_SIZE - 1)
-
-static struct list_head tcp_apps[TCP_APP_TAB_SIZE];
-static DEFINE_SPINLOCK(tcp_app_lock);
-
 static inline __u16 tcp_app_hashkey(__be16 port)
 {
 	return (((__force u16)port >> TCP_APP_TAB_BITS) ^ (__force u16)port)
@@ -597,21 +587,23 @@ static int tcp_register_app(struct ip_vs_app *inc)
 	__u16 hash;
 	__be16 port = inc->port;
 	int ret = 0;
+	struct netns_ipvs *ipvs = net_ipvs(&init_net);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(&init_net, IPPROTO_TCP);
 
 	hash = tcp_app_hashkey(port);
 
-	spin_lock_bh(&tcp_app_lock);
-	list_for_each_entry(i, &tcp_apps[hash], p_list) {
+	spin_lock_bh(&ipvs->tcp_app_lock);
+	list_for_each_entry(i, &ipvs->tcp_apps[hash], p_list) {
 		if (i->port == port) {
 			ret = -EEXIST;
 			goto out;
 		}
 	}
-	list_add(&inc->p_list, &tcp_apps[hash]);
-	atomic_inc(&ip_vs_protocol_tcp.appcnt);
+	list_add(&inc->p_list, &ipvs->tcp_apps[hash]);
+	atomic_inc(&pd->pp->appcnt);
 
   out:
-	spin_unlock_bh(&tcp_app_lock);
+	spin_unlock_bh(&ipvs->tcp_app_lock);
 	return ret;
 }
 
@@ -619,16 +611,20 @@ static int tcp_register_app(struct ip_vs_app *inc)
 static void
 tcp_unregister_app(struct ip_vs_app *inc)
 {
-	spin_lock_bh(&tcp_app_lock);
-	atomic_dec(&ip_vs_protocol_tcp.appcnt);
+	struct netns_ipvs *ipvs = net_ipvs(&init_net);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(&init_net, IPPROTO_TCP);
+
+	spin_lock_bh(&ipvs->tcp_app_lock);
+	atomic_dec(&pd->pp->appcnt);
 	list_del(&inc->p_list);
-	spin_unlock_bh(&tcp_app_lock);
+	spin_unlock_bh(&ipvs->tcp_app_lock);
 }
 
 
 static int
 tcp_app_conn_bind(struct ip_vs_conn *cp)
 {
+	struct netns_ipvs *ipvs = net_ipvs(&init_net);
 	int hash;
 	struct ip_vs_app *inc;
 	int result = 0;
@@ -640,12 +636,12 @@ tcp_app_conn_bind(struct ip_vs_conn *cp)
 	/* Lookup application incarnations and bind the right one */
 	hash = tcp_app_hashkey(cp->vport);
 
-	spin_lock(&tcp_app_lock);
-	list_for_each_entry(inc, &tcp_apps[hash], p_list) {
+	spin_lock(&ipvs->tcp_app_lock);
+	list_for_each_entry(inc, &ipvs->tcp_apps[hash], p_list) {
 		if (inc->port == cp->vport) {
 			if (unlikely(!ip_vs_app_inc_get(inc)))
 				break;
-			spin_unlock(&tcp_app_lock);
+			spin_unlock(&ipvs->tcp_app_lock);
 
 			IP_VS_DBG_BUF(9, "%s(): Binding conn %s:%u->"
 				      "%s:%u to app %s on port %u\n",
@@ -662,7 +658,7 @@ tcp_app_conn_bind(struct ip_vs_conn *cp)
 			goto out;
 		}
 	}
-	spin_unlock(&tcp_app_lock);
+	spin_unlock(&ipvs->tcp_app_lock);
 
   out:
 	return result;
@@ -672,24 +668,34 @@ tcp_app_conn_bind(struct ip_vs_conn *cp)
 /*
  *	Set LISTEN timeout. (ip_vs_conn_put will setup timer)
  */
-void ip_vs_tcp_conn_listen(struct ip_vs_conn *cp)
+void ip_vs_tcp_conn_listen(struct net *net, struct ip_vs_conn *cp)
 {
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
+
 	spin_lock(&cp->lock);
 	cp->state = IP_VS_TCP_S_LISTEN;
-	cp->timeout = ip_vs_protocol_tcp.timeout_table[IP_VS_TCP_S_LISTEN];
+	cp->timeout = ( pd ? pd->timeout_table[IP_VS_TCP_S_LISTEN]
+			   : tcp_timeouts[IP_VS_TCP_S_LISTEN]);
 	spin_unlock(&cp->lock);
 }
 
-
-static void ip_vs_tcp_init(struct ip_vs_protocol *pp)
+/* ---------------------------------------------
+ *   timeouts is netns related now.
+ * ---------------------------------------------
+ */
+static void __ip_vs_tcp_init(struct net *net, struct ip_vs_proto_data *pd)
 {
-	IP_VS_INIT_HASH_TABLE(tcp_apps);
-	pp->timeout_table = tcp_timeouts;
-}
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
+	ip_vs_init_hash_table(ipvs->tcp_apps, TCP_APP_TAB_SIZE);
+	spin_lock_init(&ipvs->tcp_app_lock);
+	pd->timeout_table = ip_vs_create_timeout_table((int*)tcp_timeouts,
+							sizeof(tcp_timeouts));
+}
 
-static void ip_vs_tcp_exit(struct ip_vs_protocol *pp)
+static void __ip_vs_tcp_exit(struct net *net, struct ip_vs_proto_data *pd)
 {
+	kfree(pd->timeout_table);
 }
 
 
@@ -699,8 +705,10 @@ struct ip_vs_protocol ip_vs_protocol_tcp = {
 	.num_states =		IP_VS_TCP_S_LAST,
 	.dont_defrag =		0,
 	.appcnt =		ATOMIC_INIT(0),
-	.init =			ip_vs_tcp_init,
-	.exit =			ip_vs_tcp_exit,
+	.init =			NULL,
+	.exit =			NULL,
+	.init_netns =		__ip_vs_tcp_init,
+	.exit_netns =		__ip_vs_tcp_exit,
 	.register_app =		tcp_register_app,
 	.unregister_app =	tcp_unregister_app,
 	.conn_schedule =	tcp_conn_schedule,
@@ -714,5 +722,4 @@ struct ip_vs_protocol ip_vs_protocol_tcp = {
 	.app_conn_bind =	tcp_app_conn_bind,
 	.debug_packet =		ip_vs_tcpudp_debug_packet,
 	.timeout_change =	tcp_timeout_change,
-	.set_state_timeout =	tcp_set_state_timeout,
 };
-- 
1.7.2.3

