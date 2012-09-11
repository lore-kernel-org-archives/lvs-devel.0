From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH V3 7/8] ipvs: API change to avoid rescan of IPv6 exthdr
Date: Tue, 11 Sep 2012 14:38:56 +0200
Message-ID: <20120911123827.4305.81205.stgit@dragon>
References: <20120911123531.4305.40304.stgit@dragon>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20120911123531.4305.40304.stgit@dragon>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Hans Schillstrom <hans@schillstrom.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Thomas Graf <tgraf@suug.ch>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

Reduce the number of times we scan/skip the IPv6 exthdrs.

This patch contains a lot of API changes.  This is done, to avoid
repeating the scan of finding the IPv6 headers, via ipv6_find_hdr(),
which is called by ip_vs_fill_iph_skb().

Finding the IPv6 headers is done as early as possible, and passed on
as a pointer "struct ip_vs_iphdr *" to the affected functions.

This patch reduce/removes 19 calls to ip_vs_fill_iph_skb().

Notice, I have choosen, not to change the API of function
pointer "(*schedule)" (in struct ip_vs_scheduler) as it can be
used by external schedulers, via {un,}register_ip_vs_scheduler.
Only 4 out of 10 schedulers use info from ip_vs_iphdr*, and when
they do, they are only interested in iph->{s,d}addr.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
V3:
 - This patch is introduced in V3, to allow easier integration of
   Patricks idea and my RFC patch of caching exthdr info in skb->cb[]


 include/net/ip_vs.h                     |   81 +++++++++++-----------
 net/netfilter/ipvs/ip_vs_conn.c         |   15 ++--
 net/netfilter/ipvs/ip_vs_core.c         |  116 ++++++++++++++-----------------
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |    9 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |   42 ++++-------
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |   40 ++++-------
 net/netfilter/ipvs/ip_vs_proto_udp.c    |   41 ++++-------
 net/netfilter/ipvs/ip_vs_xmit.c         |   61 +++++++---------
 net/netfilter/xt_ipvs.c                 |    2 -
 9 files changed, 177 insertions(+), 230 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 98806b6..a681ad6 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -487,27 +487,26 @@ struct ip_vs_protocol {
 
 	int (*conn_schedule)(int af, struct sk_buff *skb,
 			     struct ip_vs_proto_data *pd,
-			     int *verdict, struct ip_vs_conn **cpp);
+			     int *verdict, struct ip_vs_conn **cpp,
+			     struct ip_vs_iphdr *iph);
 
 	struct ip_vs_conn *
 	(*conn_in_get)(int af,
 		       const struct sk_buff *skb,
 		       const struct ip_vs_iphdr *iph,
-		       unsigned int proto_off,
 		       int inverse);
 
 	struct ip_vs_conn *
 	(*conn_out_get)(int af,
 			const struct sk_buff *skb,
 			const struct ip_vs_iphdr *iph,
-			unsigned int proto_off,
 			int inverse);
 
-	int (*snat_handler)(struct sk_buff *skb,
-			    struct ip_vs_protocol *pp, struct ip_vs_conn *cp);
+	int (*snat_handler)(struct sk_buff *skb, struct ip_vs_protocol *pp,
+			    struct ip_vs_conn *cp, struct ip_vs_iphdr *iph);
 
-	int (*dnat_handler)(struct sk_buff *skb,
-			    struct ip_vs_protocol *pp, struct ip_vs_conn *cp);
+	int (*dnat_handler)(struct sk_buff *skb, struct ip_vs_protocol *pp,
+			    struct ip_vs_conn *cp, struct ip_vs_iphdr *iph);
 
 	int (*csum_check)(int af, struct sk_buff *skb,
 			  struct ip_vs_protocol *pp);
@@ -607,7 +606,7 @@ struct ip_vs_conn {
 	   NF_ACCEPT can be returned when destination is local.
 	 */
 	int (*packet_xmit)(struct sk_buff *skb, struct ip_vs_conn *cp,
-			   struct ip_vs_protocol *pp);
+			   struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
 
 	/* Note: we can group the following members into a structure,
 	   in order to save more space, and the following members are
@@ -858,13 +857,11 @@ struct ip_vs_app {
 
 	struct ip_vs_conn *
 	(*conn_in_get)(const struct sk_buff *skb, struct ip_vs_app *app,
-		       const struct iphdr *iph, unsigned int proto_off,
-		       int inverse);
+		       const struct iphdr *iph, int inverse);
 
 	struct ip_vs_conn *
 	(*conn_out_get)(const struct sk_buff *skb, struct ip_vs_app *app,
-			const struct iphdr *iph, unsigned int proto_off,
-			int inverse);
+			const struct iphdr *iph, int inverse);
 
 	int (*state_transition)(struct ip_vs_conn *cp, int direction,
 				const struct sk_buff *skb,
@@ -1163,14 +1160,12 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p);
 
 struct ip_vs_conn * ip_vs_conn_in_get_proto(int af, const struct sk_buff *skb,
 					    const struct ip_vs_iphdr *iph,
-					    unsigned int proto_off,
 					    int inverse);
 
 struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p);
 
 struct ip_vs_conn * ip_vs_conn_out_get_proto(int af, const struct sk_buff *skb,
 					     const struct ip_vs_iphdr *iph,
-					     unsigned int proto_off,
 					     int inverse);
 
 /* put back the conn without restarting its timer */
@@ -1343,9 +1338,10 @@ extern struct ip_vs_scheduler *ip_vs_scheduler_get(const char *sched_name);
 extern void ip_vs_scheduler_put(struct ip_vs_scheduler *scheduler);
 extern struct ip_vs_conn *
 ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
-	       struct ip_vs_proto_data *pd, int *ignored);
+	       struct ip_vs_proto_data *pd, int *ignored,
+	       struct ip_vs_iphdr *iph);
 extern int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
