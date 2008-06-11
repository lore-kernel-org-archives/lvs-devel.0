From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 24/26] IPVS: Add IPv6 support to userspace interface.
Date: Wed, 11 Jun 2008 19:12:07 +0200
Message-ID: <1213204329-10973-25-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213204338; bh=pHYmmnP49j/Tr1FyO19nFb91B5M=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=EvH//csy905zGvpKOEQMAQ2NOk6z5inKhUWjab+1
	vLnNRrc+IFyDPOVRs61DC0QwxtWKhmvRfhCtzWDb4cfWYw==
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com, "Julius R. Volz" <juliusv@google.com>

Add support for adding/modifying/deleting IPv6 service and dest entries by
introducing several new functions and implementing corresponding switches
and checks in existing code.

Signed-off-by: Julius R. Volz <juliusv@google.com>

 3 files changed, 364 insertions(+), 19 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index ab59696..9790ed4 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1017,6 +1017,12 @@ extern struct ctl_path net_vs_ctl_path[];
 extern struct ip_vs_service *
 ip_vs_service_get(__u32 fwmark, __u16 protocol, __be32 vaddr, __be16 vport);
 
+#ifdef CONFIG_IP_VS_IPV6
+extern struct ip_vs_service *
+ip_vs_service_get_v6(__u32 fwmark, __u16 protocol,
+		     const struct in6_addr *vaddr, __be16 vport);
+#endif
+
 static inline void ip_vs_service_put(struct ip_vs_service *svc)
 {
 	atomic_dec(&svc->usecnt);
@@ -1024,6 +1030,11 @@ static inline void ip_vs_service_put(struct ip_vs_service *svc)
 
 extern struct ip_vs_dest *
 ip_vs_lookup_real_service(__u16 protocol, __be32 daddr, __be16 dport);
+#ifdef CONFIG_IP_VS_IPV6
+extern struct ip_vs_dest *
+ip_vs_lookup_real_service_v6(__u16 protocol, const struct in6_addr *daddr,
+			     __be16 dport);
+#endif
 extern int ip_vs_use_count_inc(void);
 extern void ip_vs_use_count_dec(void);
 extern int ip_vs_control_init(void);
@@ -1031,6 +1042,11 @@ extern void ip_vs_control_cleanup(void);
 extern struct ip_vs_dest *
 ip_vs_find_dest(__be32 daddr, __be16 dport,
 		 __be32 vaddr, __be16 vport, __u16 protocol);
+#ifdef CONFIG_IP_VS_IPV6
+extern struct ip_vs_dest *
+ip_vs_find_dest_v6(const struct in6_addr *daddr, __be16 dport,
+		   const struct in6_addr *vaddr, __be16 vport, __u16 protocol);
+#endif
 extern struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp);
 
 
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index ea0fd77..6b031a8 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -633,8 +633,16 @@ struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp)
 	struct ip_vs_dest *dest;
 
 	if ((cp) && (!cp->dest)) {
-		dest = ip_vs_find_dest(cp->daddr, cp->dport,
-				       cp->vaddr, cp->vport, cp->protocol);
+#ifdef CONFIG_IP_VS_IPV6
+		if (cp->af == AF_INET6)
+			dest = ip_vs_find_dest_v6(&cp->daddr.v6, cp->dport,
+						  &cp->vaddr.v6, cp->vport,
+						  cp->protocol);
+		else
+#endif
+			dest = ip_vs_find_dest(cp->daddr.v4, cp->dport,
+					       cp->vaddr.v4, cp->vport,
+					       cp->protocol);
 		ip_vs_bind_dest(cp, dest);
 		return dest;
 	} else
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index ca198b9..388278a 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -428,6 +428,31 @@ __ip_vs_service_get(__u16 protocol, __be32 vaddr, __be16 vport)
 	return NULL;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static __inline__ struct ip_vs_service *
