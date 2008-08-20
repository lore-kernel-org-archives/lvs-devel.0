From: Julius Volz <juliusv@google.com>
Subject: [PATCH RFC 18/24] IPVS: Convert dest/service lookup functions
Date: Wed, 20 Aug 2008 18:15:25 +0200
Message-ID: <1219248931-15064-19-git-send-email-juliusv@google.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219248947; bh=6BQq/cOjRI6TY/5go8stWnnH2fk=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=CYKS3krJYyyFH2nWLyr02xi0QKLH4vmrlNtliFPL
	7eoWLMBN+9ltJ4yVIgSIUFHUi8GDJRdwsAENrmhMjsX2Kg==
In-Reply-To: <1219248931-15064-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Convert the low-level dest and service lookup/hashing functions to deal
with IPv6 entries.

Signed-off-by: Julius Volz <juliusv@google.com>

 2 files changed, 63 insertions(+), 31 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index c80eaec..28880e4 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -807,7 +807,8 @@ extern struct ip_vs_stats ip_vs_stats;
 extern const struct ctl_path net_vs_ctl_path[];
 
 extern struct ip_vs_service *
-ip_vs_service_get(__u32 fwmark, __u16 protocol, __be32 vaddr, __be16 vport);
+ip_vs_service_get(int af, __u32 fwmark, __u16 protocol,
+		  const union nf_inet_addr *vaddr, __be16 vport);
 
 static inline void ip_vs_service_put(struct ip_vs_service *svc)
 {
@@ -815,14 +816,16 @@ static inline void ip_vs_service_put(struct ip_vs_service *svc)
 }
 
 extern struct ip_vs_dest *
-ip_vs_lookup_real_service(__u16 protocol, __be32 daddr, __be16 dport);
+ip_vs_lookup_real_service(int af, __u16 protocol,
+			  const union nf_inet_addr *daddr, __be16 dport);
+
 extern int ip_vs_use_count_inc(void);
 extern void ip_vs_use_count_dec(void);
 extern int ip_vs_control_init(void);
 extern void ip_vs_control_cleanup(void);
 extern struct ip_vs_dest *
-ip_vs_find_dest(__be32 daddr, __be16 dport,
-		 __be32 vaddr, __be16 vport, __u16 protocol);
+ip_vs_find_dest(int af, const union nf_inet_addr *daddr, __be16 dport,
+		const union nf_inet_addr *vaddr, __be16 vport, __u16 protocol);
 extern struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp);
 
 
diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index f9db095..6127a97 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -303,11 +303,19 @@ static atomic_t ip_vs_nullsvc_counter = ATOMIC_INIT(0);
  *	Returns hash value for virtual service
  */
 static __inline__ unsigned
-ip_vs_svc_hashkey(unsigned proto, __be32 addr, __be16 port)
+ip_vs_svc_hashkey(int af, unsigned proto, const union nf_inet_addr *addr,
+		  __be16 port)
 {
 	register unsigned porth = ntohs(port);
+	__be32 addr_fold = addr->ip;
 
-	return (proto^ntohl(addr)^(porth>>IP_VS_SVC_TAB_BITS)^porth)
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		addr_fold = addr->ip6[0]^addr->ip6[1]^
+			    addr->ip6[2]^addr->ip6[3];
+#endif
+
+	return (proto^ntohl(addr_fold)^(porth>>IP_VS_SVC_TAB_BITS)^porth)
 		& IP_VS_SVC_TAB_MASK;
 }
 
@@ -338,7 +346,8 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
 		/*
 		 *  Hash it by <protocol,addr,port> in ip_vs_svc_table
 		 */
