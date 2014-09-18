From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 14/15] ipvs: use the new dest addr family field
Date: Thu, 18 Sep 2014 09:26:00 +0900
Message-ID: <1410999961-7975-15-git-send-email-horms@verge.net.au>
References: <1410999961-7975-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1410999961-7975-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Alex Gartrell <agartrell@fb.com>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

Use the new address family field cp->daf when printing
cp->daddr in logs or connection listing.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Alex Gartrell <agartrell@fb.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c       | 49 +++++++++++++++++++++++++++--------
 net/netfilter/ipvs/ip_vs_core.c       |  6 ++---
 net/netfilter/ipvs/ip_vs_proto_sctp.c |  2 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |  2 +-
 4 files changed, 43 insertions(+), 16 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 13e9cee..b0f7b62 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -27,6 +27,7 @@
 
 #include <linux/interrupt.h>
 #include <linux/in.h>
+#include <linux/inet.h>
 #include <linux/net.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
@@ -77,6 +78,13 @@ static unsigned int ip_vs_conn_rnd __read_mostly;
 #define CT_LOCKARRAY_SIZE  (1<<CT_LOCKARRAY_BITS)
 #define CT_LOCKARRAY_MASK  (CT_LOCKARRAY_SIZE-1)
 
+/* We need an addrstrlen that works with or without v6 */
+#ifdef CONFIG_IP_VS_IPV6
+#define IP_VS_ADDRSTRLEN INET6_ADDRSTRLEN
+#else
+#define IP_VS_ADDRSTRLEN (8+1)
+#endif
+
 struct ip_vs_aligned_lock
 {
 	spinlock_t	l;
@@ -588,7 +596,7 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 		      ip_vs_proto_name(cp->protocol),
 		      IP_VS_DBG_ADDR(cp->af, &cp->caddr), ntohs(cp->cport),
 		      IP_VS_DBG_ADDR(cp->af, &cp->vaddr), ntohs(cp->vport),
-		      IP_VS_DBG_ADDR(cp->af, &cp->daddr), ntohs(cp->dport),
+		      IP_VS_DBG_ADDR(cp->daf, &cp->daddr), ntohs(cp->dport),
 		      ip_vs_fwd_tag(cp), cp->state,
 		      cp->flags, atomic_read(&cp->refcnt),
 		      atomic_read(&dest->refcnt));
@@ -685,7 +693,7 @@ static inline void ip_vs_unbind_dest(struct ip_vs_conn *cp)
 		      ip_vs_proto_name(cp->protocol),
 		      IP_VS_DBG_ADDR(cp->af, &cp->caddr), ntohs(cp->cport),
 		      IP_VS_DBG_ADDR(cp->af, &cp->vaddr), ntohs(cp->vport),
-		      IP_VS_DBG_ADDR(cp->af, &cp->daddr), ntohs(cp->dport),
+		      IP_VS_DBG_ADDR(cp->daf, &cp->daddr), ntohs(cp->dport),
 		      ip_vs_fwd_tag(cp), cp->state,
 		      cp->flags, atomic_read(&cp->refcnt),
 		      atomic_read(&dest->refcnt));
@@ -754,7 +762,7 @@ int ip_vs_check_template(struct ip_vs_conn *ct)
 			      ntohs(ct->cport),
 			      IP_VS_DBG_ADDR(ct->af, &ct->vaddr),
 			      ntohs(ct->vport),
