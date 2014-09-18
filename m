From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 02/15] ipvs: Add destination address family to netlink interface
Date: Thu, 18 Sep 2014 09:25:48 +0900
Message-ID: <1410999961-7975-3-git-send-email-horms@verge.net.au>
References: <1410999961-7975-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1410999961-7975-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Alex Gartrell <agartrell@fb.com>, Simon Horman <horms@verge.net.au>

From: Alex Gartrell <agartrell@fb.com>

This is necessary to support heterogeneous pools.  For example, if you have
an ipv6 addressed network, you'll want to be able to forward ipv4 traffic
into it.

This patch enforces that destination address family is the same as service
family, as none of the forwarding mechanisms support anything else.

For the old setsockopt mechanism, we simply set the dest address family to
AF_INET as we do with the service.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h            |  3 +++
 include/uapi/linux/ip_vs.h     |  3 +++
 net/netfilter/ipvs/ip_vs_ctl.c | 45 +++++++++++++++++++++++++++++++++++-------
 3 files changed, 44 insertions(+), 7 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 624a8a5..b7e2b62 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -648,6 +648,9 @@ struct ip_vs_dest_user_kern {
 	/* thresholds for active connections */
 	u32			u_threshold;	/* upper threshold */
 	u32			l_threshold;	/* lower threshold */
+
+	/* Address family of addr */
+	u16			af;
 };
 
 
diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
index fbcffe8..cabe95d 100644
--- a/include/uapi/linux/ip_vs.h
+++ b/include/uapi/linux/ip_vs.h
@@ -384,6 +384,9 @@ enum {
 	IPVS_DEST_ATTR_PERSIST_CONNS,	/* persistent connections */
 
 	IPVS_DEST_ATTR_STATS,		/* nested attribute for dest stats */
+
+	IPVS_DEST_ATTR_ADDR_FAMILY,	/* Address family of address */
+
 	__IPVS_DEST_ATTR_MAX,
 };
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index bd2b208..594cec7 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -816,6 +816,8 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	dest->u_threshold = udest->u_threshold;
 	dest->l_threshold = udest->l_threshold;
 
+	dest->af = udest->af;
+
 	spin_lock_bh(&dest->dst_lock);
 	__ip_vs_dst_cache_reset(dest);
 	spin_unlock_bh(&dest->dst_lock);
@@ -846,8 +848,12 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 
 	EnterFunction(2);
 
+	/* Temporary for consistency */
+	if (udest->af != svc->af)
+		return -EINVAL;
+
 #ifdef CONFIG_IP_VS_IPV6
