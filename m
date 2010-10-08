From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [RFC PATCH 3/9] ipvs network name space aware
Date: Fri, 8 Oct 2010 13:16:57 +0200
Message-ID: <201010081316.57914.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr


This patch just contains ip_vs_conn.c
and does the normal
 - moving to vars to struct ipvs
 - adding per netns init and exit

proc_fs required some extra work with adding/chaning private data to get the net ptr.

Signed-off-by:Hans Schillstrom <hans.schillstrom@ericsson.com>

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index b71c69a..c47828f 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -47,7 +47,7 @@

 /*
  * Connection hash size. Default is what was selected at compile time.
-*/
+ */
 int ip_vs_conn_tab_bits = CONFIG_IP_VS_TAB_BITS;
 module_param_named(conn_tab_bits, ip_vs_conn_tab_bits, int, 0444);
 MODULE_PARM_DESC(conn_tab_bits, "Set connections' hash size");
@@ -56,23 +56,12 @@ MODULE_PARM_DESC(conn_tab_bits, "Set connections' hash size");
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
@@ -153,7 +142,7 @@ static unsigned int ip_vs_conn_hashkey(int af, unsigned proto,
  *	Hashes ip_vs_conn in ip_vs_conn_tab by proto,addr,port.
  *	returns bool success.
  */
-static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
+static inline int ip_vs_conn_hash(struct net *net, struct ip_vs_conn *cp)
 {
 	unsigned hash;
 	int ret;
@@ -168,7 +157,7 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
 	spin_lock(&cp->lock);

 	if (!(cp->flags & IP_VS_CONN_F_HASHED)) {
-		list_add(&cp->c_list, &ip_vs_conn_tab[hash]);
+		list_add(&cp->c_list, &net->ipvs->conn_tab[hash]);
 		cp->flags |= IP_VS_CONN_F_HASHED;
 		atomic_inc(&cp->refcnt);
 		ret = 1;
@@ -221,18 +210,20 @@ static inline int ip_vs_conn_unhash(struct ip_vs_conn *cp)
  *	s_addr, s_port: pkt source address (foreign host)
  *	d_addr, d_port: pkt dest address (load balancer)
  */
-static inline struct ip_vs_conn *__ip_vs_conn_in_get
-(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
- const union nf_inet_addr *d_addr, __be16 d_port)
+static inline struct ip_vs_conn *
+__ip_vs_conn_in_get(struct net *net, int af, int protocol,
+		    const union nf_inet_addr *s_addr, __be16 s_port,
+		    const union nf_inet_addr *d_addr, __be16 d_port)
 {
 	unsigned hash;
 	struct ip_vs_conn *cp;
+	struct netns_ipvs *ipvs = net->ipvs;

 	hash = ip_vs_conn_hashkey(af, protocol, s_addr, s_port);

 	ct_read_lock(hash);

-	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
+	list_for_each_entry(cp, &ipvs->conn_tab[hash], c_list) {
 		if (cp->af == af &&
 		    ip_vs_addr_equal(af, s_addr, &cp->caddr) &&
 		    ip_vs_addr_equal(af, d_addr, &cp->vaddr) &&
@@ -251,16 +242,18 @@ static inline struct ip_vs_conn *__ip_vs_conn_in_get
 	return NULL;
 }

-struct ip_vs_conn *ip_vs_conn_in_get
-(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
- const union nf_inet_addr *d_addr, __be16 d_port)
+struct ip_vs_conn *
+ip_vs_conn_in_get(struct net *net, int af, int protocol,
+		  const union nf_inet_addr *s_addr, __be16 s_port,
+		  const union nf_inet_addr *d_addr, __be16 d_port)
 {
 	struct ip_vs_conn *cp;

-	cp = __ip_vs_conn_in_get(af, protocol, s_addr, s_port, d_addr, d_port);
-	if (!cp && atomic_read(&ip_vs_conn_no_cport_cnt))
-		cp = __ip_vs_conn_in_get(af, protocol, s_addr, 0, d_addr,
-					 d_port);
+	cp = __ip_vs_conn_in_get(net, af, protocol,
+				 s_addr, s_port, d_addr, d_port);
+	if (!cp && atomic_read(&net->ipvs->conn_no_cport_cnt))
+		cp = __ip_vs_conn_in_get(net, af, protocol,
+					 s_addr, 0, d_addr, d_port);

 	IP_VS_DBG_BUF(9, "lookup/in %s %s:%d->%s:%d %s\n",
 		      ip_vs_proto_name(protocol),
@@ -278,35 +271,41 @@ ip_vs_conn_in_get_proto(int af, const struct sk_buff *skb,
 			unsigned int proto_off, int inverse)
 {
 	__be16 _ports[2], *pptr;
+	struct net *net = dev_net(skb->dev);

 	pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
 	if (pptr == NULL)
 		return NULL;

+	BUG_ON(!net);
 	if (likely(!inverse))
-		return ip_vs_conn_in_get(af, iph->protocol,
+		return ip_vs_conn_in_get(net, af, iph->protocol,
 					 &iph->saddr, pptr[0],
 					 &iph->daddr, pptr[1]);
 	else
-		return ip_vs_conn_in_get(af, iph->protocol,
+		return ip_vs_conn_in_get(net, af, iph->protocol,
 					 &iph->daddr, pptr[1],
 					 &iph->saddr, pptr[0]);
 }
 EXPORT_SYMBOL_GPL(ip_vs_conn_in_get_proto);

-/* Get reference to connection template */
-struct ip_vs_conn *ip_vs_ct_in_get
-(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
- const union nf_inet_addr *d_addr, __be16 d_port)
+/*
+ *  Get reference to connection template
+ */
+struct ip_vs_conn *
+ip_vs_ct_in_get(struct net *net, int af, int protocol,
+		const union nf_inet_addr *s_addr, __be16 s_port,
+		const union nf_inet_addr *d_addr, __be16 d_port)
 {
 	unsigned hash;
 	struct ip_vs_conn *cp;
+	struct netns_ipvs *ipvs = net->ipvs;

 	hash = ip_vs_conn_hashkey(af, protocol, s_addr, s_port);

 	ct_read_lock(hash);

-	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
+	list_for_each_entry(cp, &ipvs->conn_tab[hash], c_list) {
 		if (cp->af == af &&
 		    ip_vs_addr_equal(af, s_addr, &cp->caddr) &&
 		    /* protocol should only be IPPROTO_IP if
@@ -341,12 +340,14 @@ struct ip_vs_conn *ip_vs_ct_in_get
  *	s_addr, s_port: pkt source address (inside host)
  *	d_addr, d_port: pkt dest address (foreign host)
  */
-struct ip_vs_conn *ip_vs_conn_out_get
-(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
- const union nf_inet_addr *d_addr, __be16 d_port)
+struct ip_vs_conn *
+ip_vs_conn_out_get(struct net *net, int af, int protocol,
+		   const union nf_inet_addr *s_addr, __be16 s_port,
+		   const union nf_inet_addr *d_addr, __be16 d_port)
 {
 	unsigned hash;
 	struct ip_vs_conn *cp, *ret=NULL;
+	struct netns_ipvs *ipvs = net->ipvs;

 	/*
 	 *	Check for "full" addressed entries
@@ -355,7 +356,7 @@ struct ip_vs_conn *ip_vs_conn_out_get

 	ct_read_lock(hash);

-	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
+	list_for_each_entry(cp, &ipvs->conn_tab[hash], c_list) {
 		if (cp->af == af &&
 		    ip_vs_addr_equal(af, d_addr, &cp->caddr) &&
 		    ip_vs_addr_equal(af, s_addr, &cp->daddr) &&
@@ -386,17 +387,19 @@ ip_vs_conn_out_get_proto(int af, const struct sk_buff *skb,
 			 unsigned int proto_off, int inverse)
 {
 	__be16 _ports[2], *pptr;
+	struct net *net = dev_net(skb->dev);

 	pptr = skb_header_pointer(skb, proto_off, sizeof(_ports), _ports);
 	if (pptr == NULL)
 		return NULL;

+	BUG_ON(!net);
 	if (likely(!inverse))
-		return ip_vs_conn_out_get(af, iph->protocol,
+		return ip_vs_conn_out_get(net, af, iph->protocol,
 					  &iph->saddr, pptr[0],
 					  &iph->daddr, pptr[1]);
 	else
-		return ip_vs_conn_out_get(af, iph->protocol,
+		return ip_vs_conn_out_get(net, af, iph->protocol,
 					  &iph->daddr, pptr[1],
 					  &iph->saddr, pptr[0]);
 }
@@ -408,7 +411,7 @@ EXPORT_SYMBOL_GPL(ip_vs_conn_out_get_proto);
 void ip_vs_conn_put(struct ip_vs_conn *cp)
 {
 	unsigned long t = (cp->flags & IP_VS_CONN_F_ONE_PACKET) ?
-		0 : cp->timeout;
+			   0 : cp->timeout;
 	mod_timer(&cp->timer, jiffies+t);

 	__ip_vs_conn_put(cp);
@@ -418,19 +421,19 @@ void ip_vs_conn_put(struct ip_vs_conn *cp)
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

@@ -561,12 +564,12 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
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
@@ -638,7 +641,7 @@ static inline void ip_vs_unbind_dest(struct ip_vs_conn *cp)
  *	If available, return 1, otherwise invalidate this connection
  *	template and return 0.
  */
-int ip_vs_check_template(struct ip_vs_conn *ct)
+int ip_vs_check_template(struct net *net, struct ip_vs_conn *ct)
 {
 	struct ip_vs_dest *dest = ct->dest;

@@ -647,7 +650,7 @@ int ip_vs_check_template(struct ip_vs_conn *ct)
 	 */
 	if ((dest == NULL) ||
 	    !(dest->flags & IP_VS_DEST_F_AVAILABLE) ||
-	    (sysctl_ip_vs_expire_quiescent_template &&
+	    (net->ipvs->sysctl_expire_quiescent_template &&
 	     (atomic_read(&dest->weight) == 0))) {
 		IP_VS_DBG_BUF(9, "check_template: dest not available for "
 			      "protocol %s s:%s:%d v:%s:%d "
@@ -668,7 +671,7 @@ int ip_vs_check_template(struct ip_vs_conn *ct)
 				ct->dport = htons(0xffff);
 				ct->vport = htons(0xffff);
 				ct->cport = 0;
-				ip_vs_conn_hash(ct);
+				ip_vs_conn_hash(net, ct);
 			}
 		}

@@ -720,16 +723,17 @@ static void ip_vs_conn_expire(unsigned long data)
 		if (unlikely(cp->app != NULL))
 			ip_vs_unbind_app(cp);
 		ip_vs_unbind_dest(cp);
+		BUG_ON(!cp->net);
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
@@ -748,18 +752,22 @@ void ip_vs_conn_expire_now(struct ip_vs_conn *cp)


 /*
- *	Create a new connection entry and hash it into the ip_vs_conn_tab
+ *	Create a new connection entry and hash it into the ip_vs_conn_tab,
+ * 	netns ptr will be stored in ip_vs_con here.
  */
 struct ip_vs_conn *
-ip_vs_conn_new(int af, int proto, const union nf_inet_addr *caddr, __be16 cport,
+ip_vs_conn_new(struct net *net, int af, int proto,
+	       const union nf_inet_addr *caddr, __be16 cport,
 	       const union nf_inet_addr *vaddr, __be16 vport,
-	       const union nf_inet_addr *daddr, __be16 dport, unsigned flags,
-	       struct ip_vs_dest *dest)
+	       const union nf_inet_addr *daddr, __be16 dport,
+	       unsigned flags, struct ip_vs_dest *dest)
 {
 	struct ip_vs_conn *cp;
-	struct ip_vs_protocol *pp = ip_vs_proto_get(proto);
+	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, proto);
+	struct ip_vs_protocol *pp;
+	struct netns_ipvs *ipvs = net->ipvs;

-	cp = kmem_cache_zalloc(ip_vs_conn_cachep, GFP_ATOMIC);
+	cp = kmem_cache_zalloc(ipvs->conn_cachep, GFP_ATOMIC);
 	if (cp == NULL) {
 		IP_VS_ERR_RL("%s(): no memory\n", __func__);
 		return NULL;
@@ -790,9 +798,9 @@ ip_vs_conn_new(int af, int proto, const union nf_inet_addr *caddr, __be16 cport,
 	atomic_set(&cp->n_control, 0);
 	atomic_set(&cp->in_pkts, 0);

-	atomic_inc(&ip_vs_conn_count);
+	atomic_inc(&ipvs->conn_count);
 	if (flags & IP_VS_CONN_F_NO_CPORT)
-		atomic_inc(&ip_vs_conn_no_cport_cnt);
+		atomic_inc(&ipvs->conn_no_cport_cnt);

 	/* Bind the connection with a destination server */
 	ip_vs_bind_dest(cp, dest);
@@ -808,12 +816,14 @@ ip_vs_conn_new(int af, int proto, const union nf_inet_addr *caddr, __be16 cport,
 	else
 #endif
 		ip_vs_bind_xmit(cp);
-
-	if (unlikely(pp && atomic_read(&pp->appcnt)))
-		ip_vs_bind_app(cp, pp);
-
+	cp->net = net;	/* netns ptr  needed in timer */
+	if( pd ) {
+		pp = pd->pp;
+		if (unlikely(pp && atomic_read(&pd->appcnt)))
+			ip_vs_bind_app(net, cp, pp);
+	}
 	/* Hash it in the ip_vs_conn_tab finally */
-	ip_vs_conn_hash(cp);
+	ip_vs_conn_hash(net, cp);

 	return cp;
 }
@@ -824,16 +834,33 @@ ip_vs_conn_new(int af, int proto, const union nf_inet_addr *caddr, __be16 cport,
  */
 #ifdef CONFIG_PROC_FS

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
+static inline void *ipvs_seq_priv_get(struct seq_file *seq)
+{
+	return ((struct ipvs_private *)seq->private)->private;
+}
+
 static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
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
+				ipvs_seq_priv_set(seq, &ipvs->conn_tab[idx]);
 				return cp;
 			}
 		}
@@ -845,15 +872,17 @@ static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)

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
@@ -863,27 +892,28 @@ static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
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
@@ -928,7 +958,16 @@ static const struct seq_operations ip_vs_conn_seq_ops = {

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
@@ -936,7 +975,8 @@ static const struct file_operations ip_vs_conn_fops = {
 	.open    = ip_vs_conn_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_private,
+
 };

 static const char *ip_vs_origin_name(unsigned flags)
@@ -991,7 +1031,17 @@ static const struct seq_operations ip_vs_conn_sync_seq_ops = {

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
@@ -999,7 +1049,7 @@ static const struct file_operations ip_vs_conn_sync_fops = {
 	.open    = ip_vs_conn_sync_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_private,
 };

 #endif
@@ -1036,11 +1086,14 @@ static inline int todrop_entry(struct ip_vs_conn *cp)
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
@@ -1053,7 +1106,7 @@ void ip_vs_random_dropentry(void)
 		 */
 		ct_write_lock_bh(hash);

-		list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
+		list_for_each_entry(cp, &ipvs->conn_tab[hash], c_list) {
 			if (cp->flags & IP_VS_CONN_F_TEMPLATE)
 				/* connection template */
 				continue;
@@ -1091,11 +1144,13 @@ void ip_vs_random_dropentry(void)

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
@@ -1104,7 +1159,7 @@ static void ip_vs_conn_flush(void)
 		 */
 		ct_write_lock_bh(idx);

-		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
+		list_for_each_entry(cp, &ipvs->conn_tab[idx], c_list) {

 			IP_VS_DBG(4, "del connection\n");
 			ip_vs_conn_expire_now(cp);
@@ -1118,16 +1173,17 @@ static void ip_vs_conn_flush(void)

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
@@ -1136,19 +1192,26 @@ int __init ip_vs_conn_init(void)
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
@@ -1158,31 +1221,46 @@ int __init ip_vs_conn_init(void)
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

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
