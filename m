From: Julius Volz <juliusv@google.com>
Subject: [PATCHv3 12/24] IPVS: Extend functions for getting/creating connections
Date: Tue,  2 Sep 2008 15:55:43 +0200
Message-ID: <1220363755-9854-13-git-send-email-juliusv@google.com>
References: <1220363755-9854-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220363766; bh=nqTqos+59l3sc8x9qlRrZU87PGk=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=L8cO6dxFX2z6551EnNojTlmmQTR+GY4aLez8DmXs
	ukZBK8M3eIRh4jUHHUpQYboe7qJ7z13jDFlluQQyUggPOw==
In-Reply-To: <1220363755-9854-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Extend functions for getting/creating connections and connection
templates for IPv6 support and fix the callers.

Signed-off-by: Julius Volz <juliusv@google.com>

 8 files changed, 209 insertions(+), 163 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index c173f1a..2689349 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -642,11 +642,16 @@ enum {
 };
 
 extern struct ip_vs_conn *ip_vs_conn_in_get
-(int protocol, __be32 s_addr, __be16 s_port, __be32 d_addr, __be16 d_port);
+(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
+ const union nf_inet_addr *d_addr, __be16 d_port);
+
 extern struct ip_vs_conn *ip_vs_ct_in_get
-(int protocol, __be32 s_addr, __be16 s_port, __be32 d_addr, __be16 d_port);
+(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
+ const union nf_inet_addr *d_addr, __be16 d_port);
+
 extern struct ip_vs_conn *ip_vs_conn_out_get
-(int protocol, __be32 s_addr, __be16 s_port, __be32 d_addr, __be16 d_port);
+(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
+ const union nf_inet_addr *d_addr, __be16 d_port);
 
 /* put back the conn without restarting its timer */
 static inline void __ip_vs_conn_put(struct ip_vs_conn *cp)
@@ -657,8 +662,9 @@ extern void ip_vs_conn_put(struct ip_vs_conn *cp);
 extern void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport);
 
 extern struct ip_vs_conn *
