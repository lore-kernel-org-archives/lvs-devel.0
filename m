From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 6/9] ipvs: reduce sync rate with time thresholds
Date: Wed, 21 Mar 2012 17:56:21 +0900
Message-ID: <1332320185-27157-7-git-send-email-horms@verge.net.au>
References: <1332320185-27157-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1332320185-27157-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

	Add two new sysctl vars to control the sync rate with the
main idea to reduce the rate for connection templates because
currently it depends on the packet rate for controlled connections.
This mechanism should be useful also for normal connections
with high traffic.

sync_refresh_period: in seconds, difference in reported connection
	timer that triggers new sync message. It can be used to
	avoid sync messages for the specified period (or half of
	the connection timeout if it is lower) if connection state
	is not changed from last sync.

sync_retries: integer, 0..3, defines sync retries with period of
	sync_refresh_period/8. Useful to protect against loss of
	sync messages.

	Allow sysctl_sync_threshold to be used with
sysctl_sync_period=0, so that only single sync message is sent
if sync_refresh_period is also 0.

	Add new field "sync_endtime" in connection structure to
hold the reported time when connection expires. The 2 lowest
bits will represent the retry count.

	As the sysctl_sync_period now can be 0 use ACCESS_ONCE to
avoid division by zero.

Special thanks to Aleksey Chudov for being patient with me,
for his extensive reports and helping in all tests.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Tested-by: Aleksey Chudov <aleksey.chudov@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |   36 ++++++++++--
 net/netfilter/ipvs/ip_vs_conn.c |    7 ++-
 net/netfilter/ipvs/ip_vs_core.c |   30 +---------
 net/netfilter/ipvs/ip_vs_ctl.c  |   25 ++++++++-
 net/netfilter/ipvs/ip_vs_sync.c |  121 +++++++++++++++++++++++++++++++++-----
 5 files changed, 168 insertions(+), 51 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index ebe517f..8bee5d0 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -504,6 +504,7 @@ struct ip_vs_conn {
 						 * state transition triggerd
 						 * synchronization
 						 */
+	unsigned long		sync_endtime;	/* jiffies + sent_retries */
 
 	/* Control members */
 	struct ip_vs_conn       *control;       /* Master control connection */
@@ -873,6 +874,8 @@ struct netns_ipvs {
 	int			sysctl_expire_nodest_conn;
 	int			sysctl_expire_quiescent_template;
 	int			sysctl_sync_threshold[2];
+	unsigned int		sysctl_sync_refresh_period;
+	int			sysctl_sync_retries;
 	int			sysctl_nat_icmp_send;
 
 	/* ip_vs_lblc */
@@ -908,9 +911,12 @@ struct netns_ipvs {
 	struct net		*net;            /* Needed by timer routines */
 };
 
-#define DEFAULT_SYNC_THRESHOLD	3
-#define DEFAULT_SYNC_PERIOD	50
-#define DEFAULT_SYNC_VER	1
+#define DEFAULT_SYNC_THRESHOLD		3
+#define DEFAULT_SYNC_PERIOD		50
+#define DEFAULT_SYNC_REFRESH_PERIOD	(0U * HZ)
+#define DEFAULT_SYNC_RETRIES		0
+#define DEFAULT_SYNC_VER		1
+#define IPVS_SYNC_FLUSH_TIME		(HZ * 2)
 
 #ifdef CONFIG_SYSCTL
 
@@ -921,7 +927,17 @@ static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
 
 static inline int sysctl_sync_period(struct netns_ipvs *ipvs)
 {
-	return ipvs->sysctl_sync_threshold[1];
+	return ACCESS_ONCE(ipvs->sysctl_sync_threshold[1]);
+}
+
+static inline unsigned int sysctl_sync_refresh_period(struct netns_ipvs *ipvs)
+{
+	return ACCESS_ONCE(ipvs->sysctl_sync_refresh_period);
+}
+
+static inline int sysctl_sync_retries(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_sync_retries;
 }
 
 static inline int sysctl_sync_ver(struct netns_ipvs *ipvs)
@@ -941,6 +957,16 @@ static inline int sysctl_sync_period(struct netns_ipvs *ipvs)
 	return DEFAULT_SYNC_PERIOD;
 }
 
+static inline unsigned int sysctl_sync_refresh_period(struct netns_ipvs *ipvs)
+{
+	return DEFAULT_SYNC_REFRESH_PERIOD;
+}
+
+static inline int sysctl_sync_retries(struct netns_ipvs *ipvs)
+{
+	return DEFAULT_SYNC_RETRIES & 3;
+}
+
 static inline int sysctl_sync_ver(struct netns_ipvs *ipvs)
 {
 	return DEFAULT_SYNC_VER;
@@ -1218,7 +1244,7 @@ extern struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp);
 extern int start_sync_thread(struct net *net, int state, char *mcast_ifn,
 			     __u8 syncid);
 extern int stop_sync_thread(struct net *net, int state);
-extern void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp);
+extern void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp, int pkts);
 
 
 /*
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index a7c6bc8..126971c 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -761,7 +761,8 @@ int ip_vs_check_template(struct ip_vs_conn *ct)
 static void ip_vs_conn_expire(unsigned long data)
 {
 	struct ip_vs_conn *cp = (struct ip_vs_conn *)data;
-	struct netns_ipvs *ipvs = net_ipvs(ip_vs_conn_net(cp));
+	struct net *net = ip_vs_conn_net(cp);
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	cp->timeout = 60*HZ;
 
@@ -826,6 +827,9 @@ static void ip_vs_conn_expire(unsigned long data)
 		  atomic_read(&cp->refcnt)-1,
 		  atomic_read(&cp->n_control));
 
+	if (ipvs->sync_state & IP_VS_STATE_MASTER)
+		ip_vs_sync_conn(net, cp, sysctl_sync_threshold(ipvs));
+
 	ip_vs_conn_put(cp);
 }
 
@@ -899,6 +903,7 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
 	/* Set its state and timeout */
 	cp->state = 0;
 	cp->timeout = 3*HZ;
