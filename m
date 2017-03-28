From: simran singhal <singhalsimran0@gmail.com>
Subject: [PATCH v2] netfilter: Clean up tests if NULL returned on failure
Date: Tue, 28 Mar 2017 18:43:40 +0530
Message-ID: <20170328131340.GA19688@singhal-Inspiron-5558>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=NpBKd5LC3CpDOJo+pD5WNUeIFwyR0hCmGtJZAikp3Jo=;
        b=Jnc8EtBp37cICRupZcING/TBLf8609aqFVUuf+u+PkENziaRBG0N9CT4S+IxohEgjt
         sK60cMhrVBzdpn1fUyyM7BChFKIfyE7/+sDAZAJj62QOnENMmgB6t5AntPCNVVuqzj/2
         Oa16nOJXpa9EJLTqy5ULNeNd7IXRGvJIAGHGaWZXZzAhW+GMRFTvyqI6p4iMKKYVQcIU
         2uY86vIt695DJRfkjw2wnmEXoDDEXVMDgqrbKQneYqFQOSd6/b0Sha0MlKHBzCFZ4kFM
         PSgv7Wse4my/D3tCl/a8v/DgSfd/FXMDafNy0qrIPw6HhPwg7DnnKnjUBQ1LsKqTaDnn
         skmw==
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, outreachy-kernel@googlegroups.com

Some functions like kmalloc/kzalloc return NULL on failure. When NULL
represents failure, !x is commonly used.

Signed-off-by: simran singhal <singhalsimran0@gmail.com>
---
 
 v2:
   -squash all the patches of the patch-set.
 
 net/netfilter/ipvs/ip_vs_ctl.c       |  4 ++--
 net/netfilter/ipvs/ip_vs_dh.c        |  2 +-
 net/netfilter/ipvs/ip_vs_lblc.c      |  2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c     |  4 ++--
 net/netfilter/ipvs/ip_vs_sh.c        |  2 +-
 net/netfilter/ipvs/ip_vs_wrr.c       |  2 +-
 net/netfilter/nf_conntrack_netlink.c |  2 +-
 net/netfilter/nf_conntrack_proto.c   |  2 +-
 net/netfilter/nf_nat_core.c          |  2 +-
 net/netfilter/nf_tables_api.c        | 24 ++++++++++++------------
 net/netfilter/nfnetlink.c            |  2 +-
 net/netfilter/xt_TEE.c               |  2 +-
 12 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 5aeb0dd..efe348a 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -910,7 +910,7 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 	}
 
 	dest = kzalloc(sizeof(struct ip_vs_dest), GFP_KERNEL);
-	if (dest == NULL)
+	if (!dest)
 		return -ENOMEM;
 
 	dest->stats.cpustats = alloc_percpu(struct ip_vs_cpu_stats);
@@ -1228,7 +1228,7 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 #endif
 
 	svc = kzalloc(sizeof(struct ip_vs_service), GFP_KERNEL);
