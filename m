From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH] net: netfilter: replace explicit NULL comparison with !
 operator
Date: Wed, 29 Mar 2017 12:14:26 +0530
Message-ID: <20170329064426.GA22509@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=5B5jsCxIAiMXHlvaMdWfyflXHGJQstkgORMYJ/yLxhg=;
        b=ISRpwhWbVeRO000scHZq4E0ofCGMYLMpfp54SkA4qLTP6yPjrZcbvgVVjglnfELcZi
         CzAH3cEV1YxWRICatPCPBeIfwBre5jj9JuasVjkk7cZvRp6tCuLKwQmzqun8WkQglTRi
         jpDxxLA9ZA5k/o0igRNYN0cauIpj0Mn7bIzgo3DywvrlbAxu2E/n64a5xme1kb/WazDb
         SE7h80i1WFfifpg+SDARKK3J6RJPhCukk3DByGzHdssFTcKSia+zrJ9sEK6ZJHsKJ1cR
         vEI0cwtXxhuYXYehGMXJ+N2+oq0GNOKb4YxFUNpSyHPvdCN9x/oa+BsWy+5qVDbobZ6c
         rDzw==
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

Replace explicit NULL comparison with ! operator to simplify code.

Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c         |  8 ++---
 net/netfilter/ipvs/ip_vs_proto.c       |  8 ++---
 net/netfilter/nf_conntrack_broadcast.c |  2 +-
 net/netfilter/nf_conntrack_core.c      |  2 +-
 net/netfilter/nf_conntrack_ecache.c    |  4 +--
 net/netfilter/nf_conntrack_helper.c    |  4 +--
 net/netfilter/nf_conntrack_proto.c     |  4 +--
 net/netfilter/nf_log.c                 |  2 +-
 net/netfilter/nf_nat_redirect.c        |  2 +-
 net/netfilter/nf_tables_api.c          | 62 +++++++++++++++++-----------------
 net/netfilter/nfnetlink_log.c          |  6 ++--
 net/netfilter/nfnetlink_queue.c        |  8 ++---
 net/netfilter/nft_compat.c             |  4 +--
 net/netfilter/nft_ct.c                 | 10 +++---
 net/netfilter/nft_dynset.c             | 14 ++++----
 net/netfilter/nft_log.c                | 14 ++++----
 net/netfilter/nft_lookup.c             |  2 +-
 net/netfilter/nft_payload.c            |  4 +--
 net/netfilter/nft_set_hash.c           |  4 +--
 net/netfilter/x_tables.c               |  8 ++---
 net/netfilter/xt_TCPMSS.c              |  4 +--
 net/netfilter/xt_addrtype.c            |  2 +-
 net/netfilter/xt_connlimit.c           |  2 +-
 net/netfilter/xt_conntrack.c           |  2 +-
 net/netfilter/xt_hashlimit.c           |  4 +--
 net/netfilter/xt_recent.c              |  6 ++--
 26 files changed, 96 insertions(+), 96 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 5aeb0dde6ccc..32daa0b3797e 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
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
@@ -1299,7 +1299,7 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 
 
  out_err:
