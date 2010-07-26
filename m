From: Simon Horman <horms@verge.net.au>
Subject: [patch] ipvs: provide default ip_vs_conn_{in,out}_get_proto
Date: Mon, 26 Jul 2010 16:56:32 +0900
Message-ID: <20100726075632.GB11755@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

This removes duplicate code by providing a default implementation
which is used by 3 of the 4 modules that provide these call.

Signed-off-by: Simon Horman <horms@verge.net.au>

 include/net/ip_vs.h                   |   12 +++++++
 net/netfilter/ipvs/ip_vs_conn.c       |   45 ++++++++++++++++++++++++++
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   53 +------------------------------
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |   50 +----------------------------
 net/netfilter/ipvs/ip_vs_proto_udp.c  |   56 +--------------------------------
 5 files changed, 63 insertions(+), 153 deletions(-)

Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_proto_sctp.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_proto_sctp.c	2010-07-18 15:16:58.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_proto_sctp.c	2010-07-18 15:17:01.000000000 +0900
@@ -8,55 +8,6 @@
 #include <net/sctp/checksum.h>
 #include <net/ip_vs.h>
 
-
-static struct ip_vs_conn *
-sctp_conn_in_get(int af,
-		 const struct sk_buff *skb,
-		 struct ip_vs_protocol *pp,
-		 const struct ip_vs_iphdr *iph,
-		 unsigned int proto_off,
-		 int inverse)
-{
-	__be16 _ports[2], *pptr;
-
-	pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
-	if (pptr == NULL)
-		return NULL;
-
-	if (likely(!inverse)) 
-		return ip_vs_conn_in_get(af, iph->protocol,
-					 &iph->saddr, pptr[0],
-					 &iph->daddr, pptr[1]);
-	else 
-		return ip_vs_conn_in_get(af, iph->protocol,
-					 &iph->daddr, pptr[1],
-					 &iph->saddr, pptr[0]);
-}
-
-static struct ip_vs_conn *
-sctp_conn_out_get(int af,
-		  const struct sk_buff *skb,
-		  struct ip_vs_protocol *pp,
-		  const struct ip_vs_iphdr *iph,
-		  unsigned int proto_off,
-		  int inverse)
-{
-	__be16 _ports[2], *pptr;
-
-	pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
-	if (pptr == NULL)
-		return NULL;
-
-	if (likely(!inverse)) 
-		return ip_vs_conn_out_get(af, iph->protocol,
-					  &iph->saddr, pptr[0],
-					  &iph->daddr, pptr[1]);
-	else 
-		return ip_vs_conn_out_get(af, iph->protocol,
-					  &iph->daddr, pptr[1],
-					  &iph->saddr, pptr[0]);
-}
-
 static int
 sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		   int *verdict, struct ip_vs_conn **cpp)
@@ -1169,8 +1120,8 @@ struct ip_vs_protocol ip_vs_protocol_sct
 	.register_app = sctp_register_app,
 	.unregister_app = sctp_unregister_app,
 	.conn_schedule = sctp_conn_schedule,
-	.conn_in_get = sctp_conn_in_get,
-	.conn_out_get = sctp_conn_out_get,
+	.conn_in_get = ip_vs_conn_in_get_proto,
+	.conn_out_get = ip_vs_conn_out_get_proto,
 	.snat_handler = sctp_snat_handler,
 	.dnat_handler = sctp_dnat_handler,
 	.csum_check = sctp_csum_check,
Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_proto_tcp.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_proto_tcp.c	2010-07-18 15:16:58.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_proto_tcp.c	2010-07-18 15:17:01.000000000 +0900
@@ -27,52 +27,6 @@
 
 #include <net/ip_vs.h>
 
