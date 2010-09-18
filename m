From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipvs: changes related to service usecnt
Date: Sat, 18 Sep 2010 17:18:46 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.1009181704560.8786@u.domain.uli>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


	Change the usage of svc usecnt during command execution:

- we check if svc is registered but we do not need to hold usecnt
reference while under __ip_vs_mutex, only the packet handling needs
it during scheduling

- change __ip_vs_service_get to __ip_vs_service_find and
__ip_vs_svc_fwm_get to __ip_vs_svc_fwm_find because now caller
will increase svc->usecnt

- put common code that calls update_service in __ip_vs_update_dest

- put common code in ip_vs_unlink_service() and use it to unregister
the service

- add comment that svc should not be accessed after ip_vs_del_service 
anymore

- all IP_VS_WAIT_WHILE calls are now unified: usecnt > 0

- Properly log the app ports

	As result, some problems are fixed:

- possible use-after-free of svc in ip_vs_genl_set_cmd after
ip_vs_del_service because our usecnt reference does not guarantee that
svc is not freed on refcnt==0, eg. when no dests are moved to trash

- possible usecnt leak in do_ip_vs_set_ctl after ip_vs_del_service
when the service is not freed now, for example, when some
destionations are moved into trash and svc->refcnt remains above 0.
It is harmless because svc is not in hash anymore.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

	This patch applies on net-next-2.6-e548833 (2010-SEP-10)
and also after the last 3 patches for nfct.

