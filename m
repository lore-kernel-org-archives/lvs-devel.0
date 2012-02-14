From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [PATCH 1/2] IPVS Bug IPv6 extension header handling faulty.
Date: Tue, 14 Feb 2012 13:48:08 +0100
Message-ID: <1329223689-19792-2-git-send-email-hans.schillstrom@ericsson.com>
References: <1329223689-19792-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1329223689-19792-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: kaber@trash.net, pablo@netfilter.org, hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

IPv6 headers must be processed in order of apperence,
neither can it be assumed that Upper layer headers is first.
If anything else than L4 is the first header IPVS will throw it.

IPVS will write SNAT & DNAT modifications at a fixed pos witch
will corrupt the message. Proper header possition must be found
before writing modifying packet.

Since it is quite costly to scan and find ipv6 headers, it
is done once and sent as "struct iphdr *" to affected funcs.
This is what causes most of the changes in this patch.

This patch depends on "NETFILTER added flags to ipv6_find_hdr()" patch
http://www.spinics.net/lists/netfilter-devel/msg20684.html

This also adds a dependence to ip6_tables.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/ip_vs.h                     |  143 +++++++++++------
 net/netfilter/ipvs/ip_vs_conn.c         |   15 +-
 net/netfilter/ipvs/ip_vs_core.c         |  261 +++++++++++++-----------------
 net/netfilter/ipvs/ip_vs_dh.c           |   10 +-
 net/netfilter/ipvs/ip_vs_lblc.c         |   12 +-
 net/netfilter/ipvs/ip_vs_lblcr.c        |   12 +-
 net/netfilter/ipvs/ip_vs_lc.c           |    3 +-
 net/netfilter/ipvs/ip_vs_nq.c           |    3 +-
 net/netfilter/ipvs/ip_vs_pe_sip.c       |   29 +++-
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |    9 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |   42 ++---
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |   40 ++---
 net/netfilter/ipvs/ip_vs_proto_udp.c    |   43 +++---
 net/netfilter/ipvs/ip_vs_rr.c           |    3 +-
 net/netfilter/ipvs/ip_vs_sed.c          |    3 +-
 net/netfilter/ipvs/ip_vs_sh.c           |   10 +-
 net/netfilter/ipvs/ip_vs_wlc.c          |    3 +-
 net/netfilter/ipvs/ip_vs_wrr.c          |    3 +-
 net/netfilter/ipvs/ip_vs_xmit.c         |   41 +++---
 net/netfilter/xt_ipvs.c                 |    4 +-
 20 files changed, 346 insertions(+), 343 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index ebe517f..4ad1f37a 100644
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
@@ -103,29 +106,71 @@ static inline struct net *seq_file_single_net(struct seq_file *seq)
 /* Connections' size value needed by ip_vs_ctl.c */
 extern int ip_vs_conn_tab_size;
 
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
 
 struct ip_vs_iphdr {
-	int len;
-	__u8 protocol;
+	__u32 len;	/* IPv4 simply where L4 starts
+			   IPv6 where to find next header */
+	__u32 offs;	/* IPv6 frags: header offset in nfct_reasm skb */
+	__u16 fragoffs;
+	__s16 protocol;
+	__s32 flags;
 	union nf_inet_addr saddr;
 	union nf_inet_addr daddr;
 };
 
 static inline void
