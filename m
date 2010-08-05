From: Simon Horman <horms@verge.net.au>
Subject: [rfc 05/13] [RFC 05/13] IPVS: Add struct ip_vs_conn_param
Date: Thu, 05 Aug 2010 20:48:00 +0900
Message-ID: <20100805115240.514170255@vergenet.net>
References: <20100805114755.118303531@vergenet.net>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline; filename=0005-IPVS-Add-struct-ip_vs_conn_param.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h                     |   44 ++++++---
 net/netfilter/ipvs/ip_vs_conn.c         |  161 +++++++++++++++----------------
 net/netfilter/ipvs/ip_vs_core.c         |   63 ++++++------
 net/netfilter/ipvs/ip_vs_ftp.c          |   58 +++++++-----
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |   47 ++++------
 net/netfilter/ipvs/ip_vs_sync.c         |   33 +++----
 6 files changed, 208 insertions(+), 198 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index a4747a0..68f9b4a 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -355,6 +355,15 @@ struct ip_vs_protocol {
 
 extern struct ip_vs_protocol * ip_vs_proto_get(unsigned short proto);
 
+struct ip_vs_conn_param {
+	const union nf_inet_addr	*caddr;
+	const union nf_inet_addr	*vaddr;
+	__be16				cport;
+	__be16				vport;
+	__u16				protocol;
+	u16				af;
+};
+
 /*
  *	IP_VS structure allocated for each dynamically scheduled connection
  */
@@ -624,13 +633,23 @@ enum {
 	IP_VS_DIR_LAST,
 };
 
-extern struct ip_vs_conn *ip_vs_conn_in_get
-(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
- const union nf_inet_addr *d_addr, __be16 d_port);
+static inline void ip_vs_conn_fill_param(int af, int protocol,
+					 const union nf_inet_addr *caddr,
+					 __be16 cport,
+					 const union nf_inet_addr *vaddr,
+					 __be16 vport,
+					 struct ip_vs_conn_param *p)
+{
+	p->af = af;
+	p->protocol = protocol;
+	p->caddr = caddr;
+	p->cport = cport;
+	p->vaddr = vaddr;
+	p->vport = vport;
+}
 
-extern struct ip_vs_conn *ip_vs_ct_in_get
-(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
- const union nf_inet_addr *d_addr, __be16 d_port);
+struct ip_vs_conn *ip_vs_conn_in_get(const struct ip_vs_conn_param *p);
+struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p);
 
 struct ip_vs_conn * ip_vs_conn_in_get_proto(int af, const struct sk_buff *skb,
 					    struct ip_vs_protocol *pp,
@@ -638,9 +657,7 @@ struct ip_vs_conn * ip_vs_conn_in_get_proto(int af, const struct sk_buff *skb,
 					    unsigned int proto_off,
 					    int inverse);
 
-extern struct ip_vs_conn *ip_vs_conn_out_get
-(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
- const union nf_inet_addr *d_addr, __be16 d_port);
+struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p);
 
 struct ip_vs_conn * ip_vs_conn_out_get_proto(int af, const struct sk_buff *skb,
 					     struct ip_vs_protocol *pp,
@@ -656,11 +673,10 @@ static inline void __ip_vs_conn_put(struct ip_vs_conn *cp)
 extern void ip_vs_conn_put(struct ip_vs_conn *cp);
 extern void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport);
 
