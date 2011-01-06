From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 10/22] IPVS: netns, use ip_vs_proto_data as param.
Date: Thu,  6 Jan 2011 15:16:06 +0900
Message-ID: <1294294578-8601-11-git-send-email-horms@verge.net.au>
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

*v3
Mostly comments from Julian
The pp -> pd conversion should start from functions like
ip_vs_out() that use pp = ip_vs_proto_get(iph.protocol),
now they should use ip_vs_proto_data_get(net, iph.protocol).
conn_in_get() and conn_out_get() unused param *pp, removed.

*v4
ip_vs_protocol_timeout_change() walk the proto_data path.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h                     |   18 ++-----
 net/netfilter/ipvs/ip_vs_conn.c         |    2 -
 net/netfilter/ipvs/ip_vs_core.c         |   77 +++++++++++++++++++------------
 net/netfilter/ipvs/ip_vs_ctl.c          |   55 ++++++++++++++--------
 net/netfilter/ipvs/ip_vs_proto.c        |   21 ++++++---
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |   10 ++--
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |   16 +++----
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |   27 +++++------
 net/netfilter/ipvs/ip_vs_proto_udp.c    |   11 ++---
 net/netfilter/xt_ipvs.c                 |    2 +-
 10 files changed, 129 insertions(+), 110 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 3c45a00..464ea36 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -372,13 +372,12 @@ struct ip_vs_protocol {
 	void (*exit_netns)(struct net *net, struct ip_vs_proto_data *pd);
 
 	int (*conn_schedule)(int af, struct sk_buff *skb,
-			     struct ip_vs_protocol *pp,
+			     struct ip_vs_proto_data *pd,
 			     int *verdict, struct ip_vs_conn **cpp);
 
 	struct ip_vs_conn *
 	(*conn_in_get)(int af,
 		       const struct sk_buff *skb,
-		       struct ip_vs_protocol *pp,
 		       const struct ip_vs_iphdr *iph,
 		       unsigned int proto_off,
 		       int inverse);
@@ -386,7 +385,6 @@ struct ip_vs_protocol {
 	struct ip_vs_conn *
 	(*conn_out_get)(int af,
 			const struct sk_buff *skb,
-			struct ip_vs_protocol *pp,
 			const struct ip_vs_iphdr *iph,
 			unsigned int proto_off,
 			int inverse);
@@ -404,7 +402,7 @@ struct ip_vs_protocol {
 
 	int (*state_transition)(struct ip_vs_conn *cp, int direction,
 				const struct sk_buff *skb,
-				struct ip_vs_protocol *pp);
+				struct ip_vs_proto_data *pd);
 
 	int (*register_app)(struct ip_vs_app *inc);
 
@@ -417,9 +415,7 @@ struct ip_vs_protocol {
 			     int offset,
 			     const char *msg);
 
-	void (*timeout_change)(struct ip_vs_protocol *pp, int flags);
-
-	int (*set_state_timeout)(struct ip_vs_protocol *pp, char *sname, int to);
+	void (*timeout_change)(struct ip_vs_proto_data *pd, int flags);
 };
 
 /*
@@ -778,7 +774,6 @@ struct ip_vs_conn *ip_vs_conn_in_get(const struct ip_vs_conn_param *p);
 struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p);
 
 struct ip_vs_conn * ip_vs_conn_in_get_proto(int af, const struct sk_buff *skb,
-					    struct ip_vs_protocol *pp,
 					    const struct ip_vs_iphdr *iph,
 					    unsigned int proto_off,
 					    int inverse);
@@ -786,7 +781,6 @@ struct ip_vs_conn * ip_vs_conn_in_get_proto(int af, const struct sk_buff *skb,
 struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p);
 
 struct ip_vs_conn * ip_vs_conn_out_get_proto(int af, const struct sk_buff *skb,
-					     struct ip_vs_protocol *pp,
 					     const struct ip_vs_iphdr *iph,
 					     unsigned int proto_off,
 					     int inverse);
@@ -917,7 +911,7 @@ static inline void ip_vs_pe_put(const struct ip_vs_pe *pe)
  */
 extern int ip_vs_protocol_init(void);
 extern void ip_vs_protocol_cleanup(void);
-extern void ip_vs_protocol_timeout_change(int flags);
+extern void ip_vs_protocol_timeout_change(struct netns_ipvs *ipvs, int flags);
 extern int *ip_vs_create_timeout_table(int *table, int size);
 extern int
 ip_vs_set_state_timeout(int *table, int num, const char *const *names,
@@ -947,9 +941,9 @@ extern struct ip_vs_scheduler *ip_vs_scheduler_get(const char *sched_name);
 extern void ip_vs_scheduler_put(struct ip_vs_scheduler *scheduler);
 extern struct ip_vs_conn *
 ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
-	       struct ip_vs_protocol *pp, int *ignored);
+	       struct ip_vs_proto_data *pd, int *ignored);
 extern int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