-
-static struct ip_vs_conn *
-tcp_conn_in_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
-		const struct ip_vs_iphdr *iph, unsigned int proto_off,
-		int inverse)
-{
-	__be16 _ports[2], *pptr;
-
-	pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
-	if (pptr == NULL)
-		return NULL;
-
-	if (likely(!inverse)) {
-		return ip_vs_conn_in_get(af, iph->protocol,
-					 &iph->saddr, pptr[0],
-					 &iph->daddr, pptr[1]);
-	} else {
-		return ip_vs_conn_in_get(af, iph->protocol,
-					 &iph->daddr, pptr[1],
-					 &iph->saddr, pptr[0]);
-	}
-}
-
-static struct ip_vs_conn *
-tcp_conn_out_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
-		 const struct ip_vs_iphdr *iph, unsigned int proto_off,
-		 int inverse)
-{
-	__be16 _ports[2], *pptr;
-
-	pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
-	if (pptr == NULL)
-		return NULL;
-
-	if (likely(!inverse)) {
-		return ip_vs_conn_out_get(af, iph->protocol,
-					  &iph->saddr, pptr[0],
-					  &iph->daddr, pptr[1]);
-	} else {
-		return ip_vs_conn_out_get(af, iph->protocol,
-					  &iph->daddr, pptr[1],
-					  &iph->saddr, pptr[0]);
-	}
-}
-
-
 static int
 tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		  int *verdict, struct ip_vs_conn **cpp)
@@ -721,8 +675,8 @@ struct ip_vs_protocol ip_vs_protocol_tcp
 	.register_app =		tcp_register_app,
 	.unregister_app =	tcp_unregister_app,
 	.conn_schedule =	tcp_conn_schedule,
-	.conn_in_get =		tcp_conn_in_get,
-	.conn_out_get =		tcp_conn_out_get,
+	.conn_in_get =		ip_vs_conn_in_get_proto,
+	.conn_out_get =		ip_vs_conn_out_get_proto,
 	.snat_handler =		tcp_snat_handler,
 	.dnat_handler =		tcp_dnat_handler,
 	.csum_check =		tcp_csum_check,
Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_proto_udp.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_proto_udp.c	2010-07-18 15:16:58.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_proto_udp.c	2010-07-18 15:17:01.000000000 +0900
@@ -27,58 +27,6 @@
 #include <net/ip.h>
 #include <net/ip6_checksum.h>
 
-static struct ip_vs_conn *
-udp_conn_in_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
-		const struct ip_vs_iphdr *iph, unsigned int proto_off,
-		int inverse)
-{
-	struct ip_vs_conn *cp;
-	__be16 _ports[2], *pptr;
-
-	pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
-	if (pptr == NULL)
-		return NULL;
-
-	if (likely(!inverse)) {
-		cp = ip_vs_conn_in_get(af, iph->protocol,
-				       &iph->saddr, pptr[0],
-				       &iph->daddr, pptr[1]);
-	} else {
-		cp = ip_vs_conn_in_get(af, iph->protocol,
-				       &iph->daddr, pptr[1],
-				       &iph->saddr, pptr[0]);
-	}
-
-	return cp;
-}
-
-
-static struct ip_vs_conn *
-udp_conn_out_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
-		 const struct ip_vs_iphdr *iph, unsigned int proto_off,
-		 int inverse)
-{
-	struct ip_vs_conn *cp;
-	__be16 _ports[2], *pptr;
-
-	pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
-	if (pptr == NULL)
-		return NULL;
-
-	if (likely(!inverse)) {
-		cp = ip_vs_conn_out_get(af, iph->protocol,
-					&iph->saddr, pptr[0],
-					&iph->daddr, pptr[1]);
-	} else {
-		cp = ip_vs_conn_out_get(af, iph->protocol,
-					&iph->daddr, pptr[1],
-					&iph->saddr, pptr[0]);
-	}
-
-	return cp;
-}
-
-
 static int
 udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		  int *verdict, struct ip_vs_conn **cpp)
@@ -520,8 +468,8 @@ struct ip_vs_protocol ip_vs_protocol_udp
 	.init =			udp_init,
 	.exit =			udp_exit,
 	.conn_schedule =	udp_conn_schedule,
