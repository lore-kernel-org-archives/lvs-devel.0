From: Julius Volz <juliusv@google.com>
Subject: [PATCHv3 05/24] IPVS: Add internal versions of sockopt interface structs
Date: Tue,  2 Sep 2008 15:55:36 +0200
Message-ID: <1220363755-9854-6-git-send-email-juliusv@google.com>
References: <1220363755-9854-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220363766; bh=wj9RX7axCXerkKjqafql/Bqiju8=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=UYdKjKC/x+pCzsBwCH3x7SBmSKMAjaVWJw2Tm1ua
	XhEYTBdgrLbQDl5MV1zdmF4x+jkoClCKw1nkcyBdUgfJWQ==
In-Reply-To: <1220363755-9854-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Add extended internal versions of struct ip_vs_service_user and struct
ip_vs_dest_user (the originals can't be modified as they are part
of the old sockopt interface). Adjust ip_vs_ctl.c to work with the new
data structures and add some minor AF-awareness.

Signed-off-by: Julius Volz <juliusv@google.com>

 2 files changed, 129 insertions(+), 48 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 0400e59..1adf8a0 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -400,6 +400,45 @@ struct ip_vs_conn {
 
 
 /*
+ *	Extended internal versions of struct ip_vs_service_user and
+ *	ip_vs_dest_user for IPv6 support.
+ *
+ *	We need these to conveniently pass around service and destination
+ *	options, but unfortunately, we also need to keep the old definitions to
+ *	maintain userspace backwards compatibility for the setsockopt interface.
+ */
+struct ip_vs_service_user_kern {
+	/* virtual service addresses */
+	u16			af;
+	u16			protocol;
+	union nf_inet_addr	addr;		/* virtual ip address */
+	u16			port;
+	u32			fwmark;		/* firwall mark of service */
+
+	/* virtual service options */
+	char			*sched_name;
+	unsigned		flags;		/* virtual service flags */
+	unsigned		timeout;	/* persistent timeout in sec */
+	u32			netmask;	/* persistent netmask */
+};
+
+
+struct ip_vs_dest_user_kern {
+	/* destination server address */
+	union nf_inet_addr	addr;
+	u16			port;
+
+	/* real server options */
+	unsigned		conn_flags;	/* connection flags */
+	int			weight;		/* destination weight */
+
+	/* thresholds for active connections */
+	u32			u_threshold;	/* upper threshold */
+	u32			l_threshold;	/* lower threshold */
+};
+
+
+/*
  *	The information about the virtual service offered to the net
  *	and the forwarding entries
  */
diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index 3f2277b..a0c8b7b 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -708,7 +708,7 @@ ip_vs_zero_stats(struct ip_vs_stats *stats)
  */
 static void
 __ip_vs_update_dest(struct ip_vs_service *svc,
-		    struct ip_vs_dest *dest, struct ip_vs_dest_user *udest)
+		    struct ip_vs_dest *dest, struct ip_vs_dest_user_kern *udest)
 {
 	int conn_flags;
 
@@ -717,7 +717,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc,
 	conn_flags = udest->conn_flags | IP_VS_CONN_F_INACTIVE;
 
 	/* check if local node and update the flags */
-	if (inet_addr_type(&init_net, udest->addr) == RTN_LOCAL) {
+	if (inet_addr_type(&init_net, udest->addr.ip) == RTN_LOCAL) {
 		conn_flags = (conn_flags & ~IP_VS_CONN_F_FWD_MASK)
 			| IP_VS_CONN_F_LOCALNODE;
 	}
@@ -761,7 +761,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc,
  *	Create a destination for the given service
  */
 static int
-ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest,
+ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 	       struct ip_vs_dest **dest_p)
 {
 	struct ip_vs_dest *dest;
@@ -769,7 +769,7 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest,
 
 	EnterFunction(2);
 
-	atype = inet_addr_type(&init_net, udest->addr);
+	atype = inet_addr_type(&init_net, udest->addr.ip);
 	if (atype != RTN_LOCAL && atype != RTN_UNICAST)
 		return -EINVAL;
 
@@ -779,11 +779,12 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest,
 		return -ENOMEM;
 	}
 
+	dest->af = svc->af;
 	dest->protocol = svc->protocol;
-	dest->vaddr.ip = svc->addr.ip;
+	dest->vaddr = svc->addr;
 	dest->vport = svc->port;
 	dest->vfwmark = svc->fwmark;
-	dest->addr.ip = udest->addr;
+	ip_vs_addr_copy(svc->af, &dest->addr, &udest->addr);
 	dest->port = udest->port;
 
 	atomic_set(&dest->activeconns, 0);
@@ -808,10 +809,10 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest,
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
 
@@ -828,10 +829,12 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
 		return -ERANGE;
 	}
 
