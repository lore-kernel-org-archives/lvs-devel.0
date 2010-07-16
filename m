From: Simon Horman <horms@verge.net.au>
Subject: [rfc] ipvs: Add ip_vs_onepacket_enabled()
Date: Fri, 16 Jul 2010 17:30:35 +0900
Message-ID: <20100716083035.GA30888@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Graf <tgraf@infradead.org>
Cc: Nick Chalk <nick@loadbalancer.org>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

Add ip_vs_onepacket_enabled() instead of open-coding the logic three times.

Signed-off-by: Simon Horman <horms@verge.net.au>

--- 

Compile tested only.

Extracted from a patch by Thomas Graf <tgraf@infradead.org>.
Thomas, feel free to make this patch from you and add a signed-off-by line.

Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_core.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_core.c	2010-07-16 16:44:49.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_core.c	2010-07-16 16:45:20.000000000 +0900
@@ -165,7 +165,6 @@ ip_vs_conn_stats(struct ip_vs_conn *cp,
 	spin_unlock(&ip_vs_stats.lock);
 }
 
-
 static inline int
 ip_vs_set_state(struct ip_vs_conn *cp, int direction,
 		const struct sk_buff *skb,
@@ -176,6 +175,12 @@ ip_vs_set_state(struct ip_vs_conn *cp, i
 	return pp->state_transition(cp, direction, skb, pp);
 }
 
+static inline __u16
+ip_vs_onepacket_enabled(struct ip_vs_service *svc, struct ip_vs_iphdr iph)
+{
+	return (svc->flags & IP_VS_SVC_F_ONEPACKET &&
+		iph->protocol == IPPROTO_UDP) ? IP_VS_CONN_F_ONE_PACKET : 0;
+}
 
 /*
  *  IPVS persistent scheduling function
@@ -194,7 +199,6 @@ ip_vs_sched_persist(struct ip_vs_service
 	struct ip_vs_dest *dest;
 	struct ip_vs_conn *ct;
 	__be16  dport;			/* destination port to forward */
-	__be16  flags;
 	union nf_inet_addr snet;	/* source network of the client,
 					   after masking */
 
@@ -341,10 +345,6 @@ ip_vs_sched_persist(struct ip_vs_service
 		dport = ports[1];
 	}
 
-	flags = (svc->flags & IP_VS_SVC_F_ONEPACKET
-		 && iph.protocol == IPPROTO_UDP)?
-		IP_VS_CONN_F_ONE_PACKET : 0;
-
 	/*
 	 *    Create a new connection according to the template
 	 */
@@ -352,7 +352,7 @@ ip_vs_sched_persist(struct ip_vs_service
 			    &iph.saddr, ports[0],
 			    &iph.daddr, ports[1],
 			    &dest->addr, dport,
-			    flags,
+			    ip_vs_onepacket_enabled(svc, &iph),
 			    dest);
 	if (cp == NULL) {
 		ip_vs_conn_put(ct);
@@ -382,7 +382,7 @@ ip_vs_schedule(struct ip_vs_service *svc
 	struct ip_vs_conn *cp = NULL;
 	struct ip_vs_iphdr iph;
 	struct ip_vs_dest *dest;
-	__be16 _ports[2], *pptr, flags;
+	__be16 _ports[2], *pptr;
 
 	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 	pptr = skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
@@ -412,10 +412,6 @@ ip_vs_schedule(struct ip_vs_service *svc
 		return NULL;
 	}
 
-	flags = (svc->flags & IP_VS_SVC_F_ONEPACKET
-		 && iph.protocol == IPPROTO_UDP)?
-		IP_VS_CONN_F_ONE_PACKET : 0;
-
 	/*
 	 *    Create a connection entry.
 	 */
@@ -423,7 +419,7 @@ ip_vs_schedule(struct ip_vs_service *svc
 			    &iph.saddr, pptr[0],
 			    &iph.daddr, pptr[1],
 			    &dest->addr, dest->port ? dest->port : pptr[1],
-			    flags,
+			    ip_vs_onepacket_enabled(svc, &iph),
 			    dest);
 	if (cp == NULL)
 		return NULL;
@@ -473,9 +469,6 @@ int ip_vs_leave(struct ip_vs_service *sv
 	if (sysctl_ip_vs_cache_bypass && svc->fwmark && unicast) {
 		int ret, cs;
 		struct ip_vs_conn *cp;
-		__u16 flags = (svc->flags & IP_VS_SVC_F_ONEPACKET &&
-				iph.protocol == IPPROTO_UDP)?
-				IP_VS_CONN_F_ONE_PACKET : 0;
 		union nf_inet_addr daddr =  { .all = { 0, 0, 0, 0 } };
 
 		ip_vs_service_put(svc);
@@ -486,7 +479,8 @@ int ip_vs_leave(struct ip_vs_service *sv
 				    &iph.saddr, pptr[0],
 				    &iph.daddr, pptr[1],
 				    &daddr, 0,
-				    IP_VS_CONN_F_BYPASS | flags,
+				    IP_VS_CONN_F_BYPASS,
+				    ip_vs_onepacket_enabled(svc, &iph),
 				    NULL);
 		if (cp == NULL)
 			return NF_DROP;