-	.conn_in_get =		udp_conn_in_get,
-	.conn_out_get =		udp_conn_out_get,
+	.conn_in_get =		ip_vs_conn_in_get_proto,
+	.conn_out_get =		ip_vs_conn_out_get_proto,
 	.snat_handler =		udp_snat_handler,
 	.dnat_handler =		udp_dnat_handler,
 	.csum_check =		udp_csum_check,
Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_conn.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c	2010-07-18 15:16:58.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_conn.c	2010-07-18 16:37:44.000000000 +0900
@@ -271,6 +271,29 @@ struct ip_vs_conn *ip_vs_conn_in_get
 	return cp;
 }
 
+struct ip_vs_conn *
+ip_vs_conn_in_get_proto(int af, const struct sk_buff *skb,
+			struct ip_vs_protocol *pp,
+			const struct ip_vs_iphdr *iph,
+			unsigned int proto_off, int inverse)
+{
+	__be16 _ports[2], *pptr;
+
+	pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
+	if (pptr == NULL)
+		return NULL;
+
+	if (likely(!inverse))
+		return ip_vs_conn_in_get(af, iph->protocol,
+					 &iph->saddr, pptr[0],
+					 &iph->daddr, pptr[1]);
+	else
+		return ip_vs_conn_in_get(af, iph->protocol,
+					 &iph->daddr, pptr[1],
+					 &iph->saddr, pptr[0]);
+}
+EXPORT_SYMBOL_GPL(ip_vs_conn_in_get_proto);
+
 /* Get reference to connection template */
 struct ip_vs_conn *ip_vs_ct_in_get
 (int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
@@ -356,6 +379,28 @@ struct ip_vs_conn *ip_vs_conn_out_get
 	return ret;
 }
 
+struct ip_vs_conn *
+ip_vs_conn_out_get_proto(int af, const struct sk_buff *skb,
+			 struct ip_vs_protocol *pp,
+			 const struct ip_vs_iphdr *iph,
+			 unsigned int proto_off, int inverse)
+{
+	__be16 _ports[2], *pptr;
+
+	pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
+	if (pptr == NULL)
+		return NULL;
+
+	if (likely(!inverse))
+		return ip_vs_conn_out_get(af, iph->protocol,
+					  &iph->saddr, pptr[0],
+					  &iph->daddr, pptr[1]);
+	else
+		return ip_vs_conn_out_get(af, iph->protocol,
+					  &iph->daddr, pptr[1],
+					  &iph->saddr, pptr[0]);
+}
+EXPORT_SYMBOL_GPL(ip_vs_conn_out_get_proto);
 
 /*
  *      Put back the conn and restart its timer with its timeout
Index: nf-next-2.6/include/net/ip_vs.h
===================================================================
--- nf-next-2.6.orig/include/net/ip_vs.h	2010-07-18 15:16:58.000000000 +0900
+++ nf-next-2.6/include/net/ip_vs.h	2010-07-18 16:37:44.000000000 +0900
@@ -632,10 +632,22 @@ extern struct ip_vs_conn *ip_vs_ct_in_ge
 (int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
  const union nf_inet_addr *d_addr, __be16 d_port);
 
+struct ip_vs_conn * ip_vs_conn_in_get_proto(int af, const struct sk_buff *skb,
+					    struct ip_vs_protocol *pp,
+					    const struct ip_vs_iphdr *iph,
+					    unsigned int proto_off,
+					    int inverse);
+
 extern struct ip_vs_conn *ip_vs_conn_out_get
 (int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
  const union nf_inet_addr *d_addr, __be16 d_port);
 
+struct ip_vs_conn * ip_vs_conn_out_get_proto(int af, const struct sk_buff *skb,
+					     struct ip_vs_protocol *pp,
+					     const struct ip_vs_iphdr *iph,
+					     unsigned int proto_off,
+					     int inverse);
+
 /* put back the conn without restarting its timer */
 static inline void __ip_vs_conn_put(struct ip_vs_conn *cp)
 {