-	if (svc != NULL) {
+	if (svc) {
 		ip_vs_unbind_scheduler(svc, sched);
 		ip_vs_service_free(svc);
 	}
@@ -2453,7 +2453,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 
 	switch (cmd) {
 	case IP_VS_SO_SET_ADD:
-		if (svc != NULL)
+		if (svc)
 			ret = -EEXIST;
 		else
 			ret = ip_vs_add_service(ipvs, &usvc, &svc);
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 8ae480715cea..6ee7fec2ef47 100644
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
diff --git a/net/netfilter/nf_conntrack_broadcast.c b/net/netfilter/nf_conntrack_broadcast.c
index 4e99cca61612..a016d47e5a80 100644
--- a/net/netfilter/nf_conntrack_broadcast.c
+++ b/net/netfilter/nf_conntrack_broadcast.c
@@ -42,7 +42,7 @@ int nf_conntrack_broadcast_help(struct sk_buff *skb,
 
 	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(rt->dst.dev);
-	if (in_dev != NULL) {
+	if (in_dev) {
 		for_primary_ifa(in_dev) {
 			if (ifa->ifa_broadcast == iph->daddr) {
 				mask = ifa->ifa_mask;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index ffb78e5f7b70..282d7ec1acba 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1345,7 +1345,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	/* It may be an special packet, error, unclean...
 	 * inverse of the return code tells to the netfilter
 	 * core what to do with the packet. */
-	if (l4proto->error != NULL) {
+	if (l4proto->error) {
 		ret = l4proto->error(net, tmpl, skb, dataoff, pf, hooknum);
 		if (ret <= 0) {
 			NF_CT_STAT_INC_ATOMIC(net, error);
diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index da9df2d56e66..11184cae5329 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -266,7 +266,7 @@ int nf_conntrack_register_notifier(struct net *net,
 	mutex_lock(&nf_ct_ecache_mutex);
 	notify = rcu_dereference_protected(net->ct.nf_conntrack_event_cb,
 					   lockdep_is_held(&nf_ct_ecache_mutex));
-	if (notify != NULL) {
+	if (notify) {
 		ret = -EBUSY;
 		goto out_unlock;
 	}
@@ -302,7 +302,7 @@ int nf_ct_expect_register_notifier(struct net *net,
 	mutex_lock(&nf_ct_ecache_mutex);
 	notify = rcu_dereference_protected(net->ct.nf_expect_event_cb,
 					   lockdep_is_held(&nf_ct_ecache_mutex));
-	if (notify != NULL) {
+	if (notify) {
 		ret = -EBUSY;
 		goto out_unlock;
 	}
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 6dc44d9b4190..fda6348a88e5 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -224,9 +224,9 @@ int __nf_ct_try_assign_helper(struct nf_conn *ct, struct nf_conn *tmpl,
 	if (test_bit(IPS_HELPER_BIT, &ct->status))
 		return 0;
 
-	if (tmpl != NULL) {
+	if (tmpl) {
 		help = nfct_help(tmpl);
-		if (help != NULL) {
+		if (help) {
 			helper = help->helper;
 			set_bit(IPS_HELPER_BIT, &ct->status);
 		}
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 2d6ee1803415..cb1e1593fc82 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -307,7 +307,7 @@ int nf_ct_l4proto_register_sysctl(struct net *net,
 	int err = 0;
 
 #ifdef CONFIG_SYSCTL
-	if (pn->ctl_table != NULL) {
+	if (pn->ctl_table) {
 		err = nf_ct_register_sysctl(net,
 					    &pn->ctl_table_header,
 					    "net/netfilter",
@@ -329,7 +329,7 @@ void nf_ct_l4proto_unregister_sysctl(struct net *net,
 				     struct nf_conntrack_l4proto *l4proto)
 {
 #ifdef CONFIG_SYSCTL
-	if (pn->ctl_table_header != NULL)
+	if (pn->ctl_table_header)
 		nf_ct_unregister_sysctl(&pn->ctl_table_header,
 					&pn->ctl_table,
 					pn->users);
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 8d85a0598b60..fd4cea972bc3 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -226,7 +226,7 @@ void nf_log_packet(struct net *net,
 	const struct nf_logger *logger;
 
 	rcu_read_lock();
-	if (loginfo != NULL)
+	if (loginfo)
 		logger = rcu_dereference(loggers[pf][loginfo->type]);
 	else
 		logger = rcu_dereference(net->nf.nf_loggers[pf]);
diff --git a/net/netfilter/nf_nat_redirect.c b/net/netfilter/nf_nat_redirect.c
index d43869879fcf..8bb0a169e640 100644
--- a/net/netfilter/nf_nat_redirect.c
+++ b/net/netfilter/nf_nat_redirect.c
@@ -100,7 +100,7 @@ nf_nat_redirect_ipv6(struct sk_buff *skb, const struct nf_nat_range *range,
 
 		rcu_read_lock();
 		idev = __in6_dev_get(skb->dev);
-		if (idev != NULL) {
+		if (idev) {
 			list_for_each_entry(ifa, &idev->addr_list, if_list) {
 				newdst = ifa->addr;
 				addr = true;
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 434c739dfeca..e9d98557579a 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -77,7 +77,7 @@ nf_tables_afinfo_lookup(struct net *net, int family, bool autoload)
 	struct nft_af_info *afi;
 
 	afi = nft_afinfo_lookup(net, family);
-	if (afi != NULL)
+	if (afi)
 		return afi;
 #ifdef CONFIG_MODULES
 	if (autoload) {
@@ -85,7 +85,7 @@ nf_tables_afinfo_lookup(struct net *net, int family, bool autoload)
 		request_module("nft-afinfo-%u", family);
 		nfnl_lock(NFNL_SUBSYS_NFTABLES);
 		afi = nft_afinfo_lookup(net, family);
-		if (afi != NULL)
+		if (afi)
 			return ERR_PTR(-EAGAIN);
 	}
 #endif
@@ -375,7 +375,7 @@ static struct nft_table *nf_tables_table_lookup(const struct nft_af_info *afi,
 		return ERR_PTR(-EINVAL);
 
 	table = nft_table_lookup(afi, nla, genmask);
-	if (table != NULL)
+	if (table)
 		return table;
 
 	return ERR_PTR(-ENOENT);
@@ -409,7 +409,7 @@ nf_tables_chain_type_lookup(const struct nft_af_info *afi,
 	const struct nf_chain_type *type;
 
 	type = __nf_tables_chain_type_lookup(afi->family, nla);
-	if (type != NULL)
+	if (type)
 		return type;
 #ifdef CONFIG_MODULES
 	if (autoload) {
@@ -418,7 +418,7 @@ nf_tables_chain_type_lookup(const struct nft_af_info *afi,
 			       nla_len(nla), (const char *)nla_data(nla));
 		nfnl_lock(NFNL_SUBSYS_NFTABLES);
 		type = __nf_tables_chain_type_lookup(afi->family, nla);
-		if (type != NULL)
+		if (type)
 			return ERR_PTR(-EAGAIN);
 	}
 #endif
@@ -870,7 +870,7 @@ int nft_register_chain_type(const struct nf_chain_type *ctype)
 	int err = 0;
 
 	nfnl_lock(NFNL_SUBSYS_NFTABLES);
-	if (chain_type[ctype->family][ctype->type] != NULL) {
+	if (chain_type[ctype->family][ctype->type]) {
 		err = -EBUSY;
 		goto out;
 	}
@@ -1231,7 +1231,7 @@ static void nf_tables_chain_destroy(struct nft_chain *chain)
 
 		module_put(basechain->type->owner);
 		free_percpu(basechain->stats);
-		if (basechain->ops[0].dev != NULL)
+		if (basechain->ops[0].dev)
 			dev_put(basechain->ops[0].dev);
 		kfree(basechain);
 	} else {
@@ -1312,7 +1312,7 @@ static int nft_chain_parse_hook(struct net *net,
 static void nft_chain_release_hook(struct nft_chain_hook *hook)
 {
 	module_put(hook->type->owner);
-	if (hook->dev != NULL)
+	if (hook->dev)
 		dev_put(hook->dev);
 }
 
@@ -1740,7 +1740,7 @@ static int nf_tables_expr_parse(const struct nft_ctx *ctx,
 	} else
 		memset(info->tb, 0, sizeof(info->tb[0]) * (type->maxattr + 1));
 
-	if (type->select_ops != NULL) {
+	if (type->select_ops) {
 		ops = type->select_ops(ctx,
 				       (const struct nlattr * const *)info->tb);
 		if (IS_ERR(ops)) {
@@ -2278,7 +2278,7 @@ static int nf_tables_newrule(struct net *net, struct sock *nlsk,
 	nf_tables_rule_destroy(&ctx, rule);
 err1:
 	for (i = 0; i < n; i++) {
-		if (info[i].ops != NULL)
+		if (info[i].ops)
 			module_put(info[i].ops->type->owner);
 	}
 	return err;
@@ -2409,7 +2409,7 @@ nft_select_set_ops(const struct nlattr * const nla[],
 	}
 #endif
 	features = 0;
-	if (nla[NFTA_SET_FLAGS] != NULL) {
+	if (nla[NFTA_SET_FLAGS]) {
 		features = ntohl(nla_get_be32(nla[NFTA_SET_FLAGS]));
 		features &= NFT_SET_INTERVAL | NFT_SET_MAP | NFT_SET_TIMEOUT |
 			    NFT_SET_OBJECT;
@@ -2456,14 +2456,14 @@ nft_select_set_ops(const struct nlattr * const nla[],
 
 		if (!try_module_get(ops->owner))
 			continue;
-		if (bops != NULL)
+		if (bops)
 			module_put(bops->owner);
 
 		bops = ops;
 		best = est;
 	}
 
-	if (bops != NULL)
+	if (bops)
 		return bops;
 
 	return ERR_PTR(-EOPNOTSUPP);
@@ -2509,7 +2509,7 @@ static int nft_ctx_init_from_setattr(struct nft_ctx *ctx, struct net *net,
 			return PTR_ERR(afi);
 	}
 
-	if (nla[NFTA_SET_TABLE] != NULL) {
+	if (nla[NFTA_SET_TABLE]) {
 		if (afi == NULL)
 			return -EAFNOSUPPORT;
 
@@ -2568,7 +2568,7 @@ static int nf_tables_set_alloc_name(struct nft_ctx *ctx, struct nft_set *set,
 	unsigned int n = 0, min = 0;
 
 	p = strnchr(name, NFT_SET_MAXNAMELEN, '%');
-	if (p != NULL) {
+	if (p) {
 		if (p[1] != 'd' || strchr(p + 2, '%'))
 			return -EINVAL;
 
@@ -2855,7 +2855,7 @@ static int nf_tables_set_desc_parse(const struct nft_ctx *ctx,
 	if (err < 0)
 		return err;
 
-	if (da[NFTA_SET_DESC_SIZE] != NULL)
+	if (da[NFTA_SET_DESC_SIZE])
 		desc->size = ntohl(nla_get_be32(da[NFTA_SET_DESC_SIZE]));
 
 	return 0;
@@ -2891,7 +2891,7 @@ static int nf_tables_newset(struct net *net, struct sock *nlsk,
 	memset(&desc, 0, sizeof(desc));
 
 	ktype = NFT_DATA_VALUE;
-	if (nla[NFTA_SET_KEY_TYPE] != NULL) {
+	if (nla[NFTA_SET_KEY_TYPE]) {
 		ktype = ntohl(nla_get_be32(nla[NFTA_SET_KEY_TYPE]));
 		if ((ktype & NFT_DATA_RESERVED_MASK) == NFT_DATA_RESERVED_MASK)
 			return -EINVAL;
@@ -2902,7 +2902,7 @@ static int nf_tables_newset(struct net *net, struct sock *nlsk,
 		return -EINVAL;
 
 	flags = 0;
-	if (nla[NFTA_SET_FLAGS] != NULL) {
+	if (nla[NFTA_SET_FLAGS]) {
 		flags = ntohl(nla_get_be32(nla[NFTA_SET_FLAGS]));
 		if (flags & ~(NFT_SET_ANONYMOUS | NFT_SET_CONSTANT |
 			      NFT_SET_INTERVAL | NFT_SET_TIMEOUT |
@@ -2916,7 +2916,7 @@ static int nf_tables_newset(struct net *net, struct sock *nlsk,
 	}
 
 	dtype = 0;
-	if (nla[NFTA_SET_DATA_TYPE] != NULL) {
+	if (nla[NFTA_SET_DATA_TYPE]) {
 		if (!(flags & NFT_SET_MAP))
 			return -EINVAL;
 
@@ -2936,7 +2936,7 @@ static int nf_tables_newset(struct net *net, struct sock *nlsk,
 	} else if (flags & NFT_SET_MAP)
 		return -EINVAL;
 
-	if (nla[NFTA_SET_OBJ_TYPE] != NULL) {
+	if (nla[NFTA_SET_OBJ_TYPE]) {
 		if (!(flags & NFT_SET_OBJECT))
 			return -EINVAL;
 
@@ -2950,24 +2950,24 @@ static int nf_tables_newset(struct net *net, struct sock *nlsk,
 		objtype = NFT_OBJECT_UNSPEC;
 
 	timeout = 0;
-	if (nla[NFTA_SET_TIMEOUT] != NULL) {
+	if (nla[NFTA_SET_TIMEOUT]) {
 		if (!(flags & NFT_SET_TIMEOUT))
 			return -EINVAL;
 		timeout = msecs_to_jiffies(be64_to_cpu(nla_get_be64(
 						nla[NFTA_SET_TIMEOUT])));
 	}
 	gc_int = 0;
-	if (nla[NFTA_SET_GC_INTERVAL] != NULL) {
+	if (nla[NFTA_SET_GC_INTERVAL]) {
 		if (!(flags & NFT_SET_TIMEOUT))
 			return -EINVAL;
 		gc_int = ntohl(nla_get_be32(nla[NFTA_SET_GC_INTERVAL]));
 	}
 
 	policy = NFT_SET_POL_PERFORMANCE;
-	if (nla[NFTA_SET_POLICY] != NULL)
+	if (nla[NFTA_SET_POLICY])
 		policy = ntohl(nla_get_be32(nla[NFTA_SET_POLICY]));
 
-	if (nla[NFTA_SET_DESC] != NULL) {
+	if (nla[NFTA_SET_DESC]) {
 		err = nf_tables_set_desc_parse(&ctx, &desc, nla[NFTA_SET_DESC]);
 		if (err < 0)
 			return err;
@@ -3009,7 +3009,7 @@ static int nf_tables_newset(struct net *net, struct sock *nlsk,
 		udlen = nla_len(nla[NFTA_SET_USERDATA]);
 
 	size = 0;
-	if (ops->privsize != NULL)
+	if (ops->privsize)
 		size = ops->privsize(nla);
 
 	err = -ENOMEM;
@@ -3635,12 +3635,12 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 		    flags & NFT_SET_ELEM_INTERVAL_END)
 			return -EINVAL;
 	} else {
-		if (nla[NFTA_SET_ELEM_DATA] != NULL)
+		if (nla[NFTA_SET_ELEM_DATA])
 			return -EINVAL;
 	}
 
 	timeout = 0;
-	if (nla[NFTA_SET_ELEM_TIMEOUT] != NULL) {
+	if (nla[NFTA_SET_ELEM_TIMEOUT]) {
 		if (!(set->flags & NFT_SET_TIMEOUT))
 			return -EINVAL;
 		timeout = msecs_to_jiffies(be64_to_cpu(nla_get_be64(
@@ -3664,7 +3664,7 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 			nft_set_ext_add(&tmpl, NFT_SET_EXT_TIMEOUT);
 	}
 
-	if (nla[NFTA_SET_ELEM_OBJREF] != NULL) {
+	if (nla[NFTA_SET_ELEM_OBJREF]) {
 		if (!(set->flags & NFT_SET_OBJECT)) {
 			err = -EINVAL;
 			goto err2;
@@ -3678,7 +3678,7 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 		nft_set_ext_add(&tmpl, NFT_SET_EXT_OBJREF);
 	}
 
-	if (nla[NFTA_SET_ELEM_DATA] != NULL) {
+	if (nla[NFTA_SET_ELEM_DATA]) {
 		err = nft_data_init(ctx, &data, sizeof(data), &d2,
 				    nla[NFTA_SET_ELEM_DATA]);
 		if (err < 0)
@@ -3715,7 +3715,7 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	 * must be the last extension added.
 	 */
 	ulen = 0;
-	if (nla[NFTA_SET_ELEM_USERDATA] != NULL) {
+	if (nla[NFTA_SET_ELEM_USERDATA]) {
 		ulen = nla_len(nla[NFTA_SET_ELEM_USERDATA]);
 		if (ulen > 0)
 			nft_set_ext_add_length(&tmpl, NFT_SET_EXT_USERDATA,
@@ -3780,7 +3780,7 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 err4:
 	kfree(elem.priv);
 err3:
-	if (nla[NFTA_SET_ELEM_DATA] != NULL)
+	if (nla[NFTA_SET_ELEM_DATA])
 		nft_data_uninit(&data, d2.type);
 err2:
 	nft_data_uninit(&elem.key.val, d1.type);
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 08247bf7d7b8..e85a4e1da9e9 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -683,9 +683,9 @@ nfulnl_log_packet(struct net *net,
 		size += nla_total_size(sizeof(u_int32_t));
 	if (inst->flags & NFULNL_CFG_F_CONNTRACK) {
 		nfnl_ct = rcu_dereference(nfnl_ct_hook);
-		if (nfnl_ct != NULL) {
+		if (nfnl_ct) {
 			ct = nfnl_ct->get_ct(skb, &ctinfo);
-			if (ct != NULL)
+			if (ct)
 				size += nfnl_ct->build_size(ct);
 		}
 	}
@@ -868,7 +868,7 @@ static int nfulnl_recv_config(struct net *net, struct sock *ctnl,
 		}
 	}
 
-	if (cmd != NULL) {
+	if (cmd) {
 		switch (cmd->command) {
 		case NFULNL_CFG_CMD_BIND:
 			if (inst) {
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 3ee0b8a000a4..f23cf318a9f2 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -422,9 +422,9 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 	nfnl_ct = rcu_dereference(nfnl_ct_hook);
 
 	if (queue->flags & NFQA_CFG_F_CONNTRACK) {
-		if (nfnl_ct != NULL) {
+		if (nfnl_ct) {
 			ct = nfnl_ct->get_ct(entskb, &ctinfo);
-			if (ct != NULL)
+			if (ct)
 				size += nfnl_ct->build_size(ct);
 		}
 	}
@@ -1166,7 +1166,7 @@ static int nfqnl_recv_verdict(struct net *net, struct sock *ctnl,
 	nfnl_ct = rcu_dereference(nfnl_ct_hook);
 
 	if (nfqa[NFQA_CT]) {
-		if (nfnl_ct != NULL)
+		if (nfnl_ct)
 			ct = nfqnl_ct_parse(nfnl_ct, nlh, nfqa, entry, &ctinfo);
 	}
 
@@ -1275,7 +1275,7 @@ static int nfqnl_recv_config(struct net *net, struct sock *ctnl,
 		goto err_out_unlock;
 	}
 
-	if (cmd != NULL) {
+	if (cmd) {
 		switch (cmd->command) {
 		case NFQNL_CFG_CMD_BIND:
 			if (queue) {
diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index c21e7eb8dce0..9d314c567ccd 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -271,7 +271,7 @@ nft_target_destroy(const struct nft_ctx *ctx, const struct nft_expr *expr)
 	par.target = target;
 	par.targinfo = info;
 	par.family = ctx->afi->family;
-	if (par.target->destroy != NULL)
+	if (par.target->destroy)
 		par.target->destroy(&par);
 
 	nft_xt_put(container_of(expr->ops, struct nft_xt, ops));
@@ -454,7 +454,7 @@ nft_match_destroy(const struct nft_ctx *ctx, const struct nft_expr *expr)
 	par.match = match;
 	par.matchinfo = info;
 	par.family = ctx->afi->family;
-	if (par.match->destroy != NULL)
+	if (par.match->destroy)
 		par.match->destroy(&par);
 
 	nft_xt_put(container_of(expr->ops, struct nft_xt, ops));
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 0264258c46fe..a05b4f1100ca 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -374,7 +374,7 @@ static int nft_ct_get_init(const struct nft_ctx *ctx,
 	priv->dir = IP_CT_DIR_MAX;
 	switch (priv->key) {
 	case NFT_CT_DIRECTION:
-		if (tb[NFTA_CT_DIRECTION] != NULL)
+		if (tb[NFTA_CT_DIRECTION])
 			return -EINVAL;
 		len = sizeof(u8);
 		break;
@@ -387,19 +387,19 @@ static int nft_ct_get_init(const struct nft_ctx *ctx,
 	case NFT_CT_SECMARK:
 #endif
 	case NFT_CT_EXPIRATION:
-		if (tb[NFTA_CT_DIRECTION] != NULL)
+		if (tb[NFTA_CT_DIRECTION])
 			return -EINVAL;
 		len = sizeof(u32);
 		break;
 #ifdef CONFIG_NF_CONNTRACK_LABELS
 	case NFT_CT_LABELS:
-		if (tb[NFTA_CT_DIRECTION] != NULL)
+		if (tb[NFTA_CT_DIRECTION])
 			return -EINVAL;
 		len = NF_CT_LABELS_MAX_SIZE;
 		break;
 #endif
 	case NFT_CT_HELPER:
-		if (tb[NFTA_CT_DIRECTION] != NULL)
+		if (tb[NFTA_CT_DIRECTION])
 			return -EINVAL;
 		len = NF_CT_HELPER_NAME_LEN;
 		break;
@@ -450,7 +450,7 @@ static int nft_ct_get_init(const struct nft_ctx *ctx,
 		return -EOPNOTSUPP;
 	}
 
-	if (tb[NFTA_CT_DIRECTION] != NULL) {
+	if (tb[NFTA_CT_DIRECTION]) {
 		priv->dir = nla_get_u8(tb[NFTA_CT_DIRECTION]);
 		switch (priv->dir) {
 		case IP_CT_DIR_ORIGINAL:
diff --git a/net/netfilter/nft_dynset.c b/net/netfilter/nft_dynset.c
index 049ad2d9ee66..a0bf5eeab581 100644
--- a/net/netfilter/nft_dynset.c
+++ b/net/netfilter/nft_dynset.c
@@ -85,7 +85,7 @@ static void nft_dynset_eval(const struct nft_expr *expr,
 		} else if (sexpr == NULL)
 			goto out;
 
-		if (sexpr != NULL)
+		if (sexpr)
 			sexpr->ops->eval(sexpr, regs, pkt);
 
 		if (priv->invert)
@@ -163,7 +163,7 @@ static int nft_dynset_init(const struct nft_ctx *ctx,
 	}
 
 	timeout = 0;
-	if (tb[NFTA_DYNSET_TIMEOUT] != NULL) {
+	if (tb[NFTA_DYNSET_TIMEOUT]) {
 		if (!(set->flags & NFT_SET_TIMEOUT))
 			return -EINVAL;
 		timeout = msecs_to_jiffies(be64_to_cpu(nla_get_be64(
@@ -175,7 +175,7 @@ static int nft_dynset_init(const struct nft_ctx *ctx,
 	if (err < 0)
 		return err;
 
-	if (tb[NFTA_DYNSET_SREG_DATA] != NULL) {
+	if (tb[NFTA_DYNSET_SREG_DATA]) {
 		if (!(set->flags & NFT_SET_MAP))
 			return -EINVAL;
 		if (set->dtype == NFT_DATA_VERDICT)
@@ -188,7 +188,7 @@ static int nft_dynset_init(const struct nft_ctx *ctx,
 	} else if (set->flags & NFT_SET_MAP)
 		return -EINVAL;
 
-	if (tb[NFTA_DYNSET_EXPR] != NULL) {
+	if (tb[NFTA_DYNSET_EXPR]) {
 		if (!(set->flags & NFT_SET_EVAL))
 			return -EINVAL;
 		if (!(set->flags & NFT_SET_ANONYMOUS))
@@ -208,7 +208,7 @@ static int nft_dynset_init(const struct nft_ctx *ctx,
 	nft_set_ext_add_length(&priv->tmpl, NFT_SET_EXT_KEY, set->klen);
 	if (set->flags & NFT_SET_MAP)
 		nft_set_ext_add_length(&priv->tmpl, NFT_SET_EXT_DATA, set->dlen);
-	if (priv->expr != NULL)
+	if (priv->expr)
 		nft_set_ext_add_length(&priv->tmpl, NFT_SET_EXT_EXPR,
 				       priv->expr->ops->size);
 	if (set->flags & NFT_SET_TIMEOUT) {
@@ -226,7 +226,7 @@ static int nft_dynset_init(const struct nft_ctx *ctx,
 	return 0;
 
 err1:
-	if (priv->expr != NULL)
+	if (priv->expr)
 		nft_expr_destroy(ctx, priv->expr);
 	return err;
 }
@@ -237,7 +237,7 @@ static void nft_dynset_destroy(const struct nft_ctx *ctx,
 	struct nft_dynset *priv = nft_expr_priv(expr);
 
 	nf_tables_unbind_set(ctx, priv->set, &priv->binding);
-	if (priv->expr != NULL)
+	if (priv->expr)
 		nft_expr_destroy(ctx, priv->expr);
 }
 
diff --git a/net/netfilter/nft_log.c b/net/netfilter/nft_log.c
index 6f6e64423643..41d62f8678df 100644
--- a/net/netfilter/nft_log.c
+++ b/net/netfilter/nft_log.c
@@ -60,14 +60,14 @@ static int nft_log_init(const struct nft_ctx *ctx,
 	if (tb[NFTA_LOG_LEVEL] != NULL &&
 	    tb[NFTA_LOG_GROUP] != NULL)
 		return -EINVAL;
-	if (tb[NFTA_LOG_GROUP] != NULL) {
+	if (tb[NFTA_LOG_GROUP]) {
 		li->type = NF_LOG_TYPE_ULOG;
-		if (tb[NFTA_LOG_FLAGS] != NULL)
+		if (tb[NFTA_LOG_FLAGS])
 			return -EINVAL;
 	}
 
 	nla = tb[NFTA_LOG_PREFIX];
-	if (nla != NULL) {
+	if (nla) {
 		priv->prefix = kmalloc(nla_len(nla) + 1, GFP_KERNEL);
 		if (priv->prefix == NULL)
 			return -ENOMEM;
@@ -78,7 +78,7 @@ static int nft_log_init(const struct nft_ctx *ctx,
 
 	switch (li->type) {
 	case NF_LOG_TYPE_LOG:
-		if (tb[NFTA_LOG_LEVEL] != NULL) {
+		if (tb[NFTA_LOG_LEVEL]) {
 			li->u.log.level =
 				ntohl(nla_get_be32(tb[NFTA_LOG_LEVEL]));
 		} else {
@@ -89,7 +89,7 @@ static int nft_log_init(const struct nft_ctx *ctx,
 			goto err1;
 		}
 
-		if (tb[NFTA_LOG_FLAGS] != NULL) {
+		if (tb[NFTA_LOG_FLAGS]) {
 			li->u.log.logflags =
 				ntohl(nla_get_be32(tb[NFTA_LOG_FLAGS]));
 			if (li->u.log.logflags & ~NF_LOG_MASK) {
@@ -100,12 +100,12 @@ static int nft_log_init(const struct nft_ctx *ctx,
 		break;
 	case NF_LOG_TYPE_ULOG:
 		li->u.ulog.group = ntohs(nla_get_be16(tb[NFTA_LOG_GROUP]));
-		if (tb[NFTA_LOG_SNAPLEN] != NULL) {
+		if (tb[NFTA_LOG_SNAPLEN]) {
 			li->u.ulog.flags |= NF_LOG_F_COPY_LEN;
 			li->u.ulog.copy_len =
 				ntohl(nla_get_be32(tb[NFTA_LOG_SNAPLEN]));
 		}
-		if (tb[NFTA_LOG_QTHRESHOLD] != NULL) {
+		if (tb[NFTA_LOG_QTHRESHOLD]) {
 			li->u.ulog.qthreshold =
 				ntohs(nla_get_be16(tb[NFTA_LOG_QTHRESHOLD]));
 		}
diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index e21aea7e5ec8..47c68b06fea4 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -103,7 +103,7 @@ static int nft_lookup_init(const struct nft_ctx *ctx,
 		}
 	}
 
-	if (tb[NFTA_LOOKUP_DREG] != NULL) {
+	if (tb[NFTA_LOOKUP_DREG]) {
 		if (priv->invert)
 			return -EINVAL;
 		if (!(set->flags & NFT_SET_MAP))
diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index 7d699bbd45b0..c324138d5262 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -408,8 +408,8 @@ nft_payload_select_ops(const struct nft_ctx *ctx,
 		return ERR_PTR(-EOPNOTSUPP);
 	}
 
-	if (tb[NFTA_PAYLOAD_SREG] != NULL) {
-		if (tb[NFTA_PAYLOAD_DREG] != NULL)
+	if (tb[NFTA_PAYLOAD_SREG]) {
+		if (tb[NFTA_PAYLOAD_DREG])
 			return ERR_PTR(-EINVAL);
 		return &nft_payload_set_ops;
 	}
diff --git a/net/netfilter/nft_set_hash.c b/net/netfilter/nft_set_hash.c
index 5f652720fc78..ff0357a289a5 100644
--- a/net/netfilter/nft_set_hash.c
+++ b/net/netfilter/nft_set_hash.c
@@ -83,7 +83,7 @@ static bool nft_hash_lookup(const struct net *net, const struct nft_set *set,
 	};
 
 	he = rhashtable_lookup_fast(&priv->ht, &arg, nft_hash_params);
-	if (he != NULL)
+	if (he)
 		*ext = &he->ext;
 
 	return !!he;
@@ -106,7 +106,7 @@ static bool nft_hash_update(struct nft_set *set, const u32 *key,
 	};
 
 	he = rhashtable_lookup_fast(&priv->ht, &arg, nft_hash_params);
-	if (he != NULL)
+	if (he)
 		goto out;
 
 	he = new(set, expr, regs);
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 14857afc9937..f7f4ac911373 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -459,7 +459,7 @@ int xt_check_match(struct xt_mtchk_param *par,
 		       par->match->proto);
 		return -EINVAL;
 	}
-	if (par->match->checkentry != NULL) {
+	if (par->match->checkentry) {
 		ret = par->match->checkentry(par);
 		if (ret < 0)
 			return ret;
@@ -842,7 +842,7 @@ int xt_check_target(struct xt_tgchk_param *par,
 		       par->target->proto);
 		return -EINVAL;
 	}
-	if (par->target->checkentry != NULL) {
+	if (par->target->checkentry) {
 		ret = par->target->checkentry(par);
 		if (ret < 0)
 			return ret;
@@ -1023,7 +1023,7 @@ void xt_free_table_info(struct xt_table_info *info)
 {
 	int cpu;
 
-	if (info->jumpstack != NULL) {
+	if (info->jumpstack) {
 		for_each_possible_cpu(cpu)
 			kvfree(info->jumpstack[cpu]);
 		kvfree(info->jumpstack);
@@ -1401,7 +1401,7 @@ static void *xt_mttg_seq_next(struct seq_file *seq, void *v, loff_t *ppos,
 		return NULL;
 	}
 
-	if (ppos != NULL)
+	if (ppos)
 		++*ppos;
 	return trav;
 }
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 27241a767f17..6dac2c2e40ea 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -64,11 +64,11 @@ static u_int32_t tcpmss_reverse_mtu(struct net *net,
 	}
 	rcu_read_lock();
 	ai = nf_get_afinfo(family);
-	if (ai != NULL)
+	if (ai)
 		ai->route(net, (struct dst_entry **)&rt, &fl, false);
 	rcu_read_unlock();
 
-	if (rt != NULL) {
+	if (rt) {
 		mtu = dst_mtu(&rt->dst);
 		dst_release(&rt->dst);
 	}
diff --git a/net/netfilter/xt_addrtype.c b/net/netfilter/xt_addrtype.c
index e329dabde35f..836e9ba7d55b 100644
--- a/net/netfilter/xt_addrtype.c
+++ b/net/netfilter/xt_addrtype.c
@@ -50,7 +50,7 @@ static u32 match_lookup_rt6(struct net *net, const struct net_device *dev,
 	rcu_read_lock();
 
 	afinfo = nf_get_afinfo(NFPROTO_IPV6);
-	if (afinfo != NULL) {
+	if (afinfo) {
 		const struct nf_ipv6_ops *v6ops;
 
 		if (dev && (mask & XT_ADDRTYPE_LOCAL)) {
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index b8fd4ab762ed..5407e644a929 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -328,7 +328,7 @@ connlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	unsigned int connections;
 
 	ct = nf_ct_get(skb, &ctinfo);
-	if (ct != NULL) {
+	if (ct) {
 		tuple_ptr = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
 		zone = nf_ct_zone(ct);
 	} else if (!nf_ct_get_tuplepr(skb, skb_network_offset(skb),
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.c
index c0fb217bc649..617815b57d71 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -181,7 +181,7 @@ conntrack_mt(const struct sk_buff *skb, struct xt_action_param *par,
 		statebit = XT_CONNTRACK_STATE_INVALID;
 
 	if (info->match_flags & XT_CONNTRACK_STATE) {
-		if (ct != NULL) {
+		if (ct) {
 			if (test_bit(IPS_SRC_NAT_BIT, &ct->status))
 				statebit |= XT_CONNTRACK_STATE_SNAT;
 			if (test_bit(IPS_DST_NAT_BIT, &ct->status))
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 2a6dfe8b74d3..244a4ac1ba58 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -193,7 +193,7 @@ dsthash_alloc_init(struct xt_hashlimit_htable *ht,
 	 * hashtable, double check if this packet lost race.
 	 */
 	ent = dsthash_find(ht, dst);
-	if (ent != NULL) {
+	if (ent) {
 		spin_unlock(&ht->lock);
 		*race = true;
 		return ent;
@@ -368,7 +368,7 @@ static void htable_remove_proc_entry(struct xt_hashlimit_htable *hinfo)
 	else
 		parent = hashlimit_net->ip6t_hashlimit;
 
-	if (parent != NULL)
+	if (parent)
 		remove_proc_entry(hinfo->name, parent);
 }
 
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 1d89a4eaf841..47e7adaec00e 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -374,7 +374,7 @@ static int recent_mt_check(const struct xt_mtchk_param *par,
 
 	mutex_lock(&recent_mutex);
 	t = recent_table_lookup(recent_net, info->name);
-	if (t != NULL) {
+	if (t) {
 		if (nstamp_mask > t->nstamps_max_mask) {
 			spin_lock_bh(&recent_lock);
 			recent_table_flush(t);
@@ -461,7 +461,7 @@ static void recent_mt_destroy(const struct xt_mtdtor_param *par)
 		list_del(&t->list);
 		spin_unlock_bh(&recent_lock);
 #ifdef CONFIG_PROC_FS
-		if (recent_net->xt_recent != NULL)
+		if (recent_net->xt_recent)
 			remove_proc_entry(t->name, recent_net->xt_recent);
 #endif
 		recent_table_flush(t);
@@ -596,7 +596,7 @@ recent_mt_proc_write(struct file *file, const char __user *input,
 
 	++c;
 	--size;
-	if (strnchr(c, size, ':') != NULL) {
+	if (strnchr(c, size, ':')) {
 		family = NFPROTO_IPV6;
 		succ   = in6_pton(c, size, (void *)&addr, '\n', NULL);
 	} else {
-- 
2.11.0

