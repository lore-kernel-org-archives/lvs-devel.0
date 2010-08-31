From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH v2.6.36-rc2 RFC] ipvs: Netfilter connection tracking changes
Date: Wed, 1 Sep 2010 02:22:12 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.1009010142350.21284@u.domain.uli>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Hannes Eder <heder@google.com>


	Add more code to IPVS to work with Netfilter connection
tracking and fix some problems.

- Allow IPVS to be compiled without connection tracking as in
2.6.35 and before. This can avoid keeping conntracks for all
IPVS connections because this costs memory. ip_vs_ftp still
depends on connection tracking and NAT as implemented for 2.6.36.

- Add sysctl var "conntrack" to enable connection tracking for
all IPVS connections. For loaded IPVS directors it needs
tuning of nf_conntrack_max limit.

- Add IP_VS_CONN_F_NFCT connection flag to request the connection
to use connection tracking. This allows user space to provide this
flag, for example, in dest->conn_flags. This can be useful to
request connection tracking per real server instead of forcing it
for all connections with the "conntrack" sysctl. This flag is
set currently only by ip_vs_ftp and of course by "conntrack" sysctl.

- Add ip_vs_nfct.c file to hold all connection tracking code,
by this way main code should not depend of netfilter conntrack
support.

- Return back the ip_vs_post_routing handler as in 2.6.35 and use
skb->ipvs_property=1 to allow IPVS to work without connection
tracking

- new sysctl flag "snat_reroute". Recent kernels use
ip_route_me_harder() to route LVS-NAT responses properly by
VIP when there are multiple paths to client. But setups
that do not have alternative default routes can skip this
routing lookup by using snat_reroute=0.

Connection tracking:

- most of the code is already in 2.6.36-rc

- alter conntrack reply tuple for LVS-NAT connections when first packet
from client is forwarded and conntrack state is NEW or RELATED.
Additionally, alter reply for RELATED connections from real server,
again for packet in original direction.

- add IP_VS_XMIT_TUNNEL to confirm conntrack (without altering
reply) for LVS-TUN early because we want to call nf_reset. It is
needed because we add IPIP header and we want the original conntrack
to be preserved, not destroyed. The transmitted IPIP packets
can reuse same conntrack, so we do not set skb->ipvs_property

- try to destroy conntrack when the IPVS connection is destroyed.
It is not fatal if conntrack disappears before that, it depends
on the used timers.

Fix problems from long time:

- add skb->ip_summed = CHECKSUM_NONE for the LVS-TUN transmitters

Fix problems only in 2.6.36-rc:

- when altering PASV response in ip_vs_ftp we should check with
nfct_nat(ct) if NAT is enabled for conntrack before calling
nf_nat_mangle_tcp_packet. This avoids possible crash when
iptable_nat is not loaded.

- do not create expectation in ip_vs_ftp when PORT command is
forwarded, leave it to nf_conntrack_ftp.c:help(). This
avoids packet drops because nf_ct_expect_related() fails in help().

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

	Simon, this patch is against 2.6.36-rc2, I tested it
for IPv4. In fact, it is ready for inclusion in net-next but
I'm not sure if it applies properly. After first comments we can
move the discussion to netdev. The snat_reroute part can be
separated, if needed at all. Also, IP_VS_CONN_F_NFCT can be
added to ipvsadm as real server option. The two problems
in ip_vs_ftp can be also fixed in next 2.6.36-rc kernels.
May be Hannes Eder can comment if he can see these problems.
But I worry that this full patch is needed for 2.6.36
because not all systems use netfilter conntrack and are
not tuned for many conntracks. Now 2.6.36 can come as
surprise to them because IPVS requires Netfilter connection
tracking support.

diff -urNp v2.6.36-rc2/linux/include/linux/ip_vs.h linux/include/linux/ip_vs.h
--- v2.6.36-rc2/linux/include/linux/ip_vs.h	2010-08-26 09:11:45.000000000 +0300
+++ linux/include/linux/ip_vs.h	2010-08-28 16:24:37.000000000 +0300
@@ -87,6 +87,7 @@
 #define IP_VS_CONN_F_NO_CPORT	0x0800		/* no client port set yet */
 #define IP_VS_CONN_F_TEMPLATE	0x1000		/* template, not connection */
 #define IP_VS_CONN_F_ONE_PACKET	0x2000		/* forward only one packet */
+#define IP_VS_CONN_F_NFCT	0x4000		/* use netfilter conntrack */
 
 #define IP_VS_SCHEDNAME_MAXLEN	16
 #define IP_VS_IFNAME_MAXLEN	16
diff -urNp v2.6.36-rc2/linux/include/net/ip_vs.h linux/include/net/ip_vs.h
--- v2.6.36-rc2/linux/include/net/ip_vs.h	2010-08-26 09:11:45.000000000 +0300
+++ linux/include/net/ip_vs.h	2010-08-31 02:25:58.000000000 +0300
@@ -25,7 +25,9 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>			/* for struct ipv6hdr */
 #include <net/ipv6.h>			/* for ipv6_addr_copy */
-
+#ifdef CONFIG_IP_VS_NFCT
+#include <net/netfilter/nf_conntrack.h>
+#endif
 
 /* Connections' size value needed by ip_vs_ctl.c */
 extern int ip_vs_conn_tab_size;
@@ -798,6 +800,8 @@ extern int sysctl_ip_vs_expire_nodest_co
 extern int sysctl_ip_vs_expire_quiescent_template;
 extern int sysctl_ip_vs_sync_threshold[2];
 extern int sysctl_ip_vs_nat_icmp_send;
+extern int sysctl_ip_vs_snat_reroute;
+extern int sysctl_ip_vs_conntrack;
 extern struct ip_vs_stats ip_vs_stats;
 extern const struct ctl_path net_vs_ctl_path[];
 
@@ -955,6 +959,49 @@ static inline __wsum ip_vs_check_diff2(_
 	return csum_partial(diff, sizeof(diff), oldsum);
 }
 