diff -urp net-next-2.6-e548833/linux/net/netfilter/ipvs/ip_vs_app.c linux/net/netfilter/ipvs/ip_vs_app.c
--- net-next-2.6-e548833/linux/net/netfilter/ipvs/ip_vs_app.c	2010-09-10 08:27:33.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_app.c	2010-09-18 16:32:51.000000000 +0300
@@ -103,8 +103,8 @@ ip_vs_app_inc_new(struct ip_vs_app *app,
 		goto out;
 
 	list_add(&inc->a_list, &app->incs_list);
-	IP_VS_DBG(9, "%s application %s:%u registered\n",
-		  pp->name, inc->name, inc->port);
+	IP_VS_DBG(9, "%s App %s:%u registered\n",
+		  pp->name, inc->name, ntohs(inc->port));
 
 	return 0;
 
@@ -130,7 +130,7 @@ ip_vs_app_inc_release(struct ip_vs_app *
 		pp->unregister_app(inc);
 
 	IP_VS_DBG(9, "%s App %s:%u unregistered\n",
-		  pp->name, inc->name, inc->port);
+		  pp->name, inc->name, ntohs(inc->port));
 
 	list_del(&inc->a_list);
 
diff -urp net-next-2.6-e548833/linux/net/netfilter/ipvs/ip_vs_ctl.c linux/net/netfilter/ipvs/ip_vs_ctl.c
--- net-next-2.6-e548833/linux/net/netfilter/ipvs/ip_vs_ctl.c	2010-09-10 08:27:33.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_ctl.c	2010-09-18 16:08:01.000000000 +0300
@@ -401,7 +401,7 @@ static int ip_vs_svc_unhash(struct ip_vs
  *	Get service by {proto,addr,port} in the service table.
  */
 static inline struct ip_vs_service *
-__ip_vs_service_get(int af, __u16 protocol, const union nf_inet_addr *vaddr,
+__ip_vs_service_find(int af, __u16 protocol, const union nf_inet_addr *vaddr,
 		    __be16 vport)
 {
 	unsigned hash;
@@ -416,7 +416,6 @@ __ip_vs_service_get(int af, __u16 protoc
 		    && (svc->port == vport)
 		    && (svc->protocol == protocol)) {
 			/* HIT */
-			atomic_inc(&svc->usecnt);
 			return svc;
 		}
 	}
@@ -429,7 +428,7 @@ __ip_vs_service_get(int af, __u16 protoc
  *	Get service by {fwmark} in the service table.
  */
 static inline struct ip_vs_service *
-__ip_vs_svc_fwm_get(int af, __u32 fwmark)
+__ip_vs_svc_fwm_find(int af, __u32 fwmark)
 {
 	unsigned hash;
 	struct ip_vs_service *svc;
@@ -440,7 +439,6 @@ __ip_vs_svc_fwm_get(int af, __u32 fwmark
 	list_for_each_entry(svc, &ip_vs_svc_fwm_table[hash], f_list) {
 		if (svc->fwmark == fwmark && svc->af == af) {
 			/* HIT */
-			atomic_inc(&svc->usecnt);
 			return svc;
 		}
 	}
@@ -459,14 +457,14 @@ ip_vs_service_get(int af, __u32 fwmark, 
 	/*
 	 *	Check the table hashed by fwmark first
 	 */
-	if (fwmark && (svc = __ip_vs_svc_fwm_get(af, fwmark)))
+	if (fwmark && (svc = __ip_vs_svc_fwm_find(af, fwmark)))
 		goto out;
 
 	/*
 	 *	Check the table hashed by <protocol,addr,port>
 	 *	for "full" addressed entries
 	 */
-	svc = __ip_vs_service_get(af, protocol, vaddr, vport);
+	svc = __ip_vs_service_find(af, protocol, vaddr, vport);
 
 	if (svc == NULL
 	    && protocol == IPPROTO_TCP
@@ -476,7 +474,7 @@ ip_vs_service_get(int af, __u32 fwmark, 
 		 * Check if ftp service entry exists, the packet
 		 * might belong to FTP data connections.
 		 */
-		svc = __ip_vs_service_get(af, protocol, vaddr, FTPPORT);
+		svc = __ip_vs_service_find(af, protocol, vaddr, FTPPORT);
 	}
 
 	if (svc == NULL
@@ -484,10 +482,12 @@ ip_vs_service_get(int af, __u32 fwmark, 
 		/*
 		 * Check if the catch-all port (port zero) exists
 		 */
-		svc = __ip_vs_service_get(af, protocol, vaddr, 0);
+		svc = __ip_vs_service_find(af, protocol, vaddr, 0);
 	}
 
   out:
+	if (svc)
+		atomic_inc(&svc->usecnt);
 	read_unlock(&__ip_vs_svc_lock);
 
 	IP_VS_DBG_BUF(9, "lookup service: fwm %u %s %s:%u %s\n",
@@ -506,14 +506,19 @@ __ip_vs_bind_svc(struct ip_vs_dest *dest
 	dest->svc = svc;
 }
 
-static inline void
+static void
 __ip_vs_unbind_svc(struct ip_vs_dest *dest)
 {
 	struct ip_vs_service *svc = dest->svc;
 
 	dest->svc = NULL;
-	if (atomic_dec_and_test(&svc->refcnt))
+	if (atomic_dec_and_test(&svc->refcnt)) {
+		IP_VS_DBG_BUF(3, "Removing service %u/%s:%u usecnt=%d\n",
+			      svc->fwmark,
+			      IP_VS_DBG_ADDR(svc->af, &svc->addr),
+			      ntohs(svc->port), atomic_read(&svc->usecnt));
 		kfree(svc);
+	}
 }
 
 
@@ -758,8 +763,8 @@ ip_vs_zero_stats(struct ip_vs_stats *sta
  *	Update a destination in the given service
  */
 static void
-__ip_vs_update_dest(struct ip_vs_service *svc,
-		    struct ip_vs_dest *dest, struct ip_vs_dest_user_kern *udest)
+__ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
+		    struct ip_vs_dest_user_kern *udest, int add)
 {
 	int conn_flags;
 
@@ -813,6 +818,25 @@ __ip_vs_update_dest(struct ip_vs_service
 		dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
 	dest->u_threshold = udest->u_threshold;
 	dest->l_threshold = udest->l_threshold;
+
+	if (add)
+		ip_vs_new_estimator(&dest->stats);
+
+	write_lock_bh(&__ip_vs_svc_lock);
+
+	/* Wait until all other svc users go away */
+	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 0);
+
+	if (add) {
+		list_add(&dest->n_list, &svc->destinations);
+		svc->num_dests++;
+	}
+
+	/* call the update_service, because server weight may be changed */
+	if (svc->scheduler->update_service)
+		svc->scheduler->update_service(svc);
+
+	write_unlock_bh(&__ip_vs_svc_lock);
 }
 
 
@@ -860,13 +884,12 @@ ip_vs_new_dest(struct ip_vs_service *svc
 	atomic_set(&dest->activeconns, 0);
 	atomic_set(&dest->inactconns, 0);
 	atomic_set(&dest->persistconns, 0);
-	atomic_set(&dest->refcnt, 0);
+	atomic_set(&dest->refcnt, 1);
 
 	INIT_LIST_HEAD(&dest->d_list);
 	spin_lock_init(&dest->dst_lock);
 	spin_lock_init(&dest->stats.lock);
-	__ip_vs_update_dest(svc, dest, udest);
-	ip_vs_new_estimator(&dest->stats);
+	__ip_vs_update_dest(svc, dest, udest, 1);
 
 	*dest_p = dest;
 
@@ -926,65 +949,22 @@ ip_vs_add_dest(struct ip_vs_service *svc
 			      IP_VS_DBG_ADDR(svc->af, &dest->vaddr),
 			      ntohs(dest->vport));
 
-		__ip_vs_update_dest(svc, dest, udest);
-
 		/*
 		 * Get the destination from the trash
 		 */
 		list_del(&dest->n_list);
 
-		ip_vs_new_estimator(&dest->stats);
-
-		write_lock_bh(&__ip_vs_svc_lock);
-
+		__ip_vs_update_dest(svc, dest, udest, 1);
+		ret = 0;
+	} else {
 		/*
-		 * Wait until all other svc users go away.
+		 * Allocate and initialize the dest structure
 		 */
-		IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 1);
-
-		list_add(&dest->n_list, &svc->destinations);
-		svc->num_dests++;
-
-		/* call the update_service function of its scheduler */
-		if (svc->scheduler->update_service)
-			svc->scheduler->update_service(svc);
-
-		write_unlock_bh(&__ip_vs_svc_lock);
-		return 0;
-	}
-
-	/*
-	 * Allocate and initialize the dest structure
-	 */
-	ret = ip_vs_new_dest(svc, udest, &dest);
-	if (ret) {
-		return ret;
+		ret = ip_vs_new_dest(svc, udest, &dest);
 	}
-
-	/*
-	 * Add the dest entry into the list
-	 */
-	atomic_inc(&dest->refcnt);
-
-	write_lock_bh(&__ip_vs_svc_lock);
-
-	/*
-	 * Wait until all other svc users go away.
-	 */
-	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 1);
-
-	list_add(&dest->n_list, &svc->destinations);
-	svc->num_dests++;
-
-	/* call the update_service function of its scheduler */
-	if (svc->scheduler->update_service)
-		svc->scheduler->update_service(svc);
-
-	write_unlock_bh(&__ip_vs_svc_lock);
-
 	LeaveFunction(2);
 
-	return 0;
+	return ret;
 }
 
 
@@ -1023,19 +1003,7 @@ ip_vs_edit_dest(struct ip_vs_service *sv
 		return -ENOENT;
 	}
 
-	__ip_vs_update_dest(svc, dest, udest);
-
-	write_lock_bh(&__ip_vs_svc_lock);
-
-	/* Wait until all other svc users go away */
-	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 1);
-
-	/* call the update_service, because server weight may be changed */
-	if (svc->scheduler->update_service)
-		svc->scheduler->update_service(svc);
-
-	write_unlock_bh(&__ip_vs_svc_lock);
-
+	__ip_vs_update_dest(svc, dest, udest, 0);
 	LeaveFunction(2);
 
 	return 0;
@@ -1062,6 +1030,10 @@ static void __ip_vs_del_dest(struct ip_v
 	 *  the destination into the trash.
 	 */
 	if (atomic_dec_and_test(&dest->refcnt)) {
+		IP_VS_DBG_BUF(3, "Removing destination %u/%s:%u\n",
+			      dest->vfwmark,
+			      IP_VS_DBG_ADDR(dest->af, &dest->addr),
+			      ntohs(dest->port));
 		ip_vs_dst_reset(dest);
 		/* simply decrease svc->refcnt here, let the caller check
 		   and release the service if nobody refers to it.
@@ -1128,7 +1100,7 @@ ip_vs_del_dest(struct ip_vs_service *svc
 	/*
 	 *	Wait until all other svc users go away.
 	 */
-	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 1);
+	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 0);
 
 	/*
 	 *	Unlink dest from the service
@@ -1185,7 +1157,7 @@ ip_vs_add_service(struct ip_vs_service_u
 	}
 
 	/* I'm the first user of the service */
-	atomic_set(&svc->usecnt, 1);
+	atomic_set(&svc->usecnt, 0);
 	atomic_set(&svc->refcnt, 0);
 
 	svc->af = u->af;
@@ -1279,7 +1251,7 @@ ip_vs_edit_service(struct ip_vs_service 
 	/*
 	 * Wait until all other svc users go away.
 	 */
-	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 1);
+	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 0);
 
 	/*
 	 * Set the flags and timeout value
@@ -1378,21 +1350,23 @@ static void __ip_vs_del_service(struct i
 	/*
 	 *    Free the service if nobody refers to it
 	 */
-	if (atomic_read(&svc->refcnt) == 0)
+	if (atomic_read(&svc->refcnt) == 0) {
+		IP_VS_DBG_BUF(3, "Removing service %u/%s:%u usecnt=%d\n",
+			      svc->fwmark,
+			      IP_VS_DBG_ADDR(svc->af, &svc->addr),
+			      ntohs(svc->port), atomic_read(&svc->usecnt));
 		kfree(svc);
+	}
 
 	/* decrease the module use count */
 	ip_vs_use_count_dec();
 }
 
 /*
- *	Delete a service from the service list
+ * Unlink a service from list and try to delete it if its refcnt reached 0
  */
-static int ip_vs_del_service(struct ip_vs_service *svc)
+static void ip_vs_unlink_service(struct ip_vs_service *svc)
 {
-	if (svc == NULL)
-		return -EEXIST;
-
 	/*
 	 * Unhash it from the service table
 	 */
@@ -1403,11 +1377,21 @@ static int ip_vs_del_service(struct ip_v
 	/*
 	 * Wait until all the svc users go away.
 	 */
-	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 1);
+	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 0);
 
 	__ip_vs_del_service(svc);
 
 	write_unlock_bh(&__ip_vs_svc_lock);
+}
+
+/*
+ *	Delete a service from the service list
+ */
+static int ip_vs_del_service(struct ip_vs_service *svc)
+{
+	if (svc == NULL)
+		return -EEXIST;
+	ip_vs_unlink_service(svc);
 
 	return 0;
 }
@@ -1426,14 +1410,7 @@ static int ip_vs_flush(void)
 	 */
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		list_for_each_entry_safe(svc, nxt, &ip_vs_svc_table[idx], s_list) {
-			write_lock_bh(&__ip_vs_svc_lock);
-			ip_vs_svc_unhash(svc);
-			/*
-			 * Wait until all the svc users go away.
-			 */
-			IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 0);
-			__ip_vs_del_service(svc);
-			write_unlock_bh(&__ip_vs_svc_lock);
+			ip_vs_unlink_service(svc);
 		}
 	}
 
@@ -1443,14 +1420,7 @@ static int ip_vs_flush(void)
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		list_for_each_entry_safe(svc, nxt,
 					 &ip_vs_svc_fwm_table[idx], f_list) {
-			write_lock_bh(&__ip_vs_svc_lock);
-			ip_vs_svc_unhash(svc);
-			/*
-			 * Wait until all the svc users go away.
-			 */
-			IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 0);
-			__ip_vs_del_service(svc);
-			write_unlock_bh(&__ip_vs_svc_lock);
+			ip_vs_unlink_service(svc);
 		}
 	}
 