-extern struct ip_vs_conn *
-ip_vs_conn_new(int af, int proto, const union nf_inet_addr *caddr, __be16 cport,
-	       const union nf_inet_addr *vaddr, __be16 vport,
-	       const union nf_inet_addr *daddr, __be16 dport, unsigned flags,
-	       struct ip_vs_dest *dest);
+struct ip_vs_conn *ip_vs_conn_new(const struct ip_vs_conn_param *p,
+				  const union nf_inet_addr *daddr,
+				  __be16 dport, unsigned flags,
+				  struct ip_vs_dest *dest);
 extern void ip_vs_conn_expire_now(struct ip_vs_conn *cp);
 
 extern const char * ip_vs_state_name(__u16 proto, int state);
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index b71c69a..ca5d2f1 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -218,27 +218,26 @@ static inline int ip_vs_conn_unhash(struct ip_vs_conn *cp)
 /*
  *  Gets ip_vs_conn associated with supplied parameters in the ip_vs_conn_tab.
  *  Called for pkts coming from OUTside-to-INside.
- *	s_addr, s_port: pkt source address (foreign host)
- *	d_addr, d_port: pkt dest address (load balancer)
+ *	p->caddr, p->cport: pkt source address (foreign host)
+ *	p->vaddr, p->vport: pkt dest address (load balancer)
  */