-			struct ip_vs_proto_data *pd);
+			struct ip_vs_proto_data *pd, struct ip_vs_iphdr *iph);
 
 extern void ip_vs_scheduler_err(struct ip_vs_service *svc, const char *msg);
 
@@ -1404,33 +1400,38 @@ extern void ip_vs_read_estimator(struct ip_vs_stats_user *dst,
 /*
  *	Various IPVS packet transmitters (from ip_vs_xmit.c)
  */
-extern int ip_vs_null_xmit
-(struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
-extern int ip_vs_bypass_xmit
-(struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
-extern int ip_vs_nat_xmit
-(struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
-extern int ip_vs_tunnel_xmit
-(struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
-extern int ip_vs_dr_xmit
-(struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
-extern int ip_vs_icmp_xmit
-(struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp,
- int offset, unsigned int hooknum);
+extern int ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
+			   struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+extern int ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
+			     struct ip_vs_protocol *pp,
+			     struct ip_vs_iphdr *iph);
+extern int ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
+			  struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+extern int ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
+			     struct ip_vs_protocol *pp,
+			     struct ip_vs_iphdr *iph);
+extern int ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
+			 struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+extern int ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
+			   struct ip_vs_protocol *pp, int offset,
+			   unsigned int hooknum, struct ip_vs_iphdr *iph);
 extern void ip_vs_dst_reset(struct ip_vs_dest *dest);
 
 #ifdef CONFIG_IP_VS_IPV6
-extern int ip_vs_bypass_xmit_v6
-(struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
-extern int ip_vs_nat_xmit_v6
-(struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
-extern int ip_vs_tunnel_xmit_v6
-(struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
-extern int ip_vs_dr_xmit_v6
-(struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
-extern int ip_vs_icmp_xmit_v6
-(struct sk_buff *skb, struct ip_vs_conn *cp, struct ip_vs_protocol *pp,
- int offset, unsigned int hooknum);
+extern int ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
+				struct ip_vs_protocol *pp,
+				struct ip_vs_iphdr *iph);
+extern int ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
+			     struct ip_vs_protocol *pp,
+			     struct ip_vs_iphdr *iph);
+extern int ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
+				struct ip_vs_protocol *pp,
+				struct ip_vs_iphdr *iph);
+extern int ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
+			    struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+extern int ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
+			      struct ip_vs_protocol *pp, int offset,
+			      unsigned int hooknum, struct ip_vs_iphdr *iph);
 #endif
 
 #ifdef CONFIG_SYSCTL
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index d6c1c26..30e764a 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -308,13 +308,12 @@ struct ip_vs_conn *ip_vs_conn_in_get(const struct ip_vs_conn_param *p)
 static int
 ip_vs_conn_fill_param_proto(int af, const struct sk_buff *skb,
 			    const struct ip_vs_iphdr *iph,
-			    unsigned int proto_off, int inverse,
-			    struct ip_vs_conn_param *p)
+			    int inverse, struct ip_vs_conn_param *p)
 {
 	__be16 _ports[2], *pptr;
 	struct net *net = skb_net(skb);
 
-	pptr = frag_safe_skb_hp(skb, proto_off, sizeof(_ports), _ports, iph);
+	pptr = frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports, iph);
 	if (pptr == NULL)
 		return 1;
 
@@ -329,12 +328,11 @@ ip_vs_conn_fill_param_proto(int af, const struct sk_buff *skb,
 
 struct ip_vs_conn *
 ip_vs_conn_in_get_proto(int af, const struct sk_buff *skb,
-			const struct ip_vs_iphdr *iph,
-			unsigned int proto_off, int inverse)
+			const struct ip_vs_iphdr *iph, int inverse)
 {
 	struct ip_vs_conn_param p;
 
-	if (ip_vs_conn_fill_param_proto(af, skb, iph, proto_off, inverse, &p))
+	if (ip_vs_conn_fill_param_proto(af, skb, iph, inverse, &p))
 		return NULL;
 
 	return ip_vs_conn_in_get(&p);
@@ -432,12 +430,11 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
 
 struct ip_vs_conn *
 ip_vs_conn_out_get_proto(int af, const struct sk_buff *skb,
-			 const struct ip_vs_iphdr *iph,
-			 unsigned int proto_off, int inverse)
+			 const struct ip_vs_iphdr *iph, int inverse)
 {
 	struct ip_vs_conn_param p;
 
-	if (ip_vs_conn_fill_param_proto(af, skb, iph, proto_off, inverse, &p))
+	if (ip_vs_conn_fill_param_proto(af, skb, iph, inverse, &p))
 		return NULL;
 
 	return ip_vs_conn_out_get(&p);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 4b9995e..f72d64f 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -222,11 +222,10 @@ ip_vs_conn_fill_param_persist(const struct ip_vs_service *svc,
  */
 static struct ip_vs_conn *
 ip_vs_sched_persist(struct ip_vs_service *svc,
-		    struct sk_buff *skb,
-		    __be16 src_port, __be16 dst_port, int *ignored)
+		    struct sk_buff *skb, __be16 src_port, __be16 dst_port,
+		    int *ignored, struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_conn *cp = NULL;
-	struct ip_vs_iphdr iph;
 	struct ip_vs_dest *dest;
 	struct ip_vs_conn *ct;
 	__be16 dport = 0;		/* destination port to forward */
@@ -236,20 +235,18 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	union nf_inet_addr snet;	/* source network of the client,
 					   after masking */
 
-	ip_vs_fill_iph_skb(svc->af, skb, &iph);
-
 	/* Mask saddr with the netmask to adjust template granularity */
 #ifdef CONFIG_IP_VS_IPV6
 	if (svc->af == AF_INET6)
-		ipv6_addr_prefix(&snet.in6, &iph.saddr.in6, svc->netmask);
+		ipv6_addr_prefix(&snet.in6, &iph->saddr.in6, svc->netmask);
 	else
 #endif
-		snet.ip = iph.saddr.ip & svc->netmask;
+		snet.ip = iph->saddr.ip & svc->netmask;
 
 	IP_VS_DBG_BUF(6, "p-schedule: src %s:%u dest %s:%u "
 		      "mnet %s\n",
-		      IP_VS_DBG_ADDR(svc->af, &iph.saddr), ntohs(src_port),
-		      IP_VS_DBG_ADDR(svc->af, &iph.daddr), ntohs(dst_port),
+		      IP_VS_DBG_ADDR(svc->af, &iph->saddr), ntohs(src_port),
+		      IP_VS_DBG_ADDR(svc->af, &iph->daddr), ntohs(dst_port),
 		      IP_VS_DBG_ADDR(svc->af, &snet));
 
 	/*
@@ -266,8 +263,8 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	 * is created for other persistent services.
 	 */
 	{
-		int protocol = iph.protocol;
-		const union nf_inet_addr *vaddr = &iph.daddr;
+		int protocol = iph->protocol;
+		const union nf_inet_addr *vaddr = &iph->daddr;
 		__be16 vport = 0;
 
 		if (dst_port == svc->port) {
@@ -342,14 +339,14 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 		dport = dest->port;
 
 	flags = (svc->flags & IP_VS_SVC_F_ONEPACKET
-		 && iph.protocol == IPPROTO_UDP)?
+		 && iph->protocol == IPPROTO_UDP) ?
 		IP_VS_CONN_F_ONE_PACKET : 0;
 
 	/*
 	 *    Create a new connection according to the template
 	 */
-	ip_vs_conn_fill_param(svc->net, svc->af, iph.protocol, &iph.saddr,
-			      src_port, &iph.daddr, dst_port, &param);
+	ip_vs_conn_fill_param(svc->net, svc->af, iph->protocol, &iph->saddr,
+			      src_port, &iph->daddr, dst_port, &param);
 
 	cp = ip_vs_conn_new(&param, &dest->addr, dport, flags, dest, skb->mark);
 	if (cp == NULL) {
@@ -392,22 +389,20 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
  */
 struct ip_vs_conn *
 ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
-	       struct ip_vs_proto_data *pd, int *ignored)
+	       struct ip_vs_proto_data *pd, int *ignored,
+	       struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_protocol *pp = pd->pp;
 	struct ip_vs_conn *cp = NULL;
-	struct ip_vs_iphdr iph;
 	struct ip_vs_dest *dest;
 	__be16 _ports[2], *pptr;
 	unsigned int flags;
 
 	*ignored = 1;
-
 	/*
 	 * IPv6 frags, only the first hit here.
 	 */
-	ip_vs_fill_iph_skb(svc->af, skb, &iph);
-	pptr = frag_safe_skb_hp(skb, iph.len, sizeof(_ports), _ports, &iph);
+	pptr = frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports, iph);
 	if (pptr == NULL)
 		return NULL;
 
@@ -427,7 +422,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	 *    Do not schedule replies from local real server.
 	 */
 	if ((!skb->dev || skb->dev->flags & IFF_LOOPBACK) &&
-	    (cp = pp->conn_in_get(svc->af, skb, &iph, iph.len, 1))) {
+	    (cp = pp->conn_in_get(svc->af, skb, iph, 1))) {
 		IP_VS_DBG_PKT(12, svc->af, pp, skb, 0,
 			      "Not scheduling reply for existing connection");
 		__ip_vs_conn_put(cp);
@@ -438,7 +433,8 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	 *    Persistent service
 	 */
 	if (svc->flags & IP_VS_SVC_F_PERSISTENT)
-		return ip_vs_sched_persist(svc, skb, pptr[0], pptr[1], ignored);
+		return ip_vs_sched_persist(svc, skb, pptr[0], pptr[1], ignored,
+					   iph);
 
 	*ignored = 0;
 
@@ -460,7 +456,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	}
 
 	flags = (svc->flags & IP_VS_SVC_F_ONEPACKET
-		 && iph.protocol == IPPROTO_UDP)?
+		 && iph->protocol == IPPROTO_UDP) ?
 		IP_VS_CONN_F_ONE_PACKET : 0;
 
 	/*
@@ -469,9 +465,9 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	{
 		struct ip_vs_conn_param p;
 
-		ip_vs_conn_fill_param(svc->net, svc->af, iph.protocol,
-				      &iph.saddr, pptr[0], &iph.daddr, pptr[1],
-				      &p);
+		ip_vs_conn_fill_param(svc->net, svc->af, iph->protocol,
+				      &iph->saddr, pptr[0], &iph->daddr,
+				      pptr[1], &p);
 		cp = ip_vs_conn_new(&p, &dest->addr,
 				    dest->port ? dest->port : pptr[1],
 				    flags, dest, skb->mark);
@@ -500,18 +496,16 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
  *  no destination is available for a new connection.
  */
 int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
-		struct ip_vs_proto_data *pd)
+		struct ip_vs_proto_data *pd, struct ip_vs_iphdr *iph)
 {
 	__be16 _ports[2], *pptr;
-	struct ip_vs_iphdr iph;
 #ifdef CONFIG_SYSCTL
 	struct net *net;
 	struct netns_ipvs *ipvs;
 	int unicast;
 #endif
 
-	ip_vs_fill_iph_skb(svc->af, skb, &iph);
-	pptr = frag_safe_skb_hp(skb, iph.len, sizeof(_ports), _ports, &iph);
+	pptr = frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports, iph);
 	if (pptr == NULL) {
 		ip_vs_service_put(svc);
 		return NF_DROP;
@@ -522,10 +516,10 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 
 #ifdef CONFIG_IP_VS_IPV6
 	if (svc->af == AF_INET6)
-		unicast = ipv6_addr_type(&iph.daddr.in6) & IPV6_ADDR_UNICAST;
+		unicast = ipv6_addr_type(&iph->daddr.in6) & IPV6_ADDR_UNICAST;
 	else
 #endif
-		unicast = (inet_addr_type(net, iph.daddr.ip) == RTN_UNICAST);
+		unicast = (inet_addr_type(net, iph->daddr.ip) == RTN_UNICAST);
 
 	/* if it is fwmark-based service, the cache_bypass sysctl is up
 	   and the destination is a non-local unicast, then create
@@ -535,7 +529,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		int ret;
 		struct ip_vs_conn *cp;
 		unsigned int flags = (svc->flags & IP_VS_SVC_F_ONEPACKET &&
-				      iph.protocol == IPPROTO_UDP)?
+				      iph->protocol == IPPROTO_UDP) ?
 				      IP_VS_CONN_F_ONE_PACKET : 0;
 		union nf_inet_addr daddr =  { .all = { 0, 0, 0, 0 } };
 
@@ -545,9 +539,9 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		IP_VS_DBG(6, "%s(): create a cache_bypass entry\n", __func__);
 		{
 			struct ip_vs_conn_param p;
-			ip_vs_conn_fill_param(svc->net, svc->af, iph.protocol,
-					      &iph.saddr, pptr[0],
-					      &iph.daddr, pptr[1], &p);
+			ip_vs_conn_fill_param(svc->net, svc->af, iph->protocol,
+					      &iph->saddr, pptr[0],
+					      &iph->daddr, pptr[1], &p);
 			cp = ip_vs_conn_new(&p, &daddr, 0,
 					    IP_VS_CONN_F_BYPASS | flags,
 					    NULL, skb->mark);
@@ -562,7 +556,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd);
 
 		/* transmit the first SYN packet */
-		ret = cp->packet_xmit(skb, cp, pd->pp);
+		ret = cp->packet_xmit(skb, cp, pd->pp, iph);
 		/* do not touch skb anymore */
 
 		atomic_inc(&cp->in_pkts);
@@ -911,7 +905,7 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
 	ip_vs_fill_ip4hdr(cih, &ciph);
 	ciph.len += offset;
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_out_get(AF_INET, skb, &ciph, offset, 1);
+	cp = pp->conn_out_get(AF_INET, skb, &ciph, 1);
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -922,7 +916,7 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
 
 #ifdef CONFIG_IP_VS_IPV6
 static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
-			     unsigned int hooknum)
+			     unsigned int hooknum, struct ip_vs_iphdr *ipvsh)
 {
 	struct icmp6hdr	_icmph, *ic;
 	struct ipv6hdr _ip6, *ip6;	/* The ip header contained
@@ -931,10 +925,6 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 	struct ip_vs_protocol *pp;
 	union nf_inet_addr snet;
 
-	struct ip_vs_iphdr ipvsh_stack;
-	struct ip_vs_iphdr *ipvsh = &ipvsh_stack;
-	ip_vs_fill_iph_skb(AF_INET6, skb, ipvsh);
-
 	*related = 1;
 	ic = frag_safe_skb_hp(skb, ipvsh->len, sizeof(_icmph), &_icmph, ipvsh);
 	if (ic == NULL)
@@ -977,7 +967,7 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 	ipvsh->daddr.in6 = ip6->daddr;
 
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_out_get(AF_INET6, skb, ipvsh, ipvsh->len, 1);
+	cp = pp->conn_out_get(AF_INET6, skb, ipvsh, 1);
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -1016,17 +1006,17 @@ static inline int is_tcp_reset(const struct sk_buff *skb, int nh_len)
  */
 static unsigned int
 handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
-		struct ip_vs_conn *cp, int ihl)
+		struct ip_vs_conn *cp, struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_protocol *pp = pd->pp;
 
 	IP_VS_DBG_PKT(11, af, pp, skb, 0, "Outgoing packet");
 
