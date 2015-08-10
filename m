From: Alex Gartrell <agartrell@fb.com>
Subject: [RFC PATCH net-next] ipvs: enable the scheduling of icmp packets
Date: Sun, 9 Aug 2015 18:53:30 -0700
Message-ID: <1439171610-226215-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : mime-version : content-type; s=facebook;
 bh=MuvA5tLm59Wtzxi14BYMbrG8XBKZLrmFGVRyfiLgyzA=;
 b=E8FzsbL18EpUpdAd1RnBebh8Zp0PBg3OVIVlTRbYhmB8uPJR4dqjWv+rfG64Z2BU4Xke
 lsLyEH1ZSrFAlNabqRp1sTYo+wuIvhVfbo97aR9GaoGM6I9uizz6j0b948D3WfAooGJT
 5glZVY2i/VFLPHDDvQFBoo7MiSdjrmVsZRc= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ja@ssi.bg, horms@verge.net.au
Cc: lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

If the schedule_icmp sysctl is set, ICMP messages for unseen flows will be
handed off to the appropriate schedulers.  This is very necessary for us at
Facebook, because we ECMP load balance down to the IPVS instances and rely
on a deterministic scheduler rather than sync'ing, so a TCP SYN and an
ICMPv6 PACKET_TOO_BIG packet are unlikely to end up on the same ipvs host.

This patch introduces the following behavior changes:

1) We no longer check for !th->rst in the sloppy_tcp schedule case

Why? First, it's useful to schedule these packets anyway (the assumption
being that we want to push the state all the way down to the actual TCP
terminator in this case).  Second, this bit is not present in IPv4 ICMP
packets, and the alternative is to also plumb an "is_icmp" field all the
way through.

2) Packets that do not contain full transport headers are not rejected for
udp, sloppy tcp, or sloppy sctp.  It was simply cleaner to implement this
way.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 include/net/ip_vs.h                     |  15 ++++-
 net/netfilter/ipvs/ip_vs_core.c         | 107 +++++++++++++++++++++++---------
 net/netfilter/ipvs/ip_vs_ctl.c          |   7 +++
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |   2 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |  47 +++++++++-----
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |  47 +++++++++++---
 net/netfilter/ipvs/ip_vs_proto_udp.c    |  23 ++++---
 7 files changed, 181 insertions(+), 67 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 4e3731e..8d7420d 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -444,7 +444,7 @@ struct ip_vs_protocol {
 	int (*conn_schedule)(int af, struct sk_buff *skb,
 			     struct ip_vs_proto_data *pd,
 			     int *verdict, struct ip_vs_conn **cpp,
-			     struct ip_vs_iphdr *iph);
+			     struct ip_vs_iphdr *iph, int inverse);
 
 	struct ip_vs_conn *
 	(*conn_in_get)(int af,
@@ -942,6 +942,7 @@ struct netns_ipvs {
 	int			sysctl_pmtu_disc;
 	int			sysctl_backup_only;
 	int			sysctl_conn_reuse_mode;
+	int			sysctl_schedule_icmp;
 
 	/* ip_vs_lblc */
 	int			sysctl_lblc_expiration;
@@ -1065,6 +1066,11 @@ static inline int sysctl_conn_reuse_mode(struct netns_ipvs *ipvs)
 	return ipvs->sysctl_conn_reuse_mode;
 }
 
+static inline int sysctl_schedule_icmp(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_schedule_icmp;
+}
+
 #else
 
 static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
@@ -1137,6 +1143,11 @@ static inline int sysctl_conn_reuse_mode(struct netns_ipvs *ipvs)
 	return 1;
 }
 
