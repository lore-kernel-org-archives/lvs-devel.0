From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH 2/3] ipvs: Fix faulty IPv6 extension header handling in IPVS
Date: Mon, 20 Aug 2012 15:08:40 +0200
Message-ID: <20120820130840.1509.75794.stgit@dragon>
References: <20120820130732.1509.13080.stgit@dragon>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20120820130732.1509.13080.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, Hans Schillstrom <hans@schillstrom.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org

Based on patch from: Hans Schillstrom

IPv6 headers must be processed in order of appearance,
neither can it be assumed that Upper layer headers is first.
If anything else than L4 is the first header IPVS will throw it.

IPVS will write SNAT & DNAT modifications at a fixed pos which
will corrupt the message. Proper header position must be found
before writing modifying packet.

This patch contains a lot of API changes.  This is done, to avoid
the costly scan of finding the IPv6 headers, via ipv6_find_hdr().
Finding the IPv6 headers is done as early as possible, and passed
on as a pointer "struct ip_vs_iphdr *" to the affected functions.

Notice, I have choosen, not to change the API of function
pointer "(*schedule)" (in struct ip_vs_scheduler) as it can be
used by external schedulers, via {un,}register_ip_vs_scheduler.
Only 4 out of 10 schedulers use info from ip_vs_iphdr*, and when
they do, they are only interested in iph->{s,d}addr.

This patch depends on commit 84018f55a:
 "netfilter: ip6_tables: add flags parameter to ipv6_find_hdr()"

This also adds a dependency to ip6_tables.

Hans left some questions in ip_vs_pe_sip.c, which I'm uncertain about.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
---

 include/net/ip_vs.h                     |  173 +++++++++++++++------
 net/netfilter/ipvs/ip_vs_conn.c         |   15 +-
 net/netfilter/ipvs/ip_vs_core.c         |  253 +++++++++++++------------------
 net/netfilter/ipvs/ip_vs_dh.c           |    2 
 net/netfilter/ipvs/ip_vs_lblc.c         |    2 
 net/netfilter/ipvs/ip_vs_lblcr.c        |    2 
 net/netfilter/ipvs/ip_vs_pe_sip.c       |   27 ++-
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |    9 -
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |   42 ++---
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |   40 ++---
 net/netfilter/ipvs/ip_vs_proto_udp.c    |   41 ++---
 net/netfilter/ipvs/ip_vs_sh.c           |    2 
 net/netfilter/ipvs/ip_vs_xmit.c         |   41 +++--
 net/netfilter/xt_ipvs.c                 |    4 
 14 files changed, 340 insertions(+), 313 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index aba0bb2..8d5920f 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -22,6 +22,9 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>			/* for struct ipv6hdr */
 #include <net/ipv6.h>
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#include <linux/netfilter_ipv6/ip6_tables.h>
+#endif
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 #include <net/netfilter/nf_conntrack.h>
 #endif
@@ -103,30 +106,99 @@ static inline struct net *seq_file_single_net(struct seq_file *seq)
 /* Connections' size value needed by ip_vs_ctl.c */
 extern int ip_vs_conn_tab_size;
 
-
 struct ip_vs_iphdr {
-	int len;
-	__u8 protocol;
+	__u32 len;	/* IPv4 simply where L4 starts
+			   IPv6 where to find next header */
+	__u32 offs;	/* IPv6 frags: header offset in nfct_reasm skb */
+	__u16 fragoffs; /* IPv6 fragment offset, 0 if first frag (or not frag)*/
+	__s16 protocol;
+	__s32 flags;
 	union nf_inet_addr saddr;
 	union nf_inet_addr daddr;
 };
 
+/* Dependency to module: nf_defrag_ipv6 */
+#if defined(CONFIG_NF_DEFRAG_IPV6) || defined(CONFIG_NF_DEFRAG_IPV6_MODULE)
+static inline struct sk_buff *skb_nfct_reasm(const struct sk_buff *skb)
+{
+	return skb->nfct_reasm;
+}
+#else
+static inline struct sk_buff *skb_nfct_reasm(const struct sk_buff *skb)
+{
+	return NULL;
+}
+#endif
+
+static inline void
+ip_vs_fill_ip4hdr(const void *nh, struct ip_vs_iphdr *iphdr)
+{
+	const struct iphdr *iph = nh;
+
+	iphdr->len	= iph->ihl * 4;
+	iphdr->fragoffs	= 0;
+	iphdr->protocol	= iph->protocol;
+	iphdr->saddr.ip	= iph->saddr;
+	iphdr->daddr.ip	= iph->daddr;
+}
+
+/* This function handles filling *ip_vs_iphdr, both for IPv4 and IPv6.
+ * IPv6 requires some extra work, as finding proper header position,
+ * depend on the IPv6 extension headers.
+ */
 static inline void
