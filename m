From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [RFC PATCH 8/9] ipvs network name space aware
Date: Fri, 8 Oct 2010 13:17:10 +0200
Message-ID: <201010081317.12241.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr

This patch contains all proto files

All timeouts are moved to ipvs struct.
Global "timeout tables" are used as default values only.

Signed-off-by:Hans Schillstrom <hans.schillstrom@ericsson.com>

diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 027f654..c17e02c 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -38,7 +38,6 @@
  * ipvs protocol table.
  */

-#define IP_VS_PROTO_TAB_SIZE		32	/* must be power of 2 */
 #define IP_VS_PROTO_HASH(proto)		((proto) & (IP_VS_PROTO_TAB_SIZE-1))

 static struct ip_vs_protocol *ip_vs_proto_table[IP_VS_PROTO_TAB_SIZE];
@@ -60,6 +59,30 @@ static int __used __init register_ip_vs_protocol(struct ip_vs_protocol *pp)
 	return 0;
 }

+/*
+ *	register an ipvs protocols netns related data
+ */
+static int
+register_ip_vs_proto_netns(struct net *net, struct ip_vs_protocol *pp )
+{
+	unsigned hash = IP_VS_PROTO_HASH(pp->protocol);
+	struct ip_vs_proto_data *pd =
+			kzalloc(sizeof(struct ip_vs_proto_data), GFP_ATOMIC);
+
+	if (!pd) {
+		pr_err("%s(): no memory.\n", __func__);
+		return -ENOMEM;
+	}
+	pd->pp=pp;	/* For speed issues */
+	pd->next = net->ipvs->proto_data_table[hash];
+	net->ipvs->proto_data_table[hash] = pd;
+	atomic_set(&pd->appcnt,0);	/* Init app counter */
+
+	if (pp->init_netns != NULL)
+		pp->init_netns(net, pd);
+
+	return 0;
+}

 /*
  *	unregister an ipvs protocol
@@ -81,6 +104,28 @@ static int unregister_ip_vs_protocol(struct ip_vs_protocol *pp)

 	return -ESRCH;
 }
+/*
+ *	unregister an ipvs protocols netns data
+ */
+static int
+unregister_ip_vs_proto_netns(struct net *net, struct ip_vs_proto_data *pd)
+{
+	struct ip_vs_proto_data **pd_p;
+	unsigned hash = IP_VS_PROTO_HASH(pd->pp->protocol);
+
+	pd_p = &net->ipvs->proto_data_table[hash];
+	for (; *pd_p; pd_p = &(*pd_p)->next) {
+		if (*pd_p == pd) {
+			*pd_p = pd->next;
+			if (pd->pp->exit_netns != NULL)
+				pd->pp->exit_netns(net, pd);
+			kfree(pd);
+			return 0;
+		}
+	}
+
+	return -ESRCH;
+}


 /*
@@ -100,6 +145,24 @@ struct ip_vs_protocol * ip_vs_proto_get(unsigned short proto)
 }
 EXPORT_SYMBOL(ip_vs_proto_get);

+/*
+ *	get ip_vs_protocol object data by netns and proto
+ */
+struct ip_vs_proto_data *
+ip_vs_proto_data_get(struct net *net, unsigned short proto)
+{
+	struct ip_vs_proto_data *pd;
+	unsigned hash = IP_VS_PROTO_HASH(proto);
+	struct netns_ipvs *ipvs = net->ipvs;
+
+	for (pd = ipvs->proto_data_table[hash]; pd; pd = pd->next) {
+		if (pd->pp->protocol == proto)
+			return pd;
+	}
+
+	return NULL;
+}
+EXPORT_SYMBOL(ip_vs_proto_data_get);

 /*
  *	Propagate event for state change to all protocols
@@ -118,8 +181,7 @@ void ip_vs_protocol_timeout_change(int flags)
 }


-int *
-ip_vs_create_timeout_table(int *table, int size)
+int *ip_vs_create_timeout_table(const int *table, int size)
 {
 	return kmemdup(table, size, GFP_ATOMIC);
 }
@@ -235,7 +297,44 @@ ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp,
 #endif
 		ip_vs_tcpudp_debug_packet_v4(pp, skb, offset, msg);
 }
+static int  __net_init  __ip_vs_protocol_init(struct net *net)
+{

+#ifdef CONFIG_IP_VS_PROTO_TCP
+	register_ip_vs_proto_netns(net, &ip_vs_protocol_tcp);
+#endif
+#ifdef CONFIG_IP_VS_PROTO_UDP
+	register_ip_vs_proto_netns(net, &ip_vs_protocol_udp);
+#endif
+#ifdef CONFIG_IP_VS_PROTO_SCTP
+	register_ip_vs_proto_netns(net, &ip_vs_protocol_sctp);
+#endif
+#ifdef CONFIG_IP_VS_PROTO_AH
+	register_ip_vs_proto_netns(net, &ip_vs_protocol_ah);
+#endif
+#ifdef CONFIG_IP_VS_PROTO_ESP
+	register_ip_vs_proto_netns(net, &ip_vs_protocol_esp);
+#endif
+	return 0;
+}
+
+static void __net_exit __ip_vs_protocol_cleanup(struct net *net)
+{
+	struct ip_vs_proto_data *pd;
+	int i;
+	struct netns_ipvs *ipvs = net->ipvs;
+
+	/* unregister all the ipvs proto data for this netns */
+	for (i = 0; i < IP_VS_PROTO_TAB_SIZE; i++) {
+		while ((pd = ipvs->proto_data_table[i]) != NULL)
+			unregister_ip_vs_proto_netns(net, pd);
+	}
+}
+
+static struct pernet_operations ipvs_proto_ops = {
+	.init = __ip_vs_protocol_init,
+	.exit = __ip_vs_protocol_cleanup,
+};

 int __init ip_vs_protocol_init(void)
 {
@@ -266,7 +365,7 @@ int __init ip_vs_protocol_init(void)
 #endif
 	pr_info("Registered protocols (%s)\n", &protocols[2]);

-	return 0;
+	return register_pernet_subsys(&ipvs_proto_ops);
 }


