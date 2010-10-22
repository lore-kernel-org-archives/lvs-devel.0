From: Simon Horman <horms@verge.net.au>
Subject: [rfc v2 03/10] ipvs network name space aware: conn
Date: Fri, 22 Oct 2010 22:09:37 +0200
Message-ID: <20101022202357.344354364@joe.akashicho.tokyo.vergenet.net>
References: <20101022200934.822223308@joe.akashicho.tokyo.vergenet.net>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline; filename=ipvs-netns-3.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, Julian Anastasov <ja@ssi.bg>, Daniel Lezcano <daniel.lezcano@free.fr>, Wensong Zhang <wensong@linux-vs.org>


This patch just contains ip_vs_conn.c
and does the normal
 - moving to vars to struct ipvs
 - adding per netns init and exit

proc_fs required some extra work with adding/chaning private data to get the net ptr.

Signed-off-by:Hans Schillstrom <hans.schillstrom@ericsson.com>

Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_conn.c
===================================================================
--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_conn.c	2010-10-22 21:33:39.000000000 +0200
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_conn.c	2010-10-22 21:34:55.000000000 +0200
@@ -56,23 +56,12 @@ MODULE_PARM_DESC(conn_tab_bits, "Set con
 int ip_vs_conn_tab_size;
 int ip_vs_conn_tab_mask;
 
-/*
- *  Connection hash table: for input and output packets lookups of IPVS
- */
-static struct list_head *ip_vs_conn_tab;
-
-/*  SLAB cache for IPVS connections */
-static struct kmem_cache *ip_vs_conn_cachep __read_mostly;
-
-/*  counter for current IPVS connections */
-static atomic_t ip_vs_conn_count = ATOMIC_INIT(0);
-
-/*  counter for no client port connections */
-static atomic_t ip_vs_conn_no_cport_cnt = ATOMIC_INIT(0);
-
 /* random value for IPVS connection hash */
 static unsigned int ip_vs_conn_rnd;
 
+/* cache name cnt */
+static atomic_t conn_cache_nr = ATOMIC_INIT(0);
+
 /*
  *  Fine locking granularity for big connection hash table
  */
@@ -173,8 +162,8 @@ static unsigned int ip_vs_conn_hashkey_c
 {
 	struct ip_vs_conn_param p;
 
-	ip_vs_conn_fill_param(cp->af, cp->protocol, &cp->caddr, cp->cport,
-			      NULL, 0, &p);
+	ip_vs_conn_fill_param(NULL, cp->af, cp->protocol, &cp->caddr,
+			      cp->cport, NULL, 0, &p);
 
 	if (cp->dest && cp->dest->svc->pe) {
 		p.pe = cp->dest->svc->pe;
@@ -189,7 +178,7 @@ static unsigned int ip_vs_conn_hashkey_c
  *	Hashes ip_vs_conn in ip_vs_conn_tab by proto,addr,port.
  *	returns bool success.
  */
-static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
+static inline int ip_vs_conn_hash(struct net *net, struct ip_vs_conn *cp)
 {
 	unsigned hash;
 	int ret;
@@ -204,7 +193,7 @@ static inline int ip_vs_conn_hash(struct
 	spin_lock(&cp->lock);
 
 	if (!(cp->flags & IP_VS_CONN_F_HASHED)) {
-		list_add(&cp->c_list, &ip_vs_conn_tab[hash]);
+		list_add(&cp->c_list, &net->ipvs->conn_tab[hash]);
 		cp->flags |= IP_VS_CONN_F_HASHED;
 		atomic_inc(&cp->refcnt);
 		ret = 1;
@@ -262,12 +251,13 @@ __ip_vs_conn_in_get(const struct ip_vs_c
 {
 	unsigned hash;
 	struct ip_vs_conn *cp;
+	struct netns_ipvs *ipvs = p->net->ipvs;
 
 	hash = ip_vs_conn_hashkey_param(p, false);
 
 	ct_read_lock(hash);
 
-	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
+	list_for_each_entry(cp, &ipvs->conn_tab[hash], c_list) {
 		if (cp->af == p->af &&
 		    ip_vs_addr_equal(p->af, p->caddr, &cp->caddr) &&
 		    ip_vs_addr_equal(p->af, p->vaddr, &cp->vaddr) &&
@@ -286,12 +276,13 @@ __ip_vs_conn_in_get(const struct ip_vs_c
 	return NULL;
 }
 
-struct ip_vs_conn *ip_vs_conn_in_get(const struct ip_vs_conn_param *p)
+struct ip_vs_conn *
+ip_vs_conn_in_get(const struct ip_vs_conn_param *p)
 {
 	struct ip_vs_conn *cp;
 
 	cp = __ip_vs_conn_in_get(p);
-	if (!cp && atomic_read(&ip_vs_conn_no_cport_cnt)) {
+	if (!cp && atomic_read(&p->net->ipvs->conn_no_cport_cnt)) {
 		struct ip_vs_conn_param cport_zero_p = *p;
 		cport_zero_p.cport = 0;
 		cp = __ip_vs_conn_in_get(&cport_zero_p);
@@ -313,16 +304,19 @@ ip_vs_conn_fill_param_proto(int af, cons
 			    struct ip_vs_conn_param *p)
 {
 	__be16 _ports[2], *pptr;
+	struct net *net = dev_net(skb->dev);
 
 	pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
 	if (pptr == NULL)
 		return 1;
 
 	if (likely(!inverse))
-		ip_vs_conn_fill_param(af, iph->protocol, &iph->saddr, pptr[0],
+		ip_vs_conn_fill_param(net, af, iph->protocol,
+				      &iph->saddr, pptr[0],
 				      &iph->daddr, pptr[1], p);
 	else
-		ip_vs_conn_fill_param(af, iph->protocol, &iph->daddr, pptr[1],
+		ip_vs_conn_fill_param(net, af, iph->protocol,
+				      &iph->daddr, pptr[1],
 				      &iph->saddr, pptr[0], p);
 	return 0;
 }
@@ -347,12 +341,13 @@ struct ip_vs_conn *ip_vs_ct_in_get(const
 {
 	unsigned hash;
 	struct ip_vs_conn *cp;
+	struct netns_ipvs *ipvs = p->net->ipvs;
 
 	hash = ip_vs_conn_hashkey_param(p, false);
 
 	ct_read_lock(hash);
 
-	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
+	list_for_each_entry(cp, &ipvs->conn_tab[hash], c_list) {
 		if (p->pe_data && p->pe->ct_match) {
 			if (p->pe->ct_match(p, cp))
 				goto out;
@@ -394,6 +389,7 @@ struct ip_vs_conn *ip_vs_conn_out_get(co
 {
 	unsigned hash;
 	struct ip_vs_conn *cp, *ret=NULL;
+	struct netns_ipvs *ipvs = p->net->ipvs;
 
 	/*
 	 *	Check for "full" addressed entries
@@ -402,7 +398,7 @@ struct ip_vs_conn *ip_vs_conn_out_get(co
 
 	ct_read_lock(hash);
 
-	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
+	list_for_each_entry(cp, &ipvs->conn_tab[hash], c_list) {
 		if (cp->af == p->af &&
 		    ip_vs_addr_equal(p->af, p->vaddr, &cp->caddr) &&
 		    ip_vs_addr_equal(p->af, p->caddr, &cp->daddr) &&
@@ -457,19 +453,19 @@ void ip_vs_conn_put(struct ip_vs_conn *c
 /*
  *	Fill a no_client_port connection with a client port number
  */
-void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport)
+void ip_vs_conn_fill_cport(struct net *net, struct ip_vs_conn *cp, __be16 cport)
 {
 	if (ip_vs_conn_unhash(cp)) {
 		spin_lock(&cp->lock);
 		if (cp->flags & IP_VS_CONN_F_NO_CPORT) {
-			atomic_dec(&ip_vs_conn_no_cport_cnt);
+			atomic_dec(&net->ipvs->conn_no_cport_cnt);
 			cp->flags &= ~IP_VS_CONN_F_NO_CPORT;
 			cp->cport = cport;
 		}
 		spin_unlock(&cp->lock);
 
 		/* hash on new dport */
-		ip_vs_conn_hash(cp);
+		ip_vs_conn_hash(net, cp);
 	}
 }
 
@@ -606,12 +602,12 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, s
  * Check if there is a destination for the connection, if so
  * bind the connection to the destination.
  */
-struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp)
+struct ip_vs_dest *ip_vs_try_bind_dest(struct net *net, struct ip_vs_conn *cp)
 {
 	struct ip_vs_dest *dest;
 
 	if ((cp) && (!cp->dest)) {
-		dest = ip_vs_find_dest(cp->af, &cp->daddr, cp->dport,
+		dest = ip_vs_find_dest(net, cp->af, &cp->daddr, cp->dport,
 				       &cp->vaddr, cp->vport,
 				       cp->protocol);
 		ip_vs_bind_dest(cp, dest);
@@ -683,7 +679,7 @@ static inline void ip_vs_unbind_dest(str
  *	If available, return 1, otherwise invalidate this connection
  *	template and return 0.
  */
-int ip_vs_check_template(struct ip_vs_conn *ct)
+int ip_vs_check_template(struct net *net, struct ip_vs_conn *ct)
 {
 	struct ip_vs_dest *dest = ct->dest;
 
@@ -692,7 +688,7 @@ int ip_vs_check_template(struct ip_vs_co
 	 */
 	if ((dest == NULL) ||
 	    !(dest->flags & IP_VS_DEST_F_AVAILABLE) ||
-	    (sysctl_ip_vs_expire_quiescent_template &&
+	    (net->ipvs->sysctl_expire_quiescent_template &&
 	     (atomic_read(&dest->weight) == 0))) {
 		IP_VS_DBG_BUF(9, "check_template: dest not available for "
 			      "protocol %s s:%s:%d v:%s:%d "
@@ -713,7 +709,7 @@ int ip_vs_check_template(struct ip_vs_co
 				ct->dport = htons(0xffff);
 				ct->vport = htons(0xffff);
 				ct->cport = 0;
-				ip_vs_conn_hash(ct);
+				ip_vs_conn_hash(net, ct);
 			}
 		}
 
@@ -763,22 +759,22 @@ static void ip_vs_conn_expire(unsigned l
 			ip_vs_control_del(cp);
 
 		if (cp->flags & IP_VS_CONN_F_NFCT)
-			ip_vs_conn_drop_conntrack(/cp);
+			ip_vs_conn_drop_conntrack(cp);
 
 		kfree(cp->pe_data);
 		if (unlikely(cp->app != NULL))
 			ip_vs_unbind_app(cp);
 		ip_vs_unbind_dest(cp);
 		if (cp->flags & IP_VS_CONN_F_NO_CPORT)
-			atomic_dec(&ip_vs_conn_no_cport_cnt);
-		atomic_dec(&ip_vs_conn_count);
+			atomic_dec(&cp->net->ipvs->conn_no_cport_cnt);
+		atomic_dec(&cp->net->ipvs->conn_count);
 
-		kmem_cache_free(ip_vs_conn_cachep, cp);
+		kmem_cache_free(cp->net->ipvs->conn_cachep, cp);
 		return;
 	}
 
 	/* hash it back to the table */
-	ip_vs_conn_hash(cp);
+	ip_vs_conn_hash(cp->net, cp);
 
   expire_later:
 	IP_VS_DBG(7, "delayed: conn->refcnt-1=%d conn->n_control=%d\n",
@@ -795,9 +791,9 @@ void ip_vs_conn_expire_now(struct ip_vs_
 		mod_timer(&cp->timer, jiffies);
 }
 
-
 /*
- *	Create a new connection entry and hash it into the ip_vs_conn_tab
+ *	Create a new connection entry and hash it into the ip_vs_conn_tab,
+ *	netns ptr will be stored in ip_vs_con here.
  */
 struct ip_vs_conn *
 ip_vs_conn_new(const struct ip_vs_conn_param *p,
@@ -805,9 +801,12 @@ ip_vs_conn_new(const struct ip_vs_conn_p
 	       struct ip_vs_dest *dest)
 {
 	struct ip_vs_conn *cp;
-	struct ip_vs_protocol *pp = ip_vs_proto_get(p->protocol);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(p->net,
+							   p->protocol);
+	struct ip_vs_protocol *pp;
+	struct netns_ipvs *ipvs = p->net->ipvs;
 
-	cp = kmem_cache_zalloc(ip_vs_conn_cachep, GFP_ATOMIC);
+	cp = kmem_cache_zalloc(ipvs->conn_cachep, GFP_ATOMIC);
 	if (cp == NULL) {
 		IP_VS_ERR_RL("%s(): no memory\n", __func__);
 		return NULL;
@@ -842,9 +841,9 @@ ip_vs_conn_new(const struct ip_vs_conn_p
 	atomic_set(&cp->n_control, 0);
 	atomic_set(&cp->in_pkts, 0);
 
-	atomic_inc(&ip_vs_conn_count);
+	atomic_inc(&ipvs->conn_count);
 	if (flags & IP_VS_CONN_F_NO_CPORT)
-		atomic_inc(&ip_vs_conn_no_cport_cnt);
+		atomic_inc(&ipvs->conn_no_cport_cnt);
 
 	/* Bind the connection with a destination server */
 	ip_vs_bind_dest(cp, dest);
@@ -861,8 +860,12 @@ ip_vs_conn_new(const struct ip_vs_conn_p
 #endif
 		ip_vs_bind_xmit(cp);
 
-	if (unlikely(pp && atomic_read(&pp->appcnt)))
-		ip_vs_bind_app(cp, pp);
+	cp->net = p->net;	/* netns ptr  needed in timer */
+	if (pd) {
+		pp = pd->pp;
+		if (unlikely(pp && atomic_read(&pd->appcnt)))
+			ip_vs_bind_app(p->net, cp, pp);
+	}
 
 	/*
 	 * Allow conntrack to be preserved. By default, conntrack
@@ -875,11 +878,27 @@ ip_vs_conn_new(const struct ip_vs_conn_p
 		cp->flags |= IP_VS_CONN_F_NFCT;
 
 	/* Hash it in the ip_vs_conn_tab finally */
-	ip_vs_conn_hash(cp);
+	ip_vs_conn_hash(p->net, cp);
 
 	return cp;
 }
 
+struct ipvs_private {
+	struct seq_net_private p;
+	void *private;
+};
+
+static inline void ipvs_seq_priv_set(struct seq_file *seq, void *data)
+{
+	struct ipvs_private *ipriv=(struct ipvs_private *)seq->private;
+	ipriv->private = data;
+}
+
+static inline void *ipvs_seq_priv_get(struct seq_file *seq)
+{
+	return ((struct ipvs_private *)seq->private)->private;
+}
+
 /*
  *	/proc/net/ip_vs_conn entries
  */
@@ -889,13 +908,15 @@ static void *ip_vs_conn_array(struct seq
 {
 	int idx;
 	struct ip_vs_conn *cp;
+	struct net *net = seq_file_net(seq);
+	struct netns_ipvs *ipvs = net->ipvs;
 
 	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
 		ct_read_lock_bh(idx);
-		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
+		list_for_each_entry(cp, &ipvs->conn_tab[idx], c_list) {
 			if (pos-- == 0) {
-				seq->private = &ip_vs_conn_tab[idx];
-			return cp;
+				ipvs_seq_priv_set(seq, &ipvs->conn_tab[idx]);
+				return cp;
 			}
 		}
 		ct_read_unlock_bh(idx);
@@ -906,15 +927,17 @@ static void *ip_vs_conn_array(struct seq
 
 static void *ip_vs_conn_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	seq->private = NULL;
+	ipvs_seq_priv_set(seq, NULL);
 	return *pos ? ip_vs_conn_array(seq, *pos - 1) :SEQ_START_TOKEN;
 }
-
+ /* netns: conn_tab OK */
 static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct ip_vs_conn *cp = v;
-	struct list_head *e, *l = seq->private;
+	struct list_head *e, *l = ipvs_seq_priv_get(seq);
 	int idx;
+	struct net *net = seq_file_net(seq);
+	struct netns_ipvs *ipvs = net->ipvs;
 
 	++*pos;
 	if (v == SEQ_START_TOKEN)
@@ -924,27 +947,28 @@ static void *ip_vs_conn_seq_next(struct
 	if ((e = cp->c_list.next) != l)
 		return list_entry(e, struct ip_vs_conn, c_list);
 
-	idx = l - ip_vs_conn_tab;
+	idx = l - ipvs->conn_tab;
 	ct_read_unlock_bh(idx);
 
 	while (++idx < ip_vs_conn_tab_size) {
 		ct_read_lock_bh(idx);
-		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
-			seq->private = &ip_vs_conn_tab[idx];
+		list_for_each_entry(cp, &ipvs->conn_tab[idx], c_list) {
+			ipvs_seq_priv_set(seq, &ipvs->conn_tab[idx]);
 			return cp;
 		}
 		ct_read_unlock_bh(idx);
 	}
-	seq->private = NULL;
+	ipvs_seq_priv_set(seq, NULL);
 	return NULL;
 }
-
+/* netns: conn_tab OK */
 static void ip_vs_conn_seq_stop(struct seq_file *seq, void *v)
 {
-	struct list_head *l = seq->private;
+	struct list_head *l = ipvs_seq_priv_get(seq);
+	struct net *net = seq_file_net(seq);
 
 	if (l)
-		ct_read_unlock_bh(l - ip_vs_conn_tab);
+		ct_read_unlock_bh(l - net->ipvs->conn_tab);
 }
 
 static int ip_vs_conn_seq_show(struct seq_file *seq, void *v)
@@ -1004,7 +1028,16 @@ static const struct seq_operations ip_vs
 
 static int ip_vs_conn_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &ip_vs_conn_seq_ops);
+	int ret;
+	struct ipvs_private *priv;
+
+	ret = seq_open_net(inode, file, &ip_vs_conn_seq_ops,
+			   sizeof(struct ipvs_private));
+	if (!ret) {
+		priv = ((struct seq_file *)file->private_data)->private;
+		priv->private = NULL;
+	}
+	return ret;
 }
 
 static const struct file_operations ip_vs_conn_fops = {
@@ -1012,7 +1045,8 @@ static const struct file_operations ip_v
 	.open    = ip_vs_conn_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_private,
+
 };
 
 static const char *ip_vs_origin_name(unsigned flags)
@@ -1067,7 +1101,17 @@ static const struct seq_operations ip_vs
 
 static int ip_vs_conn_sync_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &ip_vs_conn_sync_seq_ops);
+	int ret;
+	struct ipvs_private *ipriv;
+
+	ret = seq_open_net(inode, file, &ip_vs_conn_sync_seq_ops,
+			   sizeof(struct ipvs_private));
+	if (!ret) {
+		ipriv = ((struct seq_file *)file->private_data)->private;
+		ipriv->private = NULL;
+	}
+	return ret;
+//	return seq_open(file, &ip_vs_conn_sync_seq_ops);
 }
 
 static const struct file_operations ip_vs_conn_sync_fops = {
@@ -1075,7 +1119,7 @@ static const struct file_operations ip_v
 	.open    = ip_vs_conn_sync_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_private,
 };
 
 #endif
@@ -1112,11 +1156,14 @@ static inline int todrop_entry(struct ip
 	return 1;
 }
 
-/* Called from keventd and must protect itself from softirqs */
-void ip_vs_random_dropentry(void)
+/* Called from keventd and must protect itself from softirqs
+ * netns: conn_tab OK
+ */
+void ip_vs_random_dropentry(struct net *net)
 {
 	int idx;
 	struct ip_vs_conn *cp;
+	struct netns_ipvs *ipvs = net->ipvs;
 
 	/*
 	 * Randomly scan 1/32 of the whole table every second
@@ -1129,7 +1176,7 @@ void ip_vs_random_dropentry(void)
 		 */
 		ct_write_lock_bh(hash);
 
-		list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
+		list_for_each_entry(cp, &ipvs->conn_tab[hash], c_list) {
 			if (cp->flags & IP_VS_CONN_F_TEMPLATE)
 				/* connection template */
 				continue;
@@ -1167,11 +1214,13 @@ void ip_vs_random_dropentry(void)
 
 /*
  *      Flush all the connection entries in the ip_vs_conn_tab
+ * netns: conn_tab OK
  */
-static void ip_vs_conn_flush(void)
+static void ip_vs_conn_flush(struct net *net)
 {
 	int idx;
 	struct ip_vs_conn *cp;
+	struct netns_ipvs *ipvs = net->ipvs;
 
   flush_again:
 	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
@@ -1180,7 +1229,7 @@ static void ip_vs_conn_flush(void)
 		 */
 		ct_write_lock_bh(idx);
 
-		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
+		list_for_each_entry(cp, &ipvs->conn_tab[idx], c_list) {
 
 			IP_VS_DBG(4, "del connection\n");
 			ip_vs_conn_expire_now(cp);
@@ -1194,16 +1243,17 @@ static void ip_vs_conn_flush(void)
 
 	/* the counter may be not NULL, because maybe some conn entries
 	   are run by slow timer handler or unhashed but still referred */
-	if (atomic_read(&ip_vs_conn_count) != 0) {
+	if (atomic_read(&ipvs->conn_count) != 0) {
 		schedule();
 		goto flush_again;
 	}
 }
 
 
-int __init ip_vs_conn_init(void)
+int __net_init __ip_vs_conn_init(struct net *net)
 {
 	int idx;
+	struct netns_ipvs *ipvs = net->ipvs;
 
 	/* Compute size and mask */
 	ip_vs_conn_tab_size = 1 << ip_vs_conn_tab_bits;
@@ -1212,19 +1262,26 @@ int __init ip_vs_conn_init(void)
 	/*
 	 * Allocate the connection hash table and initialize its list heads
 	 */
-	ip_vs_conn_tab = vmalloc(ip_vs_conn_tab_size *
+	ipvs->conn_tab = vmalloc(ip_vs_conn_tab_size *
 				 sizeof(struct list_head));
-	if (!ip_vs_conn_tab)
+	if (!ipvs->conn_tab)
 		return -ENOMEM;
 
 	/* Allocate ip_vs_conn slab cache */
-	ip_vs_conn_cachep = kmem_cache_create("ip_vs_conn",
+	/* Todo: find a better way to name the cache */
+	snprintf(ipvs->conn_cname, sizeof(ipvs->conn_cname)-1,
+			"ipvs_conn_%d", atomic_read(&conn_cache_nr) );
+	atomic_inc(&conn_cache_nr);
+
+	ipvs->conn_cachep = kmem_cache_create(ipvs->conn_cname,
 					      sizeof(struct ip_vs_conn), 0,
 					      SLAB_HWCACHE_ALIGN, NULL);
-	if (!ip_vs_conn_cachep) {
-		vfree(ip_vs_conn_tab);
+	if (!ipvs->conn_cachep) {
+		vfree(ipvs->conn_tab);
 		return -ENOMEM;
 	}
+	atomic_set(&ipvs->conn_count, 0);
+	atomic_set(&ipvs->conn_no_cport_cnt, 0);
 
 	pr_info("Connection hash table configured "
 		"(size=%d, memory=%ldKbytes)\n",
@@ -1234,31 +1291,46 @@ int __init ip_vs_conn_init(void)
 		  sizeof(struct ip_vs_conn));
 
 	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
-		INIT_LIST_HEAD(&ip_vs_conn_tab[idx]);
+		INIT_LIST_HEAD(&ipvs->conn_tab[idx]);
 	}
 
 	for (idx = 0; idx < CT_LOCKARRAY_SIZE; idx++)  {
 		rwlock_init(&__ip_vs_conntbl_lock_array[idx].l);
 	}
 
-	proc_net_fops_create(&init_net, "ip_vs_conn", 0, &ip_vs_conn_fops);
-	proc_net_fops_create(&init_net, "ip_vs_conn_sync", 0, &ip_vs_conn_sync_fops);
-
-	/* calculate the random value for connection hash */
-	get_random_bytes(&ip_vs_conn_rnd, sizeof(ip_vs_conn_rnd));
+	proc_net_fops_create(net, "ip_vs_conn", 0, &ip_vs_conn_fops);
+	proc_net_fops_create(net, "ip_vs_conn_sync", 0, &ip_vs_conn_sync_fops);
 
 	return 0;
 }
+/* Cleanup and release all netns related ... */
+static void __net_exit __ip_vs_conn_cleanup(struct net *net) {
 
+	/* flush all the connection entries first */
+	ip_vs_conn_flush(net);
+	/* Release the empty cache */
+	kmem_cache_destroy(net->ipvs->conn_cachep);
+	proc_net_remove(net, "ip_vs_conn");
+	proc_net_remove(net, "ip_vs_conn_sync");
+	vfree(net->ipvs->conn_tab);
+}
+static struct pernet_operations ipvs_conn_ops = {
+	.init = __ip_vs_conn_init,
+	.exit = __ip_vs_conn_cleanup,
+};
 
-void ip_vs_conn_cleanup(void)
+int __init ip_vs_conn_init(void)
 {
-	/* flush all the connection entries first */
-	ip_vs_conn_flush();
+	int rv;
 
-	/* Release the empty cache */
-	kmem_cache_destroy(ip_vs_conn_cachep);
-	proc_net_remove(&init_net, "ip_vs_conn");
-	proc_net_remove(&init_net, "ip_vs_conn_sync");
-	vfree(ip_vs_conn_tab);
+	rv = register_pernet_subsys(&ipvs_conn_ops);
+
+	/* calculate the random value for connection hash */
+	get_random_bytes(&ip_vs_conn_rnd, sizeof(ip_vs_conn_rnd));
+	return rv;
+}
+
+void ip_vs_conn_cleanup(void)
+{
+	unregister_pernet_subsys(&ipvs_conn_ops);
 }
Index: lvs-test-2.6/include/net/ip_vs.h
===================================================================
--- lvs-test-2.6.orig/include/net/ip_vs.h	2010-10-22 21:34:49.000000000 +0200
+++ lvs-test-2.6/include/net/ip_vs.h	2010-10-22 21:35:00.000000000 +0200
@@ -1060,9 +1060,9 @@ static inline void ip_vs_notrack(struct
  *      Netfilter connection tracking
  *      (from ip_vs_nfct.c)
  */
-static inline int ip_vs_conntrack_enabled(void)
+static inline int ip_vs_conntrack_enabled(struct net *net)
 {
-	return sysctl_ip_vs_conntrack;
+	return net->ipvs->sysctl_conntrack;
 }
 
 extern void ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp,
@@ -1075,7 +1075,7 @@ extern void ip_vs_conn_drop_conntrack(st
 
 #else
 
-static inline int ip_vs_conntrack_enabled(void)
+static inline int ip_vs_conntrack_enabled(struct net *net)
 {
 	return 0;
 }