-ip_vs_fill_iphdr(int af, const void *nh, struct ip_vs_iphdr *iphdr)
+ip_vs_fill_iph_skb(int af, const struct sk_buff *skb, struct ip_vs_iphdr *iphdr)
 {
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
-		const struct ipv6hdr *iph = nh;
-		iphdr->len = sizeof(struct ipv6hdr);
-		iphdr->protocol = iph->nexthdr;
+		const struct ipv6hdr *iph =
+			(struct ipv6hdr *)skb_network_header(skb);
 		iphdr->saddr.in6 = iph->saddr;
 		iphdr->daddr.in6 = iph->daddr;
+		/* ipv6_find_hdr() updates len, flags, offs */
+		iphdr->len	 = 0;
+		iphdr->flags	 = 0;
+		iphdr->offs	 = 0;
+		iphdr->protocol  = ipv6_find_hdr(skb, &iphdr->len, -1,
+						 &iphdr->fragoffs,
+						 &iphdr->flags);
+		/* get proto from re-assembled packet and it's offset */
+		if (skb_nfct_reasm(skb))
+			iphdr->protocol = ipv6_find_hdr(skb_nfct_reasm(skb),
+							&iphdr->offs, -1, NULL,
+							NULL);
 	} else
 #endif
 	{
-		const struct iphdr *iph = nh;
-		iphdr->len = iph->ihl * 4;
-		iphdr->protocol = iph->protocol;
+		const struct iphdr *iph =
+			(struct iphdr *)skb_network_header(skb);
+		iphdr->len	= iph->ihl * 4;
+		iphdr->fragoffs	= 0;
+		iphdr->protocol	= iph->protocol;
+		iphdr->saddr.ip	= iph->saddr;
+		iphdr->daddr.ip	= iph->daddr;
+	}
+}
+
+/* This function is a faster version of ip_vs_fill_iph_skb().
+ * Where we only populate {s,d}addr (and avoid calling ipv6_find_hdr()).
+ * This is used by the some of the ip_vs_*_schedule() functions.
+ * (Mostly done to avoid ABI breakage of external schedulers)
+ */
+static inline void
+ip_vs_fill_iph_addr_only(int af, const struct sk_buff *skb,
+			 struct ip_vs_iphdr *iphdr)
+{
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6) {
+		const struct ipv6hdr *iph =
+			(struct ipv6hdr *)skb_network_header(skb);
+		iphdr->saddr.in6 = iph->saddr;
+		iphdr->daddr.in6 = iph->daddr;
+	} else {
+#endif
+		const struct iphdr *iph =
+			(struct iphdr *)skb_network_header(skb);
 		iphdr->saddr.ip = iph->saddr;
 		iphdr->daddr.ip = iph->daddr;
 	}