-	if (svc == NULL) {
+	if (!svc) {
 		IP_VS_DBG(1, "%s(): no memory\n", __func__);
 		ret = -ENOMEM;
 		goto out_err;
diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index 75f798f..22a2535 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -159,7 +159,7 @@ static int ip_vs_dh_init_svc(struct ip_vs_service *svc)
 
 	/* allocate the DH table for this service */
 	s = kzalloc(sizeof(struct ip_vs_dh_state), GFP_KERNEL);
-	if (s == NULL)
+	if (!s)
 		return -ENOMEM;
 
 	svc->sched_data = s;
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 5824927..d7c6031 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -352,7 +352,7 @@ static int ip_vs_lblc_init_svc(struct ip_vs_service *svc)
 	 *    Allocate the ip_vs_lblc_table for this service
 	 */
 	tbl = kmalloc(sizeof(*tbl), GFP_KERNEL);
-	if (tbl == NULL)
+	if (!tbl)
 		return -ENOMEM;
 
 	svc->sched_data = tbl;
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 703f118..b0a9e1c 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -113,7 +113,7 @@ static void ip_vs_dest_set_insert(struct ip_vs_dest_set *set,
 	}
 
 	e = kmalloc(sizeof(*e), GFP_ATOMIC);
-	if (e == NULL)
+	if (!e)
 		return;
 
 	ip_vs_dest_hold(dest);
@@ -515,7 +515,7 @@ static int ip_vs_lblcr_init_svc(struct ip_vs_service *svc)
 	 *    Allocate the ip_vs_lblcr_table for this service
 	 */
 	tbl = kmalloc(sizeof(*tbl), GFP_KERNEL);
-	if (tbl == NULL)
+	if (!tbl)
 		return -ENOMEM;
 
 	svc->sched_data = tbl;
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 16aaac6..99f3c3e 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -235,7 +235,7 @@ static int ip_vs_sh_init_svc(struct ip_vs_service *svc)
 
 	/* allocate the SH table for this service */
 	s = kzalloc(sizeof(struct ip_vs_sh_state), GFP_KERNEL);
-	if (s == NULL)
+	if (!s)
 		return -ENOMEM;
 
 	svc->sched_data = s;
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index 17e6d44..0923e6c 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -116,7 +116,7 @@ static int ip_vs_wrr_init_svc(struct ip_vs_service *svc)
 	 *    Allocate the mark variable for WRR scheduling
 	 */
 	mark = kmalloc(sizeof(struct ip_vs_wrr_mark), GFP_KERNEL);
-	if (mark == NULL)
+	if (!mark)
 		return -ENOMEM;
 
 	mark->cl = list_entry(&svc->destinations, struct ip_vs_dest, n_list);
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 6806b5e..cdcf4c1 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -779,7 +779,7 @@ ctnetlink_alloc_filter(const struct nlattr * const cda[])
 	struct ctnetlink_filter *filter;
 
 	filter = kzalloc(sizeof(*filter), GFP_KERNEL);
-	if (filter == NULL)
+	if (!filter)
 		return ERR_PTR(-ENOMEM);
 
 	filter->mark.val = ntohl(nla_get_be32(cda[CTA_MARK]));
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 2d6ee18..48d8354 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -358,7 +358,7 @@ int nf_ct_l4proto_register_one(struct nf_conntrack_l4proto *l4proto)
 		proto_array = kmalloc(MAX_NF_CT_PROTO *
 				      sizeof(struct nf_conntrack_l4proto *),
 				      GFP_KERNEL);
-		if (proto_array == NULL) {
+		if (!proto_array) {
 			ret = -ENOMEM;
 			goto out_unlock;
 		}
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 94b14c5..922bd5b 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -626,7 +626,7 @@ int nf_nat_l4proto_register(u8 l3proto, const struct nf_nat_l4proto *l4proto)
 	if (nf_nat_l4protos[l3proto] == NULL) {
 		l4protos = kmalloc(IPPROTO_MAX * sizeof(struct nf_nat_l4proto *),
 				   GFP_KERNEL);
-		if (l4protos == NULL) {
+		if (!l4protos) {
 			ret = -ENOMEM;
 			goto out;
 		}
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 434c739..b7645d7 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -117,7 +117,7 @@ static struct nft_trans *nft_trans_alloc_gfp(const struct nft_ctx *ctx,
 	struct nft_trans *trans;
 
 	trans = kzalloc(sizeof(struct nft_trans) + size, gfp);
-	if (trans == NULL)
+	if (!trans)
 		return NULL;
 
 	trans->msg_type = msg_type;
@@ -720,7 +720,7 @@ static int nf_tables_newtable(struct net *net, struct sock *nlsk,
 
 	err = -ENOMEM;
 	table = kzalloc(sizeof(*table), GFP_KERNEL);
-	if (table == NULL)
+	if (!table)
 		goto err2;
 
 	nla_strlcpy(table->name, name, NFT_TABLE_MAXNAMELEN);
@@ -1478,7 +1478,7 @@ static int nf_tables_newchain(struct net *net, struct sock *nlsk,
 			return err;
 
 		basechain = kzalloc(sizeof(*basechain), GFP_KERNEL);
-		if (basechain == NULL) {
+		if (!basechain) {
 			nft_chain_release_hook(&hook);
 			return -ENOMEM;
 		}
@@ -1526,7 +1526,7 @@ static int nf_tables_newchain(struct net *net, struct sock *nlsk,
 		basechain->policy = policy;
 	} else {
 		chain = kzalloc(sizeof(*chain), GFP_KERNEL);
-		if (chain == NULL)
+		if (!chain)
 			return -ENOMEM;
 	}
 
@@ -1800,7 +1800,7 @@ struct nft_expr *nft_expr_init(const struct nft_ctx *ctx,
 
 	err = -ENOMEM;
 	expr = kzalloc(info.ops->size, GFP_KERNEL);
-	if (expr == NULL)
+	if (!expr)
 		goto err2;
 
 	err = nf_tables_newexpr(ctx, &info, expr);
@@ -2214,7 +2214,7 @@ static int nf_tables_newrule(struct net *net, struct sock *nlsk,
 
 	err = -ENOMEM;
 	rule = kzalloc(sizeof(*rule) + size + usize, GFP_KERNEL);
-	if (rule == NULL)
+	if (!rule)
 		goto err1;
 
 	nft_activate_next(net, rule);
@@ -2810,7 +2810,7 @@ static int nf_tables_getset(struct net *net, struct sock *nlsk,
 		struct nft_ctx *ctx_dump;
 
 		ctx_dump = kmalloc(sizeof(*ctx_dump), GFP_KERNEL);
-		if (ctx_dump == NULL)
+		if (!ctx_dump)
 			return -ENOMEM;
 
 		*ctx_dump = ctx;
@@ -3014,7 +3014,7 @@ static int nf_tables_newset(struct net *net, struct sock *nlsk,
 
 	err = -ENOMEM;
 	set = kzalloc(sizeof(*set) + size + udlen, GFP_KERNEL);
-	if (set == NULL)
+	if (!set)
 		goto err1;
 
 	nla_strlcpy(name, nla[NFTA_SET_NAME], sizeof(set->name));
@@ -3541,7 +3541,7 @@ void *nft_set_elem_init(const struct nft_set *set,
 	void *elem;
 
 	elem = kzalloc(set->ops->elemsize + tmpl->len, gfp);
-	if (elem == NULL)
+	if (!elem)
 		return NULL;
 
 	ext = nft_set_elem_ext(set, elem);
@@ -3995,7 +3995,7 @@ struct nft_set_gc_batch *nft_set_gc_batch_alloc(const struct nft_set *set,
 	struct nft_set_gc_batch *gcb;
 
 	gcb = kzalloc(sizeof(*gcb), gfp);
-	if (gcb == NULL)
+	if (!gcb)
 		return gcb;
 	gcb->head.set = set;
 	return gcb;
@@ -4081,7 +4081,7 @@ static struct nft_object *nft_obj_init(const struct nft_object_type *type,
 
 	err = -ENOMEM;
 	obj = kzalloc(sizeof(struct nft_object) + type->size, GFP_KERNEL);
-	if (obj == NULL)
+	if (!obj)
 		goto err1;
 
 	err = type->init((const struct nlattr * const *)tb, obj);
@@ -5563,7 +5563,7 @@ static int __init nf_tables_module_init(void)
 
 	info = kmalloc(sizeof(struct nft_expr_info) * NFT_RULE_MAXEXPRS,
 		       GFP_KERNEL);
-	if (info == NULL) {
+	if (!info) {
 		err = -ENOMEM;
 		goto err1;
 	}
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 68eda920..c39f16c 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -232,7 +232,7 @@ static int nfnl_err_add(struct list_head *list, struct nlmsghdr *nlh, int err)
 	struct nfnl_err *nfnl_err;
 
 	nfnl_err = kmalloc(sizeof(struct nfnl_err), GFP_KERNEL);
-	if (nfnl_err == NULL)
+	if (!nfnl_err)
 		return -ENOMEM;
 
 	nfnl_err->nlh = nlh;
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index 86b0580..5df3282 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -95,7 +95,7 @@ static int tee_tg_check(const struct xt_tgchk_param *par)
 			return -EINVAL;
 
 		priv = kzalloc(sizeof(*priv), GFP_KERNEL);
-		if (priv == NULL)
+		if (!priv)
 			return -ENOMEM;
 
 		priv->tginfo  = info;
-- 
2.7.4