+	cp->sync_endtime = jiffies & ~3UL;
 
 	/* Bind its packet transmitter */
 #ifdef CONFIG_IP_VS_IPV6
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 2555816..b3686d8 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1613,34 +1613,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	else
 		pkts = atomic_add_return(1, &cp->in_pkts);
 
-	if ((ipvs->sync_state & IP_VS_STATE_MASTER) &&
-	    cp->protocol == IPPROTO_SCTP) {
-		if ((cp->state == IP_VS_SCTP_S_ESTABLISHED &&
-			(pkts % sysctl_sync_period(ipvs)
-			 == sysctl_sync_threshold(ipvs))) ||
-				(cp->old_state != cp->state &&
-				 ((cp->state == IP_VS_SCTP_S_CLOSED) ||
-				  (cp->state == IP_VS_SCTP_S_SHUT_ACK_CLI) ||
-				  (cp->state == IP_VS_SCTP_S_SHUT_ACK_SER)))) {
-			ip_vs_sync_conn(net, cp);
-			goto out;
-		}
-	}
-
-	/* Keep this block last: TCP and others with pp->num_states <= 1 */
-	else if ((ipvs->sync_state & IP_VS_STATE_MASTER) &&
-	    (((cp->protocol != IPPROTO_TCP ||
-	       cp->state == IP_VS_TCP_S_ESTABLISHED) &&
-	      (pkts % sysctl_sync_period(ipvs)
-	       == sysctl_sync_threshold(ipvs))) ||
-	     ((cp->protocol == IPPROTO_TCP) && (cp->old_state != cp->state) &&
-	      ((cp->state == IP_VS_TCP_S_FIN_WAIT) ||
-	       (cp->state == IP_VS_TCP_S_CLOSE) ||
-	       (cp->state == IP_VS_TCP_S_CLOSE_WAIT) ||
-	       (cp->state == IP_VS_TCP_S_TIME_WAIT)))))
-		ip_vs_sync_conn(net, cp);
-out:
-	cp->old_state = cp->state;
+	if (ipvs->sync_state & IP_VS_STATE_MASTER)
+		ip_vs_sync_conn(net, cp, pkts);
 
 	ip_vs_conn_put(cp);
 	return ret;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index b3afe18..da922c7 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1599,6 +1599,10 @@ static int ip_vs_zero_all(struct net *net)
 }
 
 #ifdef CONFIG_SYSCTL
+
+static int zero;
+static int three = 3;
+
 static int
 proc_do_defense_mode(ctl_table *table, int write,
 		     void __user *buffer, size_t *lenp, loff_t *ppos)
