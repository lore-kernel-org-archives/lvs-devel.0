From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 04/12] ipvs: do not schedule conns from real servers
Date: Sun, 17 Oct 2010 16:24:37 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010171621090.20665@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


 	This patch is needed to avoid scheduling of
packets from local real server when we add ip_vs_in
in LOCAL_OUT hook to support local client.

 	Currently, when ip_vs_in can not find existing
connection it tries to create new one by calling ip_vs_schedule.

 	The default indication from ip_vs_schedule was if
connection was scheduled to real server. If real server is
not available we try to use the bypass forwarding method
or to send ICMP error. But in some cases we do not want to use
the bypass feature. So, add flag 'ignored' to indicate if
the scheduler ignores this packet.

 	Make sure we do not create new connections from replies.
We can hit this problem for persistent services and local real
server when ip_vs_in is added to LOCAL_OUT hook to handle
local clients.

 	Also, make sure ip_vs_schedule ignores SYN packets
for Active FTP DATA from local real server. The FTP DATA
connection should be created on SYN+ACK from client to assign
correct connection daddr.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp nf-next-2.6-a91fd26/linux/include/net/ip_vs.h linux/include/net/ip_vs.h
--- nf-next-2.6-a91fd26/linux/include/net/ip_vs.h	2010-10-16 19:33:26.905355251 +0300
+++ linux/include/net/ip_vs.h	2010-10-16 19:33:21.404355368 +0300
@@ -849,7 +849,8 @@ extern int ip_vs_unbind_scheduler(struct
  extern struct ip_vs_scheduler *ip_vs_scheduler_get(const char *sched_name);
  extern void ip_vs_scheduler_put(struct ip_vs_scheduler *scheduler);
  extern struct ip_vs_conn *
-ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb);
+ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
+	       struct ip_vs_protocol *pp, int *ignored);
  extern int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
  			struct ip_vs_protocol *pp);

diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_core.c linux/net/netfilter/ipvs/ip_vs_core.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_core.c	2010-10-16 15:13:35.796354309 +0300
+++ linux/net/netfilter/ipvs/ip_vs_core.c	2010-10-17 14:44:15.502374802 +0300
@@ -342,7 +342,8 @@ ip_vs_sched_persist(struct ip_vs_service
   *  Protocols supported: TCP, UDP
   */
  struct ip_vs_conn *
-ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb)
+ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
+	       struct ip_vs_protocol *pp, int *ignored)
  {
  	struct ip_vs_conn *cp = NULL;
  	struct ip_vs_iphdr iph;
@@ -350,16 +351,43 @@ ip_vs_schedule(struct ip_vs_service *svc
  	__be16 _ports[2], *pptr;
  	unsigned int flags;

+	*ignored = 1;
  	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
  	pptr = skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
  	if (pptr == NULL)
  		return NULL;

  	/*
+	 * FTPDATA needs this check when using local real server.
+	 * Never schedule Active FTPDATA connections from real server.
+	 * For LVS-NAT they must be already created. For other methods
+	 * with persistence the connection is created on SYN+ACK.
+	 */
+	if (pptr[0] == FTPDATA) {
+		IP_VS_DBG_PKT(12, pp, skb, 0, "Not scheduling FTPDATA");
+		return NULL;
+	}
+
+	/*
+	 * Do not schedule replies from local real server. It is risky
+	 * for fwmark services but mostly for persistent services.
+	 */
+	if ((!skb->dev || skb->dev->flags & IFF_LOOPBACK) &&
+	    (svc->flags & IP_VS_SVC_F_PERSISTENT || svc->fwmark) &&
+	    (cp = pp->conn_in_get(svc->af, skb, pp, &iph, iph.len, 1))) {
+		IP_VS_DBG_PKT(12, pp, skb, 0,
+			      "Not scheduling reply for existing connection");
+		__ip_vs_conn_put(cp);
+		return NULL;
+	}
+
+	/*
  	 *    Persistent service
  	 */
-	if (svc->flags & IP_VS_SVC_F_PERSISTENT)
+	if (svc->flags & IP_VS_SVC_F_PERSISTENT) {
+		*ignored = 0;
  		return ip_vs_sched_persist(svc, skb, pptr);
+	}

  	/*
  	 *    Non-persistent service
@@ -372,6 +400,8 @@ ip_vs_schedule(struct ip_vs_service *svc
  		return NULL;
  	}

+	*ignored = 0;
+
  	dest = svc->scheduler->schedule(svc, skb);
  	if (dest == NULL) {
  		IP_VS_DBG(1, "Schedule: no dest found.\n");
diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto_sctp.c linux/net/netfilter/ipvs/ip_vs_proto_sctp.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto_sctp.c	2010-10-13 22:22:35.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_proto_sctp.c	2010-10-16 15:14:05.631355648 +0300
@@ -31,6 +31,8 @@ sctp_conn_schedule(int af, struct sk_buf
  	if ((sch->type == SCTP_CID_INIT) &&
  	    (svc = ip_vs_service_get(af, skb->mark, iph.protocol,
  				     &iph.daddr, sh->dest))) {
+		int ignored;
+
  		if (ip_vs_todrop()) {
  			/*
  			 * It seems that we are very loaded.
@@ -44,8 +46,8 @@ sctp_conn_schedule(int af, struct sk_buf
  		 * Let the virtual server select a real server for the
  		 * incoming connection, and create a connection entry.
  		 */
-		*cpp = ip_vs_schedule(svc, skb);
-		if (!*cpp) {
+		*cpp = ip_vs_schedule(svc, skb, pp, &ignored);
+		if (!*cpp && !ignored) {
  			*verdict = ip_vs_leave(svc, skb, pp);
  			return 0;
  		}
diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto_tcp.c linux/net/netfilter/ipvs/ip_vs_proto_tcp.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto_tcp.c	2010-10-16 15:13:19.746354152 +0300
+++ linux/net/netfilter/ipvs/ip_vs_proto_tcp.c	2010-10-16 15:14:05.631355648 +0300
@@ -43,9 +43,12 @@ tcp_conn_schedule(int af, struct sk_buff
  		return 0;
  	}

+	/* No !th->ack check to allow scheduling on SYN+ACK for Active FTP */
  	if (th->syn &&
  	    (svc = ip_vs_service_get(af, skb->mark, iph.protocol, &iph.daddr,
  				     th->dest))) {
+		int ignored;
+
  		if (ip_vs_todrop()) {
  			/*
  			 * It seems that we are very loaded.
@@ -60,8 +63,8 @@ tcp_conn_schedule(int af, struct sk_buff
  		 * Let the virtual server select a real server for the
  		 * incoming connection, and create a connection entry.
  		 */
-		*cpp = ip_vs_schedule(svc, skb);
-		if (!*cpp) {
+		*cpp = ip_vs_schedule(svc, skb, pp, &ignored);
+		if (!*cpp && !ignored) {
  			*verdict = ip_vs_leave(svc, skb, pp);
  			return 0;
  		}
diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto_udp.c linux/net/netfilter/ipvs/ip_vs_proto_udp.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto_udp.c	2010-10-16 15:13:19.747354966 +0300
+++ linux/net/netfilter/ipvs/ip_vs_proto_udp.c	2010-10-16 15:14:05.632355394 +0300
@@ -46,6 +46,8 @@ udp_conn_schedule(int af, struct sk_buff
  	svc = ip_vs_service_get(af, skb->mark, iph.protocol,
  				&iph.daddr, uh->dest);
  	if (svc) {
+		int ignored;
+
  		if (ip_vs_todrop()) {
  			/*
  			 * It seems that we are very loaded.
@@ -60,8 +62,8 @@ udp_conn_schedule(int af, struct sk_buff
  		 * Let the virtual server select a real server for the
  		 * incoming connection, and create a connection entry.
  		 */
-		*cpp = ip_vs_schedule(svc, skb);
-		if (!*cpp) {
+		*cpp = ip_vs_schedule(svc, skb, pp, &ignored);
+		if (!*cpp && !ignored) {
  			*verdict = ip_vs_leave(svc, skb, pp);
  			return 0;
  		}
