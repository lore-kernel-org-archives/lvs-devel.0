From: Simon Horman <horms@verge.net.au>
Subject: [patch v2.2 3/4] [PATCH v2.1 3/4] IPVS: make FTP work with full NAT support
Date: Sat, 01 May 2010 13:20:17 +1000
Message-ID: <20100501032120.998807955@vergenet.net>
References: <20100501032014.406353538@vergenet.net>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline; filename=3.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julius Volz <julius.volz@gmail.com>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, Hannes Eder <heder@google.com>

From:	Hannes Eder <heder@google.com>

Use nf_conntrack/nf_nat code to do the packet mangling and the TCP
sequence adjusting.  The function 'ip_vs_skb_replace' is now dead
code, so it is removed.

To SNAT FTP, use something like:

% iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32 \
> --vport 21 -j SNAT --to-source 192.168.10.10

and for the data connections in passive mode:

% iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32 \
> --vportctl 21 -j SNAT --to-source 192.168.10.10

using '-m state --state RELATED' would also works.

Make sure the kernel modules ip_vs_ftp, nf_conntrack_ftp, and
nf_nat_ftp are loaded.

[ trivial up-port by Simon Horman <horms@verge.net.au> ]
Signed-off-by: Hannes Eder <heder@google.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

--- 

 include/net/ip_vs.h             |    2 
 net/netfilter/ipvs/Kconfig      |    2 
 net/netfilter/ipvs/ip_vs_app.c  |   43 ---------
 net/netfilter/ipvs/ip_vs_core.c |    1 
 net/netfilter/ipvs/ip_vs_ftp.c  |  178 ++++++++++++++++++++++++++++++++++++---
 5 files changed, 164 insertions(+), 62 deletions(-)


Index: nf-next-2.6/include/net/ip_vs.h
===================================================================
--- nf-next-2.6.orig/include/net/ip_vs.h	2010-04-29 20:11:51.000000000 +0900
+++ nf-next-2.6/include/net/ip_vs.h	2010-04-29 20:12:03.000000000 +0900
@@ -716,8 +716,6 @@ extern void ip_vs_app_inc_put(struct ip_
 
 extern int ip_vs_app_pkt_out(struct ip_vs_conn *, struct sk_buff *skb);
 extern int ip_vs_app_pkt_in(struct ip_vs_conn *, struct sk_buff *skb);
-extern int ip_vs_skb_replace(struct sk_buff *skb, gfp_t pri,
-			     char *o_buf, int o_len, char *n_buf, int n_len);
 extern int ip_vs_app_init(void);
 extern void ip_vs_app_cleanup(void);
 
Index: nf-next-2.6/net/netfilter/ipvs/Kconfig
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/Kconfig	2010-04-29 20:11:59.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/Kconfig	2010-04-29 20:12:03.000000000 +0900
@@ -231,7 +231,7 @@ comment 'IPVS application helper'
 
 config	IP_VS_FTP
   	tristate "FTP protocol helper"
-        depends on IP_VS_PROTO_TCP
+        depends on IP_VS_PROTO_TCP && NF_NAT
 	---help---
 	  FTP is a protocol that transfers IP address and/or port number in
 	  the payload. In the virtual server via Network Address Translation,
Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_app.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_app.c	2010-04-29 20:11:51.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_app.c	2010-04-29 20:12:03.000000000 +0900
@@ -568,49 +568,6 @@ static const struct file_operations ip_v
 };
 #endif
 