+static inline int sysctl_schedule_icmp(struct netns_ipvs *ipvs)
+{
+	return 0;
+}
+
 #endif
 
 /* IPVS core functions
@@ -1358,7 +1369,7 @@ void ip_vs_scheduler_put(struct ip_vs_scheduler *scheduler);
 struct ip_vs_conn *
 ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	       struct ip_vs_proto_data *pd, int *ignored,
-	       struct ip_vs_iphdr *iph);
+	       struct ip_vs_iphdr *iph, int inverse);
 int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		struct ip_vs_proto_data *pd, struct ip_vs_iphdr *iph);
 
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 38fbc19..ef44e07 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -412,7 +412,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 struct ip_vs_conn *
 ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	       struct ip_vs_proto_data *pd, int *ignored,
-	       struct ip_vs_iphdr *iph)
+	       struct ip_vs_iphdr *iph, int inverse)
 {
 	struct ip_vs_protocol *pp = pd->pp;
 	struct ip_vs_conn *cp = NULL;
@@ -420,6 +420,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	struct ip_vs_dest *dest;
 	__be16 _ports[2], *pptr;
 	unsigned int flags;
+	__be16 client_port, svc_port;
 
 	*ignored = 1;
 	/*
@@ -429,13 +430,21 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	if (pptr == NULL)
 		return NULL;
 
+	if (inverse) {
+		client_port = pptr[1];
+		svc_port = pptr[0];
+	} else {
+		client_port = pptr[0];
+		svc_port = pptr[1];
+	}
+
 	/*
 	 * FTPDATA needs this check when using local real server.
 	 * Never schedule Active FTPDATA connections from real server.
 	 * For LVS-NAT they must be already created. For other methods
 	 * with persistence the connection is created on SYN+ACK.
 	 */