+	ip_vs_addr_copy(svc->af, &daddr, &udest->addr);
+
 	/*
 	 * Check if the dest already exists in the list
 	 */
-	dest = ip_vs_lookup_dest(svc, daddr, dport);
+	dest = ip_vs_lookup_dest(svc, daddr.ip, dport);
 	if (dest != NULL) {
 		IP_VS_DBG(1, "ip_vs_add_dest(): dest already exists\n");
 		return -EEXIST;
@@ -841,7 +844,7 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
 	 * Check if the dest already exists in the trash and
 	 * is from the same service
 	 */
-	dest = ip_vs_trash_get_dest(svc, daddr, dport);
+	dest = ip_vs_trash_get_dest(svc, daddr.ip, dport);
 	if (dest != NULL) {
 		IP_VS_DBG(3, "Get destination %u.%u.%u.%u:%u from trash, "
 			  "dest->refcnt=%d, service %u/%u.%u.%u.%u:%u\n",
@@ -916,10 +919,10 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
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
@@ -935,10 +938,12 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
 		return -ERANGE;
 	}
 
+	ip_vs_addr_copy(svc->af, &daddr, &udest->addr);
+
 	/*
 	 *  Lookup the destination list
 	 */
-	dest = ip_vs_lookup_dest(svc, daddr, dport);
+	dest = ip_vs_lookup_dest(svc, daddr.ip, dport);
 	if (dest == NULL) {
 		IP_VS_DBG(1, "ip_vs_edit_dest(): dest doesn't exist\n");
 		return -ENOENT;
@@ -1029,15 +1034,15 @@ static void __ip_vs_unlink_dest(struct ip_vs_service *svc,
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
+	dest = ip_vs_lookup_dest(svc, udest->addr.ip, dport);
+
 	if (dest == NULL) {
 		IP_VS_DBG(1, "ip_vs_del_dest(): destination not found!\n");
 		return -ENOENT;
@@ -1072,7 +1077,8 @@ ip_vs_del_dest(struct ip_vs_service *svc,struct ip_vs_dest_user *udest)
  *	Add a service into the service hash table
  */
 static int
-ip_vs_add_service(struct ip_vs_service_user *u, struct ip_vs_service **svc_p)
+ip_vs_add_service(struct ip_vs_service_user_kern *u,
+		  struct ip_vs_service **svc_p)
 {
 	int ret = 0;
 	struct ip_vs_scheduler *sched = NULL;
@@ -1101,8 +1107,9 @@ ip_vs_add_service(struct ip_vs_service_user *u, struct ip_vs_service **svc_p)
 	atomic_set(&svc->usecnt, 1);
 	atomic_set(&svc->refcnt, 0);
 
+	svc->af = u->af;
 	svc->protocol = u->protocol;
-	svc->addr.ip = u->addr;
+	ip_vs_addr_copy(svc->af, &svc->addr, &u->addr);
 	svc->port = u->port;
 	svc->fwmark = u->fwmark;
 	svc->flags = u->flags;
@@ -1161,7 +1168,7 @@ ip_vs_add_service(struct ip_vs_service_user *u, struct ip_vs_service **svc_p)
  *	Edit a service and bind it with a new scheduler
  */
 static int
-ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user *u)
+ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 {
 	struct ip_vs_scheduler *sched, *old_sched;
 	int ret = 0;
@@ -1905,14 +1912,44 @@ static const unsigned char set_arglen[SET_CMDID(IP_VS_SO_SET_MAX)+1] = {
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
@@ -1952,35 +1989,40 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
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
 		ret = -EFAULT;
 		goto out_unlock;
 	}
 
 	/* Lookup the exact service by <protocol, addr, port> or fwmark */
-	if (usvc->fwmark == 0)
-		svc = __ip_vs_service_get(usvc->protocol,
-					  usvc->addr, usvc->port);
+	if (usvc.fwmark == 0)
+		svc = __ip_vs_service_get(usvc.protocol,
+					  usvc.addr.ip, usvc.port);
 	else
-		svc = __ip_vs_svc_fwm_get(usvc->fwmark);
+		svc = __ip_vs_svc_fwm_get(usvc.fwmark);
 
 	if (cmd != IP_VS_SO_SET_ADD
-	    && (svc == NULL || svc->protocol != usvc->protocol)) {
+	    && (svc == NULL || svc->protocol != usvc.protocol)) {
 		ret = -ESRCH;
 		goto out_unlock;
 	}
@@ -1990,10 +2032,10 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
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
@@ -2004,13 +2046,13 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
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
@@ -2517,7 +2559,7 @@ nla_put_failure:
 	return skb->len;
 }
 
-static int ip_vs_genl_parse_service(struct ip_vs_service_user *usvc,
+static int ip_vs_genl_parse_service(struct ip_vs_service_user_kern *usvc,
 				    struct nlattr *nla, int full_entry)
 {
 	struct nlattr *attrs[IPVS_SVC_ATTR_MAX + 1];
@@ -2537,6 +2579,7 @@ static int ip_vs_genl_parse_service(struct ip_vs_service_user *usvc,
 	if (!(nla_af && (nla_fwmark || (nla_port && nla_protocol && nla_addr))))
 		return -EINVAL;
 
+	usvc->af = nla_get_u16(nla_af);
 	/* For now, only support IPv4 */
 	if (nla_get_u16(nla_af) != AF_INET)
 		return -EAFNOSUPPORT;
@@ -2572,7 +2615,7 @@ static int ip_vs_genl_parse_service(struct ip_vs_service_user *usvc,
 		if (usvc->fwmark)
 			svc = __ip_vs_svc_fwm_get(usvc->fwmark);
 		else
-			svc = __ip_vs_service_get(usvc->protocol, usvc->addr,
+			svc = __ip_vs_service_get(usvc->protocol, usvc->addr.ip,
 						  usvc->port);
 		if (svc) {
 			usvc->flags = svc->flags;
@@ -2583,9 +2626,7 @@ static int ip_vs_genl_parse_service(struct ip_vs_service_user *usvc,
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
@@ -2595,7 +2636,7 @@ static int ip_vs_genl_parse_service(struct ip_vs_service_user *usvc,
 
 static struct ip_vs_service *ip_vs_genl_find_service(struct nlattr *nla)
 {
-	struct ip_vs_service_user usvc;
+	struct ip_vs_service_user_kern usvc;
 	int ret;
 
 	ret = ip_vs_genl_parse_service(&usvc, nla, 0);
@@ -2605,7 +2646,7 @@ static struct ip_vs_service *ip_vs_genl_find_service(struct nlattr *nla)
 	if (usvc.fwmark)
 		return __ip_vs_svc_fwm_get(usvc.fwmark);
 	else
-		return __ip_vs_service_get(usvc.protocol, usvc.addr,
+		return __ip_vs_service_get(usvc.protocol, usvc.addr.ip,
 					   usvc.port);
 }
 
@@ -2705,7 +2746,7 @@ out_err:
 	return skb->len;
 }
 
-static int ip_vs_genl_parse_dest(struct ip_vs_dest_user *udest,
+static int ip_vs_genl_parse_dest(struct ip_vs_dest_user_kern *udest,
 				 struct nlattr *nla, int full_entry)
 {
 	struct nlattr *attrs[IPVS_DEST_ATTR_MAX + 1];
@@ -2861,8 +2902,8 @@ static int ip_vs_genl_set_config(struct nlattr **attrs)
 static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 {
 	struct ip_vs_service *svc = NULL;
-	struct ip_vs_service_user usvc;
-	struct ip_vs_dest_user udest;
+	struct ip_vs_service_user_kern usvc;
+	struct ip_vs_dest_user_kern udest;
 	int ret = 0, cmd;
 	int need_full_svc = 0, need_full_dest = 0;
 
@@ -2914,7 +2955,8 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 
 	/* Lookup the exact service by <protocol, addr, port> or fwmark */
 	if (usvc.fwmark == 0)
-		svc = __ip_vs_service_get(usvc.protocol, usvc.addr, usvc.port);
+		svc = __ip_vs_service_get(usvc.protocol, usvc.addr.ip,
+					  usvc.port);
 	else
 		svc = __ip_vs_svc_fwm_get(usvc.fwmark);
 
-- 
1.5.4.5