@@ -2147,15 +2117,15 @@ do_ip_vs_set_ctl(struct sock *sk, int cm
 
 	/* Lookup the exact service by <protocol, addr, port> or fwmark */
 	if (usvc.fwmark == 0)
-		svc = __ip_vs_service_get(usvc.af, usvc.protocol,
-					  &usvc.addr, usvc.port);
+		svc = __ip_vs_service_find(usvc.af, usvc.protocol,
+					   &usvc.addr, usvc.port);
 	else
-		svc = __ip_vs_svc_fwm_get(usvc.af, usvc.fwmark);
+		svc = __ip_vs_svc_fwm_find(usvc.af, usvc.fwmark);
 
 	if (cmd != IP_VS_SO_SET_ADD
 	    && (svc == NULL || svc->protocol != usvc.protocol)) {
 		ret = -ESRCH;
-		goto out_drop_service;
+		goto out_unlock;
 	}
 
 	switch (cmd) {
@@ -2189,10 +2159,6 @@ do_ip_vs_set_ctl(struct sock *sk, int cm
 		ret = -EINVAL;
 	}
 
-out_drop_service:
-	if (svc)
-		ip_vs_service_put(svc);
-
   out_unlock:
 	mutex_unlock(&__ip_vs_mutex);
   out_dec:
@@ -2285,10 +2251,10 @@ __ip_vs_get_dest_entries(const struct ip
 	int ret = 0;
 
 	if (get->fwmark)
-		svc = __ip_vs_svc_fwm_get(AF_INET, get->fwmark);
+		svc = __ip_vs_svc_fwm_find(AF_INET, get->fwmark);
 	else
-		svc = __ip_vs_service_get(AF_INET, get->protocol, &addr,
-					  get->port);
+		svc = __ip_vs_service_find(AF_INET, get->protocol, &addr,
+					   get->port);
 
 	if (svc) {
 		int count = 0;
@@ -2316,7 +2282,6 @@ __ip_vs_get_dest_entries(const struct ip
 			}
 			count++;
 		}
-		ip_vs_service_put(svc);
 	} else
 		ret = -ESRCH;
 	return ret;
@@ -2437,15 +2402,14 @@ do_ip_vs_get_ctl(struct sock *sk, int cm
 		entry = (struct ip_vs_service_entry *)arg;
 		addr.ip = entry->addr;
 		if (entry->fwmark)
-			svc = __ip_vs_svc_fwm_get(AF_INET, entry->fwmark);
+			svc = __ip_vs_svc_fwm_find(AF_INET, entry->fwmark);
 		else
-			svc = __ip_vs_service_get(AF_INET, entry->protocol,
-						  &addr, entry->port);
+			svc = __ip_vs_service_find(AF_INET, entry->protocol,
+						   &addr, entry->port);
 		if (svc) {
 			ip_vs_copy_service(entry, svc);
 			if (copy_to_user(user, entry, sizeof(*entry)) != 0)
 				ret = -EFAULT;
-			ip_vs_service_put(svc);
 		} else
 			ret = -ESRCH;
 	}
@@ -2712,10 +2676,12 @@ nla_put_failure:
 }
 
 static int ip_vs_genl_parse_service(struct ip_vs_service_user_kern *usvc,
-				    struct nlattr *nla, int full_entry)
+				    struct nlattr *nla, int full_entry,
+				    struct ip_vs_service **ret_svc)
 {
 	struct nlattr *attrs[IPVS_SVC_ATTR_MAX + 1];
 	struct nlattr *nla_af, *nla_port, *nla_fwmark, *nla_protocol, *nla_addr;
+	struct ip_vs_service *svc;
 
 	/* Parse mandatory identifying service fields first */
 	if (nla == NULL ||
@@ -2751,12 +2717,18 @@ static int ip_vs_genl_parse_service(stru
 		usvc->fwmark = 0;
 	}
 
+	if (usvc->fwmark)
+		svc = __ip_vs_svc_fwm_find(usvc->af, usvc->fwmark);
+	else
+		svc = __ip_vs_service_find(usvc->af, usvc->protocol,
+					   &usvc->addr, usvc->port);
+	*ret_svc = svc;
+
 	/* If a full entry was requested, check for the additional fields */
 	if (full_entry) {
 		struct nlattr *nla_sched, *nla_flags, *nla_timeout,
 			      *nla_netmask;
 		struct ip_vs_flags flags;
-		struct ip_vs_service *svc;
 
 		nla_sched = attrs[IPVS_SVC_ATTR_SCHED_NAME];
 		nla_flags = attrs[IPVS_SVC_ATTR_FLAGS];
@@ -2769,16 +2741,8 @@ static int ip_vs_genl_parse_service(stru
 		nla_memcpy(&flags, nla_flags, sizeof(flags));
 
 		/* prefill flags from service if it already exists */
-		if (usvc->fwmark)
-			svc = __ip_vs_svc_fwm_get(usvc->af, usvc->fwmark);
-		else
-			svc = __ip_vs_service_get(usvc->af, usvc->protocol,
-						  &usvc->addr, usvc->port);
-		if (svc) {
+		if (svc)
 			usvc->flags = svc->flags;
-			ip_vs_service_put(svc);
-		} else
-			usvc->flags = 0;
 
 		/* set new flags from userland */
 		usvc->flags = (usvc->flags & ~flags.mask) |
@@ -2794,17 +2758,11 @@ static int ip_vs_genl_parse_service(stru
 static struct ip_vs_service *ip_vs_genl_find_service(struct nlattr *nla)
 {
 	struct ip_vs_service_user_kern usvc;
+	struct ip_vs_service *svc;
 	int ret;
 
-	ret = ip_vs_genl_parse_service(&usvc, nla, 0);
-	if (ret)
-		return ERR_PTR(ret);
-
-	if (usvc.fwmark)
-		return __ip_vs_svc_fwm_get(usvc.af, usvc.fwmark);
-	else
-		return __ip_vs_service_get(usvc.af, usvc.protocol,
-					   &usvc.addr, usvc.port);
+	ret = ip_vs_genl_parse_service(&usvc, nla, 0, &svc);
+	return ret ? ERR_PTR(ret) : svc;
 }
 
 static int ip_vs_genl_fill_dest(struct sk_buff *skb, struct ip_vs_dest *dest)
@@ -2895,7 +2853,6 @@ static int ip_vs_genl_dump_dests(struct 
 
 nla_put_failure:
 	cb->args[0] = idx;
-	ip_vs_service_put(svc);
 
 out_err:
 	mutex_unlock(&__ip_vs_mutex);
@@ -3108,17 +3065,10 @@ static int ip_vs_genl_set_cmd(struct sk_
 
 	ret = ip_vs_genl_parse_service(&usvc,
 				       info->attrs[IPVS_CMD_ATTR_SERVICE],
-				       need_full_svc);
+				       need_full_svc, &svc);
 	if (ret)
 		goto out;
 
-	/* Lookup the exact service by <protocol, addr, port> or fwmark */
-	if (usvc.fwmark == 0)
-		svc = __ip_vs_service_get(usvc.af, usvc.protocol,
-					  &usvc.addr, usvc.port);
-	else
-		svc = __ip_vs_svc_fwm_get(usvc.af, usvc.fwmark);
-
 	/* Unless we're adding a new service, the service must already exist */
 	if ((cmd != IPVS_CMD_NEW_SERVICE) && (svc == NULL)) {
 		ret = -ESRCH;
@@ -3152,6 +3102,7 @@ static int ip_vs_genl_set_cmd(struct sk_
 		break;
 	case IPVS_CMD_DEL_SERVICE:
 		ret = ip_vs_del_service(svc);
+		/* do not use svc, it can be freed */
 		break;
 	case IPVS_CMD_NEW_DEST:
 		ret = ip_vs_add_dest(svc, &udest);
@@ -3170,8 +3121,6 @@ static int ip_vs_genl_set_cmd(struct sk_
 	}
 
 out:
-	if (svc)
-		ip_vs_service_put(svc);
 	mutex_unlock(&__ip_vs_mutex);
 
 	return ret;
@@ -3217,7 +3166,6 @@ static int ip_vs_genl_get_cmd(struct sk_
 			goto out_err;
 		} else if (svc) {
 			ret = ip_vs_genl_fill_service(msg, svc);
-			ip_vs_service_put(svc);
 			if (ret)
 				goto nla_put_failure;
 		} else {
