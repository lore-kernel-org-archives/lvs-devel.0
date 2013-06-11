From: Alexander Frolkin <avf@eldamar.org.uk>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Tue, 11 Jun 2013 13:38:24 +0100
Message-ID: <20130611123824.GC25531@eldamar.org.uk>
References: <20130524120935.GL264@eldamar.org.uk>
 <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg>
 <20130524151408.GM264@eldamar.org.uk>
 <alpine.LFD.2.00.1305272251170.1728@ja.ssi.bg>
 <20130610151257.GB19108@eldamar.org.uk>
 <alpine.LFD.2.00.1306102247410.1972@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1306102247410.1972@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hi,

> 	When you post the patch inline I'll comment
> about some styling problems.

Updated patch, including your changes from the last email:

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 4405886..22bea5d 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1002,6 +1002,8 @@ struct netns_ipvs {
 	int			sysctl_sync_sock_size;
 	int			sysctl_cache_bypass;
 	int			sysctl_expire_nodest_conn;
+	int			sysctl_sloppy_tcp;
+	int			sysctl_sloppy_sctp;
 	int			sysctl_expire_quiescent_template;
 	int			sysctl_sync_threshold[2];
 	unsigned int		sysctl_sync_refresh_period;
@@ -1044,6 +1046,8 @@ struct netns_ipvs {
 #define DEFAULT_SYNC_THRESHOLD	3
 #define DEFAULT_SYNC_PERIOD	50
 #define DEFAULT_SYNC_VER	1
+#define DEFAULT_SLOPPY_TCP	0
+#define DEFAULT_SLOPPY_SCTP	0
 #define DEFAULT_SYNC_REFRESH_PERIOD	(0U * HZ)
 #define DEFAULT_SYNC_RETRIES		0
 #define IPVS_SYNC_WAKEUP_RATE	8
@@ -1080,6 +1084,16 @@ static inline int sysctl_sync_ver(struct netns_ipvs *ipvs)
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
@@ -1133,6 +1147,16 @@ static inline int sysctl_sync_ver(struct netns_ipvs *ipvs)
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
index 7014649..04f8cbc 100644
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
@@ -3722,6 +3734,8 @@ static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	tbl[idx++].data = &ipvs->sysctl_sync_sock_size;
 	tbl[idx++].data = &ipvs->sysctl_cache_bypass;
 	tbl[idx++].data = &ipvs->sysctl_expire_nodest_conn;
+	tbl[idx++].data = &ipvs->sysctl_sloppy_tcp;
+	tbl[idx++].data = &ipvs->sysctl_sloppy_sctp;
 	tbl[idx++].data = &ipvs->sysctl_expire_quiescent_template;
 	ipvs->sysctl_sync_threshold[0] = DEFAULT_SYNC_THRESHOLD;
 	ipvs->sysctl_sync_threshold[1] = DEFAULT_SYNC_PERIOD;
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 8646488..9b1867b 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -15,6 +15,7 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 {
 	struct net *net;
 	struct ip_vs_service *svc;
+	struct netns_ipvs *ipvs;
 	sctp_chunkhdr_t _schunkh, *sch;
 	sctp_sctphdr_t *sh, _sctph;
 
@@ -27,13 +28,15 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	if (sch == NULL)
 		return 0;
 	net = skb_net(skb);
+	ipvs = net_ipvs(net);
 	rcu_read_lock();
-	if ((sch->type == SCTP_CID_INIT) &&
+	if ((sysctl_sloppy_sctp(ipvs) ||
+	    (sch->type == SCTP_CID_INIT)) &&
 	    (svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
 				      &iph->daddr, sh->dest))) {
 		int ignored;
 
-		if (ip_vs_todrop(net_ipvs(net))) {
+		if (ip_vs_todrop(ipvs)) {
 			/*
 			 * It seems that we are very loaded.
 			 * We have to drop this packet :(
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 50a1594..3fd23fa 100644
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
+	if ((sysctl_sloppy_tcp(ipvs) || th->syn) && !th->rst &&
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
 
I haven't touched the SCTP state tables yet.


Alex

