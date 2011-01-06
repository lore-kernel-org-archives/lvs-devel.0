From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 11/22] IPVS: netns, common protocol changes and use of appcnt.
Date: Thu,  6 Jan 2011 15:16:07 +0900
Message-ID: <1294294578-8601-12-git-send-email-horms@verge.net.au>
References: <1294294578-8601-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1294294578-8601-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Patrick McHardy <kaber@trash.net>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

appcnt and timeout_table moved from struct ip_vs_protocol to
ip_vs proto_data.

struct net *net added as first param to
 - register_app()
 - unregister_app()
 - app_conn_bind()
 - ip_vs_conn_new()

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h                   |    2 -
 net/netfilter/ipvs/ip_vs_conn.c       |    6 ++--
 net/netfilter/ipvs/ip_vs_proto_sctp.c |    4 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |    5 +--
 net/netfilter/ipvs/ip_vs_proto_udp.c  |    4 +-
 net/netfilter/ipvs/ip_vs_sync.c       |   57 ++++++++++++++++++---------------
 6 files changed, 40 insertions(+), 38 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 464ea36..cc6ae62 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -360,8 +360,6 @@ struct ip_vs_protocol {
 	u16			protocol;
 	u16			num_states;
 	int			dont_defrag;
-	atomic_t		appcnt;		/* counter of proto app incs */
-	int			*timeout_table;	/* protocol timeout table */
 
 	void (*init)(struct ip_vs_protocol *pp);
 
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index a7aba6a..b2024c9 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -804,7 +804,7 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
 	       struct ip_vs_dest *dest, __u32 fwmark)
 {
 	struct ip_vs_conn *cp;
-	struct ip_vs_protocol *pp = ip_vs_proto_get(p->protocol);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(&init_net, p->protocol);
 
 	cp = kmem_cache_zalloc(ip_vs_conn_cachep, GFP_ATOMIC);
 	if (cp == NULL) {
@@ -863,8 +863,8 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
 #endif
 		ip_vs_bind_xmit(cp);
 
-	if (unlikely(pp && atomic_read(&pp->appcnt)))
-		ip_vs_bind_app(cp, pp);
+	if (unlikely(pd && atomic_read(&pd->appcnt)))
+		ip_vs_bind_app(cp, pd->pp);
 
 	/*
 	 * Allow conntrack to be preserved. By default, conntrack
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 19bc379..0f14f79 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -1035,7 +1035,7 @@ static int sctp_register_app(struct ip_vs_app *inc)
 		}
 	}
 	list_add(&inc->p_list, &ipvs->sctp_apps[hash]);
-	atomic_inc(&pd->pp->appcnt);
+	atomic_inc(&pd->appcnt);
 out:
 	spin_unlock_bh(&ipvs->sctp_app_lock);
 
@@ -1048,7 +1048,7 @@ static void sctp_unregister_app(struct ip_vs_app *inc)
 	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(&init_net, IPPROTO_SCTP);
 
 	spin_lock_bh(&ipvs->sctp_app_lock);
-	atomic_dec(&pd->pp->appcnt);
+	atomic_dec(&pd->appcnt);
 	list_del(&inc->p_list);
 	spin_unlock_bh(&ipvs->sctp_app_lock);
 }
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index d7c2455..290b380 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -596,7 +596,7 @@ static int tcp_register_app(struct ip_vs_app *inc)
 		}
 	}
 	list_add(&inc->p_list, &ipvs->tcp_apps[hash]);
-	atomic_inc(&pd->pp->appcnt);
+	atomic_inc(&pd->appcnt);
 
   out:
 	spin_unlock_bh(&ipvs->tcp_app_lock);
@@ -611,7 +611,7 @@ tcp_unregister_app(struct ip_vs_app *inc)
 	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(&init_net, IPPROTO_TCP);
 
 	spin_lock_bh(&ipvs->tcp_app_lock);
-	atomic_dec(&pd->pp->appcnt);
+	atomic_dec(&pd->appcnt);
 	list_del(&inc->p_list);
 	spin_unlock_bh(&ipvs->tcp_app_lock);
 }
@@ -701,7 +701,6 @@ struct ip_vs_protocol ip_vs_protocol_tcp = {
 	.protocol =		IPPROTO_TCP,
 	.num_states =		IP_VS_TCP_S_LAST,
 	.dont_defrag =		0,
-	.appcnt =		ATOMIC_INIT(0),
 	.init =			NULL,
 	.exit =			NULL,
 	.init_netns =		__ip_vs_tcp_init,
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index aa85df2..3719837 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -373,7 +373,7 @@ static int udp_register_app(struct ip_vs_app *inc)
 		}
 	}
 	list_add(&inc->p_list, &ipvs->udp_apps[hash]);
-	atomic_inc(&pd->pp->appcnt);
+	atomic_inc(&pd->appcnt);
 
   out:
 	spin_unlock_bh(&ipvs->udp_app_lock);
@@ -388,7 +388,7 @@ udp_unregister_app(struct ip_vs_app *inc)
 	struct netns_ipvs *ipvs = net_ipvs(&init_net);
 
 	spin_lock_bh(&ipvs->udp_app_lock);
-	atomic_dec(&pd->pp->appcnt);
+	atomic_dec(&pd->appcnt);
 	list_del(&inc->p_list);
 	spin_unlock_bh(&ipvs->udp_app_lock);
 }
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 662aa2c..67b2b09 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -725,17 +725,16 @@ ip_vs_conn_fill_param_sync(int af, union ip_vs_sync_conn *sc,
  *  Param: ...
  *         timeout is in sec.
  */
-static void ip_vs_proc_conn(struct ip_vs_conn_param *param,  unsigned flags,
-			    unsigned state, unsigned protocol, unsigned type,
+static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
+			    unsigned int flags, unsigned int state,
+			    unsigned int protocol, unsigned int type,
 			    const union nf_inet_addr *daddr, __be16 dport,
 			    unsigned long timeout, __u32 fwmark,
-			    struct ip_vs_sync_conn_options *opt,
-			    struct ip_vs_protocol *pp)
+			    struct ip_vs_sync_conn_options *opt)
 {
 	struct ip_vs_dest *dest;
 	struct ip_vs_conn *cp;
 
-
 	if (!(flags & IP_VS_CONN_F_TEMPLATE))
 		cp = ip_vs_conn_in_get(param);
 	else
@@ -821,17 +820,23 @@ static void ip_vs_proc_conn(struct ip_vs_conn_param *param,  unsigned flags,
 		if (timeout > MAX_SCHEDULE_TIMEOUT / HZ)
 			timeout = MAX_SCHEDULE_TIMEOUT / HZ;
 		cp->timeout = timeout*HZ;
-	} else if (!(flags & IP_VS_CONN_F_TEMPLATE) && pp->timeout_table)
-		cp->timeout = pp->timeout_table[state];
-	else
-		cp->timeout = (3*60*HZ);
+	} else {
+		struct ip_vs_proto_data *pd;
+
+		pd = ip_vs_proto_data_get(net, protocol);
+		if (!(flags & IP_VS_CONN_F_TEMPLATE) && pd && pd->timeout_table)
+			cp->timeout = pd->timeout_table[state];
+		else
+			cp->timeout = (3*60*HZ);
+	}
 	ip_vs_conn_put(cp);
 }
 
 /*
  *  Process received multicast message for Version 0
  */
