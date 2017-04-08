From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH] net: netfilter: ipvs: Replace explicit NULL comparison
Date: Sat, 8 Apr 2017 22:48:05 +0530
Message-ID: <20170408171805.GA9156@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=uqwrOs5I0XNVywr7fzZ/+WN8V6l5Fyaf2GxGu+VtN2M=;
        b=koyn1PtBtsYB5zddeNotWkC0QkoIHHSsg61ZN9mxTVs4nkxYVpw78uGbxM3zsWRz82
         oJiqiTprpYYc4fPFzOlpQd+xtfZGBRUtJd7VHZV+raITTJynLY4IY5zDmvwqw8pRElB0
         ULz+mfP845QNjk/Px4e9x+5Ko0NwLRYOtCuDhS9+ru9gCsPEWUd8Bs7dtrsaX3nB1tyu
         V3gCejV9b4yfnmgKERwyxkNUaFyDJkiNMVwI4XOZzb73Ng0WXxHNXL05LNc1x+BH7kpi
         PsE2UjShdc0nKiHqtP+880hyp/8Oj532WF3FoNJCks5/eZ9BpSF9RjWIseajr+mFSvWa
         3O8A==
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

Replace explicit NULL comparison to simplify code.

Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c   | 40 ++++++++++++++++++++--------------------
 net/netfilter/ipvs/ip_vs_proto.c | 22 +++++++++++-----------
 2 files changed, 31 insertions(+), 31 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 5aeb0dde6ccc..481dcfa5f2c6 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -436,7 +436,7 @@ ip_vs_service_find(struct netns_ipvs *ipvs, int af, __u32 fwmark, __u16 protocol
 		svc = __ip_vs_service_find(ipvs, af, protocol, vaddr, FTPPORT);
 	}
 
