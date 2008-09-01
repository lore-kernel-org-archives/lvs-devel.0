From: Julius Volz <juliusv@google.com>
Subject: [PATCHv2 RFC 17/25] IPVS: Convert real server lookup functions
Date: Mon,  1 Sep 2008 14:56:14 +0200
Message-ID: <1220273782-19901-18-git-send-email-juliusv@google.com>
References: <1220273782-19901-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220273824; bh=JnxJ7C2o2EOq0wpVDi38sdPMeUQ=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=oL/RnkHK+0YQoRWsqAfINlHJqT8ac3NQN0NHpF6o
	piZmpMbQsEvo7X3I59RYwKbRlpF3Hcx+iTPjGmAslcK+ig==
In-Reply-To: <1220273782-19901-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Convert functions for looking up destinations (real servers) to support
IPv6 services/dests.

Signed-off-by: Julius Volz <juliusv@google.com>

 5 files changed, 66 insertions(+), 37 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index a7eda08..c163c18 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -804,14 +804,16 @@ static inline void ip_vs_service_put(struct ip_vs_service *svc)
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
 
 
diff --git a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
index 814d416..2f5c4d8 100644
--- a/net/ipv4/ipvs/ip_vs_conn.c
+++ b/net/ipv4/ipvs/ip_vs_conn.c
@@ -490,8 +490,9 @@ struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp)
 	struct ip_vs_dest *dest;
 
 	if ((cp) && (!cp->dest)) {
-		dest = ip_vs_find_dest(cp->daddr.ip, cp->dport,
-				       cp->vaddr.ip, cp->vport, cp->protocol);
+		dest = ip_vs_find_dest(cp->af, &cp->daddr, cp->dport,
+				       &cp->vaddr, cp->vport,
+				       cp->protocol);
 		ip_vs_bind_dest(cp, dest);
 		return dest;
 	} else
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 0bf871c..2725b93 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -956,8 +956,8 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 						  sizeof(_ports), _ports);
 			if (pptr == NULL)
 				return NF_ACCEPT;	/* Not for me */