-static void ip_vs_process_message_v0(const char *buffer, const size_t buflen)
+static void ip_vs_process_message_v0(struct net *net, const char *buffer,
+				     const size_t buflen)
 {
 	struct ip_vs_sync_mesg_v0 *m = (struct ip_vs_sync_mesg_v0 *)buffer;
 	struct ip_vs_sync_conn_v0 *s;
@@ -843,7 +848,7 @@ static void ip_vs_process_message_v0(const char *buffer, const size_t buflen)
 
 	p = (char *)buffer + sizeof(struct ip_vs_sync_mesg_v0);
 	for (i=0; i<m->nr_conns; i++) {
-		unsigned flags, state;
+		unsigned int flags, state;
 
 		if (p + SIMPLE_CONN_SIZE > buffer+buflen) {
 			IP_VS_ERR_RL("BACKUP v0, bogus conn\n");
@@ -879,7 +884,6 @@ static void ip_vs_process_message_v0(const char *buffer, const size_t buflen)
 			}
 		} else {
 			/* protocol in templates is not used for state/timeout */
-			pp = NULL;
 			if (state > 0) {
 				IP_VS_DBG(2, "BACKUP v0, Invalid template state %u\n",
 					state);
@@ -894,9 +898,9 @@ static void ip_vs_process_message_v0(const char *buffer, const size_t buflen)
 				      s->vport, &param);
 
 		/* Send timeout as Zero */
-		ip_vs_proc_conn(&param, flags, state, s->protocol, AF_INET,
+		ip_vs_proc_conn(net, &param, flags, state, s->protocol, AF_INET,
 				(union nf_inet_addr *)&s->daddr, s->dport,
-				0, 0, opt, pp);
+				0, 0, opt);
 	}
 }
 
