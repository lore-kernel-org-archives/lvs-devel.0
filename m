From: Thomas Graf <tgraf@infradead.org>
Subject: [PATCH] one-packet scheduling
Date: Thu, 24 Jun 2010 08:29:19 -0400
Message-ID: <20100624122919.GB26308@bombadil.infradead.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org

Hi,

This is an updated version of Julian's One Packet Scheduler patch. It is
based on http://marc.info/?l=linux-virtual-server&m=112800257026121&w=2
with all issues raised in previous discussions addressed.

Index: net-2.6/include/linux/ip_vs.h
===================================================================
--- net-2.6.orig/include/linux/ip_vs.h
+++ net-2.6/include/linux/ip_vs.h
@@ -19,6 +19,7 @@
  */
 #define IP_VS_SVC_F_PERSISTENT	0x0001		/* persistent port */
 #define IP_VS_SVC_F_HASHED	0x0002		/* hashed entry */
+#define IP_VS_SVC_F_ONEPACKET	0x0004		/* one-packet scheduling */
 
 /*
  *      Destination Server Flags
@@ -85,6 +86,7 @@
 #define IP_VS_CONN_F_SEQ_MASK	0x0600		/* in/out sequence mask */
 #define IP_VS_CONN_F_NO_CPORT	0x0800		/* no client port set yet */
 #define IP_VS_CONN_F_TEMPLATE	0x1000		/* template, not connection */
+#define IP_VS_CONN_F_ONE_PACKET	0x2000		/* forward only one packet */
 
 #define IP_VS_SCHEDNAME_MAXLEN	16
 #define IP_VS_IFNAME_MAXLEN	16
Index: net-2.6/net/netfilter/ipvs/ip_vs_conn.c
===================================================================
--- net-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c
+++ net-2.6/net/netfilter/ipvs/ip_vs_conn.c
@@ -158,6 +158,9 @@ static inline int ip_vs_conn_hash(struct
 	unsigned hash;
 	int ret;
 
+	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
+		return 0;
+
 	/* Hash by protocol, client address and port */
 	hash = ip_vs_conn_hashkey(cp->af, cp->protocol, &cp->caddr, cp->cport);
 
@@ -359,8 +362,13 @@ struct ip_vs_conn *ip_vs_conn_out_get
  */
 void ip_vs_conn_put(struct ip_vs_conn *cp)
 {
+	unsigned long timeout = cp->timeout;
+
+	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
+		timeout = 0;
+
 	/* reset it expire in its timeout */
-	mod_timer(&cp->timer, jiffies+cp->timeout);
+	mod_timer(&cp->timer, jiffies+timeout);
 
 	__ip_vs_conn_put(cp);
 }
@@ -653,7 +661,7 @@ static void ip_vs_conn_expire(unsigned l
 	/*
 	 *	unhash it if it is hashed in the conn table
 	 */
-	if (!ip_vs_conn_unhash(cp))
+	if (!ip_vs_conn_unhash(cp) && !(cp->flags & IP_VS_CONN_F_ONE_PACKET))
 		goto expire_later;
 
 	/*
Index: net-2.6/net/netfilter/ipvs/ip_vs_core.c
===================================================================
--- net-2.6.orig/net/netfilter/ipvs/ip_vs_core.c
+++ net-2.6/net/netfilter/ipvs/ip_vs_core.c
@@ -176,6 +176,13 @@ ip_vs_set_state(struct ip_vs_conn *cp, i
 	return pp->state_transition(cp, direction, skb, pp);
 }
 
+static inline __u16
+ip_vs_onepacket_enabled(struct ip_vs_service *svc, struct ip_vs_iphdr *iph)
+{
+	return (svc->flags & IP_VS_SVC_F_ONEPACKET
+		&& iph->protocol == IPPROTO_UDP)
+		? IP_VS_CONN_F_ONE_PACKET : 0;
+}
 
 /*
  *  IPVS persistent scheduling function
@@ -347,7 +354,7 @@ ip_vs_sched_persist(struct ip_vs_service
 			    &iph.saddr, ports[0],
 			    &iph.daddr, ports[1],
 			    &dest->addr, dport,
-			    0,
+			    ip_vs_onepacket_enabled(svc, &iph),
 			    dest);
 	if (cp == NULL) {
 		ip_vs_conn_put(ct);
@@ -414,7 +421,7 @@ ip_vs_schedule(struct ip_vs_service *svc
 			    &iph.saddr, pptr[0],
 			    &iph.daddr, pptr[1],
 			    &dest->addr, dest->port ? dest->port : pptr[1],
-			    0,
+			    ip_vs_onepacket_enabled(svc, &iph),
 			    dest);
 	if (cp == NULL)
 		return NULL;
@@ -474,7 +481,8 @@ int ip_vs_leave(struct ip_vs_service *sv
 				    &iph.saddr, pptr[0],
 				    &iph.daddr, pptr[1],
 				    &daddr, 0,
-				    IP_VS_CONN_F_BYPASS,
+				    IP_VS_CONN_F_BYPASS |
+				    ip_vs_onepacket_enabled(svc, &iph),
 				    NULL);
 		if (cp == NULL)
 			return NF_DROP;
Index: net-2.6/net/netfilter/ipvs/ip_vs_ctl.c
===================================================================
--- net-2.6.orig/net/netfilter/ipvs/ip_vs_ctl.c
+++ net-2.6/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1857,21 +1857,27 @@ static int ip_vs_info_seq_show(struct se
 		if (iter->table == ip_vs_svc_table) {
 #ifdef CONFIG_IP_VS_IPV6
 			if (svc->af == AF_INET6)
-				seq_printf(seq, "%s  [%pI6]:%04X %s ",
+				seq_printf(seq, "%s  [%pI6]:%04X %s%s ",
 					   ip_vs_proto_name(svc->protocol),
 					   &svc->addr.in6,
 					   ntohs(svc->port),
-					   svc->scheduler->name);
+					   svc->scheduler->name,
+					   (svc->flags & IP_VS_SVC_F_ONEPACKET)?
+					   " ops":"");
 			else
 #endif
-				seq_printf(seq, "%s  %08X:%04X %s ",
+				seq_printf(seq, "%s  %08X:%04X %s%s ",
 					   ip_vs_proto_name(svc->protocol),
 					   ntohl(svc->addr.ip),
 					   ntohs(svc->port),
-					   svc->scheduler->name);
+					   svc->scheduler->name,
+					   (svc->flags & IP_VS_SVC_F_ONEPACKET)?
+					   " ops":"");
 		} else {
-			seq_printf(seq, "FWM  %08X %s ",
-				   svc->fwmark, svc->scheduler->name);
+			seq_printf(seq, "FWM  %08X %s%s ",
+				   svc->fwmark, svc->scheduler->name,
+				   (svc->flags & IP_VS_SVC_F_ONEPACKET)?
+				   " ops":"");
 		}
 
 		if (svc->flags & IP_VS_SVC_F_PERSISTENT)