+__ip_vs_service_get_v6(__u16 protocol, const struct in6_addr *vaddr, __be16 vport)
+{
+	unsigned hash;
+	struct ip_vs_service *svc;
+
+	/* Check for "full" addressed entries */
+	hash = ip_vs_svc_hashkey_v6(protocol, vaddr, vport);
+
+	list_for_each_entry(svc, &ip_vs_svc_table[hash], s_list){
+		if ((svc->af == AF_INET6)
+		    && ipv6_addr_equal(&svc->addr.v6, vaddr)
+		    && (svc->port == vport)
+		    && (svc->protocol == protocol)) {
+			/* HIT */
+			atomic_inc(&svc->usecnt);
+			return svc;
+		}
+	}
+
+	return NULL;
+}
+#endif
+
 
 /*
  *	Get service by {fwmark} in the service table.
@@ -500,6 +525,56 @@ ip_vs_service_get(__u32 fwmark, __u16 protocol, __be32 vaddr, __be16 vport)
 	return svc;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+struct ip_vs_service *
+ip_vs_service_get_v6(__u32 fwmark, __u16 protocol, const struct in6_addr *vaddr, __be16 vport)
+{
+	struct ip_vs_service *svc;
+
+	read_lock(&__ip_vs_svc_lock);
+
+	/*
+	 *	Check the table hashed by fwmark first
+	 */
+	if (fwmark && (svc = __ip_vs_svc_fwm_get(fwmark)))
+		goto out;
+
+	/*
+	 *	Check the table hashed by <protocol,addr,port>
+	 *	for "full" addressed entries
+	 */
+	svc = __ip_vs_service_get_v6(protocol, vaddr, vport);
+
+	if (svc == NULL
+	    && protocol == IPPROTO_TCP
+	    && atomic_read(&ip_vs_ftpsvc_counter)
+	    && (vport == FTPDATA || ntohs(vport) >= PROT_SOCK)) {
+		/*
+		 * Check if ftp service entry exists, the packet
+		 * might belong to FTP data connections.
+		 */
+		svc = __ip_vs_service_get_v6(protocol, vaddr, FTPPORT);
+	}
+
+	if (svc == NULL
+	    && atomic_read(&ip_vs_nullsvc_counter)) {
+		/*
+		 * Check if the catch-all port (port zero) exists
+		 */
+		svc = __ip_vs_service_get_v6(protocol, vaddr, 0);
+	}
+
+  out:
+	read_unlock(&__ip_vs_svc_lock);
+
+	IP_VS_DBG(9, "lookup service: fwm %u %s " NIP6_FMT ":%u %s\n",
+		  fwmark, ip_vs_proto_name(protocol),
+		  NIP6(*vaddr), ntohs(vport),
+		  svc?"hit":"not hit");
+
+	return svc;
+}
+#endif
 
 static inline void
 __ip_vs_bind_svc(struct ip_vs_dest *dest, struct ip_vs_service *svc)
@@ -621,6 +696,38 @@ ip_vs_lookup_real_service(__u16 protocol, __be32 daddr, __be16 dport)
 	return NULL;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+struct ip_vs_dest *
+ip_vs_lookup_real_service_v6(__u16 protocol, const struct in6_addr *daddr,
+			     __be16 dport)
+{
+	unsigned hash;
+	struct ip_vs_dest *dest;
+
+	/*
+	 *	Check for "full" addressed entries
+	 *	Return the first found entry
+	 */
+	hash = ip_vs_rs_hashkey_v6(daddr, dport);
+
+	read_lock(&__ip_vs_rs_lock);
+	list_for_each_entry(dest, &ip_vs_rtable[hash], d_list) {
+		if ((dest->af == AF_INET6)
+		    && (ipv6_addr_equal(&dest->addr.v6, daddr))
+		    && (dest->port == dport)
+		    && ((dest->protocol == protocol) ||
+			dest->vfwmark)) {
+			/* HIT */
+			read_unlock(&__ip_vs_rs_lock);
+			return dest;
+		}
+	}
+	read_unlock(&__ip_vs_rs_lock);
+
+	return NULL;
+}
+#endif
+
 /*
  *	Lookup destination by {addr,port} in the given service
  */
