From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [*v2 PATCH 10/22] IPVS: netns, use ip_vs_proto_data as param.
Date: Mon, 13 Dec 2010 14:38:18 +0100
Message-ID: <1292247510-753-11-git-send-email-hans.schillstrom@ericsson.com>
References: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

ip_vs_protocol *pp is replaced by ip_vs_proto_data *pd in
function call in ip_vs_protocol struct i.e. :,
 - timeout_change()
 - state_transition()

ip_vs_protocol_timeout_change() got ipvs as param, due to above
and a upcoming patch - defence work

Most of this changes are triggered by Julians comment:
"tcp_timeout_change should work with the new struct ip_vs_proto_data
        so that tcp_state_table will go to pd->state_table
        and set_tcp_state will get pd instead of pp"

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/ip_vs.h                   |    6 ++--
 net/netfilter/ipvs/ip_vs_core.c       |    4 ++-
 net/netfilter/ipvs/ip_vs_ctl.c        |   54 ++++++++++++++++++++-------------
 net/netfilter/ipvs/ip_vs_proto.c      |   17 ++++++++--
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   10 ++----
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |   20 +++++-------
 net/netfilter/ipvs/ip_vs_proto_udp.c  |    5 +--
 7 files changed, 65 insertions(+), 51 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 3765add..045cbe0 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -406,7 +406,7 @@ struct ip_vs_protocol {
 
 	int (*state_transition)(struct ip_vs_conn *cp, int direction,
 				const struct sk_buff *skb,
-				struct ip_vs_protocol *pp);
+				struct ip_vs_proto_data *pd);
 
 	int (*register_app)(struct ip_vs_app *inc);
 
@@ -419,7 +419,7 @@ struct ip_vs_protocol {
 			     int offset,
 			     const char *msg);
 
-	void (*timeout_change)(struct ip_vs_protocol *pp, int flags);
+	void (*timeout_change)(struct ip_vs_proto_data *pd, int flags);
 
 	int (*set_state_timeout)(struct ip_vs_protocol *pp, char *sname, int to);
 };
@@ -919,7 +919,7 @@ static inline void ip_vs_pe_put(const struct ip_vs_pe *pe)
  */
 extern int ip_vs_protocol_init(void);
 extern void ip_vs_protocol_cleanup(void);