-			if (ip_vs_lookup_real_service(iph.protocol,
-						      iph.saddr.ip,
+			if (ip_vs_lookup_real_service(af, iph.protocol,
+						      &iph.saddr,
 						      pptr[0])) {
 				/*
 				 * Notify the real server: there is no
diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index 151d368..3dae1d9 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -492,11 +492,20 @@ __ip_vs_unbind_svc(struct ip_vs_dest *dest)
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
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		addr_fold = addr->ip6[0]^addr->ip6[1]^
+			    addr->ip6[2]^addr->ip6[3];
+#endif
 
-	return (ntohl(addr)^(porth>>IP_VS_RTAB_BITS)^porth)
+	return (ntohl(addr_fold)^(porth>>IP_VS_RTAB_BITS)^porth)
 		& IP_VS_RTAB_MASK;
 }
 
@@ -516,7 +525,8 @@ static int ip_vs_rs_hash(struct ip_vs_dest *dest)
 	 *	Hash by proto,addr,port,
 	 *	which are the parameters of the real service.
 	 */
-	hash = ip_vs_rs_hashkey(dest->addr.ip, dest->port);
+	hash = ip_vs_rs_hashkey(dest->af, &dest->addr, dest->port);
+
 	list_add(&dest->d_list, &ip_vs_rtable[hash]);
 
 	return 1;
@@ -543,7 +553,9 @@ static int ip_vs_rs_unhash(struct ip_vs_dest *dest)
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
@@ -552,11 +564,12 @@ ip_vs_lookup_real_service(__u16 protocol, __be32 daddr, __be16 dport)
 	 *	Check for "full" addressed entries
 	 *	Return the first found entry
 	 */
-	hash = ip_vs_rs_hashkey(daddr, dport);
+	hash = ip_vs_rs_hashkey(af, daddr, dport);
 
 	read_lock(&__ip_vs_rs_lock);
 	list_for_each_entry(dest, &ip_vs_rtable[hash], d_list) {
-		if ((dest->addr.ip == daddr)
+		if ((dest->af == af)
+		    && ip_vs_addr_equal(af, &dest->addr, daddr)
 		    && (dest->port == dport)
 		    && ((dest->protocol == protocol) ||
 			dest->vfwmark)) {
@@ -574,7 +587,8 @@ ip_vs_lookup_real_service(__u16 protocol, __be32 daddr, __be16 dport)
  *	Lookup destination by {addr,port} in the given service
  */
 static struct ip_vs_dest *
-ip_vs_lookup_dest(struct ip_vs_service *svc, __be32 daddr, __be16 dport)
+ip_vs_lookup_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
+		  __be16 dport)
 {
 	struct ip_vs_dest *dest;
 
@@ -582,7 +596,9 @@ ip_vs_lookup_dest(struct ip_vs_service *svc, __be32 daddr, __be16 dport)
 	 * Find the destination for the given service
 	 */
 	list_for_each_entry(dest, &svc->destinations, n_list) {
-		if ((dest->addr.ip == daddr) && (dest->port == dport)) {
+		if ((dest->af == svc->af)
+		    && ip_vs_addr_equal(svc->af, &dest->addr, daddr)
+		    && (dest->port == dport)) {
 			/* HIT */
 			return dest;
 		}
@@ -601,14 +617,14 @@ ip_vs_lookup_dest(struct ip_vs_service *svc, __be32 daddr, __be16 dport)
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
-	union nf_inet_addr _vaddr = { .ip = vaddr };
 
-	svc = ip_vs_service_get(AF_INET, 0, protocol, &_vaddr, vport);
+	svc = ip_vs_service_get(af, 0, protocol, vaddr, vport);
 	if (!svc)
 		return NULL;
 	dest = ip_vs_lookup_dest(svc, daddr, dport);
@@ -629,7 +645,8 @@ struct ip_vs_dest *ip_vs_find_dest(__be32 daddr, __be16 dport,
  *  scheduling.
  */
 static struct ip_vs_dest *
-ip_vs_trash_get_dest(struct ip_vs_service *svc, __be32 daddr, __be16 dport)
+ip_vs_trash_get_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
+		     __be16 dport)
 {
 	struct ip_vs_dest *dest, *nxt;
 
@@ -637,17 +654,19 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, __be32 daddr, __be16 dport)
 	 * Find the destination in trash
 	 */
 	list_for_each_entry_safe(dest, nxt, &ip_vs_dest_trash, n_list) {
-		IP_VS_DBG(3, "Destination %u/%u.%u.%u.%u:%u still in trash, "
-			  "dest->refcnt=%d\n",
-			  dest->vfwmark,
-			  NIPQUAD(dest->addr.ip), ntohs(dest->port),
-			  atomic_read(&dest->refcnt));
-		if (dest->addr.ip == daddr &&
+		IP_VS_DBG_BUF(3, "Destination %u/%s:%u still in trash, "
+			      "dest->refcnt=%d\n",
+			      dest->vfwmark,
+			      IP_VS_DBG_ADDR(svc->af, &dest->addr),
+			      ntohs(dest->port),
+			      atomic_read(&dest->refcnt));
+		if (dest->af == svc->af &&
+		    ip_vs_addr_equal(svc->af, &dest->addr, daddr) &&
 		    dest->port == dport &&
 		    dest->vfwmark == svc->fwmark &&
 		    dest->protocol == svc->protocol &&
 		    (svc->fwmark ||
-		     (dest->vaddr.ip == svc->addr.ip &&
+		     (ip_vs_addr_equal(svc->af, &dest->vaddr, &svc->addr) &&
 		      dest->vport == svc->port))) {
 			/* HIT */
 			return dest;
@@ -657,10 +676,11 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, __be32 daddr, __be16 dport)
 		 * Try to purge the destination from trash if not referenced
 		 */
 		if (atomic_read(&dest->refcnt) == 1) {
-			IP_VS_DBG(3, "Removing destination %u/%u.%u.%u.%u:%u "
-				  "from trash\n",
-				  dest->vfwmark,
-				  NIPQUAD(dest->addr.ip), ntohs(dest->port));
+			IP_VS_DBG_BUF(3, "Removing destination %u/%s:%u "
+				      "from trash\n",
+				      dest->vfwmark,
+				      IP_VS_DBG_ADDR(svc->af, &dest->addr),
+				      ntohs(dest->port));
 			list_del(&dest->n_list);
 			ip_vs_dst_reset(dest);
 			__ip_vs_unbind_svc(dest);
@@ -847,7 +867,8 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	/*
 	 * Check if the dest already exists in the list
 	 */
-	dest = ip_vs_lookup_dest(svc, daddr.ip, dport);
+	dest = ip_vs_lookup_dest(svc, &daddr, dport);
+
 	if (dest != NULL) {
 		IP_VS_DBG(1, "ip_vs_add_dest(): dest already exists\n");
 		return -EEXIST;
@@ -857,7 +878,8 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	 * Check if the dest already exists in the trash and
 	 * is from the same service
 	 */
-	dest = ip_vs_trash_get_dest(svc, daddr.ip, dport);
+	dest = ip_vs_trash_get_dest(svc, &daddr, dport);
+
 	if (dest != NULL) {
 		IP_VS_DBG(3, "Get destination %u.%u.%u.%u:%u from trash, "
 			  "dest->refcnt=%d, service %u/%u.%u.%u.%u:%u\n",
@@ -956,7 +978,8 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	/*
 	 *  Lookup the destination list
 	 */
-	dest = ip_vs_lookup_dest(svc, daddr.ip, dport);
+	dest = ip_vs_lookup_dest(svc, &daddr, dport);
+
 	if (dest == NULL) {
 		IP_VS_DBG(1, "ip_vs_edit_dest(): dest doesn't exist\n");
 		return -ENOENT;
@@ -1054,7 +1077,7 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 
 	EnterFunction(2);
 
-	dest = ip_vs_lookup_dest(svc, udest->addr.ip, dport);
+	dest = ip_vs_lookup_dest(svc, &udest->addr, dport);
 
 	if (dest == NULL) {
 		IP_VS_DBG(1, "ip_vs_del_dest(): destination not found!\n");
diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
index 3ce1093..40647ed 100644
--- a/net/ipv4/ipvs/ip_vs_sync.c
+++ b/net/ipv4/ipvs/ip_vs_sync.c
@@ -383,8 +383,11 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 			 * If it is not found the connection will remain unbound
 			 * but still handled.
 			 */
-			dest = ip_vs_find_dest(s->daddr, s->dport,
-					       s->vaddr, s->vport,
+			dest = ip_vs_find_dest(AF_INET,
+					       (union nf_inet_addr *)&s->daddr,
+					       s->dport,
+					       (union nf_inet_addr *)&s->vaddr,
+					       s->vport,
 					       s->protocol);
 			/*  Set the approprite ativity flag */
 			if (s->protocol == IPPROTO_TCP) {
-- 
1.5.4.5