-			struct ip_vs_protocol *pp);
+			struct ip_vs_proto_data *pd);
 
 
 /*
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 7a0e79e..a7aba6a 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -329,7 +329,6 @@ ip_vs_conn_fill_param_proto(int af, const struct sk_buff *skb,
 
 struct ip_vs_conn *
 ip_vs_conn_in_get_proto(int af, const struct sk_buff *skb,
-			struct ip_vs_protocol *pp,
 			const struct ip_vs_iphdr *iph,
 			unsigned int proto_off, int inverse)
 {
@@ -428,7 +427,6 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
 
 struct ip_vs_conn *
 ip_vs_conn_out_get_proto(int af, const struct sk_buff *skb,
-			 struct ip_vs_protocol *pp,
 			 const struct ip_vs_iphdr *iph,
 			 unsigned int proto_off, int inverse)
 {
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index d0616ea..9317aff 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -177,11 +177,11 @@ ip_vs_conn_stats(struct ip_vs_conn *cp, struct ip_vs_service *svc)
 static inline int
 ip_vs_set_state(struct ip_vs_conn *cp, int direction,
 		const struct sk_buff *skb,
-		struct ip_vs_protocol *pp)
+		struct ip_vs_proto_data *pd)
 {
-	if (unlikely(!pp->state_transition))
+	if (unlikely(!pd->pp->state_transition))
 		return 0;
-	return pp->state_transition(cp, direction, skb, pp);
+	return pd->pp->state_transition(cp, direction, skb, pd);
 }
 
 static inline int
@@ -378,8 +378,9 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
  */
 struct ip_vs_conn *
 ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
-	       struct ip_vs_protocol *pp, int *ignored)
+	       struct ip_vs_proto_data *pd, int *ignored)
 {
+	struct ip_vs_protocol *pp = pd->pp;
 	struct ip_vs_conn *cp = NULL;
 	struct ip_vs_iphdr iph;
 	struct ip_vs_dest *dest;
@@ -408,7 +409,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	 *    Do not schedule replies from local real server.
 	 */
 	if ((!skb->dev || skb->dev->flags & IFF_LOOPBACK) &&
-	    (cp = pp->conn_in_get(svc->af, skb, pp, &iph, iph.len, 1))) {
+	    (cp = pp->conn_in_get(svc->af, skb, &iph, iph.len, 1))) {
 		IP_VS_DBG_PKT(12, svc->af, pp, skb, 0,
 			      "Not scheduling reply for existing connection");
 		__ip_vs_conn_put(cp);
@@ -479,11 +480,12 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
  *  no destination is available for a new connection.
  */
 int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
-		struct ip_vs_protocol *pp)
+		struct ip_vs_proto_data *pd)
 {
 	__be16 _ports[2], *pptr;
 	struct ip_vs_iphdr iph;
 	int unicast;
+
 	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 
 	pptr = skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
@@ -530,10 +532,10 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		ip_vs_in_stats(cp, skb);
 
 		/* set state */
-		cs = ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pp);
+		cs = ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd);
 
 		/* transmit the first SYN packet */
-		ret = cp->packet_xmit(skb, cp, pp);
+		ret = cp->packet_xmit(skb, cp, pd->pp);
 		/* do not touch skb anymore */
 
 		atomic_inc(&cp->in_pkts);
@@ -840,7 +842,7 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
 
 	ip_vs_fill_iphdr(AF_INET, cih, &ciph);
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_out_get(AF_INET, skb, pp, &ciph, offset, 1);
+	cp = pp->conn_out_get(AF_INET, skb, &ciph, offset, 1);
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -917,7 +919,7 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 
 	ip_vs_fill_iphdr(AF_INET6, cih, &ciph);
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_out_get(AF_INET6, skb, pp, &ciph, offset, 1);
+	cp = pp->conn_out_get(AF_INET6, skb, &ciph, offset, 1);
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -956,9 +958,11 @@ static inline int is_tcp_reset(const struct sk_buff *skb, int nh_len)
  * Used for NAT and local client.
  */
 static unsigned int