@@ -643,6 +750,29 @@ ip_vs_lookup_dest(struct ip_vs_service *svc, __be32 daddr, __be16 dport)
 	return NULL;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static struct ip_vs_dest *
+ip_vs_lookup_dest_v6(struct ip_vs_service *svc, const struct in6_addr *daddr,
+		     __be16 dport)
+{
+	struct ip_vs_dest *dest;
+
+	/*
+	 * Find the destination for the given service
+	 */
+	list_for_each_entry(dest, &svc->destinations, n_list) {
+		if ((dest->af == AF_INET6)
+		    && ipv6_addr_equal(&dest->addr.v6, daddr)
+		    && (dest->port == dport)) {
+			/* HIT */
+			return dest;
+		}
+	}
+
+	return NULL;
+}
+#endif
+
 /*
  * Find destination by {daddr,dport,vaddr,protocol}
  * Cretaed to be used in ip_vs_process_message() in
@@ -669,6 +799,25 @@ struct ip_vs_dest *ip_vs_find_dest(__be32 daddr, __be16 dport,
 	return dest;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+struct ip_vs_dest *ip_vs_find_dest_v6(const struct in6_addr *daddr, __be16 dport,
+				      const struct in6_addr *vaddr, __be16 vport,
+				      __u16 protocol)
+{
+	struct ip_vs_dest *dest;
+	struct ip_vs_service *svc;
+
+	svc = ip_vs_service_get_v6(0, protocol, vaddr, vport);
+	if (!svc)
+		return NULL;
+	dest = ip_vs_lookup_dest_v6(svc, daddr, dport);
+	if (dest)
+		atomic_inc(&dest->refcnt);
+	ip_vs_service_put(svc);
+	return dest;
+}
+#endif
+
 /*
  *  Lookup dest by {svc,addr,port} in the destination trash.
  *  The destination trash is used to hold the destinations that are removed
@@ -723,12 +872,59 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, __be32 daddr, __be16 dport)
 	return NULL;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static struct ip_vs_dest *
+ip_vs_trash_get_dest_v6(struct ip_vs_service *svc, const struct in6_addr *daddr,
+			__be16 dport)
+{
+	struct ip_vs_dest *dest, *nxt;
+
+	/*
+	 * Find the destination in trash
+	 */
+	list_for_each_entry_safe(dest, nxt, &ip_vs_dest_trash, n_list) {
+		IP_VS_DBG(3, "Destination %u/" NIP6_FMT ":%u still in trash, "
+			  "dest->refcnt=%d\n",
+			  dest->vfwmark,
+			  NIP6(dest->addr.v6), ntohs(dest->port),
+			  atomic_read(&dest->refcnt));
+		if (dest->af == AF_INET6 &&
+		    ipv6_addr_equal(&dest->addr.v6, daddr) &&
+		    dest->port == dport &&
+		    dest->vfwmark == svc->fwmark &&
+		    dest->protocol == svc->protocol &&
+		    (svc->fwmark ||
+		     (ipv6_addr_equal(&dest->vaddr.v6, &svc->addr.v6) &&
+		      dest->vport == svc->port))) {
+			/* HIT */
+			return dest;
+		}
+
+		/*
+		 * Try to purge the destination from trash if not referenced
+		 */
+		if (atomic_read(&dest->refcnt) == 1) {
+			IP_VS_DBG(3, "Removing destination %u/" NIP6_FMT ":%u "
+				  "from trash\n",
+				  dest->vfwmark,
+				  NIP6(dest->addr.v6), ntohs(dest->port));
+			list_del(&dest->n_list);
+			ip_vs_dst_reset(dest);
+			__ip_vs_unbind_svc(dest);
+			kfree(dest);
+		}
+	}
+
+	return NULL;
+}
+#endif
+
 
 /*
  *  Clean up all the destinations in the trash
  *  Called by the ip_vs_control_cleanup()
  *
- *  When the ip_vs_control_clearup is activated by ipvs module exit,
+ *  When the ip_vs_control_cleanup is activated by ipvs module exit,
  *  the service tables must have been flushed and all the connections
  *  are expired, and the refcnt of each destination in the trash must
  *  be 1, so we simply release them here.
@@ -831,9 +1027,19 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest,
 
 	EnterFunction(2);
 
-	atype = inet_addr_type(&init_net, udest->addr);
-	if (atype != RTN_LOCAL && atype != RTN_UNICAST)
-		return -EINVAL;
+#ifdef CONFIG_IP_VS_IPV6
+	if (svc->af == AF_INET6) {
+		atype = ipv6_addr_type(&udest->addr.v6);
+		if (!(atype & IPV6_ADDR_UNICAST) &&
+			!__ip_vs_addr_is_local_v6(&udest->addr.v6))
+			return -EINVAL;
+	} else
+#endif
+	{
+		atype = inet_addr_type(&init_net, udest->addr.v4);
+		if (atype != RTN_LOCAL && atype != RTN_UNICAST)
+			return -EINVAL;
+	}
 
 	dest = kzalloc(sizeof(struct ip_vs_dest), GFP_ATOMIC);
 	if (dest == NULL) {
@@ -874,12 +1080,18 @@ static int
 ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
 {
 	struct ip_vs_dest *dest;
-	__be32 daddr = udest->addr;
+	union ip_vs_addr_user daddr = udest->addr;
 	__be16 dport = udest->port;
 	int ret;
 
 	EnterFunction(2);
 
+	if (udest->af != svc->af) {
+		IP_VS_ERR("ip_vs_add_dest(): address families of service and "
+			  "destination do not match\n");
+		return -EFAULT;
+	}
+
 	if (udest->weight < 0) {
 		IP_VS_ERR("ip_vs_add_dest(): server weight less than zero\n");
 		return -ERANGE;
@@ -894,7 +1106,14 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
 	/*
 	 * Check if the dest already exists in the list
 	 */