-static inline struct ip_vs_conn *__ip_vs_conn_in_get
-(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
- const union nf_inet_addr *d_addr, __be16 d_port)
+static inline struct ip_vs_conn *
+__ip_vs_conn_in_get(const struct ip_vs_conn_param *p)
 {
 	unsigned hash;
 	struct ip_vs_conn *cp;
 
-	hash = ip_vs_conn_hashkey(af, protocol, s_addr, s_port);
+	hash = ip_vs_conn_hashkey(p->af, p->protocol, p->caddr, p->cport);
 
 	ct_read_lock(hash);
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (cp->af == af &&
-		    ip_vs_addr_equal(af, s_addr, &cp->caddr) &&
-		    ip_vs_addr_equal(af, d_addr, &cp->vaddr) &&
-		    s_port == cp->cport && d_port == cp->vport &&
-		    ((!s_port) ^ (!(cp->flags & IP_VS_CONN_F_NO_CPORT))) &&
-		    protocol == cp->protocol) {
+		if (cp->af == p->af &&
+		    ip_vs_addr_equal(p->af, p->caddr, &cp->caddr) &&
+		    ip_vs_addr_equal(p->af, p->vaddr, &cp->vaddr) &&
+		    p->cport == cp->cport && p->vport == cp->vport &&
+		    ((!p->cport) ^ (!(cp->flags & IP_VS_CONN_F_NO_CPORT))) &&
+		    p->protocol == cp->protocol) {
 			/* HIT */
 			atomic_inc(&cp->refcnt);
 			ct_read_unlock(hash);
@@ -251,71 +250,82 @@ static inline struct ip_vs_conn *__ip_vs_conn_in_get
 	return NULL;
 }
 
-struct ip_vs_conn *ip_vs_conn_in_get
-(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
- const union nf_inet_addr *d_addr, __be16 d_port)
+struct ip_vs_conn *ip_vs_conn_in_get(const struct ip_vs_conn_param *p)
 {
 	struct ip_vs_conn *cp;
 
-	cp = __ip_vs_conn_in_get(af, protocol, s_addr, s_port, d_addr, d_port);
-	if (!cp && atomic_read(&ip_vs_conn_no_cport_cnt))
-		cp = __ip_vs_conn_in_get(af, protocol, s_addr, 0, d_addr,
-					 d_port);
+	cp = __ip_vs_conn_in_get(p);
+	if (!cp && atomic_read(&ip_vs_conn_no_cport_cnt)) {
+		struct ip_vs_conn_param cport_zero_p = *p;
+		cport_zero_p.cport = 0;
+		cp = __ip_vs_conn_in_get(&cport_zero_p);
+	}
 
 	IP_VS_DBG_BUF(9, "lookup/in %s %s:%d->%s:%d %s\n",
-		      ip_vs_proto_name(protocol),
-		      IP_VS_DBG_ADDR(af, s_addr), ntohs(s_port),
-		      IP_VS_DBG_ADDR(af, d_addr), ntohs(d_port),
+		      ip_vs_proto_name(p->protocol),
+		      IP_VS_DBG_ADDR(p->af, p->caddr), ntohs(p->cport),
+		      IP_VS_DBG_ADDR(p->af, p->vaddr), ntohs(p->vport),
 		      cp ? "hit" : "not hit");
 
 	return cp;
 }
 
+static int
+ip_vs_conn_fill_param_proto(int af, const struct sk_buff *skb,
+			    const struct ip_vs_iphdr *iph,
+			    unsigned int proto_off, int inverse,
+			    struct ip_vs_conn_param *p)
+{
+	__be16 _ports[2], *pptr;
+
+	pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
+	if (pptr == NULL)
+		return 1;
+
+	if (likely(!inverse))
+		ip_vs_conn_fill_param(af, iph->protocol, &iph->saddr, pptr[0],
+				      &iph->daddr, pptr[1], p);
+	else
+		ip_vs_conn_fill_param(af, iph->protocol, &iph->saddr, pptr[0],
+				      &iph->daddr, pptr[1], p);
+	return 0;
+}
+
 struct ip_vs_conn *
 ip_vs_conn_in_get_proto(int af, const struct sk_buff *skb,
 			struct ip_vs_protocol *pp,
 			const struct ip_vs_iphdr *iph,
 			unsigned int proto_off, int inverse)
 {
-	__be16 _ports[2], *pptr;
+	struct ip_vs_conn_param p;
 
-	pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
-	if (pptr == NULL)
+	if (ip_vs_conn_fill_param_proto(af, skb, iph, proto_off, inverse, &p))
 		return NULL;
 
-	if (likely(!inverse))
-		return ip_vs_conn_in_get(af, iph->protocol,
-					 &iph->saddr, pptr[0],
-					 &iph->daddr, pptr[1]);
-	else
-		return ip_vs_conn_in_get(af, iph->protocol,
-					 &iph->daddr, pptr[1],
-					 &iph->saddr, pptr[0]);
+	return ip_vs_conn_in_get(&p);
 }
 EXPORT_SYMBOL_GPL(ip_vs_conn_in_get_proto);
 
 /* Get reference to connection template */
-struct ip_vs_conn *ip_vs_ct_in_get
-(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
- const union nf_inet_addr *d_addr, __be16 d_port)
+struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
 {
 	unsigned hash;
 	struct ip_vs_conn *cp;
 
-	hash = ip_vs_conn_hashkey(af, protocol, s_addr, s_port);
+	hash = ip_vs_conn_hashkey(p->af, p->protocol, p->caddr, p->cport);
 
 	ct_read_lock(hash);
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (cp->af == af &&
-		    ip_vs_addr_equal(af, s_addr, &cp->caddr) &&
+		if (cp->af == p->af &&
+		    ip_vs_addr_equal(p->af, p->caddr, &cp->caddr) &&
 		    /* protocol should only be IPPROTO_IP if
-		     * d_addr is a fwmark */
-		    ip_vs_addr_equal(protocol == IPPROTO_IP ? AF_UNSPEC : af,
-		                     d_addr, &cp->vaddr) &&
-		    s_port == cp->cport && d_port == cp->vport &&
+		     * p->vaddr is a fwmark */
+		    ip_vs_addr_equal(p->protocol == IPPROTO_IP ? AF_UNSPEC :
+				     p->af, p->vaddr, &cp->vaddr) &&
+		    p->cport == cp->cport && p->vport == cp->vport &&
 		    cp->flags & IP_VS_CONN_F_TEMPLATE &&
-		    protocol == cp->protocol) {
+		    p->protocol == cp->protocol) {
 			/* HIT */
 			atomic_inc(&cp->refcnt);
 			goto out;
@@ -327,9 +337,9 @@ struct ip_vs_conn *ip_vs_ct_in_get
 	ct_read_unlock(hash);
 
 	IP_VS_DBG_BUF(9, "template lookup/in %s %s:%d->%s:%d %s\n",
-		      ip_vs_proto_name(protocol),
-		      IP_VS_DBG_ADDR(af, s_addr), ntohs(s_port),
-		      IP_VS_DBG_ADDR(af, d_addr), ntohs(d_port),
+		      ip_vs_proto_name(p->protocol),
+		      IP_VS_DBG_ADDR(p->af, p->caddr), ntohs(p->cport),
+		      IP_VS_DBG_ADDR(p->af, p->vaddr), ntohs(p->vport),
 		      cp ? "hit" : "not hit");
 
 	return cp;
@@ -341,9 +351,7 @@ struct ip_vs_conn *ip_vs_ct_in_get
  *	s_addr, s_port: pkt source address (inside host)
  *	d_addr, d_port: pkt dest address (foreign host)
  */
-struct ip_vs_conn *ip_vs_conn_out_get
-(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
- const union nf_inet_addr *d_addr, __be16 d_port)
+struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
 {
 	unsigned hash;
 	struct ip_vs_conn *cp, *ret=NULL;
@@ -351,16 +359,16 @@ struct ip_vs_conn *ip_vs_conn_out_get
 	/*
 	 *	Check for "full" addressed entries
 	 */
-	hash = ip_vs_conn_hashkey(af, protocol, d_addr, d_port);
+	hash = ip_vs_conn_hashkey(p->af, p->protocol, p->vaddr, p->vport);
 
 	ct_read_lock(hash);
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (cp->af == af &&
-		    ip_vs_addr_equal(af, d_addr, &cp->caddr) &&
-		    ip_vs_addr_equal(af, s_addr, &cp->daddr) &&
-		    d_port == cp->cport && s_port == cp->dport &&
-		    protocol == cp->protocol) {
+		if (cp->af == p->af &&
+		    ip_vs_addr_equal(p->af, p->vaddr, &cp->caddr) &&
+		    ip_vs_addr_equal(p->af, p->caddr, &cp->daddr) &&
+		    p->vport == cp->cport && p->cport == cp->dport &&
+		    p->protocol == cp->protocol) {
 			/* HIT */
 			atomic_inc(&cp->refcnt);
 			ret = cp;
@@ -371,9 +379,9 @@ struct ip_vs_conn *ip_vs_conn_out_get
 	ct_read_unlock(hash);
 
 	IP_VS_DBG_BUF(9, "lookup/out %s %s:%d->%s:%d %s\n",
-		      ip_vs_proto_name(protocol),
-		      IP_VS_DBG_ADDR(af, s_addr), ntohs(s_port),
-		      IP_VS_DBG_ADDR(af, d_addr), ntohs(d_port),
+		      ip_vs_proto_name(p->protocol),
+		      IP_VS_DBG_ADDR(p->af, p->caddr), ntohs(p->cport),
+		      IP_VS_DBG_ADDR(p->af, p->vaddr), ntohs(p->vport),
 		      ret ? "hit" : "not hit");
 
 	return ret;
@@ -385,20 +393,12 @@ ip_vs_conn_out_get_proto(int af, const struct sk_buff *skb,
 			 const struct ip_vs_iphdr *iph,
 			 unsigned int proto_off, int inverse)
 {
-	__be16 _ports[2], *pptr;
+	struct ip_vs_conn_param p;
 
-	pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
-	if (pptr == NULL)
+	if (!ip_vs_conn_fill_param_proto(af, skb, iph, proto_off, inverse, &p))
 		return NULL;
 
-	if (likely(!inverse))
-		return ip_vs_conn_out_get(af, iph->protocol,
-					  &iph->saddr, pptr[0],
-					  &iph->daddr, pptr[1]);
-	else
-		return ip_vs_conn_out_get(af, iph->protocol,
-					  &iph->daddr, pptr[1],
-					  &iph->saddr, pptr[0]);
+	return ip_vs_conn_out_get(&p);
 }
 EXPORT_SYMBOL_GPL(ip_vs_conn_out_get_proto);
 
@@ -751,13 +751,12 @@ void ip_vs_conn_expire_now(struct ip_vs_conn *cp)
  *	Create a new connection entry and hash it into the ip_vs_conn_tab
  */
 struct ip_vs_conn *
-ip_vs_conn_new(int af, int proto, const union nf_inet_addr *caddr, __be16 cport,
-	       const union nf_inet_addr *vaddr, __be16 vport,
+ip_vs_conn_new(const struct ip_vs_conn_param *p,
 	       const union nf_inet_addr *daddr, __be16 dport, unsigned flags,
 	       struct ip_vs_dest *dest)
 {
 	struct ip_vs_conn *cp;
-	struct ip_vs_protocol *pp = ip_vs_proto_get(proto);
+	struct ip_vs_protocol *pp = ip_vs_proto_get(p->protocol);
 
 	cp = kmem_cache_zalloc(ip_vs_conn_cachep, GFP_ATOMIC);
 	if (cp == NULL) {
@@ -767,14 +766,14 @@ ip_vs_conn_new(int af, int proto, const union nf_inet_addr *caddr, __be16 cport,
 
 	INIT_LIST_HEAD(&cp->c_list);
 	setup_timer(&cp->timer, ip_vs_conn_expire, (unsigned long)cp);
-	cp->af		   = af;
-	cp->protocol	   = proto;
-	ip_vs_addr_copy(af, &cp->caddr, caddr);
-	cp->cport	   = cport;
-	ip_vs_addr_copy(af, &cp->vaddr, vaddr);
-	cp->vport	   = vport;
+	cp->af		   = p->af;
+	cp->protocol	   = p->protocol;
+	ip_vs_addr_copy(p->af, &cp->caddr, p->caddr);
+	cp->cport	   = p->cport;
+	ip_vs_addr_copy(p->af, &cp->vaddr, p->vaddr);
+	cp->vport	   = p->vport;
 	/* proto should only be IPPROTO_IP if d_addr is a fwmark */
-	ip_vs_addr_copy(proto == IPPROTO_IP ? AF_UNSPEC : af,
+	ip_vs_addr_copy(p->protocol == IPPROTO_IP ? AF_UNSPEC : p->af,
 			&cp->daddr, daddr);
 	cp->dport          = dport;
 	cp->flags	   = flags;
@@ -803,7 +802,7 @@ ip_vs_conn_new(int af, int proto, const union nf_inet_addr *caddr, __be16 cport,
 
 	/* Bind its packet transmitter */
 #ifdef CONFIG_IP_VS_IPV6
-	if (af == AF_INET6)
+	if (p->af == AF_INET6)
 		ip_vs_bind_xmit_v6(cp);
 	else
 #endif
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 0fcc6f9..439c40f 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -196,11 +196,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	__be16  flags;
 	union nf_inet_addr snet;	/* source network of the client,
 					   after masking */
-	int protocol = iph.protocol;
-	const union nf_inet_addr *vaddr = &iph.daddr;
-	union nf_inet_addr fwmark = { .ip = htonl(svc->fwmark) };
-	__be16 vport = 0;
-
+	struct ip_vs_conn_param param;
 
 	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 
@@ -232,6 +228,11 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	 * is created for other persistent services.
 	 */
 	{
+		int protocol = iph.protocol;
+		const union nf_inet_addr *vaddr = &iph.daddr;
+		union nf_inet_addr fwmark = { .ip = htonl(svc->fwmark) };
+		__be16 vport = 0;
+
 		if (ports[1] == svc->port) {
 			/* non-FTP template:
 			 * <protocol, caddr, 0, vaddr, vport, daddr, dport>
@@ -253,11 +254,12 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 				vaddr = &fwmark;
 			}
 		}
+		ip_vs_conn_fill_param(svc->af, protocol, &snet, 0,
+				      vaddr, vport, &param);
 	}
 
 	/* Check if a template already exists */
-	ct = ip_vs_ct_in_get(svc->af, protocol, &snet, 0, vaddr, vport);
-
+	ct = ip_vs_ct_in_get(&param);
 	if (!ct || !ip_vs_check_template(ct)) {
 		/* No template found or the dest of the connection
 		 * template is not available.
@@ -272,8 +274,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 			dport = dest->port;
 
 		/* Create a template */
-		ct = ip_vs_conn_new(svc->af, protocol, &snet, 0,vaddr, vport,
-				    &dest->addr, dport,
+		ct = ip_vs_conn_new(&param, &dest->addr, dport,
 				    IP_VS_CONN_F_TEMPLATE, dest);
 		if (ct == NULL)
 			return NULL;
@@ -291,12 +292,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	/*
 	 *    Create a new connection according to the template
 	 */
-	cp = ip_vs_conn_new(svc->af, iph.protocol,
-			    &iph.saddr, ports[0],
-			    &iph.daddr, ports[1],
-			    &dest->addr, dport,
-			    flags,
-			    dest);
+	cp = ip_vs_conn_new(&param, &dest->addr, dport, flags, dest);
 	if (cp == NULL) {
 		ip_vs_conn_put(ct);
 		return NULL;
@@ -362,14 +358,16 @@ ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	/*
 	 *    Create a connection entry.
 	 */
-	cp = ip_vs_conn_new(svc->af, iph.protocol,
-			    &iph.saddr, pptr[0],
-			    &iph.daddr, pptr[1],
-			    &dest->addr, dest->port ? dest->port : pptr[1],
-			    flags,
-			    dest);
-	if (cp == NULL)
-		return NULL;
+	{
+		struct ip_vs_conn_param p;
+		ip_vs_conn_fill_param(svc->af, iph.protocol, &iph.saddr,
+				      pptr[0], &iph.daddr, pptr[1], &p);
+		cp = ip_vs_conn_new(&p, &dest->addr,
+				    dest->port ? dest->port : pptr[1],
+				    flags, dest);
+		if (!cp)
+			return NULL;
+	}
 
 	IP_VS_DBG_BUF(6, "Schedule fwd:%c c:%s:%u v:%s:%u "
 		      "d:%s:%u conn->flags:%X conn->refcnt:%d\n",
@@ -425,14 +423,17 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 
 		/* create a new connection entry */
 		IP_VS_DBG(6, "%s(): create a cache_bypass entry\n", __func__);
-		cp = ip_vs_conn_new(svc->af, iph.protocol,
-				    &iph.saddr, pptr[0],
-				    &iph.daddr, pptr[1],
-				    &daddr, 0,
-				    IP_VS_CONN_F_BYPASS | flags,
-				    NULL);
-		if (cp == NULL)
-			return NF_DROP;
+		{
+			struct ip_vs_conn_param p;
+			ip_vs_conn_fill_param(svc->af, iph.protocol,
+					      &iph.saddr, pptr[0],
+					      &iph.daddr, pptr[1], &p);
+			cp = ip_vs_conn_new(&p, &daddr, 0,
+					    IP_VS_CONN_F_BYPASS | flags,
+					    NULL);
+			if (!cp)
+				return NF_DROP;
+		}
 
 		/* statistics */
 		ip_vs_in_stats(cp, skb);
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index f228a17..d50e908 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -156,6 +156,7 @@ ip_vs_expect_callback(struct nf_conn *ct,
 {
 	struct nf_conntrack_tuple *orig, new_reply;
 	struct ip_vs_conn *cp;
+	struct ip_vs_conn_param p;
 
 	if (exp->tuple.src.l3num != PF_INET)
 		return;
@@ -170,9 +171,11 @@ ip_vs_expect_callback(struct nf_conn *ct,
 
 	/* RS->CLIENT */
 	orig = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
-	cp = ip_vs_conn_out_get(exp->tuple.src.l3num, orig->dst.protonum,
-				&orig->src.u3, orig->src.u.tcp.port,
-				&orig->dst.u3, orig->dst.u.tcp.port);
+	ip_vs_conn_fill_param(exp->tuple.src.l3num, orig->dst.protonum,
+			      &orig->src.u3, orig->src.u.tcp.port,
+			      &orig->dst.u3, orig->dst.u.tcp.port, &p);
+
+	cp = ip_vs_conn_out_get(&p);
 	if (cp) {
 		/* Change reply CLIENT->RS to CLIENT->VS */
 		new_reply = ct->tuplehash[IP_CT_DIR_REPLY].tuple;
@@ -192,9 +195,7 @@ ip_vs_expect_callback(struct nf_conn *ct,
 	}
 
 	/* CLIENT->VS */
-	cp = ip_vs_conn_in_get(exp->tuple.src.l3num, orig->dst.protonum,
-			       &orig->src.u3, orig->src.u.tcp.port,
-			       &orig->dst.u3, orig->dst.u.tcp.port);
+	cp = ip_vs_conn_in_get(&p);
 	if (cp) {
 		/* Change reply VS->CLIENT to RS->CLIENT */
 		new_reply = ct->tuplehash[IP_CT_DIR_REPLY].tuple;
@@ -327,13 +328,18 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		/*
 		 * Now update or create an connection entry for it
 		 */
-		n_cp = ip_vs_conn_out_get(AF_INET, iph->protocol, &from, port,
-					  &cp->caddr, 0);
+		{
+			struct ip_vs_conn_param p;
+			ip_vs_conn_fill_param(AF_INET, iph->protocol,
+					      &from, port, &cp->caddr, 0, &p);
+			n_cp = ip_vs_conn_out_get(&p);
+		}
 		if (!n_cp) {
-			n_cp = ip_vs_conn_new(AF_INET, IPPROTO_TCP,
-					      &cp->caddr, 0,
-					      &cp->vaddr, port,
-					      &from, port,
+			struct ip_vs_conn_param p;
+
+			ip_vs_conn_fill_param(AF_INET, IPPROTO_TCP, &cp->caddr,
+					      0, &cp->vaddr, port, &p);
+			n_cp = ip_vs_conn_new(&p, &from, port,
 					      IP_VS_CONN_F_NO_CPORT,
 					      cp->dest);
 			if (!n_cp)
@@ -479,21 +485,23 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		  ip_vs_proto_name(iph->protocol),
 		  &to.ip, ntohs(port), &cp->vaddr.ip, 0);
 
-	n_cp = ip_vs_conn_in_get(AF_INET, iph->protocol,
-				 &to, port,
-				 &cp->vaddr, htons(ntohs(cp->vport)-1));
-	if (!n_cp) {
-		n_cp = ip_vs_conn_new(AF_INET, IPPROTO_TCP,
-				      &to, port,
+	{
+		struct ip_vs_conn_param p;
+
+		ip_vs_conn_fill_param(AF_INET, iph->protocol, &to, port,
 				      &cp->vaddr, htons(ntohs(cp->vport)-1),
-				      &cp->daddr, htons(ntohs(cp->dport)-1),
-				      0,
-				      cp->dest);
-		if (!n_cp)
-			return 0;
+				      &p);
+		n_cp = ip_vs_conn_in_get(&p);
+		if (!n_cp) {
+			n_cp = ip_vs_conn_new(&p, &cp->daddr,
+					      htons(ntohs(cp->dport)-1),
+					      0, cp->dest);
+			if (!n_cp)
+				return 0;
 
-		/* add its controller */
-		ip_vs_control_add(n_cp, cp);
+			/* add its controller */
+			ip_vs_control_add(n_cp, cp);
+		}
 	}
 
 	ct = (struct nf_conn *)skb->nfct;
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index 1892dfc..963ebeb 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -40,6 +40,19 @@ struct isakmp_hdr {
 
 #define PORT_ISAKMP	500
 
+static void
+ah_esp_conn_fill_param_proto(int af, const struct ip_vs_iphdr *iph,
+			     int inverse, struct ip_vs_conn_param *p)
+{
+	if (likely(!inverse))
+		ip_vs_conn_fill_param(af, IPPROTO_UDP,
+				      &iph->saddr, htons(PORT_ISAKMP),
+				      &iph->daddr, htons(PORT_ISAKMP), p);
+	else
+		ip_vs_conn_fill_param(af, iph->protocol,
+				      &iph->saddr, htons(PORT_ISAKMP),
+				      &iph->daddr, htons(PORT_ISAKMP), p);
+}
 
 static struct ip_vs_conn *
 ah_esp_conn_in_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
@@ -47,21 +60,10 @@ ah_esp_conn_in_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
 		   int inverse)
 {
 	struct ip_vs_conn *cp;
+	struct ip_vs_conn_param p;
 
-	if (likely(!inverse)) {
-		cp = ip_vs_conn_in_get(af, IPPROTO_UDP,
-				       &iph->saddr,
-				       htons(PORT_ISAKMP),
-				       &iph->daddr,
-				       htons(PORT_ISAKMP));
-	} else {
-		cp = ip_vs_conn_in_get(af, IPPROTO_UDP,
-				       &iph->daddr,
-				       htons(PORT_ISAKMP),
-				       &iph->saddr,
-				       htons(PORT_ISAKMP));
-	}
-
+	ah_esp_conn_fill_param_proto(af, iph, inverse, &p);
+	cp = ip_vs_conn_in_get(&p);
 	if (!cp) {
 		/*
 		 * We are not sure if the packet is from our
@@ -87,21 +89,10 @@ ah_esp_conn_out_get(int af, const struct sk_buff *skb,
 		    int inverse)
 {
 	struct ip_vs_conn *cp;
+	struct ip_vs_conn_param p;
 
-	if (likely(!inverse)) {
-		cp = ip_vs_conn_out_get(af, IPPROTO_UDP,
-					&iph->saddr,
-					htons(PORT_ISAKMP),
-					&iph->daddr,
-					htons(PORT_ISAKMP));
-	} else {
-		cp = ip_vs_conn_out_get(af, IPPROTO_UDP,
-					&iph->daddr,
-					htons(PORT_ISAKMP),
-					&iph->saddr,
-					htons(PORT_ISAKMP));
-	}
-
+	ah_esp_conn_fill_param_proto(af, iph, inverse, &p);
+	cp = ip_vs_conn_out_get(&p);
 	if (!cp) {
 		IP_VS_DBG_BUF(12, "Unknown ISAKMP entry for inout packet "
 			      "%s%s %s->%s\n",
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 7ba0693..f68631f 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -301,6 +301,7 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_dest *dest;
+	struct ip_vs_conn_param param;
 	char *p;
 	int i;
 
@@ -370,18 +371,17 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 			}
 		}
 
-		if (!(flags & IP_VS_CONN_F_TEMPLATE))
-			cp = ip_vs_conn_in_get(AF_INET, s->protocol,
-					       (union nf_inet_addr *)&s->caddr,
-					       s->cport,
-					       (union nf_inet_addr *)&s->vaddr,
-					       s->vport);
-		else
-			cp = ip_vs_ct_in_get(AF_INET, s->protocol,
-					     (union nf_inet_addr *)&s->caddr,
-					     s->cport,
-					     (union nf_inet_addr *)&s->vaddr,
-					     s->vport);
+		{
+			ip_vs_conn_fill_param(AF_INET, s->protocol,
+					      (union nf_inet_addr *)&s->caddr,
+					      s->cport,
+					      (union nf_inet_addr *)&s->vaddr,
+					      s->vport, &param);
+			if (!(flags & IP_VS_CONN_F_TEMPLATE))
+				cp = ip_vs_conn_in_get(&param);
+			else
+				cp = ip_vs_ct_in_get(&param);
+		}
 		if (!cp) {
 			/*
 			 * Find the appropriate destination for the connection.
@@ -406,14 +406,9 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 				else
 					flags &= ~IP_VS_CONN_F_INACTIVE;
 			}
-			cp = ip_vs_conn_new(AF_INET, s->protocol,
-					    (union nf_inet_addr *)&s->caddr,
-					    s->cport,
-					    (union nf_inet_addr *)&s->vaddr,
-					    s->vport,
+			cp = ip_vs_conn_new(&param,
 					    (union nf_inet_addr *)&s->daddr,
-					    s->dport,
-					    flags, dest);
+					    s->dport, flags, dest);
 			if (dest)
 				atomic_dec(&dest->refcnt);
 			if (!cp) {
-- 
1.7.1