-extern void ip_vs_protocol_timeout_change(int flags);
+extern void ip_vs_protocol_timeout_change(struct netns_ipvs *ipvs, int flags);
 extern int *ip_vs_create_timeout_table(int *table, int size);
 extern int
 ip_vs_set_state_timeout(int *table, int num, const char *const *names,
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 90d307c..c9289b5 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -181,7 +181,9 @@ ip_vs_set_state(struct ip_vs_conn *cp, int direction,
 {
 	if (unlikely(!pp->state_transition))
 		return 0;
-	return pp->state_transition(cp, direction, skb, pp);
+	return pp->state_transition(cp, direction, skb,
+				    ip_vs_proto_data_get(skb_net(skb),
+							 pp->protocol));
 }
 
 static inline int
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 37cb8d1..2c9cd5c 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -38,6 +38,7 @@
 #include <linux/mutex.h>
 
 #include <net/net_namespace.h>
+#include <linux/nsproxy.h>
 #include <net/ip.h>
 #ifdef CONFIG_IP_VS_IPV6
 #include <net/ipv6.h>
@@ -127,7 +128,7 @@ static int __ip_vs_addr_is_local_v6(const struct in6_addr *addr)
  *	update_defense_level is called from keventd and from sysctl,
  *	so it needs to protect itself from softirqs
  */
-static void update_defense_level(void)
+static void update_defense_level(struct netns_ipvs *ipvs)
 {
 	struct sysinfo i;
 	static int old_secure_tcp = 0;
@@ -241,7 +242,7 @@ static void update_defense_level(void)
 	}
 	old_secure_tcp = sysctl_ip_vs_secure_tcp;
 	if (to_change >= 0)
-		ip_vs_protocol_timeout_change(sysctl_ip_vs_secure_tcp>1);
+		ip_vs_protocol_timeout_change(ipvs, sysctl_ip_vs_secure_tcp>1);
 	spin_unlock(&ip_vs_securetcp_lock);
 
 	local_bh_enable();
@@ -257,7 +258,10 @@ static DECLARE_DELAYED_WORK(defense_work, defense_work_handler);
 
 static void defense_work_handler(struct work_struct *work)
 {
-	update_defense_level();
+	struct net *net = &init_net;
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
+	update_defense_level(ipvs);
 	if (atomic_read(&ip_vs_dropentry))
 		ip_vs_random_dropentry();
 
@@ -1502,6 +1506,7 @@ static int
 proc_do_defense_mode(ctl_table *table, int write,
 		     void __user *buffer, size_t *lenp, loff_t *ppos)
 {
+	struct net *net = current->nsproxy->net_ns;
 	int *valp = table->data;
 	int val = *valp;
 	int rc;
@@ -1512,7 +1517,7 @@ proc_do_defense_mode(ctl_table *table, int write,
 			/* Restore the correct value */
 			*valp = val;
 		} else {
-			update_defense_level();
+			update_defense_level(net_ipvs(net));
 		}
 	}
 	return rc;
@@ -2033,8 +2038,10 @@ static const struct file_operations ip_vs_stats_fops = {
 /*
  *	Set timeout values for tcp tcpfin udp in the timeout_table.
  */
-static int ip_vs_set_timeout(struct ip_vs_timeout_user *u)
+static int ip_vs_set_timeout(struct net *net, struct ip_vs_timeout_user *u)
 {
+	struct ip_vs_proto_data *pd;
+
 	IP_VS_DBG(2, "Setting timeout tcp:%d tcpfin:%d udp:%d\n",
 		  u->tcp_timeout,
 		  u->tcp_fin_timeout,
@@ -2042,19 +2049,22 @@ static int ip_vs_set_timeout(struct ip_vs_timeout_user *u)
 
 #ifdef CONFIG_IP_VS_PROTO_TCP
 	if (u->tcp_timeout) {
-		ip_vs_protocol_tcp.timeout_table[IP_VS_TCP_S_ESTABLISHED]
+		pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
+		pd->timeout_table[IP_VS_TCP_S_ESTABLISHED]
 			= u->tcp_timeout * HZ;
 	}
 
 	if (u->tcp_fin_timeout) {
-		ip_vs_protocol_tcp.timeout_table[IP_VS_TCP_S_FIN_WAIT]
+		pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
+		pd->timeout_table[IP_VS_TCP_S_FIN_WAIT]
 			= u->tcp_fin_timeout * HZ;
 	}
 #endif
 
 #ifdef CONFIG_IP_VS_PROTO_UDP
 	if (u->udp_timeout) {
-		ip_vs_protocol_udp.timeout_table[IP_VS_UDP_S_NORMAL]
+		pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
+		pd->timeout_table[IP_VS_UDP_S_NORMAL]
 			= u->udp_timeout * HZ;
 	}
 #endif
@@ -2158,7 +2168,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		goto out_unlock;
 	} else if (cmd == IP_VS_SO_SET_TIMEOUT) {
 		/* Set timeout values for (tcp tcpfin udp) */
-		ret = ip_vs_set_timeout((struct ip_vs_timeout_user *)arg);
+		ret = ip_vs_set_timeout(net, (struct ip_vs_timeout_user *)arg);
 		goto out_unlock;
 	} else if (cmd == IP_VS_SO_SET_STARTDAEMON) {
 		struct ip_vs_daemon_user *dm = (struct ip_vs_daemon_user *)arg;
@@ -2369,17 +2379,19 @@ __ip_vs_get_dest_entries(struct net *net, const struct ip_vs_get_dests *get,
 }
 
 static inline void
-__ip_vs_get_timeouts(struct ip_vs_timeout_user *u)
+__ip_vs_get_timeouts(struct net *net, struct ip_vs_timeout_user *u)
 {
+	struct ip_vs_proto_data *pd;
+
 #ifdef CONFIG_IP_VS_PROTO_TCP
-	u->tcp_timeout =
-		ip_vs_protocol_tcp.timeout_table[IP_VS_TCP_S_ESTABLISHED] / HZ;
-	u->tcp_fin_timeout =
-		ip_vs_protocol_tcp.timeout_table[IP_VS_TCP_S_FIN_WAIT] / HZ;
+	pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
+	u->tcp_timeout = pd->timeout_table[IP_VS_TCP_S_ESTABLISHED] / HZ;
+	u->tcp_fin_timeout = pd->timeout_table[IP_VS_TCP_S_FIN_WAIT] / HZ;
 #endif
 #ifdef CONFIG_IP_VS_PROTO_UDP
+	pd = ip_vs_proto_data_get(net, IPPROTO_UDP);
 	u->udp_timeout =
-		ip_vs_protocol_udp.timeout_table[IP_VS_UDP_S_NORMAL] / HZ;
+			pd->timeout_table[IP_VS_UDP_S_NORMAL] / HZ;
 #endif
 }
 
@@ -2519,7 +2531,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	{
 		struct ip_vs_timeout_user t;
 
-		__ip_vs_get_timeouts(&t);
+		__ip_vs_get_timeouts(net, &t);
 		if (copy_to_user(user, &t, sizeof(t)) != 0)
 			ret = -EFAULT;
 	}
@@ -3090,11 +3102,11 @@ static int ip_vs_genl_del_daemon(struct nlattr **attrs)
 	return stop_sync_thread(nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]));
 }
 
-static int ip_vs_genl_set_config(struct nlattr **attrs)
+static int ip_vs_genl_set_config(struct net *net, struct nlattr **attrs)
 {
 	struct ip_vs_timeout_user t;
 
-	__ip_vs_get_timeouts(&t);
+	__ip_vs_get_timeouts(net, &t);
 
 	if (attrs[IPVS_CMD_ATTR_TIMEOUT_TCP])
 		t.tcp_timeout = nla_get_u32(attrs[IPVS_CMD_ATTR_TIMEOUT_TCP]);
@@ -3106,7 +3118,7 @@ static int ip_vs_genl_set_config(struct nlattr **attrs)
 	if (attrs[IPVS_CMD_ATTR_TIMEOUT_UDP])
 		t.udp_timeout = nla_get_u32(attrs[IPVS_CMD_ATTR_TIMEOUT_UDP]);
 
-	return ip_vs_set_timeout(&t);
+	return ip_vs_set_timeout(net, &t);
 }
 
 static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
@@ -3127,7 +3139,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 		ret = ip_vs_flush(net);
 		goto out;
 	} else if (cmd == IPVS_CMD_SET_CONFIG) {
-		ret = ip_vs_genl_set_config(info->attrs);
+		ret = ip_vs_genl_set_config(net, info->attrs);
 		goto out;
 	} else if (cmd == IPVS_CMD_NEW_DAEMON ||
 		   cmd == IPVS_CMD_DEL_DAEMON) {
@@ -3279,7 +3291,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	{
 		struct ip_vs_timeout_user t;
 
-		__ip_vs_get_timeouts(&t);
+		__ip_vs_get_timeouts(net, &t);
 #ifdef CONFIG_IP_VS_PROTO_TCP
 		NLA_PUT_U32(msg, IPVS_CMD_ATTR_TIMEOUT_TCP, t.tcp_timeout);
 		NLA_PUT_U32(msg, IPVS_CMD_ATTR_TIMEOUT_TCP_FIN,
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 1089248..803c6ec 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -152,9 +152,8 @@ EXPORT_SYMBOL(ip_vs_proto_get);
  *	get ip_vs_protocol object data by netns and proto
  */
 struct ip_vs_proto_data *
-ip_vs_proto_data_get(struct net *net, unsigned short proto)
+__ipvs_proto_data_get(struct netns_ipvs *ipvs, unsigned short proto)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_proto_data *pd;
 	unsigned hash = IP_VS_PROTO_HASH(proto);
 
@@ -165,12 +164,20 @@ ip_vs_proto_data_get(struct net *net, unsigned short proto)
 
 	return NULL;
 }
+
+struct ip_vs_proto_data *
+ip_vs_proto_data_get(struct net *net, unsigned short proto)
+{
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
+	return __ipvs_proto_data_get(ipvs, proto);
+}
 EXPORT_SYMBOL(ip_vs_proto_data_get);
 
 /*
  *	Propagate event for state change to all protocols
  */
-void ip_vs_protocol_timeout_change(int flags)
+void ip_vs_protocol_timeout_change(struct netns_ipvs *ipvs, int flags)
 {
 	struct ip_vs_protocol *pp;
 	int i;
@@ -178,7 +185,9 @@ void ip_vs_protocol_timeout_change(int flags)
 	for (i = 0; i < IP_VS_PROTO_TAB_SIZE; i++) {
 		for (pp = ip_vs_proto_table[i]; pp; pp = pp->next) {
 			if (pp->timeout_change)
-				pp->timeout_change(pp, flags);
+				pp->timeout_change(__ipvs_proto_data_get(ipvs,
+									 pp->protocol),
+						   flags);
 		}
 	}
 }
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 108ae0c..88715bd 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -916,14 +916,13 @@ return ip_vs_set_state_timeout(pp->timeout_table, IP_VS_SCTP_S_LAST,
 } */
 
 static inline int
-set_sctp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
+set_sctp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 		int direction, const struct sk_buff *skb)
 {
 	sctp_chunkhdr_t _sctpch, *sch;
 	unsigned char chunk_type;
 	int event, next_state;
 	int ihl;
-	struct ip_vs_proto_data *pd;
 
 #ifdef CONFIG_IP_VS_IPV6
 	ihl = cp->af == AF_INET ? ip_hdrlen(skb) : sizeof(struct ipv6hdr);
@@ -975,7 +974,7 @@ set_sctp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 
 		IP_VS_DBG_BUF(8, "%s %s  %s:%d->"
 				"%s:%d state: %s->%s conn->refcnt:%d\n",
-				pp->name,
+				pd->pp->name,
 				((direction == IP_VS_DIR_OUTPUT) ?
 				 "output " : "input "),
 				IP_VS_DBG_ADDR(cp->af, &cp->daddr),
@@ -999,7 +998,6 @@ set_sctp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 			}
 		}
 	}
-	pd = ip_vs_proto_data_get(&init_net, pp->protocol); /* tmp fix */
 	if (likely(pd))
 		cp->timeout = pd->timeout_table[cp->state = next_state];
 	else	/* What to do ? */
@@ -1010,12 +1008,12 @@ set_sctp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 
 static int
 sctp_state_transition(struct ip_vs_conn *cp, int direction,
-		const struct sk_buff *skb, struct ip_vs_protocol *pp)
+		const struct sk_buff *skb, struct ip_vs_proto_data *pd)
 {
 	int ret = 0;
 
 	spin_lock(&cp->lock);
-	ret = set_sctp_state(pp, cp, direction, skb);
+	ret = set_sctp_state(pd, cp, direction, skb);
 	spin_unlock(&cp->lock);
 
 	return ret;
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 8986b25..eec7563 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -448,10 +448,7 @@ static struct tcp_states_t tcp_states_dos [] = {
 /*rst*/ {{sCL, sCL, sCL, sSR, sCL, sCL, sCL, sCL, sLA, sLI, sCL }},
 };
 
-static struct tcp_states_t *tcp_state_table = tcp_states;
-
-
-static void tcp_timeout_change(struct ip_vs_protocol *pp, int flags)
+static void tcp_timeout_change(struct ip_vs_proto_data *pd, int flags)
 {
 	int on = (flags & 1);		/* secure_tcp */
 
@@ -461,7 +458,7 @@ static void tcp_timeout_change(struct ip_vs_protocol *pp, int flags)
 	** for most if not for all of the applications. Something
 	** like "capabilities" (flags) for each object.
 	*/
-	tcp_state_table = (on? tcp_states_dos : tcp_states);
+	pd->tcp_state_table = (on? tcp_states_dos : tcp_states);
 }
 /* Remove dot used
 static int
@@ -485,13 +482,12 @@ static inline int tcp_state_idx(struct tcphdr *th)
 }
 
 static inline void
-set_tcp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
+set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 	      int direction, struct tcphdr *th)
 {
 	int state_idx;
 	int new_state = IP_VS_TCP_S_CLOSE;
 	int state_off = tcp_state_off[direction];
-	struct ip_vs_proto_data *pd;  /* Temp fix */
 
 	/*
 	 *    Update state offset to INPUT_ONLY if necessary
@@ -509,7 +505,7 @@ set_tcp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 		goto tcp_state_out;
 	}
 
-	new_state = tcp_state_table[state_off+state_idx].next_state[cp->state];
+	new_state = pd->tcp_state_table[state_off+state_idx].next_state[cp->state];
 
   tcp_state_out:
 	if (new_state != cp->state) {
@@ -517,7 +513,7 @@ set_tcp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 
 		IP_VS_DBG_BUF(8, "%s %s [%c%c%c%c] %s:%d->"
 			      "%s:%d state: %s->%s conn->refcnt:%d\n",
-			      pp->name,
+			      pd->pp->name,
 			      ((state_off == TCP_DIR_OUTPUT) ?
 			       "output " : "input "),
 			      th->syn ? 'S' : '.',
@@ -547,7 +543,6 @@ set_tcp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 		}
 	}
 
-	pd = ip_vs_proto_data_get(&init_net, pp->protocol);
 	if (likely(pd))
 		cp->timeout = pd->timeout_table[cp->state = new_state];
 	else	/* What to do ? */
@@ -560,7 +555,7 @@ set_tcp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 static int
 tcp_state_transition(struct ip_vs_conn *cp, int direction,
 		     const struct sk_buff *skb,
-		     struct ip_vs_protocol *pp)
+		     struct ip_vs_proto_data *pd)
 {
 	struct tcphdr _tcph, *th;
 
@@ -575,7 +570,7 @@ tcp_state_transition(struct ip_vs_conn *cp, int direction,
 		return 0;
 
 	spin_lock(&cp->lock);
-	set_tcp_state(pp, cp, direction, th);
+	set_tcp_state(pd, cp, direction, th);
 	spin_unlock(&cp->lock);
 
 	return 1;
@@ -698,6 +693,7 @@ static void __ip_vs_tcp_init(struct net *net, struct ip_vs_proto_data *pd)
 	spin_lock_init(&ipvs->tcp_app_lock);
 	pd->timeout_table = ip_vs_create_timeout_table((int*)tcp_timeouts,
 							sizeof(tcp_timeouts));
+	pd->tcp_state_table =  tcp_states;
 }
 
 static void __ip_vs_tcp_exit(struct net *net, struct ip_vs_proto_data *pd)
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index f30cb8c..585d140 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -470,11 +470,8 @@ static const char * udp_state_name(int state)
 static int
 udp_state_transition(struct ip_vs_conn *cp, int direction,
 		     const struct sk_buff *skb,
-		     struct ip_vs_protocol *pp)
+		     struct ip_vs_proto_data *pd)
 {
-	struct ip_vs_proto_data *pd;   /* Temp fix, pp will be replaced by pd */
-
-	pd = ip_vs_proto_data_get(&init_net, IPPROTO_UDP);
 	if (unlikely(!pd)) {
 		pr_err("UDP no ns data\n");
 		return 0;
-- 
1.7.2.3

