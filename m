From: Julius Volz <juliusv@google.com>
Subject: [PATCHv3 06/24] IPVS: Convert __ip_vs_svc_get() and __ip_vs_fwm_get()
Date: Tue,  2 Sep 2008 15:55:37 +0200
Message-ID: <1220363755-9854-7-git-send-email-juliusv@google.com>
References: <1220363755-9854-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220363765; bh=bk+elq9tbr32YmMASgQ7DhFJp+M=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=JDMozLzeniX06QowNppOFc5UTgPrGr1vgZOq2518
	DZFbiceGtCO7l+dWzuFi+t5qAZd+SrUuSJ8xKqOzNCPCKw==
In-Reply-To: <1220363755-9854-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Add support for getting services based on their address family to
__ip_vs_service_get(), __ip_vs_fwm_get() and the helper hash function
ip_vs_svc_hashkey(). Adjust the callers.

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 47 insertions(+), 32 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index a0c8b7b..a2d69b2 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -282,11 +282,19 @@ static atomic_t ip_vs_nullsvc_counter = ATOMIC_INIT(0);
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
 
@@ -317,7 +325,7 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
 		/*
 		 *  Hash it by <protocol,addr,port> in ip_vs_svc_table
 		 */
-		hash = ip_vs_svc_hashkey(svc->protocol, svc->addr.ip,
+		hash = ip_vs_svc_hashkey(svc->af, svc->protocol, &svc->addr,
 					 svc->port);
 		list_add(&svc->s_list, &ip_vs_svc_table[hash]);
 	} else {
@@ -364,17 +372,19 @@ static int ip_vs_svc_unhash(struct ip_vs_service *svc)
 /*
  *	Get service by {proto,addr,port} in the service table.
  */
-static __inline__ struct ip_vs_service *
-__ip_vs_service_get(__u16 protocol, __be32 vaddr, __be16 vport)
+static inline struct ip_vs_service *
+__ip_vs_service_get(int af, __u16 protocol, const union nf_inet_addr *vaddr,
+		    __be16 vport)
 {
 	unsigned hash;
 	struct ip_vs_service *svc;
 
 	/* Check for "full" addressed entries */
-	hash = ip_vs_svc_hashkey(protocol, vaddr, vport);
+	hash = ip_vs_svc_hashkey(af, protocol, vaddr, vport);
 
 	list_for_each_entry(svc, &ip_vs_svc_table[hash], s_list){
-		if ((svc->addr.ip == vaddr)
+		if ((svc->af == af)
+		    && ip_vs_addr_equal(af, &svc->addr, vaddr)
 		    && (svc->port == vport)
 		    && (svc->protocol == protocol)) {
 			/* HIT */
@@ -390,7 +400,8 @@ __ip_vs_service_get(__u16 protocol, __be32 vaddr, __be16 vport)
 /*
  *	Get service by {fwmark} in the service table.
  */
-static __inline__ struct ip_vs_service *__ip_vs_svc_fwm_get(__u32 fwmark)
+static inline struct ip_vs_service *
+__ip_vs_svc_fwm_get(int af, __u32 fwmark)
 {
 	unsigned hash;
 	struct ip_vs_service *svc;
@@ -399,7 +410,7 @@ static __inline__ struct ip_vs_service *__ip_vs_svc_fwm_get(__u32 fwmark)
 	hash = ip_vs_svc_fwm_hashkey(fwmark);
 
 	list_for_each_entry(svc, &ip_vs_svc_fwm_table[hash], f_list) {
-		if (svc->fwmark == fwmark) {
+		if (svc->fwmark == fwmark && svc->af == af) {
 			/* HIT */
 			atomic_inc(&svc->usecnt);
 			return svc;
@@ -413,20 +424,20 @@ struct ip_vs_service *
 ip_vs_service_get(__u32 fwmark, __u16 protocol, __be32 vaddr, __be16 vport)
 {
 	struct ip_vs_service *svc;
-
+	union nf_inet_addr _vaddr = { .ip = vaddr };
 	read_lock(&__ip_vs_svc_lock);
 
 	/*
 	 *	Check the table hashed by fwmark first
 	 */
-	if (fwmark && (svc = __ip_vs_svc_fwm_get(fwmark)))
+	if (fwmark && (svc = __ip_vs_svc_fwm_get(AF_INET, fwmark)))
 		goto out;
 
 	/*
 	 *	Check the table hashed by <protocol,addr,port>
 	 *	for "full" addressed entries
 	 */
-	svc = __ip_vs_service_get(protocol, vaddr, vport);
+	svc = __ip_vs_service_get(AF_INET, protocol, &_vaddr, vport);
 
 	if (svc == NULL
 	    && protocol == IPPROTO_TCP
@@ -436,7 +447,7 @@ ip_vs_service_get(__u32 fwmark, __u16 protocol, __be32 vaddr, __be16 vport)
 		 * Check if ftp service entry exists, the packet
 		 * might belong to FTP data connections.
 		 */
-		svc = __ip_vs_service_get(protocol, vaddr, FTPPORT);
+		svc = __ip_vs_service_get(AF_INET, protocol, &_vaddr, FTPPORT);
 	}
 
 	if (svc == NULL
@@ -444,7 +455,7 @@ ip_vs_service_get(__u32 fwmark, __u16 protocol, __be32 vaddr, __be16 vport)
 		/*
 		 * Check if the catch-all port (port zero) exists
 		 */
-		svc = __ip_vs_service_get(protocol, vaddr, 0);
+		svc = __ip_vs_service_get(AF_INET, protocol, &_vaddr, 0);
 	}
 
   out:
@@ -2016,10 +2027,10 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 
 	/* Lookup the exact service by <protocol, addr, port> or fwmark */
 	if (usvc.fwmark == 0)
-		svc = __ip_vs_service_get(usvc.protocol,
-					  usvc.addr.ip, usvc.port);
+		svc = __ip_vs_service_get(usvc.af, usvc.protocol,
+					  &usvc.addr, usvc.port);
 	else
-		svc = __ip_vs_svc_fwm_get(usvc.fwmark);
+		svc = __ip_vs_svc_fwm_get(usvc.af, usvc.fwmark);
 
 	if (cmd != IP_VS_SO_SET_ADD
 	    && (svc == NULL || svc->protocol != usvc.protocol)) {
@@ -2141,13 +2152,15 @@ __ip_vs_get_dest_entries(const struct ip_vs_get_dests *get,
 			 struct ip_vs_get_dests __user *uptr)
 {
 	struct ip_vs_service *svc;
+	union nf_inet_addr addr = { .ip = get->addr };
 	int ret = 0;
 
 	if (get->fwmark)
-		svc = __ip_vs_svc_fwm_get(get->fwmark);
+		svc = __ip_vs_svc_fwm_get(AF_INET, get->fwmark);
 	else
-		svc = __ip_vs_service_get(get->protocol,
-					  get->addr, get->port);
+		svc = __ip_vs_service_get(AF_INET, get->protocol, &addr,
+					  get->port);
+
 	if (svc) {
 		int count = 0;
 		struct ip_vs_dest *dest;
@@ -2282,13 +2295,15 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	{
 		struct ip_vs_service_entry *entry;
 		struct ip_vs_service *svc;
+		union nf_inet_addr addr;
 
 		entry = (struct ip_vs_service_entry *)arg;
+		addr.ip = entry->addr;
 		if (entry->fwmark)
-			svc = __ip_vs_svc_fwm_get(entry->fwmark);
+			svc = __ip_vs_svc_fwm_get(AF_INET, entry->fwmark);
 		else
-			svc = __ip_vs_service_get(entry->protocol,
-						  entry->addr, entry->port);
+			svc = __ip_vs_service_get(AF_INET, entry->protocol,
+						  &addr, entry->port);
 		if (svc) {
 			ip_vs_copy_service(entry, svc);
 			if (copy_to_user(user, entry, sizeof(*entry)) != 0)
@@ -2613,10 +2628,10 @@ static int ip_vs_genl_parse_service(struct ip_vs_service_user_kern *usvc,
 
 		/* prefill flags from service if it already exists */
 		if (usvc->fwmark)
-			svc = __ip_vs_svc_fwm_get(usvc->fwmark);
+			svc = __ip_vs_svc_fwm_get(usvc->af, usvc->fwmark);
 		else
-			svc = __ip_vs_service_get(usvc->protocol, usvc->addr.ip,
-						  usvc->port);
+			svc = __ip_vs_service_get(usvc->af, usvc->protocol,
+						  &usvc->addr, usvc->port);
 		if (svc) {
 			usvc->flags = svc->flags;
 			ip_vs_service_put(svc);
@@ -2644,10 +2659,10 @@ static struct ip_vs_service *ip_vs_genl_find_service(struct nlattr *nla)
 		return ERR_PTR(ret);
 
 	if (usvc.fwmark)
-		return __ip_vs_svc_fwm_get(usvc.fwmark);
+		return __ip_vs_svc_fwm_get(usvc.af, usvc.fwmark);
 	else
-		return __ip_vs_service_get(usvc.protocol, usvc.addr.ip,
-					   usvc.port);
+		return __ip_vs_service_get(usvc.af, usvc.protocol,
+					   &usvc.addr, usvc.port);
 }
 
 static int ip_vs_genl_fill_dest(struct sk_buff *skb, struct ip_vs_dest *dest)
@@ -2955,10 +2970,10 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 
 	/* Lookup the exact service by <protocol, addr, port> or fwmark */
 	if (usvc.fwmark == 0)
-		svc = __ip_vs_service_get(usvc.protocol, usvc.addr.ip,
-					  usvc.port);
+		svc = __ip_vs_service_get(usvc.af, usvc.protocol,
+					  &usvc.addr, usvc.port);
 	else
-		svc = __ip_vs_svc_fwm_get(usvc.fwmark);
+		svc = __ip_vs_svc_fwm_get(usvc.af, usvc.fwmark);
 
 	/* Unless we're adding a new service, the service must already exist */
 	if ((cmd != IPVS_CMD_NEW_SERVICE) && (svc == NULL)) {
-- 
1.5.4.5

