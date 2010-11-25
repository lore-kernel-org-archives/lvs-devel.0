From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 4/8] IPVS: Handle Scheduling errors.
Date: Thu, 25 Nov 2010 10:46:54 +0900
Message-ID: <1290649618-18955-5-git-send-email-horms@verge.net.au>
References: <1290649618-18955-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1290649618-18955-1-git-send-email-horms@verge.net.au>
Sender: netfilter-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

If ip_vs_conn_fill_param_persist return an error to ip_vs_sched_persist,
this error must propagate as ignored=-1 to ip_vs_schedule().
Errors from ip_vs_conn_new() in ip_vs_sched_persist() and ip_vs_schedule()
should also return *ignored=-1;

This patch just relies on the fact that ignored is 1 before calling
ip_vs_sched_persist().

Sent from Julian:
  "The new case when ip_vs_conn_fill_param_persist fails
   should set *ignored = -1, so that we can use NF_DROP,
   see below. *ignored = -1 should be also used for ip_vs_conn_new
   failure in ip_vs_sched_persist() and ip_vs_schedule().
   The new negative value should be handled in tcp,udp,sctp"

"To summarize:

- *ignored = 1:
      protocol tried to schedule (eg. on SYN), found svc but the
      svc/scheduler decides that this packet should be accepted with
      NF_ACCEPT because it must not be scheduled.

- *ignored = 0:
      scheduler can not find destination, so try bypass or
      return ICMP and then NF_DROP (ip_vs_leave).

- *ignored = -1:
      scheduler tried to schedule but fatal error occurred, eg.
      ip_vs_conn_new failure (ENOMEM) or ip_vs_sip_fill_param
      failure such as missing Call-ID, ENOMEM on skb_linearize
      or pe_data. In this case we should return NF_DROP without
      any attempts to send ICMP with ip_vs_leave."

More or less all ideas and input to this patch is work from
Julian Anastasov

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c       |   56 +++++++++++++++++++++++---------
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   11 +++++--
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |   10 +++++-
 net/netfilter/ipvs/ip_vs_proto_udp.c  |   10 +++++-
 4 files changed, 64 insertions(+), 23 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 9acdd79..3445da6 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -177,7 +177,7 @@ ip_vs_set_state(struct ip_vs_conn *cp, int direction,
 	return pp->state_transition(cp, direction, skb, pp);
 }
 
-static inline void
+static inline int
 ip_vs_conn_fill_param_persist(const struct ip_vs_service *svc,
 			      struct sk_buff *skb, int protocol,
 			      const union nf_inet_addr *caddr, __be16 cport,
@@ -187,7 +187,9 @@ ip_vs_conn_fill_param_persist(const struct ip_vs_service *svc,
 	ip_vs_conn_fill_param(svc->af, protocol, caddr, cport, vaddr, vport, p);
 	p->pe = svc->pe;
 	if (p->pe && p->pe->fill_param)
-		p->pe->fill_param(p, skb);
+		return p->pe->fill_param(p, skb);
+
+	return 0;
 }
 
 /*
@@ -200,7 +202,7 @@ ip_vs_conn_fill_param_persist(const struct ip_vs_service *svc,
 static struct ip_vs_conn *
 ip_vs_sched_persist(struct ip_vs_service *svc,
 		    struct sk_buff *skb,
-		    __be16 src_port, __be16 dst_port)
+		    __be16 src_port, __be16 dst_port, int *ignored)
 {
 	struct ip_vs_conn *cp = NULL;
 	struct ip_vs_iphdr iph;
@@ -268,20 +270,27 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 				vaddr = &fwmark;
 			}
 		}
-		ip_vs_conn_fill_param_persist(svc, skb, protocol, &snet, 0,
-					      vaddr, vport, &param);
+		/* return *ignored = -1 so NF_DROP can be used */
+		if (ip_vs_conn_fill_param_persist(svc, skb, protocol, &snet, 0,
+						  vaddr, vport, &param) < 0) {
+			*ignored = -1;
+			return NULL;
+		}
 	}
 
 	/* Check if a template already exists */
 	ct = ip_vs_ct_in_get(&param);
 	if (!ct || !ip_vs_check_template(ct)) {
-		/* No template found or the dest of the connection
+		/*
+		 * No template found or the dest of the connection
 		 * template is not available.
+		 * return *ignored=0 i.e. ICMP and NF_DROP
 		 */
 		dest = svc->scheduler->schedule(svc, skb);
 		if (!dest) {
 			IP_VS_DBG(1, "p-schedule: no dest found.\n");
 			kfree(param.pe_data);
+			*ignored = 0;
 			return NULL;
 		}
 
@@ -296,6 +305,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 				    IP_VS_CONN_F_TEMPLATE, dest, skb->mark);
 		if (ct == NULL) {
 			kfree(param.pe_data);
+			*ignored = -1;
 			return NULL;
 		}
 
@@ -323,6 +333,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	cp = ip_vs_conn_new(&param, &dest->addr, dport, flags, dest, skb->mark);
 	if (cp == NULL) {
 		ip_vs_conn_put(ct);
+		*ignored = -1;
 		return NULL;
 	}
 
