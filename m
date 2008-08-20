From: Julius Volz <juliusv@google.com>
Subject: [PATCH RFC 23/24] IPVS: Small address/af usage fixups
Date: Wed, 20 Aug 2008 18:15:30 +0200
Message-ID: <1219248931-15064-24-git-send-email-juliusv@google.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219248945; bh=shn0sfwZ8vkHKfASX4NXnysrsH4=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=gY/uJcrBM/AQI5G4Qm98ucJzIsgjKJoohB9UcoNQ
	31u/1PxT/ODmxVUbQ+sUHvWt29oWg08FLHIen7lup3D1kA==
In-Reply-To: <1219248931-15064-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Where this has not already been covered by other patches, fix up the code
to work with the new data structures and 'af' parameters.

Signed-off-by: Julius Volz <juliusv@google.com>

 4 files changed, 158 insertions(+), 97 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
index f0b848d..011d455 100644
--- a/net/ipv4/ipvs/ip_vs_conn.c
+++ b/net/ipv4/ipvs/ip_vs_conn.c
@@ -489,8 +489,9 @@ struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp)
 	struct ip_vs_dest *dest;
 
 	if ((cp) && (!cp->dest)) {
-		dest = ip_vs_find_dest(cp->daddr, cp->dport,
-				       cp->vaddr, cp->vport, cp->protocol);
+		dest = ip_vs_find_dest(cp->af, &cp->daddr, cp->dport,
+				       &cp->vaddr, cp->vport,
+				       cp->protocol);
 		ip_vs_bind_dest(cp, dest);
 		return dest;
 	} else
diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index f2caf56..ba4d7c2 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -759,7 +759,7 @@ ip_vs_zero_stats(struct ip_vs_stats *stats)
  */
 static void
 __ip_vs_update_dest(struct ip_vs_service *svc,
-		    struct ip_vs_dest *dest, struct ip_vs_dest_user *udest)
+		    struct ip_vs_dest *dest, struct ip_vs_dest_user_kern *udest)
 {
 	int conn_flags;
 
@@ -820,7 +820,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc,
  *	Create a destination for the given service
  */
 static int
-ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest,
+ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 	       struct ip_vs_dest **dest_p)
 {
 	struct ip_vs_dest *dest;
@@ -848,11 +848,12 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest,
 		return -ENOMEM;
 	}
 
+	dest->af = svc->af;
 	dest->protocol = svc->protocol;
 	dest->vaddr = svc->addr;
 	dest->vport = svc->port;
 	dest->vfwmark = svc->fwmark;
-	dest->addr = udest->addr;
+	ip_vs_addr_copy(svc->af, &dest->addr, &udest->addr);
 	dest->port = udest->port;
 
 	atomic_set(&dest->activeconns, 0);
@@ -877,10 +878,10 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest,
  *	Add a destination into an existing service
  */
 static int
-ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
+ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 {
 	struct ip_vs_dest *dest;
-	__be32 daddr = udest->addr;
+	union nf_inet_addr daddr;
 	__be16 dport = udest->port;
 	int ret;
 
@@ -897,10 +898,13 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
 		return -ERANGE;
 	}
 
+	ip_vs_addr_copy(svc->af, &daddr, &udest->addr);
+
 	/*
 	 * Check if the dest already exists in the list
 	 */