+#ifdef CONFIG_IP_VS_NFCT
+/*
+ *      Netfilter connection tracking
+ *      (from ip_vs_nfct.c)
+ */
+static inline int ip_vs_conntrack_enabled(void)
+{
+	return sysctl_ip_vs_conntrack;
+}
+
+extern void ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp,
+				   int outin);
+extern int ip_vs_confirm_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp);
+extern void ip_vs_nfct_expect_related(struct sk_buff *skb, struct nf_conn *ct,
+				      struct ip_vs_conn *cp, u_int8_t proto,
+				      const __be16 port, int from_rs);
+extern void ip_vs_conn_drop_conntrack(struct ip_vs_conn *cp);
+
+#else
+
+static inline int ip_vs_conntrack_enabled(void)
+{
+	return 0;
+}
+
+static inline void ip_vs_update_conntrack(struct sk_buff *skb,
+					  struct ip_vs_conn *cp, int outin)
+{
+}
+
+static inline int ip_vs_confirm_conntrack(struct sk_buff *skb,
+					  struct ip_vs_conn *cp)
+{
+	return NF_ACCEPT;
+}
+
+static inline void ip_vs_conn_drop_conntrack(struct ip_vs_conn *cp)
+{
+}
+/* CONFIG_IP_VS_NFCT */
+#endif
+
+
 #endif /* __KERNEL__ */
 
 #endif	/* _NET_IP_VS_H */
diff -urNp v2.6.36-rc2/linux/net/netfilter/ipvs/Kconfig linux/net/netfilter/ipvs/Kconfig
--- v2.6.36-rc2/linux/net/netfilter/ipvs/Kconfig	2010-08-26 09:11:47.000000000 +0300
+++ linux/net/netfilter/ipvs/Kconfig	2010-08-28 19:52:16.000000000 +0300
@@ -3,7 +3,7 @@
 #
 menuconfig IP_VS
 	tristate "IP virtual server support"
-	depends on NET && INET && NETFILTER && NF_CONNTRACK
+	depends on NET && INET && NETFILTER
 	---help---
 	  IP Virtual Server support will let you build a high-performance
 	  virtual server based on cluster of two or more real servers. This
@@ -235,7 +235,8 @@ comment 'IPVS application helper'
 
 config	IP_VS_FTP
   	tristate "FTP protocol helper"
-        depends on IP_VS_PROTO_TCP && NF_NAT
+        depends on IP_VS_PROTO_TCP && NF_CONNTRACK && NF_NAT
+	select IP_VS_NFCT
 	---help---
 	  FTP is a protocol that transfers IP address and/or port number in
 	  the payload. In the virtual server via Network Address Translation,
@@ -247,4 +248,12 @@ config	IP_VS_FTP
 	  If you want to compile it in kernel, say Y. To compile it as a
 	  module, choose M here. If unsure, say N.
 
+config	IP_VS_NFCT
+	bool "Netfilter connection tracking"
+	depends on NF_CONNTRACK
+	---help---
+	  The Netfilter connection tracking support allows the IPVS
+	  connection state to be exported to the Netfilter framework
+	  for filtering purposes.
+
 endif # IP_VS
diff -urNp v2.6.36-rc2/linux/net/netfilter/ipvs/Makefile linux/net/netfilter/ipvs/Makefile
--- v2.6.36-rc2/linux/net/netfilter/ipvs/Makefile	2010-05-17 10:49:01.000000000 +0300
+++ linux/net/netfilter/ipvs/Makefile	2010-08-26 09:18:28.000000000 +0300
@@ -9,10 +9,13 @@ ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_UD
 ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_AH_ESP) += ip_vs_proto_ah_esp.o
 ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_SCTP) += ip_vs_proto_sctp.o
 
+ip_vs-extra_objs-y :=
+ip_vs-extra_objs-$(CONFIG_IP_VS_NFCT) += ip_vs_nfct.o
+
 ip_vs-objs :=	ip_vs_conn.o ip_vs_core.o ip_vs_ctl.o ip_vs_sched.o	   \
 		ip_vs_xmit.o ip_vs_app.o ip_vs_sync.o	   		   \
 		ip_vs_est.o ip_vs_proto.o 				   \
-		$(ip_vs_proto-objs-y)
+		$(ip_vs_proto-objs-y) $(ip_vs-extra_objs-y)
 
 
 # IPVS core