-ip_vs_conn_new(int proto, __be32 caddr, __be16 cport, __be32 vaddr, __be16 vport,
-	       __be32 daddr, __be16 dport, unsigned flags,
+ip_vs_conn_new(int af, int proto, const union nf_inet_addr *caddr, __be16 cport,
+	       const union nf_inet_addr *vaddr, __be16 vport,
+	       const union nf_inet_addr *daddr, __be16 dport, unsigned flags,
 	       struct ip_vs_dest *dest);
 extern void ip_vs_conn_expire_now(struct ip_vs_conn *cp);
 
diff --git a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
index 639d4bc..15eec28 100644
--- a/net/ipv4/ipvs/ip_vs_conn.c
+++ b/net/ipv4/ipvs/ip_vs_conn.c
@@ -114,9 +114,18 @@ static inline void ct_write_unlock_bh(unsigned key)
 /*
  *	Returns hash value for IPVS connection entry
  */
-static unsigned int ip_vs_conn_hashkey(unsigned proto, __be32 addr, __be16 port)
+static unsigned int ip_vs_conn_hashkey(int af, unsigned proto,
+				       const union nf_inet_addr *addr,
+				       __be16 port)
 {
-	return jhash_3words((__force u32)addr, (__force u32)port, proto, ip_vs_conn_rnd)
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		return jhash_3words(jhash(addr, 16, ip_vs_conn_rnd),
+				    (__force u32)port, proto, ip_vs_conn_rnd)
+			& IP_VS_CONN_TAB_MASK;
+#endif
+	return jhash_3words((__force u32)addr->ip, (__force u32)port, proto,
+			    ip_vs_conn_rnd)
 		& IP_VS_CONN_TAB_MASK;
 }
 
@@ -131,7 +140,7 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
 	int ret;
 
 	/* Hash by protocol, client address and port */
-	hash = ip_vs_conn_hashkey(cp->protocol, cp->caddr.ip, cp->cport);
+	hash = ip_vs_conn_hashkey(cp->af, cp->protocol, &cp->caddr, cp->cport);
 
 	ct_write_lock(hash);
 
@@ -162,7 +171,7 @@ static inline int ip_vs_conn_unhash(struct ip_vs_conn *cp)
 	int ret;
 
 	/* unhash it and decrease its reference counter */
-	hash = ip_vs_conn_hashkey(cp->protocol, cp->caddr.ip, cp->cport);
+	hash = ip_vs_conn_hashkey(cp->af, cp->protocol, &cp->caddr, cp->cport);
 
 	ct_write_lock(hash);
 
@@ -187,18 +196,21 @@ static inline int ip_vs_conn_unhash(struct ip_vs_conn *cp)
  *	d_addr, d_port: pkt dest address (load balancer)
  */
 static inline struct ip_vs_conn *__ip_vs_conn_in_get
-(int protocol, __be32 s_addr, __be16 s_port, __be32 d_addr, __be16 d_port)
+(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
+ const union nf_inet_addr *d_addr, __be16 d_port)
 {
 	unsigned hash;
 	struct ip_vs_conn *cp;
 
-	hash = ip_vs_conn_hashkey(protocol, s_addr, s_port);
+	hash = ip_vs_conn_hashkey(af, protocol, s_addr, s_port);
 
 	ct_read_lock(hash);
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (s_addr == cp->caddr.ip && s_port == cp->cport &&
-		    d_port == cp->vport && d_addr == cp->vaddr.ip &&
+		if (cp->af == af &&
+		    ip_vs_addr_equal(af, s_addr, &cp->caddr) &&
+		    ip_vs_addr_equal(af, d_addr, &cp->vaddr) &&
+		    s_port == cp->cport && d_port == cp->vport &&
 		    ((!s_port) ^ (!(cp->flags & IP_VS_CONN_F_NO_CPORT))) &&
 		    protocol == cp->protocol) {
 			/* HIT */
@@ -214,37 +226,42 @@ static inline struct ip_vs_conn *__ip_vs_conn_in_get
 }
 
 struct ip_vs_conn *ip_vs_conn_in_get
-(int protocol, __be32 s_addr, __be16 s_port, __be32 d_addr, __be16 d_port)
+(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
+ const union nf_inet_addr *d_addr, __be16 d_port)
 {
 	struct ip_vs_conn *cp;
 
-	cp = __ip_vs_conn_in_get(protocol, s_addr, s_port, d_addr, d_port);
+	cp = __ip_vs_conn_in_get(af, protocol, s_addr, s_port, d_addr, d_port);
 	if (!cp && atomic_read(&ip_vs_conn_no_cport_cnt))
-		cp = __ip_vs_conn_in_get(protocol, s_addr, 0, d_addr, d_port);
+		cp = __ip_vs_conn_in_get(af, protocol, s_addr, 0, d_addr,
+					 d_port);
 
-	IP_VS_DBG(9, "lookup/in %s %u.%u.%u.%u:%d->%u.%u.%u.%u:%d %s\n",
-		  ip_vs_proto_name(protocol),
-		  NIPQUAD(s_addr), ntohs(s_port),
-		  NIPQUAD(d_addr), ntohs(d_port),
-		  cp?"hit":"not hit");
+	IP_VS_DBG_BUF(9, "lookup/in %s %s:%d->%s:%d %s\n",
+		      ip_vs_proto_name(protocol),
+		      IP_VS_DBG_ADDR(af, s_addr), ntohs(s_port),
+		      IP_VS_DBG_ADDR(af, d_addr), ntohs(d_port),
+		      cp ? "hit" : "not hit");
 
 	return cp;
 }
 
 /* Get reference to connection template */
 struct ip_vs_conn *ip_vs_ct_in_get
-(int protocol, __be32 s_addr, __be16 s_port, __be32 d_addr, __be16 d_port)
+(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
+ const union nf_inet_addr *d_addr, __be16 d_port)
 {
 	unsigned hash;
 	struct ip_vs_conn *cp;
 
-	hash = ip_vs_conn_hashkey(protocol, s_addr, s_port);
+	hash = ip_vs_conn_hashkey(af, protocol, s_addr, s_port);
 
 	ct_read_lock(hash);
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (s_addr == cp->caddr.ip && s_port == cp->cport &&
-		    d_port == cp->vport && d_addr == cp->vaddr.ip &&
+		if (cp->af == af &&
+		    ip_vs_addr_equal(af, s_addr, &cp->caddr) &&
+		    ip_vs_addr_equal(af, d_addr, &cp->vaddr) &&
+		    s_port == cp->cport && d_port == cp->vport &&
 		    cp->flags & IP_VS_CONN_F_TEMPLATE &&
 		    protocol == cp->protocol) {
 			/* HIT */
@@ -257,11 +274,11 @@ struct ip_vs_conn *ip_vs_ct_in_get
   out:
 	ct_read_unlock(hash);
 
-	IP_VS_DBG(9, "template lookup/in %s %u.%u.%u.%u:%d->%u.%u.%u.%u:%d %s\n",
-		  ip_vs_proto_name(protocol),
-		  NIPQUAD(s_addr), ntohs(s_port),
-		  NIPQUAD(d_addr), ntohs(d_port),
-		  cp?"hit":"not hit");
+	IP_VS_DBG_BUF(9, "template lookup/in %s %s:%d->%s:%d %s\n",
+		      ip_vs_proto_name(protocol),
+		      IP_VS_DBG_ADDR(af, s_addr), ntohs(s_port),
+		      IP_VS_DBG_ADDR(af, d_addr), ntohs(d_port),
+		      cp ? "hit" : "not hit");
 
 	return cp;
 }
@@ -273,7 +290,8 @@ struct ip_vs_conn *ip_vs_ct_in_get
  *	d_addr, d_port: pkt dest address (foreign host)
  */
 struct ip_vs_conn *ip_vs_conn_out_get
-(int protocol, __be32 s_addr, __be16 s_port, __be32 d_addr, __be16 d_port)
+(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
+ const union nf_inet_addr *d_addr, __be16 d_port)
 {
 	unsigned hash;
 	struct ip_vs_conn *cp, *ret=NULL;
@@ -281,13 +299,15 @@ struct ip_vs_conn *ip_vs_conn_out_get
 	/*
 	 *	Check for "full" addressed entries
 	 */
-	hash = ip_vs_conn_hashkey(protocol, d_addr, d_port);
+	hash = ip_vs_conn_hashkey(af, protocol, d_addr, d_port);
 
 	ct_read_lock(hash);
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (d_addr == cp->caddr.ip && d_port == cp->cport &&
-		    s_port == cp->dport && s_addr == cp->daddr.ip &&
+		if (cp->af == af &&
+		    ip_vs_addr_equal(af, d_addr, &cp->caddr) &&
+		    ip_vs_addr_equal(af, s_addr, &cp->daddr) &&
+		    d_port == cp->cport && s_port == cp->dport &&
 		    protocol == cp->protocol) {
 			/* HIT */
 			atomic_inc(&cp->refcnt);
@@ -298,11 +318,11 @@ struct ip_vs_conn *ip_vs_conn_out_get
 
 	ct_read_unlock(hash);
 
-	IP_VS_DBG(9, "lookup/out %s %u.%u.%u.%u:%d->%u.%u.%u.%u:%d %s\n",
-		  ip_vs_proto_name(protocol),
-		  NIPQUAD(s_addr), ntohs(s_port),
-		  NIPQUAD(d_addr), ntohs(d_port),
-		  ret?"hit":"not hit");
+	IP_VS_DBG_BUF(9, "lookup/out %s %s:%d->%s:%d %s\n",
+		      ip_vs_proto_name(protocol),
+		      IP_VS_DBG_ADDR(af, s_addr), ntohs(s_port),
+		      IP_VS_DBG_ADDR(af, d_addr), ntohs(d_port),
+		      ret ? "hit" : "not hit");
 
 	return ret;
 }
@@ -625,8 +645,9 @@ void ip_vs_conn_expire_now(struct ip_vs_conn *cp)
  *	Create a new connection entry and hash it into the ip_vs_conn_tab
  */
 struct ip_vs_conn *
-ip_vs_conn_new(int proto, __be32 caddr, __be16 cport, __be32 vaddr, __be16 vport,
-	       __be32 daddr, __be16 dport, unsigned flags,
+ip_vs_conn_new(int af, int proto, const union nf_inet_addr *caddr, __be16 cport,
+	       const union nf_inet_addr *vaddr, __be16 vport,
+	       const union nf_inet_addr *daddr, __be16 dport, unsigned flags,
 	       struct ip_vs_dest *dest)
 {
 	struct ip_vs_conn *cp;
@@ -640,12 +661,13 @@ ip_vs_conn_new(int proto, __be32 caddr, __be16 cport, __be32 vaddr, __be16 vport
 
 	INIT_LIST_HEAD(&cp->c_list);
 	setup_timer(&cp->timer, ip_vs_conn_expire, (unsigned long)cp);
+	cp->af		   = af;
 	cp->protocol	   = proto;
-	cp->caddr.ip	   = caddr;
+	ip_vs_addr_copy(af, &cp->caddr, caddr);
 	cp->cport	   = cport;
-	cp->vaddr.ip	   = vaddr;
+	ip_vs_addr_copy(af, &cp->vaddr, vaddr);
 	cp->vport	   = vport;
-	cp->daddr.ip	   = daddr;
+	ip_vs_addr_copy(af, &cp->daddr, daddr);
 	cp->dport          = dport;
 	cp->flags	   = flags;
 	spin_lock_init(&cp->lock);
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 34aaa14..2d5a433 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -173,19 +173,21 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 		    __be16 ports[2])
 {
 	struct ip_vs_conn *cp = NULL;
-	struct iphdr *iph = ip_hdr(skb);
+	struct ip_vs_iphdr iph;
 	struct ip_vs_dest *dest;
 	struct ip_vs_conn *ct;
 	__be16  dport;	 /* destination port to forward */
-	__be32  snet;	 /* source network of the client, after masking */
+	union nf_inet_addr snet;	/* source network of the client,
+					   after masking */
+	ip_vs_fill_iphdr(AF_INET, skb_network_header(skb), &iph);
 
 	/* Mask saddr with the netmask to adjust template granularity */
-	snet = iph->saddr & svc->netmask;
+	snet.ip = iph.saddr.ip & svc->netmask;
 
 	IP_VS_DBG(6, "p-schedule: src %u.%u.%u.%u:%u dest %u.%u.%u.%u:%u "
 		  "mnet %u.%u.%u.%u\n",
-		  NIPQUAD(iph->saddr), ntohs(ports[0]),
-		  NIPQUAD(iph->daddr), ntohs(ports[1]),
+		  NIPQUAD(iph.saddr.ip), ntohs(ports[0]),
+		  NIPQUAD(iph.daddr.ip), ntohs(ports[1]),
 		  NIPQUAD(snet));
 
 	/*
@@ -204,11 +206,11 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	if (ports[1] == svc->port) {
 		/* Check if a template already exists */
 		if (svc->port != FTPPORT)
-			ct = ip_vs_ct_in_get(iph->protocol, snet, 0,
-					       iph->daddr, ports[1]);
+			ct = ip_vs_ct_in_get(AF_INET, iph.protocol, &snet, 0,
+					     &iph.daddr, ports[1]);
 		else
-			ct = ip_vs_ct_in_get(iph->protocol, snet, 0,
-					       iph->daddr, 0);
+			ct = ip_vs_ct_in_get(AF_INET, iph.protocol, &snet, 0,
+					     &iph.daddr, 0);
 
 		if (!ct || !ip_vs_check_template(ct)) {
 			/*
@@ -228,18 +230,18 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 			 * for ftp service.
 			 */
 			if (svc->port != FTPPORT)
-				ct = ip_vs_conn_new(iph->protocol,
-						    snet, 0,
-						    iph->daddr,
+				ct = ip_vs_conn_new(AF_INET, iph.protocol,
+						    &snet, 0,
+						    &iph.daddr,
 						    ports[1],
-						    dest->addr.ip, dest->port,
+						    &dest->addr, dest->port,
 						    IP_VS_CONN_F_TEMPLATE,
 						    dest);
 			else
-				ct = ip_vs_conn_new(iph->protocol,
-						    snet, 0,
-						    iph->daddr, 0,
-						    dest->addr.ip, 0,
+				ct = ip_vs_conn_new(AF_INET, iph.protocol,
+						    &snet, 0,
+						    &iph.daddr, 0,
+						    &dest->addr, 0,
 						    IP_VS_CONN_F_TEMPLATE,
 						    dest);
 			if (ct == NULL)
@@ -258,12 +260,16 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 		 * fwmark template: <IPPROTO_IP,caddr,0,fwmark,0,daddr,0>
 		 * port zero template: <protocol,caddr,0,vaddr,0,daddr,0>
 		 */
-		if (svc->fwmark)
-			ct = ip_vs_ct_in_get(IPPROTO_IP, snet, 0,
-					       htonl(svc->fwmark), 0);
-		else
-			ct = ip_vs_ct_in_get(iph->protocol, snet, 0,
-					       iph->daddr, 0);
+		if (svc->fwmark) {
+			union nf_inet_addr fwmark = {
+				.all = { 0, 0, 0, htonl(svc->fwmark) }
+			};
+
+			ct = ip_vs_ct_in_get(AF_INET, IPPROTO_IP, &snet, 0,
+					     &fwmark, 0);
+		} else
+			ct = ip_vs_ct_in_get(AF_INET, iph.protocol, &snet, 0,
+					     &iph.daddr, 0);
 
 		if (!ct || !ip_vs_check_template(ct)) {
 			/*
@@ -282,18 +288,22 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 			/*
 			 * Create a template according to the service
 			 */
-			if (svc->fwmark)
-				ct = ip_vs_conn_new(IPPROTO_IP,
-						    snet, 0,
-						    htonl(svc->fwmark), 0,
-						    dest->addr.ip, 0,
+			if (svc->fwmark) {
+				union nf_inet_addr fwmark = {
+					.all = { 0, 0, 0, htonl(svc->fwmark) }
+				};
+
+				ct = ip_vs_conn_new(AF_INET, IPPROTO_IP,
+						    &snet, 0,
+						    &fwmark, 0,
+						    &dest->addr, 0,
 						    IP_VS_CONN_F_TEMPLATE,
 						    dest);
-			else
-				ct = ip_vs_conn_new(iph->protocol,
-						    snet, 0,
-						    iph->daddr, 0,
-						    dest->addr.ip, 0,
+			} else
+				ct = ip_vs_conn_new(AF_INET, iph.protocol,
+						    &snet, 0,
+						    &iph.daddr, 0,
+						    &dest->addr, 0,
 						    IP_VS_CONN_F_TEMPLATE,
 						    dest);
 			if (ct == NULL)
@@ -310,10 +320,10 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	/*
 	 *    Create a new connection according to the template
 	 */
-	cp = ip_vs_conn_new(iph->protocol,
-			    iph->saddr, ports[0],
-			    iph->daddr, ports[1],
-			    dest->addr.ip, dport,
+	cp = ip_vs_conn_new(AF_INET, iph.protocol,
+			    &iph.saddr, ports[0],
+			    &iph.daddr, ports[1],
+			    &dest->addr, dport,
 			    0,
 			    dest);
 	if (cp == NULL) {
@@ -342,12 +352,12 @@ struct ip_vs_conn *
 ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 {
 	struct ip_vs_conn *cp = NULL;
-	struct iphdr *iph = ip_hdr(skb);
+	struct ip_vs_iphdr iph;
 	struct ip_vs_dest *dest;
 	__be16 _ports[2], *pptr;
 
-	pptr = skb_header_pointer(skb, iph->ihl*4,
-				  sizeof(_ports), _ports);
+	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
+	pptr = skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
 	if (pptr == NULL)
 		return NULL;
 
@@ -377,10 +387,10 @@ ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	/*
 	 *    Create a connection entry.
 	 */
-	cp = ip_vs_conn_new(iph->protocol,
-			    iph->saddr, pptr[0],
-			    iph->daddr, pptr[1],
-			    dest->addr.ip, dest->port ? dest->port : pptr[1],
+	cp = ip_vs_conn_new(AF_INET, iph.protocol,
+			    &iph.saddr, pptr[0],
+			    &iph.daddr, pptr[1],
+			    &dest->addr, dest->port ? dest->port : pptr[1],
 			    0,
 			    dest);
 	if (cp == NULL)
@@ -408,10 +418,10 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		struct ip_vs_protocol *pp)
 {
 	__be16 _ports[2], *pptr;
-	struct iphdr *iph = ip_hdr(skb);
+	struct ip_vs_iphdr iph;
+	ip_vs_fill_iphdr(AF_INET, skb_network_header(skb), &iph);
 
-	pptr = skb_header_pointer(skb, iph->ihl*4,
-				  sizeof(_ports), _ports);
+	pptr = skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
 	if (pptr == NULL) {
 		ip_vs_service_put(svc);
 		return NF_DROP;
@@ -421,7 +431,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 	   and the destination is RTN_UNICAST (and not local), then create
 	   a cache_bypass connection entry */
 	if (sysctl_ip_vs_cache_bypass && svc->fwmark
-	    && (inet_addr_type(&init_net, iph->daddr) == RTN_UNICAST)) {
+	    && (inet_addr_type(&init_net, iph.daddr.ip) == RTN_UNICAST)) {
 		int ret, cs;
 		struct ip_vs_conn *cp;
 
@@ -429,9 +439,9 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 
 		/* create a new connection entry */
 		IP_VS_DBG(6, "ip_vs_leave: create a cache_bypass entry\n");
-		cp = ip_vs_conn_new(iph->protocol,
-				    iph->saddr, pptr[0],
-				    iph->daddr, pptr[1],
+		cp = ip_vs_conn_new(AF_INET, iph.protocol,
+				    &iph.saddr, pptr[0],
+				    &iph.daddr, pptr[1],
 				    0, 0,
 				    IP_VS_CONN_F_BYPASS,
 				    NULL);
diff --git a/net/ipv4/ipvs/ip_vs_ftp.c b/net/ipv4/ipvs/ip_vs_ftp.c
index bfe5d70..0c3fbe0 100644
--- a/net/ipv4/ipvs/ip_vs_ftp.c
+++ b/net/ipv4/ipvs/ip_vs_ftp.c
@@ -140,7 +140,7 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	struct tcphdr *th;
 	char *data, *data_limit;
 	char *start, *end;
-	__be32 from;
+	union nf_inet_addr from;
 	__be16 port;
 	struct ip_vs_conn *n_cp;
 	char buf[24];		/* xxx.xxx.xxx.xxx,ppp,ppp\000 */
@@ -166,24 +166,25 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		if (ip_vs_ftp_get_addrport(data, data_limit,
 					   SERVER_STRING,
 					   sizeof(SERVER_STRING)-1, ')',
-					   &from, &port,
+					   &from.ip, &port,
 					   &start, &end) != 1)
 			return 1;
 
 		IP_VS_DBG(7, "PASV response (%u.%u.%u.%u:%d) -> "
 			  "%u.%u.%u.%u:%d detected\n",
-			  NIPQUAD(from), ntohs(port), NIPQUAD(cp->caddr.ip), 0);
+			  NIPQUAD(from.ip), ntohs(port),
+			  NIPQUAD(cp->caddr.ip), 0);
 
 		/*
 		 * Now update or create an connection entry for it
 		 */
-		n_cp = ip_vs_conn_out_get(iph->protocol, from, port,
-					  cp->caddr.ip, 0);
+		n_cp = ip_vs_conn_out_get(AF_INET, iph->protocol, &from, port,
+					  &cp->caddr, 0);
 		if (!n_cp) {
-			n_cp = ip_vs_conn_new(IPPROTO_TCP,
-					      cp->caddr.ip, 0,
-					      cp->vaddr.ip, port,
-					      from, port,
+			n_cp = ip_vs_conn_new(AF_INET, IPPROTO_TCP,
+					      &cp->caddr, 0,
+					      &cp->vaddr, port,
+					      &from, port,
 					      IP_VS_CONN_F_NO_CPORT,
 					      cp->dest);
 			if (!n_cp)
@@ -196,9 +197,9 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		/*
 		 * Replace the old passive address with the new one
 		 */
-		from = n_cp->vaddr.ip;
+		from.ip = n_cp->vaddr.ip;
 		port = n_cp->vport;
-		sprintf(buf,"%d,%d,%d,%d,%d,%d", NIPQUAD(from),
+		sprintf(buf, "%d,%d,%d,%d,%d,%d", NIPQUAD(from.ip),
 			(ntohs(port)>>8)&255, ntohs(port)&255);
 		buf_len = strlen(buf);
 
@@ -243,7 +244,7 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	struct tcphdr *th;
 	char *data, *data_start, *data_limit;
 	char *start, *end;
-	__be32 to;
+	union nf_inet_addr to;
 	__be16 port;
 	struct ip_vs_conn *n_cp;
 
@@ -291,12 +292,12 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	 */
 	if (ip_vs_ftp_get_addrport(data_start, data_limit,
 				   CLIENT_STRING, sizeof(CLIENT_STRING)-1,
-				   '\r', &to, &port,
+				   '\r', &to.ip, &port,
 				   &start, &end) != 1)
 		return 1;
 
 	IP_VS_DBG(7, "PORT %u.%u.%u.%u:%d detected\n",
-		  NIPQUAD(to), ntohs(port));
+		  NIPQUAD(to.ip), ntohs(port));
 
 	/* Passive mode off */
 	cp->app_data = NULL;
@@ -306,16 +307,16 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	 */
 	IP_VS_DBG(7, "protocol %s %u.%u.%u.%u:%d %u.%u.%u.%u:%d\n",
 		  ip_vs_proto_name(iph->protocol),
-		  NIPQUAD(to), ntohs(port), NIPQUAD(cp->vaddr.ip), 0);
+		  NIPQUAD(to.ip), ntohs(port), NIPQUAD(cp->vaddr.ip), 0);
 
-	n_cp = ip_vs_conn_in_get(iph->protocol,
-				 to, port,
-				 cp->vaddr.ip, htons(ntohs(cp->vport)-1));
+	n_cp = ip_vs_conn_in_get(AF_INET, iph->protocol,
+				 &to, port,
+				 &cp->vaddr, htons(ntohs(cp->vport)-1));
 	if (!n_cp) {
-		n_cp = ip_vs_conn_new(IPPROTO_TCP,
-				      to, port,
-				      cp->vaddr.ip, htons(ntohs(cp->vport)-1),
-				      cp->daddr.ip, htons(ntohs(cp->dport)-1),
+		n_cp = ip_vs_conn_new(AF_INET, IPPROTO_TCP,
+				      &to, port,
+				      &cp->vaddr, htons(ntohs(cp->vport)-1),
+				      &cp->daddr, htons(ntohs(cp->dport)-1),
 				      0,
 				      cp->dest);
 		if (!n_cp)
diff --git a/net/ipv4/ipvs/ip_vs_proto_ah_esp.c b/net/ipv4/ipvs/ip_vs_proto_ah_esp.c
index 4b0b8f2..2b18a78 100644
--- a/net/ipv4/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_ah_esp.c
@@ -46,16 +46,16 @@ ah_esp_conn_in_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
 	struct ip_vs_conn *cp;
 
 	if (likely(!inverse)) {
-		cp = ip_vs_conn_in_get(IPPROTO_UDP,
-				       iph->saddr.ip,
+		cp = ip_vs_conn_in_get(af, IPPROTO_UDP,
+				       &iph->saddr,
 				       htons(PORT_ISAKMP),
-				       iph->daddr.ip,
+				       &iph->daddr,
 				       htons(PORT_ISAKMP));
 	} else {
-		cp = ip_vs_conn_in_get(IPPROTO_UDP,
-				       iph->daddr.ip,
+		cp = ip_vs_conn_in_get(af, IPPROTO_UDP,
+				       &iph->daddr,
 				       htons(PORT_ISAKMP),
-				       iph->saddr.ip,
+				       &iph->saddr,
 				       htons(PORT_ISAKMP));
 	}
 
@@ -86,16 +86,16 @@ ah_esp_conn_out_get(int af, const struct sk_buff *skb,
 	struct ip_vs_conn *cp;
 
 	if (likely(!inverse)) {
-		cp = ip_vs_conn_out_get(IPPROTO_UDP,
-					iph->saddr.ip,
+		cp = ip_vs_conn_out_get(af, IPPROTO_UDP,
+					&iph->saddr,
 					htons(PORT_ISAKMP),
-					iph->daddr.ip,
+					&iph->daddr,
 					htons(PORT_ISAKMP));
 	} else {
-		cp = ip_vs_conn_out_get(IPPROTO_UDP,
-					iph->daddr.ip,
+		cp = ip_vs_conn_out_get(af, IPPROTO_UDP,
+					&iph->daddr,
 					htons(PORT_ISAKMP),
-					iph->saddr.ip,
+					&iph->saddr,
 					htons(PORT_ISAKMP));
 	}
 
diff --git a/net/ipv4/ipvs/ip_vs_proto_tcp.c b/net/ipv4/ipvs/ip_vs_proto_tcp.c
index 3daae43..3da2bb0 100644
--- a/net/ipv4/ipvs/ip_vs_proto_tcp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_tcp.c
@@ -36,13 +36,13 @@ tcp_conn_in_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
 		return NULL;
 
 	if (likely(!inverse)) {
-		return ip_vs_conn_in_get(iph->protocol,
-					 iph->saddr.ip, pptr[0],
-					 iph->daddr.ip, pptr[1]);
+		return ip_vs_conn_in_get(af, iph->protocol,
+					 &iph->saddr, pptr[0],
+					 &iph->daddr, pptr[1]);
 	} else {
-		return ip_vs_conn_in_get(iph->protocol,
-					 iph->daddr.ip, pptr[1],
-					 iph->saddr.ip, pptr[0]);
+		return ip_vs_conn_in_get(af, iph->protocol,
+					 &iph->daddr, pptr[1],
+					 &iph->saddr, pptr[0]);
 	}
 }
 
@@ -58,13 +58,13 @@ tcp_conn_out_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
 		return NULL;
 
 	if (likely(!inverse)) {
-		return ip_vs_conn_out_get(iph->protocol,
-					  iph->saddr.ip, pptr[0],
-					  iph->daddr.ip, pptr[1]);
+		return ip_vs_conn_out_get(af, iph->protocol,
+					  &iph->saddr, pptr[0],
+					  &iph->daddr, pptr[1]);
 	} else {
-		return ip_vs_conn_out_get(iph->protocol,
-					  iph->daddr.ip, pptr[1],
-					  iph->saddr.ip, pptr[0]);
+		return ip_vs_conn_out_get(af, iph->protocol,
+					  &iph->daddr, pptr[1],
+					  &iph->saddr, pptr[0]);
 	}
 }
 
diff --git a/net/ipv4/ipvs/ip_vs_proto_udp.c b/net/ipv4/ipvs/ip_vs_proto_udp.c
index 6cca0ad..fd8bd93 100644
--- a/net/ipv4/ipvs/ip_vs_proto_udp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_udp.c
@@ -36,13 +36,13 @@ udp_conn_in_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
 		return NULL;
 
 	if (likely(!inverse)) {
-		cp = ip_vs_conn_in_get(iph->protocol,
-				       iph->saddr.ip, pptr[0],
-				       iph->daddr.ip, pptr[1]);
+		cp = ip_vs_conn_in_get(af, iph->protocol,
+				       &iph->saddr, pptr[0],
+				       &iph->daddr, pptr[1]);
 	} else {
-		cp = ip_vs_conn_in_get(iph->protocol,
-				       iph->daddr.ip, pptr[1],
-				       iph->saddr.ip, pptr[0]);
+		cp = ip_vs_conn_in_get(af, iph->protocol,
+				       &iph->daddr, pptr[1],
+				       &iph->saddr, pptr[0]);
 	}
 
 	return cp;
@@ -62,13 +62,13 @@ udp_conn_out_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
 		return NULL;
 
 	if (likely(!inverse)) {
-		cp = ip_vs_conn_out_get(iph->protocol,
-					iph->saddr.ip, pptr[0],
-					iph->daddr.ip, pptr[1]);
+		cp = ip_vs_conn_out_get(af, iph->protocol,
+					&iph->saddr, pptr[0],
+					&iph->daddr, pptr[1]);
 	} else {
-		cp = ip_vs_conn_out_get(iph->protocol,
-					iph->daddr.ip, pptr[1],
-					iph->saddr.ip, pptr[0]);
+		cp = ip_vs_conn_out_get(af, iph->protocol,
+					&iph->daddr, pptr[1],
+					&iph->saddr, pptr[0]);
 	}
 
 	return cp;
diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
index 2cf47b2..3ce1093 100644
--- a/net/ipv4/ipvs/ip_vs_sync.c
+++ b/net/ipv4/ipvs/ip_vs_sync.c
@@ -366,13 +366,17 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 		}
 
 		if (!(flags & IP_VS_CONN_F_TEMPLATE))
-			cp = ip_vs_conn_in_get(s->protocol,
-					       s->caddr, s->cport,
-					       s->vaddr, s->vport);
+			cp = ip_vs_conn_in_get(AF_INET, s->protocol,
+					       (union nf_inet_addr *)&s->caddr,
+					       s->cport,
+					       (union nf_inet_addr *)&s->vaddr,
+					       s->vport);
 		else
-			cp = ip_vs_ct_in_get(s->protocol,
-					       s->caddr, s->cport,
-					       s->vaddr, s->vport);
+			cp = ip_vs_ct_in_get(AF_INET, s->protocol,
+					     (union nf_inet_addr *)&s->caddr,
+					     s->cport,
+					     (union nf_inet_addr *)&s->vaddr,
+					     s->vport);
 		if (!cp) {
 			/*
 			 * Find the appropriate destination for the connection.
@@ -389,10 +393,13 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 				else
 					flags &= ~IP_VS_CONN_F_INACTIVE;
 			}
-			cp = ip_vs_conn_new(s->protocol,
-					    s->caddr, s->cport,
-					    s->vaddr, s->vport,
-					    s->daddr, s->dport,
+			cp = ip_vs_conn_new(AF_INET, s->protocol,
+					    (union nf_inet_addr *)s->caddr,
+					    s->cport,
+					    (union nf_inet_addr *)s->vaddr,
+					    s->vport,
+					    (union nf_inet_addr *)s->daddr,
+					    s->dport,
 					    flags, dest);
 			if (dest)
 				atomic_dec(&dest->refcnt);
-- 
1.5.4.5

