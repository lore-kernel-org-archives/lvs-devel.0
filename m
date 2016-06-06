From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] ipvs: update real-server binding of outgoing connections in SIP-pe
Date: Mon,  6 Jun 2016 18:24:37 +0900
Message-ID: <1465205077-15139-2-git-send-email-horms@verge.net.au>
References: <1465205077-15139-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1465205081; bh=AITTPCyuYWQXP41i7hQgr08qdqRmkxlaNeQ/iZOoC5g=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=JreDh5QeJ7Vw7873tbEq6VrrbKTYjcMXmm3b1t+hTWVpKitwdUW8oGdgfGidKDXz7
	 FXuay/j8joDa5kJZ2icWTvZAzZ5zdpN4rW7l56xdf0TNkDicJ2RTO1MByb3GiCb41r
	 RM0f96opchPdV8LNx0nxYio5d120UfWTEzsTDI9I=
In-Reply-To: <1465205077-15139-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Marco Angaroni <marcoangaroni@gmail.com>, Simon Horman <horms@verge.net.au>

From: Marco Angaroni <marcoangaroni@gmail.com>

Previous patch that introduced handling of outgoing packets in SIP
persistent-engine did not call ip_vs_check_template() in case packet was
matching a connection template. Assumption was that real-server was
healthy, since it was sending a packet just in that moment.

There are however real-server fault conditions requiring that association
between call-id and real-server (represented by connection template)
gets updated. Here is an example of the sequence of events:
  1) RS1 is a back2back user agent that handled call-id1 and call-id2
  2) RS1 is down and was marked as unavailable
  3) new message from outside comes to IPVS with call-id1
  4) IPVS reschedules the message to RS2, which becomes new call handler
  5) RS2 forwards the message outside, translating call-id1 to call-id2
  6) inside pe->conn_out() IPVS matches call-id2 with existing template
  7) IPVS does not change association call-id2 <-> RS1
  8) new message comes from client with call-id2
  9) IPVS reschedules the message to a real-server potentially different
     from RS2, which is now the correct destination

This patch introduces ip_vs_check_template() call in the handling of
outgoing packets for SIP-pe. And also introduces a second optional
argument for ip_vs_check_template() that allows to check if dest
associated to a connection template is the same dest that was identified
as the source of the packet. This is to change the real-server bound to a
particular call-id independently from its availability status: the idea
is that it's more reliable, for in->out direction (where internal
network can be considered trusted), to always associate a call-id with
the last real-server that used it in one of its messages. Think about
above sequence of events where, just after step 5, RS1 returns instead
to be available.

Comparison of dests is done by simply comparing pointers to struct
ip_vs_dest; there should be no cases where struct ip_vs_dest keeps its
memory address, but represent a different real-server in terms of
ip-address / port.

Fixes: 39b972231536 ("ipvs: handle connections started by real-servers")
Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             | 2 +-
 net/netfilter/ipvs/ip_vs_conn.c | 5 +++--
 net/netfilter/ipvs/ip_vs_core.c | 5 +++--
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index af4c10ebb241..cd6018a9ee24 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1232,7 +1232,7 @@ void ip_vs_conn_expire_now(struct ip_vs_conn *cp);
 const char *ip_vs_state_name(__u16 proto, int state);
 
 void ip_vs_tcp_conn_listen(struct ip_vs_conn *cp);
-int ip_vs_check_template(struct ip_vs_conn *ct);
+int ip_vs_check_template(struct ip_vs_conn *ct, struct ip_vs_dest *cdest);
 void ip_vs_random_dropentry(struct netns_ipvs *ipvs);
 int ip_vs_conn_init(void);
 void ip_vs_conn_cleanup(void);
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 2cb3c626cd43..096a45103f14 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -762,7 +762,7 @@ static int expire_quiescent_template(struct netns_ipvs *ipvs,
  *	If available, return 1, otherwise invalidate this connection
  *	template and return 0.
  */
-int ip_vs_check_template(struct ip_vs_conn *ct)
+int ip_vs_check_template(struct ip_vs_conn *ct, struct ip_vs_dest *cdest)
 {
 	struct ip_vs_dest *dest = ct->dest;
 	struct netns_ipvs *ipvs = ct->ipvs;
@@ -772,7 +772,8 @@ int ip_vs_check_template(struct ip_vs_conn *ct)
 	 */
 	if ((dest == NULL) ||
 	    !(dest->flags & IP_VS_DEST_F_AVAILABLE) ||
-	    expire_quiescent_template(ipvs, dest)) {
+	    expire_quiescent_template(ipvs, dest) ||
+	    (cdest && (dest != cdest))) {
 		IP_VS_DBG_BUF(9, "check_template: dest not available for "
 			      "protocol %s s:%s:%d v:%s:%d "
 			      "-> d:%s:%d\n",
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 1207f20d24e4..2c1b498a7a27 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -321,7 +321,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 
 	/* Check if a template already exists */
 	ct = ip_vs_ct_in_get(&param);
-	if (!ct || !ip_vs_check_template(ct)) {
+	if (!ct || !ip_vs_check_template(ct, NULL)) {
 		struct ip_vs_scheduler *sched;
 
 		/*
@@ -1154,7 +1154,8 @@ struct ip_vs_conn *ip_vs_new_conn_out(struct ip_vs_service *svc,
 						  vport, &param) < 0)
 			return NULL;
 		ct = ip_vs_ct_in_get(&param);
-		if (!ct) {
+		/* check if template exists and points to the same dest */
+		if (!ct || !ip_vs_check_template(ct, dest)) {
 			ct = ip_vs_conn_new(&param, dest->af, daddr, dport,
 					    IP_VS_CONN_F_TEMPLATE, dest, 0);
 			if (!ct) {
-- 
2.1.4