diff -urNp v2.6.36-rc2/linux/net/netfilter/ipvs/ip_vs_conn.c linux/net/netfilter/ipvs/ip_vs_conn.c
--- v2.6.36-rc2/linux/net/netfilter/ipvs/ip_vs_conn.c	2010-08-26 09:11:47.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_conn.c	2010-08-28 19:41:19.000000000 +0300
@@ -717,6 +717,9 @@ static void ip_vs_conn_expire(unsigned l
 		if (cp->control)
 			ip_vs_control_del(cp);
 
+		if (cp->flags & IP_VS_CONN_F_NFCT)
+			ip_vs_conn_drop_conntrack(cp);
+
 		if (unlikely(cp->app != NULL))
 			ip_vs_unbind_app(cp);
 		ip_vs_unbind_dest(cp);
@@ -812,6 +815,16 @@ ip_vs_conn_new(int af, int proto, const 
 	if (unlikely(pp && atomic_read(&pp->appcnt)))
 		ip_vs_bind_app(cp, pp);
 
+	/*
+	 * Allow conntrack to be preserved. By default, conntrack
+	 * is created and destroyed for every packet.
+	 * Sometimes keeping conntrack can be useful for
+	 * IP_VS_CONN_F_ONE_PACKET too.
+	 */
+
+	if (ip_vs_conntrack_enabled())
+		cp->flags |= IP_VS_CONN_F_NFCT;
+
 	/* Hash it in the ip_vs_conn_tab finally */
 	ip_vs_conn_hash(cp);
 
diff -urNp v2.6.36-rc2/linux/net/netfilter/ipvs/ip_vs_core.c linux/net/netfilter/ipvs/ip_vs_core.c
--- v2.6.36-rc2/linux/net/netfilter/ipvs/ip_vs_core.c	2010-08-26 09:11:47.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_core.c	2010-09-01 01:06:16.000000000 +0300
@@ -535,6 +535,23 @@ int ip_vs_leave(struct ip_vs_service *sv
 	return NF_DROP;
 }
 
+/*
+ * It is hooked before NF_IP_PRI_NAT_SRC at the NF_INET_POST_ROUTING
+ * chain and is used to avoid double NAT and confirmation when we do
+ * not want to keep the conntrack structure
+ */
+static unsigned int ip_vs_post_routing(unsigned int hooknum,
+				       struct sk_buff *skb,
+				       const struct net_device *in,
+				       const struct net_device *out,
+				       int (*okfn)(struct sk_buff *))
+{
+	if (!skb->ipvs_property)
+		return NF_ACCEPT;
+	/* The packet was sent from IPVS, exit this chain */
+	return NF_STOP;
+}
+
 __sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset)
 {
 	return csum_fold(skb_checksum(skb, offset, skb->len - offset, 0));
@@ -691,7 +708,10 @@ static int handle_response_icmp(int af, 
 	/* do the statistics and put it back */
 	ip_vs_out_stats(cp, skb);
 
-	skb->ipvs_property = 1;
+	if (!(cp->flags & IP_VS_CONN_F_NFCT))
+		skb->ipvs_property = 1;
+	else
+		ip_vs_update_conntrack(skb, cp, 0);
 	verdict = NF_ACCEPT;
 
 out:
@@ -905,20 +925,31 @@ handle_response(int af, struct sk_buff *
 		ip_send_check(ip_hdr(skb));
 	}
 
+	/*
+	 * nf_iterate does not expect change in the skb->dst->dev.
+	 * It looks like it is not fatal to enable this code for hooks
+	 * where our handlers are at the end of the chain list and
+	 * when all next handlers use skb->dst->dev and not outdev.
+	 * It will definitely route properly the inout NAT traffic
+	 * when multiple paths are used.
+	 */
+
 	/* For policy routing, packets originating from this
 	 * machine itself may be routed differently to packets
 	 * passing through.  We want this packet to be routed as
 	 * if it came from this machine itself.  So re-compute
 	 * the routing information.
 	 */
+	if (sysctl_ip_vs_snat_reroute) {
 #ifdef CONFIG_IP_VS_IPV6
-	if (af == AF_INET6) {
-		if (ip6_route_me_harder(skb) != 0)
-			goto drop;
-	} else
+		if (af == AF_INET6) {
+			if (ip6_route_me_harder(skb) != 0)
+				goto drop;
+		} else
 #endif
-		if (ip_route_me_harder(skb, RTN_LOCAL) != 0)
-			goto drop;
+			if (ip_route_me_harder(skb, RTN_LOCAL) != 0)
+				goto drop;
+	}
 
 	IP_VS_DBG_PKT(10, pp, skb, 0, "After SNAT");
 
@@ -926,14 +957,18 @@ handle_response(int af, struct sk_buff *
 	ip_vs_set_state(cp, IP_VS_DIR_OUTPUT, skb, pp);
 	ip_vs_conn_put(cp);
 
-	skb->ipvs_property = 1;
+	if (!(cp->flags & IP_VS_CONN_F_NFCT))
+		skb->ipvs_property = 1;
+	else
+		ip_vs_update_conntrack(skb, cp, 0);
 
 	LeaveFunction(11);
 	return NF_ACCEPT;
 
 drop:
-	ip_vs_conn_put(cp);
 	kfree_skb(skb);
+	ip_vs_conn_put(cp);
+	LeaveFunction(11);
 	return NF_STOLEN;
 }
 
@@ -964,8 +999,13 @@ ip_vs_out(unsigned int hooknum, struct s
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
 			int related, verdict = ip_vs_out_icmp_v6(skb, &related);
 
-			if (related)
+			if (related) {
+				if (sysctl_ip_vs_snat_reroute &&
+					NF_ACCEPT == verdict &&
+					ip6_route_me_harder(skb))
+					verdict = NF_DROP;
 				return verdict;
+			}
 			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 		}
 	} else
@@ -973,8 +1013,13 @@ ip_vs_out(unsigned int hooknum, struct s
 		if (unlikely(iph.protocol == IPPROTO_ICMP)) {
 			int related, verdict = ip_vs_out_icmp(skb, &related);
 
-			if (related)
+			if (related) {
+				if (sysctl_ip_vs_snat_reroute &&
+					NF_ACCEPT == verdict &&
+					ip_route_me_harder(skb, RTN_LOCAL))
+					verdict = NF_DROP;
 				return verdict;
+			}
 			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 		}
 
@@ -1478,6 +1523,14 @@ static struct nf_hook_ops ip_vs_ops[] __
 		.hooknum        = NF_INET_FORWARD,
 		.priority       = 99,
 	},
+	/* Before the netfilter connection tracking, exit from POST_ROUTING */
+	{
+		.hook		= ip_vs_post_routing,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET,
+		.hooknum        = NF_INET_POST_ROUTING,
+		.priority       = NF_IP_PRI_NAT_SRC-1,
+	},
 #ifdef CONFIG_IP_VS_IPV6
 	/* After packet filtering, forward packet through VS/DR, VS/TUN,
 	 * or VS/NAT(change destination), so that filtering rules can be
@@ -1506,6 +1559,14 @@ static struct nf_hook_ops ip_vs_ops[] __
 		.hooknum        = NF_INET_FORWARD,
 		.priority       = 99,
 	},
+	/* Before the netfilter connection tracking, exit from POST_ROUTING */
+	{
+		.hook		= ip_vs_post_routing,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET6,
+		.hooknum        = NF_INET_POST_ROUTING,
+		.priority       = NF_IP6_PRI_NAT_SRC-1,
+	},
 #endif
 };
 
diff -urNp v2.6.36-rc2/linux/net/netfilter/ipvs/ip_vs_ctl.c linux/net/netfilter/ipvs/ip_vs_ctl.c
--- v2.6.36-rc2/linux/net/netfilter/ipvs/ip_vs_ctl.c	2010-08-26 09:11:47.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_ctl.c	2010-08-28 18:34:26.000000000 +0300
@@ -88,6 +88,10 @@ int sysctl_ip_vs_expire_nodest_conn = 0;
 int sysctl_ip_vs_expire_quiescent_template = 0;
 int sysctl_ip_vs_sync_threshold[2] = { 3, 50 };
 int sysctl_ip_vs_nat_icmp_send = 0;
+int sysctl_ip_vs_snat_reroute = 1;
+#ifdef CONFIG_IP_VS_NFCT
+int sysctl_ip_vs_conntrack;
+#endif
 
 
 #ifdef CONFIG_IP_VS_DEBUG
@@ -1579,6 +1583,15 @@ static struct ctl_table vs_vars[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_do_defense_mode,
 	},
+#ifdef CONFIG_IP_VS_NFCT
+	{
+		.procname	= "conntrack",
+		.data		= &sysctl_ip_vs_conntrack,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+#endif
 	{
 		.procname	= "secure_tcp",
 		.data		= &sysctl_ip_vs_secure_tcp,
@@ -1586,6 +1599,13 @@ static struct ctl_table vs_vars[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_do_defense_mode,
 	},
+	{
+		.procname	= "snat_reroute",
+		.data		= &sysctl_ip_vs_snat_reroute,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 #if 0
 	{
 		.procname	= "timeout_established",
diff -urNp v2.6.36-rc2/linux/net/netfilter/ipvs/ip_vs_ftp.c linux/net/netfilter/ipvs/ip_vs_ftp.c
--- v2.6.36-rc2/linux/net/netfilter/ipvs/ip_vs_ftp.c	2010-08-26 09:11:47.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_ftp.c	2010-08-29 21:37:52.000000000 +0300
@@ -20,17 +20,6 @@
  *
  * Author:	Wouter Gadeyne
  *
- *
- * Code for ip_vs_expect_related and ip_vs_expect_callback is taken from
- * http://www.ssi.bg/~ja/nfct/:
- *
- * ip_vs_nfct.c:	Netfilter connection tracking support for IPVS
- *
- * Portions Copyright (C) 2001-2002
- * Antefacto Ltd, 181 Parnell St, Dublin 1, Ireland.
- *
- * Portions Copyright (C) 2003-2008
- * Julian Anastasov
  */
 
 #define KMSG_COMPONENT "IPVS"
@@ -45,6 +34,7 @@
 #include <linux/netfilter.h>
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_expect.h>
+#include <net/netfilter/nf_nat.h>
 #include <net/netfilter/nf_nat_helper.h>
 #include <linux/gfp.h>
 #include <net/protocol.h>
@@ -57,16 +47,6 @@
 #define SERVER_STRING "227 Entering Passive Mode ("
 #define CLIENT_STRING "PORT "
 
-#define FMT_TUPLE	"%pI4:%u->%pI4:%u/%u"
-#define ARG_TUPLE(T)	&(T)->src.u3.ip, ntohs((T)->src.u.all), \
-			&(T)->dst.u3.ip, ntohs((T)->dst.u.all), \
-			(T)->dst.protonum
-
-#define FMT_CONN	"%pI4:%u->%pI4:%u->%pI4:%u/%u:%u"
-#define ARG_CONN(C)	&((C)->caddr.ip), ntohs((C)->cport), \
-			&((C)->vaddr.ip), ntohs((C)->vport), \
-			&((C)->daddr.ip), ntohs((C)->dport), \
-			(C)->protocol, (C)->state
 
 /*
  * List of ports (up to IP_VS_APP_MAX_PORTS) to be handled by helper
@@ -84,6 +64,8 @@ static int ip_vs_ftp_pasv;
 static int
 ip_vs_ftp_init_conn(struct ip_vs_app *app, struct ip_vs_conn *cp)
 {
+	/* We use connection tracking for the command connection */
+	cp->flags |= IP_VS_CONN_F_NFCT;
 	return 0;
 }
 
@@ -148,120 +130,6 @@ static int ip_vs_ftp_get_addrport(char *
 }
 
 /*
- * Called from init_conntrack() as expectfn handler.
- */
-static void
-ip_vs_expect_callback(struct nf_conn *ct,
-		      struct nf_conntrack_expect *exp)
-{
-	struct nf_conntrack_tuple *orig, new_reply;
-	struct ip_vs_conn *cp;
-
-	if (exp->tuple.src.l3num != PF_INET)
-		return;
-
-	/*
-	 * We assume that no NF locks are held before this callback.
-	 * ip_vs_conn_out_get and ip_vs_conn_in_get should match their
-	 * expectations even if they use wildcard values, now we provide the
-	 * actual values from the newly created original conntrack direction.
-	 * The conntrack is confirmed when packet reaches IPVS hooks.
-	 */
-
-	/* RS->CLIENT */
-	orig = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
-	cp = ip_vs_conn_out_get(exp->tuple.src.l3num, orig->dst.protonum,
-				&orig->src.u3, orig->src.u.tcp.port,
-				&orig->dst.u3, orig->dst.u.tcp.port);
-	if (cp) {
-		/* Change reply CLIENT->RS to CLIENT->VS */
-		new_reply = ct->tuplehash[IP_CT_DIR_REPLY].tuple;
-		IP_VS_DBG(7, "%s(): ct=%p, status=0x%lX, tuples=" FMT_TUPLE ", "
-			  FMT_TUPLE ", found inout cp=" FMT_CONN "\n",
-			  __func__, ct, ct->status,
-			  ARG_TUPLE(orig), ARG_TUPLE(&new_reply),
-			  ARG_CONN(cp));
-		new_reply.dst.u3 = cp->vaddr;
-		new_reply.dst.u.tcp.port = cp->vport;
-		IP_VS_DBG(7, "%s(): ct=%p, new tuples=" FMT_TUPLE ", " FMT_TUPLE
-			  ", inout cp=" FMT_CONN "\n",
-			  __func__, ct,
-			  ARG_TUPLE(orig), ARG_TUPLE(&new_reply),
-			  ARG_CONN(cp));
-		goto alter;
-	}
-
-	/* CLIENT->VS */
-	cp = ip_vs_conn_in_get(exp->tuple.src.l3num, orig->dst.protonum,
-			       &orig->src.u3, orig->src.u.tcp.port,
-			       &orig->dst.u3, orig->dst.u.tcp.port);
-	if (cp) {
-		/* Change reply VS->CLIENT to RS->CLIENT */
-		new_reply = ct->tuplehash[IP_CT_DIR_REPLY].tuple;
-		IP_VS_DBG(7, "%s(): ct=%p, status=0x%lX, tuples=" FMT_TUPLE ", "
-			  FMT_TUPLE ", found outin cp=" FMT_CONN "\n",
-			  __func__, ct, ct->status,
-			  ARG_TUPLE(orig), ARG_TUPLE(&new_reply),
-			  ARG_CONN(cp));
-		new_reply.src.u3 = cp->daddr;
-		new_reply.src.u.tcp.port = cp->dport;
-		IP_VS_DBG(7, "%s(): ct=%p, new tuples=" FMT_TUPLE ", "
-			  FMT_TUPLE ", outin cp=" FMT_CONN "\n",
-			  __func__, ct,
-			  ARG_TUPLE(orig), ARG_TUPLE(&new_reply),
-			  ARG_CONN(cp));
-		goto alter;
-	}
-
-	IP_VS_DBG(7, "%s(): ct=%p, status=0x%lX, tuple=" FMT_TUPLE
-		  " - unknown expect\n",
-		  __func__, ct, ct->status, ARG_TUPLE(orig));
-	return;
-
-alter:
-	/* Never alter conntrack for non-NAT conns */
-	if (IP_VS_FWD_METHOD(cp) == IP_VS_CONN_F_MASQ)
-		nf_conntrack_alter_reply(ct, &new_reply);
-	ip_vs_conn_put(cp);
-	return;
-}
-
-/*
- * Create NF conntrack expectation with wildcard (optional) source port.
- * Then the default callback function will alter the reply and will confirm
- * the conntrack entry when the first packet comes.
- */
-static void
-ip_vs_expect_related(struct sk_buff *skb, struct nf_conn *ct,
-		     struct ip_vs_conn *cp, u_int8_t proto,
-		     const __be16 *port, int from_rs)
-{
-	struct nf_conntrack_expect *exp;
-
-	BUG_ON(!ct || ct == &nf_conntrack_untracked);
-
-	exp = nf_ct_expect_alloc(ct);
-	if (!exp)
-		return;
-
-	if (from_rs)
-		nf_ct_expect_init(exp, NF_CT_EXPECT_CLASS_DEFAULT,
-				  nf_ct_l3num(ct), &cp->daddr, &cp->caddr,
-				  proto, port, &cp->cport);
-	else
-		nf_ct_expect_init(exp, NF_CT_EXPECT_CLASS_DEFAULT,
-				  nf_ct_l3num(ct), &cp->caddr, &cp->vaddr,
-				  proto, port, &cp->vport);
-
-	exp->expectfn = ip_vs_expect_callback;
-
-	IP_VS_DBG(7, "%s(): ct=%p, expect tuple=" FMT_TUPLE "\n",
-		  __func__, ct, ARG_TUPLE(&exp->tuple));
-	nf_ct_expect_related(exp);
-	nf_ct_expect_put(exp);
-}
-
-/*
  * Look at outgoing ftp packets to catch the response to a PASV command
  * from the server (inside-to-outside).
  * When we see one, we build a connection entry with the client address,
@@ -334,7 +202,8 @@ static int ip_vs_ftp_out(struct ip_vs_ap
 					      &cp->caddr, 0,
 					      &cp->vaddr, port,
 					      &from, port,
-					      IP_VS_CONN_F_NO_CPORT,
+					      IP_VS_CONN_F_NO_CPORT |
+					      IP_VS_CONN_F_NFCT,
 					      cp->dest);
 			if (!n_cp)
 				return 0;
@@ -359,7 +228,7 @@ static int ip_vs_ftp_out(struct ip_vs_ap
 		buf_len = strlen(buf);
 
 		ct = nf_ct_get(skb, &ctinfo);
-		if (ct && !nf_ct_is_untracked(ct)) {
+		if (ct && !nf_ct_is_untracked(ct) && nfct_nat(ct)) {
 			/* If mangling fails this function will return 0
 			 * which will cause the packet to be dropped.
 			 * Mangling can only fail under memory pressure,
@@ -370,8 +239,8 @@ static int ip_vs_ftp_out(struct ip_vs_ap
 						       start-data, end-start,
 						       buf, buf_len);
 			if (ret)
-				ip_vs_expect_related(skb, ct, n_cp,
-						     IPPROTO_TCP, NULL, 0);
+				ip_vs_nfct_expect_related(skb, ct, n_cp,
+							  IPPROTO_TCP, 0, 0);
 		}
 
 		/*
@@ -409,7 +278,6 @@ static int ip_vs_ftp_in(struct ip_vs_app
 	union nf_inet_addr to;
 	__be16 port;
 	struct ip_vs_conn *n_cp;
-	struct nf_conn *ct;
 
 #ifdef CONFIG_IP_VS_IPV6
 	/* This application helper doesn't work with IPv6 yet,
@@ -487,7 +355,7 @@ static int ip_vs_ftp_in(struct ip_vs_app
 				      &to, port,
 				      &cp->vaddr, htons(ntohs(cp->vport)-1),
 				      &cp->daddr, htons(ntohs(cp->dport)-1),
-				      0,
+				      IP_VS_CONN_F_NFCT,
 				      cp->dest);
 		if (!n_cp)
 			return 0;
@@ -496,10 +364,16 @@ static int ip_vs_ftp_in(struct ip_vs_app
 		ip_vs_control_add(n_cp, cp);
 	}
 
-	ct = (struct nf_conn *)skb->nfct;
-	if (ct && ct != &nf_conntrack_untracked)
-		ip_vs_expect_related(skb, ct, n_cp,
-				     IPPROTO_TCP, &n_cp->dport, 1);
+	/* This expectation should be created by netfilter */
+#if 0
+	{
+		struct nf_conn *ct = (struct nf_conn *)skb->nfct;
+
+		if (ct)
+			ip_vs_nfct_expect_related(skb, ct, n_cp, IPPROTO_TCP,
+						  n_cp->dport, 1);
+	}
+#endif
 
 	/*
 	 *	Move tunnel to listen state
diff -urNp v2.6.36-rc2/linux/net/netfilter/ipvs/ip_vs_nfct.c linux/net/netfilter/ipvs/ip_vs_nfct.c
--- v2.6.36-rc2/linux/net/netfilter/ipvs/ip_vs_nfct.c	1970-01-01 02:00:00.000000000 +0200
+++ linux/net/netfilter/ipvs/ip_vs_nfct.c	2010-08-31 02:27:14.000000000 +0300
@@ -0,0 +1,292 @@
+/*
+ * ip_vs_nfct.c:	Netfilter connection tracking support for IPVS
+ *
+ * Portions Copyright (C) 2001-2002
+ * Antefacto Ltd, 181 Parnell St, Dublin 1, Ireland.
+ *
+ * Portions Copyright (C) 2003-2010
+ * Julian Anastasov
+ *
+ *
+ * This code is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ *
+ * Authors:
+ * Ben North <ben@redfrontdoor.org>
+ * Julian Anastasov <ja@ssi.bg>		Reorganize and sync with latest kernels
+ * Hannes Eder <heder@google.com>	Extend NFCT support for FTP, ipvs match
+ *
+ *
+ * Current status:
+ *
+ * - provide conntrack confirmation for new and related connections, by
+ * this way we can see their proper conntrack state in all hooks
+ * - support for all forwarding methods, not only NAT
+ * - FTP support (NAT), ability to support other NAT apps with expectations
+ * - to correctly create expectations for related NAT connections the proper
+ * NF conntrack support must be already installed, eg. ip_vs_ftp requires
+ * nf_conntrack_ftp ... iptables_nat for the same ports (but no iptables
+ * NAT rules are needed)
+ * - alter reply for NAT when forwarding packet in original direction:
+ * conntrack from client in NEW or RELATED (Passive FTP DATA) state or
+ * when RELATED conntrack is created from real server (Active FTP DATA)
+ * - if iptables_nat is not loaded the Passive FTP will not work (the
+ * PASV response can not be NAT-ed) but Active FTP should work
+ *
+ */
+
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/compiler.h>
+#include <linux/vmalloc.h>
+#include <linux/skbuff.h>
+#include <net/ip.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
+#include <net/ip_vs.h>
+#include <net/netfilter/nf_conntrack_core.h>
+#include <net/netfilter/nf_conntrack_expect.h>
+#include <net/netfilter/nf_conntrack_helper.h>
+#include <net/netfilter/nf_conntrack_zones.h>
+
+
+#define FMT_TUPLE	"%pI4:%u->%pI4:%u/%u"
+#define ARG_TUPLE(T)	&(T)->src.u3.ip, ntohs((T)->src.u.all), \
+			&(T)->dst.u3.ip, ntohs((T)->dst.u.all), \
+			(T)->dst.protonum
+
+#define FMT_CONN	"%pI4:%u->%pI4:%u->%pI4:%u/%u:%u"
+#define ARG_CONN(C)	&((C)->caddr.ip), ntohs((C)->cport), \
+			&((C)->vaddr.ip), ntohs((C)->vport), \
+			&((C)->daddr.ip), ntohs((C)->dport), \
+			(C)->protocol, (C)->state
+
+void
+ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp, int outin)
+{
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+	struct nf_conntrack_tuple new_tuple;
+
+	if (ct == NULL || nf_ct_is_confirmed(ct) || nf_ct_is_untracked(ct) ||
+	    nf_ct_is_dying(ct))
+		return;
+
+	/* Never alter conntrack for non-NAT conns */
+	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
+		return;
+
+	/* Alter reply only in original direction */
+	if (CTINFO2DIR(ctinfo) != IP_CT_DIR_ORIGINAL)
+		return;
+
+	/*
+	 * The connection is not yet in the hashtable, so we update it.
+	 * CIP->VIP will remain the same, so leave the tuple in
+	 * IP_CT_DIR_ORIGINAL untouched.  When the reply comes back from the
+	 * real-server we will see RIP->DIP.
+	 */
+	new_tuple = ct->tuplehash[IP_CT_DIR_REPLY].tuple;
+	/*
+	 * This will also take care of UDP and other protocols.
+	 */
+	if (outin) {
+		new_tuple.src.u3 = cp->daddr;
+		if (new_tuple.dst.protonum != IPPROTO_ICMP &&
+		    new_tuple.dst.protonum != IPPROTO_ICMPV6)
+			new_tuple.src.u.tcp.port = cp->dport;
+	} else {
+		new_tuple.dst.u3 = cp->vaddr;
+		if (new_tuple.dst.protonum != IPPROTO_ICMP &&
+		    new_tuple.dst.protonum != IPPROTO_ICMPV6)
+			new_tuple.dst.u.tcp.port = cp->vport;
+	}
+	IP_VS_DBG(7, "%s: Updating conntrack ct=%p, status=0x%lX, "
+		  "ctinfo=%d, old reply=" FMT_TUPLE
+		  ", new reply=" FMT_TUPLE ", cp=" FMT_CONN "\n",
+		  __func__, ct, ct->status, ctinfo,
+		  ARG_TUPLE(&ct->tuplehash[IP_CT_DIR_REPLY].tuple),
+		  ARG_TUPLE(&new_tuple), ARG_CONN(cp));
+	nf_conntrack_alter_reply(ct, &new_tuple);
+}
+
+int ip_vs_confirm_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp)
+{
+	return nf_conntrack_confirm(skb);
+}
+
+/*
+ * Called from init_conntrack() as expectfn handler.
+ */
+static void ip_vs_nfct_expect_callback(struct nf_conn *ct,
+	struct nf_conntrack_expect *exp)
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
+		IP_VS_DBG(7, "%s: ct=%p, status=0x%lX, tuples=" FMT_TUPLE ", "
+			  FMT_TUPLE ", found inout cp=" FMT_CONN "\n",
+			  __func__, ct, ct->status,
+			  ARG_TUPLE(orig), ARG_TUPLE(&new_reply),
+			  ARG_CONN(cp));
+		new_reply.dst.u3 = cp->vaddr;
+		new_reply.dst.u.tcp.port = cp->vport;
+		IP_VS_DBG(7, "%s: ct=%p, new tuples=" FMT_TUPLE ", " FMT_TUPLE
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
+		IP_VS_DBG(7, "%s: ct=%p, status=0x%lX, tuples=" FMT_TUPLE ", "
+			  FMT_TUPLE ", found outin cp=" FMT_CONN "\n",
+			  __func__, ct, ct->status,
+			  ARG_TUPLE(orig), ARG_TUPLE(&new_reply),
+			  ARG_CONN(cp));
+		new_reply.src.u3 = cp->daddr;
+		new_reply.src.u.tcp.port = cp->dport;
+		IP_VS_DBG(7, "%s: ct=%p, new tuples=" FMT_TUPLE ", "
+			  FMT_TUPLE ", outin cp=" FMT_CONN "\n",
+			  __func__, ct,
+			  ARG_TUPLE(orig), ARG_TUPLE(&new_reply),
+			  ARG_CONN(cp));
+		goto alter;
+	}
+
+	IP_VS_DBG(7, "%s: ct=%p, status=0x%lX, tuple=" FMT_TUPLE
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
+ * Use port 0 to expect connection from any port.
+ */
+void ip_vs_nfct_expect_related(struct sk_buff *skb, struct nf_conn *ct,
+			       struct ip_vs_conn *cp, u_int8_t proto,
+			       const __be16 port, int from_rs)
+{
+	struct nf_conntrack_expect *exp;
+
+	if (ct == NULL || nf_ct_is_untracked(ct))
+		return;
+
+	exp = nf_ct_expect_alloc(ct);
+	if (!exp)
+		return;
+
+	nf_ct_expect_init(exp, NF_CT_EXPECT_CLASS_DEFAULT, nf_ct_l3num(ct),
+			from_rs ? &cp->daddr : &cp->caddr,
+			from_rs ? &cp->caddr : &cp->vaddr,
+			proto, port ? &port : NULL,
+			from_rs ? &cp->cport : &cp->vport);
+
+	exp->expectfn = ip_vs_nfct_expect_callback;
+
+	IP_VS_DBG(7, "%s: ct=%p, expect tuple=" FMT_TUPLE "\n",
+		__func__, ct, ARG_TUPLE(&exp->tuple));
+	nf_ct_expect_related(exp);
+	nf_ct_expect_put(exp);
+}
+EXPORT_SYMBOL(ip_vs_nfct_expect_related);
+
+/*
+ * Our connection was terminated, try to drop the conntrack immediately
+ */
+void ip_vs_conn_drop_conntrack(struct ip_vs_conn *cp)
+{
+	struct nf_conntrack_tuple_hash *h;
+	struct nf_conn *ct;
+	struct nf_conntrack_tuple tuple;
+
+	if (!cp->cport)
+		return;
+
+	tuple = (struct nf_conntrack_tuple) {
+		.dst = { .protonum = cp->protocol, .dir = IP_CT_DIR_ORIGINAL } };
+	tuple.src.u3 = cp->caddr;
+	tuple.src.u.all = cp->cport;
+	tuple.src.l3num = cp->af;
+	tuple.dst.u3 = cp->vaddr;
+	tuple.dst.u.all = cp->vport;
+
+	IP_VS_DBG(7, "%s: dropping conntrack with tuple=" FMT_TUPLE
+		" for conn " FMT_CONN "\n",
+		__func__, ARG_TUPLE(&tuple), ARG_CONN(cp));
+
+	h = nf_conntrack_find_get(&init_net, NF_CT_DEFAULT_ZONE, &tuple);
+	if (h) {
+		ct = nf_ct_tuplehash_to_ctrack(h);
+		/* Show what happens instead of calling nf_ct_kill() */
+		if (del_timer(&ct->timeout)) {
+			IP_VS_DBG(7, "%s: ct=%p, deleted conntrack timer for tuple="
+				FMT_TUPLE "\n",
+				__func__, ct, ARG_TUPLE(&tuple));
+			if (ct->timeout.function)
+				ct->timeout.function(ct->timeout.data);
+		} else {
+			IP_VS_DBG(7, "%s: ct=%p, no conntrack timer for tuple="
+				FMT_TUPLE "\n",
+				__func__, ct, ARG_TUPLE(&tuple));
+		}
+		nf_ct_put(ct);
+	} else {
+		IP_VS_DBG(7, "%s: no conntrack for tuple=" FMT_TUPLE "\n",
+			__func__, ARG_TUPLE(&tuple));
+	}
+}
+
diff -urNp v2.6.36-rc2/linux/net/netfilter/ipvs/ip_vs_xmit.c linux/net/netfilter/ipvs/ip_vs_xmit.c
--- v2.6.36-rc2/linux/net/netfilter/ipvs/ip_vs_xmit.c	2010-08-26 09:11:47.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_xmit.c	2010-09-01 01:30:08.000000000 +0300
@@ -28,7 +28,6 @@
 #include <net/ip6_route.h>
 #include <linux/icmpv6.h>
 #include <linux/netfilter.h>
-#include <net/netfilter/nf_conntrack.h>
 #include <linux/netfilter_ipv4.h>
 
 #include <net/ip_vs.h>
@@ -194,12 +193,37 @@ ip_vs_dst_reset(struct ip_vs_dest *dest)
 	dst_release(old_dst);
 }
 
-#define IP_VS_XMIT(pf, skb, rt)				\
+#define IP_VS_XMIT_TUNNEL(skb, cp)				\
+({								\
+	int __ret = NF_ACCEPT;					\
+								\
+	if (unlikely((cp)->flags & IP_VS_CONN_F_NFCT))		\
+		__ret = ip_vs_confirm_conntrack(skb, cp);	\
+	if (__ret == NF_ACCEPT) {				\
+		nf_reset(skb);					\
+		(skb)->ip_summed = CHECKSUM_NONE;		\
+	}							\
+	__ret;							\
+})
+
+#define IP_VS_XMIT_NAT(pf, skb, cp)				\
+do {							\
+	if (likely(!((cp)->flags & IP_VS_CONN_F_NFCT)))	\
+		(skb)->ipvs_property = 1;		\
+	else						\
+		ip_vs_update_conntrack(skb, cp, 1);	\
+	skb_forward_csum(skb);				\
+	NF_HOOK(pf, NF_INET_LOCAL_OUT, (skb), NULL,	\
+		skb_dst(skb)->dev, dst_output);		\
+} while (0)
+
+#define IP_VS_XMIT(pf, skb, cp)				\
 do {							\
-	(skb)->ipvs_property = 1;			\
+	if (likely(!((cp)->flags & IP_VS_CONN_F_NFCT)))	\
+		(skb)->ipvs_property = 1;		\
 	skb_forward_csum(skb);				\
 	NF_HOOK(pf, NF_INET_LOCAL_OUT, (skb), NULL,	\
-		(rt)->dst.dev, dst_output);		\
+		skb_dst(skb)->dev, dst_output);		\
 } while (0)
 
 
@@ -271,7 +295,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, s
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(NFPROTO_IPV4, skb, rt);
+	IP_VS_XMIT(NFPROTO_IPV4, skb, cp);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -335,7 +359,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(NFPROTO_IPV6, skb, rt);
+	IP_VS_XMIT(NFPROTO_IPV6, skb, cp);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -349,30 +373,6 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb
 }
 #endif
 