-	if (!skb_make_writable(skb, ihl))
+	if (!skb_make_writable(skb, iph->len))
 		goto drop;
 
 	/* mangle the packet */
-	if (pp->snat_handler && !pp->snat_handler(skb, pp, cp))
+	if (pp->snat_handler && !pp->snat_handler(skb, pp, cp, iph))
 		goto drop;
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1125,7 +1115,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
 			int related;
 			int verdict = ip_vs_out_icmp_v6(skb, &related,
-							hooknum);
+							hooknum, &iph);
 
 			if (related)
 				return verdict;
@@ -1160,10 +1150,10 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	/*
 	 * Check if the packet belongs to an existing entry
 	 */
-	cp = pp->conn_out_get(af, skb, &iph, iph.len, 0);
+	cp = pp->conn_out_get(af, skb, &iph, 0);
 
 	if (likely(cp))
-		return handle_response(af, skb, pd, cp, iph.len);
+		return handle_response(af, skb, pd, cp, &iph);
 	if (sysctl_nat_icmp_send(net) &&
 	    (pp->protocol == IPPROTO_TCP ||
 	     pp->protocol == IPPROTO_UDP ||
@@ -1375,7 +1365,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	/* The embedded headers contain source and dest in reverse order.
 	 * For IPIP this is error for request, not for reply.
 	 */
-	cp = pp->conn_in_get(AF_INET, skb, &ciph, offset, ipip ? 0 : 1);
+	cp = pp->conn_in_get(AF_INET, skb, &ciph, ipip ? 0 : 1);
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -1444,7 +1434,7 @@ ignore_ipip:
 	ip_vs_in_stats(cp, skb);
 	if (IPPROTO_TCP == cih->protocol || IPPROTO_UDP == cih->protocol)
 		offset += 2 * sizeof(__u16);
-	verdict = ip_vs_icmp_xmit(skb, cp, pp, offset, hooknum);
+	verdict = ip_vs_icmp_xmit(skb, cp, pp, offset, hooknum, &ciph);
 
 out:
 	__ip_vs_conn_put(cp);
@@ -1453,8 +1443,8 @@ out:
 }
 
 #ifdef CONFIG_IP_VS_IPV6
-static int
-ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
+static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
+			    unsigned int hooknum, struct ip_vs_iphdr *iph)
 {
 	struct net *net = NULL;
 	struct ipv6hdr _ip6h, *ip6h;
@@ -1465,10 +1455,6 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 	struct ip_vs_proto_data *pd;
 	unsigned int offs_ciph, verdict;
 
-	struct ip_vs_iphdr iph_stack;
-	struct ip_vs_iphdr *iph = &iph_stack;
-	ip_vs_fill_iph_skb(AF_INET6, skb, iph);
-
 	*related = 1;
 
 	ic = frag_safe_skb_hp(skb, iph->len, sizeof(_icmph), &_icmph, iph);
@@ -1522,7 +1508,7 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 	/* The embedded headers contain source and dest in reverse order
 	 * if not from localhost
 	 */
-	cp = pp->conn_in_get(AF_INET6, skb, &ciph, ciph.len,
+	cp = pp->conn_in_get(AF_INET6, skb, &ciph,
 			     (hooknum == NF_INET_LOCAL_OUT) ? 0 : 1);
 
 	if (!cp)
@@ -1540,7 +1526,7 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 	    IPPROTO_SCTP == ciph.protocol)
 		offs_ciph = ciph.len + (2 * sizeof(__u16));
 
-	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, offs_ciph, hooknum);
+	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, offs_ciph, hooknum, &ciph);
 
 	__ip_vs_conn_put(cp);
 