-		hash = ip_vs_svc_hashkey(svc->protocol, svc->addr, svc->port);
+		hash = ip_vs_svc_hashkey(svc->af, svc->protocol, &svc->addr,
+					 svc->port);
 		list_add(&svc->s_list, &ip_vs_svc_table[hash]);
 	} else {
 		/*
@@ -385,16 +394,18 @@ static int ip_vs_svc_unhash(struct ip_vs_service *svc)
  *	Get service by {proto,addr,port} in the service table.
  */
 static __inline__ struct ip_vs_service *
-__ip_vs_service_get(__u16 protocol, __be32 vaddr, __be16 vport)
+__ip_vs_service_get(int af, __u16 protocol, const union nf_inet_addr *vaddr,
+		    __be16 vport)
 {
 	unsigned hash;
 	struct ip_vs_service *svc;
 
 	/* Check for "full" addressed entries */
-	hash = ip_vs_svc_hashkey(protocol, vaddr, vport);
+	hash = ip_vs_svc_hashkey(af, protocol, vaddr, vport);
 
 	list_for_each_entry(svc, &ip_vs_svc_table[hash], s_list){
-		if ((svc->addr == vaddr)
+		if ((svc->af == af)
+		    && ip_vs_addr_equal(af, &svc->addr, vaddr)
 		    && (svc->port == vport)
 		    && (svc->protocol == protocol)) {
 			/* HIT */
@@ -410,7 +421,7 @@ __ip_vs_service_get(__u16 protocol, __be32 vaddr, __be16 vport)
 /*
  *	Get service by {fwmark} in the service table.
  */
-static __inline__ struct ip_vs_service *__ip_vs_svc_fwm_get(__u32 fwmark)
+static __inline__ struct ip_vs_service *__ip_vs_svc_fwm_get(int af, __u32 fwmark)
 {
 	unsigned hash;
 	struct ip_vs_service *svc;
@@ -419,7 +430,7 @@ static __inline__ struct ip_vs_service *__ip_vs_svc_fwm_get(__u32 fwmark)
 	hash = ip_vs_svc_fwm_hashkey(fwmark);
 
 	list_for_each_entry(svc, &ip_vs_svc_fwm_table[hash], f_list) {
-		if (svc->fwmark == fwmark) {
+		if (svc->fwmark == fwmark && svc->af == af) {
 			/* HIT */
 			atomic_inc(&svc->usecnt);
 			return svc;
@@ -430,7 +441,8 @@ static __inline__ struct ip_vs_service *__ip_vs_svc_fwm_get(__u32 fwmark)
 }
 
 struct ip_vs_service *
-ip_vs_service_get(__u32 fwmark, __u16 protocol, __be32 vaddr, __be16 vport)
+ip_vs_service_get(int af, __u32 fwmark, __u16 protocol,
+		  const union nf_inet_addr *vaddr, __be16 vport)
 {
 	struct ip_vs_service *svc;
 
@@ -439,14 +451,14 @@ ip_vs_service_get(__u32 fwmark, __u16 protocol, __be32 vaddr, __be16 vport)
 	/*
 	 *	Check the table hashed by fwmark first
 	 */
-	if (fwmark && (svc = __ip_vs_svc_fwm_get(fwmark)))
+	if (fwmark && (svc = __ip_vs_svc_fwm_get(af, fwmark)))
 		goto out;
 
 	/*
 	 *	Check the table hashed by <protocol,addr,port>
 	 *	for "full" addressed entries
 	 */
-	svc = __ip_vs_service_get(protocol, vaddr, vport);
+	svc = __ip_vs_service_get(af, protocol, vaddr, vport);
 
 	if (svc == NULL
 	    && protocol == IPPROTO_TCP
@@ -456,7 +468,7 @@ ip_vs_service_get(__u32 fwmark, __u16 protocol, __be32 vaddr, __be16 vport)
 		 * Check if ftp service entry exists, the packet
 		 * might belong to FTP data connections.
 		 */
-		svc = __ip_vs_service_get(protocol, vaddr, FTPPORT);
+		svc = __ip_vs_service_get(af, protocol, vaddr, FTPPORT);
 	}
 
 	if (svc == NULL
@@ -464,7 +476,7 @@ ip_vs_service_get(__u32 fwmark, __u16 protocol, __be32 vaddr, __be16 vport)
 		/*
 		 * Check if the catch-all port (port zero) exists
 		 */
-		svc = __ip_vs_service_get(protocol, vaddr, 0);
+		svc = __ip_vs_service_get(af, protocol, vaddr, 0);
 	}
 
   out:
@@ -500,11 +512,18 @@ __ip_vs_unbind_svc(struct ip_vs_dest *dest)
 /*
  *	Returns hash value for real service
  */
-static __inline__ unsigned ip_vs_rs_hashkey(__be32 addr, __be16 port)
+static __inline__ unsigned ip_vs_rs_hashkey(int af,
+					    const union nf_inet_addr *addr,
+					    __be16 port)
 {
 	register unsigned porth = ntohs(port);
+	__be32 addr_fold = addr->ip;
 
-	return (ntohl(addr)^(porth>>IP_VS_RTAB_BITS)^porth)
+	if (af == AF_INET6)
+		addr_fold = addr->ip6[0]^addr->ip6[1]^
+			    addr->ip6[2]^addr->ip6[3];
+
+	return (ntohl(addr_fold)^(porth>>IP_VS_RTAB_BITS)^porth)
 		& IP_VS_RTAB_MASK;
 }
 
@@ -524,7 +543,8 @@ static int ip_vs_rs_hash(struct ip_vs_dest *dest)
 	 *	Hash by proto,addr,port,
 	 *	which are the parameters of the real service.
 	 */
-	hash = ip_vs_rs_hashkey(dest->addr, dest->port);
+	hash = ip_vs_rs_hashkey(dest->af, &dest->addr, dest->port);
+
 	list_add(&dest->d_list, &ip_vs_rtable[hash]);
 
 	return 1;
@@ -551,7 +571,9 @@ static int ip_vs_rs_unhash(struct ip_vs_dest *dest)
  *	Lookup real service by <proto,addr,port> in the real service table.
  */
 struct ip_vs_dest *
-ip_vs_lookup_real_service(__u16 protocol, __be32 daddr, __be16 dport)
+ip_vs_lookup_real_service(int af, __u16 protocol,
+			  const union nf_inet_addr *daddr,
+			  __be16 dport)
 {
 	unsigned hash;
 	struct ip_vs_dest *dest;
@@ -560,11 +582,12 @@ ip_vs_lookup_real_service(__u16 protocol, __be32 daddr, __be16 dport)
 	 *	Check for "full" addressed entries
 	 *	Return the first found entry
 	 */
-	hash = ip_vs_rs_hashkey(daddr, dport);
+	hash = ip_vs_rs_hashkey(af, daddr, dport);
 
 	read_lock(&__ip_vs_rs_lock);
 	list_for_each_entry(dest, &ip_vs_rtable[hash], d_list) {
-		if ((dest->addr == daddr)
+		if ((dest->af == af)
+		    && ip_vs_addr_equal(af, &dest->addr, daddr)
 		    && (dest->port == dport)
 		    && ((dest->protocol == protocol) ||
 			dest->vfwmark)) {
@@ -582,7 +605,8 @@ ip_vs_lookup_real_service(__u16 protocol, __be32 daddr, __be16 dport)
  *	Lookup destination by {addr,port} in the given service
  */
 static struct ip_vs_dest *
-ip_vs_lookup_dest(struct ip_vs_service *svc, __be32 daddr, __be16 dport)
+ip_vs_lookup_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
+		  __be16 dport)
 {
 	struct ip_vs_dest *dest;
 
@@ -590,7 +614,9 @@ ip_vs_lookup_dest(struct ip_vs_service *svc, __be32 daddr, __be16 dport)
 	 * Find the destination for the given service
 	 */
 	list_for_each_entry(dest, &svc->destinations, n_list) {
-		if ((dest->addr == daddr) && (dest->port == dport)) {
+		if ((dest->af == svc->af)
+		    && ip_vs_addr_equal(svc->af, &dest->addr, daddr)
+		    && (dest->port == dport)) {
 			/* HIT */
 			return dest;
 		}
@@ -609,13 +635,14 @@ ip_vs_lookup_dest(struct ip_vs_service *svc, __be32 daddr, __be16 dport)
  * ip_vs_lookup_real_service() looked promissing, but
  * seems not working as expected.
  */
-struct ip_vs_dest *ip_vs_find_dest(__be32 daddr, __be16 dport,
-				    __be32 vaddr, __be16 vport, __u16 protocol)
+struct ip_vs_dest *ip_vs_find_dest(int af, const union nf_inet_addr *daddr,
+				   __be16 dport, const union nf_inet_addr *vaddr,
+				   __be16 vport, __u16 protocol)
 {
 	struct ip_vs_dest *dest;
 	struct ip_vs_service *svc;
 
-	svc = ip_vs_service_get(0, protocol, vaddr, vport);
+	svc = ip_vs_service_get(af, 0, protocol, vaddr, vport);
 	if (!svc)
 		return NULL;
 	dest = ip_vs_lookup_dest(svc, daddr, dport);
@@ -636,7 +663,8 @@ struct ip_vs_dest *ip_vs_find_dest(__be32 daddr, __be16 dport,
  *  scheduling.
  */
 static struct ip_vs_dest *
-ip_vs_trash_get_dest(struct ip_vs_service *svc, __be32 daddr, __be16 dport)
+ip_vs_trash_get_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
+		     __be16 dport)
 {
 	struct ip_vs_dest *dest, *nxt;
 
@@ -650,12 +678,13 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, __be32 daddr, __be16 dport)
 			      IP_VS_DBG_ADDR(svc->af, &dest->addr),
 			      ntohs(dest->port),
 			      atomic_read(&dest->refcnt));
-		if (dest->addr == daddr &&
+		if (dest->af == svc->af &&
+		    ip_vs_addr_equal(svc->af, &dest->addr, daddr) &&
 		    dest->port == dport &&
 		    dest->vfwmark == svc->fwmark &&
 		    dest->protocol == svc->protocol &&
 		    (svc->fwmark ||
-		     (dest->vaddr == svc->addr &&
+		     (ip_vs_addr_equal(svc->af, &dest->vaddr, &svc->addr) &&
 		      dest->vport == svc->port))) {
 			/* HIT */
 			return dest;
-- 
1.5.4.5