-static void
-ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp)
-{
-	struct nf_conn *ct = (struct nf_conn *)skb->nfct;
-	struct nf_conntrack_tuple new_tuple;
-
-	if (ct == NULL || nf_ct_is_untracked(ct) || nf_ct_is_confirmed(ct))
-		return;
-
-	/*
-	 * The connection is not yet in the hashtable, so we update it.
-	 * CIP->VIP will remain the same, so leave the tuple in
-	 * IP_CT_DIR_ORIGINAL untouched.  When the reply comes back from the
-	 * real-server we will see RIP->DIP.
-	 */
-	new_tuple = ct->tuplehash[IP_CT_DIR_REPLY].tuple;
-	new_tuple.src.u3 = cp->daddr;
-	/*
-	 * This will also take care of UDP and other protocols.
-	 */
-	new_tuple.src.u.tcp.port = cp->dport;
-	nf_conntrack_alter_reply(ct, &new_tuple);
-}
-
 /*
  *      NAT transmitter (only for outside-to-inside nat forwarding)
  *      Not used for related ICMP
@@ -428,8 +428,6 @@ ip_vs_nat_xmit(struct sk_buff *skb, stru
 
 	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");
 
-	ip_vs_update_conntrack(skb, cp);
-
 	/* FIXME: when application helper enlarges the packet and the length
 	   is larger than the MTU of outgoing device, there will be still
 	   MTU problem. */
