From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/8] ipvs: sloppy TCP and SCTP
Date: Wed, 26 Jun 2013 18:11:24 +0900
Message-ID: <1372237890-28211-3-git-send-email-horms@verge.net.au>
References: <1372237890-28211-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1372237890-28211-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Alexander Frolkin <avf@eldamar.org.uk>, Simon Horman <horms@verge.net.au>

From: Alexander Frolkin <avf@eldamar.org.uk>

This adds support for sloppy TCP and SCTP modes to IPVS.

When enabled (sysctls net.ipv4.vs.sloppy_tcp and
net.ipv4.vs.sloppy_sctp), allows IPVS to create connection state on any
packet, not just a TCP SYN (or SCTP INIT).

This allows connections to fail over from one IPVS director to another
mid-flight.

Signed-off-by: Alexander Frolkin <avf@eldamar.org.uk>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h                   | 24 ++++++++++++++++++++++++
 net/netfilter/ipvs/ip_vs_ctl.c        | 14 ++++++++++++++
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 18 ++++++++++--------
 net/netfilter/ipvs/ip_vs_proto_tcp.c  | 14 ++++++++------
 4 files changed, 56 insertions(+), 14 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index f5faf85..95860df 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -978,6 +978,8 @@ struct netns_ipvs {
 	int			sysctl_sync_sock_size;
 	int			sysctl_cache_bypass;
 	int			sysctl_expire_nodest_conn;
+	int			sysctl_sloppy_tcp;
+	int			sysctl_sloppy_sctp;
 	int			sysctl_expire_quiescent_template;
 	int			sysctl_sync_threshold[2];
 	unsigned int		sysctl_sync_refresh_period;
@@ -1020,6 +1022,8 @@ struct netns_ipvs {
 #define DEFAULT_SYNC_THRESHOLD	3
 #define DEFAULT_SYNC_PERIOD	50
 #define DEFAULT_SYNC_VER	1
+#define DEFAULT_SLOPPY_TCP	0
+#define DEFAULT_SLOPPY_SCTP	0
 #define DEFAULT_SYNC_REFRESH_PERIOD	(0U * HZ)
 #define DEFAULT_SYNC_RETRIES		0
 #define IPVS_SYNC_WAKEUP_RATE	8
@@ -1056,6 +1060,16 @@ static inline int sysctl_sync_ver(struct netns_ipvs *ipvs)
 	return ipvs->sysctl_sync_ver;
 }
 
+static inline int sysctl_sloppy_tcp(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_sloppy_tcp;
+}
+
+static inline int sysctl_sloppy_sctp(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_sloppy_sctp;
+}
+
 static inline int sysctl_sync_ports(struct netns_ipvs *ipvs)
 {
 	return ACCESS_ONCE(ipvs->sysctl_sync_ports);
@@ -1109,6 +1123,16 @@ static inline int sysctl_sync_ver(struct netns_ipvs *ipvs)
 	return DEFAULT_SYNC_VER;
 }
 
+static inline int sysctl_sloppy_tcp(struct netns_ipvs *ipvs)
+{
+	return DEFAULT_SLOPPY_TCP;
+}
+
+static inline int sysctl_sloppy_sctp(struct netns_ipvs *ipvs)
+{
+	return DEFAULT_SLOPPY_SCTP;
+}
+
 static inline int sysctl_sync_ports(struct netns_ipvs *ipvs)
 {
 	return 1;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 47e5108..da035fc 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1739,6 +1739,18 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "sloppy_tcp",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "sloppy_sctp",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "expire_quiescent_template",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
@@ -3723,6 +3735,8 @@ static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	tbl[idx++].data = &ipvs->sysctl_sync_sock_size;
 	tbl[idx++].data = &ipvs->sysctl_cache_bypass;
 	tbl[idx++].data = &ipvs->sysctl_expire_nodest_conn;
+	tbl[idx++].data = &ipvs->sysctl_sloppy_tcp;
+	tbl[idx++].data = &ipvs->sysctl_sloppy_sctp;
 	tbl[idx++].data = &ipvs->sysctl_expire_quiescent_template;
 	ipvs->sysctl_sync_threshold[0] = DEFAULT_SYNC_THRESHOLD;
 	ipvs->sysctl_sync_threshold[1] = DEFAULT_SYNC_PERIOD;
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 8646488..df29d64 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -15,6 +15,7 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 {
 	struct net *net;
 	struct ip_vs_service *svc;
+	struct netns_ipvs *ipvs;
 	sctp_chunkhdr_t _schunkh, *sch;
 	sctp_sctphdr_t *sh, _sctph;
 
@@ -27,13 +28,14 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	if (sch == NULL)
 		return 0;
 	net = skb_net(skb);
+	ipvs = net_ipvs(net);
 	rcu_read_lock();
-	if ((sch->type == SCTP_CID_INIT) &&
+	if ((sch->type == SCTP_CID_INIT || sysctl_sloppy_sctp(ipvs)) &&
 	    (svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
 				      &iph->daddr, sh->dest))) {
 		int ignored;
 
-		if (ip_vs_todrop(net_ipvs(net))) {
+		if (ip_vs_todrop(ipvs)) {
 			/*
 			 * It seems that we are very loaded.
 			 * We have to drop this packet :(
@@ -232,21 +234,21 @@ static struct ipvs_sctp_nextstate
 	 * STATE : IP_VS_SCTP_S_NONE
 	 */
 	/*next state *//*event */
-	{{IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_CLI */ },
+	{{IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_DATA_CLI */ },
 	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_SER */ },
 	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
 	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
-	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
+	 {IP_VS_SCTP_S_INIT_ACK_CLI /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
 	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
-	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
+	 {IP_VS_SCTP_S_ECHO_CLI /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
 	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
-	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
+	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
 	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
 	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
 	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
-	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_CLI */ },
+	 {IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_SHUT_CLI */ },
 	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_SER */ },
-	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
+	 {IP_VS_SCTP_S_SHUT_ACK_CLI /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
 	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
 	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
 	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ },
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 50a1594..e3a6972 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -39,6 +39,7 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	struct net *net;
 	struct ip_vs_service *svc;
 	struct tcphdr _tcph, *th;
+	struct netns_ipvs *ipvs;
 
 	th = skb_header_pointer(skb, iph->len, sizeof(_tcph), &_tcph);
 	if (th == NULL) {
@@ -46,14 +47,15 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		return 0;
 	}
 	net = skb_net(skb);
+	ipvs = net_ipvs(net);
 	/* No !th->ack check to allow scheduling on SYN+ACK for Active FTP */
 	rcu_read_lock();
-	if (th->syn &&
+	if ((th->syn || sysctl_sloppy_tcp(ipvs)) && !th->rst &&
 	    (svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
 				      &iph->daddr, th->dest))) {
 		int ignored;
 
-		if (ip_vs_todrop(net_ipvs(net))) {
+		if (ip_vs_todrop(ipvs)) {
 			/*
 			 * It seems that we are very loaded.
 			 * We have to drop this packet :(
@@ -401,7 +403,7 @@ static struct tcp_states_t tcp_states [] = {
 /*        sNO, sES, sSS, sSR, sFW, sTW, sCL, sCW, sLA, sLI, sSA	*/
 /*syn*/ {{sSR, sES, sES, sSR, sSR, sSR, sSR, sSR, sSR, sSR, sSR }},
 /*fin*/ {{sCL, sCW, sSS, sTW, sTW, sTW, sCL, sCW, sLA, sLI, sTW }},
-/*ack*/ {{sCL, sES, sSS, sES, sFW, sTW, sCL, sCW, sCL, sLI, sES }},
+/*ack*/ {{sES, sES, sSS, sES, sFW, sTW, sCL, sCW, sCL, sLI, sES }},
 /*rst*/ {{sCL, sCL, sCL, sSR, sCL, sCL, sCL, sCL, sLA, sLI, sSR }},
 
 /*	OUTPUT */
@@ -415,7 +417,7 @@ static struct tcp_states_t tcp_states [] = {
 /*        sNO, sES, sSS, sSR, sFW, sTW, sCL, sCW, sLA, sLI, sSA	*/
 /*syn*/ {{sSR, sES, sES, sSR, sSR, sSR, sSR, sSR, sSR, sSR, sSR }},
 /*fin*/ {{sCL, sFW, sSS, sTW, sFW, sTW, sCL, sCW, sLA, sLI, sTW }},
-/*ack*/ {{sCL, sES, sSS, sES, sFW, sTW, sCL, sCW, sCL, sLI, sES }},
+/*ack*/ {{sES, sES, sSS, sES, sFW, sTW, sCL, sCW, sCL, sLI, sES }},
 /*rst*/ {{sCL, sCL, sCL, sSR, sCL, sCL, sCL, sCL, sLA, sLI, sCL }},
 };
 
@@ -424,7 +426,7 @@ static struct tcp_states_t tcp_states_dos [] = {
 /*        sNO, sES, sSS, sSR, sFW, sTW, sCL, sCW, sLA, sLI, sSA	*/
 /*syn*/ {{sSR, sES, sES, sSR, sSR, sSR, sSR, sSR, sSR, sSR, sSA }},
 /*fin*/ {{sCL, sCW, sSS, sTW, sTW, sTW, sCL, sCW, sLA, sLI, sSA }},
-/*ack*/ {{sCL, sES, sSS, sSR, sFW, sTW, sCL, sCW, sCL, sLI, sSA }},
+/*ack*/ {{sES, sES, sSS, sSR, sFW, sTW, sCL, sCW, sCL, sLI, sSA }},
 /*rst*/ {{sCL, sCL, sCL, sSR, sCL, sCL, sCL, sCL, sLA, sLI, sCL }},
 
 /*	OUTPUT */
@@ -438,7 +440,7 @@ static struct tcp_states_t tcp_states_dos [] = {
 /*        sNO, sES, sSS, sSR, sFW, sTW, sCL, sCW, sLA, sLI, sSA	*/
 /*syn*/ {{sSA, sES, sES, sSR, sSA, sSA, sSA, sSA, sSA, sSA, sSA }},
 /*fin*/ {{sCL, sFW, sSS, sTW, sFW, sTW, sCL, sCW, sLA, sLI, sTW }},
-/*ack*/ {{sCL, sES, sSS, sES, sFW, sTW, sCL, sCW, sCL, sLI, sES }},
+/*ack*/ {{sES, sES, sSS, sES, sFW, sTW, sCL, sCW, sCL, sLI, sES }},
 /*rst*/ {{sCL, sCL, sCL, sSR, sCL, sCL, sCL, sCL, sLA, sLI, sCL }},
 };
 
-- 
1.8.2.1
