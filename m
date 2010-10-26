From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [RFC PATCH 1/4] IPVS: Prepare for transferring firewall marks (fwmark) to the backup daemon.
Date: Tue, 26 Oct 2010 13:00:20 +0200
Message-ID: <1288090823-31135-1-git-send-email-hans.schillstrom@ericsson.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>

Two structs will have fwmark added:
 * ip_vs_conn
 * ip_vs_conn_param

ip_vs_conn_fill_param will have an extra param - fwmark
The effects of that is in this patch.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/ip_vs.h                     |    7 ++++++-
 net/netfilter/ipvs/ip_vs_conn.c         |    9 +++++----
 net/netfilter/ipvs/ip_vs_core.c         |   13 +++++++------
 net/netfilter/ipvs/ip_vs_ctl.c          |    4 ++--
 net/netfilter/ipvs/ip_vs_ftp.c          |    8 +++++---
 net/netfilter/ipvs/ip_vs_nfct.c         |    2 +-
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |   13 ++++++++-----
 net/netfilter/ipvs/ip_vs_sync.c         |    4 ++--
 8 files changed, 36 insertions(+), 24 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index b7bbd6c..128965c 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -360,6 +360,7 @@ extern struct ip_vs_protocol * ip_vs_proto_get(unsigned short proto);
 struct ip_vs_conn_param {
 	const union nf_inet_addr	*caddr;
 	const union nf_inet_addr	*vaddr;
+	__be32				fwmark;
 	__be16				cport;
 	__be16				vport;
 	__u16				protocol;
@@ -381,6 +382,7 @@ struct ip_vs_conn {
 	union nf_inet_addr       caddr;          /* client address */
 	union nf_inet_addr       vaddr;          /* virtual address */
 	union nf_inet_addr       daddr;          /* destination address */
+	__be32			 fwmark;	 /* fw mark for service */
 	volatile __u32           flags;          /* status flags */
 	__be16                   cport;
 	__be16                   vport;
@@ -679,6 +681,7 @@ static inline void ip_vs_conn_fill_param(int af, int protocol,
 					 __be16 cport,
 					 const union nf_inet_addr *vaddr,
 					 __be16 vport,
+					 __be32 fwmark,
 					 struct ip_vs_conn_param *p)
 {
 	p->af = af;
@@ -687,6 +690,7 @@ static inline void ip_vs_conn_fill_param(int af, int protocol,
 	p->cport = cport;
 	p->vaddr = vaddr;
 	p->vport = vport;
+	p->fwmark = fwmark;
 	p->pe = NULL;
 	p->pe_data = NULL;
 }
@@ -889,7 +893,8 @@ extern int ip_vs_control_init(void);
 extern void ip_vs_control_cleanup(void);
 extern struct ip_vs_dest *
 ip_vs_find_dest(int af, const union nf_inet_addr *daddr, __be16 dport,
-		const union nf_inet_addr *vaddr, __be16 vport, __u16 protocol);
+		const union nf_inet_addr *vaddr, __be16 vport, __u16 protocol,
+		__u32 fwmark);
 extern struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp);
 
 
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index e9adecd..866165c 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -174,7 +174,7 @@ static unsigned int ip_vs_conn_hashkey_conn(const struct ip_vs_conn *cp)
 	struct ip_vs_conn_param p;
 
 	ip_vs_conn_fill_param(cp->af, cp->protocol, &cp->caddr, cp->cport,
-			      NULL, 0, &p);
+			      NULL, 0, 0, &p);
 
 	if (cp->dest && cp->dest->svc->pe) {
 		p.pe = cp->dest->svc->pe;
@@ -320,10 +320,10 @@ ip_vs_conn_fill_param_proto(int af, const struct sk_buff *skb,
 
 	if (likely(!inverse))
 		ip_vs_conn_fill_param(af, iph->protocol, &iph->saddr, pptr[0],
-				      &iph->daddr, pptr[1], p);
+				      &iph->daddr, pptr[1], skb->mark, p);
 	else
 		ip_vs_conn_fill_param(af, iph->protocol, &iph->daddr, pptr[1],
-				      &iph->saddr, pptr[0], p);
+				      &iph->saddr, pptr[0], skb->mark, p);
 	return 0;
 }
 