@@ -945,7 +949,7 @@ static int ip_vs_proc_str(__u8 *p, unsigned int plen, unsigned int *data_len,
 /*
  *   Process a Version 1 sync. connection
  */
-static inline int ip_vs_proc_sync_conn(__u8 *p, __u8 *msg_end)
+static inline int ip_vs_proc_sync_conn(struct net *net, __u8 *p, __u8 *msg_end)
 {
 	struct ip_vs_sync_conn_options opt;
 	union  ip_vs_sync_conn *s;
@@ -1043,7 +1047,6 @@ static inline int ip_vs_proc_sync_conn(__u8 *p, __u8 *msg_end)
 		}
 	} else {
 		/* protocol in templates is not used for state/timeout */
-		pp = NULL;
 		if (state > 0) {
 			IP_VS_DBG(3, "BACKUP, Invalid template state %u\n",
 				state);
@@ -1058,18 +1061,18 @@ static inline int ip_vs_proc_sync_conn(__u8 *p, __u8 *msg_end)
 	}
 	/* If only IPv4, just silent skip IPv6 */
 	if (af == AF_INET)
-		ip_vs_proc_conn(&param, flags, state, s->v4.protocol, af,
+		ip_vs_proc_conn(net, &param, flags, state, s->v4.protocol, af,
 				(union nf_inet_addr *)&s->v4.daddr, s->v4.dport,
 				ntohl(s->v4.timeout), ntohl(s->v4.fwmark),
-				(opt_flags & IPVS_OPT_F_SEQ_DATA ? &opt : NULL),
-				pp);
+				(opt_flags & IPVS_OPT_F_SEQ_DATA ? &opt : NULL)
+				);
 #ifdef CONFIG_IP_VS_IPV6
 	else
-		ip_vs_proc_conn(&param, flags, state, s->v6.protocol, af,
+		ip_vs_proc_conn(net, &param, flags, state, s->v6.protocol, af,
 				(union nf_inet_addr *)&s->v6.daddr, s->v6.dport,
 				ntohl(s->v6.timeout), ntohl(s->v6.fwmark),
-				(opt_flags & IPVS_OPT_F_SEQ_DATA ? &opt : NULL),
-				pp);
+				(opt_flags & IPVS_OPT_F_SEQ_DATA ? &opt : NULL)
+				);
 #endif
 	return 0;
 	/* Error exit */
@@ -1083,7 +1086,8 @@ out:
  *      ip_vs_conn entries.
  *      Handles Version 0 & 1
  */
-static void ip_vs_process_message(__u8 *buffer, const size_t buflen)
+static void ip_vs_process_message(struct net *net, __u8 *buffer,
+				  const size_t buflen)
 {
 	struct ip_vs_sync_mesg *m2 = (struct ip_vs_sync_mesg *)buffer;
 	__u8 *p, *msg_end;
@@ -1136,7 +1140,8 @@ static void ip_vs_process_message(__u8 *buffer, const size_t buflen)
 				return;
 			}
 			/* Process a single sync_conn */
-			if ((retc=ip_vs_proc_sync_conn(p, msg_end)) < 0) {
+			retc = ip_vs_proc_sync_conn(net, p, msg_end);
+			if (retc < 0) {
 				IP_VS_ERR_RL("BACKUP, Dropping buffer, Err: %d in decoding\n",
 					     retc);
 				return;
@@ -1146,7 +1151,7 @@ static void ip_vs_process_message(__u8 *buffer, const size_t buflen)
 		}
 	} else {
 		/* Old type of message */
-		ip_vs_process_message_v0(buffer, buflen);
+		ip_vs_process_message_v0(net, buffer, buflen);
 		return;
 	}
 }
@@ -1500,7 +1505,7 @@ static int sync_thread_backup(void *data)
 			/* disable bottom half, because it accesses the data
 			   shared by softirq while getting/creating conns */
 			local_bh_disable();
-			ip_vs_process_message(tinfo->buf, len);
+			ip_vs_process_message(&init_net, tinfo->buf, len);
 			local_bh_enable();
 		}
 	}
-- 
1.7.2.3