@@ -398,27 +470,26 @@ struct ip_vs_protocol {
 
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
@@ -518,7 +589,7 @@ struct ip_vs_conn {
 	   NF_ACCEPT can be returned when destination is local.
 	 */
 	int (*packet_xmit)(struct sk_buff *skb, struct ip_vs_conn *cp,
-			   struct ip_vs_protocol *pp);
+			   struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
 
 	/* Note: we can group the following members into a structure,
 	   in order to save more space, and the following members are
@@ -769,13 +840,11 @@ struct ip_vs_app {
 
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
@@ -1074,14 +1143,12 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p);
 
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
@@ -1254,9 +1321,10 @@ extern struct ip_vs_scheduler *ip_vs_scheduler_get(const char *sched_name);
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
 
@@ -1315,33 +1383,38 @@ extern void ip_vs_read_estimator(struct ip_vs_stats_user *dst,
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
index 1548df9..a00db99 100644
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
 
-	pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
+	pptr = skb_header_pointer(skb, iph->len, sizeof(_ports), _ports);
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
index 58918e2..32c69ed 100644
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
 
-	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
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
@@ -392,18 +389,20 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
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
-	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
-	pptr = skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
+	/*
+	 * IPv6 frags, only the first hit here.
+	 */
+	pptr = skb_header_pointer(skb, iph->len, sizeof(_ports), _ports);
 	if (pptr == NULL)
 		return NULL;
 
@@ -423,7 +422,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	 *    Do not schedule replies from local real server.
 	 */
 	if ((!skb->dev || skb->dev->flags & IFF_LOOPBACK) &&
-	    (cp = pp->conn_in_get(svc->af, skb, &iph, iph.len, 1))) {
+	    (cp = pp->conn_in_get(svc->af, skb, iph, 1))) {
 		IP_VS_DBG_PKT(12, svc->af, pp, skb, 0,
 			      "Not scheduling reply for existing connection");
 		__ip_vs_conn_put(cp);
@@ -434,7 +433,8 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	 *    Persistent service
 	 */
 	if (svc->flags & IP_VS_SVC_F_PERSISTENT)
-		return ip_vs_sched_persist(svc, skb, pptr[0], pptr[1], ignored);
+		return ip_vs_sched_persist(svc, skb, pptr[0], pptr[1], ignored,
+					   iph);
 
 	*ignored = 0;
 
@@ -456,7 +456,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	}
 
 	flags = (svc->flags & IP_VS_SVC_F_ONEPACKET
-		 && iph.protocol == IPPROTO_UDP)?
+		 && iph->protocol == IPPROTO_UDP) ?
 		IP_VS_CONN_F_ONE_PACKET : 0;
 
 	/*
@@ -465,9 +465,9 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
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
@@ -496,19 +496,16 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
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
 
-	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
-
-	pptr = skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
+	pptr = skb_header_pointer(skb, iph->len, sizeof(_ports), _ports);
 	if (pptr == NULL) {
 		ip_vs_service_put(svc);
 		return NF_DROP;
@@ -519,10 +516,10 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 
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
@@ -532,7 +529,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		int ret;
 		struct ip_vs_conn *cp;
 		unsigned int flags = (svc->flags & IP_VS_SVC_F_ONEPACKET &&
-				      iph.protocol == IPPROTO_UDP)?
+				      iph->protocol == IPPROTO_UDP) ?
 				      IP_VS_CONN_F_ONE_PACKET : 0;
 		union nf_inet_addr daddr =  { .all = { 0, 0, 0, 0 } };
 
@@ -542,9 +539,9 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
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
@@ -559,7 +556,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd);
 
 		/* transmit the first SYN packet */
-		ret = cp->packet_xmit(skb, cp, pd->pp);
+		ret = cp->packet_xmit(skb, cp, pd->pp, iph);
 		/* do not touch skb anymore */
 
 		atomic_inc(&cp->in_pkts);
@@ -898,50 +895,38 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
 	IP_VS_DBG_PKT(11, AF_INET, pp, skb, offset,
 		      "Checking outgoing ICMP for");
 
-	offset += cih->ihl * 4;
-
-	ip_vs_fill_iphdr(AF_INET, cih, &ciph);
+	ip_vs_fill_ip4hdr(cih, &ciph);
+	ciph.len += offset;
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_out_get(AF_INET, skb, &ciph, offset, 1);
+	cp = pp->conn_out_get(AF_INET, skb, &ciph, 1);
 	if (!cp)
 		return NF_ACCEPT;
 
 	snet.ip = iph->saddr;
 	return handle_response_icmp(AF_INET, skb, &snet, cih->protocol, cp,
-				    pp, offset, ihl);
+				    pp, ciph.len, ihl);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
 static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
-			     unsigned int hooknum)
+			     unsigned int hooknum, struct ip_vs_iphdr *ipvsh)
 {
-	struct ipv6hdr *iph;
 	struct icmp6hdr	_icmph, *ic;
-	struct ipv6hdr	_ciph, *cih;	/* The ip header contained
+	struct ipv6hdr _ip6, *ip6;	/* The ip header contained
 					   within the ICMP */
-	struct ip_vs_iphdr ciph;
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
-	unsigned int offset;
 	union nf_inet_addr snet;
 
 	*related = 1;
 
-	/* reassemble IP fragments */
-	if (ipv6_hdr(skb)->nexthdr == IPPROTO_FRAGMENT) {
-		if (ip_vs_gather_frags_v6(skb, ip_vs_defrag_user(hooknum)))
-			return NF_STOLEN;
-	}
-
-	iph = ipv6_hdr(skb);
-	offset = sizeof(struct ipv6hdr);
-	ic = skb_header_pointer(skb, offset, sizeof(_icmph), &_icmph);
+	ic = skb_header_pointer(skb, ipvsh->len, sizeof(_icmph), &_icmph);
 	if (ic == NULL)
 		return NF_DROP;
 
-	IP_VS_DBG(12, "Outgoing ICMPv6 (%d,%d) %pI6->%pI6\n",
+	IP_VS_DBG(12, "Outgoing ICMPv6 (%d,%d) %pI6c->%pI6c\n",
 		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
-		  &iph->saddr, &iph->daddr);
+		  &ipvsh->saddr, &ipvsh->daddr);
 
 	/*
 	 * Work through seeing if this is for us.
@@ -958,34 +943,26 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 	}
 
 	/* Now find the contained IP header */
-	offset += sizeof(_icmph);
-	cih = skb_header_pointer(skb, offset, sizeof(_ciph), &_ciph);
-	if (cih == NULL)
-		return NF_ACCEPT; /* The packet looks wrong, ignore */
+	ipvsh->len += sizeof(_icmph);
+	ip6 = skb_header_pointer(skb, ipvsh->len, sizeof(_ip6), &_ip6);
+	ipvsh->protocol = ipv6_find_hdr(skb, &ipvsh->len, -1,
+					&ipvsh->fragoffs, &ipvsh->flags);
 
-	pp = ip_vs_proto_get(cih->nexthdr);
-	if (!pp)
-		return NF_ACCEPT;
-
-	/* Is the embedded protocol header present? */
-	/* TODO: we don't support fragmentation at the moment anyways */
-	if (unlikely(cih->nexthdr == IPPROTO_FRAGMENT && pp->dont_defrag))
+	pp = ip_vs_proto_get(ipvsh->protocol);
+	if (!pp || (ipvsh->protocol < 0))
 		return NF_ACCEPT;
+	/* fill the rest of ipvsh */
+	ipvsh->saddr.in6 = ip6->saddr;
+	ipvsh->daddr.in6 = ip6->daddr;
 
-	IP_VS_DBG_PKT(11, AF_INET6, pp, skb, offset,
-		      "Checking outgoing ICMPv6 for");
-
-	offset += sizeof(struct ipv6hdr);
-
-	ip_vs_fill_iphdr(AF_INET6, cih, &ciph);
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_out_get(AF_INET6, skb, &ciph, offset, 1);
+	cp = pp->conn_out_get(AF_INET6, skb, ipvsh, 1);
 	if (!cp)
 		return NF_ACCEPT;
 
-	snet.in6 = iph->saddr;
-	return handle_response_icmp(AF_INET6, skb, &snet, cih->nexthdr, cp,
-				    pp, offset, sizeof(struct ipv6hdr));
+	snet.in6 = ipvsh->saddr.in6;
+	return handle_response_icmp(AF_INET6, skb, &snet, ipvsh->protocol, cp,
+				    pp, ipvsh->len, sizeof(struct ipv6hdr));
 }
 #endif
 