@@ -1632,7 +1636,8 @@ proc_do_sync_threshold(ctl_table *table, int write,
 	memcpy(val, valp, sizeof(val));
 
 	rc = proc_dointvec(table, write, buffer, lenp, ppos);
-	if (write && (valp[0] < 0 || valp[1] < 0 || valp[0] >= valp[1])) {
+	if (write && (valp[0] < 0 || valp[1] < 0 ||
+	    (valp[0] >= valp[1] && valp[1]))) {
 		/* Restore the correct value */
 		memcpy(valp, val, sizeof(val));
 	}
@@ -1743,6 +1748,20 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= proc_do_sync_threshold,
 	},
 	{
+		.procname	= "sync_refresh_period",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "sync_retries",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &three,
+	},
+	{
 		.procname	= "nat_icmp_send",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
@@ -3661,6 +3680,10 @@ int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	ipvs->sysctl_sync_threshold[1] = DEFAULT_SYNC_PERIOD;
 	tbl[idx].data = &ipvs->sysctl_sync_threshold;
 	tbl[idx++].maxlen = sizeof(ipvs->sysctl_sync_threshold);
+	ipvs->sysctl_sync_refresh_period = DEFAULT_SYNC_REFRESH_PERIOD;
+	tbl[idx++].data = &ipvs->sysctl_sync_refresh_period;
+	ipvs->sysctl_sync_retries = clamp_t(int, DEFAULT_SYNC_RETRIES, 0, 3);
+	tbl[idx++].data = &ipvs->sysctl_sync_retries;
 	tbl[idx++].data = &ipvs->sysctl_nat_icmp_send;
 
 
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 9201c43..8ee8a57 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -442,11 +442,94 @@ ip_vs_sync_buff_create_v0(struct netns_ipvs *ipvs)
 	return sb;
 }
 
+/* Check if conn should be synced.
+ * pkts: conn packets, use sysctl_sync_threshold to avoid packet check
+ * - (1) sync_refresh_period: reduce sync rate. Additionally, retry
+ *	sync_retries times with period of sync_refresh_period/8
+ * - (2) if both sync_refresh_period and sync_period are 0 send sync only
+ *	for state changes or only once when pkts matches sync_threshold
+ * - (3) templates: rate can be reduced only with sync_refresh_period or
+ *	with (2)
+ */
+static int ip_vs_sync_conn_needed(struct netns_ipvs *ipvs,
+				  struct ip_vs_conn *cp, int pkts)
+{
+	unsigned long orig = ACCESS_ONCE(cp->sync_endtime);
+	unsigned long now = jiffies;
+	unsigned long n = (now + cp->timeout) & ~3UL;
+	unsigned int sync_refresh_period;
+	int sync_period;
+	int force;
+
+	/* Check if we sync in current state */
+	if (unlikely(cp->flags & IP_VS_CONN_F_TEMPLATE))
+		force = 0;
+	else if (likely(cp->protocol == IPPROTO_TCP)) {
+		if (!((1 << cp->state) &
+		      ((1 << IP_VS_TCP_S_ESTABLISHED) |
+		       (1 << IP_VS_TCP_S_FIN_WAIT) |
+		       (1 << IP_VS_TCP_S_CLOSE) |
+		       (1 << IP_VS_TCP_S_CLOSE_WAIT) |
+		       (1 << IP_VS_TCP_S_TIME_WAIT))))
+			return 0;
+		force = cp->state != cp->old_state;
+		if (force && cp->state != IP_VS_TCP_S_ESTABLISHED)
+			goto set;
+	} else if (unlikely(cp->protocol == IPPROTO_SCTP)) {
+		if (!((1 << cp->state) &
+		      ((1 << IP_VS_SCTP_S_ESTABLISHED) |
+		       (1 << IP_VS_SCTP_S_CLOSED) |
+		       (1 << IP_VS_SCTP_S_SHUT_ACK_CLI) |
+		       (1 << IP_VS_SCTP_S_SHUT_ACK_SER))))
+			return 0;
+		force = cp->state != cp->old_state;
+		if (force && cp->state != IP_VS_SCTP_S_ESTABLISHED)
+			goto set;
+	} else {
+		/* UDP or another protocol with single state */
+		force = 0;
+	}
+
+	sync_refresh_period = sysctl_sync_refresh_period(ipvs);
+	if (sync_refresh_period > 0) {
+		long diff = n - orig;
+		long min_diff = max(cp->timeout >> 1, 10UL * HZ);
+
+		/* Avoid sync if difference is below sync_refresh_period
+		 * and below the half timeout.
+		 */
+		if (abs(diff) < min_t(long, sync_refresh_period, min_diff)) {
+			int retries = orig & 3;
+
+			if (retries >= sysctl_sync_retries(ipvs))
+				return 0;
+			if (time_before(now, orig - cp->timeout +
+					(sync_refresh_period >> 3)))
+				return 0;
+			n |= retries + 1;
+		}
+	}
+	sync_period = sysctl_sync_period(ipvs);
+	if (sync_period > 0) {
+		if (!(cp->flags & IP_VS_CONN_F_TEMPLATE) &&
+		    pkts % sync_period != sysctl_sync_threshold(ipvs))
+			return 0;
+	} else if (sync_refresh_period <= 0 &&
+		   pkts != sysctl_sync_threshold(ipvs))
+		return 0;
+
+set:
+	cp->old_state = cp->state;
+	n = cmpxchg(&cp->sync_endtime, orig, n);
+	return n == orig || force;
+}
+
 /*
  *      Version 0 , could be switched in by sys_ctl.
  *      Add an ip_vs_conn information into the current sync_buff.
  */
-void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp)
+static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
+			       int pkts)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_sync_mesg_v0 *m;
@@ -459,6 +542,9 @@ void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp)
 	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
 		return;
 