@@ -613,7 +613,7 @@ struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp)
 	if ((cp) && (!cp->dest)) {
 		dest = ip_vs_find_dest(cp->af, &cp->daddr, cp->dport,
 				       &cp->vaddr, cp->vport,
-				       cp->protocol);
+				       cp->protocol, cp->fwmark);
 		ip_vs_bind_dest(cp, dest);
 		return dest;
 	} else
@@ -825,6 +825,7 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
 	ip_vs_addr_copy(p->protocol == IPPROTO_IP ? AF_UNSPEC : p->af,
 			&cp->daddr, daddr);
 	cp->dport          = dport;
+	cp->fwmark	   = p->fwmark;
 	cp->flags	   = flags;
 	if (flags & IP_VS_CONN_F_TEMPLATE && p->pe_data) {
 		cp->pe_data = p->pe_data;
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index b4e51e9..61abf39 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -184,7 +184,8 @@ ip_vs_conn_fill_param_persist(const struct ip_vs_service *svc,
 			      const union nf_inet_addr *vaddr, __be16 vport,
 			      struct ip_vs_conn_param *p)
 {
-	ip_vs_conn_fill_param(svc->af, protocol, caddr, cport, vaddr, vport, p);
+	ip_vs_conn_fill_param(svc->af, protocol, caddr, cport, vaddr, vport,
+			      skb->mark, p);
 	p->pe = svc->pe;
 	if (p->pe && p->pe->fill_param)
 		p->pe->fill_param(p, skb);
@@ -318,7 +319,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	 *    Create a new connection according to the template
 	 */
 	ip_vs_conn_fill_param(svc->af, iph.protocol, &iph.saddr, ports[0],
-			      &iph.daddr, ports[1], &param);
+			      &iph.daddr, ports[1], skb->mark, &param);
 	cp = ip_vs_conn_new(&param, &dest->addr, dport, flags, dest);
 	if (cp == NULL) {
 		ip_vs_conn_put(ct);
@@ -419,8 +420,8 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	 */
 	{
 		struct ip_vs_conn_param p;
-		ip_vs_conn_fill_param(svc->af, iph.protocol, &iph.saddr,
-				      pptr[0], &iph.daddr, pptr[1], &p);
+		ip_vs_conn_fill_param(svc->af, iph.protocol, &iph.saddr, pptr[0],
+				      &iph.daddr, pptr[1], skb->mark, &p);
 		cp = ip_vs_conn_new(&p, &dest->addr,
 				    dest->port ? dest->port : pptr[1],
 				    flags, dest);
@@ -485,8 +486,8 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		{
 			struct ip_vs_conn_param p;
 			ip_vs_conn_fill_param(svc->af, iph.protocol,
-					      &iph.saddr, pptr[0],
-					      &iph.daddr, pptr[1], &p);
+					      &iph.saddr, pptr[0],&iph.daddr,
+					      pptr[1], skb->mark, &p);
 			cp = ip_vs_conn_new(&p, &daddr, 0,
 					    IP_VS_CONN_F_BYPASS | flags,
 					    NULL);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 5f5daa3..0129b52 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -657,12 +657,12 @@ ip_vs_lookup_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
 struct ip_vs_dest *ip_vs_find_dest(int af, const union nf_inet_addr *daddr,
 				   __be16 dport,
 				   const union nf_inet_addr *vaddr,
-				   __be16 vport, __u16 protocol)
+				   __be16 vport, __u16 protocol, __u32 fwmark)
 {
 	struct ip_vs_dest *dest;
 	struct ip_vs_service *svc;
 
-	svc = ip_vs_service_get(af, 0, protocol, vaddr, vport);
+	svc = ip_vs_service_get(af, fwmark, protocol, vaddr, vport);
 	if (!svc)
 		return NULL;
 	dest = ip_vs_lookup_dest(svc, daddr, dport);
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 7545500..84287c0 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -198,13 +198,15 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		{
 			struct ip_vs_conn_param p;
 			ip_vs_conn_fill_param(AF_INET, iph->protocol,
-					      &from, port, &cp->caddr, 0, &p);
+					      &from, port, &cp->caddr,
+					      0, skb->mark, &p);
 			n_cp = ip_vs_conn_out_get(&p);
 		}
 		if (!n_cp) {
 			struct ip_vs_conn_param p;
 			ip_vs_conn_fill_param(AF_INET, IPPROTO_TCP, &cp->caddr,
-					      0, &cp->vaddr, port, &p);
+					      0, &cp->vaddr, port,
+					      skb->mark, &p);
 			n_cp = ip_vs_conn_new(&p, &from, port,
 					      IP_VS_CONN_F_NO_CPORT |
 					      IP_VS_CONN_F_NFCT,
@@ -360,7 +362,7 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		struct ip_vs_conn_param p;
 		ip_vs_conn_fill_param(AF_INET, iph->protocol, &to, port,
 				      &cp->vaddr, htons(ntohs(cp->vport)-1),
-				      &p);
+				      skb->mark, &p);
 		n_cp = ip_vs_conn_in_get(&p);
 		if (!n_cp) {
 			n_cp = ip_vs_conn_new(&p, &cp->daddr,
diff --git a/net/netfilter/ipvs/ip_vs_nfct.c b/net/netfilter/ipvs/ip_vs_nfct.c
index 4680647..21afc06 100644
--- a/net/netfilter/ipvs/ip_vs_nfct.c
+++ b/net/netfilter/ipvs/ip_vs_nfct.c
@@ -157,7 +157,7 @@ static void ip_vs_nfct_expect_callback(struct nf_conn *ct,
 	orig = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
 	ip_vs_conn_fill_param(exp->tuple.src.l3num, orig->dst.protonum,
 			      &orig->src.u3, orig->src.u.tcp.port,
-			      &orig->dst.u3, orig->dst.u.tcp.port, &p);
+			      &orig->dst.u3, orig->dst.u.tcp.port, 0, &p);
 	cp = ip_vs_conn_out_get(&p);
 	if (cp) {
 		/* Change reply CLIENT->RS to CLIENT->VS */
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index 3a04611..6f62eba 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -42,16 +42,19 @@ struct isakmp_hdr {
 
 static void
 ah_esp_conn_fill_param_proto(int af, const struct ip_vs_iphdr *iph,
-			     int inverse, struct ip_vs_conn_param *p)
+			     int inverse, const struct sk_buff *skb,
+			     struct ip_vs_conn_param *p)
 {
 	if (likely(!inverse))
 		ip_vs_conn_fill_param(af, IPPROTO_UDP,
 				      &iph->saddr, htons(PORT_ISAKMP),
-				      &iph->daddr, htons(PORT_ISAKMP), p);
+				      &iph->daddr, htons(PORT_ISAKMP),
+				      skb->mark, p);
 	else
 		ip_vs_conn_fill_param(af, IPPROTO_UDP,
 				      &iph->daddr, htons(PORT_ISAKMP),
-				      &iph->saddr, htons(PORT_ISAKMP), p);
+				      &iph->saddr, htons(PORT_ISAKMP),
+				      skb->mark, p);
 }
 
 static struct ip_vs_conn *
@@ -62,7 +65,7 @@ ah_esp_conn_in_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
 	struct ip_vs_conn *cp;
 	struct ip_vs_conn_param p;
 
-	ah_esp_conn_fill_param_proto(af, iph, inverse, &p);
+	ah_esp_conn_fill_param_proto(af, iph, inverse, skb, &p);
 	cp = ip_vs_conn_in_get(&p);
 	if (!cp) {
 		/*
@@ -91,7 +94,7 @@ ah_esp_conn_out_get(int af, const struct sk_buff *skb,
 	struct ip_vs_conn *cp;
 	struct ip_vs_conn_param p;
 
-	ah_esp_conn_fill_param_proto(af, iph, inverse, &p);
+	ah_esp_conn_fill_param_proto(af, iph, inverse, skb, &p);
 	cp = ip_vs_conn_out_get(&p);
 	if (!cp) {
 		IP_VS_DBG_BUF(12, "Unknown ISAKMP entry for inout packet "
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index ab85aed..c74d47b 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -295,7 +295,7 @@ ip_vs_conn_fill_param_sync(int af, int protocol,
 			   struct ip_vs_conn_param *p)
 {
 	/* XXX: Need to take into account persistence engine */
-	ip_vs_conn_fill_param(af, protocol, caddr, cport, vaddr, vport, p);
+	ip_vs_conn_fill_param(af, protocol, caddr, cport, vaddr, vport, 0, p);
 	return 0;
 }
 
@@ -406,7 +406,7 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 					       s->dport,
 					       (union nf_inet_addr *)&s->vaddr,
 					       s->vport,
-					       s->protocol);
+					       s->protocol, 0);
 			/*  Set the approprite ativity flag */
 			if (s->protocol == IPPROTO_TCP) {
 				if (state != IP_VS_TCP_S_ESTABLISHED)
-- 
1.6.0.2