@@ -1610,7 +1596,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 		}
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
 			int related;
-			int verdict = ip_vs_in_icmp_v6(skb, &related, hooknum);
+			int verdict = ip_vs_in_icmp_v6(skb, &related, hooknum,
+						       &iph);
 
 			if (related)
 				return verdict;
@@ -1633,8 +1620,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	/*
 	 * Check if the packet belongs to an existing connection entry
 	 */
-	cp = pp->conn_in_get(af, skb, &iph, iph.len, 0);
-
+	cp = pp->conn_in_get(af, skb, &iph, 0);
 	if (unlikely(!cp) && !iph.fragoffs) {
 		/* No (second) fragments need to enter here, as nf_defrag_ipv6
 		 * replayed fragment zero will already have created the cp
@@ -1642,7 +1628,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 		int v;
 
 		/* Schedule and create new connection entry into &cp */
-		if (!pp->conn_schedule(af, skb, pd, &v, &cp))
+		if (!pp->conn_schedule(af, skb, pd, &v, &cp, &iph))
 			return v;
 	}
 
@@ -1680,7 +1666,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	ip_vs_in_stats(cp, skb);
 	ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd);
 	if (cp->packet_xmit)
-		ret = cp->packet_xmit(skb, cp, pp);
+		ret = cp->packet_xmit(skb, cp, pp, &iph);
 		/* do not touch skb anymore */
 	else {
 		IP_VS_DBG_RL("warning: packet_xmit is null");
@@ -1854,7 +1840,7 @@ ip_vs_forward_icmp_v6(unsigned int hooknum, struct sk_buff *skb,
 	if (!net_ipvs(net)->enable)
 		return NF_ACCEPT;
 
-	return ip_vs_in_icmp_v6(skb, &r, hooknum);
+	return ip_vs_in_icmp_v6(skb, &r, hooknum, &iphdr);
 }
 #endif
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index 5b8eb8b..5de3dd3 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -57,7 +57,7 @@ ah_esp_conn_fill_param_proto(struct net *net, int af,
 
 static struct ip_vs_conn *
 ah_esp_conn_in_get(int af, const struct sk_buff *skb,
-		   const struct ip_vs_iphdr *iph, unsigned int proto_off,
+		   const struct ip_vs_iphdr *iph,
 		   int inverse)
 {
 	struct ip_vs_conn *cp;
@@ -85,9 +85,7 @@ ah_esp_conn_in_get(int af, const struct sk_buff *skb,
 
 static struct ip_vs_conn *
 ah_esp_conn_out_get(int af, const struct sk_buff *skb,
-		    const struct ip_vs_iphdr *iph,
-		    unsigned int proto_off,
-		    int inverse)
+		    const struct ip_vs_iphdr *iph, int inverse)
 {
 	struct ip_vs_conn *cp;
 	struct ip_vs_conn_param p;
@@ -110,7 +108,8 @@ ah_esp_conn_out_get(int af, const struct sk_buff *skb,
 
 static int
 ah_esp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
-		     int *verdict, struct ip_vs_conn **cpp)
+		     int *verdict, struct ip_vs_conn **cpp,
+		     struct ip_vs_iphdr *iph)
 {
 	/*
 	 * AH/ESP is only related traffic. Pass the packet to IP stack.
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index b903db6..746048b 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -10,28 +10,26 @@
 
 static int
 sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
-		   int *verdict, struct ip_vs_conn **cpp)
+		   int *verdict, struct ip_vs_conn **cpp,
+		   struct ip_vs_iphdr *iph)
 {
 	struct net *net;
 	struct ip_vs_service *svc;
 	sctp_chunkhdr_t _schunkh, *sch;
 	sctp_sctphdr_t *sh, _sctph;
-	struct ip_vs_iphdr iph;
 
-	ip_vs_fill_iph_skb(af, skb, &iph);
-
-	sh = skb_header_pointer(skb, iph.len, sizeof(_sctph), &_sctph);
+	sh = skb_header_pointer(skb, iph->len, sizeof(_sctph), &_sctph);
 	if (sh == NULL)
 		return 0;
 
-	sch = skb_header_pointer(skb, iph.len + sizeof(sctp_sctphdr_t),
+	sch = skb_header_pointer(skb, iph->len + sizeof(sctp_sctphdr_t),
 				 sizeof(_schunkh), &_schunkh);
 	if (sch == NULL)
 		return 0;
 	net = skb_net(skb);
 	if ((sch->type == SCTP_CID_INIT) &&
-	    (svc = ip_vs_service_get(net, af, skb->mark, iph.protocol,
-				     &iph.daddr, sh->dest))) {
+	    (svc = ip_vs_service_get(net, af, skb->mark, iph->protocol,
+				     &iph->daddr, sh->dest))) {
 		int ignored;
 
 		if (ip_vs_todrop(net_ipvs(net))) {
@@ -47,10 +45,10 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		 * Let the virtual server select a real server for the
 		 * incoming connection, and create a connection entry.
 		 */
-		*cpp = ip_vs_schedule(svc, skb, pd, &ignored);
+		*cpp = ip_vs_schedule(svc, skb, pd, &ignored, iph);
 		if (!*cpp && ignored <= 0) {
 			if (!ignored)
-				*verdict = ip_vs_leave(svc, skb, pd);
+				*verdict = ip_vs_leave(svc, skb, pd, iph);
 			else {
 				ip_vs_service_put(svc);
 				*verdict = NF_DROP;
@@ -64,20 +62,16 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 }
 
 static int
-sctp_snat_handler(struct sk_buff *skb,
-		  struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
+sctp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
+		  struct ip_vs_conn *cp, struct ip_vs_iphdr *iph)
 {
 	sctp_sctphdr_t *sctph;
-	unsigned int sctphoff;
+	unsigned int sctphoff = iph->len;
 	struct sk_buff *iter;
 	__be32 crc32;
 
-	struct ip_vs_iphdr iph;
-	ip_vs_fill_iph_skb(cp->af, skb, &iph);
-	sctphoff = iph.len;
-
 #ifdef CONFIG_IP_VS_IPV6
-	if (cp->af == AF_INET6 && iph.fragoffs)
+	if (cp->af == AF_INET6 && iph->fragoffs)
 		return 1;
 #endif
 
@@ -110,20 +104,16 @@ sctp_snat_handler(struct sk_buff *skb,
 }
 
 static int
-sctp_dnat_handler(struct sk_buff *skb,
-		  struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
+sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
+		  struct ip_vs_conn *cp, struct ip_vs_iphdr *iph)
 {
 	sctp_sctphdr_t *sctph;
-	unsigned int sctphoff;
+	unsigned int sctphoff = iph->len;
 	struct sk_buff *iter;
 	__be32 crc32;
 
-	struct ip_vs_iphdr iph;
-	ip_vs_fill_iph_skb(cp->af, skb, &iph);
-	sctphoff = iph.len;
-
 #ifdef CONFIG_IP_VS_IPV6
-	if (cp->af == AF_INET6 && iph.fragoffs)
+	if (cp->af == AF_INET6 && iph->fragoffs)
 		return 1;
 #endif
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 8a96069..9af653a 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -33,16 +33,14 @@
 
 static int
 tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
-		  int *verdict, struct ip_vs_conn **cpp)
+		  int *verdict, struct ip_vs_conn **cpp,
+		  struct ip_vs_iphdr *iph)
 {
 	struct net *net;
 	struct ip_vs_service *svc;
 	struct tcphdr _tcph, *th;
-	struct ip_vs_iphdr iph;
 
-	ip_vs_fill_iph_skb(af, skb, &iph);
-
-	th = skb_header_pointer(skb, iph.len, sizeof(_tcph), &_tcph);
+	th = skb_header_pointer(skb, iph->len, sizeof(_tcph), &_tcph);
 	if (th == NULL) {
 		*verdict = NF_DROP;
 		return 0;
@@ -50,8 +48,8 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	net = skb_net(skb);
 	/* No !th->ack check to allow scheduling on SYN+ACK for Active FTP */
 	if (th->syn &&
-	    (svc = ip_vs_service_get(net, af, skb->mark, iph.protocol,
-				     &iph.daddr, th->dest))) {
+	    (svc = ip_vs_service_get(net, af, skb->mark, iph->protocol,
+				     &iph->daddr, th->dest))) {
 		int ignored;
 
 		if (ip_vs_todrop(net_ipvs(net))) {
@@ -68,10 +66,10 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		 * Let the virtual server select a real server for the
 		 * incoming connection, and create a connection entry.
 		 */
-		*cpp = ip_vs_schedule(svc, skb, pd, &ignored);
+		*cpp = ip_vs_schedule(svc, skb, pd, &ignored, iph);
 		if (!*cpp && ignored <= 0) {
 			if (!ignored)
-				*verdict = ip_vs_leave(svc, skb, pd);
+				*verdict = ip_vs_leave(svc, skb, pd, iph);
 			else {
 				ip_vs_service_put(svc);
 				*verdict = NF_DROP;
@@ -128,20 +126,16 @@ tcp_partial_csum_update(int af, struct tcphdr *tcph,
 
 
 static int
-tcp_snat_handler(struct sk_buff *skb,
-		 struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
+tcp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
+		 struct ip_vs_conn *cp, struct ip_vs_iphdr *iph)
 {
 	struct tcphdr *tcph;
-	unsigned int tcphoff;
+	unsigned int tcphoff = iph->len;
 	int oldlen;
 	int payload_csum = 0;
 
-	struct ip_vs_iphdr iph;
-	ip_vs_fill_iph_skb(cp->af, skb, &iph);
-	tcphoff = iph.len;
-
 #ifdef CONFIG_IP_VS_IPV6
-	if (cp->af == AF_INET6 && iph.fragoffs)
+	if (cp->af == AF_INET6 && iph->fragoffs)
 		return 1;
 #endif
 	oldlen = skb->len - tcphoff;
@@ -210,20 +204,16 @@ tcp_snat_handler(struct sk_buff *skb,
 
 
 static int
-tcp_dnat_handler(struct sk_buff *skb,
-		 struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
+tcp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
+		 struct ip_vs_conn *cp, struct ip_vs_iphdr *iph)
 {
 	struct tcphdr *tcph;
-	unsigned int tcphoff;
+	unsigned int tcphoff = iph->len;
 	int oldlen;
 	int payload_csum = 0;
 
-	struct ip_vs_iphdr iph;
-	ip_vs_fill_iph_skb(cp->af, skb, &iph);
-	tcphoff = iph.len;
-
 #ifdef CONFIG_IP_VS_IPV6
-	if (cp->af == AF_INET6 && iph.fragoffs)
+	if (cp->af == AF_INET6 && iph->fragoffs)
 		return 1;
 #endif
 	oldlen = skb->len - tcphoff;
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index d6f4eee..503a842 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -30,23 +30,22 @@
 
 static int
 udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
-		  int *verdict, struct ip_vs_conn **cpp)
+		  int *verdict, struct ip_vs_conn **cpp,
+		  struct ip_vs_iphdr *iph)
 {
 	struct net *net;
 	struct ip_vs_service *svc;
 	struct udphdr _udph, *uh;
-	struct ip_vs_iphdr iph;
 
-	ip_vs_fill_iph_skb(af, skb, &iph);
-
-	uh = skb_header_pointer(skb, iph.len, sizeof(_udph), &_udph);
+	/* IPv6 fragments, only first fragment will hit this */
+	uh = skb_header_pointer(skb, iph->len, sizeof(_udph), &_udph);
 	if (uh == NULL) {
 		*verdict = NF_DROP;
 		return 0;
 	}
 	net = skb_net(skb);
-	svc = ip_vs_service_get(net, af, skb->mark, iph.protocol,
-				&iph.daddr, uh->dest);
+	svc = ip_vs_service_get(net, af, skb->mark, iph->protocol,
+				&iph->daddr, uh->dest);
 	if (svc) {
 		int ignored;
 
@@ -64,10 +63,10 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		 * Let the virtual server select a real server for the
 		 * incoming connection, and create a connection entry.
 		 */
-		*cpp = ip_vs_schedule(svc, skb, pd, &ignored);
+		*cpp = ip_vs_schedule(svc, skb, pd, &ignored, iph);
 		if (!*cpp && ignored <= 0) {
 			if (!ignored)
-				*verdict = ip_vs_leave(svc, skb, pd);
+				*verdict = ip_vs_leave(svc, skb, pd, iph);
 			else {
 				ip_vs_service_put(svc);
 				*verdict = NF_DROP;
@@ -125,20 +124,16 @@ udp_partial_csum_update(int af, struct udphdr *uhdr,
 
 
 static int
-udp_snat_handler(struct sk_buff *skb,
-		 struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
+udp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
+		 struct ip_vs_conn *cp, struct ip_vs_iphdr *iph)
 {
 	struct udphdr *udph;
-	unsigned int udphoff;
+	unsigned int udphoff = iph->len;
 	int oldlen;
 	int payload_csum = 0;
 
-	struct ip_vs_iphdr iph;
-	ip_vs_fill_iph_skb(cp->af, skb, &iph);
-	udphoff = iph.len;
-
 #ifdef CONFIG_IP_VS_IPV6
-	if (cp->af == AF_INET6 && iph.fragoffs)
+	if (cp->af == AF_INET6 && iph->fragoffs)
 		return 1;
 #endif
 	oldlen = skb->len - udphoff;
@@ -212,20 +207,16 @@ udp_snat_handler(struct sk_buff *skb,
 
 
 static int
-udp_dnat_handler(struct sk_buff *skb,
-		 struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
+udp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
+		 struct ip_vs_conn *cp, struct ip_vs_iphdr *iph)
 {
 	struct udphdr *udph;
-	unsigned int udphoff;
+	unsigned int udphoff = iph->len;
 	int oldlen;
 	int payload_csum = 0;
 
-	struct ip_vs_iphdr iph;
-	ip_vs_fill_iph_skb(cp->af, skb, &iph);
-	udphoff = iph.len;
-
 #ifdef CONFIG_IP_VS_IPV6
-	if (cp->af == AF_INET6 && iph.fragoffs)
+	if (cp->af == AF_INET6 && iph->fragoffs)
 		return 1;
 #endif
 	oldlen = skb->len - udphoff;
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index e44933f..90122eb 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -424,7 +424,7 @@ do {							\
  */
 int
 ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		struct ip_vs_protocol *pp)
+		struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	/* we do not touch skb and do not need pskb ptr */
 	IP_VS_XMIT(NFPROTO_IPV4, skb, cp, 1);
@@ -438,7 +438,7 @@ ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
  */
 int
 ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp)
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	struct rtable *rt;			/* Route to the other host */
 	struct iphdr  *iph = ip_hdr(skb);
@@ -493,17 +493,16 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		     struct ip_vs_protocol *pp)
+		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph)
 {
 	struct rt6_info *rt;			/* Route to the other host */
-	struct ip_vs_iphdr iph;
 	int    mtu;
 
 	EnterFunction(10);
-	ip_vs_fill_iph_skb(cp->af, skb, &iph);
 
-	if (!(rt = __ip_vs_get_out_rt_v6(skb, NULL, &iph.daddr.in6, NULL, 0,
-					 IP_VS_RT_MODE_NON_LOCAL)))
+	rt = __ip_vs_get_out_rt_v6(skb, NULL, &iph->daddr.in6, NULL, 0,
+				   IP_VS_RT_MODE_NON_LOCAL);
+	if (!rt)
 		goto tx_error_icmp;
 
 	/* MTU checking */
@@ -515,7 +514,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 			skb->dev = net->loopback_dev;
 		}
 		/* only send ICMP too big on first fragment */
-		if (!iph.fragoffs)
+		if (!iph->fragoffs)
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		dst_release(&rt->dst);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
@@ -559,7 +558,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
  */
 int
 ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-	       struct ip_vs_protocol *pp)
+	       struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	struct rtable *rt;		/* Route to the other host */
 	int mtu;
@@ -629,7 +628,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error_put;
 
 	/* mangle the packet */
-	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp))
+	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp, ipvsh))
 		goto tx_error_put;
 	ip_hdr(skb)->daddr = cp->daddr.ip;
 	ip_send_check(ip_hdr(skb));
@@ -677,20 +676,18 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp)
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph)
 {
 	struct rt6_info *rt;		/* Route to the other host */
 	int mtu;
 	int local;
-	struct ip_vs_iphdr iph;
 
 	EnterFunction(10);
-	ip_vs_fill_iph_skb(cp->af, skb, &iph);
 
 	/* check if it is a connection of no-client-port */
-	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT && !iph.fragoffs)) {
+	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT && !iph->fragoffs)) {
 		__be16 _pt, *p;
-		p = skb_header_pointer(skb, iph.len, sizeof(_pt), &_pt);
+		p = skb_header_pointer(skb, iph->len, sizeof(_pt), &_pt);
 		if (p == NULL)
 			goto tx_error;
 		ip_vs_conn_fill_cport(cp, *p);
@@ -739,7 +736,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 			skb->dev = net->loopback_dev;
 		}
 		/* only send ICMP too big on first fragment */
-		if (!iph.fragoffs)
+		if (!iph->fragoffs)
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		IP_VS_DBG_RL_PKT(0, AF_INET6, pp, skb, 0,
 				 "ip_vs_nat_xmit_v6(): frag needed for");
@@ -754,7 +751,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error_put;
 
 	/* mangle the packet */
-	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp))
+	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp, iph))
 		goto tx_error;
 	ipv6_hdr(skb)->daddr = cp->daddr.in6;
 
@@ -815,7 +812,7 @@ tx_error_put:
  */
 int
 ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp)
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
 	struct rtable *rt;			/* Route to the other host */
@@ -935,7 +932,7 @@ tx_error_put:
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		     struct ip_vs_protocol *pp)
+		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	struct rt6_info *rt;		/* Route to the other host */
 	struct in6_addr saddr;		/* Source for tunnel */
@@ -945,10 +942,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	unsigned int max_headroom;	/* The extra header space needed */
 	int    mtu;
 	int ret;
-	struct ip_vs_iphdr ipvsh;
 
 	EnterFunction(10);
-	ip_vs_fill_iph_skb(cp->af, skb, &ipvsh);
 
 	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6,
 					 &saddr, 1, (IP_VS_RT_MODE_LOCAL |
@@ -978,7 +973,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 			skb->dev = net->loopback_dev;
 		}
 		/* only send ICMP too big on first fragment */
-		if (!ipvsh.fragoffs)
+		if (!ipvsh->fragoffs)
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error_put;
@@ -1060,7 +1055,7 @@ tx_error_put:
  */
 int
 ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-	      struct ip_vs_protocol *pp)
+	      struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	struct rtable *rt;			/* Route to the other host */
 	struct iphdr  *iph = ip_hdr(skb);
@@ -1121,14 +1116,12 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		 struct ip_vs_protocol *pp)
+		 struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph)
 {
 	struct rt6_info *rt;			/* Route to the other host */
 	int    mtu;
-	struct ip_vs_iphdr iph;
 
 	EnterFunction(10);
-	ip_vs_fill_iph_skb(cp->af, skb, &iph);
 
 	if (!(rt = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
 					 0, (IP_VS_RT_MODE_LOCAL |
@@ -1148,7 +1141,7 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 			skb->dev = net->loopback_dev;
 		}
 		/* only send ICMP too big on first fragment */
-		if (!iph.fragoffs)
+		if (!iph->fragoffs)
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		dst_release(&rt->dst);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
@@ -1193,7 +1186,8 @@ tx_error:
  */
 int
 ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		struct ip_vs_protocol *pp, int offset, unsigned int hooknum)
+		struct ip_vs_protocol *pp, int offset, unsigned int hooknum,
+		struct ip_vs_iphdr *iph)
 {
 	struct rtable	*rt;	/* Route to the other host */
 	int mtu;
@@ -1208,7 +1202,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	   translate address/port back */
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
 		if (cp->packet_xmit)
-			rc = cp->packet_xmit(skb, cp, pp);
+			rc = cp->packet_xmit(skb, cp, pp, iph);
 		else
 			rc = NF_ACCEPT;
 		/* do not touch skb anymore */
@@ -1314,24 +1308,23 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		struct ip_vs_protocol *pp, int offset, unsigned int hooknum)
+		struct ip_vs_protocol *pp, int offset, unsigned int hooknum,
+		struct ip_vs_iphdr *iph)
 {
 	struct rt6_info	*rt;	/* Route to the other host */
 	int mtu;
 	int rc;
 	int local;
 	int rt_mode;
-	struct ip_vs_iphdr iph;
 
 	EnterFunction(10);
-	ip_vs_fill_iph_skb(cp->af, skb, &iph);
 
 	/* The ICMP packet for VS/TUN, VS/DR and LOCALNODE will be
 	   forwarded directly here, because there is no need to
 	   translate address/port back */
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
 		if (cp->packet_xmit)
-			rc = cp->packet_xmit(skb, cp, pp);
+			rc = cp->packet_xmit(skb, cp, pp, iph);
 		else
 			rc = NF_ACCEPT;
 		/* do not touch skb anymore */
@@ -1388,7 +1381,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 			skb->dev = net->loopback_dev;
 		}
 		/* only send ICMP too big on first fragment */
-		if (!iph.fragoffs)
+		if (!iph->fragoffs)
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error_put;
diff --git a/net/netfilter/xt_ipvs.c b/net/netfilter/xt_ipvs.c
index 3f9b8cd..8d47c37 100644
--- a/net/netfilter/xt_ipvs.c
+++ b/net/netfilter/xt_ipvs.c
@@ -85,7 +85,7 @@ ipvs_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	/*
 	 * Check if the packet belongs to an existing entry
 	 */
-	cp = pp->conn_out_get(family, skb, &iph, iph.len, 1 /* inverse */);
+	cp = pp->conn_out_get(family, skb, &iph, 1 /* inverse */);
 	if (unlikely(cp == NULL)) {
 		match = false;
 		goto out;