@@ -1018,17 +995,17 @@ static inline int is_tcp_reset(const struct sk_buff *skb, int nh_len)
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
@@ -1115,17 +1092,17 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (!net_ipvs(net)->enable)
 		return NF_ACCEPT;
 
-	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_skb(af, skb, &iph);
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
 			int related;
 			int verdict = ip_vs_out_icmp_v6(skb, &related,
-							hooknum);
+							hooknum, &iph);
 
 			if (related)
 				return verdict;
-			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+			ip_vs_fill_iph_skb(af, skb, &iph);
 		}
 	} else
 #endif
@@ -1135,7 +1112,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 
 			if (related)
 				return verdict;
-			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+			ip_vs_fill_ip4hdr(skb_network_header(skb), &iph);
 		}
 
 	pd = ip_vs_proto_data_get(net, iph.protocol);
@@ -1145,31 +1122,23 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 
 	/* reassemble IP fragments */
 #ifdef CONFIG_IP_VS_IPV6
-	if (af == AF_INET6) {
-		if (ipv6_hdr(skb)->nexthdr == IPPROTO_FRAGMENT) {
-			if (ip_vs_gather_frags_v6(skb,
-						  ip_vs_defrag_user(hooknum)))
-				return NF_STOLEN;
-		}
-
-		ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
-	} else
+	if (af == AF_INET)
 #endif
 		if (unlikely(ip_is_fragment(ip_hdr(skb)) && !pp->dont_defrag)) {
 			if (ip_vs_gather_frags(skb,
 					       ip_vs_defrag_user(hooknum)))
 				return NF_STOLEN;
 
-			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+			ip_vs_fill_ip4hdr(skb_network_header(skb), &iph);
 		}
 
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
@@ -1375,13 +1344,13 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 		      "Checking incoming ICMP for");
 
 	offset2 = offset;
-	offset += cih->ihl * 4;
-
-	ip_vs_fill_iphdr(AF_INET, cih, &ciph);
+	ip_vs_fill_ip4hdr(cih, &ciph);
+	ciph.len += offset;
+	offset = ciph.len;
 	/* The embedded headers contain source and dest in reverse order.
 	 * For IPIP this is error for request, not for reply.
 	 */
-	cp = pp->conn_in_get(AF_INET, skb, &ciph, offset, ipip ? 0 : 1);
+	cp = pp->conn_in_get(AF_INET, skb, &ciph, ipip ? 0 : 1);
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -1450,7 +1419,7 @@ ignore_ipip:
 	ip_vs_in_stats(cp, skb);
 	if (IPPROTO_TCP == cih->protocol || IPPROTO_UDP == cih->protocol)
 		offset += 2 * sizeof(__u16);
-	verdict = ip_vs_icmp_xmit(skb, cp, pp, offset, hooknum);
+	verdict = ip_vs_icmp_xmit(skb, cp, pp, offset, hooknum, &ciph);
 
 out:
 	__ip_vs_conn_put(cp);
@@ -1459,14 +1428,11 @@ out:
 }
 
 #ifdef CONFIG_IP_VS_IPV6