-
-/*
- *	Replace a segment of data with a new segment
- */
-int ip_vs_skb_replace(struct sk_buff *skb, gfp_t pri,
-		      char *o_buf, int o_len, char *n_buf, int n_len)
-{
-	int diff;
-	int o_offset;
-	int o_left;
-
-	EnterFunction(9);
-
-	diff = n_len - o_len;
-	o_offset = o_buf - (char *)skb->data;
-	/* The length of left data after o_buf+o_len in the skb data */
-	o_left = skb->len - (o_offset + o_len);
-
-	if (diff <= 0) {
-		memmove(o_buf + n_len, o_buf + o_len, o_left);
-		memcpy(o_buf, n_buf, n_len);
-		skb_trim(skb, skb->len + diff);
-	} else if (diff <= skb_tailroom(skb)) {
-		skb_put(skb, diff);
-		memmove(o_buf + n_len, o_buf + o_len, o_left);
-		memcpy(o_buf, n_buf, n_len);
-	} else {
-		if (pskb_expand_head(skb, skb_headroom(skb), diff, pri))
-			return -ENOMEM;
-		skb_put(skb, diff);
-		memmove(skb->data + o_offset + n_len,
-			skb->data + o_offset + o_len, o_left);
-		skb_copy_to_linear_data_offset(skb, o_offset, n_buf, n_len);
-	}
-
-	/* must update the iph total length here */
-	ip_hdr(skb)->tot_len = htons(skb->len);
-
-	LeaveFunction(9);
-	return 0;
-}
-
-
 int __init ip_vs_app_init(void)
 {
 	/* we will replace it with proc_net_ipvs_create() soon */
Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_core.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_core.c	2010-04-29 20:11:59.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_core.c	2010-04-29 20:12:03.000000000 +0900
@@ -52,7 +52,6 @@
 
 EXPORT_SYMBOL(register_ip_vs_scheduler);
 EXPORT_SYMBOL(unregister_ip_vs_scheduler);
-EXPORT_SYMBOL(ip_vs_skb_replace);
 EXPORT_SYMBOL(ip_vs_proto_name);
 EXPORT_SYMBOL(ip_vs_conn_new);
 EXPORT_SYMBOL(ip_vs_conn_in_get);
Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_ftp.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_ftp.c	2010-04-29 20:11:51.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_ftp.c	2010-04-29 20:12:03.000000000 +0900
@@ -20,6 +20,17 @@
  *
  * Author:	Wouter Gadeyne
  *
+ *
+ * Code for ip_vs_expect_related and ip_vs_expect_callback is taken from
+ * http://www.ssi.bg/~ja/nfct/:
+ *
+ * ip_vs_nfct.c:	Netfilter connection tracking support for IPVS
+ *
+ * Portions Copyright (C) 2001-2002
+ * Antefacto Ltd, 181 Parnell St, Dublin 1, Ireland.
+ *
+ * Portions Copyright (C) 2003-2008
+ * Julian Anastasov
  */
 
 #define KMSG_COMPONENT "IPVS"
@@ -32,6 +43,9 @@
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/netfilter.h>
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_expect.h>
+#include <net/netfilter/nf_nat_helper.h>
 #include <net/protocol.h>
 #include <net/tcp.h>
 #include <asm/unaligned.h>
@@ -42,6 +56,16 @@
 #define SERVER_STRING "227 Entering Passive Mode ("
 #define CLIENT_STRING "PORT "
 
+#define FMT_TUPLE	"%u.%u.%u.%u:%u->%u.%u.%u.%u:%u/%u"
+#define ARG_TUPLE(T)	NIPQUAD((T)->src.u3.ip), ntohs((T)->src.u.all), \
+			NIPQUAD((T)->dst.u3.ip), ntohs((T)->dst.u.all), \
+			(T)->dst.protonum
+
+#define FMT_CONN	"%u.%u.%u.%u:%u->%u.%u.%u.%u:%u->%u.%u.%u.%u:%u/%u:%u"
+#define ARG_CONN(C)	NIPQUAD((C)->caddr), ntohs((C)->cport), \
+			NIPQUAD((C)->vaddr), ntohs((C)->vport), \
+			NIPQUAD((C)->daddr), ntohs((C)->dport), \
+			(C)->protocol, (C)->state
 
 /*
  * List of ports (up to IP_VS_APP_MAX_PORTS) to be handled by helper
@@ -122,6 +146,119 @@ static int ip_vs_ftp_get_addrport(char *
 	return 1;
 }
 
+/*
+ * Called from init_conntrack() as expectfn handler.
+ */
+static void
+ip_vs_expect_callback(struct nf_conn *ct,
+		      struct nf_conntrack_expect *exp)
+{
+	struct nf_conntrack_tuple *orig, new_reply;
+	struct ip_vs_conn *cp;
+
+	if (exp->tuple.src.l3num != PF_INET)
+		return;
+
+	/*
+	 * We assume that no NF locks are held before this callback.
+	 * ip_vs_conn_out_get and ip_vs_conn_in_get should match their
+	 * expectations even if they use wildcard values, now we provide the
+	 * actual values from the newly created original conntrack direction.
+	 * The conntrack is confirmed when packet reaches IPVS hooks.
+	 */
+
+	/* RS->CLIENT */
+	orig = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
+	cp = ip_vs_conn_out_get(exp->tuple.src.l3num, orig->dst.protonum,
+				&orig->src.u3, orig->src.u.tcp.port,
+				&orig->dst.u3, orig->dst.u.tcp.port);
+	if (cp) {
+		/* Change reply CLIENT->RS to CLIENT->VS */
+		new_reply = ct->tuplehash[IP_CT_DIR_REPLY].tuple;
+		IP_VS_DBG(7, "%s(): ct=%p, status=0x%lX, tuples=" FMT_TUPLE ", "
+			  FMT_TUPLE ", found inout cp=" FMT_CONN "\n",
+			  __func__, ct, ct->status,
+			  ARG_TUPLE(orig), ARG_TUPLE(&new_reply),
+			  ARG_CONN(cp));
+		new_reply.dst.u3 = cp->vaddr;
+		new_reply.dst.u.tcp.port = cp->vport;
+		IP_VS_DBG(7, "%s(): ct=%p, new tuples=" FMT_TUPLE ", " FMT_TUPLE
+			  ", inout cp=" FMT_CONN "\n",
+			  __func__, ct,
+			  ARG_TUPLE(orig), ARG_TUPLE(&new_reply),
+			  ARG_CONN(cp));
+		goto alter;
+	}
+
+	/* CLIENT->VS */
+	cp = ip_vs_conn_in_get(exp->tuple.src.l3num, orig->dst.protonum,
+			       &orig->src.u3, orig->src.u.tcp.port,
+			       &orig->dst.u3, orig->dst.u.tcp.port);
+	if (cp) {
+		/* Change reply VS->CLIENT to RS->CLIENT */
+		new_reply = ct->tuplehash[IP_CT_DIR_REPLY].tuple;
+		IP_VS_DBG(7, "%s(): ct=%p, status=0x%lX, tuples=" FMT_TUPLE ", "
+			  FMT_TUPLE ", found outin cp=" FMT_CONN "\n",
+			  __func__, ct, ct->status,
+			  ARG_TUPLE(orig), ARG_TUPLE(&new_reply),
+			  ARG_CONN(cp));
+		new_reply.src.u3 = cp->daddr;
+		new_reply.src.u.tcp.port = cp->dport;
+		IP_VS_DBG(7, "%s(): ct=%p, new tuples=" FMT_TUPLE ", "
+			  FMT_TUPLE ", outin cp=" FMT_CONN "\n",
+			  __func__, ct,
+			  ARG_TUPLE(orig), ARG_TUPLE(&new_reply),
+			  ARG_CONN(cp));
+		goto alter;
+	}
+
+	IP_VS_DBG(7, "%s(): ct=%p, status=0x%lX, tuple=" FMT_TUPLE
+		  " - unknown expect\n",
+		  __func__, ct, ct->status, ARG_TUPLE(orig));
+	return;
+
+alter:
+	/* Never alter conntrack for non-NAT conns */
+	if (IP_VS_FWD_METHOD(cp) == IP_VS_CONN_F_MASQ)
+		nf_conntrack_alter_reply(ct, &new_reply);
+	ip_vs_conn_put(cp);
+	return;
+}
+
+/*
+ * Create NF conntrack expectation with wildcard (optional) source port.
+ * Then the default callback function will alter the reply and will confirm
+ * the conntrack entry when the first packet comes.
+ */
+static void
+ip_vs_expect_related(struct sk_buff *skb, struct nf_conn *ct,
+		     struct ip_vs_conn *cp, u_int8_t proto,
+		     const __be16 *port, int from_rs)
+{
+	struct nf_conntrack_expect *exp;
+
+	BUG_ON(!ct || ct == &nf_conntrack_untracked);
+
+	exp = nf_ct_expect_alloc(ct);
+	if (!exp)
+		return;
+
+	if (from_rs)
+		nf_ct_expect_init(exp, NF_CT_EXPECT_CLASS_DEFAULT,
+				  nf_ct_l3num(ct), &cp->daddr, &cp->caddr,
+				  proto, port, &cp->cport);
+	else
+		nf_ct_expect_init(exp, NF_CT_EXPECT_CLASS_DEFAULT,
+				  nf_ct_l3num(ct), &cp->caddr, &cp->vaddr,
+				  proto, port, &cp->vport);
+
+	exp->expectfn = ip_vs_expect_callback;
+
+	IP_VS_DBG(7, "%s(): ct=%p, expect tuple=" FMT_TUPLE "\n",
+		  __func__, ct, ARG_TUPLE(&exp->tuple));
+	nf_ct_expect_related(exp);
+	nf_ct_expect_put(exp);
+}
 
 /*
  * Look at outgoing ftp packets to catch the response to a PASV command
@@ -146,9 +283,11 @@ static int ip_vs_ftp_out(struct ip_vs_ap
 	union nf_inet_addr from;
 	__be16 port;
 	struct ip_vs_conn *n_cp;
-	char buf[24];		/* xxx.xxx.xxx.xxx,ppp,ppp\000 */
+	char buf[sizeof("xxx,xxx,xxx,xxx,ppp,ppp")];
 	unsigned buf_len;
 	int ret;
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
 
 #ifdef CONFIG_IP_VS_IPV6
 	/* This application helper doesn't work with IPv6 yet,
@@ -208,23 +347,26 @@ static int ip_vs_ftp_out(struct ip_vs_ap
 		 */
 		from.ip = n_cp->vaddr.ip;
 		port = n_cp->vport;
-		sprintf(buf, "%u,%u,%u,%u,%u,%u", NIPQUAD(from.ip),
-			(ntohs(port)>>8)&255, ntohs(port)&255);
-		buf_len = strlen(buf);
+		buf_len = sprintf(buf, "%u,%u,%u,%u,%u,%u", NIPQUAD(from.ip),
+				  (ntohs(port)>>8)&255, ntohs(port)&255);
+
+		ct = nf_ct_get(skb, &ctinfo);
+		ret = nf_nat_mangle_tcp_packet(skb,
+					       ct,
+					       ctinfo,
+					       start-data,
+					       end-start,
+					       buf,
+					       buf_len);
+
+		if (ct && ct != &nf_conntrack_untracked)
+			ip_vs_expect_related(skb, ct, n_cp,
+					     IPPROTO_TCP, NULL, 0);
 
 		/*
-		 * Calculate required delta-offset to keep TCP happy
+		 * Not setting 'diff' is intentional, otherwise the sequence
+		 * would be adjusted twice.
 		 */
-		*diff = buf_len - (end-start);
-
-		if (*diff == 0) {
-			/* simply replace it with new passive address */
-			memcpy(start, buf, buf_len);
-			ret = 1;
-		} else {
-			ret = !ip_vs_skb_replace(skb, GFP_ATOMIC, start,
-					  end-start, buf, buf_len);
-		}
 
 		cp->app_data = NULL;
 		ip_vs_tcp_conn_listen(n_cp);
@@ -256,6 +398,7 @@ static int ip_vs_ftp_in(struct ip_vs_app
 	union nf_inet_addr to;
 	__be16 port;
 	struct ip_vs_conn *n_cp;
+	struct nf_conn *ct;
 
 #ifdef CONFIG_IP_VS_IPV6
 	/* This application helper doesn't work with IPv6 yet,
@@ -342,6 +485,11 @@ static int ip_vs_ftp_in(struct ip_vs_app
 		ip_vs_control_add(n_cp, cp);
 	}
 
+	ct = (struct nf_conn *)skb->nfct;
+	if (ct && ct != &nf_conntrack_untracked)
+		ip_vs_expect_related(skb, ct, n_cp,
+				     IPPROTO_TCP, &n_cp->dport, 1);
+
 	/*
 	 *	Move tunnel to listen state
 	 */