+	if (!ip_vs_sync_conn_needed(ipvs, cp, pkts))
+		return;
+
 	spin_lock(&ipvs->sync_buff_lock);
 	if (!ipvs->sync_buff) {
 		ipvs->sync_buff =
@@ -504,8 +590,14 @@ void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp)
 	spin_unlock(&ipvs->sync_buff_lock);
 
 	/* synchronize its controller if it has */
-	if (cp->control)
-		ip_vs_sync_conn(net, cp->control);
+	cp = cp->control;
+	if (cp) {
+		if (cp->flags & IP_VS_CONN_F_TEMPLATE)
+			pkts = atomic_add_return(1, &cp->in_pkts);
+		else
+			pkts = sysctl_sync_threshold(ipvs);
+		ip_vs_sync_conn(net, cp->control, pkts);
+	}
 }
 
 /*
@@ -513,7 +605,7 @@ void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp)
  *      Called by ip_vs_in.
  *      Sending Version 1 messages
  */
-void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp)
+void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp, int pkts)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_sync_mesg *m;
@@ -523,13 +615,16 @@ void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp)
 
 	/* Handle old version of the protocol */
 	if (sysctl_sync_ver(ipvs) == 0) {
-		ip_vs_sync_conn_v0(net, cp);
+		ip_vs_sync_conn_v0(net, cp, pkts);
 		return;
 	}
 	/* Do not sync ONE PACKET */
 	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
 		goto control;
 sloop:
+	if (!ip_vs_sync_conn_needed(ipvs, cp, pkts))
+		goto control;
+
 	/* Sanity checks */
 	pe_name_len = 0;
 	if (cp->pe_data_len) {
@@ -644,16 +739,10 @@ control:
 	cp = cp->control;
 	if (!cp)
 		return;
-	/*
-	 * Reduce sync rate for templates
-	 * i.e only increment in_pkts for Templates.
-	 */
-	if (cp->flags & IP_VS_CONN_F_TEMPLATE) {
-		int pkts = atomic_add_return(1, &cp->in_pkts);
-
-		if (pkts % sysctl_sync_period(ipvs) != 1)
-			return;
-	}
+	if (cp->flags & IP_VS_CONN_F_TEMPLATE)
+		pkts = atomic_add_return(1, &cp->in_pkts);
+	else
+		pkts = sysctl_sync_threshold(ipvs);
 	goto sloop;
 }
 
@@ -1442,7 +1531,7 @@ next_sync_buff(struct netns_ipvs *ipvs)
 	if (sb)
 		return sb;
 	/* Do not delay entries in buffer for more than 2 seconds */
-	return get_curr_sync_buff(ipvs, 2 * HZ);
+	return get_curr_sync_buff(ipvs, IPVS_SYNC_FLUSH_TIME);
 }
 
 static int sync_thread_master(void *data)
-- 
1.7.6.3