-static int
-ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
+static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
+			    unsigned int hooknum, struct ip_vs_iphdr *iph)
 {
 	struct net *net = NULL;
-	struct ipv6hdr *iph;
 	struct icmp6hdr	_icmph, *ic;
-	struct ipv6hdr	_ciph, *cih;	/* The ip header contained
-					   within the ICMP */
 	struct ip_vs_iphdr ciph;
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
@@ -1475,19 +1441,11 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 
 	*related = 1;
 
-	/* reassemble IP fragments */
-	if (ipv6_hdr(skb)->nexthdr == IPPROTO_FRAGMENT) {
-		if (ip_vs_gather_frags_v6(skb, ip_vs_defrag_user(hooknum)))
-			return NF_STOLEN;
-	}
-
-	iph = ipv6_hdr(skb);
-	offset = sizeof(struct ipv6hdr);
-	ic = skb_header_pointer(skb, offset, sizeof(_icmph), &_icmph);
+	ic = skb_header_pointer(skb, iph->len, sizeof(_icmph), &_icmph);
 	if (ic == NULL)
 		return NF_DROP;
 
-	IP_VS_DBG(12, "Incoming ICMPv6 (%d,%d) %pI6->%pI6\n",
+	IP_VS_DBG(12, "Incoming ICMPv6 (%d,%d) %pI6c->%pI6c\n",
 		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
 		  &iph->saddr, &iph->daddr);
 
@@ -1506,39 +1464,43 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 	}
 
 	/* Now find the contained IP header */
-	offset += sizeof(_icmph);
-	cih = skb_header_pointer(skb, offset, sizeof(_ciph), &_ciph);
-	if (cih == NULL)
-		return NF_ACCEPT; /* The packet looks wrong, ignore */
+	ciph.len = iph->len + sizeof(_icmph);
+	ciph.flags = 0;
+	ciph.fragoffs = 0;
+	ciph.protocol = ipv6_find_hdr(skb, &ciph.len, -1, &ciph.fragoffs,
+				      &ciph.flags);
+	ciph.saddr = iph->saddr;	/* con_in_get() handles reverse order */
+	ciph.daddr = iph->daddr;
 
 	net = skb_net(skb);
-	pd = ip_vs_proto_data_get(net, cih->nexthdr);
+	pd = ip_vs_proto_data_get(net, ciph.protocol);
 	if (!pd)
 		return NF_ACCEPT;
 	pp = pd->pp;
 
-	/* Is the embedded protocol header present? */
-	/* TODO: we don't support fragmentation at the moment anyways */
-	if (unlikely(cih->nexthdr == IPPROTO_FRAGMENT && pp->dont_defrag))
+	/* Is the embedded protocol header present?
+	 * If it's the second or later fragment we don't know what it is
+	 * i.e. just let it through.
+	 */
+	if (ciph.fragoffs)
 		return NF_ACCEPT;
 
+	offset = ciph.len;
 	IP_VS_DBG_PKT(11, AF_INET6, pp, skb, offset,
 		      "Checking incoming ICMPv6 for");
 
-	offset += sizeof(struct ipv6hdr);
-
-	ip_vs_fill_iphdr(AF_INET6, cih, &ciph);
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_in_get(AF_INET6, skb, &ciph, offset, 1);
+	cp = pp->conn_in_get(AF_INET6, skb, &ciph, 1);
 	if (!cp)
 		return NF_ACCEPT;
 
 	/* do the statistics and put it back */
 	ip_vs_in_stats(cp, skb);
-	if (IPPROTO_TCP == cih->nexthdr || IPPROTO_UDP == cih->nexthdr ||
-	    IPPROTO_SCTP == cih->nexthdr)
-		offset += 2 * sizeof(__u16);
-	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, offset, hooknum);
+	if (IPPROTO_TCP == ciph.protocol || IPPROTO_UDP == ciph.protocol ||
+	    IPPROTO_SCTP == ciph.protocol)
+		offset = ciph.len + (2 * sizeof(__u16));
+
+	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, offset, hooknum, &ciph);
 
 	__ip_vs_conn_put(cp);
 