-			      IP_VS_DBG_ADDR(ct->af, &ct->daddr),
+			      IP_VS_DBG_ADDR(ct->daf, &ct->daddr),
 			      ntohs(ct->dport));
 
 		/*
@@ -1051,6 +1059,7 @@ static int ip_vs_conn_seq_show(struct seq_file *seq, void *v)
 		struct net *net = seq_file_net(seq);
 		char pe_data[IP_VS_PENAME_MAXLEN + IP_VS_PEDATA_MAXLEN + 3];
 		size_t len = 0;
+		char dbuf[IP_VS_ADDRSTRLEN];
 
 		if (!ip_vs_conn_net_eq(cp, net))
 			return 0;
@@ -1065,24 +1074,32 @@ static int ip_vs_conn_seq_show(struct seq_file *seq, void *v)
 		pe_data[len] = '\0';
 
 #ifdef CONFIG_IP_VS_IPV6
+		if (cp->daf == AF_INET6)
+			snprintf(dbuf, sizeof(dbuf), "%pI6", &cp->daddr.in6);
+		else
+#endif
+			snprintf(dbuf, sizeof(dbuf), "%08X",
+				 ntohl(cp->daddr.ip));
+
+#ifdef CONFIG_IP_VS_IPV6
 		if (cp->af == AF_INET6)
 			seq_printf(seq, "%-3s %pI6 %04X %pI6 %04X "
-				"%pI6 %04X %-11s %7lu%s\n",
+				"%s %04X %-11s %7lu%s\n",
 				ip_vs_proto_name(cp->protocol),
 				&cp->caddr.in6, ntohs(cp->cport),
 				&cp->vaddr.in6, ntohs(cp->vport),
-				&cp->daddr.in6, ntohs(cp->dport),
+				dbuf, ntohs(cp->dport),
 				ip_vs_state_name(cp->protocol, cp->state),
 				(cp->timer.expires-jiffies)/HZ, pe_data);
 		else
 #endif
 			seq_printf(seq,
 				"%-3s %08X %04X %08X %04X"
-				" %08X %04X %-11s %7lu%s\n",
+				" %s %04X %-11s %7lu%s\n",
 				ip_vs_proto_name(cp->protocol),
 				ntohl(cp->caddr.ip), ntohs(cp->cport),
 				ntohl(cp->vaddr.ip), ntohs(cp->vport),
-				ntohl(cp->daddr.ip), ntohs(cp->dport),
+				dbuf, ntohs(cp->dport),
 				ip_vs_state_name(cp->protocol, cp->state),
 				(cp->timer.expires-jiffies)/HZ, pe_data);
 	}
@@ -1120,6 +1137,7 @@ static const char *ip_vs_origin_name(unsigned int flags)
 
 static int ip_vs_conn_sync_seq_show(struct seq_file *seq, void *v)
 {
+	char dbuf[IP_VS_ADDRSTRLEN];
 
 	if (v == SEQ_START_TOKEN)
 		seq_puts(seq,
@@ -1132,12 +1150,21 @@ static int ip_vs_conn_sync_seq_show(struct seq_file *seq, void *v)
 			return 0;
 
 #ifdef CONFIG_IP_VS_IPV6
+		if (cp->daf == AF_INET6)
+			snprintf(dbuf, sizeof(dbuf), "%pI6", &cp->daddr.in6);
+		else
+#endif
+			snprintf(dbuf, sizeof(dbuf), "%08X",
+				 ntohl(cp->daddr.ip));
+
+#ifdef CONFIG_IP_VS_IPV6
 		if (cp->af == AF_INET6)
-			seq_printf(seq, "%-3s %pI6 %04X %pI6 %04X %pI6 %04X %-11s %-6s %7lu\n",
+			seq_printf(seq, "%-3s %pI6 %04X %pI6 %04X "
+				"%s %04X %-11s %-6s %7lu\n",
 				ip_vs_proto_name(cp->protocol),
 				&cp->caddr.in6, ntohs(cp->cport),
 				&cp->vaddr.in6, ntohs(cp->vport),
-				&cp->daddr.in6, ntohs(cp->dport),
+				dbuf, ntohs(cp->dport),
 				ip_vs_state_name(cp->protocol, cp->state),
 				ip_vs_origin_name(cp->flags),
 				(cp->timer.expires-jiffies)/HZ);
@@ -1145,11 +1172,11 @@ static int ip_vs_conn_sync_seq_show(struct seq_file *seq, void *v)
 #endif
 			seq_printf(seq,
 				"%-3s %08X %04X %08X %04X "
-				"%08X %04X %-11s %-6s %7lu\n",
+				"%s %04X %-11s %-6s %7lu\n",
 				ip_vs_proto_name(cp->protocol),
 				ntohl(cp->caddr.ip), ntohs(cp->cport),
 				ntohl(cp->vaddr.ip), ntohs(cp->vport),
-				ntohl(cp->daddr.ip), ntohs(cp->dport),
+				dbuf, ntohs(cp->dport),
 				ip_vs_state_name(cp->protocol, cp->state),
 				ip_vs_origin_name(cp->flags),
 				(cp->timer.expires-jiffies)/HZ);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 1f6ecb7..990decb 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -492,9 +492,9 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	IP_VS_DBG_BUF(6, "Schedule fwd:%c c:%s:%u v:%s:%u "
 		      "d:%s:%u conn->flags:%X conn->refcnt:%d\n",
 		      ip_vs_fwd_tag(cp),
-		      IP_VS_DBG_ADDR(svc->af, &cp->caddr), ntohs(cp->cport),
-		      IP_VS_DBG_ADDR(svc->af, &cp->vaddr), ntohs(cp->vport),
-		      IP_VS_DBG_ADDR(svc->af, &cp->daddr), ntohs(cp->dport),
+		      IP_VS_DBG_ADDR(cp->af, &cp->caddr), ntohs(cp->cport),
+		      IP_VS_DBG_ADDR(cp->af, &cp->vaddr), ntohs(cp->vport),
+		      IP_VS_DBG_ADDR(cp->daf, &cp->daddr), ntohs(cp->dport),
 		      cp->flags, atomic_read(&cp->refcnt));
 
 	ip_vs_conn_stats(cp, svc);
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 2f7ea75..5b84c0b 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -432,7 +432,7 @@ set_sctp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 				pd->pp->name,
 				((direction == IP_VS_DIR_OUTPUT) ?
 				 "output " : "input "),
-				IP_VS_DBG_ADDR(cp->af, &cp->daddr),
+				IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
 				ntohs(cp->dport),
 				IP_VS_DBG_ADDR(cp->af, &cp->caddr),
 				ntohs(cp->cport),
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index e3a6972..8e92beb 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -510,7 +510,7 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 			      th->fin ? 'F' : '.',
 			      th->ack ? 'A' : '.',
 			      th->rst ? 'R' : '.',
-			      IP_VS_DBG_ADDR(cp->af, &cp->daddr),
+			      IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
 			      ntohs(cp->dport),
 			      IP_VS_DBG_ADDR(cp->af, &cp->caddr),
 			      ntohs(cp->cport),
-- 
2.0.1