@@ -437,7 +435,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, stru
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(NFPROTO_IPV4, skb, rt);
+	IP_VS_XMIT_NAT(NFPROTO_IPV4, skb, cp);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -445,8 +443,8 @@ ip_vs_nat_xmit(struct sk_buff *skb, stru
   tx_error_icmp:
 	dst_link_failure(skb);
   tx_error:
-	LeaveFunction(10);
 	kfree_skb(skb);
+	LeaveFunction(10);
 	return NF_STOLEN;
   tx_error_put:
 	ip_rt_put(rt);
@@ -506,8 +504,6 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, s
 
 	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");
 
-	ip_vs_update_conntrack(skb, cp);
-
 	/* FIXME: when application helper enlarges the packet and the length
 	   is larger than the MTU of outgoing device, there will be still
 	   MTU problem. */
@@ -515,7 +511,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, s
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(NFPROTO_IPV6, skb, rt);
+	IP_VS_XMIT_NAT(NFPROTO_IPV6, skb, cp);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -565,6 +561,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, s
 	struct iphdr  *iph;			/* Our new IP header */
 	unsigned int max_headroom;		/* The extra header space needed */
 	int    mtu;
+	int ret;
 
 	EnterFunction(10);
 
@@ -649,7 +646,11 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, s
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	ip_local_out(skb);
+	ret = IP_VS_XMIT_TUNNEL(skb, cp);
+	if (ret == NF_ACCEPT)
+		ip_local_out(skb);
+	else if (ret == NF_DROP)
+		kfree_skb(skb);
 
 	LeaveFunction(10);
 
@@ -675,6 +676,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb
 	struct ipv6hdr  *iph;		/* Our new IP header */
 	unsigned int max_headroom;	/* The extra header space needed */
 	int    mtu;
+	int ret;
 
 	EnterFunction(10);
 
@@ -755,7 +757,11 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	ip6_local_out(skb);
+	ret = IP_VS_XMIT_TUNNEL(skb, cp);
+	if (ret == NF_ACCEPT)
+		ip6_local_out(skb);
+	else if (ret == NF_DROP)
+		kfree_skb(skb);
 
 	LeaveFunction(10);
 
@@ -814,7 +820,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struc
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(NFPROTO_IPV4, skb, rt);
+	IP_VS_XMIT(NFPROTO_IPV4, skb, cp);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -867,7 +873,7 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, st
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(NFPROTO_IPV6, skb, rt);
+	IP_VS_XMIT(NFPROTO_IPV6, skb, cp);
 
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -941,7 +947,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, str
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(NFPROTO_IPV4, skb, rt);
+	IP_VS_XMIT(NFPROTO_IPV4, skb, cp);
 
 	rc = NF_STOLEN;
 	goto out;
@@ -1016,7 +1022,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
-	IP_VS_XMIT(NFPROTO_IPV6, skb, rt);
+	IP_VS_XMIT(NFPROTO_IPV6, skb, cp);
 
 	rc = NF_STOLEN;
 	goto out;