-	if (svc == NULL
+	if (!svc
 	    && atomic_read(&ipvs->nullsvc_counter)) {
 		/*
 		 * Check if the catch-all port (port zero) exists
@@ -910,7 +910,7 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 	}
 
 	dest = kzalloc(sizeof(struct ip_vs_dest), GFP_KERNEL);
-	if (dest == NULL)
+	if (!dest)
 		return -ENOMEM;
 
 	dest->stats.cpustats = alloc_percpu(struct ip_vs_cpu_stats);
@@ -983,7 +983,7 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	dest = ip_vs_lookup_dest(svc, udest->af, &daddr, dport);
 	rcu_read_unlock();
 
-	if (dest != NULL) {
+	if (dest) {
 		IP_VS_DBG(1, "%s(): dest already exists\n", __func__);
 		return -EEXIST;
 	}
@@ -994,7 +994,7 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	 */
 	dest = ip_vs_trash_get_dest(svc, udest->af, &daddr, dport);
 
-	if (dest != NULL) {
+	if (dest) {
 		IP_VS_DBG_BUF(3, "Get destination %s:%u from trash, "
 			      "dest->refcnt=%d, service %u/%s:%u\n",
 			      IP_VS_DBG_ADDR(udest->af, &daddr), ntohs(dport),
@@ -1047,7 +1047,7 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	dest = ip_vs_lookup_dest(svc, udest->af, &daddr, dport);
 	rcu_read_unlock();
 
-	if (dest == NULL) {
+	if (!dest) {
 		IP_VS_DBG(1, "%s(): dest doesn't exist\n", __func__);
 		return -ENOENT;
 	}
@@ -1129,7 +1129,7 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	dest = ip_vs_lookup_dest(svc, udest->af, &udest->addr, dport);
 	rcu_read_unlock();
 
-	if (dest == NULL) {
+	if (!dest) {
 		IP_VS_DBG(1, "%s(): destination not found!\n", __func__);
 		return -ENOENT;
 	}
@@ -1208,7 +1208,7 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 
 	if (u->pe_name && *u->pe_name) {
 		pe = ip_vs_pe_getbyname(u->pe_name);
-		if (pe == NULL) {
+		if (!pe) {
 			pr_info("persistence engine module ip_vs_pe_%s "
 				"not found\n", u->pe_name);
 			ret = -ENOENT;
@@ -1228,7 +1228,7 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 #endif
 
 	svc = kzalloc(sizeof(struct ip_vs_service), GFP_KERNEL);
-	if (svc == NULL) {
+	if (!svc) {
 		IP_VS_DBG(1, "%s(): no memory\n", __func__);
 		ret = -ENOMEM;
 		goto out_err;
@@ -1299,7 +1299,7 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 
 
  out_err:
-	if (svc != NULL) {
+	if (svc) {
 		ip_vs_unbind_scheduler(svc, sched);
 		ip_vs_service_free(svc);
 	}
@@ -1339,7 +1339,7 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 
 	if (u->pe_name && *u->pe_name) {
 		pe = ip_vs_pe_getbyname(u->pe_name);
-		if (pe == NULL) {
+		if (!pe) {
 			pr_info("persistence engine module ip_vs_pe_%s "
 				"not found\n", u->pe_name);
 			ret = -ENOENT;
@@ -1476,7 +1476,7 @@ static void ip_vs_unlink_service(struct ip_vs_service *svc, bool cleanup)
  */
 static int ip_vs_del_service(struct ip_vs_service *svc)
 {
-	if (svc == NULL)
+	if (!svc)
 		return -EEXIST;
 	ip_vs_unlink_service(svc, false);
 
@@ -2446,14 +2446,14 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 	rcu_read_unlock();
 
 	if (cmd != IP_VS_SO_SET_ADD
-	    && (svc == NULL || svc->protocol != usvc.protocol)) {
+	    && (!svc || svc->protocol != usvc.protocol)) {
 		ret = -ESRCH;
 		goto out_unlock;
 	}
 
 	switch (cmd) {
 	case IP_VS_SO_SET_ADD:
-		if (svc != NULL)
+		if (svc)
 			ret = -EEXIST;
 		else
 			ret = ip_vs_add_service(ipvs, &usvc, &svc);
@@ -3088,7 +3088,7 @@ static int ip_vs_genl_parse_service(struct netns_ipvs *ipvs,
 	struct ip_vs_service *svc;
 
 	/* Parse mandatory identifying service fields first */
-	if (nla == NULL ||
+	if (!nla ||
 	    nla_parse_nested(attrs, IPVS_SVC_ATTR_MAX, nla, ip_vs_svc_policy))
 		return -EINVAL;
 
@@ -3287,7 +3287,7 @@ static int ip_vs_genl_parse_dest(struct ip_vs_dest_user_kern *udest,
 	struct nlattr *nla_addr_family;
 
 	/* Parse mandatory identifying destination fields first */
-	if (nla == NULL ||
+	if (!nla ||
 	    nla_parse_nested(attrs, IPVS_DEST_ATTR_MAX, nla, ip_vs_dest_policy))
 		return -EINVAL;
 
@@ -3582,7 +3582,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 		goto out;
 
 	/* Unless we're adding a new service, the service must already exist */
-	if ((cmd != IPVS_CMD_NEW_SERVICE) && (svc == NULL)) {
+	if ((cmd != IPVS_CMD_NEW_SERVICE) && (!svc)) {
 		ret = -ESRCH;
 		goto out;
 	}
@@ -3633,7 +3633,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 
 	switch (cmd) {
 	case IPVS_CMD_NEW_SERVICE:
-		if (svc == NULL)
+		if (!svc)
 			ret = ip_vs_add_service(ipvs, &usvc, &svc);
 		else
 			ret = -EEXIST;
@@ -3695,7 +3695,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	mutex_lock(&__ip_vs_mutex);
 
 	reply = genlmsg_put_reply(msg, info, &ip_vs_genl_family, 0, reply_cmd);
-	if (reply == NULL)
+	if (!reply)
 		goto nla_put_failure;
 
 	switch (cmd) {
@@ -3902,7 +3902,7 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 
 	if (!net_eq(net, &init_net)) {
 		tbl = kmemdup(vs_vars, sizeof(vs_vars), GFP_KERNEL);
-		if (tbl == NULL)
+		if (!tbl)
 			return -ENOMEM;
 
 		/* Don't export sysctls to unprivileged users */
@@ -3960,7 +3960,7 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 	tbl[idx++].data = &ipvs->sysctl_ignore_tunneled;
 
 	ipvs->sysctl_hdr = register_net_sysctl(net, "net/ipv4/vs", tbl);
-	if (ipvs->sysctl_hdr == NULL) {
+	if (!ipvs->sysctl_hdr) {
 		if (!net_eq(net, &init_net))
 			kfree(tbl);
 		return -ENOMEM;
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 8ae480715cea..7c650b8ab2b7 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -53,7 +53,7 @@ static int __used __init register_ip_vs_protocol(struct ip_vs_protocol *pp)
 	pp->next = ip_vs_proto_table[hash];
 	ip_vs_proto_table[hash] = pp;
 
-	if (pp->init != NULL)
+	if (pp->init)
 		pp->init(pp);
 
 	return 0;
@@ -77,7 +77,7 @@ register_ip_vs_proto_netns(struct netns_ipvs *ipvs, struct ip_vs_protocol *pp)
 	ipvs->proto_data_table[hash] = pd;
 	atomic_set(&pd->appcnt, 0);	/* Init app counter */
 
-	if (pp->init_netns != NULL) {
+	if (pp->init_netns) {
 		int ret = pp->init_netns(ipvs, pd);
 		if (ret) {
 			/* unlink an free proto data */
@@ -102,7 +102,7 @@ static int unregister_ip_vs_protocol(struct ip_vs_protocol *pp)
 	for (; *pp_p; pp_p = &(*pp_p)->next) {
 		if (*pp_p == pp) {
 			*pp_p = pp->next;
-			if (pp->exit != NULL)
+			if (pp->exit)
 				pp->exit(pp);
 			return 0;
 		}
@@ -124,7 +124,7 @@ unregister_ip_vs_proto_netns(struct netns_ipvs *ipvs, struct ip_vs_proto_data *p
 	for (; *pd_p; pd_p = &(*pd_p)->next) {
 		if (*pd_p == pd) {
 			*pd_p = pd->next;
-			if (pd->pp->exit_netns != NULL)
+			if (pd->pp->exit_netns)
 				pd->pp->exit_netns(ipvs, pd);
 			kfree(pd);
 			return 0;
@@ -219,7 +219,7 @@ const char * ip_vs_state_name(__u16 proto, int state)
 {
 	struct ip_vs_protocol *pp = ip_vs_proto_get(proto);
 
-	if (pp == NULL || pp->state_name == NULL)
+	if (!pp || !pp->state_name)
 		return (IPPROTO_IP == proto) ? "NONE" : "ERR!";
 	return pp->state_name(state);
 }
@@ -235,7 +235,7 @@ ip_vs_tcpudp_debug_packet_v4(struct ip_vs_protocol *pp,
 	struct iphdr _iph, *ih;
 
 	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
-	if (ih == NULL)
+	if (!ih)
 		sprintf(buf, "TRUNCATED");
 	else if (ih->frag_off & htons(IP_OFFSET))
 		sprintf(buf, "%pI4->%pI4 frag", &ih->saddr, &ih->daddr);
@@ -244,7 +244,7 @@ ip_vs_tcpudp_debug_packet_v4(struct ip_vs_protocol *pp,
 
 		pptr = skb_header_pointer(skb, offset + ih->ihl*4,
 					  sizeof(_ports), _ports);
-		if (pptr == NULL)
+		if (!pptr)
 			sprintf(buf, "TRUNCATED %pI4->%pI4",
 				&ih->saddr, &ih->daddr);
 		else
@@ -267,7 +267,7 @@ ip_vs_tcpudp_debug_packet_v6(struct ip_vs_protocol *pp,
 	struct ipv6hdr _iph, *ih;
 
 	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
-	if (ih == NULL)
+	if (!ih)
 		sprintf(buf, "TRUNCATED");
 	else if (ih->nexthdr == IPPROTO_FRAGMENT)
 		sprintf(buf, "%pI6c->%pI6c frag", &ih->saddr, &ih->daddr);
@@ -276,7 +276,7 @@ ip_vs_tcpudp_debug_packet_v6(struct ip_vs_protocol *pp,
 
 		pptr = skb_header_pointer(skb, offset + sizeof(struct ipv6hdr),
 					  sizeof(_ports), _ports);
-		if (pptr == NULL)
+		if (!pptr)
 			sprintf(buf, "TRUNCATED %pI6c->%pI6c",
 				&ih->saddr, &ih->daddr);
 		else
@@ -347,7 +347,7 @@ void __net_exit ip_vs_protocol_net_cleanup(struct netns_ipvs *ipvs)
 
 	/* unregister all the ipvs proto data for this netns */
 	for (i = 0; i < IP_VS_PROTO_TAB_SIZE; i++) {
-		while ((pd = ipvs->proto_data_table[i]) != NULL)
+		while (pd = ipvs->proto_data_table[i])
 			unregister_ip_vs_proto_netns(ipvs, pd);
 	}
 }
@@ -392,7 +392,7 @@ void ip_vs_protocol_cleanup(void)
 
 	/* unregister all the ipvs protocols */
 	for (i = 0; i < IP_VS_PROTO_TAB_SIZE; i++) {
-		while ((pp = ip_vs_proto_table[i]) != NULL)
+		while (pp = ip_vs_proto_table[i])
 			unregister_ip_vs_protocol(pp);
 	}
 }
-- 
2.11.0

