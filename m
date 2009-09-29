From: Hannes Eder <heder@google.com>
Subject: [PATCH v2 3/4] IPVS: make FTP work with full NAT support
Date: Tue, 29 Sep 2009 14:35:50 +0200
Message-ID: <20090929123543.13798.32170.stgit@jazzy.zrh.corp.google.com>
References: <20090929123501.13798.84004.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1254229980; bh=2o0+4ZRT7PGLqQG8CTJlVVngad0=;
	h=DomainKey-Signature:Subject:To:From:Cc:Date:Message-ID:
	 In-Reply-To:References:User-Agent:MIME-Version:Content-Type:
	 Content-Transfer-Encoding; b=PSLVG0pdMuhyi2SjR81+tw5XlOfoO5BV/Myhe
	NC2yPNnwPw/uncAo1lMiZ+hxauOwJuMIIi1dceYh0Kai9c/qQ==
In-Reply-To: <20090929123501.13798.84004.stgit@jazzy.zrh.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julius Volz <julius.volz@gmail.com>, lvs-users@linuxvirtualserver.org, Laurent Grawet <laurent.grawet@uclouvain.be>, Jean-Luc Fortemaison <jl.fortemaison@uclouvain.be>, linux-kernel@vger.kernel.org, Jan Engelhardt <jengelh@medozas.de>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, =?ISO-8859-1?Q?Fabien_Duch=EAne?= <mad_fab@skynet.be>, Joseph Mack NA3T <jmack@wm7d.net>, Patrick McHardy <kaber@trash.net>

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

Signed-off-by: Hannes Eder <heder@google.com>

 include/net/ip_vs.h             |    2 
 net/netfilter/ipvs/Kconfig      |    2 
 net/netfilter/ipvs/ip_vs_app.c  |   43 ---------
 net/netfilter/ipvs/ip_vs_core.c |    1 
 net/netfilter/ipvs/ip_vs_ftp.c  |  178 ++++++++++++++++++++++++++++++++++++---
 5 files changed, 164 insertions(+), 62 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 98978e7..ec467de 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -724,8 +724,6 @@ extern void ip_vs_app_inc_put(struct ip_vs_app *inc);
 
 extern int ip_vs_app_pkt_out(struct ip_vs_conn *, struct sk_buff *skb);
 extern int ip_vs_app_pkt_in(struct ip_vs_conn *, struct sk_buff *skb);
-extern int ip_vs_skb_replace(struct sk_buff *skb, gfp_t pri,
-			     char *o_buf, int o_len, char *n_buf, int n_len);
 extern int ip_vs_app_init(void);
 extern void ip_vs_app_cleanup(void);
 
diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index fca5379..afc03ec 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -226,7 +226,7 @@ comment 'IPVS application helper'
 
 config	IP_VS_FTP
   	tristate "FTP protocol helper"
-        depends on IP_VS_PROTO_TCP
+        depends on IP_VS_PROTO_TCP && NF_NAT
 	---help---
 	  FTP is a protocol that transfers IP address and/or port number in
 	  the payload. In the virtual server via Network Address Translation,
diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index 3c7e427..1e2d450 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -568,49 +568,6 @@ static const struct file_operations ip_vs_app_fops = {
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
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index d5e00ae..e200725 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -52,7 +52,6 @@
 
 EXPORT_SYMBOL(register_ip_vs_scheduler);
 EXPORT_SYMBOL(unregister_ip_vs_scheduler);
-EXPORT_SYMBOL(ip_vs_skb_replace);
 EXPORT_SYMBOL(ip_vs_proto_name);
 EXPORT_SYMBOL(ip_vs_conn_new);
 EXPORT_SYMBOL(ip_vs_conn_in_get);
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 33e2c79..a810ed2 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
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
@@ -122,6 +146,119 @@ static int ip_vs_ftp_get_addrport(char *data, char *data_limit,
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
@@ -146,9 +283,11 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
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
@@ -208,23 +347,26 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		 */
 		from.ip = n_cp->vaddr.ip;
 		port = n_cp->vport;
-		sprintf(buf, "%d,%d,%d,%d,%d,%d", NIPQUAD(from.ip),
-			(ntohs(port)>>8)&255, ntohs(port)&255);
-		buf_len = strlen(buf);
+		buf_len = sprintf(buf, "%d,%d,%d,%d,%d,%d", NIPQUAD(from.ip),
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
@@ -256,6 +398,7 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	union nf_inet_addr to;
 	__be16 port;
 	struct ip_vs_conn *n_cp;
+	struct nf_conn *ct;
 
 #ifdef CONFIG_IP_VS_IPV6
 	/* This application helper doesn't work with IPv6 yet,
@@ -342,6 +485,11 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
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