-	dest = ip_vs_lookup_dest(svc, daddr, dport);
+#ifdef CONFIG_IP_VS_IPV6
+	dest = (svc->af == AF_INET)
+		? ip_vs_lookup_dest(svc, daddr.v4, dport)
+		: ip_vs_lookup_dest_v6(svc, &daddr.v6, dport);
+#else
+	dest = ip_vs_lookup_dest(svc, daddr.v4, dport);
+#endif
+
 	if (dest != NULL) {
 		IP_VS_DBG(1, "ip_vs_add_dest(): dest already exists\n");
 		return -EEXIST;
@@ -904,7 +1123,14 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
 	 * Check if the dest already exists in the trash and
 	 * is from the same service
 	 */
-	dest = ip_vs_trash_get_dest(svc, daddr, dport);
+#ifdef CONFIG_IP_VS_IPV6
+	dest = (svc->af == AF_INET)
+		? ip_vs_trash_get_dest(svc, daddr.v4, dport)
+		: ip_vs_trash_get_dest_v6(svc, &daddr.v6, dport);
+#else
+	dest = ip_vs_trash_get_dest(svc, daddr.v4, dport);
+#endif
+
 	if (dest != NULL) {
 		IP_VS_DBG_V4(svc->af, 3, "Get destination %u.%u.%u.%u:%u from trash, "
 			     "dest->refcnt=%d, service %u/%u.%u.%u.%u:%u\n",
@@ -989,11 +1215,17 @@ static int
 ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
 {
 	struct ip_vs_dest *dest;
-	__be32 daddr = udest->addr;
+	union ip_vs_addr_user daddr = udest->addr;
 	__be16 dport = udest->port;
 
 	EnterFunction(2);
 
+	if (udest->af != svc->af) {
+		IP_VS_ERR("ip_vs_edit_dest(): address families of service and "
+			  "destination do not match\n");
+		return -EFAULT;
+	}
+
 	if (udest->weight < 0) {
 		IP_VS_ERR("ip_vs_edit_dest(): server weight less than zero\n");
 		return -ERANGE;
@@ -1008,7 +1240,14 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
 	/*
 	 *  Lookup the destination list
 	 */
-	dest = ip_vs_lookup_dest(svc, daddr, dport);
+#ifdef CONFIG_IP_VS_IPV6
+	dest = (svc->af == AF_INET)
+		? ip_vs_lookup_dest(svc, daddr.v4, dport)
+		: ip_vs_lookup_dest_v6(svc, &daddr.v6, dport);
+#else
+	dest = ip_vs_lookup_dest(svc, daddr.v4, dport);
+#endif
+
 	if (dest == NULL) {
 		IP_VS_DBG(1, "ip_vs_edit_dest(): dest doesn't exist\n");
 		return -ENOENT;
@@ -1104,15 +1343,28 @@ static void __ip_vs_unlink_dest(struct ip_vs_service *svc,
  *	Delete a destination server in the given service
  */
 static int
-ip_vs_del_dest(struct ip_vs_service *svc,struct ip_vs_dest_user *udest)
+ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
 {
 	struct ip_vs_dest *dest;
-	__be32 daddr = udest->addr;
+	union ip_vs_addr_user daddr = udest->addr;
 	__be16 dport = udest->port;
 
 	EnterFunction(2);
 
-	dest = ip_vs_lookup_dest(svc, daddr, dport);
+	if (udest->af != svc->af) {
+		IP_VS_ERR("ip_vs_add_dest(): address families of service and"
+			  "destination do not match\n");
+		return -EFAULT;
+	}
+
+#ifdef CONFIG_IP_VS_IPV6
+	dest = (svc->af == AF_INET)
+		? ip_vs_lookup_dest(svc, daddr.v4, dport)
+		: ip_vs_lookup_dest_v6(svc, &daddr.v6, dport);
+#else
+	dest = ip_vs_lookup_dest(svc, daddr.v4, dport);
+#endif
+
 	if (dest == NULL) {
 		IP_VS_DBG(1, "ip_vs_del_dest(): destination not found!\n");
 		return -ENOENT;
@@ -1165,6 +1417,19 @@ ip_vs_add_service(struct ip_vs_service_user *u, struct ip_vs_service **svc_p)
 		goto out_mod_dec;
 	}
 
+#ifdef CONFIG_IP_VS_IPV6
+	if (u->af == AF_INET6) {
+		if (!sched->supports_ipv6) {
+			ret = EAFNOSUPPORT;
+			goto out_err;
+		}
+		if ((u->netmask < 1) || (u->netmask > 128)) {
+			ret = EINVAL;
+			goto out_err;
+		}
+	}
+#endif
+
 	svc = kzalloc(sizeof(struct ip_vs_service), GFP_ATOMIC);
 	if (svc == NULL) {
 		IP_VS_DBG(1, "ip_vs_add_service: kmalloc failed.\n");
@@ -1253,6 +1518,19 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user *u)
 	}
 	old_sched = sched;
 
+#ifdef CONFIG_IP_VS_IPV6
+	if (u->af == AF_INET6) {
+		if (!sched->supports_ipv6) {
+			ret = EAFNOSUPPORT;
+			goto out;
+		}
+		if ((u->netmask < 1) || (u->netmask > 128)) {
+			ret = EINVAL;
+			goto out;
+		}
+	}
+#endif
+
 	write_lock_bh(&__ip_vs_svc_lock);
 
 	/*
@@ -1685,6 +1963,7 @@ static struct ctl_table vs_vars[] = {
 
 struct ctl_path net_vs_ctl_path[] = {
 	{ .procname = "net", .ctl_name = CTL_NET, },
+	/* TODO IPv6: possible to move / duplicate this? */
 	{ .procname = "ipv4", .ctl_name = NET_IPV4, },
 	{ .procname = "vs", },
 	{ }
@@ -2031,12 +2310,33 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 
 	if (cmd == IP_VS_SO_SET_ZERO) {
 		/* if no service address is set, zero counters in all */
-		if (!usvc->fwmark && !usvc->addr && !usvc->port) {
+#ifdef CONFIG_IP_VS_IPV6
+		struct in6_addr zero_addr = { .s6_addr32 = {0, 0, 0, 0} };
+		if (usvc->af == AF_INET6 && !usvc->fwmark &&
+		    ipv6_addr_equal(&usvc->addr.v6,&zero_addr) && !usvc->port) {
+			ret = ip_vs_zero_all();
+			goto out_unlock;
+		}
+#endif
+		if (!usvc->fwmark && !usvc->addr.v4 && !usvc->port) {
 			ret = ip_vs_zero_all();
 			goto out_unlock;
 		}
 	}
 
+	/* Check for valid address family */
+	if (usvc->af != AF_INET) {
+#ifdef CONFIG_IP_VS_IPV6
+		if (usvc->af != AF_INET6) {
+			ret = -EAFNOSUPPORT;
+			goto out_unlock;
+		}
+#else
+		ret = -EAFNOSUPPORT;
+		goto out_unlock;
+#endif
+	}
+
 	/* Check for valid protocol: TCP or UDP, even for fwmark!=0 */
 	if (usvc->protocol!=IPPROTO_TCP && usvc->protocol!=IPPROTO_UDP) {
 		IP_VS_ERR_V4(usvc->af, "set_ctl: invalid protocol: %d %d.%d.%d.%d:%d %s\n",
@@ -2053,8 +2353,14 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 
 	/* Lookup the exact service by <protocol, addr, port> or fwmark */
 	if (usvc->fwmark == 0)
-		svc = __ip_vs_service_get(usvc->protocol,
-					  usvc->addr, usvc->port);
+#ifdef CONFIG_IP_VS_IPV6
+		if (usvc->af == AF_INET6)
+			svc = __ip_vs_service_get_v6(usvc->protocol,
+						     &usvc->addr.v6, usvc->port);
+		else
+#endif
+			svc = __ip_vs_service_get(usvc->protocol,
+						  usvc->addr.v4, usvc->port);
 	else
 		svc = __ip_vs_svc_fwm_get(usvc->fwmark);
 
@@ -2183,9 +2489,17 @@ __ip_vs_get_dest_entries(const struct ip_vs_get_dests *get,
 
 	if (get->fwmark)
 		svc = __ip_vs_svc_fwm_get(get->fwmark);
+	else if (get->af == AF_INET6)
+#ifdef CONFIG_IP_VS_IPV6
+		svc = __ip_vs_service_get_v6(get->protocol,
+					     &get->addr.v6, get->port);
+#else
+		return -EAFNOSUPPORT;
+#endif
 	else
 		svc = __ip_vs_service_get(get->protocol,
-					  get->addr, get->port);
+					  get->addr.v4, get->port);
+
 	if (svc) {
 		int count = 0;
 		struct ip_vs_dest *dest;
@@ -2325,9 +2639,16 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 		entry = (struct ip_vs_service_entry *)arg;
 		if (entry->fwmark)
 			svc = __ip_vs_svc_fwm_get(entry->fwmark);
+#ifdef CONFIG_IP_VS_IPV6
+		else if (entry->af == AF_INET6)
+			svc = __ip_vs_service_get_v6(entry->protocol,
+						     &entry->addr.v6,
+						     entry->port);
+#endif
 		else
 			svc = __ip_vs_service_get(entry->protocol,
-						  entry->addr, entry->port);
+						  entry->addr.v4, entry->port);
+
 		if (svc) {
 			ip_vs_copy_service(entry, svc);
 			if (copy_to_user(user, entry, sizeof(*entry)) != 0)
-- 
1.5.3.6

