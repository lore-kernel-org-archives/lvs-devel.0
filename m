From: Simon Horman <horms@verge.net.au>
Subject: [patch nf-next-2.6] IPVS: one-packet scheduling
Date: Tue, 22 Jun 2010 11:14:12 +0900
Message-ID: <20100622021405.GA19071@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Nick Chalk <nick@loadbalancer.org>

From: Nick Chalk <nick@loadbalancer.org>

IPVS: one-packet scheduling

Allow one-packet scheduling for UDP connections. When the fwmark-based or
normal virtual service is marked with '-o' or '--ops' options all
connections are created only to schedule one packet. Useful to schedule UDP
packets from same client port to different real servers. Recommended with
RR or WRR schedulers (the connections are not visible with ipvsadm -L).

Signed-off-by: Nick Chalk <nick@loadbalancer.org>
Signed-off-by: Simon Horman <horms@verge.net.au>

--- 
U
Up-port of http://www.ssi.bg/~ja/tmp/ops-2.4.32-1.diff

Patrick, you asked me to repost this when nf-next was open again.
It seems to be open now.

Index: nf-next-2.6/include/linux/ip_vs.h
===================================================================
--- nf-next-2.6.orig/include/linux/ip_vs.h	2010-05-19 11:59:32.000000000 +0900
+++ nf-next-2.6/include/linux/ip_vs.h	2010-05-19 12:06:23.000000000 +0900
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
Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_conn.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c	2010-05-19 11:59:32.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_conn.c	2010-05-19 12:06:23.000000000 +0900
@@ -158,6 +158,9 @@ static inline int ip_vs_conn_hash(struct
 	unsigned hash;
 	int ret;
 
+	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
+		return 0;
+
 	/* Hash by protocol, client address and port */
 	hash = ip_vs_conn_hashkey(cp->af, cp->protocol, &cp->caddr, cp->cport);
 
@@ -355,8 +358,9 @@ struct ip_vs_conn *ip_vs_conn_out_get
  */
 void ip_vs_conn_put(struct ip_vs_conn *cp)
 {
-	/* reset it expire in its timeout */
-	mod_timer(&cp->timer, jiffies+cp->timeout);
+	unsigned long t = (cp->flags & IP_VS_CONN_F_ONE_PACKET) ?
+		0 : cp->timeout;
+	mod_timer(&cp->timer, jiffies+t);
 
 	__ip_vs_conn_put(cp);
 }
@@ -649,7 +653,7 @@ static void ip_vs_conn_expire(unsigned l
 	/*
 	 *	unhash it if it is hashed in the conn table
 	 */
-	if (!ip_vs_conn_unhash(cp))
+	if (!ip_vs_conn_unhash(cp) && !(cp->flags & IP_VS_CONN_F_ONE_PACKET))
 		goto expire_later;
 
 	/*
Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_core.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_core.c	2010-05-19 11:59:32.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_core.c	2010-05-19 12:08:08.000000000 +0900
@@ -194,6 +194,7 @@ ip_vs_sched_persist(struct ip_vs_service
 	struct ip_vs_dest *dest;
 	struct ip_vs_conn *ct;
 	__be16  dport;			/* destination port to forward */
+	__be16  flags;
 	union nf_inet_addr snet;	/* source network of the client,
					   after masking */
 
@@ -340,6 +341,10 @@ ip_vs_sched_persist(struct ip_vs_service
 		dport = ports[1];
 	}
 
+	flags = (svc->flags & IP_VS_SVC_F_ONEPACKET
+		 && iph.protocol == IPPROTO_UDP)?
+		IP_VS_CONN_F_ONE_PACKET : 0;
+
 	/*
 	 *    Create a new connection according to the template
 	 */
@@ -347,7 +352,7 @@ ip_vs_sched_persist(struct ip_vs_service
 			    &iph.saddr, ports[0],
 			    &iph.daddr, ports[1],
 			    &dest->addr, dport,
-			    0,
+			    flags,
 			    dest);
 	if (cp == NULL) {
 		ip_vs_conn_put(ct);
@@ -377,7 +382,7 @@ ip_vs_schedule(struct ip_vs_service *svc
 	struct ip_vs_conn *cp = NULL;
 	struct ip_vs_iphdr iph;
 	struct ip_vs_dest *dest;
-	__be16 _ports[2], *pptr;
+	__be16 _ports[2], *pptr, flags;
 
 	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 	pptr = skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
@@ -407,6 +412,10 @@ ip_vs_schedule(struct ip_vs_service *svc
 		return NULL;
 	}
 
+	flags = (svc->flags & IP_VS_SVC_F_ONEPACKET
+		 && iph.protocol == IPPROTO_UDP)?
+		IP_VS_CONN_F_ONE_PACKET : 0;
+
 	/*
 	 *    Create a connection entry.
 	 */
@@ -414,7 +423,7 @@ ip_vs_schedule(struct ip_vs_service *svc
 			    &iph.saddr, pptr[0],
 			    &iph.daddr, pptr[1],
 			    &dest->addr, dest->port ? dest->port : pptr[1],
-			    0,
+			    flags,
 			    dest);
 	if (cp == NULL)
 		return NULL;
@@ -464,6 +473,9 @@ int ip_vs_leave(struct ip_vs_service *sv
 	if (sysctl_ip_vs_cache_bypass && svc->fwmark && unicast) {
 		int ret, cs;
 		struct ip_vs_conn *cp;
+		__u16 flags = (svc->flags & IP_VS_SVC_F_ONEPACKET &&
+				iph.protocol == IPPROTO_UDP)?
+				IP_VS_CONN_F_ONE_PACKET : 0;
 		union nf_inet_addr daddr =  { .all = { 0, 0, 0, 0 } };
 
 		ip_vs_service_put(svc);
@@ -474,7 +486,7 @@ int ip_vs_leave(struct ip_vs_service *sv
 				    &iph.saddr, pptr[0],
 				    &iph.daddr, pptr[1],
 				    &daddr, 0,
-				    IP_VS_CONN_F_BYPASS,
+				    IP_VS_CONN_F_BYPASS | flags,
 				    NULL);
 		if (cp == NULL)
 			return NF_DROP;
Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_ctl.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_ctl.c	2010-05-19 11:59:32.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_ctl.c	2010-05-19 12:06:23.000000000 +0900
@@ -1864,14 +1864,16 @@ static int ip_vs_info_seq_show(struct se
 					   svc->scheduler->name);
 			else
 #endif
-				seq_printf(seq, "%s  %08X:%04X %s ",
+				seq_printf(seq, "%s  %08X:%04X %s %s ",
 					   ip_vs_proto_name(svc->protocol),
 					   ntohl(svc->addr.ip),
 					   ntohs(svc->port),
-					   svc->scheduler->name);
+					   svc->scheduler->name,
+					   (svc->flags & IP_VS_SVC_F_ONEPACKET)?"ops ":"");
 		} else {
-			seq_printf(seq, "FWM  %08X %s ",
-				   svc->fwmark, svc->scheduler->name);
+			seq_printf(seq, "FWM  %08X %s %s",
+				   svc->fwmark, svc->scheduler->name,
+				   (svc->flags & IP_VS_SVC_F_ONEPACKET)?"ops ":"");
 		}
 
 		if (svc->flags & IP_VS_SVC_F_PERSISTENT)

--
To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