-ip_vs_fill_iphdr(int af, const void *nh, struct ip_vs_iphdr *iphdr)
+ip_vs_fill_ip4hdr(const void *nh, struct ip_vs_iphdr *iphdr)
 {
+	const struct iphdr *iph = nh;
+
+	iphdr->len = iph->ihl * 4;
+	iphdr->offs = 0;
+	iphdr->fragoffs = 0;
+	iphdr->protocol = iph->protocol;
+	iphdr->flags = 0;
+	iphdr->saddr.ip = iph->saddr;
+	iphdr->daddr.ip = iph->daddr;
+}
+
+static inline void
+ip_vs_fill_iph_skb(int af, const struct sk_buff *skb, struct ip_vs_iphdr *iphdr)
+{
+	iphdr->len   = 0;
+	iphdr->flags = 0;
+	iphdr->offs  = 0;
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
-		const struct ipv6hdr *iph = nh;
-		iphdr->len = sizeof(struct ipv6hdr);
-		iphdr->protocol = iph->nexthdr;
+		const struct ipv6hdr *iph =
+			(struct ipv6hdr *)skb_network_header(skb);
+
+		iphdr->protocol = ipv6_find_hdr(skb, &iphdr->len, -1,
+						&iphdr->fragoffs,
+						&iphdr->flags);
 		iphdr->saddr.in6 = iph->saddr;
 		iphdr->daddr.in6 = iph->daddr;
+		/* get proto from re-assembled packet and it's offset */
+		if (skb_nfct_reasm(skb))
+			iphdr->protocol = ipv6_find_hdr(skb_nfct_reasm(skb),
+							&iphdr->offs, -1, NULL,
+							NULL);
 	} else
 #endif
 	{
-		const struct iphdr *iph = nh;
+		const struct iphdr *iph =
+			(struct iphdr *)skb_network_header(skb);
 		iphdr->len = iph->ihl * 4;
+		iphdr->fragoffs = 0;
 		iphdr->protocol = iph->protocol;
 		iphdr->saddr.ip = iph->saddr;
 		iphdr->daddr.ip = iph->daddr;
@@ -398,27 +443,26 @@ struct ip_vs_protocol {
 
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
@@ -517,7 +561,7 @@ struct ip_vs_conn {
 	   NF_ACCEPT can be returned when destination is local.
 	 */
 	int (*packet_xmit)(struct sk_buff *skb, struct ip_vs_conn *cp,
-			   struct ip_vs_protocol *pp);
+			   struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
 
 	/* Note: we can group the following members into a structure,
 	   in order to save more space, and the following members are
@@ -694,7 +738,8 @@ struct ip_vs_scheduler {
 
 	/* selecting a server from the given service */
 	struct ip_vs_dest* (*schedule)(struct ip_vs_service *svc,
-				       const struct sk_buff *skb);
+				       const struct sk_buff *skb,
+				       struct ip_vs_iphdr *iph);
 };
 
 /* The persistence engine object */
@@ -768,13 +813,11 @@ struct ip_vs_app {
 
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
@@ -993,14 +1036,12 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p);
 
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
@@ -1172,9 +1213,10 @@ extern struct ip_vs_scheduler *ip_vs_scheduler_get(const char *sched_name);
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
 
@@ -1233,33 +1275,38 @@ extern void ip_vs_read_estimator(struct ip_vs_stats_user *dst,
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
index 29fa5ba..550029d 100644
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
index 611c335..43b6eab 100644
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
@@ -235,20 +234,18 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
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
@@ -265,8 +262,8 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	 * is created for other persistent services.
 	 */
 	{
-		int protocol = iph.protocol;
-		const union nf_inet_addr *vaddr = &iph.daddr;
+		int protocol = iph->protocol;
+		const union nf_inet_addr *vaddr = &iph->daddr;
 		const union nf_inet_addr fwmark = { .ip = htonl(svc->fwmark) };
 		__be16 vport = 0;
 
@@ -307,7 +304,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 		 * template is not available.
 		 * return *ignored=0 i.e. ICMP and NF_DROP
 		 */
-		dest = svc->scheduler->schedule(svc, skb);
+		dest = svc->scheduler->schedule(svc, skb, iph);
 		if (!dest) {
 			IP_VS_DBG(1, "p-schedule: no dest found.\n");
 			kfree(param.pe_data);
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
 
@@ -449,14 +449,14 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 		return NULL;
 	}
 
-	dest = svc->scheduler->schedule(svc, skb);
+	dest = svc->scheduler->schedule(svc, skb, iph);
 	if (dest == NULL) {
 		IP_VS_DBG(1, "Schedule: no dest found.\n");
 		return NULL;
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
@@ -1358,11 +1327,10 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	IP_VS_DBG_PKT(11, AF_INET, pp, skb, offset,
 		      "Checking incoming ICMP for");
 
-	offset += cih->ihl * 4;
-
-	ip_vs_fill_iphdr(AF_INET, cih, &ciph);
+	ip_vs_fill_ip4hdr(cih, &ciph);
+	ciph.len += offset;
 	/* The embedded headers contain source and dest in reverse order */
-	cp = pp->conn_in_get(AF_INET, skb, &ciph, offset, 1);
+	cp = pp->conn_in_get(AF_INET, skb, &ciph, 1);
 	if (!cp)
 		return NF_ACCEPT;
 
@@ -1379,8 +1347,8 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	/* do the statistics and put it back */
 	ip_vs_in_stats(cp, skb);
 	if (IPPROTO_TCP == cih->protocol || IPPROTO_UDP == cih->protocol)
-		offset += 2 * sizeof(__u16);
-	verdict = ip_vs_icmp_xmit(skb, cp, pp, offset, hooknum);
+		ciph.len += 2 * sizeof(__u16);
+	verdict = ip_vs_icmp_xmit(skb, cp, pp, ciph.len, hooknum, &ciph);
 
 out:
 	__ip_vs_conn_put(cp);
@@ -1389,14 +1357,11 @@ out:
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
@@ -1405,19 +1370,11 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 
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
 
@@ -1436,39 +1393,43 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
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
 
@@ -1504,7 +1465,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (unlikely((skb->pkt_type != PACKET_HOST &&
 		      hooknum != NF_INET_LOCAL_OUT) ||
 		     !skb_dst(skb))) {
-		ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+		ip_vs_fill_iph_skb(af, skb, &iph);
 		IP_VS_DBG_BUF(12, "packet type=%d proto=%d daddr=%s"
 			      " ignored in hook %u\n",
 			      skb->pkt_type, iph.protocol,
@@ -1516,7 +1477,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (!net_ipvs(net)->enable)
 		return NF_ACCEPT;
 
-	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_skb(af, skb, &iph);
 
 	/* Bad... Do not break raw sockets */
 	if (unlikely(skb->sk != NULL && hooknum == NF_INET_LOCAL_OUT &&
@@ -1532,11 +1493,12 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (af == AF_INET6) {
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
 			int related;
-			int verdict = ip_vs_in_icmp_v6(skb, &related, hooknum);
+			int verdict = ip_vs_in_icmp_v6(skb, &related, hooknum,
+						       &iph);
 
 			if (related)
 				return verdict;
-			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+			ip_vs_fill_iph_skb(af, skb, &iph);
 		}
 	} else
 #endif
@@ -1546,7 +1508,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 
 			if (related)
 				return verdict;
-			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+			/* I don't think this one is needed ... /HS */
+			ip_vs_fill_iph_skb(af, skb, &iph);
 		}
 
 	/* Protocol supported? */
@@ -1556,13 +1519,13 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
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
 
@@ -1592,7 +1555,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	ip_vs_in_stats(cp, skb);
 	ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd);
 	if (cp->packet_xmit)
-		ret = cp->packet_xmit(skb, cp, pp);
+		ret = cp->packet_xmit(skb, cp, pp, &iph);
 		/* do not touch skb anymore */
 	else {
 		IP_VS_DBG_RL("warning: packet_xmit is null");
@@ -1749,8 +1712,10 @@ ip_vs_forward_icmp_v6(unsigned int hooknum, struct sk_buff *skb,
 {
 	int r;
 	struct net *net;
+	struct ip_vs_iphdr iphdr;
 
-	if (ipv6_hdr(skb)->nexthdr != IPPROTO_ICMPV6)
+	ip_vs_fill_iph_skb(AF_INET6, skb, &iphdr);
+	if (iphdr.protocol != IPPROTO_ICMPV6)
 		return NF_ACCEPT;
 
 	/* ipvs enabled in this netns ? */
@@ -1758,7 +1723,7 @@ ip_vs_forward_icmp_v6(unsigned int hooknum, struct sk_buff *skb,
 	if (!net_ipvs(net)->enable)
 		return NF_ACCEPT;
 
-	return ip_vs_in_icmp_v6(skb, &r, hooknum);
+	return ip_vs_in_icmp_v6(skb, &r, hooknum, &iphdr);
 }
 #endif
 
diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index 1c269e5..e4ea1fd 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -209,18 +209,16 @@ static inline int is_overloaded(struct ip_vs_dest *dest)
  *      Destination hashing scheduling
  */
 static struct ip_vs_dest *
-ip_vs_dh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
+ip_vs_dh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		  struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_dest *dest;
 	struct ip_vs_dh_bucket *tbl;
-	struct ip_vs_iphdr iph;
-
-	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
 	tbl = (struct ip_vs_dh_bucket *)svc->sched_data;
-	dest = ip_vs_dh_get(svc->af, tbl, &iph.daddr);
+	dest = ip_vs_dh_get(svc->af, tbl, &iph->daddr);
 	if (!dest
 	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
 	    || atomic_read(&dest->weight) <= 0
@@ -229,7 +227,7 @@ ip_vs_dh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	}
 
 	IP_VS_DBG_BUF(6, "DH: destination IP address %s --> server %s:%d\n",
-		      IP_VS_DBG_ADDR(svc->af, &iph.daddr),
+		      IP_VS_DBG_ADDR(svc->af, &iph->daddr),
 		      IP_VS_DBG_ADDR(svc->af, &dest->addr),
 		      ntohs(dest->port));
 
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 0f16283..74c7278 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -472,20 +472,18 @@ is_overloaded(struct ip_vs_dest *dest, struct ip_vs_service *svc)
  *    Locality-Based (weighted) Least-Connection scheduling
  */
 static struct ip_vs_dest *
-ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
+ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		    struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_lblc_table *tbl = svc->sched_data;
-	struct ip_vs_iphdr iph;
 	struct ip_vs_dest *dest = NULL;
 	struct ip_vs_lblc_entry *en;
 
-	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
-
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
 	/* First look in our cache */
 	read_lock(&svc->sched_lock);
-	en = ip_vs_lblc_get(svc->af, tbl, &iph.daddr);
+	en = ip_vs_lblc_get(svc->af, tbl, &iph->daddr);
 	if (en) {
 		/* We only hold a read lock, but this is atomic */
 		en->lastuse = jiffies;
@@ -517,12 +515,12 @@ ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 
 	/* If we fail to create a cache entry, we'll just use the valid dest */
 	write_lock(&svc->sched_lock);
-	ip_vs_lblc_new(tbl, &iph.daddr, dest);
+	ip_vs_lblc_new(tbl, &iph->daddr, dest);
 	write_unlock(&svc->sched_lock);
 
 out:
 	IP_VS_DBG_BUF(6, "LBLC: destination IP address %s --> server %s:%d\n",
-		      IP_VS_DBG_ADDR(svc->af, &iph.daddr),
+		      IP_VS_DBG_ADDR(svc->af, &iph->daddr),
 		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port));
 
 	return dest;
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index eec797f..8620c68 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -642,20 +642,18 @@ is_overloaded(struct ip_vs_dest *dest, struct ip_vs_service *svc)
  *    Locality-Based (weighted) Least-Connection scheduling
  */
 static struct ip_vs_dest *
-ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
+ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		     struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_lblcr_table *tbl = svc->sched_data;
-	struct ip_vs_iphdr iph;
 	struct ip_vs_dest *dest = NULL;
 	struct ip_vs_lblcr_entry *en;
 
-	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
-
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
 	/* First look in our cache */
 	read_lock(&svc->sched_lock);
-	en = ip_vs_lblcr_get(svc->af, tbl, &iph.daddr);
+	en = ip_vs_lblcr_get(svc->af, tbl, &iph->daddr);
 	if (en) {
 		/* We only hold a read lock, but this is atomic */
 		en->lastuse = jiffies;
@@ -711,12 +709,12 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 
 	/* If we fail to create a cache entry, we'll just use the valid dest */
 	write_lock(&svc->sched_lock);
-	ip_vs_lblcr_new(tbl, &iph.daddr, dest);
+	ip_vs_lblcr_new(tbl, &iph->daddr, dest);
 	write_unlock(&svc->sched_lock);
 
 out:
 	IP_VS_DBG_BUF(6, "LBLCR: destination IP address %s --> server %s:%d\n",
-		      IP_VS_DBG_ADDR(svc->af, &iph.daddr),
+		      IP_VS_DBG_ADDR(svc->af, &iph->daddr),
 		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port));
 
 	return dest;
diff --git a/net/netfilter/ipvs/ip_vs_lc.c b/net/netfilter/ipvs/ip_vs_lc.c
index f391819..316ba52 100644
--- a/net/netfilter/ipvs/ip_vs_lc.c
+++ b/net/netfilter/ipvs/ip_vs_lc.c
@@ -26,7 +26,8 @@
  *	Least Connection scheduling
  */
 static struct ip_vs_dest *
-ip_vs_lc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
+ip_vs_lc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		  struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_dest *dest, *least = NULL;
 	unsigned int loh = 0, doh;
diff --git a/net/netfilter/ipvs/ip_vs_nq.c b/net/netfilter/ipvs/ip_vs_nq.c
index 984d9c1..d13e9c6 100644
--- a/net/netfilter/ipvs/ip_vs_nq.c
+++ b/net/netfilter/ipvs/ip_vs_nq.c
@@ -55,7 +55,8 @@ ip_vs_nq_dest_overhead(struct ip_vs_dest *dest)
  *	Weighted Least Connection scheduling
  */
 static struct ip_vs_dest *
-ip_vs_nq_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
+ip_vs_nq_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		  struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_dest *dest, *least = NULL;
 	unsigned int loh = 0, doh;
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
index 1fbf7a2..40e0e54 100644
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
index ef8641f..623dcde 100644
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
index f4b7262..92f4207 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -30,23 +30,24 @@
 
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
+	/*
+	 * IPv6 fragments, only first fragment will hit this /HS
+	 */
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
 
@@ -64,10 +65,10 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
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
@@ -125,20 +126,18 @@ udp_partial_csum_update(int af, struct udphdr *uhdr,
 
 
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
@@ -210,20 +209,18 @@ udp_snat_handler(struct sk_buff *skb,
 
 
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
diff --git a/net/netfilter/ipvs/ip_vs_rr.c b/net/netfilter/ipvs/ip_vs_rr.c
index c49b388..a8fb998 100644
--- a/net/netfilter/ipvs/ip_vs_rr.c
+++ b/net/netfilter/ipvs/ip_vs_rr.c
@@ -46,7 +46,8 @@ static int ip_vs_rr_update_svc(struct ip_vs_service *svc)
  * Round-Robin Scheduling
  */
 static struct ip_vs_dest *
-ip_vs_rr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
+ip_vs_rr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		  struct ip_vs_iphdr *iph)
 {
 	struct list_head *p, *q;
 	struct ip_vs_dest *dest;
diff --git a/net/netfilter/ipvs/ip_vs_sed.c b/net/netfilter/ipvs/ip_vs_sed.c
index 89ead24..26735e8 100644
--- a/net/netfilter/ipvs/ip_vs_sed.c
+++ b/net/netfilter/ipvs/ip_vs_sed.c
@@ -59,7 +59,8 @@ ip_vs_sed_dest_overhead(struct ip_vs_dest *dest)
  *	Weighted Least Connection scheduling
  */
 static struct ip_vs_dest *
-ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
+ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		   struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_dest *dest, *least;
 	unsigned int loh, doh;
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 069e8d4..51d5a61 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -222,18 +222,16 @@ static inline int is_overloaded(struct ip_vs_dest *dest)
  *      Source Hashing scheduling
  */
 static struct ip_vs_dest *
-ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
+ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		  struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_dest *dest;
 	struct ip_vs_sh_bucket *tbl;
-	struct ip_vs_iphdr iph;
-
-	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 
 	IP_VS_DBG(6, "ip_vs_sh_schedule(): Scheduling...\n");
 
 	tbl = (struct ip_vs_sh_bucket *)svc->sched_data;
-	dest = ip_vs_sh_get(svc->af, tbl, &iph.saddr);
+	dest = ip_vs_sh_get(svc->af, tbl, &iph->saddr);
 	if (!dest
 	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
 	    || atomic_read(&dest->weight) <= 0
@@ -243,7 +241,7 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	}
 
 	IP_VS_DBG_BUF(6, "SH: source IP address %s --> server %s:%d\n",
-		      IP_VS_DBG_ADDR(svc->af, &iph.saddr),
+		      IP_VS_DBG_ADDR(svc->af, &iph->saddr),
 		      IP_VS_DBG_ADDR(svc->af, &dest->addr),
 		      ntohs(dest->port));
 
diff --git a/net/netfilter/ipvs/ip_vs_wlc.c b/net/netfilter/ipvs/ip_vs_wlc.c
index bc1bfc4..ad5672e 100644
--- a/net/netfilter/ipvs/ip_vs_wlc.c
+++ b/net/netfilter/ipvs/ip_vs_wlc.c
@@ -31,7 +31,8 @@
  *	Weighted Least Connection scheduling
  */
 static struct ip_vs_dest *
-ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
+ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		   struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_dest *dest, *least;
 	unsigned int loh, doh;
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index fd0d4e0..5fcdd3b 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -126,7 +126,8 @@ static int ip_vs_wrr_update_svc(struct ip_vs_service *svc)
  *    Weighted Round-Robin Scheduling
  */
 static struct ip_vs_dest *
-ip_vs_wrr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
+ip_vs_wrr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		   struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_dest *dest;
 	struct ip_vs_wrr_mark *mark = svc->sched_data;
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 7fd66de..53155c1 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -379,7 +379,7 @@ do {							\
  */
 int
 ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		struct ip_vs_protocol *pp)
+		struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	/* we do not touch skb and do not need pskb ptr */
 	IP_VS_XMIT(NFPROTO_IPV4, skb, cp, 1);
@@ -393,7 +393,7 @@ ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
  */
 int
 ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp)
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	struct rtable *rt;			/* Route to the other host */
 	struct iphdr  *iph = ip_hdr(skb);
@@ -448,16 +448,16 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
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
@@ -511,7 +511,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
  */
 int
 ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-	       struct ip_vs_protocol *pp)
+	       struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	struct rtable *rt;		/* Route to the other host */
 	int mtu;
@@ -581,7 +581,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error_put;
 
 	/* mangle the packet */
-	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp))
+	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp, ipvsh))
 		goto tx_error_put;
 	ip_hdr(skb)->daddr = cp->daddr.ip;
 	ip_send_check(ip_hdr(skb));
@@ -629,7 +629,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp)
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph)
 {
 	struct rt6_info *rt;		/* Route to the other host */
 	int mtu;
@@ -640,8 +640,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* check if it is a connection of no-client-port */
 	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT)) {
 		__be16 _pt, *p;
-		p = skb_header_pointer(skb, sizeof(struct ipv6hdr),
-				       sizeof(_pt), &_pt);
+		p = skb_header_pointer(skb, iph->len, sizeof(_pt), &_pt);
 		if (p == NULL)
 			goto tx_error;
 		ip_vs_conn_fill_cport(cp, *p);
@@ -703,7 +702,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error_put;
 
 	/* mangle the packet */
-	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp))
+	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp, iph))
 		goto tx_error;
 	ipv6_hdr(skb)->daddr = cp->daddr.in6;
 