@@ -275,6 +374,7 @@ void ip_vs_protocol_cleanup(void)
 	struct ip_vs_protocol *pp;
 	int i;

+	unregister_pernet_subsys(&ipvs_proto_ops);
 	/* unregister all the ipvs protocols */
 	for (i = 0; i < IP_VS_PROTO_TAB_SIZE; i++) {
 		while ((pp = ip_vs_proto_table[i]) != NULL)
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index 1892dfc..1b77ef1 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -47,15 +47,17 @@ ah_esp_conn_in_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
 		   int inverse)
 {
 	struct ip_vs_conn *cp;
+	struct net *net = dev_net(skb->dev);

+	BUG_ON(!net);
 	if (likely(!inverse)) {
-		cp = ip_vs_conn_in_get(af, IPPROTO_UDP,
+		cp = ip_vs_conn_in_get(net, af, IPPROTO_UDP,
 				       &iph->saddr,
 				       htons(PORT_ISAKMP),
 				       &iph->daddr,
 				       htons(PORT_ISAKMP));
 	} else {
-		cp = ip_vs_conn_in_get(af, IPPROTO_UDP,
+		cp = ip_vs_conn_in_get(net, af, IPPROTO_UDP,
 				       &iph->daddr,
 				       htons(PORT_ISAKMP),
 				       &iph->saddr,
@@ -87,15 +89,17 @@ ah_esp_conn_out_get(int af, const struct sk_buff *skb,
 		    int inverse)
 {
 	struct ip_vs_conn *cp;
+	struct net *net = dev_net(skb->dev);

+	BUG_ON(!net);
 	if (likely(!inverse)) {
-		cp = ip_vs_conn_out_get(af, IPPROTO_UDP,
+		cp = ip_vs_conn_out_get(net, af, IPPROTO_UDP,
 					&iph->saddr,
 					htons(PORT_ISAKMP),
 					&iph->daddr,
 					htons(PORT_ISAKMP));
 	} else {
-		cp = ip_vs_conn_out_get(af, IPPROTO_UDP,
+		cp = ip_vs_conn_out_get(net, af, IPPROTO_UDP,
 					&iph->daddr,
 					htons(PORT_ISAKMP),
 					&iph->saddr,
@@ -173,27 +177,14 @@ ah_esp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
 		ah_esp_debug_packet_v4(pp, skb, offset, msg);
 }

-
-static void ah_esp_init(struct ip_vs_protocol *pp)
-{
-	/* nothing to do now */
-}
-
-
-static void ah_esp_exit(struct ip_vs_protocol *pp)
-{
-	/* nothing to do now */
-}
-
-
 #ifdef CONFIG_IP_VS_PROTO_AH
 struct ip_vs_protocol ip_vs_protocol_ah = {
 	.name =			"AH",
 	.protocol =		IPPROTO_AH,
 	.num_states =		1,
 	.dont_defrag =		1,
-	.init =			ah_esp_init,
-	.exit =			ah_esp_exit,
+	.init =			NULL,
+	.exit =			NULL,
 	.conn_schedule =	ah_esp_conn_schedule,
 	.conn_in_get =		ah_esp_conn_in_get,
 	.conn_out_get =		ah_esp_conn_out_get,
@@ -206,7 +197,6 @@ struct ip_vs_protocol ip_vs_protocol_ah = {
 	.app_conn_bind =	NULL,
 	.debug_packet =		ah_esp_debug_packet,
 	.timeout_change =	NULL,		/* ISAKMP */
-	.set_state_timeout =	NULL,
 };
 #endif

@@ -216,8 +206,8 @@ struct ip_vs_protocol ip_vs_protocol_esp = {
 	.protocol =		IPPROTO_ESP,
 	.num_states =		1,
 	.dont_defrag =		1,
-	.init =			ah_esp_init,
-	.exit =			ah_esp_exit,
+	.init =			NULL,
+	.exit =			NULL,
 	.conn_schedule =	ah_esp_conn_schedule,
 	.conn_in_get =		ah_esp_conn_in_get,
 	.conn_out_get =		ah_esp_conn_out_get,
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 4c0855c..0e7eb5d 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -16,7 +16,9 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 	sctp_chunkhdr_t _schunkh, *sch;
 	sctp_sctphdr_t *sh, _sctph;
 	struct ip_vs_iphdr iph;
-
+	struct net *net = dev_net(skb->dev);
+
+	BUG_ON(!net);
 	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);

 	sh = skb_header_pointer(skb, iph.len, sizeof(_sctph), &_sctph);
@@ -29,7 +31,7 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		return 0;

 	if ((sch->type == SCTP_CID_INIT) &&
-	    (svc = ip_vs_service_get(af, skb->mark, iph.protocol,
+	    (svc = ip_vs_service_get(net, af, skb->mark, iph.protocol,
 				     &iph.daddr, sh->dest))) {
 		if (ip_vs_todrop()) {
 			/*
@@ -224,7 +226,7 @@ static enum ipvs_sctp_event_t sctp_events[255] = {
 	IP_VS_SCTP_EVE_SHUT_COM_CLI,
 };

-static struct ipvs_sctp_nextstate
+static const struct ipvs_sctp_nextstate
  sctp_states_table[IP_VS_SCTP_S_LAST][IP_VS_SCTP_EVE_LAST] = {
 	/*
 	 * STATE : IP_VS_SCTP_S_NONE
@@ -853,7 +855,7 @@ static struct ipvs_sctp_nextstate
 /*
  *      Timeout table[state]
  */
-static int sctp_timeouts[IP_VS_SCTP_S_LAST + 1] = {
+static const int sctp_timeouts[IP_VS_SCTP_S_LAST + 1] = {
 	[IP_VS_SCTP_S_NONE]         =     2 * HZ,
 	[IP_VS_SCTP_S_INIT_CLI]     =     1 * 60 * HZ,
 	[IP_VS_SCTP_S_INIT_SER]     =     1 * 60 * HZ,
@@ -901,6 +903,7 @@ static void sctp_timeout_change(struct ip_vs_protocol *pp, int flags)
 {
 }

+/*
 static int
 sctp_set_state_timeout(struct ip_vs_protocol *pp, char *sname, int to)
 {
@@ -908,7 +911,7 @@ sctp_set_state_timeout(struct ip_vs_protocol *pp, char *sname, int to)
 return ip_vs_set_state_timeout(pp->timeout_table, IP_VS_SCTP_S_LAST,
 				sctp_state_name_table, sname, to);
 }
-
+*/
 static inline int
 set_sctp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 		int direction, const struct sk_buff *skb)
@@ -917,7 +920,10 @@ set_sctp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 	unsigned char chunk_type;
 	int event, next_state;
 	int ihl;
+	struct net *net = dev_net(skb->dev);
+	struct ip_vs_proto_data *pd;

+	BUG_ON(!net);
 #ifdef CONFIG_IP_VS_IPV6
 	ihl = cp->af == AF_INET ? ip_hdrlen(skb) : sizeof(struct ipv6hdr);
 #else
@@ -992,10 +998,13 @@ set_sctp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 			}
 		}
 	}
+	pd = ip_vs_proto_data_get(net, pp->protocol);
+	if(likely(pd))
+		cp->timeout = pd->timeout_table[cp->state = next_state];
+	else	/* What to do ? */
+		cp->timeout = sctp_timeouts[cp->state = next_state];

-	 cp->timeout = pp->timeout_table[cp->state = next_state];
-
-	 return 1;
+	return 1;
 }

 static int
@@ -1011,59 +1020,55 @@ sctp_state_transition(struct ip_vs_conn *cp, int direction,
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
 		& SCTP_APP_TAB_MASK;
 }

-static int sctp_register_app(struct ip_vs_app *inc)
+static int sctp_register_app(struct net *net, struct ip_vs_app *inc)
 {
 	struct ip_vs_app *i;
 	__u16 hash;
 	__be16 port = inc->port;
 	int ret = 0;
+	struct netns_ipvs *ipvs = net->ipvs;
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_SCTP);

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
+	atomic_inc(&pd->appcnt);
 out:
-	spin_unlock_bh(&sctp_app_lock);
+	spin_unlock_bh(&ipvs->sctp_app_lock);

 	return ret;
 }

-static void sctp_unregister_app(struct ip_vs_app *inc)
+static void sctp_unregister_app(struct net *net, struct ip_vs_app *inc)
 {
-	spin_lock_bh(&sctp_app_lock);
-	atomic_dec(&ip_vs_protocol_sctp.appcnt);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_SCTP);
+
+	BUG_ON(!pd);
+	spin_lock_bh(&net->ipvs->sctp_app_lock);
+	atomic_dec(&pd->appcnt);
 	list_del(&inc->p_list);
-	spin_unlock_bh(&sctp_app_lock);
+	spin_unlock_bh(&net->ipvs->sctp_app_lock);
 }

-static int sctp_app_conn_bind(struct ip_vs_conn *cp)
+static int sctp_app_conn_bind(struct net *net, struct ip_vs_conn *cp)
 {
 	int hash;
 	struct ip_vs_app *inc;
 	int result = 0;
+	struct netns_ipvs *ipvs = net->ipvs;

 	/* Default binding: bind app only for NAT */
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
@@ -1071,12 +1076,12 @@ static int sctp_app_conn_bind(struct ip_vs_conn *cp)
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
@@ -1092,43 +1097,50 @@ static int sctp_app_conn_bind(struct ip_vs_conn *cp)
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
+	ip_vs_init_hash_table(net->ipvs->sctp_apps, SCTP_APP_TAB_SIZE);
+	spin_lock_init(&net->ipvs->tcp_app_lock);
+	pd->timeout_table = ip_vs_create_timeout_table(sctp_timeouts,
+							sizeof(sctp_timeouts));
 }

-
-static void ip_vs_sctp_exit(struct ip_vs_protocol *pp)
+static void __ip_vs_sctp_exit(struct net *net, struct ip_vs_proto_data *pd)
 {
-
+	kfree(pd->timeout_table);
 }

+
 struct ip_vs_protocol ip_vs_protocol_sctp = {
-	.name = "SCTP",
-	.protocol = IPPROTO_SCTP,
-	.num_states = IP_VS_SCTP_S_LAST,
-	.dont_defrag = 0,
-	.appcnt = ATOMIC_INIT(0),
-	.init = ip_vs_sctp_init,
-	.exit = ip_vs_sctp_exit,
-	.register_app = sctp_register_app,
+	.name 		= "SCTP",
+	.protocol 	= IPPROTO_SCTP,
+	.num_states 	= IP_VS_SCTP_S_LAST,
+	.dont_defrag 	= 0,
+	.init 		= NULL,
+	.exit 		= NULL,
+	.init_netns 	= __ip_vs_sctp_init,
+	.exit_netns 	= __ip_vs_sctp_exit,
+	.register_app 	= sctp_register_app,
 	.unregister_app = sctp_unregister_app,
-	.conn_schedule = sctp_conn_schedule,
-	.conn_in_get = ip_vs_conn_in_get_proto,
-	.conn_out_get = ip_vs_conn_out_get_proto,
-	.snat_handler = sctp_snat_handler,
-	.dnat_handler = sctp_dnat_handler,
-	.csum_check = sctp_csum_check,
-	.state_name = sctp_state_name,
+	.conn_schedule 	= sctp_conn_schedule,
+	.conn_in_get 	= ip_vs_conn_in_get_proto,
+	.conn_out_get 	= ip_vs_conn_out_get_proto,
+	.snat_handler 	= sctp_snat_handler,
+	.dnat_handler 	= sctp_dnat_handler,
+	.csum_check 	= sctp_csum_check,
+	.state_name 	= sctp_state_name,
 	.state_transition = sctp_state_transition,
-	.app_conn_bind = sctp_app_conn_bind,
-	.debug_packet = ip_vs_tcpudp_debug_packet,
+	.app_conn_bind 	= sctp_app_conn_bind,
+	.debug_packet 	= ip_vs_tcpudp_debug_packet,
 	.timeout_change = sctp_timeout_change,
-	.set_state_timeout = sctp_set_state_timeout,
+/*	.set_state_timeout = sctp_set_state_timeout, */
 };
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 282d24d..bd40721 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -9,7 +9,12 @@
  *              as published by the Free Software Foundation; either version
  *              2 of the License, or (at your option) any later version.
  *
- * Changes:
+ * Changes:     Hans Schillstrom <hans.schillstrom@ericsson.com>
+ *
+ *              Network name space (netns) aware.
+ *              Global data moved to netns i.e struct netns_ipvs
+ *              tcp_timeouts table has copy per netns in a hash table per
+ *              protocol ip_vs_proto_data and is handled by netns
  *
  */

@@ -34,7 +39,9 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 	struct ip_vs_service *svc;
 	struct tcphdr _tcph, *th;
 	struct ip_vs_iphdr iph;
-
+	struct net *net = dev_net(skb->dev);
+
+	BUG_ON(!net);
 	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);

 	th = skb_header_pointer(skb, iph.len, sizeof(_tcph), &_tcph);
@@ -44,8 +51,8 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 	}

 	if (th->syn &&
-	    (svc = ip_vs_service_get(af, skb->mark, iph.protocol, &iph.daddr,
-				     th->dest))) {
+	    (svc = ip_vs_service_get(net, af, skb->mark, iph.protocol,
+			    	     &iph.daddr, th->dest))) {
 		if (ip_vs_todrop()) {
 			/*
 			 * It seems that we are very loaded.
@@ -316,7 +323,7 @@ static const int tcp_state_off[IP_VS_DIR_LAST] = {
 /*
  *	Timeout table[state]
  */
-static int tcp_timeouts[IP_VS_TCP_S_LAST+1] = {
+static const int tcp_timeouts[IP_VS_TCP_S_LAST+1] = {
 	[IP_VS_TCP_S_NONE]		=	2*HZ,
 	[IP_VS_TCP_S_ESTABLISHED]	=	15*60*HZ,
 	[IP_VS_TCP_S_SYN_SENT]		=	2*60*HZ,
@@ -430,13 +437,13 @@ static void tcp_timeout_change(struct ip_vs_protocol *pp, int flags)
 	*/
 	tcp_state_table = (on? tcp_states_dos : tcp_states);
 }
-
+/* Removed not used
 static int
 tcp_set_state_timeout(struct ip_vs_protocol *pp, char *sname, int to)
 {
 	return ip_vs_set_state_timeout(pp->timeout_table, IP_VS_TCP_S_LAST,
 				       tcp_state_name_table, sname, to);
-}
+} */

 static inline int tcp_state_idx(struct tcphdr *th)
 {
@@ -452,12 +459,13 @@ static inline int tcp_state_idx(struct tcphdr *th)
 }

 static inline void
-set_tcp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
+set_tcp_state(struct net *net, struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 	      int direction, struct tcphdr *th)
 {
 	int state_idx;
 	int new_state = IP_VS_TCP_S_CLOSE;
 	int state_off = tcp_state_off[direction];
+	struct ip_vs_proto_data *pd;

 	/*
 	 *    Update state offset to INPUT_ONLY if necessary
@@ -512,8 +520,12 @@ set_tcp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 			}
 		}
 	}
-
-	cp->timeout = pp->timeout_table[cp->state = new_state];
+	pd = ip_vs_proto_data_get(net, pp->protocol);
+	if(likely(pd))
+		cp->timeout = pd->timeout_table[cp->state = new_state];
+	else	/* What to do ? */
+		cp->timeout = tcp_timeouts[cp->state = new_state];
+	IP_VS_DBG(8, "%s() timeout=%lu, pd=%p def=%d\n", __func__, cp->timeout, pd->timeout_table, tcp_timeouts[new_state]);
 }


@@ -525,6 +537,7 @@ tcp_state_transition(struct ip_vs_conn *cp, int direction,
 		     const struct sk_buff *skb,
 		     struct ip_vs_protocol *pp)
 {
+	struct net *net = dev_net(skb->dev);
 	struct tcphdr _tcph, *th;

 #ifdef CONFIG_IP_VS_IPV6
@@ -538,7 +551,7 @@ tcp_state_transition(struct ip_vs_conn *cp, int direction,
 		return 0;

 	spin_lock(&cp->lock);
-	set_tcp_state(pp, cp, direction, th);
+	set_tcp_state(net, pp, cp, direction, th);
 	spin_unlock(&cp->lock);

 	return 1;
@@ -548,12 +561,6 @@ tcp_state_transition(struct ip_vs_conn *cp, int direction,
 /*
  *	Hash table for TCP application incarnations
  */
-#define	TCP_APP_TAB_BITS	4
-#define	TCP_APP_TAB_SIZE	(1 << TCP_APP_TAB_BITS)
-#define	TCP_APP_TAB_MASK	(TCP_APP_TAB_SIZE - 1)
-
-static struct list_head tcp_apps[TCP_APP_TAB_SIZE];
-static DEFINE_SPINLOCK(tcp_app_lock);

 static inline __u16 tcp_app_hashkey(__be16 port)
 {
@@ -562,47 +569,51 @@ static inline __u16 tcp_app_hashkey(__be16 port)
 }


-static int tcp_register_app(struct ip_vs_app *inc)
+static int tcp_register_app(struct net *net, struct ip_vs_app *inc)
 {
 	struct ip_vs_app *i;
 	__u16 hash;
 	__be16 port = inc->port;
 	int ret = 0;
+	struct netns_ipvs *ipvs = net->ipvs;
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_TCP);

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
+	atomic_inc(&pd->appcnt);

   out:
-	spin_unlock_bh(&tcp_app_lock);
+	spin_unlock_bh(&ipvs->tcp_app_lock);
 	return ret;
 }


-static void
-tcp_unregister_app(struct ip_vs_app *inc)
+static void tcp_unregister_app(struct net *net, struct ip_vs_app *inc)
 {
-	spin_lock_bh(&tcp_app_lock);
-	atomic_dec(&ip_vs_protocol_tcp.appcnt);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
+
+	BUG_ON(!pd);
+	spin_lock_bh(&net->ipvs->tcp_app_lock);
+	atomic_dec(&pd->appcnt);
 	list_del(&inc->p_list);
-	spin_unlock_bh(&tcp_app_lock);
+	spin_unlock_bh(&net->ipvs->tcp_app_lock);
 }


-static int
-tcp_app_conn_bind(struct ip_vs_conn *cp)
+static int tcp_app_conn_bind(struct net *net, struct ip_vs_conn *cp)
 {
 	int hash;
 	struct ip_vs_app *inc;
 	int result = 0;
+	struct netns_ipvs *ipvs = net->ipvs;

 	/* Default binding: bind app only for NAT */
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
@@ -611,12 +622,12 @@ tcp_app_conn_bind(struct ip_vs_conn *cp)
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
@@ -633,7 +644,7 @@ tcp_app_conn_bind(struct ip_vs_conn *cp)
 			goto out;
 		}
 	}
-	spin_unlock(&tcp_app_lock);
+	spin_unlock(&ipvs->tcp_app_lock);

   out:
 	return result;
@@ -643,24 +654,32 @@ tcp_app_conn_bind(struct ip_vs_conn *cp)
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
+	                   : tcp_timeouts[IP_VS_TCP_S_LISTEN] );
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
+	ip_vs_init_hash_table(net->ipvs->tcp_apps, TCP_APP_TAB_SIZE);
+	spin_lock_init(&net->ipvs->tcp_app_lock);
+	pd->timeout_table = ip_vs_create_timeout_table(tcp_timeouts,
+							sizeof(tcp_timeouts));
 }

-
-static void ip_vs_tcp_exit(struct ip_vs_protocol *pp)
+static void __ip_vs_tcp_exit(struct net *net, struct ip_vs_proto_data *pd)
 {
+	kfree(pd->timeout_table);
 }


@@ -669,9 +688,10 @@ struct ip_vs_protocol ip_vs_protocol_tcp = {
 	.protocol =		IPPROTO_TCP,
 	.num_states =		IP_VS_TCP_S_LAST,
 	.dont_defrag =		0,
-	.appcnt =		ATOMIC_INIT(0),
-	.init =			ip_vs_tcp_init,
-	.exit =			ip_vs_tcp_exit,
+	.init =			NULL,
+	.exit =			NULL,
+	.init_netns =		__ip_vs_tcp_init,
+	.exit_netns =		__ip_vs_tcp_exit,
 	.register_app =		tcp_register_app,
 	.unregister_app =	tcp_unregister_app,
 	.conn_schedule =	tcp_conn_schedule,
@@ -685,5 +705,5 @@ struct ip_vs_protocol ip_vs_protocol_tcp = {
 	.app_conn_bind =	tcp_app_conn_bind,
 	.debug_packet =		ip_vs_tcpudp_debug_packet,
 	.timeout_change =	tcp_timeout_change,
-	.set_state_timeout =	tcp_set_state_timeout,
+/*	.set_state_timeout =	tcp_set_state_timeout, */
 };
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 8553231..d067843 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -9,7 +9,10 @@
  *              as published by the Free Software Foundation; either version
  *              2 of the License, or (at your option) any later version.
  *
- * Changes:
+ * Changes:     Hans Schillstrom <hans.schillstrom@ericsson.com>
+ *
+ *              Network name space (netns) aware.
+ *              Global data moved to netns i.e struct netns_ipvs
  *
  */

@@ -34,7 +37,9 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 	struct ip_vs_service *svc;
 	struct udphdr _udph, *uh;
 	struct ip_vs_iphdr iph;
-
+	struct net *net = dev_net(skb->dev);
+
+	BUG_ON(!net);
 	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);

 	uh = skb_header_pointer(skb, iph.len, sizeof(_udph), &_udph);
@@ -43,7 +48,7 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		return 0;
 	}

-	svc = ip_vs_service_get(af, skb->mark, iph.protocol,
+	svc = ip_vs_service_get(net, af, skb->mark, iph.protocol,
 				&iph.daddr, uh->dest);
 	if (svc) {
 		if (ip_vs_todrop()) {
@@ -323,13 +328,6 @@ udp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
  *	unregister_app or app_conn_bind is called each time.
  */

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
@@ -337,47 +335,52 @@ static inline __u16 udp_app_hashkey(__be16 port)
 }


-static int udp_register_app(struct ip_vs_app *inc)
+static int udp_register_app(struct net *net, struct ip_vs_app *inc)
 {
 	struct ip_vs_app *i;
 	__u16 hash;
 	__be16 port = inc->port;
 	int ret = 0;
+	struct netns_ipvs *ipvs = net->ipvs;
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_UDP);

+	BUG_ON(!pd);
 	hash = udp_app_hashkey(port);

-
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
+	atomic_inc(&pd->appcnt);

   out:
-	spin_unlock_bh(&udp_app_lock);
+	spin_unlock_bh(&ipvs->udp_app_lock);
 	return ret;
 }


-static void
-udp_unregister_app(struct ip_vs_app *inc)
+static void udp_unregister_app(struct net *net, struct ip_vs_app *inc)
 {
-	spin_lock_bh(&udp_app_lock);
-	atomic_dec(&ip_vs_protocol_udp.appcnt);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_UDP);
+
+	BUG_ON(!pd);
+	spin_lock_bh(&net->ipvs->udp_app_lock);
+	atomic_dec(&pd->appcnt);
 	list_del(&inc->p_list);
-	spin_unlock_bh(&udp_app_lock);
+	spin_unlock_bh(&net->ipvs->udp_app_lock);
 }


-static int udp_app_conn_bind(struct ip_vs_conn *cp)
+static int udp_app_conn_bind(struct net *net, struct ip_vs_conn *cp)
 {
 	int hash;
 	struct ip_vs_app *inc;
 	int result = 0;
+	struct netns_ipvs *ipvs = net->ipvs;

 	/* Default binding: bind app only for NAT */
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
@@ -386,12 +389,12 @@ static int udp_app_conn_bind(struct ip_vs_conn *cp)
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
@@ -408,14 +411,14 @@ static int udp_app_conn_bind(struct ip_vs_conn *cp)
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
@@ -425,14 +428,20 @@ static const char *const udp_state_name_table[IP_VS_UDP_S_LAST+1] = {
 	[IP_VS_UDP_S_LAST]		=	"BUG!",
 };

-
+/*
 static int
-udp_set_state_timeout(struct ip_vs_protocol *pp, char *sname, int to)
+udp_set_state_timeout(struct net *net, struct ip_vs_protocol *pp, char *sname,
+                      int to)
 {
-	return ip_vs_set_state_timeout(pp->timeout_table, IP_VS_UDP_S_LAST,
-				       udp_state_name_table, sname, to);
+	struct ip_vs_proto_data *pd=ip_vs_proto_data_get(net, IPPROTO_UDP);
+	if (pd)
+		return ip_vs_set_state_timeout(pd->timeout_table,
+					       IP_VS_UDP_S_LAST,
+					       udp_state_name_table, sname, to);
+	else
+		return -ENOENT;
 }
-
+*/
 static const char * udp_state_name(int state)
 {
 	if (state >= IP_VS_UDP_S_LAST)
@@ -445,28 +454,40 @@ udp_state_transition(struct ip_vs_conn *cp, int direction,
 		     const struct sk_buff *skb,
 		     struct ip_vs_protocol *pp)
 {
-	cp->timeout = pp->timeout_table[IP_VS_UDP_S_NORMAL];
+	struct net *net = dev_net(skb->dev);
+	struct ip_vs_proto_data *pd=ip_vs_proto_data_get(net, IPPROTO_UDP);
+	if(unlikely(pd))
+		return 0;
+
+	cp->timeout = pd->timeout_table[IP_VS_UDP_S_NORMAL];
 	return 1;
 }
-
-static void udp_init(struct ip_vs_protocol *pp)
+/* ---------------------------------------------
+ *   timeouts is netns related now.
+ * ---------------------------------------------
+ */
+static void __udp_init(struct net *net, struct ip_vs_proto_data *pd)
 {
-	IP_VS_INIT_HASH_TABLE(udp_apps);
-	pp->timeout_table = udp_timeouts;
+	ip_vs_init_hash_table(net->ipvs->udp_apps, UDP_APP_TAB_SIZE);
+	spin_lock_init(&net->ipvs->udp_app_lock);
+	pd->timeout_table = ip_vs_create_timeout_table(udp_timeouts,
+							sizeof(udp_timeouts));
 }

-static void udp_exit(struct ip_vs_protocol *pp)
+static void __udp_exit(struct net *net, struct ip_vs_proto_data *pd)
 {
+	kfree(pd->timeout_table);
 }

-
 struct ip_vs_protocol ip_vs_protocol_udp = {
 	.name =			"UDP",
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
@@ -480,5 +501,5 @@ struct ip_vs_protocol ip_vs_protocol_udp = {
 	.app_conn_bind =	udp_app_conn_bind,
 	.debug_packet =		ip_vs_tcpudp_debug_packet,
 	.timeout_change =	NULL,
-	.set_state_timeout =	udp_set_state_timeout,
+/*	.set_state_timeout =	udp_set_state_timeout, */
 };

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