@@ -1574,7 +1536,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (unlikely((skb->pkt_type != PACKET_HOST &&
 		      hooknum != NF_INET_LOCAL_OUT) ||
 		     !skb_dst(skb))) {
-		ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+		ip_vs_fill_iph_skb(af, skb, &iph);
 		IP_VS_DBG_BUF(12, "packet type=%d proto=%d daddr=%s"
 			      " ignored in hook %u\n",
 			      skb->pkt_type, iph.protocol,
@@ -1586,7 +1548,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (!net_ipvs(net)->enable)
 		return NF_ACCEPT;
 
-	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_skb(af, skb, &iph);
 
 	/* Bad... Do not break raw sockets */
 	if (unlikely(skb->sk != NULL && hooknum == NF_INET_LOCAL_OUT &&
@@ -1602,11 +1564,11 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (af == AF_INET6) {
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
 			int related;
-			int verdict = ip_vs_in_icmp_v6(skb, &related, hooknum);
+			int verdict = ip_vs_in_icmp_v6(skb, &related, hooknum,
+						       &iph);
 
 			if (related)
 				return verdict;
-			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 		}
 	} else
 #endif
@@ -1616,7 +1578,6 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 
 			if (related)
 				return verdict;
-			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 		}
 
 	/* Protocol supported? */
@@ -1626,13 +1587,13 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	pp = pd->pp;
 	/*
 	 * Check if the packet belongs to an existing connection entry
+	 * Only sched first IPv6 fragment.
 	 */
-	cp = pp->conn_in_get(af, skb, &iph, iph.len, 0);
-
-	if (unlikely(!cp)) {
+	cp = pp->conn_in_get(af, skb, &iph, 0);
+	if (unlikely(!cp) && !iph.fragoffs) {
 		int v;
 
-		if (!pp->conn_schedule(af, skb, pd, &v, &cp))
+		if (!pp->conn_schedule(af, skb, pd, &v, &cp, &iph))
 			return v;
 	}
 
@@ -1662,7 +1623,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	ip_vs_in_stats(cp, skb);
 	ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd);
 	if (cp->packet_xmit)
-		ret = cp->packet_xmit(skb, cp, pp);
+		ret = cp->packet_xmit(skb, cp, pp, &iph);
 		/* do not touch skb anymore */
 	else {
 		IP_VS_DBG_RL("warning: packet_xmit is null");
@@ -1793,8 +1754,10 @@ ip_vs_forward_icmp_v6(unsigned int hooknum, struct sk_buff *skb,
 {
 	int r;
 	struct net *net;
+	struct ip_vs_iphdr iphdr;
 
-	if (ipv6_hdr(skb)->nexthdr != IPPROTO_ICMPV6)
+	ip_vs_fill_iph_skb(AF_INET6, skb, &iphdr);
+	if (iphdr.protocol != IPPROTO_ICMPV6)
 		return NF_ACCEPT;
 
 	/* ipvs enabled in this netns ? */
@@ -1802,7 +1765,7 @@ ip_vs_forward_icmp_v6(unsigned int hooknum, struct sk_buff *skb,
 	if (!net_ipvs(net)->enable)
 		return NF_ACCEPT;
 
-	return ip_vs_in_icmp_v6(skb, &r, hooknum);
+	return ip_vs_in_icmp_v6(skb, &r, hooknum, &iphdr);
 }
 #endif
 
diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index 8b7dca9..7f3b0cc 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -215,7 +215,7 @@ ip_vs_dh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	struct ip_vs_dh_bucket *tbl;
 	struct ip_vs_iphdr iph;
 
-	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
 
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index df646cc..cbd3748 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -479,7 +479,7 @@ ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	struct ip_vs_dest *dest = NULL;
 	struct ip_vs_lblc_entry *en;
 
-	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
 
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 570e31e..161b679 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -649,7 +649,7 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	struct ip_vs_dest *dest = NULL;
 	struct ip_vs_lblcr_entry *en;
 
-	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
 
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
index 1aa5cac..bb28b4f 100644
--- a/net/netfilter/ipvs/ip_vs_pe_sip.c
+++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
@@ -68,26 +68,37 @@ static int get_callid(const char *dptr, unsigned int dataoff,
 static int
 ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
 {
+	struct sk_buff *reasm = skb_nfct_reasm(skb);
 	struct ip_vs_iphdr iph;
 	unsigned int dataoff, datalen, matchoff, matchlen;
 	const char *dptr;
 	int retc;
 
-	ip_vs_fill_iphdr(p->af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_skb(p->af, skb, &iph);
 
 	/* Only useful with UDP */
 	if (iph.protocol != IPPROTO_UDP)
 		return -EINVAL;
+	/*
+	 * todo: IPv6 fragments:
+	 *       I think this only should be done for the first fragment. /HS
+	 */
+	if (!reasm) {
+		reasm = skb;
+		dataoff = iph.len + sizeof(struct udphdr);
+	} else
+		dataoff = iph.offs + sizeof(struct udphdr);
 
-	/* No Data ? */
-	dataoff = iph.len + sizeof(struct udphdr);
-	if (dataoff >= skb->len)
+	if (dataoff >= reasm->len)
 		return -EINVAL;
-
-	if ((retc=skb_linearize(skb)) < 0)
+	/*
+	 * todo: Check if this will mess-up the reasm skb !!! /HS
+	 */
+	retc = skb_linearize(reasm);
+	if (retc < 0)
 		return retc;
-	dptr = skb->data + dataoff;
-	datalen = skb->len - dataoff;
+	dptr = reasm->data + dataoff;
+	datalen = reasm->len - dataoff;
 
 	if (get_callid(dptr, dataoff, datalen, &matchoff, &matchlen))
 		return -EINVAL;
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
index 9f3fb75..746048b 100644
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
 
-	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
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
@@ -64,20 +62,18 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
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
 
 #ifdef CONFIG_IP_VS_IPV6
-	if (cp->af == AF_INET6)
-		sctphoff = sizeof(struct ipv6hdr);
-	else
+	if (cp->af == AF_INET6 && iph->fragoffs)
+		return 1;
 #endif
-		sctphoff = ip_hdrlen(skb);
 
 	/* csum_check requires unshared skb */
 	if (!skb_make_writable(skb, sctphoff + sizeof(*sctph)))
@@ -108,20 +104,18 @@ sctp_snat_handler(struct sk_buff *skb,
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
 
 #ifdef CONFIG_IP_VS_IPV6
-	if (cp->af == AF_INET6)
-		sctphoff = sizeof(struct ipv6hdr);
-	else
+	if (cp->af == AF_INET6 && iph->fragoffs)
+		return 1;
 #endif
-		sctphoff = ip_hdrlen(skb);
 
 	/* csum_check requires unshared skb */
 	if (!skb_make_writable(skb, sctphoff + sizeof(*sctph)))
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index cd609cc..9af653a 100644
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
 
-	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
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
@@ -128,20 +126,18 @@ tcp_partial_csum_update(int af, struct tcphdr *tcph,
 
 
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
 
 #ifdef CONFIG_IP_VS_IPV6
-	if (cp->af == AF_INET6)
-		tcphoff = sizeof(struct ipv6hdr);
-	else
+	if (cp->af == AF_INET6 && iph->fragoffs)
+		return 1;
 #endif
-		tcphoff = ip_hdrlen(skb);
 	oldlen = skb->len - tcphoff;
 
 	/* csum_check requires unshared skb */
@@ -208,20 +204,18 @@ tcp_snat_handler(struct sk_buff *skb,
 
 
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
 
 #ifdef CONFIG_IP_VS_IPV6
-	if (cp->af == AF_INET6)
-		tcphoff = sizeof(struct ipv6hdr);
-	else
+	if (cp->af == AF_INET6 && iph->fragoffs)
+		return 1;
 #endif
-		tcphoff = ip_hdrlen(skb);
 	oldlen = skb->len - tcphoff;
 
 	/* csum_check requires unshared skb */
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 2fedb2d..503a842 100644
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
 
-	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
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
@@ -125,20 +124,18 @@ udp_partial_csum_update(int af, struct udphdr *uhdr,
 
 
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
 
 #ifdef CONFIG_IP_VS_IPV6
-	if (cp->af == AF_INET6)
-		udphoff = sizeof(struct ipv6hdr);
-	else
+	if (cp->af == AF_INET6 && iph->fragoffs)
+		return 1;
 #endif
-		udphoff = ip_hdrlen(skb);
 	oldlen = skb->len - udphoff;
 
 	/* csum_check requires unshared skb */
@@ -210,20 +207,18 @@ udp_snat_handler(struct sk_buff *skb,
 
 
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
 
 #ifdef CONFIG_IP_VS_IPV6
-	if (cp->af == AF_INET6)
-		udphoff = sizeof(struct ipv6hdr);
-	else
+	if (cp->af == AF_INET6 && iph->fragoffs)
+		return 1;
 #endif
-		udphoff = ip_hdrlen(skb);
 	oldlen = skb->len - udphoff;
 
 	/* csum_check requires unshared skb */
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 0512652..e331269 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -228,7 +228,7 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	struct ip_vs_sh_bucket *tbl;
 	struct ip_vs_iphdr iph;
 
-	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
 
 	IP_VS_DBG(6, "ip_vs_sh_schedule(): Scheduling...\n");
 
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index eef3432..925cca2 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -408,7 +408,7 @@ do {							\
  */
 int
 ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		struct ip_vs_protocol *pp)
+		struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	/* we do not touch skb and do not need pskb ptr */
 	IP_VS_XMIT(NFPROTO_IPV4, skb, cp, 1);
@@ -422,7 +422,7 @@ ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
  */
 int
 ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp)
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	struct rtable *rt;			/* Route to the other host */
 	struct iphdr  *iph = ip_hdr(skb);
@@ -477,16 +477,16 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		     struct ip_vs_protocol *pp)
+		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph)
 {
 	struct rt6_info *rt;			/* Route to the other host */
-	struct ipv6hdr  *iph = ipv6_hdr(skb);
 	int    mtu;
 
 	EnterFunction(10);
 
-	if (!(rt = __ip_vs_get_out_rt_v6(skb, NULL, &iph->daddr, NULL, 0,
-					 IP_VS_RT_MODE_NON_LOCAL)))
+	rt = __ip_vs_get_out_rt_v6(skb, NULL, &iph->daddr.in6, NULL, 0,
+				   IP_VS_RT_MODE_NON_LOCAL);
+	if (!rt)
 		goto tx_error_icmp;
 
 	/* MTU checking */
@@ -540,7 +540,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
  */
 int
 ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-	       struct ip_vs_protocol *pp)
+	       struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	struct rtable *rt;		/* Route to the other host */
 	int mtu;
@@ -610,7 +610,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error_put;
 
 	/* mangle the packet */
-	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp))
+	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp, ipvsh))
 		goto tx_error_put;
 	ip_hdr(skb)->daddr = cp->daddr.ip;
 	ip_send_check(ip_hdr(skb));
@@ -658,7 +658,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp)
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph)
 {
 	struct rt6_info *rt;		/* Route to the other host */
 	int mtu;
@@ -669,8 +669,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* check if it is a connection of no-client-port */
 	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT)) {
 		__be16 _pt, *p;
-		p = skb_header_pointer(skb, sizeof(struct ipv6hdr),
-				       sizeof(_pt), &_pt);
+		p = skb_header_pointer(skb, iph->len, sizeof(_pt), &_pt);
 		if (p == NULL)
 			goto tx_error;
 		ip_vs_conn_fill_cport(cp, *p);
@@ -732,7 +731,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error_put;
 
 	/* mangle the packet */
-	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp))
+	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp, iph))
 		goto tx_error;
 	ipv6_hdr(skb)->daddr = cp->daddr.in6;
 