-handle_response(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
+handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		struct ip_vs_conn *cp, int ihl)
 {
+	struct ip_vs_protocol *pp = pd->pp;
+
 	IP_VS_DBG_PKT(11, af, pp, skb, 0, "Outgoing packet");
 
 	if (!skb_make_writable(skb, ihl))
@@ -1007,7 +1011,7 @@ handle_response(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 	IP_VS_DBG_PKT(10, af, pp, skb, 0, "After SNAT");
 
 	ip_vs_out_stats(cp, skb);
-	ip_vs_set_state(cp, IP_VS_DIR_OUTPUT, skb, pp);
+	ip_vs_set_state(cp, IP_VS_DIR_OUTPUT, skb, pd);
 	skb->ipvs_property = 1;
 	if (!(cp->flags & IP_VS_CONN_F_NFCT))
 		ip_vs_notrack(skb);
@@ -1034,6 +1038,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	struct net *net = NULL;
 	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
+	struct ip_vs_proto_data *pd;
 	struct ip_vs_conn *cp;
 
 	EnterFunction(11);
@@ -1079,9 +1084,10 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 		}
 
-	pp = ip_vs_proto_get(iph.protocol);
-	if (unlikely(!pp))
+	pd = ip_vs_proto_data_get(net, iph.protocol);
+	if (unlikely(!pd))
 		return NF_ACCEPT;
+	pp = pd->pp;
 
 	/* reassemble IP fragments */
 #ifdef CONFIG_IP_VS_IPV6
@@ -1107,10 +1113,10 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	/*
 	 * Check if the packet belongs to an existing entry
 	 */
-	cp = pp->conn_out_get(af, skb, pp, &iph, iph.len, 0);
+	cp = pp->conn_out_get(af, skb, &iph, iph.len, 0);
 
 	if (likely(cp))
-		return handle_response(af, skb, pp, cp, iph.len);
+		return handle_response(af, skb, pd, cp, iph.len);
 	if (sysctl_ip_vs_nat_icmp_send &&
 	    (pp->protocol == IPPROTO_TCP ||
 	     pp->protocol == IPPROTO_UDP ||
@@ -1236,12 +1242,14 @@ ip_vs_local_reply6(unsigned int hooknum, struct sk_buff *skb,
 static int
 ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 {
+	struct net *net = NULL;
 	struct iphdr *iph;
 	struct icmphdr	_icmph, *ic;
 	struct iphdr	_ciph, *cih;	/* The ip header contained within the ICMP */
 	struct ip_vs_iphdr ciph;
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
+	struct ip_vs_proto_data *pd;
 	unsigned int offset, ihl, verdict;
 	union nf_inet_addr snet;
 
@@ -1283,9 +1291,11 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	if (cih == NULL)
 		return NF_ACCEPT; /* The packet looks wrong, ignore */
 
-	pp = ip_vs_proto_get(cih->protocol);
-	if (!pp)
+	net = skb_net(skb);
+	pd = ip_vs_proto_data_get(net, cih->protocol);
+	if (!pd)
 		return NF_ACCEPT;
+	pp = pd->pp;
 
 	/* Is the embedded protocol header present? */
 	if (unlikely(cih->frag_off & htons(IP_OFFSET) &&
@@ -1299,10 +1309,10 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 
 	ip_vs_fill_iphdr(AF_INET, cih, &ciph);
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_in_get(AF_INET, skb, pp, &ciph, offset, 1);
+	cp = pp->conn_in_get(AF_INET, skb, &ciph, offset, 1);
 	if (!cp) {
 		/* The packet could also belong to a local client */
-		cp = pp->conn_out_get(AF_INET, skb, pp, &ciph, offset, 1);
+		cp = pp->conn_out_get(AF_INET, skb, &ciph, offset, 1);
 		if (cp) {
 			snet.ip = iph->saddr;
 			return handle_response_icmp(AF_INET, skb, &snet,
@@ -1346,6 +1356,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 static int
 ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 {
+	struct net *net = NULL;
 	struct ipv6hdr *iph;
 	struct icmp6hdr	_icmph, *ic;
 	struct ipv6hdr	_ciph, *cih;	/* The ip header contained
@@ -1353,6 +1364,7 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 	struct ip_vs_iphdr ciph;
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
+	struct ip_vs_proto_data *pd;
 	unsigned int offset, verdict;
 	union nf_inet_addr snet;
 	struct rt6_info *rt;
@@ -1395,9 +1407,11 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 	if (cih == NULL)
 		return NF_ACCEPT; /* The packet looks wrong, ignore */
 
-	pp = ip_vs_proto_get(cih->nexthdr);
-	if (!pp)
+	net = skb_net(skb);
+	pd = ip_vs_proto_data_get(net, cih->nexthdr);
+	if (!pd)
 		return NF_ACCEPT;
+	pp = pd->pp;
 
 	/* Is the embedded protocol header present? */
 	/* TODO: we don't support fragmentation at the moment anyways */
@@ -1411,10 +1425,10 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 
 	ip_vs_fill_iphdr(AF_INET6, cih, &ciph);
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_in_get(AF_INET6, skb, pp, &ciph, offset, 1);
+	cp = pp->conn_in_get(AF_INET6, skb, &ciph, offset, 1);
 	if (!cp) {
 		/* The packet could also belong to a local client */
-		cp = pp->conn_out_get(AF_INET6, skb, pp, &ciph, offset, 1);
+		cp = pp->conn_out_get(AF_INET6, skb, &ciph, offset, 1);
 		if (cp) {
 			ipv6_addr_copy(&snet.in6, &iph->saddr);
 			return handle_response_icmp(AF_INET6, skb, &snet,
@@ -1457,8 +1471,10 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 static unsigned int
 ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 {
+	struct net *net = NULL;
 	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
+	struct ip_vs_proto_data *pd;
 	struct ip_vs_conn *cp;
 	int ret, restart, pkts;
 
@@ -1514,20 +1530,21 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 		}
 
+	net = skb_net(skb);
 	/* Protocol supported? */
-	pp = ip_vs_proto_get(iph.protocol);
-	if (unlikely(!pp))
+	pd = ip_vs_proto_data_get(net, iph.protocol);
+	if (unlikely(!pd))
 		return NF_ACCEPT;
-
+	pp = pd->pp;
 	/*
 	 * Check if the packet belongs to an existing connection entry
 	 */
-	cp = pp->conn_in_get(af, skb, pp, &iph, iph.len, 0);
+	cp = pp->conn_in_get(af, skb, &iph, iph.len, 0);
 
 	if (unlikely(!cp)) {
 		int v;
 
-		if (!pp->conn_schedule(af, skb, pp, &v, &cp))
+		if (!pp->conn_schedule(af, skb, pd, &v, &cp))
 			return v;
 	}
 
@@ -1555,7 +1572,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	}
 
 	ip_vs_in_stats(cp, skb);
-	restart = ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pp);
+	restart = ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd);
 	if (cp->packet_xmit)
 		ret = cp->packet_xmit(skb, cp, pp);
 		/* do not touch skb anymore */
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 3a67386..f69bff6 100644
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
@@ -241,7 +242,8 @@ static void update_defense_level(void)
 	}
 	old_secure_tcp = sysctl_ip_vs_secure_tcp;
 	if (to_change >= 0)
-		ip_vs_protocol_timeout_change(sysctl_ip_vs_secure_tcp>1);
+		ip_vs_protocol_timeout_change(ipvs,
+					     sysctl_ip_vs_secure_tcp > 1);
 	spin_unlock(&ip_vs_securetcp_lock);
 
 	local_bh_enable();
@@ -257,7 +259,10 @@ static DECLARE_DELAYED_WORK(defense_work, defense_work_handler);
 
 static void defense_work_handler(struct work_struct *work)
 {
-	update_defense_level();
+	struct net *net = &init_net;
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
+	update_defense_level(ipvs);
 	if (atomic_read(&ip_vs_dropentry))
 		ip_vs_random_dropentry();
 
@@ -1504,6 +1509,7 @@ static int
 proc_do_defense_mode(ctl_table *table, int write,
 		     void __user *buffer, size_t *lenp, loff_t *ppos)
 {
+	struct net *net = current->nsproxy->net_ns;
 	int *valp = table->data;
 	int val = *valp;
 	int rc;
@@ -1514,7 +1520,7 @@ proc_do_defense_mode(ctl_table *table, int write,
 			/* Restore the correct value */
 			*valp = val;
 		} else {
-			update_defense_level();
+			update_defense_level(net_ipvs(net));
 		}
 	}
 	return rc;
@@ -2035,8 +2041,10 @@ static const struct file_operations ip_vs_stats_fops = {
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
@@ -2044,19 +2052,22 @@ static int ip_vs_set_timeout(struct ip_vs_timeout_user *u)
 
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
+		pd = ip_vs_proto_data_get(net, IPPROTO_UDP);
+		pd->timeout_table[IP_VS_UDP_S_NORMAL]
 			= u->udp_timeout * HZ;
 	}
 #endif
@@ -2160,7 +2171,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		goto out_unlock;
 	} else if (cmd == IP_VS_SO_SET_TIMEOUT) {
 		/* Set timeout values for (tcp tcpfin udp) */
-		ret = ip_vs_set_timeout((struct ip_vs_timeout_user *)arg);
+		ret = ip_vs_set_timeout(net, (struct ip_vs_timeout_user *)arg);
 		goto out_unlock;
 	} else if (cmd == IP_VS_SO_SET_STARTDAEMON) {
 		struct ip_vs_daemon_user *dm = (struct ip_vs_daemon_user *)arg;
@@ -2372,17 +2383,19 @@ __ip_vs_get_dest_entries(struct net *net, const struct ip_vs_get_dests *get,
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
 
@@ -2523,7 +2536,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	{
 		struct ip_vs_timeout_user t;
 
-		__ip_vs_get_timeouts(&t);
+		__ip_vs_get_timeouts(net, &t);
 		if (copy_to_user(user, &t, sizeof(t)) != 0)
 			ret = -EFAULT;
 	}
@@ -3094,11 +3107,11 @@ static int ip_vs_genl_del_daemon(struct nlattr **attrs)
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
@@ -3110,7 +3123,7 @@ static int ip_vs_genl_set_config(struct nlattr **attrs)
 	if (attrs[IPVS_CMD_ATTR_TIMEOUT_UDP])
 		t.udp_timeout = nla_get_u32(attrs[IPVS_CMD_ATTR_TIMEOUT_UDP]);
 
-	return ip_vs_set_timeout(&t);
+	return ip_vs_set_timeout(net, &t);
 }
 
 static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
@@ -3131,7 +3144,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 		ret = ip_vs_flush(net);
 		goto out;
 	} else if (cmd == IPVS_CMD_SET_CONFIG) {
-		ret = ip_vs_genl_set_config(info->attrs);
+		ret = ip_vs_genl_set_config(net, info->attrs);
 		goto out;
 	} else if (cmd == IPVS_CMD_NEW_DAEMON ||
 		   cmd == IPVS_CMD_DEL_DAEMON) {
@@ -3283,7 +3296,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	{
 		struct ip_vs_timeout_user t;
 
-		__ip_vs_get_timeouts(&t);
+		__ip_vs_get_timeouts(net, &t);
 #ifdef CONFIG_IP_VS_PROTO_TCP
 		NLA_PUT_U32(msg, IPVS_CMD_ATTR_TIMEOUT_TCP, t.tcp_timeout);
 		NLA_PUT_U32(msg, IPVS_CMD_ATTR_TIMEOUT_TCP_FIN,
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 9f609d4..6ac986c 100644
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
 
@@ -165,20 +164,28 @@ ip_vs_proto_data_get(struct net *net, unsigned short proto)
 
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
-	struct ip_vs_protocol *pp;
+	struct ip_vs_proto_data *pd;
 	int i;
 
 	for (i = 0; i < IP_VS_PROTO_TAB_SIZE; i++) {
-		for (pp = ip_vs_proto_table[i]; pp; pp = pp->next) {
-			if (pp->timeout_change)
-				pp->timeout_change(pp, flags);
+		for (pd = ipvs->proto_data_table[i]; pd; pd = pd->next) {
+			if (pd->pp->timeout_change)
+				pd->pp->timeout_change(pd, flags);
 		}
 	}
 }
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index b8b37fa..28039cb 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -55,7 +55,7 @@ ah_esp_conn_fill_param_proto(int af, const struct ip_vs_iphdr *iph,
 }
 
 static struct ip_vs_conn *
-ah_esp_conn_in_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
+ah_esp_conn_in_get(int af, const struct sk_buff *skb,
 		   const struct ip_vs_iphdr *iph, unsigned int proto_off,
 		   int inverse)
 {
@@ -72,7 +72,7 @@ ah_esp_conn_in_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
 		IP_VS_DBG_BUF(12, "Unknown ISAKMP entry for outin packet "
 			      "%s%s %s->%s\n",
 			      inverse ? "ICMP+" : "",
-			      pp->name,
+			      ip_vs_proto_get(iph->protocol)->name,
 			      IP_VS_DBG_ADDR(af, &iph->saddr),
 			      IP_VS_DBG_ADDR(af, &iph->daddr));
 	}
@@ -83,7 +83,6 @@ ah_esp_conn_in_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 static struct ip_vs_conn *
 ah_esp_conn_out_get(int af, const struct sk_buff *skb,
-		    struct ip_vs_protocol *pp,
 		    const struct ip_vs_iphdr *iph,
 		    unsigned int proto_off,
 		    int inverse)
@@ -97,7 +96,7 @@ ah_esp_conn_out_get(int af, const struct sk_buff *skb,
 		IP_VS_DBG_BUF(12, "Unknown ISAKMP entry for inout packet "
 			      "%s%s %s->%s\n",
 			      inverse ? "ICMP+" : "",
-			      pp->name,
+			      ip_vs_proto_get(iph->protocol)->name,
 			      IP_VS_DBG_ADDR(af, &iph->saddr),
 			      IP_VS_DBG_ADDR(af, &iph->daddr));
 	}
@@ -107,7 +106,7 @@ ah_esp_conn_out_get(int af, const struct sk_buff *skb,
 
 
 static int
-ah_esp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
+ah_esp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		     int *verdict, struct ip_vs_conn **cpp)
 {
 	/*
@@ -137,7 +136,6 @@ struct ip_vs_protocol ip_vs_protocol_ah = {
 	.app_conn_bind =	NULL,
 	.debug_packet =		ip_vs_tcpudp_debug_packet,
 	.timeout_change =	NULL,		/* ISAKMP */
-	.set_state_timeout =	NULL,
 };
 #endif
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index f826dd1..19bc379 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -9,7 +9,7 @@
 #include <net/ip_vs.h>
 
 static int
-sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
+sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		   int *verdict, struct ip_vs_conn **cpp)
 {
 	struct net *net;
@@ -47,10 +47,10 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		 * Let the virtual server select a real server for the
 		 * incoming connection, and create a connection entry.
 		 */
-		*cpp = ip_vs_schedule(svc, skb, pp, &ignored);
+		*cpp = ip_vs_schedule(svc, skb, pd, &ignored);
 		if (!*cpp && ignored <= 0) {
 			if (!ignored)
-				*verdict = ip_vs_leave(svc, skb, pp);
+				*verdict = ip_vs_leave(svc, skb, pd);
 			else {
 				ip_vs_service_put(svc);
 				*verdict = NF_DROP;
@@ -907,14 +907,13 @@ static const char *sctp_state_name(int state)
 }
 
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
@@ -966,7 +965,7 @@ set_sctp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 
 		IP_VS_DBG_BUF(8, "%s %s  %s:%d->"
 				"%s:%d state: %s->%s conn->refcnt:%d\n",
-				pp->name,
+				pd->pp->name,
 				((direction == IP_VS_DIR_OUTPUT) ?
 				 "output " : "input "),
 				IP_VS_DBG_ADDR(cp->af, &cp->daddr),
@@ -990,7 +989,6 @@ set_sctp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 			}
 		}
 	}
-	pd = ip_vs_proto_data_get(&init_net, pp->protocol); /* tmp fix */
 	if (likely(pd))
 		cp->timeout = pd->timeout_table[cp->state = next_state];
 	else	/* What to do ? */
@@ -1001,12 +999,12 @@ set_sctp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 
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
index 9d9df3d..d7c2455 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -32,7 +32,7 @@
 #include <net/ip_vs.h>
 
 static int
-tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
+tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		  int *verdict, struct ip_vs_conn **cpp)
 {
 	struct net *net;
@@ -68,10 +68,10 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		 * Let the virtual server select a real server for the
 		 * incoming connection, and create a connection entry.
 		 */
-		*cpp = ip_vs_schedule(svc, skb, pp, &ignored);
+		*cpp = ip_vs_schedule(svc, skb, pd, &ignored);
 		if (!*cpp && ignored <= 0) {
 			if (!ignored)
-				*verdict = ip_vs_leave(svc, skb, pp);
+				*verdict = ip_vs_leave(svc, skb, pd);
 			else {
 				ip_vs_service_put(svc);
 				*verdict = NF_DROP;
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
+	pd->tcp_state_table = (on ? tcp_states_dos : tcp_states);
 }
 
 static inline int tcp_state_idx(struct tcphdr *th)
@@ -478,13 +475,12 @@ static inline int tcp_state_idx(struct tcphdr *th)
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
@@ -502,7 +498,8 @@ set_tcp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 		goto tcp_state_out;
 	}
 
-	new_state = tcp_state_table[state_off+state_idx].next_state[cp->state];
+	new_state =
+		pd->tcp_state_table[state_off+state_idx].next_state[cp->state];
 
   tcp_state_out:
 	if (new_state != cp->state) {
@@ -510,7 +507,7 @@ set_tcp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 
 		IP_VS_DBG_BUF(8, "%s %s [%c%c%c%c] %s:%d->"
 			      "%s:%d state: %s->%s conn->refcnt:%d\n",
-			      pp->name,
+			      pd->pp->name,
 			      ((state_off == TCP_DIR_OUTPUT) ?
 			       "output " : "input "),
 			      th->syn ? 'S' : '.',
@@ -540,7 +537,6 @@ set_tcp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 		}
 	}
 
-	pd = ip_vs_proto_data_get(&init_net, pp->protocol);
 	if (likely(pd))
 		cp->timeout = pd->timeout_table[cp->state = new_state];
 	else	/* What to do ? */
@@ -553,7 +549,7 @@ set_tcp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
 static int
 tcp_state_transition(struct ip_vs_conn *cp, int direction,
 		     const struct sk_buff *skb,
-		     struct ip_vs_protocol *pp)
+		     struct ip_vs_proto_data *pd)
 {
 	struct tcphdr _tcph, *th;
 
@@ -568,7 +564,7 @@ tcp_state_transition(struct ip_vs_conn *cp, int direction,
 		return 0;
 
 	spin_lock(&cp->lock);
-	set_tcp_state(pp, cp, direction, th);
+	set_tcp_state(pd, cp, direction, th);
 	spin_unlock(&cp->lock);
 
 	return 1;
@@ -691,6 +687,7 @@ static void __ip_vs_tcp_init(struct net *net, struct ip_vs_proto_data *pd)
 	spin_lock_init(&ipvs->tcp_app_lock);
 	pd->timeout_table = ip_vs_create_timeout_table((int *)tcp_timeouts,
 							sizeof(tcp_timeouts));
+	pd->tcp_state_table =  tcp_states;
 }
 
 static void __ip_vs_tcp_exit(struct net *net, struct ip_vs_proto_data *pd)
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 71a4721..aa85df2 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -29,7 +29,7 @@
 #include <net/ip6_checksum.h>
 
 static int
-udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
+udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		  int *verdict, struct ip_vs_conn **cpp)
 {
 	struct net *net;
@@ -64,10 +64,10 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		 * Let the virtual server select a real server for the
 		 * incoming connection, and create a connection entry.
 		 */
-		*cpp = ip_vs_schedule(svc, skb, pp, &ignored);
+		*cpp = ip_vs_schedule(svc, skb, pd, &ignored);
 		if (!*cpp && ignored <= 0) {
 			if (!ignored)
-				*verdict = ip_vs_leave(svc, skb, pp);
+				*verdict = ip_vs_leave(svc, skb, pd);
 			else {
 				ip_vs_service_put(svc);
 				*verdict = NF_DROP;
@@ -457,11 +457,8 @@ static const char * udp_state_name(int state)
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
diff --git a/net/netfilter/xt_ipvs.c b/net/netfilter/xt_ipvs.c
index 9127a3d..bb10b07 100644
--- a/net/netfilter/xt_ipvs.c
+++ b/net/netfilter/xt_ipvs.c
@@ -85,7 +85,7 @@ ipvs_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	/*
 	 * Check if the packet belongs to an existing entry
 	 */
-	cp = pp->conn_out_get(family, skb, pp, &iph, iph.len, 1 /* inverse */);
+	cp = pp->conn_out_get(family, skb, &iph, iph.len, 1 /* inverse */);
 	if (unlikely(cp == NULL)) {
 		match = false;
 		goto out;
-- 
1.7.2.3