@@ -342,6 +353,21 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
  *  It selects a server according to the virtual service, and
  *  creates a connection entry.
  *  Protocols supported: TCP, UDP
+ *
+ *  Usage of *ignored
+ *
+ * 1 :   protocol tried to schedule (eg. on SYN), found svc but the
+ *       svc/scheduler decides that this packet should be accepted with
+ *       NF_ACCEPT because it must not be scheduled.
+ *
+ * 0 :   scheduler can not find destination, so try bypass or
+ *       return ICMP and then NF_DROP (ip_vs_leave).
+ *
+ * -1 :  scheduler tried to schedule but fatal error occurred, eg.
+ *       ip_vs_conn_new failure (ENOMEM) or ip_vs_sip_fill_param
+ *       failure such as missing Call-ID, ENOMEM on skb_linearize
+ *       or pe_data. In this case we should return NF_DROP without
+ *       any attempts to send ICMP with ip_vs_leave.
  */
 struct ip_vs_conn *
 ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
@@ -372,11 +398,9 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	}
 
 	/*
-	 * Do not schedule replies from local real server. It is risky
-	 * for fwmark services but mostly for persistent services.
+	 *    Do not schedule replies from local real server.
 	 */
 	if ((!skb->dev || skb->dev->flags & IFF_LOOPBACK) &&
-	    (svc->flags & IP_VS_SVC_F_PERSISTENT || svc->fwmark) &&
 	    (cp = pp->conn_in_get(svc->af, skb, pp, &iph, iph.len, 1))) {
 		IP_VS_DBG_PKT(12, svc->af, pp, skb, 0,
 			      "Not scheduling reply for existing connection");
@@ -387,10 +411,10 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	/*
 	 *    Persistent service
 	 */
-	if (svc->flags & IP_VS_SVC_F_PERSISTENT) {
-		*ignored = 0;
-		return ip_vs_sched_persist(svc, skb, pptr[0], pptr[1]);
-	}
+	if (svc->flags & IP_VS_SVC_F_PERSISTENT)
+		return ip_vs_sched_persist(svc, skb, pptr[0], pptr[1], ignored);
+
+	*ignored = 0;
 
 	/*
 	 *    Non-persistent service
@@ -403,8 +427,6 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 		return NULL;
 	}
 
-	*ignored = 0;
-
 	dest = svc->scheduler->schedule(svc, skb);
 	if (dest == NULL) {
 		IP_VS_DBG(1, "Schedule: no dest found.\n");
@@ -425,8 +447,10 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 		cp = ip_vs_conn_new(&p, &dest->addr,
 				    dest->port ? dest->port : pptr[1],
 				    flags, dest, skb->mark);
-		if (!cp)
+		if (!cp) {
+			*ignored = -1;
 			return NULL;
+		}
 	}
 
 	IP_VS_DBG_BUF(6, "Schedule fwd:%c c:%s:%u v:%s:%u "
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 1ea96bc..a315159 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -47,13 +47,18 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		 * incoming connection, and create a connection entry.
 		 */
 		*cpp = ip_vs_schedule(svc, skb, pp, &ignored);
-		if (!*cpp && !ignored) {
-			*verdict = ip_vs_leave(svc, skb, pp);
+		if (!*cpp && ignored <= 0) {
+			if (!ignored)
+				*verdict = ip_vs_leave(svc, skb, pp);
+			else {
+				ip_vs_service_put(svc);
+				*verdict = NF_DROP;
+			}
 			return 0;
 		}
 		ip_vs_service_put(svc);
 	}
-
+	/* NF_ACCEPT */
 	return 1;
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index f6c5200..1cdab12 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -64,12 +64,18 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		 * incoming connection, and create a connection entry.
 		 */
 		*cpp = ip_vs_schedule(svc, skb, pp, &ignored);
-		if (!*cpp && !ignored) {
-			*verdict = ip_vs_leave(svc, skb, pp);
+		if (!*cpp && ignored <= 0) {
+			if (!ignored)
+				*verdict = ip_vs_leave(svc, skb, pp);
+			else {
+				ip_vs_service_put(svc);
+				*verdict = NF_DROP;
+			}
 			return 0;
 		}
 		ip_vs_service_put(svc);
 	}
+	/* NF_ACCEPT */
 	return 1;
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 9d106a0..cd398de 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -63,12 +63,18 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		 * incoming connection, and create a connection entry.
 		 */
 		*cpp = ip_vs_schedule(svc, skb, pp, &ignored);
-		if (!*cpp && !ignored) {
-			*verdict = ip_vs_leave(svc, skb, pp);
+		if (!*cpp && ignored <= 0) {
+			if (!ignored)
+				*verdict = ip_vs_leave(svc, skb, pp);
+			else {
+				ip_vs_service_put(svc);
+				*verdict = NF_DROP;
+			}
 			return 0;
 		}
 		ip_vs_service_put(svc);
 	}
+	/* NF_ACCEPT */
 	return 1;
 }
 
-- 
1.7.2.3