@@ -793,7 +792,7 @@ tx_error_put:
  */
 int
 ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp)
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
 	struct rtable *rt;			/* Route to the other host */
@@ -913,7 +912,7 @@ tx_error_put:
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		     struct ip_vs_protocol *pp)
+		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	struct rt6_info *rt;		/* Route to the other host */
 	struct in6_addr saddr;		/* Source for tunnel */
@@ -1034,7 +1033,7 @@ tx_error_put:
  */
 int
 ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-	      struct ip_vs_protocol *pp)
+	      struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	struct rtable *rt;			/* Route to the other host */
 	struct iphdr  *iph = ip_hdr(skb);
@@ -1095,7 +1094,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		 struct ip_vs_protocol *pp)
+		 struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph)
 {
 	struct rt6_info *rt;			/* Route to the other host */
 	int    mtu;
@@ -1163,7 +1162,8 @@ tx_error:
  */
 int
 ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		struct ip_vs_protocol *pp, int offset, unsigned int hooknum)
+		struct ip_vs_protocol *pp, int offset, unsigned int hooknum,
+		struct ip_vs_iphdr *iph)
 {
 	struct rtable	*rt;	/* Route to the other host */
 	int mtu;
@@ -1178,7 +1178,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	   translate address/port back */
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
 		if (cp->packet_xmit)
-			rc = cp->packet_xmit(skb, cp, pp);
+			rc = cp->packet_xmit(skb, cp, pp, iph);
 		else
 			rc = NF_ACCEPT;
 		/* do not touch skb anymore */
@@ -1284,7 +1284,8 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		struct ip_vs_protocol *pp, int offset, unsigned int hooknum)
+		struct ip_vs_protocol *pp, int offset, unsigned int hooknum,
+		struct ip_vs_iphdr *iph)
 {
 	struct rt6_info	*rt;	/* Route to the other host */
 	int mtu;
@@ -1299,7 +1300,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	   translate address/port back */
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
 		if (cp->packet_xmit)
-			rc = cp->packet_xmit(skb, cp, pp);
+			rc = cp->packet_xmit(skb, cp, pp, iph);
 		else
 			rc = NF_ACCEPT;
 		/* do not touch skb anymore */
diff --git a/net/netfilter/xt_ipvs.c b/net/netfilter/xt_ipvs.c
index bb10b07..8d47c37 100644
--- a/net/netfilter/xt_ipvs.c
+++ b/net/netfilter/xt_ipvs.c
@@ -67,7 +67,7 @@ ipvs_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		goto out;
 	}
 
-	ip_vs_fill_iphdr(family, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_skb(family, skb, &iph);
 
 	if (data->bitmask & XT_IPVS_PROTO)
 		if ((iph.protocol == data->l4proto) ^
@@ -85,7 +85,7 @@ ipvs_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	/*
 	 * Check if the packet belongs to an existing entry
 	 */
-	cp = pp->conn_out_get(family, skb, &iph, iph.len, 1 /* inverse */);
+	cp = pp->conn_out_get(family, skb, &iph, 1 /* inverse */);
 	if (unlikely(cp == NULL)) {
 		match = false;
 		goto out;
