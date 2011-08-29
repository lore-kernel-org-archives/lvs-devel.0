From: Joe Perches <joe@perches.com>
Subject: [PATCH 06/24] netfilter: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:25 -0700
Message-ID: <13c1c12486cae409dfa5254b1435e660f2b17e05.1314650069.git.joe@perches.com>
References: <cover.1314650069.git.joe@perches.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <cover.1314650069.git.joe@perches.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bart De Schuymer <bart.de.schuymer@pandora.be>, Patrick McHardy <kaber@trash.net>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, James Morris <jmorris@namei.org>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, bridge@lists.linux-foundation.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org

Removing unnecessary messages saves code and text.

Site specific OOM messages are duplications of a generic MM
out of memory message and aren't really useful, so just
delete them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/bridge/netfilter/ebt_ulog.c         |    7 +++----
 net/ipv4/netfilter/ipt_CLUSTERIP.c      |    1 -
 net/ipv4/netfilter/ipt_ULOG.c           |    4 +---
 net/ipv4/netfilter/nf_nat_snmp_basic.c  |   22 ++--------------------
 net/ipv6/netfilter/nf_conntrack_reasm.c |    7 +++----
 net/netfilter/ipset/ip_set_core.c       |    4 +---
 net/netfilter/ipvs/ip_vs_core.c         |    5 ++---
 net/netfilter/ipvs/ip_vs_ctl.c          |   18 ++++++------------
 net/netfilter/ipvs/ip_vs_dh.c           |    5 ++---
 net/netfilter/ipvs/ip_vs_lblc.c         |    9 +++------
 net/netfilter/ipvs/ip_vs_lblcr.c        |   13 ++++---------
 net/netfilter/ipvs/ip_vs_proto.c        |    5 ++---
 net/netfilter/ipvs/ip_vs_sh.c           |    5 ++---
 net/netfilter/ipvs/ip_vs_wrr.c          |    5 ++---
 net/netfilter/nf_conntrack_core.c       |    5 +----
 net/netfilter/nfnetlink_log.c           |    7 ++-----
 net/netfilter/xt_IDLETIMER.c            |    2 --
 net/netfilter/xt_hashlimit.c            |    5 +----
 18 files changed, 37 insertions(+), 92 deletions(-)

diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index bf2a333..5449294 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -102,16 +102,15 @@ static struct sk_buff *ulog_alloc_skb(unsigned int size)
 	unsigned int n;
 
 	n = max(size, nlbufsiz);
-	skb = alloc_skb(n, GFP_ATOMIC);
+	skb = alloc_skb(n, GFP_ATOMIC | __GFP_NOWARN);
 	if (!skb) {
-		pr_debug("cannot alloc whole buffer of size %ub!\n", n);
 		if (n > size) {
 			/* try to allocate only as much as we need for
 			 * current packet */
 			skb = alloc_skb(size, GFP_ATOMIC);
 			if (!skb)
-				pr_debug("cannot even allocate "
-					 "buffer of size %ub\n", size);
+				pr_debug("cannot even allocate buffer of size %ub\n",
+					 size);
 		}
 	}
 
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index db8d22d..a639967 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -395,7 +395,6 @@ static int clusterip_tg_check(const struct xt_tgchk_param *par)
 			config = clusterip_config_init(cipinfo,
 							e->ip.dst.s_addr, dev);
 			if (!config) {
-				pr_info("cannot allocate config\n");
 				dev_put(dev);
 				return -ENOMEM;
 			}
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index 446e0f4..b550815 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -135,10 +135,8 @@ static struct sk_buff *ulog_alloc_skb(unsigned int size)
 	 * due to slab allocator restrictions */
 
 	n = max(size, nlbufsiz);