@@ -764,7 +763,7 @@ tx_error_put:
  */
 int
 ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		  struct ip_vs_protocol *pp)
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	struct rtable *rt;			/* Route to the other host */
 	__be32 saddr;				/* Source for tunnel */
@@ -882,7 +881,7 @@ tx_error_put:
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		     struct ip_vs_protocol *pp)
+		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	struct rt6_info *rt;		/* Route to the other host */
 	struct in6_addr saddr;		/* Source for tunnel */
@@ -1003,7 +1002,7 @@ tx_error_put:
  */
 int
 ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-	      struct ip_vs_protocol *pp)
+	      struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
 	struct rtable *rt;			/* Route to the other host */
 	struct iphdr  *iph = ip_hdr(skb);
@@ -1064,7 +1063,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		 struct ip_vs_protocol *pp)
+		 struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph)
 {
 	struct rt6_info *rt;			/* Route to the other host */
 	int    mtu;
@@ -1132,7 +1131,8 @@ tx_error:
  */
 int
 ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-		struct ip_vs_protocol *pp, int offset, unsigned int hooknum)
+		struct ip_vs_protocol *pp, int offset, unsigned int hooknum,
+		struct ip_vs_iphdr *iph)
 {
 	struct rtable	*rt;	/* Route to the other host */
 	int mtu;
@@ -1147,7 +1147,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	   translate address/port back */
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
 		if (cp->packet_xmit)
-			rc = cp->packet_xmit(skb, cp, pp);
+			rc = cp->packet_xmit(skb, cp, pp, iph);
 		else
 			rc = NF_ACCEPT;
 		/* do not touch skb anymore */
@@ -1253,7 +1253,8 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #ifdef CONFIG_IP_VS_IPV6
 int
 ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-		struct ip_vs_protocol *pp, int offset, unsigned int hooknum)
+		struct ip_vs_protocol *pp, int offset, unsigned int hooknum,
+		struct ip_vs_iphdr *iph)
 {
 	struct rt6_info	*rt;	/* Route to the other host */
 	int mtu;
@@ -1268,7 +1269,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
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
-- 
1.7.2.3