-	dest = ip_vs_lookup_dest(svc, daddr, dport);
+	dest = ip_vs_lookup_dest(svc, &daddr, dport);
+
 	if (dest != NULL) {
 		IP_VS_DBG(1, "ip_vs_add_dest(): dest already exists\n");
 		return -EEXIST;
@@ -910,7 +914,7 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
 	 * Check if the dest already exists in the trash and
 	 * is from the same service
 	 */
-	dest = ip_vs_trash_get_dest(svc, daddr, dport);
+	dest = ip_vs_trash_get_dest(svc, &daddr, dport);
 
 	if (dest != NULL) {
 		IP_VS_DBG_BUF(3, "Get destination %s:%u from trash, "
@@ -985,10 +989,10 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
  *	Edit a destination in the given service
  */
 static int
-ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
+ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 {
 	struct ip_vs_dest *dest;
-	__be32 daddr = udest->addr;
+	union nf_inet_addr daddr;
 	__be16 dport = udest->port;
 
 	EnterFunction(2);
@@ -1004,10 +1008,13 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
 		return -ERANGE;
 	}
 
+	ip_vs_addr_copy(svc->af, &daddr, &udest->addr);
+
 	/*
 	 *  Lookup the destination list
 	 */
-	dest = ip_vs_lookup_dest(svc, daddr, dport);
+	dest = ip_vs_lookup_dest(svc, &daddr, dport);
+
 	if (dest == NULL) {
 		IP_VS_DBG(1, "ip_vs_edit_dest(): dest doesn't exist\n");
 		return -ENOENT;
@@ -1099,15 +1106,15 @@ static void __ip_vs_unlink_dest(struct ip_vs_service *svc,
  *	Delete a destination server in the given service
  */
 static int
-ip_vs_del_dest(struct ip_vs_service *svc,struct ip_vs_dest_user *udest)
+ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 {
 	struct ip_vs_dest *dest;
-	__be32 daddr = udest->addr;
 	__be16 dport = udest->port;
 
 	EnterFunction(2);
 
-	dest = ip_vs_lookup_dest(svc, daddr, dport);
+	dest = ip_vs_lookup_dest(svc, &udest->addr, dport);
+
 	if (dest == NULL) {
 		IP_VS_DBG(1, "ip_vs_del_dest(): destination not found!\n");
 		return -ENOENT;
@@ -1142,7 +1149,8 @@ ip_vs_del_dest(struct ip_vs_service *svc,struct ip_vs_dest_user *udest)
  *	Add a service into the service hash table
  */
 static int
-ip_vs_add_service(struct ip_vs_service_user *u, struct ip_vs_service **svc_p)
+ip_vs_add_service(struct ip_vs_service_user_kern *u,
+		  struct ip_vs_service **svc_p)
 {
 	int ret = 0;
 	struct ip_vs_scheduler *sched = NULL;
@@ -1184,8 +1192,9 @@ ip_vs_add_service(struct ip_vs_service_user *u, struct ip_vs_service **svc_p)
 	atomic_set(&svc->usecnt, 1);
 	atomic_set(&svc->refcnt, 0);
 
+	svc->af = u->af;
 	svc->protocol = u->protocol;
-	svc->addr = u->addr;
+	ip_vs_addr_copy(svc->af, &svc->addr, &u->addr);
 	svc->port = u->port;
 	svc->fwmark = u->fwmark;
 	svc->flags = u->flags;
@@ -1247,7 +1256,7 @@ ip_vs_add_service(struct ip_vs_service_user *u, struct ip_vs_service **svc_p)
  *	Edit a service and bind it with a new scheduler
  */
 static int
-ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user *u)
+ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 {
 	struct ip_vs_scheduler *sched, *old_sched;
 	int ret = 0;
@@ -2030,14 +2039,44 @@ static const unsigned char set_arglen[SET_CMDID(IP_VS_SO_SET_MAX)+1] = {
 	[SET_CMDID(IP_VS_SO_SET_ZERO)]		= SERVICE_ARG_LEN,
 };
 
+static void ip_vs_copy_usvc_compat(struct ip_vs_service_user_kern *usvc,
+				  struct ip_vs_service_user *usvc_compat)
+{
+	usvc->af		= AF_INET;
+	usvc->protocol		= usvc_compat->protocol;
+	usvc->addr.ip		= usvc_compat->addr;
+	usvc->port		= usvc_compat->port;
+	usvc->fwmark		= usvc_compat->fwmark;
+
+	/* Deep copy of sched_name is not needed here */
+	usvc->sched_name	= usvc_compat->sched_name;
+
+	usvc->flags		= usvc_compat->flags;
+	usvc->timeout		= usvc_compat->timeout;
+	usvc->netmask		= usvc_compat->netmask;
+}
+
+static void ip_vs_copy_udest_compat(struct ip_vs_dest_user_kern *udest,
+				   struct ip_vs_dest_user *udest_compat)
+{
+	udest->addr.ip		= udest_compat->addr;
+	udest->port		= udest_compat->port;
+	udest->conn_flags	= udest_compat->conn_flags;
+	udest->weight		= udest_compat->weight;
+	udest->u_threshold	= udest_compat->u_threshold;
+	udest->l_threshold	= udest_compat->l_threshold;
+}
+
 static int
 do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 {
 	int ret;
 	unsigned char arg[MAX_ARG_LEN];
-	struct ip_vs_service_user *usvc;
+	struct ip_vs_service_user *usvc_compat;
+	struct ip_vs_service_user_kern usvc;
 	struct ip_vs_service *svc;
-	struct ip_vs_dest_user *udest;
+	struct ip_vs_dest_user *udest_compat;
+	struct ip_vs_dest_user_kern udest;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -2077,35 +2116,41 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		goto out_unlock;
 	}
 
-	usvc = (struct ip_vs_service_user *)arg;
-	udest = (struct ip_vs_dest_user *)(usvc + 1);
+	usvc_compat = (struct ip_vs_service_user *)arg;
+	udest_compat = (struct ip_vs_dest_user *)(usvc_compat + 1);
+
+	/* We only use the new structs internally, so copy userspace compat
+	 * structs to extended internal versions */
+	ip_vs_copy_usvc_compat(&usvc, usvc_compat);
+	ip_vs_copy_udest_compat(&udest, udest_compat);
 
 	if (cmd == IP_VS_SO_SET_ZERO) {
 		/* if no service address is set, zero counters in all */
-		if (!usvc->fwmark && !usvc->addr && !usvc->port) {
+		if (!usvc.fwmark && !usvc.addr.ip && !usvc.port) {
 			ret = ip_vs_zero_all();
 			goto out_unlock;
 		}
 	}
 
 	/* Check for valid protocol: TCP or UDP, even for fwmark!=0 */
-	if (usvc->protocol!=IPPROTO_TCP && usvc->protocol!=IPPROTO_UDP) {
+	if (usvc.protocol != IPPROTO_TCP && usvc.protocol != IPPROTO_UDP) {
 		IP_VS_ERR("set_ctl: invalid protocol: %d %d.%d.%d.%d:%d %s\n",
-			  usvc->protocol, NIPQUAD(usvc->addr),
-			  ntohs(usvc->port), usvc->sched_name);
+			  usvc.protocol, NIPQUAD(usvc.addr.ip),
+			  ntohs(usvc.port), usvc.sched_name);
+
 		ret = -EFAULT;
 		goto out_unlock;
 	}
 
 	/* Lookup the exact service by <protocol, addr, port> or fwmark */
-	if (usvc->fwmark == 0)
-		svc = __ip_vs_service_get(usvc->protocol,
-					  usvc->addr, usvc->port);
+	if (usvc.fwmark == 0)
+		svc = __ip_vs_service_get(usvc.af, usvc.protocol,
+					  &usvc.addr, usvc.port);
 	else
-		svc = __ip_vs_svc_fwm_get(usvc->fwmark);
+		svc = __ip_vs_svc_fwm_get(usvc.af, usvc.fwmark);
 
 	if (cmd != IP_VS_SO_SET_ADD
-	    && (svc == NULL || svc->protocol != usvc->protocol)) {
+	    && (svc == NULL || svc->protocol != usvc.protocol)) {
 		ret = -ESRCH;
 		goto out_unlock;
 	}
@@ -2115,10 +2160,10 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		if (svc != NULL)
 			ret = -EEXIST;
 		else
-			ret = ip_vs_add_service(usvc, &svc);
+			ret = ip_vs_add_service(&usvc, &svc);
 		break;
 	case IP_VS_SO_SET_EDIT:
-		ret = ip_vs_edit_service(svc, usvc);
+		ret = ip_vs_edit_service(svc, &usvc);
 		break;
 	case IP_VS_SO_SET_DEL:
 		ret = ip_vs_del_service(svc);
@@ -2129,13 +2174,13 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		ret = ip_vs_zero_service(svc);
 		break;
 	case IP_VS_SO_SET_ADDDEST:
-		ret = ip_vs_add_dest(svc, udest);
+		ret = ip_vs_add_dest(svc, &udest);
 		break;
 	case IP_VS_SO_SET_EDITDEST:
-		ret = ip_vs_edit_dest(svc, udest);
+		ret = ip_vs_edit_dest(svc, &udest);
 		break;
 	case IP_VS_SO_SET_DELDEST:
-		ret = ip_vs_del_dest(svc, udest);
+		ret = ip_vs_del_dest(svc, &udest);
 		break;
 	default:
 		ret = -EINVAL;
@@ -2166,7 +2211,7 @@ static void
 ip_vs_copy_service(struct ip_vs_service_entry *dst, struct ip_vs_service *src)
 {
 	dst->protocol = src->protocol;
-	dst->addr = src->addr;
+	dst->addr = src->addr.ip;
 	dst->port = src->port;
 	dst->fwmark = src->fwmark;
 	strlcpy(dst->sched_name, src->scheduler->name, sizeof(dst->sched_name));
@@ -2233,13 +2278,15 @@ __ip_vs_get_dest_entries(const struct ip_vs_get_dests *get,
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
@@ -2249,7 +2296,7 @@ __ip_vs_get_dest_entries(const struct ip_vs_get_dests *get,
 			if (count >= get->num_dests)
 				break;
 
-			entry.addr = dest->addr;
+			entry.addr = dest->addr.ip;
 			entry.port = dest->port;
 			entry.conn_flags = atomic_read(&dest->conn_flags);
 			entry.weight = atomic_read(&dest->weight);
@@ -2374,13 +2421,17 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
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
+						  &addr,
+						  entry->port);
+
 		if (svc) {
 			ip_vs_copy_service(entry, svc);
 			if (copy_to_user(user, entry, sizeof(*entry)) != 0)
@@ -2651,7 +2702,7 @@ nla_put_failure:
 	return skb->len;
 }
 
-static int ip_vs_genl_parse_service(struct ip_vs_service_user *usvc,
+static int ip_vs_genl_parse_service(struct ip_vs_service_user_kern *usvc,
 				    struct nlattr *nla, int full_entry)
 {
 	struct nlattr *attrs[IPVS_SVC_ATTR_MAX + 1];
@@ -2708,10 +2759,10 @@ static int ip_vs_genl_parse_service(struct ip_vs_service_user *usvc,
 
 		/* prefill flags from service if it already exists */
 		if (usvc->fwmark)
-			svc = __ip_vs_svc_fwm_get(usvc->fwmark);
+			svc = __ip_vs_svc_fwm_get(usvc->af, usvc->fwmark);
 		else
-			svc = __ip_vs_service_get(usvc->protocol, usvc->addr,
-						  usvc->port);
+			svc = __ip_vs_service_get(usvc->af, usvc->protocol,
+						  &usvc->addr, usvc->port);
 		if (svc) {
 			usvc->flags = svc->flags;
 			ip_vs_service_put(svc);
@@ -2721,9 +2772,7 @@ static int ip_vs_genl_parse_service(struct ip_vs_service_user *usvc,
 		/* set new flags from userland */
 		usvc->flags = (usvc->flags & ~flags.mask) |
 			      (flags.flags & flags.mask);
-
-		strlcpy(usvc->sched_name, nla_data(nla_sched),
-			sizeof(usvc->sched_name));
+		usvc->sched_name = nla_data(nla_sched);
 		usvc->timeout = nla_get_u32(nla_timeout);
 		usvc->netmask = nla_get_u32(nla_netmask);
 	}
@@ -2733,7 +2782,7 @@ static int ip_vs_genl_parse_service(struct ip_vs_service_user *usvc,
 
 static struct ip_vs_service *ip_vs_genl_find_service(struct nlattr *nla)
 {
-	struct ip_vs_service_user usvc;
+	struct ip_vs_service_user_kern usvc;
 	int ret;
 
 	ret = ip_vs_genl_parse_service(&usvc, nla, 0);
@@ -2741,10 +2790,10 @@ static struct ip_vs_service *ip_vs_genl_find_service(struct nlattr *nla)
 		return ERR_PTR(ret);
 
 	if (usvc.fwmark)
-		return __ip_vs_svc_fwm_get(usvc.fwmark);
+		return __ip_vs_svc_fwm_get(usvc.af, usvc.fwmark);
 	else
-		return __ip_vs_service_get(usvc.protocol, usvc.addr,
-					   usvc.port);
+		return __ip_vs_service_get(usvc.af, usvc.protocol,
+					   &usvc.addr, usvc.port);
 }
 
 static int ip_vs_genl_fill_dest(struct sk_buff *skb, struct ip_vs_dest *dest)
@@ -2843,7 +2892,7 @@ out_err:
 	return skb->len;
 }
 
-static int ip_vs_genl_parse_dest(struct ip_vs_dest_user *udest,
+static int ip_vs_genl_parse_dest(struct ip_vs_dest_user_kern *udest,
 				 struct nlattr *nla, int full_entry)
 {
 	struct nlattr *attrs[IPVS_DEST_ATTR_MAX + 1];
@@ -2999,8 +3048,8 @@ static int ip_vs_genl_set_config(struct nlattr **attrs)
 static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 {
 	struct ip_vs_service *svc = NULL;
-	struct ip_vs_service_user usvc;
-	struct ip_vs_dest_user udest;
+	struct ip_vs_service_user_kern usvc;
+	struct ip_vs_dest_user_kern udest;
 	int ret = 0, cmd;
 	int need_full_svc = 0, need_full_dest = 0;
 
@@ -3052,9 +3101,10 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 
 	/* Lookup the exact service by <protocol, addr, port> or fwmark */
 	if (usvc.fwmark == 0)
-		svc = __ip_vs_service_get(usvc.protocol, usvc.addr, usvc.port);
+		svc = __ip_vs_service_get(usvc.af, usvc.protocol,
+					  &usvc.addr, usvc.port);
 	else
-		svc = __ip_vs_svc_fwm_get(usvc.fwmark);
+		svc = __ip_vs_svc_fwm_get(usvc.af, usvc.fwmark);
 
 	/* Unless we're adding a new service, the service must already exist */
 	if ((cmd != IPVS_CMD_NEW_SERVICE) && (svc == NULL)) {
diff --git a/net/ipv4/ipvs/ip_vs_ftp.c b/net/ipv4/ipvs/ip_vs_ftp.c
index b4c7491..2abc34a 100644
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
@@ -174,24 +174,24 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		if (ip_vs_ftp_get_addrport(data, data_limit,
 					   SERVER_STRING,
 					   sizeof(SERVER_STRING)-1, ')',
-					   &from, &port,
+					   &from.ip, &port,
 					   &start, &end) != 1)
 			return 1;
 
 		IP_VS_DBG(7, "PASV response (%u.%u.%u.%u:%d) -> "
 			  "%u.%u.%u.%u:%d detected\n",
-			  NIPQUAD(from), ntohs(port), NIPQUAD(cp->caddr), 0);
+			  NIPQUAD(from.ip), ntohs(port), NIPQUAD(cp->caddr.ip), 0);
 
 		/*
 		 * Now update or create an connection entry for it
 		 */
-		n_cp = ip_vs_conn_out_get(iph->protocol, from, port,
-					  cp->caddr, 0);
+		n_cp = ip_vs_conn_out_get(AF_INET, iph->protocol, &from, port,
+					  &cp->caddr, 0);
 		if (!n_cp) {
-			n_cp = ip_vs_conn_new(IPPROTO_TCP,
-					      cp->caddr, 0,
-					      cp->vaddr, port,
-					      from, port,
+			n_cp = ip_vs_conn_new(AF_INET, IPPROTO_TCP,
+					      &cp->caddr, 0,
+					      &cp->vaddr, port,
+					      &from, port,
 					      IP_VS_CONN_F_NO_CPORT,
 					      cp->dest);
 			if (!n_cp)
@@ -204,9 +204,9 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		/*
 		 * Replace the old passive address with the new one
 		 */
-		from = n_cp->vaddr;
+		from.ip = n_cp->vaddr.ip;
 		port = n_cp->vport;
-		sprintf(buf,"%d,%d,%d,%d,%d,%d", NIPQUAD(from),
+		sprintf(buf,"%d,%d,%d,%d,%d,%d", NIPQUAD(from.ip),
 			(ntohs(port)>>8)&255, ntohs(port)&255);
 		buf_len = strlen(buf);
 
@@ -251,7 +251,7 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	struct tcphdr *th;
 	char *data, *data_start, *data_limit;
 	char *start, *end;
-	__be32 to;
+	union nf_inet_addr to;
 	__be16 port;
 	struct ip_vs_conn *n_cp;
 
@@ -307,12 +307,12 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
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
@@ -322,16 +322,16 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	 */
 	IP_VS_DBG(7, "protocol %s %u.%u.%u.%u:%d %u.%u.%u.%u:%d\n",
 		  ip_vs_proto_name(iph->protocol),
-		  NIPQUAD(to), ntohs(port), NIPQUAD(cp->vaddr), 0);
+		  NIPQUAD(to.ip), ntohs(port), NIPQUAD(cp->vaddr.ip), 0);
 
-	n_cp = ip_vs_conn_in_get(iph->protocol,
-				 to, port,
-				 cp->vaddr, htons(ntohs(cp->vport)-1));
+	n_cp = ip_vs_conn_in_get(AF_INET, iph->protocol,
+				 &to, port,
+				 &cp->vaddr, htons(ntohs(cp->vport)-1));
 	if (!n_cp) {
-		n_cp = ip_vs_conn_new(IPPROTO_TCP,
-				      to, port,
-				      cp->vaddr, htons(ntohs(cp->vport)-1),
-				      cp->daddr, htons(ntohs(cp->dport)-1),
+		n_cp = ip_vs_conn_new(AF_INET, IPPROTO_TCP,
+				      &to, port,
+				      &cp->vaddr, htons(ntohs(cp->vport)-1),
+				      &cp->daddr, htons(ntohs(cp->dport)-1),
 				      0,
 				      cp->dest);
 		if (!n_cp)
diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
index a652da2..40647ed 100644
--- a/net/ipv4/ipvs/ip_vs_sync.c
+++ b/net/ipv4/ipvs/ip_vs_sync.c
@@ -256,9 +256,9 @@ void ip_vs_sync_conn(struct ip_vs_conn *cp)
 	s->cport = cp->cport;
 	s->vport = cp->vport;
 	s->dport = cp->dport;
-	s->caddr = cp->caddr;
-	s->vaddr = cp->vaddr;
-	s->daddr = cp->daddr;
+	s->caddr = cp->caddr.ip;
+	s->vaddr = cp->vaddr.ip;
+	s->daddr = cp->daddr.ip;
 	s->flags = htons(cp->flags & ~IP_VS_CONN_F_HASHED);
 	s->state = htons(cp->state);
 	if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
@@ -366,21 +366,28 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
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
@@ -389,10 +396,13 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
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