-	if (pptr[0] == FTPDATA) {
+	if (client_port == FTPDATA) {
 		IP_VS_DBG_PKT(12, svc->af, pp, skb, 0,
 			      "Not scheduling FTPDATA");
 		return NULL;
@@ -456,15 +465,15 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	 *    Persistent service
 	 */
 	if (svc->flags & IP_VS_SVC_F_PERSISTENT)
-		return ip_vs_sched_persist(svc, skb, pptr[0], pptr[1], ignored,
-					   iph);
+		return ip_vs_sched_persist(svc, skb, client_port, svc_port,
+					   ignored, iph);
 
 	*ignored = 0;
 
 	/*
 	 *    Non-persistent service
 	 */
-	if (!svc->fwmark && pptr[1] != svc->port) {
+	if (!svc->fwmark && svc_port != svc->port) {
 		if (!svc->port)
 			pr_err("Schedule: port zero only supported "
 			       "in persistent services, "
@@ -496,10 +505,10 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 		struct ip_vs_conn_param p;
 
 		ip_vs_conn_fill_param(svc->net, svc->af, iph->protocol,
-				      &iph->saddr, pptr[0], &iph->daddr,
-				      pptr[1], &p);
+				      &iph->saddr, client_port, &iph->daddr,
+				      svc_port, &p);
 		cp = ip_vs_conn_new(&p, dest->af, &dest->addr,
-				    dest->port ? dest->port : pptr[1],
+				    dest->port ? dest->port : svc_port,
 				    flags, dest, skb->mark);
 		if (!cp) {
 			*ignored = -1;
@@ -1327,6 +1336,42 @@ ip_vs_local_reply6(const struct nf_hook_ops *ops, struct sk_buff *skb,
 
 #endif
 
+static unsigned int
+ip_vs_try_to_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
+		      int *verdict, struct ip_vs_conn **cpp,
+		      struct ip_vs_iphdr *iph, int inverse)
+{
+	struct ip_vs_protocol *pp = pd->pp;
+
+	if (!iph->fragoffs) {
+		/* No (second) fragments need to enter here, as nf_defrag_ipv6
+		 * replayed fragment zero will already have created the cp
+		 */
+
+		/* Schedule and create new connection entry into &cp */
+		if (!pp->conn_schedule(af, skb, pd, verdict, cpp, iph,
+				       inverse))
+			return 0;
+	}
+
+	if (unlikely(!*cpp)) {
+		/* sorry, all this trouble for a no-hit :) */
+		IP_VS_DBG_PKT(12, af, pp, skb, 0,
+			      "ip_vs_in: packet continues traversal as normal");
+		if (iph->fragoffs) {
+			/* Fragment that couldn't be mapped to a conn entry
+			 * is missing module nf_defrag_ipv6
+			 */
+			IP_VS_DBG_RL("Unhandled frag, load nf_defrag_ipv6\n");
+			IP_VS_DBG_PKT(7, af, pp, skb, 0, "unhandled fragment");
+		}
+		*verdict = NF_ACCEPT;
+		return 0;
+	}
+
+	return 1;
+}
+
 /*
  *	Handle ICMP messages in the outside-to-inside direction (incoming).
  *	Find any that might be relevant, check against existing connections,
@@ -1423,6 +1468,15 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	 * For IPIP this is error for request, not for reply.
 	 */
 	cp = pp->conn_in_get(AF_INET, skb, &ciph, ipip ? 0 : 1);
+
+	if (unlikely(!cp) && sysctl_schedule_icmp(net_ipvs(net))) {
+		int v;
+
+		if (!ip_vs_try_to_schedule(
+			    AF_INET, skb, pd, &v, &cp, &ciph, !ipip))
+			return v;
+	}
+
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -1501,7 +1555,7 @@ ignore_ipip:
 	verdict = ip_vs_icmp_xmit(skb, cp, pp, offset, hooknum, &ciph);
 
 out:
-	__ip_vs_conn_put(cp);
+	ip_vs_conn_put(cp);
 
 	return verdict;
 }
@@ -1578,12 +1632,21 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 	cp = pp->conn_in_get(AF_INET6, skb, &ciph,
 			     (hooknum == NF_INET_LOCAL_OUT) ? 0 : 1);
 
+	if (unlikely(!cp) && sysctl_schedule_icmp(net_ipvs(net))) {
+		int v;
+
+		if (!ip_vs_try_to_schedule(
+			    AF_INET6, skb, pd, &v, &cp, &ciph,
+			    (hooknum == NF_INET_LOCAL_OUT) ? 0 : 1))
+			return v;
+	}
+
 	if (!cp)
 		return NF_ACCEPT;
 	/* VS/TUN, VS/DR and LOCALNODE just let it go */
 	if ((hooknum == NF_INET_LOCAL_OUT) &&
 	    (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)) {
-		__ip_vs_conn_put(cp);
+		ip_vs_conn_put(cp);
 		return NF_ACCEPT;
 	}
 
@@ -1598,7 +1661,7 @@ static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
 
 	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, writable, hooknum, &ciph);
 
-	__ip_vs_conn_put(cp);
+	ip_vs_conn_put(cp);
 
 	return verdict;
 }
@@ -1700,31 +1763,13 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 		cp = NULL;
 	}
 
-	if (unlikely(!cp) && !iph.fragoffs) {
-		/* No (second) fragments need to enter here, as nf_defrag_ipv6
-		 * replayed fragment zero will already have created the cp
-		 */
+	if (unlikely(!cp)) {
 		int v;
 
-		/* Schedule and create new connection entry into &cp */
-		if (!pp->conn_schedule(af, skb, pd, &v, &cp, &iph))
+		if (!ip_vs_try_to_schedule(af, skb, pd, &v, &cp, &iph, 0))
 			return v;
 	}
 
-	if (unlikely(!cp)) {
-		/* sorry, all this trouble for a no-hit :) */
-		IP_VS_DBG_PKT(12, af, pp, skb, 0,
-			      "ip_vs_in: packet continues traversal as normal");
-		if (iph.fragoffs) {
-			/* Fragment that couldn't be mapped to a conn entry
-			 * is missing module nf_defrag_ipv6
-			 */
-			IP_VS_DBG_RL("Unhandled frag, load nf_defrag_ipv6\n");
-			IP_VS_DBG_PKT(7, af, pp, skb, 0, "unhandled fragment");
-		}
-		return NF_ACCEPT;
-	}
-
 	IP_VS_DBG_PKT(11, af, pp, skb, 0, "Incoming packet");
 	/* Check the server status */
 	if (cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 24c5542..3e0657d 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1844,6 +1844,12 @@ static struct ctl_table vs_vars[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "schedule_icmp",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 #ifdef CONFIG_IP_VS_DEBUG
 	{
 		.procname	= "debug_level",
@@ -3818,6 +3824,7 @@ static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	tbl[idx++].data = &ipvs->sysctl_backup_only;
 	ipvs->sysctl_conn_reuse_mode = 1;
 	tbl[idx++].data = &ipvs->sysctl_conn_reuse_mode;
+	tbl[idx++].data = &ipvs->sysctl_schedule_icmp;
 
 
 	ipvs->sysctl_hdr = register_net_sysctl(net, "net/ipv4/vs", tbl);
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index 5de3dd3..31c0b20 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -109,7 +109,7 @@ ah_esp_conn_out_get(int af, const struct sk_buff *skb,
 static int
 ah_esp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		     int *verdict, struct ip_vs_conn **cpp,
-		     struct ip_vs_iphdr *iph)
+		     struct ip_vs_iphdr *iph, int is_icmp)
 {
 	/*
 	 * AH/ESP is only related traffic. Pass the packet to IP stack.
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 5b84c0b..b2ab6e1 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -11,33 +11,48 @@
 static int
 sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		   int *verdict, struct ip_vs_conn **cpp,
-		   struct ip_vs_iphdr *iph)
+		   struct ip_vs_iphdr *iph, int inverse)
 {
 	struct net *net;
 	struct ip_vs_service *svc;
 	struct netns_ipvs *ipvs;
-	sctp_chunkhdr_t _schunkh, *sch;
-	sctp_sctphdr_t *sh, _sctph;
+	__be16 _ports[2];
+	__be16 *ports = NULL;
 
-	sh = skb_header_pointer(skb, iph->len, sizeof(_sctph), &_sctph);
-	if (sh == NULL) {
-		*verdict = NF_DROP;
-		return 0;
-	}
-
-	sch = skb_header_pointer(skb, iph->len + sizeof(sctp_sctphdr_t),
-				 sizeof(_schunkh), &_schunkh);
-	if (sch == NULL) {
+	ports = skb_header_pointer(skb, iph->len, sizeof(_ports), &_ports);
+	if (!ports) {
 		*verdict = NF_DROP;
 		return 0;
 	}
 
 	net = skb_net(skb);
 	ipvs = net_ipvs(net);
+
 	rcu_read_lock();
-	if ((sch->type == SCTP_CID_INIT || sysctl_sloppy_sctp(ipvs)) &&
-	    (svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
-				      &iph->daddr, sh->dest))) {
+
+	if (!sysctl_sloppy_sctp(ipvs)) {
+		sctp_chunkhdr_t _schunkh, *sch;
+
+		sch = skb_header_pointer(skb, iph->len + sizeof(sctp_sctphdr_t),
+					 sizeof(_schunkh), &_schunkh);
+		if (!sch) {
+			*verdict = NF_DROP;
+			return 0;
+		}
+		if (sch->type != SCTP_CID_INIT) {
+			*verdict = NF_ACCEPT;
+			return 0;
+		}
+	}
+
+	if (inverse)
+		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+					 &iph->saddr, ports[0]);
+	else
+		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+					 &iph->daddr, ports[1]);
+
+	if (svc) {
 		int ignored;
 
 		if (ip_vs_todrop(ipvs)) {
@@ -53,7 +68,7 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		 * Let the virtual server select a real server for the
 		 * incoming connection, and create a connection entry.
 		 */
-		*cpp = ip_vs_schedule(svc, skb, pd, &ignored, iph);
+		*cpp = ip_vs_schedule(svc, skb, pd, &ignored, iph, inverse);
 		if (!*cpp && ignored <= 0) {
 			if (!ignored)
 				*verdict = ip_vs_leave(svc, skb, pd, iph);
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 8e92beb..4ffef87 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -34,25 +34,52 @@
 static int
 tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		  int *verdict, struct ip_vs_conn **cpp,
-		  struct ip_vs_iphdr *iph)
+		  struct ip_vs_iphdr *iph, int inverse)
 {
 	struct net *net;
 	struct ip_vs_service *svc;
 	struct tcphdr _tcph, *th;
 	struct netns_ipvs *ipvs;
+	__be16 _ports[2];
+	__be16 *ports = NULL;
 
-	th = skb_header_pointer(skb, iph->len, sizeof(_tcph), &_tcph);
-	if (th == NULL) {
+	net = skb_net(skb);
+	ipvs = net_ipvs(net);
+
+	if (sysctl_sloppy_tcp(ipvs)) {
+		/* We're going to schedule any tcp that looks even vaguely
+		 * like a tcp header (important for ICMP where many fields
+		 * may be lost)
+		 */
+		ports = skb_header_pointer(
+			skb, iph->len, sizeof(_ports), &_ports);
+	} else {
+		th = skb_header_pointer(
+			skb, iph->len, sizeof(_tcph), &_tcph);
+		if (th && th->syn && !th->rst) {
+			/* We are not scheduling sloppily and we seem to
+			 * have a valid SYN or SYN-ACK (for active FTP)
+			 * here.
+			 */
+			ports = &th->source;
+		}
+	}
+
+	if (!ports) {
 		*verdict = NF_DROP;
 		return 0;
 	}
-	net = skb_net(skb);
-	ipvs = net_ipvs(net);
-	/* No !th->ack check to allow scheduling on SYN+ACK for Active FTP */
+
 	rcu_read_lock();
-	if ((th->syn || sysctl_sloppy_tcp(ipvs)) && !th->rst &&
-	    (svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
-				      &iph->daddr, th->dest))) {
+
+	if (inverse)
+		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+					 &iph->saddr, ports[0]);
+	else
+		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+					 &iph->daddr, ports[1]);
+
+	if (svc) {
 		int ignored;
 
 		if (ip_vs_todrop(ipvs)) {
@@ -69,7 +96,7 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		 * Let the virtual server select a real server for the
 		 * incoming connection, and create a connection entry.
 		 */
-		*cpp = ip_vs_schedule(svc, skb, pd, &ignored, iph);
+		*cpp = ip_vs_schedule(svc, skb, pd, &ignored, iph, inverse);
 		if (!*cpp && ignored <= 0) {
 			if (!ignored)
 				*verdict = ip_vs_leave(svc, skb, pd, iph);
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index b62a3c0..7417fc2 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -31,22 +31,31 @@
 static int
 udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		  int *verdict, struct ip_vs_conn **cpp,
-		  struct ip_vs_iphdr *iph)
+		  struct ip_vs_iphdr *iph, int inverse)
 {
 	struct net *net;
 	struct ip_vs_service *svc;
-	struct udphdr _udph, *uh;
+	__be16 _ports[2];
+	__be16 *ports = NULL;
+
+	ports = skb_header_pointer(
+		skb, iph->len, sizeof(_ports), &_ports);
 
 	/* IPv6 fragments, only first fragment will hit this */
-	uh = skb_header_pointer(skb, iph->len, sizeof(_udph), &_udph);
-	if (uh == NULL) {
+	if (!ports) {
 		*verdict = NF_DROP;
 		return 0;
 	}
 	net = skb_net(skb);
 	rcu_read_lock();
-	svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
-				 &iph->daddr, uh->dest);
+
+	if (inverse)
+		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+					 &iph->saddr, ports[0]);
+	else
+		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+					 &iph->daddr, ports[1]);
+
 	if (svc) {
 		int ignored;
 
@@ -64,7 +73,7 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		 * Let the virtual server select a real server for the
 		 * incoming connection, and create a connection entry.
 		 */
-		*cpp = ip_vs_schedule(svc, skb, pd, &ignored, iph);
+		*cpp = ip_vs_schedule(svc, skb, pd, &ignored, iph, inverse);
 		if (!*cpp && ignored <= 0) {
 			if (!ignored)
 				*verdict = ip_vs_leave(svc, skb, pd, iph);
-- 
Alex Gartrell <agartrell@fb.com>