-	skb = alloc_skb(n, GFP_ATOMIC);
+	skb = alloc_skb(n, GFP_ATOMIC | __GFP_NOWARN);
 	if (!skb) {
-		pr_debug("cannot alloc whole buffer %ub!\n", n);
-
 		if (n > size) {
 			/* try to allocate only as much as we need for
 			 * current packet */
diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index d1cb412..2133c30 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -400,11 +400,8 @@ static unsigned char asn1_octets_decode(struct asn1_ctx *ctx,
 	*len = 0;
 
 	*octets = kmalloc(eoc - ctx->pointer, GFP_ATOMIC);
-	if (*octets == NULL) {
-		if (net_ratelimit())
-			pr_notice("OOM in bsalg (%d)\n", __LINE__);
+	if (*octets == NULL)
 		return 0;
-	}
 
 	ptr = *octets;
 	while (ctx->pointer < eoc) {
@@ -451,11 +448,8 @@ static unsigned char asn1_oid_decode(struct asn1_ctx *ctx,
 		return 0;
 
 	*oid = kmalloc(size * sizeof(unsigned long), GFP_ATOMIC);
-	if (*oid == NULL) {
-		if (net_ratelimit())
-			pr_notice("OOM in bsalg (%d)\n", __LINE__);
+	if (*oid == NULL)
 		return 0;
-	}
 
 	optr = *oid;
 
@@ -728,8 +722,6 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 		*obj = kmalloc(sizeof(struct snmp_object) + len, GFP_ATOMIC);
 		if (*obj == NULL) {
 			kfree(id);
-			if (net_ratelimit())
-				pr_notice("OOM in bsalg (%d)\n", __LINE__);
 			return 0;
 		}
 		(*obj)->syntax.l[0] = l;
@@ -744,8 +736,6 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 		if (*obj == NULL) {
 			kfree(p);
 			kfree(id);
-			if (net_ratelimit())
-				pr_notice("OOM in bsalg (%d)\n", __LINE__);
 			return 0;
 		}
 		memcpy((*obj)->syntax.c, p, len);
@@ -759,8 +749,6 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 		*obj = kmalloc(sizeof(struct snmp_object), GFP_ATOMIC);
 		if (*obj == NULL) {
 			kfree(id);
-			if (net_ratelimit())
-				pr_notice("OOM in bsalg (%d)\n", __LINE__);
 			return 0;
 		}
 		if (!asn1_null_decode(ctx, end)) {
@@ -780,8 +768,6 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 		if (*obj == NULL) {
 			kfree(lp);
 			kfree(id);
-			if (net_ratelimit())
-				pr_notice("OOM in bsalg (%d)\n", __LINE__);
 			return 0;
 		}
 		memcpy((*obj)->syntax.ul, lp, len);
@@ -801,8 +787,6 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 		if (*obj == NULL) {
 			kfree(p);
 			kfree(id);
-			if (net_ratelimit())
-				pr_notice("OOM in bsalg (%d)\n", __LINE__);
 			return 0;
 		}
 		memcpy((*obj)->syntax.uc, p, len);
@@ -819,8 +803,6 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 		*obj = kmalloc(sizeof(struct snmp_object) + len, GFP_ATOMIC);
 		if (*obj == NULL) {
 			kfree(id);
-			if (net_ratelimit())
-				pr_notice("OOM in bsalg (%d)\n", __LINE__);
 			return 0;
 		}
 		(*obj)->syntax.ul[0] = ul;
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 0857272..f2f2523 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -182,7 +182,6 @@ fq_find(__be32 id, u32 user, struct in6_addr *src, struct in6_addr *dst)
 	return container_of(q, struct nf_ct_frag6_queue, q);
 
 oom:
-	pr_debug("Can't alloc new queue\n");
 	return NULL;
 }
 
@@ -370,10 +369,10 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 		struct sk_buff *clone;
 		int i, plen = 0;
 
-		if ((clone = alloc_skb(0, GFP_ATOMIC)) == NULL) {
-			pr_debug("Can't alloc skb\n");
+		clone = alloc_skb(0, GFP_ATOMIC);
+		if (clone == NULL)
 			goto out_oom;
-		}
+
 		clone->next = head->next;
 		head->next = clone;
 		skb_shinfo(clone)->frag_list = skb_shinfo(head)->frag_list;
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index d7e86ef..86137b5 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1699,10 +1699,8 @@ ip_set_init(void)
 
 	ip_set_list = kzalloc(sizeof(struct ip_set *) * ip_set_max,
 			      GFP_KERNEL);
-	if (!ip_set_list) {
-		pr_err("ip_set: Unable to create ip_set_list\n");
+	if (!ip_set_list)
 		return -ENOMEM;
-	}
 
 	ret = nfnetlink_subsys_register(&ip_set_netlink_subsys);
 	if (ret != 0) {
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 4f77bb1..67d7ff7 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1878,10 +1878,9 @@ static int __net_init __ip_vs_init(struct net *net)
 	struct netns_ipvs *ipvs;
 
 	ipvs = net_generic(net, ip_vs_net_id);
-	if (ipvs == NULL) {
-		pr_err("%s(): no memory.\n", __func__);
+	if (ipvs == NULL)
 		return -ENOMEM;
-	}
+
 	/* Hold the beast until a service is registerd */
 	ipvs->enable = 0;
 	ipvs->net = net;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 2b771dc..1d1926c 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -856,15 +856,12 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 	}
 
 	dest = kzalloc(sizeof(struct ip_vs_dest), GFP_KERNEL);
-	if (dest == NULL) {
-		pr_err("%s(): no memory.\n", __func__);
+	if (dest == NULL)
 		return -ENOMEM;
-	}
+
 	dest->stats.cpustats = alloc_percpu(struct ip_vs_cpu_stats);
-	if (!dest->stats.cpustats) {
-		pr_err("%s() alloc_percpu failed\n", __func__);
+	if (!dest->stats.cpustats)
 		goto err_alloc;
-	}
 
 	dest->af = svc->af;
 	dest->protocol = svc->protocol;
@@ -1168,10 +1165,8 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 		goto out_err;
 	}
 	svc->stats.cpustats = alloc_percpu(struct ip_vs_cpu_stats);
-	if (!svc->stats.cpustats) {
-		pr_err("%s() alloc_percpu failed\n", __func__);
+	if (!svc->stats.cpustats)
 		goto out_err;
-	}
 
 	/* I'm the first user of the service */
 	atomic_set(&svc->usecnt, 0);
@@ -3691,10 +3686,9 @@ int __net_init ip_vs_control_net_init(struct net *net)
 
 	/* procfs stats */
 	ipvs->tot_stats.cpustats = alloc_percpu(struct ip_vs_cpu_stats);
-	if (!ipvs->tot_stats.cpustats) {
-		pr_err("%s(): alloc_percpu.\n", __func__);
+	if (!ipvs->tot_stats.cpustats)
 		return -ENOMEM;
-	}
+
 	spin_lock_init(&ipvs->tot_stats.lock);
 
 	proc_net_fops_create(net, "ip_vs", 0, &ip_vs_info_fops);
diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index 95fd0d1..1c269e5 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -150,10 +150,9 @@ static int ip_vs_dh_init_svc(struct ip_vs_service *svc)
 	/* allocate the DH table for this service */
 	tbl = kmalloc(sizeof(struct ip_vs_dh_bucket)*IP_VS_DH_TAB_SIZE,
 		      GFP_ATOMIC);
-	if (tbl == NULL) {
-		pr_err("%s(): no memory\n", __func__);
+	if (tbl == NULL)
 		return -ENOMEM;
-	}
+
 	svc->sched_data = tbl;
 	IP_VS_DBG(6, "DH hash table (memory=%Zdbytes) allocated for "
 		  "current service\n",
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 87e40ea..0f16283 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -202,10 +202,8 @@ ip_vs_lblc_new(struct ip_vs_lblc_table *tbl, const union nf_inet_addr *daddr,
 	en = ip_vs_lblc_get(dest->af, tbl, daddr);
 	if (!en) {
 		en = kmalloc(sizeof(*en), GFP_ATOMIC);
-		if (!en) {
-			pr_err("%s(): no memory\n", __func__);
+		if (!en)
 			return NULL;
-		}
 
 		en->af = dest->af;
 		ip_vs_addr_copy(dest->af, &en->addr, daddr);
@@ -345,10 +343,9 @@ static int ip_vs_lblc_init_svc(struct ip_vs_service *svc)
 	 *    Allocate the ip_vs_lblc_table for this service
 	 */
 	tbl = kmalloc(sizeof(*tbl), GFP_ATOMIC);
-	if (tbl == NULL) {
-		pr_err("%s(): no memory\n", __func__);
+	if (tbl == NULL)
 		return -ENOMEM;
-	}
+
 	svc->sched_data = tbl;
 	IP_VS_DBG(6, "LBLC hash table (memory=%Zdbytes) allocated for "
 		  "current service\n", sizeof(*tbl));
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 90f618a..eec797f 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -112,10 +112,8 @@ ip_vs_dest_set_insert(struct ip_vs_dest_set *set, struct ip_vs_dest *dest)
 	}
 
 	e = kmalloc(sizeof(*e), GFP_ATOMIC);
-	if (e == NULL) {
-		pr_err("%s(): no memory\n", __func__);
+	if (e == NULL)
 		return NULL;
-	}
 
 	atomic_inc(&dest->refcnt);
 	e->dest = dest;
@@ -373,10 +371,8 @@ ip_vs_lblcr_new(struct ip_vs_lblcr_table *tbl, const union nf_inet_addr *daddr,
 	en = ip_vs_lblcr_get(dest->af, tbl, daddr);
 	if (!en) {
 		en = kmalloc(sizeof(*en), GFP_ATOMIC);
-		if (!en) {
-			pr_err("%s(): no memory\n", __func__);
+		if (!en)
 			return NULL;
-		}
 
 		en->af = dest->af;
 		ip_vs_addr_copy(dest->af, &en->addr, daddr);
@@ -516,10 +512,9 @@ static int ip_vs_lblcr_init_svc(struct ip_vs_service *svc)
 	 *    Allocate the ip_vs_lblcr_table for this service
 	 */
 	tbl = kmalloc(sizeof(*tbl), GFP_ATOMIC);
-	if (tbl == NULL) {
-		pr_err("%s(): no memory\n", __func__);
+	if (tbl == NULL)
 		return -ENOMEM;
-	}
+
 	svc->sched_data = tbl;
 	IP_VS_DBG(6, "LBLCR hash table (memory=%Zdbytes) allocated for "
 		  "current service\n", sizeof(*tbl));
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 52d073c..8531293 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -74,10 +74,9 @@ register_ip_vs_proto_netns(struct net *net, struct ip_vs_protocol *pp)
 	struct ip_vs_proto_data *pd =
 			kzalloc(sizeof(struct ip_vs_proto_data), GFP_ATOMIC);
 
-	if (!pd) {
-		pr_err("%s(): no memory.\n", __func__);
+	if (!pd)
 		return -ENOMEM;
-	}
+
 	pd->pp = pp;	/* For speed issues */
 	pd->next = ipvs->proto_data_table[hash];
 	ipvs->proto_data_table[hash] = pd;
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index b5e2556..33815f4 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -147,10 +147,9 @@ static int ip_vs_sh_init_svc(struct ip_vs_service *svc)
 	/* allocate the SH table for this service */
 	tbl = kmalloc(sizeof(struct ip_vs_sh_bucket)*IP_VS_SH_TAB_SIZE,
 		      GFP_ATOMIC);
-	if (tbl == NULL) {
-		pr_err("%s(): no memory\n", __func__);
+	if (tbl == NULL)
 		return -ENOMEM;
-	}
+
 	svc->sched_data = tbl;
 	IP_VS_DBG(6, "SH hash table (memory=%Zdbytes) allocated for "
 		  "current service\n",
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index 1ef41f5..fd0d4e0 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -85,10 +85,9 @@ static int ip_vs_wrr_init_svc(struct ip_vs_service *svc)
 	 *    Allocate the mark variable for WRR scheduling
 	 */
 	mark = kmalloc(sizeof(struct ip_vs_wrr_mark), GFP_ATOMIC);
-	if (mark == NULL) {
-		pr_err("%s(): no memory\n", __func__);
+	if (mark == NULL)
 		return -ENOMEM;
-	}
+
 	mark->cl = &svc->destinations;
 	mark->cw = 0;
 	mark->mw = ip_vs_wrr_max_weight(svc);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 5acfaf5..7202b06 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -661,7 +661,6 @@ __nf_conntrack_alloc(struct net *net, u16 zone,
 	 */
 	ct = kmem_cache_alloc(net->ct.nf_conntrack_cachep, gfp);
 	if (ct == NULL) {
-		pr_debug("nf_conntrack_alloc: Can't alloc conntrack.\n");
 		atomic_dec(&net->ct.count);
 		return ERR_PTR(-ENOMEM);
 	}
@@ -749,10 +748,8 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 
 	ct = __nf_conntrack_alloc(net, zone, tuple, &repl_tuple, GFP_ATOMIC,
 				  hash);
-	if (IS_ERR(ct)) {
-		pr_debug("Can't allocate conntrack.\n");
+	if (IS_ERR(ct))
 		return (struct nf_conntrack_tuple_hash *)ct;
-	}
 
 	if (!l4proto->new(ct, skb, dataoff)) {
 		nf_conntrack_free(ct);
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 2d8158a..66b2c54 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -307,17 +307,14 @@ nfulnl_alloc_skb(unsigned int inst_size, unsigned int pkt_size)
 	n = max(inst_size, pkt_size);
 	skb = alloc_skb(n, GFP_ATOMIC);
 	if (!skb) {
-		pr_notice("nfnetlink_log: can't alloc whole buffer (%u bytes)\n",
-			inst_size);
-
 		if (n > pkt_size) {
 			/* try to allocate only as much as we need for current
 			 * packet */
 
 			skb = alloc_skb(pkt_size, GFP_ATOMIC);
 			if (!skb)
-				pr_err("nfnetlink_log: can't even alloc %u "
-				       "bytes\n", pkt_size);
+				pr_err("nfnetlink_log: can't even alloc %u bytes\n",
+				       pkt_size);
 		}
 	}
 
diff --git a/net/netfilter/xt_IDLETIMER.c b/net/netfilter/xt_IDLETIMER.c
index 3bdd443..f407ebc1 100644
--- a/net/netfilter/xt_IDLETIMER.c
+++ b/net/netfilter/xt_IDLETIMER.c
@@ -122,14 +122,12 @@ static int idletimer_tg_create(struct idletimer_tg_info *info)
 
 	info->timer = kmalloc(sizeof(*info->timer), GFP_KERNEL);
 	if (!info->timer) {
-		pr_debug("couldn't alloc timer\n");
 		ret = -ENOMEM;
 		goto out;
 	}
 
 	info->timer->attr.attr.name = kstrdup(info->label, GFP_KERNEL);
 	if (!info->timer->attr.attr.name) {
-		pr_debug("couldn't alloc attribute name\n");
 		ret = -ENOMEM;
 		goto out_free_timer;
 	}
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 9228ee0..dfd52ba 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -176,10 +176,7 @@ dsthash_alloc_init(struct xt_hashlimit_htable *ht,
 		ent = NULL;
 	} else
 		ent = kmem_cache_alloc(hashlimit_cachep, GFP_ATOMIC);
-	if (!ent) {
-		if (net_ratelimit())
-			pr_err("cannot allocate dsthash_ent\n");
-	} else {
+	if (ent) {
 		memcpy(&ent->dst, dst, sizeof(ent->dst));
 		spin_lock_init(&ent->lock);
 
-- 
1.7.6.405.gc1be0