-	if (svc->af == AF_INET6) {
+	if (udest->af == AF_INET6) {
 		atype = ipv6_addr_type(&udest->addr.in6);
 		if ((!(atype & IPV6_ADDR_UNICAST) ||
 			atype & IPV6_ADDR_LINKLOCAL) &&
@@ -875,12 +881,12 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 		u64_stats_init(&ip_vs_dest_stats->syncp);
 	}
 
-	dest->af = svc->af;
+	dest->af = udest->af;
 	dest->protocol = svc->protocol;
 	dest->vaddr = svc->addr;
 	dest->vport = svc->port;
 	dest->vfwmark = svc->fwmark;
-	ip_vs_addr_copy(svc->af, &dest->addr, &udest->addr);
+	ip_vs_addr_copy(udest->af, &dest->addr, &udest->addr);
 	dest->port = udest->port;
 
 	atomic_set(&dest->activeconns, 0);
@@ -928,7 +934,7 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 		return -ERANGE;
 	}
 
-	ip_vs_addr_copy(svc->af, &daddr, &udest->addr);
+	ip_vs_addr_copy(udest->af, &daddr, &udest->addr);
 
 	/* We use function that requires RCU lock */
 	rcu_read_lock();
@@ -949,7 +955,7 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	if (dest != NULL) {
 		IP_VS_DBG_BUF(3, "Get destination %s:%u from trash, "
 			      "dest->refcnt=%d, service %u/%s:%u\n",
-			      IP_VS_DBG_ADDR(svc->af, &daddr), ntohs(dport),
+			      IP_VS_DBG_ADDR(udest->af, &daddr), ntohs(dport),
 			      atomic_read(&dest->refcnt),
 			      dest->vfwmark,
 			      IP_VS_DBG_ADDR(svc->af, &dest->vaddr),
@@ -992,7 +998,7 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 		return -ERANGE;
 	}
 
-	ip_vs_addr_copy(svc->af, &daddr, &udest->addr);
+	ip_vs_addr_copy(udest->af, &daddr, &udest->addr);
 
 	/* We use function that requires RCU lock */
 	rcu_read_lock();
@@ -2244,6 +2250,7 @@ static void ip_vs_copy_udest_compat(struct ip_vs_dest_user_kern *udest,
 	udest->weight		= udest_compat->weight;
 	udest->u_threshold	= udest_compat->u_threshold;
 	udest->l_threshold	= udest_compat->l_threshold;
+	udest->af		= AF_INET;
 }
 
 static int
@@ -2480,6 +2487,12 @@ __ip_vs_get_dest_entries(struct net *net, const struct ip_vs_get_dests *get,
 			if (count >= get->num_dests)
 				break;
 
+			/* Cannot expose heterogeneous members via sockopt
+			 * interface
+			 */
+			if (dest->af != svc->af)
+				continue;
+
 			entry.addr = dest->addr.ip;
 			entry.port = dest->port;
 			entry.conn_flags = atomic_read(&dest->conn_flags);
@@ -2777,6 +2790,7 @@ static const struct nla_policy ip_vs_dest_policy[IPVS_DEST_ATTR_MAX + 1] = {
 	[IPVS_DEST_ATTR_INACT_CONNS]	= { .type = NLA_U32 },
 	[IPVS_DEST_ATTR_PERSIST_CONNS]	= { .type = NLA_U32 },
 	[IPVS_DEST_ATTR_STATS]		= { .type = NLA_NESTED },
+	[IPVS_DEST_ATTR_ADDR_FAMILY]	= { .type = NLA_U16 },
 };
 
 static int ip_vs_genl_fill_stats(struct sk_buff *skb, int container_type,
@@ -3032,7 +3046,8 @@ static int ip_vs_genl_fill_dest(struct sk_buff *skb, struct ip_vs_dest *dest)
 	    nla_put_u32(skb, IPVS_DEST_ATTR_INACT_CONNS,
 			atomic_read(&dest->inactconns)) ||
 	    nla_put_u32(skb, IPVS_DEST_ATTR_PERSIST_CONNS,
-			atomic_read(&dest->persistconns)))
+			atomic_read(&dest->persistconns)) ||
+	    nla_put_u16(skb, IPVS_DEST_ATTR_ADDR_FAMILY, dest->af))
 		goto nla_put_failure;
 	if (ip_vs_genl_fill_stats(skb, IPVS_DEST_ATTR_STATS, &dest->stats))
 		goto nla_put_failure;
@@ -3113,6 +3128,7 @@ static int ip_vs_genl_parse_dest(struct ip_vs_dest_user_kern *udest,
 {
 	struct nlattr *attrs[IPVS_DEST_ATTR_MAX + 1];
 	struct nlattr *nla_addr, *nla_port;
+	struct nlattr *nla_addr_family;
 
 	/* Parse mandatory identifying destination fields first */
 	if (nla == NULL ||
@@ -3121,6 +3137,7 @@ static int ip_vs_genl_parse_dest(struct ip_vs_dest_user_kern *udest,
 
 	nla_addr	= attrs[IPVS_DEST_ATTR_ADDR];
 	nla_port	= attrs[IPVS_DEST_ATTR_PORT];
+	nla_addr_family	= attrs[IPVS_DEST_ATTR_ADDR_FAMILY];
 
 	if (!(nla_addr && nla_port))
 		return -EINVAL;
@@ -3130,6 +3147,11 @@ static int ip_vs_genl_parse_dest(struct ip_vs_dest_user_kern *udest,
 	nla_memcpy(&udest->addr, nla_addr, sizeof(udest->addr));
 	udest->port = nla_get_be16(nla_port);
 
+	if (nla_addr_family)
+		udest->af = nla_get_u16(nla_addr_family);
+	else
+		udest->af = 0;
+
 	/* If a full entry was requested, check for the additional fields */
 	if (full_entry) {
 		struct nlattr *nla_fwd, *nla_weight, *nla_u_thresh,
@@ -3357,6 +3379,15 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 					    need_full_dest);
 		if (ret)
 			goto out;
+
+		/* Old protocols did not allow the user to specify address
+		 * family, so we set it to zero instead.  We also didn't
+		 * allow heterogeneous pools in the old code, so it's safe
+		 * to assume that this will have the same address family as
+		 * the service.
+		 */
+		if (udest.af == 0)
+			udest.af = svc->af;
 	}
 
 	switch (cmd) {
-- 
2.0.1
